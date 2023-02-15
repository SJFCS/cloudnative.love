---
title: 使用 kubeadm 进行证书管理
---



## 使用自定义的证书

默认情况下, kubeadm 会生成运行一个集群所需的全部证书。 

你可以通过`--cert-dir` 参数或配置文件中的 `CertificatesDir` 配置项指明的目录中。默认的值是 `/etc/kubernetes/pki`。

如果在运行 `kubeadm init` 之前存在给定的证书和私钥对，kubeadm 将不会重写它们。 可以将现有的 CA 复制到 `/etc/kubernetes/pki/ca.crt` 和 `/etc/kubernetes/pki/ca.key` 中，而 kubeadm 将使用此 CA 对其余证书进行签名。

## 检查证书是否过期

你可以使用 `check-expiration` 子命令来检查证书何时过期

```shell
kubeadm certs check-expiration
```

该命令显示 `/etc/kubernetes/pki` 文件夹中的客户端证书以及 kubeadm（`admin.conf`, `controller-manager.conf` 和 `scheduler.conf`） 使用的 KUBECONFIG 文件中嵌入的客户端证书的到期时间/剩余时间。

## 手动更新证书

你能随时通过 `kubeadm certs renew` 命令手动更新你的证书。

```
kubeadm certs renew all
```

> **警告：** 如果你运行了一个 HA 集群，这个命令需要在所有控制面板节点上执行。

## 通过crontab定时更新证书

```sh
0 0 15 10 * kubeadm alpha certs renew all
分时日月周
```

## 证书过期kubectl命令无法使用

```sh
# 更新客户端配置
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

>https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
>
>https://kubernetes.io/zh/docs/tasks/tls/certificate-rotation/
>
>https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
>
>https://github.com/kubernetes/kubeadm/issues/581
>
> [Kubernetes 中的 PKI 证书和要求](https://kubernetes.io/zh/docs/setup/best-practices/certificates/)。
>证书过期处理：https://blog.csdn.net/ywq935/article/details/88355832
>
>自动轮换证书https://www.cnblogs.com/skymyyang/p/11093686.html

