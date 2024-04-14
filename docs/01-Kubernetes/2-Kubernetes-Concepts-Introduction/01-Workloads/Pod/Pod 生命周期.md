---
title: Pod 生命周期
tags: [Kubernetes]
sidebar_position: 2
---
pod的生命周期，它主要包含下面的过程：

- pod创建过程
- 运行初始化容器（init container）过程
- 运行主容器（main container）
  - 容器启动后钩子（post start）、容器终止前钩子（pre stop）
  - 容器的存活性探测（liveness probe）、就绪性探测（readiness probe）
- pod终止过程


## Pod phase

在整个生命周期中，Pod会出现5种**状态**，分别如下：

- **Pending**：API Server创建了Pod资源对象并已经存入了etcd中，但是它并未被调度完成，或者仍然处于从仓库下载镜像的过程中。
- **Running**：Pod已经被调度到某节点之上，并且所有容器都已经被kubelet创建完成。
- **Succeeded**：Pod 中的所有容器都被成功终止，并且不会再重启。
- **Failed**：Pod 中的所有容器都已终止了，并且至少有一个容器是因为失败终止。也就是说，容器以非0状态退出或者被系统终止。
- **Unknown**：因为某些原因无法取得 Pod 的状态，通常是因为与 Pod 所在主机通信失败。


## Pod创建和终止

**pod的创建过程**

Pod 是Kubernetes的基础单元，了解其创建的过程，更有助于理解系统的运作。

1. 用户通过kubectl或其他api客户端提交需要创建的pod信息给apiServer
2. apiServer开始生成pod对象的信息，并将信息存入etcd，然后返回确认信息至客户端
3. apiServer开始反映etcd中的pod对象的变化，其它组件使用watch机制来跟踪检查apiServer上的变动
4. scheduler发现有新的pod对象要创建，开始为Pod分配主机并将结果信息更新至apiServer
5. node节点上的kubelet发现有pod调度过来，尝试调用runtime启动容器，并将结果回送至apiServer
6. apiServer将接收到的pod状态信息存入etcd中


**pod的终止过程**

1. 用户向apiServer发送删除pod对象的命令
2. apiServcer中的pod对象信息会随着时间的推移而更新，在宽限期内（默认30s），pod被视为dead
3. 将pod标记为terminating状态
4. kubelet在监控到pod对象转为terminating状态的同时启动pod关闭过程
5. 端点控制器监控到pod对象的关闭行为时将其从所有匹配到此端点的service资源的端点列表中移除
6. 如果当前pod对象定义了preStop钩子处理器，则在其标记为terminating后即会以同步的方式启动执行
7. pod对象中的容器进程收到停止信号
8. 宽限期结束后，若pod中还存在仍在运行的进程，那么pod对象会收到立即终止的信号
9. kubelet请求apiServer将此pod资源的宽限期设置为0从而完成删除操作，此时pod对于用户已不可见

### init容器

init容器是在pod的主容器启动之前要运行的容器，主要是做一些主容器的前置工作，它具有两大特征：

1. init容器必须运行完成直至结束，若某初始化容器运行失败，那么kubernetes需要重启它直到成功完成
2. init容器必须按照定义的顺序执行，当且仅当前一个成功之后，后面的一个才能运行


### 钩子函数

钩子函数能够感知自身生命周期中的事件，并在相应的时刻到来时运行用户指定的程序代码。

kubernetes在主容器的启动之后和停止之前提供了两个钩子函数：

- post start：容器创建之后执行，如果失败了会重启容器
- pre stop  ：容器终止之前执行，执行完成之后容器将成功终止，在其完成之前会阻塞删除容器的操作

钩子处理器支持使用下面三种方式定义动作：

- Exec命令：在容器内执行一次命令

 ```yaml
  ……
    lifecycle:
      postStart: 
        exec:
          command:
          - cat
          - /tmp/healthy
  ……
 ```

- TCPSocket：在当前容器尝试访问指定的socket

 ```yaml
  ……      
    lifecycle:
      postStart:
        tcpSocket:
          port: 8080
  ……
 ```

