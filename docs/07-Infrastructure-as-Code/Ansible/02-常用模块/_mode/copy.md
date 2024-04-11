# copy复制模块

[[toc]]

## 1. 概要

- `copy`复制模块将文件从本地或远程计算机复制到远程计算机上的某个位置。
- 使用`fetch`复制模块可以将文件从远程位置复制到ansible主机文件夹。
- 如果需要在复制的文件中进行大量变量插值，请使用`template`模板模块。 在内容字段中使用变量将导致不可预测的输出。
- 对于Windows目标，请使用用`win_copy`模块。
- 递归复制模块的复制功能无法扩展到大量（>数百个）文件，即当递归复制大量文件时会非常的慢，这时推荐使用`synchronize`模块(synchronize同步模块是rsync的包装器，它在递归复制大量深层嵌套文件方面非常高效且快速)。
- 源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/copy.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/copy.py)
- 官方文档：[https://docs.ansible.com/ansible/latest/modules/copy_module.html](https://docs.ansible.com/ansible/latest/modules/copy_module.html)



## 2. 参数

| 参数                     | 可选值 | 默认值 | 说明                                                         |
| ------------------------ | ------ | ------ | ------------------------------------------------------------ |
| `attributes`             |        |        | `string`，复制后的文件或文件夹的属性，默认是`=`，如果需要进行`+`、`-`操作，则需要包含在字符串中。别名`attr`。可以参考`chattr`。 |
| `backup`                 | yes/no | no     | `boolean`，创建一个带时间戳的备份文件，以防不小心破坏文件的情况下找到原始文件。 |
| `checksum`               |        |        | `string`，传输文件的SHA1校验和。用于验证文件副本是否成功。如果未提供，则Ansible将使用src文件的本地计算校验和。 |
| `content`                |        |        | `string`,当代替`src`使用时，将文件的内容直接设置为指定的值。仅在`dest`是文件时有效。 如果文件不存在，则创建它。对于高级格式化，或者如果内容包含变量，请使用`template`模板模块。`content`与`src`必须提供一个！ |
| `decrypt`                | yes/no | yes    | `boolean`，此选项使用Vault控制源文件的自动解密。             |
| `dest`      **required** |        |        | `path`，文件应复制到的远程绝对路径。如果`src`是目录，则`dest`必须也是目录；如果`dest`是不存在的路径，并且`dest`以“ /”结尾或`src`是目录，则创建`dest`目录；如果`dest`是相对路径，则路径开始值由远程主机决定；如果`src`和`dest`是文件，则不会创建`dest`的父目录，如果父目录不存在，则该任务将失败。 |
| `directory_mode`         |        |        | `raw`，如`directory_mode='0770'`,当进行递归复制时，新创建的文件夹使用的文件夹模式，该参数对已经存在的文件夹没有影响，**但对子目录有影响**。如果目标目录不存在，则会新建目录，并且对目标目录及其子目录都会应用该文件夹权限模式；如果目标目录存在，则不会影响目标目录本身，只会影响目标目录的子目录！ |
| `follow`                 | yes/no | no     | 是否跟踪目标系统上面的链接文件。                             |
| `force`                  | yes/no | yes    | 是否强制覆盖已经存在的文件。当设置为`yes`时当远程文件内容与源文件内容不同时就会被替换掉；当设置为`no`时，只会传输远程主机上不存在的文件。 |
| `group`                  |        |        | `string`,用户组的名称。                                      |
| `local_follow`           | yes/no | yes    | 是否跟踪源系统上面的链接文件。                               |
| `mode`                   |        |        | `path`,目标文件或目录的权限。对于那些习惯于`/usr/bin/chmod`的用户，请记住模式实际上是八进制数。您必须添加一个前导零，以便Ansible的YAML解析器知道它是一个八进制数(例如`0644`或`01777`)或用引号(例如`'644'`或`'1777'`)来使Ansible接收字符串并可以从字符串进行自己的转换成数字。不遵循这些规则的话，Ansible将会这这些数字当做十进制数，这将引起异常。从Ansible1.8开始，可以将模式指定为符号模式（例如，`u+rwx`或`u=rw,g=r,o=r`)。从Ansible2.3开始，该模式也可能是`preserve`,表示保留源文件相同的权限。(The permissions are r for read, w for write and x for execute.) |
| `owner`                  |        |        | `string`，文件拥有者名称。                                   |
| `remote_src`             | yes/no | no     | `boolean`，如果设置为`yes`，则会在远程主机上寻找`src`源文件；如果设置为`no`，则会在Ansible master主机上面寻找`src`源文件。 |
| `src`                    |        |        | `path`,本地待复制的文件。可以是相对或绝对路径。如果路径是目录，则会递归复制。如果路径以“ /”结尾，则仅将该目录的内部内容复制到目标位置。 否则，如果它不以“ /”结尾，则将复制路径本身及目录下所有的内容。 此行为类似于`rsync`命令行工具。`content`与`src`必须提供一个！ |
| `unsafe_writes`          | yes/no | no     | `boolean`,影响何时使用原子操作来防止数据损坏或对目标文件的读取不一致。 默认情况下，此模块使用原子操作来防止数据损坏或对目标文件的读取不一致，但是有时会以防止这种情况的方式配置或破坏系统。一个示例是docker挂载的文件，该文件无法从容器内部进行原子更新，只能以不安全的方式写入。 当原子操作失败时，此选项允许Ansible退回到不安全的文件更新方法（但是，它不会强制Ansible执行不安全的写操作）。 重要！不安全的写入会受到竞争条件的影响，并可能导致数据损坏。 |
| `validate`               |        |        | `string`，验证命令在复制之前运行，保证命令安全传递。         |



## 3. 返回值

| 键                                                           | 何时返回       | 描述信息                                                     |
| ------------------------------------------------------------ | -------------- | ------------------------------------------------------------ |
| **backup_file**                                    string    | `backup=yes`时 | 备份文件的路径，如`/path/to/file.txt.2015-02-12@22:09~ `     |
| **checksum**                                       string    | success        | 复制后文件的SHA1校验和,如`6e642bb8dd5c2e027bf21dd923337cbb4214f827` |
| **dest**                                                  string | success        | 目标路径 `/path/to/file.txt `                                |
| **gid**                                                    integer | success        | GID,如`100`                                                  |
| **group**                                               string | success        | 文件的组名,如`httpd                                 `        |
| **md5sum**                                          string   | when supported | 复制后文件的MD5校验和,如`2a5aeecc61dc98c4d780b14b330e3282`   |
| **mode**                                               string | success        | 目标权限，如`420`                                            |
| **owner**                                              string | success        | 文件的owner,如`httpd`                                        |
| **size**                                                  integer | success        | 文件的大小,如`1220`                                          |
| **src**                                                     string | changed        | 用于在目标计算机上进行复制的源文件，如`/home/httpd/.ansible/tmp/ansible-tmp-1423796390.97-147729857856000/source` |
| **state**                                                 string | success        | 执行后目标的状态，如`file`                                   |
| **uid**                                                     integer | success        | 文件的owner ID,如`100`                                       |



## 4. 临时命令的使用

复制家目录下面的文件：

```sh
[ansible@master ~]$ ansible node1 -m copy -a 'src=.bashrc dest=/tmp/test.bashrc'
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "b034d28772e19df759119731956ffd27b21ce399", 
    "dest": "/tmp/test.bashrc", 
    "gid": 1001, 
    "group": "ansible", 
    "md5sum": "2df33d5c8322df0b3e9afa2b923efa37", 
    "mode": "0664", 
    "owner": "ansible", 
    "size": 350, 
    "src": "/home/ansible/.ansible/tmp/ansible-tmp-1595920692.14-3848-131725126874205/source", 
    "state": "file", 
    "uid": 1001
};
[ansible@master ~]$ 
```

在node1节点上面查看文件信息：

```sh
# 查看复制后的文件的权限、所属、大小等信息
[ansible@node1 ~]$ ls -lah /tmp/test.bashrc 
-rw-rw-r-- 1 ansible ansible 350 Jul 28 15:18 /tmp/test.bashrc

# 查看md5sum值
[ansible@node1 ~]$ md5sum /tmp/test.bashrc 
2df33d5c8322df0b3e9afa2b923efa37  /tmp/test.bashrc

# 查看sha1sum值
[ansible@node1 ~]$ sha1sum /tmp/test.bashrc 
b034d28772e19df759119731956ffd27b21ce399  /tmp/test.bashrc

# 查看用户信息
[ansible@node1 ~]$ id ansible
uid=1001(ansible) gid=1001(ansible) groups=1001(ansible)
[ansible@node1 ~]$ 
```

可以看到md5值、sha1值、文件大小等信息与Ansible返回信息中的值是一样的。我们此处简单的使用临时命令进行复制操作。



## 5. 剧本的使用

### 5.1 仅指定`dest`参数进行复制

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    # copy no src path
    - name: copy no src path
      copy:
        dest: /tmp/nosrc
