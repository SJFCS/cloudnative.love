---
title: Scheduling, Preemption and Eviction
tags: [Kubernetes]
---

本文介绍 定向调度、亲和力调度、污点容忍度的原理配置
- https://kubernetes.io/blog/2017/03/advanced-scheduling-in-kubernetes/ 

kubernetes提供了四大类调度方式：

- 自动调度：运行在哪个节点上完全由Scheduler经过一系列的算法计算得出
- 定向调度：NodeName、NodeSelector
- 亲和性调度：NodeAffinity、PodAffinity、PodAntiAffinity
- 污点（容忍）调度：Taints、Toleration

## 定向调度

定向调度，指的是利用在pod上声明nodeName或者nodeSelector，以此将Pod调度到期望的node节点上。注意，这里的调度是强制的，这就意味着即使要调度的目标Node不存在，也会向上面进行调度，只不过pod运行失败而已。

### NodeName

NodeName用于强制约束将Pod调度到指定的Name的Node节点上。这种方式，其实是直接跳过Scheduler的调度逻辑，直接将Pod调度到指定名称的节点。

接下来，实验一下：创建一个pod-nodename.yaml文件

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodename
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  nodeName: node1 # 指定调度到node1节点上
```
### NodeSelector

NodeSelector用于将pod调度到添加了指定标签的node节点上。它是通过kubernetes的label-selector机制实现的，也就是说，在pod创建之前，会由scheduler使用MatchNodeSelector调度策略进行label匹配，找出目标node，然后将pod调度到目标节点，该匹配规则是强制约束。

1 首先分别为node节点添加标签

```powershell
[root@master ~]# kubectl label nodes node1 nodeenv=pro
node/node2 labeled
[root@master ~]# kubectl label nodes node2 nodeenv=test
node/node2 labeled
```

2 创建一个pod-nodeselector.yaml文件，并使用它创建Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodeselector
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  nodeSelector: 
    nodeenv: pro # 指定调度到具有nodeenv=pro标签的节点上
```


## 亲和性调度

上一节，介绍了两种定向调度的方式，使用起来非常方便，但是也有一定的问题，那就是如果没有满足条件的Node，那么Pod将不会被运行，即使在集群中还有可用Node列表也不行，这就限制了它的使用场景。

基于上面的问题，kubernetes还提供了一种亲和性调度（Affinity）。它在NodeSelector的基础之上的进行了扩展，可以通过配置的形式，实现优先选择满足条件的Node进行调度，如果没有，也可以调度到不满足条件的节点上，使调度更加灵活。

Affinity主要分为三类：

- nodeAffinity(node亲和性): 以node为目标，解决pod可以调度到哪些node的问题
- podAffinity(pod亲和性) :  以pod为目标，解决pod可以和哪些已存在的pod部署在同一个拓扑域中的问题
- podAntiAffinity(pod反亲和性) :  以pod为目标，解决pod不能和哪些已存在pod部署在同一个拓扑域中的问题

关于亲和性(反亲和性)使用场景的说明：
- **亲和性**：如果两个应用频繁交互，那就有必要利用亲和性让两个应用的尽可能的靠近，这样可以减少因网络通信而带来的性能损耗。
- **反亲和性**：当应用的采用多副本部署时，有必要采用反亲和性让各个应用实例打散分布在各个node上，这样可以提高服务的高可用性。

### NodeAffinity

首先来看一下`NodeAffinity`的可配置项：

```yaml
pod.spec.affinity.nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:  #Node节点必须满足指定的所有规则才可以，硬亲和力配置
    nodeSelectorTerms:  #节点选择列表,科普自制多个matchExpressions（满足其一），每个matchExpressions下可配置多个key、value类型的选择器（都需要满足），其中values可以配置多个（满足其一）
#   - matchFields:   #按节点字段列出的节点选择器要求列表
    - matchExpressions:   #按节点标签列出的节点选择器要求列表(推荐)
      - key: kubernetes.io/e2e-az-name
        operator: In 	#关系符 参数如下：
        				#Exists（节点存在label的key为指定的值即可，不能配置values字段）
        				#DoesNotExist（节点不存在label的key为指定的值即可，不能配置values字段）
        				#In（相当于key = value）, NotIn（相当于key != value）
        				#Gt（大于value指定的值）
        				#Lt(小于value指定的值)
        values:
        - e2e-az1
        - az-2
  preferredDuringSchedulingIgnoredDuringExecution: #优先调度到满足指定的规则的Node，软亲和力配置
  - weight: #倾向权重，在范围1-100。    
    preference:   #一个节点选择器项，与相应的权重相关联，可配置多个
#     matchFields:   #按节点字段列出的节点选择器要求列表
      matchExpressions:   #按节点标签列出的节点选择器要求列表(推荐)
        key:    键
        operator: 关系符 支持In, NotIn, Exists, DoesNotExist, Gt, Lt        
        values: 值

```
关系符的使用说明:

```yaml
- matchExpressions:
  - key: nodeenv              # 匹配存在标签的key为nodeenv的节点
    operator: Exists
  - key: nodeenv              # 匹配标签的key为nodeenv,且value是"xxx"或"yyy"的节点
    operator: In
    values: ["xxx","yyy"]
  - key: nodeenv              # 匹配标签的key为nodeenv,且value大于"xxx"的节点
    operator: Gt
    values: "xxx"
```

#### 案例1： node硬亲和力配置

接下来首先演示一下`requiredDuringSchedulingIgnoredDuringExecution` ,

创建pod-nodeaffinity-required.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodeaffinity-required
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  affinity:  #亲和性设置
    nodeAffinity: #设置node亲和性
      requiredDuringSchedulingIgnoredDuringExecution: # 硬限制
        nodeSelectorTerms:
        - matchExpressions: # 匹配env的值在["xxx","yyy"]中的标签
          - key: nodeenv
            operator: In
            values: ["xxx","yyy"]
```

```powershell
# 创建pod
[root@master ~]# kubectl create -f pod-nodeaffinity-required.yaml
pod/pod-nodeaffinity-required created

# 查看pod状态 （运行失败）
[root@master ~]# kubectl get pods pod-nodeaffinity-required -n dev -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP       NODE    ...... 
pod-nodeaffinity-required   0/1     Pending   0          16s   <none>   <none>  ......

# 查看Pod的详情
# 发现调度失败，提示node选择失败
[root@master ~]# kubectl describe pod pod-nodeaffinity-required -n dev
......
  Warning  FailedScheduling  <unknown>  default-scheduler  0/3 nodes are available: 3 node(s) didn't match node selector.
  Warning  FailedScheduling  <unknown>  default-scheduler  0/3 nodes are available: 3 node(s) didn't match node selector.

#接下来，停止pod
[root@master ~]# kubectl delete -f pod-nodeaffinity-required.yaml
pod "pod-nodeaffinity-required" deleted

# 修改文件，将values: ["xxx","yyy"]------> ["pro","yyy"]
[root@master ~]# vim pod-nodeaffinity-required.yaml

# 再次启动
[root@master ~]# kubectl create -f pod-nodeaffinity-required.yaml
pod/pod-nodeaffinity-required created

# 此时查看，发现调度成功，已经将pod调度到了node1上
[root@master ~]# kubectl get pods pod-nodeaffinity-required -n dev -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE  ...... 
pod-nodeaffinity-required   1/1     Running   0          11s   10.244.1.89   node1 ......
```

#### 案例2： node软亲和力配置

接下来再演示一下`preferredDuringSchedulingIgnoredDuringExecution` ,

创建pod-nodeaffinity-preferred.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodeaffinity-preferred
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  affinity:  #亲和性设置
    nodeAffinity: #设置node亲和性
      preferredDuringSchedulingIgnoredDuringExecution: # 软限制
      - weight: 1
        preference:
          matchExpressions: # 匹配env的值在["xxx","yyy"]中的标签(当前环境没有)
          - key: nodeenv
            operator: In
            values: ["xxx","yyy"]
```

```powershell
# 创建pod
[root@master ~]# kubectl create -f pod-nodeaffinity-preferred.yaml
pod/pod-nodeaffinity-preferred created

# 查看pod状态 （运行成功）
[root@master ~]# kubectl get pod pod-nodeaffinity-preferred -n dev
NAME                         READY   STATUS    RESTARTS   AGE
pod-nodeaffinity-preferred   1/1     Running   0          40s
```