- HTTPGet：在当前容器中向某url发起http请求

 ```yaml
  ……
    lifecycle:
      postStart:
        httpGet:
          path: / #URI地址
          port: 80 #端口号
          host: 192.168.109.100 #主机地址
          scheme: HTTP #支持的协议，http或者https
  ……
 ```

### 容器探针

- Pod 提供三种探针：

1. StartupProbe：在启动探针成功前，阻止其他探针执行，成功后将不在进行探测。（如果服务第一次启动时间较长建议配置此参数，因为它不会参与容器生命周期内的健康检查，可降低LivenessProbe探测时间值，加快愈合速度，）

2. LivenessProbe：如果探测失败，kubelet会根据配置的[重启策略](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy)进行相应的处理。若没有配置该探针，默认就是success。

3. ReadinessProbe：指示容器是否准备好服务请求。如果就绪探测失败，端点控制器将从与 Pod 匹配的所有 Service 的端点中删除该 Pod 的 IP 地址。初始延迟之前的就绪状态默认为 `Failure`。如果容器不提供就绪探针，则默认状态为 `Success`。


- 探测方法：

- **ExecAction：**在容器内执行指定命令。如果命令退出时返回码为 0 则认为诊断成功。
- **TCPSocketAction：**对指定端口上的容器的 IP 地址进行 TCP 检查。如果端口打开，则诊断被认为是成功的。
- **HTTPGetAction：**对指定的端口和路径上的容器的 IP 地址执行 HTTP Get 请求。如果响应的状态码大于等于200 且小于 400，则诊断被认为是成功的。
- **grpc**:
      port: 99

- Exec命令：在容器内执行一次命令，如果命令执行的退出码为0，则认为程序正常，否则不正常

 ```yaml
  ……
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
  ……
 ```

- TCPSocket：将会尝试访问一个用户容器的端口，如果能够建立这条连接，则认为程序正常，否则不正常

 ```yaml
  ……      
    livenessProbe:
      tcpSocket:
        port: 8080
  ……
 ```

- HTTPGet：调用容器内Web应用的URL，如果返回的状态码在200和399之间，则认为程序正常，否则不正常

 ```yaml
  ……
    livenessProbe:
      httpGet:
        path: / #URI地址
        port: 80 #端口号
        host: 127.0.0.1 #主机地址
        scheme: HTTP #支持的协议，http或者https
  ……
 ```
- 健康检查参数配置&时间计算

  - initialDelaySeconds: 60    # 初始化时间
  - timeoutSeconds: 5   # 超时时间
  - periodSeconds: 10   # 间隔周期
  - successThreshold: 1 # 检查成功为1次表示就绪
  - failureThreshold: 5 # 检测失败2次表示未就绪

每次检查的间隔是10秒，最长超时时间是5秒，也就是单次检查应该是10 + 5 = 15秒（periodSeconds + timeoutSeconds），所以最长的重启时间为（10 + 5）* 5 ，（periodSeconds + timeoutSeconds） * failureThreshold

此时又分为了两种情况：

1. **首次启动时**：最长重启时间需要加上initialDelaySeconds，因为需要等待initialDelaySeconds秒后才会执行健康检查。最长重启时间：（periodSeconds + timeoutSeconds） * failureThreshold + initialDelaySeconds

2. **程序启动完成后**：此时不需要计入initialDelaySeconds，最长重启时间：（periodSeconds + timeoutSeconds） * failureThreshold

### 重启策略

一旦容器探测出现了问题，kubernetes就会对容器所在的Pod进行重启，其实这是由pod的重启策略决定的，pod的重启策略有 3 种，分别如下：

- Always ：容器失效时，自动重启该容器，这也是默认值。
- OnFailure ： 容器终止运行且退出码不为0时重启
- Never ： 不论状态为何，都不重启该容器

重启策略适用于pod对象中的所有容器，首次需要重启的容器，将在其需要时立即进行重启，随后再次需要重启的操作将由kubelet延迟一段时间后进行，且反复的重启操作的延迟时长以此为10s、20s、40s、80s、160s和300s，300s是最大延迟时长。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-restartpolicy
spec:
  containers:
  ...
  restartPolicy: Never # 设置重启策略为Never
