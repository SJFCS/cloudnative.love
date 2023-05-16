---
title: Sudo & Pbrun
---



配置方式不同：pbrun需要在系统中配置，以允许特定的用户或用户组在特定的主机上运行特定的命令或程序；而sudo的配置则是由管理员在sudoers文件中进行配置。


身份验证方式不同：pbrun需要提供目标用户的用户名和密码进行身份验证，而sudo则是通过当前用户的密码进行身份验证。


特权执行方式不同：pbrun切换到目标用户的身份后，执行的命令或程序也是在目标用户的环境中执行；而sudo则是在当前用户的环境中执行，只是在执行时以特权身份运行。




sudo 是一个 setuid 程序，setuid 是一种特殊的文件属性，能让运行的可执行文件自动获得对应用户的身份，身份有两种，UID 和 GID。因为 sudo 具有 root 用户权限，所以也可以获得其它用户和组的权限。怎么指定用户请 RTFM plz


sudo -iu

install 




[How To Create a Sudo User on CentOS](https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-centos-quickstart)

