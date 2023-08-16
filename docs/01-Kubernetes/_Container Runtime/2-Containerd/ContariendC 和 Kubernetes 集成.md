---
title: ContariendC 和 Kubernetes 集成
tags: [containerd,kubernetes,troubleshooting]
---
## 环境

1. k8s的容器运行时为contariend 
2. 镜像仓库harbor 开启了https
3. 拉取的仓库为私有

crictl连接容器运行时为Containerd  ，如下

```bash
cat /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 30
debug: false
```

## 现象

创建cronjob任务时 POD 状态为 `ImagePullBackOff` 


```bash
[root@node1 configs]# kubectl get pod -o wide
NAME                            READY   STATUS             RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
cronjob-demo-1627891980-vhsfd   0/1     ImagePullBackOff   0          16m   10.233.28.5   node3   <none>           <none>
```

通过`kubectl describe`查看发现 无法拉取镜像

```bash
[root@node1 configs]# kubectl describe pod cronjob-demo-1627891980-vhsfd


  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  2m7s                default-scheduler  Successfully assigned default/cronjob-demo-1627891980-vhsfd to node3
  Warning  Failed     55s                 kubelet            Failed to pull image "hub.mooc.com/kubernetes/cronjob:v1": rpc error: code = Unknown desc = faile                           d to pull and unpack image "hub.mooc.com/kubernetes/cronjob:v1": failed to resolve reference "hub.mooc.com/kubernetes/cronjob:v1": failed to do request: Head                            https://hub.mooc.com/v2/kubernetes/cronjob/manifests/v1: dial tcp: lookup hub.mooc.com on 8.8.8.8:53: read udp 10.50.1.103:36844->8.8.8.8:53: i/o timeout
  Warning  Failed     55s (x3 over 116s)  kubelet            Error: ErrImagePull
  Normal   BackOff    17s (x5 over 115s)  kubelet            Back-off pulling image "hub.mooc.com/kubernetes/cronjob:v1"
  Warning  Failed     17s (x5 over 115s)  kubelet            Error: ImagePullBackOff
  Normal   Pulling    6s (x4 over 2m6s)   kubelet            Pulling image "hub.mooc.com/kubernetes/cronjob:v1"


```

## 解决过程

使用crictl 和 ctr 尝试手动 pull ，可见提示x509证书相关错误

```bash

[root@node1 configs]# crictl pull hub.mooc.com/kubernetes/cronjob:v1
FATA[0000] pulling image: rpc error: code = Unknown desc = failed to pull and unpack image "hub.mooc.com/kubernetes/cronjob:v1": failed to resolve reference "                           hub.mooc.com/kubernetes/cronjob:v1": failed to do request: Head https://hub.mooc.com/v2/kubernetes/cronjob/manifests/v1: x509: certificate signed by unknown a                           uthority

[root@node1 configs]#  ctr i  pull hub.mooc.com/kubernetes/cronjob:v1
INFO[0000] trying next host                              error="failed to do request: Head https://hub.mooc.com/v2/kubernetes/cronjob/manifests/v1: x509: certificate signed by unknown authority" host=hub.mooc.com
ctr: failed to resolve reference "hub.mooc.com/kubernetes/cronjob:v1": failed to do request: Head https://hub.mooc.com/v2/kubernetes/cronjob/manifests/v1: x509: certificate signed by unknown authority
```

由于Containerd没有配置Harbor的CA 无法对Harbor证书进行验证，所以我尝试跳过证书

```bash

[root@node1 ~]# ctr i  pull 10.50.1.104/kubernetes/cronjob:v1  --skip-verify
ctr: failed to resolve reference "10.50.1.104/kubernetes/cronjob:v1": unexpected status code [manifests v1]: 401 Unauthorized
```

此时已经不报 `certificate signed by unknown authority`错误了，`401 Unauthorized`认证失败则是因为我们用的私有仓库需要通过用户名密码登录，加上用户名密码再试一次

```bash
[root@node1 configs]#  ctr i  pull 10.50.1.104/kubernetes/cronjob:v1 -user admin:Harbor12345 --skip-verify
```

![image-20210804100340643](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%97%A0%E6%B3%95%E6%8B%89%E5%8F%96%20%E6%8E%92%E9%94%99containerd2/2021.08.05-11:51:08-image-20210804100340643.png)

显然pull成功，但是crictl却没有相关参数，且K8S下拉镜像仍然失败。

K8S会通过crictl下拉镜像，crictl可连接Docker/Conainerd的socket，本文crictl链接Conainerd。

docker 可通过login登录认证 和json定义私有镜像仓库，ctr作为Containerd的CLI  则需要 `-user admin:Harbor12345`  `-k（--skip-verify）`参数 或配置文件来定义，我们需编辑`/etc/containerd/config.toml` 添加如下内容：

```bash
[plugins."io.containerd.grpc.v1.cri".registry]
   [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          	endpoint = ["https://registry-1.docker.io"]
                #到此为配置文件默认生成，之后为需要添加的内容
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.example.net"]
            endpoint = ["harbor.example.net"]
    [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.example.net".tls]
            insecure_skip_verify = true
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.example.net".auth]
            username = "admin"
            password = "Harbor12345"
```

由于 Harbor 是基于 Https 的，理论上需要提前配置 tls 证书，但可以通过 `insecure_skip_verify` 选项跳过证书认证。

当然，如果你想通过 Kubernetes 的 secret 来进行用户验证，此处无需配置以下段落

```bash
 [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.example.net".auth]
          username = "admin"
          password = "Harbor12345"
```

Kubernetes 集群使用 `docker-registry` 类型的 Secret 来通过镜像仓库的身份验证，进而拉取私有映像。所以需要创建 Secret，命名为 `regcred`：

```bash
🐳  → kubectl create secret docker-registry regcred \
  --docker-server=<你的镜像仓库服务器> \
  --docker-username=<你的用户名> \
  --docker-password=<你的密码> \
  --docker-email=<你的邮箱地址> \
  --namespace=项目所在命名空间 
```

然后就可以在 yml的spec:字段中使用该 secret 来访问私有镜像仓库了

```yaml
spec:
  imagePullSecrets:
  - name: regcred
```

或者，想更安全一点，将 CA证书添加到`/etc/containerd/config.toml` 配置中，代替`insecure_skip_verify = true`：

```toml
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        ...
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.example.net".tls]
          ca_file = "/etc/ssl/certs/ca.pem"
```

最后保存并重启containerd服务即可

```bash
systemctl restart containerd
```

服务正常

```bash
[root@node1 configs]# kubectl get pod -o wide
NAME                            READY   STATUS    RESTARTS   AGE    IP            NODE    NOMINATED NODE   READINESS GATES
cronjob-demo-1627896120-l76n2   1/1     Running   0          136m   10.233.28.6   node3   <none>           <none>

```

## 注意：

配置文件`/etc/containerd/config.toml`中`io.containerd.grpc.v1.cri`字段在较新的Containerd中为`cri`


配置完成后，每个节点都可以从个人仓库获取镜像。但是创建pods时无法拉取谷歌pause3.2镜像，
原因在于containerd配置文件中规定了使用谷歌仓库中的pause镜像。将配置文件中的`sandbox_image = “k8s.gcr.io/pause:3.2` 改为阿里云仓库即可或每个节点crictl手动pull镜像。
