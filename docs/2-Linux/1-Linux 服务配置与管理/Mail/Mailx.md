---
title: Mailx
---

```bash
yum install mailx -y
# 配置
vim /etc/mail.rc
set from=XXX@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=XXX@qq.com
set smtp-auth-password=XXX
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/

# 测试
echo &quot;hello world&quot; | mail -s &quot;hello&quot; xxx@qq.com
```