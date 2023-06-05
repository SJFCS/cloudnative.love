# shell执行远程脚本模块

[[toc]]

`shell`模块在主机上面执行命令。

- `shell`模块获取以空格分隔的列表组成的命令。
- 所指定的命令会在所有选择的主机上面执行。
- 处理shell命令，能使用`$HOME`以及重定向(`>`，`<`)、管道(`|`)、分号(`;`)、And符号(`&`)等。这是与`command`模块不一样的位置。
- `shell`模块与`command`模块几乎一样，但是`shell`模块是通过在远程主机上面通过shell脚本(`/bin/sh`)执行命令的。
- 自由格式命令或cmd参数是必须的。

shell模块的帮助文档：[https://docs.ansible.com/ansible/latest/modules/shell_module.html](https://docs.ansible.com/ansible/latest/modules/shell_module.html)

shell模块的源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/shell.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/shell.py)



## 1.  注意事项

- 如果要安全且可预测地执行命令，推荐使用`command`模块，除非明确要求使用`shell`模块。
- 如果要使用嵌入式脚本的话,请使用`script`模块以及`template`模块。
- 要重启电脑的话，使用`reboot`或`win_reboot`模块。
- 需要注意的是，如果使用`shell`模块执行shell脚本，需要将脚本复制到远程主机上面，而不能仅放在Ansible管理节点上。



## 2. shell模块参数

| 参数                 | 可选值             | 默认值 | 说明                                                         |
| -------------------- | ------------------ | ------ | ------------------------------------------------------------ |
| ~~argv~~             | **注意，无此参数** |        | **与command模块相比，shell模块没有argv参数**                 |
| `chdir`              |                    |        | `path`，在执行命令前切换到指定的工作目录，类似于使用`cd`命令切换`working directory`工作目录 |
| `cmd`                |                    |        | `string`，需要运行的命令                                     |
| `creates`            |                    |        | `path`，文件名或glob模式，如果对应的文件存在，则忽略此步     |
| `free_form`          |                    |        | 自由形式运行，可执行任何linux命令，**该参数实际不存在!!**.比如，当我们想要在远程主机上执行ls命令时，我们并不需要写成`free_form=ls`，这样写反而是错误的，因为并没有任何参数的名字是`free_form`，当我们想要在远程主机中执行`ls`命令时，直接写成`ls`即可，这就是`free_form`参数的含义，因为`command`模块的作用是执行命令，所以，任何一个可以在远程主机上执行的命令都可以被称为`free_form` |
| `removes`            |                    |        | `path`，文件名或glob模式，如果对应的文件存在，则执行此步     |
| `stdin`              |                    |        | `path`, 将指定路径设置为标准输入                             |
| `stdin_add_newline`  | yes/no             | yes    | `boolean`,如果设置`yes`，则会在标准输入后面增加一行          |
| ~~strip_empty_ends~~ | **注意，无此参数** |        | **与command模块相比，shell模块没有strip_empty_ends参数**     |
| `warn`               | yes/no             | yes    | `boolean`,如果设置`yes`，则会警告，在`2.14`版本会移除该参数  |
| **executable**       |                    |        | 与command模块相比，shell模块增加了executable参数，通过该参数改变SHELL可执行命令的路径（默认为`/bin/sh`），即用不同的shell执行脚本 |

## 3. shell模块返回值

| 键      | 是否返回 | 描述                                 |
| ------- | -------- | ------------------------------------ |
| `cmd`   | 一直返回 | `list`，在远程主机上面执行的命令列表 |
| `start` | 一直返回 | `string`,命令开始时间                |
| `end`   | 一直返回 | `string`,命令结束时间                |
| `delta` | 一直返回 | `string`,命令运行时间                |

以及一些其他的通用返回值。

官方示例：

