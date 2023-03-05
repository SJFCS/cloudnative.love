# htpasswd用户认证模块

[[toc]]

## 1. 概述

- `htpasswd`模块用于管理使用`htpasswd`进行用户认证的用户文件。
- 可以添加或删除一个用户/密码对象，可以用Nginx或Apache等Web服务器的用户认证。
- 官方文档 ：[https://docs.ansible.com/ansible/2.9/modules/htpasswd_module.html](https://docs.ansible.com/ansible/2.9/modules/htpasswd_module.html)


## 2. 官方示例

```yaml
# Add a user to a password file and ensure permissions are set
- htpasswd:
    path: /etc/nginx/passwdfile
    name: janedoe
    password: '9s36?;fyNp'
    owner: root
    group: www-data
    mode: 0640

# Remove a user from a password file
- htpasswd:
    path: /etc/apache2/passwdfile
    name: foobar
    state: absent

# Add a user to a password file suitable for use by libpam-pwdfile
- htpasswd:
    path: /etc/mail/passwords
    name: alex
    password: oedu2eGh
    crypt_scheme: md5_crypt
```

