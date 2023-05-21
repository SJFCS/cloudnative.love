---
title: 容器日志采集利器：Filebeat深度剖析与实践
---
在云原生时代和容器化浪潮中，容器的日志采集是一个看起来不起眼却又无法忽视的重要议题。对于容器日志采集我们常用的工具有Filebeat和Fluentd，两者对比各有优劣，相比基于ruby的Fluentd，考虑到可定制性，我们一般默认选择golang技术栈的Filebeat作为主力的日志采集agent。  
相比较传统的日志采集方式，容器化下单节点会运行更多的服务，负载也会有更短的生命周期，而这些更容易对日志采集agent造成压力，虽然Filebeat足够轻量级和高性能，但如果不了解Filebeat的机制，不合理的配置Filebeat，实际的生产环境使用中可能也会给我们带来意想不到的麻烦和难题。

日志采集的功能看起来不复杂，主要功能无非就是找到配置的日志文件，然后读取并处理，发送至相应的后端如elasticsearch,kafka等。  
Filebeat官网有张示意图，如下所示：

![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/filebeat.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/filebeat.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/filebeat.png")

针对每个日志文件，Filebeat都会启动一个harvester协程，即一个goroutine，在该goroutine中不停的读取日志文件，直到文件的EOF末尾。一个最简单的表示采集目录的input配置大概如下所示：

```
filebeat.inputs:
- type: log
  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /var/log/*.log
```

不同的harvester goroutine采集到的日志数据都会发送至一个全局的队列queue中，queue的实现有两种：基于内存和基于磁盘的队列，目前基于磁盘的队列还是处于alpha阶段，Filebeat默认启用的是基于内存的缓存队列。  
每当队列中的数据缓存到一定的大小或者超过了定时的时间（默认1s)，会被注册的client从队列中消费，发送至配置的后端。目前可以设置的client有kafka、elasticsearch、redis等。

虽然这一切看着挺简单，但在实际使用中，我们还是需要考虑更多的问题，例如：

-   日志文件是如何被filbebeat发现又是如何被采集的？
-   Filebeat是如何确保日志采集发送到远程的存储中，不丢失一条数据的？
-   如果Filebeat挂掉，下次采集如何确保从上次的状态开始而不会重新采集所有日志？
-   Filebeat的内存或者cpu占用过多，该如何分析解决？
-   Filebeat如何支持docker和kubernetes，如何配置容器化下的日志采集？
-   想让Filebeat采集的日志发送至的后端存储，如果原生不支持，怎样定制化开发？

这些均需要对Filebeat有更深入的理解，下面让我们跟随Filebeat的源码一起探究其中的实现机制。

Filebeat源码归属于beats项目，而beats项目的设计初衷是为了采集各类的数据，所以beats抽象出了一个libbeat库，基于libbeat我们可以快速的开发实现一个采集的工具，除了Filebeat，还有像metricbeat、packetbeat等官方的项目也是在beats工程中。  
如果我们大致看一下代码就会发现，libbeat已经实现了内存缓存队列memqueue、几种output日志发送客户端，数据的过滤处理processor等通用功能，而Filebeat只需要实现日志文件的读取等和日志相关的逻辑即可。

从代码的实现角度来看，Filebeat大概可以分以下几个模块：

-   input: 找到配置的日志文件，启动harvester
-   harvester: 读取文件，发送至spooler
-   spooler: 缓存日志数据，直到可以发送至publisher
-   publisher: 发送日志至后端，同时通知registrar
-   registrar: 记录日志文件被采集的状态

对于日志文件的采集和生命周期管理，Filebeat抽象出一个Crawler的结构体， 在Filebeat启动后，crawler会根据配置创建，然后遍历并运行每个input：

```
for _, inputConfig := range c.inputConfigs {
err := c.startInput(pipeline, inputConfig, r.GetStates())
}
```

在每个input运行的逻辑里，首先会根据配置获取匹配的日志文件，需要注意的是，这里的匹配方式并非正则，而是采用linux glob的规则，和正则还是有一些区别。

