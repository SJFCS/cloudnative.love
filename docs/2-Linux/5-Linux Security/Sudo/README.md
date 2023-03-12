---
title: Sudo
---

sudo 执行后 owner权限是谁

sudo mv 不修改文件所有者
sudo 是一个 setuid 程序，setuid 是一种特殊的文件属性，能让运行的可执行文件自动获得对应用户的身份，身份有两种，UID 和 GID。因为 sudo 具有 root 用户权限，所以也可以获得其它用户和组的权限。怎么指定用户请 RTFM plz


sudo -iu

install 