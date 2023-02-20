---
title: CURL基础用法

categories:
  - Linux基础命令
series: 
  - 
lastmod: '2020-04-17'

featuredImage: 
authors: songjinfeng
draft: false
toc: true

---



## 前言

有时候shell脚本可以放在http页面上，不用download，可以直接执行。

通常我们可以用curl的方式执行http页面上的shell脚本。 一般方式是：

```
curl http://XXX.com/xx/xx.sh | bash
```

这样脚本就可以在本地机器上执行了。

## 带参

有时也有需要传入参数的脚本。分为无名参数和具名参数（长选项和短选项）。

### 无名参

`-s`方式

```
curl -s http://XXX.com/xx/xx.sh | bash -s arg1 arg2
```

`bash <`方式

```
bash <(curl -s http://XXX.com/xx/xx.sh) arg1 arg2
```

### 具名参数

由于直接调用了bash命令，因此在远程脚本需要传递具名参数时，为了区分是bash命令的参数还是远程脚本的，可以使用--作为区分，可以理解为分割线，--前面的比如-s属于bash，后面的-x abc -y xyz属于远程脚本的参数

```
curl -L http://XXX.com/xx/xx.sh | bash -s -- -x abc -y xyz
```

参考

> [passing parameters to bash when executing a script fetched by curl](https://stackoverflow.com/questions/4642915/passing-parameters-to-bash-when-executing-a-script-fetched-by-curl/4642975)