[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v 
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [copy no src path] **************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "src (or content) is required"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0 
```

可以看到,提示`"src (or content) is required"`,即至少应指定`src`或`content`参数之一。



### 5.2 指定src和dest参数

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: copy .bashrc to /tmp
      copy:
        src: .bashrc
        dest: /tmp

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [copy .bashrc to /tmp] **********************************************************
changed: [node1] => {"changed": true, "checksum": "b034d28772e19df759119731956ffd27b21ce399", "dest": "/tmp/.bashrc", "gid": 1001, "group": "ansible", "md5sum": "2df33d5c8322df0b3e9afa2b923efa37", "mode": "0664", "owner": "ansible", "size": 350, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1595923204.2-3968-122237293978653/source", "state": "file", "uid": 1001}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到能够正常的复制到`dest`指定目录中，如果`src`指定的文件不是绝对路径，则会在当前用户的家目录或者家目录下面`files`目录查找文件。

我们检查一下是否真的会从`files`目录下面复制文件：

```sh
# 首先准备一个files目录，然后里面存放mycopy,yml文件
[ansible@master ~]$ cat files/mycopy.yml 
- hosts: node1
  tasks:
    # 检查ansible是否会在files路径下面复制文件
    - name: copy mycopy.yml to /tmp
      copy:
        src: mycopy.yml
        dest: /tmp/

[ansible@master ~]$ 

# 查看剧本文件
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    # 检查ansible是否会在files路径下面复制文件
    - name: copy mycopy.yml to /tmp
      copy:
        src: mycopy.yml
        dest: /tmp/
[ansible@master ~]$ 

# 剧本文件规范性检查
[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ 

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$

# 执行剧本
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [copy mycopy.yml to /tmp] *******************************************************
changed: [node1] => {"changed": true, "checksum": "b7e88a61065eee4162a43ecbb964291ff4519465", "dest": "/tmp/mycopy.yml", "gid": 1001, "group": "ansible", "md5sum": "15c25e81393f06a358082f66c3d1606f", "mode": "0664", "owner": "ansible", "size": 178, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596164759.88-3980-121681678092154/source", "state": "file", "uid": 1001}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，能够正常执行，我们再在node1节点上面检查一下，是否有mycopy.yml文件：

```sh
[ansible@node1 ~]$ ls -lah /tmp/mycopy.yml 
-rw-rw-r-- 1 ansible ansible 178 Jul 31 11:06 /tmp/mycopy.yml
[ansible@node1 ~]$ md5sum /tmp/mycopy.yml 
15c25e81393f06a358082f66c3d1606f  /tmp/mycopy.yml
[ansible@node1 ~]$ sha1sum /tmp/mycopy.yml 
b7e88a61065eee4162a43ecbb964291ff4519465  /tmp/mycopy.yml
[ansible@node1 ~]$ cat /tmp/mycopy.yml 
- hosts: node1
  tasks:
    # 检查ansible是否会在files路径下面复制文件
    - name: copy mycopy.yml to /tmp
      copy:
        src: mycopy.yml
        dest: /tmp/

[ansible@node1 ~]$ 
```

可以看到文件正常复制！



我们现在将`files`文件夹重命名一下：

```sh
[ansible@master ~]$ mv files/ files_new
[ansible@master ~]$ ls -ld files_new/
drwxrwxr-x 2 ansible ansible 24 Jul 31 11:03 files_new/
```

然后再执行一下剧本:

```sh
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [copy mycopy.yml to /tmp] *******************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: If you are using a module and expect the file to exist on the remote, see the remote_src option
fatal: [node1]: FAILED! => {"changed": false, "msg": "Could not find or access 'mycopy.yml'\nSearched in:\n\t/home/ansible/files/mycopy.yml\n\t/home/ansible/mycopy.yml\n\t/home/ansible/files/mycopy.yml\n\t/home/ansible/mycopy.yml on the Ansible Controller.\nIf you are using a module and expect the file to exist on the remote, see the remote_src option"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 

```

此时,可以看到,执行失败,因为此时没有找到`mycopy.yml`文件!

通过以上可以知道,Ansible会从用户家目录或者家目录下面的`files`文件夹去搜索需要复制的文件。



### 5.3 指定文件的UID/GID和mode

我们现在来尝试指定复制后文件的用户、用户组以及权限模式。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy file with owner and permissions
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo1.conf
        owner: jenkins
        group: zabbix
        mode: '0644'

    - name: Copy file with owner and permission, using symbolic representation
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo2.conf
        owner: root
        group: root
        mode: u=rw,g=r,o=r

    - name: Another symbolic mode example, adding some permissions and removing others
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo3.conf
        owner: root
        group: tester1
        mode: u+rw,g-wx,o-rwx

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy file with owner and permissions] ******************************************
fatal: [node1]: FAILED! => {"changed": false, "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32", "msg": "Destination /etc not writable"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

上面可以看到，当复制文件到Ansible家目录、/tmp目录以外其他目录时，没有写权限。需要进行权限提升，我们修改一下剧本文件：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy file with owner and permissions
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo1.conf
        owner: jenkins
        group: zabbix
        mode: '0644'
      become: yes

    - name: Copy file with owner and permission, using symbolic representation
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo2.conf
        owner: root
        group: root
        mode: u=rw,g=r,o=r
      become: yes

    - name: Another symbolic mode example, adding some permissions and removing others
      copy:
        src: /etc/httpd/conf/httpd.conf
        dest: /etc/foo3.conf
        owner: root
        group: tester1
        mode: u+rw,g-wx,o-rwx
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy file with owner and permissions] ******************************************
changed: [node1] => {"changed": true, "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32", "dest": "/etc/foo1.conf", "gid": 1004, "group": "zabbix", "md5sum": "f5e7449c0f17bc856e86011cb5d152ba", "mode": "0644", "owner": "jenkins", "size": 11753, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596176584.91-13692-7976699276027/source", "state": "file", "uid": 1003}

TASK [Copy file with owner and permission, using symbolic representation] ************
changed: [node1] => {"changed": true, "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32", "dest": "/etc/foo2.conf", "gid": 0, "group": "root", "md5sum": "f5e7449c0f17bc856e86011cb5d152ba", "mode": "0644", "owner": "root", "size": 11753, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596176585.51-13708-155970258986390/source", "state": "file", "uid": 0}

TASK [Another symbolic mode example, adding some permissions and removing others] ****
changed: [node1] => {"changed": true, "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32", "dest": "/etc/foo3.conf", "gid": 1010, "group": "tester1", "md5sum": "f5e7449c0f17bc856e86011cb5d152ba", "mode": "0640", "owner": "root", "size": 11753, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596176585.9-13724-113578652198919/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

通过`become: yes`权限提升后，正常复制了文件，我们在node1节点上面查看一下：

```sh
[ansible@node1 ~]$ ls -lah /etc/foo*
-rw-r--r-- 1 jenkins zabbix  12K Jul 31 14:23 /etc/foo1.conf
-rw-r--r-- 1 root    root    12K Jul 31 14:23 /etc/foo2.conf
-rw-r----- 1 root    tester1 12K Jul 31 14:23 /etc/foo3.conf
[ansible@node1 ~]$ 
```

可以看到，权限也如我们期望的一样，用户、用户组都按剧本的要求设置成功了。我们将node1节点上测试用的文件删除掉：

```sh
[ansible@node1 ~]$ trash-put /tmp/mycopy.yml 
[ansible@node1 ~]$ trash-empty
[ansible@node1 ~]$ sudo trash-put /etc/foo*
[ansible@node1 ~]$ sudo trash-empty
```



### 5.4 备份文件

我们来准备两个文件`/etc/master.foo`和`/etc/node1.foo`。

Ansible主机上面准备`/etc/master.foo`文件：

```sh
# 直接使用重定向会提示权限拒绝。
# 这是因为重定向符号">"也是bash的命令。sudo只是让echo命令具有了root权限，但是没有让">"命令也具有root权限，所以bash会认为这个命令没有写入信息的权限。
[ansible@master ~]$ sudo echo "foo in master" > /etc/master.foo
bash: /etc/master.foo: Permission denied

# 写文件
[ansible@master ~]$ echo "foo in master"|sudo tee /etc/master.foo
foo in master
[ansible@master ~]$ ls -lah /etc/master.foo 
-rw-r--r-- 1 root root 14 Jul 31 14:46 /etc/master.foo

# 查看文件内容
[ansible@master ~]$ cat /etc/master.foo 
foo in master
[ansible@master ~]$ 
```

node1节点上面准备`/etc/node1.foo`文件：

```sh
[ansible@node1 ~]$ echo "foo in node1"|sudo tee /etc/node1.foo
foo in node1
[ansible@node1 ~]$ ls -lah /etc/node1.foo 
-rw-r--r-- 1 root root 13 Jul 31 14:49 /etc/node1.foo
[ansible@node1 ~]$ cat /etc/node1.foo 
foo in node1
[ansible@node1 ~]$ 
```

下面我们来测试备份功能。

```sh
# 查看剧本文件，复制时增加了`backup: yes`参数
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy a new node1.foo file into place, backing up the original if it differs from the copied version
      copy:
        src: /etc/master.foo
        dest: /etc/node1.foo
        mode: '0644'
        backup: yes
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a new node1.foo file into place, backing up the original if it differs from the copied version] ***
changed: [node1] => {"backup_file": "/etc/node1.foo.6098.2020-07-31@14:53:30~", "changed": true, "checksum": "2d389645b886c601eedf448a4c1242c632d59fa4", "dest": "/etc/node1.foo", "gid": 0, "group": "root", "md5sum": "a6a70d7678b826b0020de76cae84444e", "mode": "0644", "owner": "root", "size": 14, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596178410.36-15268-51793262793377/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到返回值时，增加了`"backup_file": "/etc/node1.foo.6098.2020-07-31@14:53:30~"`，即有一个备份文件。

我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ ls -lah /etc/node1*
-rw-r--r-- 1 root root 14 Jul 31 14:53 /etc/node1.foo
-rw-r--r-- 1 root root 13 Jul 31 14:49 /etc/node1.foo.6098.2020-07-31@14:53:30~
[ansible@node1 ~]$ cat /etc/node1.foo
foo in master
[ansible@node1 ~]$ cat /etc/node1.foo.6098.2020-07-31\@14\:53\:30~ 
foo in node1
[ansible@node1 ~]$ 
```

可以看到，原来的文件已经成功备份了！可以看到，备份的的目标文件，如果目标文件原来已经存在，就可以进行备份！



### 5.5 对目标文件进行有效性验证、在远程主机上面复制文件

我们对`/etc/sudoers`文件进行复制，注意此文件的特殊性：

```sh
[ansible@master ~]$ ls -lah /etc/sudoers
-r--r----- 1 root root 4.3K Jun 15 11:36 /etc/sudoers
```

默认情况下，除了root用户和root组外，其他用户是不能查看的，就算我们在剧本中使用`become`权限提升也会出现异常：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy a new "sudoers" file into place, after passing validation with visudo
      copy:
        src: /etc/sudoers
        dest: /etc/sudoers.edit
        validate: /usr/sbin/visudo -csf %s
        backup: yes
      become: yes

    - name: Copy a "sudoers" file on the remote machine for editing
      copy:
        src: /etc/sudoers
        dest: /etc/sudoers.edit
        remote_src: yes
        validate: /usr/sbin/visudo -csf %s
        backup: yes
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a new "sudoers" file into place, after passing validation with visudo] ****
fatal: [node1]: FAILED! => {"msg": "an error occurred while trying to read the file '/etc/sudoers': [Errno 13] Permission denied: '/etc/sudoers'"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，虽然我们已经增加了`become: yes`选项，仍然不能读取文件`/etc/sudoers`。原因是，此处的`become: yes`是对远程节点上面的操作进行权限提升，不是对Ansible主机上面进行权限提示，默认情况下，ansible账号是不能读取文件`/etc/sudoers`的，我们试一下就知道：

```sh
[ansible@master ~]$ cat /etc/sudoers
cat: /etc/sudoers: Permission denied
[ansible@master ~]$ 
```

为了使得我们能够正常的复制文件`/etc/sudoers`,我们需要给它的other增加`r`读权限！

我们使用临时命令改一下权限(注意，记得等会改回来！！！)：

```sh
[ansible@master ~]$ ansible localhost -b -m command -a "chmod o+r -v /etc/sudoers"
[WARNING]: Consider using the file module with mode rather than running 'chmod'.  If
you need to use command because file is insufficient you can add 'warn: false' to
this command task or set 'command_warnings=False' in ansible.cfg to get rid of this
message.
localhost | CHANGED | rc=0 >>
mode of ‘/etc/sudoers’ changed from 0440 (r--r-----) to 0444 (r--r--r--)
[ansible@master ~]$ ls -lah /etc/sudoers
-r--r--r-- 1 root root 4.3K Jun 15 11:36 /etc/sudoers
```

然后，我们再执行剧本看看：

```sh
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a new "sudoers" file into place, after passing validation with visudo] ****
changed: [node1] => {"changed": true, "checksum": "fc1b13262ba3f494d09e70b9c16cfb312bb30fa5", "dest": "/etc/sudoers.edit", "gid": 0, "group": "root", "md5sum": "1957e5b5957bbca9eecdeee7a2ecd799", "mode": "0644", "owner": "root", "size": 4360, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596184442.73-20594-199025725859240/source", "state": "file", "uid": 0}

TASK [Copy a "sudoers" file on the remote machine for editing] ***********************
changed: [node1] => {"backup_file": "/etc/sudoers.edit.12668.2020-07-31@16:34:03~", "changed": true, "checksum": "e4e30f4236105f9314f72b4166fc61c8f1d53560", "dest": "/etc/sudoers.edit", "gid": 0, "group": "root", "md5sum": "ca221b0055d44f1ac93b2e65be3060de", "mode": "0644", "owner": "root", "size": 4366, "src": "/etc/sudoers", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

发现可以正常执行！我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ ls -lah /etc/sudoers*
-r--r-----. 1 root root 4.3K Jun 15 11:37 /etc/sudoers
-rw-r--r--  1 root root 4.3K Jun 15 11:37 /etc/sudoers.edit
-rw-r--r--  1 root root 4.3K Jul 31 16:34 /etc/sudoers.edit.12668.2020-07-31@16:34:03~

ls: cannot open directory /etc/sudoers.d: Permission denied
[ansible@node1 ~]$ l
```

可以看到，任务1并没有进行备份文件，因为刚开始的时候`/etc/sudoers.edit`并不存在。任务2对文件进行了备份！

这个时候，我们不知道Ansible是否对新生成的配置文件进行了校验！

我们在node1节点上面修改一下`/etc/sudoers.edit`文件，在最后增加一行`notexistuser`，然后检查一下这个文件的有效性：

```sh
[ansible@node1 ~]$ nl -ba /etc/sudoers.edit|tail
   113	## cdrom as root
   114	# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom
   115	
   116	## Allows members of the users group to shutdown this system
   117	# %users  localhost=/sbin/shutdown -h now
   118	
   119	## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
   120	#includedir /etc/sudoers.d
   121	ansible ALL=(ALL)       NOPASSWD: ALL
   122	notexistuser
[ansible@node1 ~]$ sudo visudo -csf /etc/sudoers.edit
>>> /etc/sudoers.edit: syntax error near line 122 <<<
parse error in /etc/sudoers.edit near line 122
[ansible@node1 ~]$
[ansible@node1 ~]$ ls -lah /etc/sudoers.edit
-rw-r--r-- 1 root root 4.3K Jul 31 16:38 /etc/sudoers.edit
```

可以看到122行配置的是有问题的！并且此时权限是`0644`的，即`root`用户也是有`w`写权限的。



我们修改一下剧本文件，并执行：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy a "sudoers" file on the remote machine for editing
      copy:
        src: /etc/sudoers.edit
        dest: /etc/sudoers.edit1
        remote_src: yes
        validate: /usr/sbin/visudo -csf %s
        owner: root
        group: root
        mode: u=r,g=r
        backup: yes
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a "sudoers" file on the remote machine for editing] ***********************
fatal: [node1]: FAILED! => {"changed": false, "exit_status": 1, "msg": "failed to validate", "stderr": ">>> /etc/sudoers.edit: syntax error near line 122 <<<\n", "stderr_lines": [">>> /etc/sudoers.edit: syntax error near line 122 <<<"], "stdout": "parse error in /etc/sudoers.edit near line 122\n", "stdout_lines": ["parse error in /etc/sudoers.edit near line 122"]}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到，校验时发生异常，Ansible剧本执行失败。但是，此时检查`/etc/sudoers.edit`的权限，会发现已经被修改了：

```sh
[ansible@node1 ~]$ ls -lah /etc/sudoers.edit
-r--r--r-- 1 root root 4.3K Jul 31 16:38 /etc/sudoers.edit
```

由于有异常，此处修改将权限修改回去：

```sh
[ansible@node1 ~]$ ls -lah /etc/sudoers.edit
-r--r--r-- 1 root root 4.3K Jul 31 16:38 /etc/sudoers.edit
[ansible@node1 ~]$ sudo chmod u+w -v /etc/sudoers.edit
mode of ‘/etc/sudoers.edit’ changed from 0444 (r--r--r--) to 0644 (rw-r--r--)
[ansible@node1 ~]$ ls -lah /etc/sudoers.edit
-rw-r--r-- 1 root root 4.3K Jul 31 16:38 /etc/sudoers.edit
[ansible@node1 ~]$ 
```

我们使用彩排模式来运行一下：

```sh
[ansible@master ~]$ ansible-playbook --check copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a "sudoers" file on the remote machine for editing] ***********************
changed: [node1] => {"changed": true, "checksum": "35c174b6dd6ad47c967fc337033f54d8e34d4ab8", "dest": "/etc/sudoers.edit1", "md5sum": "c66d111bcf71ed350d262109e3bc7298", "src": "/etc/sudoers.edit"}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```

彩排模式下并没有发现有任何异常，说明此时并没有检查出配置文件的问题。



好，说明Ansible在复制时，是正常进行了校验的！我们再把`/etc/sudoers.edit`最后一行的内容删除掉：

```sh
[ansible@node1 ~]$ nl -ba /etc/sudoers.edit|tail
   112	## Allows members of the users group to mount and unmount the 
   113	## cdrom as root
   114	# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom
   115	
   116	## Allows members of the users group to shutdown this system
   117	# %users  localhost=/sbin/shutdown -h now
   118	
   119	## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
   120	#includedir /etc/sudoers.d
   121	ansible ALL=(ALL)       NOPASSWD: ALL
[ansible@node1 ~]$ ls -lah /etc/sudoers.edit
-rw-r--r-- 1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit
[ansible@node1 ~]$ 
```

再执行剧本：

```sh
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a "sudoers" file on the remote machine for editing] ***********************
changed: [node1] => {"changed": true, "checksum": "e4e30f4236105f9314f72b4166fc61c8f1d53560", "dest": "/etc/sudoers.edit1", "gid": 0, "group": "root", "md5sum": "ca221b0055d44f1ac93b2e65be3060de", "mode": "0444", "owner": "root", "size": 4366, "src": "/etc/sudoers.edit", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

但是此时并没有进行备份，因为`/etc/sudoers.edit1`本来就不存在，不需要备份。检查配置文件没有出现异常！但是，权限好像并不是我们想要的`-r-r-----`:

```sh
ansible@node1 ~]$ ls -lah /etc/sudoers*
-r--r-----. 1 root root 4.3K Jun 15 11:37 /etc/sudoers
-r--r--r--  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit
-r--r--r--  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit1
-rw-r--r--  1 root root 4.3K Jul 31 16:34 /etc/sudoers.edit.12668.2020-07-31@16:34:03~

ls: cannot open directory /etc/sudoers.d: Permission denied
[ansible@node1 ~]$ 
```

然后，`/etc/sudoers.edit`的权限又变了！！

我们把生成的文件删除掉，并且把权限改回来：

```sh
[ansible@node1 ~]$ ls -lah /etc/sudoers*
-r--r-----. 1 root root 4.3K Jun 15 11:37 /etc/sudoers
-r--r--r--  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit
-r--r--r--  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit1
-rw-r--r--  1 root root 4.3K Jul 31 16:34 /etc/sudoers.edit.12668.2020-07-31@16:34:03~

ls: cannot open directory /etc/sudoers.d: Permission denied
[ansible@node1 ~]$ 
[ansible@node1 ~]$ sudo trash-put /etc/sudoers.edit1
[ansible@node1 ~]$ sudo chmod u+w -v /etc/sudoers.edit
mode of ‘/etc/sudoers.edit’ changed from 0444 (r--r--r--) to 0644 (rw-r--r--)
[ansible@node1 ~]$ ls -lah /etc/sudoers*
-r--r-----. 1 root root 4.3K Jun 15 11:37 /etc/sudoers
-rw-r--r--  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit
-rw-r--r--  1 root root 4.3K Jul 31 16:34 /etc/sudoers.edit.12668.2020-07-31@16:34:03~

ls: cannot open directory /etc/sudoers.d: Permission denied
[ansible@node1 ~]$ 
```

再改一下剧本文件，将`mode: u=r,g=r`改成`mode: u=r,g=r,o=`试试看：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy a "sudoers" file on the remote machine for editing
      copy:
        src: /etc/sudoers.edit
        dest: /etc/sudoers.edit1
        remote_src: yes
        validate: /usr/sbin/visudo -csf %s
        owner: root
        group: root
        mode: u=r,g=r,o=
        backup: yes
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy a "sudoers" file on the remote machine for editing] ***********************
changed: [node1] => {"changed": true, "checksum": "e4e30f4236105f9314f72b4166fc61c8f1d53560", "dest": "/etc/sudoers.edit1", "gid": 0, "group": "root", "md5sum": "ca221b0055d44f1ac93b2e65be3060de", "mode": "0440", "owner": "root", "size": 4366, "src": "/etc/sudoers.edit", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时再看查node1节点上面的文件：

```sh
[ansible@node1 ~]$ ls -lah /etc/sudoers*
-r--r-----. 1 root root 4.3K Jun 15 11:37 /etc/sudoers
-r--r-----  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit
-r--r-----  1 root root 4.3K Jul 31 17:30 /etc/sudoers.edit1
-rw-r--r--  1 root root 4.3K Jul 31 16:34 /etc/sudoers.edit.12668.2020-07-31@16:34:03~

ls: cannot open directory /etc/sudoers.d: Permission denied
[ansible@node1 ~]$
```

此时`/etc/sudoers.edit1`权限是对的，但不知道为什么`/etc/sudoers.edit`的写权限还是被删除了！这应该是一个问题！

最后，记得将ansible主机上面的`/etc/sudoer`配置文件权限改回去：

```sh
[ansible@master ~]$ sudo chmod o-r -v /etc/sudoers
mode of ‘/etc/sudoers’ changed from 0444 (r--r--r--) to 0440 (r--r-----)
```



### 5.6 通过content进行文本复制

首先查看node1节点上面有没有我们需要处理的文件：

```sh
[ansible@node1 ~]$ ls /etc/mine.conf
ls: cannot access /etc/mine.conf: No such file or directory
```

可以看到没有`/etc/mine.conf`文件。



我们编写剧本文件，通过指定文件内容来复制文件：

```sh
# 查看剧本文件
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy using inline content
      copy:
        content: '# This file was moved to /etc/other.conf'
        dest: /etc/mine.conf
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy using inline content] *****************************************************
changed: [node1] => {"changed": true, "checksum": "2d81dab6cea6299fe8a036e9ad4fa3cd095a7638", "dest": "/etc/mine.conf", "gid": 0, "group": "root", "md5sum": "26b1d9d389ebe90a542b38b3f3cad9c1", "mode": "0644", "owner": "root", "size": 40, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596437858.92-3653-198445832117442/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到剧本正常执行，并创建了文件`/etc/mine.conf`。

我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ ls -lah /etc/mine.conf
-rw-r--r-- 1 root root 40 Aug  3 14:57 /etc/mine.conf
[ansible@node1 ~]$ cat /etc/mine.conf 
# This file was moved to /etc/other.conf[ansible@node1 ~]$ 
[ansible@node1 ~]$ 
```

可以看到，创建成功！



#### 5.6.1 多行处理

- 使用单引号或不用引号时，不能正常处理多行

注意，如果需要输入多行文本，使用`\n`是不起作用的，请看下面的示例：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy multi-line using inline content
      copy:
        content: 'Hello\nWorld\n'
        dest: /etc/mine.conf
      become: yes

[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy multi-line using inline content] ******************************************
changed: [node1] => {"changed": true, "checksum": "726303012e97f909aef582cbb1236e45565a12c3", "dest": "/etc/mine.conf", "gid": 0, "group": "root", "md5sum": "496a18b0116261b3ead17521062a6ec5", "mode": "0644", "owner": "root", "size": 14, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596438877.33-3754-79783084979596/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时在node1节点上面检查，可以发现`\n`没有被正常解析：

```sh
[ansible@node1 ~]$ cat /etc/mine.conf 
Hello\nWorld\n[ansible@node1 ~]$ 
[ansible@node1 ~]$ 
```

如果将`content: 'Hello\nWorld\n'`改成`content: Hello\nWorld\n`，生成的文件也不会自动换行！



- 使用双引号能正常处理多行文本

改用双引号包裹需要换行的字符串：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy multi-line using inline content
      copy:
        content: "Hello\nWorld\n"
        dest: /etc/mine.conf
      become: yes

[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy multi-line using inline content] ******************************************
changed: [node1] => {"changed": true, "checksum": "24742cf4aab04750f8d8ab80c4f2900848acaed7", "dest": "/etc/mine.conf", "gid": 0, "group": "root", "md5sum": "f41121a903eafadf258962abc57c8644", "mode": "0644", "owner": "root", "size": 12, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596439037.9-3796-118403454039117/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时查看node1节点上面的文件：

```sh
[ansible@node1 ~]$ cat /etc/mine.conf 
Hello
World
[ansible@node1 ~]$ 
```

可以看到，此时正常换行了！！



- 使用变量处理多行文本

也可以通过使用变量处理多行文本，可以参考[How can I copy a multi-line string to a file with literal newlines?](https://stackoverflow.com/questions/55540994/how-can-i-copy-a-multi-line-string-to-a-file-with-literal-newlines)。

我们将node1上面生成的临时文件删除掉，重新来复制：

```sh
[ansible@node1 ~]$ sudo trash-put /etc/mine.conf 
[ansible@node1 ~]$ sudo trash-empty 
[ansible@node1 ~]$ cat /etc/mine.conf 
cat: /etc/mine.conf: No such file or directory
```

说明文件已经删除了，我们再来复制：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  vars:
    mytext: |
      Hello
      world!
  tasks:
    - name: Copy using inline content
      copy:
        content: "{{ mytext }}"
        dest: /etc/mine.conf
      become: yes


[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy using inline content] *****************************************************
changed: [node1] => {"changed": true, "checksum": "520297853d3b60208a9670a96dcef080ba4798ed", "dest": "/etc/mine.conf", "gid": 0, "group": "root", "md5sum": "4de8e8c09e399aafdf1d9cf55e6007ce", "mode": "0644", "owner": "root", "size": 13, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596439506.57-3920-116668763239110/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本正常执行，此时查看node1节点上面的文件：

```sh
[ansible@node1 ~]$ cat /etc/mine.conf 
Hello
world!
[ansible@node1 ~]$ 
```

可以看到，此时也正常生成了多行文本！



#### 5.6.2 动态模板插值

我们也可以使用`copy`模块进行少量的动态模板插值处理，如果你需要编写大量的模板化文件的话，建议使用`template`模块。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy using inline content
      copy:
        content: "Hello, {{ ansible_user_id }} @ {{ ansible_hostname }}\n"
        dest: /etc/mine.conf
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy using inline content] *****************************************************
changed: [node1] => {"changed": true, "checksum": "3ed88e0737d6bd865389f37292d85648ec547bd4", "dest": "/etc/mine.conf", "gid": 0, "group": "root", "md5sum": "dac6cb7d1d0d30e3c7b9ef7c06eff1a0", "mode": "0644", "owner": "root", "size": 23, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596441196.11-4156-138994193287357/source", "state": "file", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们在剧本中使用了两个动态的变量`ansible_user_id`和`ansible_hostname`，此时剧本正常执行，我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ cat /etc/mine.conf 
Hello, ansible @ node1
[ansible@node1 ~]$ 
```

我们把这个`/etc/mine.conf`测试文件删除掉。



### 5.7 文件夹复制

我们来复制一下`/home/ansible`目录到新的服务器上面，看一下效果。

首先，准备一些基础文件，包含链接文件：

```sh
[ansible@master ~]$ ls -li data/
total 16
18231173 lrwxrwxrwx 1 root    root     6 Aug  3 16:34 link1 -> origin
18231174 lrwxrwxrwx 1 root    root     6 Aug  3 16:34 link2 -> origin
18231177 lrwxrwxrwx 1 root    root    11 Aug  3 16:35 link3 -> origin3.txt
18231175 -rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 link3_hard
18231178 lrwxrwxrwx 1 root    root    11 Aug  3 16:35 link4 -> origin4.txt
18231176 -rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 link4_hard
33608935 drwxrwxr-x 2 ansible ansible 44 Aug  3 16:34 origin
18231175 -rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 origin3.txt
18231176 -rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 origin4.txt
[ansible@master ~]$ ls -li data/origin
total 8
18231170 -rw-rw-r-- 1 ansible ansible 9 Aug  3 16:33 origin1.txt
18231172 -rw-rw-r-- 1 ansible ansible 9 Aug  3 16:33 origin2.txt
[ansible@master ~]$ 
[ansible@master ~]$ tree data
data
├── link1 -> origin
├── link2 -> origin
├── link3 -> origin3.txt
├── link3_hard
├── link4 -> origin4.txt
├── link4_hard
├── origin
│   ├── origin1.txt
│   └── origin2.txt
├── origin3.txt
└── origin4.txt

3 directories, 8 files
[ansible@master ~]$ 
```

注意，通过`-i`参数可以看到文件的inode值，可以看到软硬链接的inode值。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory without trailing slash
      copy:
        src: /home/ansible/data
        dest: /tmp/data1
      become: yes

    - name: Copy directory with trailing slash
      copy:
        src: /home/ansible/data/
        dest: /tmp/data2
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory without trailing slash] *****************************************
changed: [node1] => {"changed": true, "dest": "/tmp/data1/", "src": "/home/ansible/data"}

TASK [Copy directory with trailing slash] ********************************************
changed: [node1] => {"changed": true, "dest": "/tmp/data2/", "src": "/home/ansible/data/"}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时，查看一下node1节点上面的文件情况：

```sh
[ansible@node1 tmp]$ ll -i data*
data1:
total 0
17046823 drwxr-xr-x 5 root root 146 Aug  3 16:54 data

data2:
total 24
33657173 drwxr-xr-x 2 root root 44 Aug  3 16:54 link1
50445909 drwxr-xr-x 2 root root 44 Aug  3 16:54 link2
33657168 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3
33657170 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3_hard
33657169 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4
33657171 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4_hard
  314097 drwxr-xr-x 2 root root 44 Aug  3 16:54 origin
33657165 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin3.txt
33657167 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin4.txt
[ansible@node1 tmp]$ 
[ansible@node1 tmp]$ ll -i data1/data/
total 24
33657124 drwxr-xr-x 2 root root 44 Aug  3 16:54 link1
50445906 drwxr-xr-x 2 root root 44 Aug  3 16:54 link2
18061210 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3
16781287 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3_hard
18061222 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4
16777294 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4_hard
  211760 drwxr-xr-x 2 root root 44 Aug  3 16:54 origin
18061205 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin3.txt
18061208 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin4.txt
[ansible@node1 tmp]$ 

[ansible@node1 tmp]$ tree data*
data1
└── data
    ├── link1
    │   ├── origin1.txt
    │   └── origin2.txt
    ├── link2
    │   ├── origin1.txt
    │   └── origin2.txt
    ├── link3
    ├── link3_hard
    ├── link4
    ├── link4_hard
    ├── origin
    │   ├── origin1.txt
    │   └── origin2.txt
    ├── origin3.txt
    └── origin4.txt
data2
├── link1
│   ├── origin1.txt
│   └── origin2.txt
├── link2
│   ├── origin1.txt
│   └── origin2.txt
├── link3
├── link3_hard
├── link4
├── link4_hard
├── origin
│   ├── origin1.txt
│   └── origin2.txt
├── origin3.txt
└── origin4.txt

7 directories, 24 files
[ansible@node1 tmp]$
```

此时，可以看出来当`src`路径最后带`/`时，会直接复制文件夹中的子文件夹和文件；当`src`路径最后不带`/`时，会直接复制`src`所指定的文件夹，以及其子文件夹和文件。

另外，文件所属关系是`root:root`。



### 5.8 跟随链接文件

去们接着分析上节中的示例最后的文件情况。

链接文件文件夹的情况：

由于默认情况下`local_follow`参数是否跟踪源系统上面的链接文件的值是`yes`，即默认会跟踪源系统上面的链接文件。因此我们在复制`link1`和`link2`时，会复制`link1`、`link2`所指向的源文件`origin`文件夹下面的文件`origin1.txt`和`origin2.txt`，因此此时，在node1节点是`link1`和`link2`变成了文件夹，而不是软链接，并且在这两个文件夹中都有文件`origin1.txt`和`origin2.txt`。

再查看一下软、硬链接文件的情况：

```sh
[ansible@node1 tmp]$ cd data1/data/
[ansible@node1 data]$ ls
link1  link2  link3  link3_hard  link4  link4_hard  origin  origin3.txt  origin4.txt
[ansible@node1 data]$ ll -i .
total 24
33657124 drwxr-xr-x 2 root root 44 Aug  3 16:54 link1
50445906 drwxr-xr-x 2 root root 44 Aug  3 16:54 link2
18061210 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3
16781287 -rw-r--r-- 1 root root  9 Aug  3 16:54 link3_hard
18061222 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4
16777294 -rw-r--r-- 1 root root  9 Aug  3 16:54 link4_hard
  211760 drwxr-xr-x 2 root root 44 Aug  3 16:54 origin
18061205 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin3.txt
18061208 -rw-r--r-- 1 root root  9 Aug  3 16:54 origin4.txt
[ansible@node1 data]$ cat link3
origin 3
[ansible@node1 data]$ cat link3_hard 
origin 3
[ansible@node1 data]$ cat link4
origin 4
[ansible@node1 data]$ cat link4_hard 
origin 4
[ansible@node1 data]$ cat origin3.txt 
origin 3
[ansible@node1 data]$ cat origin4.txt 
origin 4
[ansible@node1 data]$ 
```

可以看到，这个时候全部都被当做普通的文件，并没有链接文件。

我们先保留`data1`和`data2`这两个文件夹，以便于后面生成的文件进行对比分析。

我们通过`local_follow`和`follow`来控制一下输出结果。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory with local follow yes and follow no
      copy:
        src: /home/ansible/data/
        dest: /tmp/local_yes_remote_no
        local_follow: yes
        follow: no
      become: yes

    - name: Copy directory with local follow yes and follow yes
      copy:
        src: /home/ansible/data/
        dest: /tmp/local_yes_remote_yes
        local_follow: yes
        follow: yes
      become: yes

    - name: Copy directory with local follow no and follow no
      copy:
        src: /home/ansible/data/
        dest: /tmp/local_no_remote_no
        local_follow: no
        follow: no
      become: yes

    - name: Copy directory with local follow no and follow yes
      copy:
        src: /home/ansible/data/
        dest: /tmp/local_no_remote_yes
        local_follow: no
        follow: yes
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory with local follow yes and follow no] ****************************
changed: [node1] => {"changed": true, "dest": "/tmp/local_yes_remote_no/", "src": "/home/ansible/data/"}

TASK [Copy directory with local follow yes and follow yes] ***************************
changed: [node1] => {"changed": true, "dest": "/tmp/local_yes_remote_yes/", "src": "/home/ansible/data/"}

TASK [Copy directory with local follow no and follow no] *****************************
changed: [node1] => {"changed": true, "dest": "/tmp/local_no_remote_no/", "src": "/home/ansible/data/"}

TASK [Copy directory with local follow no and follow yes] ****************************
changed: [node1] => {"changed": true, "dest": "/tmp/local_no_remote_yes/", "src": "/home/ansible/data/"}

PLAY RECAP ***************************************************************************
node1                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

分四种情况控制复制后的输出。

我们在node1节点上面检查一下：

```sh
[ansible@node1 tmp]$ ll -i local_*
local_no_remote_no:
total 16
50442694 lrwxrwxrwx 1 root root  6 Aug  3 17:28 link1 -> origin
50442699 lrwxrwxrwx 1 root root  6 Aug  3 17:28 link2 -> origin
50445918 lrwxrwxrwx 1 root root 11 Aug  3 17:28 link3 -> origin3.txt
  138484 -rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
50445919 lrwxrwxrwx 1 root root 11 Aug  3 17:28 link4 -> origin4.txt
  138485 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
  138487 drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
  138469 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
  138483 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt

local_no_remote_yes:
total 16
50418359 lrwxrwxrwx 1 root root  6 Aug  3 17:28 link1 -> origin
50669612 lrwxrwxrwx 1 root root  6 Aug  3 17:28 link2 -> origin
50418356 lrwxrwxrwx 1 root root 11 Aug  3 17:28 link3 -> origin3.txt
  138491 -rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
50418358 lrwxrwxrwx 1 root root 11 Aug  3 17:28 link4 -> origin4.txt
  138492 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
  138494 drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
  138482 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
  138490 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt

local_yes_remote_no:
total 24
  787855 drwxr-xr-x 2 root root 44 Aug  3 17:27 link1
17046822 drwxr-xr-x 2 root root 44 Aug  3 17:27 link2
  400313 -rw-r--r-- 1 root root  9 Aug  3 17:27 link3
  787842 -rw-r--r-- 1 root root  9 Aug  3 17:27 link3_hard
  400399 -rw-r--r-- 1 root root  9 Aug  3 17:27 link4
  787851 -rw-r--r-- 1 root root  9 Aug  3 17:27 link4_hard
33657163 drwxr-xr-x 2 root root 44 Aug  3 17:27 origin
  314101 -rw-r--r-- 1 root root  9 Aug  3 17:27 origin3.txt
  400312 -rw-r--r-- 1 root root  9 Aug  3 17:27 origin4.txt

local_yes_remote_yes:
total 24
  138476 drwxr-xr-x 2 root root 44 Aug  3 17:28 link1
17430706 drwxr-xr-x 2 root root 44 Aug  3 17:28 link2
  138471 -rw-r--r-- 1 root root  9 Aug  3 17:27 link3
  138473 -rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
  138472 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4
  138474 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
33657164 drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
  138468 -rw-r--r-- 1 root root  9 Aug  3 17:27 origin3.txt
  138470 -rw-r--r-- 1 root root  9 Aug  3 17:27 origin4.txt
[ansible@node1 tmp]$ 
```

可以看出，复制后的内容权限比较复杂！`local_no_remote_no`和`local_no_remote_yes`文件夹内容一样，此时因为不跟随链接文件，软链接仍然存在；`local_yes_remote_no`和`local_yes_remote_yes`文件夹内容一样，此时跟随链接文件，会直接复制软链接指向的文件夹中的文件。

可以知道，对于从Ansible主机上面复制文件到远程主机，仅`local_follow`起作用，`follow`不起作用！



我们在测试一下，在远程主机上面使用`follow`参数进行文件复制。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy remote directory with follow yes
      copy:
        src: /tmp/local_no_remote_no/
        dest: /tmp/remote_yes
        remote_src: yes
        follow: yes
      become: yes

    - name: Copy remote directory with follow no
      copy:
        src: /tmp/local_no_remote_no/
        dest: /tmp/remote_no
        remote_src: yes
        follow: no
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy remote directory with follow yes] *****************************************
changed: [node1] => {"changed": true, "checksum": null, "dest": "/tmp/remote_yes", "gid": 0, "group": "root", "md5sum": null, "mode": "0755", "owner": "root", "size": 146, "src": "/tmp/local_no_remote_no/", "state": "directory", "uid": 0}

