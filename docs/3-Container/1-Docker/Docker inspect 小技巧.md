---
title: Docker inspect 小技巧
tags: [Docker]
---
## inspect 简介

docker inspect 用于查看 docker 对象的底层基础信息(Return low-level information on Docker objects)。

包括容器的id、创建时间、运行状态、启动参数、目录挂载、网路配置等等。该命令也可以用来查看docker镜像的信息。

命令用法如下：

```
# 查看容器信息
docker inspect {Container ID}/{Container Name}

# 查看{Image:Version}镜像信息
docker inspect --type=image {Image:Version}

--size 用于查看容器的文件大小，加上该参数，输出的结果中会包含SizeRootFs和SizeRw

-f/--format 支持 go-template 格式化输出。可以结合其他的go方法（如range，split）使用。
```
:::tip 
通常会加上`|grep -C 15 IPAddress/Port/Name...`来缩小查询范围

```
grep 参数：

-A显示匹配后和它后面的n行。（After，之后）

-B显示匹配行和它前面的n行。（Before，之前）

-C匹配行和它前后各n行。（Context，上下文）
```

我们可以利用管道符来对输出结果进行美化输出，如在命令结尾添加 `|python -m json.tool` 或者 `|jq` 。

:::
## inspact 常用字段
通过inspact内容可以看到如下字段:

### **容器名称**：

```
{{.Name}}
```

### **IP地址：**

```
{{.NetworkSettings.IPAddress}}
{{.NetworkSettings.Networks.bridge.IPAddress}}
```

### **端口**：

```
{{.HostConfig.PortBindings}}
{{.NetworkSettings.Ports}}
```

## inspect 常用查询语句

在得知如上相关字段后我们可以通过 `inspect -f/--format`来精确查找

### 列出所有容器对应的名称，端口，及ip

```
docker inspect -f='{{.Name}}  |  {{.NetworkSettings.IPAddress}}  |  {{.NetworkSettings.Ports}}' $(docker ps -aq)

```

inspect --format 也可以指定range ... end，例如：

```
docker inspect --format='{{.Name}} - {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
```

### 查看目录挂载信息

输入如下命令, 则会输出容器的Mounts信息，可以看到容器中各个目录在宿主机的具体挂载位置。

```
docker inspect --format="{{json .Mounts}}"  container
```


### 查看容器网络信息

查看网络信息可以使用下面命令：

```
#查看完整网络信息
docker inspect --format="{{json .NetworkSettings}}" container | jq

#查看网络端口映射
docker inspect --format="{{json .NetworkSettings.Ports}}" container | jq

# 查看容器的网络ip、网关等信息
docker inspect --format="{{json .NetworkSettings.Networks}}" container | jq
```