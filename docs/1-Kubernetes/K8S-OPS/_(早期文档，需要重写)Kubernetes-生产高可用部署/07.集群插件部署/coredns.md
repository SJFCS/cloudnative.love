---
title: 使用coredns代替kube-dns
---

为了在一个新的 Kubernetes 集群中安装 coryns 而不是 kube-dns，我们需要使用 feature-gates  标志并将其设置为 coryns = true。在安装新的 Kubernetes 集群时，使用以下命令将 coryns 安装为默认 DNS 服务。

```
# kubeadm init --feature-gates CoreDNS=true
```

检查要升级的 coreddns 版本:

```
# kubeadm upgrade plan  --feature-gates CoreDNS=true
```

然后可以使用 kubeadm 升级 apply 和特性门 coreddns = true 来升级使用 coreddns 作为默认 DNS 的集群:

```
# kubeadm upgrade apply <version> --feature-gates CoreDNS=true
# kubeadm upgrade apply v1.10.0-alpha.1  --feature-gates CoreDNS=true 
```

### 简介

`CoreDNS`是一个`Go`语言实现的链式插件`DNS服务端`，是CNCF成员，是一个 高性能、易扩展的`DNS服务端`。可以很方便的部署在k8s集群中，用来代替`kube-dns`。

### 使用kubeadm初始化时指定

> 修改`kubeadm-master.config`配置文件

```
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: v1.9.0
imageRepository: registry.cn-shanghai.aliyuncs.com/gcr-k8s
etcd:
  image: registry.cn-shanghai.aliyuncs.com/gcr-k8s/etcd-amd64:3.1.10
api:
  advertiseAddress: 11.11.11.111
networking:
  podSubnet: 10.244.0.0/16
featureGates:
  CoreDNS: true

作者：_CountingStars
链接：https://juejin.cn/post/6844903636858830861
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 单独部署coredns

> 不依赖kubeadm的方式，适用于不是使用kubeadm创建的k8s集群，或者kubeadm初始化集群之后，删除了dns相关部署。

```
# 在calico网络中也配置一个coredns
# 10.96.0.10 为k8s官方指定的kube-dns地址
mkdir coredns && cd coredns
wget https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed
wget https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/deploy.sh
chmod +x deploy.sh
./deploy.sh -i 10.96.0.10 > coredns.yml
kubectl apply -f coredns.yml

# 查看
kubectl get pods --namespace kube-system
kubectl get svc --namespace kube-system

```

