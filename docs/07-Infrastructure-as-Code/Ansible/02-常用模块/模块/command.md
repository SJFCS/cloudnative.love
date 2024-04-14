# Command命令模块

[[toc]]



`command`模块在主机上面执行命令。

- `command`模块获取以空格分隔的列表组成的命令。
- 所指定的命令会在所有选择的主机上面执行。
- 不能处理shell命令，不能使用`$HOME`以及重定向(`>`，`<`)、管道(`|`)、分号(`;`)、And符号(`&`)等。此时应使用`shell`模块。
- 要创建比使用空格分隔的参数更易于阅读的命令任务，请使用`args`任务关键字传递参数或使用`cmd`参数。
- 自由格式命令或cmd参数是必须的。

command模块的帮助文档：[https://docs.ansible.com/ansible/latest/modules/command_module.html](https://docs.ansible.com/ansible/latest/modules/command_module.html)

command模块的源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/command.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/command.py)

获取帮助信息：

```sh
[ansible@master ~]$ ansible-doc -s command   
- name: Execute commands on targets
  command:
      argv:                  # Passes the command as a list rather than a string. Use `argv' to avoid quoting values that would
                               otherwise be interpreted incorrectly (for example "user name"). Only the
                               string or the list form can be provided, not both.  One or the other must
                               be provided.
      chdir:                 # Change into this directory before running the command.
      cmd:                   # The command to run.
      creates:               # A filename or (since 2.0) glob pattern. If it already exists, this step *won't* be run.
      free_form:             # The command module takes a free form command to run. There is no actual parameter named 'free form'.
      removes:               # A filename or (since 2.0) glob pattern. If it already exists, this step *will* be run.
      stdin:                 # Set the stdin of the command directly to the specified value.
      stdin_add_newline:     # If set to `yes', append a newline to stdin data.
      strip_empty_ends:      # Strip empty lines from the end of stdout/stderr in result.
      warn:                  # Enable or disable task warnings.
      
[ansible@master ~]$ ansible-doc command
> COMMAND    (/usr/lib/python2.7/site-packages/ansible/modules/commands/command.py)

        The `command' module takes the command name followed by a list of space-delimited arguments. The
        given command will be executed on all selected nodes. The command(s) will not be processed through
        the shell, so variables like `$HOME' and operations like `"<"', `">"', `"|"', `";"' and `"&"' will
        not work. Use the [shell] module if you need these features. To create `command' tasks that are
        easier to read than the ones using space-delimited arguments, pass parameters using the `args' L(task
        keyword,../reference_appendices/playbooks_keywords.html#task) or use `cmd' parameter. Either a free
        form command or `cmd' parameter is required, see the examples. For Windows targets, use the
        [win_command] module instead.

  * This module is maintained by The Ansible Core Team
  * note: This module has a corresponding action plugin.

OPTIONS (= is mandatory):

- argv
        Passes the command as a list rather than a string.
        Use `argv' to avoid quoting values that would otherwise be interpreted incorrectly (for example "user
        name").
        Only the string or the list form can be provided, not both.  One or the other must be provided.
        [Default: (null)]
        type: list
        version_added: 2.6

- chdir
        Change into this directory before running the command.
        [Default: (null)]
        type: path
        version_added: 0.6

- cmd
        The command to run.
        [Default: (null)]
        type: str

- creates
        A filename or (since 2.0) glob pattern. If it already exists, this step *won't* be run.
        [Default: (null)]
        type: path

- free_form
        The command module takes a free form command to run.
        There is no actual parameter named 'free form'.
        [Default: (null)]

- removes
        A filename or (since 2.0) glob pattern. If it already exists, this step *will* be run.
        [Default: (null)]
        type: path
        version_added: 0.8

- stdin
        Set the stdin of the command directly to the specified value.
        [Default: (null)]
        version_added: 2.4