NodeAffinity规则设置的注意事项：
    1 如果同时定义了nodeSelector和nodeAffinity，那么必须两个条件都得到满足，Pod才能运行在指定的Node上
    2 如果nodeAffinity指定了多个nodeSelectorTerms，那么只需要其中一个能够匹配成功即可
    3 如果一个nodeSelectorTerms中有多个matchExpressions ，则一个节点必须满足所有的才能匹配成功
    4 如果一个pod所在的Node在Pod运行期间其标签发生了改变，不再符合该Pod的节点亲和性需求，则系统将忽略此变化

### PodAffinity & PodAntiAffinity

+ PodAffinity主要实现以运行的Pod为参照，实现让新创建的Pod跟参照pod在一个区域的功能。

+ PodAntiAffinity主要实现以运行的Pod为参照，让新创建的Pod跟参照pod不在一个区域中的功能。

首先来看一下`PodAffinity & PodAntiAffinity`的可配置项：

```yaml
pod.spec.affinity:
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    namespaces:       #指定参照pod的namespace，空为当前命名空间
    topologyKey:      #指定调度作用域,key和valueSSD为同一个域
    labelSelector:    #标签选择器
      matchExpressions:  #按节点标签列出的节点选择器要求列表(推荐)
      - key:    #键
        operator: #关系符 支持In, NotIn, Exists, DoesNotExist.
        values: #值
#     matchLabels:    #指多个matchExpressions映射的内容
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution: 
  - weight: #倾向权重，在范围1-100  
    podAffinityTerm:  #选项
      namespaces:      
      topologyKey:
      labelSelector:
        matchExpressions:  
          key:
          operator:          
          values:
#       matchLabels: 

```
### 拓扑域TopologyKey详解

topologyKey用于指定调度时作用域，key和valueTRUE为同一个域，例如:

> 如果指定为kubernetes.io/hostname，那就是以Node节点为区分范围
> 如果指定为beta.kubernetes.io/os,则以Node节点的操作系统类型来区分

#### 案例1： pod硬亲和力配置

接下来，演示下`requiredDuringSchedulingIgnoredDuringExecution`,

1）首先创建一个参照Pod，pod-podaffinity-target.yaml：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-podaffinity-target
  namespace: dev
  labels:
    podenv: pro #设置标签
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  nodeName: node1 # 将目标pod名确指定到node1上
```

```powershell
# 启动目标pod
[root@master ~]# kubectl create -f pod-podaffinity-target.yaml
pod/pod-podaffinity-target created

# 查看pod状况
[root@master ~]# kubectl get pods  pod-podaffinity-target -n dev
NAME                     READY   STATUS    RESTARTS   AGE
pod-podaffinity-target   1/1     Running   0          4s
```

2）创建pod-podaffinity-required.yaml，内容如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-podaffinity-required
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  affinity:  #亲和性设置
    podAffinity: #设置pod亲和性
      requiredDuringSchedulingIgnoredDuringExecution: # 硬限制
      - labelSelector:
          matchExpressions: # 匹配env的值在["xxx","yyy"]中的标签
          - key: podenv
            operator: In
            values: ["xxx","yyy"]
        topologyKey: kubernetes.io/hostname
```

上面配置表达的意思是：新Pod必须要与拥有标签nodeenv=xxx或者nodeenv=yyy的pod在同一Node上，显然现在没有这样pod，接下来，运行测试一下。

```powershell
# 启动pod
[root@master ~]# kubectl create -f pod-podaffinity-required.yaml
pod/pod-podaffinity-required created

# 查看pod状态，发现未运行
[root@master ~]# kubectl get pods pod-podaffinity-required -n dev
NAME                       READY   STATUS    RESTARTS   AGE
pod-podaffinity-required   0/1     Pending   0          9s

# 查看详细信息
[root@master ~]# kubectl describe pods pod-podaffinity-required  -n dev
......
Events:
  Type     Reason            Age        From               Message
  ----     ------            ----       ----               -------
  Warning  FailedScheduling  <unknown>  default-scheduler  0/3 nodes are available: 2 node(s) didn't match pod affinity rules, 1 node(s) had taints that the pod didn't tolerate.

# 接下来修改  values: ["xxx","yyy"]----->values:["pro","yyy"]
# 意思是：新Pod必须要与拥有标签nodeenv=xxx或者nodeenv=yyy的pod在同一Node上
[root@master ~]# vim pod-podaffinity-required.yaml

# 然后重新创建pod，查看效果
[root@master ~]# kubectl delete -f  pod-podaffinity-required.yaml
pod "pod-podaffinity-required" deleted
[root@master ~]# kubectl create -f pod-podaffinity-required.yaml
pod/pod-podaffinity-required created

# 发现此时Pod运行正常
[root@master ~]# kubectl get pods pod-podaffinity-required -n dev
NAME                       READY   STATUS    RESTARTS   AGE   LABELS
pod-podaffinity-required   1/1     Running   0          6s    <none>
```

