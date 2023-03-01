---
title: 平滑升级 kubeadm 集群
---



参考官方文档：https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## 准备开始

- 务必仔细认真阅读[发行说明](https://git.k8s.io/kubernetes/CHANGELOG/CHANGELOG-1.22.md)。
- 集群应使用静态的控制平面和 etcd Pod 或者外部 etcd。
- 务必备份所有重要组件，例如存储在数据库中应用层面的状态。 `kubeadm upgrade` 不会影响你的工作负载，只会涉及 Kubernetes 内部的组件，但备份终究是好的。
- [必须禁用交换分区](https://serverfault.com/questions/684771/best-way-to-disable-swap-in-linux)。

- 在对 kubelet 作次版本升版时需要[腾空节点](https://kubernetes.io/zh/docs/tasks/administer-cluster/safely-drain-node/)。 对于控制面节点，其上可能运行着 CoreDNS Pods 或者其它非常重要的负载。
- 升级后，因为容器规约的哈希值已更改，所有容器都会被重新启动。

## 更新yum源

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all
yum makecache
```

## 确定版本

查找可升级版本

```
kubeadm upgrade plan
kubeadm upgrade plan 1.20.10
```

查找kubeamd安装包版本

```
yum list --showduplicates kubeadm --disableexcludes=kubernetes
# 在列表中查找版本
# 1.22.x-0，其中 x 是最新的补丁版本
```

## 升级控制平面节点

控制面节点上的升级过程应该每次处理一个节点。 首先选择一个要先行升级的控制面节点。该节点上必须拥有 `/etc/kubernetes/admin.conf` 文件。

### **升级第一个控制面节点**

```shell
yum install -y kubeadm-1.20.5-0 --disableexcludes=kubernetes
```

- 验证下载操作正常，并且 kubeadm 版本正确：

  ```shell
  kubeadm version
  ```

- 验证升级计划：

  ```shell
  kubeadm upgrade plan 1.20.5
  ```

  此命令检查你的集群是否可被升级，并取回你要升级的目标版本。 命令也会显示一个包含组件配置版本状态的表格。

  > **说明：**
  >
  > `kubeadm upgrade` 也会自动对 kubeadm 在节点上所管理的证书执行续约操作。 如果需要略过证书续约操作，可以使用标志 `--certificate-renewal=false`。 更多的信息，可参阅[证书管理指南](https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-certs)。

  > **说明：**
  >
  > 如果 `kubeadm upgrade plan` 给出任何需要手动升级的组件配置，用户必须 通过 `--config` 命令行标志向 `kubeadm upgrade apply` 命令提供替代的配置文件。 如果不这样做，`kubeadm upgrade apply` 会出错并退出，不再执行升级操作。

选择要升级到的目标版本，运行合适的命令。例如：

```shell
# 将 x 替换为你为此次升级所选择的补丁版本号
sudo kubeadm upgrade apply v1.20.5
```

> 你也可以使用配置文件来对集群进行升级
>
> 导出当前配置文件
>
> ```
> kubeadm config view > kubeadm-config-upgrade.yaml
> ```
>
> 修改版本
>
> ```
> imageRepository 的值修改为：registry.cn-hangzhou.aliyuncs.com/google_containers
> kubernetesVersion 的值修改为： v1.20.5
> ```
>
> 执行升级
>
> ```
> # 对比
> kubeadm upgrade diff --config kubeadm-config-upgrade.yaml
> # 预检测
> kubeadm upgrade apply --config kubeadm-config-upgrade.yaml --dry-run
> # 执行升级
> kubeadm upgrade apply --config kubeadm-config-upgrade.yaml
> ```

一旦该命令结束，你应该会看到：

```
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.22.x". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

- 手动升级你的 CNI 驱动插件。

  你的容器网络接口（CNI）驱动应该提供了程序自身的升级说明。 参阅[插件](https://kubernetes.io/zh/docs/concepts/cluster-administration/addons/)页面查找你的 CNI 驱动， 并查看是否需要其他升级步骤。

  如果 CNI 驱动作为 DaemonSet 运行，则在其他控制平面节点上不需要此步骤。
  
  > 升级 calico 时，集群内部网络会不可用，请选择合适的时间升级

### 升级 kubelet 和 kubectl

- 通过将节点标记为不可调度并腾空节点为节点作升级准备：

  ```shell
  # 将 <node-to-drain> 替换为你要腾空的控制面节点名称
  kubectl drain <node-to-drain> --ignore-daemonsets
  ```

+ 升级 kubelet 和 kubectl

   ```
  # 用最新的补丁版本号替换 1.22.x-00 中的 x
  yum install -y kubelet-1.20.5-0 kubectl-1.20.5-0 --disableexcludes=kubernetes
  ```

- 重启 kubelet

  ```shell
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  ```

- 通过将节点标记为可调度，让其重新上线：

  ```shell
  # 将 <node-to-drain> 替换为你的节点名称
  kubectl uncordon <node-to-drain>
  ```

### **对于其它控制面节点**

+ 与前面不同这里使用`kubeadm upgrade node`

   ```
   sudo kubeadm upgrade node
   ```

此外，不需要执行 `kubeadm upgrade plan` 和更新 CNI 驱动插件的操作。

+ 升级 kubelet 和 kubectl **参照前文**

## 升级工作节点

工作节点上的升级过程应该一次执行一个节点，或者一次执行几个节点， 以不影响运行工作负载所需的最小容量。

+ 升级 kubeadm

   ```shell
   # 用最新的补丁版本替换 1.22.x-00 中的 x
   yum install -y kubeadm-1.22.x-0 --disableexcludes=kubernetes
   ```

+ 对于工作节点，下面的命令会升级本地的 kubelet 配置：

    ```shell
   sudo kubeadm upgrade node
   ```

+ 将节点标记为不可调度并驱逐所有负载，准备节点的维护：

  ```shell
  # 将 <node-to-drain> 替换为你正在腾空的节点的名称
  kubectl drain <node-to-drain> --ignore-daemonsets
  ```

- 升级 kubelet 和 kubectl：

   ```shell
  # 将 1.22.x-0 x 替换为最新的补丁版本
  yum install -y kubelet-1.22.x-0 kubectl-1.22.x-0 --disableexcludes=kubernetes
  ```

- 重启 kubelet

  ```shell
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  ```

+ 通过将节点标记为可调度，让节点重新上线:

   ```shell
   # 将 <node-to-drain> 替换为当前节点的名称
  kubectl uncordon <node-to-drain>
  ```

## 验证集群的状态

在所有节点上升级 kubelet 后，通过从 kubectl 可以访问集群的任何位置运行以下命令， 验证所有节点是否再次可用：

```shell
kubectl get nodes
```

`STATUS` 应显示所有节点为 `Ready` 状态，并且版本号已经被更新。

## 从故障状态恢复

如果 `kubeadm upgrade` 失败并且没有回滚，例如由于执行期间节点意外关闭， 你可以再次运行 `kubeadm upgrade`。 此命令是幂等的，并最终确保实际状态是你声明的期望状态。 要从故障状态恢复，你还可以运行 `kubeadm upgrade --force` 而无需更改集群正在运行的版本。

在升级期间，kubeadm 向 `/etc/kubernetes/tmp` 目录下的如下备份文件夹写入数据：

- `kubeadm-backup-etcd-<date>-<time>`
- `kubeadm-backup-manifests-<date>-<time>`

`kubeadm-backup-etcd` 包含当前控制面节点本地 etcd 成员数据的备份。 如果 etcd 升级失败并且自动回滚也无法修复，则可以将此文件夹中的内容复制到 `/var/lib/etcd` 进行手工修复。如果使用的是外部的 etcd，则此备份文件夹为空。

`kubeadm-backup-manifests` 包含当前控制面节点的静态 Pod 清单文件的备份版本。 如果升级失败并且无法自动回滚，则此文件夹中的内容可以复制到 `/etc/kubernetes/manifests` 目录实现手工恢复。 如果由于某些原因，在升级前后某个组件的清单未发生变化，则 kubeadm 也不会为之 生成备份版本。

## 工作原理  

`kubeadm upgrade apply` 做了以下工作：

- 检查你的集群是否处于可升级状态:
  - API 服务器是可访问的
  - 所有节点处于 `Ready` 状态
  - 控制面是健康的
- 强制执行版本偏差策略。
- 确保控制面的镜像是可用的或可拉取到服务器上。
- 如果组件配置要求版本升级，则生成替代配置与/或使用用户提供的覆盖版本配置。
- 升级控制面组件或回滚（如果其中任何一个组件无法启动）。
- 应用新的 `CoreDNS` 和 `kube-proxy` 清单，并强制创建所有必需的 RBAC 规则。
- 如果旧文件在 180 天后过期，将创建 API 服务器的新证书和密钥文件并备份旧文件。

`kubeadm upgrade node` 在其他控制平节点上执行以下操作：

- 从集群中获取 kubeadm `ClusterConfiguration`。
- （可选操作）备份 kube-apiserver 证书。
- 升级控制平面组件的静态 Pod 清单。
- 为本节点升级 kubelet 配置

`kubeadm upgrade node` 在工作节点上完成以下工作：

- 从集群取回 kubeadm `ClusterConfiguration`。
- 为本节点升级 kubelet 配置。