TASK [Copy remote directory with follow no] ******************************************
changed: [node1] => {"changed": true, "checksum": null, "dest": "/tmp/remote_no", "gid": 0, "group": "root", "md5sum": null, "mode": "0755", "owner": "root", "size": 146, "src": "/tmp/local_no_remote_no/", "state": "directory", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时再查看新生成的文件夹：

```sh
[ansible@node1 tmp]$ ll -i remote_*
remote_no:
total 16
33608953 lrwxrwxrwx 1 root root  6 Aug  4 16:52 link1 -> origin
33608955 lrwxrwxrwx 1 root root  6 Aug  4 16:52 link2 -> origin
33608938 lrwxrwxrwx 1 root root 11 Aug  4 16:52 link3 -> origin3.txt
33575000 -rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
33608951 lrwxrwxrwx 1 root root 11 Aug  4 16:52 link4 -> origin4.txt
33575002 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
50442985 drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
33574993 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
33574995 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt

remote_yes:
total 16
33653763 lrwxrwxrwx 1 root root  6 Aug  4 16:52 link1 -> origin
33653764 lrwxrwxrwx 1 root root  6 Aug  4 16:52 link2 -> origin
33657182 lrwxrwxrwx 1 root root 11 Aug  4 16:52 link3 -> origin3.txt
33657180 -rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
33657183 lrwxrwxrwx 1 root root 11 Aug  4 16:52 link4 -> origin4.txt
33657181 -rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
50442982 drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
33657161 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
33657179 -rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt
[ansible@node1 tmp]$ 
```

可以看到，文件跟随了文件系统，`follow`没有起作用！！！有可能我理解错了！



我们把`follow`换成`local_follow`再来试一下：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy remote directory with local_follow yes
      copy:
        src: /tmp/local_no_remote_no/
        dest: /tmp/local_follow_yes
        remote_src: yes
        local_follow: yes
      become: yes

    - name: Copy remote directory with local_follow no
      copy:
        src: /tmp/local_no_remote_no/
        dest: /tmp/local_follow_no
        remote_src: yes
        local_follow: no
      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy remote directory with local_follow yes] ***********************************
