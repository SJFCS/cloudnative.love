---
title: ConfigMap&Secret
tags: [Kubernetes]
---
## ConfigMap

ConfigMap是一种比较特殊的存储卷，它的主要作用是用来存储配置信息的。

创建configmap.yaml，内容如下：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap
  namespace: dev
data:
  info: |
    username:admin
    password:123456
```

### 创建ConfigMap的几种形式

```bash
从文件夹创建
kubectl create cm cmfromdir --from-file=conf/
从文件创建
kubectl create cm cmfromfile --from-file=conf/redis.conf 
从文件创建并改名
kubectl create cm cmspecialname --from-file=game-conf=game.conf
kubectl create cm cmspecialname2 --from-file=game-conf=game.conf  --from-file=redis-conf=redis.conf
从环境变量创建
kubectl create cm gameenvcm --from-env-file=game.conf
从命令行创建
kubectl  create cm envfromliteral --from-literal=level=INFO --from-literal=PASSWORD=redis123
```
### 使用valueFrom和envFrom定义环境变量

```bash
containers:
  - image: nginx 
    name: nginx
    envFrom:
    - configMapRef:
        name: gameenvcm
      prefix: fromCm_ # prefix: 可为变量添加开头
    env:
    - name: TEST_ENV
      value: testenv
    - name: LIVES
      valueFrom:
        configMapKeyRef:
          name: gameenvcm
          key: lives
```

### 以文件的形式挂载ConfigMap


注意会覆盖挂载文件夹，可使用**subPath**参数规避

```BASH
apiVersion: v1
kind: ConfigMap
metadata:
  name: combined-configs
data:
  redis.conf: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
  myconfig.conf: |
    option1: value1
    option2: value2
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config/redis.conf
      subPath: redis.conf
    - name: config-volume
      mountPath: /etc/config/myconfig.conf
      subPath: myconfig.conf
  volumes:
  - name: config-volume
    configMap:
      name: combined-configs
```

### 自定义挂载权限及名称

```yaml
volumes:
  - name: redisconf
    configMap:
      name: redis-conf
  - name: cmfromfile
    configMap:
      name: cmfromfile
      items:
        - key: redis.conf
          path: redis.conf.bak
        - key: redis.conf
          path: redis.conf.bak2
          mode: 0644 # 优先级高
      defaultMode: 0666  # 328 8进制与10进制
```
## Secret

在kubernetes中，还存在一种和ConfigMap非常类似的对象，称为Secret对象。它主要用于存储敏感信息，例如密码、秘钥、证书等等。

### Secret常用类型

Secret：[https://kubernetes.io/docs/concepts/configuration/secret/#creating-a-secret](https://kubernetes.io/docs/concepts/configuration/secret/)

- paque：通用型Secret，默认类型；
- ubernetes.io/service-account-token：作用于ServiceAccount，包含一个令牌，用于标识API服务账户；
- ubernetes.io/dockerconfigjson：下载私有仓库镜像使用的Secret，和宿主机的/root/.docker/config.json一致，宿主机登录后即可产生该文件；
- ubernetes.io/basic-auth：用于使用基本认证（账号密码）的Secret，可以使用Opaque取代；
- ubernetes.io/ssh-auth：用于存储ssh密钥的Secret；
- ubernetes.io/tls：用于存储HTTPS域名证书文件的Secret，可以被Ingress使用；
- ootstrap.kubernetes.io/token：一种简单的 bearer token，用于创建新集群或将新节点添加到现有集群，在集群安装时可用于自动颁发集群的证书。


例子：

1)  首先使用base64对数据进行编码

```yaml
[root@master ~]# echo -n 'admin' | base64 #准备username
YWRtaW4=
[root@master ~]# echo -n '123456' | base64 #准备password
MTIzNDU2
```
2)  接下来编写secret.yaml，并创建Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret
  namespace: dev
type: Opaque
data:
  username: YWRtaW4=
  password: MTIzNDU2
```
3) 创建pod-secret.yaml，将上面创建的secret挂载进去：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
    volumeMounts: # 将secret挂载到目录
    - name: config
      mountPath: /secret/config
  volumes:
  - name: config
    secret:
      secretName: secret
```



### 使用Secret拉取私有仓库镜像

```bash
kubectl create secret docker-registry myregistrykey \
--docker-server=DOCKER_REGISTRY_SERVER \
--docker-username=DOCKER_USER \
--docker-password=DOCKER_PASSWORD \
--docker-email=DOCKER_EMAIL
```

pod中使用以下字段：
```bash
 spec:
      imagePullSecrets:
      - name: myregistry
      containers:
```

### 使用Secret管理HTTPS证书

创建证书

```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=test.com"
```

创建secret tls

```bash
kubectl -n default create secret tls nginx-test-tls --key=tls.key --cert=tls.crt
```

ingress调用证书

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: nginx-https-test
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: https-test.com
    http:
      paths:
      - backend:
          serviceName: nginx-svc
          servicePort: 80
  tls:
   - secretName: nginx-test-tls
```


## ConfigMap&Secret 热更新（基于文件）

```bash
kubectl create cm nginx-conf --from-file=nginx.conf --dry-run=client -oyaml | kubectl replace -f -
```

## ConfigMap&Secret使用限制

- 提前场景ConfigMap和Secret
- 引用Key必须存在
- envFrom、valueFrom无法热更新环境变量
- envFrom配置环境变量，如果key是无效的，它会忽略掉无效的key
- ConfigMap和Secret必须要和Pod或者是引用它资源在同一个命名空间
- subPath也是无法热更新的

你可以添加**immutable:true** 设置为不可变的，来禁止通过kubectl edit修改此资源

- https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes
- https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/zh-cn/docs/tasks/configmap-secret/managing-secret-using-kubectl/
- https://kubernetes.io/zh-cn/docs/tasks/configmap-secret/managing-secret-using-config-file/