#### 案例2： pod软亲和力配置

关于`PodAffinity`的 `preferredDuringSchedulingIgnoredDuringExecution`，这里不再演示。

#### 案例3： pod反亲和力配置

1）继续使用上个案例中目标pod

```powershell
[root@master ~]# kubectl get pods -n dev -o wide --show-labels
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE    LABELS
pod-podaffinity-required 1/1     Running   0          3m29s   10.244.1.38   node1   <none>     
pod-podaffinity-target   1/1     Running   0          9m25s   10.244.1.37   node1   podenv=pro
```

2）创建pod-podantiaffinity-required.yaml，内容如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-podantiaffinity-required
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
  affinity:  #亲和性设置
    podAntiAffinity: #设置pod亲和性
      requiredDuringSchedulingIgnoredDuringExecution: # 硬限制
      - labelSelector:
          matchExpressions: # 匹配podenv的值在["pro"]中的标签
          - key: podenv
            operator: In
            values: ["pro"]
        topologyKey: kubernetes.io/hostname
```

上面配置表达的意思是：新Pod必须要与拥有标签nodeenv=pro的pod不在同一Node上，运行测试一下。

```powershell
# 创建pod
[root@master ~]# kubectl create -f pod-podantiaffinity-required.yaml
pod/pod-podantiaffinity-required created

# 查看pod
# 发现调度到了node2上
[root@master ~]# kubectl get pods pod-podantiaffinity-required -n dev -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE   .. 
pod-podantiaffinity-required   1/1     Running   0          30s   10.244.1.96   node2  ..
```

#### 案例4：应用部署在不同的宿主机

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: must-be-diff-nodes
  namespace: kube-public
  labels:
    app: must-be-diff-nodes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: must-be-diff-nodes
  template:
    metadata:
      labels:
        app: must-be-diff-nodes
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - must-be-diff-nodes
            topologyKey: kubernetes.io/hostname
      containers:
      - image: nginx
        imagePullPolicy: IfNotPresent
        name: must-be-diff-nodes
```

#### 案例5：应用不同副本固定节点

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
spec:
  selector:
    matchLabels:
      app: store
  replicas: 3
  template:
    metadata:
      labels:
        app: store
    spec:
      nodeSelector:
          app: store
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis-server
        image: redis:3.2-alpine
```

#### 案例6：应用和缓存尽量部署在同一个域内

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  selector:
    matchLabels:
      app: web-store
  replicas: 3
  template:
    metadata:
      labels:
        app: web-store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - store
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.16-alpine
```

#### 案例7：尽量调度到高配置服务器

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: prefer-ssd
  name: prefer-ssd
  namespace: kube-public
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prefer-ssd
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: prefer-ssd
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - preference:
              matchExpressions:
              - key: ssd
                operator: In
                values:
                - "true"
              - key: master
                operator: NotIn
                values:
                - "true"
            weight: 100
          - preference:
              matchExpressions:
              - key: type
                operator: In
                values:
                - physical
            weight: 10
      containers:
      - env:
        - name: TZ
          value: Asia/Shanghai
        - name: LANG
          value: C.UTF-8
        image: nginx
        imagePullPolicy: IfNotPresent
        name: prefer-ssd
```

#### 案例8：应用多区域部署

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: must-be-diff-zone
  namespace: kube-public
  labels:
    app: must-be-diff-zone
spec:
  replicas: 3 
  selector:
    matchLabels:
      app: must-be-diff-zone
  template:
    metadata:
      labels:
        app: must-be-diff-zone
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - must-be-diff-zone
            topologyKey: region
      containers:
      - image: nginx
        imagePullPolicy: IfNotPresent
        name: must-be-diff-zone
```



## 污点和容忍

官方文档：https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

### **污点（Taints）**

前面的调度方式都是站在Pod的角度上，通过在Pod上添加属性，来确定Pod是否要调度到指定的Node上，其实我们也可以站在Node的角度上，通过在Node上添加**污点**属性，来决定是否允许Pod调度过来。