changed: [node1] => {"changed": true, "checksum": null, "dest": "/tmp/local_follow_yes", "gid": 0, "group": "root", "md5sum": null, "mode": "0755", "owner": "root", "size": 146, "src": "/tmp/local_no_remote_no/", "state": "directory", "uid": 0}

TASK [Copy remote directory with local_follow no] ************************************
changed: [node1] => {"changed": true, "checksum": null, "dest": "/tmp/local_follow_no", "gid": 0, "group": "root", "md5sum": null, "mode": "0755", "owner": "root", "size": 146, "src": "/tmp/local_no_remote_no/", "state": "directory", "uid": 0}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时再查看文件系统：

```sh
[ansible@node1 tmp]$ ll local_follow_*
local_follow_no:
total 16
lrwxrwxrwx 1 root root  6 Aug  4 16:59 link1 -> origin
lrwxrwxrwx 1 root root  6 Aug  4 16:59 link2 -> origin
lrwxrwxrwx 1 root root 11 Aug  4 16:59 link3 -> origin3.txt
-rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
lrwxrwxrwx 1 root root 11 Aug  4 16:59 link4 -> origin4.txt
-rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
-rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
-rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt

local_follow_yes:
total 24
drwxr-xr-x 2 root root 44 Aug  3 17:28 link1
drwxr-xr-x 2 root root 44 Aug  3 17:28 link2
-rw-r--r-- 1 root root  9 Aug  3 17:28 link3
-rw-r--r-- 1 root root  9 Aug  3 17:28 link3_hard
-rw-r--r-- 1 root root  9 Aug  3 17:28 link4
-rw-r--r-- 1 root root  9 Aug  3 17:28 link4_hard
drwxr-xr-x 2 root root 44 Aug  3 17:28 origin
-rw-r--r-- 1 root root  9 Aug  3 17:28 origin3.txt
-rw-r--r-- 1 root root  9 Aug  3 17:28 origin4.txt
[ansible@node1 tmp]$ 
```

