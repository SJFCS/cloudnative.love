---
title: containerd命令详解
tags: 
  - posts
categories:
  - Kubernetes
series:
  - 
lastmod: '2021-07-28'
featuredImage: 
authors: songjinfeng
draft: true
toc: true
---

https://kubernetes.io/zh/docs/tasks/debug-application-cluster/crictl/

## 容器运行时关系图

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img2020.cnblogs.com/blog/700209/202107/2021.09.24-00:18:41-700209-20210712111124430-1048640961.png)



![image-20210803160632712](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/containerd/2021.09.24-00:18:39-image-20210803160632712.png)



![image-20210803160655004](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/containerd/2021.09.24-00:18:43-image-20210803160655004.png)

## 部署containerd

```bash
#安装
https://github.com/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz

tar 

find . -type f

rm -rf ./opt     ./etc/cni
cp -r user/ /
cp -r etc /
vi /etc/systemd/system/containerd.service
```

## 生成配置文件

```
mkdir /etc/containerd/ && containerd config default > /etc/containerd/config.toml

# 修改oom_score = -999 系统内存不足时不至于杀掉此守护进程
```

## 基础命令


 ```
 ctr i list
 ctr i pull docker.io/livrary/redis:alpine redis
 
 镜像标记tag
 ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
 注意: 若新镜像reference 已存在, 需要先删除新reference, 或者如下方式强制替换
 ctr -n k8s.io i tag --force registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
 
 ctr -t -d docker.io/livrary/redis:alpine redis
 ctr ns ls
 
 ctr c ls
 ctr t ls
 ctr t kill redis
 ctr t rm redis
 ctr c rm redis
 
 查看docker容器
 ctr -n moby t ls
 
 k8s node节点
 crictl ps
 crictl pods
 
 
 ```



## 镜像pull目录，使用du查看大小

```
containerd：du -sm /var/lib/containerd

docker：du -sm /var/lib/docker
```



![image-20210602111335321](D:/assets/Untitled/image-20210602111335321.png)

 操作containerd使用的命名空间不同，镜像物理隔离目录完全不同。

containerd可以看到docker创建的容器，但由于docker和containerd存储目录不同，containerd看不到docker pull镜像

## 踩坑
原文链接：https://blog.csdn.net/Aisaka81/article/details/118494975

**坑1**

root目录使用xfs文件系统时，会出现无法创建snapshot的问题，报错如下：

```bash
● containerd.service - containerd container runtime
   Loaded: loaded (/usr/lib/systemd/system/containerd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: https://containerd.io
 
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.267658802+08:00" level=info msg="loading plugin \"io.containerd.grpc.v1.cri\"..." type=io.containerd.grpc.v1
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268039537+08:00" level=info msg="Start cri plugin with config {PluginConfig:{ContainerdConfig:{Snapshotter:overlayfs DefaultRuntimeName:runc DefaultRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:<nil> PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} UntrustedWorkloadRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:<nil> PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} Runtimes:map[runc:{Type:io.containerd.runc.v2 Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:0xc00041b860 PrivilegedWithoutHostDevices:false BaseRuntimeSpec:}] NoPivot:false DisableSnapshotAnnotations:true DiscardUnpackedLayers:false} CniConfig:{NetworkPluginBinDir:/opt/cni/bin NetworkPluginConfDir:/etc/cni/net.d NetworkPluginMaxConfNum:1 NetworkPluginConfTemplate:} Registry:{Mirrors:map[172.18.121.16:8083:{Endpoints:[http://172.18.121.16:8083]} docker.io:{Endpoints:[https://registry-1.docker.io]}] Configs:map[] Auths:map[] Headers:map[]} ImageDecryption:{KeyModel:} DisableTCPService:true StreamServerAddress:127.0.0.1 StreamServerPort:0 StreamIdleTimeout:4h0m0s EnableSelinux:false SelinuxCategoryRange:1024 SandboxImage:k8s.gcr.io/pause:3.2 StatsCollectPeriod:10 SystemdCgroup:false EnableTLSStreaming:false X509KeyPairStreaming:{TLSCertFile: TLSKeyFile:} MaxContainerLogLineSize:16384 DisableCgroup:false DisableApparmor:false RestrictOOMScoreAdj:false MaxConcurrentDownloads:3 DisableProcMount:false UnsetSeccompProfile: TolerateMissingHugetlbController:true DisableHugetlbController:true IgnoreImageDefinedVolumes:false} ContainerdRootDir:/var/lib/containerd ContainerdEndpoint:/run/containerd/containerd.sock RootDir:/var/lib/containerd/io.containerd.grpc.v1.cri StateDir:/run/containerd/io.containerd.grpc.v1.cri}"
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268115703+08:00" level=info msg="Connect containerd service"
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268199993+08:00" level=warning msg="failed to load plugin io.containerd.grpc.v1.cri" error="failed to create CRI service: failed to find snapshotter \"overlayfs\""
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268219975+08:00" level=info msg="loading plugin \"io.containerd.grpc.v1.introspection\"..." type=io.containerd.grpc.v1
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268610460+08:00" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268717460+08:00" level=info msg=serving... address=/run/containerd/containerd.sock
7月 02 10:30:59 localhost.localdomain containerd[2617]: time="2021-07-02T10:30:59.268752374+08:00" level=info msg="containerd successfully booted in 0.039053s"
7月 02 11:02:37 localhost.localdomain systemd[1]: Stopping containerd container runtime...
7月 02 11:02:37 localhost.localdomain systemd[1]: Stopped containerd container runtime.
```

估计是由于xfs不支持overlayfs导致。更换ext4文件系统解决。
**坑2**

ctr命令从非安全仓库拉取镜像时，出现如下错误：

 http: server gave HTTP response to HTTPS client

即使配置了镜像仓库地址为http也不行，需要在拉取时加入--plain-http参数

**坑3**

runc在PATH中，但创建容器并运行时，还是会提示

exec: "runc": executable file not found in $PATH: unknown

原因比较蛋疼，containerd创建容器时，是根据config.conf中的PATH，也就是镜像默认的PATH路径去寻找runc的。如果你的PATH配置比较奇葩，那就有可能找不到。建议的做法是将/usr/bin、/usr/local/bin等常用目录全部建一个runc的软连接。

**坑4**

Kubernetes containerd失败的pull镜像从私有仓库harbor

**坑5**

```
    sandbox_image = "registry.cn-beijing.aliyuncs.com/images_k8s/pause-amd64:3.3"
```



https://www.orchome.com/10011

## 使用crictl连接containerd  

链接：https://www.jianshu.com/p/fb35351e4e08

修改crictl的配置文件，在/etc/crictl.yaml写入以下内容：

```

[root@node1 configs]# cat /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 30
debug: false

```

**修改kubelet配置和kubeadm安装时配置**

- 在 kubelet配置文件 10-kubeadm.conf 的`[Service]` 结点加入以下配置：

  ```
  Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
  ```

+ 在kubeadm配置文件 kubeadm.yaml 中加入

  ```yaml
  apiVersion: kubeadm.k8s.io/v1beta1
  kind: InitConfiguration
  nodeRegistration:
    criSocket: /run/containerd/containerd.sock
    name: containerd
  ```

到此containerd和kubernetes的集成就完成了。下面可以直接安装即可。
