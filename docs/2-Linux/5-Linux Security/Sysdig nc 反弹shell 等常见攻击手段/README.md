unhide
sysdig


Sysdig : Open Source Universal System Visibility With Native Contaier Support.

虽然 Linux 有很多系统分析和调优的工具 如strace、tcpdump、htop、iftop、lsof、netstat，但是它们一般都负责某个特殊的功能，并且使用方式有很大的差异，如果要分析和定位问题，一般都需要熟练掌握需要命令的使用。而且这些工具的数据无法进行共享，只能相互独立工作。Sysdig 一个工具就能实现上述所有工具的功能，并且提供了统一的使用语法。



CPU、Memory、Disk IO、网络 IO•支持各种 IO 活动：进程、文件、网络连接等

来分析这些数据



Sysdig 有着类似于 tcpdump 的过滤语法，用户可以随意组合自己的过滤逻辑，用户还可以自己编写 Lua 脚本来自定义分析逻辑，基本上不受任何限制。



https://mp.weixin.qq.com/s/j4vfelk1Eu-rl2s8B70_CQ