即可以看出`local_follow`是指定是否跟随源文件的，如果源文件是一个软链接文件并且链接到一个目录，则会创建一个同名的目标文件夹，并将源文件软链接指向的文件夹的内容复制到这个目标文件夹中。如果源文件是一个软链接文件，链接到一个文件，则会创建一个同名的目标文件，并将源文件软链接指向的文件的内容复制到这个目标文件中。

我们把node1节点上面生成的测试文件删除掉：

```sh
[ansible@node1 tmp]$ sudo trash-put data* local_* remote_*
[ansible@node1 tmp]$ sudo trash-empty
```



我们前面对`follow`参数理解有误！

我们重新进行一下测试。

我们来创建一个软链接和一个硬链接：

```sh
[ansible@node1 tmp]$ mkdir origin1
[ansible@node1 tmp]$ ln -s origin1 origin1_soft
[ansible@node1 tmp]$ mkdir origin2
[ansible@node1 tmp]$ ln -s origin2 origin2_soft
[ansible@node1 tmp]$ ll -id origin*
16777294 drwxrwxr-x 2 ansible ansible 6 Aug  4 17:11 origin1
17039808 lrwxrwxrwx 1 ansible ansible 7 Aug  4 17:11 origin1_soft -> origin1
50418355 drwxrwxr-x 2 ansible ansible 6 Aug  4 17:15 origin2
17039809 lrwxrwxrwx 1 ansible ansible 7 Aug  4 17:16 origin2_soft -> origin2
```