```

 
**资源需求和资源限制**

 在Docker的范畴内，我们知道可以对运行的容器进行请求或消耗的资源进行限制。而在Kubernetes中，也有同样的机制，容器或Pod可以进行申请和消耗的资源就是CPU和内存。CPU属于可压缩型资源，即资源的额度可以按照需求进行收缩。而内存属于不可压缩型资源，对内存的收缩可能会导致无法预知的问题。

资源的隔离目前是属于容器级别，CPU和内存资源的配置需要Pod中的容器spec字段下进行定义。其具体字段，可以使用"requests"进行定义请求的确保资源可用量。也就是说容器的运行可能用不到这样的资源量，但是必须确保有这么多的资源供给。而"limits"是用于限制资源可用的最大值，属于硬限制。

在Kubernetes中，1个单位的CPU相当于虚拟机的1颗虚拟CPU（vCPU）或者是物理机上一个超线程的CPU，它支持分数计量方式，一个核心（1core）相当于1000个微核心（millicores），因此500m相当于是0.5个核心，即二分之一个核心。内存的计量方式也是一样的，默认的单位是字节，也可以使用E、P、T、G、M和K作为单位后缀，或者是Ei、Pi、Ti、Gi、Mi、Ki等形式单位后缀。 

<!-- 注意：同样都是1core，不同频率的cpu的性能也会有差异 -->

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "1"
      limits:
        memory: "64Mi"
        cpu: "1"
```

当进程申请分配超过limit属性定义的内存大小时，该Pod将会被OOM killer杀死。

Pod资源默认的重启策略为Always，在memleak因为内存限制而终止会立即重启，此时该Pod会被OOM  killer杀死，在多次重复因为内存资源耗尽重启会触发Kunernetes系统的重启延迟，每次重启的时间会不断拉长，后面看到的Pod的状态通常为"CrashLoopBackOff"。



### QOS服务质量

在一个Kubernetes集群上，运行的Pod众多，那么当节点都无法满足多个Pod对象的资源使用时，是按照什么样的顺序去终止这些Pod对象呢？

Kubernetes是无法自行去判断的，需要借助于Pod对象的优先级进行判定终止Pod的优先问题。根据Pod对象的requests和limits属性，Kubernetes将Pod对象分为三个服务质量类别：

**Guaranteed**：最高服务质量，当宿主机内存不够时，会先kill掉QoS为BestEffort和Burstable的Pod，如果内存还是不够，才会kill掉QoS为Guaranteed，该级别Pod的资源占用量一般比较明确，即requests的cpu和memory和limits的cpu和memory配置的一致。

- Pod中的每个容器必须指定limits.memory和requests.memory，并且两者需要相等；
- Pod中的每个容器必须指定limits.cpu和limits.memory，并且两者需要相等。

**Burstable**： 服务质量低于Guaranteed，当宿主机内存不够时，会先kill掉QoS为BestEffort的Pod，如果内存还是不够之后就会kill掉QoS级别为Burstable的Pod，用来保证QoS质量为Guaranteed的Pod，该级别Pod一般知道最小资源使用量，但是当机器资源充足时，还是想尽可能的使用更多的资源，即limits字段的cpu和memory大于requests的cpu和memory的配置。

- Pod不符合Guaranteed的配置要求；
- Pod中至少有一个容器配置了requests.cpu或requests.memory。

**BestEffort**：尽力而为，当宿主机内存不够时，首先kill的就是该QoS的Pod，用以保证Burstable和Guaranteed级别的Pod正常运行。

-  不设置resources参数


## 推荐阅读
- [Delaying application start until sidecar is ready](https://medium.com/@marko.luksa/delaying-application-start-until-sidecar-is-ready-2ec2d21a7b74)
- [Kubernetes Pod 生命周期和重启策略](https://system51.github.io/2019/08/23/Kubernetes-Pod-Lifecycle/)
- [kubernetes基础-Pod生命周期和状态](https://isekiro.com/kubernetes%E5%9F%BA%E7%A1%80-pod%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E5%92%8C%E7%8A%B6%E6%80%81/)
