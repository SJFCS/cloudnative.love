---
title: Mail
---

SMTP,IMAPS,POP3S

DMARC,SPF,Domain Keys

crontab 默认使用mail来发送信息

- https://github.com/modoboa/modoboa
- https://github.com/mail-in-a-box/mailinabox
- https://github.com/mailcow/mailcow-dockerized

目标：局域网不同用户通过mail交流。可跨主机交流



要实现局域网不同主机不同用户通过mail交流，可以使用Postfix邮件服务器和mailx命令行邮件客户端程序结合使用。


以下是一种可能的配置方案：



在一台Linux服务器上安装并配置Postfix邮件服务器。

可以按照前面提到的方法安装和配置Postfix。


配置Postfix允许局域网内的主机访问。

可以在Postfix的主配置文件/etc/postfix/main.cf中添加以下参数：

```
mynetworks = 192.168.0.0/24

```
其中，192.168.0.0/24是局域网的网段。这样，局域网内的主机就可以通过SMTP协议访问Postfix邮件服务器。



在各个主机上安装mailx命令行邮件客户端程序。

可以使用以下命令在Ubuntu系统中安装mailx：


```
sudo apt-get install mailutils

```

在各个主机上创建邮件用户账号。

可以使用以下命令在Linux系统中创建一个邮件用户账号：
```
sudo adduser mailuser

```


在各个主机上使用mailx客户端发送邮件。

可以使用以下命令在Linux系统中使用mailx客户端发送邮件：

```
echo "This is a test message." | mail -s "Test message" user@example.com

```

其中，user@example.com是接收邮件的用户邮箱地址。


这样，用户在不同的主机上使用mailx客户端发送邮件，邮件将通过SMTP协议发送给Postfix邮件服务器进行传递和投递。其他用户可以在自己的邮箱中查看和回复邮件。需要注意的是，为了保证邮件的安全性，可以使用加密协议（如TLS）来保护邮件的传输和存储。