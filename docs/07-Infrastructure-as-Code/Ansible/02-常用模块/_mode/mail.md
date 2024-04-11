# mail邮件模块

[[toc]]

## 1. 概述

- mail模块用于发送邮件通知。
- 官方文档链接  [https://docs.ansible.com/ansible/2.9/modules/mail_module.html](https://docs.ansible.com/ansible/2.9/modules/mail_module.html)
- 你可能想知道为什么自动发送电子邮件？在复杂的环境中，有时会有无法实现自动化的过程，这可能是因为您缺乏实现自动化的权限，也可能是因为并非所有人都同意采用通用方法。
- 如果你不能自动执行某一特定步骤，但该步骤是非阻塞的，那么向责任方发送一封电子邮件，让他们履行自己的职责，这是一种将责任推给他人的优雅方式。
- 发送邮件也可以作为一种通知团队中一个或多个成员已（成功）采取特定行动的方式。

## 2. 参数


| 参数           | 描述                    |
|----------------|-------------------------|
| attach    list | 邮件附件，默认`[]`       |
| bcc   list     | 暗抄送，默认`[]`         |
| body   string  | 邮件主体，默认`$subject` |
| cc   list      | 抄送，默认`[]`           |
| charset   string  | 邮件编码，默认`utf-8` |
| from   string  | 邮件发送人，默认`root` |
| headers   list  | 追加的头部信息 |
| host   string  | 邮件服务器，默认`localhost` |
| password   string  | SMTP邮件服务器密码 |
| port   integer  | 邮件服务器端口号，默认`25` ，有效端口号范围`[1, 65534]`|
| secure   string  | 安全协议，可选值：`always`加密连接；`never`不使用SSL/TLS协议；`starttls`尝试SSL/TLS协议连接，如果不能这样则会失败；`try`尝试使用SSL/TLS协议连接，如果不能这样但不失败 |
| subject   string  | 邮件主题，必须字段 |
| subtype   string  | 类型，使用`html`还是默认的`plain`普通文本 |
| timeout   integer  | 超时时间，默认`20`秒 |
| to  list      | 收件人，默认`root`           |
| username   string  | SMTP邮件服务器用户名 |

## 3. 官方示例

```yaml
- name: Example playbook sending mail to root
  mail:
    subject: System {{ ansible_hostname }} has been successfully provisioned.
  delegate_to: localhost

- name: Sending an e-mail using Gmail SMTP servers
  mail:
    host: smtp.gmail.com
    port: 587
    username: username@gmail.com
    password: mysecret
    to: John Smith <john.smith@example.com>
    subject: Ansible-report
    body: System {{ ansible_hostname }} has been successfully provisioned.
  delegate_to: localhost

- name: Send e-mail to a bunch of users, attaching files
  mail:
    host: 127.0.0.1
    port: 2025
    subject: Ansible-report
    body: Hello, this is an e-mail. I hope you like it ;-)
    from: jane@example.net (Jane Jolie)
    to:
    - John Doe <j.d@example.org>
    - Suzie Something <sue@example.com>
    cc: Charlie Root <root@localhost>
    attach:
    - /etc/group
    - /tmp/avatar2.png
    headers:
    - Reply-To=john@example.com
    - X-Special="Something or other"
    charset: us-ascii
  delegate_to: localhost

- name: Sending an e-mail using the remote machine, not the Ansible controller node
  mail:
    host: localhost
    port: 25
    to: John Smith <john.smith@example.com>
    subject: Ansible-report
    body: System {{ ansible_hostname }} has been successfully provisioned.

- name: Sending an e-mail using Legacy SSL to the remote machine
  mail:
    host: localhost
    port: 25
    to: John Smith <john.smith@example.com>
    subject: Ansible-report
    body: System {{ ansible_hostname }} has been successfully provisioned.
    secure: always

- name: Sending an e-mail using StartTLS to the remote machine
  mail:
    host: localhost
    port: 25
    to: John Smith <john.smith@example.com>
    subject: Ansible-report
    body: System {{ ansible_hostname }} has been successfully provisioned.
    secure: starttls
```

## 4. 剧本的使用

### 4.1 向ansible主机发送邮件

编写剧本文件`mail.yml`:
```yaml
- hosts: node1
  tasks:
    - name: Example playbook sending mail to root
      mail:
        subject: System {{ ansible_hostname }} has been successfully provisioned.
      delegate_to: localhost
```
注意此处的`delegate_to: localhost`表示任务委派/代理，即最后由ansible主机发送邮件通知。

在执行剧本前，切换到`root`账号，查看`mail`邮件信息：
```sh
[root@master ~]# mail
No mail for root
[root@master ~]#
```
可以看到，此时没有邮件。


检查剧本文件并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint mail.yml
[ansible@master ansible_playbooks]$ ansible-playbook mail.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Example playbook sending mail to root] ***************************************************************************
ok: [node1 -> localhost] => {"changed": false, "msg": "Mail sent successfully", "result": {}}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时切换到`root`账号，查看邮件信息：
```sh
[root@master ~]# mail
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@master.loca  Tue Nov  8 20:35  28/984   "System node1 has been successfully provisioned."
& next
Message  1:
From root@kmaster.localdomain  Tue Nov  8 20:35:27 2022
Return-Path: <root@master.localdomain>
X-Original-To: root
Delivered-To: root@master.localdomain
Content-Type: multipart/mixed; -charset="utf-8";
 boundary="===============5024072418243279231=="
From: root@master.localdomain
Date: Tue, 08 Nov 2022 20:35:27 +0800
Subject: System node1 has been successfully provisioned.
X-Mailer: Ansible mail module
To: root@master.localdomain
Cc:
Status: R

Part 1:
Content-Type: text/plain; charset="utf-8"

System node1 has been successfully provisioned.

&
```

