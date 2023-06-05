linux操作系统经历了从Sysvinit，到Upstart再到Systemd的进化，
还有其他的启动管理程序，但是用的不多

Sysvinit
其中Sysvinit是使用最悠久的，它使用运行级别进行不同程序的启动
Sysvinit 的配置文件是/etc/inittab
读取完配置文件后，
sysvinit 顺序地执行以下这些步骤，从而将系统初始化为预订的 runlevel X。
/etc/rc.d/rc.sysinit
/etc/rc.d/rc 和/etc/rc.d/rcX.d/ (X 代表运行级别 0-6)
/etc/rc.d/rc.local
X Display Manager（如果需要的话）
系统关闭时，会将/etc/rc.d/rcX.d/目录下所有 K 开头的脚本执行

UpStart
UpStart是ubuntu在给系统安装在笔记本上时，发现传统的方式是串行的，
不能并发也不能进行延后执行（比如插入打印机后再启动驱动）
所以开发了UpStart
它使用job工作单位和event事件进行控制

Systemd
这是我们的主角Systemd，从ubuntu15开始，ubuntu也不使用UpStart了
systemctl是 Systemd 的主命令，用于管理系统
