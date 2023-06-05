---
title: Supervisor
---

官方文档的项目描述：

> Supervisor is a client/server system that allows its users to monitor and control a number of processes on UNIX-like operating systems.
>
> It shares some of the same goals of programs like [*launchd*](http://supervisord.org/glossary.html#term-launchd), [*daemontools*](http://supervisord.org/glossary.html#term-daemontools), and [*runit*](http://supervisord.org/glossary.html#term-runit). Unlike some of these programs, it is not meant to be run as a substitute for `init` as “process id 1”. Instead it is meant to be used to control processes related to a project or a customer, and is meant to start like any other program at boot time.

即：

- `supervisor`是一个C/S系统，用于监控和管理Unix-like操作系统上面的一序列进程。
- `supervisor`的功能与`launchd`、`daemontools`、`runit`类似，但与这些程序不同的是，它不是作为“进程id 1”的init的替代品运行的。相反，它旨在用于控制与项目或客户相关的流程，并在启动时像任何其他程序一样启动。



## 1. 简介

- supervisor是一个Python第三方包，用于管理Unix系统上面的进程。
- pypi链接：[https://pypi.org/project/supervisor/](https://pypi.org/project/supervisor/)。
- 官方文档：[Supervisor: A Process Control System](http://supervisord.org/)
- 源码: [https://github.com/Supervisor/supervisor/](https://github.com/Supervisor/supervisor/)

我们主要参考官方文档，详细学习该工具的使用。



### 1.1 特性

- 方便/Convenience，不需要编写`rc.d`脚本，并且当程序崩溃后`rc.d`脚本不会自动重启该程序，但`supervisor`可以自动启动崩溃的程序。
- 准确/Accuracy，通常情况下很难获取程序的启停状态，PID文件也不是那么靠谱，而`supervisor`会以子进程的形式启动其管理的进程，所以其一直知道其子进程的启停状态，并且可以方便的查询到这些数据。
- 代表团机制/Delegation，代表团机制，可以通过配置允许不同权限的用户对相应的监控进程进行启动与管理。
- 流程组/Process Groups，进程经常需要以组的形成进行启停，有时候还有启停顺序。`supervisor`允许你为管理的程序设置启动优先级，可以将一组逻辑相关的进程作为一个单元停止和启动。
- 简单/Simple，`supervisor`通过ini配置文件来管理你的应用，并提供了多种人性化的配置选项。
- 集中管理/Centralized，`supervisor`可以让你在一个地方集中管理你的进程的启动、停止和监控，进程可以单独控制或者分组控制，你可以通过本地或远程命令行或Web接口来管理你的应用。
- 高效/Efficient，`supervisor`通过`fork/exec`方式产生子进程，子进程不能作为守护进程，当有子进程挂掉后，操作系统会立即通知`supervisor`，这与使用PID文件或者轮询来重启挂掉的应用是不一样的。
- 可扩展/Extensible，`supervisor`提供一个简单的事件通知协议，你可以使用任何语言来监控它，并且使用XML-RPC接口来控制`supervisor`。
- 兼容的/Compatible，`supervisor`不支持Windows系统，但支持主流的Unix-like操作系统，如Linux, Mac OS X, Solaris, FreeBSD等，`supervisor`完全由python编写，不需要C编译器支持。
- 经过时间考验的/Proven，`supervisor`一直积极地开发，已经经过时间的考验，并且被很多服务器使用。



### 1.2 组件

- `supervisord`, Supervisor服务器组件是`supervisord`，负责自己管理的子程序的启动、响应客户端的命令、重新启动崩溃或退出的子进程，记录进程的标准输入或标准输出日志，以及生成和处理子进程生命周期中相关的事件。
    - 对应的配置是文件通常位于`/etc/supervisord.conf`，此配置文件是“ Windows-ini”样式配置文件。因为配置文件中可能包含未加密的用户名和密码，请通过文件系统权限确保该文件安全。
- `supervisorctl`，Supervisor命令行客户端组件是`supervisorctl`，为Supervisor提供Shell接口。通过该命令行客户端，用户可以一次性连接到多个管理的子进程，控制子进程的启动、停止等，并获取Supervisor管理的所有进程的列表。
    - 命令行客户端通过Unix域套接字或TCP套接字与服务器通话。服务器端会在执行命令前验证用户身份。客户端进程通常使用与服务器相同的配置文件，在其中使用`[susterisorctl]`部分的任何配置文件都可以正常工作。
- `Web Server`，如果你启动了网络套接字，那么可以通过浏览器访问Supervisor Web用户界面。在配置文件中，激活了` [inet_http_server]`配置，那么通常情况下，可以通过 [http://localhost:9001/](http://localhost:9001/)  访问Supervisor Web用户界面，在该Supervisor Web用户界面上，可以查看进程状态，并控制进程的状态。
- `XML-RPC`接口，为Web UI提供服务的HTTP服务器同时提供了XML-RPC接口服务，该接口也可以用来查询和控制Supervisor管理的进程。详细可查看 [XML-RPC API Documentation](http://supervisord.org/api.html#xml-rpc)



### 1.3 平台要求

- Supervisor已经在Linux (Ubuntu 18.04), Mac OS X (10.4/10.5/10.6),  Solaris (10 for Intel) 和 FreeBSD 6.1 上面进行了测试. 可以在大部分的Unix系统上面正常运行。
- Supervisor不支持Windows系统。
- Supervisor旨在Python 3版本3.4或更高版本以及Python 2版本2.7上工作。

## 2. 安装

### 2.1 有网络访问权限安装

- 使用`pip`命令安装，可以直接使用`pip install supervisor`进行安装。
- 不使用`pip`命令安装，则你需要先在 [https://pypi.org/project/supervisor/#files](https://pypi.org/project/supervisor/#files) 下载安装包，然后进行解压，并使用`python setup.py install`安装，安装时会自动下载想着依赖包。



### 2.2 无网络访问权限安装

- 如果你的目标主机无网络访问权限，则应手动下载Supervisor的包及其依赖包，并上传到该服务器上，然后先安装依赖包再安装Supervisor包。相对比较麻烦。



### 2.3 安装发布版本

- 一些Linux发行版可以通过系统的软件包管理器来安装Supervisor。这些软件包是由第三方而不是Supervisor开发人员制作的。
- 你可以使用包管理工具来查看Supervisor是否可用。

```sh
# ubuntu系统
apt-cache show supervisor

# centos系统
yum info supervisor
```

- 通过软件包管理器安装Supervisor，通常落后于官方的版本。

我们尝试在CentOS7上面安装Supervisor:

```sh
# 安装epel源，你可以配置清华大学的镜像加速
# yum install epel-release -y

# 查看是否有supervisor包，可以看到查出supervisor包信息
# yum info supervisor
```

安装：

```sh
# yum install -y supervisor
```

可以看到，通过源安装时，会自动安装想着依赖。

查看安装的包以及相关文件：

```sh
# rpm -qa|grep supervisor
supervisor-3.4.0-1.el7.noarch
# rpm -ql supervisor
/etc/logrotate.d/supervisor  # meizhaohui comment: 日志切割配置文件
/etc/supervisord.conf  # meizhaohui comment: Supervisor配置文件
/etc/supervisord.d   # meizhaohui comment: Supervisor管理的应用（进程）的配置文件夹
/etc/tmpfiles.d/supervisor.conf
/usr/bin/echo_supervisord_conf  # meizhaohui comment: 打印Suervisor默认的配置文件
/usr/bin/pidproxy  # meizhaohui comment: pidproxy程序是一个启动进程的小垫片，在接收到信号后，将信号发送给pidfile中提供的pid,用于杀死Supervisor管理的进程自动创建的子进程
/usr/bin/supervisorctl  # meizhaohui comment: Supervisor客户端程序
/usr/bin/supervisord  # meizhaohui comment: Supervisor服务端程序
/usr/lib/python2.7/site-packages/supervisor  # meizhaohui comment: Supervisor的python程序代码目录
/usr/lib/systemd/system/supervisord.service   # meizhaohui comment: systemctl管理的Supervisor的服务配置文件
/usr/share/doc/supervisor-3.4.0   # meizhaohui comment: Supervisor的帮助文档
/var/log/supervisor   # meizhaohui comment: Supervisor的日志文件夹
/var/run/supervisor   # meizhaohui comment: Supervisor的pid文件
#
```

可以看到，已经自动生成了很多相关的文件，详细说明见上面的备注信息。

### 2.4 创建配置文件

- 一旦Supervisor安装完成，你就可以运行命令`echo_supervisord_conf`，它会打印出Supervisor的示例配置到您的终端输出上。

- 你也可以使用`echo_supervisord_conf > /etc/supervisord.conf`命令将示例配置重定向到配置文件中。

- 如果你没有`root`权限，那么就可以直接输出到当前目录，如`echo_supervisord_conf > supervisord.conf`，然后启动`supervisord`时通过指定`-c`选项来指定配置文件的位置。

- 如`supervisord -c supervisord.conf`，Supervisor通常会先搜索当前目录来查找配置文件，再去搜索其他位置。

- 一旦你生成了你的配置文件，那么就可以开始修改这个配置文件了。

    

## 3. 运行Supervisor

本章在解决如何运行`supervisord`和`supervisorctl`命令时使用了`BINDIR`作为参考。该目录是Python配置安装后对应的二进制目录。如果Python是通过命令`./configure --prefix=/usr/local/py; make; make install`安装的，那么`BINDIR`二进制目录通常是`/usr/local/py/bin`，Python解释器在不同的平台使用不同的`BINDIR`目录，你可以在安装过程中通过`setup.py install`的输出可看其位置。

上面可以看到，我们的几个二进制文件详情：

```sh
/usr/bin/echo_supervisord_conf  # meizhaohui comment: 打印Suervisor默认的配置文件
/usr/bin/pidproxy  # meizhaohui comment: pidproxy程序是一个启动进程的小垫片，在接收到信号后，将信号发送给pidfile中提供的pid,用于杀死Supervisor管理的进程自动创建的子进程
/usr/bin/supervisorctl  # meizhaohui comment: Supervisor客户端程序
/usr/bin/supervisord  # meizhaohui comment: Supervisor服务端程序
```

即知我们对应的`BINDIR`是`/usr/bin`目录。



### 3.1 增加管理程序

在`supervisord`为您做任何有用的事情之前，您需要将至少一个`program`程序块添加到其配置中。 `program`程序块部分会定义一个怎么是如何运行和管理的。 您只需要编辑`supervisord.conf`文件添加一个程序块即可。

一个最简单的程序是运行`cat`程序。 下面是`supervisord`运行`cat`程序的示例：

```ini
[program:foo]
command=/bin/cat
```

将该示例程序直接添加到`/etc/supervisord.conf`配置文件中，添加后查看最后几行：
```sh
# tail /etc/supervisord.conf
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = supervisord.d/*.ini

[program:foo]
command=/bin/cat
```

这是最简单的程序配置，因为它仅对一个命令设置了名称。程序配置有很多其他的配置，此处并没有展示出来，详细请参考 [`[program:x]` Section Settings](http://supervisord.org/configuration.html#programx-section) 。



### 3.2 运行supervisord

为了开始`supervisord`，请执行命令`$BINDIR/supervisord`，这样`supervisord`程序会作为守护进程运行，并与终端分离，并保存日志。

你也可以让`supervisord`在前台运行，这个时候则需要在启动时使用`-n`参数，这将有助于调试启动异常。

::: warning 警告

当`supervisord`启动时，它会首先在当前目录搜索配置文件。如果你安全意识强的话，建议使用`-c`参数来指定配置文件，这些将不会有人能够骗你去运行一个存在流氓病毒的`supervisord.conf`文件。当以`root`账号运行时，如果不指定`-c`参数，则会发出警告。

:::

为了验证以上问题，我们先看一下`supervisord`的帮助信息：

```sh
# supervisord --help
supervisord -- run a set of applications as daemons.

Usage: /bin/supervisord [options]

Options:
-c/--configuration FILENAME -- configuration file path (searches if not given)  # 指定配置文件路径
-n/--nodaemon -- run in the foreground (same as 'nodaemon=true' in config file)  # 在前台运行，不以守护进程运行
-h/--help -- print this usage message and exit  # 获取本帮助信息
-v/--version -- print supervisord version number and exit  # 打印版本信息
-u/--user USER -- run supervisord as this user (or numeric uid)  # 指定运行supervisord的用户或UID
-m/--umask UMASK -- use this umask for daemon subprocess (default is 022)  # 指定子进程的UMASK,默认022
-d/--directory DIRECTORY -- directory to chdir to when daemonized  # 指定守护进程在哪个目录执行
-l/--logfile FILENAME -- use FILENAME as logfile path  # 指定日志文件路径
-y/--logfile_maxbytes BYTES -- use BYTES to limit the max size of logfile  # 限制日志文件大小
-z/--logfile_backups NUM -- number of backups to keep when max bytes reached   # 指定日志文件备份数量
-e/--loglevel LEVEL -- use LEVEL as log level (debug,info,warn,error,critical)  # 设置日志级别
-j/--pidfile FILENAME -- write a pid file for the daemon process to FILENAME  # 指定守护进程PID文件
-i/--identifier STR -- identifier used for this instance of supervisord  # 标识supervisord实例
-q/--childlogdir DIRECTORY -- the log directory for child process logs  # 指定子程序日志文件路径
-k/--nocleanup --  prevent the process from performing cleanup (removal of
                   old automatic child log files) at startup.  # 不清理子程序日志文件
-a/--minfds NUM -- the minimum number of file descriptors for start success  # 启动成功后最小文件描述符的数值
-t/--strip_ansi -- strip ansi escape codes from process output  # 剥离转义输出
--minprocs NUM  -- the minimum number of processes available for start success # 启动时可使用的最小进程数量
--profile_options OPTIONS -- run supervisord under profiler and output
                             results based on OPTIONS, which  is a comma-sep'd
                             list of 'cumulative', 'calls', and/or 'callers',
                             e.g. 'cumulative,callers')  # 其他选项

#
```

可以看到，其有很多参数，我直接在后面加上中文注释信息。



#### 3.2.1 root用户不指定配置文件参数运行

我们尝试运行一下：

```sh
# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
# echo $?
0
# ps -ef|grep supervisord
root      7529     1  0 06:57 ?        00:00:00 /usr/bin/python /bin/supervisord
root      7566  3445  0 06:57 pts/0    00:00:00 grep --color=auto supervisord
#
```

可以看到，直接以`root`账号运行时，可以正常运行成功（可以看到supervisord的进程7529），但发出了警告！让我们指定`-c`参数来设置配置文件。

查询Supervisor管理的程序状态：

```sh
# 查询程序状态，可以看到foo应用还在运行，对应的pid是7535
# supervisorctl status
foo                              RUNNING   pid 7535, uptime 0:02:28

# 我们搜索一下正在运行的进程中的cat程序，可以看到其进程就是7535,说明与上面的状态是对应的
# ps -ef|grep cat|grep -v grep
root      7535  7529  0 06:57 ?        00:00:00 /bin/cat
```

可以看到，虽然我们启动`supervisord`时并有指定配置文件，其仍然搜索到了`/etc/supervisord.conf`配置文件，并成功运行了我们刚设置的`foo`应用。

我们停止`supervisord`进程：

```sh
# kill -9 7529
# supervisorctl status
unix:///var/run/supervisor/supervisor.sock refused connection
# ps -ef|grep supervisord
root      8519  3445  0 07:04 pts/0    00:00:00 grep --color=auto supervisord
```

可以看到停止`supervisord`进程后，客户端工具`supervisorctl`命令获取状态失败了。

```sh
# ps -ef|grep cat|grep -v grep
```

此时，由`supervisord`管理的应用进程也被停止了！



#### 3.2.2 root用户指定配置文件参数运行

使用`-c`参数指定配置文件：

```sh
# 指定配置文件启动Supervisord服务
# supervisord -c /etc/supervisord.conf
Unlinking stale socket /var/run/supervisor/supervisor.sock

# 查看supervisord进程
# ps -ef|grep supervisord|grep -v grep
root      6241     1  0 06:13 ?        00:00:00 /usr/bin/python /bin/supervisord -c /etc/supervisord.conf

# 查看状态
# supervisorctl status
foo                              RUNNING   pid 6244, uptime 0:00:17

# 查看运行的cat进程，可以看到cat进程的父进程是supervisord进程，这也说明了Supervisor管理的应用都是supervisord的子进程
# ps -ef|grep cat|grep -v grep
root      6244  6241  0 06:13 ?        00:00:00 /bin/cat
#
```

可以看到，此时Supervisor没有抛出警告信息。

使用`kill`命令将`supervisord`进程杀掉。

```sh
# kill -9 6241
# ps -ef|grep cat|grep -v grep
# ps -ef|grep supervisord|grep -v grep
```

杀掉`supervisord`进程后，其管理的子进程也会自动被杀掉。



#### 3.2.3 查看supervisord版本信息

查看版本信息：

```sh
# supervisord --version
3.4.0
# supervisord -v
3.4.0
```



#### 3.2.4 查看Supervisor日志文件

- Supervisor的默认日志文件夹是`/var/log/supervisor`，Supervisor的日志文件都存放在这个目录里面。``
- `/var/log/supervisor/supervisord.log`是Supervisor的日志文件。
- 可以通过`-l/--logfile FILENAME -- use FILENAME as logfile path  # 指定日志文件路径`来改变日志存放路径。

```sh
# ls -lh /var/log/supervisor/
total 4.0K
-rw-r--r-- 1 root root 1.6K Aug 12 06:13 supervisord.log
# cat /var/log/supervisor/supervisord.log
#
```

#### 3.2.5 root用户指定日志文件参数运行

尝试修改日志路径启动`supervisord`程序：

```sh
# 创建用于存放日志用的文件夹
# mkdir -p /srv/supervisor/

# 指定日志文件参数，启动supervisord服务
# supervisord -c /etc/supervisord.conf --logfile /srv/supervisor/supervisord.log
Unlinking stale socket /var/run/supervisor/supervisor.sock

# 可以看到，已经生成了日志文件
# ls -lh /srv/supervisor/supervisord.log
-rw-r--r-- 1 root root 797 Aug 12 06:44 /srv/supervisor/supervisord.log

# 查看日志文件内容
# cat /srv/supervisor/supervisord.log
```

此时，查看默认的日志文件最后10行：

```sh
# tail /var/log/supervisor/supervisord.log
#
```

可以看到，默认的日志文件并没有更新，日志只写入了我们提定的日志文件中，说明指定日志文件生效了。



#### 3.2.6 不在后台运行

有时，如果我们想调试`supervisord`启动程序，可以使用`-n/--nodaemon`参数，让其不在后台运行，也就是在前台运行：

```sh
# supervisord -c /etc/supervisord.conf -n
2022-08-12 06:49:51,924 CRIT Supervisor is running as root.  Privileges were not dropped because no user is specified in the config file.  If you intend to run as root, you can set user=root in the config file to avoid this message.
2022-08-12 06:49:51,924 WARN No file matches via include "/etc/supervisord.d/*.ini"
Unlinking stale socket /var/run/supervisor/supervisor.sock
2022-08-12 06:49:52,241 INFO RPC interface 'supervisor' initialized
2022-08-12 06:49:52,241 CRIT Server 'unix_http_server' running without any HTTP authentication checking
2022-08-12 06:49:52,242 INFO supervisord started with pid 11367
2022-08-12 06:49:53,244 INFO spawned: 'foo' with pid 11371
2022-08-12 06:49:54,245 INFO success: foo entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)

# 此时我按了一下Ctrl+C取消程序运行，supervisord收到信号，终止了程序
^C2022-08-12 06:51:42,615 WARN received SIGINT indicating exit request
2022-08-12 06:51:42,615 INFO waiting for foo to die
2022-08-12 06:51:42,616 INFO stopped: foo (terminated by SIGTERM)

# 此时可以看到，supervisord进程已经没有了
# ps -ef|grep supervisord
root     11651  6163  0 06:51 pts/0    00:00:00 grep --color=auto supervisord
```



#### 3.2.7 指定PID文件运行

可以通过指定`-j/--pidfile FILENAME`参数来设置`supervisord`运行时的PID文件：

```sh
# supervisord -c /etc/supervisord.conf --pidfile /srv/supervisor/pid
# ps -ef|grep supervisord
root      4550     1  0 13:15 ?        00:00:00 /usr/bin/python /bin/supervisord -c /etc/supervisord.conf --pidfile /srv/supervisor/pid
root      4580  3957  0 13:15 pts/0    00:00:00 grep --color=auto supervisord
# cat /srv/supervisor/pid
4550
# supervisorctl status
foo                              RUNNING   pid 4553, uptime 0:14:37
```

可以看到`/srv/supervisor/pid`里面的内容4550就是对应supervisord进程的PID了。

停止正在运行的`supervisord`程序：

```sh
# kill -9 4550
# ps -ef|grep supervisord
root      7640  3957  0 13:37 pts/0    00:00:00 grep --color=auto supervisord
```



#### 3.2.8 以systemctl服务运行

每次启动都指定参数非常的麻烦，当需要指定参数越来越多的话，就建议使用配置文件来设置配置，并以服务的形式运行Supervisord程序。

查看对应的服务文件：

```sh
# cat /usr/lib/systemd/system/supervisord.service
[Unit]
Description=Process Monitoring and Control Daemon
After=rc-local.service nss-user-lookup.target

[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf

[Install]
WantedBy=multi-user.target
```

查看服务状态并启动：

```sh
# 查看supervisord服务状态，可以看到当前未启动
# systemctl status supervisord.service
● supervisord.service - Process Monitoring and Control Daemon
   Loaded: loaded (/usr/lib/systemd/system/supervisord.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
   
# 启动supervisord服务 
# systemctl start supervisord.service

# 查看supervisord服务状态
# systemctl status supervisord.service
# 设置开机启动supervisord服务
# systemctl enable supervisord.service
Created symlink from /etc/systemd/system/multi-user.target.wants/supervisord.service to /usr/lib/systemd/system/supervisord.service.
```

此时查看一下Supervisor状态：

```sh
# supervisorctl status
foo                              RUNNING   pid 7786, uptime 0:03:40
```

可以看到，通过服务的方式也同样可以启动`supervisord`并运行管理的程序。

停止`supervisord`服务：

```sh
# 停止supervisord服务
# systemctl stop supervisord.service

# 查看supervisord服务状态
# systemctl status supervisord.service

 
# 查看supervisor状态，因为服务已经停止，所有些时查看状态看不到管理的程序 
# supervisorctl status
unix:///var/run/supervisor/supervisor.sock no such file
```

### 3.3 运行supervisorctl

- 通过`supervisorctl`命令可以控制Supervisor管理的应用，可以通过`help`来获取更多的命令行信息。

```sh
# supervisorctl help
#
```

可以看到`supervisorctl`支持很多子命令。

#### 3.3.1 设置`supervisorctl`别名`spctl`

- 每次都输入`supervisorctl`太麻烦，命令太长，我们设置一个别名`spctl`。

```sh
alias spctl='supervisorctl'
```

将以上命令加入到`~/.bashrc`配置文件中，然后使用`source ~/.bashrc`重新加载配置，此时就可以直接使用`spctl`命令了。

启动`supervisord`服务：

```sh
# systemctl start supervisord.service
# systemctl status supervisord.service
```

此时，使用我们刚创建的别名查看Supervisor管理的应用：

```sh
# spctl status
foo                              RUNNING   pid 30840, uptime 0:00:51
```

可以看到，别名可以正常使用。



#### 3.3.2 指定配置文件

Supervisor默认会读到`/etc/supervisord.conf`，我们复制一份该文件到`/root`目录下，并作一点修改，然后指定配置文件：

```sh
# 复制配置文件
# cp /etc/supervisord.conf .

# 搜索之前指定的测试应用
# grep 'foo' supervisord.conf
[program:foo]

# 将应用改个名字
# sed -i  's/foo/bar/g' supervisord.conf

# 查看新的配置内容
# grep 'bar' supervisord.conf
[program:bar]
```

指定配置文件;

```sh
# spctl -c /root/supervisord.conf
foo                              RUNNING   pid 30840, uptime 2 days, 6:09:12
supervisor>
supervisor> exit
```

可以看到，此时指定配置文件并没有什么用。由于我们此处并没有指定任何动作，supervisor进程进入到交互模式了。



#### 3.3.3 进入交互模式

可以通过`-i/--interactive`参数进入到交互模式：

```sh
# 进入到交互模式下
# spctl -i
foo                              RUNNING   pid 30840, uptime 2 days, 6:15:41

# 获取帮助信息，可以看到，有很多命令
supervisor> help

default commands (type help <topic>):
=====================================
add    exit      open  reload  restart   start   tail
avail  fg        pid   remove  shutdown  status  update
clear  maintail  quit  reread  signal    stop    version

# 查看日志最后输出
supervisor> tail foo

# 查看状态
supervisor> status
foo                              RUNNING   pid 30840, uptime 2 days, 6:15:59

# 停止foo应用
supervisor> stop foo
foo: stopped

# 再次查看状态
supervisor> status
foo                              STOPPED   Aug 15 10:37 PM

# 启动foo应用
supervisor> start foo
foo: started

# 再次查看状态
supervisor> status
foo                              RUNNING   pid 27309, uptime 0:00:04

# 退出交互模式
supervisor> exit
#
```

#### 3.3.4  **supervisorctl** Actions动作

直接复制官网的解释：

```sh
help

    Print a list of available actions # 打印有效的动作列表

help <action>

    Print help for <action> # 打印某个动作的帮助信息

add <name> [...]

    Activates any updates in config for process/group # 激活配置文件中指定的某个应用或组

remove <name> [...]

    Removes process/group from active config  # 移除配置文件中指定的某个应用或组

update

    Reload config and add/remove as necessary, and will restart affected programs # 更新应用

update all

    Reload config and add/remove as necessary, and will restart affected programs # 更新所有应用

update <gname> [...]

    Update specific groups, and will restart affected programs # 更新指定群组

clear <name>

    Clear a process’ log files.  # 清理某个应用的日志文件

clear <name> <name>

    Clear multiple process’ log files # 清理多个应用的日志文件

clear all

    Clear all process’ log files # 清理所有应用的日志文件

fg <process>

    Connect to a process in foreground mode Press Ctrl+C to exit foreground # 将某个进程在前台运行

pid

    Get the PID of supervisord. # 获取supervisord的pid

pid <name>

    Get the PID of a single child process by name. # 获取某个子应用的pid

pid all

    Get the PID of every child process, one per line. # 获取所有子应用的pid

reload

    Restarts the remote supervisord # 重启supervisord

reread

    Reload the daemon’s configuration files, without add/remove (no restarts)  # 重新读取配置文件，但不重启

restart <name>

    Restart a process Note: restart does not reread config files. For that, see reread and update. # 重启应用，此时不会重新读取配置文件

restart <gname>:*

    Restart all processes in a group Note: restart does not reread config files. For that, see reread and update. # 重启某个组中所有应用，此时不会重新读取配置文件

restart <name> <name>

    Restart multiple processes or groups Note: restart does not reread config files. For that, see reread and update. # 重启多个应用，此时不会重新读取配置文件

restart all

    Restart all processes Note: restart does not reread config files. For that, see reread and update. # 重启所有应用，此时不会重新读取配置文件

signal

    No help on signal # 信号，无帮助信息

start <name>

    Start a process  # 启动某个应用

start <gname>:*

    Start all processes in a group  # 启动某个应用组

start <name> <name>

    Start multiple processes or groups  # 启动多个应用

start all

    Start all processes  # 启动所有应用

status

    Get all process status info.  # 查看所有应用状态信息

status <name>

    Get status on a single process by name.  # 查看某个应用的状态信息

status <name> <name>

    Get status on multiple named processes.  # 查询多个应用的状态信息

stop <name>

    Stop a process  # 停止某个应用

stop <gname>:*

    Stop all processes in a group  # 停止某个应用组

stop <name> <name>

    Stop multiple processes or groups # 停止多个应用或组

stop all

    Stop all processes # 停止所有应用

tail [-f] <name> [stdout|stderr] (default stdout)

    Output the last part of process logs Ex: tail -f <name> Continuous tail of named process stdout Ctrl-C to exit. tail -100 <name> last 100 bytes of process stdout tail <name> stderr last 1600 bytes of process stderr # 查看日志
```



### 3.4 Signals信号

- 可以向`supervisord`程序发送信号，让其执行一些操作。
- 你可以发送任何以下定义的信号给`supervisord`程序或者Supervisor管理的应用程序。

#### 3.4.1 Signal Handlers信号处理

- `SIGTERM`，此信号会导致`supervisord`及其子进程都被关闭。
- `SIGINT`，此信号会导致`supervisord`及其子进程都被关闭。
- `SIGQUIT`，此信号会导致`supervisord`及其子进程都被关闭。
- `SIGHUP`，此信号会导致`supervisord`停止所有子进程(`supervisord`主进程不会停掉)，并重新加载配置，然后启动所有程序。
- `SIGUSR2`，此信号会导致`supervisord`停止，并重新打开主日志和子日志文件。

为了演示信号，我们来构建另外两个应用。

```sh
[root@master ~]# tail /etc/supervisord.conf
files = supervisord.d/*.ini

[program:foo]
command=/bin/cat

[program:app1]
command=/bin/cat

[program:app2]
command=/bin/cat
```

在`/etc/supervisord.conf`中增加`app1`和`app2`应用。

然后重新加载配置并查看状态：

```sh
# 重新加载配置
# spctl reload
Restarted supervisord

# 查看状态
# spctl status
app1                             RUNNING   pid 13708, uptime 0:00:03
app2                             RUNNING   pid 13707, uptime 0:00:03
foo                              RUNNING   pid 13706, uptime 0:00:03
```

可以看到，此时三个应用都启动起来了！

查看`supervisord`的pid:

```sh
# 通过进程查看supervisord的pid，可以看到是13125
# ps -ef|grep supervisord|grep -v grep
root     13125     1  0 19:49 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf

# 通过客户端命令查看，也可以看到supervisord的pid是13125
# spctl pid
13125
```

我们使用`kill`命令向`supervisord`发送信号。



#### 3.4.2 SIGTERM信号

直接使用`kill -s SIGTERM $(spctl pid)`可以发送信号`SIGTERM`信号：

```sh
# kill -s SIGTERM $(spctl pid)
# ps -ef|grep supervisord|grep -v grep
# ps -ef|grep cat
root     15119 12728  0 20:03 pts/0    00:00:00 grep --color=auto cat
# spctl pid
unix:///var/run/supervisor/supervisor.sock no such file
# spctl status
unix:///var/run/supervisor/supervisor.sock no such file
```

此时，可以看到，此时已经没有`supervisord`进程了，`cat`进程也没有，客户端命令也没有获取到信息。说明发送`SIGTERM`信号后，Supervisor服务端及其管理的应用都会停止。



#### 3.4.3 SIGINT信号

由于上面Supervisor服务端已经停止了，由于我们此处要多次启动`supervisord`服务，因此编写快捷命令：

```sh
# tail -n 4 ~/.bashrc
# 启动supervisord服务
alias spstart='systemctl start supervisord.service'
# 查看supervisord进程
alias spstatus='ps -ef|grep supervisord|grep -v grep'
```

使用`source ~/.bashrc`重新加载配置。

然后，就可以使用`spstart`启动`supervisord`服务：

```sh
# spstart
# spstatus
root     16372     1  0 20:12 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
# spctl pid
16372
# spctl status
app1                             RUNNING   pid 16375, uptime 0:00:14
app2                             RUNNING   pid 16374, uptime 0:00:14
foo                              RUNNING   pid 16373, uptime 0:00:14
```

直接使用`kill -s SIGINT $(spctl pid)`可以发送`SIGINT`信号：

```sh
# kill -s SIGINT $(spctl pid)
# spstatus
# ps -ef|grep cat
root     17597 12728  0 20:21 pts/0    00:00:00 grep --color=auto cat
# spctl pid
unix:///var/run/supervisor/supervisor.sock no such file
# spctl status
unix:///var/run/supervisor/supervisor.sock no such file
```

此时，可以看到，此时已经没有`supervisord`进程了，`cat`进程也没有，客户端命令也没有获取到信息。说明发送`SIGINT`信号后，Supervisor服务端及其管理的应用都会停止。



#### 3.4.4 SIGQUIT信号

直接使用`kill -s SIGQUIT $(spctl pid)`可以发送`SIGQUIT`信号：

```sh
# spstart
# spstatus
root     17925     1  0 20:23 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
# spctl pid
17925
# spctl status
app1                             RUNNING   pid 17933, uptime 0:00:16
app2                             RUNNING   pid 17932, uptime 0:00:16
foo                              RUNNING   pid 17931, uptime 0:00:16

# 发送信号
# kill -s SIGQUIT $(spctl pid)
# spstatus
# ps -ef|grep cat
root     18085 12728  0 20:24 pts/0    00:00:00 grep --color=auto cat
# spctl pid
unix:///var/run/supervisor/supervisor.sock no such file
# spctl status
unix:///var/run/supervisor/supervisor.sock no such file
```

此时，可以看到，重新启动`supervisord`服务后，发送信号后，此时已经没有`supervisord`进程了，`cat`进程也没有，客户端命令也没有获取到信息。说明发送`SIGQUIT`信号后，Supervisor服务端及其管理的应用都会停止。



#### 3.4.5 SIGHUP信号

直接使用`kill -s SIGHUP $(spctl pid)`可以发送`SIGHUP`信号：

```sh
# spstart
# spstatus
root     18482     1  0 20:27 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
# spctl pid
18482
# spctl status
app1                             RUNNING   pid 18490, uptime 0:00:14
app2                             RUNNING   pid 18489, uptime 0:00:14
foo                              RUNNING   pid 18488, uptime 0:00:14

# 停掉一个应用
# spctl stop foo
foo: stopped
# spctl status
app1                             RUNNING   pid 18490, uptime 0:00:26
app2                             RUNNING   pid 18489, uptime 0:00:26
foo                              STOPPED   Aug 18 08:28 PM

# 发送信号
# kill -s SIGHUP $(spctl pid)

# 查看supervisord进程，可以看到，其进程并没有发生变化，仍然是18482
# spstatus
root     18482     1  0 20:27 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
# spctl pid
18482

# 查看管理的应用状态，可以看到，三个应该都重新启动了，pid发生了变化，并且刚才手动停掉的foo应用，也被重新拉起来了
# spctl status
app1                             RUNNING   pid 18938, uptime 0:00:22
app2                             RUNNING   pid 18937, uptime 0:00:22
foo                              RUNNING   pid 18936, uptime 0:00:22
```

此时，可以看到，重新启动`supervisord`服务后，发送信号后，此时`supervisord`进程没有停掉，进程仍然运行着，管理的子应用都被重新启动了。说明发送`SIGHUP`信号后，Supervisor服务端进程保持不变，其管理的应用都会重新启动。



#### 3.4.6 SIGUSR2信号

直接使用`kill -s SIGUSR2 $(spctl pid)`可以发送`SIGUSR2`信号：

```sh
# 停掉一个应用
# spctl stop foo
foo: stopped
# spctl status
app1                             RUNNING   pid 18938, uptime 0:06:11
app2                             RUNNING   pid 18937, uptime 0:06:11
foo                              STOPPED   Aug 18 08:36 PM

# 发送信号
# kill -s SIGUSR2 $(spctl pid)

# 查看supervisord状态，可以看到其pid未变化
# spstatus
root     18482     1  0 20:27 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
# spctl pid
18482

# Supervisor管理的应用的pid也没有变化
# spctl status
app1                             RUNNING   pid 18938, uptime 0:06:53
app2                             RUNNING   pid 18937, uptime 0:06:53
foo                              STOPPED   Aug 18 08:36 PM
```

此时，可以看到，重新启动`supervisord`服务后，发送信号后，此时`supervisord`进程没有停掉，进程仍然运行着，管理的子应用也没有发生变化，pid没有改变。说明发送`SIGUSR2`信号后，Supervisor服务端进程和应用进程保持不变。

该信号用于重新打开日志文件，当日志文件非常大时，可以使用该信号来释放日志文件空间。因为此处的三个应用并没有日志文件，所有看不到效果。

但看`supervisor`的主日志，可以看到增加了以下日志：

```sh
# tail /var/log/supervisor/supervisord.log
2022-08-18 20:30:38,586 INFO spawned: 'foo' with pid 18936
2022-08-18 20:30:38,587 INFO spawned: 'app2' with pid 18937
2022-08-18 20:30:38,588 INFO spawned: 'app1' with pid 18938
2022-08-18 20:30:39,589 INFO success: foo entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18 20:30:39,589 INFO success: app2 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18 20:30:39,589 INFO success: app1 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18 20:36:43,843 INFO waiting for foo to stop
2022-08-18 20:36:43,843 INFO stopped: foo (terminated by SIGTERM)
2022-08-18 20:37:13,389 INFO received SIGUSR2 indicating log reopen request
2022-08-18 20:37:13,389 INFO supervisord logreopen
```

可以看到，最后两行日志中显示了`supervisord logreopen`！！



### 3.5 运行时安全

- 开发人员已竭尽全力确保Supervisor不会导致意想不到的特权升级。
- 由于`supervisord`在其配置文件中可以指定任意路径，并可写入数据，这可能导致符号链接攻击漏洞。
- 在指定配置文件路径时，应非常小心，确保非特权用户无法读到这些配置文件。

## 4. 配置文件

- Supervisor的配置文件通常命名为`supervisord.conf`。`supervisord`和`supervisorctl`都会使用该配置文件。
- 如果在启动`supervisord`时没指定`-c`参数，则会按以下顺序寻找配置文件，并使用找到的第一个配置文件。

1. `../etc/supervisord.conf` (Relative to the executable)
1. `../supervisord.conf` (Relative to the executable)
1. `$CWD/supervisord.conf`
1. `$CWD/etc/supervisord.conf`
1. `/etc/supervisord.conf`
1. `/etc/supervisor/supervisord.conf` (since Supervisor 3.3.0)

::: tip 提示

经过测试总结后，可知Supervisor搜索配置文件的顺序：

1. /etc/supervisord.conf
1. /supervisord.conf
1. supervisord.conf
1. etc/supervisord.conf
1. /etc/supervisor/supervisord.conf

:::

### 4.1 配置文件搜索顺序

为了测试，我们先看一下可执行文件所有目录：

```sh
[root@master ~]# whereis supervisord
supervisord: /usr/bin/supervisord /etc/supervisord.d /etc/supervisord.conf
[root@master ~]# whereis supervisorctl
supervisorctl: /usr/bin/supervisorctl
```

可以看到可执行文件位于`/usr/bin`目录。那么其父目录是`/usr`，以家目录`~`作为当前工作目录。

然后，我们创建以下三个目录：`/usr/etc`、`~/etc`和`/etc/supervisor`。

```sh
[root@master ~]# mkdir /usr/etc ~/etc /etc/supervisor
```

我们注释掉`/etc/supervisord.conf`原来的三个应用，然后增加一个新应用：

```sh
[root@master ~]# tail -n 11 /etc/supervisord.conf
; [program:foo]
; command=/bin/cat
;
; [program:app1]
; command=/bin/cat
;
; [program:app2]
; command=/bin/cat

[program:app5]
command=/bin/cat
```

按搜索顺序，设置不同的app序号，将`/etc/supervisor.conf`复制到其他几个位置：

```sh
[root@master ~]# cp /etc/supervisord.conf /usr/etc/
[root@master ~]# cp /etc/supervisord.conf /usr/
[root@master ~]# cp /etc/supervisord.conf ~
[root@master ~]# cp /etc/supervisord.conf ~/etc/
[root@master ~]# cp /etc/supervisord.conf /etc/supervisor/
```

然后，对以上几个位置的`supervisord.conf`进行修改，修改后，分别查看最后两行的内容：

```sh
[root@master ~]# tail -n 2 /usr/etc/supervisord.conf
[program:app1]
command=/bin/cat
[root@master ~]# tail -n 2 /usr/supervisord.conf
[program:app2]
command=/bin/cat
[root@master ~]# tail -n 2 ~/supervisord.conf
[program:app3]
command=/bin/cat
[root@master ~]# tail -n 2 ~/etc/supervisord.conf
[program:app4]
command=/bin/cat
[root@master ~]# tail -n 2 /etc/supervisord.conf
[program:app5]
command=/bin/cat
[root@master ~]# tail -n 2 /etc/supervisor/supervisord.conf
[program:app6]
command=/bin/cat
[root@master ~]#
```

先停掉之前的`supervisord`服务：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 18938, uptime 1 day, 1:49:34
app2                             RUNNING   pid 18937, uptime 1 day, 1:49:34
foo                              STOPPED   Aug 18 08:36 PM
[root@master ~]# spctl pid
18482
[root@master ~]# kill -9 18482
[root@master ~]# spctl pid
unix:///var/run/supervisor/supervisor.sock refused connection
```

现在已经配置有以上6个配置文件，直接启动`supervisord`:

```sh
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
Unlinking stale socket /var/run/supervisor/supervisor.sock

# 可以看到app5启动了，这是上面第5个配置文件 /etc/supervisord.conf 中配置的应用
[root@master ~]# spctl status
app5                             RUNNING   pid 3680, uptime 0:00:09

# 查看日志
[root@master ~]# tail /var/log/supervisor/supervisord.log
2022-08-19 22:22:35,553 CRIT Supervisor is running as root.  Privileges were not dropped because no user is specified in the config file.  If you intend to run as root, you can set user=root in the config file to avoid this message.
2022-08-19 22:22:35,553 WARN No file matches via include "/etc/supervisord.d/*.ini"
2022-08-19 22:22:35,911 INFO RPC interface 'supervisor' initialized
2022-08-19 22:22:35,911 CRIT Server 'unix_http_server' running without any HTTP authentication checking
2022-08-19 22:22:35,911 INFO daemonizing the supervisord process
2022-08-19 22:22:35,912 INFO supervisord started with pid 3674
2022-08-19 22:22:36,914 INFO spawned: 'app5' with pid 3680
2022-08-19 22:22:37,915 INFO success: app5 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)

# 发送信号，停掉supervisor及其应用
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

现在开始做改变：

```sh
[root@master ~]# mv /etc/supervisord.conf{,.bak}
[root@master ~]# ll /etc/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:18 /etc/supervisord.conf.bak
```

此时再启动`supervisord`服务：

```sh
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
  
# 可以看到app3启动了，这是上面第3个配置文件 ~/supervisord.conf 中配置的应用  
[root@master ~]# spctl status
app3                             RUNNING   pid 5895, uptime 0:00:05

# 发送信号，停掉supervisor及其应用
[root@master ~]# kill -s SIGTERM $(spctl pid)
```



现在再将第3个配置文件重命名：

```sh
[root@master ~]# mv ~/supervisord.conf{,.bak}
[root@master ~]# ll ~/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:14 /root/supervisord.conf.bak
```

此时再启动`supervisord`服务：

```sh
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
  
# 可以看到app4启动了，这是上面第4个配置文件 ~/etc/supervisord.conf 中配置的应用  
[root@master ~]# spctl status
app4                             RUNNING   pid 7010, uptime 0:00:18

# 发送信号，停掉supervisor及其应用
[root@master ~]# kill -s SIGTERM $(spctl pid)
```



现在再将第4个配置文件重命名：

```sh
[root@master ~]# mv ~/etc/supervisord.conf{,.bak}
[root@master ~]# ll ~/etc/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:18 /root/etc/supervisord.conf.bak
```

此时再启动`supervisord`服务：

```sh
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
  
# 可以看到app6启动了，这是上面第6个配置文件 /etc/supervisor/supervisord.conf 中配置的应用  
[root@master ~]# spctl status
app6                             RUNNING   pid 7744, uptime 0:00:04

# 发送信号，停掉supervisor及其应用
[root@master ~]# kill -s SIGTERM $(spctl pid)
```



现在再将第6个配置文件重命名：

```sh
[root@master ~]# mv /etc/supervisor/supervisord.conf{,.bak}
[root@master ~]# ll /etc/supervisor/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:14 /etc/supervisor/supervisord.conf.bak
```

此时再启动`supervisord`服务：

```sh
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
Error: No config file found at default paths (/etc/supervisord.conf, /supervisord.conf, supervisord.conf, etc/supervisord.conf, /etc/supervisord.conf, /etc/supervisor/supervisord.conf); use the -c option to specify a config file at a different path
For help, use /bin/supervisord -h
[root@master ~]# spctl status
http://localhost:9001 refused connection
```

此时，可以看到，`supervisord`没能启动起来！！！

看上面的提示，在默认的路径 (/etc/supervisord.conf, /supervisord.conf, supervisord.conf, etc/supervisord.conf, /etc/supervisord.conf, /etc/supervisor/supervisord.conf)中没有找到配置文件。那么我需要重新确认一下路径1和路径2的位置。



```sh
[root@master ~]# ls  -ld /bin
lrwxrwxrwx. 1 root root 7 Mar  7  2019 /bin -> usr/bin
[root@master ~]# ls -lah /bin/supervisord
-rwxr-xr-x 1 root root 318 Mar 11  2020 /bin/supervisord
```

那么相对于可执行文件的两个路径就是`/etc/supervisord.conf`和`/supervisord.conf`，而不是`/usr/etc/supervisord.conf`和`/usr/supervisord.conf`。

那么我们需要重新整理一下各个位置的`supervisord.conf`配置文件。此时，可以看到路径1和路径5是相同的路径。

我们修改一下`/etc/supervisord.conf`的app名称。

查看路径1和路径5的配置文件最后两行内容：

```sh
[root@master ~]# tail -n 2 /etc/supervisord.conf
[program:app1_5]
command=/bin/cat
```

查看路径2配置文件最后两行内容：

```sh
[root@master ~]# tail -n 2 /supervisord.conf
[program:app2]
command=/bin/cat
```



查看路径3配置文件最后两行内容：

```sh
[root@master ~]# tail -n 2 ~/supervisord.conf
[program:app3]
command=/bin/cat
```


查看路径4配置文件最后两行内容：

```sh
[root@master ~]# tail -n 2 ~/etc/supervisord.conf
[program:app4]
command=/bin/cat
```


查看路径6配置文件最后两行内容：

```sh
[root@master ~]# tail -n 2 /supervisord.conf
[program:app6]
command=/bin/cat
```



此时，再进行测试：

```sh
# 停止之前运行的Supervisor应用
[root@master ~]# kill -s SIGTERM $(spctl pid)
[root@master ~]# spctl status
unix:///var/run/supervisor/supervisor.sock no such file

# 启动应用
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '

# 启动了app1_5应用
# 可以看到，首先搜索到了 /etc/supervisord.conf 配置文件
[root@master ~]# spctl status
app1_5                           RUNNING   pid 28799, uptime 0:00:03
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

对`/etc/supervisord.conf`进行重命名，然后再次启动应用：

```sh
[root@master ~]# mv /etc/supervisord.conf{,.bak}
[root@master ~]# ll /etc/supervisord.conf.bak
-rw-r--r-- 1 root root 8102 Aug 20 09:16 /etc/supervisord.conf.bak
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '

# 可以看到，搜索到顺序2的 /supervisord.conf 配置文件
[root@master ~]# spctl status
app2                             RUNNING   pid 29343, uptime 0:00:04
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

对`/supervisord.conf`进行重命名，然后再次启动应用：

```sh
[root@master ~]# mv /supervisord.conf /supervisord.conf.bak
[root@master ~]# ll /supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:13 /supervisord.conf.bak
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '

# 可以看到，搜索到顺序3的 ~/supervisord.conf 配置文件
[root@master ~]# spctl status
app3                             RUNNING   pid 29788, uptime 0:00:02
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

对`~/supervisord.conf`进行重命名，然后再次启动应用：

```sh
[root@master ~]# mv ~/supervisord.conf{,.bak}
[root@master ~]# ll ~/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 19 22:14 /root/supervisord.conf.bak
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '

# 可以看到，搜索到顺序4的 ~/etc/supervisord.conf 配置文件
[root@master ~]# spctl status
app4                             RUNNING   pid 30145, uptime 0:00:02
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

对`~/etc/supervisord.conf`进行重命名，然后再次启动应用：

```sh
[root@master ~]# mv ~/etc/supervisord.conf{,.bak}
[root@master ~]# ll ~/etc/supervisord.conf.bak
-rw-r--r-- 1 root root 8100 Aug 20 08:48 /root/etc/supervisord.conf.bak
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
# 可以看到，搜索到顺序6的 /etc/supervisor/supervisord.conf 配置文件
[root@master ~]# spctl status
app6                             RUNNING   pid 30472, uptime 0:00:02
[root@master ~]# kill -s SIGTERM $(spctl pid)
```

对`/etc/supervisor/supervisord.conf`进行重命名，然后再次启动应用：

```sh
[root@master ~]# mv /etc/supervisor/supervisord.conf{,.bak}
[root@master ~]# supervisord
/usr/lib/python2.7/site-packages/supervisor/options.py:461: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
  'Supervisord is running as root and it is searching '
Error: No config file found at default paths (/etc/supervisord.conf, /supervisord.conf, supervisord.conf, etc/supervisord.conf, /etc/supervisord.conf, /etc/supervisor/supervisord.conf); use the -c option to specify a config file at a different path
For help, use /bin/supervisord -h

# 可以看到，所有搜索路径中都找不到配置文件，启动失败，查询不到相关的应用
[root@master ~]# spctl status
http://localhost:9001 refused connection
[root@master ~]#
```

通过以上测试可以发现，Supervisor确实是按文档中列出的搜索顺序搜索配置文件的。

我们再次确认一下Supervisor搜索配置文件的顺序：

1. /etc/supervisord.conf
2. /supervisord.conf
3. supervisord.conf
4. etc/supervisord.conf
5. /etc/supervisor/supervisord.conf



通常我们使用默认的`/etc/supervisord.conf`作为配置文件即可，不需要在别的位置设置配置文件。将测试过程的配置文件和目录删除掉，擦除测试痕迹。

```sh
[root@master ~]# mv /etc/supervisord.conf.bak /etc/supervisord.conf
[root@master ~]# rm -f /supervisord.conf.bak
[root@master ~]# rm -f supervisord.conf.bak
[root@master ~]# rm -rf etc/supervisord.conf.bak etc
[root@master ~]# rm -rf /etc/supervisor
```

此时，再使用`systemctl`启动`supervisord`服务：

```sh
[root@master ~]# systemctl start supervisord
[root@master ~]# systemctl status supervisord
● supervisord.service - Process Monitoring and Control Daemon
   Loaded: loaded (/usr/lib/systemd/system/supervisord.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2022-08-20 09:48:38 CST; 5s ago
  Process: 1012 ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf (code=exited, status=0/SUCCESS)
 Main PID: 1015 (supervisord)
    Tasks: 2
   Memory: 10.9M
   CGroup: /system.slice/supervisord.service
           ├─1015 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
           └─1016 /bin/cat
[root@master ~]# spctl status
app1_5                           RUNNING   pid 1016, uptime 0:00:13
```

可以看到，此时使用默认的配置文件启动了`app1_5`应用。



### 4.2 文件格式

`Supervisor.conf`是一个Windows-INI风格的(Python ConfigParser)文件。它有节(每个节由`[header]`表示)和节中的键/值对。下面描述各节及其允许值。



#### 4.2.1  环境变量

- 在启动`supervisord`时，可以在配置文件中使用环境变量。
- 在配置文件中使用Python字符串表达式语法`%(ENV_X)s`来引用某个环境变量。

增加快捷命令，我们需要多次停止`supervisord`服务：

```sh
alias spstop='kill -s SIGTERM $(spctl pid)'
```

使用`spstop`就可以快速停止`supervisord`服务。

##### 4.2.1.1 获取linux环境变量(失败)

我们修改`/etc/supervisord.conf`,设置一个应用：

```sh
# 设置app应用，不停的ping百度的网站
[root@master ~]# tail -n 2 /etc/supervisord.conf
[program:app]
command=/bin/ping %(ENV_HOST)s
[root@master ~]#

# 我们手动看设置的HOST环境变量，是`baidu.com`
[root@master ~]# echo $HOST
baidu.com

# 手动ping一下百度
[root@master ~]# ping -c 3 $HOST
PING baidu.com (110.242.68.66) 56(84) bytes of data.
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=1 ttl=51 time=25.2 ms
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=2 ttl=51 time=26.0 ms
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=3 ttl=51 time=25.2 ms

--- baidu.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 25.200/25.485/26.040/0.392 ms
[root@master ~]#
```

启动`supervisord`服务：

```sh
# 尝试启动服务
[root@master ~]# spstart
Job for supervisord.service failed because the control process exited with error code. See "systemctl status supervisord.service" and "journalctl -xe" for details.

# 查看服务状态，并查看详细日志，可以看到抛出了异常
[root@master ~]# systemctl status supervisord.service -l
● supervisord.service - Process Monitoring and Control Daemon
   Loaded: loaded (/usr/lib/systemd/system/supervisord.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sat 2022-08-20 16:57:13 CST; 14s ago
  Process: 16286 ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf (code=exited, status=2)
 Main PID: 9480 (code=exited, status=0/SUCCESS)

Aug 20 16:57:13 master.hellogitlab.com systemd[1]: Starting Process Monitoring and Control Daemon...
Aug 20 16:57:13 master.hellogitlab.com supervisord[16286]: Error: Format string '/bin/ping %(ENV_HOST)s' for 'program:app.command' contains names ('ENV_HOST') which cannot be expanded. Available names: ENV_LANG, ENV_PATH, group_name, here, host_node_name, process_num, program_name in section 'program:app' (file: '/etc/supervisord.conf')
Aug 20 16:57:13 master.hellogitlab.com supervisord[16286]: For help, use /usr/bin/supervisord -h
Aug 20 16:57:13 master.hellogitlab.com systemd[1]: supervisord.service: control process exited, code=exited status=2
Aug 20 16:57:13 master.hellogitlab.com systemd[1]: Failed to start Process Monitoring and Control Daemon.
Aug 20 16:57:13 master.hellogitlab.com systemd[1]: Unit supervisord.service entered failed state.
Aug 20 16:57:13 master.hellogitlab.com systemd[1]: supervisord.service failed.
[root@master ~]#
```

异常：`Error: Format string '/bin/ping %(ENV_HOST)s' for 'program:app.command' contains names ('ENV_HOST') which cannot be expanded. Available names: ENV_LANG, ENV_PATH, group_name, here, host_node_name, process_num, program_name in section 'program:app' (file: '/etc/supervisord.conf')`

`ENV_HOST`不能被扩展，有效的名称是`ENV_LANG, ENV_PATH, group_name, here, host_node_name, process_num, program_name`。

可知，使用supervisor管理的应用是获取不到linux的环境变量的，需要在`/etc/supervisord.conf`里进行设置。



##### 4.2.1.2 使用主机域名环境变量host_node_name

我们修改一下：

```sh
# 查看修改后最后两行，尝试ping一个环境变量
[root@master ~]# tail -n 2 /etc/supervisord.conf
[program:app]
command = ping %(host_node_name)s

# 查看主机名
[root@master ~]# hostname
master.hellogitlab.com

# 启动supervisord服务
[root@master ~]# spstart

# 查看应用状态，可以看到app应用正在运行
[root@master ~]# spctl status
app                              RUNNING   pid 30991, uptime 0:00:07

# 搜索ping进程，可以看到，其进程30991，与上一个命令中显示的进程id相同
# 同时，可以看到执行的命令是`ping master.hellogitlab.com`
# 也就是说，%(host_node_name)s 会被解析为节点域名
[root@master ~]# ps -ef|grep ping
root     30991 30990  0 21:09 ?        00:00:00 ping master.hellogitlab.com
root     31046 21666  0 21:09 pts/0    00:00:00 grep --color=auto ping
```

通过测试，可以知道：

- `%(ENV_PATH)s` ，会扩展为PATH环境变量的值，如`/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin`。
- `%(here)s`，会扩展为`/etc`路径。
- `%(host_node_name)s`，会扩展为节点主机名。

其他`ENV_LANG`、`group_name`、`process_num`和`program_name`暂未测试出解析出的结果。



### 4.3 `[unix_http_server]`块设置 

`supervisord.conf`文件包含一个名为`[unix_http_server]`的部分，在这个部分中应该插入监听UNIX域套接字的HTTP服务器的配置参数。如果配置文件没有`[unix_http_server]`节，UNIX域套接字HTTP服务器将不会启动。

| 序号 | 字段名     | 默认值                              | 是否必需字段 | 备注                                                                                                                             |
| ---- | ---------- | ----------------------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `file`     | /var/run/supervisor/supervisor.sock | 是           | UNIX域套接字的路径，上级将在该套接字上侦听HTTP/XML-RPC请求。因为没有该文件的话，那么**supervisorctl**将无法连接到**supervisord** |
| 2    | `chmod`    | 0700                                | 否           | 在启动时将UNIX域套接字的UNIX权限模式位更改为此值                                                                                 |
| 3    | `chown`    | 使用启动supervisord的用户名和组     | 否           | 套接字文件的用户和组                                                                                                             |
| 4    | `username` | 不需要用户认证                      | 否           | 此HTTP服务器的身份验证所需的用户名                                                                                               |
| 5    | `password` | 不需要密码                          | 否           | 向此HTTP服务器进行身份验证所需的密码，可以是明文或加密密文                                                                       |

#### 4.3.1 修改套接字文件权限

尝试将`chmod`值改成`0770`后，启动服务可查看套接字文件的权限：

```sh
[root@master ~]# head /etc/supervisord.conf
; Sample supervisor config file.

[unix_http_server]
file=/var/run/supervisor/supervisor.sock   ; (the path to the socket file)
chmod=0770                 ; socket file mode (default 0700)
;chown=nobody:nogroup       ; socket file uid:gid owner
;username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))

;[inet_http_server]         ; inet (TCP) server disabled by default

[root@master ~]# ll /var/run/supervisor/supervisor.sock
srwxrwx--- 1 root root 0 Aug 20 21:54 /var/run/supervisor/supervisor.sock
```

#### 4.3.2 使用明文密码开启身份验证

尝试将`username`和`passord`前的`;`分号注释去掉：

```sh
[root@master ~]# head /etc/supervisord.conf
; Sample supervisor config file.

[unix_http_server]
file=/var/run/supervisor/supervisor.sock   ; (the path to the socket file)
;chmod=0700                 ; socket file mode (default 0700)
;chown=nobody:nogroup       ; socket file uid:gid owner
username=user              ; (default is no username (open server))
password=123               ; (default is no password (open server))

;[inet_http_server]         ; inet (TCP) server disabled by default
[root@master ~]#
```

启动服务，然后使用`spctl`查看状态：

```sh
# 启动服务
[root@master ~]# spstart
[root@master ~]# spstatus
root     10920     1  0 22:11 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf

# 尝试用spctl查看状态，可以看到，提示服务端要求认证
[root@master ~]# spctl status
Error: Server requires authentication
For help, use /bin/supervisorctl -h
```

查看帮助信息：

```sh
[root@master ~]# spctl -h
supervisorctl -- control applications run by supervisord from the cmd line.

Usage: /bin/supervisorctl [options] [action [arguments]]

Options:
-c/--configuration FILENAME -- configuration file path (searches if not given)
-h/--help -- print usage message and exit
-i/--interactive -- start an interactive shell after executing commands
-s/--serverurl URL -- URL on which supervisord server is listening
     (default "http://localhost:9001").
-u/--username USERNAME -- username to use for authentication with server
-p/--password PASSWORD -- password to use for authentication with server
-r/--history-file -- keep a readline history (if readline is available)

action [arguments] -- see below

Actions are commands like "tail" or "stop".  If -i is specified or no action is
specified on the command line, a "shell" interpreting actions typed
interactively is started.  Use the action "help" to find out about available
actions.

[root@master ~]#
```

可以看到，可以通过`-u/--username`和`-p/--password`来与服务端进行认证交互。

我们使用配置文件中的用户名和密码进行验证一下：

```sh
[root@master ~]# spctl -u user -p 123 status
app                              RUNNING   pid 10922, uptime 0:04:11
[root@master ~]# spctl --username user --password 123 status
app                              RUNNING   pid 10922, uptime 0:04:26
```

可以看到，通过设置用户名和密码参数后，可以直接获取应用状态，说明认证成功。



#### 4.3.3 使用加密密码开启身份验证

>   MD5与SHA-1都是散列算法，无法被还原出原内容，但是可采用暴力破解（字典法）不断将各种字符串进行散列并与原始散列值比较，若字符串加密后的值与原始散列值比较后相同，则判定那个字符串为原内容。
>    2004年8月17日，王小云教授证实MD5算法无法防止碰撞，因此也有一定几率利用碰撞法取得MD5的原内容。
>    为了增大MD5算法的破解难度，国内不少CMS厂商都在后台的密码验证中给原密码散列后并加了一些随机字符串（盐）再重新散列一次，但是为了更加安全，也有厂商用SHA-1代替MD5。  

在linux操作系统中，可以使用`sha1sum`获取字段串的SHA-1哈希值：

```sh
[root@master ~]# echo -n 'thepassword'|sha1sum
82ab876d1387bfafe46cc1c8a2ef074eae50cb1d  -
[root@master ~]# echo -n 'thepassword'|sha1sum|awk '{print "{SHA}"$1}'
{SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d
```

可以看到，获取的值与官方文档中给出的值是一样的：

> For example, `{SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d` is the SHA-stored version of the password “thepassword”.

因此，我们可以将该加密后的SHA1散列值配置到配置文件中：

```sh
[root@master ~]# head /etc/supervisord.conf
; Sample supervisor config file.

[unix_http_server]
file=/var/run/supervisor/supervisor.sock   ; (the path to the socket file)
;chmod=0700                 ; socket file mode (default 0700)
;chown=nobody:nogroup       ; socket file uid:gid owner
username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))
password={SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d

[root@master ~]#
```

可以看到，已经配置了加密的密码。



重启supervisor服务，并查看应用：

```sh
[root@master ~]# spstatus
root     10920     1  0 22:11 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
You have new mail in /var/spool/mail/root
[root@master ~]# kill -9 10920
[root@master ~]# spstart
[root@master ~]# spctl status
Error: Server requires authentication
For help, use /bin/supervisorctl -h

# 可以看到，使用新密码thepassword能够正常认证成功，显示出了应用状态信息
[root@master ~]# spctl --username user --password thepassword status
app                              RUNNING   pid 15374, uptime 0:00:22
```



我们可以通过交互模式进入到`supervisor`命令行：

```sh
[root@master ~]# spctl
Server requires authentication
Username:user
Password:  # <<------ 此处输入密码thepassword后，回车开始认证 

app                              RUNNING   pid 15374, uptime 0:05:54
supervisor> status
app                              RUNNING   pid 15374, uptime 0:06:03
supervisor> pid
15371
supervisor> reload
Really restart the remote supervisord process y/N? Y
Restarted supervisord
supervisor> status
app                              RUNNING   pid 16510, uptime 0:00:04
supervisor> quit
[root@master ~]#
```



使用加密的密码进行身份认证，可提高Supervisor的应用的安全性，防止非授权用户操作相关应用。



### 4.4 `[inet_http_server]`块设置

`supervisord.conf`文件包含一个名为`[inet_http_server]`的部分，在这个部分中应该插入监听TCP套接字的HTTP服务器的配置参数。如果配置文件没有`[inet_http_server]`节，inet HTTP服务器将不会启动。即不会提供Web服务。

::: warning 警告

默认情况下，不会开启Web服务，如果你开启了该Web服务，则应阅读以下安全警告。

- inet HTTP服务器仅用于受信任的环境。
- 它应该只绑定到本地主机，或者只能从一个隔离的、受信任的网络中访问。如设置防火墙白名单！
- inet HTTP服务器不支持任何形式的加密。
- 默认未开启用户名和密码认证。
- 可以从`supervisorctl`远程控制inet HTTP服务器。
- Web界面允许对应用进行管理，如启动或停止，也可以查看应用日志信息。
- 永远不要向公网开放inet HTTP服务器！

:::

| 序号 | 字段名     | 默认值         | 是否必需字段 | 备注                                                       |
| ---- | ---------- | -------------- | ------------ | ---------------------------------------------------------- |
| 1    | `port`     | 无默认值       | 是           | HTTP监听端口                                               |
| 2    | `username` | 不需要用户认证 | 否           | 此HTTP服务器的身份验证所需的用户名                         |
| 3    | `password` | 不需要密码     | 否           | 向此HTTP服务器进行身份验证所需的密码，可以是明文或加密密文 |

#### 4.4.1 开启Web服务

查看默认配置：

```sh
[root@master ~]# grep -A4 'inet_http_server'  /etc/supervisord.conf
;[inet_http_server]         ; inet (TCP) server disabled by default
;port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
;username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))
```

可以看到默认情况下，未开启web服务。

我们开启该服务，修改后再次查看配置：

```sh
[root@master ~]# grep -A4 'inet_http_server'  /etc/supervisord.conf
[inet_http_server]         ; inet (TCP) server disabled by default
port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
;username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))
```

此时重启`supervisord`服务：

```sh
[root@master ~]# spctl status
Error: Server requires authentication
For help, use /bin/supervisorctl -h
[root@master ~]# spstatus
root     15371     1  0 Aug20 ?        00:00:14 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# kill -9 15371
[root@master ~]# spstatus
[root@master ~]# spstart
[root@master ~]# spstatus
root     10066     1  0 06:30 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
```

查看监听端口：

```sh
[root@master ~]# netstat -tunlp|grep 9001
tcp        0      0 127.0.0.1:9001          0.0.0.0:*               LISTEN      10066/python
```

可以看到，端口`9001`对应的进程id是10066，就是`supervisord`服务对应的pid。

我们使用`curl`请求URL:

```sh
[root@master ~]# curl localhost:9001 > app.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2383  100  2383    0     0   334k      0 --:--:-- --:--:-- --:--:--  387k
[root@master ~]#
```

然后使用vim打开`app.html`文件：


可以看到，已经显示了`app`应用的状态信息了。我们在命令行对照一下：

```sh
[root@master ~]# spctl --username user --password thepassword status
app                              RUNNING   pid 10067, uptime 0:11:11
```

 可以看到，进程PID是10067，和在app.html文件中看到的是一样的！！



由于我们绑定的端口是`port=127.0.0.1:9001`，此时只能在服务器上面访问，远程无法访问该Web服务。

需要修改绑定IP并开启防火墙放行白名单才能够远程访问。



#### 4.4.2 防火墙设置

防火墙放行`9001`端口：
```sh
# 添加防火墙白名单规则，允许指定IP访问9001端口
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="27.17.246.137" port protocol="tcp" port="9001" accept"

# 重启防火墙
firewall-cmd --reload
```

如果你是使用的腾讯云的话，还需要登陆腾讯云控制台中，给服务器主机增加防火墙规则。

#### 4.4.3 远程访问Web服务

打开`inet_http_server`相关配置：

```sh
[root@master ~]# grep -A4 'inet_http_server'  /etc/supervisord.conf
[inet_http_server]         ; inet (TCP) server disabled by default
;port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
port=192.168.12.6:9001
username=user              ; (default is no username (open server))
password=123               ; (default is no password (open server))
```

然后启动`supervisord`服务，注意，此处`port=192.168.12.6:9001`处填写的IP是内网IP，不要写公网IP，否则启动时会报异常：`polkitd[2359]: Unregistered Authentication Agent for unix-process`。

启动服务：

```sh
[root@master ~]# spstart
```



访问：


输入用户名和密码后，就可以登陆进Web页面了：


可以看到，页面上面已经显示了正在运行的服务。



尝试点击Stop停止按钮，停止后的状态如下：




再点击Start启动按钮，可以看到服务又重新启动了。通过这里的测试可以看到，虽然在使用命令行`supervisorctl`时需要输入密码，但此处在Web页面上面控制Supervisor管理的应用时，并不需要输入密码，也就是说Web页面的管理与是否在`unix_http_server`中开启用户认证是没有关系的。



#### 4.4.4 使用加密密码开启身份验证

同样，可以像`4.3.3`节中一样，将配置文件中的密码加密：

```sh
# 获取加密字符串
[root@master ~]# echo -n 'thepassword'|sha1sum|awk '{print "{SHA}"$1}'
{SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d

# 修改配置文件 
[root@master ~]# vi /etc/supervisord.conf

# 查看修改后的配置，使用加密密码
[root@master ~]# grep -A5 'inet_http_server'  /etc/supervisord.conf
[inet_http_server]         ; inet (TCP) server disabled by default
;port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
port=10.0.4.7:9001
username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))
password={SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d
```

重启`supervisord`服务：

```sh
[root@master ~]# spstatus
root     22123     1  0 06:45 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# kill -9 22123
[root@master ~]# spstart
[root@master ~]# spstatus
root     25968     1  0 07:06 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
```

此时，再次访问Web页面，可以看到需要重新输入密码，使用新密码`thepassword`可以正常登陆。说明加密密码生效了。



### 4.5 `[supervisord]`块设置

`supervisord.conf`文件包含一个名为`[supervisord]`的部分，在这个部分配置与``supervisord``相关的全局设置。

我们可以看一下`/etc/supervisord.conf`中关于这一部分的配置：

```sh
[root@master ~]# grep -A17 '\[supervisord]' /etc/supervisord.conf
[supervisord]
logfile=/var/log/supervisor/supervisord.log  ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (log level;default info; others: debug,warn,trace)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)
;umask=022                  ; (process file creation umask;default 022)
;user=chrism                 ; (default is current user, required if root)
;identifier=supervisor       ; (supervisord identifier, default is 'supervisor')
;directory=/tmp              ; (default is not to cd during start)
;nocleanup=true              ; (don't clean up tempfiles at start;default false)
;childlogdir=/tmp            ; ('AUTO' child log dir, default $TEMP)
;environment=KEY=value       ; (key value pairs to add to environment)
;strip_ansi=false            ; (strip ansi escape codes in logs; def. false)

[root@master ~]#
```

可以看到配置还是比较多的。

| 序号 | 字段名             | 默认值                 | 是否必需字段 | 备注                                                                                                                                                       |
| ---- | ------------------ | ---------------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `logfile`          | `$CWD/supervisord.log` | 否           | supervisord进程的活动日志的路径。如果`logfile`被设置为不可查找的特殊文件，例如`/dev/stdout`，则必须通过设置`logfile_maxbytes = 0`来禁用日志循环。          |
| 2    | `logfile_maxbytes` | 50MB                   | 否           | 日志文件最大字节数，可以使用`KB`/`MB`/`GB`等后缀，设置为0时表明日志文件大小无限制。                                                                        |
| 3    | `logfile_backups`  | 10                     | 否           | 日志文件备份数量，设置为0则表明不备份日志                                                                                                                  |
| 4    | `loglevel`         | info                   | 否           | 日志级别，可选值为`critical`, `error`, `warn`, `info`, `debug`, `trace`, or `blather`                                                                      |
| 5    | `pidfile`          | `$CWD/supervisord.pid` | 否           | PID文件路径                                                                                                                                                |
| 6    | `umask`            | 022                    | 否           | `supervisord`进程文件的掩码                                                                                                                                |
| 7    | `nodaemon`         | false                  | 否           | 为`true`时不以守护进程运行，即在前台运行。默认是以守护进程运行                                                                                             |
| 8    | `silent`           | false                  | 否           | 如果设置为`true`则不以守护进程运行时，日志将保持静默状态，不输出到标准输出                                                                                 |
| 9    | `minfds`           | 1024                   | 否           | 要启动`supervisord`必需的最小文件描述符数量                                                                                                                |
| 10   | `minprocs`         | 200                    | 否           | 要启动`supervisord`必需的最小进程描述符数量                                                                                                                |
| 11   | `nocleanup`        | false                  | 否           | 限制清理`AUTO`子进程的日志文件                                                                                                                             |
| 12   | `childlogdir`      | tempfile.gettempdir()  | 否           | `AUTO`子日志文件的目录                                                                                                                                     |
| 13   | `user`             | 不切换用户             | 否           | 切换到该用户运行                                                                                                                                           |
| 14   | `directory`        | 不切换目录             | 否           | 切换到这个目录运行`supervisord`守护进程                                                                                                                    |
| 15   | `strip_ansi`       | false                  | 否           | 从子日志文件中删除所有ANSI转义序列                                                                                                                         |
| 16   | `environment`      | 无默认值               | 否           | 环境变量，`key="val"，KEY2="val2"`形式的键/值对列表，建议每个变量的值带上双引号，如果要指定`%`百分号，使用两个`%%`百分号表示即可，如`URI="/first%%20name"` |
| 17   | `identifier`       | supervisor             | 否           | 标识符，此管理进程的标识符字符串，由RPC接口使用。                                                                                                          |

通常情况下，不需要修改`supervisord`块的设置，保持默认即可。

如果产生的日志文件比较大的话，建议将`logfile_maxbytes`值调大一些。



#### 4.5.1 调整日志文件大小

默认日志文件大小是`50MB`，为了便于测试，我将配置文件中`logfile_maxbytes`改成`5KB`。

先看当前日志文件夹文件大小：

```sh
[root@master supervisor]# pwd
/var/log/supervisor
[root@master supervisor]# ls -lah
total 80K
drwxrwx---   2 root root 4.0K Aug 21 03:19 .
drwxr-xr-x. 12 root root 4.0K Aug 10 06:28 ..
-rw-r--r--   1 root root  11K Aug 26 22:40 supervisord.log
-rw-r--r--   1 root root 5.4K Aug 18 19:47 supervisord.log-20220814
-rw-r--r--   1 root root  45K Aug 20 22:39 supervisord.log-20220821
[root@master supervisor]#
```

查看配置文件：

```sh
[root@master supervisor]# grep -A17 '\[supervisord]' /etc/supervisord.conf
[supervisord]
logfile=/var/log/supervisor/supervisord.log  ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=1KB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (log level;default info; others: debug,warn,trace)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)
;umask=022                  ; (process file creation umask;default 022)
;user=chrism                 ; (default is current user, required if root)
;identifier=supervisor       ; (supervisord identifier, default is 'supervisor')
;directory=/tmp              ; (default is not to cd during start)
;nocleanup=true              ; (don't clean up tempfiles at start;default false)
;childlogdir=/tmp            ; ('AUTO' child log dir, default $TEMP)
;environment=KEY=value       ; (key value pairs to add to environment)
;strip_ansi=false            ; (strip ansi escape codes in logs; def. false)

[root@master supervisor]#
```

查看当前`supervisord`状态并重启：

```sh
[root@master supervisor]# spstatus
root     12305     1  0 Aug26 ?        00:00:11 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master supervisor]# kill -9 12305
[root@master supervisor]# spstart
[root@master supervisor]# spstatus
root      1587     1  0 21:16 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master supervisor]#
```

此时查看日志文件夹文件：

```sh
[root@master supervisor]# ls -lah
total 84K
drwxrwx---   2 root root 4.0K Aug 27 21:16 .
drwxr-xr-x. 12 root root 4.0K Aug 10 06:28 ..
-rw-r--r--   1 root root  526 Aug 27 21:16 supervisord.log
-rw-r--r--   1 root root  11K Aug 27 21:16 supervisord.log.1
-rw-r--r--   1 root root 5.4K Aug 18 19:47 supervisord.log-20220814
-rw-r--r--   1 root root  45K Aug 20 22:39 supervisord.log-20220821
```

因此之前的日志文件已经超过1KB，所以会对文件日志进行切割，生成新的备份文件。可以看到已经生成了一个备份日志文件`supervisord.log.1`。

当我再次重启`supervisord`时，又生成了一个新的日志文件：

```sh
[root@master supervisor]# ls -lah
total 88K
drwxrwx---   2 root root 4.0K Aug 27 21:21 .
drwxr-xr-x. 12 root root 4.0K Aug 10 06:28 ..
-rw-r--r--   1 root root  526 Aug 27 21:21 supervisord.log
-rw-r--r--   1 root root 1.5K Aug 27 21:21 supervisord.log.1
-rw-r--r--   1 root root  11K Aug 27 21:16 supervisord.log.2
-rw-r--r--   1 root root 5.4K Aug 18 19:47 supervisord.log-20220814
-rw-r--r--   1 root root  45K Aug 20 22:39 supervisord.log-20220821
```

可以看到，当日志文件超过了规定的大小后就会生成一个备份日志文件。

我们将`logfile_maxbytes`的值还原成默认的`50MB`。



### 4.6 `[supervisorctl]`块设置

`[supervisorctl]`块设置主要是`supervisorctl`交互式Shell的设置。



查看当前的配置：

```sh
[root@master ~]# grep -A7 '\[supervisorctl]' /etc/supervisord.conf
[supervisorctl]
serverurl=unix:///var/run/supervisor/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as http_username if set
;password=123                ; should be same as http_password if set
prompt=supervisor         ; cmd line prompt (default "supervisor")
;history_file=~/.sc_history  ; use readline history if available

[root@master ~]#
```

涉及的配置：

| 序号 | 字段名         | 默认值                                  | 是否必需字段 | 备注                                                                                                                                   |
| ---- | -------------- | --------------------------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `serverurl`    | `http://localhost:9001`                 | 否           | 访问supervisord服务器的URL                                                                                                             |
| 2    | `username`     | 不需要用户认证                          | 否           | 访问`supervisord`服务器的身份验证所需的用户名，需要与 `[unix_http_server]`块设置中的用户名一样                                         |
| 3    | `password`     | 不需要密码用启动supervisord的用户名和组 | 否           | 访问`supervisord`服务器进行身份验证所需的密码，可以是明文或加密密文套接字文件的用户和组，需要与 `[unix_http_server]`块设置中的密码一样 |
| 4    | `prompt`       | `supervisor`                            | 否           | `supervisorctl`命令行提示符                                                                                                            |
| 5    | `history_file` | 没有文件                                | 否           | 持久化历史文件的路径                                                                                                                   |



#### 4.6.1 修改`supervisorctl`命令行提示符

在`3.3.3`节可知默认的命令行提示符如下：

```sh
# 获取帮助信息，可以看到，有很多命令
supervisor> help

default commands (type help <topic>):
=====================================
add    exit      open  reload  restart   start   tail
avail  fg        pid   remove  shutdown  status  update
clear  maintail  quit  reread  signal    stop    version
```

即提示符是`supervisor`。

我们修改为`prompt=mysupervisor`：

```sh
[supervisorctl]
serverurl=unix:///var/run/supervisor/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as http_username if set
;password=123                ; should be same as http_password if set
prompt=mysupervisor         ; cmd line prompt (default "supervisor")
;history_file=~/.sc_history  ; use readline history if available

[root@master ~]#
```

重启`supervisord`后进入到`supervisorctl`命令行：

```sh
[root@master ~]# spctl
Server requires authentication
Username:user
Password:

app                              RUNNING   pid 6965, uptime 0:06:04
mysupervisor> help

default commands (type help <topic>):
=====================================
add    exit      open  reload  restart   start   tail
avail  fg        pid   remove  shutdown  status  update
clear  maintail  quit  reread  signal    stop    version

mysupervisor> exit
[root@master ~]#
```

可以看到，此时命令行提示符已经修改成了`mysupervisor`。

我们将此处设置还原。



### 4.7 `[program:x]`块设置

为了便于本节测试，关闭配置文件中设置的`supervisord`服务器的用户名和密码认证。



- 配置文件中，至少得有一个`[program]`块，该处的`x`代表的是程序或应用名，告知`supervisor`要启动或控制哪些应用。
- `[program:foo]`表示`foo`应用程序，
- 没有应用名的块`[program]`是错误的。
- 应用名不应包含冒号和括号。

此部分算是`supervisor`中最复杂的一部分，我们一个个的看。

先看一下配置文件中的默认示例：

```sh
[root@master ~]# grep -A28 '\[program:theprogramname]' /etc/supervisord.conf
;[program:theprogramname]
;command=/bin/cat              ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
;autostart=true                ; start at supervisord start (default: true)
;autorestart=true              ; retstart at unexpected quit (default: true)
;startsecs=10                  ; number of secs prog must stay running (def. 1)
;startretries=3                ; max # of serial start failures (default 3)
;exitcodes=0,2                 ; 'expected' exit codes for process (default 0,2)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (default 10)
;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (default 10)
;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;environment=A=1,B=2           ; process environment additions (def no adds)
;serverurl=AUTO                ; override serverurl computation (childutils)

[root@master ~]#
```

可以看到，配置项差不多有30个配置项。


| 序号 | 字段名                    | 默认值             | 是否必需字段 | 备注                                                                                                                                                            |
| ---- | ------------------------- | ------------------ | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `command`                 | 无默认值           | 是           | 启动程序的命令                                                                                                                                                  |
| 2    | `process_name`            | `%(program_name)s` | 否           | 程序名称，对应`[program:x]`处的`x`，也就是应用名称。<br/>如果`numprocs`大于1,那么此处的配置中必须包含`%(process_num)s`的值，如`%(program_name)s_%(process_num)s` |
| 3    | `numprocs`                | 1                  | 否           | 程序实例数，可以启动多个程序实例                                                                                                                                |
| 4    | `numprocs_start`          | 0                  | 否           | 程序实例从哪个数字开始标记，如`app:app_0`、`app:app_1`之类的                                                                                                    |
| 5    | `priority`                | 999                | 否           | 程序启停的优先级，数字越小优先级越高                                                                                                                            |
| 6    | `autostart`               | `true`             | 否           | `supervisord`启动后自动启动应用                                                                                                                                 |
| 7    | `startsecs`               | 1                  | 否           | 程序启动后，需要保持多长时间（秒）才认为该程序处于`RUNNING`运行状态                                                                                             |
| 8    | `startretries`            | 3                  | 否           | 在将程序置于`FATAL`状态前，尝试重新运行程序的次数                                                                                                               |
| 9    | `autorestart`             | unexpected         | 否           | 当程序处于`RUNNING`状态时，如果其退出了，是否需要自动重启该程序                                                                                                 |
| 10   | `exitcodes`               | 0                  | 否           | 退出码，`autorestart`使用的的“预期”退出码列表                                                                                                                   |
| 11   | `stopsignal`              | TERM               | 否           | 停止进程所使用的信号，可以是TERM、HUP、INT、QUIT、KILL、USR1或USR2中的任何一个                                                                                  |
| 12   | `stopwaitsecs`            | 10                 | 否           | 在程序发送停止信号后，等待操作系统返回SIGCHLD给**supervisord**的秒数                                                                                            |
| 13   | `stopasgroup`             | `false`            | 否           | 如果为true，则向整个进程组发送停止信号                                                                                                                          |
| 14   | `killasgroup`             | `false`            | 否           | 向进程组发送`SIGKILL`信号杀死进程组                                                                                                                             |
| 15   | `user`                    | 不切换用户         | 否           | 当`supervisord`以`root`账号运行时，可以指定`user`参数来切换到该用户运行管理的应用程序                                                                           |
| 16   | `redirect_stderr`         | `false`            | 否           | 重定向标准异常到标准输出                                                                                                                                        |
| 17   | `stdout_logfile`          | `AUTO`             | 否           | 标准输出日志文件，多个程序不能设置相同的日志文件。默认情况下，`supervisord`会自动选择日志存放位置                                                               |
| 18   | `stdout_logfile_maxbytes` | `50MB`             | 否           | 标准输出日志文件大小最大值，设置为0表示无限制。后缀可以是“KB”, “MB”, and “GB”等                                                                                 |
| 19   | `stdout_logfile_backups`  | 10                 | 否           | 日志轮询备份数量，设置为0，则不进行备份                                                                                                                         |
| 20   | `stdout_capture_maxbytes` | 0                  | 否           | 当进程处于“stdout捕获模式”，捕获FIFO所写入的最大字节数。设置为0表示关闭捕获模式                                                                                 |
| 21   | `stdout_events_enabled`   | 0                  | 否           | 如果为true，当进程写入其stdout文件描述符时将触发`PROCESS_LOG_STDOUT`事件。只有在接收数据时文件描述符未处于捕获模式时才会触发事件                                |
| 22   | `stdout_syslog`           | `false`            | 否           | 标准输出将进程名称也定向到`syslog`                                                                                                                              |
| 23   | `stderr_logfile`          | `AUTO`             | 否           | 标准异常日志文件                                                                                                                                                |
| 24   | `stderr_logfile_maxbytes` | `50MB`             | 否           | 标准异常日志文件最大字节数                                                                                                                                      |
| 25   | `stderr_logfile_backups`  | 10                 | 否           | 标准异常日志轮询备份数量                                                                                                                                        |
| 26   | `stderr_events_enabled`   | `false`            | 否           | 标准异常事件捕获                                                                                                                                                |
| 27   | `stderr_syslog`           | `false`            | 否           | 标准异常将进程名称也定向到`syslog`                                                                                                                              |
| 28   | `environment`             | 没有额外的环境变量 | 否           | 环境变量，键值对。                                                                                                                                              |
| 29   | `directory`               | 不改变目录         | 否           | 在执行程序前，切换到该目录下                                                                                                                                    |
| 30   | `umask`                   | 未设置掩码         | 否           | 一个表示进程掩码的八进制数字(如002、022)                                                                                                                        |
| 31   | `serverurl`               | `AUTO`             | 否           | 传递给子进程的URL                                                                                                                                               |



#### 4.7.1 `command`启动程序的命令-必需字段

- `command`用于指定启动程序所使用的命令。
- 命令可以使用绝对或相对路径。如`/path/to/programname`或`programname`。
- 命令也可以接受参数，如`/path/to/program foo bar`。
- 命令行可以使用双引号将包含空格的参数传递给程序，如`/path/to/program/name -p "foo bar"`。
- 命令行也接受Python表达式，如`/path/to/programname --port=80%(process_num)02d`，扩展后，可能是`/path/to/programname --port=8000`。
- 字符表达式是根据字典计算的，字典中包含`group_name`, `host_node_name`, `program_name`, `process_num`, `numprocs`, `here`等键，以及`ENV_`相关的环境变量。
- **被控制的程序本身不应是守护进程**，因为`supervisord`认为所有子进程都是由它来管理的。
- 如果命令看起来像是配置文件的注释的话，命令将会被截断。如`command=bash -c 'foo ; bar'`会被解析为`command=bash -c 'foo`。
- `command`是必须字段！因为你不指定启动命令，`supervisor`不知道要启动什么程序。



#### 4.7.2 `process_name`程序名称

- 程序名称，对应`[program:x]`处的`x`，也就是应用名称。
- 如果`numprocs`大于1,那么此处的配置中必须包含`%(process_num)s`的值，如`%(program_name)s_%(process_num)s`。

我们配置三个应用，一个默认不设置程序名称、一个使用默认值作为程序名称、一个设置一个自定义的程序名称。配置如下：

```ini
[program:app_no_name]
command = cat

[program:app_with_default_name]
command = cat
process_name = %(program_name)s

[program:app_with_name]
command = cat
process_name = app
```

然后重新加载配置：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
app_no_name                       RUNNING   pid 11659, uptime 0:00:03
app_with_default_name             RUNNING   pid 11658, uptime 0:00:03
app_with_name:app                 RUNNING   pid 11657, uptime 0:00:03
[root@master ~]#
```

可以看到，应用`app_no_name`和`app_with_default_name`应用后面没有显示其对应的程序名称，而`app_with_name`后面多了`:app`，显示了程序名称。



#### 4.7.3 `numprocs`设置进程实例数

我们可以使用`numprocs`设置进程实例数，默认只启动一个进程实例，我们可以设置启动多个进程实例。

当我们修改配置，注意掉之前的应用，重新设置以下应用：

```ini
[program:app]
command = cat
numprocs = 3
```

此时，尝试重新加载配置：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
unix:///var/run/supervisor/supervisor.sock no such file
[root@master ~]#
```

可以看到，`supervisord`服务没有启动起来。

我们查看一下服务的状态信息：

```sh
[root@master ~]# systemctl status supervisord.service -l
● supervisord.service - Process Monitoring and Control Daemon
   Loaded: loaded (/usr/lib/systemd/system/supervisord.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sat 2022-09-03 23:22:19 CST; 3min 45s ago
  Process: 26235 ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf (code=exited, status=2)
 Main PID: 18978 (code=exited, status=2)

Sep 03 23:22:19 master.hellogitlab.com systemd[1]: Starting Process Monitoring and Control Daemon...
Sep 03 23:22:19 master.hellogitlab.com supervisord[26235]: Error: %(process_num) must be present within process_name when numprocs > 1 in section 'program:app' (file: '/etc/supervisord.conf')
Sep 03 23:22:19 master.hellogitlab.com supervisord[26235]: For help, use /usr/bin/supervisord -h
Sep 03 23:22:19 master.hellogitlab.com systemd[1]: supervisord.service: control process exited, code=exited status=2
Sep 03 23:22:19 master.hellogitlab.com systemd[1]: Failed to start Process Monitoring and Control Daemon.
Sep 03 23:22:19 master.hellogitlab.com systemd[1]: Unit supervisord.service entered failed state.
Sep 03 23:22:19 master.hellogitlab.com systemd[1]: supervisord.service failed.
[root@master ~]#
```

此时可以看到，抛出了异常：`Error: %(process_num) must be present within process_name when numprocs > 1 in section 'program:app' (file: '/etc/supervisord.conf')`，可以看到，在`app`应用中，当配置了`numprocs > 1`时，在`process_name`名称中必须包含`%(process_num)`这个变量，而我们在配置文件中并没有配置。

因此，我们修改一下配置。

修改后的应用配置如下：

```sh
[program:app_no_name]
command = cat

[program:app]
command = cat
process_name = %(program_name)s_%(process_num)s
numprocs = 3

[program:app_with_name]
command = cat
process_name = myapp_%(process_num)s
numprocs = 3
```

然后重新启动`supervisord`服务，并查看状态信息：

```sh
# 启动supervisord服务
[root@master ~]# spstart

# 查看应用状态信息
[root@master ~]# spctl status
app:app_0                        RUNNING   pid 28769, uptime 0:00:06
app:app_1                        RUNNING   pid 28768, uptime 0:00:06
app:app_2                        RUNNING   pid 28770, uptime 0:00:06
app_no_name                      RUNNING   pid 28774, uptime 0:00:06
app_with_name:myapp_0            RUNNING   pid 28772, uptime 0:00:06
app_with_name:myapp_1            RUNNING   pid 28771, uptime 0:00:06
app_with_name:myapp_2            RUNNING   pid 28773, uptime 0:00:06
```

此时，可以查看一下`cat`进程的实例数：

```sh
[root@master ~]# ps -ef|grep cat|grep -v grep
root     28768 28761  0 23:35 ?        00:00:00 cat
root     28769 28761  0 23:35 ?        00:00:00 cat
root     28770 28761  0 23:35 ?        00:00:00 cat
root     28771 28761  0 23:35 ?        00:00:00 cat
root     28772 28761  0 23:35 ?        00:00:00 cat
root     28773 28761  0 23:35 ?        00:00:00 cat
root     28774 28761  0 23:35 ?        00:00:00 cat
[root@master ~]# ps -ef|grep cat|grep -v grep|wc -l
7
```

可以看到，有7个`cat`实例在运行。其中，1个实例由`app_no_name`运行、3个实例由`app`应用运行，由于`app`应用中`process_name = %(program_name)s_%(process_num)s`指定的进程的名称，`%(program_name)s`会被解析扩展为应用的名称，也就是`app`，而`%(process_num)s`会被扩展会当前实例的序号，默认从0开始标号。3个实例由`app_with_name`应用运行，该应用由于指定了`process_name = myapp_%(process_num)s`程序名称不会去解析默认的程序名称，而是使用`myapp_`与序列号进行拼接。



#### 4.7.4 `numprocs_start`设置进程实例序号起始值

通过上一节的示例可以看到，当存在多个进程实例时，进程实例序号默认从0开始，我们可以通过配置`numprocs_start`参数来改变这个行为。

修改配置，增加`numprocs_start`参数，修改后配置如下：

```ini
[program:app_no_name]
command = cat

[program:app]
command = cat
process_name = %(program_name)s_%(process_num)s
numprocs = 3
numprocs_start = 100

[program:app_with_name]
command = cat
process_name = myapp_%(process_num)s
numprocs = 3
numprocs_start = 1
```

重新加载配置，并查看应用状态：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 31341, uptime 0:00:03
app:app_101                      RUNNING   pid 31342, uptime 0:00:03
app:app_102                      RUNNING   pid 31340, uptime 0:00:03
app_no_name                      RUNNING   pid 31346, uptime 0:00:03
app_with_name:myapp_1            RUNNING   pid 31343, uptime 0:00:03
app_with_name:myapp_2            RUNNING   pid 31345, uptime 0:00:03
app_with_name:myapp_3            RUNNING   pid 31344, uptime 0:00:03
[root@master ~]#
```

可以看到：

- 应用`app`的序号从100开始，三个实例的应用名称分别是`app_100`、`app_101`和`app_102`。
- 应用`app_with_name`的序号从1开始，三个实例的应用名称分别是是`myapp_1`、`myapp_2`和`myapp_3`。

由此可见增加`numprocs_start`参数的确改变了多实例应用的进程名称。通常，我们更习惯序号从1开始，因此，存在多实例时，配置`numprocs_start = 1`会更合适。



#### 4.7.5 `priority`改变进程优先级

- `priority`设置应用优先级，默认值为`999`。

当我们没有设置应用进程优先级时，`supervisord`会自己帮我们决定先启动哪个应用，再启动哪个应用。

如针对上述3个应用，我们看一下`pid`情况：

```sh
# 按第4列，也就pid对应的数值排序
[root@master ~]# spctl status|sort -k4
app:app_102                      RUNNING   pid 31340, uptime 0:08:11
app:app_100                      RUNNING   pid 31341, uptime 0:08:11
app:app_101                      RUNNING   pid 31342, uptime 0:08:11
app_with_name:myapp_1            RUNNING   pid 31343, uptime 0:08:11
app_with_name:myapp_3            RUNNING   pid 31344, uptime 0:08:11
app_with_name:myapp_2            RUNNING   pid 31345, uptime 0:08:11
app_no_name                      RUNNING   pid 31346, uptime 0:08:11
```

如果`supervisord`是按先启动的应用的进程PID小，后启动的应用的进程PID在的话，那么通过上面排序可知，默认先启动`app`应用，再启动`app_with_name`应用，最后再启动`app_no_name`应用。

假如，我们要先启动`app_no_name`应用，再启动`app`应用，最后启动`app_with_name`应用。此时`priority`参数就可以改变这种行为。

我们修改配置：

```ini
[program:app_no_name]
command = cat
priority = 901

[program:app]
command = cat
process_name = %(program_name)s_%(process_num)s
numprocs = 3
numprocs_start = 100
priority = 902

[program:app_with_name]
command = cat
process_name = myapp_%(process_num)s
numprocs = 3
numprocs_start = 1
priority = 903
```

此处，可以看到：

- `app_no_name`设置的优先级是`priority = 901`，比默认值`999`小，比`app`应用`902`小，比`app_with_name`应用的`903`小，此时，说明`app_no_name`的优先级最高，会最先启动；`app`应用的优先级次之，会在中间启动；`app_with_name`优先级最低，会最后启动。

我们实际看一下应用进程情况：

```sh
[root@master ~]# spctl status|sort -k4
app_no_name                      RUNNING   pid 2516, uptime 0:00:15
app:app_102                      RUNNING   pid 2517, uptime 0:00:15
app:app_100                      RUNNING   pid 2518, uptime 0:00:15
app:app_101                      RUNNING   pid 2519, uptime 0:00:15
app_with_name:myapp_1            RUNNING   pid 2520, uptime 0:00:15
app_with_name:myapp_3            RUNNING   pid 2521, uptime 0:00:15
app_with_name:myapp_2            RUNNING   pid 2522, uptime 0:00:15
```

也的确是按我们设置的优先级顺序启动的。`app_no_name`的进程ID是2516，值最小，说明它先被启动。而`app`对应的三个进程ID分别是2517、2518、2519，进程ID值变大了。而最后启动的`app_with_name`应用三个实例的进程ID是2520、2521和2522，进程ID值更大了，说明它们最后启动起来。



现在我们来尝试停止所有的应用，看看哪个应用会被先停止，为了捕获到停止过程，我们在执行停止命令后，马上查看应用状态。

由于应用停止太快，我们使用命令没能获取到哪个应用先被停止：

```sh
[root@master ~]# spctl stop all ; echo "first status" ; spctl status ; echo "second status" ; spctl status;  echo "third status" ; spctl status
app_no_name: stopped
app_with_name:myapp_3: stopped
app_with_name:myapp_2: stopped
app:app_102: stopped
app:app_100: stopped
app:app_101: stopped
app_with_name:myapp_1: stopped
first status
app:app_100                      STOPPED   Sep 04 12:21 AM
app:app_101                      STOPPED   Sep 04 12:21 AM
app:app_102                      STOPPED   Sep 04 12:21 AM
app_no_name                      STOPPED   Sep 04 12:21 AM
app_with_name:myapp_1            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_2            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_3            STOPPED   Sep 04 12:21 AM
second status
app:app_100                      STOPPED   Sep 04 12:21 AM
app:app_101                      STOPPED   Sep 04 12:21 AM
app:app_102                      STOPPED   Sep 04 12:21 AM
app_no_name                      STOPPED   Sep 04 12:21 AM
app_with_name:myapp_1            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_2            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_3            STOPPED   Sep 04 12:21 AM
third status
app:app_100                      STOPPED   Sep 04 12:21 AM
app:app_101                      STOPPED   Sep 04 12:21 AM
app:app_102                      STOPPED   Sep 04 12:21 AM
app_no_name                      STOPPED   Sep 04 12:21 AM
app_with_name:myapp_1            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_2            STOPPED   Sep 04 12:21 AM
app_with_name:myapp_3            STOPPED   Sep 04 12:21 AM
[root@master ~]#
```

可以看到，瞬间就停止了，后面三次看到的状态都是相同的，都是`STOPPED`停止状态。

再测试几次启动和停止：

```sh
[root@master ~]# spctl stop all
app_no_name: stopped
app:app_102: stopped
app:app_100: stopped
app:app_101: stopped
app_with_name:myapp_1: stopped
app_with_name:myapp_3: stopped
app_with_name:myapp_2: stopped

[root@master ~]# spctl start all
app_no_name: started
app:app_102: started
app:app_100: started
app:app_101: started
app_with_name:myapp_1: started
app_with_name:myapp_3: started
app_with_name:myapp_2: started

[root@master ~]# spctl stop all
app:app_101: stopped
app_no_name: stopped
app:app_102: stopped
app_with_name:myapp_1: stopped
app_with_name:myapp_3: stopped
app:app_100: stopped
app_with_name:myapp_2: stopped

[root@master ~]# spctl start all
app_no_name: started
app:app_102: started
app:app_100: started
app:app_101: started
app_with_name:myapp_1: started
app_with_name:myapp_3: started
app_with_name:myapp_2: started
```

可以看到，停止顺序并不是完成相同，启动顺序是按优先级顺序启动的，这个位置停止处的显示，有可能是因为输出延迟导致的。

理论上，应该是优先级高（数字小的）在启动时先启动，在停止时后停止。



#### 4.7.6 `autorestart`自动重启异常退出的应用

注意，**该参数与`autostart`意义不一样，`autostart`是指`supervisord`服务启动后，自动启动管理的应用。而`autorestart`是指是否自动重启管理的应用。**

默认情况下，当Supervisor管理的应用异常停止时，Supervisor会自动重启该应用。

我们尝试手动杀掉`app_no_name`对应的进程：

```sh
# 查看应用状态
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 9613, uptime 20:57:41
app:app_101                      RUNNING   pid 9614, uptime 20:57:41
app:app_102                      RUNNING   pid 9612, uptime 20:57:41
app_no_name                      RUNNING   pid 13570, uptime 0:00:02
app_with_name:myapp_1            RUNNING   pid 9615, uptime 20:57:41
app_with_name:myapp_2            RUNNING   pid 9617, uptime 20:57:41
app_with_name:myapp_3            RUNNING   pid 9616, uptime 20:57:41

# 杀掉app_no_name对应的进程，并查看应用状态
# 可以看到，此时应用马上就在`STARTING`正在启动状态
[root@master ~]# kill -9 13570; spctl status
app:app_100                      RUNNING   pid 9613, uptime 20:58:13
app:app_101                      RUNNING   pid 9614, uptime 20:58:13
app:app_102                      RUNNING   pid 9612, uptime 20:58:13
app_no_name                      STARTING
app_with_name:myapp_1            RUNNING   pid 9615, uptime 20:58:13
app_with_name:myapp_2            RUNNING   pid 9617, uptime 20:58:13
app_with_name:myapp_3            RUNNING   pid 9616, uptime 20:58:13

# 再次查看应用状态时，可以看到`app_no_name`已经是`RUNNING`正在运行状态
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 9613, uptime 20:58:18
app:app_101                      RUNNING   pid 9614, uptime 20:58:18
app:app_102                      RUNNING   pid 9612, uptime 20:58:18
app_no_name                      RUNNING   pid 13682, uptime 0:00:05
app_with_name:myapp_1            RUNNING   pid 9615, uptime 20:58:18
app_with_name:myapp_2            RUNNING   pid 9617, uptime 20:58:18
app_with_name:myapp_3            RUNNING   pid 9616, uptime 20:58:18
[root@master ~]#
```

当我将所有`cat`进程都杀掉后，应用又自动重启了：

```sh
[root@master ~]# killall cat
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 16849, uptime 0:00:04
app:app_101                      RUNNING   pid 16850, uptime 0:00:04
app:app_102                      RUNNING   pid 16847, uptime 0:00:04
app_no_name                      RUNNING   pid 16848, uptime 0:00:04
app_with_name:myapp_1            RUNNING   pid 16851, uptime 0:00:04
app_with_name:myapp_2            RUNNING   pid 16853, uptime 0:00:04
app_with_name:myapp_3            RUNNING   pid 16852, uptime 0:00:04
[root@master ~]#
```

我们关闭`app_no_name`的`autorestart`功能，然后再进行测试：

```ini
[program:app_no_name]
command = cat
priority = 901
autorestart = false

[program:app]
command = cat
process_name = %(program_name)s_%(process_num)s
numprocs = 3
numprocs_start = 100
priority = 902

[program:app_with_name]
command = cat
process_name = myapp_%(process_num)s
numprocs = 3
numprocs_start = 1
priority = 903
```

加载加载配置，然后测试：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 19959, uptime 0:00:03
app:app_101                      RUNNING   pid 19960, uptime 0:00:03
app:app_102                      RUNNING   pid 19958, uptime 0:00:03
app_no_name                      RUNNING   pid 19957, uptime 0:00:03
app_with_name:myapp_1            RUNNING   pid 19961, uptime 0:00:03
app_with_name:myapp_2            RUNNING   pid 19963, uptime 0:00:03
app_with_name:myapp_3            RUNNING   pid 19962, uptime 0:00:03

# 杀掉app_no_name应用对应的进程19957
[root@master ~]# kill -9 19957

# 再次查看应用状态，可以看到app_no_name状态已经是EXITED退出状态了
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 19959, uptime 0:00:16
app:app_101                      RUNNING   pid 19960, uptime 0:00:16
app:app_102                      RUNNING   pid 19958, uptime 0:00:16
app_no_name                      EXITED    Sep 04 10:13 PM
app_with_name:myapp_1            RUNNING   pid 19961, uptime 0:00:16
app_with_name:myapp_2            RUNNING   pid 19963, uptime 0:00:16
app_with_name:myapp_3            RUNNING   pid 19962, uptime 0:00:16
[root@master ~]#
```



#### 4.7.7 `autostart`自动启动应用

我们修改上节的配置：

```ini
[program:app_no_name]
command = cat
priority = 901
autostart = false

[program:app]
command = cat
process_name = %(program_name)s_%(process_num)s
numprocs = 3
numprocs_start = 100
priority = 902

[program:app_with_name]
command = cat
process_name = myapp_%(process_num)s
numprocs = 3
numprocs_start = 1
priority = 903
```

查看应用状态，并重新加载配置：

```sh
# 查看应用状态，可以看到应用都在运行
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 21693, uptime 0:00:33
app:app_101                      RUNNING   pid 21694, uptime 0:00:33
app:app_102                      RUNNING   pid 21692, uptime 0:00:33
app_no_name                      RUNNING   pid 21789, uptime 0:00:05
app_with_name:myapp_1            RUNNING   pid 21695, uptime 0:00:33
app_with_name:myapp_2            RUNNING   pid 21697, uptime 0:00:33
app_with_name:myapp_3            RUNNING   pid 21696, uptime 0:00:33

# 重新加载配置
[root@master ~]# spctl reload
Restarted supervisord

# 可以看到，其他应用都启动了
# 只有app_no_name应用没有启动，状态为Not started，表示未启动
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 21842, uptime 0:00:02
app:app_101                      RUNNING   pid 21843, uptime 0:00:02
app:app_102                      RUNNING   pid 21841, uptime 0:00:02
app_no_name                      STOPPED   Not started
app_with_name:myapp_1            RUNNING   pid 21844, uptime 0:00:02
app_with_name:myapp_2            RUNNING   pid 21846, uptime 0:00:02
app_with_name:myapp_3            RUNNING   pid 21845, uptime 0:00:02
[root@master ~]#
```

我们杀掉`supervisord`应用进程后，再重启该应用：

```sh
[root@master ~]# spstatus
root     20570     1  0 22:16 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# kill -9 20570
[root@master ~]# spctl status
unix:///var/run/supervisor/supervisor.sock refused connection
[root@master ~]# spstart
[root@master ~]# spctl status
app:app_100                      RUNNING   pid 22325, uptime 0:00:02
app:app_101                      RUNNING   pid 22326, uptime 0:00:02
app:app_102                      RUNNING   pid 22324, uptime 0:00:02
app_no_name                      STOPPED   Not started
app_with_name:myapp_1            RUNNING   pid 22327, uptime 0:00:02
app_with_name:myapp_2            RUNNING   pid 22329, uptime 0:00:02
app_with_name:myapp_3            RUNNING   pid 22328, uptime 0:00:02
```

可以看到，`app_no_name`还是没有自动启动！！！

为了方便Supervisor管理应用，还是建议使用`autostart = true`自动启动管理的应用！



#### 4.7.8 `user`改变运行应用的用户

当使用`root`用户启动`supervisord`服务时，可以通过`user`参数来改变应用运行时的用户。

默认情况下，`supervisord`会以运行用户`root`启动应用。通过`user`修改启动用户时，启动用户应在`/etc/passwd`中可以查找到，否则会启动异常，提示`Error: Invalid user name nonono in section`异常。

注意，`command`指定命令时，不要使用`alias`定义的快捷命令，修改配置：

```ini
[program:fast_web]
command = fastweb3 8765
autostart = true
autorestart = true
user = nobody
```

重启服务：

```sh
# spstart
# spctl status
fast_web                         BACKOFF   can't find command 'fastweb3'
```

此时，可以看到，启动异常。

我们应直接使用`python3 -m http.server 8765`来启动HTTP服务：

```ini
[program:fast_web]
command = python3 -m http.server 8765
autostart = true
autorestart = true
user = nobody
```

重启服务：

```sh
# spctl reload
Restarted supervisord
# spctl status
fast_web                         RUNNING   pid 5207, uptime 0:00:03
# ps -ef|head -n 1;ps -ef|grep nobody|grep -v grep
UID        PID  PPID  C STIME TTY          TIME CMD
nobody    5207  4348  0 23:15 ?        00:00:00 python3 -m http.server 8765
```

重启后，的确可以看到进程的UID已经修改为`nobody`了。



此时，打开页面 [http://master.hellogitlab.com:8765/](http://master.hellogitlab.com:8765/)：


可以看到，此处共享的目录并不是我们想共享的目录，因此需要修改限制，增加一个`directory`参数来限制工作目录：

```sh
# 修改配置
# echo 'directory = /tmp/fastweb' >> /etc/supervisord.conf
```

查看配置：

```ini
[program:fast_web]
command = python3 -m http.server 8765
autostart = true
autorestart = true
user = nobody
directory = /tmp/fastweb
```

 重新加载配置，并查看状态：

```sh
# spctl reload
Restarted supervisord
# spctl status
fast_web                         RUNNING   pid 7601, uptime 0:00:02
```

查看`index.html`内容：

```html
# cat /tmp/fastweb/index.html
<html>
  <head>
    <meta charset="utf-8">
    <link rel="icon" href="favicon.ico">
  </head>
  <body>
   fast web
   <hr>
   <ul>
   <li><a href="backup/">backup/</a></li>
   </ul>
   <hr>
  </body>
</html>
```

此时打开页面，效果图如下：


这样就是用Supervisor管理共享目录了。

不想共享的时候，就将`fast_web`应用停掉：

```sh
# spctl stop fast_web
fast_web: stopped
# spctl status
fast_web                         STOPPED   Sep 05 11:31 PM
```

此时，就停止Web分享了。



#### 4.7.9 `directory`修改工作目录

默认情况下，Supervisor并不会切换管理的应用的工作目录，当需要在指定目录运行命令时，使用`directory`可以切换工作目录。

示例则可以参考上一节的共享目录的设置：

```ini
[program:fast_web]
command = python3 -m http.server 8765
autostart = true
autorestart = true
user = nobody
directory = /tmp/fastweb
```

当设置了正确的工作目录后，可以正确的分享自己需要共享的目录了。



如果不指定`directory`参数，默认会在`/`根目录运行程序。

请看到下示例：

```ini
[program:test_ping]
command = ping localhost
stdout_logfile = ./test_ping.log
```

重启加载配置：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
fast_web                         RUNNING   pid 21652, uptime 0:00:03
test_ping                        RUNNING   pid 21653, uptime 0:00:03
[root@master ~]# ll test_ping.log
ls: cannot access test_ping.log: No such file or directory
[root@master ~]# ll /test_ping.log
-rw-r--r-- 1 root root 1606 Sep  7 20:54 /test_ping.log
[root@master ~]# tail /test_ping.log
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=23 ttl=64 time=0.030 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=24 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=25 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=26 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=27 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=28 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=29 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=30 ttl=64 time=0.021 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=31 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=32 ttl=64 time=0.022 ms
[root@master ~]#
```

而我们通过`fuser`或`lsof`可以看出文件被哪个进程占用过：

```sh
[root@master ~]# fuser -uv /test_ping.log
                     USER        PID ACCESS COMMAND
/test_ping.log:      root       4348 F.... (root)supervisord
[root@master ~]# lsof /test_ping.log
COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF  NODE NAME
superviso 4348 root   18w   REG  253,1    14503 23220 /test_ping.log
[root@master ~]# spstatus
root      4348     1  0 Sep05 ?        00:00:25 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
```

可以看到，默认工作目录是`/`根目录。

当停止应用时，日志不再输出：


#### 4.7.10 `stdout_logfile`日志文件设置

涉及日志文件的配置项比较多，此除不一一测试。包括：

- `redirect_stderr` ,重定向标准异常到标准输出。
- `stdout_logfile`，标准输出日志文件。
- `stdout_logfile_maxbytes`， 标准输出日志文件大小。
- `stdout_logfile_backups`， 标准输出日志文件备份数量。
- ... 其他以`std`开头的配置项。

我们为了不设置标准异常日志，将标准异常输出到标准输出配置文件中。

看以下示例：

```ini
[program:test_ping]
command = ping localhost
redirect_stderr = true
stdout_logfile = /var/log/test_ping.log
stdout_logfile_maxbytes = 1KB
stdout_logfile_backups = 3
```

重启配置：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
test_ping                        RUNNING   pid 12917, uptime 0:00:02
```

查看日志文件数量：

```sh
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root 1014 Sep  7 23:09 /var/log/test_ping.log
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  148 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  222 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  370 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  518 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  592 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  666 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  740 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  814 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  888 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  962 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root    0 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  148 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  222 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  296 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  370 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  444 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  518 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  592 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  592 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  666 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  740 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  814 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  888 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  962 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root    0 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root   74 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  148 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  222 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  296 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  370 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  370 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  444 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  518 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  592 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  666 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  740 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  740 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  814 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  888 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  962 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root    0 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root   74 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]# ls -lah /var/log/test_ping.log*
-rw-r--r-- 1 root root  222 Sep  7 23:09 /var/log/test_ping.log
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.1
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.2
-rw-r--r-- 1 root root 1.1K Sep  7 23:09 /var/log/test_ping.log.3
[root@master ~]#
```

可以看到，当日志文件超过规定的大小`1KB`后，就会自动生成一个备份文件。

```sh
[root@master ~]# tail /var/log/test_ping.log.3
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=103 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=104 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=105 ttl=64 time=0.028 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=106 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=107 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=108 ttl=64 time=0.025 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=109 ttl=64 time=0.029 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=110 ttl=64 time=0.022 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=111 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=112 ttl=64 time=0.027 ms
[root@master ~]# tail /var/log/test_ping.log.2
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=131 ttl=64 time=0.021 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=132 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=133 ttl=64 time=0.028 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=134 ttl=64 time=0.025 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=135 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=136 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=137 ttl=64 time=0.025 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=138 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=139 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=140 ttl=64 time=0.026 ms
[root@master ~]# tail /var/log/test_ping.log.1
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=145 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=146 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=147 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=148 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=149 ttl=64 time=0.011 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=150 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=151 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=152 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=153 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=154 ttl=64 time=0.025 ms
[root@master ~]# tail /var/log/test_ping.log
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=155 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=156 ttl=64 time=0.026 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=157 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=158 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=159 ttl=64 time=0.025 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=160 ttl=64 time=0.024 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=161 ttl=64 time=0.027 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=162 ttl=64 time=0.024 ms
64 bytes from VM-4-7-centos (127.0.0.1): icmp_seq=163 ttl=64 time=0.026 ms
[root@master ~]#
```

通过查看日志内容可知，最先生成的日志会存放在较大数字的备份文件中(如`test_ping.log.3`)，当当前日志超过日志文件规定大小时，就会重新生成一个新的备份文件，并重名为`test_ping.log.1`，而原先的`test_ping.log.1`文件会被命名为`test_ping.log.2`，原先的`test_ping.log.2`文件会被命名为`test_ping.log.3`，原先的`test_ping.log.3`文件会被删除。



#### 4.7.11 `environment`设置环境变量

本节模拟一个Flask Web应用。

编写一个Flask的`app.py`应用：

```py
import os
import json
from flask import Flask
app = Flask(__name__)

port = os.environ.get('FLASK_PORT')
debug = os.environ.get('FLASK_DEBUG')
environment = os.environ.get('FLASK_ENV')

env_info ={
    'port': port,
    'debug': debug,
    'environment': environment,
}

@app.route('/')
def hello_world():
    return 'Hello World!'

@app.route('/env')
def env():
    return  json.dumps(env_info, ensure_ascii=False)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)
```

编辑配置如下：

```ini
[program:flaskapp]
command = python3 app.py
directory = /tmp/test_flask
redirect_stderr = true
stdout_logfile = /tmp/test_flask/test_flask.log
environment=FLASK_PORT=8765,FLASK_DEBUG='True',FLASK_ENV=development2022
```

重新加载配置：

```sh
[root@master test_flask]# spctl reload
Restarted supervisord
[root@master test_flask]# spctl status
flaskapp                         RUNNING   pid 28221, uptime 0:00:05
```

访问 [http://master.hellogitlab.com:8765/](http://master.hellogitlab.com:8765/):



访问 [http://master.hellogitlab.com:8765/env](http://master.hellogitlab.com:8765/env)：


说明flask应用正常启动了！！并且页面中也显示了Supervisor传输过去的环境变量！！！



### 4.8 `[include]`块设置

- 配置文件中可以包含`[include]`块，如果设置了`[include]`块，则必须配置一个`files`参数，值是对应的文件。

直接看默认的配置：

```ini
; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = supervisord.d/*.ini
```

即只包含一个`files`参数，并且由`supervisord.d/*.ini`指定包含`supervisord.d`目录下面所有的`ini`配置文件。

通过该参数，就可以将原来在`/etc/supervisord.conf`中配置的应用块给转移到`/etc/supervisord.d`目录下，将各个应用分离开，便于管理。

我们将`/etc/supervisord.conf`中原来的应用注释掉，排除注释后查看文件内容：

```sh
[root@master supervisord.d]# pwd
/etc/supervisord.d
[root@master supervisord.d]# grep -v '^;' /etc/supervisord.conf |awk NF
[unix_http_server]
file=/var/run/supervisor/supervisor.sock   ; (the path to the socket file)
[inet_http_server]         ; inet (TCP) server disabled by default
port=10.0.4.7:9001
username=user              ; (default is no username (open server))
password={SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d
[supervisord]
logfile=/var/log/supervisor/supervisord.log  ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (log level;default info; others: debug,warn,trace)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
[supervisorctl]
serverurl=unix:///var/run/supervisor/supervisor.sock ; use a unix:// URL  for a unix socket
prompt=supervisor         ; cmd line prompt (default "supervisor")
[include]
files = supervisord.d/*.ini
[root@master supervisord.d]#
```

然后，在`/etc/supervisord.d`目录下创建几个应用：

```sh
[root@master supervisord.d]# cat app1.ini
[program:app1]
command=/bin/cat
[root@master supervisord.d]# cat app2.ini
[program:app2]
command=/bin/cat
[root@master supervisord.d]# cat flaskapp.ini
[program:flaskapp]
command = python3 app.py
directory = /tmp/test_flask
redirect_stderr = true
stdout_logfile = /tmp/test_flask/test_flask.log
environment = FLASK_PORT=8765,FLASK_DEBUG='False',FLASK_ENV=development2022

[root@master supervisord.d]#
```

然后，我们重新加载配置：

```sh
[root@master supervisord.d]# spctl reload
Restarted supervisord
[root@master supervisord.d]# spctl status
app1                             RUNNING   pid 26284, uptime 0:00:03
app2                             RUNNING   pid 26283, uptime 0:00:03
flaskapp                         RUNNING   pid 26282, uptime 0:00:03
```

可以看到三个应用都启动起来了，说明Supervisor自动加载了在`/etc/supervisord.d`目录下的`ini`配置文件！



### 4.9 其他块设置

`[group:x]`、`[fcgi-program:x]`、`[eventlistener:x]`、`[rpcinterface:x]`块很少使用，忽略。



## 5. 子进程

- **supervisord**的主要目的是根据配置文件中的数据创建和管理进程。它通过创建子进程来实现这一点。supervisor生成的每个子进程在其整个生命周期内都由supervisord管理( **supervisord**是它创建的每个进程的父进程)。当子进程死亡时，通过 `SIGCHLD`信号通知supervisor其子进程死亡，并执行适当的操作。

### 5.1 非守护的子进程

- 由supervisor运行的程序都不应是守护进程，它们必须在前台运行。
- 由supervisor运行的程序不应与终端分离。
- 最简单的判断一个程序是否是守护进程，是你在命令行命令该命令，然后看它是否将控制权交给你，如果将控制权交给你了（此时你可以输出其他命令，做其他的操作）就说明这个进程是守护进程。如果它继续在前台运行，那么你可以通过按`Ctrl + C`来停止它，然后你就可以获得终端控制权了。
- 有些程序(如`mysqld`)会忽略supervisor发送给它的信号。supervisor只会杀死它管理的进程，不能杀死由它管理的进程产生的子进程。这类进程通常有一个`PIDFILE`，包含进程的PID。此时可以使用`pidproxy`来处理这类程序。

```ini
[program:mysql]
command=/path/to/pidproxy /path/to/pidfile /path/to/mysqld_safe
```

查看`pidproxy`路径和内容：

```sh
[root@master ~]# whereis pidproxy
pidproxy: /usr/bin/pidproxy
[root@master ~]# cat /usr/bin/pidproxy
#!/usr/bin/python
# EASY-INSTALL-ENTRY-SCRIPT: 'supervisor==3.4.0','console_scripts','pidproxy'
__requires__ = 'supervisor==3.4.0'
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.exit(
        load_entry_point('supervisor==3.4.0', 'console_scripts', 'pidproxy')()
    )
[root@master ~]#
```

- 在运行子进程时，没有shell被**supervisord**执行，所以像`USER`、`PATH`、`HOME`、`SHELL`、`LOGNAME`等环境变量不会从默认值改变或重新分配。注意，当您以root用户运行配置中带有`user=`节的**supervisord**程序时，这一点特别重要。与**cron**不同，当对`user=`程序配置选项中定义的用户执行setuid时，**supervisord**不会试图识别和覆盖基本环境变量，如`USER`、`PATH`、`HOME`和`LOGNAME`。如果需要为特定程序设置环境变量，而这些变量可能由shell调用为特定用户设置，则必须在`environment=` 程序配置选项中显式设置。



### 5.2 进程状态

直接看官方的状态图：

- 由Supervisor管理的应用通常处于上图中指出的某一种状态，你在客户端可以看到这些状态名称。
- `STOPPED`(0)，进程按要求停止掉，或者从来就没启动过。
- `STARTING`(10)，进程正在启动。
- `RUNNING`(20)，进程正在运行。
- `BACKOFF`(30)，进程进入到启动状态后，在定义的`startsecs`秒前，很快就退出，无法进入到运行状态，此时就称为`BACKOFF`状态，即回退状态，发生某种异常强制退出。
- `STOPPING`(40)，进程按要求正在停止状态。
- `EXITED`(100)，进程由运行状态退出（预期或意外退出）。
- `FATAL`(200)，进程无法成功启动，致命错误状态。
- `UNKNOWN`(1000)，未知状态，supervisor程序异常。



#### 5.2.1 RUNNING、BACKOFF、FATAL状态切换

如果一个配置有自动重启的程序处于`BACKOFF`回退状态时，Supervisor会自动重启该程序，此时程序会在`STARTTING`启动中和`BACKOFF`回退状态之间切换，直到Supervisor在指定重试次数`startretries`后，如果程序还没有启动成功，则会将程序状态设置为`FATAL`致命错误，无法启动。

#### 5.2.2 重试说明

重试会增加等待时间。每次等待时间比上一次多一秒。

如设置`startretries = 3`重试次数为3，`supervisord`会等待1秒后重试第一次运行程序，当重试第1次失败后，`supervisord`会等待2秒后重试第二次运行程序，当重试第2次失败后，`supervisord`会等待3秒后重试第三次运行程序，当重试第3次还是失败时，`supervisord`就不会再重试了，会将程序状态设置为`FATAL`致命错误状态。

#### 5.2.3 `EXITED`退出的程序会重启吗

`EXITED`退出的程序会不会重启跟`autorestart`配置有关。

- `autorestart = false`时，即不重启，退出的程序从不会自动重启。
- `autorestart = true`时，即重启，退出的程序会无条件自动重启。
- `autorestart = unexpected`时，即有条件不重启，退出的程序有条件会自动重启。如果程序退出码与`exitcodes`不匹配，则会自动重启。

#### 5.2.4 程序无法启动状态异常怎么处理

通道情况下，我们可以去看`/var/log/supervisor/supervisor.log`:

```sh
[root@master ~]# ls -lah /var/log/supervisor/supervisord.log
-rw-r--r-- 1 root root 51K Sep  8 21:28 /var/log/supervisor/supervisord.log
[root@master ~]# tail /var/log/supervisor/supervisord.log
2022-09-08 20:37:05,854 INFO spawned: 'app1' with pid 26284
2022-09-08 20:37:07,140 INFO success: flaskapp entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-09-08 20:37:07,140 INFO success: app2 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-09-08 20:37:07,140 INFO success: app1 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-09-08 21:28:00,274 INFO waiting for flaskapp to stop
2022-09-08 21:28:00,274 INFO waiting for app2 to stop
2022-09-08 21:28:00,274 INFO waiting for app1 to stop
2022-09-08 21:28:00,274 INFO stopped: app2 (terminated by SIGTERM)
2022-09-08 21:28:00,274 INFO stopped: app1 (terminated by SIGTERM)
2022-09-08 21:28:00,275 INFO stopped: flaskapp (terminated by SIGTERM)
[root@master ~]#
```

如果管理的程序有定义自己的日志文件，也可以去看它自己的日志文件来排查异常。



## 6. 日志

**supervisord**执行的主要任务之一是日志记录。 **supervisord**会记录一个活动日志，详细描述它在运行时所做的事情。它还将子进程stdout和stderr输出记录到其他文件(如果配置为这样做的话)。

```sh
[root@master ~]# grep -A4 '\[supervisord]' /etc/supervisord.conf
[supervisord]
logfile=/var/log/supervisor/supervisord.log  ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (log level;default info; others: debug,warn,trace)
```

通常情况下，我们只用保持这个`loglevel = info`即可。

简单看一下日志等级：

| 配置文件值/Config File Value | 输出编码/Output Code | 描述/Description                                                                                                                                                    |
| ---------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| critical                     | CRIT                 | Messages that indicate a condition that requires immediate user attention, a supervisor state change, or an error in supervisor itself. 立即需要注意并处理的        |
| error                        | ERRO                 | Messages that indicate a potentially ignorable error condition (e.g. unable to clear a log directory).错误异常                                                      |
| warn                         | WARN                 | Messages that indicate an anomalous condition which isn’t an error. 警告信息                                                                                        |
| info                         | INFO                 | Normal informational output.  This is the default log level if none is explicitly configured. 正常消息输出                                                          |
| debug                        | DEBG                 | Messages useful for users trying to debug process configuration and communications behavior (process output, listener state changes, event notifications). 调试消息 |
| trace                        | TRAC                 | Messages useful for developers trying to debug supervisor plugins, and information about HTTP and RPC requests and responses. 调试supervisor插件相关的消息          |
| blather                      | BLAT                 | Messages useful for developers trying to debug supervisor itself. 开发supervisor程序使用的消息                                                                      |



## 7. 事件

事件是supervisor 3.0中引入的新特征，如果仅想使用supervisor来管理应用程序的话，可以不用理会事件。

我们忽略！



## 8. XML-RPC API接口

- 我们可以使用XML-RPC API接口来扩展supervisor的功能。
- 你可以使用第三方的RPC接口插件，也可以自己写插件。



### 8.1 配置XML-RPX 接口工厂模式

> An additional RPC interface is configured into a supervisor installation by adding a `[rpcinterface:x]` section in the Supervisor configuration file.
>
> In the sample config file, there is a section which is named `[rpcinterface:supervisor]`.  By default it looks like this:
>
> ```
> [rpcinterface:supervisor]
> supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
> ```
>
> This section *must* remain in the configuration for the standard setup of supervisor to work properly.  If you don’t want supervisor to do anything it doesn’t already do out of the box, this is all you need to know about this type of section.

通常情况下，我们可以增加额外的`[rpcinterface:x]`块来增加新的接口。

但是，配置文件中必须包含以下配置：

```ini
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
```

如果你不想让Supervisor做任何事，你可以不用配置这个。如果要让它管理其他应用，配置文件中应包含以上配置。

配置文件中默认已经添加了这两行配置。



如果我们注释掉这两行配置项：

```ini
; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
; [rpcinterface:supervisor]
; supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
```

然后再尝试重新加载配置：

```sh
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
Sorry, supervisord responded but did not recognize the supervisor namespace commands that supervisorctl uses to control it.  Please check that the [rpcinterface:supervisor] section is enabled in the configuration file (see sample.conf).
[root@master ~]#
[root@master ~]# spstatus
root      4232     1  0 20:11 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# ps -ef|grep cat
root      7346  4232  0 20:27 ?        00:00:00 /bin/cat
root      7347  4232  0 20:27 ?        00:00:00 /bin/cat
root      7348  4232  0 20:27 ?        00:00:00 /bin/cat
root      9269 31815  0 20:38 pts/4    00:00:00 grep --color=auto cat
```

此时，虽然`supervisord`程序启动了，应用程序也启动了，但我们`supervisorctl`命令行却不能行，同时，Web页面也不能正常访问。

为了让命令行和web页面能够正常使用，我们取消这两行的注释。然后再重启：

```ini
; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
```

注意此时需要重新启动`supervisord`服务：

```sh
[root@master ~]# spstatus
root      4232     1  0 20:11 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# kill -9 4232
[root@master ~]# spstart
[root@master ~]# spctl reload
Restarted supervisord
[root@master ~]# spctl status
app1                             RUNNING   pid 10299, uptime 0:00:07
app2                             RUNNING   pid 10298, uptime 0:00:07
flaskapp                         RUNNING   pid 10297, uptime 0:00:07
[root@master ~]#
```

此时Web页面也可以正常访问。



### 8.2 API接口的使用

我们直接按官方示例操作。请参考 [http://supervisord.org/api.html#xml-rpc-api-documentation](http://supervisord.org/api.html#xml-rpc-api-documentation) 。

**为了使用API接口，你必须像上一节那样，在配置文件中配置好`[rpcinterface:supervisor]`块。**

直接用客户端连接。

#### 8.2.1 Python2 连接示例

官方示例：

```python
import xmlrpclib
server = xmlrpclib.Server('http://localhost:9001/RPC2')
```

操作过程：

```python
[root@master ~]# python
Python 2.7.5 (default, Nov 16 2020, 22:23:17)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-44)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import xmlrpclib
>>> server = xmlrpclib.Server('http://localhost:9001/RPC2')
>>> server.supervisor.getVersion()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1233, in __call__
    return self.__send(self.__name, args)
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1591, in __request
    verbose=self.__verbose
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1273, in request
    return self.single_request(host, handler, request_body, verbose)
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1301, in single_request
    self.send_content(h, request_body)
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1448, in send_content
    connection.endheaders(request_body)
  File "/usr/lib64/python2.7/httplib.py", line 1052, in endheaders
    self._send_output(message_body)
  File "/usr/lib64/python2.7/httplib.py", line 890, in _send_output
    self.send(msg)
  File "/usr/lib64/python2.7/httplib.py", line 852, in send
    self.connect()
  File "/usr/lib64/python2.7/httplib.py", line 833, in connect
    self.timeout, self.source_address)
  File "/usr/lib64/python2.7/socket.py", line 571, in create_connection
    raise err
socket.error: [Errno 111] Connection refused
>>>
```

操作命令失败！！！提示连接拒绝。原因，我们在配置文件中设置了如下配置：

```ini
[inet_http_server]         ; inet (TCP) server disabled by default
;port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
port=10.0.4.7:9001
username=user              ; (default is no username (open server))
;password=123               ; (default is no password (open server))

password={SHA}82ab876d1387bfafe46cc1c8a2ef074eae50cb1d
```

即设置了使用IP形式访问接口，并配置了用户名密码认证。因此，为了正常访问接口，应使用IP形式访问，我们将`localhost`替换成IP再访问接口：

```python
>>> server = xmlrpclib.Server('http://10.0.4.7:9001/RPC2')
>>> server.supervisor.getState()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1233, in __call__
    return self.__send(self.__name, args)
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1591, in __request
    verbose=self.__verbose
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1273, in request
    return self.single_request(host, handler, request_body, verbose)
  File "/usr/lib64/python2.7/xmlrpclib.py", line 1321, in single_request
    response.msg,
xmlrpclib.ProtocolError: <ProtocolError for 10.0.4.7:9001/RPC2: 401 Unauthorized>
```

此时，可以看到，提示认证失败。因此我们在建立rpc server时应提供认证。

```python
import xmlrpclib
server = xmlrpclib.Server('http://username:password@ip:9001/RPC2')
```

再尝试一下：

```python
>>> server = xmlrpclib.Server('http://user:thepassword@10.0.4.7:9001/RPC2')
>>> server.supervisor.getState()
{'statename': 'RUNNING', 'statecode': 1}
>>>
```

可以看到，通过使用IP并配置用户名和密码后，服务连接建立成功。接口正常返回了数据。



#### 8.2.2 Python3 连接示例

官方示例：

```python
from xmlrpc.client import ServerProxy
server = ServerProxy('http://localhost:9001/RPC2')
```

有了python2的操作经验，我们在python3测试时，直接使用ip、用户名密码进行认证建立连接，操作过程如下：

```python
[root@master ~]# python3
Python 3.6.8 (default, Nov 16 2020, 16:55:22)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-44)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from xmlrpc.client import ServerProxy
>>> server = ServerProxy('http://user:thepassword@10.0.4.7:9001/RPC2')
>>> server.supervisor.getState()
{'statename': 'RUNNING', 'statecode': 1}
>>>
```

可以看到，直接能够连接成功，访问接口正常！！！



**后面我们使用Python 3来测试API接口。**



#### 8.2.3 状态与控制

##### 8.2.3.1 获取API版本信息

```python
# api版本信息
>>> server.supervisor.getAPIVersion()
'3.0'

# supervisor版本信息
>>> server.supervisor.getSupervisorVersion()
'3.4.0'
```



##### 8.2.3.2 获取Supervisor标识字符串

```python
>>> server.supervisor.getIdentification()
'supervisor'
```



##### 8.2.3.3 获取Supervisor当前状态

```python
>>> server.supervisor.getState()
{'statename': 'RUNNING', 'statecode': 1}
```



##### 8.2.3.4 获取supervisord的pid

```python
>>> server.supervisor.getPID()
10279
```

查看当前的supeervisord的pid:

```sh
[root@master ~]# spstatus
root     10279     1  0 Sep11 ?        00:00:31 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
```



##### 8.2.3.5 关闭supervisor服务

```python
>>> server.supervisor.shutdown()
true
```

查看当前的supeervisord的进程:

```sh
[root@master ~]# ps -ef|grep supervisord
root      5874  3653  0 22:24 pts/4    00:00:00 grep --color=auto supervisord
```

此时，可以看到已经没有`supervisord`进程了。

当应用关掉后，连接会被断开，不能执行其他命令：

```python
>>> server.supervisor.restart()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1112, in __call__
    return self.__send(self.__name, args)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1452, in __request
    verbose=self.__verbose
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1154, in request
    return self.single_request(host, handler, request_body, verbose)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1166, in single_request
    http_conn = self.send_request(host, handler, request_body, verbose)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1279, in send_request
    self.send_content(connection, request_body)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1309, in send_content
    connection.endheaders(request_body)
  File "/usr/lib64/python3.6/http/client.py", line 1249, in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
  File "/usr/lib64/python3.6/http/client.py", line 1036, in _send_output
    self.send(msg)
  File "/usr/lib64/python3.6/http/client.py", line 974, in send
    self.connect()
  File "/usr/lib64/python3.6/http/client.py", line 946, in connect
    (self.host,self.port), self.timeout, self.source_address)
  File "/usr/lib64/python3.6/socket.py", line 724, in create_connection
    raise err
  File "/usr/lib64/python3.6/socket.py", line 713, in create_connection
    sock.connect(sa)
ConnectionRefusedError: [Errno 111] Connection refused
>>> server.supervisor.getAPIVersion()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1112, in __call__
    return self.__send(self.__name, args)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1452, in __request
    verbose=self.__verbose
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1154, in request
    return self.single_request(host, handler, request_body, verbose)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1166, in single_request
    http_conn = self.send_request(host, handler, request_body, verbose)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1279, in send_request
    self.send_content(connection, request_body)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1309, in send_content
    connection.endheaders(request_body)
  File "/usr/lib64/python3.6/http/client.py", line 1249, in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
  File "/usr/lib64/python3.6/http/client.py", line 1036, in _send_output
    self.send(msg)
  File "/usr/lib64/python3.6/http/client.py", line 974, in send
    self.connect()
  File "/usr/lib64/python3.6/http/client.py", line 946, in connect
    (self.host,self.port), self.timeout, self.source_address)
  File "/usr/lib64/python3.6/socket.py", line 724, in create_connection
    raise err
  File "/usr/lib64/python3.6/socket.py", line 713, in create_connection
    sock.connect(sa)
ConnectionRefusedError: [Errno 111] Connection refused
>>>
```

可以看到连接拒绝。

我们在另外一个终端重新启动supervisord服务：

```sh
[root@master ~]# spstart
[root@master ~]# spstatus
root      6527     1  0 22:27 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
[root@master ~]# spctl status
app1                             RUNNING   pid 6531, uptime 0:00:07
app2                             RUNNING   pid 6530, uptime 0:00:07
flaskapp                         RUNNING   pid 6529, uptime 0:00:07
```

此时再在python命令行执行命令，可以正常执行。说明连接已经恢复。



##### 8.2.3.5 重启supervisor服务

```python
>>> server.supervisor.restart()
true
```

查看当前的supeervisord的进程:

```sh
# 查看supervisord进程，可以看到，进程pid并没有改变
[root@master ~]# spstatus
root      6527     1  0 22:27 ?        00:00:00 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
```

查看子应用状态信息：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 6940, uptime 0:00:05
app2                             RUNNING   pid 6939, uptime 0:00:05
flaskapp                         RUNNING   pid 6938, uptime 0:00:05
```

可以看到supervisor管理的应用重新启动了，其pid发生了变化。



忽略与日志相关的方法！！



#### 8.2.4 进程控制

我们停止`flaskapp`应用：

```sh
[root@master ~]# spctl stop flaskapp
flaskapp: stopped
[root@master ~]# spctl status
app1                             RUNNING   pid 6940, uptime 0:03:57
app2                             RUNNING   pid 6939, uptime 0:03:57
flaskapp                         STOPPED   Sep 13 10:33 PM
```

然后测试进程控制相关方法。



##### 8.2.4.1 查看所有应用状态信息

```python 
>>> server.supervisor.getAllProcessInfo()
[{'description': 'pid 6940, uptime 0:04:50', 'pid': 6940, 'stderr_logfile': '/tmp/app1-stderr---supervisor-tV36Pp.log', 'stop': 0, 'logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663079689, 'group': 'app1', 'name': 'app1', 'statename': 'RUNNING', 'start': 1663079399, 'state': 20, 'stdout_logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log'}, {'description': 'pid 6939, uptime 0:04:50', 'pid': 6939, 'stderr_logfile': '/tmp/app2-stderr---supervisor-733iVd.log', 'stop': 0, 'logfile': '/tmp/app2-stdout---supervisor-yp97lV.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663079689, 'group': 'app2', 'name': 'app2', 'statename': 'RUNNING', 'start': 1663079399, 'state': 20, 'stdout_logfile': '/tmp/app2-stdout---supervisor-yp97lV.log'}, {'description': 'Sep 13 10:33 PM', 'pid': 0, 'stderr_logfile': '', 'stop': 1663079632, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663079689, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'STOPPED', 'start': 1663079399, 'state': 0, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}]
```

我们可以对获取的所有信息进行处理：

```python
all_process_info = server.supervisor.getAllProcessInfo()
print('name        \tstatename\tdescription')
for info in all_process_info:
    print('{:<15}\t{:<9}\t{}'.format(
        info.get('name'),
        info.get('statename'),
        info.get('description')
    ))
```

运行后，结果如下：

```sh
name            statename       description
app1            RUNNING         pid 6940, uptime 0:19:11
app2            RUNNING         pid 6939, uptime 0:19:11
flaskapp        STOPPED         Sep 13 10:33 PM
```

与`spctl status`获取的数据差不多：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 6940, uptime 0:20:53
app2                             RUNNING   pid 6939, uptime 0:20:53
flaskapp                         STOPPED   Sep 13 10:33 PM
```

可以看到，除了`uptime`后面的数据不一致，其他的内容是一样的！！也就是说通过api获取的数据是正确的、



##### 8.2.4.2 查看单个应用状态

```python
>>> server.supervisor.getProcessInfo('flaskapp')
{'description': 'Sep 13 10:33 PM', 'pid': 0, 'stderr_logfile': '', 'stop': 1663079632, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663081461, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'STOPPED', 'start': 1663079399, 'state': 0, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}
>>> server.supervisor.getProcessInfo('app1')
{'description': 'pid 6940, uptime 0:34:27', 'pid': 6940, 'stderr_logfile': '/tmp/app1-stderr---supervisor-tV36Pp.log', 'stop': 0, 'logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081466, 'group': 'app1', 'name': 'app1', 'statename': 'RUNNING', 'start': 1663079399, 'state': 20, 'stdout_logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log'}
>>> server.supervisor.getProcessInfo('app2')
{'description': 'pid 6939, uptime 0:34:30', 'pid': 6939, 'stderr_logfile': '/tmp/app2-stderr---supervisor-733iVd.log', 'stop': 0, 'logfile': '/tmp/app2-stdout---supervisor-yp97lV.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081469, 'group': 'app2', 'name': 'app2', 'statename': 'RUNNING', 'start': 1663079399, 'state': 20, 'stdout_logfile': '/tmp/app2-stdout---supervisor-yp97lV.log'}
```



##### 8.2.4.3 启动某个应用

```python
>>> server.supervisor.startProcess('flaskapp')
True
>>> server.supervisor.getProcessInfo('flaskapp')
{'description': 'pid 13743, uptime 0:00:05', 'pid': 13743, 'stderr_logfile': '', 'stop': 1663079632, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081609, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'RUNNING', 'start': 1663081604, 'state': 20, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}
>>>
```

查看应用状态：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 6940, uptime 0:37:06
app2                             RUNNING   pid 6939, uptime 0:37:06
flaskapp                         RUNNING   pid 13743, uptime 0:00:21
```

可以看到，应用启动成功，查看状态信息一致。



##### 8.2.4.4 停止某个应用

```python
>>> server.supervisor.stopProcess('flaskapp')
True
>>> server.supervisor.getProcessInfo('flaskapp')
{'description': 'Sep 13 11:10 PM', 'pid': 0, 'stderr_logfile': '', 'stop': 1663081804, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663081807, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'STOPPED', 'start': 1663081604, 'state': 0, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}
```

查看应用状态：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 6940, uptime 0:40:20
app2                             RUNNING   pid 6939, uptime 0:40:20
flaskapp                         STOPPED   Sep 13 11:10 PM
```

可以看到，应用停止成功，查看状态信息一致。



##### 8.2.4.5 停止所有应用

```python
>>> server.supervisor.stopAllProcesses()
[{'status': 80, 'group': 'app2', 'name': 'app2', 'description': 'OK'}, {'status': 80, 'group': 'app1', 'name': 'app1', 'description': 'OK'}]
>>> server.supervisor.getAllProcessInfo()
[{'description': 'Sep 13 11:11 PM', 'pid': 0, 'stderr_logfile': '/tmp/app1-stderr---supervisor-tV36Pp.log', 'stop': 1663081881, 'logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663081893, 'group': 'app1', 'name': 'app1', 'statename': 'STOPPED', 'start': 1663079399, 'state': 0, 'stdout_logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log'}, {'description': 'Sep 13 11:11 PM', 'pid': 0, 'stderr_logfile': '/tmp/app2-stderr---supervisor-733iVd.log', 'stop': 1663081881, 'logfile': '/tmp/app2-stdout---supervisor-yp97lV.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663081893, 'group': 'app2', 'name': 'app2', 'statename': 'STOPPED', 'start': 1663079399, 'state': 0, 'stdout_logfile': '/tmp/app2-stdout---supervisor-yp97lV.log'}, {'description': 'Sep 13 11:10 PM', 'pid': 0, 'stderr_logfile': '', 'stop': 1663081804, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': -1, 'spawnerr': '', 'now': 1663081893, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'STOPPED', 'start': 1663081604, 'state': 0, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}]
```

查看应用状态：

```sh
[root@master ~]# spctl status
app1                             STOPPED   Sep 13 11:11 PM
app2                             STOPPED   Sep 13 11:11 PM
flaskapp                         STOPPED   Sep 13 11:10 PM
```

可以看到，所有应用都停止了，查看状态信息一致。





##### 8.2.4.6 启动所有应用

```python
>>> server.supervisor.startAllProcesses()
[{'status': 80, 'group': 'flaskapp', 'name': 'flaskapp', 'description': 'OK'}, {'status': 80, 'group': 'app2', 'name': 'app2', 'description': 'OK'}, {'status': 80, 'group': 'app1', 'name': 'app1', 'description': 'OK'}]
>>> server.supervisor.getAllProcessInfo()
[{'description': 'pid 14879, uptime 0:00:05', 'pid': 14879, 'stderr_logfile': '/tmp/app1-stderr---supervisor-tV36Pp.log', 'stop': 1663081881, 'logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081984, 'group': 'app1', 'name': 'app1', 'statename': 'RUNNING', 'start': 1663081979, 'state': 20, 'stdout_logfile': '/tmp/app1-stdout---supervisor-HtWh8M.log'}, {'description': 'pid 14878, uptime 0:00:05', 'pid': 14878, 'stderr_logfile': '/tmp/app2-stderr---supervisor-733iVd.log', 'stop': 1663081881, 'logfile': '/tmp/app2-stdout---supervisor-yp97lV.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081984, 'group': 'app2', 'name': 'app2', 'statename': 'RUNNING', 'start': 1663081979, 'state': 20, 'stdout_logfile': '/tmp/app2-stdout---supervisor-yp97lV.log'}, {'description': 'pid 14877, uptime 0:00:05', 'pid': 14877, 'stderr_logfile': '', 'stop': 1663081804, 'logfile': '/tmp/test_flask/test_flask.log', 'exitstatus': 0, 'spawnerr': '', 'now': 1663081984, 'group': 'flaskapp', 'name': 'flaskapp', 'statename': 'RUNNING', 'start': 1663081979, 'state': 20, 'stdout_logfile': '/tmp/test_flask/test_flask.log'}]
```

查看应用状态：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 14879, uptime 0:00:53
app2                             RUNNING   pid 14878, uptime 0:00:53
flaskapp                         RUNNING   pid 14877, uptime 0:00:53
```

可以看到，所有应用都启动了，查看状态信息一致。



##### 8.2.4.7 重新加载配置文件

> `reloadConfig`() Reload the configuration.
>
> The result contains three arrays containing names of process groups:
>
> - added gives the process groups that have been added
> - changed gives the process groups whose contents have changed
> - removed gives the process groups that are no longer in the configuration
>
> @return array result  [[added, changed, removed]]

准备一个`app3.ini`配置：

```sh
[root@master supervisord.d]# cat app3.ini
[program:app3]
command=/bin/cat
```

然后重新加载配置：

```python
# 加载配置成功,新加入的配置对应的应用不会自动启动！！！！
>>> server.supervisor.reloadConfig()
[[['app3'], [], []]]

# 加载配置后，应用并不会自动启动，尝试启动app3时会抛出异常，提示不知道app3这个应用
>>> server.supervisor.startProcess('app3')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1112, in __call__
    return self.__send(self.__name, args)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1452, in __request
    verbose=self.__verbose
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1154, in request
    return self.single_request(host, handler, request_body, verbose)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1170, in single_request
    return self.parse_response(resp)
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 1342, in parse_response
    return u.close()
  File "/usr/lib64/python3.6/xmlrpc/client.py", line 656, in close
    raise Fault(**self._stack[0])
xmlrpc.client.Fault: <Fault 10: 'BAD_NAME: app3'>
    
# 通过软重启supervisord,此时应用会自动重启
>>> server.supervisor.restart()
True
```

查看应用状态：

```sh
[root@master ~]# spctl status
app1                             RUNNING   pid 15677, uptime 0:00:03
app2                             RUNNING   pid 15676, uptime 0:00:03
app3                             RUNNING   pid 15675, uptime 0:00:03
flaskapp                         RUNNING   pid 15674, uptime 0:00:03
```



#### 8.2.5 获取系统方法和帮助信息

##### 8.2.5.1 列出系统包含哪些可用的方法

```python
>>> server.system.listMethods()
['supervisor.addProcessGroup', 'supervisor.clearAllProcessLogs', 'supervisor.clearLog', 'supervisor.clearProcessLog', 'supervisor.clearProcessLogs', 'supervisor.getAPIVersion', 'supervisor.getAllConfigInfo', 'supervisor.getAllProcessInfo', 'supervisor.getIdentification', 'supervisor.getPID', 'supervisor.getProcessInfo', 'supervisor.getState', 'supervisor.getSupervisorVersion', 'supervisor.getVersion', 'supervisor.readLog', 'supervisor.readMainLog', 'supervisor.readProcessLog', 'supervisor.readProcessStderrLog', 'supervisor.readProcessStdoutLog', 'supervisor.reloadConfig', 'supervisor.removeProcessGroup', 'supervisor.restart', 'supervisor.sendProcessStdin', 'supervisor.sendRemoteCommEvent', 'supervisor.shutdown', 'supervisor.signalAllProcesses', 'supervisor.signalProcess', 'supervisor.signalProcessGroup', 'supervisor.startAllProcesses', 'supervisor.startProcess', 'supervisor.startProcessGroup', 'supervisor.stopAllProcesses', 'supervisor.stopProcess', 'supervisor.stopProcessGroup', 'supervisor.tailProcessLog', 'supervisor.tailProcessStderrLog', 'supervisor.tailProcessStdoutLog', 'system.listMethods', 'system.methodHelp', 'system.methodSignature', 'system.multicall']
>>>
```

每行列一个方法：

```python
>>> for i in server.system.listMethods():
...     print(i)
...
supervisor.addProcessGroup
supervisor.clearAllProcessLogs
supervisor.clearLog
supervisor.clearProcessLog
supervisor.clearProcessLogs
supervisor.getAPIVersion
supervisor.getAllConfigInfo
supervisor.getAllProcessInfo
supervisor.getIdentification
supervisor.getPID
supervisor.getProcessInfo
supervisor.getState
supervisor.getSupervisorVersion
supervisor.getVersion
supervisor.readLog
supervisor.readMainLog
supervisor.readProcessLog
supervisor.readProcessStderrLog
supervisor.readProcessStdoutLog
supervisor.reloadConfig
supervisor.removeProcessGroup
supervisor.restart
supervisor.sendProcessStdin
supervisor.sendRemoteCommEvent
supervisor.shutdown
supervisor.signalAllProcesses
supervisor.signalProcess
supervisor.signalProcessGroup
supervisor.startAllProcesses
supervisor.startProcess
supervisor.startProcessGroup
supervisor.stopAllProcesses
supervisor.stopProcess
supervisor.stopProcessGroup
supervisor.tailProcessLog
supervisor.tailProcessStderrLog
supervisor.tailProcessStdoutLog
system.listMethods
system.methodHelp
system.methodSignature
system.multicall
>>>
```

可以看到方法非常多！！！



##### 8.2.5.2 获取接口方法帮助信息

```python
>>> server.system.methodHelp('supervisor.shutdown')
' Shut down the supervisor process\n\n        @return boolean result always returns True unless error\n        '
>>> server.system.methodHelp('supervisor.reloadConfig')
'\n        Reload the configuration.\n\n        The result contains three arrays containing names of process\n        groups:\n\n        * `added` gives the process groups that have been added\n        * `changed` gives the process groups whose contents have\n          changed\n        * `removed` gives the process groups that are no longer\n          in the configuration\n\n        @return array result  [[added, changed, removed]]\n\n        '
>>> server.system.methodHelp('supervisor.startProcess')
' Start a process\n\n        @param string name Process name (or ``group:name``, or ``group:*``)\n        @param boolean wait Wait for process to be fully started\n        @return boolean result     Always true unless error\n\n
```



你可以查看源码，来编写自己的插件，或者给社区做贡献！

## 9. 使用Supervisor管理Tomcat应用

- tomcat下载：[https://mirrors.cnnic.cn/apache/tomcat/](https://mirrors.cnnic.cn/apache/tomcat/)

openjdk安装：
```sh
[root@master ~]# yum install java-1.8.0-openjdk -y
```

配置`JAVA_HOME`环境变量:

```sh
[root@master ~]# whereis java
java: /usr/bin/java /usr/lib/java /etc/java /usr/share/java /usr/share/man/man1/java.1.gz
[root@master ~]# ll /usr/bin/java
lrwxrwxrwx 1 root root 22 Feb 27 22:39 /usr/bin/java -> /etc/alternatives/java
[root@master ~]# ll /etc/alternatives/java
lrwxrwxrwx 1 root root 73 Feb 27 22:39 /etc/alternatives/java -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre/bin/java
[root@master ~]# tail -n 2 /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre

[root@master ~]#
```

下载tomcat：
```sh
[root@master ~]# cd /srv/
[root@master srv]# wget https://mirrors.cnnic.cn/apache/tomcat/tomcat-9/v9.0.72/bin/apache-tomcat-9.0.72.tar.gz
[root@master srv]# tar -zxvf apache-tomcat-9.0.72.tar.gz
```

查看tomcat可执行文件夹文件信息：
```sh
[root@master srv]# cd apache-tomcat-9.0.72/bin/
[root@master bin]# ll
total 896
-rw-r----- 1 root root  35213 Feb 18 17:25 bootstrap.jar
-rw-r----- 1 root root  16840 Feb 18 17:25 catalina.bat
-rwxr-x--- 1 root root  25294 Feb 18 17:25 catalina.sh
-rw-r----- 1 root root   1664 Feb 18 17:25 catalina-tasks.xml
-rw-r----- 1 root root   2123 Feb 18 17:25 ciphers.bat
-rwxr-x--- 1 root root   1997 Feb 18 17:25 ciphers.sh
-rw-r----- 1 root root  25765 Feb 18 17:25 commons-daemon.jar
-rw-r----- 1 root root 214019 Feb 18 17:25 commons-daemon-native.tar.gz
-rw-r----- 1 root root   2040 Feb 18 17:25 configtest.bat
-rwxr-x--- 1 root root   1922 Feb 18 17:25 configtest.sh
-rwxr-x--- 1 root root   9100 Feb 18 17:25 daemon.sh
-rw-r----- 1 root root   2091 Feb 18 17:25 digest.bat
-rwxr-x--- 1 root root   1965 Feb 18 17:25 digest.sh
-rw-r----- 1 root root   3606 Feb 18 17:25 makebase.bat
-rwxr-x--- 1 root root   3382 Feb 18 17:25 makebase.sh
-rw-r----- 1 root root   3460 Feb 18 17:25 setclasspath.bat
-rwxr-x--- 1 root root   3708 Feb 18 17:25 setclasspath.sh
-rw-r----- 1 root root   2020 Feb 18 17:25 shutdown.bat
-rwxr-x--- 1 root root   1902 Feb 18 17:25 shutdown.sh
-rw-r----- 1 root root   2022 Feb 18 17:25 startup.bat
-rwxr-x--- 1 root root   1904 Feb 18 17:25 startup.sh
-rw-r----- 1 root root  48970 Feb 18 17:25 tomcat-juli.jar
-rw-r----- 1 root root 437622 Feb 18 17:25 tomcat-native.tar.gz
-rw-r----- 1 root root   4574 Feb 18 17:25 tool-wrapper.bat
-rwxr-x--- 1 root root   5540 Feb 18 17:25 tool-wrapper.sh
-rw-r----- 1 root root   2026 Feb 18 17:25 version.bat
-rwxr-x--- 1 root root   1908 Feb 18 17:25 version.sh
[root@master bin]#
[root@master bin]# ./version.sh
Using CATALINA_BASE:   /srv/apache-tomcat-9.0.72
Using CATALINA_HOME:   /srv/apache-tomcat-9.0.72
Using CATALINA_TMPDIR: /srv/apache-tomcat-9.0.72/temp
Using JRE_HOME:        /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre
Using CLASSPATH:       /srv/apache-tomcat-9.0.72/bin/bootstrap.jar:/srv/apache-tomcat-9.0.72/bin/tomcat-juli.jar
Using CATALINA_OPTS:
Server version: Apache Tomcat/9.0.72
Server built:   Feb 18 2023 09:25:13 UTC
Server number:  9.0.72.0
OS Name:        Linux
OS Version:     3.10.0-1062.el7.x86_64
Architecture:   amd64
JVM Version:    1.8.0_362-b08
JVM Vendor:     Red Hat, Inc.
[root@master bin]#
```

手动启动tomcat:
```sh
# 启动tomcat
[root@master bin]# ./startup.sh
Using CATALINA_BASE:   /srv/apache-tomcat-9.0.72
Using CATALINA_HOME:   /srv/apache-tomcat-9.0.72
Using CATALINA_TMPDIR: /srv/apache-tomcat-9.0.72/temp
Using JRE_HOME:        /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre
Using CLASSPATH:       /srv/apache-tomcat-9.0.72/bin/bootstrap.jar:/srv/apache-tomcat-9.0.72/bin/tomcat-juli.jar
Using CATALINA_OPTS:
Tomcat started.
[root@master bin]#

# 查询监听端口
[root@master bin]# netstat -tunlp|grep java
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      1993/java
tcp6       0      0 :::8080                 :::*                    LISTEN      1993/java
[root@master bin]#

# 停止tomcat服务
[root@master bin]# ./shutdown.sh
Using CATALINA_BASE:   /srv/apache-tomcat-9.0.72
Using CATALINA_HOME:   /srv/apache-tomcat-9.0.72
Using CATALINA_TMPDIR: /srv/apache-tomcat-9.0.72/temp
Using JRE_HOME:        /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre
Using CLASSPATH:       /srv/apache-tomcat-9.0.72/bin/bootstrap.jar:/srv/apache-tomcat-9.0.72/bin/tomcat-juli.jar
Using CATALINA_OPTS:
[root@master bin]# netstat -tunlp|grep java
[root@master bin]#
```

使用supervisor管理tomcat，增加tomcat.ini配置：
```sh
[root@master ~]# cat /etc/supervisord.d/tomcat.ini
[program:tomcat]
command = /srv/apache-tomcat-9.0.72/bin/catalina.sh run
stdout_logfile = /srv/apache-tomcat-9.0.72/logs/catalina.out
environment = JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre"
redirect_stderr = true
autorestart = true
stopasgroup = true
killasgroup = true

[root@master ~]#
```

启动superviord服务：
```sh
[root@master ~]# systemctl start supervisord
[root@master ~]# systemctl status supervisord
● supervisord.service - Process Monitoring and Control Daemon
   Loaded: loaded (/usr/lib/systemd/system/supervisord.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-02-27 23:12:08 CST; 4s ago
  Process: 2244 ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf (code=exited, status=0/SUCCESS)
 Main PID: 2247 (supervisord)
    Tasks: 30
   Memory: 94.8M
   CGroup: /system.slice/supervisord.service
           ├─2247 /usr/bin/python /usr/bin/supervisord -c /etc/supervisord.conf
           └─2248 /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64/jre/bin/java -Djava.util.logging.confi...

Feb 27 23:12:08 master systemd[1]: Starting Process Monitoring and Control Daemon...
Feb 27 23:12:08 master systemd[1]: Started Process Monitoring and Control Daemon.


# 查看应用状态，可以看到tomcat启动起来了
[root@master ~]# supervisorctl status
tomcat                           RUNNING   pid 2248, uptime 0:00:14
[root@master ~]# netstat -tunlp|grep java
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      2248/java
tcp6       0      0 :::8080                 :::*                    LISTEN      2248/java
[root@master ~]#
```

此时，可以看到，tomcat正常启动了！！

本总结文档到此结束！！^_^ 😀💪💪



参考

- [官方文档](http://supervisord.org/introduction.html)
- [Linux进程管理工具——supervisor](http://www.cppblog.com/kenkao/archive/2016/09/23/214298.html)
- [进程管理工具之supervisor详解](https://www.cnblogs.com/xingxia/p/python_supervisor.html) 
- [进程管理利器Supervisor--入门简介 ](https://www.dandelioncloud.cn/article/details/1508653963862941697)
- [Linux后台进程管理利器：supervisor ](https://www.liaoxuefeng.com/article/895919885120064)
- [supervisor进程、服务超级监控工具配置-折腾笔记](http://blog.claves.cn/archives/1737)
- [supervisor系列：4、子进程](https://blog.csdn.net/weixin_39510813/article/details/118091669)

