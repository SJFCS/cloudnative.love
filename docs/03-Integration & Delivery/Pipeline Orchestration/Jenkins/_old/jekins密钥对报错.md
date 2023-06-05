---
title: Jekins配置密钥时报错：Failed to add SSH key. Message invalid privatekey(Jenkins 2.257)

categories:
  - CI/CD
series: 
  - 
lastmod: '2021-04-07'
featuredImage: 
authors: 转载
draft: false
toc: true
---

> 原文链接：[jenkins:配置密钥时报错的解决：Failed to add SSH key. Message invalid privatekey(Jenkins 2.257)](https://www.cnblogs.com/architectforest/p/13707244.html)



## 错误信息

```none
jenkins.plugins.publish_over.BapPublisherException: Failed to add SSH key. Message [invalid privatekey: [B@60373f7]
```

## 产生问题的原因

生成密钥的openssh的版本过高，jenkins不支持

```shell
[root@localhost ~]# ssh-keygen -t rsa
```

**查看所生成私钥的格式:**

```shell
[root@localhost ~]$ more .ssh/id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
…
```

密钥文件首行（jenkins 2.2.57 版本在检验密钥时还不支持这种格式）

```shell
-----BEGIN OPENSSH PRIVATE KEY——
```

## 解决方案

**指定格式生成密钥文件**

```shell
[root@localhost ~]# ssh-keygen -m PEM -t rsa -b 4096

# -m 参数指定密钥的格式，PEM是rsa之前使用的旧格式
# -b 指定密钥长度。对于RSA密钥，最小要求768位，默认是2048位。
```

**重新生成密钥文件**

```shell
[root@localhost ~]# more /root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEA44rzAenw3N7Tpjy5KXJpVia5oSTV/HrRg7d8PdCeJ3N1AiZU
...
```

**密钥首行（这样改动后可以通过jenkins对密钥格式的验证）**

```
-----BEGIN RSA PRIVATE KEY-----
```