---
title: ETCD 的备份与恢复
tags: [Database,ETCD]
---
- [disaster recovery](https://github.com/etcd-io/website/blob/main/content/en/docs/v3.5/op-guide/recovery.md) 

- [Disaster Recovery for your Kubernetes Clusters [I] - Andy Goldstein & Steve Kriss, Heptio](https://www.youtube.com/watch?v=qRPNuT080Hk)

- [configure-upgrade-etcd](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster)

## API 版本

ETCDCTL 可以使用 2 个 API 版本,默认情况下，它设置为使用版本 2。每个版本都有不同的命令集。

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>

  <TabItem value="API Version2">

  设置环境变量 ETCDCTL_API 指定要使用的API版本

  ```bash
  export ETCDCTL_API=2
  ```

  命令集
  ```bash
  etcdctl backup
  etcdctl cluster-health
  etcdctl mk
  etcdctl mkdir
  etcdctl set
  ```  
  </TabItem>

  <TabItem value="API Version3">

  设置环境变量 ETCDCTL_API 指定要使用的API版本

  ```bash
  export ETCDCTL_API=3
  ```

  命令集
  ```bash
  etcdctl snapshot save 
  etcdctl endpoint health
  etcdctl member list
  etcdctl get
  etcdctl put
  ```
  </TabItem>

</Tabs>

除此之外，您还必须指定证书文件的路径，以便 ETCDCTL 可以对 ETCD API 服务器进行身份验证。证书文件在 etcd-master 的以下路径中可用。

```bash
# 端点ENDPOINT信息
kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep advertise-client-urls
# 证书位置
kubectl describe  pods -n kube-system etcd-cluster1-controlplane  | grep pki
```

## 创建快照

SSH 到 ETCD 控制平面节点，然后使用我们上面标识的端点和证书进行备份：

```bash
export ETCDCTL_API=3
export ENDPOINT=http:/node1:2379
export TIME=$(date +%Y%m%d_%H%M%S)
# 在只选中一个节点时，才可以执行 snapshot 命令
etcdctl snapshot save ${TIME}_snapshot.db \
--endpoints=$ENDPOINT \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \

# 查看备份文件的信息
etcdctl --write-out=table snapshot status ${TIME}_snapshot.d
```

## ETCD 备份恢复

因为 etcd 采用 raft 协议，所以整个集群能够容忍的故障节点数为（n-1)/2，大多数情况下故障节点会从失败中恢复，如果故障节点无法从失败中恢复，那么请按下面情况进行恢复。

- 在集群下线节点数**不超过 (N-1)/2 **的情况下，集群仍能正常读写。
  - 从集群中剔除故障节点：使用 `member remove` 命令剔除错误节点。保证当前集群的健康状况
  - 清除故障节点的脏数据：错误节点必须停止，然后删除data dir。保证 `member` 信息被清理干净，清空 `member` 目录
  - 将故障节点节点以新的 member 身份重新加入集群：使用 `member add` 命令添加
  - 启动 etcd 服务：确保节点的 `/data/etcd.env` `/data/etcd.service` 以及 etcd/etcdctl 均配置完成，并添加启动参数`--initial-cluster-state existing` 这样其启动后会自动从正常节点自动同步数据

- 在集群下线节点数**超过 (N-1)/2 **的情况下，集群变为只读。

  此时则需要启用 灾难恢复（disaster recovery）来恢复集群。

### 故障不超过 (N-1)/2 数据恢复

```shell
export ETCDCTL_API=3
export ENDPOINT=http://node1:2379,http://node2:2379,http://node3:2379

# 查看节点状态
etcdctl --endpoints=$ETCD_ENDPOINTS --write-out=table endpoint status

# 列出所有节点，记录下损坏节点的 ID
etcdctl --endpoints $ENDPOINT member list

# 使用你记录下的 ID，从集群中移除该节点
etcdctl --endpoints $ENDPOINT member remove <id>

# 如果你是将原节点重新加入集群，还需要清理干净数据目录
sudo rm -rf /data/etcd.data

# 现在将该节点加入到 etcd 集群，加入成功后，会打印出一系列新节点需要设置的参数
etcdctl --endpoints=$ENDPOINT member add etcd1 --peer-urls="http://node1:2380"
```

<!-- 
或者恢复这个故障节点
```bash
ETCDCTL_API=3 etcdctl snapshot restore /root/cluster2.db --data-dir /var/lib/etcd-data-new \
--endpoints=https://node1:2379 \
--cacert=/etc/etcd/pki/ca.pem \
--cert=/etc/etcd/pki/etcd.pem \
--key=/etc/etcd/pki/etcd-key.pem 
``` -->
:::caution

由于etcd的数据已经被删除，因此当前节点重启时，从其他的节点获取数据，因此需要调整参数–initial-cluster-state，从new改成existing
- 方法1: 修改 `/data/etcd.env`，如果你的主机 IP 没有变更的话，一般只需要修改 `ETCD_INITIAL_CLUSTER_STATE="existing"` 
- 方法2: 添加启动参数`--initial-cluster-state existing`
:::

等待集群数据完成同步并恢复既可，由于整体集群有多副本，因此单节点异常时，并不会导致整个集群异常，只要正常启动对应的节点并同步数据即可恢复。

### 故障超过 (N-1)/2 灾难恢复

所有成员都应使用相同的 snapshot 快照进行恢复。



对于仍然可用的节点，将旧的数据移动到别的地方，它基本上已经没用了：

```shell
mv /data/etcd.data /data/etcd.data.old
```

然后确保所有节点上都已经配置好了 `/data/etcd.env` 和 `/data/etcd.service`，但是暂时不要启动 etcd 服务！

现在在所有节点上， 分别使用 snapshot 恢复它们的数据目录：

```shell
export ETCDCTL_API=3
# 获取 etcd 的配置信息
source /data/etcd.env

# 使用 snapshot.db 这个快照，将 etcd 数据恢复到 $ETCD_DATA_DIR 这个目录中
etcdctl snapshot restore snapshot.db \
  --name=$ETCD_NAME \
  --initial-cluster "${NAME_1}=http://${HOST_1}:2380,${NAME_2}=http://${HOST_2}:2380,${NAME_3}=http://${HOST_3}:2380" \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 \
  --data-dir=$ETCD_DATA_DIR \
  --initial-cluster-token=$ETCD_INITIAL_CLUSTER_TOKEN
```

:::caution
确保新目录上的权限为正确的(应归etcd用户所有)：
```bash
chown -R etcd:etcd /var/lib/etcd-data-new
etcd-server ~ ➜  ls -ld /var/lib/etcd-data-new/
drwx------ 3 etcd etcd 4096 Nov 11 01:48 /var/lib/etcd-data-new/
```
:::
















<!-- ## 备忘

<Tabs groupId="ETCD部署方式">
  <TabItem value="systemd">

  `vi /etc/systemd/system/etcd.service` 来更新 etcd 的 systemd 服务单元文件，或者 `sudo EDITOR=vim systemctl edit etcd.service`

  然后重启服务

  ```bash
  systemctl daemon-reload 
  systemctl restart etcd
  ```

  </TabItem>
  <TabItem value="kubeadm">

  位于 `/etc/kubernetes/manifests` 目录下的静态 pod。

  `watch "crictl ps | grep etcd"` 来查看 ETCD pod 何时重启。

  `kubectl delete pod -n kube-system etcd-controlplane` 重启它并等待 1 分钟。

  如果您在 ETCD YAML 文件中将 --data-dir 更改为 `/var/lib/etcd-from-backup`，请确保 etcd-data 的 volumeMounts 也已更新，mountPath 指向 `/var/lib/ etcd-from-backup` ，并且`--data-dir`目录的权限正确

  ```yaml title="/etc/kubernetes/manifests/etcd.yaml"
    volumes:
    - hostPath:
        path: /var/lib/etcd-from-backup
        type: DirectoryOrCreate
      name: etcd-data
        With this change, /var/lib/etcd on the container points to /var/lib/etcd-from-backup on the controlplane (which is what we want).
  ```
  </TabItem>
</Tabs> -->
