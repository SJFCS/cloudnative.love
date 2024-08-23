---
title: Docker时间宿主机同步
tags:
  - posts
categories:
  - Docker
series: 
  - 
lastmod: '2021-03-07'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---
## 一、分析时间不一致的原因

在Docker容器创建好之后，可能会发现容器时间跟宿主机时间不一致，此时需要同步它们的时间，让容器时间跟宿主机时间保持一致。

<!--more-->

 宿主机采用了CST时区，CST应该是指（China Shanghai Time，东八区时间）

容器采用了UTC时区，UTC应该是指（Coordinated Universal Time，标准时间）

此时，容器与宿主机之间采用的时区不一致，两个时区之间相隔8小时。

## 二、同步时间的方法

### 方案1：共享主机localtime

在创建容器的时候指定启动参数，挂载宿主机的localtime文件到**容器内**，以此来保证宿主机和容器的时区一致。

```
docker run --privileged --name=qinjiaxi --net=host -it -v ~:/share /etc/localtime:/etc/localtime:ro docker.xxx.xxx.com.cn/robotframework:2.7.14 bash
```

### 方案2：复制宿主机localtime到容器中

```
docker cp /etc/localtime <container_id>:/etc/
```

### 方案3：在创建dockerfile时自定义镜像的时间格式与时区

在dockerfile创建初期增加一行内容，内容规定了该镜像的时间格式以及时区。

```
#设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
```