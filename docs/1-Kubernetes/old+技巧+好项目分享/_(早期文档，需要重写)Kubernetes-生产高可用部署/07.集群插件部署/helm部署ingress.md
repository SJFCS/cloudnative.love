---
title: Helm部署ingress
---



## 前言

[ingress nginx部署文档](https://kubernetes.github.io/ingress-nginx/deploy/)提供了多种公有云部署方式，也提供了Bare-metal 裸金属部署 [Bare-metal considerations裸金属部署注意事项](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)。本文[使用Helm进行部署ingress](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)（只支持 Helm v 3）

[Helm官方部署文档](https://helm.sh/docs/intro/install/)提供了二进制、脚本、包管理器等安装方式，下面使用二进制安装

## 安装Helm

每个Helm [版本](https://github.com/helm/helm/releases)都提供了各种操作系统的二进制版本，这些版本可以手动下载和安装。

1. 下载 [需要的版本](https://github.com/helm/helm/releases)
2. 解压(`tar -zxvf helm-v3.6.3-linux-amd64.tar.gz`)
3. 在解压目中找到`helm`程序，移动到需要的目录中(`mv linux-amd64/helm /usr/local/bin/helm`)

## 添加ingress的helm仓库

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

## 下载ingress的helm包至本地

我们需要修改默认配置，所以不能直接`helm install ingress-nginx ingress-nginx/ingress-nginx`，需要先下载至本地

```
helm search repo ingress
helm pull ingress-nginx/ingress-nginx --version  4.0.1
tar xf ingress-nginx-4.0.1.tgz && cd ingress-nginx
```

## 更改对应的配置

```bash
vim values.yaml

修改镜像地址，需要将公网镜像同步至公司内网镜像仓库
注释镜像的digest值

hostNetwork设置为true
dnsPolicy设置为 ClusterFirstWithHostNet

kind设置为DaemonSet
nodeSelector:添加ingress: "true"部署至指定节点

type: LoadBalancer改为type: ClustertIP（LoadBalancer适用于云环境）

根据需要配置limit
```

## 部署ingress

将ingress controller部署至Node节点（ingress controller不要部署在master节点，生产环境最少三个ingress controller，并且最好是独立的节点），添加命名空间并给需要部署ingress的节点打上`ingress: "true"`标签

```
kubectl create ns ingress-nginx

kubectl label node node3 ingress=true
kubectl get node --show-labels

helm install ingress-nginx -n ingress-nginx .
```

## 检测已安装的版本:

```
export POD_NAME=$(kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')

kubectl -n ingress-nginx exec -it $POD_NAME -- /nginx-ingress-controller --version
```

```
-------------------------------------------------------------------------------
NGINX Ingress controller
  Release:       v1.0.0
  Build:         041eb167c7bfccb1d1653f194924b0c5fd885e10
  Repository:    https://github.com/kubernetes/ingress-nginx
  nginx version: nginx/1.20.1
-------------------------------------------------------------------------------
```

## 访问测试

```
kubectl --namespace ingress-nginx port-forward $POD_NAME 8080:80
```

```
root@node1[18:04:18]:~$ curl  127.0.0.1:8080
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

 

## 其他

## 检查可用的 GitLab Runner Helm Chart 版本

Helm Chart 和 GitLab Runner 的版本不遵循相同的版本控制。使用以下命令获取 Helm Chart 和 GitLab Runner 之间的版本映射：

```
# For Helm 2
helm search -l gitlab/gitlab-runner

# For Helm 3
helm search repo -l gitlab/gitlab-runner
```

## 