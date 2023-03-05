# tempfile模块

[[toc]]

## 1. 概要

- `tempfile`模块创建临时文件和目录。 `mktemp`命令在不同的系统上采用不同的参数，这个模块有助于避免与此相关的麻烦。 模块创建的文件/目录只能由创建者访问。 如果您需要让它们可供其他人访问，您需要使用`ansible.builtin.file` 模块。
- 官方文档：[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/tempfile_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/tempfile_module.html)



## 2. 参数

| 参数                     | 可选值 | 默认值 | 说明                                                         |
| ------------------------ | ------ | ------ | ------------------------------------------------------------ |
| `path`             |        |        | `path`，临时文件或目录创建的位置路径。如果不指定则会使用系统默认的临时目录路径 |
| `prefix`             |        |  "ansible."      | `string`，临时文件或目录的前缀 |
| `state`             | "file"、"directory"       |  "file"      | `string`，创建临时文件还是创建临时目录，默认创建临时文件 |
| `suffix`             |        |  ""      | `string`，临时文件或目录的后缀 |


## 3. 官方示例

```yaml
- name: Create temporary build directory
  ansible.builtin.tempfile:
    state: directory
    suffix: build

- name: Create temporary file
  ansible.builtin.tempfile:
    state: file
    suffix: temp
  register: tempfile_1

- name: Use the registered var and the file module to remove the temporary file
  ansible.builtin.file:
    path: "{{ tempfile_1.path }}"
    state: absent
  when: tempfile_1.path is defined
```

## 4. 剧本的使用

创建剧本文件`tempfile.yml`:

```yaml
- hosts: node1
  tasks:
    - name: Create temporary build directory
      ansible.builtin.tempfile:
        state: directory
        suffix: build

    - name: Create temporary file with prefix
      ansible.builtin.tempfile:
        state: file
        prefix: ansible_temp_

    - name: Create temporary file with suffix
      ansible.builtin.tempfile:
        state: file
        suffix: .temp

    - name: Create temporary file with path
      ansible.builtin.tempfile:
        state: file
        # path定义的目录需要存在
        path: /var/log/tempfile
      become: yes
```

检查剧本语法并执行：

```sh
[ansible@master ansible_playbooks]$ ansible-lint tempfile.yml 
[ansible@master ansible_playbooks]$ ansible-playbook tempfile.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************
ok: [node1]

TASK [Create temporary build directory] **********************************************************************************************************************************
changed: [node1] => {"changed": true, "gid": 1002, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/tmp/ansible.dylJ0sbuild", "size": 4096, "state": "directory", "uid": 1002}                                                                                                                                                     

TASK [Create temporary file with prefix] *********************************************************************************************************************************
changed: [node1] => {"changed": true, "gid": 1002, "group": "ansible", "mode": "0600", "owner": "ansible", "path": "/tmp/ansible_temp_lY7kn5", "size": 0, "state": "file", "uid": 1002}                                                                                                                                                             

TASK [Create temporary file with suffix] *********************************************************************************************************************************
changed: [node1] => {"changed": true, "gid": 1002, "group": "ansible", "mode": "0600", "owner": "ansible", "path": "/tmp/ansible.1hP3WN.temp", "size": 0, "state": "file", "uid": 1002}                                                                                                                                                              

TASK [Create temporary file with path] ***********************************************************************************************************************************
changed: [node1] => {"changed": true, "gid": 0, "group": "root", "mode": "0600", "owner": "root", "path": "/var/log/tempfile/ansible.1txuKd", "size": 0, "state": "file", "uid": 0}                                                                                                                                                                 

PLAY RECAP ***************************************************************************************************************************************************************
node1                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ansible_playbooks]$ 
```

在节点上检查生成的临时文件：

```sh
[meizhaohui@node1 ~]$ ll -d /tmp/ansible*
-rw------- 1 ansible ansible    0 Jan 14 09:03 /tmp/ansible.1hP3WN.temp
drwx------ 2 ansible ansible 4096 Jan 14 09:03 /tmp/ansible.dylJ0sbuild
-rw------- 1 ansible ansible    0 Jan 14 09:03 /tmp/ansible_temp_lY7kn5
[meizhaohui@node1 ~]$ ll -d /var/log/tempfile/ansible.1txuKd 
-rw------- 1 root root 0 Jan 14 09:03 /var/log/tempfile/ansible.1txuKd
```

可以看到，临时文件和临时文件夹创建成功。

- 当不指定`path`路径时，会默认在`/tmp`目录创建临时文件或目录。
- 当指定`path`时，`path`指定的目录需要是已经存在的，并且`ansible`用户需要在该目录有读写权限，因此需要加上`become: yes`来提升权限。