---
title: K8S-Pull镜像脚本

---

脚本说明

1、拉取镜像时使用mirrorgcrio仓库，解决国内拉取问题

2、拉取完成后自动修改镜像tag为k8s.gcr.io，并删除mirrorgcrio这个tag
脚本文件

```bash
#!/bin/bash
# 获取要拉取的镜像信息，images.txt是临时文件
kubeadm config images list > images.txt
 
# 替换成mirrorgcrio的仓库，该仓库国内可用，和k8s.gcr.io的更新时间只差一两天
sed -i 's@k8s.gcr.io@mirrorgcrio@g' images.txt
 
# 拉取各镜像
cat images.txt | while read line
do
    docker pull $line
done
 
# 修改镜像tag为k8s.gcr.io仓库，并删除mirrorgcrio的tag
sed -i 's@mirrorgcrio/@@g' images.txt
cat images.txt | while read line
do
    docker tag mirrorgcrio/$line k8s.gcr.io/$line
    docker rmi -f mirrorgcrio/$line
done
 
# 操作完后显示本地docker镜像
docker images
 
# 删除临时文件
rm -f images.txt
```

```BASH
set -o errexit
set -o nounset
set -o pipefail

##这里定义版本，按照上面得到的列表自己改一下版本号

KUBE_VERSION=v1.18.5
KUBE_PAUSE_VERSION=3.2
ETCD_VERSION=3.4.3-0
DNS_VERSION=1.6.7

##这是原始仓库名，最后需要改名成这个
GCR_URL=k8s.gcr.io

##这里就是写你要使用的仓库
DOCKERHUB_URL=gotok8s

##这里是镜像列表，新版本要把coredns改成coredns/coredns
images=(
kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
kube-apiserver:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
coredns:${DNS_VERSION}
)

##这里是拉取和改名的循环语句
for imageName in ${images[@]} ; do
  docker pull $DOCKERHUB_URL/$imageName
  docker tag $DOCKERHUB_URL/$imageName $GCR_URL/$imageName
  docker rmi $DOCKERHUB_URL/$imageName
done
```