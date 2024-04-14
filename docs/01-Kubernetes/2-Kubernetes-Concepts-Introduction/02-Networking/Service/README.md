---
title: Service
tags: [Kubernetes]
---

在kubernetes中，pod是应用程序的载体，我们可以通过pod的ip来访问应用程序，虽然每个Pod都会分配一个单独的Pod IP，然而却存在如下两问题：
  - Pod IP 会随着Pod的重建产生变化
  - Pod IP 仅仅是集群内可见的虚拟IP，外部无法访问

为了解决这个问题，kubernetes提供了Service资源，Service会对提供同一个服务的多个pod进行聚合，并且提供一个统一的入口地址。通过访问Service的入口地址就能访问到后面的pod服务。

Kubernetes 的内部服务发现是基于 Service + DNS 解析实现的，默认情况下解析到的是一个稳定的虚拟 IP 地址（Service），该虚拟 IP 再通过 kube_proxy 将流量均衡到后端的 Pods 上。

Service在很多情况下只是一个概念，真正起作用的其实是kube-proxy服务进程，每个Node节点上都运行着一个kube-proxy服务进程。当创建Service的时候会通过api-server向etcd写入创建的service的信息，而kube-proxy会基于监听的机制发现这种Service的变动，然后**它会将最新的Service信息转换成对应的访问规则**。


## kube-proxy 的代理模式

1. userspace 模式：  
   用户态的转发方案，由于性能问题以弃用
2. iptables  模式：  
   通过 Iptables 实现的一个四层（TCP）NAT，kube_proxy 只负责创建 iptables 的 nat 规则，不负责流量转发。负载均衡较差