我们重新测试一下，通过控制`follow`参数来复制文件：

```sh
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory with follow yes] ************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: OSError: [Errno 17] File exists: '/tmp/origin1_soft'
fatal: [node1]: FAILED! => {"changed": false, "checksum": "583b2b893e08e60a29a3d1b4d8acef00b08b9fdc", "module_stderr": "Shared connection to node1 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1596533019.5-3995-256786935668312/AnsiballZ_copy.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1596533019.5-3995-256786935668312/AnsiballZ_copy.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1596533019.5-3995-256786935668312/AnsiballZ_copy.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.files.copy', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_copy_payload_b0y6Zc/ansible_copy_payload.zip/ansible/modules/files/copy.py\", line 790, in <module>\r\n    \r\n  File \"/tmp/ansible_copy_payload_b0y6Zc/ansible_copy_payload.zip/ansible/modules/files/copy.py\", line 588, in main\r\n    \r\n  File \"/usr/lib64/python2.7/os.py\", line 157, in makedirs\r\n    mkdir(name, mode)\r\nOSError: [Errno 17] File exists: '/tmp/origin1_soft'\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

复制文件夹出错！因为提示文件夹已经存在！

我们来测试文件看一下。

创建一些文件：

```sh
[ansible@node1 tmp]$ echo "file origin 1" > file1_origin
[ansible@node1 tmp]$ echo "file origin 2" > file2_origin
[ansible@node1 tmp]$ ln -s file1_origin file1_soft
[ansible@node1 tmp]$ ln -s file2_origin file2_soft
[ansible@node1 tmp]$ ll file*
-rw-rw-r-- 1 ansible ansible 14 Aug  4 17:37 file1_origin
lrwxrwxrwx 1 ansible ansible 12 Aug  4 17:37 file1_soft -> file1_origin
-rw-rw-r-- 1 ansible ansible 14 Aug  4 17:37 file2_origin
lrwxrwxrwx 1 ansible ansible 12 Aug  4 17:37 file2_soft -> file2_origin
[ansible@node1 tmp]$ 
```

再进行复制：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy file with follow yes
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file1_soft
        follow: yes
      become: yes

    - name: Copy file with follow no
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file2_soft
        follow: no
      become: yes


[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy file with follow yes] *****************************************************
fatal: [node1]: FAILED! => {"msg": "Failed to get information on remote file (/tmp/file1_soft): Permission denied"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```

oh,no!又失败了！提示`Failed to get information on remote file (/tmp/file1_soft): Permission denied`，按理说，使用了`become: yes`权限提升后，应该是有权限的！我们通过`root`账号查看`file1_soft`时会提示错误：

```sh
[root@node1 tmp]# cat file1_soft
cat: file1_soft: Permission denied
```

可以看到，直接使用`cat`查看软链接文件会提示权限拒绝。

查看文档知道，`/tmp`目录由于通常设置了粘滞位，因为`protected_symlinks`拒绝访问`/tmp/file1_soft`，即`/tmp`目录比较特殊。

通过以下命令可以查看已经开启了`fs.protected_symlinks`保护：

```sh
# 设置为0时，符号链接跟随行为不受限制。
# 设置为1时，符号链接跟随行为受限制。
[root@node1 ~]# sysctl -n fs.protected_symlinks
1
```

说明系统开启了`fs.protected_symlinks`保护。



我们看一段粘滞位的介绍。

> **文件的粘滞位(sticky)位是作什么用的？**
> 普通文件的sticky位会被linux内核忽略，目录的sticky位表示这个目录里的文件只能被owner和root删除。
>
> 如果用户对目录有写权限，则可以删除其中的文件和子目录，即使该用户不是这些文件的所有者，而且也没有读或写许可。粘滞位出现执行许可的位置上，用`t`表示，设置了该位后，其它用户就不可以删除不属于他的文件和目录。但是该目录下的目录不继承该权限，要再设置才可使用。
>
> 可以通过以下命令设置粘滞位，`770`前面的`1`就表示设置粘滞位：
>
> ```sh
> $ chmod 1770 xxx
> ```
>
> 举一个linux下的常见目录来做例子，也就是 /tmp 目录来说一下粘滞位的作用。
>
> ```sh
> [root@node1 ~]# ls -ld /tmp/
> drwxrwxrwt. 11 root root 4096 Aug  5 10:08 /tmp/
> [root@node1 ~]# 
> ```
>
> 注意other位置的`t`，这便是粘滞位。
> 我们都知道，`/tmp`常被我们用来存放临时文件，是所有用户。但是我们不希望别的用户随随便便的就删除了自己的文件，于是便有了粘滞位，它的作用便是让用户只能删除属于自己的文件。
>
> 那么原来的执行标志`x`到哪里去了呢? 系统是这样规定的, 假如本来在该位上有`x`, 则这些特别标志 (suid, sgid, sticky) 显示为小写字母 (s, s, t). 否则, 显示为大写字母 (S, S, T) 。
>
> 操作：
>
> ```sh
> $ chmod 777 xxx
> $ chmod +t xxx
> ```
>
> 等价于:
>
> ```sh
> chmod 1777 xxx
> ```
>
> 在以前旧的系统当中,如果一个程序文件一旦设置了粘滞位,那么当该程序中止的时候他的所有指令段将被保存到系统的交换分区当中,
> 再次运行时可以更快的调入系统.
>
> 不过现在的操作系统已经不再使用这种功能了.但这并不表示这一功能已经完全被废弃.当一个目录设置为粘滞位时，它将发挥特殊的作用,
>
> 即当一个目录被设置为"粘滞位"(用`chmod a+t`),则该目录下的文件只能由:
>
> - 超级管理员删除
>
> - 该目录的所有者删除
>
> - 该文件的所有者删除
>
>
> 也就是说,即便该目录是任何人都可以写,但也只有文件的属主才可以删除文件。

好，我们现在不进行权限提升，修改一下剧本文件，再重新运行：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy file with follow yes
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file1_soft
        follow: yes
# become: yes

    - name: Copy file with follow no
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file2_soft
        follow: no
