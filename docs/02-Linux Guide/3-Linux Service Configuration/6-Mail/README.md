---
title: Mail
---

:::tip
mail -s 命令在 Linux/Unix 系统中通常使用 Mail Transfer Agent (MTA) 来发送邮件。在大多数情况下，邮件服务器软件 Postfix 是默认的 MTA，而非命令行邮件客户端 Mailx。

当你在命令行中使用 mail -s 命令发送邮件时，该命令会将邮件传递给本地的 Postfix 服务，并由 Postfix 处理和传递邮件。因此，mail -s 命令实际上是使用 Postfix 来发送邮件，而非 Mailx。但在某些情况下，系统管理员可能会配置使用其他 MTA 或 Mail Transfer Agent 替代 Postfix，这取决于系统的具体配置。
:::


SMTP,IMAPS,POP3S

DMARC,SPF,Domain Keys

crontab 默认使用mail来发送信息

- https://github.com/modoboa/modoboa
- https://github.com/mail-in-a-box/mailinabox
- https://github.com/mailcow/mailcow-dockerized


```
echo "This is a test message." | mail -s "Test message" user@example.com

```

其中，user@example.com是接收邮件的用户邮箱地址。


这样，用户在不同的主机上使用mailx客户端发送邮件，邮件将通过SMTP协议发送给Postfix邮件服务器进行传递和投递。其他用户可以在自己的邮箱中查看和回复邮件。需要注意的是，为了保证邮件的安全性，可以使用加密协议（如TLS）来保护邮件的传输和存储。


mail, mailx都是收发邮件用的，类似浏览器的作用，叫做mail user agent（MUA）.

sendmail,postfix是做邮件服务器的，类似apache, nginx的作用，可以用作mail transport agent（MTA）

扩展：

邮件用户代理（MUA，Mail User Agent）；

邮件传送代理（MTA，Mail Transport Agent）；

邮件分发代理（MDA，Mail Deliver Agent）；

mail 是用户使用客户端（类似foxmail）负责向MTA 撰写发送邮件;

mailx和mail本职是一样的，只是版本不同，叫法不一样；

sedmail，postfix就是负责邮件传输的MTA；