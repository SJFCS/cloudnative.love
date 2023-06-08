# 防止`rm -rf /`误删除的方法

[[toc]]

## 概述


- `rm -rf /`意味着擦除根路径`/`下挂载的所有内容而无需询问。 
- `rm -rf /` 命令在`Linux`下执行后，就是一场灾难。

:::warning 警告

☢️☢️☢️请不要在生产环境执行`rm -rf /`命令！！！！
:::

为了防止这种误删除操作，找了很多办法，有建议回收站机制、也有说给重要目录设置权限等等方法、还有替换`rm`删除命令的方法；总结了一下，还是觉得禁用`rm`命令，并设置安全删除命令 `safe-rm` 和垃圾回收机制`trash-cli`。


## `safe-rm`安全删除命令



`safe-rm`，它具有 `rm` 命令的所有功能，不过 `safe-rm` 命令可以设置路径黑名单，也就是说在黑名单中的目录或文件将不会被删除；我们把 `rm` 命令禁用，之后执行 `safe-rm` 命令，也就不会误删除黑名单中的目录或文件了。

`safe-rm` 的官网：[https://repo.or.cz/w/safe-rm.git](https://repo.or.cz/w/safe-rm.git)

### safe-rm README文档

```sh
safe-rm - https://launchpad.net/safe-rm
prevention of accidental deletions using a directory blacklist

Copyright (C) 2008-2014  Francois Marier <francois@fmarier.org>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

How to use
-----------

Once you have installed safe-rm on your system (see INSTALL), you will need to
fill the system-wide or user-specific blacklists with the paths that you'd like
to protect against accidental deletion.

The system-wide blacklist lives in /etc/safe-rm.conf and you should probably add
paths like these:

  /
  /etc
  /usr
  /usr/lib
  /var

The user-specific blacklist lives in ~/.config/safe-rm and could include things like:

  /home/username/documents
  /home/username/documents/*
  /home/username/.mozilla


Other approaches
-----------------

If you want more protection than what safe-rm can offer, here are a few suggestions.

You could of couse request confirmation everytime you delete a file by putting this in
your /etc/bash.bashrc:

  alias rm='rm -i'

But this won't protect you from getting used to always saying yes, or from accidently
using 'rm -rf'.

Or you could make use of the Linux filesystem "immutable" attribute by marking (as root)
each file you want to protect:

  chattr +i file

Of course this is only usable on filesystems which support this feature.

Here are two projects which allow you to recover recently deleted files by trapping
all unlink(), rename() and open() system calls through the LD_PRELOAD facility:

  delsafe
  http://homepage.esoterica.pt/~nx0yew/delsafe/

  libtrashcan
  http://hpux.connect.org.uk/hppd/hpux/Development/Libraries/libtrash-0.2/readme.html

There are also projects which implement the FreeDesktop.org trashcan spec. For example:

  trash-cli
  http://code.google.com/p/trash-cli/

Finally, this project is a fork of GNU coreutils and adds features similar to safe-rm
to the rm command directly:

  http://wiki.github.com/d5h/rmfd/
```

### 下载

```sh
[root@localhost ~]# wget https://launchpad.net/safe-rm/trunk/0.12/+download/safe-rm-0.12.tar.gz
```

### 解压

```sh
[root@localhost ~]# tar -zxvf safe-rm-0.12.tar.gz
```
 
### 查看rm存放的路径

```sh
[root@localhost ~]# whereis rm
/usr/bin/rm
```

### 查看PATH环境变量

```sh
[root@localhost ~]# echo $PATH
/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
```

### 复制`safe-rm`到`$PATH`某个目录下

复制`safe-rm`到`/usr/local/bin`目录下(将 `safe-rm`放在 `$PATH`中比原`rm`程序靠前的位置):

```sh
[root@localhost ~]# cp ~/safe-rm-0.12/safe-rm /usr/local/bin/safe-rm
```

### 创建配置文件

- 创建`/etc/safe-rm.conf`，设置路径黑名单，将重要文件或者目录的完整路径输入进去保存就可以了，每条以回车分隔:

```sh
[root@localhost ~]# touch /etc/safe-rm.conf
[root@localhost ~]# cat /etc/safe-rm.conf
/
/bin
/boot
/dev
/etc
/home
/initrd
/lib
/proc
/root
/sbin
/sys
/usr
/usr/bin
/usr/include
/usr/lib
/usr/local
/usr/local/bin
/usr/local/include
/usr/local/sbin
/usr/local/share
/usr/sbin
/usr/share
/usr/src
/var
/etc/safe-rm.conf
[root@localhost ~]#
```

### 测试删除
   
- 测试`safe-rm`命令，`safe-rm`会跳过`/etc/safe-rm.conf`中配置的目录或文件（**最好先找个测试目录进行实验，别弄不好成灾难了....**）:

```sh
[root@localhost ~]# echo "/a/b/c" >> /etc/safe-rm.conf
[root@localhost ~]# mkdir -p /a/b/c
[root@localhost ~]# safe-rm -rm /a/b/c
safe-rm: skipping /a/b/c
```

## `trash-cli`垃圾回收机制


`trash-cli`是一个使用python开发的软件包，包含`trash-put`、`trash-rm`、`trash-list`、`trash-restore`、`trash`、`trash-empty`等命令，我们可以通过这些命令，将文件移动到回收站，或者还原删除了的文件。

`trash-cli`提供以下命令：

- `trash-put`          trash files and directories.  将文件或目录移入回收站
- `trash-empty`       empty the trashcan(s).   清空回收站
- `trash-list`          list trashed files.    列出回收站中的文件
- `trash-restore`       restore a trashed file.  还原回收站中的文件
- `trash-rm`  remove individual files from the trashcan. 删除回收站中的单个文件

参考：[https://github.com/andreafrancia/trash-cli](https://github.com/andreafrancia/trash-cli)


### 简易安装


依赖:

- Python 2.7 or Python 3
- setuptools

安装命令:
 
```sh 
[root@localhost ~]# easy_install trash-cli
```

### 源码安装


安装命令:

```sh
[root@localhost ~]# git clone https://github.com/andreafrancia/trash-cli.git
[root@localhost ~]# cd trash-cli
[root@localhost ~]# python setup.py install
```

### 使用方法


删除文件:

```sh
[root@localhost ~]# trash-put foo
```

列出回收站中的文件:

```sh
[root@localhost ~]# trash-list
2008-06-01 10:30:48 /root/bar
2008-06-02 21:50:41 /root/bar
2008-06-23 21:50:49 /root/foo
```

搜索回收站:

```sh
[root@localhost ~]# trash-list | grep foo
2007-08-30 12:36:00 /root/foo
2007-08-30 12:39:41 /root/foo
```

恢复回收站中的文件:

```sh
[root@localhost ~]# trash-restore
0 2007-08-30 12:36:00 /root/foo
1 2007-08-30 12:39:41 /root/bar
2 2007-08-30 12:39:41 /root/bar2
3 2007-08-30 12:39:41 /root/foo2
4 2007-08-30 12:39:41 /root/foo
What file to restore [0..4]: 4
$ ls foo
foo
```


清空回收站:

```sh
[root@localhost ~]# trash-empty
```

删除回收站中`<days>`天前的文件:

```sh
[root@localhost ~]# trash-empty <days>
```

示例:

```sh
[root@localhost ~]# date
Tue Feb 19 20:26:52 CET 2008
[root@localhost ~]# trash-list
2008-02-19 20:11:34 /home/einar/today
2008-02-18 20:11:34 /home/einar/yesterday
2008-02-10 20:11:34 /home/einar/last_week
[root@localhost ~]# trash-empty 7
[root@localhost ~]# trash-list
2008-02-19 20:11:34 /home/einar/today
2008-02-18 20:11:34 /home/einar/yesterday
[root@localhost ~]# trash-empty 1
[root@localhost ~]# trash-list
2008-02-19 20:11:34 /home/einar/today
```

仅删除匹配的文件:

```
[root@localhost ~]# trash-rm *.o

Note: you need to use quotes in order to protect the pattern from shell expansion.(你需要使用引号来保护模式免受shell扩展。)
```

配置`~/.bashrc`禁用`rm`命令
---------------------------

在`~/.bashrc`中重命名`rm`:

```sh
[root@localhost ~]# cat ~/.bashrc|grep 'trash-put'
alias rm='echo -e "Info:\033[31mrm can not be used, please use \033[32msafe-rm\033[0m or \033[32mtrash-put\033[0m\n"' 
[root@localhost ~]# source ~/.bashrc
[root@localhost ~]# rm
Info:rm can not be used, please use safe-rm or trash-put
```

## 禁止所有人使用`rm`命令

在`/etc/bashrc`中增加重命名：

```sh
[root@localhost ~]# tail -n 5 /etc/bashrc
alias rm='echo -e "Info:\033[31mrm can not be used, please use \033[32msafe-rm\033[0m or \033[32mtrash-put\033[0m\n"'
alias v.='vi ~/.bashrc'
alias s.='source ~/.bashrc && echo "reload OK"'
```
在`/etc/bashrc`中配置后，使用`rm`命令就会提示使用`safe-rm`或`trash-put`命令进行删除操作。

使用`rm`命令时的提示如下:


参考文献：

- [safe-rm](https://repo.or.cz/w/safe-rm.git)
- [trash-cli官网](https://github.com/andreafrancia/trash-cli)

