# fetch从远程主机复制文件模块

[[toc]]


## 概要

- `copy`复制模块将文件从本地或远程计算机复制到远程计算机上的某个位置。但`fetch`模块刚好相反，是从远程复制文件到ansible主机。
- 使用`fetch`访存模块可以将文件从远程位置复制到本地文件夹。
- 如果文件在目标位置已经存在，并且与源文件不同的话，则会被覆盖。
- 官方文档：[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html)

## 参数

| 参数                     | 可选值 | 默认值 | 说明                                                         |
| ------------------------ | ------ | ------ | ------------------------------------------------------------ |
| `dest`      **required** |        |        | `string`，必须字段，从远程复制的文件将保存在该目录下。       |
| `fail_on_missing`                 | yes/no | yes     | `boolean`，远程源文件缺失或不能读取时，将任务设置为失败状态。 |
| `flat`               |  yes/no      | no       | `string`，改变默认的目标存放行为，如果仅操作一个远程主机，有点类似于copy模块；当操作多个主机时，如果文件相同的话，则每个主机都会覆盖这个文件。当`dest`以`/`结尾时，`flat=yes`时会直接将文件复制到`dest`所在目录 |
| `src`      **required** |        |        | `string`,远程文件，注意不是目录，递归复暂不支持 |
| `validate_checksum`                 | yes/no | yes     | `boolean`，是否校验文件的sum值，默认校验 |

## 官方示例

```yaml
- name: Store file into /tmp/fetched/host.example.com/tmp/somefile
  ansible.builtin.fetch:
    src: /tmp/somefile
    dest: /tmp/fetched

- name: Specifying a path directly
  ansible.builtin.fetch:
    src: /tmp/somefile
    dest: /tmp/prefix-{{ inventory_hostname }}
    flat: yes

- name: Specifying a destination path
  ansible.builtin.fetch:
    src: /tmp/uniquefile
    dest: /tmp/special/
    flat: yes

- name: Storing in a path relative to the playbook
  ansible.builtin.fetch:
    src: /tmp/uniquefile
    dest: special/prefix-{{ inventory_hostname }}
    flat: yes
```

## 测试

我们直接对官方示例进行改造。

修改剧本文件：

```yaml
- hosts: myhosts
  tasks:
    - name: Store file into /tmp/fetched/host.example.com/tmp/somefile
      ansible.builtin.fetch:
        src: /etc/selinux/config
        dest: /tmp/fetched

    - name: Specifying a path directly
      ansible.builtin.fetch:
        src: /etc/selinux/config
        dest: /tmp/prefix-{{ inventory_hostname }}
        flat: yes

    - name: Specifying a destination path
      ansible.builtin.fetch:
        src: /etc/selinux/config
        dest: /tmp/special/
        flat: yes

    - name: Storing in a path relative to the playbook
      ansible.builtin.fetch:
        src: /etc/selinux/config
        dest: special/prefix-{{ inventory_hostname }}
        flat: yes

```

语法检查：

```sh
[ansible@master ansible_playbooks]$ ansible-lint fetch.yml
[ansible@master ansible_playbooks]$
```

没有异常，执行剧本：

```sh
[ansible@master ansible_playbooks]$ ansible-playbook fetch.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [myhosts] *********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]
ok: [node2]

TASK [Store file into /tmp/fetched/host.example.com/tmp/somefile] ******************************************************
changed: [node1] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/fetched/node1/etc/selinux/config", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}
changed: [node2] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/fetched/node2/etc/selinux/config", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}

TASK [Specifying a path directly] **************************************************************************************
changed: [node1] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/prefix-node1", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}
changed: [node2] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/prefix-node2", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}

TASK [Specifying a destination path] ***********************************************************************************
changed: [node1] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/special/config", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}
ok: [node2] => {"changed": false, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/tmp/special/config", "file": "/etc/selinux/config", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f"}

TASK [Storing in a path relative to the playbook] **********************************************************************
changed: [node1] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/home/ansible/ansible_playbooks/special/prefix-node1", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}
changed: [node2] => {"changed": true, "checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "dest": "/home/ansible/ansible_playbooks/special/prefix-node2", "md5sum": "34f4a7bb4ddd0d73016072466ce8350f", "remote_checksum": "46107a2c962af694d961e342fa17f4db2f2662fc", "remote_md5sum": null}

PLAY RECAP *************************************************************************************************************
node1                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node2                      : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

- 默认不使用`flat`展平时，会根据`hosts`主机配置文件中的主机名，以及远程主机上面的路径，形成一个组合路径。



第1个任务，未配置`flat`展平。按默认方式复制文件。

查看生成的文件：

```sh
[ansible@master ansible_playbooks]$ find /tmp/fetched
/tmp/fetched
/tmp/fetched/node1
/tmp/fetched/node1/etc
/tmp/fetched/node1/etc/selinux
/tmp/fetched/node1/etc/selinux/config
/tmp/fetched/node2
/tmp/fetched/node2/etc
/tmp/fetched/node2/etc/selinux
/tmp/fetched/node2/etc/selinux/config
```

可以看到，此时生成的目录是`dest`的配置路径`/tmp/fetched` + 主机名(`node1`或`node2`) + 源文件`src`的路径`/etc/selinux/config`。



第2个任务，直接指定文件的名称前缀，并后接主机名：

```sh
[ansible@master ansible_playbooks]$ ll /tmp/prefix*
-rw-r--r-- 1 ansible ansible 541 Sep 15 22:21 /tmp/prefix-node1
-rw-r--r-- 1 ansible ansible 541 Sep 15 22:21 /tmp/prefix-node2
```



此处引用一下官方对`flat`的解释：

>**flat**
>
>Allows you to override the default behavior of appending hostname/path/to/file to the destination.
>
>If `dest` ends with ‘/’, it will use the basename of the source file, similar to the copy module.
>
>This can be useful if working with a single host, or if retrieving files that are uniquely named per host.
>
>If using multiple hosts with the same filename, the file will be overwritten for each host.

第3个任务，由于进行`flat`展平，并且`dest  = /tmp/special/`路径最后包含了`/`，说明文件直接复制到该目录，由于两个主机上在`/etc/selinux/config`配置一模一样，所以`node2`节点的配置文件被忽略：

```sh
[ansible@master ansible_playbooks]$ ll /tmp/special/config
-rw-r--r-- 1 ansible ansible 541 Sep 15 22:21 /tmp/special/config
```



第4个任务，目标路径使用了相对路径，此时直接在当前工作路径生成了目标文件：

```sh
[ansible@master ansible_playbooks]$ ll
total 8
-rw-rw-r-- 1 ansible ansible  699 Sep 15 22:14 fetch.yml
drwxrwxr-x 2 ansible ansible 4096 Sep 15 22:21 special
[ansible@master ansible_playbooks]$ ll special/
total 8
-rw-r--r-- 1 ansible ansible 541 Sep 15 22:21 prefix-node1
-rw-r--r-- 1 ansible ansible 541 Sep 15 22:21 prefix-node2
```






## 返回值

| 键                                                           | 描述信息                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **changed**                                             boolean | 是否发生变更                                                 |
| **checksum**                                       string    | 复制后文件的SHA1校验和,如`46107a2c962af694d961e342fa17f4db2f2662fc` |
| **dest**                                                          string | 目标文件在ansible主机上的绝对路径                            |
| **md5sum**                                                  string | 目标文件的md5值                                              |
| **remote_checksum**                               string     | 远程文件的SHA1校验和                                         |

