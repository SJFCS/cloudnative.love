# yum包管理器模块

[[toc]]

## 1. 概要

- `yum`模块通过`yum`包管理器来管理包。
- 使用yum软件包管理器安装，升级，降级，删除和列出软件包和组。
- 该模块仅适用于Python2。如果需要Python 3支持，请参见`dnf`模块。
- 主机上面必须安装`yum`包管理器。
- 源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/yum.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/yum.py)
- 官方文档：[https://docs.ansible.com/ansible/latest/modules/yum_module.html](https://docs.ansible.com/ansible/latest/modules/yum_module.html)

## 2. 参数

| 参数                                                         | 可选值                                                       | 默认值           | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------- | ------------------------------------------------------------ |
| **allow_downgrade**                                                       boolean | yes/no                                                       | no               | 指定是否允许在已经安装有更高版本的情况下指定的软件包和版本降级处理。 **请注意，设置`allow_downgrade=True`可使此模块以非幂等方式运行。 该任务最终可能会导致一组软件包与要安装的指定软件包的完整列表不匹配（因为降级的软件包与其他软件包之间的依赖关系可能导致对先前事务中的软件包进行更改）。** 因此该操作很危险！！！ |
| **autoremove**                                                       boolean | yes/no                                                       | no               | 是否自动删除所有“叶”软件包，这些软件包最初是作为用户安装的软件包的依赖项安装的，但不再是任何此类软件包所必需的。注意，该参数应该单独使用，或者与`state=absent`一起作用。此功能要求`yum>=3.4.3(RHEL/CentOS 7+)` |
| **bugfix**                                                       - | yes/no                                                       | no               | 如果本参数设置为`yes`，并且`state=latest`，那么仅安装标准为`bugfix`相关的更新 |
| **conf_file**                                                       - |                                                              |                  | 用于事务的远程`yum`配置文件。                                |
| **disable_excludes**                                                       - |                                                              |                  | 禁用YUM配置文件中定义的排除项。 如果设置为`all`，则禁用所有排除。 如果设置为`main`，则禁用yum.conf中`[main]`中定义的排除项。 如果设置为` repoid`，则禁用为给定的 repo ID定义的排除项。 |
| **disable_gpg_check**                                                       boolean | yes/no                                                       | no               | 是否禁用正在安装的软件包签名的GPG检查。 仅当状态`state`为`present`或`latest`时才有效。 |
| **disable_plugin**                                                       - |                                                              |                  | 要为安装/更新操作禁用的插件名称。 **禁用的插件在事务处理之后将不存在。** |
| **disablerepo**                                                       - |                                                              |                  | 禁用指定存储库，**这些存储库的设置只对当前事务有影响，并不会像yum-config-manager一样禁用仓库**。如果有多个存储库，使用英文逗号分隔，从Ansible 2.7开始，可以使用列表代替。 |
| **download_dir**                                                       string |                                                              |                  | 指定用于存储软件包的备用目录。仅当指定了`download_only`时才有效。 |
| **download_only**                                                       boolean | yes/no                                                       | no               | 仅下载包，但不安装。                                         |
| **enable_plugin**                                                       - |                                                              |                  | 需要启用进行安装/更新操作的插件名称。 启用的插件在事务之后不存在。 |
| **enablerepo**                                                       - |                                                              |                  | 需要启用有存储库，**这些存储库的设置只对当前事务有影响，并不会像yum-config-manager一样启用仓库**。如果有多个存储库，使用英文逗号分隔，从Ansible 2.7开始，可以使用列表代替。 |
| **exclude**                                                       - |                                                              |                  | 需要排除的包名称，仅当状态`state`为`present`或`latest`时才有效。 |
| **install_weak_deps**                                                       boolean | yes/no                                                       | yes              | 安装通过弱依赖关系链接的所有软件包。 注意：此功能需要`yum >= 4（RHEL/CentOS 8+）` |
| **installroot**                                                       - |                                                              | **Default:** "/" | 指定一个备用`installroot`，相对于该根节点，将安装所有软件包。 |
| **list**                                                       - |                                                              |                  | 要运行等效于`yum list --show-duplicates <package>`的软件包名称。 除了列出软件包外，还可以列出以下内容： `installed`已安装、`updates`更新、`available`可用、以及 `repos`存储库。 此参数与`name`互斥。 |
| **lock_timeout**                                                       integer |                                                              | **Default:** 30  | 等待释放yum锁定文件的时间。                                  |
| **name**                                                       list                      / elements=string |                                                              |                  | 带有版本的软件包名称或软件包说明符，例如`name-1.0`。 如果指定了以前的版本，则该任务还需要打开`allow_downgrade`。 有关降级软件包的注意事项，请参见`allow_downgrade`文档。 当使用`state=latest`时，它可以是`*`，这意味着运行`yum -y update`。 您还可以将url或本地路径传递给rpm文件(使用`state=present`)。要对多个软件包进行操作，可以接受英文逗号分隔的软件包字符串或软件包列表(从Ansible 2.0版开始)。 别名：`pkg`。 |
| **releasever**                                                       - |                                                              |                  | 指定安装所有软件包的替代版本。                               |
| **security**                                                       boolean | yes/no                                                       | no               | 如果设置为`yes`并且`state=latest`，则仅安装标记为安全相关的更新。 |
| **skip_broken**                                                       boolean | yes/no                                                       | no               | 跳过依赖项已损坏的软件包，并抛出问题异常。                   |
| **state**                                                       - | **可选值:**                                                                                                                                                               absent                                                                                                                                                                                               installed                                                                                                                                                                                               latest                                                                                                                                                                                               present                                                                                                                                                                                               removed |                  | 是否要安装(`present` or `installed`, `latest`)或移除(`absent` or `removed`)包装。 `present`和`installed`将仅确保已安装所需的软件包。 如果不是最新的可用版本，`latest`将更新指定的软件包。 `absent`和`removed`将删除指定的软件包。 默认值为`None`，但实际上默认动作为`present`，除非为此模块启用了`autoremove`自动删除选项，此时`state=absent`不存在。 |
| **update_cache**                                                       boolean | yes/no                                                       | no               | 强制yum检查缓存是否过期，并在需要时重新下载。仅当状态`state`为`present`或`latest`时才有效。别名`expire-cache`。 |
| **update_only**                                                       boolean | yes/no                                                       | no               | 使用`latest`最新版本时，仅更新安装的软件包。 不要安装软件包。 仅在状态为`state=latest`最新时才有效。 |
| **use_backend**                                                       - | **可选值:**                                                                                                                                                               **auto** ←                                                                                                                                                                                               yum                                                                                                                                                                                               yum4                                                                                                                                                                                               dnf | `auto`自动       | 这个模块支持`yum`，上游yum开发人员将其称为`yum3`/`YUM3`/`yum-preprecated`。从Ansible2.7+开始，此模块还支持`YUM4`，这是新的`yum`，并且具有`dnf`后端。默认情况下，此模块将基于“ansible_pkg_mgr”事实选择后端。 |
| **validate_certs**                                                       boolean | yes/no                                                       | yes              | 仅当使用https网址作为rpm的源时才适用。 例如用于本地安装。 如果设置为`no`，则不会验证SSL证书。 当使用自签名证书的个人站点时，可以设置为`no`,这样可以避免验证源站点。 在Ansible 2.1之前的版本中，代码就像设置为`yes`一样工作。 |

## 3. 注意事项

- 当与`loop`循环一起使用时，每个包将被单独处理。将列表直接传递给`name`选项会更有效。
- 在1.9.2之前的版本中，此模块分别安装和卸载给yum模块的每个软件包。当必须一起安装或删除由文件名或URL指定的程序包时，这会引起问题。在1.9.2中，此问题已修复，因此可以在一个yum事务中安装软件包。但是，如果其中一个软件包添加了其他软件包所来自的新yum存储库(例如epel-release)，则该软件包需要安装在单独的任务中。这模仿了yum的命令行行为。
- yum模块不支持以幂等的方式清除yum缓存，因此`yum`模块不会自动清除yum缓存。唯一的方法是使用`command`命令模块直接调用yum命令，即`yum clean all`。
- 本模块中某些参数比较危险，不要随意测试！！！
- 本模块需要使用`root`操作，因此需要使用`become`权限提升。



## 4. 返回值

| 键                                                  | 何时返回 | 描述信息                                                     |
| --------------------------------------------------- | -------- | ------------------------------------------------------------ |
| **results**                                    list | 一直     | 相关包信息组成的列表,如`"results": ["httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed"]` |
| **changes**                                 dict    | 有变更时 | 安装或卸载的包的信息，如`"changes": {"removed": ["MariaDB-client", "MariaDB-server"]}` |



## 5. 官方示例

```yaml
- name: install the latest version of Apache
  yum:
    name: httpd
    state: latest

- name: ensure a list of packages installed
  yum:
    name: "{{ packages }}"
  vars:
    packages:
    - httpd
    - httpd-tools

- name: remove the Apache package
  yum:
    name: httpd
    state: absent

- name: install the latest version of Apache from the testing repo
  yum:
    name: httpd
    enablerepo: testing
    state: present

- name: install one specific version of Apache
  yum:
    name: httpd-2.2.29-1.4.amzn1
    state: present

- name: upgrade all packages
  yum:
    name: '*'
    state: latest

- name: upgrade all packages, excluding kernel & foo related packages
  yum:
    name: '*'
    state: latest
    exclude: kernel*,foo*

- name: install the nginx rpm from a remote repo
  yum:
    name: http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present

- name: install nginx rpm from a local file
  yum:
    name: /usr/local/src/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present

- name: install the 'Development tools' package group
  yum:
    name: "@Development tools"
    state: present

- name: install the 'Gnome desktop' environment group
  yum:
    name: "@^gnome-desktop-environment"
    state: present

- name: List ansible packages and register result to print with debug later.
  yum:
    list: ansible
  register: result

- name: Install package with multiple repos enabled
  yum:
    name: sos
    enablerepo: "epel,ol7_latest"

- name: Install package with multiple repos disabled
  yum:
    name: sos
    disablerepo: "epel,ol7_latest"

- name: Install a list of packages
  yum:
    name:
      - nginx
      - postgresql
      - postgresql-server
    state: present

- name: Download the nginx package but do not install it
  yum:
    name:
      - nginx
    state: latest
    download_only: true
```



## 6. 基础知识

我们可以使用`yum`命令来搜索或安装、卸载包，下面列出一些相关的命令：

- `yum search <packagename>`  搜索某个包
- `yum search <packagename>  --showduplicates`  搜索某个包时显示多个版本
- `yum info <packagename>`  查看某个包的介绍信息
- `rpm -qa|grep <packagename>` 搜索是否安装了某个包
- `yum install <packagename> -y` 安装某个包

我们来试一下这些命令：

```sh
# 查看本机是否安装了httpd相关的包
[ansible@node1 ~]$ rpm -qa|grep httpd
httpd-2.4.6-93.el7.centos.x86_64
httpd-tools-2.4.6-93.el7.centos.x86_64

# 查看本机是否安装了mariadb相关的包
# 说明: mariadb是mysql的一个分支，可以实现mysql一样的功能
[ansible@node1 ~]$ rpm -qa|grep -i mariadb
MariaDB-client-10.5.4-1.el7.centos.x86_64
MariaDB-compat-10.5.4-1.el7.centos.x86_64
MariaDB-common-10.5.4-1.el7.centos.x86_64
MariaDB-server-10.5.4-1.el7.centos.x86_64

# 查看是否安装了nginx相关的包
[ansible@node1 ~]$ rpm -qa|grep nginx

# 你可以使用下面的命令搜索httpd相关的包，显示的内容比较多，此处忽略
[ansible@node1 ~]$ yum search httpd 
[ansible@node1 ~]$ yum search httpd --showduplicates

# 查看httpd包的介绍
[ansible@node1 ~]$ yum info httpd 
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
ius                                                                                      365/365
Installed Packages
Name        : httpd
Arch        : x86_64
Version     : 2.4.6
Release     : 93.el7.centos
Size        : 9.4 M
Repo        : installed
From repo   : base
Summary     : Apache HTTP Server
URL         : http://httpd.apache.org/
License     : ASL 2.0
Description : The Apache HTTP Server is a powerful, efficient, and extensible
            : web server.

[ansible@node1 ~]$ 
```



## 7. 使用临时命令

我们先来使用临时命令尝试运行一下`yum`模块的命令。

### 7.1 查看是否安装某软件

```sh
# 查看是否安装httpd包
[ansible@master ~]$ ansible node1 -m yum -a 'name=httpd'
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed"
    ]
}
[ansible@master ~]$

# 查看是否安装mysql包
[ansible@master ~]$ ansible node1 -m yum -a 'name=mysql'
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "MariaDB-client-10.5.4-1.el7.centos.x86_64 providing mysql is already installed"
    ]
}

# 查看是否安装mariadb包
[ansible@master ~]$ ansible node1 -m yum -a 'name=mariadb'
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "MariaDB-client-10.5.4-1.el7.centos.x86_64 providing mariadb is already installed"
    ]
}
[ansible@master ~]$ 
```

### 7.2 查看多个软件包、软件包名大小写敏感

通过下面的示例可以看到软件包名大小写敏感，多个软件包之间使用英文逗号分隔开。

```sh
[ansible@master ~]$ ansible node1 -m yum -a 'name=mariadb-server,MariaDB-client'
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "MariaDB-server-10.5.4-1.el7.centos.x86_64 providing mariadb-server is already installed", 
        "MariaDB-client-10.5.4-1.el7.centos.x86_64 providing MariaDB-client is already installed"
    ]
}
[ansible@master ~]$ ansible node1 -m yum -a 'name=mariadb-Server,MariaDB-Client'
node1 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "No package matching 'mariadb-Server' found available, installed or updated", 
    "rc": 126, 
    "results": [
        "No package matching 'mariadb-Server' found available, installed or updated"
    ]
}
[ansible@master ~]$ 
[ansible@master ~]$ ansible node1 -m yum -a 'name=mariadb-server,MariaDB-Client'
node1 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "No package matching 'MariaDB-Client' found available, installed or updated", 
    "rc": 126, 
    "results": [
        "MariaDB-server-10.5.4-1.el7.centos.x86_64 providing mariadb-server is already installed", 
        "No package matching 'MariaDB-Client' found available, installed or updated"
    ]
}
[ansible@master ~]$ ansible node1 -m yum -a 'name=MariaDB-server,MariaDB-client'
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "MariaDB-server-10.5.4-1.el7.centos.x86_64 providing MariaDB-server is already installed", 
        "MariaDB-client-10.5.4-1.el7.centos.x86_64 providing MariaDB-client is already installed"
    ]
}
[ansible@master ~]$ 
```



## 8. 使用剧本

下面我们主要使用httpd、nginx、mysql包来进行相关的测试。

首先，我们使用剧本来卸载httpd、nginx、mysql包。



### 8.1 卸载包

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 卸载包
    - name: uninstall the Apache
      yum:
        name: httpd
        state: absent
      become: yes

    # 卸载多个包
    - name: uninstall the MariaDB
      yum:
        name:
          - MariaDB-client
          - MariaDB-server
        state: absent
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [uninstall the Apache] *********************************************************************
changed: [node1] => {"changed": true, "changes": {"removed": ["httpd"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package httpd.x86_64 0:2.4.6-93.el7.centos will be erased\n--> Processing Dependency: httpd-mmn = 20120211x8664 for package: python36-mod_wsgi-4.6.2-2.el7.ius.x86_64\n--> Running transaction check\n---> Package python36-mod_wsgi.x86_64 0:4.6.2-2.el7.ius will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                Arch        Version                    Repository  Size\n================================================================================\nRemoving:\n httpd                  x86_64      2.4.6-93.el7.centos        @base      9.4 M\nRemoving for dependencies:\n python36-mod_wsgi      x86_64      4.6.2-2.el7.ius            @ius       1.1 M\n\nTransaction Summary\n================================================================================\nRemove  1 Package (+1 Dependent package)\n\nInstalled size: 10 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing    : python36-mod_wsgi-4.6.2-2.el7.ius.x86_64                     1/2 \n  Erasing    : httpd-2.4.6-93.el7.centos.x86_64                             2/2 \nwarning: file /etc/httpd/conf/httpd.conf: remove failed: No such file or directory\n  Verifying  : python36-mod_wsgi-4.6.2-2.el7.ius.x86_64                     1/2 \n  Verifying  : httpd-2.4.6-93.el7.centos.x86_64                             2/2 \n\nRemoved:\n  httpd.x86_64 0:2.4.6-93.el7.centos                                            \n\nDependency Removed:\n  python36-mod_wsgi.x86_64 0:4.6.2-2.el7.ius                                    \n\nComplete!\n"]}

TASK [uninstall the MariaDB] ********************************************************************
changed: [node1] => {"changed": true, "changes": {"removed": ["MariaDB-client", "MariaDB-server"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package MariaDB-client.x86_64 0:10.5.4-1.el7.centos will be erased\n---> Package MariaDB-server.x86_64 0:10.5.4-1.el7.centos will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch        Version                    Repository     Size\n================================================================================\nRemoving:\n MariaDB-client      x86_64      10.5.4-1.el7.centos        @mariadb       65 M\n MariaDB-server      x86_64      10.5.4-1.el7.centos        @mariadb      129 M\n\nTransaction Summary\n================================================================================\nRemove  2 Packages\n\nInstalled size: 194 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing    : MariaDB-server-10.5.4-1.el7.centos.x86_64                    1/2 \n  Erasing    : MariaDB-client-10.5.4-1.el7.centos.x86_64                    2/2 \n  Verifying  : MariaDB-client-10.5.4-1.el7.centos.x86_64                    1/2 \n  Verifying  : MariaDB-server-10.5.4-1.el7.centos.x86_64                    2/2 \n\nRemoved:\n  MariaDB-client.x86_64 0:10.5.4-1.el7.centos                                   \n  MariaDB-server.x86_64 0:10.5.4-1.el7.centos                                   \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们再查检查一下,这些包是否已经卸载了:

```sh
[ansible@node1 ~]$ rpm -qa|grep httpd
httpd-tools-2.4.6-93.el7.centos.x86_64
[ansible@node1 ~]$ rpm -qa|grep -i mariadb
MariaDB-compat-10.5.4-1.el7.centos.x86_64
MariaDB-common-10.5.4-1.el7.centos.x86_64
[ansible@node1 ~]$ 
```

可以看到,我们指定的包已经卸载了,Ansible并没有直接卸载相关的包。



### 8.2 安装包

::: tip 提示
脚本执行慢，半天没有响应，可能是软件包比较大，yum源比较慢，可以使用国内镜像源加速！！！
:::

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 确定包是否安装，如果没有安装则安装
    - name: ensure a list of packages installed
      yum:
        name: "{{ packages }}"
      vars:
        packages:
        - httpd
        - httpd-tools
      become: yes

    # 确定包是否安装，如果没有安装则安装
    - name: install the MariaDB-server and MariaDB-client
      yum:
        name:
          - MariaDB-client
          - MariaDB-server
        state: installed
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [ensure a list of packages installed] ******************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["httpd"]}, "msg": "", "rc": 0, "results": ["httpd-tools-2.4.6-93.el7.centos.x86_64 providing httpd-tools is already installed", "Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package httpd.x86_64 0:2.4.6-93.el7.centos will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package       Arch           Version                        Repository    Size\n================================================================================\nInstalling:\n httpd         x86_64         2.4.6-93.el7.centos            base         2.7 M\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal download size: 2.7 M\nInstalled size: 9.4 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : httpd-2.4.6-93.el7.centos.x86_64                             1/1 \n  Verifying  : httpd-2.4.6-93.el7.centos.x86_64                             1/1 \n\nInstalled:\n  httpd.x86_64 0:2.4.6-93.el7.centos                                            \n\nComplete!\n"]}

TASK [install the MariaDB-server and MariaDB-client] ********************************************
^C [ERROR]: User interrupted execution
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [ensure a list of packages installed] ******************************************************
ok: [node1] => {"changed": false, "msg": "", "rc": 0, "results": ["httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed", "httpd-tools-2.4.6-93.el7.centos.x86_64 providing httpd-tools is already installed"]}

TASK [install the MariaDB-server and MariaDB-client] *****

----> 此处一直卡住不动，使用Ctrl+C取消任务了
```

将`state: installed`改成再试一下`state: present`。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 确定包是否安装，如果没有安装则安装
    - name: ensure a list of packages installed
      yum:
        name: "{{ packages }}"
      vars:
        packages:
        - httpd
        - httpd-tools
      become: yes

    # 确定包是否安装，如果没有安装则安装
    - name: install the MariaDB-server and MariaDB-client
      yum:
        name:
          - MariaDB-client
          - MariaDB-server
        state: present
      become: yes
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [ensure a list of packages installed] ******************************************************
ok: [node1] => {"changed": false, "msg": "", "rc": 0, "results": ["httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed", "httpd-tools-2.4.6-93.el7.centos.x86_64 providing httpd-tools is already installed"]}

TASK [install the MariaDB-server and MariaDB-client] ********************************************
----> 此处一直卡住不动
^C [ERROR]: User interrupted execution
```

检查node1节点：

```sh
[ansible@node1 ~]$ ps -ef|grep yum
ansible   8810  8560  0 17:26 pts/1    00:00:00 /bin/sh -c sudo -H -S -n  -u root /bin/sh -c 'echo BECOME-SUCCESS-odsohwwtdtrntiohbyoosvefmaivzcee ; /usr/bin/python /home/ansible/.ansible/tmp/ansible-tmp-1597051573.01-5886-174205555753699/AnsiballZ_yum.py' && sleep 0
root      8826  8810  0 17:26 pts/1    00:00:00 sudo -H -S -n -u root /bin/sh -c echo BECOME-SUCCESS-odsohwwtdtrntiohbyoosvefmaivzcee ; /usr/bin/python /home/ansible/.ansible/tmp/ansible-tmp-1597051573.01-5886-174205555753699/AnsiballZ_yum.py
root      8827  8826  0 17:26 pts/1    00:00:00 /bin/sh -c echo BECOME-SUCCESS-odsohwwtdtrntiohbyoosvefmaivzcee ; /usr/bin/python /home/ansible/.ansible/tmp/ansible-tmp-1597051573.01-5886-174205555753699/AnsiballZ_yum.py
root      8828  8827  0 17:26 pts/1    00:00:00 /usr/bin/python /home/ansible/.ansible/tmp/ansible-tmp-1597051573.01-5886-174205555753699/AnsiballZ_yum.py
root      8829  8828  0 17:26 pts/1    00:00:00 /usr/bin/python /bin/yum -d 2 -y install MariaDB-client MariaDB-server
ansible   8941  3603  0 17:28 pts/0    00:00:00 grep --color=auto yum
[ansible@node1 ~]$ 
```

后台运行的程序一直没有终止，我们按Ctrl+C强制终止Ansible运行。

手动执行安装操作看一下：

```sh
[ansible@node1 ~]$ sudo yum install MariaDB-client MariaDB-server -y
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.bit.edu.cn
 * extras: mirror.bit.edu.cn
 * updates: mirror.bit.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package MariaDB-client.x86_64 0:10.5.4-1.el7.centos will be installed
---> Package MariaDB-server.x86_64 0:10.5.4-1.el7.centos will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================
 Package                  Arch             Version                       Repository         Size
=================================================================================================
Installing:
 MariaDB-client           x86_64           10.5.4-1.el7.centos           mariadb            13 M
 MariaDB-server           x86_64           10.5.4-1.el7.centos           mariadb            26 M

Transaction Summary
=================================================================================================
Install  2 Packages

Total download size: 39 M
Installed size: 39 M
Downloading packages:
No Presto metadata available for mariadb
(2/2): MariaDB-server-10.5.4-1.el 53% [============-           ]  16 kB/s |  21 MB  00:19:22 ETA 
```

可以看到，中间需要下载包，需要的时间比较长，`00:19:22 ETA `提示还要19分钟，可能是因为这个原因导致我们认为Ansible卡住了。

我们重新运行剧本，但是把调试级别设置为`-vv`：

```sh
[ansible@master ~]$ ansible-playbook yum.yml -vv
ansible-playbook 2.9.9
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/ansible/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.5 (default, Apr  2 2020, 13:16:51) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
Using /etc/ansible/ansible.cfg as config file

PLAYBOOK: yum.yml *******************************************************************************
1 plays in yum.yml

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
task path: /home/ansible/yum.yml:1
ok: [node1]
META: ran handlers

TASK [ensure a list of packages installed] ******************************************************
task path: /home/ansible/yum.yml:4
ok: [node1] => {"changed": false, "msg": "", "rc": 0, "results": ["httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed", "httpd-tools-2.4.6-93.el7.centos.x86_64 providing httpd-tools is already installed"]}

TASK [install the MariaDB-client] ***************************************************************
task path: /home/ansible/yum.yml:14
```

运行的过程中，我们查看一下node1节点上面的缓存文件：

```sh
[ansible@node1 packages]$ pwd
/var/cache/yum/x86_64/7/mariadb/packages
[ansible@node1 packages]$ ll
total 0
-rw-r--r-- 1 root root 0 Aug 11 09:42 MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm
-rw-r--r-- 1 root root 0 Aug 11 09:42 MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm
[ansible@node1 packages]$ ll
total 16
-rw-r--r-- 1 root root 16384 Aug 11 09:42 MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm
-rw-r--r-- 1 root root     0 Aug 11 09:42 MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm
[ansible@node1 packages]$ du -sh
52K	.
[ansible@node1 packages]$ du -sh
60K	.
[ansible@node1 packages]$ du -sh
196K	.
[ansible@node1 packages]$ du -sh
196K	.
[ansible@node1 packages]$ du -sh
196K	.
[ansible@node1 packages]$ du -sh
196K	.
[ansible@node1 packages]$ du -sh
216K	.
[ansible@node1 packages]$ du -sh
220K	.
[ansible@node1 packages]$ du -sh
228K	.
```

可以看到，后台yum还在缓慢的下载文件！由于网速原因，下载比较慢。

经过漫长的等待，最终还是失败了！

```sh
TASK [install the MariaDB-client] ***************************************************************
task path: /home/ansible/yum.yml:14

fatal: [node1]: FAILED! => {"changed": false, "changes": {"installed": ["MariaDB-client", "MariaDB-server"]}, "msg": "http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttp://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on http://yum.mariadb.org/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\n\n\nError downloading packages:\n  MariaDB-server-10.5.5-1.el7.centos.x86_64: [Errno 256] No more mirrors to try.\n\n", "rc": 1, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package MariaDB-client.x86_64 0:10.5.5-1.el7.centos will be installed\n---> Package MariaDB-server.x86_64 0:10.5.5-1.el7.centos will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch        Version                     Repository    Size\n================================================================================\nInstalling:\n MariaDB-client      x86_64      10.5.5-1.el7.centos         mariadb       13 M\n MariaDB-server      x86_64      10.5.5-1.el7.centos         mariadb       26 M\n\nTransaction Summary\n================================================================================\nInstall  2 Packages\n\nTotal download size: 39 M\nInstalled size: 195 M\nDownloading packages:\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们更新一下node1节点上面的MariaDB的源为清华源，参考 [https://mirrors.tuna.tsinghua.edu.cn/help/mariadb/](https://mirrors.tuna.tsinghua.edu.cn/help/mariadb/)

修改后，MariaDB的源配置如下：

```sh
[ansible@node1 ~]$ cat /etc/yum.repos.d/MariaDB.repo 
# MariaDB 10.5 CentOS repository list - created 2020-07-07 08:02 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum//RPM-GPG-KEY-MariaDB
gpgcheck=1
[ansible@node1 ~]$ 
```

再次执行剧本，成功执行：

```sh
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [ensure a list of packages installed] ******************************************************
ok: [node1] => {"changed": false, "msg": "", "rc": 0, "results": ["httpd-2.4.6-93.el7.centos.x86_64 providing httpd is already installed", "httpd-tools-2.4.6-93.el7.centos.x86_64 providing httpd-tools is already installed"]}

TASK [install the MariaDB-client] ***************************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["MariaDB-client", "MariaDB-server"]}, "msg": "https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttps://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-client-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttps://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\nhttps://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: [Errno 12] Timeout on https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.5/centos7-amd64/rpms/MariaDB-server-10.5.5-1.el7.centos.x86_64.rpm: (28, 'Operation too slow. Less than 1000 bytes/sec transferred the last 30 seconds')\nTrying other mirror.\n", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package MariaDB-client.x86_64 0:10.5.5-1.el7.centos will be installed\n---> Package MariaDB-server.x86_64 0:10.5.5-1.el7.centos will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch        Version                     Repository    Size\n================================================================================\nInstalling:\n MariaDB-client      x86_64      10.5.5-1.el7.centos         mariadb       13 M\n MariaDB-server      x86_64      10.5.5-1.el7.centos         mariadb       26 M\n\nTransaction Summary\n================================================================================\nInstall  2 Packages\n\nTotal download size: 39 M\nInstalled size: 195 M\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                              154 kB/s |  39 MB  04:19     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : MariaDB-client-10.5.5-1.el7.centos.x86_64                    1/2 \n  Installing : MariaDB-server-10.5.5-1.el7.centos.x86_64                    2/2 \n  Verifying  : MariaDB-server-10.5.5-1.el7.centos.x86_64                    1/2 \n  Verifying  : MariaDB-client-10.5.5-1.el7.centos.x86_64                    2/2 \n\nInstalled:\n  MariaDB-client.x86_64 0:10.5.5-1.el7.centos                                   \n  MariaDB-server.x86_64 0:10.5.5-1.el7.centos                                   \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

然后我们在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ rpm -qa|grep MariaDB
MariaDB-compat-10.5.4-1.el7.centos.x86_64
MariaDB-server-10.5.5-1.el7.centos.x86_64
MariaDB-common-10.5.4-1.el7.centos.x86_64
MariaDB-client-10.5.5-1.el7.centos.x86_64
[ansible@node1 ~]$ 
```

可以看到MariaDB-server和MariaDB-client安装成功了。



### 8.3 列出所有相关包

我们可以使用`list`参数来列出你想了解的某个包相关的可安裝的软件清单。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 列出所有httpd相关的包
    - name: List httpd* packages and register result to print with debug later.
      yum:
        list: httpd*
      register: result

    # 输出相关信息
    - name: print the result
      debug:
        var: result
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [List httpd* packages and register result to print with debug later.] **********************
ok: [node1] => {"changed": false, "results": [{"arch": "x86_64", "envra": "0:httpd-devel-2.4.6-93.el7.centos.x86_64", "epoch": "0", "name": "httpd-devel", "release": "93.el7.centos", "repo": "base", "version": "2.4.6", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd-itk-2.4.7.04-2.el7.x86_64", "epoch": "0", "name": "httpd-itk", "release": "2.el7", "repo": "epel", "version": "2.4.7.04", "yumstate": "available"}, {"arch": "noarch", "envra": "0:httpd-manual-2.4.6-93.el7.centos.noarch", "epoch": "0", "name": "httpd-manual", "release": "93.el7.centos", "repo": "base", "version": "2.4.6", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd-tools-2.4.6-93.el7.centos.x86_64", "epoch": "0", "name": "httpd-tools", "release": "93.el7.centos", "repo": "base", "version": "2.4.6", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-devel-2.4.41-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-devel", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "noarch", "envra": "0:httpd24u-filesystem-2.4.41-1.el7.ius.noarch", "epoch": "0", "name": "httpd24u-filesystem", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "noarch", "envra": "0:httpd24u-manual-2.4.41-1.el7.ius.noarch", "epoch": "0", "name": "httpd24u-manual", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_ldap-2.4.41-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-mod_ldap", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "1:httpd24u-mod_proxy_html-2.4.41-1.el7.ius.x86_64", "epoch": "1", "name": "httpd24u-mod_proxy_html", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_security2-mlogc-2.9.2-1.ius.el7.x86_64", "epoch": "0", "name": "httpd24u-mod_security2-mlogc", "release": "1.ius.el7", "repo": "ius", "version": "2.9.2", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_security2-mlogc-2.9.3-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-mod_security2-mlogc", "release": "1.el7.ius", "repo": "ius", "version": "2.9.3", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_security2-2.9.2-1.ius.el7.x86_64", "epoch": "0", "name": "httpd24u-mod_security2", "release": "1.ius.el7", "repo": "ius", "version": "2.9.2", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_security2-2.9.3-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-mod_security2", "release": "1.el7.ius", "repo": "ius", "version": "2.9.3", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_session-2.4.41-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-mod_session", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "1:httpd24u-mod_ssl-2.4.41-1.el7.ius.x86_64", "epoch": "1", "name": "httpd24u-mod_ssl", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-mod_xsendfile-0.12-1.ius.el7.x86_64", "epoch": "0", "name": "httpd24u-mod_xsendfile", "release": "1.ius.el7", "repo": "ius", "version": "0.12", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-tools-2.4.41-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u-tools", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd24u-2.4.41-1.el7.ius.x86_64", "epoch": "0", "name": "httpd24u", "release": "1.el7.ius", "repo": "ius", "version": "2.4.41", "yumstate": "available"}, {"arch": "x86_64", "envra": "0:httpd-2.4.6-93.el7.centos.x86_64", "epoch": "0", "name": "httpd", "release": "93.el7.centos", "repo": "base", "version": "2.4.6", "yumstate": "available"}]}

TASK [print the result] *************************************************************************
ok: [node1] => {
    "result": {
        "changed": false, 
        "failed": false, 
        "results": [
            {
                "arch": "x86_64", 
                "envra": "0:httpd-devel-2.4.6-93.el7.centos.x86_64", 
                "epoch": "0", 
                "name": "httpd-devel", 
                "release": "93.el7.centos", 
                "repo": "base", 
                "version": "2.4.6", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd-itk-2.4.7.04-2.el7.x86_64", 
                "epoch": "0", 
                "name": "httpd-itk", 
                "release": "2.el7", 
                "repo": "epel", 
                "version": "2.4.7.04", 
                "yumstate": "available"
            }, 
            {
                "arch": "noarch", 
                "envra": "0:httpd-manual-2.4.6-93.el7.centos.noarch", 
                "epoch": "0", 
                "name": "httpd-manual", 
                "release": "93.el7.centos", 
                "repo": "base", 
                "version": "2.4.6", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd-tools-2.4.6-93.el7.centos.x86_64", 
                "epoch": "0", 
                "name": "httpd-tools", 
                "release": "93.el7.centos", 
                "repo": "base", 
                "version": "2.4.6", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-devel-2.4.41-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-devel", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "noarch", 
                "envra": "0:httpd24u-filesystem-2.4.41-1.el7.ius.noarch", 
                "epoch": "0", 
                "name": "httpd24u-filesystem", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "noarch", 
                "envra": "0:httpd24u-manual-2.4.41-1.el7.ius.noarch", 
                "epoch": "0", 
                "name": "httpd24u-manual", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_ldap-2.4.41-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_ldap", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "1:httpd24u-mod_proxy_html-2.4.41-1.el7.ius.x86_64", 
                "epoch": "1", 
                "name": "httpd24u-mod_proxy_html", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_security2-mlogc-2.9.2-1.ius.el7.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_security2-mlogc", 
                "release": "1.ius.el7", 
                "repo": "ius", 
                "version": "2.9.2", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_security2-mlogc-2.9.3-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_security2-mlogc", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.9.3", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_security2-2.9.2-1.ius.el7.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_security2", 
                "release": "1.ius.el7", 
                "repo": "ius", 
                "version": "2.9.2", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_security2-2.9.3-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_security2", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.9.3", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_session-2.4.41-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_session", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "1:httpd24u-mod_ssl-2.4.41-1.el7.ius.x86_64", 
                "epoch": "1", 
                "name": "httpd24u-mod_ssl", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-mod_xsendfile-0.12-1.ius.el7.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-mod_xsendfile", 
                "release": "1.ius.el7", 
                "repo": "ius", 
                "version": "0.12", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-tools-2.4.41-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u-tools", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd24u-2.4.41-1.el7.ius.x86_64", 
                "epoch": "0", 
                "name": "httpd24u", 
                "release": "1.el7.ius", 
                "repo": "ius", 
                "version": "2.4.41", 
                "yumstate": "available"
            }, 
            {
                "arch": "x86_64", 
                "envra": "0:httpd-2.4.6-93.el7.centos.x86_64", 
                "epoch": "0", 
                "name": "httpd", 
                "release": "93.el7.centos", 
                "repo": "base", 
                "version": "2.4.6", 
                "yumstate": "available"
            }
        ]
    }
}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到列出了很多`httpd`相关的包了！



### 8.4 下载包但不进行安装

我们可以使用临时命令(如`ansible node1 -b -m yum -a 'name=nginx download_only=yes download_dir=softs/nginx/'`)也可以使用剧本进行包的下载。

使用`download_dir`指定下载目录时，这个目录可以不用存在，Ansible会自动创建这个目录。

我们现在来使用剧本下载安装包。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 下载包不指定下载目录
    - name: Download the nginx package but do not install it
      yum:
        name:
          - nginx
        state: latest
        download_only: yes
      become: yes

    # 下载包指定下载目录，指定目录可以不用存在
    - name: Download the nginx package but do not install it specified download_dir
      yum:
        name:
          - nginx
        state: latest
        download_only: yes
        download_dir: softs/not_exist_dir/
      become: yes
[ansible@master ~]$ 
# 剧本规范检查时，提示403异常，不建议安装最新的包
[ansible@master ~]$ ansible-lint yum.yml 
[403] Package installs should not use latest
yum.yml:4
Task/Handler: Download the nginx package but do not install it

[403] Package installs should not use latest
yum.yml:13
Task/Handler: Download the nginx package but do not install it specified download_dir

[ansible@master ~]$ 
```

我们可以使用以下方法将403异常忽略掉。

```sh
[ansible@master ~]$ cat > .ansible-lint << EOF
> skip_list:
>   - '403'
> EOF
[ansible@master ~]$ cat .ansible-lint 
skip_list:
  - '403'
[ansible@master ~]$ 
```

然后再进行检查：

```sh
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Download the nginx package but do not install it] *****************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["nginx"], "updated": []}, "msg": "", "obsoletes": {"iwl7265-firmware": {"dist": "noarch", "repo": "@anaconda", "version": "22.0.7.0-69.el7"}}, "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package nginx.x86_64 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: nginx-all-modules = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: nginx-filesystem = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: nginx-filesystem for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: redhat-indexhtml for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: libprofiler.so.0()(64bit) for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Running transaction check\n---> Package centos-indexhtml.noarch 0:7-9.el7.centos will be installed\n---> Package gperftools-libs.x86_64 0:2.6.1-1.el7 will be installed\n---> Package nginx-all-modules.noarch 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: nginx-mod-http-image-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-http-perl = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-http-xslt-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-mail = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-stream = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n---> Package nginx-filesystem.noarch 1:1.16.1-1.el7 will be installed\n--> Running transaction check\n---> Package nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: gd for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\n--> Processing Dependency: libgd.so.2()(64bit) for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\n---> Package nginx-mod-http-perl.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-mail.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-stream.x86_64 1:1.16.1-1.el7 will be installed\n--> Running transaction check\n---> Package gd.x86_64 0:2.0.35-26.el7 will be installed\n--> Processing Dependency: libXpm.so.4()(64bit) for package: gd-2.0.35-26.el7.x86_64\n--> Running transaction check\n---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                         Arch       Version              Repository\n                                                                           Size\n================================================================================\nInstalling:\n nginx                           x86_64     1:1.16.1-1.el7       epel     562 k\nInstalling for dependencies:\n centos-indexhtml                noarch     7-9.el7.centos       base      92 k\n gd                              x86_64     2.0.35-26.el7        base     146 k\n gperftools-libs                 x86_64     2.6.1-1.el7          base     272 k\n libXpm                          x86_64     3.5.12-1.el7         base      55 k\n nginx-all-modules               noarch     1:1.16.1-1.el7       epel      19 k\n nginx-filesystem                noarch     1:1.16.1-1.el7       epel      21 k\n nginx-mod-http-image-filter     x86_64     1:1.16.1-1.el7       epel      30 k\n nginx-mod-http-perl             x86_64     1:1.16.1-1.el7       epel      39 k\n nginx-mod-http-xslt-filter      x86_64     1:1.16.1-1.el7       epel      29 k\n nginx-mod-mail                  x86_64     1:1.16.1-1.el7       epel      57 k\n nginx-mod-stream                x86_64     1:1.16.1-1.el7       epel      84 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+11 Dependent packages)\n\nTotal download size: 1.4 M\nInstalled size: 4.1 M\nBackground downloading packages, then exiting:\n--------------------------------------------------------------------------------\nTotal                                              117 kB/s | 1.4 MB  00:12     \nexiting because \"Download Only\" specified\n"]}

TASK [Download the nginx package but do not install it specified download_dir] *********************************
changed: [node1] => {"changed": true, "changes": {"installed": ["nginx"], "updated": []}, "msg": "", "obsoletes": {"iwl7265-firmware": {"dist": "noarch", "repo": "@anaconda", "version": "22.0.7.0-69.el7"}}, "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package nginx.x86_64 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: nginx-all-modules = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: nginx-filesystem = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: nginx-filesystem for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: redhat-indexhtml for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Processing Dependency: libprofiler.so.0()(64bit) for package: 1:nginx-1.16.1-1.el7.x86_64\n--> Running transaction check\n---> Package centos-indexhtml.noarch 0:7-9.el7.centos will be installed\n---> Package gperftools-libs.x86_64 0:2.6.1-1.el7 will be installed\n---> Package nginx-all-modules.noarch 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: nginx-mod-http-image-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-http-perl = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-http-xslt-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-mail = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n--> Processing Dependency: nginx-mod-stream = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch\n---> Package nginx-filesystem.noarch 1:1.16.1-1.el7 will be installed\n--> Running transaction check\n---> Package nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7 will be installed\n--> Processing Dependency: gd for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\n--> Processing Dependency: libgd.so.2()(64bit) for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\n---> Package nginx-mod-http-perl.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-mail.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-stream.x86_64 1:1.16.1-1.el7 will be installed\n--> Running transaction check\n---> Package gd.x86_64 0:2.0.35-26.el7 will be installed\n--> Processing Dependency: libXpm.so.4()(64bit) for package: gd-2.0.35-26.el7.x86_64\n--> Running transaction check\n---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                         Arch       Version              Repository\n                                                                           Size\n================================================================================\nInstalling:\n nginx                           x86_64     1:1.16.1-1.el7       epel     562 k\nInstalling for dependencies:\n centos-indexhtml                noarch     7-9.el7.centos       base      92 k\n gd                              x86_64     2.0.35-26.el7        base     146 k\n gperftools-libs                 x86_64     2.6.1-1.el7          base     272 k\n libXpm                          x86_64     3.5.12-1.el7         base      55 k\n nginx-all-modules               noarch     1:1.16.1-1.el7       epel      19 k\n nginx-filesystem                noarch     1:1.16.1-1.el7       epel      21 k\n nginx-mod-http-image-filter     x86_64     1:1.16.1-1.el7       epel      30 k\n nginx-mod-http-perl             x86_64     1:1.16.1-1.el7       epel      39 k\n nginx-mod-http-xslt-filter      x86_64     1:1.16.1-1.el7       epel      29 k\n nginx-mod-mail                  x86_64     1:1.16.1-1.el7       epel      57 k\n nginx-mod-stream                x86_64     1:1.16.1-1.el7       epel      84 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+11 Dependent packages)\n\nTotal download size: 1.4 M\nInstalled size: 4.1 M\nBackground downloading packages, then exiting:\nexiting because \"Download Only\" specified\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们在node1节点上面检查一下，可以看到：

```sh
[ansible@node1 ~]$ ls -lah /var/cache/yum/x86_64/7/{base,epel}/packages/
/var/cache/yum/x86_64/7/base/packages/:
total 572K
drwxr-xr-x. 2 root root  175 Aug 11 12:12 .
drwxr-xr-x. 4 root root  278 Aug 11 09:37 ..
-rw-r--r--  1 root root  92K Jul  4  2014 centos-indexhtml-7-9.el7.centos.noarch.rpm
-rw-r--r--  1 root root 146K Jul  4  2014 gd-2.0.35-26.el7.x86_64.rpm
-rw-r--r--  1 root root 273K Apr 25  2018 gperftools-libs-2.6.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  56K Aug 11  2017 libXpm-3.5.12-1.el7.x86_64.rpm

/var/cache/yum/x86_64/7/epel/packages/:
total 868K
drwxr-xr-x. 2 root root 4.0K Aug 11 12:12 .
drwxr-xr-x. 4 root root 4.0K Aug 11 09:37 ..
-rw-r--r--  1 root root 562K Oct  4  2019 nginx-1.16.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  20K Oct  4  2019 nginx-all-modules-1.16.1-1.el7.noarch.rpm
-rw-r--r--  1 root root  21K Oct  4  2019 nginx-filesystem-1.16.1-1.el7.noarch.rpm
-rw-r--r--  1 root root  30K Oct  4  2019 nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  39K Oct  4  2019 nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  29K Oct  4  2019 nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  57K Oct  4  2019 nginx-mod-mail-1.16.1-1.el7.x86_64.rpm
-rw-r--r--  1 root root  85K Oct  4  2019 nginx-mod-stream-1.16.1-1.el7.x86_64.rpm
[ansible@node1 ~]$ ls -lah softs/not_exist_dir/
total 1.5M
drwxr-xr-x 2 root root 4.0K Aug 11 12:12 .
drwxr-xr-x 3 root root   27 Aug 11 12:12 ..
-rw-r--r-- 1 root root  92K Jul  4  2014 centos-indexhtml-7-9.el7.centos.noarch.rpm
-rw-r--r-- 1 root root 146K Jul  4  2014 gd-2.0.35-26.el7.x86_64.rpm
-rw-r--r-- 1 root root 273K Apr 25  2018 gperftools-libs-2.6.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  56K Aug 11  2017 libXpm-3.5.12-1.el7.x86_64.rpm
-rw-r--r-- 1 root root 562K Oct  4  2019 nginx-1.16.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  20K Oct  4  2019 nginx-all-modules-1.16.1-1.el7.noarch.rpm
-rw-r--r-- 1 root root  21K Oct  4  2019 nginx-filesystem-1.16.1-1.el7.noarch.rpm
-rw-r--r-- 1 root root  30K Oct  4  2019 nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  39K Oct  4  2019 nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  29K Oct  4  2019 nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  57K Oct  4  2019 nginx-mod-mail-1.16.1-1.el7.x86_64.rpm
-rw-r--r-- 1 root root  85K Oct  4  2019 nginx-mod-stream-1.16.1-1.el7.x86_64.rpm
[ansible@node1 ~]$ 
```

当不指定下载目录时，yum会将依赖包下载到各自的仓库对应的缓存目录下，而指定目录时，会将所有的依赖包都下载到指定目录中。



### 8.5 安装指定版本软件

我计划升级一下httpd版本到比较新的`2.4.41`版本。

```sh
# 查看当前安装的版本
[ansible@node1 ~]$ rpm -qa|grep httpd
httpd-tools-2.4.6-93.el7.centos.x86_64
httpd-2.4.6-93.el7.centos.x86_64

# 查看一下，可升级的版本
[ansible@node1 ~]$ yum list httpd24u
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Available Packages
httpd24u.x86_64                               2.4.41-1.el7.ius                                ius
[ansible@node1 ~]$ 
```

现在我们尝试使用剧本来安装新版本。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 安装指定版本的软件包
    - name: install one specific version of Apache
      yum:
        name: httpd24u-2.4.41
        state: present
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install one specific version of Apache] ***************************************************
fatal: [node1]: FAILED! => {"changed": false, "changes": {"installed": ["httpd24u-2.4.41"]}, "msg": "Error: httpd24u-tools conflicts with httpd-tools-2.4.6-93.el7.centos.x86_64\nError: httpd24u conflicts with httpd-2.4.6-93.el7.centos.x86_64\n", "rc": 1, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package httpd24u.x86_64 0:2.4.41-1.el7.ius will be installed\n--> Processing Dependency: httpd24u-filesystem = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: httpd24u-filesystem = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: httpd24u-tools = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libnghttp2.so.14()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libbrotlienc.so.1()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libapr15uutil-1.so.0()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libapr15u-1.so.0()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Running transaction check\n---> Package apr15u.x86_64 0:1.5.2-2.ius.el7 will be installed\n---> Package apr15u-util.x86_64 0:1.5.4-3.ius.el7 will be installed\n---> Package brotli.x86_64 0:1.0.7-5.el7 will be installed\n---> Package httpd24u-filesystem.noarch 0:2.4.41-1.el7.ius will be installed\n---> Package httpd24u-tools.x86_64 0:2.4.41-1.el7.ius will be installed\n---> Package libnghttp2.x86_64 0:1.33.0-1.1.el7 will be installed\n--> Processing Conflict: httpd24u-tools-2.4.41-1.el7.ius.x86_64 conflicts httpd-tools < 2.4.41-1.el7.ius\n--> Processing Conflict: httpd24u-2.4.41-1.el7.ius.x86_64 conflicts httpd < 2.4.41-1.el7.ius\n--> Finished Dependency Resolution\n You could try using --skip-broken to work around the problem\n You could try running: rpm -Va --nofiles --nodigest\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，因为软件包存在冲突，安装指定软件包失败！Ansible不会自动帮我们删除之前的旧版本的软件包。

因此我们先把旧版本的软件包删除，然后再安装。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 卸载旧版本的Apache
    - name: uninstall the older Apache
      yum:
        name:
          - httpd
          - httpd-tools
        state: absent
      become: yes

    # 安装指定版本的软件包
    - name: install one specific version of Apache
      yum:
        name:
          - httpd24u-2.4.41
        state: present
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [uninstall the older Apache] ***************************************************************
changed: [node1] => {"changed": true, "changes": {"removed": ["httpd", "httpd-tools"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package httpd.x86_64 0:2.4.6-93.el7.centos will be erased\n---> Package httpd-tools.x86_64 0:2.4.6-93.el7.centos will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package            Arch          Version                    Repository    Size\n================================================================================\nRemoving:\n httpd              x86_64        2.4.6-93.el7.centos        @base        9.4 M\n httpd-tools        x86_64        2.4.6-93.el7.centos        @base        168 k\n\nTransaction Summary\n================================================================================\nRemove  2 Packages\n\nInstalled size: 9.5 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing    : httpd-2.4.6-93.el7.centos.x86_64                             1/2 \n  Erasing    : httpd-tools-2.4.6-93.el7.centos.x86_64                       2/2 \n  Verifying  : httpd-tools-2.4.6-93.el7.centos.x86_64                       1/2 \n  Verifying  : httpd-2.4.6-93.el7.centos.x86_64                             2/2 \n\nRemoved:\n  httpd.x86_64 0:2.4.6-93.el7.centos  httpd-tools.x86_64 0:2.4.6-93.el7.centos \n\nComplete!\n"]}

TASK [install one specific version of Apache] ***************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["httpd24u-2.4.41"]}, "msg": "https://mirrors.tuna.tsinghua.edu.cn/ius/7/x86_64/packages/a/apr15u-1.5.2-2.ius.el7.x86_64.rpm: [Errno 14] curl#7 - \"Failed to connect to 2402:f000:1:408:8100::1: Network is unreachable\"\nTrying other mirror.\nhttps://mirrors.tuna.tsinghua.edu.cn/ius/7/x86_64/packages/a/apr15u-util-1.5.4-3.ius.el7.x86_64.rpm: [Errno 14] curl#7 - \"Failed to connect to 2402:f000:1:408:8100::1: Network is unreachable\"\nTrying other mirror.\nhttps://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/Packages/b/brotli-1.0.7-5.el7.x86_64.rpm: [Errno 14] curl#7 - \"Failed to connect to 2402:f000:1:408:8100::1: Network is unreachable\"\nTrying other mirror.\n", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.bit.edu.cn\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package httpd24u.x86_64 0:2.4.41-1.el7.ius will be installed\n--> Processing Dependency: httpd24u-filesystem = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: httpd24u-filesystem = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: httpd24u-tools = 2.4.41-1.el7.ius for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libnghttp2.so.14()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libbrotlienc.so.1()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libapr15uutil-1.so.0()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Processing Dependency: libapr15u-1.so.0()(64bit) for package: httpd24u-2.4.41-1.el7.ius.x86_64\n--> Running transaction check\n---> Package apr15u.x86_64 0:1.5.2-2.ius.el7 will be installed\n---> Package apr15u-util.x86_64 0:1.5.4-3.ius.el7 will be installed\n---> Package brotli.x86_64 0:1.0.7-5.el7 will be installed\n---> Package httpd24u-filesystem.noarch 0:2.4.41-1.el7.ius will be installed\n---> Package httpd24u-tools.x86_64 0:2.4.41-1.el7.ius will be installed\n---> Package libnghttp2.x86_64 0:1.33.0-1.1.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                   Arch         Version                Repository  Size\n================================================================================\nInstalling:\n httpd24u                  x86_64       2.4.41-1.el7.ius       ius        1.4 M\nInstalling for dependencies:\n apr15u                    x86_64       1.5.2-2.ius.el7        ius        112 k\n apr15u-util               x86_64       1.5.4-3.ius.el7        ius         93 k\n brotli                    x86_64       1.0.7-5.el7            epel       318 k\n httpd24u-filesystem       noarch       2.4.41-1.el7.ius       ius         27 k\n httpd24u-tools            x86_64       2.4.41-1.el7.ius       ius         90 k\n libnghttp2                x86_64       1.33.0-1.1.el7         epel        68 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+6 Dependent packages)\n\nTotal download size: 2.1 M\nInstalled size: 6.5 M\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                               62 kB/s | 2.1 MB  00:34     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : apr15u-1.5.2-2.ius.el7.x86_64                                1/7 \n  Installing : apr15u-util-1.5.4-3.ius.el7.x86_64                           2/7 \n  Installing : httpd24u-tools-2.4.41-1.el7.ius.x86_64                       3/7 \n  Installing : libnghttp2-1.33.0-1.1.el7.x86_64                             4/7 \n  Installing : httpd24u-filesystem-2.4.41-1.el7.ius.noarch                  5/7 \n  Installing : brotli-1.0.7-5.el7.x86_64                                    6/7 \n  Installing : httpd24u-2.4.41-1.el7.ius.x86_64                             7/7 \n  Verifying  : httpd24u-tools-2.4.41-1.el7.ius.x86_64                       1/7 \n  Verifying  : brotli-1.0.7-5.el7.x86_64                                    2/7 \n  Verifying  : apr15u-util-1.5.4-3.ius.el7.x86_64                           3/7 \n  Verifying  : apr15u-1.5.2-2.ius.el7.x86_64                                4/7 \n  Verifying  : httpd24u-filesystem-2.4.41-1.el7.ius.noarch                  5/7 \n  Verifying  : httpd24u-2.4.41-1.el7.ius.x86_64                             6/7 \n  Verifying  : libnghttp2-1.33.0-1.1.el7.x86_64                             7/7 \n\nInstalled:\n  httpd24u.x86_64 0:2.4.41-1.el7.ius                                            \n\nDependency Installed:\n  apr15u.x86_64 0:1.5.2-2.ius.el7                                               \n  apr15u-util.x86_64 0:1.5.4-3.ius.el7                                          \n  brotli.x86_64 0:1.0.7-5.el7                                                   \n  httpd24u-filesystem.noarch 0:2.4.41-1.el7.ius                                 \n  httpd24u-tools.x86_64 0:2.4.41-1.el7.ius                                      \n  libnghttp2.x86_64 0:1.33.0-1.1.el7                                            \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，旧的版本被卸载掉，新的版本安装成功，我们检查一下：

```sh
[ansible@node1 ~]$ rpm -qa|grep httpd
httpd24u-filesystem-2.4.41-1.el7.ius.noarch
httpd24u-tools-2.4.41-1.el7.ius.x86_64
httpd24u-2.4.41-1.el7.ius.x86_64
[ansible@node1 ~]$ httpd -v
Server version: Apache/2.4.41 (IUS)
Server built:   Aug 25 2019 19:41:04
```

可以看到，`httpd`已经成功升级了！



### 8.6 仓库的禁用

我们可以通过以下命令查看当前我们系统有哪些yum仓库：

```sh
[ansible@node1 ~]$ yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                       repo name                                                    status
base/7/x86_64                 CentOS-7 - Base                                              10,070
epel/x86_64                   Extra Packages for Enterprise Linux 7 - x86_64               13,425
extras/7/x86_64               CentOS-7 - Extras                                               413
ius/x86_64                    IUS for Enterprise Linux 7 - x86_64                             365
mariadb                       MariaDB                                                          92
updates/7/x86_64              CentOS-7 - Updates                                            1,112
repolist: 25,477
[ansible@node1 ~]$ 

# 查看nginx cowsay lua53u信息可知它们位于epel、ius仓库中
[ansible@node1 ~]$ yum info nginx cowsay lua53u
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Available Packages
Name        : cowsay
Arch        : noarch
Version     : 3.04
Release     : 4.el7
Size        : 42 k
Repo        : epel/x86_64
Summary     : Configurable speaking/thinking cow
URL         : https://github.com/tnalpgge/rank-amateur-cowsay
License     : GPLv3+
Description : cowsay is a configurable talking cow, written in Perl.  It operates
            : much as the figlet program does, and it written in the same spirit
            : of silliness.
            : It generates ASCII pictures of a cow with a message. It can also generate
            : pictures of other animals.

Name        : lua53u
Arch        : x86_64
Version     : 5.3.4
Release     : 1.ius.el7
Size        : 184 k
Repo        : ius/x86_64
Summary     : Powerful light-weight programming language
URL         : http://www.lua.org/
License     : MIT
Description : Lua is a powerful light-weight programming language designed for
            : extending applications. Lua is also frequently used as a
            : general-purpose, stand-alone language. Lua is free software.
            : Lua combines simple procedural syntax with powerful data description
            : constructs based on associative arrays and extensible semantics. Lua
            : is dynamically typed, interpreted from bytecodes, and has automatic
            : memory management with garbage collection, making it ideal for
            : configuration, scripting, and rapid prototyping.

Name        : nginx
Arch        : x86_64
Epoch       : 1
Version     : 1.16.1
Release     : 1.el7
Size        : 562 k
Repo        : epel/x86_64
Summary     : A high performance web server and reverse proxy server
URL         : http://nginx.org/
License     : BSD
Description : Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and
            : IMAP protocols, with a strong focus on high concurrency, performance and low
            : memory usage.

[ansible@node1 ~]$ 
```

为了防止出现异常操作，我们先备份一下仓库的配置文件。

```sh
[ansible@node1 ~]$ sudo cp -r /etc/yum.repos.d /etc/yum.repos.d.bak
[ansible@node1 ~]$ ls /etc/yum.repos.d*
/etc/yum.repos.d:
CentOS-Base.repo       CentOS-fasttrack.repo  CentOS-Vault.repo  ius.repo
CentOS-CR.repo         CentOS-Media.repo      epel.repo          MariaDB.repo
CentOS-Debuginfo.repo  CentOS-Sources.repo    epel-testing.repo

/etc/yum.repos.d.bak:
CentOS-Base.repo       CentOS-fasttrack.repo  CentOS-Vault.repo  ius.repo
CentOS-CR.repo         CentOS-Media.repo      epel.repo          MariaDB.repo
CentOS-Debuginfo.repo  CentOS-Sources.repo    epel-testing.repo
[ansible@node1 ~]$ 
```

我们可以直接使用`yum-config-manager`来管理仓库是否禁用。

```sh
# 禁用epel仓库
[ansible@node1 ~]$ sudo yum-config-manager --disable epel
# 查看epel仓库状态，显示disabled表示禁用
[ansible@node1 ~]$ yum repolist epel
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                    repo name                                                     status
epel/x86_64                Extra Packages for Enterprise Linux 7 - x86_64                disabled
repolist: 0
[ansible@node1 ~]$
# 查看epel仓库配置文件，可以看到enabled=0
[ansible@node1 ~]$ cat /etc/yum.repos.d/epel.repo 
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $basearch - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/$basearch/debug
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/SRPMS
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1
[ansible@node1 ~]$

# 启用epel仓库
[ansible@node1 ~]$ sudo yum-config-manager --enable epel

# 查看epel仓库状态，没有显示disabled，表示已经启用了
[ansible@node1 ~]$ yum repolist epel
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                     repo name                                                      status
epel/x86_64                 Extra Packages for Enterprise Linux 7 - x86_64                 13,425
repolist: 13,425

# 查看epel仓库配置文件，可以看到enabled=1
[ansible@node1 ~]$ cat /etc/yum.repos.d/epel.repo 
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $basearch - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/$basearch/debug
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/SRPMS
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1
[ansible@node1 ~]$ 
```



现在我们尝试使用`disablerepo`来禁用某个仓库。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 禁用某些仓库时，来安装包
    - name: install packages with disable some repo
      yum:
        name:
          - nginx
          - cowsay
          - lua53u
        disablerepo:
          - epel
          - ius
        state: installed
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install packages with disable some repo] **************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "No package matching 'nginx' found available, installed or updated", "rc": 126, "results": ["No package matching 'nginx' found available, installed or updated"]}

PLAY RECAP **************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

第一次运行，我们禁用了`epel`和`ius`仓库，此时，`nginx`包没有找到，因为`nginx`包是在`epel`仓库中。所以说明禁用生效了。

现在，假如我们不安装`epel`和`ius`仓库的软件，安装`base`仓库中的`at`包：

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 禁用某些仓库时，来安装包
    - name: install packages with disable some repo
      yum:
        name:
          - at
          # - nginx
          # - cowsay
          # - lua53u
        disablerepo:
          - epel
          - ius
        state: installed
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install packages with disable some repo] **************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["at"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirrors.cn99.com\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package at.x86_64 0:3.1.13-24.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package       Arch              Version                  Repository       Size\n================================================================================\nInstalling:\n at            x86_64            3.1.13-24.el7            base             51 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal download size: 51 k\nInstalled size: 95 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : at-3.1.13-24.el7.x86_64                                      1/1 \n  Verifying  : at-3.1.13-24.el7.x86_64                                      1/1 \n\nInstalled:\n  at.x86_64 0:3.1.13-24.el7                                                     \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到`at`安装成功。此时我们查看一下`epel`和`ius`仓库状态：

```sh
[ansible@node1 ~]$ yum repolist epel
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                     repo name                                                      status
epel/x86_64                 Extra Packages for Enterprise Linux 7 - x86_64                 13,425
repolist: 13,425
[ansible@node1 ~]$ yum repolist ius
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                          repo name                                                 status
ius/x86_64                       IUS for Enterprise Linux 7 - x86_64                       365
repolist: 365
[ansible@node1 ~]$ 
```

可以看到，并没有被禁用！



下面我尝试在剧本中安装一个在上一个任务中被禁用的仓库里面的包：

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 禁用某些仓库时，来安装包
    - name: install packages with disable some repo
      yum:
        name:
          - at
          # - nginx
          # - cowsay
          # - lua53u
        disablerepo:
          - epel
          - ius
        state: installed
      become: yes

    # 安装指定版本的软件包
    - name: install package before task disable repo
      yum:
        name:
          - lua53u
        state: present
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install packages with disable some repo] **************************************************
ok: [node1] => {"changed": false, "msg": "", "rc": 0, "results": ["at-3.1.13-24.el7.x86_64 providing at is already installed"]}

TASK [install package before task disable repo] *************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["lua53u"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirrors.cn99.com\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package lua53u.x86_64 0:5.3.4-1.ius.el7 will be installed\n--> Processing Dependency: lua53u-libs(x86-64) = 5.3.4-1.ius.el7 for package: lua53u-5.3.4-1.ius.el7.x86_64\n--> Processing Dependency: liblua-5.3.so()(64bit) for package: lua53u-5.3.4-1.ius.el7.x86_64\n--> Running transaction check\n---> Package lua53u-libs.x86_64 0:5.3.4-1.ius.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch           Version                   Repository   Size\n================================================================================\nInstalling:\n lua53u              x86_64         5.3.4-1.ius.el7           ius         184 k\nInstalling for dependencies:\n lua53u-libs         x86_64         5.3.4-1.ius.el7           ius         111 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+1 Dependent package)\n\nTotal download size: 295 k\nInstalled size: 782 k\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                               40 kB/s | 295 kB  00:07     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : lua53u-libs-5.3.4-1.ius.el7.x86_64                           1/2 \n  Installing : lua53u-5.3.4-1.ius.el7.x86_64                                2/2 \n  Verifying  : lua53u-5.3.4-1.ius.el7.x86_64                                1/2 \n  Verifying  : lua53u-libs-5.3.4-1.ius.el7.x86_64                           2/2 \n\nInstalled:\n  lua53u.x86_64 0:5.3.4-1.ius.el7                                               \n\nDependency Installed:\n  lua53u-libs.x86_64 0:5.3.4-1.ius.el7                                          \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时，可以看到，虽然第一个任务禁用了`ius`仓库，但并不影响第二个任务，因此第二个任务中正常安装了`ius`仓库中的`lua53u`软件。

现在我们可以看出，**我们使用`disablerepo`禁用仓库，只对某一具体的任务有效，相互之间并无关联。**



### 8.7 仓库的启用

我们先卸载一下我们刚才安装的`lua53u`软件。

```sh
# 查看lua相关的包
[ansible@node1 ~]$ rpm -qa|grep lua
lua53u-libs-5.3.4-1.ius.el7.x86_64
lua53u-5.3.4-1.ius.el7.x86_64
lua-5.1.4-15.el7.x86_64

# 卸载包
[ansible@node1 ~]$ sudo yum remove lua53u lua53u-libs -y

# 再次查看lua相关的包
[ansible@node1 ~]$ rpm -qa|grep lua
lua-5.1.4-15.el7.x86_64
```

我们可以通过`sudo yum repo-pkgs ius list|more`命令来查看`ius`仓库中有哪些包：

```sh
[ansible@node1 ~]$ sudo yum repo-pkgs ius list|grep tmux
tmux2.x86_64                                 2.9a-2.el7.ius                 ius 
[ansible@node1 ~]$ 
[ansible@node1 ~]$ sudo yum info tmux2
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.cn99.com
 * extras: mirror.bit.edu.cn
 * updates: mirror.bit.edu.cn
Available Packages
Name        : tmux2
Arch        : x86_64
Version     : 2.9a
Release     : 2.el7.ius
Size        : 329 k
Repo        : ius/x86_64
Summary     : A terminal multiplexer
URL         : https://tmux.github.io/
License     : ISC and BSD
Description : tmux is a "terminal multiplexer."  It enables a number of terminals (or
            : windows) to be accessed and controlled from a single terminal.  tmux is
            : intended to be a simple, modern, BSD-licensed alternative to programs such
            : as GNU Screen.

[ansible@node1 ~]$
```

我们可以知道`tmux2`在`ius`仓库中。



现在我们先使用`yum-config-manager`命令把`ius`仓库禁用掉。

```sh
# 禁用ius仓库
# 启用的话，使用sudo yum-config-manager --enable ius
[ansible@node1 ~]$ sudo yum-config-manager --disable ius

# 查看ius仓库状态
[ansible@node1 ~]$ yum repolist ius
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                         repo name                                                status
ius/x86_64                      IUS for Enterprise Linux 7 - x86_64                      disabled
repolist: 0

# 因为ius仓库被禁用了，所以此时lua53u查找不到
[ansible@node1 ~]$ yum info lua53u
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Error: No matching Packages to list

# 因为ius仓库被禁用了，所以此时tmux2查找不到
[ansible@node1 ~]$ yum info tmux2
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Error: No matching Packages to list
[ansible@node1 ~]$
[ansible@node1 ~]$ rpm -qa|grep lua
lua-5.1.4-15.el7.x86_64
[ansible@node1 ~]$ rpm -qa|grep tmux
```

现在我们使用剧本来安装这两个软件。

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 启用某个仓库来安装的软件包
    - name: install package with enable some repo
      yum:
        name:
          - lua53u
        enablerepo: ius
        state: present
      become: yes

    # 不启用ius仓库来安装ius仓库的软件包
    - name: install package without enable some repo
      yum:
        name:
          - tmux2
        state: present
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install package with enable some repo] ****************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["lua53u"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirrors.cn99.com\n * extras: mirror.bit.edu.cn\n * updates: mirror.bit.edu.cn\nResolving Dependencies\n--> Running transaction check\n---> Package lua53u.x86_64 0:5.3.4-1.ius.el7 will be installed\n--> Processing Dependency: lua53u-libs(x86-64) = 5.3.4-1.ius.el7 for package: lua53u-5.3.4-1.ius.el7.x86_64\n--> Processing Dependency: liblua-5.3.so()(64bit) for package: lua53u-5.3.4-1.ius.el7.x86_64\n--> Running transaction check\n---> Package lua53u-libs.x86_64 0:5.3.4-1.ius.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch           Version                   Repository   Size\n================================================================================\nInstalling:\n lua53u              x86_64         5.3.4-1.ius.el7           ius         184 k\nInstalling for dependencies:\n lua53u-libs         x86_64         5.3.4-1.ius.el7           ius         111 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+1 Dependent package)\n\nTotal download size: 295 k\nInstalled size: 782 k\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                               41 kB/s | 295 kB  00:07     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : lua53u-libs-5.3.4-1.ius.el7.x86_64                           1/2 \n  Installing : lua53u-5.3.4-1.ius.el7.x86_64                                2/2 \n  Verifying  : lua53u-5.3.4-1.ius.el7.x86_64                                1/2 \n  Verifying  : lua53u-libs-5.3.4-1.ius.el7.x86_64                           2/2 \n\nInstalled:\n  lua53u.x86_64 0:5.3.4-1.ius.el7                                               \n\nDependency Installed:\n  lua53u-libs.x86_64 0:5.3.4-1.ius.el7                                          \n\nComplete!\n"]}

TASK [install package without enable some repo] *************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "No package matching 'tmux2' found available, installed or updated", "rc": 126, "results": ["No package matching 'tmux2' found available, installed or updated"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到，任务`install package with enable some repo`因为使用了`enablerepo: ius`参数，启用了`ius`仓库，所有成功安装了`lua53u`，而任务`install package without enable some repo`因为没有启用`ius`仓库，所以此时找不到`tmux2`这个包，安装失败！

我们此时在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ rpm -qa|grep lua
lua53u-5.3.4-1.ius.el7.x86_64
lua53u-libs-5.3.4-1.ius.el7.x86_64
lua-5.1.4-15.el7.x86_64
[ansible@node1 ~]$ rpm -qa|grep tmux
[ansible@node1 ~]$ yum repolist ius
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                         repo name                                                status
ius/x86_64                      IUS for Enterprise Linux 7 - x86_64                      disabled
repolist: 0
[ansible@node1 ~]$ 
```

可以看到`lua53u`软件已经成功安装，`tmux2`仍然没有被安装，而`ius`仓库仍然是`disabled`禁用状态。说明`enablerepo`参数并不会更改远程主机yum的仓库禁用、启用设置，只是临时生效。与`disablerepo`类似，只在该参数相关的任务中才会生效！



### 8.8 通过远程仓库安装包

我们也可以直接指定远程仓库路径来安装包，但这个时候需要自己先找到包的地址：

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  tasks:
    # 通过远程仓库安装包
    - name: install the nginx rpm from a remote repo
      yum:
        name:
          - https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/Packages/c/cowsay-3.04-4.el7.noarch.rpm
        state: present
      become: yes
[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml

[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install the nginx rpm from a remote repo] *************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["/home/ansible/.ansible/tmp/ansible-tmp-1597138865.18-15356-68319093869251/cowsay-3.04-4.el7.noarchYJ7zdE.rpm"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nExamining /home/ansible/.ansible/tmp/ansible-tmp-1597138865.18-15356-68319093869251/cowsay-3.04-4.el7.noarchYJ7zdE.rpm: cowsay-3.04-4.el7.noarch\nMarking /home/ansible/.ansible/tmp/ansible-tmp-1597138865.18-15356-68319093869251/cowsay-3.04-4.el7.noarchYJ7zdE.rpm to be installed\nResolving Dependencies\n--> Running transaction check\n---> Package cowsay.noarch 0:3.04-4.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package    Arch       Version        Repository                           Size\n================================================================================\nInstalling:\n cowsay     noarch     3.04-4.el7     /cowsay-3.04-4.el7.noarchYJ7zdE      77 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal size: 77 k\nInstalled size: 77 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : cowsay-3.04-4.el7.noarch                                     1/1 \n  Verifying  : cowsay-3.04-4.el7.noarch                                     1/1 \n\nInstalled:\n  cowsay.noarch 0:3.04-4.el7                                                    \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

最后记得将原来禁用的仓库启用一下。

```sh
[ansible@node1 ~]$ sudo yum-config-manager --enable ius
[ansible@node1 ~]$ yum repolist ius
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
repo id                          repo name                                                 status
ius/x86_64                       IUS for Enterprise Linux 7 - x86_64                       365
repolist: 365
[ansible@node1 ~]$ 
```

说明`ius`仓库启用成功。



### 8.9 通过本地rpm文件安装软件

之前我们通过`yum`只下载不安装下载了nginx的安装包以及期依赖包。

```sh
# 查看下载到的依赖包以及nginx的安装包
[ansible@node1 ~]$ ls softs/not_exist_dir/
centos-indexhtml-7-9.el7.centos.noarch.rpm  nginx-filesystem-1.16.1-1.el7.noarch.rpm
gd-2.0.35-26.el7.x86_64.rpm                 nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm
gperftools-libs-2.6.1-1.el7.x86_64.rpm      nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm
libXpm-3.5.12-1.el7.x86_64.rpm              nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm
nginx-1.16.1-1.el7.x86_64.rpm               nginx-mod-mail-1.16.1-1.el7.x86_64.rpm
nginx-all-modules-1.16.1-1.el7.noarch.rpm   nginx-mod-stream-1.16.1-1.el7.x86_64.rpm

# 我们通过命令行尝试安装nginx，可以看到nginx有依赖包需要安装
[ansible@node1 ~]$ sudo yum install nginx
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirrors.aliyun.com
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.huaweicloud.com
base                                                                      | 3.6 kB  00:00:00     
epel                                                                      | 4.7 kB  00:00:00     
extras                                                                    | 2.9 kB  00:00:00     
ius                                                                       | 1.3 kB  00:00:00     
mariadb                                                                   | 2.9 kB  00:00:00     
updates                                                                   | 2.9 kB  00:00:00     
(1/9): base/7/x86_64/group_gz                                             | 153 kB  00:00:05     
(2/9): base/7/x86_64/primary_db                                           | 6.1 MB  00:00:07     
(3/9): epel/x86_64/group_gz                                               |  95 kB  00:00:15     
(4/9): epel/x86_64/updateinfo                                             | 1.0 MB  00:00:15     
(5/9): extras/7/x86_64/primary_db                                         | 206 kB  00:00:05     
(6/9): mariadb/primary_db                                                 |  66 kB  00:00:06     
(7/9): ius/x86_64/primary                                                 |  98 kB  00:00:06     
(8/9): updates/7/x86_64/primary_db                                        | 3.8 MB  00:00:07     
(9/9): epel/x86_64/primary_db                                             | 6.9 MB  00:00:07     
ius                                                                                      365/365
Resolving Dependencies
--> Running transaction check
---> Package nginx.x86_64 1:1.16.1-1.el7 will be installed
--> Processing Dependency: nginx-all-modules = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64
--> Processing Dependency: nginx-filesystem = 1:1.16.1-1.el7 for package: 1:nginx-1.16.1-1.el7.x86_64
--> Processing Dependency: nginx-filesystem for package: 1:nginx-1.16.1-1.el7.x86_64
--> Processing Dependency: redhat-indexhtml for package: 1:nginx-1.16.1-1.el7.x86_64
--> Processing Dependency: libprofiler.so.0()(64bit) for package: 1:nginx-1.16.1-1.el7.x86_64
--> Running transaction check
---> Package centos-indexhtml.noarch 0:7-9.el7.centos will be installed
---> Package gperftools-libs.x86_64 0:2.6.1-1.el7 will be installed
---> Package nginx-all-modules.noarch 1:1.16.1-1.el7 will be installed
--> Processing Dependency: nginx-mod-http-image-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Processing Dependency: nginx-mod-http-perl = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Processing Dependency: nginx-mod-http-xslt-filter = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Processing Dependency: nginx-mod-mail = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Processing Dependency: nginx-mod-stream = 1:1.16.1-1.el7 for package: 1:nginx-all-modules-1.16.1-1.el7.noarch
---> Package nginx-filesystem.noarch 1:1.16.1-1.el7 will be installed
--> Running transaction check
---> Package nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7 will be installed
--> Processing Dependency: gd for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64
--> Processing Dependency: libgd.so.2()(64bit) for package: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64
---> Package nginx-mod-http-perl.x86_64 1:1.16.1-1.el7 will be installed
---> Package nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7 will be installed
---> Package nginx-mod-mail.x86_64 1:1.16.1-1.el7 will be installed
---> Package nginx-mod-stream.x86_64 1:1.16.1-1.el7 will be installed
--> Running transaction check
---> Package gd.x86_64 0:2.0.35-26.el7 will be installed
--> Processing Dependency: libXpm.so.4()(64bit) for package: gd-2.0.35-26.el7.x86_64
--> Running transaction check
---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================
 Package                             Arch           Version                   Repository    Size
=================================================================================================
Installing:
 nginx                               x86_64         1:1.16.1-1.el7            epel         562 k
Installing for dependencies:
 centos-indexhtml                    noarch         7-9.el7.centos            base          92 k
 gd                                  x86_64         2.0.35-26.el7             base         146 k
 gperftools-libs                     x86_64         2.6.1-1.el7               base         272 k
 libXpm                              x86_64         3.5.12-1.el7              base          55 k
 nginx-all-modules                   noarch         1:1.16.1-1.el7            epel          19 k
 nginx-filesystem                    noarch         1:1.16.1-1.el7            epel          21 k
 nginx-mod-http-image-filter         x86_64         1:1.16.1-1.el7            epel          30 k
 nginx-mod-http-perl                 x86_64         1:1.16.1-1.el7            epel          39 k
 nginx-mod-http-xslt-filter          x86_64         1:1.16.1-1.el7            epel          29 k
 nginx-mod-mail                      x86_64         1:1.16.1-1.el7            epel          57 k
 nginx-mod-stream                    x86_64         1:1.16.1-1.el7            epel          84 k

Transaction Summary
=================================================================================================
Install  1 Package (+11 Dependent packages)

Total download size: 1.4 M
Installed size: 4.1 M
Is this ok [y/d/N]: n
Exiting on user command
Your transaction was saved, rerun it with:
 yum load-transaction /tmp/yum_save_tx.2020-08-12.10-07.KSKndJ.yumtx
[ansible@node1 ~]$ 
```



我们通过本地下载的安装包安装nginx:

```sh
[ansible@master ~]$ cat yum.yml 
- hosts: node1
  vars:
    local_soft_dir: /home/ansible/softs/not_exist_dir
  tasks:
    # 通过本地rpm包安装软件
    - name: install nginx rpm from a local file
      yum:
        name:
          - "{{ local_soft_dir }}/gperftools-libs-2.6.1-1.el7.x86_64.rpm"
          # gd的依赖
          - "{{ local_soft_dir }}/libXpm-3.5.12-1.el7.x86_64.rpm"
          - "{{ local_soft_dir }}/gd-2.0.35-26.el7.x86_64.rpm"
          # nginx-all-modules的依赖
          - "{{ local_soft_dir }}/nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm"
          - "{{ local_soft_dir }}/nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm"
          - "{{ local_soft_dir }}/nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm"
          - "{{ local_soft_dir }}/nginx-mod-mail-1.16.1-1.el7.x86_64.rpm"
          - "{{ local_soft_dir }}/nginx-mod-stream-1.16.1-1.el7.x86_64.rpm"
          # nginx的依赖
          - "{{ local_soft_dir }}/centos-indexhtml-7-9.el7.centos.noarch.rpm"
          - "{{ local_soft_dir }}/nginx-filesystem-1.16.1-1.el7.noarch.rpm"
          - "{{ local_soft_dir }}/nginx-all-modules-1.16.1-1.el7.noarch.rpm"
          - "{{ local_soft_dir }}/nginx-1.16.1-1.el7.x86_64.rpm"
        state: present
      become: yes

[ansible@master ~]$ ansible-lint yum.yml 
[ansible@master ~]$ ansible-playbook --syntax-check yum.yml 

playbook: yum.yml
[ansible@master ~]$ ansible-playbook yum.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [install nginx rpm from a local file] ******************************************************
changed: [node1] => {"changed": true, "changes": {"installed": ["/home/ansible/softs/not_exist_dir/gperftools-libs-2.6.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/libXpm-3.5.12-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/gd-2.0.35-26.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/nginx-mod-mail-1.16.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/nginx-mod-stream-1.16.1-1.el7.x86_64.rpm", "/home/ansible/softs/not_exist_dir/centos-indexhtml-7-9.el7.centos.noarch.rpm", "/home/ansible/softs/not_exist_dir/nginx-filesystem-1.16.1-1.el7.noarch.rpm", "/home/ansible/softs/not_exist_dir/nginx-all-modules-1.16.1-1.el7.noarch.rpm", "/home/ansible/softs/not_exist_dir/nginx-1.16.1-1.el7.x86_64.rpm"]}, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nExamining /home/ansible/softs/not_exist_dir/gperftools-libs-2.6.1-1.el7.x86_64.rpm: gperftools-libs-2.6.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/gperftools-libs-2.6.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/libXpm-3.5.12-1.el7.x86_64.rpm: libXpm-3.5.12-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/libXpm-3.5.12-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/gd-2.0.35-26.el7.x86_64.rpm: gd-2.0.35-26.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/gd-2.0.35-26.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm: 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-mod-http-image-filter-1.16.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm: 1:nginx-mod-http-perl-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-mod-http-perl-1.16.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm: 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-mod-mail-1.16.1-1.el7.x86_64.rpm: 1:nginx-mod-mail-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-mod-mail-1.16.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-mod-stream-1.16.1-1.el7.x86_64.rpm: 1:nginx-mod-stream-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-mod-stream-1.16.1-1.el7.x86_64.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/centos-indexhtml-7-9.el7.centos.noarch.rpm: centos-indexhtml-7-9.el7.centos.noarch\nMarking /home/ansible/softs/not_exist_dir/centos-indexhtml-7-9.el7.centos.noarch.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-filesystem-1.16.1-1.el7.noarch.rpm: 1:nginx-filesystem-1.16.1-1.el7.noarch\nMarking /home/ansible/softs/not_exist_dir/nginx-filesystem-1.16.1-1.el7.noarch.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-all-modules-1.16.1-1.el7.noarch.rpm: 1:nginx-all-modules-1.16.1-1.el7.noarch\nMarking /home/ansible/softs/not_exist_dir/nginx-all-modules-1.16.1-1.el7.noarch.rpm to be installed\nExamining /home/ansible/softs/not_exist_dir/nginx-1.16.1-1.el7.x86_64.rpm: 1:nginx-1.16.1-1.el7.x86_64\nMarking /home/ansible/softs/not_exist_dir/nginx-1.16.1-1.el7.x86_64.rpm to be installed\nResolving Dependencies\n--> Running transaction check\n---> Package centos-indexhtml.noarch 0:7-9.el7.centos will be installed\n---> Package gd.x86_64 0:2.0.35-26.el7 will be installed\n---> Package gperftools-libs.x86_64 0:2.6.1-1.el7 will be installed\n---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed\n---> Package nginx.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-all-modules.noarch 1:1.16.1-1.el7 will be installed\n---> Package nginx-filesystem.noarch 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-http-perl.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-mail.x86_64 1:1.16.1-1.el7 will be installed\n---> Package nginx-mod-stream.x86_64 1:1.16.1-1.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package Arch   Version         Repository                                 Size\n================================================================================\nInstalling:\n centos-indexhtml\n         noarch 7-9.el7.centos  /centos-indexhtml-7-9.el7.centos.noarch    90 k\n gd      x86_64 2.0.35-26.el7   /gd-2.0.35-26.el7.x86_64                  542 k\n gperftools-libs\n         x86_64 2.6.1-1.el7     /gperftools-libs-2.6.1-1.el7.x86_64       1.3 M\n libXpm  x86_64 3.5.12-1.el7    /libXpm-3.5.12-1.el7.x86_64               114 k\n nginx   x86_64 1:1.16.1-1.el7  /nginx-1.16.1-1.el7.x86_64                1.6 M\n nginx-all-modules\n         noarch 1:1.16.1-1.el7  /nginx-all-modules-1.16.1-1.el7.noarch    0.0  \n nginx-filesystem\n         noarch 1:1.16.1-1.el7  /nginx-filesystem-1.16.1-1.el7.noarch     0.0  \n nginx-mod-http-image-filter\n         x86_64 1:1.16.1-1.el7  /nginx-mod-http-image-filter-1.16.1-1.el7.x86_64\n                                                                           24 k\n nginx-mod-http-perl\n         x86_64 1:1.16.1-1.el7  /nginx-mod-http-perl-1.16.1-1.el7.x86_64   54 k\n nginx-mod-http-xslt-filter\n         x86_64 1:1.16.1-1.el7  /nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64\n                                                                           24 k\n nginx-mod-mail\n         x86_64 1:1.16.1-1.el7  /nginx-mod-mail-1.16.1-1.el7.x86_64        99 k\n nginx-mod-stream\n         x86_64 1:1.16.1-1.el7  /nginx-mod-stream-1.16.1-1.el7.x86_64     171 k\n\nTransaction Summary\n================================================================================\nInstall  12 Packages\n\nTotal size: 4.1 M\nInstalled size: 4.1 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : centos-indexhtml-7-9.el7.centos.noarch                      1/12 \n  Installing : gperftools-libs-2.6.1-1.el7.x86_64                          2/12 \n  Installing : 1:nginx-filesystem-1.16.1-1.el7.noarch                      3/12 \n  Installing : libXpm-3.5.12-1.el7.x86_64                                  4/12 \n  Installing : gd-2.0.35-26.el7.x86_64                                     5/12 \n  Installing : 1:nginx-mod-stream-1.16.1-1.el7.x86_64                      6/12 \n  Installing : 1:nginx-mod-mail-1.16.1-1.el7.x86_64                        7/12 \n  Installing : 1:nginx-mod-http-perl-1.16.1-1.el7.x86_64                   8/12 \n  Installing : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64            9/12 \n  Installing : 1:nginx-1.16.1-1.el7.x86_64                                10/12 \n  Installing : 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64          11/12 \n  Installing : 1:nginx-all-modules-1.16.1-1.el7.noarch                    12/12 \n  Verifying  : libXpm-3.5.12-1.el7.x86_64                                  1/12 \n  Verifying  : 1:nginx-mod-stream-1.16.1-1.el7.x86_64                      2/12 \n  Verifying  : 1:nginx-filesystem-1.16.1-1.el7.noarch                      3/12 \n  Verifying  : gperftools-libs-2.6.1-1.el7.x86_64                          4/12 \n  Verifying  : 1:nginx-all-modules-1.16.1-1.el7.noarch                     5/12 \n  Verifying  : gd-2.0.35-26.el7.x86_64                                     6/12 \n  Verifying  : 1:nginx-mod-mail-1.16.1-1.el7.x86_64                        7/12 \n  Verifying  : 1:nginx-mod-http-perl-1.16.1-1.el7.x86_64                   8/12 \n  Verifying  : 1:nginx-1.16.1-1.el7.x86_64                                 9/12 \n  Verifying  : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64           10/12 \n  Verifying  : centos-indexhtml-7-9.el7.centos.noarch                     11/12 \n  Verifying  : 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64          12/12 \n\nInstalled:\n  centos-indexhtml.noarch 0:7-9.el7.centos                                      \n  gd.x86_64 0:2.0.35-26.el7                                                     \n  gperftools-libs.x86_64 0:2.6.1-1.el7                                          \n  libXpm.x86_64 0:3.5.12-1.el7                                                  \n  nginx.x86_64 1:1.16.1-1.el7                                                   \n  nginx-all-modules.noarch 1:1.16.1-1.el7                                       \n  nginx-filesystem.noarch 1:1.16.1-1.el7                                        \n  nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7                             \n  nginx-mod-http-perl.x86_64 1:1.16.1-1.el7                                     \n  nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7                              \n  nginx-mod-mail.x86_64 1:1.16.1-1.el7                                          \n  nginx-mod-stream.x86_64 1:1.16.1-1.el7                                        \n\nComplete!\n"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，所有的包都是从本地进行安装的，这个需要注意的是，安装过程中需要注意安装的顺序，先安装依赖包，依赖包安装完成后再安装nginx。

在node1节点上面检查，可以发现`nginx`包安装成功，并且可以查看到nginx的版本信息。

```sh
[ansible@node1 ~]$ rpm -qa|grep nginx
nginx-filesystem-1.16.1-1.el7.noarch
nginx-mod-mail-1.16.1-1.el7.x86_64
nginx-mod-http-image-filter-1.16.1-1.el7.x86_64
nginx-mod-stream-1.16.1-1.el7.x86_64
nginx-mod-http-perl-1.16.1-1.el7.x86_64
nginx-1.16.1-1.el7.x86_64
nginx-all-modules-1.16.1-1.el7.noarch
nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64
[ansible@node1 ~]$ nginx -v
nginx version: nginx/1.16.1
[ansible@node1 ~]$
```

`yum`模块其他的参数，官方也没有给出示例，用得也比较少，我们就不去理会。

你可以了解一下`yum_repository`模块 (  [https://docs.ansible.com/ansible/latest/modules/yum_repository_module.html](https://docs.ansible.com/ansible/latest/modules/yum_repository_module.html) )来管理远程主机的`yum`仓库。