```
matches, err := filepath.Glob(path)
```

获取到了所有匹配的日志文件之后，会经过一些复杂的过滤，例如如果配置了`exclude_files`则会忽略这类文件，同时还会查询文件的状态，如果文件的最近一次修改时间大于`ignore_older`的配置，也会不去采集该文件。

匹配到最终需要采集的日志文件之后，Filebeat会对每个文件启动harvester goroutine，在该goroutine中不停的读取日志，并发送给内存缓存队列memqueue。  
在`(h *Harvester) Run()`方法中，我们可以看到这么一个无限循环，省略了一些逻辑的代码如下所示：

```
for {
message, err := h.reader.Next()
if err != nil {
switch err {
case ErrFileTruncate:
logp.Info("File was truncated. Begin reading file from offset 0: %s", h.state.Source)
h.state.Offset = 0
filesTruncated.Add(1)
case ErrRemoved:
logp.Info("File was removed: %s. Closing because close_removed is enabled.", h.state.Source)
case ErrRenamed:
logp.Info("File was renamed: %s. Closing because close_renamed is enabled.", h.state.Source)
case ErrClosed:
logp.Info("Reader was closed: %s. Closing.", h.state.Source)
case io.EOF:
logp.Info("End of file reached: %s. Closing because close_eof is enabled.", h.state.Source)
case ErrInactive:
logp.Info("File is inactive: %s. Closing because close_inactive of %v reached.", h.state.Source, h.config.CloseInactive)
default:
logp.Err("Read line error: %v; File: %v", err, h.state.Source)
}
return nil
}
...
if !h.sendEvent(data, forwarder) {
return nil
}
}
```

可以看到，reader.Next()方法会不停的读取日志，如果没有返回异常，则发送日志数据到缓存队列中。  
返回的异常有几种类型，除了读取到EOF外，还会有例如文件一段时间不活跃等情况发生会使harvester goroutine退出，不再采集该文件，并关闭文件句柄。  
Filebeat为了防止占据过多的采集日志文件的文件句柄，默认的`close_inactive`参数为5min，如果日志文件5min内没有被修改，上面代码会进入ErrInactive的case，之后该harvester goroutine会被关闭。  
这种场景下还需要注意的是，如果某个文件日志采集中被移除了，但是由于此时被Filebeat保持着文件句柄，文件占据的磁盘空间会被保留直到harvester goroutine结束。

在memqueue被初始化时，Filebeat会根据配置`min_event`是否大于1创建BufferingEventLoop或者DirectEventLoop，一般默认都是BufferingEventLoop，即带缓冲的队列。

```
type bufferingEventLoop struct {
broker *Broker

buf        *batchBuffer
flushList  flushList
eventCount int

minEvents    int
maxEvents    int
flushTimeout time.Duration

// active broker API channels
events    chan pushRequest
get       chan getRequest
pubCancel chan producerCancelRequest

// ack handling
acks        chan int      // ackloop -> eventloop : total number of events ACKed by outputs
schedACKS   chan chanList // eventloop -> ackloop : active list of batches to be acked
pendingACKs chanList      // ordered list of active batches to be send to the ackloop
ackSeq      uint          // ack batch sequence number to validate ordering

// buffer flush timer state
timer *time.Timer
idleC <-chan time.Time
}

```

BufferingEventLoop是一个实现了Broker、带有各种channel的结构，主要用于将日志发送至consumer消费。 BufferingEventLoop的run方法中，同样是一个无限循环，这里可以认为是一个日志事件的调度中心。

```
for {
select {
case <-broker.done:
return
case req := <-l.events: // producer pushing new event
l.handleInsert(&req)
case req := <-l.get: // consumer asking for next batch
l.handleConsumer(&req)
case count := <-l.acks:
l.handleACK(count)
case <-l.idleC:
l.idleC = nil
l.timer.Stop()
if l.buf.length() > 0 {
l.flushBuffer()
}
}
}
```

