```
危险等级：中危

漏洞名称：OpenSSH 用户枚举漏洞(CVE-2018-15919)

详细描述：OpenSSH 7.8及之前版本，auth-gss2.c文件存在安全漏洞。远程攻击者可利用该漏洞检测其指定的用户是否存在。

解决办法：

厂商升级：新版本OpenSSH-7.9已经修复这个安全问题，请到厂商的主页下载。
链接：http://www.openssh.com/ http://www.openssh.com/portable.html
```

目标服务器是CentOS7.4，起初我以为万能的RPM包再加上 
`yum install --downloadonly --downloaddir=<directory> <package>`
 和 `yum localinstall <package>` 就能轻松搞定……但是……最新的RPM是7.4p1，不符合要求
```
[root@localhost ~]# yum info openssh
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.cqu.edu.cn
 * updates: mirrors.aliyun.com
Available Packages
Name        : openssh
Arch        : x86_64
Version     : 7.4p1
```

尝试源码编译

```bash
# 卸载7.4
yum uninstall openssh
# 安装编译所需的headers和libraries
yum install zlib-devel
yum install openssl-devel
yum install pam-devel
# 下载源码包
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.9p1.tar.gz
# 解压
tar zxvf openssh-7.9p1.tar.gz
# 切目录
cd openssh-7.9p1
# 配置
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam
# 编译
make
# 安装
make install
# 拷贝ssh-copy-id
install -v -m755 contrib/ssh-copy-id /usr/bin
# 拷贝帮助文件
install -v -m644 contrib/ssh-copy-id.1 /usr/share/man/man1
# 创建文档目录
install -v -m755 -d /usr/share/doc/openssh-7.9p1
# 拷贝文档
install -v -m644 INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-7.9p1
# 允许root登录（7.9改变了PermitRootLogin的默认值）
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# 使用PAM
echo "UserPAM yes" >> /etc/ssh/sshd_config
# 注册服务
cp -p contrib/redhat/sshd.init /etc/init.d/sshd
chmod +x /etc/init.d/sshd
# 加入sshd到chkconfig管理
chkconfig --add sshd
# 设置开机启动
chkconfig sshd on
# 检查启动项
chkconfig --list sshd
# 验证版本信息 
ssh -V
# 重启ssh服务
service sshd restart
```

可能遇到的错误和解决方法

在安装过程中我遇到过多个不同的错误，在总结这篇短文时，才发现那些都是弯路。

ssh连接时出错：error Could not get shadow information for <user>
服务启动成功，用户密码也都对，就是无法建立连接，可能是UsePAM和SELinux的问题。

客户端登录时，即便输入了正确的密码，仍然提示：
```bash
[user@localhost~]# ssh user@192.168.171.128     
user@192.168.171.128's password: 
Permission denied, please try again.
```
查看服务端日志(/var/log/messages)，发现：

```bash
error: Could not get shadow information for <user>
Failed password for <user> from <ip> port <port> ssh2
```
这可能是因为UsePAM没有启用，检查/etc/ssh/sshd_config：
```bash
# 检查UsePAM，确认是否启用了PAM
# UseAPM no
UsePAM yes
```
修改配置后，重启sshd服务后，服务恢复。如果编译时缺了--with-pam参数，UsePAM yes会让服务报错。

如果不想修改PAM选项，也可以关闭Selinux

UsePAM yes时，无论启用或禁用selinux，都不会引发Could not get shadow information错误。









sshd启动报错：Bad SSH2 cipher spec '...'

可能是升级了openssl但sshd_config配置未更新，或者配置有错，造成不一致。

可以查询当前被支持的加密方法：

```bash
[user@localhost ~]# ssh -Q cipher
3des-cbc
aes128-cbc
aes192-cbc
aes256-cbc
rijndael-cbc@lysator.liu.se
aes128-ctr
aes192-ctr
aes256-ctr
aes128-gcm@openssh.com
aes256-gcm@openssh.com
chacha20-poly1305@openssh.com
```
也可以用 `paste -s -d` ,直接将查询结果串接并写入配置文件：
```bash
echo 'Ciphers' `ssh -Q cipher | paste -d, -s` >> /etc/ssh/sshd_config
```


sshd启动报错：Bad SSH2 mac spec '...'
查询被支持的消息摘要算法：

```bash
[user@localhost ~]# ssh -Q mac
hmac-sha1
hmac-sha1-96
hmac-sha2-256
hmac-sha2-512
hmac-md5
hmac-md5-96
umac-64@openssh.com
umac-128@openssh.com
hmac-sha1-etm@openssh.com
hmac-sha1-96-etm@openssh.com
hmac-sha2-256-etm@openssh.com
hmac-sha2-512-etm@openssh.com
hmac-md5-etm@openssh.com
hmac-md5-96-etm@openssh.com
umac-64-etm@openssh.com
umac-128-etm@openssh.com
```

也可以用paste -s -d,直接将查询结果串接并写入配置文件：
```bash
echo 'MACs' `ssh -Q mac | paste -d, -s` >> /etc/ssh/sshd_config
```


sshd启动报错：Bad SSH2 KexAlgorithms '...'
查询支持的算法：
```bash
[user@localhost ~]# ssh -Q kex
diffie-hellman-group1-sha1
diffie-hellman-group14-sha1
diffie-hellman-group14-sha256
diffie-hellman-group16-sha512
diffie-hellman-group18-sha512
diffie-hellman-group-exchange-sha1
diffie-hellman-group-exchange-sha256
ecdh-sha2-nistp256
ecdh-sha2-nistp384
ecdh-sha2-nistp521
curve25519-sha256
curve25519-sha256@libssh.org
```
也可以用paste -s -d,直接将查询结果串接并写入配置文件：
```bash
echo 'KexAlgorithms' `ssh -Q kex | paste -d, -s` >> /etc/ssh/sshd_config
```

技巧
遇到错误，服务端日志必须是首选检查点。
可借助sshd -d启用debug模式来排查问题。
可以用ssh -vvv以便更快找到问题。