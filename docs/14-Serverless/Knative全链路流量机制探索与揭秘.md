---
title: "Knative全链路流量机制探索与揭秘"
date: 2020-03-07T09:51:34+08:00
draft: false
tags: ["Serverless", "Knative"]
categories: ["Serverless"]
toc:
  auto: false
---

## 引子——从自动扩缩容说起
服务接收到流量请求后，从0自动扩容为N，以及没有流量时自动缩容为0，是Serverless平台最核心的一个特征。  
可以说，自动扩缩容机制是那颗皇冠，戴上之后才能被称之为Serverless。  
当然了解Kubernetes的人会有疑问，HPA不就是用来干自动扩缩容的事儿的吗？难道我用了HPA就可以摇身一变成为Serverless了。  
这里有一点关键的区别在于，Serverless语义下的自动扩缩容是可以让服务从0到N的，但是HPA不能。HPA的机制是检测服务Pod的metrics数据（例如CPU等）然后把Deployment扩容，但当你把Deployment副本数置为0时，流量进不来，metrics数据永远为0，此时HPA也无能为力。  
所以HPA只能让服务从1到N，而从0到1的这个过程，需要额外的机制帮助hold住请求流量，扩容服务，再转发流量到服务，这就是我们常说的`冷启动`。  
可以说，`冷启动`是Serverless皇冠中的那颗明珠，如何实现更好、更快的冷启动，是所有Serverless平台极致追求的目标。  
Knative作为目前被社区和各大厂商如此重视和受关注的Serverless平台，当然也在不遗余力的优化自动扩缩容和冷启动功能。  
不过，本文并不打算直接介绍Knative自动扩缩容机制，而是先探究一下Knative中的流量实现机制，流量机制和自动扩容密切相关，只有了解其中的奥秘，才能更好的理解Knative autoscale功能。  
由于Knative其实包括Building(Tekton)、Serving和Eventing，这里只专注于Serving部分。
另外需要提前说明的是，Knative并不强依赖Istio，Serverless网关的实际选择除了集成Istio，还支持Gloo、Ambassador等。同时，即使使用了Istio，也可以选择是否使用envoy sidecar注入。本文介绍的时候，我们默认使用的是Istio和注入sidecar的部署方式。  

## 简单但是有点过时的老版流量机制
### 整体架构回顾
先回顾一下Knative官方的一个简单的原理示意图如下所示。用户创建一个Knative Service（ksvc）后，Knative会自动创建Route（route）、Configuration（cfg）资源，然后cfg会创建对应的Revision（rev）版本。rev实际上又会创建Deployment提供服务，流量最终会根据route的配置，导入到相应的rev中。  
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/knative-serving-0.png)


这是简单的CRD视角，实际上Knative的内部CRD会多一些层次结构，相对更复杂一点。下文会详细描述。  

### 冷启动时的流量转发
从冷启动和自动扩缩容的实现角度，可以参考一下下图 。从图中可以大概看到，有一个Route充当网关的角色，当服务副本数为0时，自动将请求转发到Activator组件，Activator会保持请求，同时Autoscaler组件会负责将副本数扩容，之后Activator再将请求导入到实际的Pod，并且在副本数不为0时，Route会直接将流量负载均衡到Pod，不再走Activator组件。这也是Knative实现冷启动的一个基本思路。  
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/knative-active.png)

在集成使用Istio部署时，Route默认采用的是Istio Ingress Gateway实现，大概在Knative 0.6版本之前，我们可以发现，Route的流量转发本质上是由Istio virtualservice（vs）控制。副本数为0时，vs如下所示，其中destination指向的是Activator组件。此时Activator会帮助转发冷启动时的请求。   

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: route-f8c50d56-3f47-11e9-9a9a-08002715c9e6
spec:
  gateways:
  - knative-ingress-gateway
  - mesh
  hosts:
  - helloworld-go.default.example.com
  - helloworld-go.default.svc.cluster.local
  http:
  - appendHeaders:
    route:
    - destination:
        host: Activator-Service.knative-serving.svc.cluster.local
        port:
          number: 80
      weight: 100
```
当服务副本数不为0之后，vs变为如下所示，将Ingress Gateway的流量直接转发到服务Pod上。
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: route-f8c50d56-3f47-11e9-9a9a-08002715c9e6
spec:
 hosts:
  - helloworld-go.default.example.com
  - helloworld-go.default.svc.cluster.local
  http:
  - match:
    route:
    - destination:
        host: helloworld-go-2xxcn-Service.default.svc.cluster.local
        port:
          number: 80
      weight: 100
```
我们可以很明显的看出，Knative就是通过修改vs的destination host来实现冷启动中的流量保持和转发。  
相信目前你在网上能找到资料，也基本上停留在该阶段。不过，由于Knative的快速迭代，这里的一些实现细节分析已经过时。  
下面以0.9版本为例，我们仔细探究一下现有的实现方式，和关于Knative流量的真正秘密。 

