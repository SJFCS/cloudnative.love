# user模块--管理用户账号和属性

[[toc]]

## 1. 概要

- `user`模块，用于管理用户账号和用户属性。
- 对于windows系统，请使用`win_user`模块来处理。
- `user`模块有很多参数，有些参数是`FreeBSD`、`macOS `等系统的参数，由于我们这边用得比较多的是Linux操作系统（如CentOS，Ubuntu）等，因此本文中仅会列出与部分Linux操作系统相关的参数。
- 每个平台对用户管理实用程序都有特定要求。 但是，它们通常预先安装在系统中，而Ansible需要使用这些程序作为运行时，如果没有这些基础程序Ansible将会抛出异常。在CentOS或Ubuntu系统上面，会使用`useradd`、`usermod`、`userdel`来处理用户账号。
- `user`模块官方文档[https://docs.ansible.com/ansible/latest/modules/user_module.html](https://docs.ansible.com/ansible/latest/modules/user_module.html) 。
- `user`模块源码[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/user.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/user.py) 。



## 2. 模块参数

| 参数                    | 可选值           | 默认值                                     | 说明                                                         |
| ----------------------- | ---------------- | ------------------------------------------ | ------------------------------------------------------------ |
| `append`                | yes/no           | no                                         | `boolean`，是否追加组，如果设置为`yes`，则将用户添加到`groups`指定的用户组中。如果设置为`no`，则只会将用户添加到`groups`指定的用户组中，而从其他组中删除！与`local`参数互斥！ |
| `comment`               |                  |                                            | `string`，（可选）设置用户帐户的描述信息。也称为`GECOS`即用户的详细信息，如姓名、年龄、电话等。 |
| `create_home`           | yes/no           | yes                                        | `boolean`，除非设置为`no`，否则在创建帐户或主目录不存在时将为用户创建主目录。别名`createhome` |
| `expires`               |                  |                                            | `float`，过期时间                                            |
| `force`                 | yes/no           | no                                         | `boolean`，当`state=absent`时，可以强制删除用户和用户相关的目录，就算用户正在登陆也可以删除。当`generate_ssh_key=yes`时，将会强制更新、覆盖已经存在的密钥文件。 |
| `generate_ssh_key`      | yes/no           | no                                         | `boolean`，产生SSH key文件，如果没有指定`force=yes`，则不会覆盖已经存在的密钥文件。 |
| `group`                 |                  |                                            | `string`（可选）设置用户的主组名。                           |
| `groups`                |                  |                                            | `list`，用户需要加入的组的名称组成的列表。当设置`groups=''`时，将会将用户从用户主组外的所有其他组中删除。与`local`参数互斥！ |
| `home`                  |                  |                                            | `path`，可选，设置用户家目录。                               |
| `local`                 | yes/no           | no                                         | `boolean`,强制使用本地命令替代项。当您要操作本地用户时，这在使用集中式身份验证的环境中很有用(如使用`luseradd`而不是`useradd`) 在调用命令之前会检查`/etc/passwd`是否存在现有帐户。如果本地帐户数据库位于`/etc/passwd`以外的其他位置，则当前设置将无法正常工作。 使用本地命令时，必须确保`luseradd`命令以及`/etc/passwd`必须存在于目标主机上，否则将抛出致命错误。 与`groups`和`append`参数互斥。 |
| `move_home`             | yes/no           | no                                         | `boolean`，当设置为`yes`时，并且配置了`home`参数，当旧的主目录存在时，将会将旧的主目录移到新的家目录的位置。 |
| `name` （**required**） |                  |                                            | `string`，需要增加，修改或删除的用户名，别名`user`。         |
| `non_unique`            | yes/no           | no                                         | `boolean`，允许设置用户ID不唯一。和`uid`参数一起作用。不是指一个用户可以用多个ID，而是一个ID可以用于多个用户，即可以多个用户名对应一个UID。 |
| `password`              |                  |                                            | `string`，可选，设置用户的密码，如果设置密码，该值需要加密。如果需要创建禁用的账号,请将该值设置为`!`或者`*`。有关如何加密密码，请参考https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module |
| `password_lock`         | yes/no           |                                            | `boolean`，锁定密码(usermod -L，pw lock，usermod -C)。但在不同平台上的实现方式不同，此选项并不总是意味着用户无法通过其他方法登录。此选项不会禁用用户，只会锁定密码。不要在同一任务中更改密码。目前在Linux，FreeBSD，DragonFlyBSD，NetBSD，OpenBSD上受支持。 |
| `remove`                | yes/no           | no                                         | `boolean`，移除用户并删除用户关联的目录，仅当`state=absent`时有效。与`userdel --remove`等效，详细可以查看手册页。 |
| `seuser`                |                  |                                            | `string`，可选，当SELINUX开启时设置seuser的类型。            |
| `shell`                 |                  |                                            | `string`，可选，用户默认的shell。                            |
| `skeleton`              |                  |                                            | `string`，可选，设置主框架目录。只有当`create_home`参数设置时才有效！ |
| `ssh_key_bits`          |                  | 由ssh-keygen的默认值决定，CentOS上面是2048 | `integer`，可选，在SSH密钥中指定要创建的位数。               |
| `ssh_key_comment`       |                  | “ansible-generated on $HOSTNAME”           | `string`，可选，生成SSH密钥文件时的备注信息。等同于`ssh-keygen -C Comment` |
| `ssh_key_file`          |                  | .ssh/id_rsa                                | `path`，可选，指定SSH密钥文件名。如果这是相对文件名，则它将相对于用户的主目录。此参数默认为.ssh / id_rsa。 |
| `ssh_key_passphrase`    |                  |                                            | `string`，设置SSH密钥的口令。如果未提供口令，则SSH密钥将默认为无口令。 |
| `ssh_key_type`          |                  | "rsa"                                      | `string`，可选，SSH密钥类型。如`rsa1, rsa, dsa, ecdsa and ed25519`等，可用的SSH密钥类型将取决于目标主机上的实现。 |
| `state`                 | present/absent   | present                                    | 帐户是否应存在，如果状态与声明的状态不同，则采取措施。       |
| `system`                | yes/no           | no                                         | 当`state=present`时，本参数设置为`yes`时则将用户转换成系统用户。该参数不能更新已经存在的用户信息！ |
| `uid`                   |                  |                                            | `integer`，可选，用户的UID                                   |
| `update_password`       | always/on_create | always                                     | `always`如果密码不同将会更新密码。`on_create`将仅为新创建的用户设置密码。 |



## 3. 模块返回值

| 键                                                           | 何时返回                                    | 描述说明                                        |
| ------------------------------------------------------------ | ------------------------------------------- | ----------------------------------------------- |
| **append**                                                     boolean | 当`state=present`并且用户存在时             | 是否添加用户到用户组中                          |
| **comment**                                                     string | 当用户存在时                                | 用户的详细信息，通常是用户的名字                |
| **create_home**                                                     boolean | 当用户不存在时，且不是check检查模式时       | 是否创建用户家目录                              |
| **force**                                                     boolean | 当`state=absent`并且用户存在时              | 是否强制删除用户帐户                            |
| **group**                                                     integer | 当用户存在时                                | 用户的主组的ID，如`1001`                        |
| **groups**                                                     string | 当`state=present`并且`groups`不为空时       | 用户的组列表，如`chrony,apache`                 |
| **home**                                                         string | 当`state=present`时                         | 用户家目录路径 ，如`/home/asmith`               |
| **move_home**                                                     boolean | 当`state=present`并且用户存在时             | 是否移动已经存在的家目录                        |
| **name**                                                        string | 一直返回                                    | 用户账号名称 ，如`asmith`                       |
| **password**                                                     string | 当`state=present`并且`password`参数不为空时 | 密码的掩码字符串，如`NOT_LOGGING_PASSWORD`      |
| **remove**                                                     boolean | 当`state=absent`并且用户存在时              | 是否删除用户                                    |
| **shell**                                                          string | 当`state=present`时                         | 用户登陆shell，如`/bin/bash`                    |
| **ssh_fingerprint**                                                     string | 当`generate_ssh_key` 参数是 `True`时        | 生成的SSH密钥的指纹，如字符串1，详见脚注        |
| **ssh_key_file**                                                     string | 当`generate_ssh_key` 参数是 `True`时        | SSH密钥文件的路径，如`/home/asmith/.ssh/id_rsa` |
| **ssh_public_key**                                                     string | 当`generate_ssh_key` 参数是 `True`时        | SSH公钥字符串，如字符串2，详见脚注              |
| **stderr**                                                        string | 当命令返回标准异常时                        | 命令的标准异常，如`Group wheels does not exist` |
| **stdout**                                                       string | 当命令返回标准输出时                        | 命令的标准输出                                  |
| **system**                                                     boolean | 当指定`system`参数并且用户账号不存在时      | 是否用户账号是系统账号                          |
| **uid**                                                          integer | 当指定`uid`参数时                           | 用户账号的UID，如`1044`                         |

脚注说明：

- 字符串1: `2048 SHA256:aYNHYcyVm87Igh0IMEDMbvW0QDlRQfE0aJugp684ko8 ansible-generated on host (RSA)`

- 字符串2：`ssh-rsa   AAAAB3NzaC1yc2EAAAADAQABAAABAQC95opt4SPEC06tOYsJQJIuN23BbLMGmYo8ysVZQc4h2DZE9ugbjWWGS1/pweUGjVstgzMkBEeBCByaEf/RJKNecKRPeGd2Bw9DCj/bn5Z6rGfNENKBmo   618mUJBvdlEgea96QGjOwSB7/gmonduC7gsWDMNcOdSE3wJMTim4lddiBx4RgC9yXsJ6Tkz9BHD73MXPpT5ETnse+A3fw3IGVSjaueVnlUyUmOBf7fzmZbhlFVXf2Zi2rFTXqvbdGHKkzpw1U8eB8xFPP7y  d5u1u0e6Acju/8aZ/l17IDFiLke5IzlqIMRTEbDwLNeO84YQKWTm9fODHzhYe0yvxqLiK07  ansible-generated on host`

## 4. CentOS7用户账号处理命令

用户账号管理可以参考《鸟哥的Linux私房菜(第三版)》第14章Linux账号管理与ACL权限设置，如果你没有这本书，可以参考[http://linux.vbird.org/linux_basic/0410accountmanager.php](http://linux.vbird.org/linux_basic/0410accountmanager.php) ,这个是鸟哥的官网。

名称解释：

- UID:  用户ID。
- GID: 用户组ID。
- 初始用户组：initial group，或者主组，用户的主要用户组。
- 有效用户组：effective group，用户所有的组。

此处大致列一下，用户账号管理涉及的命令：

- `id`，查看用户的用户ID、组ID，所属组信息。
- `groups`，查看用户的所属组信息。
- `newgrp`, 切换用户的有效用户组。
- `useradd`，新增用户。
- `passwd`，修改用户密码，设置密码过期时间，锁定密码等。
- `chage`，用户密码参数处理。
- `usermod`，用户设置，可以理解对用户信息进行更新。
- `userdel`，删除用户。
- `finger`，查看用户账号相关属性。
- `chfn`, 修改用户指纹(finger)信息。
- `chsh`，修改登陆SHELL。
- `groupadd`, 新增用户组。
- `groupmod`，用户组修改。
- `groupdel`，删除用户组。
- `gpasswd`, 用户组管理员功能。
- `chage`，显示密码参数更详细的信息。

用户账号管理涉及的相关文件：

- /etc/passwd  用户账号相关
- /etc/shadow 用户密码相关
- /etc/group 用户组相关
- /etc/gshadow 组管理员相关，一般不用
- /etc/default/useradd 新增用户使用的默认配置
- /etc/login.defs 用户登陆相关的一些限制默认配置
- /etc/skel/* 新创建文件时，会将该文件夹下的文件复制到新用户的家目录下面。

## 5. 模块应用

我们参考官方示例，来使用user模块。

### 5.1 使用Ad-hoc command临时命令创建用户

我们先来测试一下，使用临时命令来给远程主机创建用户：

```sh
# 直接创建时，会提示权限异常，即权限不够
[ansible@master ~]$ ansible node1 -m user -a "name=testuser1 comment='Test User 1'"
node1 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "cmd": "/sbin/useradd -c 'Test User 1' -m testuser1", 
    "msg": "[Errno 13] Permission denied", 
    "rc": 13
}

# 使用--become参数进行权限提升，成功创建用户
[ansible@master ~]$ ansible node1 --become -m user -a "name=testuser1 comment='Test User 1'"
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "Test User 1", 
    "create_home": true, 
    "group": 1003, 
    "home": "/home/testuser1", 
    "name": "testuser1", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1003
}
[ansible@master ~]$
```

可以看到，正常创建了用户，并且能够看到用户对应的一些信息，如组ID为1003，创建家目录`/home/testuser1`，用户ID为1003，对应是shell是`/bin/bash`，不是系统账号，备注信息是`Test User 1`等。我们可以在node1节点上面查看检查一下：

```sh
[ansible@node1 ~]$ tail -n 1 /etc/passwd
testuser1:x:1003:1003:Test User 1:/home/testuser1:/bin/bash
[ansible@node1 ~]$ ls -lah /home/testuser1
ls: cannot open directory /home/testuser1: Permission denied
[ansible@node1 ~]$ sudo ls -lah /home/testuser1
total 12K
drwx------  2 testuser1 testuser1  62 Jul 22 09:26 .
drwxr-xr-x. 6 root      root       68 Jul 22 09:26 ..
-rw-r--r--  1 testuser1 testuser1  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 testuser1 testuser1 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 testuser1 testuser1 231 Oct 31  2018 .bashrc
[ansible@node1 ~]$ sudo id testuser1
uid=1003(testuser1) gid=1003(testuser1) groups=1003(testuser1)
[ansible@node1 ~]$
```

可以看出用户testuser1正常创建，家目录也与Ansible返回的信息是一致，说明我们通过临时命令创建是OK的。我们后面再使用剧本方式来创建用户。



### 5.2 使用剧本创建用户

#### 5.2.1 用户名、用户描述信息、用户ID、用户组、SHELL相关

- name、comment、uid、group、groups、shell、append等参数的使用

直接运行官方文档中的前两个示例：

```sh
# 编写剧本文件
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'johnd' with a specific uid and a primary group of 'admin'
      user:
        name: johnd
        comment: John Doe
        uid: 1040
        group: admin

    - name: Add the user 'james' with a bash shell, appending the group 'admins' and 'developers' to the user's groups
      user:
        name: james
        shell: /bin/bash
        groups: admins,developers
        append: yes
[ansible@master ~]$        
# 检查剧本文件规范
[ansible@master ~]$ ansible-lint user.yml 
[ansible@master ~]$
# 检查剧本文件语法
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml
[ansible@master ~]$
# 执行剧本，可以看到执行失败
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'admin'] *******
fatal: [node1]: FAILED! => {"changed": false, "msg": "Group admin does not exist"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们执行上面的剧本发现任务执行失败了，原因是`Group admin does not exist`，即组`admin`不存在。可以猜到，如果任务1执行成功，任务2也会失败的，因为`admins`,`developers`这两个用户组也是不存在的。

由于group模块我们还没有学习，我们先查看一下group模块的帮助信息：

```sh
[ansible@master ~]$ ansible-doc -s group
- name: Add or remove groups
  group:
      gid:                   # Optional `GID' to set for the group.
      local:                 # Forces the use of "local" command alternatives on
                               platforms that
                               implement it. This is
                               useful in environments
                               that use centralized
                               authentication when you
                               want to manipulate the
                               local groups. (e.g. it
                               uses `lgroupadd'
                               instead of `groupadd').
                               This requires that
                               these commands exist on
                               the targeted host,
                               otherwise it will be a
                               fatal error.
      name:                  # (required) Name of the group to manage.
      non_unique:            # This option allows to change the group ID to a non-
                               unique value. Requires
                               `gid'. Not supported on
                               macOS or BusyBox
                               distributions.
      state:                 # Whether the group should be present or not on the
                               remote host.
      system:                # If `yes', indicates that the group created is a system
                               group.
[ansible@master ~]$ 
```

我们使用临时命令创建`admin`组：

```sh
[ansible@master ~]$ ansible node1 --become -m group -a "name=admin"
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1004, 
    "name": "admin", 
    "state": "present", 
    "system": false
}
[ansible@master ~]$ 
```

在node1上面检查一下组是否创建成功：

```sh
[ansible@node1 ~]$ sudo tail -n 1 /etc/group
admin:x:1004:
[ansible@node1 ~]$ 
```

可以看到组`admin`已经存在了！然后我们再在Ansible主机上面运行剧本：

```sh
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'admin'] *******
fatal: [node1]: FAILED! => {"changed": false, "cmd": "/sbin/useradd -u 1040 -g admin -c 'John Doe' -m johnd", "msg": "[Errno 13] Permission denied", "rc": 13}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时又报错了，但报错的信息不一样了，此次是提示`[Errno 13] Permission denied`即权限不够，因此我们需要权力提升一下。修改一下剧本文件，增加`become`参数：

```sh
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'johnd' with a specific uid and a primary group of 'admin'
      user:
        name: johnd
        comment: John Doe
        uid: 1040
        group: admin
      become: yes

    - name: Add the user 'james' with a bash shell, appending the group 'admins' and 'developers' to the user's groups
      user:
        name: james
        shell: /bin/bash
        groups: admins,developers
        append: yes
      become: yes
[ansible@master ~]$ ansible-lint user.yml 
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'admin'] *******
changed: [node1] => {"changed": true, "comment": "John Doe", "create_home": true, "group": 1004, "home": "/home/johnd", "name": "johnd", "shell": "/bin/bash", "state": "present", "system": false, "uid": 1040}

TASK [Add the user 'james' with a bash shell, appending the group 'admins' and 'developers' to the user's groups] ***
fatal: [node1]: FAILED! => {"changed": false, "msg": "Group admins does not exist"}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，此时任务1创建`johnd`用户成功，但是创建`james`用户失败，因为`Group admins does not exist`组不存在，这就验证了我们前面的预测，因为`admins`组和`developers`组不存在。

同样的，我们也使用临时命令来创建这两个组：

```sh
[ansible@master ~]$ ansible node1 --become -m group -a "name=admins"
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1005, 
    "name": "admins", 
    "state": "present", 
    "system": false
}
[ansible@master ~]$ ansible node1 --become -m group -a "name=developers"
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1006, 
    "name": "developers", 
    "state": "present", 
    "system": false
}
[ansible@master ~]$ 
```

在node1节点上面查看刚创建的组：

```sh
[ansible@node1 ~]$ sudo tail -n 3 /etc/group
admin:x:1004:
admins:x:1005:
developers:x:1006:
[ansible@node1 ~]$ 
```

可以看到，组已经成功创建，我们再来运行一下剧本：

```sh
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'admin'] *******
ok: [node1] => {"append": false, "changed": false, "comment": "John Doe", "group": 1004, "home": "/home/johnd", "move_home": false, "name": "johnd", "shell": "/bin/bash", "state": "present", "uid": 1040}

TASK [Add the user 'james' with a bash shell, appending the group 'admins' and 'developers' to the user's groups] ***
changed: [node1] => {"changed": true, "comment": "", "create_home": true, "group": 1041, "groups": "admins,developers", "home": "/home/james", "name": "james", "shell": "/bin/bash", "state": "present", "system": false, "uid": 1041}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，第一个任务没有产生修改，因为上一次运行剧本时已经成功创建了`johd`这个用户了。第2个任务成功执行，并且产生了变更，成功创建了`james`，并且将该用户加入到`admins`和`developers`组中。

我们在node1节点上检查一下：

```sh
[ansible@node1 ~]$ tail -n 1 /etc/passwd
james:x:1041:1041::/home/james:/bin/bash
[ansible@node1 ~]$ sudo id james
uid=1041(james) gid=1041(james) groups=1041(james),1005(admins),1006(developers)
[ansible@node1 ~]$ 
[ansible@node1 ~]$ sudo ls -lah /home/james/
total 12K
drwx------  2 james james  62 Jul 22 13:53 .
drwxr-xr-x. 8 root  root   94 Jul 22 13:53 ..
-rw-r--r--  1 james james  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 james james 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 james james 231 Oct 31  2018 .bashrc
[ansible@node1 ~]$ 
[ansible@node1 ~]$ tail -n 2 /etc/passwd
johnd:x:1040:1004:John Doe:/home/johnd:/bin/bash
james:x:1041:1041::/home/james:/bin/bash
```

可以看到，`james`用户有主组`james`，以及有效用户组`admins`和`developers`。并且`james`的家目录也创建成功了。通过查看`/etc/passwd`也可以知道，默认情况下新创建的用户使用的shell是`/bin/bash`。



#### 5.2.2 用户信息更新与用户删除

- name、comment、uid、group、state、remove等参数的使用

我们更新一下脚本，尝试对用户信息进行更新。

```sh
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'johnd' with a specific uid and a primary group of 'johnd'
      user:
        name: johnd
        comment: John Done
        uid: 1040
        group: johnd
      become: yes

    - name: Remove the user 'james'
      user:
        name: james
        state: absent
        remove: yes
      become: yes
[ansible@master ~]$ ansible-lint user.yml 
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'johnd'] **************************************************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "Group johnd does not exist"}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以发现，当我们使用`group`来指定用户的主要组时，尽管`group`指定的组名`johnd`与`name`指定的用户名`johnd`是相同的，这时候仍然提示`Group johnd does not exist`，即`johnd`组不存在。我们使用临时命令创建一下`johnd`组：

```sh
[ansible@master ~]$ ansible node1 --become -m group -a "name=johnd"
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1042, 
    "name": "johnd", 
    "state": "present", 
    "system": false
}
[ansible@master ~]$ 
```

执行成功，我们在node1节点上检查一下：

```sh
[ansible@node1 ~]$ tail -n 4 /etc/group
admins:x:1005:james
developers:x:1006:james
james:x:1041:
johnd:x:1042:
[ansible@node1 ~]$ 
```

可以看到`johnd`用户组创建成功。我们再来执行一下剧本：

```sh
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'johnd' with a specific uid and a primary group of 'johnd'] **************************************************************************************************
changed: [node1] => {"append": false, "changed": true, "comment": "John Done", "group": 1042, "home": "/home/johnd", "move_home": false, "name": "johnd", "shell": "/bin/bash", "state": "present", "uid": 1040}

TASK [Remove the user 'james'] **************************************************************************************************************************************************
changed: [node1] => {"changed": true, "force": false, "name": "james", "remove": true, "state": "absent"}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时执行成功了，此时可以看到`johnd`用户的组和备注信息都发生了变化。

在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ tail -n 3 /etc/passwd
test:x:1002:1002::/home/test:/bin/bash
testuser1:x:1003:1003:Test User 1:/home/testuser1:/bin/bash
johnd:x:1040:1042:John Done:/home/johnd:/bin/bash
[ansible@node1 ~]$ 
[ansible@node1 ~]$ ls -lah /home/
total 0
drwxr-xr-x.  7 root       root        81 Jul 22 14:29 .
dr-xr-xr-x. 18 root       root       240 Jul 13 15:49 ..
drwx------   7 ansible    ansible    304 Jul 17 15:52 ansible
drwx------   2 johnd      johnd       62 Jul 22 10:14 johnd
drwx------.  2 meizhaohui meizhaohui  83 Jul 14 10:00 meizhaohui
drwx------   2 test       test        62 Jul  7 16:22 test
drwx------   2 testuser1  testuser1   62 Jul 22 09:26 testuser1
[ansible@node1 ~]$ sudo ls -lah /home/johnd/
total 12K
drwx------  2 johnd johnd  62 Jul 22 10:14 .
drwxr-xr-x. 7 root  root   81 Jul 22 14:29 ..
-rw-r--r--  1 johnd johnd  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 johnd johnd 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 johnd johnd 231 Oct 31  2018 .bashrc
[ansible@node1 ~]$ 
[ansible@node1 ~]$ tail -n 3 /etc/group
admins:x:1005:
developers:x:1006:
johnd:x:1042:
[ansible@node1 ~]$ 
```

可以看到`johnd`账号的信息从`johnd:x:1040:1004:John Doe:/home/johnd:/bin/bash`变成了`johnd:x:1040:1042:John Done:/home/johnd:/bin/bash`,可以看到组信息和备注信息都发生了变化！

另外，我们发现`james`用户以及他的家目录都被删除了！以及`james`组也被删除了！



#### 5.2.3 创建用户时指定不创建家目录并改变登陆SHELL

我们修改一下剧本文件，然后再运行：

```sh
# 本意是想创建用户的时候，顺带指定他的用户组与用户名同名
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'testuser2'
      user:
        name: testuser2
        group: testuser2
        create_home: no
        shell: /bin/zsh
      become: yes
[ansible@master ~]$ ansible-lint user.yml 
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml

# 执行剧本，发现报错
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'testuser2'] *************************************************************************************************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "Group testuser2 does not exist"}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，提示用户组`testuser2`不存在，当然不存在！因为我们没有创建过这个组！因此，我们把`group`参数去掉，再运行剧本：

```sh
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'testuser2'
      user:
        name: testuser2
        create_home: no
        shell: /bin/zsh
      become: yes
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'testuser2'] *************************************************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "", "create_home": false, "group": 1041, "home": "/home/testuser2", "name": "testuser2", "shell": "/bin/zsh", "state": "present", "system": false, "uid": 1041}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时，执行成功了，并且没有创建用户家目录，设置了登陆SHELL是`/bin/zsh`。

我们在node1上面检查一下：

```sh
# 查看home下面是否有testuser2的目录，发现没有
[ansible@node1 ~]$ ls -lah /home/
total 0
drwxr-xr-x.  7 root       root        81 Jul 22 14:29 .
dr-xr-xr-x. 18 root       root       240 Jul 13 15:49 ..
drwx------   7 ansible    ansible    304 Jul 17 15:52 ansible
drwx------   2 johnd      johnd       62 Jul 22 10:14 johnd
drwx------.  2 meizhaohui meizhaohui  83 Jul 14 10:00 meizhaohui
drwx------   2 test       test        62 Jul  7 16:22 test
drwx------   2 testuser1  testuser1   62 Jul 22 09:26 testuser1

# 查看用户的用户ID、组ID，所属组信息
[ansible@node1 ~]$ sudo id testuser2
uid=1041(testuser2) gid=1041(testuser2) groups=1041(testuser2)

# 查看用户文件信息
[ansible@node1 ~]$ tail -n 1 /etc/passwd
testuser2:x:1041:1041::/home/testuser2:/bin/zsh

# 查看用户组文件信息
[ansible@node1 ~]$ tail -n 1 /etc/group
testuser2:x:1041:

# 查看当前系统支持哪些SHELL
[ansible@node1 ~]$ cat /etc/shells 
/bin/sh
/bin/bash
/usr/bin/sh
/usr/bin/bash
/usr/bin/fish

# 尝试运行zsh，发现命令不存在
[ansible@node1 ~]$ /bin/zsh
bash: /bin/zsh: No such file or directory
[ansible@node1 ~]$ 

```

通过创建`testuser2`可以知道：通过`ceate_home: no`可以指定不创建家目录；不指定`group`时，默认是会创建一个与用户名相同的初始用户组的，不需要特别指定`group`参数。另外，指定用户登陆SHELL时，Ansible并不会去检查你指定的shell是否真实存在！

我们将刚才创建的几个测试用户删除掉。

```sh
[ansible@node1 ~]$ sudo userdel -f -r testuser1 
[ansible@node1 ~]$ sudo userdel -f -r testuser2
[ansible@node1 ~]$ sudo userdel -f -r johnd
[ansible@node1 ~]$ tail -n 2 /etc/passwd
mysql:x:997:995:MySQL server:/var/lib/mysql:/sbin/nologin
test:x:1002:1002::/home/test:/bin/bash
[ansible@node1 ~]$ sudo groupdel admin
[ansible@node1 ~]$ tail -n 5 /etc/group
ansible:x:1001:
mysql:x:995:
test:x:1002:
admins:x:1005:
developers:x:1006:
[ansible@node1 ~]$ 
```

测试用户删除了，仅保留了`admins`和`developers`组。注意，删除用户时，需要使用`-f -r`参数强制删除家目录。



#### 5.2.4 改变家目录和skel框架文件夹设置

我们在node1节点上将`/etc/skel`目录复制一份到`/etc/ansible_skel`目录下,并在`/etc/ansible_skel`目录下创建一个`.vimrc`文件：

```sh
[ansible@node1 ~]$ sudo cp -r /etc/skel/ /etc/ansible_skel
[ansible@node1 ~]$ ls -ld /etc/*skel
drwxr-xr-x  2 root root 62 Jul 22 16:14 /etc/ansible_skel
drwxr-xr-x. 2 root root 62 Apr 11  2018 /etc/skel
[ansible@node1 ~]$ ls -lah /etc/*skel
/etc/ansible_skel:
total 24K
drwxr-xr-x   2 root root   62 Jul 22 16:14 .
drwxr-xr-x. 86 root root 8.0K Jul 22 16:14 ..
-rw-r--r--   1 root root   18 Jul 22 16:14 .bash_logout
-rw-r--r--   1 root root  193 Jul 22 16:14 .bash_profile
-rw-r--r--   1 root root  231 Jul 22 16:14 .bashrc

/etc/skel:
total 24K
drwxr-xr-x.  2 root root   62 Apr 11  2018 .
drwxr-xr-x. 86 root root 8.0K Jul 22 16:14 ..
-rw-r--r--.  1 root root   18 Oct 31  2018 .bash_logout
-rw-r--r--.  1 root root  193 Oct 31  2018 .bash_profile
-rw-r--r--.  1 root root  231 Oct 31  2018 .bashrc
```

然后创建一个.vimrc文件，并修改一下.vimrc和.bashrc文件的内容，修改后查看内容如下：

```sh
[ansible@node1 ~]$ cat /etc/ansible_skel/.vimrc 
syntax on
filetype plugin indent on
set hlsearch
set backspace=2
set autoindent
set ruler
set showmode
set nu
set bg=dark
set ts=4
set softtabstop=4
set shiftwidth=4
set fileencodings=utf-8,gbk,gb18030,gk2312
set showcmd
set clipboard+=unnamed
set cursorline
set confirm
set autoindent
set cindent
set expandtab
set laststatus=2
[ansible@node1 ~]$ cat /etc/ansible_skel/.bashrc 
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias rm='echo -e "Info:\033[31mrm can not be used, please use \033[32msafe-rm\033[0m or \033[32mtrash-put\033[0m\n"'
alias ls='ls --color=auto'
alias ll='ls -lah'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias v.='vi ~/.bashrc'
alias s.='source ~/.bashrc && echo "reload OK"'
alias now='date +"%Y年%m月%d日_%H:%M:%S"'
alias tar='tar --no-same-owner'
alias cdnet='cd /etc/sysconfig/network-scripts/'
# pipenv environment
export PIPENV_VENV_IN_PROJECT=1
export PIPENV_PYPI_MIRROR=https://mirrors.aliyun.com/pypi/simple
# locale and language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

[ansible@node1 ~]$ 
```

先确定`/var/lib/ansible`和`/etc/skel_not_exist`目录不存在：

```sh
[ansible@node1 ~]$ ls -lah /var/lib/ansible
ls: cannot access /var/lib/ansible: No such file or directory
[ansible@node1 ~]$ ls -lah /etc/skel_not_exist
ls: cannot access /etc/skel_not_exist: No such file or directory
```

可以看到两个目录不存在。

我们来测试一下：

```sh
# 查看剧本文件
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'jenkins' with home /var/lib/ansible/jenkins
      user:
        name: jenkins
        comment: Jenkins Automation Server
        home: /var/lib/ansible/jenkins
        skeleton: /etc/skel_not_exist
      become: yes

    - name: Add the user 'zabbix' with home /var/lib/ansible/zabbix
      user:
        name: zabbix
        comment: Zabbix Monitoring System
        home: /var/lib/ansible/zabbix
        skeleton: /etc/ansible_skel
        system: yes
        shell: /sbin/nologin
      become: yes

# 检查剧本文件规范
[ansible@master ~]$ ansible-lint user.yml 

# 检查剧本文件语法
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml

# 执行剧本，可以看到创建用户成功了，但是创建Jenkins用户时，出现了异常
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'jenkins' with home /var/lib/ansible/jenkins] ***************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Jenkins Automation Server", "create_home": true, "group": 1003, "home": "/var/lib/ansible/jenkins", "name": "jenkins", "shell": "/bin/bash", "state": "present", "stderr": "useradd: warning: the home directory already exists.\nNot copying any file from skel directory into it.\n", "stderr_lines": ["useradd: warning: the home directory already exists.", "Not copying any file from skel directory into it."], "system": false, "uid": 1003}

TASK [Add the user 'zabbix' with home /var/lib/ansible/zabbix] *****************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Zabbix Monitoring System", "create_home": true, "group": 994, "home": "/var/lib/ansible/zabbix", "name": "zabbix", "shell": "/sbin/nologin", "state": "present", "system": true, "uid": 996}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们来node1节点上面检查一下：

```sh
[ansible@node1 ~]$ ls -ld /var/lib/ansible/
drwxr-xr-x 4 root root 35 Jul 22 16:34 /var/lib/ansible/
[ansible@node1 ~]$ ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   4 root    root      35 Jul 22 16:34 .
drwxr-xr-x. 27 root    root    4.0K Jul 22 16:34 ..
drwx------   2 jenkins jenkins    6 Jul 22 16:34 jenkins
drwx------   2 zabbix  zabbix    76 Jul 22 16:34 zabbix
[ansible@node1 ~]$ ls -lah /var/lib/ansible/jenkins/
ls: cannot open directory /var/lib/ansible/jenkins/: Permission denied
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/jenkins/
total 0
drwx------ 2 jenkins jenkins  6 Jul 22 16:34 .
drwxr-xr-x 4 root    root    35 Jul 22 16:34 ..
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/zabbix/
total 16K
drwx------ 2 zabbix zabbix  76 Jul 22 16:34 .
drwxr-xr-x 4 root   root    35 Jul 22 16:34 ..
-rw-r--r-- 1 zabbix zabbix  18 Jul 22 16:14 .bash_logout
-rw-r--r-- 1 zabbix zabbix 193 Jul 22 16:14 .bash_profile
-rw-r--r-- 1 zabbix zabbix 836 Jul 22 16:21 .bashrc
-rw-r--r-- 1 zabbix zabbix 329 Jul 22 16:16 .vimrc
[ansible@node1 ~]$ 
```

可以看到，虽然刚开始，我们通过`home`参数指定jenkins用户的家目录`/var/lib/ansible/jenkins`时，`/var/lib/ansible/`目录并不存在，这时也是可以创建成功家目录的，Ansible会自动创建出家目录的上级不存在的目录！但是，我们配置`skeleton: /etc/skel_not_exist`设置从该目录复制框架文件到新的用户家目录下，由于`/etc/skel_not_exist`目录是不存在的，因此在创建`jenkins`用户的过程中，并没有复制skel文件，而创建`zabbix`用户时，由于`/etc/ansible_skel`是存在的，此时正常复制了skel文件，最后可以看到`/var/lib/ansible/jenkins/`文件夹中不包含任何文件，`/var/lib/ansible/zabbix/`包含了`/etc/ansible_skel`目录下的文件。说明复制成功。

我们先把jenkins和zabbix账号删除，再来操作一次：

```sh
[ansible@node1 ~]$ sudo userdel -f -r zabbix
userdel: zabbix mail spool (/var/spool/mail/zabbix) not found
[ansible@node1 ~]$ sudo userdel -f -r jenkins
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   2 root root    6 Jul 22 17:29 .
drwxr-xr-x. 27 root root 4.0K Jul 22 17:03 ..
[ansible@node1 ~]$ tail -n 2 /etc/passwd
mysql:x:997:995:MySQL server:/var/lib/mysql:/sbin/nologin
test:x:1002:1002::/home/test:/bin/bash
[ansible@node1 ~]$ 
```

我们更新一下剧本文件，将`skeleton: /etc/skel_not_exist`改成`skeleton: /etc/ansible_skel`，然后再执行剧本：

```sh
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    - name: Add the user 'jenkins' with home /var/lib/ansible/jenkins
      user:
        name: jenkins
        comment: Jenkins Automation Server
        home: /var/lib/ansible/jenkins
        skeleton: /etc/ansible_skel
      become: yes

    - name: Add the user 'zabbix' with home /var/lib/ansible/zabbix
      user:
        name: zabbix
        comment: Zabbix Monitoring System
        home: /var/lib/ansible/zabbix
        skeleton: /etc/ansible_skel
        system: yes
        shell: /sbin/nologin
      become: yes
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'jenkins' with home /var/lib/ansible/jenkins] ***************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Jenkins Automation Server", "create_home": true, "group": 1003, "home": "/var/lib/ansible/jenkins", "name": "jenkins", "shell": "/bin/bash", "state": "present", "system": false, "uid": 1003}

TASK [Add the user 'zabbix' with home /var/lib/ansible/zabbix] *****************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Zabbix Monitoring System", "create_home": true, "group": 994, "home": "/var/lib/ansible/zabbix", "name": "zabbix", "shell": "/sbin/nologin", "state": "present", "system": true, "uid": 996}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到此时正常执行！

```sh
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   4 root    root      35 Jul 22 17:31 .
drwxr-xr-x. 27 root    root    4.0K Jul 22 17:03 ..
drwx------   2 jenkins jenkins   76 Jul 22 17:31 jenkins
drwx------   2 zabbix  zabbix    76 Jul 22 17:31 zabbix
[ansible@node1 ~]$ tail -n 2 /etc/passwd
jenkins:x:1003:1003:Jenkins Automation Server:/var/lib/ansible/jenkins:/bin/bash
zabbix:x:996:994:Zabbix Monitoring System:/var/lib/ansible/zabbix:/sbin/nologin
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/jenkins/
total 16K
drwx------ 2 jenkins jenkins  76 Jul 22 17:31 .
drwxr-xr-x 4 root    root     35 Jul 22 17:31 ..
-rw-r--r-- 1 jenkins jenkins  18 Jul 22 16:14 .bash_logout
-rw-r--r-- 1 jenkins jenkins 193 Jul 22 16:14 .bash_profile
-rw-r--r-- 1 jenkins jenkins 836 Jul 22 16:21 .bashrc
-rw-r--r-- 1 jenkins jenkins 329 Jul 22 16:16 .vimrc
[ansible@node1 ~]$ sudo ls -lah /var/lib/ansible/zabbix/
total 16K
drwx------ 2 zabbix zabbix  76 Jul 22 17:31 .
drwxr-xr-x 4 root   root    35 Jul 22 17:31 ..
-rw-r--r-- 1 zabbix zabbix  18 Jul 22 16:14 .bash_logout
-rw-r--r-- 1 zabbix zabbix 193 Jul 22 16:14 .bash_profile
-rw-r--r-- 1 zabbix zabbix 836 Jul 22 16:21 .bashrc
-rw-r--r-- 1 zabbix zabbix 329 Jul 22 16:16 .vimrc
```

此时也可以发现节点上面正常的创建了两个用户了，并且家目录下面的文件也设置正常了！

如果我们将`/var/lib/ansible/`这个目录删除掉，再来重新创建两个新户，得到的输出又会不一样，我们先做一下准备工作：

```sh
[root@node1 home]# sudo userdel -f -r jenkins
[root@node1 home]# sudo userdel -f -r zabbix
userdel: zabbix mail spool (/var/spool/mail/zabbix) not found
[root@node1 home]# sudo trash-put /var/lib/ansible
[root@node1 home]# sudo trash-empty
[root@node1 home]# ls -lah /var/lib/ansible
ls: cannot access /var/lib/ansible: No such file or directory
```

此时再执行剧本：

```sh
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'jenkins' with home /var/lib/ansible/jenkins] ****************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Jenkins Automation Server", "create_home": true, "group": 1003, "home": "/var/lib/ansible/jenkins", "name": "jenkins", "shell": "/bin/bash", "state": "present", "stderr": "useradd: warning: the home directory already exists.\nNot copying any file from skel directory into it.\n", "stderr_lines": ["useradd: warning: the home directory already exists.", "Not copying any file from skel directory into it."], "system": false, "uid": 1003}

TASK [Add the user 'zabbix' with home /var/lib/ansible/zabbix] ******************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Zabbix Monitoring System", "create_home": true, "group": 994, "home": "/var/lib/ansible/zabbix", "name": "zabbix", "shell": "/sbin/nologin", "state": "present", "system": true, "uid": 996}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到在创建第一个用户Jenkins时，出现了警告。创建第二个用户zabbix时正常创建成功。原因就是我们刚开始的时候`/var/lib/ansible/`目录是不存在的，感觉此处是Ansible的一个bug，实际上已经将skel框架文件夹里面的文件复制到了用户的家目录里面了！如果不想有警告提示，则家目录的父目录必须是事先存在的。



#### 5.2.5 移动家目录和共用UID

在上节的基础上，我们来尝试移动zabbix的家目录，以及设置重复的UID。

先查看node1节点上面的用户情况：

```sh
[root@node1 ~]# tail -n 3 /etc/passwd
test:x:1002:1002::/home/test:/bin/bash
jenkins:x:1003:1003:Jenkins Automation Server:/var/lib/ansible/jenkins:/bin/bash
zabbix:x:996:994:Zabbix Monitoring System:/var/lib/ansible/zabbix:/sbin/nologin
[root@node1 ~]# ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   4 root    root      35 Jul 23 14:59 .
drwxr-xr-x. 27 root    root    4.0K Jul 23 11:43 ..
drwx------   2 jenkins jenkins   62 Jul 23 14:59 jenkins
drwx------   2 zabbix  zabbix    76 Jul 23 14:59 zabbix
[root@node1 ~]# ls -lah /var/lib/ansible/jenkins/
total 12K
drwx------ 2 jenkins jenkins  62 Jul 23 14:59 .
drwxr-xr-x 4 root    root     35 Jul 23 14:59 ..
-rw-r--r-- 1 jenkins jenkins  18 Oct 31  2018 .bash_logout
-rw-r--r-- 1 jenkins jenkins 193 Oct 31  2018 .bash_profile
-rw-r--r-- 1 jenkins jenkins 231 Oct 31  2018 .bashrc
[root@node1 ~]# ls -lah /var/lib/ansible/zabbix/
total 16K
drwx------ 2 zabbix zabbix  76 Jul 23 14:59 .
drwxr-xr-x 4 root   root    35 Jul 23 14:59 ..
-rw-r--r-- 1 zabbix zabbix  18 Jul 22 16:14 .bash_logout
-rw-r--r-- 1 zabbix zabbix 193 Jul 22 16:14 .bash_profile
-rw-r--r-- 1 zabbix zabbix 836 Jul 22 16:21 .bashrc
-rw-r--r-- 1 zabbix zabbix 329 Jul 22 16:16 .vimrc
[root@node1 ~]# ls -lah /home/
total 0
drwxr-xr-x.  5 root       root        51 Jul 23 14:58 .
dr-xr-xr-x. 18 root       root       240 Jul 13 15:49 ..
drwx------   7 ansible    ansible    304 Jul 22 16:19 ansible
drwx------.  2 meizhaohui meizhaohui  83 Jul 14 10:00 meizhaohui
drwx------   2 test       test        62 Jul  7 16:22 test
[root@node1 ~]# 
```

此时可以看到，我们的jenkins和zabbix用户的家目录都在`/var/lib/ansible/`目录下，jenkins的UID是1003，我们在新的剧本中需要使用这个UID。



下面我们编写一个新的剧本文件：

```sh
# 查看剧本文件内容
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    # 创建一个新的账号otherjenkins，但是与jenkins共用了一个UID
    - name: Add the user 'otherjenkins' with similar jenkins UID
      user:
        name: otherjenkins
        comment: Other Jenkins Automation Server
        home: /var/lib/ansible/other_jenkins
        # 通过non_unique指定可以设置UID不唯一
        non_unique: yes
        uid: 1003
      become: yes

    # 将zabbix用户的家目录从/var/lib/ansible/zabbix移动到/home/zabbix目录
    - name: Add the user 'zabbix' and move old home to /home/zabbix
      user:
        name: zabbix
        skeleton: /etc/skel
        home: /home/zabbix
        system: no
        shell: /bin/shell
        move_home: yes
      become: yes

# 剧本文件规范检查
[ansible@master ~]$ ansible-lint user.yml 

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************
ok: [node1]

TASK [Add the user 'otherjenkins' with similar jenkins UID] **********************************************************************************************************************
changed: [node1] => {"changed": true, "comment": "Other Jenkins Automation Server", "create_home": true, "group": 1007, "home": "/var/lib/ansible/other_jenkins", "name": "otherjenkins", "shell": "/bin/bash", "state": "present", "system": false, "uid": 1003}

TASK [Add the user 'zabbix' and move old home to /home/zabbix] ******************************************************************************************************************
changed: [node1] => {"append": false, "changed": true, "comment": "Zabbix Monitoring System", "group": 994, "home": "/home/zabbix", "move_home": true, "name": "zabbix", "shell": "/bin/shell", "state": "present", "uid": 996}

PLAY RECAP **********************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，剧本正常执行，创建了新的用户otherjenkins，并且zabbix用户也发生了变化，zabbix的家目录被移到到新的目录`/home/zabbix`目录下，我们在node1节点上面验证一下。

```sh
[root@node1 ~]# tail -n 3 /etc/passwd
jenkins:x:1003:1003:Jenkins Automation Server:/var/lib/ansible/jenkins:/bin/bash
zabbix:x:996:994:Zabbix Monitoring System:/home/zabbix:/bin/shell
othejenkins:x:1003:1007:Other Jenkins Automation Server:/var/lib/ansible/other_jenkins:/bin/bash
[root@node1 ~]# id jenkins
uid=1003(jenkins) gid=1003(jenkins) groups=1003(jenkins)
[root@node1 ~]# id otherjenkins
uid=1003(jenkins) gid=1003(jenkins) groups=1003(jenkins)
[root@node1 ~]# ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   4 root    root          42 Jul 23 15:08 .
drwxr-xr-x. 27 root    root        4.0K Jul 23 11:43 ..
drwx------   2 jenkins jenkins       62 Jul 23 14:59 jenkins
drwx------   2 jenkins othejenkins   62 Jul 23 15:08 other_jenkins
[root@node1 ~]# ls -lah /var/lib/ansible/other_jenkins/
total 12K
drwx------ 2 jenkins othejenkins  62 Jul 23 15:08 .
drwxr-xr-x 4 root    root         42 Jul 23 15:08 ..
-rw-r--r-- 1 jenkins othejenkins  18 Oct 31  2018 .bash_logout
-rw-r--r-- 1 jenkins othejenkins 193 Oct 31  2018 .bash_profile
-rw-r--r-- 1 jenkins othejenkins 231 Oct 31  2018 .bashrc
[root@node1 ~]# ls -lah /var/lib/ansible/jenkins/
total 12K
drwx------ 2 jenkins jenkins  62 Jul 23 14:59 .
drwxr-xr-x 4 root    root     42 Jul 23 15:08 ..
-rw-r--r-- 1 jenkins jenkins  18 Oct 31  2018 .bash_logout
-rw-r--r-- 1 jenkins jenkins 193 Oct 31  2018 .bash_profile
-rw-r--r-- 1 jenkins jenkins 231 Oct 31  2018 .bashrc
[root@node1 ~]# ls -lah /home/zabbix/
total 16K
drwx------  2 zabbix zabbix  76 Jul 23 14:59 .
drwxr-xr-x. 6 root   root    65 Jul 23 15:08 ..
-rw-r--r--  1 zabbix zabbix  18 Jul 22 16:14 .bash_logout
-rw-r--r--  1 zabbix zabbix 193 Jul 22 16:14 .bash_profile
-rw-r--r--  1 zabbix zabbix 836 Jul 22 16:21 .bashrc
-rw-r--r--  1 zabbix zabbix 329 Jul 22 16:16 .vimrc
[root@node1 ~]# 
```

可以看到，jenkins用户和otherjenkins用户的UID都是1003；zabbix用户的家目录从`/var/lib/ansible/zabbix`移动到`/home/zabbix`目录了，虽然我们在剧本中指定了`skeleton: /etc/skel`,由于原来的家目录是存在的，并且`move_home: yes`,因此Ansible会直接将原来的家目录中的文件移到新的家目录里面来，不会复制`/etc/skel`里面的文件。

在linux命令行，可以使用以下方式创建不同的账号共用相同的UID:

```sh
[root@node1 ~]# useradd -u 1003 -o newjenkins
[root@node1 ~]# tail -n 4 /etc/passwd|grep 1003
jenkins:x:1003:1003:Jenkins Automation Server:/var/lib/ansible/jenkins:/bin/bash
otherjenkins:x:1003:1007:Other Jenkins Automation Server:/var/lib/ansible/other_jenkins:/bin/bash
newjenkins:x:1003:1008::/home/newjenkins:/bin/bash
```

由于jenkins，otherjenkins，newjenkins共用一个UID，因此他们可以看到彼此家目录里面的文件，这有可能产生安全问题，因此尽量不要使用相同的UID。

我们把新创建的用户删除掉。

```sh
[root@node1 ~]# userdel -f -r newjenkins
[root@node1 ~]# userdel -f -r othejenkins
[root@node1 ~]# userdel -f -r jenkins
[root@node1 ~]# userdel -f -r zabbix
userdel: zabbix mail spool (/var/spool/mail/zabbix) not found
[root@node1 ~]# tail -n 3 /etc/passwd
ansible:x:1001:1001::/home/ansible:/bin/bash
mysql:x:997:995:MySQL server:/var/lib/mysql:/sbin/nologin
test:x:1002:1002::/home/test:/bin/bash
[root@node1 ~]# ls -lah /var/lib/ansible/
total 4.0K
drwxr-xr-x   2 root root    6 Jul 23 15:25 .
drwxr-xr-x. 27 root root 4.0K Jul 23 11:43 ..
[root@node1 ~]# ls -lah /home
total 0
drwxr-xr-x.  5 root       root        51 Jul 23 15:25 .
dr-xr-xr-x. 18 root       root       240 Jul 13 15:49 ..
drwx------   7 ansible    ansible    304 Jul 22 16:19 ansible
drwx------.  2 meizhaohui meizhaohui  83 Jul 14 10:00 meizhaohui
drwx------   2 test       test        62 Jul  7 16:22 test
[root@node1 ~]# 
```

可以发现测试的几个用户账号和家目录都删除了。



#### 5.2.6 SSH密钥处理

在我们创建用户的时候，也可以给用户创建密钥。SSH密钥处理主要涉及以及几个参数`generate_ssh_key`、`ssh_key_bits`、`ssh_key_comment`、`ssh_key_file`、`ssh_key_passphrase`、`ssh_key_type`等。实质上是使用`ssh-keygen`来生成密钥文件。

基础知识。

**SSH密钥类型的选择**

参考：

- [SSH密钥类型的的选择](https://www.cnblogs.com/nexiyi/archive/2013/01/06/2847865.html)
- [SSH原理与运用:远程登录](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)

> 在用 ssh-keygen 生成密钥对时，通常会面临是使用RSA还是DSA的选择：RSA or DSA, this is a question! 
>
> **原理与安全性:**
> RSA 与 DSA 都是非对称加密算法。其中RSA的安全性是基于极其困难的大整数的分解（两个素数的乘积）；DSA 的安全性是基于整数有限域离散对数难题。基本上可以认为相同密钥长度的 RSA 算法与 DSA 算法安全性相当。
>
> 有点要注意，RSA 的安全性依赖于大数分解，但是否等同于大数分解一直未能得到理论上的证明，因为没有证明破解 RSA 就一定需要作大数分解。不过也不必太过担心，RSA 从诞生以来，经历了各种攻击，至今未被完全攻破（依靠暴力破解，小于1024位密钥长度的 RSA 有被攻破的记录，但未从算法上被攻破）。
>
> **用途：**
>  DSA 只能用于数字签名，而无法用于加密（某些扩展可以支持加密）；RSA 即可作为数字签名，也可以作为加密算法。不过作为加密使用的 RSA 有着随密钥长度增加，性能急剧下降的问题。
>
> **性能：**
> 相同密钥长度下，DSA 做签名时速度更快，但做签名验证时速度较慢，一般情况验证签名的次数多于签名的次数。
> 相同密钥长度下，DSA （在扩展支持下）解密密文更快，而加密更慢；RSA 正好反过来，一般来说解密次数多于加密次数。不过由于非对称加密算法的先天性能问题，两者都不是加密的好选择。
>
> **业界支持：**
>  在业界支持方面，RSA 显然是赢家。RSA 具有更为广泛的部署与支持。
>
> 使用 ssh-keygen 时的选择：
> 上面说了那么多，可以看到RSA 与 DSA 各有优缺点。回到开头的问题，在使用 ssh-keygen 时，RSA 与 DSA到底选哪个？ 比较有意思的是，这个问题最终答案与上面那些优缺点无关。虽然理论上可以生成更长长度的 DSA 密钥 （NIST FIPS 186-3），但ssh-keygen在生成 DSA 密钥时，其长度只能为1024位（基于NIST FIPS 186-2）；而 ssh-keygen 在 RSA 的密钥长度上没有限制。
> 由于小于1024位密钥长度的 RSA 已经有被攻破的记录，所以说现在：RSA 2048 位密钥是更好的选择。
>
> **其它选择：**
>  RSA 与 DSA 各有优缺点，那有没一个更好的选择呢？答案是肯定的，ECC（Elliptic Curves Cryptography）：椭圆曲线算法。
>  ECC 与 RSA 相比，有以下的优点：
> （1）相同密钥长度下，安全性能更高，如160位ECC已经与1024位RSA、DSA有相同的安全强度。
> （2）计算量小，处理速度快，在私钥的处理速度上（解密和签名），ECC远 比RSA、DSA快得多。
> （3）存储空间占用小 ECC的密钥尺寸和系统参数与RSA、DSA相比要小得多， 所以占用的存储空间小得多。
> （4）带宽要求低使得ECC具有广泛得应用前景。
>
>  在 ssh-keygen 中，ECC 算法的相应参数是 “-t ecdsa”。可惜的是由于椭圆曲线算法只有在较新版本的 openssl 与 ssh-keygen 中才被支持，而无法得到普遍使用而去完全替代 RSA/DSA。不过由于椭圆曲线算法的优点，使其取代 RSA/DSA 而成为新一代通用的非对称加密算法成为可能，至少 SET 协议的制定者们已经把它作为下一代 SET 协议中缺省的公钥密码算法了。

注意，SSH是通过在配置文件`/etc/ssh/ssh_config`中配置`IdentityFile`来确定使用哪些文件作为密钥文件的：

```sh
[ansible@master ~]$ cat /etc/ssh/ssh_config |grep IdentityFile
#   IdentityFile ~/.ssh/identity
#   IdentityFile ~/.ssh/id_rsa
#   IdentityFile ~/.ssh/id_dsa
#   IdentityFile ~/.ssh/id_ecdsa
#   IdentityFile ~/.ssh/id_ed25519
```

即默认会在用户的家目录下面的.sssh目录查找对应的密钥文件并进行匹配。一般不需要更改，保持默认的密钥文件即可。

我们使用Ansible创建两个账号jenkins和zabbix，并分别设置相应的SSH密钥。

```sh
# 查看剧本文件
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    # 创建账号jenkins，并配置SSH密钥信息
    - name: Add the user 'jenkins' with SSH key
      user:
        name: jenkins
        comment: Jenkins Automation Server
        generate_ssh_key: yes
        ssh_key_bits: 2048
        ssh_key_type: rsa
        ssh_key_file: .ssh/id_rsa
        ssh_key_comment: jenkins@node1
      become: yes

    # 创建账号zabbix，并配置SSH密钥信息，密钥类型选择ecdsa
    - name: Add the user 'zabbix' with SSH key and passphrase
      user:
        name: zabbix
        generate_ssh_key: yes
        # ECDSA key length - valid lengths are 256, 384 or 521 bits
        ssh_key_bits: 256
        ssh_key_type: ecdsa
        ssh_key_passphrase: securePassword
        ssh_key_comment: zabbix@node1
      become: yes


# 剧本文件规范检查
[ansible@master ~]$ ansible-lint user.yml 

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook  user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'jenkins' with SSH key] *******************************************
changed: [node1] => {"changed": true, "comment": "Jenkins Automation Server", "create_home": true, "group": 1003, "home": "/home/jenkins", "name": "jenkins", "shell": "/bin/bash", "ssh_fingerprint": "2048 SHA256:oN4KshBflLTf2m0INJlj3xOMPny8H+ilO2yzYJJJ2NM jenkins@node1 (RSA)", "ssh_key_file": "/home/jenkins/.ssh/id_rsa", "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU7ALGCxLLYuSkIDEgfN1N+6hUDgmxa2iFX0YACaObgnOuJrh/Q43sE++oozqM1dfSNS7ZkLYwloR/s0glj1FZ9pOanUUtMa5FzQgVocow20QCGqRfLOmymO1NDQZh09BxcLbxE5bdoHMBEPuibcSlRiWa5Xo0wBh0ir5ggyYTMRCELNfOAgKnXvioBVHtuZ2JoFGtREek1Mx6ZIhHrPm9yy9VFMSs7gq2nFAKFaXhZq83zAmF5xDxrAeSEmyr5MhqUxRpBgKwgErp0OYUl4AlTBEGEGePTZGowXM1ae6NKrn1tfarI8UX1y8CDpX57WnMgC1+R19OcD2uIp4TyMVF jenkins@node1", "state": "present", "system": false, "uid": 1003}

TASK [Add the user 'zabbix' with SSH key and passphrase] *****************************
changed: [node1] => {"changed": true, "comment": "", "create_home": true, "group": 1004, "home": "/home/zabbix", "name": "zabbix", "shell": "/bin/bash", "ssh_fingerprint": "256 SHA256:85cWxtR0EGHT8K45abq1+RYYs/9iLGwg7hBLquFDAoQ zabbix@node1 (ECDSA)", "ssh_key_file": "/home/zabbix/.ssh/id_ecdsa", "ssh_public_key": "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBATajZfpISS2hhqoBVulYvEDpQuORp3BZ1r6tnWVlkDWPPVNNdbJpPOo94oaN25RrkyEICmDru1TOaqlCsR5ESg= zabbix@node1", "state": "present", "system": false, "uid": 1004}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，两个账号成功创建，并且返回了每个账号的公钥文件路径和名称，以及公钥文件的内容，以及相应的SSH指纹信息。

在node1节点上面检查两个用户：

```sh
[root@node1 ~]# tail -n 3 /etc/passwd
test:x:1002:1002::/home/test:/bin/bash
jenkins:x:1003:1003:Jenkins Automation Server:/home/jenkins:/bin/bash
zabbix:x:1004:1004::/home/zabbix:/bin/bash
[root@node1 ~]# ls -lah /home/jenkins/
total 12K
drwx------  3 jenkins jenkins  74 Jul 24 14:03 .
drwxr-xr-x. 7 root    root     80 Jul 24 14:03 ..
-rw-r--r--  1 jenkins jenkins  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 jenkins jenkins 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 jenkins jenkins 231 Oct 31  2018 .bashrc
drwx------  2 jenkins jenkins  38 Jul 24 14:03 .ssh
[root@node1 ~]# ls -lah /home/zabbix/
total 12K
drwx------  3 zabbix zabbix  74 Jul 24 14:03 .
drwxr-xr-x. 7 root   root    80 Jul 24 14:03 ..
-rw-r--r--  1 zabbix zabbix  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 zabbix zabbix 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 zabbix zabbix 231 Oct 31  2018 .bashrc
drwx------  2 zabbix zabbix  42 Jul 24 14:03 .ssh
[root@node1 ~]# ls -lah /home/jenkins/.ssh
total 8.0K
drwx------ 2 jenkins jenkins   38 Jul 24 14:03 .
drwx------ 3 jenkins jenkins   74 Jul 24 14:03 ..
-rw------- 1 jenkins jenkins 1.7K Jul 24 14:03 id_rsa
-rw-r--r-- 1 jenkins jenkins  395 Jul 24 14:03 id_rsa.pub
[root@node1 ~]# ls -lah /home/zabbix/.ssh
total 8.0K
drwx------ 2 zabbix zabbix  42 Jul 24 14:03 .
drwx------ 3 zabbix zabbix  74 Jul 24 14:03 ..
-rw------- 1 zabbix zabbix 314 Jul 24 14:03 id_ecdsa
-rw-r--r-- 1 zabbix zabbix 174 Jul 24 14:03 id_ecdsa.pub
[root@node1 ~]# cat /home/jenkins/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU7ALGCxLLYuSkIDEgfN1N+6hUDgmxa2iFX0YACaObgnOuJrh/Q43sE++oozqM1dfSNS7ZkLYwloR/s0glj1FZ9pOanUUtMa5FzQgVocow20QCGqRfLOmymO1NDQZh09BxcLbxE5bdoHMBEPuibcSlRiWa5Xo0wBh0ir5ggyYTMRCELNfOAgKnXvioBVHtuZ2JoFGtREek1Mx6ZIhHrPm9yy9VFMSs7gq2nFAKFaXhZq83zAmF5xDxrAeSEmyr5MhqUxRpBgKwgErp0OYUl4AlTBEGEGePTZGowXM1ae6NKrn1tfarI8UX1y8CDpX57WnMgC1+R19OcD2uIp4TyMVF jenkins@node1
[root@node1 ~]# cat /home/zabbix/.ssh/id_ecdsa.pub 
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBATajZfpISS2hhqoBVulYvEDpQuORp3BZ1r6tnWVlkDWPPVNNdbJpPOo94oaN25RrkyEICmDru1TOaqlCsR5ESg= zabbix@node1
[root@node1 ~]# 
```

可以看到通过RSA和ECC 算法得到的公钥长度是不一样的，密钥和公钥文件名称也是不一样的！注意一点ECC算法(ecdsa)支持的bit长度只能是`256, 384 or 521 bits`设置其他的值将会出现异常。



#### 5.2.7 用户密码设置

以上我们创建用户时，并没有给用户设置登陆密码，没有设置密码的用户是无法登陆到系统中的。本节我们来给用户设置密码，让用户能够登陆到系统中。

本节需要参考[https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module) 来设置用户密码。设置密码时，需要对密码进行加密处理。

我们把原文中的内容复制过来：

> **How do I generate encrypted passwords for the user module?**
>
> Ansible ad-hoc command is the easiest option:
>
> ```
> ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512', 'mysecretsalt') }}"
> ```
>
> The mkpasswd utility that is available on most Linux systems is also a great option:
>
> ```
> mkpasswd --method=sha-512
> ```
>
> If this utility is not installed on your system (e.g. you are using macOS) then you can still easily generate these passwords using Python. First, ensure that the [Passlib](https://bitbucket.org/ecollins/passlib/wiki/Home) password hashing library is installed:
>
> ```
> pip install passlib
> ```
>
> Once the library is ready, SHA512 password values can then be generated as follows:
>
> ```
> python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
> ```
>
> Use the integrated [Hashing filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#hash-filters) to generate a hashed version of a password. You shouldn’t put plaintext passwords in your playbook or host_vars; instead, use [Using Vault in playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault) to encrypt sensitive data.
>
> In OpenBSD, a similar option is available in the base system called encrypt(1):
>
> ```
> encrypt
> ```

我们参考上面的官方示例，看看如何生成加密的密码。



##### 5.2.7.1 使用临时命令生成密码

我们直接在Ansible主机上面运行上面的第一个命令：

```sh
# 使用sha512安全散列算法以及盐mysecretsalt对明文密码mypassword进行加密
[ansible@master ~]$ ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512', 'mysecretsalt') }}"
localhost | SUCCESS => {
    "msg": "$6$mysecretsalt$qJbapG68nyRab3gxvKWPUcs2g3t0oMHSHMnSKecYNpSi3CuZm.GbBqXO8BE6EI6P1JUefhA0qvD7b5LSh./PU1"
}
[ansible@master ~]$
# 使用sha512安全散列算法和随机盐对明文密码mypassword进行加密
[ansible@master ~]$ ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512') }}"
localhost | SUCCESS => {
    "msg": "$6$K/MfG1EPoZIya1rB$79Hmi5OfFL2hS51Fi/4hY.lHLYTROQCZDker8U4DGdIRrYEI640ZQKMIYAK8Pu0ry1uJ5FJcfA6wKKeI0duj4."
}

```

可以看到生成了加密的密码字符串！



##### 5.2.7.2 使用mkpasswd生成随机密码

我可查看一下`mkpasswd`的的手册页信息：

```sh
[ansible@master ~]$ man mkpasswd > mkpasswd.man
[ansible@master ~]$ cat mkpasswd.man 
MKPASSWD(1)                   General Commands Manual                   MKPASSWD(1)



NAME
       mkpasswd - generate new password, optionally apply it to a user

SYNOPSIS
       mkpasswd [ args ] [ user ]

INTRODUCTION
       mkpasswd  generates  passwords  and  can  apply them automatically to users.
       mkpasswd is based on the code from Chapter 23 of the O'Reilly book  "Explor‐
       ing Expect".

USAGE
       With no arguments, mkpasswd returns a new password.

            mkpasswd

       With a user name, mkpasswd assigns a new password to the user.

            mkpasswd don

       The passwords are randomly generated according to the flags below.


FLAGS
       The -l flag defines the length of the password.  The default is 9.  The fol‐
       lowing example creates a 20 character password.

            mkpasswd -l 20

       The -d flag defines the minimum number of digits that must be in  the  pass‐
       word.   The  default is 2.  The following example creates a password with at
       least 3 digits.

            mkpasswd -d 3

       The -c flag defines the minimum number of  lowercase  alphabetic  characters
       that must be in the password.  The default is 2.

       The  -C  flag  defines the minimum number of uppercase alphabetic characters
       that must be in the password.  The default is 2.

       The -s flag defines the minimum number of special characters that must be in
       the password.  The default is 1.

       The  -p flag names a program to set the password.  By default, /etc/yppasswd
       is used if present, otherwise /bin/passwd is used.

       The -2 flag causes characters to be chosen so that  they  alternate  between
       right  and  left  hands (qwerty-style), making it harder for anyone watching
       passwords being entered.  This can also make it easier for a password-guess‐
       ing program.

       The  -v  flag  causes  the  password-setting  interaction to be visible.  By
       default, it is suppressed.


EXAMPLE
       The following example creates a 15-character password that contains at least
       3 digits and 5 uppercase characters.

            mkpasswd -l 15 -d 3 -C 5


SEE ALSO
       "Exploring  Expect: A Tcl-Based Toolkit for Automating Interactive Programs"
       by Don Libes, O'Reilly and Associates, January 1995.

AUTHOR
       Don Libes, National Institute of Standards and Technology

       mkpasswd is in the public domain.  NIST and I  would  appreciate  credit  if
       this program or parts of it are used.





                                   22 August 1994                       MKPASSWD(1)
[ansible@master ~]$
```

上面的手册页中可以看到:

- 通过`-l`参数控制密码的长度(默认9)
- 通过`-d`参数控制密码中数字的最小个数(默认2)
- 通过`-c`参数控制密码中小写字母的最小个数(默认2)
- 通过`-C`参数控制密码中大写字母的最小个数(默认2)
- 通过`-s`参数控制密码中特殊字符的最小个数(默认1)
- 通过`-p`参数控制使用哪个程序来修改密码，默认`/bin/passwd`。
- `-2`和`-v`参数具体不怎么怎么用。

如以下命令生成长度为15，至少3个数字2个大写字母2个特殊字符的密码

```sh
[ansible@master ~]$ mkpasswd -l 15 -d 3 -C 2 -s 2
sT7yE[5cqzop$9z
```



##### 5.2.7.3 passlib的使用

安装包：

```sh
[ansible@master ~]$ sudo pip install passlib
WARNING: pip is being invoked by an old script wrapper. This will fail in a future version of pip.
Please see https://github.com/pypa/pip/issues/5599 for advice on fixing the underlying issue.
To avoid this problem you can invoke Python with '-m pip' instead of running pip directly.
Looking in indexes: https://mirrors.aliyun.com/pypi/simple/
Collecting passlib
  Downloading https://mirrors.aliyun.com/pypi/packages/11/b8/e9a78f3033228013ba8564adad8d0031bf9d39ea3acc3cdb9d55fabeb4ba/passlib-1.7.2-py2.py3-none-any.whl (507 kB)
     |████████████████████████████████| 507 kB 10.3 MB/s 
Installing collected packages: passlib
Successfully installed passlib-1.7.2
[ansible@master ~]$ whereis pip
pip: /usr/bin/pip /usr/bin/pip3.6 /usr/local/bin/pip /usr/local/bin/pip3.6
```

创建密码：
```python
[ansible@master ~]$ python3
Python 3.6.8 (default, Apr  2 2020, 13:34:55) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-39)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import getpass
>>> from passlib.hash import sha512_crypt
>>> sha512_crypt.using(rounds=5000).hash(getpass.getpass())
Password:     # 注：此处需要输入你需要加密的密码，如123456
'$6$.ol56pdud99z8Lqc$71lLw0uCDaQlwtTs1QADQZ7nk4Qasv5VtKuALuhv8oF6a9mErIE5KxV9N6Anuio0IA4glUpZaVswGpAWIrSaq1'
>>> 
>>> exit()
```

直接在命令行创建密码：
```sh
[ansible@master ~]$ python3 -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
Password: 
$6$OfOeGhmMZwVRswfh$OfU08Nj1/yAlAB4GQaUP9dx/XHID3tO9ElzdmjZ73x5piVh23eesZxAKnKfz1B/mz/I9n9Wp71gdxDxZCg67N0
[ansible@master ~]$ 
```

另外，还可以使用Ansible Vault对密码进行加密，暂时我们不用该方法，我们通过手动生成加密密码后，然后写入到剧本文件中。



我们使用Ansible的临时命令生成两个密码：

```sh
# 先用mkpasswd生成三个随机密码作为密码明文的一部分，以及加密盐
[ansible@master ~]$ mkpasswd -l 10 -d 3 -C 2 -s 0
vt5rrYX02j
[ansible@master ~]$ mkpasswd -l 10 -d 3 -C 2 -s 0
r74qbu5jTK
[ansible@master ~]$ mkpasswd -l 10 -d 3 -C 2 -s 0
yd275CfuPl

# 生成两个加密后的密码字符串
[ansible@master ~]$ ansible all -i localhost, -m debug -a "msg={{ 'jenkinsvt5rrYX02j' | password_hash('sha512', 'r74qbu5jTK') }}"
localhost | SUCCESS => {
    "msg": "$6$r74qbu5jTK$i00tB2CXSap6LmqVCrwTolPdMVUdOtF7H3hryJNvvt5Fn/LNUlTVxs2850AdofERZdVJbx8QQHWhsp/fOZy2N/"
}
[ansible@master ~]$ ansible all -i localhost, -m debug -a "msg={{ 'zabbixyd275CfuPl' | password_hash('sha512', 'r74qbu5jTK') }}"
localhost | SUCCESS => {
    "msg": "$6$r74qbu5jTK$CBQwBgsHKHwVcZ1u/xxv1UzCtiJ4gzXrZ/N416STHNkzQuSnIVLHDuRPtaXl1XN4cm1O19BfyCUmtTGq0hzxm/"
}
[ansible@master ~]$ 
```

然后，我们记录下这两个密码字符串，一个作为jenkins账号的密码，一个作为zabbix账号的密码。我们来更新一下剧本文件，增加`password`参数。

我们在执行剧本前检查一下node1节点上jenkins账号和zabbix账号的信息：

```sh
[root@node1 ~]# tail -n 2 /etc/passwd
jenkins:x:1003:1003:Jenkins Automation Server:/home/jenkins:/bin/bash
zabbix:x:1004:1004::/home/zabbix:/bin/bash
[root@node1 ~]# tail -n 2 /etc/shadow
jenkins:!!:18467:0:99999:7:::
zabbix:!!:18467:0:99999:7:::
[root@node1 ~]# 
```

可以看到，此时jenkins和zabbix账号都没有设置密码。我们现在来使用剧本来更新两个账号的密码。

```sh
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    # 创建账号jenkins，并配置SSH密钥信息
    - name: Add the user 'jenkins' with SSH key
      user:
        name: jenkins
        comment: Jenkins Automation Server
        generate_ssh_key: yes
        ssh_key_bits: 2048
        ssh_key_type: rsa
        ssh_key_file: .ssh/id_rsa
        ssh_key_comment: jenkins@node1
        password: $6$r74qbu5jTK$i00tB2CXSap6LmqVCrwTolPdMVUdOtF7H3hryJNvvt5Fn/LNUlTVxs2850AdofERZdVJbx8QQHWhsp/fOZy2N/
      become: yes

    # 创建账号zabbix，并配置SSH密钥信息，密钥类型选择ecdsa
    - name: Add the user 'zabbix' with SSH key and passphrase
      user:
        name: zabbix
        generate_ssh_key: yes
        # ECDSA key length - valid lengths are 256, 384 or 521 bits
        ssh_key_bits: 256
        ssh_key_type: ecdsa
        ssh_key_passphrase: securePassword
        ssh_key_comment: zabbix@node1
        password: $6$r74qbu5jTK$CBQwBgsHKHwVcZ1u/xxv1UzCtiJ4gzXrZ/N416STHNkzQuSnIVLHDuRPtaXl1XN4cm1O19BfyCUmtTGq0hzxm/
      become: yes

[ansible@master ~]$ ansible-lint user.yml 
[ansible@master ~]$ ansible-playbook --syntax-check user.yml

playbook: user.yml
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'jenkins' with SSH key] *******************************************
changed: [node1] => {"append": false, "changed": true, "comment": "Jenkins Automation Server", "group": 1003, "home": "/home/jenkins", "move_home": false, "name": "jenkins", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "ssh_fingerprint": "2048 SHA256:oN4KshBflLTf2m0INJlj3xOMPny8H+ilO2yzYJJJ2NM jenkins@node1 (RSA)", "ssh_key_file": "/home/jenkins/.ssh/id_rsa", "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU7ALGCxLLYuSkIDEgfN1N+6hUDgmxa2iFX0YACaObgnOuJrh/Q43sE++oozqM1dfSNS7ZkLYwloR/s0glj1FZ9pOanUUtMa5FzQgVocow20QCGqRfLOmymO1NDQZh09BxcLbxE5bdoHMBEPuibcSlRiWa5Xo0wBh0ir5ggyYTMRCELNfOAgKnXvioBVHtuZ2JoFGtREek1Mx6ZIhHrPm9yy9VFMSs7gq2nFAKFaXhZq83zAmF5xDxrAeSEmyr5MhqUxRpBgKwgErp0OYUl4AlTBEGEGePTZGowXM1ae6NKrn1tfarI8UX1y8CDpX57WnMgC1+R19OcD2uIp4TyMVF jenkins@node1", "state": "present", "uid": 1003}

TASK [Add the user 'zabbix' with SSH key and passphrase] *****************************
changed: [node1] => {"append": false, "changed": true, "comment": "", "group": 1004, "home": "/home/zabbix", "move_home": false, "name": "zabbix", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "ssh_fingerprint": "256 SHA256:85cWxtR0EGHT8K45abq1+RYYs/9iLGwg7hBLquFDAoQ zabbix@node1 (ECDSA)", "ssh_key_file": "/home/zabbix/.ssh/id_ecdsa", "ssh_public_key": "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBATajZfpISS2hhqoBVulYvEDpQuORp3BZ1r6tnWVlkDWPPVNNdbJpPOo94oaN25RrkyEICmDru1TOaqlCsR5ESg= zabbix@node1", "state": "present", "uid": 1004}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到在返回值中多了`"password": "NOT_LOGGING_PASSWORD"`,`NOT_LOGGING_PASSWORD`是密码的掩码字符串，不会显示真实的密码信息。此时我们再去node1节点看一下两个账号的信息：

```sh
[root@node1 ~]# tail -n 2 /etc/shadow
jenkins:$6$r74qbu5jTK$i00tB2CXSap6LmqVCrwTolPdMVUdOtF7H3hryJNvvt5Fn/LNUlTVxs2850AdofERZdVJbx8QQHWhsp/fOZy2N/:18467:0:99999:7:::
zabbix:$6$r74qbu5jTK$CBQwBgsHKHwVcZ1u/xxv1UzCtiJ4gzXrZ/N416STHNkzQuSnIVLHDuRPtaXl1XN4cm1O19BfyCUmtTGq0hzxm/:18467:0:99999:7:::
[root@node1 ~]# 
```

此时，可以看到在`/etc/shadow`中显示的jenkins和zabbix账号的密码加密字符串正好是我们在剧本文件中`password`字符定义的密码字符串，也和我们使用临时命令生成的加密字符串是一样的！



##### 5.2.7.4 验证密码登陆

现在我们试一下使用刚才设置的密码能不能登陆node1系统。

先检查jenkins账号：

```sh
[ansible@master ~]$ ssh jenkins@node1
jenkins@node1's password:      # <------------------- 注，此处输入jenkins的明文密码jenkinsvt5rrYX02j
Last failed login: Fri Jul 24 10:47:10 CST 2020 from 192.168.56.110 on ssh:notty
There were 2 failed login attempts since the last successful login.
[jenkins@node1 ~]$ whoami
jenkins
[jenkins@node1 ~]$ pwd
/home/jenkins
[jenkins@node1 ~]$ w
 14:22:36 up  4:07,  2 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15    9:40   0.06s  0.06s -bash
jenkins  pts/1    192.168.56.110   14:22    4.00s  0.00s  0.00s w
[jenkins@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[jenkins@node1 ~]$ ls -lah
total 12K
drwx------  3 jenkins jenkins  74 Jul 24 14:03 .
drwxr-xr-x. 7 root    root     80 Jul 24 14:03 ..
-rw-r--r--  1 jenkins jenkins  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 jenkins jenkins 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 jenkins jenkins 231 Oct 31  2018 .bashrc
drwx------  2 jenkins jenkins  38 Jul 24 14:03 .ssh
[jenkins@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

可以发现jenkins账号使用密码能够正常登陆系统！说明我们的配置是正确的！我们再检查一下zabbix账号能否正常登陆系统：

```sh
[ansible@master ~]$ ssh zabbix@node1
zabbix@node1's password:       # <------------------- 注，此处输入zabbix的明文密码zabbixyd275CfuPl
[zabbix@node1 ~]$ whoami
zabbix
[zabbix@node1 ~]$ pwd
/home/zabbix
[zabbix@node1 ~]$ w
 14:26:21 up  4:11,  2 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15    2:53   0.06s  0.06s -bash
zabbix   pts/1    192.168.56.110   14:26    5.00s  0.00s  0.00s w
[zabbix@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[zabbix@node1 ~]$ ls -lah
total 12K
drwx------  3 zabbix zabbix  74 Jul 24 14:03 .
drwxr-xr-x. 7 root   root    80 Jul 24 14:03 ..
-rw-r--r--  1 zabbix zabbix  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 zabbix zabbix 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 zabbix zabbix 231 Oct 31  2018 .bashrc
drwx------  2 zabbix zabbix  42 Jul 24 14:03 .ssh
[zabbix@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

可见zabbix也是可以正常登陆node1节点的！说明配置也是正常的！



##### 5.2.7.5 使用SSH免密登陆

上面我们成功使用密码能够登陆node1服务器，我们现在将Ansible主机上的ansible的公钥复制到node1节点的jenkins和zabbix账号下面，使ansible账号能够名密登陆到node1服务器上面的jenkins或zabbix账号里。我们来部署一下。

在复制前，我们检查一下node1节点上jenkins或zabbix账号的.ssh目录文件情况：

```sh
[root@node1 ~]# ls -lah /home/jenkins/.ssh/
total 8.0K
drwx------ 2 jenkins jenkins   38 Jul 24 14:48 .
drwx------ 3 jenkins jenkins   95 Jul 24 14:23 ..
-rw------- 1 jenkins jenkins 1.7K Jul 24 14:03 id_rsa
-rw-r--r-- 1 jenkins jenkins  395 Jul 24 14:03 id_rsa.pub
[root@node1 ~]# ls -lah /home/zabbix/.ssh/
total 8.0K
drwx------ 2 zabbix zabbix  42 Jul 24 14:03 .
drwx------ 3 zabbix zabbix  95 Jul 24 14:26 ..
-rw------- 1 zabbix zabbix 314 Jul 24 14:03 id_ecdsa
-rw-r--r-- 1 zabbix zabbix 174 Jul 24 14:03 id_ecdsa.pub
[root@node1 ~]# 
```

需要使用ssh-copy-id命令,将本地公钥信息复制到node1节点上面：

```sh
[ansible@master ~]$ ssh-copy-id jenkins@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
jenkins@node1's password:       # <------------------- 注，此处输入jenkins的明文密码jenkinsvt5rrYX02j

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'jenkins@node1'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ ssh jenkins@node1
Last login: Fri Jul 24 14:22:14 2020 from 192.168.56.110
[jenkins@node1 ~]$ whoami
jenkins
[jenkins@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[jenkins@node1 ~]$ w
 14:53:51 up  4:38,  2 users,  load average: 0.00, 0.02, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15    3:51   0.07s  0.07s -bash
jenkins  pts/1    192.168.56.110   14:53    7.00s  0.00s  0.00s w
[jenkins@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

可以看到能够正常使用jenkins账号免密登陆到node1节点。我们再来配置一下zabbix账号的免密登陆。

```sh
[ansible@master ~]$ ssh-copy-id zabbix@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
zabbix@node1's password:        # <------------------- 注，此处输入zabbix的明文密码zabbixyd275CfuPl

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'zabbix@node1'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ ssh zabbix@node1
Last login: Fri Jul 24 14:26:10 2020 from 192.168.56.110
[zabbix@node1 ~]$ whoami
zabbix
[zabbix@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15
[zabbix@node1 ~]$ w
 15:01:27 up  4:46,  2 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15   11:27   0.07s  0.07s -bash
zabbix   pts/1    192.168.56.110   15:01    3.00s  0.00s  0.00s w
[zabbix@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

可以看到使用zabbix账号免密登陆到node1节点也成功了！

我们再来看一下node1节点上面的变化：

```sh
[root@node1 ~]# ls -lah /home/jenkins/.ssh/
total 12K
drwx------ 2 jenkins jenkins   61 Jul 24 14:53 .
drwx------ 3 jenkins jenkins   95 Jul 24 14:23 ..
-rw------- 1 jenkins jenkins  411 Jul 24 14:53 authorized_keys
-rw------- 1 jenkins jenkins 1.7K Jul 24 14:03 id_rsa
-rw-r--r-- 1 jenkins jenkins  395 Jul 24 14:03 id_rsa.pub
[root@node1 ~]# ls -lah /home/zabbix/.ssh/
total 12K
drwx------ 2 zabbix zabbix  65 Jul 24 15:01 .
drwx------ 3 zabbix zabbix  95 Jul 24 14:26 ..
-rw------- 1 zabbix zabbix 411 Jul 24 15:01 authorized_keys
-rw------- 1 zabbix zabbix 314 Jul 24 14:03 id_ecdsa
-rw-r--r-- 1 zabbix zabbix 174 Jul 24 14:03 id_ecdsa.pub
[root@node1 ~]# cat /home/jenkins/.ssh/authorized_keys 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VSbn9mfA755j1q3I+rdCzgioL69jrq/JmVT5WPzaUrhpEmAt7M7TLYFCzkOLE7pwat60wWIseDz5hPHat+bp77588yvmwX/qg0kFohFyYARcDgfqOmJ0l51BsqrPSiq72AmqBP+xqKF6AjeMb9W6tblkxCiu8ScNjl7U5Fxi0For32OO/IdyU9y3XC1FRCNQi6dVV06GCeuc3Jl85SsA1MrpqbrjjbUS1mgi+hPieiZMa6Bw3c5jxGcPmT5VYODHtBPGkayUK3TDfVki/EmRkcdBMlgKO300Z8DBuEwimiivf5QPkGFBj4QfNjQeLsHvU95VkLppUpwK2iB10dGz ansible-master@192.168.56.110
[root@node1 ~]# cat /home/zabbix/.ssh/authorized_keys 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VSbn9mfA755j1q3I+rdCzgioL69jrq/JmVT5WPzaUrhpEmAt7M7TLYFCzkOLE7pwat60wWIseDz5hPHat+bp77588yvmwX/qg0kFohFyYARcDgfqOmJ0l51BsqrPSiq72AmqBP+xqKF6AjeMb9W6tblkxCiu8ScNjl7U5Fxi0For32OO/IdyU9y3XC1FRCNQi6dVV06GCeuc3Jl85SsA1MrpqbrjjbUS1mgi+hPieiZMa6Bw3c5jxGcPmT5VYODHtBPGkayUK3TDfVki/EmRkcdBMlgKO300Z8DBuEwimiivf5QPkGFBj4QfNjQeLsHvU95VkLppUpwK2iB10dGz ansible-master@192.168.56.110
[root@node1 ~]# 
```

我们可以看一下ansible账号的公钥信息：

```sh
[ansible@master ~]$ cat ~/.ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/VSbn9mfA755j1q3I+rdCzgioL69jrq/JmVT5WPzaUrhpEmAt7M7TLYFCzkOLE7pwat60wWIseDz5hPHat+bp77588yvmwX/qg0kFohFyYARcDgfqOmJ0l51BsqrPSiq72AmqBP+xqKF6AjeMb9W6tblkxCiu8ScNjl7U5Fxi0For32OO/IdyU9y3XC1FRCNQi6dVV06GCeuc3Jl85SsA1MrpqbrjjbUS1mgi+hPieiZMa6Bw3c5jxGcPmT5VYODHtBPGkayUK3TDfVki/EmRkcdBMlgKO300Z8DBuEwimiivf5QPkGFBj4QfNjQeLsHvU95VkLppUpwK2iB10dGz ansible-master@192.168.56.110
```

可以看出，实质上使用`ssh-copy-id`是将ansible账号的公钥文件`~/.ssh/id_rsa.pub `内容复制到node1节点上对应账号的`~/.ssh/authorized_keys`文件中。



#### 5.2.8 SSH密钥指定不同的密钥文件

前面我们使用了默认的密钥文件来处理SSH相关的问题，我们现在来尝试修改一下默认的密钥文件配置，使用一个非默认的名称作为密钥名称。

我们新创建两个账号，这样与前面的测试账号相互独立，互不影响。

我们更新一下剧本文件，两个账号中都指定一下`ssh_key_file`参数。

```sh
# 查看剧本文件
[ansible@master ~]$ cat user.yml 
- hosts: node1
  tasks:
    # 创建账号otherjenkins，并配置SSH密钥信息
    - name: Add the user 'otherjenkins' with SSH key
      user:
        name: otherjenkins
        comment: Other Jenkins Automation Server
        generate_ssh_key: yes
        ssh_key_bits: 2048
        ssh_key_type: rsa
        ssh_key_passphrase: securePassword
        ssh_key_file: .ssh/other_id_rsa
        ssh_key_comment: otherjenkins@node1
        password: $6$r74qbu5jTK$i00tB2CXSap6LmqVCrwTolPdMVUdOtF7H3hryJNvvt5Fn/LNUlTVxs2850AdofERZdVJbx8QQHWhsp/fOZy2N/
      become: yes

    # 创建账号otherzabbix，并配置SSH密钥信息，密钥类型选择ecdsa
    - name: Add the user 'otherzabbix' with SSH key and passphrase
      user:
        name: otherzabbix
        generate_ssh_key: yes
        # ECDSA key length - valid lengths are 256, 384 or 521 bits
        ssh_key_bits: 384
        ssh_key_type: ecdsa
        ssh_key_passphrase: securePassword
        ssh_key_file: .ssh/other_id_ecdsa
        ssh_key_comment: otherzabbix@node1
        password: $6$r74qbu5jTK$CBQwBgsHKHwVcZ1u/xxv1UzCtiJ4gzXrZ/N416STHNkzQuSnIVLHDuRPtaXl1XN4cm1O19BfyCUmtTGq0hzxm/
      become: yes
[ansible@master ~]$ 
# 检查剧本文件规范
[ansible@master ~]$ ansible-lint user.yml 

# 检查剧本文件语法
[ansible@master ~]$ ansible-playbook --syntax-check user.yml 

playbook: user.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook user.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the user 'otherjenkins' with SSH key] **************************************
changed: [node1] => {"changed": true, "comment": "Other Jenkins Automation Server", "create_home": true, "group": 1007, "home": "/home/otherjenkins", "name": "otherjenkins", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "ssh_fingerprint": "2048 SHA256:lLG1EEuNOTEJDX2XPO8VRDbQjAHqcIhlA+Idln3g9tQ otherjenkins@node1 (RSA)", "ssh_key_file": "/home/otherjenkins/.ssh/other_id_rsa", "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw7gIfGQ76QgzdxxEC6eHvEszfSCOfbnQpr0IvxV6rIKqu+2bWZrs+btuSinncABz9KczxmHfIS5t/yzYVLFR3sAR1A2CBk03PkszOSel9R7JFJN/ddYXbfBrcmpg9MyvZs58WKVlRAh//fOEYIterqK6+MB2fvnAcM/uRqbpLqC9wbKa4U7lfVngrz0/Lhl9jFTlS4LofdU1lsDP1ubAXL8643ebJC86trjc2wgWedi1/kWjyhjZ4kSNuU1R+uPN53+l56XQF+PcMp2wJ19zTCxVAdlETteXIOwXJogkVmDkVVHRiQ0VeDDL7X/vxNDkN0QYm3MrlQDRr0iIDfvof otherjenkins@node1", "state": "present", "system": false, "uid": 1005}

TASK [Add the user 'otherzabbix' with SSH key and passphrase] ************************
changed: [node1] => {"changed": true, "comment": "", "create_home": true, "group": 1008, "home": "/home/otherzabbix", "name": "otherzabbix", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "ssh_fingerprint": "384 SHA256:GyGOaNT9QUztEvtN6erdOb08/IwBJACMsRJmWAx1aH0 otherzabbix@node1 (ECDSA)", "ssh_key_file": "/home/otherzabbix/.ssh/other_id_ecdsa", "ssh_public_key": "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBDT1+TWcZyPsrhe9gNw1uiMj7l4zfnnFBKlJ2CPlfltRIpQ+5rWX4B97veUtsSJppZwpj2Ei6rIqVFOoCerpNTcolcBhrarllwm59xH5cc8HsfT1zGu634IHGHI6SgR1Cg== otherzabbix@node1", "state": "present", "system": false, "uid": 1006}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，正常执行，我们现在在node1节点上面看一下这两个账号的.ssh文件夹里面的文件信息：

```sh
[root@node1 ~]# ls -lah /home/otherjenkins/.ssh/
total 8.0K
drwx------ 2 otherjenkins otherjenkins   50 Jul 24 15:33 .
drwx------ 3 otherjenkins otherjenkins   74 Jul 24 15:33 ..
-rw------- 1 otherjenkins otherjenkins 1.8K Jul 24 15:33 other_id_rsa
-rw-r--r-- 1 otherjenkins otherjenkins  400 Jul 24 15:33 other_id_rsa.pub
[root@node1 ~]# ls -lah /home/otherzabbix/.ssh/
total 8.0K
drwx------ 2 otherzabbix otherzabbix  54 Jul 24 15:33 .
drwx------ 3 otherzabbix otherzabbix  74 Jul 24 15:33 ..
-rw------- 1 otherzabbix otherzabbix 379 Jul 24 15:33 other_id_ecdsa
-rw-r--r-- 1 otherzabbix otherzabbix 223 Jul 24 15:33 other_id_ecdsa.pub
[root@node1 ~]# 
```

我们一样的，像jenkins账号、zabbix账号一样，尝试使用密码登陆：

```sh
[ansible@master ~]$ ssh otherjenkins@node1
otherjenkins@node1's password:        # <------------------- 注，此处输入otherjenkins的明文密码jenkinsvt5rrYX02j
[otherjenkins@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[otherjenkins@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
[ansible@master ~]$ ssh otherzabbix@node1
otherzabbix@node1's password:         # <------------------- 注，此处输入otherzabbix的明文密码zabbixyd275CfuPl
[otherzabbix@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[otherzabbix@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

此时，可以看到，使用密码方式登陆正常。

现在我们也复制一下ansible账号的公钥到这两个账号上面去，看看能不能免密登陆！

```sh
[ansible@master ~]$ ssh-copy-id otherjenkins@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
otherjenkins@node1's password: 
[ansible@master ~]$ ^C
[ansible@master ~]$ 
[ansible@master ~]$ 
[ansible@master ~]$ ssh-copy-id otherjenkins@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
otherjenkins@node1's password:         # <------------------- 注，此处输入otherjenkins的明文密码jenkinsvt5rrYX02j

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'otherjenkins@node1'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ ssh otherjenkins@node1
Last login: Fri Jul 24 15:38:32 2020 from 192.168.56.110
[otherjenkins@node1 ~]$ whoami
otherjenkins
[otherjenkins@node1 ~]$ hostname -I
192.168.56.111 10.0.3.15 
[otherjenkins@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ ssh-copy-id otherzabbix@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
otherzabbix@node1's password:          # <------------------- 注，此处输入otherzabbix的明文密码zabbixyd275CfuPl

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'otherzabbix@node1'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ whoami
ansible
[ansible@master ~]$ hostname -I
192.168.56.110 10.0.3.15 
[ansible@master ~]$ exit
exit
[root@master ~]# 
```

可以看到此时也可以正常的免密登陆到远程主机！

此时检查node1节点上面两个账号的.ssh目录下的文件信息：

```sh
[root@node1 ~]# ls -lah /home/otherjenkins/.ssh/
total 12K
drwx------ 2 otherjenkins otherjenkins   73 Jul 24 15:41 .
drwx------ 3 otherjenkins otherjenkins   95 Jul 24 15:38 ..
-rw------- 1 otherjenkins otherjenkins  411 Jul 24 15:41 authorized_keys
-rw------- 1 otherjenkins otherjenkins 1.8K Jul 24 15:33 other_id_rsa
-rw-r--r-- 1 otherjenkins otherjenkins  400 Jul 24 15:33 other_id_rsa.pub
[root@node1 ~]# ls -lah /home/otherzabbix/.ssh/
total 12K
drwx------ 2 otherzabbix otherzabbix  77 Jul 24 15:42 .
drwx------ 3 otherzabbix otherzabbix  95 Jul 24 15:39 ..
-rw------- 1 otherzabbix otherzabbix 411 Jul 24 15:42 authorized_keys
-rw------- 1 otherzabbix otherzabbix 379 Jul 24 15:33 other_id_ecdsa
-rw-r--r-- 1 otherzabbix otherzabbix 223 Jul 24 15:33 other_id_ecdsa.pub
```

我们现在再测试一下，使用jenkins、otherjenkins、zabbix、otherzabbix账号能不能免密连接到master主机，以确定这些密钥都是可用的。

```sh
# jenkins能进行复制,并且可以正常免密登陆
[root@node1 ~]# su jenkins
[jenkins@node1 root]$ cd
[jenkins@node1 ~]$ ssh-copy-id ansible@192.168.56.110
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/jenkins/.ssh/id_rsa.pub"
The authenticity of host '192.168.56.110 (192.168.56.110)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@192.168.56.110's password:     # <------------------- 注，此处输入ansible的明文密码securepasswd

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@192.168.56.110'"
and check to make sure that only the key(s) you wanted were added.

[jenkins@node1 ~]$ ssh ansible@192.168.56.110
Last failed login: Fri Jul 24 15:56:38 CST 2020 from node1 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Fri Jul 24 10:16:40 2020
[ansible@master ~]$ w
 15:58:00 up  5:42,  2 users,  load average: 0.24, 0.06, 0.06
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15   14:48   0.01s  0.01s -bash
ansible  pts/1    node1            15:57    0.00s  0.00s  0.00s w
[ansible@master ~]$ hostname -I
192.168.56.110 10.0.3.15 
[ansible@master ~]$ exit
logout
Connection to 192.168.56.110 closed.
[jenkins@node1 ~]$ 
[jenkins@node1 ~]$ exit
exit
[root@node1 ~]# 

# zabbix能进行复制,并且可以正常免密登陆,但是由于我们之前给zabbix账号设置了口令，因此需要输入.ssh/id_ecdsa的口令securePassword
[root@node1 ~]# su zabbix
[zabbix@node1 root]$ cd
[zabbix@node1 ~]$ ssh-copy-id ansible@192.168.56.110
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/zabbix/.ssh/id_ecdsa.pub"
The authenticity of host '192.168.56.110 (192.168.56.110)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@192.168.56.110's password:      # <------------------- 注，此处输入ansible的明文密码securepasswd

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@192.168.56.110'"
and check to make sure that only the key(s) you wanted were added.

[zabbix@node1 ~]$ ssh ansible@192.168.56.110
Enter passphrase for key '/home/zabbix/.ssh/id_ecdsa':     # <-------- 注，此处输入id_ecdsa的口令securePassword，注意，与剧本中"ssh_key_passphrase: securePassword"对应
Last login: Fri Jul 24 15:57:57 2020 from node1
[ansible@master ~]$ w
 16:01:48 up  5:46,  2 users,  load average: 0.01, 0.03, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15   18:36   0.01s  0.01s -bash
ansible  pts/1    node1            16:01    4.00s  0.00s  0.00s w
[ansible@master ~]$ hostname -I
192.168.56.110 10.0.3.15 
[ansible@master ~]$ exit
logout
Connection to 192.168.56.110 closed.
[zabbix@node1 ~]$ exit
exit
[root@node1 ~]# 

# otherjenkins不能进行复制
[root@node1 ~]# su otherjenkins
[otherzabbix@node1 root]$ cd
[otherjenkins@node1 ~]$ ssh-copy-id ansible@192.168.56.110

/usr/bin/ssh-copy-id: ERROR: failed to open ID file '/home/otherjenkins/.pub': No such file or directory
	(to install the contents of '/home/otherjenkins/.pub' anyway, look at the -f option)
[otherjenkins@node1 ~]$ 
[otherjenkins@node1 ~]$ exit
exit

# otherzabbix不能进行复制
[root@node1 ~]# su otherzabbix
[otherzabbix@node1 root]$ cd
[otherzabbix@node1 ~]$ ssh-copy-id ansible@192.168.56.110

/usr/bin/ssh-copy-id: ERROR: failed to open ID file '/home/otherzabbix/.pub': No such file or directory
	(to install the contents of '/home/otherzabbix/.pub' anyway, look at the -f option)
[otherzabbix@node1 ~]$ exit
exit
```

可以看到，默认情况下，Ansible并不会管你设置的`ssh_key_file`是不是正确的！

有可能我们使用`ssh-copy-id`的姿势不对，我们使用`-i identity_file`参数来指定密钥文件，下面是`ssh-copy-id`手册页中的内容：

>      -i identity_file
>              Use only the key(s) contained in identity_file (rather than looking
>              for identities via ssh-add(1) or in the default_ID_file).  If the
>              filename does not end in .pub this is added.  If the filename is omit‐
>              ted, the default_ID_file is used.
>     
>              Note that this can be used to ensure that the keys copied have the
>              comment one prefers and/or extra options applied, by ensuring that the
>              key file has these set as preferred before the copy is attempted.

我们增加参数试一试：
```sh
[otherjenkins@node1 ~]$ ssh-copy-id -i ~/.ssh/other_id_rsa ansible@192.168.56.110
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/otherjenkins/.ssh/other_id_rsa.pub"
The authenticity of host '192.168.56.110 (192.168.56.110)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@192.168.56.110's password:       # <------------------- 注，此处输入ansible的明文密码securepasswd

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@192.168.56.110'"
and check to make sure that only the key(s) you wanted were added.

[otherjenkins@node1 ~]$ ssh ansible@192.168.56.110
ansible@192.168.56.110's password: 
Last failed login: Fri Jul 24 16:22:37 CST 2020 from node1 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Fri Jul 24 16:01:33 2020 from node1
[ansible@master ~]$ exit
logout
Connection to 192.168.56.110 closed.
[otherjenkins@node1 ~]$ 
```

可以看到，这个时候，虽然看起来可以使用`ssh 'ansible@192.168.56.110'`直接连接到Ansible主机，但实际上还是让我们输入密码，说明ssh连接时并没有读到我们的密钥文件！我们看一下ssh是不是也需要指定密钥文件才能免密登陆。

我们查看一下帮助信息：

```sh
[otherjenkins@node1 ~]$ ssh -h
unknown option -- h
usage: ssh [-1246AaCfGgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
           [-D [bind_address:]port] [-E log_file] [-e escape_char]
           [-F configfile] [-I pkcs11] [-i identity_file]
           [-J [user@]host[:port]] [-L address] [-l login_name] [-m mac_spec]
           [-O ctl_cmd] [-o option] [-p port] [-Q query_option] [-R address]
           [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]]
           [user@]hostname [command]
```

查看手册页可以发现：

>      -i identity_file
>              Selects a file from which the identity (private key) for public key
>              authentication is read.  The default is ~/.ssh/identity for protocol
>              version 1, and ~/.ssh/id_dsa, ~/.ssh/id_ecdsa, ~/.ssh/id_ed25519 and
>              ~/.ssh/id_rsa for protocol version 2.  Identity files may also be
>              specified on a per-host basis in the configuration file.  It is possi‐
>              ble to have multiple -i options (and multiple identities specified in
>              configuration files).  If no certificates have been explicitly speci‐
>              fied by the CertificateFile directive, ssh will also try to load cer‐
>              tificate information from the filename obtained by appending -cert.pub
>              to identity filenames.

即，我们可以通过`-i`参数来指定密钥文件，我们试一下：

```sh
[otherjenkins@node1 ~]$ ssh -i ~/.ssh/other_id_rsa ansible@192.168.56.110
Enter passphrase for key '/home/otherjenkins/.ssh/other_id_rsa': # <-------- 注，此处输入other_id_rsa的口令securePassword，注意，与剧本中"ssh_key_passphrase: securePassword"对应
Last login: Fri Jul 24 16:23:32 2020 from node1
[ansible@master ~]$ whoami
ansible
[ansible@master ~]$ hostname -I
192.168.56.110 10.0.3.15 
[ansible@master ~]$ w
 16:34:53 up  6:19,  2 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15   51:41   0.01s  0.01s -bash
ansible  pts/1    node1            16:34    5.00s  0.00s  0.00s w
[ansible@master ~]$ exit
logout
Connection to 192.168.56.110 closed.
[otherjenkins@node1 ~]$ 
[otherjenkins@node1 ~]$ exit
exit
[root@node1 ~]# 
```

此时，可以发现，使用`ssh-copy-id`或`ssh`时，必须指定密钥文件，要不就不能免密登陆！！！

我们再来测试一下，otherzabbix账号是不是也可以通过增加密钥文件参数来进行免密登陆：

```sh
[root@node1 ~]# su otherzabbix
[otherzabbix@node1 root]$ cd
[otherzabbix@node1 ~]$ ls -lah .ssh
total 12K
drwx------ 2 otherzabbix otherzabbix  77 Jul 24 15:42 .
drwx------ 3 otherzabbix otherzabbix  95 Jul 24 15:39 ..
-rw------- 1 otherzabbix otherzabbix 411 Jul 24 15:42 authorized_keys
-rw------- 1 otherzabbix otherzabbix 379 Jul 24 15:33 other_id_ecdsa
-rw-r--r-- 1 otherzabbix otherzabbix 223 Jul 24 15:33 other_id_ecdsa.pub

# 复制公钥文件
[otherzabbix@node1 ~]$ ssh-copy-id -i ~/.ssh/other_id_ecdsa ansible@192.168.56.110
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/otherzabbix/.ssh/other_id_ecdsa.pub"
The authenticity of host '192.168.56.110 (192.168.56.110)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@192.168.56.110's password:       # <------------------- 注，此处输入ansible的明文密码securepasswd

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@192.168.56.110'"
and check to make sure that only the key(s) you wanted were added.

[otherzabbix@node1 ~]$ 
[otherzabbix@node1 ~]$ ls ~/.ssh/other_id_ecdsa 
/home/otherzabbix/.ssh/other_id_ecdsa

# 免密登陆
[otherzabbix@node1 ~]$ ssh -i ~/.ssh/other_id_ecdsa ansible@192.168.56.110
Enter passphrase for key '/home/otherzabbix/.ssh/other_id_ecdsa': # <-------- 注，此处输入other_id_ecdsa的口令securePassword，注意，与剧本中"ssh_key_passphrase: securePassword"对应
Last login: Fri Jul 24 16:34:39 2020 from node1
[ansible@master ~]$ whoami
ansible
[ansible@master ~]$ hostname -I
192.168.56.110 10.0.3.15 
[ansible@master ~]$ w
 16:42:45 up  6:27,  2 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:15   59:33   0.01s  0.01s -bash
ansible  pts/1    node1            16:42    5.00s  0.01s  0.01s w
[ansible@master ~]$ exit
logout
Connection to 192.168.56.110 closed.
[otherzabbix@node1 ~]$ exit
exit
[root@node1 ~]# 
```

通过以上实验可以看到，如果通过`ssh_key_file`指定非默认的密钥文件，在使用`ssh-copy-id`或`ssh`时，必须通过`-i identity_file`参数指定密钥文件，如果在创建密钥文件时同时使用`ssh_key_passphrase: securePassword`参数指定密钥文件访问口令的话，在使用ssh远程连接时需要输入密钥文件对应的口令!

设置密钥文件的口令可以增加安全性，但是给我们操作拿来了麻烦，另外使用非默认的密钥文件，每次都要指定密钥文件，也是相当来说变麻烦了！



## 6. 总结

- 创建用户时，需要使用`root`权限，如果Ansible不是用远程主机上面的root账号控制远程主机的话，需要使用`become`参数进行权限提升。

- 当使用`group`或`groups`参数指定用户组时，所指定的组必须存在。

- 使用`append`追加用户组时，用户组必须已经存在。

- Ansible默认使用`/bin/bash`作为默认的用户Shell。

- `state=absent`配合`remove=yes`参数一起可以将用户删除掉。

- 可以通过`create_home`控制是否创建家目录，参数`create_home=yes`是创建家目录的，如果不需要创建家目录，设置`create_home=no`。

- `home`参数可以指定家目录的路径path，如果path对应的家目录的父目录不存在的话，Ansible会先创建对应的父目录，但此时会提示`useradd: warning: the home directory already exists.\nNot copying any file from skel directory into it.\n`信息，如果不想出现这种提示，必须是path对应的父目录是存在的！

- 通过`group`指定用户的初始用户组时，初始用户组必须存在，如果要创建用户时自动创建一个同名的初始用户组，不需要指定`group`参数。

- 指定用户登陆SHELL时，Ansible并不会去检查你指定的shell是否真实存在！

- 使用`home`和`move_home`参数可以将原来的用户家目录移到新的家目录位置。

- 使用`password`参数指定加密密码来设置用户的登陆密码。

- 如果通过`ssh_key_file`指定非默认的密钥文件，在使用`ssh-copy-id`或`ssh`时，必须通过`-i identity_file`参数指定密钥文件，如果在创建密钥文件时同时使用`ssh_key_passphrase: securePassword`参数指定密钥文件访问口令的话，在使用ssh远程连接时需要输入密钥文件对应的口令!

  

