---
title: Mailx
---
Mailx 是一个命令行邮件客户端，用于在 Linux/Unix 系统上发送和接收电子邮件。它是一种基于文本的工具，可以通过命令行界面和脚本进行操作。Mailx 可以通过 SMTP、POP3、IMAP 等协议来发送和接收邮件。


## 安装

```bash
yum install mailx -y
```
## 配置

```bash
vim /etc/mail.rc
set from=your_address@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=your_address@qq.com
set smtp-auth-password=your_passwd
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/
```

## 测试
```bash
echo &quot;hello world&quot; | mail -s &quot;hello&quot; xxx@qq.com
```