## 复杂但是更优异的新版流量机制

鉴于官方文档并没有最新的具体实现机制介绍，我们创建一个简单的hello-go ksvc，并以此进行分析。ksvc如下所示：
```
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: hello-go
  namespace: faas
spec:
  template:
    spec:
      containers:
      - image: harbor-yx-jd-dev.yx.netease.com/library/helloworld-go:v0.1
        env:
        - name: TARGET
          value: "Go Sample v1"
```

### virtualservice的变化
笔者的环境可简单的认为是一个标准的Istio部署，Serverless网关为Istio Ingress Gateway，所以创建完ksvc后，为了验证服务是否可以正常运行，需要发送http请求至网关。Gateway资源已经在部署Knative的时候创建，这里我们只需要关心vs。在服务副本数为0的时候，Knative控制器创建的vs关键配置如下：
```yaml
spec:
  gateways:
  - knative-serving/cluster-local-gateway
  - knative-serving/knative-ingress-gateway
  hosts:
  - hello-go.faas
  - hello-go.faas.example.com
  - hello-go.faas.svc
  - hello-go.faas.svc.cluster.local
  - f81497077928a654cf9422088e7522d5.probe.invalid
  http:
  - match:
    - authority:
        regex: ^hello-go\.faas\.example\.com(?::\d{1,5})?$
      gateways:
      - knative-serving/knative-ingress-gateway
    - authority:
        regex: ^hello-go\.faas(\.svc(\.cluster\.local)?)?(?::\d{1,5})?$
      gateways:
      - knative-serving/cluster-local-gateway
    retries:
      attempts: 3
      perTryTimeout: 10m0s
    route:
    - destination:
        host: hello-go-fpmln.faas.svc.cluster.local
        port:
          number: 80
```
vs指定了已经创建好的gw，同时destination指向的是一个Service域名。这个Service就是Knative默认自动创建的hello-go服务的Service。  
细心的我们又发现vs的ownerReferences指向了一个Knative的CRD ingress.networking.internal.knative.dev：

```yaml
  ownerReferences:
  - apiVersion: networking.internal.knative.dev/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: Ingress
    name: hello-go
    uid: 4a27a69e-5b9c-11ea-ae53-fa163ec7c05f
```
根据名字可以看到这是一个Knative内部使用的CRD，该CRD的内容其实和vs比较类似，同时ingress.networking.internal.knative.dev的ownerReferences指向了我们熟悉的route，总结下来就是：
```
route -> kingress(ingress.networking.internal.knative.dev) -> vs
```
在网关这一层涉及到的CRD资源就是如上这些。这里kingress的意义在于增加一层抽象，如果我们使用的是Gloo等其他网关，则会将kingress转换成相应的网关资源配置。最新的版本中，负责kingress到Istio vs的控制器部分代码已经独立出一个项目，可见如今的Knative对Istio已经不是强依赖。  
现在，我们已经了解到Serverless网关是由Knative控制器最终生成的vs生效到Istio Ingress Gateway上，为了验证我们刚才部署的服务是否可以正常的运行，简单的用curl命令试验一下。  
和所有的网关或者负载均衡器一样，对于7层http访问，我们需要在Header里加域名Host，用于流量转发到具体的服务。在上面的vs中已经可以看到对外域名和内部Service域名均已经配置。所以，只需要：

```bash
curl -v -H'Host:hello-go.faas.example.com'  <IngressIP>:<Port> 
```
其中，IngressIP即网关实例对外暴露的IP。  
对于冷启动来说，目前的Knative需要等十几秒，即会收到请求。根据之前老版本的经验，这个时候vs会被更新，destination指向hello-go的Service。  
不过，现在我们实际发现，vs没有任何变化，仍然指向了服务的Service。对比老版本中服务副本数为0时，其实vs的destination指向的是Activator组件的。但现在，不管服务副本数如何变化，vs一直不变。   
蹊跷只能从destination的Service域名入手。  

### revision service探索
创建ksvc后，Knative会帮我们自动创建Service如下所示。

