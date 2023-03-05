# find查找模块

[[toc]]



## 1. 概要

- `find`查找模块会根据特定条件返回文件列表。
- 官方文档：[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/find_module.html#ansible-builtin-find-module-return-a-list-of-files-based-on-specific-criteria](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/find_module.html#ansible-builtin-find-module-return-a-list-of-files-based-on-specific-criteria)



## 2. 参数

| 参数           | 说明                                                         |
| -------------- | ------------------------------------------------------------ |
| `age`          | string。选择年龄等于或大于指定时间的文件。使用负年龄则查找等于或小于指定时间的文件。<br />可使用seconds, minutes, hours, days, or weeks等单词，也可用首字母简写，如`1w` |
| `age_stamp`    | string,选择哪个时间作为比较属性，可选值为`atime`、`ctime`和`mtime`(默认) |
| `contains`     | string,在文件内容中需要包含匹配的正则表达式或模式，只有当`file_type = file`才可用 |
| `depth`        | integer，查找的最大深度，默认无限制。当`recurse = no`时，深度为1 |
| `excludes`     | list/elements=string,需要排除的模式                          |
| `file_type`    | string，文件类型，可选值为`any`、`directory`、`link`、`file`(默认) |
| `follow`       | boolean,软链接跟随，可选值`no`/`yes`，默认`no`               |
| `get_checksum` | boolean,SHA1校验和，可选值`no`/`yes`，默认`no`               |
| `hidden`       | boolean,查找隐藏文件，默认不查找，可选值`no`/`yes`，默认`no` |
| `paths`        | list / elements=string / required，查找路径，必须要绝对路径  |
| `patterns`     | list / elements=string,正则模式                              |
| ``             | boolean,将文件全部读入内存，可选值`no`/`yes`，默认`no`，设置为`yes`时对性能和内存有影响 |
| `recurse`      | boolean,递归查找文件，可选值`no`/`yes`，默认`no`             |
| `size`         | string，文件大小，可单位 bytes but b, k, m, g, and t can be appended to specify bytes, kilobytes, megabytes, gigabytes, and terabytes |
| `use_regex`    | boolean,是否用python正则，默认不用，即使用shell通配符，可选值`no`/`yes`，默认`no` |



## 3. 官方示例

```yaml
- name: Recursively find /tmp files older than 2 days
  ansible.builtin.find:
    paths: /tmp
    age: 2d
    recurse: yes

- name: Recursively find /tmp files older than 4 weeks and equal or greater than 1 megabyte
  ansible.builtin.find:
    paths: /tmp
    age: 4w
    size: 1m
    recurse: yes

- name: Recursively find /var/tmp files with last access time greater than 3600 seconds
  ansible.builtin.find:
    paths: /var/tmp
    age: 3600
    age_stamp: atime
    recurse: yes

- name: Find /var/log files equal or greater than 10 megabytes ending with .old or .log.gz
  ansible.builtin.find:
    paths: /var/log
    patterns: '*.old,*.log.gz'
    size: 10m

# Note that YAML double quotes require escaping backslashes but yaml single quotes do not.
- name: Find /var/log files equal or greater than 10 megabytes ending with .old or .log.gz via regex
  ansible.builtin.find:
    paths: /var/log
    patterns: "^.*?\\.(?:old|log\\.gz)$"
    size: 10m
    use_regex: yes

- name: Find /var/log all directories, exclude nginx and mysql
  ansible.builtin.find:
    paths: /var/log
    recurse: no
    file_type: directory
    excludes: 'nginx,mysql'

# When using patterns that contain a comma, make sure they are formatted as lists to avoid splitting the pattern
- name: Use a single pattern that contains a comma formatted as a list
  ansible.builtin.find:
    paths: /var/log
    file_type: file
    use_regex: yes
    patterns: ['^_[0-9]{2,4}_.*.log$']

- name: Use multiple patterns that contain a comma formatted as a YAML list
  ansible.builtin.find:
    paths: /var/log
    file_type: file
    use_regex: yes
    patterns:
      - '^_[0-9]{2,4}_.*.log$'
      - '^[a-z]{1,5}_.*log$'
```



## 4. 使用剧本



### 4.1 查找并删除远程日志文件

我们先在节点上面找到修改时间超过365天的文件：

```sh
[root@node2 log]# pwd
/var/log
[root@node2 log]# find . -name 'messages-*.gz' -mtime +365
./messages-202109201632079021.gz
./messages-202109151631647922.gz
./messages-202109111631302381.gz
```

编写剧本文件`find.yml`:

```yaml
- hosts: node2
  tasks:
    - name: Recursively find /var/log files older than 365 days
      ansible.builtin.find:
        paths: /var/log
        patterns: 'messages-*.gz'
        age: 365d
        recurse: yes
      register: find_result

    - name: Print files
      ansible.builtin.debug:
        msg: "{{ item.path }}"
      with_items:
        - "{{ find_result.files }}"

    - name: Delete files
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: absent
      become: yes
      with_items:
        - "{{ find_result.files }}"

```

执行剧本：

```sh
[ansible@master ansible_playbooks]$ ansible-playbook find.yml

PLAY [node2] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node2]

TASK [Recursively find /var/log files older than 365 days] *************************************************************
ok: [node2]

TASK [Print files] *****************************************************************************************************
ok: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1632079021.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109201632079021.gz', u'xusr': False, u'atime': 1631647922.0, u'inode': 425325, u'isgid': False, u'size': 2742307, u'isdir': False, u'ctime': 1632079022.963596, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True}) => {
    "msg": "/var/log/messages-202109201632079021.gz"
}
ok: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1631647921.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109151631647922.gz', u'xusr': False, u'atime': 1631302381.0, u'inode': 425271, u'isgid': False, u'size': 3466008, u'isdir': False, u'ctime': 1631647923.0588913, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True}) => {
    "msg": "/var/log/messages-202109151631647922.gz"
}
ok: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1631302381.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109111631302381.gz', u'xusr': False, u'atime': 1630523581.0, u'inode': 425220, u'isgid': False, u'size': 3973088, u'isdir': False, u'ctime': 1631302382.6122549, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True}) => {
    "msg": "/var/log/messages-202109111631302381.gz"
}

TASK [Delete files] ****************************************************************************************************
changed: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1632079021.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109201632079021.gz', u'xusr': False, u'atime': 1631647922.0, u'inode': 425325, u'isgid': False, u'size': 2742307, u'isdir': False, u'ctime': 1632079022.963596, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True})
changed: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1631647921.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109151631647922.gz', u'xusr': False, u'atime': 1631302381.0, u'inode': 425271, u'isgid': False, u'size': 3466008, u'isdir': False, u'ctime': 1631647923.0588913, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True})
changed: [node2] => (item={u'islnk': False, u'uid': 0, u'rgrp': False, u'xoth': False, u'rusr': True, u'woth': False, u'nlink': 1, u'issock': False, u'mtime': 1631302381.0, u'gr_name': u'root', u'path': u'/var/log/messages-202109111631302381.gz', u'xusr': False, u'atime': 1630523581.0, u'inode': 425220, u'isgid': False, u'size': 3973088, u'isdir': False, u'ctime': 1631302382.6122549, u'roth': False, u'isblk': False, u'xgrp': False, u'isuid': False, u'dev': 64769, u'wgrp': False, u'isreg': True, u'isfifo': False, u'mode': u'0600', u'pw_name': u'root', u'gid': 0, u'ischr': False, u'wusr': True})

PLAY RECAP *************************************************************************************************************
node2                      : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

我们此时在节点上面检查一下：

```sh
[root@node2 log]# find . -name 'messages-*.gz' -mtime +365
[root@node2 log]#
```

可以看到，之前查找的三个文件已经查找不到了，说明文件删除成功了。