上文中harvester goroutine每次读取到日志数据之后，最终会被发送至bufferingEventLoop中的`events chan pushRequest` channel，然后触发上面`req := <-l.events`的case，handleInsert方法会把数据添加至bufferingEventLoop的buf中，buf即memqueue实际缓存日志数据的队列，如果buf长度超过配置的最大值或者bufferingEventLoop中的timer定时器触发了`case <-l.idleC`，均会调用flushBuffer()方法。  
flushBuffer()又会触发`req := <-l.get`的case，然后运行handleConsumer方法，该方法中最重要的是这一句代码：

```
req.resp <- getResponse{ackChan, events}
```

这里获取到了consumer消费者的response channel，然后发送数据给这个channel。真正到这，才会触发consumer对memqueue的消费。所以，其实memqueue并非一直不停的在被consumer消费，而是在memqueue通知consumer的时候才被消费，我们可以理解为一种脉冲式的发送。

实际上，早在Filebeat初始化的时候，就已经创建了一个eventConsumer并在loop无限循环方法里试图从Broker中获取日志数据。

```
for {
if !paused && c.out != nil && consumer != nil && batch == nil {
out = c.out.workQueue
queueBatch, err := consumer.Get(c.out.batchSize)
...
batch = newBatch(c.ctx, queueBatch, c.out.timeToLive)
}
...
select {
case <-c.done:
return
case sig := <-c.sig:
handleSignal(sig)
case out <- batch:
batch = nil
}
}

```

上面consumer.Get就是消费者consumer从Broker中获取日志数据，然后发送至out的channel中被output client发送，我们看一下Get方法里的核心代码：

```
select {
case c.broker.requests <- getRequest{sz: sz, resp: c.resp}:
case <-c.done:
return nil, io.EOF
}

// if request has been send, we do have to wait for a response
resp := <-c.resp
return &batch{
consumer: c,
events:   resp.buf,
ack:      resp.ack,
state:    batchActive,
}, nil

```

getRequest的结构如下：

```
type getRequest struct {
sz   int              // request sz events from the broker
resp chan getResponse // channel to send response to
}
```

getResponse的结构：

```
type getResponse struct {
ack *ackChan
buf []publisher.Event
}
```

getResponse里包含了日志的数据，而getRequest包含了一个发送至消费者的channel。  
在上文bufferingEventLoop缓冲队列的handleConsumer方法里接收到的参数为getRequest，里面包含了consumer请求的getResponse channel。  
如果handleConsumer不发送数据，consumer.Get方法会一直阻塞在select中，直到flushBuffer，consumer的getResponse channel才会接收到日志数据。

在创建beats时，会创建一个clientWorker，clientWorker的run方法中，会不停的从consumer发送的channel里读取日志数据，然后调用client.Publish批量发送日志。

```
func (w *clientWorker) run() {
for !w.closed.Load() {
for batch := range w.qu {
if err := w.client.Publish(batch); err != nil {
return
}
}
}
}

```

libbeats库中包含了kafka、elasticsearch、logstash等几种client，它们均实现了client接口：

```
type Client interface {
Close() error
Publish(publisher.Batch) error
String() string
}
```

当然最重要的是实现Publish接口，然后将日志发送出去。

实际上，Filebeat中日志数据在各种channel里流转的设计还是比较复杂和繁琐的，笔者也是研究了好久、画了很长的架构图才理清楚其中的逻辑。 这里抽出了一个简化后的图以供参考：  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch.png")

Filebeat维护了一个registry文件在本地的磁盘，该registry文件维护了所有已经采集的日志文件的状态。 实际上，每当日志数据发送至后端成功后，会返回ack事件。Filebeat启动了一个独立的registry协程负责监听该事件，接收到ack事件后会将日志文件的State状态更新至registry文件中，State中的Offset表示读取到的文件偏移量，所以Filebeat会保证Offset记录之前的日志数据肯定被后端的日志存储接收到。  
State结构如下所示：

