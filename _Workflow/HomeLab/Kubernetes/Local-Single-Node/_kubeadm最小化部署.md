<!-- 如果要将 CRI 运行时 containerd 与 Kubernetes 一起使用，请配置参数 sysctl ：
```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# 然后应用参数：
sudo sysctl --system
``` -->

## kubeadm 部署
k8s 由api驱动，我们在不同版本部署前要重点关注api发生的变动，https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/

## Prerequisites 先决条件
### 确保节点唯一性
节点之中不可以有重复的主机名、MAC 地址或 product_uuid。
  - 你可以使用命令 ip link 或 ifconfig -a 来获取网络接口的 MAC 地址
可以使用 sudo cat /sys/class/dmi/id/product_uuid 命令对 product_uuid 校验
一般来讲，硬件设备会拥有唯一的地址，但是有些虚拟机的地址可能会重复。 Kubernetes 使用这些值来唯一确定集群中的节点。 如果这些值在每个节点上不唯一，可能会导致安装失败。

### 启机器上的某些端口。
  - nc 127.0.0.1 6443
  - https://kubernetes.io/zh-cn/docs/reference/networking/ports-and-protocols/
### Disable swap 禁用交换分区。
Kubernetes 目前不支持在系统上启用交换。 详见 [KEP-2400: Node system swap support](https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/2400-node-swap) 
如果交换已打开，请使用以下命令禁用它并重新启动
```
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```
如果您看到 /dev/zram0 ，您还应该通过以下方式删除 zram 内核模块：
```
swapoff /dev/zram0
modprobe -r zram
```
如果您的 zram 由 systemd 管理，请尝试查找 .swap 单元：
```
systemctl --type swap
```
一旦找到，您可以将其屏蔽：
```
sudo systemctl mask "dev-XYZ.swap"
```
Then reboot.  然后重新启动。
(和kubeadm无关的操作：比如日志监控agent等 ssh安全加强和免密)


