---
title: Docker-inspect小技巧
tags:
  - posts
categories:
  - Docker
series: 
  - 
lastmod: '2021-06-07'
featuredImage: 
authors: songjinfeng
draft: true
toc: true


---

<!--more-->

## inspect基础

一般查看Docker容器IP会先找到容器ID或名字，再用 inspect进行查询

```
docker ps
docker inspect 容器ID 
```

>通常会加上`| grep -C 15 IPAddress/Port/Name...`来缩小查询范围
>
>grep参数：
>-A显示匹配后和它后面的n行。（After，之后）
>-B显示匹配行和它前面的n行。（Before，之前）
>-C匹配行和它前后各n行。（Context，上下文）

通过inspact内容可以看到如下字段:

**容器名称**：

```
{{.Name}}
```

**IP地址：**

```
{{.NetworkSettings.IPAddress}}
{{.NetworkSettings.Networks.bridge.IPAddress}}
```

**端口**：

```
{{.HostConfig.PortBindings}}
{{.NetworkSettings.Ports}}
```

## inspect批量查询技巧

在得知如上相关字段后我们可以通过 `inspect -f/--format`来精确查找

综上，我们可以写出以下脚本列出所有容器对应的名称，端口，及ip

```
docker inspect -f='{{.Name}}  |  {{.NetworkSettings.IPAddress}}  |  {{.NetworkSettings.Ports}}' $(docker ps -aq)

```

>inspect --format 也可以指定range ... end，例如：
>
>```
>docker inspect --format='{{.Name}} - {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
>```

