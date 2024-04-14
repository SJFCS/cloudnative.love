# template模块


[[toc]]

## 1. 概要

- `template`模块可以将Ansible主机上面的模板文件复制到远程被控主机上。 
- `template`模块与`copy`模块的区别是，`copy`模块会原样复制文件，而`template`模板在复制时会对模板文件进行渲染后再进行复制。
- 官方文档：[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
- 模板由Jinja2 templating language处理，也就是模板Jinja2模板语言处理。
- 模板模式的文档，可以参考 [Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates/)。
- 以下附加变量可以用于模板中。
- `ansible_managed` (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid. 包含一个字符串，可用于描述模板名称、主机、模板文件的修改时间和所有者uid。
- `template_host` contains the node name of the template’s machine.模板节点名称。
- `template_uid` is the numeric user id of the owner. 所有者的UID。
- `template_path` is the path of the template. 模板的路径。
- `template_fullpath` is the absolute path of the template. 模板的绝对路径。
- `template_destpath` is the path of the template on the remote system (added in 2.8). 模板在远程系统上面的路径。
- `template_run_date` is the date that the template was rendered. 模板渲染的时间。



## 2. 参数

| 参数                    | 可选值                 | 默认值  | 说明                                                                          |
| ----------------------- | ---------------------- | ------- | ----------------------------------------------------------------------------- |
| `attributes`            |                        |         | `string`，文件最终的属性                                                      |
| `backup`                | `true`、`false`        | `false` | `boolean`，是否创建文件备份                                                   |
| `block_end_string`      |                        | "%}"    | `string`，块结束标志                                                          |
| `block_start_string`    |                        | "\{%"   | `string`，块开始标志                                                          |
| `comment_end_string`    |                        |         | `string`，备注声明结束标志                                                    |
| `comment_start_string`  |                        |         | `string`，备注声明开始标志                                                    |
| `dest`                  |                        |         | `path`，必须字段，模板在远程主机上渲染的路径                                  |
| `follow`                | `true`、`false`        | `false` | `boolean`，是否跟随软链接                                                     |
| `force`                 | `true`、`false`        | `true`  | `boolean`，如果目标已经存在，则确定何时传输文件                               |
| `group`                 |                        |         | `string`，文件的组属性                                                        |
| `lstrip_blocks`         | `true`、`false`        | `false` | `boolean`，删除开头的空格或tab                                                |
| `mode`                  |                        |         | `any`，文件的权限模式，如`0644`、`u=rw,g=r,o=r`                               |
| `newline_sequence`      | "\\n"、"\\r"、"\\r\\n" | "\\n"   | `string`，指定用于模板文件的换行序列                                          |
| `output_encoding`       |                        | "utf-8" | `string`，目标文件的文件编码，为了同质性，源模板文件必须始终使用 utf-8 编码。 |
| `owner`                 |                        |         | `string`，文件的属主属性                                                      |
| `src`                   |                        |         | `path`必须字段，在Ansible管理主机上模板文件路径，文件必须是UTF-8编码          |
| `trim_blocks`           | `true`、`false`        | `false` | `boolean`，是否删除块后面的第一个换行符                                       |
| `validate`              |                        |         | `string`，在实际执行生效前执行校验的命令                                      |
| `variable_end_string`   |                        | "}}"    | `string`，模板中变量结束标记                                                  |
| `variable_start_string` |                        | "\{\{"  | `string`，模板中变量开始标记                                                  |

## 3. 官方示例

```yaml
- name: Template a file to /etc/file.conf
  ansible.builtin.template:
    src: /mytemplates/foo.j2
    dest: /etc/file.conf
    owner: bin
    group: wheel
    mode: '0644'

- name: Template a file, using symbolic modes (equivalent to 0644)
  ansible.builtin.template:
    src: /mytemplates/foo.j2
    dest: /etc/file.conf
    owner: bin
    group: wheel
    mode: u=rw,g=r,o=r

- name: Copy a version of named.conf that is dependent on the OS. setype obtained by doing ls -Z /etc/named.conf on original file
  ansible.builtin.template:
    src: named.conf_{{ ansible_os_family }}.j2
    dest: /etc/named.conf
    group: named
    setype: named_conf_t
    mode: 0640

- name: Create a DOS-style text file from a template
  ansible.builtin.template:
    src: config.ini.j2
    dest: /share/windows/config.ini
    newline_sequence: '\r\n'

- name: Copy a new sudoers file into place, after passing validation with visudo
  ansible.builtin.template:
    src: /mine/sudoers
    dest: /etc/sudoers
    validate: /usr/sbin/visudo -cf %s

- name: Update sshd configuration safely, avoid locking yourself out
  ansible.builtin.template:
    src: etc/ssh/sshd_config.j2
    dest: /etc/ssh/sshd_config
    owner: root
    group: root
    mode: '0600'
    validate: /usr/sbin/sshd -t -f %s
    backup: yes
```

## 4. 剧本的使用

我们参照官方示例进行一些测试。

### 4.1 附加变量的使用

剧本文件如下：
```yaml
- hosts: node1
  tasks:
    - name: Template a file to /etc/file.conf
      ansible.builtin.template:
        src: /home/ansible/ansible_playbooks/mytemplates/foo.j2
        dest: /etc/file.conf
        owner: bin
        group: wheel
        mode: '0644'
      become: yes

```

查看`foo.j2`文件：

```sh
[ansible@master ansible_playbooks]$ cat mytemplates/foo.j2
# this is foo.j2 template
{{ ansible_managed }} (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid.
{{ template_host }} contains the node name of the template’s machine.
{{ template_uid }} is the numeric user id of the owner.
{{ template_path }} is the path of the template.
{{ template_fullpath }} is the absolute path of the template.
{{ template_destpath }} is the path of the template on the remote system (added in 2.8).
{{ template_run_date }} is the date that the template was rendered.

[ansible@master ansible_playbooks]$
```

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint template.yml
[ansible@master ansible_playbooks]$ ansible-playbook template.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Template a file to /etc/file.conf] *******************************************************************************
changed: [node1] => {"changed": true, "checksum": "cc8cc5fe90a021e969e45d5fbd557747f7c76292", "dest": "/etc/file.conf", "gid": 10, "group": "wheel", "md5sum": "906ff80444e5060b72253961d1c8f2a7", "mode": "0644", "owner": "bin", "size": 653, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1677019726.88-14563-141905969605338/source", "state": "file", "uid": 1}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，剧本执行完成。文件成功复制到node1节点。

此时在node1节点上验证一下：
```sh
[root@node1 ~]# cat /etc/file.conf
# this is foo.j2 template
Ansible managed (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid.
master contains the node name of the template’s machine.
ansible is the numeric user id of the owner.
/home/ansible/ansible_playbooks/mytemplates/foo.j2 is the path of the template.
/home/ansible/ansible_playbooks/mytemplates/foo.j2 is the absolute path of the template.
/etc/file.conf is the path of the template on the remote system (added in 2.8).
2023-02-22 06:48:46.905245 is the date that the template was rendered.

[root@node1 ~]# ll /etc/file.conf
-rw-r--r-- 1 bin wheel 653 Feb 22 06:48 /etc/file.conf
[root@node1 ~]#
```

通过查看文件内容、文件属性情况可知，在`foo.j2`文件中配置的附件变量都被正常的渲染，复制到节点后，文件内容已经变成渲染后的信息了。


### 4.2 校验模板文件名后缀文件备份

- 模板文件不需要以`.j2`后缀结尾。

我们修改一下剧本文件：
```yaml
- hosts: node1
  tasks:
    - name: Template a file to /etc/file.conf
      ansible.builtin.template:
        src: /home/ansible/ansible_playbooks/mytemplates/foo
        dest: /etc/file.conf
        owner: bin
        group: wheel
        mode: '0644'
        backup: true
      become: yes
```

然后再执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint template.yml
[ansible@master ansible_playbooks]$ ansible-playbook template.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Template a file to /etc/file.conf] *******************************************************************************
changed: [node1] => {"backup_file": "/etc/file.conf.466.2023-02-22@07:15:23~", "changed": true, "checksum": "221f3f5fc94776fa085f496ac607a762f9e096ae", "dest": "/etc/file.conf", "gid": 10, "group": "wheel", "md5sum": "9a1840f5160388fbce6d7a1c95823412", "mode": "0644", "owner": "bin", "size": 647, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1677021322.92-18240-53394303783237/source", "state": "file", "uid": 1}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到执行成功。

再在节点上检查一下：
```sh
[root@node1 ~]# ll /etc/file.conf*
-rw-r--r-- 1 bin wheel 647 Feb 22 07:15 /etc/file.conf
-rw-r--r-- 1 bin wheel 653 Feb 22 06:48 /etc/file.conf.466.2023-02-22@07:15:23~
[root@node1 ~]# cat /etc/file.conf
# this is foo.j2 template
Ansible managed (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid.
master contains the node name of the template’s machine.
ansible is the numeric user id of the owner.
/home/ansible/ansible_playbooks/mytemplates/foo is the path of the template.
/home/ansible/ansible_playbooks/mytemplates/foo is the absolute path of the template.
/etc/file.conf is the path of the template on the remote system (added in 2.8).
2023-02-22 07:15:22.946431 is the date that the template was rendered.

[root@node1 ~]# diff /etc/file.conf /etc/file.conf.466.2023-02-22@07\:15\:23~
5,6c5,6
< /home/ansible/ansible_playbooks/mytemplates/foo is the path of the template.
< /home/ansible/ansible_playbooks/mytemplates/foo is the absolute path of the template.
---
> /home/ansible/ansible_playbooks/mytemplates/foo.j2 is the path of the template.
> /home/ansible/ansible_playbooks/mytemplates/foo.j2 is the absolute path of the template.
8c8
< 2023-02-22 07:15:22.946431 is the date that the template was rendered.
---
> 2023-02-22 06:48:46.905245 is the date that the template was rendered.
[root@node1 ~]#
```

可以看到，原来存在的文件已经备份了，并生成了新的文件，新的文件内容也重新被渲染了。


### 4.3 使用模板默认目录templates存放模板文件

上面示例中我们通过使用`src: /home/ansible/ansible_playbooks/mytemplates/foo.j2`或`src: /home/ansible/ansible_playbooks/mytemplates/foo`来指定模板文件的绝对路径，如果我们将模板文件存放到剧本文件同级目录的`templates`目录下，Ansible也会自动查找到对应的剧本文件。

我们先复制一下文件：
```sh
[ansible@master ~]$ cd ansible_playbooks/
[ansible@master ansible_playbooks]$ mkdir templates
[ansible@master ansible_playbooks]$ cp mytemplates/foo templates/bar
[ansible@master ansible_playbooks]$ ll templates/bar
-rw-rw-r-- 1 ansible ansible 631 Feb 23 06:46 templates/bar
```

然后修改一下剧本文件`template.yml`:
```yaml
- hosts: node1
  tasks:
    - name: Template a file to /etc/file.conf
      ansible.builtin.template:
        src: bar
        dest: /etc/file.conf
        owner: bin
        group: wheel
        mode: '0644'
        backup: true
      become: yes

```

即此处`src: bar`仅指定模板的名称，并没有指定其路径，尝试执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint template.yml
[ansible@master ansible_playbooks]$ ansible-playbook template.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Template a file to /etc/file.conf] *******************************************************************************
changed: [node1] => {"backup_file": "/etc/file.conf.30029.2023-02-23@06:51:46~", "changed": true, "checksum": "a94f50c2599e8d495e8da5cab4469dec619463fd", "dest": "/etc/file.conf", "gid": 10, "group": "wheel", "md5sum": "0c55c96745d17da7d76708ecea925683", "mode": "0644", "owner": "bin", "size": 643, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1677106306.24-14023-230229998303305/source", "state": "file", "uid": 1}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，剧本成功执行，在node1节点上检查一下：
```sh
[root@node1 ~]# ll /etc/file.conf*
-rw-r--r-- 1 bin wheel 643 Feb 23 06:51 /etc/file.conf
-rw-r--r-- 1 bin wheel 647 Feb 22 07:15 /etc/file.conf.30029.2023-02-23@06:51:46~
-rw-r--r-- 1 bin wheel 653 Feb 22 06:48 /etc/file.conf.466.2023-02-22@07:15:23~
[root@node1 ~]# cat /etc/file.conf
# this is foo.j2 template
Ansible managed (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid.
master contains the node name of the template’s machine.
ansible is the numeric user id of the owner.
/home/ansible/ansible_playbooks/templates/bar is the path of the template.
/home/ansible/ansible_playbooks/templates/bar is the absolute path of the template.
/etc/file.conf is the path of the template on the remote system (added in 2.8).
2023-02-23 06:51:46.259152 is the date that the template was rendered.

[root@node1 ~]#
```

可以看到，Ansible自动从`template.yml`剧本文件同级目录`/home/ansible/ansible_playbooks/templates`下查找到了模板文件`bar`，并成功渲染！！


### 4.4 使用符号模式设置文件权限

设置文件权限时，不仅可以使用`mode: '0644'`这样数字的形式，也可以使用`mode: u=rw,g=r,o=r`这样的符号模式，示例如下：
```yaml
- hosts: node1
  tasks:
    - name: Template a file, using symbolic modes (equivalent to 0644)
      ansible.builtin.template:
        src: bar
        dest: /etc/bar.conf
        owner: bin
        group: wheel
        mode: u=rw,g=r,o=r
      become: yes

```

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint template.yml
[ansible@master ansible_playbooks]$ ansible-playbook template.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Template a file, using symbolic modes (equivalent to 0644)] ******************************************************
changed: [node1] => {"changed": true, "checksum": "77e8b25c9a6bb1890dcbe4ea5e7a801b8ce80f6a", "dest": "/etc/bar.conf", "gid": 10, "group": "wheel", "md5sum": "e018da0b98953ef66cbd88ee39ba077a", "mode": "0644", "owner": "bin", "size": 642, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1677194447.48-16981-220559966580830/source", "state": "file", "uid": 1}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，也成功执行。

在节点node1上面查看文件属性和内容：
```sh
[root@node1 ~]# cat /etc/bar.conf
# this is foo.j2 template
Ansible managed (configurable via the defaults section of ansible.cfg) contains a string which can be used to describe the template name, host, modification time of the template file and the owner uid.
master contains the node name of the template’s machine.
ansible is the numeric user id of the owner.
/home/ansible/ansible_playbooks/templates/bar is the path of the template.
/home/ansible/ansible_playbooks/templates/bar is the absolute path of the template.
/etc/bar.conf is the path of the template on the remote system (added in 2.8).
2023-02-24 07:20:47.499481 is the date that the template was rendered.

[root@node1 ~]#
```
可以看到，文件权限和内容已经配置好了。

### 4.5 使用for循环渲染Web页面

编写`web.html`文件：
```html
<!DOCTYPE html>
<html lang="en">
<head>
    {# 下面这一行解决页面中文乱码 #}
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>My Webpage</title>
</head>
<body>
    <ul id="navigation">
    {% for item in navigation %}
        <li><a href="{{ item.href }}">{{ item.caption }}</a></li>
    {% endfor %}
    </ul>

    <h1>My Webpage</h1>
    {{ author }}

    {# a comment #}
</body>
</html>
```

编写剧本文件：
```yaml
- hosts: node1
  vars:
    author: "meizhaohui"
    navigation:
      - {"href": "https://jinja.palletsprojects.com/", "caption": "JinJa2文档" }
      - {"href": "http://www.ansible.com.cn/", "caption": "Ansible中文权威指南" }
      - {"href": "https://www.baidu.com/", "caption": "百度一下" }
  tasks:
    - name: Template a file to /usr/share/nginx/html/web.html
      ansible.builtin.template:
        src: web.html
        dest: /usr/share/nginx/html/web.html
        owner: root
        group: root
        mode: '0644'
      become: yes

```

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint template.yml
[ansible@master ansible_playbooks]$ ansible-playbook template.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Template a file to /usr/share/nginx/html/web.html] ***************************************************************
changed: [node1] => {"changed": true, "checksum": "50662b657416087866018d74921dc878a4ec7bab", "dest": "/usr/share/nginx/html/web.html", "gid": 0, "group": "root", "md5sum": "7b8747b936d31c37fb59e34fb91b2fca", "mode": "0644", "owner": "root", "size": 505, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1677897655.16-662-131792568332109/source", "state": "file", "uid": 0}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

注意，在本机`/etc/hosts`中绑定一下服务器IP与域名：
```sh
192.168.56.111 node1 node1.com
```

在节点上检查生成的html文件：
```sh
[root@node1 ~]# ls -lah /usr/share/nginx/html/web.html
-rw-r--r-- 1 root root 505 Mar  4 10:40 /usr/share/nginx/html/web.html
[root@node1 ~]# cat /usr/share/nginx/html/web.html
<!DOCTYPE html>
<html lang="en">
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>My Webpage</title>
</head>
<body>
    <ul id="navigation">
            <li><a href="https://jinja.palletsprojects.com/">JinJa2文档</a></li>
            <li><a href="http://www.ansible.com.cn/">Ansible中文权威指南</a></li>
            <li><a href="https://www.baidu.com/">百度一下</a></li>
        </ul>

    <h1>My Webpage</h1>
    meizhaohui

    </body>
</html>
[root@node1 ~]#
```
在浏览器中访问 [http://node1.com/web.html](http://node1.com/web.html)



