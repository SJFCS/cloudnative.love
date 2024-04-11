# make编译模块

[[toc]]

## 1. 概述

- make模块可以运行Makefile中的目标target。
- 官方文档链接  [https://docs.ansible.com/ansible/2.9/modules/make_module.html](https://docs.ansible.com/ansible/2.9/modules/make_module.html)
- 运行本模块远程主机必须要安装有`make`程序。

## 2. 参数


| 参数                  | 描述                                                                                                 |
|-----------------------|------------------------------------------------------------------------------------------------------|
| chdir    path       | 切换工作目录                                                                                     |
| file   path       | 使用自定义Makefile |
| params   dictionary | 需要传递给make的参数，字典形式                                                                           |
| target   string   | 需要运行的目标target，如`install`、`test`、`all`等等                                                                            |


## 3. 官方示例

```yaml
- name: Build the default target
  make:
    chdir: /home/ubuntu/cool-project

- name: Run 'install' target as root
  make:
    chdir: /home/ubuntu/cool-project
    target: install
  become: yes

- name: Build 'all' target with extra arguments
  make:
    chdir: /home/ubuntu/cool-project
    target: all
    params:
      NUM_THREADS: 4
      BACKEND: lapack

- name: Build 'all' target with a custom Makefile
  make:
    chdir: /home/ubuntu/cool-project
    target: all
    file: /some-project/Makefile
```

## 4. Makefile基础

此处仅简单的编写一个Makefile文件：
```makefile
.DEFAULT_GOAL = run

help:
	@if [[ $$HELP -eq 1 ]] ; then echo "please run 'make build' or 'make clean'"; fi
build:
	gcc hello.c -o hello
clean:
	rm -f hello
run:
	./hello
```

此处进行简单说明：
- `.DEFAULT_GOAL = run`指定默认运行`run`目标。
- `help`目标用于读取`make`程序是否传递`HELP`参数，如果传递`HELP=1`，则会打印输出信息。`@if`前面的`@`表示不回显命令。`$$HELP`表示获取命令行HELP字典参数的值。
- `build`目标会编译出可执行文件`hello`。
- `clean`目标会删除可执行文件`hello`。
- `run`目标会运行可执行文件。
- 注意。每个目标下面的行首位置是`TAB`键，**不是4个空格**。如果不小心输入了4个空格，可以使用命令`sed -i 's/    /\t/g' Makefile`进行替换。
- 此处不详细介绍Makefile编写规则。

对应的`hello.c`程序内容如下：
```c
#include <stdio.h>

int main()
{
    printf("Hello,world\n");

    return 0;
}
```

此处我们先不使用ansible测试一下make命令。

```sh
# 查看make的版本信息
[root@node1 hello_world]# make --version
GNU Make 3.82
Built for x86_64-redhat-linux-gnu
Copyright (C) 2010  Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

# 查看当前工作目录
[root@node1 hello_world]# pwd
/root/c_data/hello_world

# 查看文件列表
[root@node1 hello_world]# ll
total 8
-rw-r--r-- 1 root root  80 Nov  9 20:32 hello.c
-rw-r--r-- 1 root root 173 Nov  9 20:41 Makefile

# 编译，此时会生成可执行文件hello
[root@node1 hello_world]# make build
gcc hello.c -o hello

# 运行，输出`Hello,world`
#       注意，如果你运行`make run`时，
#       抛出异常`make: *** [run] Error 12`，
#       则有可能是你的hello.c源文件中，没有指定`return 0;`退出码语句
[root@node1 hello_world]# make run
./hello
Hello,world

# 不指定目标，会运行默认目标run，也就是运行可执行程序
[root@node1 hello_world]# make
./hello
Hello,world

# 给make传递字典参数HELP=1，打印帮助信息
[root@node1 hello_world]# make help HELP=1
please run 'make build' or 'make clean'

# 给make传递字典参数HELP=0，此时不满足if条件判断，不会打印帮助信息
[root@node1 hello_world]# make help HELP=0

# 查看文件列表
[root@node1 hello_world]# ls
hello  hello.c  Makefile

# 清理，删除可执行文件hello
[root@node1 hello_world]# make clean
rm -f hello

# 查看文件列表，可以看到可执行文件已经删除掉
[root@node1 hello_world]# ls
hello.c  Makefile
[root@node1 hello_world]#
```

## 5. 剧本的使用

我们参考官方示例，使用剧本来执行远程主机上面的make程序。

直接整合成一个剧本文件`make.yml`：

```yaml
- hosts: node1
  tasks:
    - name: Run 'build' target
      make:
        chdir: /root/c_data/hello_world
        target: build
      become: yes

    - name: Build the default target
      make:
        chdir: /root/c_data/hello_world
      become: yes

    - name: Build 'help' target with extra arguments
      make:
        chdir: /root/c_data/hello_world
        target: help
        params:
          HELP: 1
      become: yes

    - name: Build 'help' target with extra arguments
      make:
        chdir: /root/c_data/hello_world
        target: help
        params:
          HELP: 0
      become: yes

    - name: Build 'clean' target
      make:
        chdir: /root/c_data/hello_world
        target: clean
        file: /root/c_data/hello_world/Makefile
      become: yes

```

检查并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint make.yml
[ansible@master ansible_playbooks]$ ansible-playbook make.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Run 'build' target] **********************************************************************************************
changed: [node1] => {"changed": true, "chdir": "/root/c_data/hello_world", "file": null, "params": null, "stderr": "", "stderr_lines": [], "stdout": "gcc hello.c -o hello", "stdout_lines": ["gcc hello.c -o hello"], "target": "build"}

TASK [Build the default target] ****************************************************************************************
changed: [node1] => {"changed": true, "chdir": "/root/c_data/hello_world", "file": null, "params": null, "stderr": "", "stderr_lines": [], "stdout": "./hello\nHello,world", "stdout_lines": ["./hello", "Hello,world"], "target": null}

TASK [Build 'help' target with extra arguments] ************************************************************************
changed: [node1] => {"changed": true, "chdir": "/root/c_data/hello_world", "file": null, "params": {"HELP": 1}, "stderr": "", "stderr_lines": [], "stdout": "please run 'make build' or 'make clean'", "stdout_lines": ["please run 'make build' or 'make clean'"], "target": "help"}

TASK [Build 'help' target with extra arguments] ************************************************************************
changed: [node1] => {"changed": true, "chdir": "/root/c_data/hello_world", "file": null, "params": {"HELP": 0}, "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": [], "target": "help"}

TASK [Build 'clean' target] ********************************************************************************************
changed: [node1] => {"changed": true, "chdir": "/root/c_data/hello_world", "file": "/root/c_data/hello_world/Makefile", "params": null, "stderr": "", "stderr_lines": [], "stdout": "rm -f hello", "stdout_lines": ["rm -f hello"], "target": "clean"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，正常执行了远程主机上面的`make`命令！！ 要让`make`做更多的事情，你需要编写满足您业务场景的`Makefile`文件。