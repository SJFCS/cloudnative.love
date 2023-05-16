---
title: Log
---

- [Linux 系统日志](https://linux.vbird.org/linux_basic/centos7/0570syslog.php)


https://devconnected.com/the-definitive-guide-to-centralized-logging-with-syslog-on-linux/

https://devconnected.com/linux-logging-complete-guide/




logger "ex200 in progress"
AI
这个命令将用来向系统日志中添加一条信息，该信息内容为 "ex200 in progress"。系统日志可以通过运行 dmesg 或者 journalctl -k 命令来查看。

通常情况下，开发人员可以在他们的脚本文件中添加 logger 命令作为一个实用工具，以便在调试和发布脚本时记录事件的状态和时刻。此外，系统管理员也可以使用 logger 命令来记录系统事件以及运行中的错误，这有助于监测系统的运作，发现问题并进行故障排除。




dmesg 或者 journalctl -k 区别
AI
dmesg 和 journalctl -k 都可以用于在 Linux 系统上查看内核的日志，但其工作方式略有不同。

dmesg 命令会显示系统启动后从内核缓冲区中读取的所有信息。这包括内核引导信息、硬件信息，以及一些内核相关的警告和错误。 这里需要注意，dmesg显示的是缓冲区的内容，而非永久存储在磁盘上的日志文件。所以，如果重启了系统，再次运行 dmesg 将会清除之前的所有日志，重新开始记录。

journalctl -k 命令是由 systemd 守护程序提供的一个利用 systemd-journald 的工具，可用于查看系统启动后记录的所有内核日志。 除了内核消息，journalctl 还记录了各种系统和进程日志，因此可以通过各种过滤器，筛选出自己想要的日志信息。使用journalctl -k时，只会显示内核相关的日志信息。

总的来说，dmesg 更偏向于查看内核启动期间的消息，而 journalctl -k 则是更全面的查看内核和系统日志的方式。




