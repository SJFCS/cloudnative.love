---
title: Authentication & Admission
tags: [Kubernetes]
---

## 访问控制概述

Kubernetes作为一个分布式集群的管理工具，保证集群的安全性是其一个重要的任务。所谓的安全性其实就是保证对Kubernetes的各种**客户端**进行**认证和鉴权**操作。

**客户端**

在Kubernetes集群中，客户端通常有两类：

- **User Account**：一般是独立于kubernetes之外的其他服务管理的用户账号。

- **Service Account**：kubernetes管理的账号，用于为Pod中的服务进程在访问Kubernetes时提供身份标识。

**认证、授权与准入控制**   

ApiServer是访问及管理资源对象的唯一入口。任何一个请求访问ApiServer，都要经过下面流程：
![](https://sysdig.com/wp-content/uploads/Kubernetes-Admission-controllers-01-flow-diagram-1930x580.jpg)

- Authentication（认证）：身份鉴别，只有正确的账号才能够通过认证
- Authorization（授权）：  判断用户是否有权限对访问的资源执行特定的动作
- Admission Control（准入控制）：用于补充授权机制以实现更加精细的访问控制功能。

不论是通过kubectl客户端还是REST请求访问K8s集群，最终都需要经过API Server来进行资源的操作并通过Etcd

请求发起方进行K8s API请求，经过Authentication（认证）、Authorization（鉴权）、AdmissionControl（准入控制）三个阶段的校验，最后把请求转化为对K8s对象的变更操作持久化至etcd中。

鉴权的最终目的，是区分请求对象，限定操作的影响范围，让其使用最小的权限完成自己所要进行操作，从而进一步保证安全。权限控制的划分方式有许多种，K8s中提供了4种鉴权模式，分别为Node、ABAC、RBAC和Webhook。

默认情况下，我们可以从/etc/kubernates/manifests/kube-apiserver.yaml文件中查看apiserver启动时认证模式

| 参数配置                         | 含义                                             | 一般的使用场景                                                                                                                |
| -------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| --authorization-mode=ABAC        | 使用基于属性的访问控制(ABAC)                     | 根据用户的用户名或者组名来控制其对集群资源的访问权限，适用于较小的组织或开发团队                                              |
| --authorization-mode=RBAC        | 使用基于角色的访问控制(RBAC)                     | 自定义ServiceAccount，绑定资源根据角色来控制资源的访问权限，适用于较大型的组织或者开发运维团队                                |
| --authorization-mode=Webhook     | 使用HTTP回调模式，允许你使用远程REST端点管理鉴权 | 将鉴权角色交给外部服务进行处理，根据自身需求，定制和扩展鉴权策略，如自定义Webhook鉴权模块对跨云平台的应用进行集中的的访问控制 |
| --authorization-mode=Node        | 针对kubelet发出的API请求执行鉴权                 | 验证节点身份，确保只有经过身份验证且具有所需权限的Node才能连接到K8s集群                                                       |
| --authorization-mode=AlwaysDeny  | 阻止所有请求                                     | 一般仅用作测试                                                                                                                |
| --authorization-mode=AlwaysAllow | 允许所有请求                                     | 不需要API请求进行鉴权的场景                                                                                                   |

## 认证管理

Kubernetes集群安全的最关键点在于如何识别并认证客户端身份，它提供了3种客户端身份认证方式：

- HTTP Base认证：通过用户名+密码的方式认证

  这种认证方式是把“用户名:密码”用BASE64算法进行编码后的字符串放在HTTP请求中的Header Authorization域里发送给服务端。服务端收到后进行解码，获取用户名及密码，然后进行用户身份认证的过程。

- HTTP Token认证：通过一个Token来识别合法用户

  这种认证方式是用一个很长的难以被模仿的字符串--Token来表明客户身份的一种方式。每个Token对应一个用户名，当客户端发起API调用请求时，需要在HTTP Header里放入Token，API Server接到Token后会跟服务器中保存的token进行比对，然后进行用户身份认证的过程。

- HTTPS证书认证：基于CA根证书签名的双向数字证书认证方式

  这种认证方式是安全性最高的一种方式，但是同时也是操作起来最麻烦的一种方式。


**HTTPS认证大体分为3个过程：**

1. 证书申请和下发

  HTTPS通信双方的服务器向CA机构申请证书，CA机构下发根证书、服务端证书及私钥给申请者

2. 客户端和服务端的双向认证

  1. 客户端向服务器端发起请求，服务端下发自己的证书给客户端，
    客户端接收到证书后，通过私钥解密证书，在证书中获得服务端的公钥，
    客户端利用服务器端的公钥认证证书中的信息，如果一致，则认可这个服务器
  2. 客户端发送自己的证书给服务器端，服务端接收到证书后，通过私钥解密证书，
    在证书中获得客户端的公钥，并用该公钥认证证书信息，确认客户端是否合法

3. 服务器端和客户端进行通信

  1. 服务器端和客户端协商好加密方案后，客户端会产生一个随机的秘钥并加密，然后发送到服务器端。  
  2. 服务器端接收这个秘钥后，双方接下来通信的所有内容都通过该随机秘钥加密

## 授权管理

授权发生在认证成功之后，通过认证就可以知道请求用户是谁， 然后Kubernetes会根据事先定义的授权策略来决定用户是否有权限访问，这个过程就称为授权。

**API Server目前支持以下几种授权策略：**
- AlwaysDeny：表示拒绝所有请求，一般用于测试
- AlwaysAllow：允许接收所有请求，相当于集群不需要授权流程（Kubernetes默认的策略）
- ABAC：基于属性的访问控制，表示使用用户配置的授权规则对用户请求进行匹配和控制
- Webhook：通过调用外部REST服务对用户进行授权
- Node：是一种专用模式，用于对kubelet发出的请求进行访问控制
- RBAC：基于角色的访问控制（kubeadm安装方式下的默认选项）


RBAC(Role-Based Access Control) 基于角色的访问控制，主要是在描述一件事情：**给哪些对象授予了哪些权限**

**其中涉及到了下面几个概念：**
- 对象：User、Groups、ServiceAccount
- 角色：代表着一组定义在资源上的可操作动作(权限)的集合
- 绑定：将定义好的角色跟用户绑定在一起


## RBAC配置示例

RBAC常用示例：https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/

RBAC引入了4个顶级资源对象：

- Role、ClusterRole：角色，用于指定一组权限
- RoleBinding、ClusterRoleBinding：角色绑定，用于将角色（权限）赋予给对象

### Role和ClusterRole

一个角色就是一组权限的集合，这里的权限都是许可形式的（白名单）。

```yaml
# Role只能对命名空间内的资源进行授权，需要指定nameapce
# ClusterRole可以对集群范围内资源、跨namespaces的范围资源、非资源类型进行授权
kind: Role|ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 namespace: default #Role是作用单个Namespace下的，具有命名空间隔离，所以需要制定Namespace，不指定则为default
 name: pod-reader
rules:
- apiGroups: [""] # 支持的API组列表,"" 空字符串，表示核心API群
 resources: ["pods"] # 支持的资源对象列表，可以定义多个，比如pods、service等
 verbs: ["get", "watch", "list"] # 允许的对资源对象的操作方法列表，可以定义多个，比如create、delete、list、get、watch、deletecollection等
```

### RoleBinding和ClusterRoleBinding

角色绑定用来把一个角色绑定到一个目标对象上，绑定目标可以是User、Group或者ServiceAccount。

```yaml
# RoleBinding可以将同一namespace中的subject绑定到某个Role下，则此subject即具有该Role定义的权限
# ClusterRoleBinding在整个集群级别和所有namespaces将特定的subject与ClusterRole绑定，授予权限

kind: RoleBinding|ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: pod-reader
  namespace: dev #ClusterRoleBinding 不需要此行
subjects: # 配置被绑定对象，可以配置多个
- kind: User # 绑定对象的类别，当前为User，还可以是Group、ServiceAccount
  name: Name # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef: # 绑定的类别
  kind: Role|ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
### 聚合ClusterRole

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: []
=====================================================
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: monitoring-endpoints
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
# These rules will be added to the "monitoring" role.
rules:
- apiGroups: [""]
  resources: ["services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
```

### **RoleBinding引用ClusterRole进行授权**

RoleBinding可以引用ClusterRole，对属于同一命名空间内ClusterRole定义的资源主体进行授权。

```markdown
    一种很常用的做法就是，集群管理员为集群范围预定义好一组角色（ClusterRole），然后在多个命名空间中重复使用这些ClusterRole。这样可以大幅提高授权管理工作效率，也使得各个命名空间下的基础性授权规则与使用体验保持一致。
```

```yaml
# 虽然authorization-clusterrole是一个集群角色，但是因为使用了RoleBinding
# 所以username只能读取dev命名空间中的资源
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: authorization-role-binding-ns
 namespace: dev
subjects:
- kind: User
 name: username
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: ClusterRole
 name: authorization-clusterrole
 apiGroup: rbac.authorization.k8s.io
```



## RBAC企业实战：

![image-20210924211857675](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%87%86%E5%85%A5%E6%8E%A7%E5%88%B6/2021.09.24-21:18:59-image-20210924211857675.png)

> 建议把ServiceAcount放在同一namespace下方便管理，将常用权限定义为ClusterRole，然后根据ServiceAcount使用RoleBinding与所需ClusterRole进行绑定

### 需求1：

1. 用户sjf可以查看default、kube-system下Pod的日志
2. 用户jinfeng可以在default下的Pod中执行命令，并且可以删除Pod

**创建ns、pod只读权限[get,list,watch]的ClusterRole**

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-readonly
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  verbs:
  - get
  - list
  - watch

```

**创建pod删除权限[get,list,delete]的ClusterRole**

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-delete
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - delete

```

**创建pod执行命令权限[get,list,create]的ClusterRole**


```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-exec
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
- apiGroups:
  - ""
  resources:
  - pods/exec
  verbs:
  - create
```

**创建pod日志查看权限[get,list,create]的ClusterRole**

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-log
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - list
  - watch
```

**创建用户管理命名空间：**

```
kubectl create ns kube-users
```

**绑定全局命名空间查看权限：**

```
kubectl create clusterrolebinding namespace-readonly \
--clusterrole=namespace-readonly  --serviceaccount=system:serviceaccounts:kube-users
```

**创建用户：**

```
kubectl create sa sjf jinfeng -n kube-users
```
**绑定权限：**

```
kubectl create rolebinding sjf-pod-log \
--clusterrole=pod-log   --serviceaccount=kube-users:sjf --namespace=kube-system
kubectl create rolebinding sjf-pod-log \
--clusterrole=pod-log   --serviceaccount=kube-users:sjf --namespace=default

kubectl create rolebinding jinfeng-pod-exec \
--clusterrole=pod-exec   --serviceaccount=kube-users:jinfeng --namespace=default
kubectl create rolebinding jinfeng-pod-delete \
--clusterrole=pod-delete   --serviceaccount=kube-users:jinfeng --namespace=default

```


### 需求2：

1. 创建一个名为deployment-clusterrole的clusterrole

   该clusterrole只允许创建Deployment、Daemonset、Statefulset的create操作

2. 在名字为app-team1的namespace下创建一个名为cicd-token的serviceAccount，并且将上一步创建clusterrole的权限绑定到该serviceAccount

创建namespace和serviceAccount

```
[root@k8s-master01 examples]# kubectl  create ns app-team1
namespace/app-team1 created
You have new mail in /var/spool/mail/root
[root@k8s-master01 examples]# kubectl  create sa cicd-token -n app-team1
serviceaccount/cicd-token created

```

创建clusterrole

```
[root@k8s-master01 ~]# cat dp-clusterrole.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: deployment-clusterrole
rules:
- apiGroups: ["extensions", "apps"]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["deployments","statefulsets","daemonsets"]
  verbs: ["create"]
[root@k8s-master01 ~]# kubectl create -f dp-clusterrole.yaml 
clusterrole.rbac.authorization.k8s.io/deployment-clusterrole created

```

绑定权限

```
[root@k8s-master01 ~]# kubectl create rolebinding deployment-rolebinding --clusterrole=deployment-clusterrole --serviceaccount=app-team1:cicd-token -n app-team1
```
或者
```

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-rolebinding
  namespace: app-team1
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: deployment-clusterrole
subjects:
- kind: ServiceAccount
  name: cicd-token
  namespace: app-team1
```
创建deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: app-team1
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      - image: redis
        imagePullPolicy: Always
        name: redis
      restartPolicy: Always
```

### 需求3：

创建一个只能管理dev空间下Pods资源的账号

1) 创建账号

