---
title: FAQ
---
https://developers.redhat.com/blog/2019/03/18/rpm-packaging-guide-creating-rpm

sudo yum --disablerepo="*" --enablerepo="仓库名称"

## 一、问题：

yum安装时提示：
This system is not registered with an entitlement server. You can use subscription-manager to register.


## 二、原因：

该错误提示意味着系统未注册到Red Hat订阅服务中心，因此无法使用yum更新。这可能会影响您的系统安全和稳定性，因为没有及时更新软件包可能会导致漏洞和错误得不到修复。Red Hat Subscription Manager订阅管理器，它会让你一直register


建议您使用subscription-manager工具进行注册以解决此问题。
或者禁用。
脚本文件: /usr/lib/yum-plugins/subscription-manager.py
配置文件: /etc/yum/pluginconf.d/subscription-manager.conf
调用了脚本 /usr/share/rhsm/repolib.py
去重写或者更新/etc/yum.repos.d/redhat.repo文件。
每次yum调用(不禁掉plugins的情况下)，都会更新此文件。

## 三、解决1：禁用

停止掉该插件的使用，在配置文件中把enable=0即可。
```
[root@localhost ~]# vim /etc/yum/pluginconf.d/subscription-manager.conf

[main]
enabled=0           #将它禁用掉
```


## 四、解决2：安装subscription-manager工具


您可以按照以下步骤解决此问题：
1.安装subscription-manager工具：

sudo yum install subscription-manage
2.注册系统：

sudo subscription-manager register
这将提示您输入Red Hat订阅服务中心的用户名和密码以注册您的系统。
启用系统订阅：

sudo subscription-manager attach --auto
这将自动为您分配可用于您的系统的最新订阅。
更新系统软件包：

sudo yum update

## yum 安装软件包遇到`cpio:rename` 报错

```bash
error:unpacking of archive failed on file /usr/1ib64/python2.7/site-packages/PyYAML-3.10-py2.7.egg-info:cpio:rename
Verifying PyYAML-3.10-11.el7.x86_64
```

先用 `lsattr <path>` 看一下 报错目录是否加锁，若存在加锁则 `chattr -i <path>`。

如果目录不存在加锁则可能为如下原因：

Linux RPM 执行升级。升级会找到一个目录（在本例中为/usr/1ib64/python2.7/site-packages/PyYAML-3.10-py2.7.egg-info），它期望在其中找到并替换/更新文件（具有相同的名称）。这个问题Linux下使用RPM包管理器升级软件的不幸结果。

将现有目录重命名为升级脚本未使用的名称 `mv /usr/1ib64/python2.7/site-packages/PyYAML-3.10-py2.7.egg-info /usr/1ib64/python2.7/site-packages/PyYAML-3.10-py2.7.egg-info.old`

参考文档：https://www.veritas.com/support/en_US/article.100010457

## yum 指定 repo
以下命令将启用名为 base 的 repo 源，并禁用其他所有 repo 源：

```bash
sudo yum --disablerepo=* --enablerepo=base update
```

## yum 指定 软件包版本

使用 -I 或 --include 选项可以确保只安装指定版本的软件包，而不是安装最新版本。
```bash
sudo yum install -I nginx-1.18.0-1.el7.ngx.x86_64
```

## yum localinstall
使用 yum 安装 RPM 包时，可以使用 --nogpgcheck 选项来跳过 GPG 密钥检查，使用 --skip-broken 选项来跳过损坏的软件包，使用 --exclude 选项来排除一些软件包，并使用 --enablerepo 和 --disablerepo 选项来启用或禁用特定的 Yum 软件库。


如果您遇到缺少依赖关系的问题，可以尝试使用 yum 的 localinstall 命令，它会自动解决依赖关系并安装所需的软件包。

```bash 
sudo yum localinstall package.rpm

```