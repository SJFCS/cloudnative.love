---
sidebar_position: 2
---
kubernetes在V1.2版本开始，引入了Deployment控制器。值得一提的是，这种控制器并不直接管理pod，而是通过管理ReplicaSet来简介管理Pod，即：Deployment管理ReplicaSet，ReplicaSet管理Pod。


Deployment主要功能有下面几个：

- 支持ReplicaSet的所有功能
- 支持发布的停止、继续
- 支持滚动升级和回滚版本


## 源清单文件

```yaml
apiVersion: apps/v1 # 版本号
kind: Deployment # 类型       
metadata: # 元数据
  name: # rs名称 
  namespace: # 所属命名空间 
  labels: #标签
    controller: deploy
spec: # 详情描述
  replicas: 3 # 副本数量
  revisionHistoryLimit: 3 # 设置保留RS旧的revision的个数
  paused: false # 暂停部署，默认是false
  progressDeadlineSeconds: 600 # 部署超时时间（s），默认是600
  minReadySeconds: 30  # Pod在被认为是就绪之前需要等待的时间（秒）
  strategy: # 策略
    type: RollingUpdate # 滚动更新策略
    rollingUpdate: # 滚动更新
      maxSurge: 30% # 最大额外可以存在的副本数，可以为百分比，也可以为整数
      maxUnavailable: 30% # 最大不可用状态的 Pod 的最大值，可以为百分比，也可以为整数
  selector: # 选择器，通过它指定该控制器管理哪些pod
    matchLabels:      # Labels匹配规则
      app: nginx-pod
    matchExpressions: # Expressions匹配规则
      - key: app,
        operator: In|NotIn
        values: 
        - nginx-pod
  template: # pod模板，当副本数量不足时，会根据下面的模板创建pod副本
    <PodTemplate>
```
注意：必须满足 matchLabels 和 matchExpressions 的所有要求才能匹配。

## 更新策略

deployment支持两种更新策略:`Recreate`和`rollingUpdate`,可以通过`strategy`指定策略类型,支持两个属性:

**Recreate**

1) 编辑pc-deployment.yaml,在spec节点下添加更新策略

```yaml
spec:
  strategy: # 策略
    type: Recreate # 重建更新
```

**rollingUpdate**

1) 编辑pc-deployment.yaml,在spec节点下添加更新策略

```yaml
spec:
  strategy: # 策略
    type: RollingUpdate # 滚动更新策略
    rollingUpdate:
      maxUnavailable: 25%  # 允许超出所需副本数的最大比例，默认为25%。
      maxSurge: 25%        # 表示在滚动更新过程中允许不可用的最大副本比例，默认为25%。
```


## 版本回退

每次更新deployment都会创建新的rs资源:

```bash
# 查看rs,发现原来的rs的依旧存在，只是pod数量变为了0，而后又新产生了一个rs，pod数量为4
[root@master ~]# kubectl get rs -n dev
NAME                       DESIRED   CURRENT   READY   AGE
pc-deployment-6696798b78   0         0         0       7m37s
pc-deployment-6696798b11   0         0         0       5m37s
pc-deployment-c848d76789   4         4         4       72s
```

deployment支持版本升级过程中的暂停、继续功能以及版本回退等诸多功能，下面具体来看.

kubectl rollout： 版本升级相关功能，支持下面的选项：

- status       显示当前升级状态
- history     显示 升级历史记录

- pause       暂停版本升级过程
- resume    继续已经暂停的版本升级过程
- restart      重启版本升级过程
- undo        回滚到上一级版本（可以使用--to-revision回滚到指定版本）

```bash
# 查看当前升级版本的状态
kubectl rollout status deploy pc-deployment -n dev

# 查看升级历史记录
kubectl rollout history deploy pc-deployment -n dev

# 版本回滚
# 这里直接使用--to-revision=1回滚到了1版本， 如果省略这个选项，就是回退到上个版本，就是2版本
kubectl rollout undo deployment pc-deployment --to-revision=1 -n dev
```
版本回滚后查看rs，发现第一个rs中有4个pod运行，后面两个版本的rs中pod为运行
其实deployment之所以可是实现版本的回滚，就是通过记录下历史rs来实现的，
一旦想回滚到哪个版本，只需要将当前版本pod数量降为0，然后将回滚版本的pod提升为目标数量就可以了
```bash
[root@master ~]# kubectl get rs -n dev
NAME                       DESIRED   CURRENT   READY   AGE
pc-deployment-6696798b78   4         4         4       78m
pc-deployment-966bf7f44    0         0         0       37m
pc-deployment-c848d767     0         0         0       71m
```

若要在更新Deployment时添加自定义的变更原因(change-cause),可以通过编辑Deployment的yaml文件来手动添加或更新注解。下面是一个示例，展示如何手动为Deployment添加kubernetes.io/change-cause注解以记录变更原因：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    kubernetes.io/change-cause: "这里填写更新的原因"
  name: <deployment-name>
  namespace: <namespace>
```
注意：--record标志将命令行记录在注解中，来记录更新的原因，但在较新版本中已经被弃用。

kubernetes.io/change-cause注解是用户自定义的，意味着你可以填写任何对你和你的团队有意义的信息，以便追踪Deployment的变更历史。
```bash
kubectl set image deployment/<deployment-name> <container-name>=<new-image>:<tag>
kubectl annotate deployment <deployment-name> kubernetes.io/change-cause="手动更新镜像至v2.0.1" --overwrite
```
