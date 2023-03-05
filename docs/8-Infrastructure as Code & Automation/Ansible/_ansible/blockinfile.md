# blockinfile文件块模块

[[toc]]

## 1. 概述

- blockinfile模块可以在指定的文件中插入一段文本(即可以是多行)，这段文本是被标记过的，以便在以后的操作中可以通过标记找到这段文本，然后修改或者删除这段文本。
- 官方文档链接  [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html#ansible-collections-ansible-builtin-blockinfile-module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html#ansible-collections-ansible-builtin-blockinfile-module)
- blockinfile大部分参数与lineinfile模块参数相同，此处不再赘述。

## 2. 参数


| 参数                  | 描述                                                                                                 |
|-----------------------|------------------------------------------------------------------------------------------------------|
| block    string       | 需要插入的文本行                                                                                     |
| marker   string       | 标记器，默认值为`“# {mark} ANSIBLE MANAGED BLOCK”`，`{mark}`将会被`marker_begin`和`marker_end`的值替换 |
| marker_begin   string | 块开头前的标记，默认`BEGIN`                                                                           |
| marker_end   string   | 块结束时的标记，默认`END`                                                                             |

其他参数请参考官方文档。

## 3. 官方示例

```yaml
# Before Ansible 2.3, option 'dest' or 'name' was used instead of 'path'
- name: Insert/Update "Match User" configuration block in /etc/ssh/sshd_config
  ansible.builtin.blockinfile:
    path: /etc/ssh/sshd_config
    block: |
      Match User ansible-agent
      PasswordAuthentication no

- name: Insert/Update eth0 configuration stanza in /etc/network/interfaces
        (it might be better to copy files into /etc/network/interfaces.d/)
  ansible.builtin.blockinfile:
    path: /etc/network/interfaces
    block: |
      iface eth0 inet static
          address 192.0.2.23
          netmask 255.255.255.0

- name: Insert/Update configuration using a local file and validate it
  ansible.builtin.blockinfile:
    block: "{{ lookup('ansible.builtin.file', './local/sshd_config') }}"
    path: /etc/ssh/sshd_config
    backup: yes
    validate: /usr/sbin/sshd -T -f %s

- name: Insert/Update HTML surrounded by custom markers after <body> line
  ansible.builtin.blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    insertafter: "<body>"
    block: |
      <h1>Welcome to {{ ansible_hostname }}</h1>
      <p>Last updated on {{ ansible_date_time.iso8601 }}</p>

- name: Remove HTML as well as surrounding markers
  ansible.builtin.blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    block: ""

- name: Add mappings to /etc/hosts
  ansible.builtin.blockinfile:
    path: /etc/hosts
    block: |
      {{ item.ip }} {{ item.name }}
    marker: "# {mark} ANSIBLE MANAGED BLOCK {{ item.name }}"
  loop:
    - { name: host1, ip: 10.10.1.10 }
    - { name: host2, ip: 10.10.1.11 }
    - { name: host3, ip: 10.10.1.12 }
```

## 4. 脚本的使用

### 4.1 添加块

我们参照官方示例进行测试，不使用真实的服务器文件，在`/tmp`目录下临时自动新建测试文件。

```yaml
- hosts: node1
  tasks:
    - name: Insert/Update "Match User" configuration block in /tmp/sshd_config
      ansible.builtin.blockinfile:
        path: /tmp/sshd_config
        block: |
          Match User ansible-agent
          PasswordAuthentication no
        create: yes
        state: present
      become: yes
```

此处`block: |`后面有个竖线`|`，使用竖线(`|`)字符表示要保留字符串中的换行字符。

检查剧本文件并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint blockinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook blockinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Insert/Update "Match User" configuration block in /tmp/sshd_config] **********************************************
changed: [node1] => {"changed": true, "msg": "File created"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，在节点上查看新生成的文件：
```sh
[root@node1 ~]# ll /tmp/sshd_config
-rw-r--r-- 1 root root 109 Oct 30 20:35 /tmp/sshd_config
[root@node1 ~]# cat /tmp/sshd_config
# BEGIN ANSIBLE MANAGED BLOCK
Match User ansible-agent
PasswordAuthentication no
# END ANSIBLE MANAGED BLOCK
```

### 4.2 删除块

现在删除刚才添加的块。

此时只用指定`block`的值为空。
```yaml
- hosts: node1
  tasks:
    - name: Insert/Update "Match User" configuration block in /tmp/sshd_config
      ansible.builtin.blockinfile:
        path: /tmp/sshd_config
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        block: ""
        state: present
      become: yes
```

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint blockinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook blockinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Remove block in /tmp/sshd_config] ********************************************************************************
changed: [node1] => {"changed": true, "msg": "Block removed"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```
可以看到，已经提示块被删除，我们此时在节点查看一下文件内容：
```sh
[root@node1 ~]# cat /tmp/sshd_config
[root@node1 ~]#
```
可以看到，文件内容为空了。说明块已经被删除了。


### 4.3 自定义标记

```yaml
- hosts: node1
  tasks:
    - name: Insert/Update block by custom markers in /tmp/sshd_config
      ansible.builtin.blockinfile:
        path: /tmp/sshd_config
        block: |
          iface eth0 inet static
              address 192.0.2.23
                netmask 255.255.255.0
        marker: "# meizhaohui add this block {mark}"
        marker_begin: ' start ==>'
        marker_end: ' end <=='
        create: yes
        state: present
      become: yes
```

我们设计一个自定义标记，然后检查剧本并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint blockinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook blockinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Insert/Update block by custom markers in /tmp/sshd_config] *******************************************************
changed: [node1] => {"changed": true, "msg": "Block inserted"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，块插入成功，在节点上查看文件内容：
```sh
[root@node1 ~]# cat /tmp/sshd_config
# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end <==[root@node1 ~]#
```

此处可以看到，在每行开头的空格缩进保留了下来。而最后没有新增换行符。与默认的标记存在区别，最后没有自动换行。

我们修改一下剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Insert/Update block by custom markers in /tmp/sshd_config
      ansible.builtin.blockinfile:
        path: /tmp/sshd_config
        block: |
          iface eth0 inet static
              address 192.0.2.23
                netmask 255.255.255.0
        marker: "# meizhaohui add this block {mark}"
        marker_begin: ' start ==>'
        marker_end: ' end <==\n'
        create: yes
        state: present
      become: yes
```

执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-playbook blockinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Insert/Update block by custom markers in /tmp/sshd_config] *******************************************************
changed: [node1] => {"changed": true, "msg": "Block inserted"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

再次在节点上面查看：
```sh
[root@node1 tmp]# cat sshd_config
# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end <==
# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end <==

[root@node1 tmp]#
```
可以看到，此次自动在结尾标记行后面增加了换行符，并开始了新行，与默认模式有一些差异。


当我将剧本文件修改成如下内容：
```yaml
- hosts: node1
  tasks:
    - name: Insert/Update block by custom markers in /tmp/sshd_config
      ansible.builtin.blockinfile:
        path: /tmp/sshd_config
        block: |
          iface eth0 inet static
              address 192.0.2.23
                netmask 255.255.255.0
        marker: "# meizhaohui add this block {mark}"
        marker_begin: ' start ==>'
        marker_end: ' end'
        create: yes
        state: present
      become: yes
```
即去掉了`marker_end: ' end'`后面的` <==`符号，再次执行后剧本后，查看节点文件内容：
```sh
[root@node1 tmp]# cat sshd_config
# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end <==
# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end <==

# meizhaohui add this block  start ==>
iface eth0 inet static
    address 192.0.2.23
      netmask 255.255.255.0
# meizhaohui add this block  end
[root@node1 tmp]#
```
此时，可以看到，此时结束符后面会自动换行，但不会新起一行。


### 4.4 块中使用变量

编写剧本文件：
```yaml
- hosts: node1
  tasks:
  - name: Insert/Update HTML surrounded by custom markers after <body> line
    ansible.builtin.blockinfile:
      path: /tmp/index.html
      marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
      insertafter: "<body>"
      block: |
        <h1>Welcome to {{ ansible_hostname }}</h1>
        <p>Last updated on {{ ansible_date_time.iso8601 }}</p>
      create: yes
```

执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint blockinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook blockinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Insert/Update HTML surrounded by custom markers after <body> line] ***********************************************
changed: [node1] => {"changed": true, "msg": "File created"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

在节点检查新生成的`index.html`文件：
```sh
[root@node1 tmp]# cat index.html
<!-- BEGIN ANSIBLE MANAGED BLOCK -->
<h1>Welcome to node1</h1>
<p>Last updated on 2022-11-02T15:07:20Z</p>
<!-- END ANSIBLE MANAGED BLOCK -->
[root@node1 tmp]#
```
可以看到，正常获取到节点信息和当前时间信息，并写入到文件中了。

感觉使用块模块比行模块更加方便，因为有修改标记，方便确认是否是自动化操作处理的。