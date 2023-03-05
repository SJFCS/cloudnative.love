# lineinfile文件内容修改模块

[[toc]]

## 1. 概述

- 本模块确保文件中有特定行，或者使用反向引用的正则表达式来替换现有行。
- 如果只想修改文件的某一行，使用本模块则非常有用。
- 如果你想修改多处内容，则可以考虑使用 [replace模块](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/replace_module.html#ansible-collections-ansible-builtin-replace-module),如果更换或替换多个相似的行，或者要在文件中插入、更新、删除一个块，则可以考虑使用 [blockinfile模块](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html#ansible-collections-ansible-builtin-blockinfile-module),其他情况则建议使用 [copy模块](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#ansible-collections-ansible-builtin-copy-module) 或 [template模块](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html#ansible-collections-ansible-builtin-template-module)。
- 官方文档 [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)


## 2. 参数

| 序号 | 参数                   | 描述                                                                                                                                                                                                                                                                                                                                           |
|:-----|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | attributes   string    | 修改完文件后，文件的属性，类似使用`chattr`修改文件属性                                                                                                                                                                                                                                                                                           |
| 2    | backrefs  boolean      | 与`state=present`一起使用，默认`no`。如果设置为`yes`，则可以使用反向引用（位置引用或命名引用），如果正则表达式`regexp`匹配上，则会填充反向引用。该参数会改变模块的操作，忽略掉`insertbefore`和`insertafter`参数，如果正则表达式不能匹配到，则文件不会发生变化；如果正则匹配到了，则最后一个匹配将会被替换成`line`参数扩展的值。本参数与`search_string`参数互斥 |
| 3    | backup    boolean      | 是否备份原始文件，默认`no`                                                                                                                                                                                                                                                                                                                      |
| 4    | create  boolean        | 与`state=present`一起使用，默认`no`。如果设置为`yes`，则当文件不存在时，会创建文件。默认情况下，如果文件不存在，则作业会失败。                                                                                                                                                                                                                          |
| 5    | firstmatch  boolean    | 与`insertbefore`和`insertafter`参数一起作用，默认`no`，如果设置为`yes`，那么会处理第一次的匹配项，而不是最后的匹配项                                                                                                                                                                                                                                 |
| 6    | group  string          | 文件修改后，文件的用户组名称，类似于`chown`命令                                                                                                                                                                                                                                                                                                  |
| 7    | insertafter  string    | 与`state=present`一起使用，如果指定的话，那么会在最后一次匹配行的后一行插入行。                                                                                                                                                                                                                                                                      |
| 8    | insertbefore string    | 与`state=present`一起使用，如果指定的话，那么会在最后一次匹配行的前一行插入行。                                                                                                                                                                                                                                                                      |
| 9    | line  string           | 文件中需要插入/替换的行                                                                                                                                                                                                                                                                                                                        |
| 10   | mode  raw              | 文件修改后的模式                                                                                                                                                                                                                                                                                                                               |
| 11   | others   string        | file模块支持的其他参数，都可以用在此参数中                                                                                                                                                                                                                                                                                                      |
| 12   | owner  string          | 文件修改后，对应的文件所有者，类似于命令`chown`                                                                                                                                                                                                                                                                                                  |
| 13   | path  string           | 待修改的文件路径                                                                                                                                                                                                                                                                                                                               |
| 14   | regexp  string         | 需要在文件中查找的正则表达式。如果`state=present`，则当正则匹配成功时，只替换最后一次匹配的行。当`state=absent`时，匹配的行将会被移除。如果正则没有匹配上，那么行将会被添加到文件中。在修改行时，`regexp`通常应该匹配行的初始状态以及行替换后的状态，以确保幂等性。                                                                                        |
| 15   | search_string  string  | 在文件中第一行匹配指定文本，不必匹配整行                                                                                                                                                                                                                                                                                                         |
| 16   | se*                    | selinux相关配置，如`selevel`/`serole`/`setype`/`seuser`，本总结文档中忽略，详见官方文档                                                                                                                                                                                                                                                           |
| 17   | state  string          | 状态，可选值:absent和present（默认）                                                                                                                                                                                                                                                                                                              |
| 18   | unsafe_writes  boolean | 不安全写，默认`no`。此选项允许Ansible在原子操作失败时回退到更新文件系统对象的不安全方法                                                                                                                                                                                                                                                          |
| 19   | validate  string       | 将更新的文件复制到最终目标之前要运行的验证命令                                                                                                                                                                                                                                                                                                 |

## 3. 官方示例

```yaml
# NOTE: Before 2.3, option 'dest', 'destfile' or 'name' was used instead of 'path'
- name: Ensure SELinux is set to enforcing mode
  ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=enforcing

- name: Make sure group wheel is not in the sudoers configuration
  ansible.builtin.lineinfile:
    path: /etc/sudoers
    state: absent
    regexp: '^%wheel'

- name: Replace a localhost entry with our own
  ansible.builtin.lineinfile:
    path: /etc/hosts
    regexp: '^127\.0\.0\.1'
    line: 127.0.0.1 localhost
    owner: root
    group: root
    mode: '0644'

- name: Replace a localhost entry searching for a literal string to avoid escaping
  ansible.builtin.lineinfile:
    path: /etc/hosts
    search_string: '127.0.0.1'
    line: 127.0.0.1 localhost
    owner: root
    group: root
    mode: '0644'

- name: Ensure the default Apache port is 8080
  ansible.builtin.lineinfile:
    path: /etc/httpd/conf/httpd.conf
    regexp: '^Listen '
    insertafter: '^#Listen '
    line: Listen 8080

- name: Ensure php extension matches new pattern
  ansible.builtin.lineinfile:
    path: /etc/httpd/conf/httpd.conf
    search_string: '<FilesMatch ".php[45]?$">'
    insertafter: '^\t<Location \/>\n'
    line: '        <FilesMatch ".php[34]?$">'

- name: Ensure we have our own comment added to /etc/services
  ansible.builtin.lineinfile:
    path: /etc/services
    regexp: '^# port for http'
    insertbefore: '^www.*80/tcp'
    line: '# port for http by default'

- name: Add a line to a file if the file does not exist, without passing regexp
  ansible.builtin.lineinfile:
    path: /tmp/testfile
    line: 192.168.1.99 foo.lab.net foo
    create: yes

# NOTE: Yaml requires escaping backslashes in double quotes but not in single quotes
- name: Ensure the JBoss memory settings are exactly as needed
  ansible.builtin.lineinfile:
    path: /opt/jboss-as/bin/standalone.conf
    regexp: '^(.*)Xms(\d+)m(.*)$'
    line: '\1Xms${xms}m\3'
    backrefs: yes

# NOTE: Fully quoted because of the ': ' on the line. See the Gotchas in the YAML docs.
- name: Validate the sudoers file before saving
  ansible.builtin.lineinfile:
    path: /etc/sudoers
    state: present
    regexp: '^%ADMIN ALL='
    line: '%ADMIN ALL=(ALL) NOPASSWD: ALL'
    validate: /usr/sbin/visudo -cf %s

# See https://docs.python.org/3/library/re.html for further details on syntax
- name: Use backrefs with alternative group syntax to avoid conflicts with variable values
  ansible.builtin.lineinfile:
    path: /tmp/config
    regexp: ^(host=).*
    line: \g<1>{{ hostname }}
    backrefs: yes
```


## 4. 剧本的使用

### 4.1 SELINUX开启与关闭

查看当前node1节点的selinux配置情况：
```sh
[meizhaohui@node1 ~]$ getenforce
Disabled
[meizhaohui@node1 ~]$ grep '^SELINUX=' /etc/selinux/config
SELINUX=disabled
```

编写剧本文件`lineinfile.yml`:

```yaml
- hosts: node1
  tasks:
    - name: Enable selinux
      ansible.builtin.lineinfile:
        path: /etc/selinux/config
        regexp: '^SELINUX='
        line: SELINUX=enforcing
      become: yes
```

检查剧本语法并执行：

```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Enable selinux] *************************************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，再次在节点上面查看selinux配置情况：

```sh
[meizhaohui@node1 ~]$ grep '^SELINUX=' /etc/selinux/config
SELINUX=enforcing
```

可以看到，配置已经被修改，修改成`SELINUX=enforcing`状态，说明SELINUX开启成功。

通常情况下，我们会关闭SELINUX，使用剧本将配置还原：

```yaml
- hosts: node1
  tasks:
    - name: Disable selinux
      ansible.builtin.lineinfile:
        path: /etc/selinux/config
        regexp: '^SELINUX='
        line: SELINUX=disabled
      become: yes
```

然后再执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Disable selinux] *************************************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时查看节点配置：
```sh
[meizhaohui@node1 ~]$ grep '^SELINUX=' /etc/selinux/config
SELINUX=disabled
[meizhaohui@node1 ~]$
```

可以看到SELINUX又变成关闭状态了。

### 4.2 显示远程主机IP

- `/etc/motd`（message of to day：每日信息）文件常用于通告信息，如计划关机时间的警告等，登陆后的提示信息。
- 通过该文件，我们可以用来显示远程主机的IP信息，便于我们确定远程主机IP。

编写剧本文件`lineinfile.yml`：

```yaml
- hosts: node1
  tasks:
    - name: Set motd info
      ansible.builtin.lineinfile:
        path: /etc/motd
        regexp: '^IP:'
        line: "IP:{{ ansible_default_ipv4['address'] }}"
      become: yes
```

默认情况下，节点node1上面没有配置`/etc/motd`的内容。我们查看一下：

```sh
[meizhaohui@node1 ~]$ cat /etc/motd
```

可以看到没有内容。

检查剧本文件语法并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Set motd info] ***************************************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line added"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，查看节点的配置文件`/etc/motd`文件内容：

```sh
[meizhaohui@node1 ~]$ cat /etc/motd
IP:192.168.12.1
```

此时，重新连接node1节点时，就可以看到远程主机IP信息了：
```sh
# 此处我配置了连接node1节点的快捷命令n1
[mzh@MacBookPro docs (master ✗)]$ n1
Last login: Tue Oct 11 20:09:19 2022 from 111.111.111.111
IP:192.168.12.1
[meizhaohui@node1 ~]$
```

可以看到，正常显示了远程主机的IP信息。


### 4.3 修改nginx监听端口并校验

我们编写修改nginx监听端口的剧本文件`lineinfile.yml`，当端口修改校验通过后，执行后面的任务，重新加载nginx配置：
```yaml
- hosts: node1
  tasks:
    - name: Change nginx port from 80 to 8081
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '^        listen       80;'
        line: "        listen       8081;"
         validate: /usr/sbin/nginx -t -c %s
      become: yes

    - name: Reload Nginx server
      ansible.builtin.command:
        cmd: /usr/sbin/nginx -s reload
      become: yes
```

在执行剧本前，我们先查看一下节点node1上nginx的配置，并看一下nginx的进程信息：
```sh
[root@node1 ~]# cd /etc/nginx/
[root@node1 nginx]# grep 'listen' nginx.conf
        listen       80;
        listen       [::]:80;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
[root@node1 nginx]# ps -ef|grep nginx
root      5673     1  0 20:31 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx     7940  5673  0 20:47 ?        00:00:00 nginx: worker process
nginx     7941  5673  0 20:47 ?        00:00:00 nginx: worker process
root      8510  4951  0 20:51 pts/0    00:00:00 grep --color=auto nginx
```

::: warning 注意
在使用`validate`进行校验时，参数值中必须带`%s`信息。如果我们直接使用配置`validate: /usr/sbin/nginx -t`运行剧本，会提示`"msg": "validate must contain %s: /usr/sbin/nginx -t"`异常信息！！因此使用`validate: /usr/sbin/nginx -t -c %s`指定需要校验的配置文件。
:::


检查剧本文件语法并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Change nginx port from 80 to 8081] *******************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

TASK [Reload Nginx server] *********************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["/usr/sbin/nginx", "-s", "reload"], "delta": "0:00:00.014303", "end": "2022-10-11 20:56:38.983474", "rc": 0, "start": "2022-10-11 20:56:38.969171", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

PLAY RECAP *************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，在节点上面查看配置信息和nginx进程信息：
```sh
[root@node1 nginx]# grep 'listen' nginx.conf
        listen       8081;
        listen       [::]:80;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
[root@node1 nginx]# ps -ef|grep nginx
root      5673     1  0 20:31 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx     9916  5673  0 20:56 ?        00:00:00 nginx: worker process
nginx     9917  5673  0 20:56 ?        00:00:00 nginx: worker process
root     10113  4951  0 20:57 pts/0    00:00:00 grep --color=auto nginx
```

可以看到，配置文件更新了，并且进程也重启了！！说明我们配置的剧本生效了。

刚才，我们将监听端口从80端口修改成了8081端口，现在我们尝试还原，并将替换后值设置成一个不满足nginx要求的行信息。

```yaml
- hosts: node1
  tasks:
    - name: Change nginx port from 8081 to 80 and with unknown directive Listen
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '^        listen       8081;'
        line: "        Listen       80;"
        validate: /usr/sbin/nginx -t -c %s
      become: yes

    - name: Reload Nginx server
      ansible.builtin.command:
        cmd: /usr/sbin/nginx -s reload
      become: yes
```

检查剧本文件语法并执行：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Change nginx port from 8081 to 80 and with unknown directive Listen] *********************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "failed to validate: rc:1 error:nginx: [emerg] unknown directive \"Listen\" in /home/ansible/.ansible/tmp/ansible-tmp-1665498341.71-2122-273596304298361/tmppccYOi:39\nnginx: configuration file /home/ansible/.ansible/tmp/ansible-tmp-1665498341.71-2122-273596304298361/tmppccYOi test failed\n"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

此时，可以看到，配置文件校验失败，提示`unknown directive \"Listen\"`未指指令`Listen`，因为我们故意将`listen`写成了`Listen`，所以nginx校验配置文件失败，校验失败后，并没有直接修改真正需要修改的配置文件`/etc/nginx/nginx.conf`，即通过`validate`参数的配置，可以确保我们修改后的配置文件校验正常。

我们将`Listen`修改为`listen`,然后再执行剧本：

```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Change nginx port from 8081 to 80 and with unknown directive Listen] *********************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

TASK [Reload Nginx server] *********************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["/usr/sbin/nginx", "-s", "reload"], "delta": "0:00:00.013576", "end": "2022-10-11 22:36:23.692407", "rc": 0, "start": "2022-10-11 22:36:23.678831", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

PLAY RECAP *************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，校验成功，配置文件对应的行被替换掉。nginx服务也被重新加载。

### 4.4 其他示例

- 默认情况下，本模块只会修改最后一次匹配的行。当指定`firstmatch=yes`参数时，则会修改第一次匹配的行。
- 如果又指定`insertbefore`或`insertafter`参数的话，则会在（最后一次或第一次）匹配行的前一行或后一行插入数据。

我们以修改nginx配置文件为例，查看nginx开头10行，并搜索`Documentation`关键字，可以看到，仅第2行和第3行包含`Documentation`关键字：

```sh
[root@node1 ~]# head /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
[root@node1 ~]# grep -n 'Documentation' /etc/nginx/nginx.conf
2:#   * Official English Documentation: http://nginx.org/en/docs/
3:#   * Official Russian Documentation: http://nginx.org/ru/docs/
```

为了测试，我们需要尝试在``关键字行附近添加一个新行，新行内容是`#   * Download Nginx: http://nginx.org/en/download.html`，即增加一个下载Nginx的链接地址。

#### 4.4.1 修改最后匹配行

当我不增加位置控制参数时，会直接替换匹配行！

此处我们不指定`firstmatch=yes`参数，也不指定`insertbefore`或`insertafter`参数，看看默认的效果。本节不测试配置文件校验。

编写剧本文件`lineinfile.yml`：

```yaml
- hosts: node1
  tasks:
    - name: Add download URL to nginx conf
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: 'Documentation'
        line: "#   * Download Nginx: http://nginx.org/en/download.html"
      become: yes
```

检查剧本文件语法并执行：

```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add download URL to nginx conf] **********************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，在节点查看配置文件：

```sh
[root@node1 ~]# head /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Download Nginx: http://nginx.org/en/download.html

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
```

可以看到，我们不增加位置控制时，当正则匹配到行后，原来第3行的`#   * Official Russian Documentation: http://nginx.org/ru/docs/`被替换成了`#   * Download Nginx: http://nginx.org/en/download.html`。

#### 4.4.2 修改首次匹配行
我不想对最后一个匹配行进行替换，只想对第一个匹配进行修改，则可以增加参数`firstmatch=yes`。

我们将节点上的配置文件还原。
```sh
[root@node1 ~]# head -n 4 /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

[root@node1 ~]#
```

然后修改剧本文件：

```yaml
- hosts: node1
  tasks:
    - name: Add download URL to nginx conf
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: 'Documentation'
        line: "#   * Download Nginx: http://nginx.org/en/download.html"
        firstmatch: yes
      become: yes
```

然后，再次执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add download URL to nginx conf] **********************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line replaced"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