```powershell
# 1) 创建证书
[root@master pki]# cd /etc/kubernetes/pki/
[root@master pki]# (umask 077;openssl genrsa -out devman.key 2048)

# 2) 用apiserver的证书去签署
# 2-1) 签名申请，申请的用户是devman,组是devgroup
[root@master pki]# openssl req -new -key devman.key -out devman.csr -subj "/CN=devman/O=devgroup"     
# 2-2) 签署证书
[root@master pki]# openssl x509 -req -in devman.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out devman.crt -days 3650

# 3) 设置集群、用户、上下文信息
[root@master pki]# kubectl config set-cluster kubernetes --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://192.168.109.100:6443

[root@master pki]# kubectl config set-credentials devman --embed-certs=true --client-certificate=/etc/kubernetes/pki/devman.crt --client-key=/etc/kubernetes/pki/devman.key

[root@master pki]# kubectl config set-context devman@kubernetes --cluster=kubernetes --user=devman

# 切换账户到devman
[root@master pki]# kubectl config use-context devman@kubernetes
Switched to context "devman@kubernetes".

# 查看dev下pod，发现没有权限
[root@master pki]# kubectl get pods -n dev
Error from server (Forbidden): pods is forbidden: User "devman" cannot list resource "pods" in API group "" in the namespace "dev"

# 切换到admin账户
[root@master pki]# kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
```

