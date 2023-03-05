# cron定时任务模块

[[toc]]

cron模块可以在远程主机上面创建定时任务，有点类似于`crontab`命令。

参考：

- [https://docs.ansible.com/ansible/latest/modules/cron_module.html](https://docs.ansible.com/ansible/latest/modules/cron_module.html)
- [https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/cron.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/cron.py)

一般在在linux系统上面都有`crontab`命令，也可以查看其配置示例：

```sh
[ansible@master ~]$ cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```

我们现在来了解一下Ansible的定时任务cron模块。

## 1. 注意事项

- 使用此模块来管理crontab和环境变量条目。 该模块允许您创建环境变量和命名的crontab条目，更新或删除它们。
- 使用cron模块管理主机定时任务时会添加`#Ansible: <name>`这样的描述信息，这个信息用于Ansible进行定位和管理定时任务。且名称name需要唯一。
- 管理环境变量时，没有描述信息。
- 使用％之类的符号时，必须正确转义它们。
- 不保证此模块具有向后兼容的接口。



## 2. 模块参数

| 参数           | 可选值                                                       | 默认值  | 说明                                                         |
| -------------- | ------------------------------------------------------------ | ------- | ------------------------------------------------------------ |
| `backup`       | yes/no                                                       | no      | `bool`，如果设置为`yes`，则在修改定时任务之前对定时任务进行备份，并返回备份文件的路径，该路径由`backup_file`表示。 |
| `cron_file`    |                                                              |         | `string`，如果指定，则使用此文件而不是单个用户的crontab。如果这是相对路径，则相对于/etc/cron.d进行解释。如果是绝对值，则通常为/etc/crontab。许多Linux发行版都希望(有些要求)文件名部分仅由大小写字母，数字，下划线和连字符组成。要使用cron_file参数，您还必须指定user用户参数。 |
| `day`          |                                                              | "*"     | `string`，每个月中哪些天需要运行定时任务，如`1-31`,`*`,`*/2`。 |
| `disabled`     | yes/no                                                       | no      | `bool`，定时任务是否被禁用，即注释掉，只有当`state=present`时才起作用。 |
| `env`          | yes/no                                                       | no      | `bool`，定时任务的环境变量，**新的环境变量会被添加加定时任务的顶部**。 |
| `hour`         |                                                              | "*"     | `string`，每天中哪些小时需要运行定时任务，如`0-23`,`*`,`*/2`。 |
| `insertafter`  |                                                              |         | `string`，与`state=present`和`env`一起使用，如果设置了该参数，则在声明指定的环境变量**之后**将插入环境变量。 |
| `insertbefore` |                                                              |         | `string`，与`state=present`和`env`一起使用，如果设置了该参数，则在声明指定的环境变量**之前**将插入环境变量。 |
| `job`          |                                                              |         | `string`，定时任务需要执行的命令，或者当指定`env`参数时为环境变量的值。命令中不应包含符行符，另外需要在`state=present`时才可用。当定义变量时，可以使用别名`value`。 |
| `minute`       |                                                              | "*"     | `string`，每小时中哪些分钟需要运行定时任务，如`0-59`,`*`,`*/2`。 |
| `name`         |                                                              |         | `string`，定时任务的描述信息。如果设置了`env`参数，那么name参数是环境变量的名称。注意，该参数是必须参数，需要设置`state=present`。如果不是`state=present`，那么定时任务也会创建，且与现存的定时任务无关！ |
| `reboot`       | 已经废弃的参数                                               |         | 请使用`special_time`参数。                                   |
| `special_time` | `annually`,<br />`daily`,<br />`hourly`,<br />`monthly`,<br />`reboot`,<br />`weekly`,<br />`yearly` |         | 特殊时间的昵称。对应是每年、每天、每小时、每月、重启、每周、每年。 |
| `state`        | absent/present                                               | present | 是否确保作业或环境变量存在或不存在。                         |
| `user`         |                                                              |         | `string`，哪个用户运行定时任务。不指定时是`root`用户，此处官网说法并不准确，如果你使用的是非root账号管理远程主机，那这个时候是这个非root账号。 |
| `weekday`      |                                                              | "*"     | t每周中的哪几天运行定时任务，如`0-6`代表周日到周六           |

## 3. 执行剧本

### 3.1 创建定时任务并移除指定定时任务

```sh
[ansible@master ~]$ cat cron.yml
- hosts: node1
  tasks:
    - name: Ensure a job that runs at 2 and 5 exists. Creates an entry like "0 7,17 * * ls -alh > /tmp/checkdirs.log"
      cron:
        name: "check dirs"
        minute: "0"
        hour: "7,17"
        job: "ls -alh > /tmp/checkdirs.log"

    - name: 'Ensure an new job 1 is present'
      cron:
        name: "an old job 1"
        minute: "0"
        hour: "2,5"
        job: "ls -alh > /tmp/oldjob1.log"
        state: present

    - name: 'Ensure an new job 2 is present'
      cron:
        name: "an old job 2"
        minute: "0"
        hour: "3,6"
        job: "ls -alh > /tmp/oldjob2.log"
        state: present

    - name: 'Ensure an old job is no longer present. Removes any job that is prefixed by "#Ansible: an old job" from the crontab'
      cron:
        name: "an old job"
        state: absent

    - name: 'Ensure an old job 2 is no longer present. Removes any job that is prefixed by "#Ansible: an old job 2" from the crontab'
      cron:
        name: "an old job 2"
        state: absent

[ansible@master ~]$ ansible-playbook --syntax-check cron.yml

playbook: cron.yml
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Ensure a job that runs at 2 and 5 exists. Creates an entry like "0 7,17 * * ls -alh > /tmp/checkdirs.log"] *************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["check dirs"]}

TASK [Ensure an new job 1 is present] ****************************************************************************************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["check dirs", "an old job 1"]}

TASK [Ensure an new job 2 is present] ****************************************************************************************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["check dirs", "an old job 1", "an old job 2"]}

TASK [Ensure an old job is no longer present. Removes any job that is prefixed by "#Ansible: an old job" from the crontab] ***************
ok: [node1] => {"changed": false, "envs": [], "jobs": ["check dirs", "an old job 1", "an old job 2"]}

TASK [Ensure an old job 2 is no longer present. Removes any job that is prefixed by "#Ansible: an old job 2" from the crontab] ***********
changed: [node1] => {"changed": true, "envs": [], "jobs": ["check dirs", "an old job 1"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

运行成功，在node1节点上面看一下定时任务情况：

```sh
[ansible@node1 ~]$ crontab -l
#Ansible: check dirs
0 7,17 * * * ls -alh > /tmp/checkdirs.log
#Ansible: an old job 1
0 2,5 * * * ls -alh > /tmp/oldjob1.log
[ansible@node1 ~]$ 
```

通过该示例，我们可以知道：

- `name`参数是必须的，用于指定定时任务的备注名称。
- `state: absent`移除旧定时任务时，只会移除与该定义完全匹配的`name`对应的定时任务，而不是以`name`定义字符开头的任务。如尝试移除`name: "an old job"`时，没有任何定时任务被移除，而使用`name: "an old job 2"`时，定时任务`#Ansible: an old job 2`被移除，定时任务`#Ansible: an old job 1`保留下来。

### 3.2 定时任务变量的定义

为了不影响本节的测试，我们在node1节点上把上面定义的定时任务都删除掉。然后在/home/ansible目录下面创建`cronjob.sh`脚本和`printcrontvariables.sh `脚本。

```sh
# 删除定时任务
[ansible@node1 ~]$ crontab -r

# 检查是否还有定时任务，发现已经没有定时任务了
[ansible@node1 ~]$ crontab -l
no crontab for ansible

# 编写一个脚本，记录下重启的时间，并保存到日志文件/tmp/cronjob.log中
[ansible@node1 ~]$ cat cronjob.sh
#!/bin/bash
echo -n "Reboot at: " |tee -a /tmp/cronjob.log
date|tee -a /tmp/cronjob.log

# 测试运行脚本，脚本正常运行
[ansible@node1 ~]$ sh cronjob.sh
Reboot at: Wed Jul 15 10:22:28 CST 2020

# 查看日志文件，正常记录重启时间（此处是模拟重启时执行脚本，并没有真正重启，后面使用Ansible进行主机重启）
[ansible@node1 ~]$ cat /tmp/cronjob.log
Reboot at: Wed Jul 15 10:22:28 CST 2020
[ansible@node1 ~]$ 
# 创建打印变量的脚本
[ansible@node1 ~]$ cat printcrontvariables.sh
#!/bin/bash
echo "USERNAME:${USERNAME}" |tee -a /tmp/variables.log
echo "ALIASNAME:${ALIASNAME}" |tee -a /tmp/variables.log
echo "APP_NAME:${APP_NAME}" |tee -a /tmp/variables.log

# 运行脚本，现在因为变量未定义，所有没有变量输出
[ansible@node1 ~]$ sh printcrontvariables.sh
USERNAME:
ALIASNAME:
APP_NAME:
```

编写剧本文件并运行剧本：

```sh
[ansible@master ~]$ cat cron.yml
- hosts: node1
  tasks:
    - name: Creates an entry like "USERNAME=ansible" on top of crontab
      cron:
        name: USERNAME
        env: yes
        job: ansible
        
    - name: Creates an entry like "ALIASNAME=ansible-alias" on top of crontab
      cron:
        name: ALIASNAME
        env: yes
        value: ansible-alias
        
    - name: Creates an entry like "APP_NAME=Ansible-APP" and insert it after USERNAME declaration
      cron:
        name: APP_NAME
        env: yes
        value: Ansible-APP
        insertafter: USERNAME
        
    - name: Creates an entry like "@reboot /home/ansible/cronjob.sh"
      cron:
        name: "a job for reboot"
        special_time: reboot
        job: "sh /home/ansible/cronjob.sh"
        
    - name: Creates an entry like "/home/ansible/printcrontvariables.sh"
      cron:
        name: "print the variables when reboot"
        special_time: reboot
        job: "sh /home/ansible/printcrontvariables.sh"
    
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml 

playbook: cron.yml
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Creates an entry like "USERNAME=ansible" on top of crontab] ************************************************************************
changed: [node1] => {"changed": true, "envs": ["USERNAME"], "jobs": []}

TASK [Creates an entry like "ALIASNAME=ansible-alias" on top of crontab] *****************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": []}

TASK [Creates an entry like "APP_NAME=Ansible-APP" and insert it after USERNAME declaration] *********************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "USERNAME", "APP_NAME"], "jobs": []}

TASK [Creates an entry like "@reboot /home/ansible/cronjob.sh"] **************************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "USERNAME", "APP_NAME"], "jobs": ["a job for reboot"]}

TASK [Creates an entry like "@reboot /home/ansible/printcrontvariables.sh"] **************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "USERNAME", "APP_NAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时在node1节点上面查看定时任务：

```sh
[ansible@node1 ~]$ crontab -l
ALIASNAME="ansible-alias"
USERNAME="ansible"
APP_NAME="Ansible-APP"
#Ansible: a job for reboot
@reboot sh /home/ansible/cronjob.sh
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
```

可以发现定时任务创建成功了！我们来看一下定时任务的添加过程。



首先我们定义了一个`USERNAME`变量，通过`job`参数来指定变量的值为`ansible`；接着我们又定义了一个变量`ALIASNAME`，此时通过`job`参数的别名`value`参数来指定变量的值为`ansible-alias`,按照Ansible的默认逻辑，后定义的变量会添加在定时任务的顶部，因此`ALIASNAME="ansible-alias"`行会位于`USERNAME="ansible"行`的上方；接着我们又定义了一个变量`APP_NAME`，此时通过`job`参数的别名`value`参数来指定变量的值为`Ansible-APP`，但此时增加了`insertafter: USERNAME`参数，表示在`USERNAME`参数行的后面添加该变量，因此此时`APP_NAME="Ansible-APP"`不会被添加到定时任务的顶部，而是在`USERNAME="ansible"`行的后面。因此，你可以依次看到`ALIASNAME="ansible-alias"`、`USERNAME="ansible"`和`APP_NAME="Ansible-APP"`这三行。最后两位任务通过`special_time: reboot`指定在主机重启时执行脚本，注意一点，任务`job`定义时，如果执行脚本，需要在前面加上`sh `关键字，即类似`job: "sh /home/ansible/cronjob.sh"`这样的，而不能是`job: "/home/ansible/cronjob.sh"`，**不带`sh `的时候定时任务不会执行**！！



好了，现在我们来重启一下node1节点：

```sh
[ansible@node1 ~]$ sudo shutdown -r now
```

重启后，我们重新SSH连接到node1节点上，查看一下定时任务是否执行，去看一下/tmp下面的日志有没有更新。

```sh
[ansible@node1 ~]$ cat /tmp/cronjob.log
Reboot at: Wed Jul 15 10:22:28 CST 2020
Reboot at: Wed Jul 15 11:23:36 CST 2020
[ansible@node1 ~]$ cat /tmp/variables.log
USERNAME:
ALIASNAME:
APP_NAME:
USERNAME:ansible
ALIASNAME:ansible-alias
APP_NAME:Ansible-APP
[ansible@node1 ~]$ 
```

可以发现脚本执行了！因为日志中增加了内容了！并且正常的获取到了刚才我们定义的三个变量的值！说明我们的配置都是正确的！



### 3.3 移除变量以及设置定时任务文件路径

编写剧本文件cron.yml如下：

```yaml
- hosts: node1
  tasks:
    - name: Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration
      cron:
        name: NEW_APP_NAME
        env: yes
        value: New-Ansible-APP
        insertbefore: USERNAME
        
    - name: Removes "APP_NAME" environment variable from crontab
      cron:
        name: APP_NAME
        env: yes
        state: absent
        
    - name: Creates a cron file under /etc/cron.d/ with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
        
    - name: Creates a cron file under /etc/cron.d/ with ansible
      cron:
        name: sync time at every month first day 
        day: "1"
        minute: "0"
        hour: "12"
        user: ansible
        job: "sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
    
    - name: Creates a cron file under /etc/crontab with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: /etc/crontab
        
    - name: Disable a crontab task with state=present
      cron:
        name: "print the variables when reboot"
        disabled: yes
        state: present
        
    - name: Disable a crontab task with state=absent
      cron:
        name: "a job for reboot"

```

执行剧本：

```sh
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml

playbook: cron.yml
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration] ************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME", "APP_NAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Removes "APP_NAME" environment variable from crontab] ******************************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Creates a cron file under /etc/cron.d/ with root] **********************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: IOError: [Errno 13] Permission denied: '/etc/cron.d/ansible_sync_time'
fatal: [node1]: FAILED! => {"changed": false, "module_stderr": "Shared connection to node1 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1594796090.13-3907-85394211968824/AnsiballZ_cron.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1594796090.13-3907-85394211968824/AnsiballZ_cron.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1594796090.13-3907-85394211968824/AnsiballZ_cron.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.cron', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_cron_payload_HqpzrZ/ansible_cron_payload.zip/ansible/modules/system/cron.py\", line 770, in <module>\r\n  File \"/tmp/ansible_cron_payload_HqpzrZ/ansible_cron_payload.zip/ansible/modules/system/cron.py\", line 740, in main\r\n  File \"/tmp/ansible_cron_payload_HqpzrZ/ansible_cron_payload.zip/ansible/modules/system/cron.py\", line 299, in write\r\nIOError: [Errno 13] Permission denied: '/etc/cron.d/ansible_sync_time'\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

发现以root账号创建定时任务失败，提示`IOError: [Errno 13] Permission denied: '/etc/cron.d/ansible_sync_time'`权限异常！说明我们操作`/etc/cron.d/`目录时，需要权限提升！我们增加一下`become: yes`参数！

修改后的cron.yml文件如下：

```yml
- hosts: node1
  tasks:
    - name: Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration
      cron:
        name: NEW_APP_NAME
        env: yes
        value: New-Ansible-APP
        insertbefore: USERNAME
        
    - name: Removes "APP_NAME" environment variable from crontab
      cron:
        name: APP_NAME
        env: yes
        state: absent
        
    - name: Creates a cron file under /etc/cron.d/ with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
      become: yes                                                       # 注意，此行是新增的
 
    - name: Creates a cron file under /etc/cron.d/ with ansible
      cron:
        name: sync time at every month first day 
        day: "1"
        minute: "0"
        hour: "12"
        user: ansible
        job: "sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
      become: yes                                                       # 注意，此行是新增的
      
    - name: Creates a cron file under /etc/crontab with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: /etc/crontab
      become: yes                                                       # 注意，此行是新增的
      
    - name: Disable a crontab task with state=present
      cron:
        name: "print the variables when reboot"
        disabled: yes
        state: present
        
    - name: Disable a crontab task with state=absent
      cron:
        name: "a job for reboot"
        disabled: yes
        state: absent

```

再次运行：

```sh
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml

playbook: cron.yml
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration] ************************************
ok: [node1] => {"changed": false, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Removes "APP_NAME" environment variable from crontab] ******************************************************************************
ok: [node1] => {"changed": false, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Creates a cron file under /etc/cron.d/ with root] **********************************************************************************
ok: [node1] => {"changed": false, "cron_file": "ansible_sync_time", "envs": [], "jobs": ["sync time at every Tuesday"]}

TASK [Creates a cron file under /etc/cron.d/ with ansible] *******************************************************************************
changed: [node1] => {"changed": true, "cron_file": "ansible_sync_time", "envs": [], "jobs": ["sync time at every Tuesday", "sync time at every month first day"]}

TASK [Creates a cron file under /etc/crontab with root] **********************************************************************************
changed: [node1] => {"changed": true, "cron_file": "/etc/crontab", "envs": ["SHELL", "PATH", "MAILTO"], "jobs": ["sync time at every Tuesday"]}

TASK [Disable a crontab task with state=present] *****************************************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "You must specify 'job' to install a new cron job or variable"}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=6    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时提示`TASK [Disable a crontab task with state=present] `任务异常，必须指定`job`参数。可以看出，如果想要将某一个定义任务注释掉，还必须带上这个任务的`job`参数。我们将之前的`"print the variables when reboot"`和`"a job for reboot"`任务的`job`参数加上：

```yaml
- hosts: node1
  tasks:
    - name: Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration
      cron:
        name: NEW_APP_NAME
        env: yes
        value: New-Ansible-APP
        insertbefore: USERNAME
        
    - name: Removes "APP_NAME" environment variable from crontab
      cron:
        name: APP_NAME
        env: yes
        state: absent
        
    - name: Creates a cron file under /etc/cron.d/ with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
      become: yes

    - name: Creates a cron file under /etc/cron.d/ with ansible
      cron:
        name: sync time at every month first day 
        day: "1"
        minute: "0"
        hour: "12"
        user: ansible
        job: "sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
      become: yes
      
    - name: Creates a cron file under /etc/crontab with root
      cron:
        name: sync time at every Tuesday
        weekday: "2"
        minute: "0"
        hour: "12"
        user: root
        job: "ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: /etc/crontab
      become: yes
      
    - name: Disable a crontab task with state=present
      cron:
        name: "print the variables when reboot"
        disabled: yes
        state: present
        job: "sh /home/ansible/printcrontvariables.sh"            # 注意,增加了此行
        
    - name: Disable a crontab task with state=absent
      cron:
        name: "a job for reboot"
        disabled: yes
        state: absent
        job: "sh /home/ansible/cronjob.sh"                        # 注意,增加了此行

```

 此时运行,全部运行成功:

```sh
[ansible@master ~]$ vi cron.yml
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml

playbook: cron.yml
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Creates an entry like "NEW_APP_NAME=New-Ansible-APP" and insert it before USERNAME declaration] ************************************
ok: [node1] => {"changed": false, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Removes "APP_NAME" environment variable from crontab] ******************************************************************************
ok: [node1] => {"changed": false, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Creates a cron file under /etc/cron.d/ with root] **********************************************************************************
ok: [node1] => {"changed": false, "cron_file": "ansible_sync_time", "envs": [], "jobs": ["sync time at every Tuesday", "sync time at every month first day"]}

