---
title: Mail
---

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