通过以上测试，我们通过执行ansible剧本给ansible主机发送了邮件通知。

通常我们更希望能够真的收到一封真实的邮件。


### 4.2 通过SMTP邮件服务器发送邮件

我们使用阿里云企业邮箱发送邮件。对应的SMTP信息可参考：[阿里邮箱IMAP、POP、SMTP地址和端口信息](https://help.aliyun.com/document_detail/36576.html)


| 协议 | 服务器地址           | 服务器端口号(常规) | 服务器端口号(加密) |
|------|----------------------|--------------------|:-------------------|
| SMTP | smtp.qiye.aliyun.com | 25                 | 465                |

推荐您使用加密端口连接，更加安全，使用时请注意加密端口是否已在您的本地电脑和网络中开放。

编写剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Sending an e-mail using Gmail SMTP servers
      mail:
        host: smtp.qiye.aliyun.com
        port: 465
        secure: always
        username: notice@hellogitlab.com
        # SMTP服务器密码信息，请注意保密
        password: securepassword
        # from: notice@hellogitlab.com
        to: 梅朝辉 <mzh@hellogitlab.com>
        subject: Ansible-report
        body: System {{ ansible_hostname }} has been successfully provisioned.
      delegate_to: localhost
```

此时执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-playbook mail.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Sending an e-mail using Gmail SMTP servers] **********************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: SMTPSenderRefused: (500, 'Error: bad syntax', 'root')
fatal: [node1 -> localhost]: FAILED! => {"changed": false, "msg": "Failed to send mail to 'mzh@hellogitlab.com': (500, 'Error: bad syntax', 'root')", "rc": 1}

PLAY RECAP *************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，发送失败，原因是我们没有设置发件人，我们将第10行的`from: notice@hellogitlab.com`配置打开：
```yaml
- hosts: node1
  tasks:
    - name: Sending an e-mail using Gmail SMTP servers
      mail:
        host: smtp.qiye.aliyun.com
        port: 465
        secure: always
        username: notice@hellogitlab.com
        # SMTP服务器密码信息，请注意保密
        password: securepassword
        from: notice@hellogitlab.com
        to: 梅朝辉 <mzh@hellogitlab.com>
        subject: Ansible-report
        body: System {{ ansible_hostname }} has been successfully provisioned.
      delegate_to: localhost
```

此时再执行剧本：

```sh
[ansible@master ansible_playbooks]$ ansible-lint mail.yml
[ansible@master ansible_playbooks]$ ansible-playbook mail.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Sending an e-mail using Gmail SMTP servers] **********************************************************************
ok: [node1 -> localhost] => {"changed": false, "msg": "Mail sent successfully", "result": {}}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

登陆邮箱服务器网页端，可以查看最新的邮件，可以看到，已经收到邮件了：
![](/img/Snipaste_2022-11-08_21-34-35.png)


你可以参照官方示例，结合实际应用场景给用户或管理员发送邮件通知，方便对剧本进行跟踪并及时进行后续操作。
