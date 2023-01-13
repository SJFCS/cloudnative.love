---
title: 部署Calico
---



**下面我们来部署网络插件Calico**

官方文档地址：https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises

>官方的三种部署方案
>
>- [Install Calico with Kubernetes API datastore, 50 nodes or less 使用 Kubernetes API 数据存储安装 Calico，50个节点或更少](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less)
>- [Install Calico with Kubernetes API datastore, more than 50 nodes 使用 Kubernetes API 数据存储安装 Calico，超过50个节点](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-more-than-50-nodes)
>- [Install Calico with etcd datastore 使用 etcd 数据存储安装 Calico](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-etcd-datastore)

本文使用etcd数据存储安装 Calico

下载 Calico 网络清单的 etcd。你也可以在github仓库下载想要的版本

```
curl https://docs.projectcalico.org/manifests/calico-etcd.yaml -o calico.yaml
```

修改calico-etcd.yaml的以下位置

```
ETCD_CA=`cat /etc/kubernetes/pki/etcd/ca.crt | base64 | tr -d '\n'`
ETCD_CERT=`cat /etc/kubernetes/pki/etcd/server.crt | base64 | tr -d '\n'`
ETCD_KEY=`cat /etc/kubernetes/pki/etcd/server.key | base64 | tr -d '\n'`
POD_SUBNET=`cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep cluster-cidr= | awk -F= '{print $NF}'`


etcd_endpoints: "https://10.0.0.10:2379,https://10.0.0.20:2379,https://10.0.0.30:2379"
etcd-key: ${ETCD_KEY}
etcd-cert: ${ETCD_CERT}
etcd-ca: ${ETCD_CA}

etcd_ca: "/calico-secrets/etcd-ca
etcd_cert: "/calico-secrets/etcd-cert
etcd_key: "/calico-secrets/etcd-key

- name: CALICO_IPV4POOL_CIDR
  value: "${POD_SUBNET}"

修改IP自动发现
当kubelet的启动参数中存在--node-ip的时候，以host-network模式启动的pod的status.hostIP字段就会自动填入kubelet中指定的ip地址。
修改前：
- name: IP
  value: "autodetect"
修改后：
- name: IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
```

使用以下命令部署。

 ```
  kubectl apply -f calico-etcd.yaml
 ```

