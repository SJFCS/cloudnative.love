---
title: FAQ
---
https://developers.redhat.com/blog/2019/03/18/rpm-packaging-guide-creating-rpm

sudo yum --disablerepo="*" --enablerepo="仓库名称"



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