# git远程仓库检出模块

## 1. 概述

- 本模块用于管理Git仓库检出，用于发布文件或者软件。
- 远程主机需要安装命令行工具git，且git版本>=1.7.1。
- 官方文档：[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html)
- 注意，如果使用ssh方式下载的话，则远程主机应将公钥配置到git服务器上。因此推荐使用`http`或`https`方式下载远程仓库。

## 2. 参数

参数较多，此处仅列出几个常用参数。


| 参数                    | 描述                                                           |
|-------------------------|----------------------------------------------------------------|
| `repo`  string/必需     | 远程仓库路径                                                   |
| `dest` path/必需        | 仓库检出存放路径                                               |
| `version` string        | 需要检出的版本，可以是`HEAD`，或者分支名称、标签名称、提交散列值等 |
| `single_branch` boolean | 仅克隆与指定分支相关的历史记录，默认`no`                        |
| `depth` integer         | 创建一个浅克隆，其历史记录被截断为指定的编号或修订版             |



## 3. 官方示例

```yaml
- name: Git checkout
  ansible.builtin.git:
    repo: 'https://foosball.example.org/path/to/repo.git'
    dest: /srv/checkout
    version: release-0.22

- name: Read-write git checkout from github
  ansible.builtin.git:
    repo: git@github.com:mylogin/hello.git
    dest: /home/mylogin/hello

- name: Just ensuring the repo checkout exists
  ansible.builtin.git:
    repo: 'https://foosball.example.org/path/to/repo.git'
    dest: /srv/checkout
    update: no

- name: Just get information about the repository whether or not it has already been cloned locally
  ansible.builtin.git:
    repo: 'https://foosball.example.org/path/to/repo.git'
    dest: /srv/checkout
    clone: no
    update: no

- name: Checkout a github repo and use refspec to fetch all pull requests
  ansible.builtin.git:
    repo: https://github.com/ansible/ansible-examples.git
    dest: /src/ansible-examples
    refspec: '+refs/pull/*:refs/heads/*'

- name: Create git archive from repo
  ansible.builtin.git:
    repo: https://github.com/ansible/ansible-examples.git
    dest: /src/ansible-examples
    archive: /tmp/ansible-examples.zip

- name: Clone a repo with separate git directory
  ansible.builtin.git:
    repo: https://github.com/ansible/ansible-examples.git
    dest: /src/ansible-examples
    separate_git_dir: /src/ansible-examples.git

- name: Example clone of a single branch
  ansible.builtin.git:
    repo: https://github.com/ansible/ansible-examples.git
    dest: /src/ansible-examples
    single_branch: yes
    version: master

- name: Avoid hanging when http(s) password is missing
  ansible.builtin.git:
    repo: https://github.com/ansible/could-be-a-private-repo
    dest: /src/from-private-repo
  environment:
    GIT_TERMINAL_PROMPT: 0 # reports "terminal prompts disabled" on missing password
    # or GIT_ASKPASS: /bin/true # for git before version 2.3.0, reports "Authentication failed" on missing password

```


## 4. 使用剧本

尝试下载gitee测试仓库中的代码，编写`git.yml`文件：

```yaml
- hosts: node2
  tasks:
    - name: Clone the git repo
      ansible.builtin.git:
        repo: https://gitee.com/meizhaohui/testgit.git
        # dest最后一级目录需要不存在
        dest: /tmp/testgit
        depth: 1
        # single_branch: yes
        version: master
```
不注释`single_branch`行时，运行时提示以下异常：

```sh
[ansible@master ansible_playbooks]$ ansible-playbook git.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node2] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node2]

TASK [Clone the git repo] **********************************************************************************************
fatal: [node2]: FAILED! => {"changed": false, "msg": "Unsupported parameters for (ansible.builtin.git) module: single_branch Supported parameters include: accept_hostkey, archive, bare, clone, depth, dest, executable, force, gpg_whitelist, key_file, recursive, reference, refspec, remote, repo, separate_git_dir, ssh_opts, track_submodules, umask, update, verify_commit, version"}

PLAY RECAP *************************************************************************************************************
node2                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

查看官方文档可知该参数是`added in 2.11 of ansible.builtin`，即ansible 2.11版本引入的。
而我们的Ansible版本是ansible 2.9.27:

```sh
[ansible@master ansible_playbooks]$ ansible --version
ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/ansible/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /bin/ansible
  python version = 2.7.5 (default, Nov 16 2020, 22:23:17) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```

因此，不能用该参数是正常的。


将该行注释后，再执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-playbook git.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node2] ***********************************************************************************************************
  1 - hosts: node2

TASK [Gathering Facts] *************************************************************************************************
ok: [node2]

TASK [Clone the git repo] **********************************************************************************************
changed: [node2] => {"after": "118bbd52d9e70b73f2db920dd17dcaac3e0c7c0f", "before": null, "changed": true}

PLAY RECAP *************************************************************************************************************
node2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

下载仓库成功。可以在节点上面检查一下：

```sh
[root@node2 ~]# cd /tmp/testgit/
[root@node2 testgit]# git remote -v
origin	https://gitee.com/meizhaohui/testgit.git (fetch)
origin	https://gitee.com/meizhaohui/testgit.git (push)
[root@node2 testgit]# git log
commit 118bbd52d9e70b73f2db920dd17dcaac3e0c7c0f (grafted, HEAD -> master, origin/master, origin/HEAD)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Aug 6 16:19:07 2022 +0800

    edited in vim
[root@node2 testgit]#
```

可以看到，只检出了最新的一次提交历史记录。


