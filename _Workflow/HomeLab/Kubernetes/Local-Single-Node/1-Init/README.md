http://linux-wiki.cn/wiki/zh-hant/%E8%A1%A5%E4%B8%81(patch)%E7%9A%84%E5%88%B6%E4%BD%9C%E4%B8%8E%E5%BA%94%E7%94%A8


sudo sh -c "containerd config default > /etc/containerd/config.toml"


containerd config default  >demo


cat patch_file | patch file_to_patch
patch file_to_patch < patch_file




diff -u original_file modified_file > patch_file
diff -u demo /etc/containerd/config.toml >patch




















```bash

kubeadm init phase addon kube-proxy \
  --control-plane-endpoint="192.168.8.100:6443" \
  --pod-network-cidr="172.16.0.0/16"  


kubeadm init \
  --control-plane-endpoint="192.168.8.100:6443" \
  --pod-network-cidr="172.16.0.0/16"  


kubeadm config migrate --old-config kubeadm-config.yaml --new-config new.yaml

sudo kubeadm init --config kubeadm-config.yaml --upload-certs    --skip-phases=addon/kube-proxy

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config




在Kubernetes中，Pod的重启计数是通过Pod的annotations来记录的。要清除Pod的重启计数，可以更新Pod的annotations并将重启计数设置为0。可以使用以下kubectl命令来完成此操作：

kubectl annotate pod <pod-name> kubernetes.io/restartedAt-
该命令会删除Pod的kubernetes.io/restartedAt注释，从而将Pod的重启计数重置为0。注意，该命令将删除Pod的所有注释，因此如果Pod还有其他注释，请在更新注释之前备份它们。



## 重新部署
sudo kubeadm reset -f 
sudo ipvsadm --clear 
sudo rm -rf ~/.kube 
sudo rm -rf $HOME/.kube/config 
sudo rm -rf /etc/cni/net.d
https://q.cnblogs.com/q/139904/
命令如下:

iptables -F (flush 清除所有的已定规则)
iptables -X (delete 删除所有用户“自定义”的链（tables）)
iptables -Z （zero 将所有的chain的计数与流量统计都归零）

/etc/rc.d/init.d/iptables save
systemctl iptables restart

# patch 生成
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sh -c "containerd config default > default.toml"
cp default.toml affter.toml
diff -u default.toml affter.toml>containerd-config-SystemdCgroup.patch

patch default.toml < containerd-config-SystemdCgroup.patch

sudo sh -c "patch /etc/containerd/config.toml < containerd-config.patch"
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service

sudo kubeadm init --config kubeadm-config.yaml --upload-certs 

kubectl taint nodes archlinux node-role.kubernetes.io/control-plane:NoSchedule-
cilium install 
```