```yaml
- name: Execute the command in remote shell; stdout goes to the specified file on the remote.
  shell: somescript.sh >> somelog.txt

- name: Change the working directory to somedir/ before executing the command.
  shell: somescript.sh >> somelog.txt
  args:
    chdir: somedir/

# You can also use the 'args' form to provide the options.
- name: This command will change the working directory to somedir/ and will only run when somedir/somelog.txt doesn't exist.
  shell: somescript.sh >> somelog.txt
  args:
    chdir: somedir/
    creates: somelog.txt

# You can also use the 'cmd' parameter instead of free form format.
- name: This command will change the working directory to somedir/.
  shell:
    cmd: ls -l | grep log
    chdir: somedir/

- name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
  shell: cat < /tmp/*txt
  args:
    executable: /bin/bash

- name: Run a command using a templated variable (always use quote filter to avoid injection)
  shell: cat {{ myfile|quote }}

# You can use shell to run other executables to perform actions inline
- name: Run expect to wait for a successful PXE boot via out-of-band CIMC
  shell: |
    set timeout 300
    spawn ssh admin@{{ cimc_host }}

    expect "password:"
    send "{{ cimc_password }}\n"

    expect "\n{{ cimc_name }}"
    send "connect host\n"

    expect "pxeboot.n12"
    send "\n"

    exit 0
  args:
    executable: /usr/bin/expect
  delegate_to: localhost

# Disabling warnings
- name: Using curl to connect to a host via SOCKS proxy (unsupported in uri). Ordinarily this would throw a warning.
  shell: curl --socks5 localhost:9000 http://www.ansible.com
  args:
    warn: no
```

## 4. 使用临时命令调用shell模块

### 4.1 执行远程主机上面的命令

```sh
[ansible@master ~]$ ansible node1 -m shell -a 'cat /etc/passwd|grep root'
node1 | CHANGED | rc=0 >>
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
[ansible@master ~]$ ansible node1 -m shell -a 'hostname;pwd'
node1 | CHANGED | rc=0 >>
node1.ansible.com
/home/ansible
[ansible@master ~]$
[ansible@master ~]$ ansible node1 -m shell -a 'echo "12/4"|bc'
node1 | CHANGED | rc=0 >>
3
```

### 4.2 执行远程主机上面的shell脚本

此时需要注意的时，脚本必须在远程主机存在，且执行时需要指定脚本的全路径：

```sh
[ansible@master ~]$ ansible node1 -m shell -a "/home/ansible/somescript.sh"
node1 | CHANGED | rc=0 >>
2020年07月10日_17:24:11
[ansible@master ~]$ ansible node1 -m shell -a 'somescript.sh'
node1 | FAILED | rc=127 >>
/bin/sh: somescript.sh: command not foundnon-zero return code
[ansible@master ~]$ 
```



## 5. 执行剧本

为了直接利用官方示例，我们编写一个脚本文件`somescript.sh`：

```sh
[ansible@master ~]$ cat somescript.sh
#!/bin/sh
date +"%Y年%m月%d日_%H:%M:%S"
[ansible@master ~]$ sh somescript.sh
2020年07月10日_16:16:25
```

脚本简单地打印出当前时间。

```sh
# 编写剧本文件
[ansible@master ~]$ cat shell.yml
- hosts: node1
  tasks:
    - name: Execute the command in remote shell; stdout goes to the specified file on the remote.
      shell: somescript.sh >> somelog.txt

    - name: Change the working directory to /tmp before executing the command.
      shell: somescript.sh >> somelog.txt
      args:
        chdir: /tmp

    # You can also use the 'args' form to provide the options.
    - name: This command will change the working directory to /tmp and will only run when /tmp/somelog.txt doesn't exist.
      shell: somescript.sh >> somelog.txt
      args:
        chdir: /tmp
        creates: somelog.txt

    # You can also use the 'cmd' parameter instead of free form format.
    - name: This command will change the working directory to /tmp.
      shell:
        cmd: ls -l | grep log
        chdir: /tmp
[ansible@master ~]$ 
# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check shell.yml

playbook: shell.yml
[ansible@master ~]$ 
```

如果我们直接执行，这时候会报错：

