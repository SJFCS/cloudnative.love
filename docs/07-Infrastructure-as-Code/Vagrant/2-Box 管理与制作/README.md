---
title: Box 管理与制作
sidebar_position: 2
---
这里列举了一些镜像地址
```bash
curl -L https://stable.release.core-os.net/amd64-usr/2023.4.0/coreos_production_vagrant_virtualbox.box > coreos_production_vagrant_virtualbox-2023.4.0.box
curl -L https://stable.release.core-os.net/amd64-usr/2023.5.0/coreos_production_vagrant_virtualbox.box > coreos_production_vagrant_virtualbox-2023.5.0.box
curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box
curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box
curl -L http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box

curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64-vagrant.box > 18.04-bionic-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/xenial/current/xenial-server-cloudimg-amd64-vagrant.box > 16.04-xenial-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/focal/current/focal-server-cloudimg-amd64-vagrant.box > 20.04-focal-server-cloudimg-amd64-vagrant.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1811_01.VirtualBox.box
curl -L https://mirrors.ustc.edu.cn/centos-cloud/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box > CentOS-7-x86_64-Vagrant-1901_01.VirtualBox.box
```

## 添加镜像到本地仓库
```bash
# vagrant box add [box-name] [box镜像文件或镜像名]
vagrant box add centos-7.3 /home/hgp/vagrant/CentOS-7-x86_64-Vagrant-1805_01.VirtualBox.box
```

## 移除本地镜像
```bash
vagrant box remove [box-name]
```

## 列出本地仓库的镜像
```bash
vagrant box list
```