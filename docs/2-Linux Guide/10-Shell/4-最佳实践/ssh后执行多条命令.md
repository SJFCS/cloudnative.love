---
title: SSH连接服务器后执行多条命令

categories:
  - Shell
series: 
  - 
lastmod: '2020-07-22'

featuredImage: 
authors: zhuanzai
draft: false
toc: true
---


https://stackoverflow.com/a/4412338/4884227

大家平时有没有遇到自己连接云服务器，ssh 连接上去之后，发现自己的一些小工具用不了

例如go build无法使用 ，由于我们安装配置golang 环境的时候，是在文件`/etc/profile`中写了配置，因此需要`source` 一下`/etc/profile`

那么是否可以在ssh 连接上服务器的时候就可以立即自动执行这一类命令呢？

我们的智慧无穷无尽，小工具也是非常的多，今天来讲述一下`SSH连接服务器后执行`多条命令可以如何做

## 1 使用分号隔开

使用 分号 `;`来隔开命令

+ 附带1条命令

  ```bash
  ssh User@Host 'source /etc/profile'
  ```

+ 附带多条命令

  ```bash
  ssh User@Host 'source /etc/profile ; uptime'
  ```

## 2 使用管道符号隔开

使用管道`|`来隔开命令

+ 附带1条命令

  ```bash
  ssh User@Host 'source /etc/profile'
  ```

+ 附带多条命令

  ```bash
  ssh User@Host 'source /etc/profile | uptime'
  ```

## 3 使用写EOF的方式

同样适用于一条 / 多条命令

```bash
ssh User@Host /bin/bash << EOF
> ls -al
> source /etc/profile
> EOF
```

## 4 使用脚本的方式

使用脚本的方式花样就更多了，例如有一个脚本`myinit.sh`在`/home/admin/code/`下面

```
myinit.sh
#!/bin/bash

source /etc/profile
ls -al
```

远程连接服务器

```bash
ssh User@Host 'bash -s' < /home/admin/code/myinit.sh
```

