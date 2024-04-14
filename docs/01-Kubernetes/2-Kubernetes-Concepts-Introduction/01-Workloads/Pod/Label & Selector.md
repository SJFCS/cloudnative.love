---
title: Label Selector
tags: [Kubernetes]
---
- https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#set-based-requirement

Label是kubernetes系统中的一个重要概念。它的作用就是在资源上添加标识，用来对它们进行区分和选择。

- 一个Label会以key/value键值对的形式附加到各种对象上，如Node、Pod、Service等等
- 一个资源对象可以定义任意数量的Label ，同一个Label也可以被添加到任意数量的资源对象上去
- Label通常在资源对象定义时确定，当然也可以在对象创建后动态添加或者删除

可以通过Label实现资源的多维度分组，以便灵活、方便地进行资源分配、调度、配置、部署等管理工作。

## Label Selector

标签定义完毕之后，还要考虑到标签的选择，这就要使用到Label Selector，即：

- Label用于给某个资源对象定义标识
- Label Selector用于查询和筛选拥有某些标签的资源对象

**当前有两种Label Selector：**

- 基于等式的Label Selector
  - name = slave: 选择所有包含Label中key="name"且value="slave"的对象
  - env != production: 选择所有包括Label中的key="env"且value不等于"production"的对象

- 基于集合的Label Selector
  - name in (master, slave): 选择所有包含Label中的key="name"且value="master"或"slave"的对象
  - name not in (frontend): 选择所有包含Label中的key="name"且value不等于"frontend"的对象

标签的选择条件可以使用多个，此时将多个Label Selector进行组合，使用逗号","进行分隔即可。例如：
	-	name=slave，env!=production
	-	name not in (frontend)，env!=production

例子：
```yaml
 selector:
   matchLabels:
     pv: "nfs-slow"
   matchExpressions:
     - {key: environment, operator: In, values: [dev]}
```

## **命令方式**

```bash
# 为pod资源打标签
[root@master ~]# kubectl label pod nginx-pod version=1.0 -n dev
pod/nginx-pod labeled
```
``` bash
# 为pod资源更新标签
[root@master ~]# kubectl label pod nginx-pod version=2.0 -n dev --overwrite
pod/nginx-pod labeled
```
```bash
# 查看标签
[root@master ~]# kubectl get pod nginx-pod  -n dev --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
nginx-pod   1/1     Running   0          10m   version=2.0
```
```bash
# 筛选标签
[root@master ~]# kubectl get pod -n dev -l version=2.0  --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
nginx-pod   1/1     Running   0          17m   version=2.0
[root@master ~]# kubectl get pod -n dev -l version!=2.0 --show-labels
No resources found in dev namespace.
```
```bash
# 选择app为reviews或者productpage的svc：
[root@k8s-master01 ~]# kubectl get svc -l  'app in (details, productpage)' --show-labels
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     LABELS
details       ClusterIP   10.99.9.178      <none>        9080/TCP   45h     app=details
nginx         ClusterIP   10.106.194.137   <none>        80/TCP     2d21h   app=productpage,version=v1
productpage   ClusterIP   10.105.229.52    <none>        9080/TCP   45h     app=productpage,tier=frontend
```
```bash
# 选择app为productpage或reviews但不包括version=v1的svc：
[root@k8s-master01 ~]# kubectl get svc -l  version!=v1,'app in (details, productpage)' --show-labels
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   LABELS
details       ClusterIP   10.99.9.178     <none>        9080/TCP   45h   app=details
productpage   ClusterIP   10.105.229.52   <none>        9080/TCP   45h   app=productpage,tier=frontend
```
```bash
# 选择labelkey名为app的svc：
[root@k8s-master01 ~]# kubectl get svc -l app --show-labels
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     LABELS
details       ClusterIP   10.99.9.178      <none>        9080/TCP   45h     app=details
nginx         ClusterIP   10.106.194.137   <none>        80/TCP     2d21h   app=productpage,version=v1
productpage   ClusterIP   10.105.229.52    <none>        9080/TCP   45h     app=productpage,tier=frontend
ratings       ClusterIP   10.96.104.95     <none>        9080/TCP   45h     app=ratings
reviews       ClusterIP   10.102.188.143   <none>        9080/TCP   45h     app=reviews

#删除标签
[root@master ~]# kubectl label pod nginx-pod version- -n dev
pod/nginx-pod labeled
```
