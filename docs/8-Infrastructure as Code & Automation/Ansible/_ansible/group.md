# group用户组模块

[[toc]]

## 1. 概要

- `group`模块，用于管理用户组。
- 对于windows系统，请使用`win_group`模块来处理。
- `group`模块参数不多。 在CentOS或Ubuntu系统上面，会使用`groupadd`、`groupdel`、`groupmod`来处理用户组。
- `group`模块官方文档[https://docs.ansible.com/ansible/latest/modules/group_module.html](https://docs.ansible.com/ansible/latest/modules/group_module.html) 。
- `group`模块源码[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/group.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/group.py) 。



## 2. 模块参数

| 参数                    | 可选值         | 默认值  | 说明                                                         |
| ----------------------- | -------------- | ------- | ------------------------------------------------------------ |
| `gid`                   |                |         | `integer`，可选，用户组的GID                                 |
| `local`                 | yes/no         | no      | `boolean`,强制使用本地命令替代项。当您要操作本地组时，这在使用集中式身份验证的环境中很有用(如使用`lgroupadd`而不是`groupadd`) ,使用本地命令时，必须确保`lgroupadd`命令存在于目标主机上，否则将抛出致命错误。 |
| `name` （**required**） |                |         | `string`，需要管理的组名。                                   |
| `non_unique`            | yes/no         | no      | `boolean`，允许设置用户组GID不唯一。和`gid`参数一起作用。不是指一个用户组可以用多个ID，而是一个GID可以用于多个用户组，即可以多个用户组对应一个GID。 |
| `state`                 | present/absent | present | 用户组是否应存在，如果状态与声明的状态不同，则采取措施。     |
| `system`                | yes/no         | no      | 用户组是否为系统用户组。                                     |



## 3. 临时命令的使用

在user模块中我们已经使用过group模块的临时命令创建过几个组，当时使用的命令是：

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

很简单，创建了三个组！

## 4. 剧本的使用

官方示例：

```yaml
- name: Ensure group "somegroup" exists
  ansible.builtin.group:
    name: somegroup
    state: present

- name: Ensure group "docker" exists with correct gid
  ansible.builtin.group:
    name: docker
    state: present
    gid: 1750
```



我们先查看一下node1节点组的情况：

```sh
[root@node1 ~]# tail -n 5 /etc/group
developers:x:1006:
jenkins:x:1003:
zabbix:x:1004:
otherjenkins:x:1007:
otherzabbix:x:1008:
```

然后使用剧本创建一个组，并创建一个用户：

```yaml
[ansible@master ~]$ cat group.yml 
- hosts: node1
  tasks:
    # 创建testers用户组
    - name: Add the group testers
      group:
        name: testers
        state: present
      become: yes

    # 创建账号tester1
    - name: Add the user tester1
      user:
        name: tester1
        groups: testers
        generate_ssh_key: yes
        # ECDSA key length - valid lengths are 256, 384 or 521 bits
        ssh_key_bits: 384
        ssh_key_type: ecdsa
        ssh_key_comment: tester1@node1
        password: $6$r74qbu5jTK$CBQwBgsHKHwVcZ1u/xxv1UzCtiJ4gzXrZ/N416STHNkzQuSnIVLHDuRPtaXl1XN4cm1O19BfyCUmtTGq0hzxm/
      become: yes
```

```sh
# 语法检查
[ansible@master ~]$ ansible-lint group.yml 

# 彩排
[ansible@master ~]$ ansible-playbook --syntax-check group.yml 

playbook: group.yml

# 执行
[ansible@master ~]$ ansible-playbook group.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Add the group testers] *********************************************************
changed: [node1] => {"changed": true, "gid": 1009, "name": "testers", "state": "present", "system": false}

TASK [Add the user tester1] **********************************************************
changed: [node1] => {"changed": true, "comment": "", "create_home": true, "group": 1010, "groups": "testers", "home": "/home/tester1", "name": "tester1", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "ssh_fingerprint": "384 SHA256:/VyClkw/9ExvkdJCZP9Ilyl9yT2JTcsM7pu9ziH++MY tester1@node1 (ECDSA)", "ssh_key_file": "/home/tester1/.ssh/id_ecdsa", "ssh_public_key": "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBHAbCKhzJG8aU09KuJlANkSK2wi/kytWEFusIv0jP+R40H0WZDA0SqBbSosO8Xxt4LIAmSw/w2wtSdPngi41EGbdsufbtrBsUH4aXTXj88hVXzLBpTxf6eVh6fZsvv3tsQ== tester1@node1", "state": "present", "system": false, "uid": 1007}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到组和用户都创建成功了！我们再在node1上面检查一下：

```sh
[root@node1 ~]# tail -n 5 /etc/group
zabbix:x:1004:
otherjenkins:x:1007:
otherzabbix:x:1008:
testers:x:1009:tester1
tester1:x:1010:
[root@node1 ~]# id tester1
uid=1007(tester1) gid=1010(tester1) groups=1010(tester1),1009(testers)
[root@node1 ~]# tail -n 1 /etc/passwd
tester1:x:1007:1010::/home/tester1:/bin/bash
[root@node1 ~]# 
```

可以看到，tester1已经加入到testers组中了！说明配置正确！