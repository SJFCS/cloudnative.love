---
title: Containerd 的前世今生
tags: 
  - posts
  - Containerd
categories:
  - Kubernetes
series:
  - Containerd
lastmod: '2021-05-04'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---

<!--more-->

## 1. Containerd 的前世今生

很久以前，Docker 强势崛起，以“镜像”这个大招席卷全球，对其他容器技术进行致命的降维打击，使其毫无招架之力，就连 Google  也不例外。Google 为了不被拍死在沙滩上，被迫拉下脸面（当然，跪舔是不可能的），希望 Docker  公司和自己联合推进一个开源的容器运行时作为 Docker 的核心依赖，不然就走着瞧。Docker  公司觉得自己的智商被侮辱了，走着瞧就走着瞧，谁怕谁啊！

很明显，Docker 公司的这个决策断送了自己的大好前程，造成了今天的悲剧。

紧接着，Google 联合 Red Hat、IBM 等几位巨佬连哄带骗忽悠 Docker 公司将 `libcontainer` 捐给中立的社区（OCI，Open Container Intiative），并改名为 `runc`，不留一点 Docker 公司的痕迹~~

这还不够，为了彻底扭转 Docker 一家独大的局面，几位大佬又合伙成立了一个基金会叫 `CNCF`（Cloud Native Computing Fundation），这个名字想必大家都很熟了，我就不详细介绍了。CNCF 的目标很明确，既然在当前的维度上干不过 Docker，干脆往上爬，升级到大规模容器编排的维度，以此来击败 Docker。

Docker 公司当然不甘示弱，搬出了 Swarm 和 Kubernetes 进行 PK，最后的结局大家都知道了，Swarm 战败。然后 Docker 公司耍了个小聪明，将自己的核心依赖 `Containerd` 捐给了 CNCF，以此来标榜 Docker 是一个 PaaS 平台。

很明显，这个小聪明又大大加速了自己的灭亡。

