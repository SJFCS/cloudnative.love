---
title: 部署Dashboard
---



### Dashboard

https://github.com/kubernetes/dashboard

#### 部署

dashboard 安装方法直接按照官网所说的执行即可：

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```

#### 创建用户

现在 dashboard 已经部署好了，问题是如何访问 dashboard 服务，新版的 dashboard  将默认权限控制到了最小，只够 dashboard 部署，要想正常访问 dashboard  服务需要授权和创建管理员账户：[官方文档:**creating-sample-user.md**](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

将如下代码保存至 `dashboard-admin.yaml`：

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding 
metadata: 
  name: admin-user
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
```

然后执行：

```
kubectl apply -f admin.yaml
```

接着获取创建的 admin 账户的 token：

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

#### 服务暴露的三种方法

拿到 token 开始将 dashboard 服务暴露出来，有三种方式：

+ **方式一** `kubectl proxy`反向代理

  官方给出的访问方式为`kubectl proxy`要从本地工作站访问 Dashboard，必须创建到 Kubernetes 集群的安全通道。运行以下命令:

```
kubectl proxy
```

然后在浏览器访问 Dashboard（http）：

```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

需要注意的是使用这种方式只能是在本机访问（服务也必须在本机），这意味着无法从集群外通过浏览器打开 dashboard

运行下面命令，可以接收所有主机的请求，可以访问到dashboard页面，但因为目前 dashboard 不支持除 `localhost` 和 `127.0.0.1` 以外的主机名登录进入控制台（ https://github.com/kubernetes/dashboard/issues/4624 ），仍然无法提供登录。

```
kubectl proxy --address='0.0.0.0'  --accept-hosts='^*$' --port=8001
```

+ **方式二** NodePort

  将kubernetes-dashboard SVC的ClusterIP更改为NodePort

```
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
```

查看SVC端口号：

```
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
```

浏览器访问集群任意节点kubernetes-dashboard SVC 的端口号即可（https）

- **方式三** `kubectl port-forward`端口转发

执行如下命令进行端口转发：

```
sudo kubectl port-forward --namespace kubernetes-dashboard --address 0.0.0.0 service/kubernetes-dashboard 443
```

然后在集群外的机器上访问进行端口转发的那台机器的 ip 即可（https）：