```bash
$ kubectl -n faas get svc
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP                                            PORT(S)      
hello-go                 ExternalName   <none>         cluster-local-gateway.istio-system.svc.cluster.local   <none>           
hello-go-fpmln           ClusterIP      10.178.4.126   <none>                                                 80/TCP             
hello-go-fpmln-m9mmg     ClusterIP      10.178.5.65    <none>                                                 80/TCP,8022/TCP  
hello-go-fpmln-metrics   ClusterIP      10.178.4.237   <none>                                                 9090/TCP,9091/TCP
```
hello-go Service是一个ExternalName Service，作用是将hello-go的Service域名增加一个dns CNAME别名记录，指向网关的Service域名。  
根据Service的annotation我们可以发现，Knative对hello-go-fpmln、hello-go-fpmln-m9mmg 、hello-go-fpmln-metrics这三个Service的定位分别为public Service、private Service和metric Service（最新版本已经将private和metrics Service合并）。  
private Service和metric Service其实不难理解。问题的关键就在这里的public Service，仔细研究hello-go-fpmln Service，我们可以发现这是一个没有labelSelector的Service，它的Endpoint不是kubernetes自动创建的，需要额外生成。  
在服务副本数为0时，查看一下Service对应的Endpoint，如下所示：

```bash
$ kubectl -n faas get ep
NAME                     ENDPOINTS                               AGE
hello-go-fpmln           172.31.16.81:8012                       
hello-go-fpmln-m9mmg     172.31.16.121:8012,172.31.16.121:8022   
hello-go-fpmln-metrics   172.31.16.121:9090,172.31.16.121:9091   
```
其中，public Service的Endpoint IP是Knative Activator的Pod IP，实际发现Activator的副本数越多这里也会相应的增加。并且由上面的分析可以看到，vs的destination指向的就是public Service。   
输入几次curl命令模拟一下http请求，虽然副本数从0开始增加到1了，但是这里的Endpoint却没有变化，仍然为Activator Pod IP。  
接着使用hey来压测一下：

```bash
./hey_linux_amd64 -n 1000000 -c 300  -m GET -host helloworld-go.faas.example.com http://<IngressIP>:80
```
发现Endpoint变化了，通过对比服务的Pod IP，已经变成了新启动的服务Pod IP，不再是Activator Pod的IP。  
```bash
$ kubectl -n faas get ep
NAME                     ENDPOINTS                         
helloworld-go-mpk25      172.31.16.121:8012
hello-go-fpmln-m9mmg     172.31.16.121:8012,172.31.16.121:8022   
hello-go-fpmln-metrics   172.31.16.121:9090,172.31.16.121:9091   
```
原来，现在新版本的冷启动流量转发机制已经不再是通过修改vs来改变网关的流量转发配置了，而是直接更新服务的public Service后端Endpoint，从而实现将流量从Activator转发到实际的服务Pod上。  
通过将流量的转发功能内聚到Service/Endpoint层，一方面减小了网关的配置更新压力，一方面Knative可以在对接各种不同的网关时的实现时更加解耦，网关层不再需要关心冷启动时的流量转发机制。  

### 流量路径
再深入从上述的三个Service入手研究，它们的ownerReference是serverlessservice.networking.internal.knative.dev(sks)，而sks的ownerReference是podautoscaler.autoscaling.internal.knative.dev(kpa)。  
在压测过程中同样发现，sks会在冷启动过后，会从Proxy模式变为Serve模式：

```bash
$ kubectl -n faas get sks
NAME             MODE    SERVICENAME      PRIVATESERVICENAME     READY   REASON
hello-go-fpmln   Proxy   hello-go-fpmln   hello-go-fpmln-m9mmg   True
```
```bash
$ kubectl -n faas get sks
NAME             MODE    SERVICENAME      PRIVATESERVICENAME     READY   REASON
hello-go-fpmln   Serve   hello-go-fpmln   hello-go-fpmln-m9mmg   True
```
这也意味着，当流量从Activator导入的时候，sks为Proxy模式，服务真正启动起来后会变成Serve模式，网关流量直接流向服务Pod。  
从名称上也可以看到，sks和kpa均为Knative内部CRD，实际上也是由于Knative设计上可以支持自定义的扩缩容方式和支持Kubernetes HPA有关，实现更高一层的抽象。  
现在为止，我们可以梳理Knative的绝大部分CRD的关系如下图所示：
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/knative-crd.png)

一个更复杂的实际实现架构图如下所示。
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/knative-service-arch.png)

简单来说，服务副本数为0时，流量路径为：
```
网关-> public Service -> Activator
````
经过冷启动后，副本数为N时，流量路径为：
```
网关-> public Service -> Pod
```
当然流量到Pod后，实际内部还有Envoy sidecar流量拦截，Queue-Proxy sidecar反向代理，才再到用户的User Container。这里的机制背后实现我们会有另外一篇文章再单独细聊。  

## 总结
Knative本身的实现可谓是云原生领域里的一个集大成者，融合Kubernetes、ServiceMesh、Serverless让Knative充满了魅力，但同时也导致了Knative的复杂性。 
网络流量的稳定保障是Serverless服务真正生产可用性的关键因素，Knative也还在高速的更新迭代中，相信Knative会在未来对网络方面的性能和稳定性投入更多的优化。  