Node被设置上污点之后就和Pod之间存在了一种相斥的关系，进而拒绝Pod调度进来，甚至可以将已经存在的Pod驱逐出去。

污点的格式为：`key=value:effect`, key和value是污点的标签，effect描述污点的作用，支持如下三个选项：

- **PreferNoSchedule：**kubernetes将**尽量避免**把Pod调度到具有该污点的Node上，除非没有其他节点可调度
- **NoSchedule：**kubernetes将不会把Pod调度到具有该污点的Node上，但**不会影响当前**Node上已存在的Pod
- **NoExecute：**kubernetes将不会把Pod调度到具有该污点的Node上，同时也会将Node上已存在的Pod**驱离**


#### 污点常用命令

使用kubectl设置和去除污点的命令示例如下：

```powershell
# 设置污点
	kubectl taint nodes node1 key=value:effect
    	# 比如：
		# kubectl taint nodes node1 ssd=true:PreferNoSchedule
# 查看一个节点的污点：
	kubectl  get node k8s-node01 -o go-template --template {{.spec.taints}}
	kubectl describe node k8s-node01 | grep Taints -A 10

# 删除污点（和label类似）：
	#基于Key删除： 
	kubectl  taint nodes node1 key-
	#基于Key+Effect删除： 
	kubectl  taint nodes node1 key:PreferNoSchedule-
	
# 修改污点（Key和Effect相同）：
	 kubectl  taint nodes node1 key=value:effect --overwrite
```

#### 实战演示

接下来，演示下污点的效果：

1. 为node1节点设置label  kubectl label node node1 tag=TRUE
2. 为node1节点设置一个污点: `tag=TRUE:PreferNoSchedule`；然后创建pod1( pod1 可以 )
3. 修改为node1节点设置一个污点: `tag=TRUE:NoSchedule`；然后创建pod2( pod1 正常  pod2 失败 )
4. 修改为node1节点设置一个污点: `tag=TRUE:NoExecute`；然后创建pod3 ( 3个pod都失败 )

```powershell
# 为node1设置污点(PreferNoSchedule)
[root@master ~]# kubectl taint nodes node1 tag=TRUE:PreferNoSchedule

# 创建pod1
[root@master ~]# kubectl run taint1 --image=nginx:1.17.1 -n dev
[root@master ~]# kubectl get pods -n dev -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP           NODE   
taint1-7665f7fd85-574h4   1/1     Running   0          2m24s   10.244.1.59   node1    

# 为node1设置污点(取消PreferNoSchedule，设置NoSchedule)
[root@master ~]# kubectl taint nodes node1 tag:PreferNoSchedule-
[root@master ~]# kubectl taint nodes node1 tag=TRUE:NoSchedule

# 创建pod2
[root@master ~]# kubectl run taint2 --image=nginx:1.17.1 -n dev
[root@master ~]# kubectl get pods taint2 -n dev -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE
taint1-7665f7fd85-574h4   1/1     Running   0          2m24s   10.244.1.59   node1 
taint2-544694789-6zmlf    0/1     Pending   0          21s     <none>        <none>   

# 为node1设置污点(取消NoSchedule，设置NoExecute)
[root@master ~]# kubectl taint nodes node1 tag:NoSchedule-
[root@master ~]# kubectl taint nodes node1 tag=TRUE:NoExecute

# 创建pod3
[root@master ~]# kubectl run taint3 --image=nginx:1.17.1 -n dev
[root@master ~]# kubectl get pods -n dev -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED 
taint1-7665f7fd85-htkmp   0/1     Pending   0          35s   <none>   <none>   <none>    
taint2-544694789-bn7wb    0/1     Pending   0          35s   <none>   <none>   <none>     
taint3-6d78dbd749-tktkq   0/1     Pending   0          6s    <none>   <none>   <none>     
```

```markdown
小提示：
    使用kubeadm搭建的集群，默认就会给master节点添加一个污点标记,所以pod就不会调度到master节点上.
```

### **容忍（Toleration）**

上面介绍了污点的作用，我们可以在node上添加污点用于拒绝pod调度上来，但是如果就是想将一个pod调度到一个有污点的node上去，这时候应该怎么做呢？这就要使用到**容忍**。


