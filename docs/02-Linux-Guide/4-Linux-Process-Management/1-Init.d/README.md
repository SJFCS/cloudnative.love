---
title: Init vs Systemd
---

作为一名开发人员，我主要在类似 Linux/Unix 的操作系统上工作，例如 Ubuntu。使用这样的操作系统已经有几年了，我可以放心地说我很熟悉它们，但仍然有很多东西我仍然不明白。在这篇文章中，我想探讨**Init**和**Systemd**之间的区别。

我记得在系统管理员 DevOps 实习期间，我必须对某些后台服务执行一些操作。此时，我仍然不知道什么是服务。我必须使用如下命令：

```Bash
sudo service <service-name> <command>
```

偶尔，我会看到有人在网上使用`init.d`，这也有效。

```Bash
sudo /etc/init.d/<service-name> <command>
```

但为什么有两个命令执行完全相同的操作呢？可悲的是，这个问题从来没有在我的脑海中闪过。只要命令有效，我就很高兴。也就是说，直到我开始研究适用于 Kubernetes 的 Fedora CoreOS，并且发生了以下情况：

```Bash
$ sudo service kubelet <command>
sudo: service: command not found
```

`service`不是命令吗？！在Google上寻找答案后，我发现该命令特定于某些Linux发行版，解决方案是使用：

```Bash
sudo systemctl <command> <service-name>
```

_什么！？_管理服务的第三个命令？是的。事实上，一些 Linux 发行版（distros）有自己的命令来管理服务，但我不打算深入讨论。在本文中，我将只讨论分别使用命令和的 init 守护进程**Init**和**Systemd**。但首先，我们需要了解什么是 init 守护进程。`service``systemctl`

## 什么是初始化守护进程？

init 守护进程是 Linux 内核执行的第一个进程，其进程 ID (PID) 始终为 1。其目的是初始化、管理和跟踪系统服务和守护进程。换句话说，init 守护进程是系统上所有进程的父进程。

## 什么是 Init

Init（也称为 System V init 或 SysVinit）是一个 init 守护进程，创建于 20 世纪 80 年代，它定义了六个运行级别（系统状态）并将所有系统服务映射到这些运行级别。这允许所有服务（定义为脚本）按照预定义的顺序启动。仅当执行序列中的当前脚本时才会执行下一个脚本，或者如果卡住则超时。除了执行超时期间出现意外等待之外，串行启动服务还会导致系统初始化过程效率低下且相对缓慢。

要创建服务，您需要编写脚本并将其存储在`/etc/init.d`目录中。`/etc/init.d/myService`您将编写一个如下所示的服务脚本：

```Bash
#!/bin/bash
# chkconfig: 2345 20 80
# description: Description comes here....

# Source function library.
. /etc/init.d/functions

start() {
    # TODO: code to start app comes here 
}

stop() {
    # TODO: code to stop app comes here 
}

case "$1" in 
    start)
       start
       ;;
    stop)
       stop
       ;;
    restart)
       stop
       start
       ;;
    status)
       # TODO: code to check status of app comes here 
       ;;
    *)
       echo "Usage: $0 {start|stop|restart|status}"
esac

exit 0
```

[您可以在手册页](https://linux.die.net/man/8/chkconfig)中阅读有关 chkconfig 的信息。本质上，它定义了您的服务应在哪个运行级别运行。获得脚本后，您可以使用该`service`命令来启动、停止和重新启动服务。

## 什么是 Systemd？

Systemd（系统守护进程）是现代系统使用的 init 守护进程，它并行启动系统服务，从而消除不必要的延迟并加快初始化过程。我所说的并行是什么意思？Systemd 使用单元依赖性来定义服务是否**希望/需要**其他服务才能成功运行，并使用单元顺序来定义服务是否需要在其**之前/之后**启动其他服务。

要创建服务，您需要编写一个`.service`存储在目录中的文件`/etc/systemd/system`。`/etc/systemd/system/myService.service`您将编写一个如下所示的文件：

```Bash
[Unit]
Description=Some Description
Requires=syslog.target
After=syslog.target

[Service]
ExecStart=/usr/sbin/<command-to-start>
ExecStop=/usr/sbin/<command-to-stop>

[Install]
WantedBy=multi-user.target
```

我将在另一篇文章中详细讨论如何使用 Systemd 创建服务。获得服务文件后，您可以使用`systemctl`命令启动、停止和重新启动服务。

## 结论

Init 和 Systemd 都是 init 守护进程，但最好使用后者，因为它在最近的 Linux 发行版中常用。Init 使用`service`而 Systemd 用于`systemctl`管理 Linux 服务。


- https://web.yueh.dev/learning/init-vs-systemd-what-is-an-init-daemon
