---
title: Box 管理与制作
---
import DocCardList from '@theme/DocCardList';


<DocCardList />

Vagrant Share 允许您与世界上的任何人共享您的 Vagrant 环境，只需一个命令即可在几乎任何网络环境中直接在您的 Vagrant 环境中进行协作： vagrant share.

https://developer.hashicorp.com/vagrant/docs/share




#### 下载vagrant镜像
```
#curl -L https://stable.release.core-os.net/amd64-usr/2023.4.0/coreos_production_vagrant_virtualbox.box > coreos_production_vagrant_virtualbox-2023.4.0.box
#curl -L https://stable.release.core-os.net/amd64-usr/2023.5.0/coreos_production_vagrant_virtualbox.box > coreos_production_vagrant_virtualbox-2023.5.0.box
#curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box
#curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box
#curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box

curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64-vagrant.box > 18.04-bionic-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/xenial/current/xenial-server-cloudimg-amd64-vagrant.box > 16.04-xenial-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/focal/current/focal-server-cloudimg-amd64-vagrant.box > 20.04-focal-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box

```

```
# 添加镜像到本地仓库
# vagrant box add [box-name] [box镜像文件或镜像名]
# 在任意目录运行vagrant box add 命令，添加给本来vagrant仓库添加镜像
vagrant box add centos-7.3 /home/hgp/vagrant/CentOS-7-x86_64-Vagrant-1805_01.VirtualBox.box
vagrant box add centos-7 /home/hgp/vagrant/CentOS-7-x86_64-Vagrant-1805_01.VirtualBox.box

# 移除本地镜像
# vagrant box remove [box-name]

# 列出本地仓库的镜像
vagrant box list

# 查看虚拟机的信息
vagrant status

# vagrant ssh登录的虚拟机的名称来自于 config.vm.define :example1
# 可以用 vagrant status 查看
```