> 污点就是拒绝，容忍就是忽略，Node通过污点拒绝pod调度上去，Pod通过容忍忽略拒绝

#### 匹配方式

```
方式一完全匹配：
tolerations:
- key: "taintKey"
  operator: "Equal"
  value: "taintValue"
  effect: "NoSchedule"

```

```
方式二不完全匹配：
tolerations:
- key: "taintKey"
  operator: "Exists"
  effect: "NoSchedule"

```

```
方式三大范围匹配（不推荐key为内置Taint）：
- key: "taintKey"
  operator: "Exists"

```

```
方式四匹配所有（不推荐）：
tolerations:
- operator: "Exists"

```

```
停留时间配置：
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
  tolerationSeconds: 3600

```

#### 实战演示

下面先通过一个案例看下效果：

1. 上一小节，已经在node1节点上打上了`NoExecute`的污点，此时pod是调度不上去的
2. 本小节，可以通过给pod添加容忍，然后将其调度上去

创建pod-toleration.yaml,内容如下 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-toleration
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    tag: "TRUE"    
  tolerations:      # 添加容忍
  - key: "tag"        # 要容忍的污点的key
    operator: "Equal" # 操作符
    value: "SSD"    # 容忍的污点的value
    effect: "NoExecute"   # 添加容忍的规则，这里必须和标记的污点规则SSD
#  tolerations:
#  - key: "tag"
#    operator: "Exists"    
```

```powershell
# 添加容忍之前的pod
[root@master ~]# kubectl get pods -n dev -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED 
pod-toleration   0/1     Pending   0          3s    <none>   <none>   <none>           

# 添加容忍之后的pod
[root@master ~]# kubectl get pods -n dev -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED
pod-toleration   1/1     Running   0          3s    10.244.1.62   node1   <none>        
```

下面看一下容忍的详细配置:

```powershell
[root@master ~]# kubectl explain pod.spec.tolerations
......
FIELDS:
   key       # 对应着要容忍的污点的键，空意味着匹配所有的键
   value     # 对应着要容忍的污点的值
   operator  # key-value的运算符，支持Equal和Exists（默认）
   effect    # 对应污点的effect，空意味着匹配所有影响
   tolerationSeconds   # 容忍时间, 当effect为NoExecute时生效，表示pod在Node上的停留时间
```

### 补充：内置污点

- **node.kubernetes.io/not-ready：**节点未准备好，相当于节点状态Ready的值为False。
- **ode.kubernetes.io/unreachable：**Node Controller访问不到节点，相当于节点状态Ready的值为Unknown。**node.kubernetes.io/out-of-disk：**节点磁盘耗尽。
- **node.kubernetes.io/memory-pressure：**节点存在内存压力。
- **node.kubernetes.io/disk-pressure：**节点存在磁盘压力。
- **node.kubernetes.io/network-unavailable：**节点网络不可达。
- **node.kubernetes.io/unschedulable：**节点不可调度。
- **node.cloudprovider.kubernetes.io/uninitialized：**如果Kubelet启动时指定了一个外部的cloudprovider，它将给当前节点添加一个Taint将其标记为不可用。在cloud-controller-manager的一个controller初始化这个节点后，Kubelet将删除这个Taint。

### 补充：降低驱逐延迟，实现宕机快速恢复

节点不健康，10秒后再驱逐（默认是300秒）：

```
tolerations:
- key: "node.kubernetes.io/unreachable"
  operator: "Exists"
  effect: "NoExecute"
  tolerationSeconds: 10
- key: node.kubernetes.io/not-ready  
  operator: Exists
  effect: NoExecute
  tolerationSeconds: 10
```

## 命令
```
创建一个污点(一个节点可以有多个污点):kubectI taint nodeS NODE NAME TAINT KEY=TAINT VALUE:EFFECT
比如:
kubectl taint nodes k8s-node01 ssd=true:PreferNoSchedule
查看一个节点的污点:
kubectl get node k8s-node01 -o go-template --template='{{.spec.taints}

}kubectl describe node k8s-node01 | grep Taints -A 10
删除污点(和label类似):基于Key州除:kubectl taint nodes k8s-node01 ssd-
共于Key+Effect除:
kubectl taint nodes k8s-node01 ssd:PreferNoSchedule
修改污点(Key和Effect相同):
kubectl taint nodes k8s-node01 ssd=true:PreferNoSchedule --overwrite
```