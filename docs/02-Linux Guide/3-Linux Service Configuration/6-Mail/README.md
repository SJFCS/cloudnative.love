---
title: Mail
---

:::tip
mail -s 命令在 Linux/Unix 系统中通常使用 Mail Transfer Agent (MTA) 来发送邮件。在大多数情况下，邮件服务器软件 Postfix 是默认的 MTA，而非命令行邮件客户端 Mailx。

当你在命令行中使用 mail -s 命令发送邮件时，该命令会将邮件传递给本地的 Postfix 服务，并由 Postfix 处理和传递邮件。因此，mail -s 命令实际上是使用 Postfix 来发送邮件，而非 Mailx。但在某些情况下，系统管理员可能会配置使用其他 MTA 或 Mail Transfer Agent 替代 Postfix，这取决于系统的具体配置。
:::


- https://github.com/modoboa/modoboa
- https://github.com/mail-in-a-box/mailinabox
- https://github.com/mailcow/mailcow-dockerized


mail, mailx都是收发邮件用的，类似浏览器的作用，叫做mail user agent（MUA）.

sendmail,postfix是做邮件服务器的，类似apache, nginx的作用，可以用作mail transport agent（MTA）