```
type State struct {
Id          string            `json:"-"` // local unique id to make comparison more efficient
Finished    bool              `json:"-"` // harvester state
Fileinfo    os.FileInfo       `json:"-"` // the file info
Source      string            `json:"source"`
Offset      int64             `json:"offset"`
Timestamp   time.Time         `json:"timestamp"`
TTL         time.Duration     `json:"ttl"`
Type        string            `json:"type"`
Meta        map[string]string `json:"meta"`
FileStateOS file.StateOS
}
```

记录在registry文件中的数据大致如下所示：

```
[{"source":"/tmp/aa.log","offset":48,"timestamp":"2019-07-03T13:54:01.298995+08:00","ttl":-1,"type":"log","meta":null,"FileStateOS":{"inode":7048952,"device":16777220}}]
```

由于文件可能会被改名或移动，Filebeat会根据inode和设备号来标志每个日志文件。  
如果Filebeat异常重启，每次采集harvester启动的时候都会读取registry文件，从上次记录的状态继续采集，确保不会从头开始重复发送所有的日志文件。  
当然，如果日志发送过程中，还没来得及返回ack，Filebeat就挂掉，registry文件肯定不会更新至最新的状态，那么下次采集的时候，这部分的日志就会重复发送，所以这意味着Filebeat只能保证at least once，无法保证不重复发送。  
还有一个比较异常的情况是，linux下如果老文件被移除，新文件马上创建，很有可能它们有相同的inode，而由于Filebeat根据inode来标志文件记录采集的偏移，会导致registry里记录的其实是被移除的文件State状态，这样新的文件采集却从老的文件Offset开始，从而会遗漏日志数据。  
为了尽量避免inode被复用的情况，同时防止registry文件随着时间增长越来越大，建议使用clean\_inactive和clean\_remove配置将长时间未更新或者被删除的文件State从registry中移除。

同时我们可以发现在harvester读取日志中，会更新registry的状态处理一些异常场景。例如，如果一个日志文件被清空，Filebeat会在下一次Reader.Next方法中返回ErrFileTruncate异常，将inode标志文件的Offset置为0，结束这次harvester，重新启动新的harvester，虽然文件不变，但是registry中的Offset为0，采集会从头开始。

特别注意的是，如果使用容器部署Filebeat，需要将registry文件挂载到宿主机上，否则容器重启后registry文件丢失，会使Filebeat从头开始重复采集日志文件。

目前Filebeat支持reload input配置，module配置，但reload的机制只有定时更新。  
在配置中打开reload.enable之后，还可以配置reload.period表示自动reload配置的时间间隔。  
Filebeat在启动时，会创建一个专门用于reload的协程。对于每个正在运行的harvester，Filebeat会将其加入一个全局的Runner列表，每次到了定时的间隔后，会触发一次配置文件的diff判断，如果是需要停止的加入stopRunner列表，然后逐个关闭，新的则加入startRunner列表，启动新的Runner。

Filebeat官方文档提供了在kubernetes下基于daemonset的部署方式，最主要的一个配置如下所示：

```
    - type: docker
      containers.ids:
      - "*"
      processors:
        - add_kubernetes_metadata:
            in_cluster: true
```

即设置输入input为docker类型。由于所有的容器的标准输出日志默认都在节点的`/var/lib/docker/containers/<containerId>/*-json.log`路径，所以本质上采集的是这类日志文件。  
和传统的部署方式有所区别的是，如果服务部署在kubernetes上，我们查看和检索日志的维度不能仅仅局限于节点和服务，还需要有podName，containerName等，所以每条日志我们都需要打标增加kubernetes的元信息才发送至后端。  
Filebeat会在配置中增加了add\_kubernetes\_metadata的processor的情况下，启动监听kubernetes的watch服务，监听所有kubernetes pod的变更，然后将归属本节点的pod最新的事件同步至本地的缓存中。  
节点上一旦发生容器的销毁创建，/var/lib/docker/containers/下会有目录的变动，Filebeat根据路径提取出containerId，再根据containerId从本地的缓存中找到pod信息，从而可以获取到podName、label等数据，并加到日志的元信息fields中。  
Filebeat还有一个beta版的功能autodiscover，autodiscover的目的是把分散到不同节点上的Filebeat配置文件集中管理。目前也支持kubernetes作为provider，本质上还是监听kubernetes事件然后采集docker的标准输出文件。  
大致架构如下所示：  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/logagent.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/logagent.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/logagent.png") 但是在实际生产环境使用中，仅采集容器的标准输出日志还是远远不够，我们往往还需要采集容器挂载出来的自定义日志目录，还需要控制每个服务的日志采集方式以及更多的定制化功能。

