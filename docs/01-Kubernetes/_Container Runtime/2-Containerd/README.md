---
title: Containerd
tags: [containerd]
---

nerdctl 这是一个用于containerd 的，且和Docker 兼容的CLI，另外还支持Compose。
安装 containerd-rootless-setuptool.sh
```bash
❯ nerdctl namespace ls
FATA[0000] rootless containerd not running? (hint: use `containerd-rootless-setuptool.sh install` to start rootless containerd): stat /run/user/1000/containerd-rootless: no such file or directory 
❯ sudo nerdctl namespace ls
NAME       CONTAINERS    IMAGES    VOLUMES    LABELS
default    0             1         0              
k8s.io     50            84        0              
moby       0             0         0              
❯ containerd-rootless-setuptool.sh install
[INFO] Checking RootlessKit functionality
/usr/bin/containerd-rootless-setuptool.sh:行111: rootlesskit：未找到命令
[ERROR] RootlessKit failed, see the error messages and https://rootlesscontaine.rs/getting-started/common/ .
❯ sudo systemctl start containerd-rootless.service

Failed to start containerd-rootless.service: Unit containerd-rootless.service not found.
❯ paru -S rootlesskit slirp4netns
正在解析依赖关系...
正在查找软件包冲突...

软件包 (1) rootlesskit-1.1.1-1

## 报错 sgid范围？？

[rootlesskit:parent] error: failed to setup UID/GID map: failed to compute uid/gid map: No subuid ranges found for user 1000 ("admin")
[ERROR] RootlessKit failed, see the error messages and https://rootlesscontaine.rs/getting-started/common/ .
这个错误提示表明您的用户没有可用的 subuid 和 subgid 范围。您可以使用以下命令为您的用户添加 subuid 和 subgid 范围：

sudo usermod --add-subuids 10000-20000 --add-subgids 10000-20000 <your-username>
该命令将为您的用户 <your-username> 添加 subuid 范围 10000-20000 和 subgid 范围 10000-20000。您可以将这些范围更改为适合您的需要的任何值。

然后，您需要重新登录以使更改生效。如果您使用的是 SSH 连接，请断开并重新连接到主机。然后再次尝试运行您的命令。


## containerd-rootless 下用普通用户运行 nerdctl namespace ls 获取不到结果 待解决
```


Kubernetes 从版本 v1.20 之后，弃用 Docker 容器运行时，在 v1.24 版本中，将彻底移除 Dockershim。`kubelet` 将直接对接 [containerd](https://github.com/containerd/containerd) 运行时。

- [Don't Panic: Kubernetes and Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)
- [Is Your Cluster Ready for v1.24?](https://kubernetes.io/blog/2022/03/31/ready-for-dockershim-removal/)

## 安装与配置

containerd 的默认配置文件位置为 `/etc/containerd/config.toml`，详见

- [containerd for Ops and Admins](https://github.com/containerd/containerd/blob/master/docs/ops.md)

### 1. 配置私有仓库

我们从私有镜像仓库拉取镜像，通常会遇到 tls 证书不可信的问题，镜像仓库的私钥/insecure 配置的文档为：

- [registry - cri-containerd](https://github.com/containerd/cri/blob/master/docs/registry.md)

文档中写到，若要使用私钥连接私有仓库，可向 `/etc/containerd/config.toml` 中添加如下内容：

```toml
# explicitly use v2 config format
version = 2

# The registry host has to be a domain name or IP. Port number is also
# needed if the default HTTPS or HTTP port is not used.
[plugin."io.containerd.grpc.v1.cri".registry.configs."my.custom.registry".tls]
    ca_file   = "ca.pem"
    # 如下密钥对用于双向 TLS 认证，如果不支持 mTLS，请去掉它们
    cert_file = "cert.pem"
    key_file  = "key.pem"
```

如果要跳过 TLS 验证，要添加的配置内容如下：

```toml
# explicitly use v2 config format
version = 2

[plugin."io.containerd.grpc.v1.cri".registry.configs."my.custom.registry".tls]
  insecure_skip_verify = true
```

>注：我们发现 v2 版的 config.toml 设置 `insecure_skip_verify` 时，如果 registry 名称带端口，比如 `resigtry.svc.local:8443`，就无法生效。。退回使用 v1 版的配置，就没问题。

### 2. 配置仓库镜像

在国内的特殊环境下，我们经常需要为 `k8s.gcr.io` 等仓库配置国内镜像，配置如下：

```toml
version = 2

# The 'plugins."io.containerd.grpc.v1.cri"' table contains all of the server options.
[plugins."io.containerd.grpc.v1.cri"]

  # sandbox_image is the image used by sandbox container.
  # 注：此镜像不会走 mirrors！
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.2"

[plugin."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugin."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = ["https://hub-mirror.c.163.com"]
  [plugin."io.containerd.grpc.v1.cri".registry.mirrors."test.https-registry.io"]
    endpoint = ["https://HostIP1:Port1"]
  # wildcard matching is supported but not required.
  [plugin."io.containerd.grpc.v1.cri".registry.mirrors."*"]
    endpoint = ["https://HostIP3:Port3"]
```


## 常用命令

命令行工具这方面现在主要有三个选择：

- containerd 提供的 `ctr`: 很难用，直接排除
- CRI 提供的 `crictl` 稍微好用一点点，可以考虑
- containerd 开发的新工具 `nerdctl`: 好用，强烈推荐

### crictl

其命令行参数和 `docker-cli` 基本一致，但是:

1. 只提供和容器/镜像相关的命令，并添加了 pod 相关命令
2. 不支持 build 镜像，作为单纯的 k8s 运行时调试工具，不需要提供这个功能

crictl 支持连接任何兼容 cri 的运行时，它默认情况下按顺序尝试连接如下几个 endpoint(on linux):

- `unix:///var/run/dockershim.sock`
- `unix:///run/containerd/containerd.sock`
- `unix:///run/crio/crio.sock`

endpoint 也可以通过命令行参数/环境变量/配置文件手动设置，详见 [docs/crictl](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)


### [nerdctl](https://github.com/containerd/nerdctl)

nerdctl 提供和 docker 完全兼容的指令，而且支持 docker-compose.yml（`nerdctl compose up`） 及其中的大部分参数。

注意点：
- nerdctl 对网络的支持不如 docker
- nerdctl 与 kubernetes 的容器、镜像是隔离的，使用 nerdctl 查看不了 kubernetes 的容器与镜像，反之亦然。