在节点上面查看配置文件前几行：
```sh
[root@node1 ~]# head -n 4 /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Download Nginx: http://nginx.org/en/download.html
#   * Official Russian Documentation: http://nginx.org/ru/docs/

[root@node1 ~]#
```

此时，可以看到，第2行的`#   * Official English Documentation: http://nginx.org/en/docs/`被替换成了`#   * Download Nginx: http://nginx.org/en/download.html`。

说明配置`firstmatch: yes`参数生效了，改变了Ansible的行为了。


#### 4.4.3 在指定行后插入数据

再次将节点上配置文件还原后，再进行测试。

修改后的剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Add download URL to nginx conf
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        insertafter: 'Documentation'
        line: "#   * Download Nginx: http://nginx.org/en/download.html"
      become: yes
```

执行剧本：

```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add download URL to nginx conf] **********************************************************************************
changed: [node1] => {"backup": "", "changed": true, "msg": "line added"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时查看节点上配置文件前5行：

```sh
[root@node1 ~]# head -n 5 /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/
#   * Download Nginx: http://nginx.org/en/download.html

[root@node1 ~]#
```

可以看到，第4行已经新增了一行，有了Nginx的下载链接信息了，在最后一次匹配（指定）行后增加了一行。

#### 4.4.4 在指定行前插入数据

此处我们保留上一节的修改，不手动还原。再尝试在指定行的前一行插入数据。

修改后的剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Add download URL to nginx conf
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        insertbefore: '^#   \* Official Russian Documentation: http://nginx.org/ru/docs/'
        line: "#  * Download Nginx: http://nginx.org/en/download.html"
        backup: yes
        state: present
      become: yes
```

然后，再次执行剧本，执行后的文件前几行如下：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add download URL to nginx conf] **********************************************************************************
changed: [node1] => {"backup": "/etc/nginx/nginx.conf.10326.2022-10-29@20:42:55~", "changed": true, "msg": "line added"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时在节点1上面查看`nginx.conf`的前几行：
```sh
[root@node1 ~]# head -n 6 /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#  * Download Nginx: http://nginx.org/en/download.html
#   * Official Russian Documentation: http://nginx.org/ru/docs/
#   * Download Nginx: http://nginx.org/en/download.html

[root@node1 ~]#
```
可以看到，的确是在原来的第3行的`#   * Official Russian Documentation: http://nginx.org/ru/docs/`前面增加了一行`#  * Download Nginx: http://nginx.org/en/download.html`。

特别要注意剧本中`insertbefore: '^#   \* Official Russian Documentation: http://nginx.org/ru/docs/'`处的`\*`，表示星号，如果不带反斜杠，则会匹配多个空格，此时会匹配不上。

如我们去掉这个斜杠，再执行剧本，可以看到没有变化。
```sh
[ansible@master ansible_playbooks]$ cat lineinfile.yml
- hosts: node1
  tasks:
    - name: Add download URL to nginx conf
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        insertbefore: '^#   * Official Russian Documentation: http://nginx.org/ru/docs/'
        line: "#  * Download Nginx: http://nginx.org/en/download.html"
        backup: yes
        state: present
      become: yes
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add download URL to nginx conf] **********************************************************************************
ok: [node1] => {"backup": "", "changed": false, "msg": ""}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以在节点上使用`grep`命令测试一下：
```sh
# *星号前不带反斜杠\，没有匹配上
[root@node1 ~]# grep '^#   * Official Russian Documentation: http://nginx.org/ru/docs/' /etc/nginx/nginx.conf

# *星号前带反斜杠\，匹配上一行
[root@node1 ~]# grep '^#   \* Official Russian Documentation: http://nginx.org/ru/docs/' /etc/nginx/nginx.conf
#   * Official Russian Documentation: http://nginx.org/ru/docs/
[root@node1 ~]#
```
可以看到，不带反斜杠时没有匹配上。


#### 4.4.5 在文件头部插入数据

我们尝试在文件最前面增加一行内容。

编写剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Insert the line at the beginning of the file
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        insertbefore: BOF
        line: "# The first line"
        backup: yes
        state: present
      become: yes
```

执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Insert the line at the beginning of the file] ********************************************************************
changed: [node1] => {"backup": "/etc/nginx/nginx.conf.17579.2022-10-29@21:22:22~", "changed": true, "msg": "line added"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

在节点上面查看文件开头几行：
```sh
[root@node1 ~]# head -n 5 /etc/nginx/nginx.conf
# The first line
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#  * Download Nginx: http://nginx.org/en/download.html
#   * Official Russian Documentation: http://nginx.org/ru/docs/
[root@node1 ~]#
```
可以看到已经在第一行添加了`# The first line`说明修改生效了。

#### 4.4.6 反向引用

我们使用反向引用替换文件中的行，如想将第3行中的`#   * Official English Documentation: http://nginx.org/en/docs/`替换成中文的文档信息`#   * Official Chinese Documentation: http://nginx.org/cn/docs/`。

我们可以这么做。
编写剧本文件：

```yaml
- hosts: node1
  tasks:
    - name: Add new language documentation
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '(.*)English(.*)en(.*)'
        line: '\1Chinese\2cn\3'
        backrefs: yes
        backup: yes
        state: present
      become: yes
```

执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add new language documentation] **********************************************************************************
changed: [node1] => {"backup": "/etc/nginx/nginx.conf.23537.2022-10-29@22:02:57~", "changed": true, "msg": "line replaced"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```
可以看到打印出消息`line replaced`行已经被替换。

而执行剧本前和执行剧本后，在节点上查看文件前5行的内容对比：
```sh
[root@node1 ~]# head -n 5 /etc/nginx/nginx.conf
# The first line
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#  * Download Nginx: http://nginx.org/en/download.html
#   * Official Russian Documentation: http://nginx.org/ru/docs/
[root@node1 ~]# head -n 5 /etc/nginx/nginx.conf
# The first line
# For more information on configuration, see:
#   * Official Chinese Documentation: http://nginx.org/cn/docs/
#  * Download Nginx: http://nginx.org/en/download.html
#   * Official Russian Documentation: http://nginx.org/ru/docs/
```

看看修改后的文件与备份文件的差异：
```sh
[root@node1 ~]# diff /etc/nginx/nginx.conf /etc/nginx/nginx.conf.23537.2022-10-29@22:02:57~
3c3
< #   * Official Chinese Documentation: http://nginx.org/cn/docs/
---
> #   * Official English Documentation: http://nginx.org/en/docs/
[root@node1 ~]#
```
可以看到，第3行除了`English`被替换成`Chinese`，`en`替换成了`cn`,其他部分都直接使用了原来的内容，剧本中参数`line: '\1Chinese\2cn\3'`的正则表达式`'\1Chinese\2cn\3'`中`\1`表示匹配到原来行中的第一部分`#   * Official `，而`\2`表示匹配到原来行中的第二部分` Documentation: http://nginx.org/`，而`\3`表示匹配到原来行中的第三部分`/docs/`。


#### 4.4.7 添加多行

编写剧本：

```yaml
- hosts: node1
  tasks:
    - name: Add multiple lines
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        line: "{{ item }}"
        backup: yes
        state: present
      with_items:
        - '# Orange'
        - '# Apple'
        - '# Banana'
      become: yes
```
如果还有别的行需要添加，只需要在`with_items`下面增加新的行即可。

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint lineinfile.yml
[ansible@master ansible_playbooks]$ ansible-playbook lineinfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Add multiple lines] **********************************************************************************************
changed: [node1] => (item=# Orange) => {"ansible_loop_var": "item", "backup": "/etc/nginx/nginx.conf.29943.2022-10-29@22:48:28~", "changed": true, "item": "# Orange", "msg": "line added"}
changed: [node1] => (item=# Apple) => {"ansible_loop_var": "item", "backup": "/etc/nginx/nginx.conf.30031.2022-10-29@22:48:28~", "changed": true, "item": "# Apple", "msg": "line added"}
changed: [node1] => (item=# Banana) => {"ansible_loop_var": "item", "backup": "/etc/nginx/nginx.conf.30119.2022-10-29@22:48:28~", "changed": true, "item": "# Banana", "msg": "line added"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

在节点查看配置文件最后几行：
```sh
[root@node1 ~]# tail /etc/nginx/nginx.conf
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}

# Orange
# Apple
# Banana
[root@node1 ~]#
```
可以看到，多行内容添加成功。