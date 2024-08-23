---
title: Docker部署
tags:
  - posts
categories:
  - Docker
series: 
  - 
lastmod: '2020-01-07'

featuredImage: 
authors: songjinfeng
draft: true
toc: true

---



## [在CentOS上安装Docker Engine](https://docs.docker.com/engine/install/centos/)

<!--more-->

1. 安装所需的软件包。

   `sudo yum install -y yum-utils `
   yum-utils 提供了 yum-config-manager

   

   device mapper 存储驱动程序需要 device-mapper-persistent-data 和 lvm2。（现在默认overlay2驱动，不需要额外安装此选项）

2. 添加软件源信息
   
   `或者 yum install epel-release -y`
   `sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo`
   
   更新并安装Docker-CE
   `sudo yum makecache fast`
   `sudo yum -y install docker-ce`
    sudo yum install docker-ce docker-ce-cli containerd.io
   
4. 开启Docker服务
   `sudo systemctl start docker`
   注意：
   要安装特定版本的Docker Engine，请在存储库中列出可用版本，然后选择并安装：
   列出并排序您存储库中可用的版本。本示例按版本号（从高到低）对结果进行排序:

   ```
   yum list docker-ce --showduplicates | sort -r
   ```
   通过其完全合格的软件包名称安装特定版本，该软件包名称是软件包名称（docker-ce）加上版本字符串，从第一个冒号（:）到（-）之间。例如docker-ce-20.10.6。

 `sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io`