```sh
[ansible@master ~]$ ansible-playbook shell.yml

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Execute the command in remote shell; stdout goes to the specified file on the remote.] *********************************************
fatal: [node1]: FAILED! => {"changed": true, "cmd": "somescript.sh >> somelog.txt", "delta": "0:00:00.002520", "end": "2020-07-10 17:12:09.914554", "msg": "non-zero return code", "rc": 127, "start": "2020-07-10 17:12:09.912034", "stderr": "/bin/sh: somescript.sh: command not found", "stderr_lines": ["/bin/sh: somescript.sh: command not found"], "stdout": "", "stdout_lines": []}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，远程没有`somescript.sh`这个脚本。

### 5.1 使用重定向和管道

我们在node1节点上面的ansible家目录下面创建一个`somescript.sh`脚本：

```sh
[ansible@node1 ~]$ cat somescript.sh
#!/bin/sh
date +"%Y年%m月%d日_%H:%M:%S"
[ansible@node1 ~]$
```

然后再在Ansible管理节点上面执行剧本：

```sh
[ansible@master ~]$ ansible-playbook shell.yml  -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Execute the command in remote shell; stdout goes to the specified file on the remote.] *********************************************
changed: [node1] => {"changed": true, "cmd": "~/somescript.sh >> somelog.txt", "delta": "0:00:00.003562", "end": "2020-07-10 17:27:10.947353", "rc": 0, "start": "2020-07-10 17:27:10.943791", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

TASK [Change the working directory to /tmp before executing the command.] ****************************************************************
changed: [node1] => {"changed": true, "cmd": "~/somescript.sh >> somelog.txt", "delta": "0:00:00.003649", "end": "2020-07-10 17:27:11.171886", "rc": 0, "start": "2020-07-10 17:27:11.168237", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

TASK [This command will change the working directory to /tmp and will only run when /tmp/somelog.txt doesn't exist.] *********************
ok: [node1] => {"changed": false, "cmd": "~/somescript.sh >> somelog.txt", "rc": 0, "stdout": "skipped, since somelog.txt exists", "stdout_lines": ["skipped, since somelog.txt exists"]}

TASK [This command will change the working directory to /tmp.] ***************************************************************************
changed: [node1] => {"changed": true, "cmd": "ls -l | grep log", "delta": "0:00:00.004408", "end": "2020-07-10 17:27:11.614706", "rc": 0, "start": "2020-07-10 17:27:11.610298", "stderr": "", "stderr_lines": [], "stdout": "-rw-rw-r-- 1 ansible ansible   54 Jul 10 17:27 somelog.txt", "stdout_lines": ["-rw-rw-r-- 1 ansible ansible   54 Jul 10 17:27 somelog.txt"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，剧本正常执行！



在node1上面进行检查：

```sh
[ansible@node1 ~]$ ls
somelog.txt  somescript.sh
[ansible@node1 ~]$ cat somelog.txt
2020年07月10日_17:27:04
2020年07月10日_17:27:10
[ansible@node1 ~]$ ls -lah /tmp/somelog.txt
-rw-rw-r-- 1 ansible ansible 54 Jul 10 17:27 /tmp/somelog.txt
[ansible@node1 ~]$ cat /tmp/somelog.txt
2020年07月10日_17:27:04
2020年07月10日_17:27:11
[ansible@node1 ~]$
```

可以看到`somelog.txt`中的确已经有日期信息，并且在ansible家目录以及/tmp目录下面都存在这个文件，说明Ansible剧本执行起作用了。



我们再来测试另外两个示例，修改一下剧本文件：

```sh
# 查看剧本文件
[ansible@master ~]$ cat shell.yml 
- hosts: node1
  vars:
    myfile: /tmp/somelog.txt
  tasks:
    - name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
      shell: cat < /tmp/*txt
      args:
        executable: /bin/bash

    - name: Run a command using a templated variable (always use quote filter to avoid injection)
      shell: cat {{ myfile|quote }}

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check shell.yml

playbook: shell.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)] ***
fatal: [node1]: FAILED! => {"changed": true, "cmd": "cat < /tmp/*txt", "delta": "0:00:00.002486", "end": "2020-07-13 15:35:24.793609", "msg": "non-zero return code", "rc": 1, "start": "2020-07-13 15:35:24.791123", "stderr": "/bin/bash: /tmp/*txt: ambiguous redirect", "stderr_lines": ["/bin/bash: /tmp/*txt: ambiguous redirect"], "stdout": "", "stdout_lines": []}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

 可以看到执行剧本时，在执行命令`cat < /tmp/*txt`报错了，提示`ambiguous redirect`,翻译过来就是`歧义重定向`,即重定向有问题。



我们下面来测试一下，当使用通配符(`*`)时出现的`ambiguous redirect`问题。



我断断续续地在ansible家目录里面创建了好几个yml剧本文件了，我们尝试使用`cat`命令和通配符重定向测试一下：

```sh
# 查看家目录下的文件，有好几个yml文件
[ansible@master ~]$ ls
command.yml  docker_login.yml  mymotd.yml  myping.yml  shell.yml  somescript.sh
[ansible@master ~]$ 
# 尝试cat查看一下，这些出现了ambiguous redirect重定向歧义异常
# 本意是想将所有的.yml文件内容输出到cat命令中进行查看，结果查看不了
[ansible@master ~]$ cat < *.yml
bash: *.yml: ambiguous redirect
# 而单独从一个文件中进行重定向时却是正常的
[ansible@master ~]$ cat < command.yml 
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

# 切换到sh环境下
[ansible@master ~]$ sh
# sh环境下，单独查看一个文件是正常的
sh-4.2$ cat < command.yml 
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

# 使用通配符进行查看又报了歧义重定向问题
sh-4.2$ cat < *.yml
sh: *.yml: ambiguous redirect
sh-4.2$ exit
exit
```

即当匹配到多个文件时，使用这种方式进行匹配是存在歧义重定向问题的。



按照测试结论，我们大概可以猜出在node1节点/tmp目录下面存在多个.txt文件。我们检查一下：

```sh
[ansible@node1 ~]$ ls /tmp/*.txt
/tmp/check.txt  /tmp/message.txt  /tmp/somelog.txt
[ansible@node1 ~]$ 
```

可以看到已经存在三个.txt文件了，我们把`/tmp/check.txt`和`/tmp/message.txt `文件删除掉，删除后再进行查看，只匹配到一个文件了，并且此时使用cat查看时并没有抛出异常：

```sh
[ansible@node1 ~]$ ls /tmp/*.txt
/tmp/somelog.txt
[ansible@node1 ~]$ 
[ansible@node1 ~]$ cat < /tmp/*.txt
2020年07月10日_17:27:04
2020年07月10日_17:27:11
[ansible@node1 ~]$ sh
sh-4.2$ pwd
/home/ansible
sh-4.2$ cat /tmp/*.txt
2020年07月10日_17:27:04
2020年07月10日_17:27:11
sh-4.2$ exit
exit
```

说明准备工作正常！

我们再进行一下Ansible剧本的执行：

```sh
[ansible@master ~]$ cat shell.yml
- hosts: node1
  vars:
    myfile: /tmp/somelog.txt
  tasks:
    - name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
      shell: cat < /tmp/*txt
      args:
        executable: /bin/bash

    - name: Run a command using a templated variable (always use quote filter to avoid injection)
      shell: cat {{ myfile|quote }}

[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)] ***
changed: [node1] => {"changed": true, "cmd": "cat < /tmp/*txt", "delta": "0:00:00.002678", "end": "2020-07-13 15:56:17.965858", "rc": 0, "start": "2020-07-13 15:56:17.963180", "stderr": "", "stderr_lines": [], "stdout": "2020年07月10日_17:27:04\n2020年07月10日_17:27:11", "stdout_lines": ["2020年07月10日_17:27:04", "2020年07月10日_17:27:11"]}

TASK [Run a command using a templated variable (always use quote filter to avoid injection)] *********************************************
changed: [node1] => {"changed": true, "cmd": "cat /tmp/somelog.txt", "delta": "0:00:00.002397", "end": "2020-07-13 15:56:18.203810", "rc": 0, "start": "2020-07-13 15:56:18.201413", "stderr": "", "stderr_lines": [], "stdout": "2020年07月10日_17:27:04\n2020年07月10日_17:27:11", "stdout_lines": ["2020年07月10日_17:27:04", "2020年07月10日_17:27:11"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

正常执行，需要注意的是，本例中提到，`/bin/sh`不能同时处理重定向和通配符(`/bin/sh doesn't handle redirection and wildcards together but bash does`)，但`/bin/bash`可以。

此时,我们可以更进一步的看一下任务1的详细信息:

```
changed: [node1] => {
    "changed": true, 
    "cmd": "cat < /tmp/*txt", 
    "delta": "0:00:00.003124", 
    "end": "2020-07-13 16:13:00.088705", 
    "invocation": {
        "module_args": {
            "_raw_params": "cat < /tmp/*txt", 
            "_uses_shell": true, 
            "argv": null, 
            "chdir": null, 
            "creates": null, 
            "executable": "/bin/bash", 
            "removes": null, 
            "stdin": null, 
            "stdin_add_newline": true, 
            "strip_empty_ends": true, 
            "warn": true
        }
    }, 
    "rc": 0, 
    "start": "2020-07-13 16:13:00.085581", 
    "stderr": "", 
    "stderr_lines": [], 
    "stdout": "2020年07月10日_17:27:04\n2020年07月10日_17:27:11", 
    "stdout_lines": [
        "2020年07月10日_17:27:04", 
        "2020年07月10日_17:27:11"
    ]
}
```

可以看到此时的参数`"executable": "/bin/bash"`,已经不是默认的`/bin/sh`了!



如果我们将示例中`executable: /bin/bash`去掉，或者改成`executable: /bin/sh`再执行剧本，都会发现异常：

```sh
# 移除executable: /bin/bash 参数
[ansible@master ~]$ cat shell.yml 
- hosts: node1
  vars:
    myfile: /tmp/somelog.txt
  tasks:
    - name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
      shell: cat < /tmp/*txt
      args:
        # executable: /bin/bash

    - name: Run a command using a templated variable (always use quote filter to avoid injection)
      shell: cat {{ myfile|quote }}

# 执行剧本失败
[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)] ***
fatal: [node1]: FAILED! => {"changed": true, "cmd": "cat < /tmp/*txt", "delta": "0:00:00.002514", "end": "2020-07-13 16:08:04.482385", "msg": "non-zero return code", "rc": 1, "start": "2020-07-13 16:08:04.479871", "stderr": "/bin/sh: /tmp/*txt: No such file or directory", "stderr_lines": ["/bin/sh: /tmp/*txt: No such file or directory"], "stdout": "", "stdout_lines": []}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 


# 将executable: /bin/bash改成executable: /bin/sh
[ansible@master ~]$ cat shell.yml
- hosts: node1
  vars:
    myfile: /tmp/somelog.txt
  tasks:
    - name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
      shell: cat < /tmp/*txt
      args:
        executable: /bin/sh

    - name: Run a command using a templated variable (always use quote filter to avoid injection)
      shell: cat {{ myfile|quote }}

# 执行剧本失败
[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)] ***
fatal: [node1]: FAILED! => {"changed": true, "cmd": "cat < /tmp/*txt", "delta": "0:00:00.002483", "end": "2020-07-13 16:08:39.423999", "msg": "non-zero return code", "rc": 1, "start": "2020-07-13 16:08:39.421516", "stderr": "/bin/sh: /tmp/*txt: No such file or directory", "stderr_lines": ["/bin/sh: /tmp/*txt: No such file or directory"], "stdout": "", "stdout_lines": []}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

查看详细日志信息时，可以看到`executable`是`/bin/sh`:

```
fatal: [node1]: FAILED! => {
    "changed": true, 
    "cmd": "cat < /tmp/*txt", 
    "delta": "0:00:00.003272", 
    "end": "2020-07-13 16:11:13.986582", 
    "invocation": {
        "module_args": {
            "_raw_params": "cat < /tmp/*txt", 
            "_uses_shell": true, 
            "argv": null, 
            "chdir": null, 
            "creates": null, 
            "executable": "/bin/sh", 
            "removes": null, 
            "stdin": null, 
            "stdin_add_newline": true, 
            "strip_empty_ends": true, 
            "warn": true
        }
    }, 
    "msg": "non-zero return code", 
    "rc": 1, 
    "start": "2020-07-13 16:11:13.983310", 
    "stderr": "/bin/sh: /tmp/*txt: No such file or directory", 
    "stderr_lines": [
        "/bin/sh: /tmp/*txt: No such file or directory"
    ], 
    "stdout": "", 
    "stdout_lines": []
}
```



### 5.2 执行其他shell

我们在node1上面安装一个fish,安装命令`sudo yum install fish -y`,安装完成后编写一个fish脚本:

```sh
# 编写脚本
[ansible@node1 ~]$ cat mytest.fish
if grep fish /etc/shells
    echo Found fish
else if grep bash /etc/shells
    echo Found bash
else
    echo Got nothing
end
[ansible@node1 ~]$ 
# 给脚本增加可执行权限
[ansible@node1 ~]$ chmod u+x mytest.fish
# 查看脚本权限
[ansible@node1 ~]$ ll mytest.fish
-rwxrw-r-- 1 ansible ansible 125 Jul 13 16:55 mytest.fish
# 执行脚本
[ansible@node1 ~]$ fish mytest.fish
/usr/bin/fish
Found fish
[ansible@node1 ~]$ 
```

尝试使用Ansible执行fish脚本:

```sh
# 编写脚本,并且指定使用/usr/bin/fish作为shell
[ansible@master ~]$ cat shell.yml
- hosts: node1
  tasks:
    - name: Run a fish shell script
      shell: fish mytest.fish
      args:
        executable: /usr/bin/fish

[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run a fish shell script] ***********************************************************************************************************
changed: [node1] => {"changed": true, "cmd": "fish mytest.fish", "delta": "0:00:00.008569", "end": "2020-07-13 17:14:30.958183", "rc": 0, "start": "2020-07-13 17:14:30.949614", "stderr": "", "stderr_lines": [], "stdout": "/usr/bin/fish\nFound fish", "stdout_lines": ["/usr/bin/fish", "Found fish"]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到正常执行fish脚本了!

### 5.3 使用expect进行自动交互式任务处理

- 在Ansible管理节点上面安装expect， 安装命令`sudo yum install expect -y`

```sh
[ansible@master ~]$ sudo yum install expect -y
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirrors.163.com
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.huaweicloud.com
base                                                                                                               | 3.6 kB  00:00:00     
epel                                                                                                               | 4.7 kB  00:00:00     
extras                                                                                                             | 2.9 kB  00:00:00     
ius                                                                                                                | 1.3 kB  00:00:00     
updates                                                                                                            | 2.9 kB  00:00:00     
(1/6): epel/x86_64/group_gz                                                                                        |  95 kB  00:00:05     
(2/6): epel/x86_64/updateinfo                                                                                      | 1.0 MB  00:00:05     
(3/6): epel/x86_64/primary_db                                                                                      | 6.8 MB  00:00:02     
(4/6): extras/7/x86_64/primary_db                                                                                  | 205 kB  00:00:05     
(5/6): updates/7/x86_64/primary_db                                                                                 | 3.0 MB  00:00:06     
(6/6): ius/x86_64/primary                                                                                          | 154 kB  00:00:06     
ius                                                                                                                               793/793
Resolving Dependencies
--> Running transaction check
---> Package expect.x86_64 0:5.45-14.el7_1 will be installed
--> Processing Dependency: libtcl8.5.so()(64bit) for package: expect-5.45-14.el7_1.x86_64
--> Running transaction check
---> Package tcl.x86_64 1:8.5.13-8.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==========================================================================================================================================
 Package                        Arch                           Version                                 Repository                    Size
==========================================================================================================================================
Installing:
 expect                         x86_64                         5.45-14.el7_1                           base                         262 k
Installing for dependencies:
 tcl                            x86_64                         1:8.5.13-8.el7                          base                         1.9 M

Transaction Summary
==========================================================================================================================================
Install  1 Package (+1 Dependent package)

Total download size: 2.1 M
Installed size: 4.9 M
Downloading packages:
(1/2): expect-5.45-14.el7_1.x86_64.rpm                                                                             | 262 kB  00:00:05     
(2/2): tcl-8.5.13-8.el7.x86_64.rpm                     70% [===============================             ] 173 kB/s | 1.5 MB  00:00:03 ETA 
(2/2): tcl-8.5.13-8.el7.x86_64.rpm                                                                                 | 1.9 MB  00:00:16     
------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                     129 kB/s | 2.1 MB  00:00:17     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 1:tcl-8.5.13-8.el7.x86_64                                                                                              1/2 
  Installing : expect-5.45-14.el7_1.x86_64                                                                                            2/2 
  Verifying  : 1:tcl-8.5.13-8.el7.x86_64                                                                                              1/2 
  Verifying  : expect-5.45-14.el7_1.x86_64                                                                                            2/2 

Installed:
  expect.x86_64 0:5.45-14.el7_1                                                                                                           

Dependency Installed:
  tcl.x86_64 1:8.5.13-8.el7                                                                                                               

Complete!
[ansible@master ~]$
# 查看expect的版本信息
[ansible@master ~]$ expect -v
expect version 5.45
```

编写expect脚本，并运行脚本：

```sh
[ansible@master ~]$ cat test.expect
#!/usr/bin/expect
# 设置超时时间
set timeout 30
# 设置主机地址
set host "node1"
# 设置用户名
set username "meizhaohui"
# 设置密码
set password "123456"

# 进入expect环境后才可以执行的expect内部命令，进行SSH连接到主机
spawn ssh $username@$host
# 这里的expect也是expect的一个内部命令，这个命令的意思是判断上次输出结果里是否包含“password”的字符串，如果有则立即返回；否则就等待一段时间后返回，这里等待时长就是前面设置的30秒；
# send "$password\r"表示当匹配到对应的输出结果时，就发送密码到打开的ssh进程
expect "*password*" {send "$password\r"}
# interact执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。
interact
[ansible@master ~]$

# 执行expect脚本，可以看到能够自动连接到node1节点，然后进入到交互界面，说明expect脚本起作用了
[ansible@master ~]$ expect test.expect
spawn ssh meizhaohui@node1
meizhaohui@node1's password: 
Last login: Tue Jul 14 10:51:47 2020 from 192.168.56.110
[meizhaohui@master ~]$ hostname -I
192.168.56.111 10.0.3.15
[meizhaohui@master ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

因此我们可以参照官方示例写一个Ansible使用登陆到node1节点的程序。

```sh
# 编写剧本文件，设置一个通过expect脚本连接到远程主机登陆的任务
[ansible@master ~]$ cat shell.yml
- hosts: node1
  vars:
    host: node1
    username: meizhaohui
    password: "123456"
  tasks:
    # You can use shell to run other executables to perform actions inline
    - name: Run expect script
      shell: |
        set timeout 300
        spawn ssh {{ username }}@{{ host }}
      
        expect "password:"
        send "{{ password }}\n"
      
        exit 0
      args:
        executable: /usr/bin/expect
      delegate_to: localhost

# 剧本文件语法检查
[ansible@master ~]$ ansible-playbook --syntax-check shell.yml 

playbook: shell.yml

# 执行剧本
[ansible@master ~]$ ansible-playbook shell.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] *****************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [node1]

TASK [Run expect script] *****************************************************************************************************************
changed: [node1 -> localhost] => {"changed": true, "cmd": "set timeout 300\nspawn ssh meizhaohui@node1\n\nexpect \"password:\"\nsend \"123456\\n\"\n\nexit 0\n", "delta": "0:00:00.066912", "end": "2020-07-14 13:56:10.467089", "rc": 0, "start": "2020-07-14 13:56:10.400177", "stderr": "", "stderr_lines": [], "stdout": "spawn ssh meizhaohui@node1\r\nmeizhaohui@node1's password: ", "stdout_lines": ["spawn ssh meizhaohui@node1", "meizhaohui@node1's password: "]}

PLAY RECAP *******************************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到剧本正常执行，说明通过Ansible执行剧本正常。