#      become: yes

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy file with follow yes] *****************************************************
changed: [node1] => {"changed": true, "checksum": "6cbe55a8cc71c4fbc6c5a84b109bb2691e9b86fb", "dest": "/tmp/file1_origin", "gid": 1001, "group": "ansible", "md5sum": "8fc9dd5b009c4b04c69018a441dbb04b", "mode": "0664", "owner": "ansible", "size": 329, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596592106.27-3715-174756753287401/source", "state": "file", "uid": 1001}

TASK [Copy file with follow no] ******************************************************
changed: [node1] => {"changed": true, "checksum": "6cbe55a8cc71c4fbc6c5a84b109bb2691e9b86fb", "dest": "/tmp/file2_soft", "gid": 1001, "group": "ansible", "md5sum": "8fc9dd5b009c4b04c69018a441dbb04b", "mode": "0664", "owner": "ansible", "size": 329, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1596592106.91-3731-137128704257098/source", "state": "file", "uid": 1001}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

这次运行成功了！我们来看一下node1节点上面的文件变化：

```sh
[root@node1 tmp]# ll -i file*
  314098 -rw-rw-r-- 1 ansible ansible 329 Aug  5 09:48 file1_origin
17039822 lrwxrwxrwx 1 ansible ansible  12 Aug  4 17:37 file1_soft -> file1_origin
16781287 -rw-rw-r-- 1 ansible ansible  14 Aug  4 17:37 file2_origin
50445901 -rw-rw-r-- 1 ansible ansible 329 Aug  5 09:48 file2_soft
[root@node1 tmp]# 
```

由于任务`Copy file with follow yes`开启了`follow: yes`进行目标系统文件的跟随,此时,将`copy.yml`复制到`file1_soft`时,会自动跟踪`file1_soft`指向的文件`file1_origin`,所以此时会将`file1_origin`进行替换覆盖掉:

```sh
[ansible@node1 tmp]$ cat file1_soft 
- hosts: node1
  tasks:
    - name: Copy file with follow yes
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file1_soft
        follow: yes
# become: yes

    - name: Copy file with follow no
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file2_soft
        follow: no
#      become: yes

[ansible@node1 tmp]$ cat file1_origin 
- hosts: node1
  tasks:
    - name: Copy file with follow yes
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file1_soft
        follow: yes
# become: yes

    - name: Copy file with follow no
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file2_soft
        follow: no
#      become: yes

[ansible@node1 tmp]$ 
```

由于任务`Copy file with follow no`没有开启了`follow`功能,指定的`follow: no`**不进行目标系统文件的跟随**,此时,`file2_soft`原来的链接关系将会被打破,`file2_soft`变成一个普通的文件,并将`copy.yml`复制到`file2_soft`这个普通文件,而`file2_soft`原先指向的`file2_origin`没有发生变化:

```sh
[ansible@node1 tmp]$ cat file2_soft 
- hosts: node1
  tasks:
    - name: Copy file with follow yes
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file1_soft
        follow: yes
# become: yes

    - name: Copy file with follow no
      copy:
        src: /home/ansible/copy.yml
        dest: /tmp/file2_soft
        follow: no
#      become: yes

[ansible@node1 tmp]$ cat file2_origin 
file origin 2
[ansible@node1 tmp]$ 
```

我们把测试文件删除掉:

```sh
[ansible@node1 tmp]$ trash-put file*
[ansible@node1 tmp]$ trash-put origin*
[ansible@node1 tmp]$ trash-empty
[ansible@node1 tmp]$ 
```



### 5.9 文件夹模式设置

我们可以使用`directory_mode`来设置目标文件夹的文件夹权限模式。当进行递归复制时，新创建的文件夹使用的文件夹模式，该参数对已经存在的文件夹没有影响。

我们先使用临时命令将Ansible主机上面的`data`目录复制到node1节点上面去。

```sh
# 先把权限改回来
[ansible@master ~]$ sudo chown -R ansible:ansible data
[ansible@master ~]$ ll data/
total 16
lrwxrwxrwx 1 ansible ansible  6 Aug  3 16:34 link1 -> origin
lrwxrwxrwx 1 ansible ansible  6 Aug  3 16:34 link2 -> origin
lrwxrwxrwx 1 ansible ansible 11 Aug  3 16:35 link3 -> origin3.txt
-rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 link3_hard
lrwxrwxrwx 1 ansible ansible 11 Aug  3 16:35 link4 -> origin4.txt
-rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 link4_hard
drwxrwxr-x 2 ansible ansible 44 Aug  3 16:34 origin
-rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 origin3.txt
-rw-rw-r-- 2 ansible ansible  9 Aug  3 16:35 origin4.txt
[ansible@master ~]$ 
```

再进行复制：

```sh
[ansible@master ~]$ ansible node1 -m copy -a "src=/home/ansible/data dest=/home/ansible local_follow=no"
node1 | CHANGED => {
    "changed": true, 
    "dest": "/home/ansible/", 
    "src": "/home/ansible/data"
}
[ansible@master ~]$ 
```

查看node1节点上面的文件：

```sh
[ansible@node1 ~]$ ll data/
total 16
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link2 -> origin
lrwxrwxrwx 1 ansible ansible 11 Aug  5 11:39 link3 -> origin3.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link3_hard
lrwxrwxrwx 1 ansible ansible 11 Aug  5 11:39 link4 -> origin4.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link4_hard
drwxrwxr-x 2 ansible ansible 44 Aug  5 11:39 origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin4.txt
[ansible@node1 ~]$ 
```

好，准备工作做得差不多了，我们现在在Ansible主机上面的data目录下面创建一些新的文件夹：

```sh
[ansible@master ~]$ mkdir -p data/{new1,new11}/{new2,new22}/{new3,new33}
[ansible@master ~]$ tree data/
data/
├── link1 -> origin
├── link2 -> origin
├── link3 -> origin3.txt
├── link3_hard
├── link4 -> origin4.txt
├── link4_hard
├── new1
│   ├── new2
│   │   ├── new3
│   │   └── new33
│   └── new22
│       ├── new3
│       └── new33
├── new11
│   ├── new2
│   │   ├── new3
│   │   └── new33
│   └── new22
│       ├── new3
│       └── new33
├── origin
│   ├── origin1.txt
│   └── origin2.txt
├── origin3.txt
└── origin4.txt

17 directories, 8 files

[ansible@master ~]$ ls -lah data/new1
total 0
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 .
drwxrwxr-x 5 ansible ansible 171 Aug  5 11:43 ..
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 new2
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 new22
[ansible@master ~]$ ls -lah data/new11
total 0
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 .
drwxrwxr-x 5 ansible ansible 171 Aug  5 11:43 ..
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 new2
drwxrwxr-x 4 ansible ansible  31 Aug  5 11:43 new22
[ansible@master ~]$ ls -lah data/new1/new2
total 0
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 .
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 ..
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new3
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new33
[ansible@master ~]$ ls -lah data/new1/new22
total 0
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 .
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 ..
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new3
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new33
[ansible@master ~]$ ls -lah data/new11/new2
total 0
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 .
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 ..
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new3
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new33
[ansible@master ~]$ ls -lah data/new11/new22
total 0
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 .
drwxrwxr-x 4 ansible ansible 31 Aug  5 11:43 ..
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new3
drwxrwxr-x 2 ansible ansible  6 Aug  5 11:43 new33
[ansible@master ~]$ 

# 更新原来origin目录下的两个文件内容
[ansible@master ~]$ cd data/origin
[ansible@master origin]$ echo "origin 1 new" > origin1.txt 
[ansible@master origin]$ echo "origin 2 new" > origin2.txt 
[ansible@master origin]$ cat origin1.txt 
origin 1 new
[ansible@master origin]$ cat origin2.txt 
origin 2 new
[ansible@master origin]$ cd
[ansible@master ~]$ 
```

新创建的文件夹的权限都是`rwxrwxr-x`,即`775`。并且原来origin目录下面的两个文件也已经更新完毕。我们现在使用剧本进行文件夹复制。

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory to exist folder with directory_mode='0700'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/data
        directory_mode: '0700'

    - name: Copy directory to new folder with directory_mode='0700'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/newdata
        directory_mode: '0700'

[ansible@master ~]$ ansible-lint copy.yml 
[ansible@master ~]$ ansible-playbook --syntax-check copy.yml 

playbook: copy.yml
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory to exist folder with directory_mode='0700'] *********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/data/", "src": "/home/ansible/data/"}

TASK [Copy directory to new folder with directory_mode='0700'] ***********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/newdata/", "src": "/home/ansible/data/"}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本正常执行，我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ ll -d *data
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 data
drwx------ 7 ansible ansible 171 Aug  5 14:05 newdata
[ansible@node1 ~]$ ll  *data
data:
total 24
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link4_hard
drwx------ 4 ansible ansible 31 Aug  5 14:05 new1
drwx------ 4 ansible ansible 31 Aug  5 14:05 new11
drwx------ 2 ansible ansible 44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin4.txt

newdata:
total 24
drwx------ 2 ansible ansible 44 Aug  5 14:05 link1
drwx------ 2 ansible ansible 44 Aug  5 14:05 link2
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link3_hard
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link4_hard
drwx------ 4 ansible ansible 31 Aug  5 14:05 new1
drwx------ 4 ansible ansible 31 Aug  5 14:05 new11
drwx------ 2 ansible ansible 44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 origin3.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 origin4.txt
[ansible@node1 ~]$ 

[ansible@node1 ~]$ ll data/{new1,new11}
data/new1:
total 0
drwx------ 4 ansible ansible 31 Aug  5 14:05 new2
drwx------ 4 ansible ansible 31 Aug  5 14:05 new22

data/new11:
total 0
drwx------ 4 ansible ansible 31 Aug  5 14:05 new2
drwx------ 4 ansible ansible 31 Aug  5 14:05 new22
[ansible@node1 ~]$ ll data/{new1,new11}/{new2,new22}
data/new11/new2:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33

data/new11/new22:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33

data/new1/new2:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33

data/new1/new22:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33
[ansible@node1 ~]$ 

# 查找权限是700的文件
[ansible@node1 ~]$ find newdata -perm '700'
newdata
newdata/link1
newdata/link2
newdata/origin
newdata/new1
newdata/new1/new2
newdata/new1/new2/new3
newdata/new1/new2/new33
newdata/new1/new22
newdata/new1/new22/new3
newdata/new1/new22/new33
newdata/new11
newdata/new11/new2
newdata/new11/new2/new3
newdata/new11/new2/new33
newdata/new11/new22
newdata/new11/new22/new3
newdata/new11/new22/new33
[ansible@node1 ~]$ find data -perm '700'
data/origin
data/new1
data/new1/new2
data/new1/new2/new3
data/new1/new2/new33
data/new1/new22
data/new1/new22/new3
data/new1/new22/new33
data/new11
data/new11/new2
data/new11/new2/new3
data/new11/new2/new33
data/new11/new22
data/new11/new22/new3
data/new11/new22/new33
[ansible@node1 ~]$ 
```

可以看到，对于原来已经存在在`data`目录，只有新增的`new1`和`new11`及其子目录以及`origin`目录的权限发生变化，都变成了`rwx------`，即`700`的形式，其他文件夹不受影响。而对于`newdata`目录，由于都是新建的文件或文件夹，文件夹都使用`0700`模式。



下面我们再将剧本里面的模式改成`0070`,这个时候再去复制：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory to exist folder with directory_mode='0070'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/data
        directory_mode: '0070'

    - name: Copy directory to new folder with directory_mode='0070'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/newdata
        directory_mode: '0070'

[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory to exist folder with directory_mode='0070'] *********************
fatal: [node1]: FAILED! => {"changed": false, "msg": "There was an issue creating /home/ansible/data/new1/new2 as requested: [Errno 13] Permission denied: '/home/ansible/data/new1/new2'", "path": "/home/ansible/data/new1/new2"}

PLAY RECAP ***************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

kuang! 出错了，因为这个时候改成了所有者也不能读和写！这时候查看node1节点上面的权限：

```sh
[ansible@node1 data]$ ll
total 24
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible  6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible  9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 link4_hard
d---rwx--- 4 ansible ansible 31 Aug  5 14:05 new1
d---rwx--- 4 ansible ansible 31 Aug  5 14:05 new11
d---rwx--- 2 ansible ansible 44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible  9 Aug  5 11:39 origin4.txt
[ansible@node1 data]$ ll new1
ls: cannot open directory new1: Permission denied
[ansible@node1 data]$ sudo ls -lah new1/
total 0
d---rwx--- 4 ansible ansible  31 Aug  5 14:05 .
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 ..
drwx------ 4 ansible ansible  31 Aug  5 14:05 new2
drwx------ 4 ansible ansible  31 Aug  5 14:05 new22
[ansible@node1 data]$ 
```

可以看到，这种随意改权限模式可能会存在问题。

我们把权限改回去：

```sh
[ansible@node1 ~]$ ls -lah data/
total 24K
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link4_hard
d---rwx--- 4 ansible ansible  31 Aug  5 14:05 new1
d---rwx--- 4 ansible ansible  31 Aug  5 14:05 new11
d---rwx--- 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin4.txt
[ansible@node1 ~]$ sudo chmod -R 700 data/{new1,new11,origin}
[ansible@node1 ~]$ ls -lah data/
total 24K
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link4_hard
drwx------ 4 ansible ansible  31 Aug  5 14:05 new1
drwx------ 4 ansible ansible  31 Aug  5 14:05 new11
drwx------ 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin4.txt
[ansible@node1 ~]$ 
```

此时权限已经改回去了。

我们重新设置一下`directory_mode='0770'`,再运行剧本:

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory to exist folder with directory_mode='0770'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/data
        directory_mode: '0770'

    - name: Copy directory to new folder with directory_mode='0770'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/newdata
        directory_mode: '0770'

[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory to exist folder with directory_mode='0770'] *********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/data/", "src": "/home/ansible/data/"}

TASK [Copy directory to new folder with directory_mode='0770'] ***********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/newdata/", "src": "/home/ansible/data/"}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时检查node1节点上面的文件夹情况：

```sh
[ansible@node1 ~]$ ls -ld data newdata
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 data
drwx------ 7 ansible ansible 171 Aug  5 14:05 newdata
[ansible@node1 ~]$ ls -lah data/
total 24K
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link4_hard
drwxrwx--- 4 ansible ansible  31 Aug  5 14:05 new1
drwxrwx--- 4 ansible ansible  31 Aug  5 14:05 new11
drwxrwx--- 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin4.txt
[ansible@node1 ~]$ ls -lah newdata/
total 24K
drwx------ 7 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
drwxrwx--- 2 ansible ansible  44 Aug  5 14:05 link1
drwxrwx--- 2 ansible ansible  44 Aug  5 14:05 link2
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4_hard
drwxrwx--- 4 ansible ansible  31 Aug  5 14:05 new1
drwxrwx--- 4 ansible ansible  31 Aug  5 14:05 new11
drwxrwx--- 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 origin4.txt
[ansible@node1 ~]$ find data -perm '770'
data/origin
data/new1
data/new1/new2
data/new1/new2/new3
data/new1/new2/new33
data/new1/new22
data/new1/new22/new3
data/new1/new22/new33
data/new11
data/new11/new2
data/new11/new2/new3
data/new11/new2/new33
data/new11/new22
data/new11/new22/new3
data/new11/new22/new33
[ansible@node1 ~]$ find newdata -perm '770'
newdata/link1
newdata/link2
newdata/origin
newdata/new1
newdata/new1/new2
newdata/new1/new2/new3
newdata/new1/new2/new33
newdata/new1/new22
newdata/new1/new22/new3
newdata/new1/new22/new33
newdata/new11
newdata/new11/new2
newdata/new11/new2/new3
newdata/new11/new2/new33
newdata/new11/new22
newdata/new11/new22/new3
newdata/new11/new22/new33
[ansible@node1 ~]$ 
```

可以看到，虽然父目录的权限没有发生变化，但子目录的权限都发生变化了！可见并不是新建的文件夹才会受影响！

> **directory_mode**
>
> When doing a recursive copy set the mode for the directories.
>
> If this is not set we will use the system defaults.
>
> The mode is only set on directories which are newly created, and will not affect those that already existed.

而官方文档上面这么写的，通过验证可知，这种说法并不准确！

我们再次试一下，将directory_mode='0777'`,再运行剧本:

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory to exist folder with directory_mode='0777'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/data
        directory_mode: '0777'

    - name: Copy directory to new folder with directory_mode='0777'
      copy:
        src: /home/ansible/data/
        dest: /home/ansible/newdata
        directory_mode: '0777'

[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory to exist folder with directory_mode='0777'] *********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/data/", "src": "/home/ansible/data/"}

TASK [Copy directory to new folder with directory_mode='0777'] ***********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/newdata/", "src": "/home/ansible/data/"}

PLAY RECAP ***************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

再次查看node1节点权限情况：

```sh
[ansible@node1 ~]$ ls -ld data newdata
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 data
drwx------ 7 ansible ansible 171 Aug  5 14:05 newdata
[ansible@node1 ~]$ ls -lah data/
total 24K
drwxrwxr-x 5 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link1 -> origin
lrwxrwxrwx 1 ansible ansible   6 Aug  5 11:39 link2 -> origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 link4_hard
drwxrwxrwx 4 ansible ansible  31 Aug  5 14:05 new1
drwxrwxrwx 4 ansible ansible  31 Aug  5 14:05 new11
drwxrwxrwx 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 11:39 origin4.txt
[ansible@node1 ~]$ ls -lah newdata/
total 24K
drwx------ 7 ansible ansible 171 Aug  5 14:05 .
drwx------ 9 ansible ansible 331 Aug  5 14:05 ..
drwxrwxrwx 2 ansible ansible  44 Aug  5 14:05 link1
drwxrwxrwx 2 ansible ansible  44 Aug  5 14:05 link2
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link3_hard
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 link4_hard
drwxrwxrwx 4 ansible ansible  31 Aug  5 14:05 new1
drwxrwxrwx 4 ansible ansible  31 Aug  5 14:05 new11
drwxrwxrwx 2 ansible ansible  44 Aug  5 14:05 origin
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 origin3.txt
-rw-rw-r-- 1 ansible ansible   9 Aug  5 14:05 origin4.txt
[ansible@node1 ~]$ find data -perm '777'
data/origin
data/link1
data/link2
data/new1
data/new1/new2
data/new1/new2/new3
data/new1/new2/new33
data/new1/new22
data/new1/new22/new3
data/new1/new22/new33
data/new11
data/new11/new2
data/new11/new2/new3
data/new11/new2/new33
data/new11/new22
data/new11/new22/new3
data/new11/new22/new33
[ansible@node1 ~]$ find newdata -perm '777'
newdata/link1
newdata/link2
newdata/origin
newdata/new1
newdata/new1/new2
newdata/new1/new2/new3
newdata/new1/new2/new33
newdata/new1/new22
newdata/new1/new22/new3
newdata/new1/new22/new33
newdata/new11
newdata/new11/new2
newdata/new11/new2/new3
newdata/new11/new2/new33
newdata/new11/new22
newdata/new11/new22/new3
newdata/new11/new22/new33
[ansible@node1 ~]$ 
```

可以看到，并没有新的文件产生，但是文件夹的权限却发生了变化！

我们再来测试一下子文件夹的复制：

```sh
[ansible@node1 ~]$ ll -d data/new1
drwxrwxrwx 4 ansible ansible 31 Aug  5 15:25 data/new1
[ansible@node1 ~]$ ll  data/new1
total 0
drwxrwxrwx 4 ansible ansible 31 Aug  5 14:05 new2
drwxrwxrwx 4 ansible ansible 31 Aug  5 14:05 new22
```

我们复制`new1`目录：

```sh
[ansible@master ~]$ cat copy.yml 
- hosts: node1
  tasks:
    - name: Copy directory to exist folder with directory_mode='0700'
      copy:
        src: /home/ansible/data/new1/
        dest: /home/ansible/data/new1
        directory_mode: '0700'
[ansible@master ~]$ ansible-playbook copy.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************

TASK [Gathering Facts] ***************************************************************
ok: [node1]

TASK [Copy directory to exist folder with directory_mode='0700'] *********************
changed: [node1] => {"changed": true, "dest": "/home/ansible/data/new1/", "src": "/home/ansible/data/new1/"}

PLAY RECAP ***************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

再次查看目录权限：

```sh
[ansible@node1 ~]$ ll -d data/new1
drwxrwxrwx 4 ansible ansible 31 Aug  5 15:25 data/new1
[ansible@node1 ~]$ ll  data/new1
total 0
drwx------ 4 ansible ansible 31 Aug  5 14:05 new2
drwx------ 4 ansible ansible 31 Aug  5 14:05 new22
[ansible@node1 ~]$ ll  data/new1/*
data/new1/new2:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33

data/new1/new22:
total 0
drwx------ 2 ansible ansible 6 Aug  5 14:05 new3
drwx------ 2 ansible ansible 6 Aug  5 14:05 new33
```

可以看到目标系统中的目标目录`data/new1`的权限并没有发生变化，但目标目录`data/new1`的子目录权限发生了变化！！！

记得删除测试文件！



## 6. 总结

- 使用相对路径时，Ansible会从用户家目录或者家目录下面的`files`文件夹去搜索需要复制的文件。
- 使用`backup`参数可以对目录文件进行备份。
- 使用`mode`修改权限时，应该将user/group/other都指定出来！
- `local_follow`是指定是否跟随源文件的，如果源文件是一个软链接文件并且链接到一个目录，则会创建一个同名的目标文件夹，并将源文件软链接指向的文件夹的内容复制到这个目标文件夹中。如果源文件是一个软链接文件，链接到一个文件，则会创建一个同名的目标文件，并将源文件软链接指向的文件的内容复制到这个目标文件中。
- `follow`可以跟踪目标系统上面的文件软链接，设置`follow=yes`时，会对软链接指向的文件进行覆盖重写，软链接关系仍然存在。设置`follow=no`时，软链接关系被破坏，软链接文件变成一个普通文件，软链接指向的文件保持不变，会将源文件内容复制到这个普通文件中。
- `directory_mode`参数会改变文件夹复制到目标系统上面的文件夹权限模式，如果目标目录不存在，则会新建目录，并且对目标目录及其子目录都会应用该文件夹权限模式；如果目标目录存在，则不会影响目标目录本身，只会影响目标目录的子目录！



参考:

- [Ansible copy Module Tutorial + Examples](https://www.toptechskills.com/ansible-tutorials-courses/ansible-copy-module-tutorial-examples/)
- [How can I copy a multi-line string to a file with literal newlines?](https://stackoverflow.com/questions/55540994/how-can-i-copy-a-multi-line-string-to-a-file-with-literal-newlines)