![img](https://cdn.jsdelivr.net/gh/yangchuansheng/imghosting@second/img/20201215014746.jpeg)

巨佬们心想，想当初想和你合作搞个中立的核心运行时，你死要面子活受罪，就是不同意，好家伙，现在自己搞了一个，还捐出来了，这是什么操作？也罢，这倒省事了，我就直接拿 `Containerd` 来做文章吧。

首先呢，为了表示 Kubernetes 的中立性，当然要搞个标准化的容器运行时接口，只要适配了这个接口的容器运行时，都可以和我一起玩耍哦，第一个支持这个接口的当然就是 `Containerd` 啦。至于这个接口的名字，大家应该都知道了，它叫 CRI（Container Runntime Interface）。

这样还不行，为了蛊惑 Docker 公司，Kubernetes 暂时先委屈自己，专门在自己的组件中集成了一个 `shim`（你可以理解为垫片），用来将 CRI 的调用翻译成 Docker 的 API，让 Docker 也能和自己愉快地玩耍，温水煮青蛙，养肥了再杀。。。

就这样，Kubernetes 一边假装和 Docker 愉快玩耍，一边背地里不断优化 Containerd 的健壮性以及和 CRI  对接的丝滑性。现在 Containerd 的翅膀已经完全硬了，是时候卸下我的伪装，和 Docker say bye bye  了。后面的事情大家也都知道了~~

Docker 这门技术成功了，Docker 这个公司却失败了。

## 2. Containerd 架构

时至今日，Containerd 已经变成一个工业级的容器运行时了，连口号都有了：超简单！超健壮！可移植性超强！

当然，为了让 Docker 以为自己不会抢饭碗，Containerd 声称自己的设计目的主要是为了嵌入到一个更大的系统中（暗指 Kubernetes），而不是直接由开发人员或终端用户使用。

事实上呢，Containerd 现在基本上啥都能干了，开发人员或者终端用户可以在宿主机中管理完整的容器生命周期，包括容器镜像的传输和存储、容器的执行和管理、存储和网络等。大家可以考虑学起来了。

**学习 Containerd 最好的时机是关注公众号 云原生实验室 后，其次是现在，看完了再关注公众号也不迟😆。**

先来看看 Containerd 的架构：

![img](https://cdn.jsdelivr.net/gh/yangchuansheng/imghosting@second/img/20201214104531.png)

可以看到 Containerd 仍然采用标准的 C/S 架构，服务端通过 `GRPC` 协议提供稳定的 API，客户端通过调用服务端的 API 进行高级的操作。

为了解耦，Containerd 将不同的职责划分给不同的组件，每个组件就相当于一个**子系统**（subsystem）。连接不同子系统的组件被称为模块。

总体上 Containerd 被划分为两个子系统：

- **Bundle** : 在 Containerd 中，`Bundle` 包含了配置、元数据和根文件系统数据，你可以理解为容器的文件系统。而 **Bundle 子系统**允许用户从镜像中提取和打包 Bundles。
- **Runtime** : Runtime 子系统用来执行 Bundles，比如创建容器。

其中，每一个子系统的行为都由一个或多个**模块**协作完成（架构图中的 `Core` 部分）。每一种类型的模块都以**插件**的形式集成到 Containerd 中，而且插件之间是相互依赖的。例如，上图中的每一个长虚线的方框都表示一种类型的插件，包括 `Service Plugin`、`Metadata Plugin`、`GC Plugin`、`Runtime Plugin` 等，其中 `Service Plugin` 又会依赖 Metadata Plugin、GC Plugin 和 Runtime Plugin。每一个小方框都表示一个细分的插件，例如 `Metadata Plugin` 依赖 Containers Plugin、Content Plugin 等。 总之，万物皆插件，插件就是模块，模块就是插件。

![img](https://cdn.jsdelivr.net/gh/yangchuansheng/imghosting@second/img/20201214131532.png)

这里介绍几个常用的插件：

- **Content Plugin** : 提供对镜像中可寻址内容的访问，所有不可变的内容都被存储在这里。
- **Snapshot Plugin** : 用来管理容器镜像的文件系统快照。镜像中的每一个 layer 都会被解压成文件系统快照，类似于 Docker 中的 `graphdriver`。
- **Metrics** : 暴露各个组件的监控指标。

从总体来看，Containerd 被分为三个大块：`Storage`、`Metadata` 和 `Runtime`，可以将上面的架构图提炼一下：

![img](https://cdn.jsdelivr.net/gh/yangchuansheng/imghosting@second/img/20201214121327.png)

这是使用 [bucketbench](https://github.com/estesp/bucketbench) 对 `Docker`、`crio` 和 `Containerd` 的性能测试结果，包括启动、停止和删除容器，以比较它们所耗的时间：

![img](https://cdn.jsdelivr.net/gh/yangchuansheng/imghosting@second/img/20201215120712.png)

可以看到 Containerd 在各个方面都表现良好，总体性能还是优越于 `Docker` 和 `crio` 的。

## 3. Containerd 安装

了解了 Containerd 的概念后，就可以动手安装体验一把了。本文的演示环境为 `Ubuntu 18.04`。

### 安装依赖

为 seccomp 安装依赖：

```bash
🐳  → sudo apt-get update
🐳  → sudo apt-get install libseccomp2
```



### 下载并解压 Containerd 程序

Containerd 提供了两个压缩包，一个叫 `containerd-${VERSION}.${OS}-${ARCH}.tar.gz`，另一个叫 `cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz`。其中  `cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz` 包含了所有 Kubernetes 需要的二进制文件。如果你只是本地测试，可以选择前一个压缩包；如果是作为 Kubernetes 的容器运行时，需要选择后一个压缩包。

Containerd 是需要调用 `runc` 的，而第一个压缩包是不包含 `runc` 二进制文件的，如果你选择第一个压缩包，还需要提前安装 runc。所以我建议直接使用 `cri-containerd` 压缩包。

首先从 [release 页面](https://github.com/containerd/containerd/releases)下载最新版本的压缩包，当前最新版本为 1.4.3：

```bash
🐳  → wget https://github.com/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz

# 也可以替换成下面的 URL 加速下载
🐳  → wget https://download.fastgit.org/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz
```

直接将压缩包解压到系统的各个目录中：

```bash
🐳  → sudo tar -C / -xzf cri-containerd-cni-1.4.3-linux-amd64.tar.gz
```

将 `/usr/local/bin` 和 `/usr/local/sbin` 追加到 `~/.bashrc` 文件的 `$PATH` 环境变量中：

```bash
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
```

立即生效：

```bash
🐳  → source ~/.bashrc
```

查看版本：

```bash
🐳  → ctr version
Client:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  Go version: go1.15.5

Server:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  UUID: d1724999-91b3-4338-9288-9a54c9d52f70
```



### 生成配置文件

Containerd 的默认配置文件为  `/etc/containerd/config.toml`，我们可以通过命令来生成一个默认的配置：

```bash
🐳  → mkdir /etc/containerd
🐳  → containerd config default > /etc/containerd/config.toml
```



### 镜像加速

由于某些不可描述的因素，在国内拉取公共镜像仓库的速度是极慢的，为了节约拉取时间，需要为 Containerd 配置镜像仓库的 `mirror`。Containerd 的镜像仓库 mirror 与 Docker 相比有两个区别：

- Containerd 只支持通过 `CRI` 拉取镜像的 mirror，也就是说，只有通过 `crictl` 或者 Kubernetes 调用时 mirror 才会生效，通过 `ctr` 拉取是不会生效的。
- `Docker` 只支持为 `Docker Hub` 配置 mirror，而 `Containerd` 支持为任意镜像仓库配置 mirror。

配置镜像加速之前，先来看下 Containerd 的配置结构，乍一看可能会觉得很复杂，复杂就复杂在 plugin 的配置部分：

```toml
[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    sandbox_image = "k8s.gcr.io/pause:3.1"
    stats_collect_period = 10
    systemd_cgroup = false
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v1"
          runtime_engine = ""
          runtime_root = ""
          privileged_without_host_devices = false
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      max_conf_num = 1
      conf_template = ""
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry-1.docker.io"]
    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""
  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"
  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"
  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"
  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]
  [plugins."io.containerd.snapshotter.v1.devmapper"]
    root_path = ""
    pool_name = ""
    base_image_size = ""
```



每一个顶级配置块的命名都是 `plugins."io.containerd.xxx.vx.xxx"` 这种形式，其实每一个顶级配置块都代表一个插件，其中 `io.containerd.xxx.vx` 表示插件的类型，vx 后面的 xxx 表示插件的 `ID`。可以通过 `ctr` 一览无余：

```bash
🐳  → ctr plugin ls
TYPE                            ID                    PLATFORMS      STATUS
io.containerd.content.v1        content               -              ok
io.containerd.snapshotter.v1    btrfs                 linux/amd64    error
io.containerd.snapshotter.v1    devmapper             linux/amd64    error
io.containerd.snapshotter.v1    aufs                  linux/amd64    ok
io.containerd.snapshotter.v1    native                linux/amd64    ok
io.containerd.snapshotter.v1    overlayfs             linux/amd64    ok
io.containerd.snapshotter.v1    zfs                   linux/amd64    error
io.containerd.metadata.v1       bolt                  -              ok
io.containerd.differ.v1         walking               linux/amd64    ok
io.containerd.gc.v1             scheduler             -              ok
io.containerd.service.v1        containers-service    -              ok
io.containerd.service.v1        content-service       -              ok
io.containerd.service.v1        diff-service          -              ok
io.containerd.service.v1        images-service        -              ok
io.containerd.service.v1        leases-service        -              ok
io.containerd.service.v1        namespaces-service    -              ok
io.containerd.service.v1        snapshots-service     -              ok
io.containerd.runtime.v1        linux                 linux/amd64    ok
io.containerd.runtime.v2        task                  linux/amd64    ok
io.containerd.monitor.v1        cgroups               linux/amd64    ok
io.containerd.service.v1        tasks-service         -              ok
io.containerd.internal.v1       restart               -              ok
io.containerd.grpc.v1           containers            -              ok
io.containerd.grpc.v1           content               -              ok
io.containerd.grpc.v1           diff                  -              ok
io.containerd.grpc.v1           events                -              ok
io.containerd.grpc.v1           healthcheck           -              ok
io.containerd.grpc.v1           images                -              ok
io.containerd.grpc.v1           leases                -              ok
io.containerd.grpc.v1           namespaces            -              ok
io.containerd.internal.v1       opt                   -              ok
io.containerd.grpc.v1           snapshots             -              ok
io.containerd.grpc.v1           tasks                 -              ok
io.containerd.grpc.v1           version               -              ok
io.containerd.grpc.v1           cri                   linux/amd64    ok
```



顶级配置块下面的子配置块表示该插件的各种配置，比如 cri 插件下面就分为 `containerd`、`cni` 和 `registry` 的配置，而 containerd 下面又可以配置各种 runtime，还可以配置默认的 runtime。

镜像加速的配置就在 cri 插件配置块下面的 registry 配置块，所以需要修改的部分如下：

```toml
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://dockerhub.mirrors.nwafu.edu.cn"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          endpoint = ["https://registry.aliyuncs.com/k8sxio"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]
          endpoint = ["xxx"]
```



- **registry.mirrors.“xxx”** : 表示需要配置 mirror 的镜像仓库。例如，`registry.mirrors."docker.io"` 表示配置 docker.io 的 mirror。
- **endpoint** : 表示提供 mirror 的镜像加速服务。例如，这里推荐使用西北农林科技大学提供的镜像加速服务作为 `docker.io` 的 mirror。

**至于 `gcr.io`，目前还没有公共的加速服务。我自己掏钱搭了个加速服务，拉取速度大概是 `3M/s` 左右，有加速需求的同学可以通过微信号：cloud-native-yang 加我为好友再详细咨询。**

### 存储配置

Containerd 有两个不同的存储路径，一个用来保存持久化数据，一个用来保存运行时状态。

```toml
root = "/var/lib/containerd"
state = "/run/containerd"
```



`root`用来保存持久化数据，包括 `Snapshots`, `Content`, `Metadata` 以及各种插件的数据。每一个插件都有自己单独的目录，Containerd 本身不存储任何数据，它的所有功能都来自于已加载的插件，真是太机智了。

```bash
🐳  → tree -L 2 /var/lib/containerd/
/var/lib/containerd/
├── io.containerd.content.v1.content
│   ├── blobs
│   └── ingest
├── io.containerd.grpc.v1.cri
│   ├── containers
│   └── sandboxes
├── io.containerd.metadata.v1.bolt
│   └── meta.db
├── io.containerd.runtime.v1.linux
│   └── k8s.io
├── io.containerd.runtime.v2.task
├── io.containerd.snapshotter.v1.aufs
│   └── snapshots
├── io.containerd.snapshotter.v1.btrfs
├── io.containerd.snapshotter.v1.native
│   └── snapshots
├── io.containerd.snapshotter.v1.overlayfs
│   ├── metadata.db
│   └── snapshots
└── tmpmounts

18 directories, 2 files
```



`state` 用来保存临时数据，包括 sockets、pid、挂载点、运行时状态以及不需要持久化保存的插件数据。

```bash
🐳  → tree -L 2 /run/containerd/
/run/containerd/
├── containerd.sock
├── containerd.sock.ttrpc
├── io.containerd.grpc.v1.cri
│   ├── containers
│   └── sandboxes
├── io.containerd.runtime.v1.linux
│   └── k8s.io
├── io.containerd.runtime.v2.task
└── runc
    └── k8s.io

8 directories, 2 files
```



### OOM

还有一项配置需要留意：

```toml
oom_score = 0
```

Containerd 是容器的守护者，一旦发生内存不足的情况，理想的情况应该是先杀死容器，而不是杀死 Containerd。所以需要调整 Containerd 的 `OOM` 权重，减少其被 **OOM Kill** 的几率。最好是将 `oom_score` 的值调整为比其他守护进程略低的值。这里的 oom_socre 其实对应的是 `/proc/<pid>/oom_socre_adj`，在早期的 Linux 内核版本里使用 `oom_adj` 来调整权重, 后来改用 `oom_socre_adj` 了。该文件描述如下：

> The value of `/proc/<pid>/oom_score_adj` is added to the badness score before it
>  is used to determine which task to kill.  Acceptable values range from -1000
>  (OOM_SCORE_ADJ_MIN) to +1000 (OOM_SCORE_ADJ_MAX).  This allows userspace to
>  polarize the preference for oom killing either by always preferring a certain
>  task or completely disabling it.  The lowest possible value, -1000, is
>  equivalent to disabling oom killing entirely for that task since it will always
>  report a badness score of 0.

在计算最终的 `badness score` 时，会在计算结果是中加上 `oom_score_adj` ,这样用户就可以通过该在值来保护某个进程不被杀死或者每次都杀某个进程。其取值范围为 `-1000` 到 `1000`。

如果将该值设置为 `-1000`，则进程永远不会被杀死，因为此时 `badness score` 永远返回0。

建议 Containerd 将该值设置为 `-999` 到 `0` 之间。如果作为 Kubernetes 的 Worker 节点，可以考虑设置为 `-999`。

### Systemd 配置

建议通过 systemd 配置 Containerd 作为守护进程运行，配置文件在上文已经被解压出来了：

```bash
🐳  → cat /etc/systemd/system/containerd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```



这里有两个重要的参数：

- **Delegate** : 这个选项允许 Containerd 以及运行时自己管理自己创建的容器的 `cgroups`。如果不设置这个选项，systemd 就会将进程移到自己的 `cgroups` 中，从而导致 Containerd 无法正确获取容器的资源使用情况。

- **KillMode** : 这个选项用来处理 Containerd 进程被杀死的方式。默认情况下，systemd 会在进程的 cgroup 中查找并杀死 Containerd 的所有子进程，这肯定不是我们想要的。`KillMode`字段可以设置的值如下。

  - **control-group**（默认值）：当前控制组里面的所有子进程，都会被杀掉
  - **process**：只杀主进程
  - **mixed**：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
  - **none**：没有进程会被杀掉，只是执行服务的 stop 命令。

  我们需要将 KillMode 的值设置为 `process`，这样可以确保升级或重启 Containerd 时不杀死现有的容器。

现在到了最关键的一步：启动 Containerd。执行一条命令就完事：

```bash
🐳  → systemctl enable containerd --now
```



接下来进入本文最后一部分：Containerd 的基本使用方式。本文只会介绍 Containerd 的本地使用方法，即本地客户端 `ctr` 的使用方法，不会涉及到 `crictl`，后面有机会再介绍 `crictl`。

参考文章：https://fuckcloudnative.io/posts/getting-started-with-containerd/#5-ctr-%E4%BD%BF%E7%94%A8