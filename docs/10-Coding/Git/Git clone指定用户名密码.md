---
title: git clone 直接指定用户名密码
tags:
  - posts
categories:
  - CI/CD
series: 
  - Git
lastmod: '2020-08-11'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---

<!--more-->

git使用用户名密码clone的方式：

```
git clone http://username:password@remote
```

 例如：我的用户名是abc@com,密码是abc123456,git地址为git@xxx.com/www.git

```
git clone http://abc@qq.com:abc123456@git.xxx.com/www.git
```

 执行报错：

```
 fatal: unable to access 'http://abc@com:abc123456@git.xxx.com/www.git/':
  Couldn't resolve host 'qq.com:abc123456@git.xxx.com'
```

 报错原因是因为用户名包含了@符号，所以需求要把@转码一下

[url编码工具](http://tool.chinaz.com/tools/urlencode.aspx)

@符号转码后变成了%40，所以只需在clone时将username变为abc%40com即可，再次执行就ok了。

部分密码中也可能会有特殊字符，在拼接之前，可以对用户名和密码分别进行url编码操作。

参考： https://www.cnblogs.com/pqchao/p/6483143.html