2） 创建Role和RoleBinding，为devman用户授权

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: dev
  name: dev-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
  
---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: authorization-role-binding
  namespace: dev
subjects:
- kind: User
  name: devman
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-role
  apiGroup: rbac.authorization.k8s.io
```

```powershell
[root@master pki]# kubectl create -f dev-role.yaml
role.rbac.authorization.k8s.io/dev-role created
rolebinding.rbac.authorization.k8s.io/authorization-role-binding created
```

3) 切换账户，再次验证

```powershell
# 切换账户到devman
[root@master pki]# kubectl config use-context devman@kubernetes
Switched to context "devman@kubernetes".

# 再次查看
[root@master pki]# kubectl get pods -n dev
NAME                                 READY   STATUS             RESTARTS   AGE
nginx-deployment-66cb59b984-8wp2k    1/1     Running            0          4d1h
nginx-deployment-66cb59b984-dc46j    1/1     Running            0          4d1h
nginx-deployment-66cb59b984-thfck    1/1     Running            0          4d1h

# 为了不影响后面的学习,切回admin账户
[root@master pki]# kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
```

## 准入控制

通过了前面的认证和授权之后，还需要经过准入控制处理通过之后，apiserver才会处理这个请求。

准入控制是一个可配置的控制器列表，可以通过在Api-Server上通过命令行设置选择执行哪些准入控制器：

```powershell
--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,
                      DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds
```

只有当所有的准入控制器都检查通过之后，apiserver才执行该请求，否则返回拒绝。

当前可配置的Admission Control准入控制如下：

- AlwaysAdmit：允许所有请求
- AlwaysDeny：禁止所有请求，一般用于测试
- AlwaysPullImages：在启动容器之前总去下载镜像
- DenyExecOnPrivileged：它会拦截所有想在Privileged Container上执行命令的请求
- ImagePolicyWebhook：这个插件将允许后端的一个Webhook程序来完成admission controller的功能。
- Service Account：实现ServiceAccount实现了自动化
- SecurityContextDeny：这个插件将使用SecurityContext的Pod中的定义全部失效
- ResourceQuota：用于资源配额管理目的，观察所有请求，确保在namespace上的配额不会超标
- LimitRanger：用于资源限制管理，作用于namespace上，确保对Pod进行资源限制
- InitialResources：为未设置资源请求与限制的Pod，根据其镜像的历史资源的使用情况进行设置
- NamespaceLifecycle：如果尝试在一个不存在的namespace中创建资源对象，则该创建请求将被拒绝。当删除一个namespace时，系统将会删除该namespace中所有对象。
- DefaultStorageClass：为了实现共享存储的动态供应，为未指定StorageClass或PV的PVC尝试匹配默认的StorageClass，尽可能减少用户在申请PVC时所需了解的后端存储细节
- DefaultTolerationSeconds：这个插件为那些没有设置forgiveness tolerations并具有notready:NoExecute和unreachable:NoExecute两种taints的Pod设置默认的“容忍”时间，为5min
- PodSecurityPolicy：这个插件用于在创建或修改Pod时决定是否根据Pod的security context和可用的PodSecurityPolicy对Pod的安全策略进行控制

### 资源配额ResourceQuota

别忘了指定ns

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-test
  labels:
    app: resourcequota
spec:
  hard:
    pods: 50
    requests.cpu: 0.5
    requests.memory: 512Mi
    limits.cpu: 5
    limits.memory: 16Gi
    configmaps: 20
    requests.storage: 40Gi
    persistentvolumeclaims: 20
    replicationcontrollers: 20
    secrets: 20
    services: 50
    services.loadbalancers: "2"
    services.nodeports: "10"
=================================
pods：限制最多启动Pod的个数
requests.cpu：限制最高CPU请求数
requests.memory：限制最高内存的请求数
limits.cpu：限制最高CPU的limit上限
limits.memory：限制最高内存的limit上限

```