TASK [Creates a cron file under /etc/cron.d/ with ansible] *******************************************************************************
ok: [node1] => {"changed": false, "cron_file": "ansible_sync_time", "envs": [], "jobs": ["sync time at every Tuesday", "sync time at every month first day"]}

TASK [Creates a cron file under /etc/crontab with root] **********************************************************************************
ok: [node1] => {"changed": false, "cron_file": "/etc/crontab", "envs": ["SHELL", "PATH", "MAILTO"], "jobs": ["sync time at every Tuesday"]}

TASK [Disable a crontab task with state=present] *****************************************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["a job for reboot", "print the variables when reboot"]}

TASK [Disable a crontab task with state=absent] ******************************************************************************************
changed: [node1] => {"changed": true, "envs": ["ALIASNAME", "NEW_APP_NAME", "USERNAME"], "jobs": ["print the variables when reboot"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=8    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

最后我们来进行定时任务的检查工作:

首先,我们来看一下node1节点上ansible的定时任务:

```sh
[ansible@node1 ~]$ crontab -l
ALIASNAME="ansible-alias"
NEW_APP_NAME="New-Ansible-APP"
USERNAME="ansible"
#Ansible: print the variables when reboot
#* * * * * sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

可以看到:

- `NEW_APP_NAME="New-Ansible-APP"`变量被正常添加,并且`APP_NAME`变量被移除,虽然上面我们运行了几次剧本,可知,在定时任务的配置文件中如果没有对应的需要移除的变量,Ansible执行时也不会报错!
- `print the variables when reboot`这个定时任务被有效的注释掉了,说明通过`disabled: yes`配合`state: present`能够有效的将定时任务注释掉!
- `#Ansible: a job for reboot`和`@reboot sh /home/ansible/cronjob.sh`这两行不见了,说明通过`disabled: yes`配合`state: absent`时,会将任务删除,不会保留!

我们再来检查一下,在`/etc/cron.d/`文件夹和`/etc/crontab`文件中的定时任务。

```sh
[ansible@node1 ~]$ ls -lah /etc/cron.d
total 20K
drwxr-xr-x.  2 root root   46 Jul 15 15:01 .
drwxr-xr-x. 85 root root 8.0K Jul 15 11:23 ..
-rw-r--r--.  1 root root  128 Apr 11  2018 0hourly
-rw-r--r--   1 root root  210 Jul 15 15:05 ansible_sync_time
[ansible@node1 ~]$ cat /etc/cron.d/ansible_sync_time 
#Ansible: sync time at every Tuesday
0 12 * * 2 root ntpdate 182.92.12.11 |tee /tmp/synctime.log
#Ansible: sync time at every month first day
0 12 1 * * ansible sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log
[ansible@node1 ~]$ ls -lah /etc/crontab 
-rw-r--r--. 1 root root 548 Jul 15 15:05 /etc/crontab
[ansible@node1 ~]$ cat /etc/crontab 
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

#Ansible: sync time at every Tuesday
0 12 * * 2 root ntpdate 182.92.12.11 |tee /tmp/synctime.log
```

可以看到，在`/etc/cron.d/`文件夹和`/etc/crontab`文件中的定时任务对应的文件或文件夹的所有者/组都是`root:root，`并且在每条定时任务时都需要指定具体由哪个用户来执行该定时任务！

### 3.4 移除定时任务以及备份定时任务文件

当编写的剧本文件越来越长时，你可以使用ansible-lint[ansible-lint剧本文件检查工具](#ansible-lint剧本文件检查工具)对剧本文件进行检查，它会给出优化意见！

```sh
# 查看剧本文件
[ansible@master ~]$ cat cron.yml
- hosts: node1
  tasks:
    - name: absent a root cron in /etc/cron.d/
      cron:
        name: sync time at every Tuesday
        cron_file: ansible_sync_time
        state: absent
      become: yes

    - name: absent a ansible cron in /etc/cron.d/
      cron:
        name: sync time at every month first day
        job: "sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
        state: absent
      become: yes

    - name: absent a ansible cron in /etc/crontab after beckup the cron
      cron:
        name: sync time at every Tuesday
        cron_file: /etc/crontab
        backup: yes
        state: absent
      become: yes

# 剧本文件规范检查
[ansible@master ~]$ ansible-lint cron.yml

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml

playbook: cron.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook cron.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [absent a root cron in /etc/cron.d/] ************************************************************************************************
changed: [node1] => {"changed": true, "cron_file": "ansible_sync_time", "envs": [], "jobs": ["sync time at every month first day"]}

TASK [absent a ansible cron in /etc/cron.d/] *********************************************************************************************
changed: [node1] => {"changed": true, "cron_file": "ansible_sync_time", "envs": [], "jobs": []}

TASK [absent a ansible cron in /etc/crontab after beckup the cron] ***********************************************************************
changed: [node1] => {"backup_file": "/tmp/crontabIyc3lH", "changed": true, "cron_file": "/etc/crontab", "envs": ["SHELL", "PATH", "MAILTO"], "jobs": []}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到剧本正常执行!可以看到:

- `state: absent`删除定时任务时,可以不用指定`job`参数。

- 虽然Ansible删除了`cron_file: ansible_sync_time`中定义的定时任务，但是`ansible_sync_time`文件并不会自动删除。
- `backup: yes`参数可以指定备份定时任务，最后的`"backup_file": "/tmp/crontabIyc3lH"`是备份定时任务到`/tmp/crontabIyc3lH`文件中。

```sh
# 查看ansible用户的定时任务
[ansible@node1 ~]$ crontab -l
ALIASNAME="ansible-alias"
NEW_APP_NAME="New-Ansible-APP"
USERNAME="ansible"
#Ansible: print the variables when reboot
#* * * * * sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
# 查看/etc/crontab中的定时任务，定时任务已经被删除，只剩下原始的一些备注信息
[ansible@node1 ~]$ cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
[ansible@node1 ~]$ ls -lah /etc/crontab
-rw-r--r--. 1 root root 450 Jul 15 16:58 /etc/crontab
[ansible@node1 ~]$ cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
[ansible@node1 ~]$ 
# ansible_sync_time文件已经被清空，但文件仍然存在，并没有被自动删除
[ansible@node1 ~]$ ls -lah /etc/cron.d/
total 16K
drwxr-xr-x.  2 root root   46 Jul 15 15:01 .
drwxr-xr-x. 85 root root 8.0K Jul 15 11:23 ..
-rw-r--r--.  1 root root  128 Apr 11  2018 0hourly
-rw-r--r--   1 root root    0 Jul 15 16:58 ansible_sync_time
# ansible_sync_time 文件内容为空
[ansible@node1 ~]$ cat /etc/cron.d/ansible_sync_time 
[ansible@node1 ~]$ 
# 查看备份文件权限
[ansible@node1 ~]$ ls -lah /tmp/crontabIyc3lH
-rw------- 1 root root 548 Jul 15 16:58 /tmp/crontabIyc3lH
[ansible@node1 ~]$ cat /tmp/crontabIyc3lH
cat: /tmp/crontabIyc3lH: Permission denied
[ansible@node1 ~]$ 
# 查看备份文件内容
[ansible@node1 ~]$ sudo cat /tmp/crontabIyc3lH 
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

#Ansible: sync time at every Tuesday
0 12 * * 2 root ntpdate 182.92.12.11 |tee /tmp/synctime.log
[ansible@node1 ~]$ 
```

上面我们备份定时任务文件时，感觉Ansible是对整个备份文件进行备份的，而不是仅备份单独的一个定时任务。



我们来验证一下。

先看一下node1节点现在的定时任务情况：

```sh
[ansible@node1 tmp]$ crontab -l
ALIASNAME="ansible-alias"
NEW_APP_NAME="New-Ansible-APP"
USERNAME="ansible"
#Ansible: print the variables when reboot
#* * * * * sh /home/ansible/printcrontvariables.sh
```

再执行剧本：

```sh
# 编写剧本，包含五个任务
[ansible@master ~]$ cat cron.yml                             
- hosts: node1
  tasks:
    # 先进行备份，然后移除NEW_APP_NAME变量
    - name: Removes "NEW_APP_NAME" environment variable from crontab
      cron:
        name: NEW_APP_NAME
        env: yes
        backup: yes
        state: absent

    # 先进行备份，然后打开一个被注释的任务
    - name: enable a crontab task with state=present
      cron:
        name: "print the variables when reboot"
        special_time: reboot
        job: "sh /home/ansible/printcrontvariables.sh"
        backup: yes
        state: present

    # 先进行备份，然后添加一个任务
    - name: Creates an entry like "@reboot /home/ansible/cronjob.sh"
      cron:
        name: "a job for reboot"
        special_time: reboot
        job: "sh /home/ansible/cronjob.sh"
        backup: yes

    # 先进行备份，然后将任务注释掉
    - name: comment a ansible cron after beckup the cron
      cron:
        name: a job for reboot
        special_time: reboot
        job: "sh /home/ansible/cronjob.sh"
        backup: yes
        disabled: yes
        state: present

    # 先进行备份，然后将任务删除掉
    - name: delete a ansible cron after beckup the cron
      cron:
        name: a job for reboot
        backup: yes
        state: absent
[ansible@master ~]$ 
# 剧本文件规范检查
[ansible@master ~]$ ansible-lint cron.yml
[ansible@master ~]$ 
# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml 

playbook: cron.yml
[ansible@master ~]$ 
# 执行剧本
[ansible@master ~]$ ansible-playbook cron.yml -v             
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Removes "NEW_APP_NAME" environment variable from crontab] **************************************************************************
changed: [node1] => {"backup_file": "/tmp/crontab88jnxv", "changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": ["print the variables when reboot"]}

TASK [enable a crontab task with state=present] ******************************************************************************************
changed: [node1] => {"backup_file": "/tmp/crontabSbSxqg", "changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": ["print the variables when reboot"]}

TASK [Creates an entry like "@reboot /home/ansible/cronjob.sh"] **************************************************************************
changed: [node1] => {"backup_file": "/tmp/crontab3le2Zg", "changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": ["print the variables when reboot", "a job for reboot"]}

TASK [comment a ansible cron after beckup the cron] **************************************************************************************
changed: [node1] => {"backup_file": "/tmp/crontabfvfATL", "changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": ["print the variables when reboot", "a job for reboot"]}

TASK [delete a ansible cron after beckup the cron] ***************************************************************************************
changed: [node1] => {"backup_file": "/tmp/crontabCNWXqE", "changed": true, "envs": ["ALIASNAME", "USERNAME"], "jobs": ["print the variables when reboot"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们来依次分析上面的五个子任务。

先看任务1：`Removes "NEW_APP_NAME" environment variable from crontab`， 此任务是移除环境变量`NEW_APP_NAME`，正常执行，有一个备份文件`"backup_file": "/tmp/crontab88jnxv"`，我们看一下备份文件的内容：

```sh
[ansible@node1 ~]$ ls -lah /tmp/crontab88jnxv
-rw------- 1 ansible ansible 169 Jul 16 11:20 /tmp/crontab88jnxv
[ansible@node1 ~]$ cat /tmp/crontab88jnxv
ALIASNAME="ansible-alias"
NEW_APP_NAME="New-Ansible-APP"
USERNAME="ansible"
#Ansible: print the variables when reboot
#* * * * * sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

可以看到，初始的定时任务里面的内容全部备份了！



再看任务2：`enable a crontab task with state=present`，此任务想将注释掉的定时任务`print the variables when reboot`重新开启，正常执行，也有一个备份文件`"backup_file": "/tmp/crontabSbSxqg"`，我们看一下备份文件的内容：

```sh
[ansible@node1 ~]$ ls -lah /tmp/crontabSbSxqg
-rw------- 1 ansible ansible 138 Jul 16 11:20 /tmp/crontabSbSxqg
[ansible@node1 ~]$ cat /tmp/crontabSbSxqg
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
#* * * * * sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

可以看到备份内部刚好是任务1将`NEW_APP_NAME`环境变量移除后的内容。此任务会将旧的同名的定时任务移除，并重写添加一个新的定时任务！即并不是直接去掉注释的`#井号。后面再验证一下这个问题。



再看任务3：`Creates an entry like "@reboot /home/ansible/cronjob.sh"`创建一个重启时执行脚本的任务，正常执行，也有一个备份文件`"backup_file": "/tmp/crontab3le2Zg"`,我们看一下备份文件的内容：

```sh
[ansible@node1 ~]$ ls -lah /tmp/crontab3le2Zg
-rw------- 1 ansible ansible 135 Jul 16 11:20 /tmp/crontab3le2Zg
[ansible@node1 ~]$ cat /tmp/crontab3le2Zg
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

可以看到，此时的备份内容包含了任务2中打印定时任务变量的脚本的定时任务。此时还不能完全确定是对整个定时任务文件进行备份，因为此时还只是有一个定时任务。但是任务3会增加一个定时任务，因此执行任务3后就会有两个定时任务！我们需要再看一下任务4的备份文件。



再看任务4：`comment a ansible cron after beckup the cron`,此任务是将上面任务3定义的定时任务给注释掉，正常执行，也有一个备份文件`"backup_file": "/tmp/crontabfvfATL"`，我们看一下备份文件的内容：

```sh
[ansible@node1 ~]$ ls -lah /tmp/crontabfvfATL
-rw------- 1 ansible ansible 198 Jul 16 11:20 /tmp/crontabfvfATL
[ansible@node1 ~]$ cat /tmp/crontabfvfATL
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
#Ansible: a job for reboot
@reboot sh /home/ansible/cronjob.sh
[ansible@node1 ~]$ 
```

此时，可以看到，两个定时任务都正常备份了，也就是说，**备份的时候，是对整个备份文件进行备份的，不是对单独一个定时任务进行备份的！**执行完本任务，应该最后一行也会被注释掉。我们可以通过下个任务的备份文件检查一下。



再看任务5：`delete a ansible cron after beckup the cron`,此任务是将任务4中注释掉的定时任务删除掉，正常执行，也有一个备份文件`"backup_file": "/tmp/crontabCNWXqE"`,我们看一下备份文件的内容：

```sh
[ansible@node1 ~]$ ls -lah /tmp/crontabCNWXqE
-rw------- 1 ansible ansible 199 Jul 16 11:20 /tmp/crontabCNWXqE
[ansible@node1 ~]$ cat /tmp/crontabCNWXqE
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
#Ansible: a job for reboot
#@reboot sh /home/ansible/cronjob.sh
```

此时，可以看到任务4的定时任务已经被注释掉的。



最后，我们再看一下，最终生成的定时任务是什么样的：

```sh
[ansible@node1 ~]$ crontab -l
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

可以看到，`a job for reboot`定时任务已经被删除了，说明任务5起作用了！



### 3.5 将定时任务注释掉，不删除定时任务

我们删除上一节运行生成的定时任务信息：

```sh
[ansible@node1 ~]$ crontab -l
ALIASNAME="ansible-alias"
USERNAME="ansible"
#Ansible: print the variables when reboot
@reboot sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ crontab -r
[ansible@node1 ~]$ crontab -l
no crontab for ansible
[ansible@node1 ~]$ 
```



重新编写一个新的cron.yml定时任务剧本如下：

```yaml
- hosts: node1
  tasks:
    # 通过指定special_time参数，在重启时执行脚本，但最后将定时任务注释掉
    - name: comment a ansible cron
      cron:
        name: a job for reboot
        special_time: reboot
        job: "sh /home/ansible/cronjob.sh"
        disabled: yes
        state: present

    # 没有指定任务定时任务执行的时间，将定时任务注释掉
    - name: Disable a crontab task without special time
      cron:
        name: "print the variables without special time"
        job: "sh /home/ansible/printcrontvariables.sh"
        disabled: yes
        state: present

    # 指定任务定时任务执行的时间为2：00，将定时任务注释掉
    - name: Disable a crontab task at 2:00
      cron:
        hour: "2"
        minute: "0"
        name: "print the variables when 2:00"
        job: "sh /home/ansible/printcrontvariables.sh"
        disabled: yes
        state: present
```



运行剧本：

```sh
# 查看剧本文件
[ansible@master ~]$ cat cron.yml 
- hosts: node1
  tasks:
    # 通过指定special_time参数，在重启时执行脚本，但最后将定时任务注释掉
    - name: comment a ansible cron
      cron:
        name: a job for reboot
        special_time: reboot
        job: "sh /home/ansible/cronjob.sh"
        disabled: yes
        state: present

    # 没有指定任务定时任务执行的时间，将定时任务注释掉
    - name: Disable a crontab task without special time
      cron:
        name: "print the variables without special time"
        job: "sh /home/ansible/printcrontvariables.sh"
        disabled: yes
        state: present

    # 指定任务定时任务执行的时间为2：00，将定时任务注释掉
    - name: Disable a crontab task at 2:00
      cron:
        hour: "2"
        minute: "0"
        name: "print the variables when 2:00"
        job: "sh /home/ansible/printcrontvariables.sh"
        disabled: yes
        state: present
[ansible@master ~]$
# 剧本规范性检查
[ansible@master ~]$ ansible-lint cron.yml
# 剧本语法检查
[ansible@master ~]$ ansible-playbook --syntax-check cron.yml 

playbook: cron.yml
[ansible@master ~]$

# 执行剧本
[ansible@master ~]$ ansible-playbook cron.yml -v             
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [comment a ansible cron] ************************************************************************************************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["a job for reboot"]}

TASK [Disable a crontab task without special time] ***************************************************************************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["a job for reboot", "print the variables without special time"]}

TASK [Disable a crontab task at 2:00] ****************************************************************************************************
changed: [node1] => {"changed": true, "envs": [], "jobs": ["a job for reboot", "print the variables without special time", "print the variables when 2:00"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

查看node1节点上的定时任务：

```sh
[ansible@node1 ~]$ crontab -l
#Ansible: a job for reboot
#@reboot sh /home/ansible/cronjob.sh
#Ansible: print the variables without special time
#* * * * * sh /home/ansible/printcrontvariables.sh
#Ansible: print the variables when 2:00
#0 2 * * * sh /home/ansible/printcrontvariables.sh
[ansible@node1 ~]$ 
```

通过本次实验可以看到：

- 使用`disabled: yes`和`state: present`注释定时任务时，会在定时任务前面增加一个`#`井号。
- 如果不指定执行时间，则定时任务会取默认值，即`* * * * *`,所有定时任务应尽可能的明确定时任务的执行时间。

## 4. 返回值

官方文档里面没有明确返回值，通过上一节的实验，我们可以总结出以下返回值。

| 键            | 是否返回   | 描述                                                         |
| ------------- | ---------- | ------------------------------------------------------------ |
| `jobs`        | 一直返回   | `list`，在远程主机上面存在的定时任务列表,如`"jobs": ["print the variables when reboot", "a job for reboot"]` |
| `envs`        | 一直返回   | `list`,环境变量列表，如`"envs": ["ALIASNAME", "USERNAME"]`   |
| `backup_file` | 备份时返回 | `string`,备份文件的路径，如`"backup_file": "/tmp/crontabfvfATL"` |

