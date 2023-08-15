---
title: Docker 时间同步
tags: [Docker]
---

## 一、分析时间不一致的原因

在Docker容器创建好之后，可能会发现容器时间跟宿主机时间不一致，此时需要同步它们的时间，让容器时间跟宿主机时间保持一致。

宿主机采用了CST时区，CST应该是指（China Shanghai Time，东八区时间）

容器采用了UTC时区，UTC应该是指（Coordinated Universal Time，标准时间）

此时，容器与宿主机之间采用的时区不一致，两个时区之间相隔8小时。

## 二、同步时间的方法

### 命令行

**共享主机 localtime 文件**

在创建容器的时候指定启动参数，挂载宿主机的 `localtime` 文件到容器内，以此来保证宿主机和容器的时区一致。

```bash
docker run -itd -v /etc/localtime:/etc/localtime:ro nginx 
```

**复制宿主机 localtime 到容器中**

```bash
docker cp /etc/localtime <container_id>:/etc/
```

### Dockerfile

在 dockerfile 创建初期增加一行内容，内容规定了该镜像的时间格式以及时区。

```dockerfile
# 方法1
# 添加时区环境变量，亚洲，上海
ENV TimeZone=Asia/Shanghai
# 使用软连接，并且将时区配置覆盖/etc/timezone
RUN ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone

# 方法2
#设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
# CentOS
RUN echo "Asia/shanghai" > /etc/timezone
# Ubuntu
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### Docker-Compose
```dockerfile
#第一种方式(推荐)：
environment:
  TZ: Asia/Shanghai
  
#第二种方式：
environment:
  SET_CONTAINER_TIMEZONE=true
  CONTAINER_TIMEZONE=Asia/Shanghai

#第三种方式：
volumes:
  - /etc/timezone:/etc/timezone
  - /etc/localtime:/etc/localtime
```