## 安装 kubeadm、kubelet 和 kubectl
https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
[kubectl](https://kubernetes.io/zh-cn/docs/tasks/tools/)：用来与集群通信的命令行工具。



## 选择容器运行时
https://github.com/TimeBye/kubeadm-ha/blob/master/docs/09/%E5%A6%82%E4%BD%95%E9%80%89%E6%8B%A9%E8%BF%90%E8%A1%8C%E6%97%B6%E7%BB%84%E4%BB%B6.md


https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/

为了在 Pod 中运行容器，Kubernetes 使用 [容器运行时（Container Runtime）](https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/)。

默认情况下，Kubernetes 使用 容器运行时接口[（Container Runtime Interface，CRI）](https://kubernetes.io/zh-cn/docs/concepts/overview/components/#container-runtime) 来与你所选择的容器运行时交互。

如果你不指定运行时，kubeadm 会自动尝试通过扫描已知的端点列表来检测已安装的容器运行时。

如果检测到有多个或者没有容器运行时，kubeadm 将抛出一个错误并要求你指定一个想要使用的运行时。
:::tip
Docker Engine 没有实现 CRI， 而这是容器运行时在 Kubernetes 中工作所需要的。 为此，必须安装一个额外的服务 cri-dockerd。 cri-dockerd 是一个基于传统的内置 Docker 引擎支持的项目， 它在 1.24 版本从 kubelet 中移除。
:::



:::tip 下面的表格包括被支持的操作系统的已知端点。
linux
运行时	Unix 域套接字
containerd	unix:///var/run/containerd/containerd.sock
CRI-O	unix:///var/run/crio/crio.sock
Docker Engine（使用 cri-dockerd）	unix:///var/run/cri-dockerd.sock
windows
运行时	Windows 命名管道路径
containerd	npipe:////./pipe/containerd-containerd
Docker Engine（使用 cri-dockerd）	npipe:////./pipe/cri-dockerd
:::



### 安装和配置先决条件  内核转发
要设置转发 IPv4 并让 iptables 查看桥接流量，请首先手动加载内核模块 overlay 和 br_netfilter 。

```bash
/etc/modules-load.d/k8s.conf
overlay
br_netfilter
```
sudo modprobe overlay
sudo modprobe br_netfilter

```bash
/etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
```
```bash
# 应用它们而无需重新启动：
# sysctl --system
# sudo sysctl -p /etc/sysctl.d/kubernetes.conf

（可选）通过运行以下命令验证 br_netfilter 覆盖模块是否已加载：
lsmod | grep br_netfilter
lsmod | grep overlay
（可选）通过运行以下命令验证 net.bridge.bridge-nf-call-iptables 、 net.bridge.bridge-nf-call-ip6tables 和 net.ipv4.ip_forward 系统变量在 sysctl 配置中是否设置为 1命令：

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
参考文档 https://kubernetes.io/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
```

### Install containerd 
要安装 rootless containerd ，请使用 nerdctl-full-bin AUR ，它是 nerdctl full pkg，与 containerd/CNI 插件/RootlessKit 捆绑在一起：
```
containerd-rootless-setuptool.sh install
然后启用/启动 containerd.service 。
```

集群中的所有节点（控制平面和工作节点）都需要 kubelet.service 的运行实例。
:::tip
所有提供的 systemd 服务都接受环境文件中的 CLI 覆盖：
kubelet.service: /etc/kubernetes/kubelet.env
kube-apiserver.service: /etc/kubernetes/kube-apiserver.env
kube-controller-manager.service: /etc/kubernetes/kube-controller-manager.env
kube-proxy.service: /etc/kubernetes/kube-proxy.env
kube-scheduler.service: /etc/kubernetes/kube-scheduler.env
:::
### Install CRI-O
当使用 [CRI-O](https://wiki.archlinux.org/title/CRI-O) 作为容器运行时时，需要提供 kubeadm init 或 kubeadm join 及其 CRI 端点： --cri-socket='unix:///run/crio/crio.sock'
当使用 CRI-O 作为容器运行时时，需要提供 kubeadm init 或 kubeadm join 及其 CRI 端点： --cri-socket='unix:///run/crio/crio.sock'

:::info
注意：CRI-O 默认情况下使用 systemd 作为其 cgroup_manager （请参阅 /etc/crio/crio.conf ）。使用 kubelet < v1.22 时，这与 kubelet us 默认值 ( cgroupfs ) 不兼容。

首次启动时（即使用 kubeadm init 之前），通过将 --cgroup-driver='systemd' 附加到 /etc/kubernetes/kubelet.env 中的 KUBELET_ARGS 环境变量来更改 kubelet 默认值。

请注意，旧版本使用的 KUBELET_EXTRA_ARGS 变量现在不再被默认的 kubelet.service 读取！


When kubeadm updates from 1.19.x to 1.20.x, then it should be possible to use https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file as explained on https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-control-plane-node, as in https://github.com/cri-o/cri-o/pull/4440/files, instead of the above. (TBC, untested.)

配置节点后，CLI 标志可以（但不必）替换为 kubelet 的配置条目：
```
/var/lib/kubelet/config.yaml
cgroupDriver: 'systemd'
```
:::

### install docker 废弃
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/
- https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/migrating-from-dockershim/change-runtime-containerd/
- https://blog.daocloud.io/8006.html



## Choose cgroup driver 选择 cgroup 驱动程序
https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/#cgroup-drivers
### containerd 
要将 /etc/containerd/config.toml 中的 systemd cgroup 驱动程序与 runc 一起使用，请设置
```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true



[plugins]

  [plugins."io.containerd.gc.v1.scheduler"]
    deletion_threshold = 0
    mutation_threshold = 100
    pause_threshold = 0.02
    schedule_delay = "0s"
    startup_delay = "100ms"

  [plugins."io.containerd.grpc.v1.cri"]
    cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]
    device_ownership_from_security_context = false
    disable_apparmor = false
    disable_cgroup = false
    disable_hugetlb_controller = true
    disable_proc_mount = false
    disable_tcp_service = true
    drain_exec_sync_io_timeout = "0s"
    enable_cdi = false
    enable_selinux = false
    enable_tls_streaming = false
    enable_unprivileged_icmp = false
    enable_unprivileged_ports = false
    ignore_image_defined_volumes = false
    image_pull_progress_timeout = "1m0s"
    max_concurrent_downloads = 3
    max_container_log_line_size = 16384
    netns_mounts_under_state_dir = false
    restrict_oom_score_adj = false
    sandbox_image = "registry.k8s.io/pause:3.8"
    selinux_category_range = 1024
    stats_collect_period = 10
    stream_idle_timeout = "4h0m0s"
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    systemd_cgroup = true
    tolerate_missing_hugetlb_controller = true
    unset_seccomp_profile = ""
```
如果 /etc/containerd/config.toml 不存在，可以通过[customizing-containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md#customizing-containerd)生成默认配置
```bash
containerd config default > /etc/containerd/config.toml
```
请记住重新启动 containerd.service 以使更改生效。

有关是否保留 cgroupfs 驱动程序或使用 systemd cgroup 驱动程序的更深入讨论，请参阅此[官方文档](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers)。


[## CRI 版本支持 ](https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/#cri-versions)

### 配置docker Cgroup 驱动

```bash
mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
      "https://registry.docker-cn.com",
      "https://docker.mirrors.ustc.edu.cn"
    ],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload && systemctl enable docker && systemctl restart docker
```

### 配置Kubelet Cgroup 驱动

```BASH
DOCKER_GROUPS=$(docker info |grep 'Cgroup' | cut -d ' ' -f4)

cat > /etc/sysconfig/kubelet <<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_GROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.2"
EOF
systemctl daemon-reload && systemctl enable  kubelet && systemctl restart  kubelet
```

## 配置 kubelet 的 cgroup 驱动

kubeadm 支持在执行 `kubeadm init` 时，传递一个 `KubeletConfiguration` 结构体。 `KubeletConfiguration` 包含 `cgroupDriver` 字段，可用于控制 kubelet 的 cgroup 驱动。

```yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta2
kubernetesVersion: v1.21.0
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

> **说明：**
>
> Kubeadm 对集群所有的节点，使用相同的 `KubeletConfiguration`。 `KubeletConfiguration` 存放于 `kube-system` 命名空间下的某个 [ConfigMap](https://kubernetes.io/zh/docs/concepts/configuration/configmap) 对象中。
>
> 执行 `init`、`join` 和 `upgrade` 等子命令会促使 kubeadm 将 `KubeletConfiguration` 写入到文件 `/var/lib/kubelet/config.yaml` 中， 继而把它传递给本地节点的 kubelet。

迁移cgroup驱动
https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#%E8%BF%81%E7%A7%BB%E5%88%B0-systemd-%E9%A9%B1%E5%8A%A8

https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/#cgroupfs-cgroup-driver
注意：更改已加入集群的节点的 cgroup 驱动是一项敏感的操作。 如果 kubelet 已经使用某 cgroup 驱动的语义创建了 Pod，更改运行时以使用别的 cgroup 驱动，当为现有 Pod 重新创建 PodSandbox 时会产生错误。 重启 kubelet 也可能无法解决此类问题。



# 部署配置

### Choose container runtime interface (CRI) 选择容器运行时接口 (CRI)

必须先配置并启动容器运行时，然后 kubelet.service 才能使用它。
您将使用容器运行时接口端点将标志 --cri-socket 传递给 kubeadm init 或 kubeadm join 以创建或加入集群。
例如，如果您选择 containerd 作为 CRI 运行时，则标志 --cri-socket 将是：
```
kubeadm init --cri-socket /run/containerd/containerd.sock
```
### Containerd 
当使用containerd作为容器运行时时，需要提供 kubeadm init 或 kubeadm join 及其CRI端点。为此，请将其标志 --cri-socket 指定为 /run/containerd/containerd.sock [[4]](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime)。
使用containerd作为CRI端点的完整 kubeadm join 如下所示：
```
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash> --cri-socket=/run/containerd/containerd.sock
```

## 集群网络
https://kubernetes.io/zh-cn/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model
https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements
## Choose Cluster Network Parameter 选择集群网络参数
### 选择 Pod CIDR 范围
必须为相应的容器运行时配置集群的网络设置。这可以使用 [cni-plugins](https://archlinux.org/packages/?name=cni-plugins)来完成。

Pod CIDR 地址是指分配给 Kubernetes 集群内 Pod 的 IP 地址范围。当 Pod 被安排在集群中的节点上运行时，它们会被分配来自此 CIDR 范围的 IP 地址。

Pod CIDR 范围是在部署 Kubernetes 集群时指定的，并且限制在集群网络内。它不应与集群内使用的其他 IP 范围重叠，例如 service CIDR 范围。

您将把带有虚拟网络 CIDR 值的标志 --pod-network-cidr 传递给 kubeadm init 或 kubeadm join 以创建或加入集群。

For example:  例如：
```
kubeadm init --pod-network-cidr='10.85.0.0/16'
```
会将您的 kubernetes 的 pod CIDR 范围设置为“10.85.0.0/16”。

### (Optional) Chosse API server advertising address
如果您的控制平面节点位于多个子网中（例如您可能安装了 tailscale tailnet），则在使用 kubeadm init 初始化 Kubernetes master 时，您可以使用 --apiserver-advertise 指定 API 服务器将通告的 IP 地址-地址标志。

该 IP 地址应该可供集群中的所有节点访问。

### (Optional) Choose alternative node network proxy provider
像 kube-proxy 这样的节点代理提供程序是一个网络代理，在集群中的每个节点上运行，维护节点上的网络规则，以允许从集群内部或外部的网络会话与 Pod 进行网络通信。

默认情况下，kubeadm 选择 kube-proxy 作为在集群中每个节点上运行的节点代理。

诸如 cilium 之类的容器网络接口 (CNI) 插件提供了 kube-proxy 的完整替代品。

如果您想使用 cilium 的节点网络代理实现来充分利用 cilium 的网络策略功能，您应该将标志 --skip-phases=addon/kube-proxy 传递给 kubeadm init 以跳过 kube-proxy 的安装。

Cilium 将在安装过程中安装完整的替代品。详细信息请参见[[5]](https://docs.cilium.io/en/latest/network/kubernetes/kubeproxy-free/)。
## [排障指南](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#usr-mounted-read-only/)
## Create cluster 创建集群








### ipvs
```
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules

bash /etc/sysconfig/modules/ipvs.modules

lsmod | grep -e ip_vs -e nf_conntrack_ipv4


paru -S ipset ipvsadm 
```


```bash
替换配置文件
# sed -i "s#k8s.gcr.io#registry.cn-hangzhou.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
sudo sed -i '/containerd.runtimes.runc.options/a\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml
# sed -i "s#https://registry-1.docker.io#https://registry.cn-hangzhou.aliyuncs.com#g"  /etc/containerd/config.toml
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable containerd
sudo systemctl restart containerd
```

kubeadm
https://juejin.cn/post/7144578684077228068
https://medium.com/@kosta709/kubernetes-by-kubeadm-config-yamls-94e2ee11244

https://web.archive.org/web/20190227062309/https://kubernetes.io/docs/setup/scratch/
```bash

kubeadm config print init-defaults  --component-configs KubeProxyConfiguratio
kubeadm config print init-defaults  --component-configs KubeletConfiguration 

sudo kubeadm init --ignore-preflight-errors=Swap phase preflight --config init.yaml
kubeadm config images list --config init.yaml
sudo kubeadm config images pull --config init.yaml

sudo ctr -n k8s.io images pull registry.k8s.io/kube-apiserver:v1.27.0
sudo ctr -n k8s.io images ls

sudo ctr -n=k8s.io images ls |awk '{ print $1 }' | xargs -r -I{} sudo ctr -n=k8s.io image remove {}

sudo nethogs

```
```bash
cat << EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF


# 修改配置
mkdir -p /etc/containerd
if [ ! -f /etc/containerd/config.toml ]; then
    containerd config default > /etc/containerd/config.toml
fi

# 设置 systemd_cgroup 为 true
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sed -i 's/k8s.gcr.io/registry.aliyuncs.com\/google_containers/g' /etc/containerd/config.toml
sed -i 's/registry.k8s.io/registry.aliyuncs.com\/google_containers/g' /etc/containerd/config.toml

systemctl restart containerd

# 确保containerd 的cgroup 为 SystemdCgroup
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock info | grep SystemdCgroup | awk -F ': ' '{ print $2 }'

sudo sh -c "kubeadm reset -f ; ipvsadm --clear ; rm -rf ~/.kube ; rm -rf $HOME/.kube/config ; rm -rf /etc/cni/net.d"

sudo kubeadm init --config demo.yaml --upload-certs --v=5

kubectl get nodes -o json | jq '.items[].spec.taints'
kubectl taint nodes archlinux node-role.kubernetes.io/control-plane:NoSchedule-

# kubeadm init --cri-socket /run/containerd/containerd.sock

```











## FAQ
Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create containerd task: cgroups: cgroup mountpoint does not exist: unknown


```bash
sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
```

```bash
# $ sudo sh -c 'echo "GRUB_CMDLINE_LINUX=systemd.unified_cgroup_hierarchy=false" > /etc/default/grub.d/cgroup.cfg'
# $ sudo update-grub
```

