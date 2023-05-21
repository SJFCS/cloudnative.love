> 本文基于笔者 2019 Golang meetup 杭州站分享整理

云原生技术大潮已经来临，技术变革迫在眉睫。  
在这股技术潮流之中，网易推出了轻舟微服务云平台，集成了微服务、Servicemesh、容器云、DevOps等，已经广泛应用于公司集团内部，同时也支撑了很多外部客户的云原生化改造和迁移。  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/qingzhou.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/qingzhou.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/qingzhou.png") 在这其中，日志是平时很容易被人忽视的一部分，却是微服务、DevOps的重要一环。没有日志，服务问题排查无从谈起，同时日志的统一采集也是很多业务数据分析、处理、审计的基础。  
但是在云原生容器化环境下，日志的采集又变得有点不同。

对于传统的物理机或者虚拟机部署的服务，日志采集工作清晰明了。  
业务日志直接输出到宿主机上，服务运行在固定的节点上，手动或者拿自动化工具把日志采集agent部署在节点上，加一下agent的配置，然后就可以开始采集日志了。同时为了方便后续的日志配置修改，还可以引入一个配置中心，用来下发agent配置。

而在Kubernetes环境中，情况就没这么简单了。  
一个Kubernetes node节点上有很多不同服务的容器在运行，容器的日志存储方式有很多不同的类型，例如stdout、hostPath、emptyDir、pv等。由于在Kubernetes集群中经常存在Pod主动或者被动的迁移，频繁的销毁、创建，我们无法和传统的方式一样人为的给每个服务下发日志采集配置。另外，由于日志数据采集后会被集中存储，所以查询日志时，可以根据namespace、pod、container、node，甚至包括容器的环境变量、label等维度来检索、过滤很重要。  
以上都是有别于传统日志采集配置方式的需求和痛点，究其原因，还是因为传统的方式脱离了Kubernetes，无法感知Kubernetes，更无法和Kubernetes集成。  
随着最近几年的迅速发展，Kubernetes已经成为容器编排的事实标准，甚至可以被认为是新一代的分布式操作系统。在这个新型的操作系统中，controller的设计思路驱动了整个系统的运行。controller的抽象解释如下图所示：

