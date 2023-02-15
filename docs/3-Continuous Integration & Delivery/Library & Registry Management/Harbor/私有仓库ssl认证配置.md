---
title: 私有仓库认证ssl配置
---



## HTTPS for Conainerd

编辑`/etc/containerd/config.toml`

## HTTPS for Docker

`/etc/docker/certs.d/`

[Configure HTTPS Access to Harbor](https://goharbor.io/docs/2.3.0/install-config/configure-https/)

## secret for Conainerd

[     配命令行 置k8s拉取Harbor镜像         ](https://www.cnblogs.com/zhang-guansheng/p/13752872.html)    

除了创建secret 也可在/etc/containerd/config.toml`中配置

**创建Secret**

```bash
# 认证名称为：harbor-registry
kubectl create secret docker-registry harbor-registry \
--namespace=项目所在命名空间
--docker-server=IP:PORT OR DOMAIN \
--docker-username=username \
--docker-password='password' \
--docker-email=test@qq.com         
```

**将 secret 添加到 ServiceAccount**

```bash
# 认证名称为：docker-harbor-registry
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-harbor-registry"}]}'
```

**在Deployment文件中添加认证**

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testapi-prod-node
spec:
  replicas: 1
  selector:
    matchLabels:
      app: testapi-prod
  template:
    metadata:
      labels:
        app: testapi-prod
    spec:
      containers:
        - name: testapi-prod-instance
          image: {IMAGE-URL}
          command: [ "dotnet", "DotNetCore.API.dll" ]
          ports:
          - containerPort: 5000
      imagePullSecrets:
        - name: harbor-registry
##        
spec:
    containers:
    - image: 
     imagePullPolicy: Always

```

## secret for Docker


    K8S在默认情况下只能拉取Harbor仓库中的公有镜像，拉取私有镜像会报错：ErrImagePull 或 ImagePullBackOff

两种解决办法：

    1.到 Harbor 仓库中把该镜像的项目设置成公开权限
    2.创建认证登录秘钥，在拉取镜像时带上该秘钥

1，先用docker登录harbor，登录的用户名密码为在harbor上注册的用户名密码，并且登录用户需要有对应仓库的拉取权限，否则不能访问仓库。

```
    docker login -u admin -p Harbor12345 hub.mooc.com
```

登录示例：docker login hub.yxtc.com:8081，登录之后会生成~/.docker/config.json文件，config.json文件内容如下

```
[root@node1 ~]# cat ~/.docker/config.json
{
        "auths": {
                "hub.mooc.com": {
                        "auth": "YWRtaW46SGFyYm9yMTIzNDU="
                }
        }
```
解码base64，可以看见正是我们刚刚输入的用户名和密码
```
[root@node1 ~]# echo YWRtaW46SGFyYm9yMTIzNDU= | base64 -d &&echo
admin:Harbor12345
```
对上面的config.json进行base64加密，命令如下：
```
[root@node1 ~]# cat ~/.docker/config.json |base64 -w 0 &&echo
ewoJImF1dGhzIjogewoJCSJodWIubW9vYy5jb20iOiB7CgkJCSJhdXRoIjogIllXUnRhVzQ2U0dGeVltOXlNVEl6TkRVPSIKCQl9Cgl9Cn0=
```

创建secret.yaml文件，文件内容如下：
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: kubernetes.io/dockerconfigjson
data:
   #这里添加加密后的密钥
  .dockerconfigjson:   ewoJImF1dGhzIjogewoJCSJodWIubW9vYy5jb20iOiB7CgkJCSJhdXRoIjogIllXUnRhVzQ2U0dGeVltOXlNVEl6TkRVPSIKCQl9Cgl9Cn0=

```

创建secret，命令如下：
```
        kubectl create -f secret.yaml，生成secret
```

用imagePullSecrets指定secret：
```
spec:
  imagePullSecrets:
    - name: mysecret
```



