---
title: Linux Security
sidebar_position: 6
hide_table_of_contents: true
tags: [Linux,Security]
---

[linux kernel cves](https://www.linuxkernelcves.com/cves)

:::tip
网络和安全是密不可分的，归类只是为了方便管理和组织知识，实际应用中两者往往是相互影响、相互支持的。因
:::

- [How To Secure A Linux Server (如何保护 Linux 服务器)](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server)
- [The Practical Linux Hardening Guide (实用 Linux 加固指南)](https://github.com/trimstray/the-practical-linux-hardening-guide)
  
### 4. 打开防火墙，只开启需要使用的端口

旧版的 linux 基本都使用 iptables 做防火墙，但是它配置特别麻烦。而新版的 linux 发行版都提供了对 `iptables` 更高层的封装，简化上手难度：

1. ubuntu 使用 ufw
2. centos 使用 firewall

**注意**：Docker 的端口映射，ufw 和 firewall 都管不到！这涉及到底层的 iptables 原理，建议网上搜索。。。
总之不要试图通过 ufw/firewall/iptables 去简单地禁用 Docker 映射的端口，没有用的。

#### 4.1 ufw

```bash
$ sudo apt-get install -y ufw  # 新版 ubuntu 自带
$ sudo ufw default deny  # 默认禁用端口
$ sudo ufw allow ssh   # 允许 ssh，这使用了 /etc/services 内的配置，该配置中 ssh 对应端口 22
$ sudo ufw allow http  # /etc/services 中 http 对应 80 端口
$ sudo ufw allow 443/tcp  # 允许 443 的 tcp 连接
$ sudo ufw --force enable  # 开启防火墙
$ sudo ufw status verbose
```

现在只开启了 22 80 和 443 端口，其他所有端口都会被禁用。

#### 4.2 firewall

```bash
systemctl start  firewalld # 启动
systemctl status firewalld # 或者 firewall-cmd --state 查看状态
systemctl disable firewalld # 停止
systemctl stop firewalld  # 禁用

# 显示服务列表  
## Amanda, FTP, Samba和TFTP等最重要的服务已经被FirewallD提供相应的服务，可以使用如下命令查看：
firewall-cmd --get-services

# 允许SSH服务通过
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent

# 禁止SSH服务通过
firewall-cmd --zone=public --remove-port=22/tcp --permanent

sudo firewall-cmd --zone=public --add-port=6379/tcp --permanent

# 修改防火墙规则后需要重载配置
sudo firewall-cmd --reload
```

## 注意事项

1. **上述操作防不了 docker 的端口映射！！！**因为 docker 端口映射的 iptables 链，和防火墙的 iptables 链层级相同！
1. 客户端的公钥文件，权限必须是 600，即仅 owner 可读写。
    - 如果客户端是 windows，必须在公钥文件的「属性」-「安全」中删除掉所有的用户（可能还需要先在「高级」中禁用权限「继承」），只保留自己的读写权限！

# 一般性建议

# CentOS7增加系统安全性

[[toc]]

为了给CentOS7系统增加系统的安全性，防止系统被黑，可以进行以下操作：

- 修改用户密码为高强度密码
- 创建`sudo`用户
- 修改`SSH`的默认`22`端口
- 禁用`root`账号远程登陆
- 使用ssh秘钥登陆并禁用密码登陆
- 安装`DenyHosts`防暴力破解软件
- 安装`ClamAV`反病毒软件
自动产生密码的软件`pygen`

### 1.2 生成20个超级难记的密码

```sh
[root@hellogitlab ~]# pwgen -cnys 14 20
T@N0PgKw)m4-ia %a3Oz\-+r170{x bPs9J84p%^nz/. mt9Ul_i'@kNOVW Yx'M7;xGZ)f.Id
T},u2]B1#s1Ob) iE6nkE_.()*$bQ 5:{8G,9OOaJ/!- /f0%Toh.ccqzq] <fjxUZQ}4wHvsa
>kx8!qvlkRf(TX W:0?cYKhOQO0{o dA_'nKikzD>7S6 ]^1S@;tBoUXurJ X/fjTy'[2,Sw2u
8=@S+>Wx1i9$yh |1Y^R4W5cgEb:E -OYSF0nS7zv/;q W=G;vt~Wzzr1F" tJD8OTl,2z13EL
```

我们使用`passwd`命令可以修改自己的密码：

```sh
[root@hellogitlab ~]# passwd
Changing password for user root.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
```

或者使用下面这种方式修改密码：

```sh
[root@hellogitlab ~]# export HISTCONTROL=ignorespace
[root@hellogitlab ~]#  echo "tJD8OTl,2z13EL" |passwd root --stdin
Changing password for user root.
passwd: all authentication tokens updated successfully.
[root@hellogitlab ~]# history |tail -n 2
  689  2019-10-31 22:36:19 export HISTCONTROL=ignorespace 
  690  2019-10-31 22:36:43 history |tail -n 2
```

上面操作进行了以下事情：
- 通过`export HISTCONTROL=ignorespace`设置`history`不记录敏感命令，即命令以空格开头时不会被记录到`history`历史记录中。
- 通过`echo "tJD8OTl,2z13EL" |passwd root --stdin`设置`root`用户密码,`--stdin`表明从标准输入中读入密码信息。
- `history |tail -n 2`查看历史记录，可以看到`echo "tJD8OTl,2z13EL" |passwd root --stdin`这条命令没有被记录。

## 2. 创建`sudo`用户

### 2.1 创建用户

新建普通用户"meizhaohui"

```sh
[root@hellogitlab ~]# useradd meizhaohui
```

### 2.1 设置密码

输入两次密码：

```sh
[root@hellogitlab ~]# passwd meizhaohui
Changing password for user meizhaohui.
New password: 
Retype new password: 
Sorry, passwords do not match.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
```

### 2.2 修改授权文件

- 查看授权文件位置

```sh
[root@hellogitlab ~]# whereis sudoers
sudoers: /etc/sudoers.d /etc/sudoers /usr/share/man/man5/sudoers.5.gz
```

- 给授权文件`/etc/sudoers`增加写(w)权限

```sh
[root@hellogitlab ~]# ls -lah /etc/sudoers
-r--r-----. 1 root root 4.3K Oct 30  2018 /etc/sudoers
[root@hellogitlab ~]# chmod -v u+w /etc/sudoers
mode of ‘/etc/sudoers’ changed from 0440 (r--r-----) to 0640 (rw-r-----)
[root@hellogitlab ~]# ls -lah /etc/sudoers
-rw-r-----. 1 root root 4.3K Oct 30  2018 /etc/sudoers
```

- 在授权文件`/etc/sudoers`中增加`sudo`用户"meizhaohui"

```sh
[root@hellogitlab ~]# sed -n '99,100p' /etc/sudoers
## Allow root to run any commands anywhere 
root    ALL=(ALL)       ALL

# 在第100行的下一行增加以下内容
meizhaohui    ALL=(ALL)       ALL

# 再次查看内容
[root@hellogitlab ~]# sed -n '99,101p' /etc/sudoers
## Allow root to run any commands anywhere 
root    ALL=(ALL)       ALL
meizhaohui      ALL=(ALL)       ALL
```
- 将授权文件的权限还原

```sh
[root@hellogitlab ~]# chmod -v u-w /etc/sudoers
mode of ‘/etc/sudoers’ changed from 0640 (rw-r-----) to 0440 (r--r-----)
[root@hellogitlab ~]# ls -lah /etc/sudoers
-r--r----- 1 root root 4.3K Oct 31 21:17 /etc/sudoers
```

### 2.3 测试`sudo`用户是否具备`sudo`权限

- 使用"meizhaohui"账号登陆系统，并尝试查看`/etc/sudoers`文件内容

```sh
[meizhaohui@hellogitlab ~]$ cat /etc/sudoers     
cat: /etc/sudoers: Permission denied
[meizhaohui@hellogitlab ~]$ head /etc/sudoers
head: cannot open ‘/etc/sudoers’ for reading: Permission denied
[meizhaohui@hellogitlab ~]$ sudo head /etc/sudoers
[sudo] password for meizhaohui: 
## Sudoers allows particular users to run various commands as
## the root user, without needing the root password.
##
## Examples are provided at the bottom of the file for collections
## of related commands, which can then be delegated out to particular
## users or groups.
## 
## This file must be edited with the 'visudo' command.

## Host Aliases
```

可以发现，不使用`sudo`命令时，无法查看文件内容，显示"`Permission denied`"，表明没有权限；使用`sudo`命令时，可以查看文件内容。说明`sudo`用户配置正确。

## 3. 修改`ssh`默认端口

- `SSH`是建立在应用层和传输层基础上的一种安全协议。`SSH`传输数据是加密的，可以有效防止传输过程被截取数据保障安全。
- `SSH`默认端口值是`22`，最大可以是`65535`。
- 为防止暴力破解，可以修改SSH端口号为非`22`，如`10000`。

下面我们将SSH的端口号改成`10000`：

- 查看配置文件`/etc/ssh/sshd_config`的默认端口

```sh
[root@hellogitlab ~]# grep -n 'Port 22' /etc/ssh/sshd_config
17:#Port 22
```

可以发现17行中显示端口号是`22`。

### 3.1 修改端口号

```sh
[root@hellogitlab ~]# sed -i 's/#Port 22/Port 10000/g' /etc/ssh/sshd_config
[root@hellogitlab ~]# sed -n '17p' /etc/ssh/sshd_config
Port 10000
```

### 3.2 重启`SSH`服务

```sh
[root@hellogitlab ~]# systemctl restart sshd
[root@hellogitlab ~]# systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-10-31 21:40:38 CST; 7s ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 27570 (sshd)
   CGroup: /system.slice/sshd.service
           └─27570 /usr/sbin/sshd -D

Oct 31 21:40:38 hellogitlab.com systemd[1]: Stopped OpenSSH server daemon.
Oct 31 21:40:38 hellogitlab.com systemd[1]: Starting OpenSSH server daemon...
Oct 31 21:40:38 hellogitlab.com sshd[27570]: Server listening on 0.0.0.0 port 10000.
Oct 31 21:40:38 hellogitlab.com systemd[1]: Started OpenSSH server daemon.
Oct 31 21:40:39 hellogitlab.com sshd[27561]: Failed password for root from 106.54.19.58 port 54334 ssh2
Oct 31 21:40:39 hellogitlab.com sshd[27561]: Connection closed by 106.54.19.58 port 54334 [preauth]
[root@hellogitlab ~]# netstat -tunlp|grep ssh
tcp        0      0 0.0.0.0:10000           0.0.0.0:*               LISTEN      27570/sshd
```

可以发现`SSH`服务在端口号已经变成`10000`了。

### 3.3 防火墙放行`10000`端口

- 查看当前防火墙放行规则信息

```sh
[root@hellogitlab ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-10-31 10:58:06 CST; 10h ago
     Docs: man:firewalld(1)
 Main PID: 25023 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─25023 /usr/bin/python -Es /usr/sbin/firewalld --nofork --nopid

Oct 31 10:58:06 hellogitlab.com systemd[1]: Starting firewalld - dynamic firewall daemon...
Oct 31 10:58:06 hellogitlab.com systemd[1]: Started firewalld - dynamic firewall daemon.

[root@hellogitlab ~]# firewall-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: ssh dhcpv6-client
  ports: 90/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

可以看到默认是放行`ssh`服务的。

为防止不必要的麻烦，我们还是手动将`10000`端口放行。

```sh
[root@hellogitlab ~]# firewall-cmd --zone=public --add-port=10000/tcp --permanent
success
[root@hellogitlab ~]# firewall-cmd --reload
success
[root@hellogitlab ~]# firewall-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: ssh dhcpv6-client
  ports: 90/tcp 10000/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

退出SecureCRT远程连接。

### 验证`SSH`端口是否修改成功

- 尝试使用`22`端口和`10000`端口连接服务器。
- 使用`22`端口连接时提示`The remote system refused the connection.`异常。
- 使用`10000`端口连接时，可以正常连接到服务器，说明配置正确。





## 4.  禁用`root`账户远程登陆

- 查看用户手册

```sh
[root@hellogitlab ~]# man sshd_config
# 可以看到以下内容
PermitRootLogin
         Specifies whether root can log in using ssh(1).  The argument must be yes, prohibit-password,
         without-password, forced-commands-only, or no.  The default is yes.

         If this option is set to prohibit-password or without-password, password and keyboard-interactive
         authentication are disabled for root.

         If this option is set to forced-commands-only, root login with public key authentication will be
         allowed, but only if the command option has been specified (which may be useful for taking remote back‐
         ups even if root login is normally not allowed).  All other authentication methods are disabled for
         root.

         If this option is set to no, root is not allowed to log in.
```

`If this option is set to no, root is not allowed to log in.`意思是指如果将"`PermitRootLogin`"配置项设置为"`no`"的话，则不允许`root`账号远程登陆。

下面我们来修改配置文件`/etc/ssh/sshd_config`中"`PermitRootLogin`"配置项的值

- 修改配置文件`/etc/ssh/sshd_config`

```sh
[root@hellogitlab ~]# grep 'PermitRootLogin' /etc/ssh/sshd_config
#PermitRootLogin yes
# the setting of "PermitRootLogin without-password".
[root@hellogitlab ~]# sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
[root@hellogitlab ~]# grep 'PermitRootLogin' /etc/ssh/sshd_config
PermitRootLogin no
# the setting of "PermitRootLogin without-password".
```

可以发现配置文件修改成功。

- 重启`SSH`服务并退出`root`账号远程连接

```sh
[root@hellogitlab ~]# systemctl restart sshd
[root@hellogitlab ~]# systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-10-31 22:04:51 CST; 5s ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 32055 (sshd)
   CGroup: /system.slice/sshd.service
           └─32055 /usr/sbin/sshd -D

Oct 31 22:04:51 hellogitlab.com systemd[1]: Stopped OpenSSH server daemon.
Oct 31 22:04:51 hellogitlab.com systemd[1]: Starting OpenSSH server daemon...
Oct 31 22:04:51 hellogitlab.com sshd[32055]: Server listening on 0.0.0.0 port 10000.
Oct 31 22:04:51 hellogitlab.com systemd[1]: Started OpenSSH server daemon.
[root@hellogitlab ~]# exit
logout
```


- 测试使用`root`账号远程连接

再次使用`root`账号远程连接时，提示`password authentication failed`

登陆`sudo`账号，并尝试切换到`root`账号里：

```sh
[meizhaohui@hellogitlab ~]$ ssh root@106.54.98.83
ssh: connect to host 106.54.98.83 port 22: Connection refused
[meizhaohui@hellogitlab ~]$ ssh root@106.54.98.83 -D 10000
ssh: connect to host 106.54.98.83 port 22: Connection refused
[meizhaohui@hellogitlab ~]$ ssh root@106.54.98.83 -p 10000
The authenticity of host '[106.54.98.83]:10000 ([106.54.98.83]:10000)' can't be established.
ECDSA key fingerprint is SHA256:Ow0AsLnlUQJg/SzRNgYG7x8HmYQPZ9ubGUpJoYRRuKk.
ECDSA key fingerprint is MD5:ec:9f:dc:43:1c:02:15:91:21:ee:a0:cb:77:bc:dd:dd.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[106.54.98.83]:10000' (ECDSA) to the list of known hosts.
root@106.54.98.83's password: 
Permission denied, please try again.
root@106.54.98.83's password: 
Permission denied, please try again.
root@106.54.98.83's password: 

[meizhaohui@hellogitlab ~]$ ^C
[meizhaohui@hellogitlab ~]$ su root
Password: 
[root@hellogitlab meizhaohui]# whoami
root
[root@hellogitlab meizhaohui]# exit
exit
[meizhaohui@hellogitlab ~]$ sudo ls /root
[sudo] password for meizhaohui: 
data
[meizhaohui@hellogitlab ~]$ 
```

- 可以看到`22`端口不能访问，并且不能使用`ssh root@106.54.98.83 -p 10000`方式连接到服务器。
- 可以看到可以能`su root`命令切换到`root`账号里，同时也可以使用`sudo ls /root`来执行一些需要使用`root`账号才能完成的事情。说明我们的配置正确。

## 5. 使用密钥登陆并禁止密码登陆

我们通过采用SSH密钥登陆，并且禁止密码登陆，可以有效防止服务器密码被暴力破解。只将自己信任的机器的公钥复制到服务器上，然后只有信任的机器才远程连接上服务器。

首先，在自己的本地电脑上面生成SSH公钥和私钥对。可以使用`ssh-keygen -C comment`方式生成公钥和密码文件。一般在家目录下的`.ssh`目录下：

```sh
$ ls -lah ~/.ssh/id_rsa*
-rw-------  1 mzh  staff   1.8K  3 27  2020 /Users/mzh/.ssh/id_rsa
-rw-r--r--  1 mzh  staff   398B  3 27  2020 /Users/mzh/.ssh/id_rsa.pub
$
```

`id_rsa`是私钥文件，自己保存好，不要让别人知道。`id_rsa.pub`是公钥文件。



可以使用`ssh-copy-id`命令将公钥文件复制到服务器端：

```sh
# 查看ssh-copy-id的帮助信息
$ ssh-copy-id -h
Usage: /usr/bin/ssh-copy-id [-h|-?|-f|-n|-s] [-i [identity_file]] [-p port] [-F alternative ssh_config file] [[-o <ssh -o options>] ...] [user@]hostname
	-f: force mode -- copy keys without trying to check if they are already installed
	-n: dry run    -- no keys are actually copied
	-s: use sftp   -- use sftp instead of executing remote-commands. Can be useful if the remote only allows sftp
	-h|-?: print this help
$
```

如可执行以下命令：

```sh
$ ssh-copy-id -p 10000 meizhaohui@hellogitlab.com
```

复制过程中，需要输入账号[meizhaohui]在服务器上面对应的密码。

复制成功后，你的公钥信息就会加入到服务器端的对应用户的`.ssh/authorized_keys`文件中：

```sh
[meizhaohui@hellogitlab ~]$ ll ~/.ssh/authorized_keys
-rw------- 1 meizhaohui meizhaohui 398 Mar 24 22:07 /home/meizhaohui/.ssh/authorized_keys
```

此时，就可以通过类似`ssh meizhaohui@hellogitlab.com -p 10000`免密远程连接到服务器。



能够免密登陆后，我们再设置SSH的配置，修改为使用密钥登陆和禁止密码登陆。

```sh
# 查看sshd配置的手册页，其中可以看到以下两项
# PubkeyAuthentication 允许公钥认证，默认是yes允许
# PasswordAuthentication 允许密码认证，默认是yes允许
$ man sshd_config
PubkeyAuthentication
             Specifies whether public key authentication is allowed.  The default is yes.
PasswordAuthentication
             Specifies whether password authentication is allowed.  The default is yes.
```

使用vim修改`/etc/ssh/sshd_config`配置文件，修改后查看：

```sh
[meizhaohui@hellogitlab ~]$ sudo grep -n 'PubkeyAuthentication' /etc/ssh/sshd_config
44:#PubkeyAuthentication yes
45:PubkeyAuthentication yes
[meizhaohui@hellogitlab ~]$ sudo grep -n 'PasswordAuthentication' /etc/ssh/sshd_config
65:#PasswordAuthentication yes
67:PasswordAuthentication no
90:# PasswordAuthentication.  Depending on your PAM configuration,
94:# PAM authentication, then enable this but set PasswordAuthentication
```

注意45行的`PubkeyAuthentication yes`和67行的`PasswordAuthentication no`，这两个配置即说明，允许公钥认证，不允许密码认证。

配置完成后，重启`sshd`服务：

```sh
[meizhaohui@hellogitlab ~]$ sudo systemctl restart sshd
```

重启后，查看`sshd`服务状态：

```sh
[meizhaohui@hellogitlab ~]$ sudo systemctl status sshd
```






## 6. 安装`DenyHosts`防暴力破解软件

denyhosts官方地址：[https://github.com/denyhosts/denyhosts](https://github.com/denyhosts/denyhosts)

推荐使用3.0版本，下载地址：[https://github.com/denyhosts/denyhosts/archive/refs/tags/v3.0.tar.gz](https://github.com/denyhosts/denyhosts/archive/refs/tags/v3.0.tar.gz)

> What is DenyHosts?
>
> DenyHosts is a script intended to be run by Linux system administrators to help  thwart SSH server attacks (also known as dictionary based attacks and brute force  attacks).
>
> If you've ever looked at your ssh log (/var/log/secure on Redhat, /var/log/auth.log on Mandrake, etc...) you may be  alarmed to see how many hackers attempted to gain access to your server.  Hopefully, none of them were successful (but  then again, how would you know?).  Wouldn't it be better to automatically prevent that attacker from continuing to gain  entry into your system?

DenyHosts用于SSH防暴力破解。当远程用户多次登陆失败时，用户的IP将会被加入到黑名单中，不允许再次登陆。只有将该IP从黑名单移除后才能再次登陆。

可直接参考官网说明进行安装配置。

此处编写一个自动安装脚本。


```sh
[mzh@MacBookPro docs (master ✗)]$ cat .vuepress/public/scripts/shell/init_denyhosts.sh 
#!/bin/bash
##################################################
#      Filename: init_denyhosts.sh
#        Author: Zhaohui Mei<mzh.whut@gmail.com>
#   Description: init the denyhosts service. 
#   Create Time: 2022-05-14 22:14:32
# Last Modified: 2022-05-14 23:18:39
##################################################


pushd /tmp || exit 1
echo "Step 1: Download install package"
wget --no-check-certificate https://udomain.dl.sourceforge.net/project/denyhosts/denyhosts/3.0/denyhosts-3.0.tar.gz
echo "Step 2: Extract the package"
tar -zxvf denyhosts-3.0.tar.gz
cd denyhosts-3.0 || exit 1
echo "Step 3: Install"
python setup.py install
echo "Step 4: Copy configuration file"
cp denyhosts.conf /etc
echo "Step 5: Change the configuration file"
sed -i 's@SECURE_LOG = /var/log/auth.log@#SECURE_LOG = /var/log/auth.log@g' /etc/denyhosts.conf
sed -i 's@#SECURE_LOG = /var/log/secure@SECURE_LOG = /var/log/secure@g' /etc/denyhosts.conf
sed -i 's@LOCK_FILE = /var/run/denyhosts.pid@#LOCK_FILE = /var/run/denyhosts.pid@g' /etc/denyhosts.conf
sed -i 's@#LOCK_FILE = /var/lock/subsys/denyhosts@LOCK_FILE = /var/lock/subsys/denyhosts@g' /etc/denyhosts.conf
sed -i 's@# from types import ListType, TupleType@from types import ListType, TupleType@g' /usr/lib/python2.7/site-packages/DenyHosts/report.py
echo "Step 6: Set the service"
cp denyhosts.service /usr/lib/systemd/system/denyhosts.service
sed -i 's@/var/run/denyhosts.pid@/var/lock/subsys/denyhosts@g' /usr/lib/systemd/system/denyhosts.service
echo "Step 7: Start the denyhosts service"
systemctl daemon-reload
systemctl enable denyhosts.service
systemctl start denyhosts.service
echo "Done!!"

```



## 7. 安装`ClamAV`反病毒软件

> ClamAV® is an open source antivirus engine for detecting trojans, viruses, malware & other malicious threats.

CLAMAV是一种开源防病毒引擎，用于检测特洛伊木马，病毒，恶意软件和其他恶意威胁。 

![](http://www.clamav.net/assets/clamav-trademark.png)

- 官网地址：[http://www.clamav.net/](http://www.clamav.net/)
- 官方文档: [ClamAV Documentation](https://docs.clamav.net/)

### 7.1 安装

参考： [https://docs.clamav.net/manual/Installing.html](https://docs.clamav.net/manual/Installing.html)

可通过包管理器或源码安装。

源码安装相对复杂一些，可参考：[https://docs.clamav.net/manual/Installing/Installing-from-source-Unix.html](https://docs.clamav.net/manual/Installing/Installing-from-source-Unix.html)


### 7.2 使用

- 更新病毒库

```sh
[root@hellogitlab ~]# freshclam
ClamAV update process started at Fri Aug 20 23:21:39 2021
daily database available for download (remote version: 26269)
Time:   10.7s, ETA:   38.4s [====>                    ]   12.00MiB/55.22MiB
Time:   30.3s, ETA:    0.0s [========================>]   55.22MiB/55.22MiB
Testing database: '/var/lib/clamav/tmp.07de6b0bad/clamav-6a2608999d639b39558087d28ded667f.tmp-daily.cvd' ...
Database test passed.
daily.cvd updated (version: 26269, sigs: 1967405, f-level: 90, builder: raynman)
main database available for download (remote version: 61)
Time:  1m 05s, ETA:    0.0s [========================>]  160.41MiB/160.41MiB
Testing database: '/var/lib/clamav/tmp.07de6b0bad/clamav-3f9cc58837e16915466a24d5fac1961d.tmp-main.cvd' ...
Database test passed.
main.cvd updated (version: 61, sigs: 6607162, f-level: 90, builder: sigmgr)
bytecode database available for download (remote version: 333)
Time:    1.9s, ETA:    0.0s [========================>]  286.79KiB/286.79KiB
Testing database: '/var/lib/clamav/tmp.07de6b0bad/clamav-4bfe995f07c6571aeb6432221988a6d2.tmp-bytecode.cvd' ...
Database test passed.
bytecode.cvd updated (version: 333, sigs: 92, f-level: 63, builder: awillia2)
```

下载完成后，可以发现在`/var/lib/clamav/`目录下多了病毒库文件。

```sh
[root@hellogitlab ~]# ls -lh /var/lib/clamav/
total 216M
-rw-r--r-- 1 clamupdate clamupdate 287K Aug 20 23:23 bytecode.cvd
-rw-r--r-- 1 clamupdate clamupdate  56M Aug 20 23:22 daily.cvd
-rw-r--r-- 1 clamupdate clamupdate   69 Aug 20 23:21 freshclam.dat
-rw-r--r-- 1 clamupdate clamupdate 161M Aug 20 23:23 main.cvd
```

- 设置本地socket文件

去掉`#LocalSocket /run/clamd.scan/clamd.sock`行的`#`:

```sh
# 尝试修改配置文件
[root@hellogitlab ~]# sed -n "s@#LocalSocket /run/clamd.scan/clamd.sock@LocalSocket /run/clamd.scan/clamd.sock@gp" /etc/clamd.d/scan.conf

# 直接在配置文件中修改，并生成配置文件
LocalSocket /run/clamd.scan/clamd.sock
[root@hellogitlab ~]# sed -i.bak "s@#LocalSocket /run/clamd.scan/clamd.sock@LocalSocket /run/clamd.scan/clamd.sock@g" /etc/clamd.d/scan.conf

# 查看文件
[root@hellogitlab ~]# ls -lh /etc/clamd.d/scan.conf*
-rw-r--r-- 1 root root 27K Aug 20 23:43 /etc/clamd.d/scan.conf
-rw-r--r-- 1 root root 27K Jun 29 22:26 /etc/clamd.d/scan.conf.bak

# 查看修改后的内容
[root@hellogitlab ~]# grep 'LocalSocket ' /etc/clamd.d/scan.conf
LocalSocket /run/clamd.scan/clamd.sock
```

- 查看clamscan的帮助信息

```sh
[root@hellogitlab ~]# clamscan -h

                       Clam AntiVirus: Scanner 0.103.3
           By The ClamAV Team: https://www.clamav.net/about.html#credits
           (C) 2021 Cisco Systems, Inc.

    clamscan [options] [file/directory/-]

    --help                -h             Show this help
    --version             -V             Print version number
    --verbose             -v             Be verbose
    --archive-verbose     -a             Show filenames inside scanned archives
    --debug                              Enable libclamav's debug messages
    --quiet                              Only output error messages
    --stdout                             Write to stdout instead of stderr. Does not affect 'debug' messages.
    --no-summary                         Disable summary at end of scanning
    --infected            -i             Only print infected files
    --suppress-ok-results -o             Skip printing OK files
    --bell                               Sound bell on virus detection

    --tempdir=DIRECTORY                  Create temporary files in DIRECTORY
    --leave-temps[=yes/no(*)]            Do not remove temporary files
    --gen-json[=yes/no(*)]               Generate JSON description of scanned file(s). JSON will be printed and also-
                                         dropped to the temp directory if --leave-temps is enabled.
    --database=FILE/DIR   -d FILE/DIR    Load virus database from FILE or load all supported db files from DIR
    --official-db-only[=yes/no(*)]       Only load official signatures
    --log=FILE            -l FILE        Save scan report to FILE
    --recursive[=yes/no(*)]  -r          Scan subdirectories recursively
    --allmatch[=yes/no(*)]   -z          Continue scanning within file after finding a match
    --cross-fs[=yes(*)/no]               Scan files and directories on other filesystems
    --follow-dir-symlinks[=0/1(*)/2]     Follow directory symlinks (0 = never, 1 = direct, 2 = always)
    --follow-file-symlinks[=0/1(*)/2]    Follow file symlinks (0 = never, 1 = direct, 2 = always)
    --file-list=FILE      -f FILE        Scan files from FILE
    --remove[=yes/no(*)]                 Remove infected files. Be careful!
    --move=DIRECTORY                     Move infected files into DIRECTORY
    --copy=DIRECTORY                     Copy infected files into DIRECTORY
    --exclude=REGEX                      Don't scan file names matching REGEX
    --exclude-dir=REGEX                  Don't scan directories matching REGEX
    --include=REGEX                      Only scan file names matching REGEX
    --include-dir=REGEX                  Only scan directories matching REGEX

    --bytecode[=yes(*)/no]               Load bytecode from the database
    --bytecode-unsigned[=yes/no(*)]      Load unsigned bytecode
                                         **Caution**: You should NEVER run bytecode signatures from untrusted sources.
                                         Doing so may result in arbitrary code execution.
    --bytecode-timeout=N                 Set bytecode timeout (in milliseconds)
    --statistics[=none(*)/bytecode/pcre] Collect and print execution statistics
    --detect-pua[=yes/no(*)]             Detect Possibly Unwanted Applications
    --exclude-pua=CAT                    Skip PUA sigs of category CAT
    --include-pua=CAT                    Load PUA sigs of category CAT
    --detect-structured[=yes/no(*)]      Detect structured data (SSN, Credit Card)
    --structured-ssn-format=X            SSN format (0=normal,1=stripped,2=both)
    --structured-ssn-count=N             Min SSN count to generate a detect
    --structured-cc-count=N              Min CC count to generate a detect
    --structured-cc-mode=X               CC mode (0=credit debit and private label, 1=credit cards only
    --scan-mail[=yes(*)/no]              Scan mail files
    --phishing-sigs[=yes(*)/no]          Enable email signature-based phishing detection
    --phishing-scan-urls[=yes(*)/no]     Enable URL signature-based phishing detection
    --heuristic-alerts[=yes(*)/no]       Heuristic alerts
    --heuristic-scan-precedence[=yes/no(*)] Stop scanning as soon as a heuristic match is found
    --normalize[=yes(*)/no]              Normalize html, script, and text files. Use normalize=no for yara compatibility
    --scan-pe[=yes(*)/no]                Scan PE files
    --scan-elf[=yes(*)/no]               Scan ELF files
    --scan-ole2[=yes(*)/no]              Scan OLE2 containers
    --scan-pdf[=yes(*)/no]               Scan PDF files
    --scan-swf[=yes(*)/no]               Scan SWF files
    --scan-html[=yes(*)/no]              Scan HTML files
    --scan-xmldocs[=yes(*)/no]           Scan xml-based document files
    --scan-hwp3[=yes(*)/no]              Scan HWP3 files
    --scan-archive[=yes(*)/no]           Scan archive files (supported by libclamav)
    --alert-broken[=yes/no(*)]           Alert on broken executable files (PE & ELF)
    --alert-broken-media[=yes/no(*)]     Alert on broken graphics files (JPEG, TIFF, PNG, GIF)
    --alert-encrypted[=yes/no(*)]        Alert on encrypted archives and documents
    --alert-encrypted-archive[=yes/no(*)] Alert on encrypted archives
    --alert-encrypted-doc[=yes/no(*)]    Alert on encrypted documents
    --alert-macros[=yes/no(*)]           Alert on OLE2 files containing VBA macros
    --alert-exceeds-max[=yes/no(*)]      Alert on files that exceed max file size, max scan size, or max recursion limit
    --alert-phishing-ssl[=yes/no(*)]     Alert on emails containing SSL mismatches in URLs
    --alert-phishing-cloak[=yes/no(*)]   Alert on emails containing cloaked URLs
    --alert-partition-intersection[=yes/no(*)] Alert on raw DMG image files containing partition intersections
    --nocerts                            Disable authenticode certificate chain verification in PE files
    --dumpcerts                          Dump authenticode certificate chain in PE files

    --max-scantime=#n                    Scan time longer than this will be skipped and assumed clean (milliseconds)
    --max-filesize=#n                    Files larger than this will be skipped and assumed clean
    --max-scansize=#n                    The maximum amount of data to scan for each container file (**)
    --max-files=#n                       The maximum number of files to scan for each container file (**)
    --max-recursion=#n                   Maximum archive recursion level for container file (**)
    --max-dir-recursion=#n               Maximum directory recursion level
    --max-embeddedpe=#n                  Maximum size file to check for embedded PE
    --max-htmlnormalize=#n               Maximum size of HTML file to normalize
    --max-htmlnotags=#n                  Maximum size of normalized HTML file to scan
    --max-scriptnormalize=#n             Maximum size of script file to normalize
    --max-ziptypercg=#n                  Maximum size zip to type reanalyze
    --max-partitions=#n                  Maximum number of partitions in disk image to be scanned
    --max-iconspe=#n                     Maximum number of icons in PE file to be scanned
    --max-rechwp3=#n                     Maximum recursive calls to HWP3 parsing function
    --pcre-match-limit=#n                Maximum calls to the PCRE match function.
    --pcre-recmatch-limit=#n             Maximum recursive calls to the PCRE match function.
    --pcre-max-filesize=#n               Maximum size file to perform PCRE subsig matching.
    --disable-cache                      Disable caching and cache checks for hash sums of scanned files.

Pass in - as the filename for stdin.

(*) Default scan settings
(**) Certain files (e.g. documents, archives, etc.) may in turn contain other
   files inside. The above options ensure safe processing of this kind of data.

[root@hellogitlab ~]#
```

- 扫描

```sh
# 递归扫描文件夹，并只显示被感染的文件
[root@hellogitlab ~]# clamscan -r -i /tmp/vim

----------- SCAN SUMMARY -----------
Known viruses: 8559335
Engine version: 0.103.3
Scanned directories: 153
Scanned files: 3423
Infected files: 0
Data scanned: 149.69 MB
Data read: 83.79 MB (ratio 1.79:1)
Time: 57.454 sec (0 m 57 s)
Start Date: 2021:08:21 00:27:26
End Date:   2021:08:21 00:28:24
```

上面的扫描结果就是扫描报告，翻译一下就是这样的：

```
----------- 扫描报告 -----------
已知病毒数: 8559335
引擎版本: 0.103.3
扫描目录数: 153
扫描文件数: 3423
感染病毒数: 0
扫描数据: 149.69 MB
数据读取: 83.79 MB (ratio 1.79:1)
扫描用时: 57.454 sec (0 m 57 s)
开始时间: 2021:08:21 00:27:26
结束时间: 2021:08:21 00:28:24
```

重点扫描的文件夹:`/bin`、`/etc`、`/home`、`/usr`、`/var`等。

- 定时更新病毒库

```sh
[root@hellogitlab ~]# crontab -l
# 每天晚上11点进行文件扫描
# update clamAV database
0 23 * * * /usr/bin/freshclam --quiet
```



参考：

- [ClamAV](https://wiki.ubuntu.org.cn/ClamAV)