- stdin_add_newline
        If set to `yes', append a newline to stdin data.
        [Default: True]
        type: bool
        version_added: 2.8

- strip_empty_ends
        Strip empty lines from the end of stdout/stderr in result.
        [Default: True]
        type: bool
        version_added: 2.8

- warn
        Enable or disable task warnings.
        [Default: True]
        type: bool
        version_added: 1.8


NOTES:
      * If you want to run a command through the shell (say you are using `<', `>', `|', etc), you
        actually want the [shell] module instead. Parsing shell metacharacters can lead to unexpected
        commands being executed if quoting is not done correctly so it is more secure to use the
        `command' module when possible.
      *  `creates', `removes', and `chdir' can be specified after the command. For instance, if you
        only want to run a command if a certain file does not exist, use this.
      * Check mode is supported when passing `creates' or `removes'. If running in check mode and
        either of these are specified, the module will check for the existence of the file and report
        the correct changed status. If these are not supplied, the task will be skipped.
      * The `executable' parameter is removed since version 2.4. If you have a need for this parameter,
        use the [shell] module instead.
      * For Windows targets, use the [win_command] module instead.
      * For rebooting systems, use the [reboot] or [win_reboot] module.


SEE ALSO:
      * Module raw
           The official documentation on the raw module.
           https://docs.ansible.com/ansible/2.9/modules/raw_module.html
      * Module script
           The official documentation on the script module.
           https://docs.ansible.com/ansible/2.9/modules/script_module.html
      * Module shell
           The official documentation on the shell module.
           https://docs.ansible.com/ansible/2.9/modules/shell_module.html
      * Module win_command
           The official documentation on the win_command module.
           https://docs.ansible.com/ansible/2.9/modules/win_command_module.html


AUTHOR: Ansible Core Team, Michael DeHaan
        METADATA:
          status:
          - stableinterface
          supported_by: core
        

EXAMPLES:

- name: return motd to registered var
  command: cat /etc/motd
  register: mymotd

- name: Run command if /path/to/database does not exist (without 'args' keyword).
  command: /usr/bin/make_database.sh db_user db_name creates=/path/to/database

# 'args' is a task keyword, passed at the same level as the module
- name: Run command if /path/to/database does not exist (with 'args' keyword).
  command: /usr/bin/make_database.sh db_user db_name
  args:
    creates: /path/to/database

# 'cmd' is module parameter
- name: Run command if /path/to/database does not exist (with 'cmd' parameter).
  command:
    cmd: /usr/bin/make_database.sh db_user db_name
    creates: /path/to/database

- name: Change the working directory to somedir/ and run the command as db_owner if /path/to/database does not exist.
  command: /usr/bin/make_database.sh db_user db_name
  become: yes
  become_user: db_owner
  args:
    chdir: somedir/
    creates: /path/to/database

# 'argv' is a parameter, indented one level from the module
- name: Use 'argv' to send a command as a list - leave 'command' empty
  command:
    argv:
      - /usr/bin/make_database.sh
      - Username with whitespace
      - dbname with whitespace

- name: safely use templated variable to run command. Always use the quote filter to avoid injection issues.
  command: cat {{ myfile|quote }}
  register: myoutput


RETURN VALUES:

cmd:
  description: the cmd that was run on the remote machine
  returned: always
  type: list
  sample:
  - echo
  - hello
delta:
  description: cmd end time - cmd start time
  returned: always
  type: str
  sample: 0:00:00.001529
end:
  description: cmd end time
  returned: always
  type: str
  sample: '2017-09-29 22:03:48.084657'
start:
  description: cmd start time
  returned: always
  type: str
  sample: '2017-09-29 22:03:48.083128'
```