### 资源限制LimitRange

别忘了指定ns

**默认的requests和limits**

```
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-mem-limit-range
spec:
  limits:
  - default:
      cpu: 1
      memory: 512Mi
    defaultRequest:
      cpu: 0.5
      memory: 256Mi
    type: Container
=============================
default：默认limits配置
defaultRequest：默认requests配置

```

**requests和limits的范围**

```
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-min-max-demo-lr
spec:
  limits:
  - max:
      cpu: "800m"
      memory: 1Gi
    min:
      cpu: "200m"
      memory: 500Mi
    type: Container
================================
max：内存CPU的最大配置
min：内存CPU的最小配置

```

**限制申请存储空间的大小**

```
apiVersion: v1
kind: LimitRange
metadata:
  name: storagelimits
spec:
  limits:
  - type: PersistentVolumeClaim
    max:
      storage: 2Gi
    min:
      storage: 1Gi
==========================
max：最大PVC的空间
min：最小PVC的空间

```


## RBAC 案例

给一个 AWS user/role 添加访问 EKS 集群的权限

官方文档: https://aws.amazon.com/cn/premiumsupport/knowledge-center/amazon-eks-cluster-access/

首先，使用 `kubectl edit configmap aws-auth -n kube-system` 修改配置，添加 `mapUsers` 配置，如下:

```yaml
apiVersion: v1 
kind: ConfigMap 
metadata: 
  name: aws-auth 
  namespace: kube-system 
data: 
  mapRoles: | 
    - rolearn: arn:aws:iam::<a-userrole>
      username: system:node:{{EC2PrivateDNSName}} 
      groups: 
        - system:bootstrappers 
        - system:nodes 
  # 添加如下配置，将 IAM 用户和 k8s 用户绑定起来
  mapUsers: | 
    - userarn: arn:aws:iam::11122223333:user/designated_user  # IAM user
      username: designated_user    # kubernetes user
      groups: 
        - system:masters
```

完成后，再使用 kubectl 给 `designated_user` 赋予集群管理员的角色：

```shell
kubectl create clusterrolebinding xxx-cluster-admin --clusterrole=cluster-admin --user=designated_user
```

这样完成后，`designated_user` 就可以使用 aws 命令，生成 `kubeconfig` 并访问 eks 集群了：

```shell
# 生成 Kubeconfig
aws eks --region <region> update-kubeconfig --name <cluster_name>
# 访问 eks 集群
kubectl get pods
```

## 给 EKS ServiceAccount 绑定一个 AWS IAM Role

>[IAM roles for service accounts- AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

>[为集群创建 IAM OIDC Provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)

1. 每个 EKS 集群都有一个 OIDC issuer URL，首先我们需要使用它，创建一个 IAM OIDC Prodiver
   1. [Create an IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
2. 创建 IAM Role，绑定需要的 Policy 权限策略，并将 EKS 集群的 serviceAccount 加入到「信任关系」中
   1. [Creating an IAM role and policy for your service account](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
3. 创建 EKS ServiceAccount，使用 annotation 关联到前面创建的 IAM Role，然后在 Pod 中使用此 serviceaccount
  1. [Associate an IAM role to a service account](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)

