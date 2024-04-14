---
title: Api Server 和 ETCD 健康状态检查
---
## kube-apiserver 健康状态检查

rancher 自定义集群或者 rke 集群，kube-scheduler 和 kube-controller-manager 以及  kube-apiserver 同时运行在一个主机上，并且都是以 host 网络默认运行。 当 kube-scheduler 和  kube-controller-manager 去连接 127.0.0.1:6443 时，其实就是在连接  kube-apiserver。有时如果提示 kube-scheduler 和 kube-controller-manager 连接  127.0.0.1:6443 失败，那么需要检查一下看是否是 kube-apiserver 本身运行异常，或者因为网络问题连接不上  kube-apiserver。

因为 rancher 自定义集群或者 rke 集群中，所有组件都开启了 ssl 认证，并且 kube-apiserver 和 etcd  均开启了双向认证。所以如果要去直接访问，则需要传递对应的客户端证书。通过在 master 主机上执行以下命令，正常状态下将返回 `OK` 两个字母。

```
curl --cacert /etc/kubernetes/ssl/kube-ca.pem --cert /etc/kubernetes/ssl/kube-node.pem --key /etc/kubernetes/ssl/kube-node-key.pem https://127.0.0.1:6443/healthz
```

## ETCD 健康状态检查

登录一台 ETCD 节点，然后通过 NODE_IP 指定 ETCD 节点 IP，再运行以下命令去检查 ETCD 服务状态。可以更换 IP 去检查多个服务状态。

```
curl --cacert /etc/kubernetes/ssl/kube-ca.pem --cert /etc/kubernetes/ssl/kube-node.pem --key /etc/kubernetes/ssl/kube-node-key.pem https://${NODE_IP}:2379/health
```