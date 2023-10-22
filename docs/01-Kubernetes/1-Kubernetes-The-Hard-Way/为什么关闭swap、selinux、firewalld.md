
关于防火墙的原因（nftables后端兼容性问题，产生重复的防火墙规则）Theiptablestooling can act as a compatibility layer, behaving like iptables but actually configuring nftables. This nftables backend is not compatible with the current kubeadm packages: it causes duplicated firewall rules and breakskube-proxy.关于selinux的原因（关闭selinux以允许容器访问宿主机的文件系统）Setting SELinux in permissive mode by runningsetenforce 0andsed ...effectively disables it. This is required to allow containers to access the host filesystem, which is needed by pod networks for example. You have to do this until SELinux support is improved in the kubelet.

至于swap嘛，开发人员有说明 https://link.zhihu.com/?target=https%3A//github.com/kubernetes/kubernetes/issues/53533