在轻舟容器云上，我们自研了一个监听kubernetes事件自动生成Filebeat配置的agent，通过CRD的方式，支持自定义容器内部日志目录、支持自定义fields、支持多行读取等功能。同时可在kubernetes上统一管理各种日志配置，而且无需用户感知pod的创建销毁和迁移，自动完成各种场景下的日志配置生成和更新。

虽然beats系列主打轻量级，虽然用golang写的Filebeat的内存占用确实比较基于jvm的logstash等好太多，但是事实告诉我们其实没那么简单。  
正常启动Filebeat，一般确实只会占用3、40MB内存，但是在轻舟容器云上偶发性的我们也会发现某些节点上的Filebeat容器内存占用超过配置的pod limit限制（一般设置为200MB），并且不停的触发的OOM。  
究其原因，一般容器化环境中，特别是裸机上运行的容器个数可能会比较多，导致创建大量的harvester去采集日志。如果没有很好的配置Filebeat，会有较大概率导致内存急剧上升。  
当然，Filebeat内存占据较大的部分还是memqueue，所有采集到的日志都会先发送至memqueue聚集，再通过output发送出去。每条日志的数据在Filebeat中都被组装为event结构，Filebeat默认配置的memqueue缓存的event个数为4096，可通过`queue.mem.events`设置。默认最大的一条日志的event大小限制为10MB，可通过`max_bytes`设置。`4096 * 10MB = 40GB`，可以想象，极端场景下，Filebeat至少占据40GB的内存。特别是配置了multiline多行模式的情况下，如果multiline配置有误，单个event误采集为上千条日志的数据，很可能导致memqueue占据了大量内存，致使内存爆炸。  
所以，合理的配置日志文件的匹配规则，限制单行日志大小，根据实际情况配置memqueue缓存的个数，才能在实际使用中规避Filebeat的内存占用过大的问题。

一般情况下Filebeat可满足大部分的日志采集需求，但是仍然避免不了一些特殊的场景需要我们对Filebeat进行定制化开发，当然Filebeat本身的设计也提供了良好的扩展性。  
beats目前只提供了像elasticsearch、kafka、logstash等几类output客户端，如果我们想要Filebeat直接发送至其他后端，需要定制化开发自己的output。同样，如果需要对日志做过滤处理或者增加元信息，也可以自制processor插件。  
无论是增加output还是写个processor，Filebeat提供的大体思路基本相同。一般来讲有3种方式：

1.  直接fork Filebeat，在现有的源码上开发。output或者processor都提供了类似Run、Stop等的接口，只需要实现该类接口，然后在init方法中注册相应的插件初始化方法即可。当然，由于golang中init方法是在import包时才被调用，所以需要在初始化Filebeat的代码中手动import。
2.  复制一份Filebeat的main.go，import我们自研的插件库，然后重新编译。本质上和方式1区别不大。
3.  Filebeat还提供了基于golang plugin的插件机制，需要把自研的插件编译成.so共享链接库，然后在Filebeat启动参数中通过-plugin指定库所在路径。不过实际上一方面golang plugin还不够成熟稳定，一方面自研的插件依然需要依赖相同版本的libbeat库，而且还需要相同的golang版本编译，坑可能更多，不太推荐。