从command模块的官方文档[https://docs.ansible.com/ansible/latest/modules/command_module.html](https://docs.ansible.com/ansible/latest/modules/command_module.html)中可以看出，此时使用了大量的playbook剧本做为示例。

## 1. command模块参数

| 参数                | 可选值 | 默认值 | 说明                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------- | ------ | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `argv`              |        |        | `list`，将命令作为列表而不是字符串传递。使用`argv`避免引用否则会被错误解释的值（例如“用户名”）。只能提供字符串或列表形式，不能同时提供。                                                                                                                                                                                                                                               |
| `chdir`             |        |        | `path`，在执行命令前切换到指定的工作目录，类似于使用`cd`命令切换`working directory`工作目录                                                                                                                                                                                                                                                                                            |
| `cmd`               |        |        | `string`，需要运行的命令                                                                                                                                                                                                                                                                                                                                                               |
| `creates`           |        |        | `path`，文件名或glob模式，如果对应的文件存在，则忽略此步<br />A filename or (since 2.0) glob pattern. If a matching file already exists, this step **will not** be run.<br />This is checked before *removes* is checked.                                                                                                                                                              |
| `free_form`         |        |        | 自由形式运行，可执行任何linux命令，**该参数实际不存在!!**.比如，当我们想要在远程主机上执行ls命令时，我们并不需要写成`free_form=ls`，这样写反而是错误的，因为并没有任何参数的名字是`free_form`，当我们想要在远程主机中执行`ls`命令时，直接写成`ls`即可，这就是`free_form`参数的含义，因为`command`模块的作用是执行命令，所以，任何一个可以在远程主机上执行的命令都可以被称为`free_form` |
| `removes`           |        |        | `path`，文件名或glob模式，如果对应的文件存在，则执行此步<br />A filename or (since 2.0) glob pattern. If a matching file exists, this step **will** be run.<br />This is checked after *creates* is checked.                                                                                                                                                                           |
| `stdin`             |        |        | `path`, 将指定路径设置为标准输入                                                                                                                                                                                                                                                                                                                                                       |
| `stdin_add_newline` | yes/no | yes    | `boolean`,如果设置`yes`，则会在标准输入后面增加一行                                                                                                                                                                                                                                                                                                                                    |
| `strip_empty_ends`  | yes/no | yes    | `boolean`,如果设置`yes`，则会移除标准输入/标准错误最后的空行                                                                                                                                                                                                                                                                                                                           |
| `warn`              | yes/no | yes    | `boolean`,如果设置`yes`，则会警告，在`2.14`版本会移除该参数                                                                                                                                                                                                                                                                                                                            |

## 2. command模块返回值

| 键      | 是否返回 | 描述                                 |
| ------- | -------- | ------------------------------------ |
| `cmd`   | 一直返回 | `list`，在远程主机上面执行的命令列表 |
| `start` | 一直返回 | `string`,命令开始时间                |
| `end`   | 一直返回 | `string`,命令结束时间                |
| `delta` | 一直返回 | `string`,命令运行时间                |

## 3. 执行剧本

为了便于测试，我们仅在一个节点(node1)上面执行剧本。

### 3.1 剧本文件语法检查、彩排和运行

```sh
# 查看剧本文件内容
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: test command
      command: head /etc/passwd

# 检查剧本文件语法是否正确
[ansible@master ~]$ ansible-playbook --syntax-check command.yml

playbook: command.yml

# 检查剧本文件语法检查的返回值
[ansible@master ~]$ echo $?
0

# 剧本彩排
[ansible@master ~]$ ansible-playbook -C command.yml

PLAY [node1] ****************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]

TASK [test command] *********************************************************************************************************************
skipping: [node1]

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

# 剧本彩排时查看详细信息
[ansible@master ~]$ ansible-playbook -C command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ****************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]

TASK [test command] *********************************************************************************************************************
skipping: [node1] => {"changed": false, "msg": "skipped, running in check mode"}

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

# 执行剧本
[ansible@master ~]$ ansible-playbook command.yml

PLAY [node1] ****************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]

TASK [test command] *********************************************************************************************************************
changed: [node1]

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

# 执行剧本时查看详细信息
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ****************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]

TASK [test command] *********************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["head", "/etc/passwd"], "delta": "0:00:00.001954", "end": "2020-07-03 15:58:49.030042", "rc": 0, "start": "2020-07-03 15:58:49.028088", "stderr": "", "stderr_lines": [], "stdout": "root:x:0:0:root:/root:/bin/bash\nbin:x:1:1:bin:/bin:/sbin/nologin\ndaemon:x:2:2:daemon:/sbin:/sbin/nologin\nadm:x:3:4:adm:/var/adm:/sbin/nologin\nlp:x:4:7:lp:/var/spool/lpd:/sbin/nologin\nsync:x:5:0:sync:/sbin:/bin/sync\nshutdown:x:6:0:shutdown:/sbin:/sbin/shutdown\nhalt:x:7:0:halt:/sbin:/sbin/halt\nmail:x:8:12:mail:/var/spool/mail:/sbin/nologin\noperator:x:11:0:operator:/root:/sbin/nologin", "stdout_lines": ["root:x:0:0:root:/root:/bin/bash", "bin:x:1:1:bin:/bin:/sbin/nologin", "daemon:x:2:2:daemon:/sbin:/sbin/nologin", "adm:x:3:4:adm:/var/adm:/sbin/nologin", "lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin", "sync:x:5:0:sync:/sbin:/bin/sync", "shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown", "halt:x:7:0:halt:/sbin:/sbin/halt", "mail:x:8:12:mail:/var/spool/mail:/sbin/nologin", "operator:x:11:0:operator:/root:/sbin/nologin"]}

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

#### 3.1.1 命令添加其他参数

```sh
# 增加-n 1参数，仅显示第一行的内容
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: test command
      command: head /etc/passwd -n 1
 
# 执行剧本
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [test command] ****************************************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["head", "/etc/passwd", "-n", "1"], "delta": "0:00:00.001891", "end": "2020-07-03 16:20:49.416730", "rc": 0, "start": "2020-07-03 16:20:49.414839", "stderr": "", "stderr_lines": [], "stdout": "root:x:0:0:root:/root:/bin/bash", "stdout_lines": ["root:x:0:0:root:/root:/bin/bash"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

#### 3.1.2 增加`creates`参数，如果文件存在则不会执行命令

```sh
# 在command: 命令的后面增加了`creates=/tmp/check.txt`参数
[ansible@master ~]$ cat command.yml 
- hosts: node1
  tasks:
    - name: test command
      command: head /etc/passwd -n 1 creates=/tmp/check.txt

# 此时没有手动在node1上面创建/tmp/check.txt文件，执行剧本能够正常执行
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [test command] ****************************************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["head", "/etc/passwd", "-n", "1"], "delta": "0:00:00.001889", "end": "2020-07-03 16:28:37.486499", "rc": 0, "start": "2020-07-03 16:28:37.484610", "stderr": "", "stderr_lines": [], "stdout": "root:x:0:0:root:/root:/bin/bash", "stdout_lines": ["root:x:0:0:root:/root:/bin/bash"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

# 手动在node1上面创建/tmp/check.txt文件后，再执行剧本，执行剧本时[test command]任务被忽略，并没有查看到/etc/passwd第一行的内容
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [test command] ****************************************************************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["head", "/etc/passwd", "-n", "1"], "rc": 0, "stdout": "skipped, since /tmp/check.txt exists", "stdout_lines": ["skipped, since /tmp/check.txt exists"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

#### 3.1.3 同时执行多个任务

```sh
# 定义检查文件夹是否存在，并且增加一个任务，现在是两个任务
# test check folder任务检查/tmp目录是否存在
# test glob pattern任务使用通配符检查/*bin/目录是否存在
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: test check folder 
      command: head /etc/passwd -n 1 creates=/tmp/
    - name: test glob pattern 
      command: head /etc/passwd -n 1 creates=/*bin/

# 由于/tmp目录和/*bin/目录（如/bin/,/sbin/目录）都存在，两个任务都被忽略掉
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [test check folder] ***********************************************************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["head", "/etc/passwd", "-n", "1"], "rc": 0, "stdout": "skipped, since /tmp/ exists", "stdout_lines": ["skipped, since /tmp/ exists"]}

TASK [test glob pattern] ***********************************************************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["head", "/etc/passwd", "-n", "1"], "rc": 0, "stdout": "skipped, since /*bin/ exists", "stdout_lines": ["skipped, since /*bin/ exists"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

#### 3.1.4  使用`args`任务关键字和`cmd`模块参数

```sh
# 定义了两个任务
# 一个使用tasks的args关键字来定义模块参数
# 另一个使用command模块自带的参数来定义参数
[ansible@master ~]$ cat command.yml 
- hosts: node1
  tasks:
    - name: Run command if /tmp/ does not exist (with 'args' keyword)
      command: head /etc/passwd -n 1 
      args:
        creates: /tmp/
    - name: Run command if /*bin/ does not exist (with 'cmd' parameter).
      command: 
        cmd: head /etc/passwd -n 1
        creates: /*bin/
[ansible@master ~]$

# 语法检查
[ansible@master ~]$ ansible-playbook --syntax-check command.yml 

playbook: command.yml
[ansible@master ~]$ echo $?
0

# 执行剧本
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [Run command if /tmp/ does not exist (with 'args' keyword)] *******************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["head", "/etc/passwd", "-n", "1"], "rc": 0, "stdout": "skipped, since /tmp/ exists", "stdout_lines": ["skipped, since /tmp/ exists"]}

TASK [Run command if /*bin/ does not exist (with 'cmd' parameter).] ****************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["head", "/etc/passwd", "-n", "1"], "rc": 0, "stdout": "skipped, since /*bin/ exists", "stdout_lines": ["skipped, since /*bin/ exists"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```

#### 3.1.5  使用`chdir`改变工作路径以及`argv`增加命令列表

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: Change the working directory to somedir 
      command: pwd 
      args:
        chdir: /tmp
    - name: Use 'argv' to send a command as a list - leave 'command' empty
      command:
        argv:
          - head
          - /etc/passwd
          - -n
          - 1  
        creates: /tmp/noexist
[ansible@master ~]$ ansible-playbook --syntax-check command.yml

playbook: command.yml
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [node1]

TASK [Change the working directory to somedir] *************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["pwd"], "delta": "0:00:00.001942", "end": "2020-07-03 17:41:50.181044", "rc": 0, "start": "2020-07-03 17:41:50.179102", "stderr": "", "stderr_lines": [], "stdout": "/tmp", "stdout_lines": ["/tmp"]}

TASK [Use 'argv' to send a command as a list - leave 'command' empty] **************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["head", "/etc/passwd", "-n", "1"], "delta": "0:00:00.001922", "end": "2020-07-03 17:41:50.399622", "rc": 0, "start": "2020-07-03 17:41:50.397700", "stderr": "", "stderr_lines": [], "stdout": "root:x:0:0:root:/root:/bin/bash", "stdout_lines": ["root:x:0:0:root:/root:/bin/bash"]}

PLAY RECAP *************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到第一个任务的标准输出是`/tmp`，说明工作目录已经正常切换到`/tmp`目录下。第二个任务中通过使用`argv`来定义任务列表，这样使得命令执行更加安全，可以避免Shell注入攻击。

#### 3.1.6 注册变量和打印

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: Use 'argv' to send a command as a list - leave 'command' empty
      command:
        argv:
          - head
          - /etc/passwd
          - -n
          - 1  
        creates: /tmp/noexist
      register: password
    - name: echo register variable
      command: echo "{{ password }}"
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [node1]

TASK [Use 'argv' to send a command as a list - leave 'command' empty] ***************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["head", "/etc/passwd", "-n", "1"], "delta": "0:00:00.001991", "end": "2020-07-06 15:59:46.843148", "rc": 0, "start": "2020-07-06 15:59:46.841157", "stderr": "", "stderr_lines": [], "stdout": "root:x:0:0:root:/root:/bin/bash", "stdout_lines": ["root:x:0:0:root:/root:/bin/bash"]}

TASK [echo register variable] *******************************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["echo", "{'stderr_lines': [], u'changed': True, u'end': u'2020-07-06 15:59:46.843148', 'failed': False, u'stdout': u'root:x:0:0:root:/root:/bin/bash', u'cmd': [u'head', u'/etc/passwd', u'-n', u'1'], u'rc': 0, u'start': u'2020-07-06 15:59:46.841157', u'stderr': u'', u'delta': u'0:00:00.001991', 'stdout_lines': [u'root:x:0:0:root:/root:/bin/bash']}"], "delta": "0:00:00.002853", "end": "2020-07-06 15:59:47.098440", "rc": 0, "start": "2020-07-06 15:59:47.095587", "stderr": "", "stderr_lines": [], "stdout": "{'stderr_lines': [], u'changed': True, u'end': u'2020-07-06 15:59:46.843148', 'failed': False, u'stdout': u'root:x:0:0:root:/root:/bin/bash', u'cmd': [u'head', u'/etc/passwd', u'-n', u'1'], u'rc': 0, u'start': u'2020-07-06 15:59:46.841157', u'stderr': u'', u'delta': u'0:00:00.001991', 'stdout_lines': [u'root:x:0:0:root:/root:/bin/bash']}", "stdout_lines": ["{'stderr_lines': [], u'changed': True, u'end': u'2020-07-06 15:59:46.843148', 'failed': False, u'stdout': u'root:x:0:0:root:/root:/bin/bash', u'cmd': [u'head', u'/etc/passwd', u'-n', u'1'], u'rc': 0, u'start': u'2020-07-06 15:59:46.841157', u'stderr': u'', u'delta': u'0:00:00.001991', 'stdout_lines': [u'root:x:0:0:root:/root:/bin/bash']}"]}

PLAY RECAP **************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

使用`register`关键字来注册变量，`{{ variable }}`来输出变量。

#### 3.1.7 测试free_form参数

Ansible实际上并没有`free_form`参数的。我们如果使用`free_form`参数反而会出错：

```sh
[ansible@master ~]$ ansible node1 -m command -a "ls -lah"
node1 | CHANGED | rc=0 >>
total 16K
drwx------  5 ansible ansible 123 Jun 28 11:31 .
drwxr-xr-x. 4 root    root     39 Jun 15 11:28 ..
drwx------  3 ansible ansible  17 Jun 15 12:42 .ansible
-rw-------  1 ansible ansible 379 Jun 15 17:33 .bash_history
-rw-r--r--  1 ansible ansible  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 ansible ansible 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 ansible ansible 231 Oct 31  2018 .bashrc
drwxrw----  3 ansible ansible  19 Jun 28 11:31 .pki
drwx------  2 ansible ansible  61 Jun 15 12:00 .ssh
[ansible@master ~]$ ansible node1 -m command -a "free_form=ls -lah"
node1 | FAILED | rc=2 >>
[Errno 2] No such file or directory
[ansible@master ~]$ 
```

#### 3.1.8 使用`removes`参数检查文件是否存在，存在则执行任务

```sh
[ansible@master ~]$ ansible node1 -m command -a "removes=/tmp pwd"
node1 | CHANGED | rc=0 >>
/home/ansible
[ansible@master ~]$ ansible node1 -m command -a "removes=/tmp1 pwd"
node1 | SUCCESS | rc=0 >>
skipped, since /tmp1 does not exist
```

可以发现`/tmp`路径存在，执行了命令`pwd`，而`/tmp1`路径不存在，没有执行命令`pwd`。

我们使用剧本运行测试一下：

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: Use 'removes' to check file exist and run command
      command:
        argv:
          - pwd
        removes: /tmp
    - name: Use 'removes' to check file not exist and not run command
      command:
        argv:
          - pwd
        removes: /tmp1

[ansible@master ~]$ ansible-playbook --syntax-check command.yml

playbook: command.yml
[ansible@master ~]$ ansible-playbook  command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [node1]

TASK [Use 'removes' to check file exist and run command] ****************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["pwd"], "delta": "0:00:00.001866", "end": "2020-07-07 10:30:24.894153", "rc": 0, "start": "2020-07-07 10:30:24.892287", "stderr": "", "stderr_lines": [], "stdout": "/home/ansible", "stdout_lines": ["/home/ansible"]}

TASK [Use 'removes' to check file not exist and not run command] ********************************************************************************************
ok: [node1] => {"changed": false, "cmd": ["pwd"], "rc": 0, "stdout": "skipped, since /tmp1 does not exist", "stdout_lines": ["skipped, since /tmp1 does not exist"]}

PLAY RECAP **************************************************************************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以发现`/tmp`路径存在，执行了命令`pwd`，而`/tmp1`路径不存在，没有执行命令`pwd`。`removes`参数与`creates`参数刚好相反。

#### 3.1.9 `stdin`与`stdin_add_newline`标准输入设置

可以参考[https://www.stacknoob.com/s/5TsgVmKHFN4fn8qfn8V3gV](https://www.stacknoob.com/s/5TsgVmKHFN4fn8qfn8V3gV)和[How to use command stdin in Ansible?](https://www.thetopsites.net/article/53108954.shtml) 的指导设置`stdin`参数。

> If you want to use the `stdin` argument to the `command` module, take a look at [the docs](https://docs.ansible.com/ansible/2.7/modules/command_module.html), which show examples using other options such as `creates`, which looks like this:
>
> ```
> # You can also use the 'args' form to provide the options.
> - name: This command will change the working directory to somedir/ and will only run when /path/to/database doesn't exist.
>   command: /usr/bin/make_database.sh arg1 arg2
>   args:
>     chdir: somedir/
>     creates: /path/to/database
> ```
>
> For your use case, you would want:
>
> ```
> - name: Log into Docker registry
>   command: docker login --username "{{ docker_registry_username }}" --password-stdin
>   args:
>     stdin: "{{ docker_registry_password }}"
> ```
>
> Your first attempt failed because you were setting `stdin` as a key at the task level (like `when` or `ignore_errors`, etc), when you actually want it to be an argument to the `command` module.
>
> Your second attempt failed because it wasn't valid YAML.
>
> **command – Execute commands on targets,**  see the examples.  For Windows targets, use the win_command module instead.  added in 2.4.  Set the stdin of the command directly to the specified value. raw –  Executes a low-down and dirty command. The official documentation on the  raw module. script – Runs a local script on a remote node after  transferring it. The official documentation on the script module. shell –  Execute shell commands on targets. The official documentation on the  shell module. 

参照上面的例子进行docker hub登陆。

- 主机清单配置

增加`docker-node`节点

```sh
[ansible@master ~]$ cat /etc/ansible/hosts
node3
docker-node ansible_host=192.168.12.98 ansible_port=10089 ansible_user=meizhaohui ansible_password=securepasswd ansible_python_interpreter=/usr/bin/python3.6

[webservers]
node1

[dbservers]
node2
```

- 修改剧本文件

```sh
[ansible@master ~]$ cat command.yml
- hosts: docker-node
  vars:
    docker_registry_username: meizhaohui
    docker_registry_password: securedockerpassword
  tasks:
    - name: print variables
      command: echo username:{{ docker_registry_username }} password:{{ docker_registry_password }} 
    - name: Use 'stdin' to change the standard input
      command: docker login --username {{ docker_registry_username }} --password-stdin
      become: yes
      args:
        stdin: "{{ docker_registry_password }}"
[ansible@master ~]$ 
```

- 语法检查后执行脚本

```sh
[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [docker-node] ***********************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [docker-node]

TASK [print variables] *******************************************************************************************************************
changed: [docker-node] => {"changed": true, "cmd": ["echo", "username:meizhaohui", "password:securedockerpassword"], "delta": "0:00:00.002726", "end": "2020-07-07 17:09:24.553348", "rc": 0, "start": "2020-07-07 17:09:24.550622", "stderr": "", "stderr_lines": [], "stdout": "username:meizhaohui password:securedockerpassword", "stdout_lines": ["username:meizhaohui password:securedockerpassword"]}

TASK [Use 'stdin' to change the standard input] ******************************************************************************************
changed: [docker-node] => {"changed": true, "cmd": ["docker", "login", "--username", "meizhaohui", "--password-stdin"], "delta": "0:00:04.427198", "end": "2020-07-07 17:09:29.360092", "rc": 0, "start": "2020-07-07 17:09:24.932894", "stderr": "WARNING! Your password will be stored unencrypted in /root/.docker/config.json.\nConfigure a credential helper to remove this warning. See\nhttps://docs.docker.com/engine/reference/commandline/login/#credentials-store", "stderr_lines": ["WARNING! Your password will be stored unencrypted in /root/.docker/config.json.", "Configure a credential helper to remove this warning. See", "https://docs.docker.com/engine/reference/commandline/login/#credentials-store"], "stdout": "Login Succeeded", "stdout_lines": ["Login Succeeded"]}

PLAY RECAP *******************************************************************************************************************************
docker-node                : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```

注意，本例中通过`vars`中定义了两个变量`docker_registry_username`和`docker_registry_password`,指定登陆docker hub的用户名和密码，参考[ansible各种变量定义及引用](https://www.cnblogs.com/deny/p/12394956.html)。将密码直接写在剧本文件中比较危险，应该考虑使用`Ansible Vault`对密码进行加密,想了解Ansible Vault,请参考[https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault)。

默认`stdin_add_newline`为`yes`，即在标准输入最后添加一个换行符，保持默认即可，不需要特别设置。

#### 3.1.10 `strip_empty_ends`移除标准输出、标准异常最后的空行

Ansible默认会移除标准输出、标准异常最后的空行的。当指定`strip_empty_ends: no`时就不会移除最后的空行。

```sh
# 查看剧本文件，默认ansible配置strip_empty_ends参数为yes，如果不需要移除标准输出、标准异常最后的空行则需要设置strip_empty_ends: no
[ansible@master ~]$ cat command.yml 
- hosts: node1
  tasks:
    - name: check empty endlines
      command: echo -e "auto remove empty endlines\n\n\n"

    - name: remove empty endlines
      command: echo -e "remove empty endlines\n\n\n"
      args:
        strip_empty_ends: yes

    - name: not remove empty endlines
      command: echo -e "not remove empty endlines\n\n\n"
      args:
        strip_empty_ends: no
[ansible@master ~]$ ansible-playbook --syntax-check command.yml 

playbook: command.yml
[ansible@master ~]$ ansible-playbook command.yml -v             
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check empty endlines] **************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["echo", "-e", "auto remove empty endlines\\n\\n\\n"], "delta": "0:00:00.003001", "end": "2020-07-09 14:46:22.406998", "rc": 0, "start": "2020-07-09 14:46:22.403997", "stderr": "", "stderr_lines": [], "stdout": "auto remove empty endlines", "stdout_lines": ["auto remove empty endlines"]}

TASK [remove empty endlines] *************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["echo", "-e", "remove empty endlines\\n\\n\\n"], "delta": "0:00:00.001790", "end": "2020-07-09 14:46:22.631634", "rc": 0, "start": "2020-07-09 14:46:22.629844", "stderr": "", "stderr_lines": [], "stdout": "remove empty endlines", "stdout_lines": ["remove empty endlines"]}

TASK [not remove empty endlines] *********************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["echo", "-e", "not remove empty endlines\\n\\n\\n"], "delta": "0:00:00.001926", "end": "2020-07-09 14:46:22.854994", "rc": 0, "start": "2020-07-09 14:46:22.853068", "stderr": "", "stderr_lines": [], "stdout": "not remove empty endlines\n\n\n\n", "stdout_lines": ["not remove empty endlines", "", "", ""]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，当不进行最后的空行移除时，标准输出时`"stdout_lines": ["not remove empty endlines", "", "", ""]`，说明最后的三个空行没有被移除。

**需要注意的是，如果结尾行中不是空行，而是由空格或`Tab`键组成的内容，也不会被移除，这种行不会被当作空行！**



#### 3.1.11 Ansible警告`warn`设置

在ansible配置文件`/etc/ansible/ansible.cfg `中可以看到以下内容：

```
# by default (as of 1.6), Ansible may display warnings based on the configuration of the
# system running ansible itself. This may include warnings about 3rd party packages or
# other conditions that should be resolved if possible.
# to disable these warnings, set the following value to False:
#system_warnings = True

# by default (as of 1.4), Ansible may display deprecation warnings for language
# features that should no longer be used and will be removed in future versions.
# to disable these warnings, set the following value to False:
#deprecation_warnings = True

# (as of 1.8), Ansible can optionally warn when usage of the shell and
# command module appear to be simplified by using a default Ansible module
# instead.  These warnings can be silenced by adjusting the following
# setting or adding warn=yes or warn=no to the end of the command line
# parameter string.  This will for example suggest using the git module
# instead of shelling out to the git command.
# command_warnings = False
```

Ansible默认开启命令异常的提示。

我们此时测试一下，在剧本中添加`warn`参数来查看警告输出。

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: check open warning
      command: sudo df /home
      args:
        warn: yes

    - name: check default warn
      command: sudo df /home

    - name: check close warning
      command: sudo df /home
      args:
        warn: no

[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check open warning] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009139", "end": "2020-07-09 17:21:13.923260", "rc": 0, "start": "2020-07-09 17:21:13.914121", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140356  15671100  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140356  15671100  13% /"]}

TASK [check default warn] ****************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009198", "end": "2020-07-09 17:21:14.148510", "rc": 0, "start": "2020-07-09 17:21:14.139312", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140356  15671100  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140356  15671100  13% /"]}

TASK [check close warning] ***************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009688", "end": "2020-07-09 17:21:14.373148", "rc": 0, "start": "2020-07-09 17:21:14.363460", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140356  15671100  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140356  15671100  13% /"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到仅任务`check open warning`有警告`[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo`，其他的两个任务`check default warn`和`check close warning`都没有警告。



我们改变一下三个任务的顺序，将任务`check default warn`调到第一个位置，任务`check open warning`调到第二个位置，再运行剧本：

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: check default warn
      command: sudo df /home

    - name: check open warning
      command: sudo df /home
      args:
        warn: yes

    - name: check close warning
      command: sudo df /home
      args:
        warn: no


[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check default warn] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009999", "end": "2020-07-10 11:14:29.666028", "rc": 0, "start": "2020-07-10 11:14:29.656029", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140308  15671148  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140308  15671148  13% /"]}

TASK [check open warning] ****************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009531", "end": "2020-07-10 11:14:29.896933", "rc": 0, "start": "2020-07-10 11:14:29.887402", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140328  15671128  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140328  15671128  13% /"]}

TASK [check close warning] ***************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009132", "end": "2020-07-10 11:14:30.125819", "rc": 0, "start": "2020-07-10 11:14:30.116687", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140328  15671128  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140328  15671128  13% /"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到仅任务`check default warn`有警告`[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo`，其他的两个任务`check open warning`和`check close warning`都没有警告。

而通过查看更详细的信息：

```sh
[ansible@master ~]$ ansible-playbook command.yml -vvvv|grep 'warn'
TASK [check default warn] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:15:56.604604", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140332  15671124  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:15:56.594842", "stderr": "", "delta": "0:00:00.009762", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": true, "chdir": null, "stdin_add_newline": true, "stdin": null}}, "warnings": ["Consider using \'become\', \'become_method\', and \'become_user\' rather than running sudo"]}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4129\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
            "warn": true
TASK [check open warning] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:15:56.841487", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140556  15670900  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:15:56.832001", "stderr": "", "delta": "0:00:00.009486", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": true, "chdir": null, "stdin_add_newline": true, "stdin": null}}, "warnings": ["Consider using \'become\', \'become_method\', and \'become_user\' rather than running sudo"]}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4129\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": true
TASK [check close warning] ***************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:15:57.076183", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140556  15670900  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:15:57.066845", "stderr": "", "delta": "0:00:00.009338", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": false, "chdir": null, "stdin_add_newline": true, "stdin": null}}}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4129\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": false
```

可以看到实质上，任务`check default warn`和任务`check open warning`都是有警告信息的，但只有任务`check default warn`打印出了警告信息。



我们再来调整一下顺序，把任务`check close warning`放在第一个位置，任务`check open warning`放在第二个位置，任务`check default warn`放在最后的位置。再运行剧本看一下：



```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: check close warning
      command: sudo df /home
      args:
        warn: no

    - name: check open warning
      command: sudo df /home
      args:
        warn: yes

    - name: check default warn
      command: sudo df /home


[ansible@master ~]$ ansible-playbook command.yml

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check close warning] ***************************************************************************************************************
changed: [node1]

TASK [check open warning] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1]

TASK [check default warn] ****************************************************************************************************************
changed: [node1]

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ ansible-playbook command.yml -vvvv|grep warn
TASK [check close warning] ***************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:27:56.322621", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140516  15670940  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:27:56.313292", "stderr": "", "delta": "0:00:00.009329", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": false, "chdir": null, "stdin_add_newline": true, "stdin": null}}}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4336\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": false
TASK [check open warning] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:27:56.559072", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140536  15670920  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:27:56.549702", "stderr": "", "delta": "0:00:00.009370", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": true, "chdir": null, "stdin_add_newline": true, "stdin": null}}, "warnings": ["Consider using \'become\', \'become_method\', and \'become_user\' rather than running sudo"]}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4336\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
            "warn": true
TASK [check default warn] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:27:56.796577", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140536  15670920  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:27:56.786893", "stderr": "", "delta": "0:00:00.009684", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": true, "chdir": null, "stdin_add_newline": true, "stdin": null}}, "warnings": ["Consider using \'become\', \'become_method\', and \'become_user\' rather than running sudo"]}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4336\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": true
[ansible@master ~]$ 
```

此时可以看到，如果通过`warn: no`关闭了警告则该任务不会了生警告信息。而`check open warning`任务和`check default warn`任务都可以看到`warnings`字段信息,但仅`check open warning`任务会打印出`[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo`警告输出.初步判断Ansible只进行一种警告输出。



我们此时修改一下默认的配置修改，设置`command_warnings = False`即不开启命令异常。

```sh
[ansible@master ~]$ grep 'command_warnings' /etc/ansible/ansible.cfg
command_warnings = False
[ansible@master ~]$ cat command.yml 
- hosts: node1
  tasks:
    - name: check close warning
      command: sudo df /home
      args:
        warn: no

    - name: check open warning
      command: sudo df /home
      args:
        warn: yes

    - name: check default warn
      command: sudo df /home


[ansible@master ~]$ 
[ansible@master ~]$ ansible-playbook command.yml

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check close warning] ***************************************************************************************************************
changed: [node1]

TASK [check open warning] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1]

TASK [check default warn] ****************************************************************************************************************
changed: [node1]

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ ansible-playbook command.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check close warning] ***************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009565", "end": "2020-07-10 11:35:25.995341", "rc": 0, "start": "2020-07-10 11:35:25.985776", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140860  15670596  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140860  15670596  13% /"]}

TASK [check open warning] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.010186", "end": "2020-07-10 11:35:26.225574", "rc": 0, "start": "2020-07-10 11:35:26.215388", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140860  15670596  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140860  15670596  13% /"]}

TASK [check default warn] ****************************************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["sudo", "df", "/home"], "delta": "0:00:00.009249", "end": "2020-07-10 11:35:26.453855", "rc": 0, "start": "2020-07-10 11:35:26.444606", "stderr": "", "stderr_lines": [], "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\n/dev/mapper/centos-root  17811456 2140860  15670596  13% /", "stdout_lines": ["Filesystem              1K-blocks    Used Available Use% Mounted on", "/dev/mapper/centos-root  17811456 2140860  15670596  13% /"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ ansible-playbook command.yml -vvvv|grep warn
TASK [check close warning] ***************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:35:49.812270", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140800  15670656  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:35:49.803130", "stderr": "", "delta": "0:00:00.009140", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": false, "chdir": null, "stdin_add_newline": true, "stdin": null}}}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4440\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": false
TASK [check open warning] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:35:50.047457", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140800  15670656  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:35:50.038055", "stderr": "", "delta": "0:00:00.009402", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": true, "chdir": null, "stdin_add_newline": true, "stdin": null}}, "warnings": ["Consider using \'become\', \'become_method\', and \'become_user\' rather than running sudo"]}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4440\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
            "warn": true
TASK [check default warn] ****************************************************************************************************************
<node1> (0, '\r\n{"changed": true, "end": "2020-07-10 11:35:50.284609", "stdout": "Filesystem              1K-blocks    Used Available Use% Mounted on\\n/dev/mapper/centos-root  17811456 2140800  15670656  13% /", "cmd": ["sudo", "df", "/home"], "rc": 0, "start": "2020-07-10 11:35:50.275440", "stderr": "", "delta": "0:00:00.009169", "invocation": {"module_args": {"creates": null, "executable": null, "_uses_shell": false, "strip_empty_ends": true, "_raw_params": "sudo df /home", "removes": null, "argv": null, "warn": false, "chdir": null, "stdin_add_newline": true, "stdin": null}}}\r\n', 'OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017\r\ndebug1: Reading configuration data /etc/ssh/ssh_config\r\ndebug1: /etc/ssh/ssh_config line 58: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug2: mux_client_hello_exchange: master version 4\r\ndebug3: mux_client_forwards: request forwardings: 0 local, 0 remote\r\ndebug3: mux_client_request_session: entering\r\ndebug3: mux_client_request_alive: entering\r\ndebug3: mux_client_request_alive: done pid = 4440\r\ndebug3: mux_client_request_session: session request sent\r\ndebug1: mux_client_request_session: master session id: 2\r\ndebug3: mux_client_read_packet: read header failed: Broken pipe\r\ndebug2: Received exit status from master 0\r\nShared connection to node1 closed.\r\n')
            "warn": false
```

此时可以看到，只有通过`warn: yes`开启警告功能，Ansible才会发出`[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo`警告信息。即仅任务`check open warning`有警告信息！



通过以上实验对比我们可以发现，保持Ansible默认的`warn`设置即开启警告信息输出比较好，防止我们在编写命令时使用不正确的命令方式或者模块。因此，建议将`command_warnings`的设置改成默认的！注释掉`command_warnings`的设置即可。

```sh
[ansible@master ~]$ grep 'command_warnings' /etc/ansible/ansible.cfg
#command_warnings = False
```

此时将`commad.yml`剧本中任务顺序改一下，将`check default warn`任务放到`check open warning`任务前面，再运行剧本：

```sh
[ansible@master ~]$ cat command.yml
- hosts: node1
  tasks:
    - name: check close warning
      command: sudo df /home
      args:
        warn: no

    - name: check default warn
      command: sudo df /home

    - name: check open warning
      command: sudo df /home
      args:
        warn: yes

[ansible@master ~]$ ansible-playbook command.yml

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [check close warning] ***************************************************************************************************************
changed: [node1]

TASK [check default warn] ****************************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [node1]

TASK [check open warning] ****************************************************************************************************************
changed: [node1]

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到默认的警告功能又开启了！