3. ipvs 模式：性能与负载均衡兼得：  
   可通过 `--ipvs-scheduler` 指定负载均衡算法，有多种算法可选，详见 [ipvs-based-in-cluster-load-balancing](https://kubernetes.io/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/)
    - 最推荐的方案，性能最高，而且支持更复杂的负载均衡策略。
    - ipvs 模式下，默认的负载均衡算法是：round robin（rr, 轮询调度）
    - ipvs 模式底层用的是 IPVS NAT 模式进行 service 端口映射
      - 这种模式下，被访问的服务看到的 srcAddr 仍然是客户端 ip，而不是 service 的 vip. 详见 [ipvs 的几种模式](https://www.cnblogs.com/skyflask/p/7500899.html)

```bash
# 10.97.97.97:80 是service提供的访问入口
# 当访问这个入口的时候，可以发现后面有三个pod的服务在等待调用，
# kube-proxy会基于rr（轮询）的策略，将请求分发到其中一个pod上去
# 这个规则会同时在集群内的所有节点上都生成，所以在任何一个节点上访问都可以。
[root@node1 ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.97.97.97:80 rr
  -> 10.244.1.39:80               Masq    1      0          0
  -> 10.244.1.40:80               Masq    1      0          0
  -> 10.244.2.33:80               Masq    1      0          0
```

## 资源清单

```yaml
kind: Service  # 资源类型
apiVersion: v1  # 资源版本
metadata: # 元数据
  name: service # 资源名称
  namespace: dev # 命名空间
spec: # 描述
  selector: # 标签选择器，用于确定当前service代理哪些pod
    app: nginx
  type: # Service类型，指定service的访问方式
  clusterIP:  # 虚拟服务的ip地址
  sessionAffinity: # session亲和性，支持ClientIP、None两个选项
  ports: # 端口信息
    - protocol: TCP 
      port: 3017  # service端口
      targetPort: 5003 # pod端口
      nodePort: 31122 # 主机端口
    # - name: http
    #   protocol: TCP
    #   port: 80
    #   targetPort: 9376
```

## Service 类型

1. ClusterIP: 集群内的 Service，上面介绍的三种代理模式就是指这种类型的 Service。 
   1. 可以通过指定 Cluster IP（spec.clusterIP）的值为 "None" 来创建 Headless Service。
   2. Headless 的 Service 只提供 DNS SRV 解析，不创建 VIP 及流量代理。
2. NodePort: 通过每个 Node 上的 IP 和静态端口（NodePort）将服务暴露到集群外部网络。 同时它也有 ClusterIP
   1. 它分配的端口号范围受限于 kube-apiserver 的启动参数 `--service-node-port-range`，范围默认是30000-32767。
3. LoadBalancer: 使用云提供商的负载局衡器，将服务暴露到外部网络，每个 LoadBalancer 都会分配到一个外部 IP 地址。
   1. LoadBalancer 有外部 IP 地址，后端通过 NodePort 将均衡转发到集群内部。
   2. kubernetes 官方没有给出 LoadBalancer 的实现方式。每个云服务商都提供了自己私有的实现。
   3. 开源的 LoadBalancer 实现： kubernetes 如何将服务暴露到外部 
4. ExternalName: 用于将集群外部的服务引入集群内部。通过返回 CNAME 和它的值，可以将服务映射到 externalName 字段的内容（例如， foo.bar.example.com）。 
   1. 这类 Service 只是单纯地添加了一条内部 DNS CNAME 解析。没有
   2. 因为 ExternalName 使用的是 DNS CNAME 记录，它要求值必须是合法的 DNS 名称，**不支持 ip 地址**！
    3. 如果需要针对外部 ip 做负载均衡，请参见下一小节

上面提到的 LoadBalancer 主要是做外部负载均衡，但是各大云厂商都提供一类注解，可以单纯创建一个内部负载均衡。
内部负载均衡的主要用途：

   1. 使得 Kubernetes 群集所在的同一虚拟网络中运行的应用程序能够访问 Kubernetes 服务
   2. 支持四层/七层转发与负载均衡，相比普通 Service，它多了一个第七层均衡的功能。

## Endpoints 和 EndpointSlice 

在 Kubernetes 中，Service不仅可以通过选择器来连接到集群内的 Pods，还可以通过不使用选择器而直接使用 EndpointSlice/Endpoints 对象来连接到集群外的后端服务。

Kubernetes 限制单个 Endpoints 对象中可以容纳的端点数量。当服务有超过 1000 个支持端点时，Kubernetes 会截断 Endpoints 对象中的数据。由于一项服务可以与多个 EndpointSlice 链接，因此 1000 个支持端点限制仅影响旧版 Endpoints API。

### Endpoint
Endpoints 是 Kubernetes 最早引入的资源之一，用于跟踪属于某个 Service 的 Pods 的 IP 地址和端口。当你创建一个 Service 时，Kubernetes 会自动创建一个与之关联的 Endpoints 对象。这个 Endpoints 对象会包含所有匹配 Service 选择器的 Pods 的 IP 地址和端口信息。

这个Endpoint对象会持续地监控与Service关联的Pod，当Pod发生变化（例如，新的Pod被创建，或者现有的Pod被销毁）时，Endpoint对象也会相应地被更新，以确保Service始终能够转发请求到正确的Pod。

然而，Endpoints 的一个缺点是它不适用于大规模集群。因为它是单个资源对象，当有很多 Pods 需要更新时，会导致性能问题。每次 Pods 增加、删除或更新时，整个 Endpoints 对象都需要被更新和重新分发给集群中的所有节点，这将导致大量的网络和 CPU 开销。


### EndpointSlice
EndpointSlice 是 Kubernetes 1.17 版本引入的，旨在解决以上 Endpoints 在大型集群中的性能问题。EndpointSlice 将 Endpoints 分割成多个较小的对象，这样当需要更新 Pods 信息时，只需要更新一部分 EndpointSlices 而不是整个 Endpoints 对象。这减少了网络流量、API 服务器的存储和 CPU 使用。

- 拓扑信息： EndpointSlice 支持更丰富的拓扑信息，例如，可以包含每个端点的拓扑信息（如节点名称、可用区等），允许更高效的流量路由和管理。
- IP 地址类型支持： EndpointSlice 支持多种 IP 地址类型，包括 IPv4 和 IPv6，而 Endpoints 主要是为单一 IP 地址类型设计。

### EndpointSlice 何时分片
在Kubernetes中，`EndpointSlice`资源会在以下情况下进行分片：

1. 当服务后的端点（Pods）数量超过`EndpointSlice`对象容量限制时（默认为100个端点每个`EndpointSlice`）。
2. 当服务的端点集合因Pod的增加或减少而动态变化时，以维持每个`EndpointSlice`对象的端点数量不超过限制。

### 分片后的示例

假设有一个名为`my-service`的服务，它背后有150个Pod作为端点。Kubernetes将会创建2个`EndpointSlice`对象来存储所有这些端点的信息。每个`EndpointSlice`可以存储100个端点（根据配置可能不同），所以前两个`EndpointSlice`将满（每个包含100个端点），而第三个将包含剩下的50个端点。

示例YAML可能如下所示：

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-1
  labels:
    kubernetes.io/service-name: my-service
addressType: IPv4
ports:
- name: http
  port: 80
  protocol: TCP
endpoints:
  - addresses: ["192.0.2.1"]
    ...
  # 总共有100个端点（Pods）的信息
```

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-2
  labels:
    kubernetes.io/service-name: my-service
addressType: IPv4
ports:
- name: http
  port: 80
  protocol: TCP
endpoints:
  - addresses: ["192.0.2.101"]
    ...
  # 另外50个端点的信息
```

通过这种方式，Kubernetes在维持服务的可用性和可扩展性的同时，优化了对`EndpointSlice`资源的更新和管理，特别是在大规模集群中。

## Service使用

### ClusterIP类型的Service

创建service-clusterip.yaml文件

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-clusterip
  namespace: dev
spec:
  selector:
    app: nginx-pod
  clusterIP: 10.97.97.97 # service的ip地址，如果不写，默认会生成一个
  type: ClusterIP
  ports:
  - port: 80  # Service端口       
    targetPort: 80 # pod端口
```

```bash
# 创建service
[root@master ~]# kubectl create -f service-clusterip.yaml
service/service-clusterip created

# 查看service
[root@master ~]# kubectl get svc -n dev -o wide
NAME                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service-clusterip   ClusterIP   10.97.97.97   <none>        80/TCP    13s   app=nginx-pod

# 查看service的详细信息
# 在这里有一个Endpoints列表，里面就是当前service可以负载到的服务入口
[root@master ~]# kubectl describe svc service-clusterip -n dev
Name:              service-clusterip
Namespace:         dev
Labels:            <none>
Annotations:       <none>
Selector:          app=nginx-pod
Type:              ClusterIP
IP:                10.97.97.97
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.39:80,10.244.1.40:80,10.244.2.33:80
Session Affinity:  None
Events:            <none>

# 查看ipvs的映射规则
[root@master ~]# ipvsadm -Ln
TCP  10.97.97.97:80 rr
  -> 10.244.1.39:80               Masq    1      0          0
  -> 10.244.1.40:80               Masq    1      0          0
  -> 10.244.2.33:80               Masq    1      0          0

# 访问10.97.97.97:80观察效果
[root@master ~]# curl 10.97.97.97:80
10.244.2.33
```

**Endpoint**

Endpoint是kubernetes中的一个资源对象，存储在etcd中，用来记录一个service对应的所有pod的访问地址，它是根据service配置文件中selector描述产生的。
    
一个Service由一组Pod组成，这些Pod通过Endpoints暴露出来，**Endpoints是实现实际服务的端点集合**。换句话说，service和pod之间的联系是通过endpoints实现的。


**负载分发策略**

对Service的访问被分发到了后端的Pod上去，目前kubernetes提供了两种负载分发策略：

- 如果不定义，默认使用kube-proxy的策略，比如随机、轮询

- 基于客户端地址的会话保持模式，即来自同一个客户端发起的所有请求都会转发到固定的一个Pod上

  此模式可以使在spec中添加`sessionAffinity:ClientIP`选项

```bash
# 查看ipvs的映射规则【rr 轮询】
[root@master ~]# ipvsadm -Ln
TCP  10.97.97.97:80 rr
  -> 10.244.1.39:80               Masq    1      0          0
  -> 10.244.1.40:80               Masq    1      0          0
  -> 10.244.2.33:80               Masq    1      0          0

# 循环访问测试
[root@master ~]# while true;do curl 10.97.97.97:80; sleep 5; done;
10.244.1.40
10.244.1.39
10.244.2.33
10.244.1.40
10.244.1.39
10.244.2.33

# 修改分发策略----sessionAffinity:ClientIP

# 查看ipvs规则【persistent 代表持久】
[root@master ~]# ipvsadm -Ln
TCP  10.97.97.97:80 rr persistent 10800
  -> 10.244.1.39:80               Masq    1      0          0
  -> 10.244.1.40:80               Masq    1      0          0
  -> 10.244.2.33:80               Masq    1      0          0

# 循环访问测试
[root@master ~]# while true;do curl 10.97.97.97; sleep 5; done;
10.244.2.33
10.244.2.33
10.244.2.33
  
# 删除service
[root@master ~]# kubectl delete -f service-clusterip.yaml
service "service-clusterip" deleted
```

### HeadLess 类型的Service

在某些场景中，开发人员可能不想使用Service提供的负载均衡功能，而希望自己来控制负载均衡策略，针对这种情况，kubernetes提供了HeadLess   Service，这类Service不会分配Cluster IP，如果想要访问service，只能通过service的域名进行查询。

创建service-headless .yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-headless 
  namespace: dev
spec:
  selector:
    app: nginx-pod
  clusterIP: None # 将clusterIP设置为None，即可创建headless  Service
  type: ClusterIP
  ports:
  - port: 80    
    targetPort: 80
```

```bash
# 创建service
[root@master ~]# kubectl create -f service-headless .yaml
service/service-headless  created

# 获取service， 发现CLUSTER-IP未分配
[root@master ~]# kubectl get svc service-headless  -n dev -o wide
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service-headless    ClusterIP   None         <none>        80/TCP    11s   app=nginx-pod

# 查看service详情
[root@master ~]# kubectl describe svc service-headless   -n dev
Name:              service-headless 
Namespace:         dev
Labels:            <none>
Annotations:       <none>
Selector:          app=nginx-pod
Type:              ClusterIP
IP:                None
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.39:80,10.244.1.40:80,10.244.2.33:80
Session Affinity:  None
Events:            <none>

# 查看域名的解析情况
[root@master ~]# kubectl exec -it pc-deployment-66cb59b984-8p84h -n dev /bin/sh
/ # cat /etc/resolv.conf
nameserver 10.96.0.10
search dev.svc.cluster.local svc.cluster.local cluster.local

[root@master ~]# dig @10.96.0.10 service-headless .dev.svc.cluster.local
service-headless .dev.svc.cluster.local. 30 IN A 10.244.1.40
service-headless .dev.svc.cluster.local. 30 IN A 10.244.1.39
service-headless .dev.svc.cluster.local. 30 IN A 10.244.2.33
```

### NodePort类型的Service

    在之前的样例中，创建的Service的ip地址只有集群内部才可以访问，如果希望将Service暴露给集群外部使用，那么就要使用到另外一种类型的Service，称为NodePort类型。NodePort的工作原理其实就是**将service的端口映射到Node的一个端口上**，然后就可以通过`NodeIp:NodePort`来访问service了。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:53:41-image-20200620175731338.png"   />

创建service-nodeport.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport
  namespace: dev
spec:
  selector:
    app: nginx-pod
  type: NodePort # service类型
  ports:
  - port: 80
    nodePort: 30002 # 指定绑定的node的端口(默认的取值范围是：30000-32767), 如果不指定，会默认分配
    targetPort: 80
```

```bash
# 创建service
[root@master ~]# kubectl create -f service-nodeport.yaml
service/service-nodeport created

# 查看service
[root@master ~]# kubectl get svc -n dev -o wide
NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)       SELECTOR
service-nodeport   NodePort   10.105.64.191   <none>        80:30002/TCP  app=nginx-pod

# 接下来可以通过电脑主机的浏览器去访问集群中任意一个nodeip的30002端口，即可访问到pod
```

### LoadBalancer类型的Service

    LoadBalancer和NodePort很相似，目的都是向外部暴露一个端口，区别在于LoadBalancer会在集群的外部再来做一个负载均衡设备，而这个设备需要外部环境支持的，外部服务发送到这个设备上的请求，会被设备负载之后转发到集群中。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:53:44-image-20200510103945494.png"  />

### ExternalName类型的Service

     ExternalName类型的Service用于引入集群外部的服务，它通过`externalName`属性指定外部一个服务的地址，然后在集群内部访问此service就可以访问到外部的服务了。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:53:46-image-20200510113311209.png"  />

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-externalname
  namespace: dev
spec:
  type: ExternalName # service类型
  externalName: www.baidu.com  #改成ip地址也可以
```

```bash
# 创建service
[root@master ~]# kubectl  create -f service-externalname.yaml
service/service-externalname created

# 域名解析
[root@master ~]# dig @10.96.0.10 service-externalname.dev.svc.cluster.local
service-externalname.dev.svc.cluster.local. 30 IN CNAME www.baidu.com.
www.baidu.com.          30      IN      CNAME   www.a.shifen.com.
www.a.shifen.com.       30      IN      A       39.156.66.18
www.a.shifen.com.       30      IN      A       39.156.66.14
```


### 使用Service代理k8s外部应用

创建带标签选择器的service会自动创建同名Endpoints，创建裸service，需要手动创建Endpoints

> 希望在生产环境中使用某个固定的名称而非IP地址进行访问外部的中间件服务
>
> 希望Service指向另一个Namespace中或其他集群中的服务
>
> 某个项目正在迁移至k8s集群，但是一部分服务仍然在集群外部，此时可以使用service代理至k8s集群外部的服务

```bash
# cat nginx-svc-external.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-svc-external
  name: nginx-svc-external
spec:
  ports:
  - name: http # Service端口的名称
    port: 80 # Service自己的端口, servicea --> serviceb http://serviceb,  http://serviceb:8080 
    protocol: TCP # UDP TCP SCTP default: TCP
    targetPort: 80 # 后端应用的端口
  sessionAffinity: None
  type: ClusterIP
```



```bash
# cat nginx-ep-external.yaml 
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: nginx-svc-external
  name: nginx-svc-external
  namespace: default
subsets:
- addresses:
  - ip: 140.205.94.189 
  ports:
  - name: http
    port: 80
    protocol: TCP
```

### 使用Service反代域名

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-externalname
  name: nginx-externalname
spec:
  type: ExternalName
  externalName: www.baidu.com
```
### 手动维护 Service 的 endpoints

>官方文档: [Services without selectors](https://kubernetes.io/docs/concepts/services-networking/service/#services-without-selectors)

前问提到过 ExternalName 类型的 Service 可以在集群中为外部域名创建一个 CNAME 记录，但是不支持 ip 地址。

那如果你就是需要用 K8s Service 来对部分已知的外部 ip 地址做负载均衡呢？

创建一个不带 label selector 的 service，以及一个同名的 endpoints，手动维护 endpoints 中的 ip 列表就行。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
---
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
```

这样，在集群内访问 `my-service:9376`，会被 Service 转发到 `182.0.2.42:9376`
## 流量策略 

### externalTrafficPolicy
使用场景：externalTrafficPolicy用于控制从集群外部来源到Service的流量的路由策略。它主要应用于类型为LoadBalancer或NodePort的Service。

Cluster（默认）：流量会被分发到所有就绪的Pod，不管Pod位于哪个节点上。这意味着即使流量进入集群的节点上没有就绪的Pod，流量也会被转发到其他节点上的Pod。这种方式可以实现负载均衡，但可能导致源IP地址被更改。

Local：流量仅被路由到接收到外部请求的节点上的就绪Pod。如果该节点没有就绪的Pod，流量将被丢弃或返回一个错误。这种方式允许保留客户端的源IP地址，对于需要源IP进行日志记录或安全策略的应用来说非常有用。

### internalTrafficPolicy
使用场景：internalTrafficPolicy用于控制从集群内部来源到Service的流量的路由策略。

Cluster（默认）：与externalTrafficPolicy的Cluster模式类似，内部流量会被分发到所有就绪的Pod，无论Pod位于哪个节点上。这提供了负载均衡，确保了服务的高可用性。

Local：内部流量仅被路由到与发送请求的源在同一节点上的就绪Pod。如果该节点上没有就绪的Pod，流量将被丢弃。这种方式适用于希望最小化跨节点流量，减少延迟和网络负载的场景。


## 参考文档
- https://cloud.google.com/kubernetes-engine/docs/concepts/service-load-balancer?hl=zh-cn