![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/controller.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/controller.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/controller.png")

由于Kubernetes良好的可扩展性，Kubernetes设计了一种自定义资源CRD的概念，用户可以自己定义各种资源，并借助一些framework开发controller，使用controller将我们的期望变成现实。  
基于这个思路，对于日志采集来说，一个服务需要采集哪些日志，需要什么样的日志配置，是用户的期望，而这一切，就需要我们开发一个日志采集的controller去实现。

![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/log-controller.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/log-controller.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/log-controller.png")

有了上面的解决思路，除了开发一个controller，剩下的就是围绕着这个思路的一些选型分析。

日志采集controller只负责对接Kubernetes，生成采集配置，并不负责真正的日志采集。目前市面上的日志采集agent有很多，例如传统ELK技术栈的Logstash，CNCF已毕业项目Fluentd，最近推出不久的Loki，还有beats系列的Filebeat。 下面简单分析一下。

-   Logstash基于JVM，分分钟内存占用达到几百MB甚至上GB，有点重，首先被我们排除。
-   Fluentd背靠CNCF看着不错，各种插件也多，不过基于Ruby和C编写，对于我们团队的技术栈来说，还是让人止于观望。虽然Fluentd还推出了存粹基于C语言的Fluentd-bit项目，内存占用很小，看着十分诱惑，但是使用C语言和不能动态reload配置，还是无法令人亲近。
-   Loki推出的时间不久，目前还是功能有限，而且一些压测数据表明性能不太好，暂持观望。
-   Filebeat和Logstash、Kibana、Elasticsearch同属Elastic公司，轻量级日志采集agent，推出就是为了替换Logstash，基于Golang编写，和我们团队技术栈完美契合，实测下来个方面性能、资源占用率都比较优秀，于是成为了我们日志采集agent第一选择。

对于日志采集agent，在Kubernetes环境下一般有两种部署方式。

1.  一种为sidecar的方式，即和业务container部署在同一个Pod里，这种方式下，Filebeat只采集该业务container的日志，也只需配置该container的日志配置，简单、隔离性好，但最大的问题是， 每个服务都要有一个Filebeat去采集，通常一个节点上有很多的Pod，加起来的内存等开销不容乐观。
2.  另外一种也是最常见的每个Node上部署一个Filebeat容器，相比而言，内存占用一般要小很多，而且对Pod无侵入性，比较符合我们的常规使用方式。同时一般使用Kubernetes的DaemonSet部署，免去了传统的类似Ansible等自动化运维工具，部署运维效率大大提升。所以我们优先使用Daemonset部署Filebeat的方式。

选择Filebeat作为日志采集agent，集成了自研的日志controller后，从节点的视角，我们看到的架构如下所示：  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch-new.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch-new.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/arch-new.png")

1.  日志平台下发具体的CRD实例到Kubernetes集群中，日志controller Ripple则负责从Kubernetes中List&Watch Pod和CRD实例。
2.  通过Ripple的过滤、聚合最终生成一个Filebeat的input配置文件，配置文件里描述了服务的采集Path路径、多行日志匹配等配置，同时还会默认把例如PodName、Hostname等配置到日志元信息中。
3.  Filebeat则根据Ripple生成的配置，自动reload并采集节点上的日志，发送至Kafka或者Elasticsearch等。

由于Ripple监听了Kubernetes事件，可以感知到Pod的生命周期，不管Pod销毁还是调度到任意的节点，依然能够自动生成相应的Filebeat配置，无需人工干预。  
Ripple能感知到Pod挂载的日志Volume，不管是docker Stdout的日志，还是使用HostPath、EmptyDir、Pv存储日志，均可以生成节点上的日志路径，告知Filebeat去采集。  
Ripple可以同时获取CRD和Pod的信息，所以除了默认给日志配置加上PodName等元信息外，还可以结合容器环境变量、Pod label、Pod Annotation等给日志打标，方便后续日志的过滤、检索查询。 除此之外，我们还给Ripple加入了日志定时清理，确保日志不丢失等功能，进一步增强了日志采集的功能和稳定性。

一般情况下Filebeat可满足大部分的日志采集需求，但是仍然避免不了一些特殊的场景需要我们对Filebeat进行定制化开发，当然Filebeat本身的设计也提供了良好的扩展性。 Filebeat目前只提供了像elasticsearch、Kafka、logstash等几类output客户端，如果我们想要Filebeat直接发送至其他后端，需要定制化开发自己的output。同样，如果需要对日志做过滤处理或者增加元信息，也可以自制processor插件。 无论是增加output还是写个processor，Filebeat提供的大体思路基本相同。一般来讲有3种方式：

1.  直接fork Filebeat，在现有的源码上开发。output或者processor都提供了类似Run、Stop等的接口，只需要实现该类接口，然后在init方法中注册相应的插件初始化方法即可。当然，由于Golang中init方法是在import包时才被调用，所以需要在初始化Filebeat的代码中手动import。
2.  复制一份Filebeat的main.go，import我们自研的插件库，然后重新编译。本质上和方式1区别不大。
3.  Filebeat还提供了基于Golang plugin的插件机制，需要把自研的插件编译成.so共享链接库，然后在Filebeat启动参数中通过-plugin指定库所在路径。不过实际上一方面Golang plugin还不够成熟稳定，一方面自研的插件依然需要依赖相同版本的libbeat库，而且还需要相同的Golang版本编译，坑可能更多，不太推荐。  
    如果想要了解更多关于Filebeat的设计，可以参考我们的这篇文章。(`https://juejin.im/post/5d29376ae51d45507022702e`)

为了支持对接各种业务方，我们目前已经扩展开发了grpc output，支持多Kafka集群的output等。

但是，真正的困难是在业务方实际使用之后，各种采集不到日志，多行日志配置或者采集二进制大文件导致Filebeat oom等问题接踵而至。我们又投入了更多的时间在对Filebeat和日志采集的全方位监控上，例如：

1.  接入轻舟监控平台，有磁盘io、网络流量传输、内存占用、cpu使用、pod事件报警等，确保基础监控的完善。
2.  加入了日志平台数据全链路延迟监控。
3.  采集Filebeat自身日志，通过自身日志上报哪些日志文件开始采集，什么时候采集结束，避免每次都需要ssh到各种节点上查看日志配置排查问题。
4.  自研Filebeat exporter，接入prometheus，采集上报自身metrics数据。

通过立体化的监控增强，大大方便了我们问题的排查，减少了运维和人力成本，也更确保了服务的稳定性。

从Docker到Kubernetes，从Istio到Knative，基于Golang的开源项目已然是云原生生态体系的主力军，Golang的简洁高效也不断吸引着新的项目采用它作为开发语言。  
除了使用Golang写Filebeat插件、开发日志采集的controller，我们轻舟微服务平台还有很多基于Golang的组件，这其中，我们踩过很多坑，也积累了一些Golang优化的经验。  
但是很多时候，我们看过太多GC原理、内存优化、性能优化，却往往在写完代码、做完一个项目的时候，无从下手。 实践是检验真理的唯一标准。 所以，亲自动手去排查、摸索，才是提升姿势水平、找到关键问题的捷径。  
对于性能优化，Golang贴心的为我们提供了三把钥匙：

-   go benchmark
-   go pprof
-   go trace

下面举个简单的示例。  
以sync.Pool为例，sync.Pool一般用于保存和复用临时对象，减少内存分配，降低GC压力。有很多的应用场景，例如号称比Golang官方Http快10倍的FastHttp大量使用了sync.Pool，Filebeat使用sync.Pool将批量日志数据聚合成Batch分批发送，Nginx-Ingress-controller渲染生成nginx配置时，也使用sync.Pool优化渲染效率。我们的日志controller Ripple也同样使用了sync.Pool去优化渲染Filebeat配置时的性能。

首先，使用go benchmark压测一下未使用sync.Pool时通过go template渲染出Filebeat配置的方法。  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench0.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench0.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench0.png") 可以看到结果显示的每次执行方法的时间，和分配的内存。

然后将go benchmark生成的profile文件，使用go pprof看下观察一下整体的性能数据。  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/pprof0.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/pprof0.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/pprof0.png") go pprof实际上有很多的数据可以供我们观察，这里仅展示一下内存的分配信息。可以看到benchmark的这段时间内共申请了多达5个多G的内存。  
接着，我们使用go trace查看压测过程中的goroutine，堆内存，GC等信息。  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/trace0.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/trace0.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/trace0.png") 这里仅截取600ms至700ms的时间段，可以很清楚的在图中看到这100ms内发生了170次的GC。

同样的方法和步骤，压测一下使用sync.Pool后的结果。  
![https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench1.png](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench1.png "https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/bench1.png") 分配的内存总量减小至了160MB，而相同的时间段内GC次数也减少到了5次。差距十分明显。

在云原生时代，日志做为可观测性的一部分，是我们排查、解决问题的基础，也是后续大数据分析处理的开始。  
在这个领域，虽然有很多开源项目，却仍然没有一个强力而统一的日志采集agent，或许这种百花齐放的景象会一直持续下去。所以，我们自研日志agent Ripple的设计中也提出了更多的抽象，保留了对接其他日志采集agent的能力。后续我们计划支持更多的日志采集agent，打造一个更加丰富、健壮的云原生日志采集系统。