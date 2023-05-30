---
title: Linux 中毒高负载排查分析

---

## 查看load average



`uptime`命令可以查看系统负荷（`w`和`top`也行）

>uptime/top从/proc/loadavg取值。
>
>/proc/sched_debug可以观察实时负载。

执行`cat /proc/loadavg`后显示`load average`字段，它的意思是"系统的平均负荷"，后面有三个数字，分别代表1分钟、5分钟、15分钟内系统的平均负荷。后面的 1/143 一个的分子是正在运行的进程数，分母是进程总数；最后是最近运行的进程ID号。

![image-20210428164535422](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E7%B3%BB%E7%BB%9F%E5%B9%B3%E5%9D%87%E8%B4%9F%E8%BD%BD/2021.04.28-16:45:36-D-assets-%E7%B3%BB%E7%BB%9F%E5%B9%B3%E5%9D%87%E8%B4%9F%E8%BD%BD-image-20210428164535422.png)

1. `满载值=CPU个数X核数`服务器只有一个单核心cpu时，空载为0满载为1
2. 我们可以通过`grep -E 'processor|model name|cpu cores' /proc/cpuinfo`列出cpu信息，其中`processor`字段表示物理cpu编号 `cpu cores`字段表示此物理cpu的核数。
3. 每个核心的负荷不超过1.0，就表明系统正常运行。但一般建议平均负载不超过70%，即`满载值<=CPU个数X核数X70%`

## 常见查询参数

```
总核数 = 物理CPU个数 X 每颗物理CPU的核数
总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数
# 查看cpu个数
lscpu中的CPU(s)字段
top后按1显示逻辑CPU状态

# 查看CPU信息（逻辑核心+型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l

查看机器型号（机器硬件型号）
dmidecode | grep "Product Name"

cat /proc/cpuinfo | grep physical | uniq -c
从0开始列出物理cpu数量，每个对应逻辑核心数
	
```

## load average异常处理方法、

### 通用

参考链接[top命令输出解释以及load average 详解及排查思路][https://blog.csdn.net/zhangchenglikecc/article/details/52103737]



首先通过`top` `ps -l`查看系统负载情况，一般cpu 的 ni 占用率很高，loadaverage 值很高，此时找出异常进程具体分析基本能解决。



**下面说一下各个参数字段含义**



```
###### nice 用来设定程序执行的优先级 ######
一般来说,程序的执行就是cpu不停在上面切换而已,默认的情况下,cpu是很公平的,他在每个进程上切换的次数是一样的,
但是如果你有一个程序很占资源,如备份,这些程序,那么你在执行的时候就会很卡,那么这个时候你就会不想要他占用那么资源， 
或者说是你想要让别的程序先执行,那么就需要修改nice这个值,他主要的作用就是修改cpu在该程序上切换的次数 。
<1> nice只能调整没有运行的进程，
<2> 优先级的数值为-20~~19，数值越小优先级越高。-20优先级最高，19的优先级最低。
<3> 普通用户只能再0~~19之间调整值，而且只能调整自己的进程，并且普通用户只能调高NI值不能降低，例如原NI值为0，则普通用户只能调整为大于0
<4> root用户才能设定进程NI值为负值。而且可以调整任何用户的进程
<5> PRI(new) = PRI(old) + NI 且PRI不能手动修改，它是通过PRI(old) + NI计算出来的
选项
-n 指定优先级
[root@www aa]# nice -n 5 vim
[root@www ~]# nice -n 1 vi&
[1] 2954
[root@www ~]# ps -l
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0  1161  1157  0  80   0 - 27096 wait   pts/0    00:00:00 bash
0 T     0  2954  1161  0  81   1 - 29245 signal pts/0    00:00:00 vi
4 R     0  2955  1161  0  80   0 - 27031 -      pts/0    00:00:00 ps
NI列即表示进程的nice值。vi进程对应的NI值正好为刚设置的1。
PRI表示进程当前的总优先级，值越小表示优先级越高，由进程默认的PRI加上NI得到，即PRI(new) = PRI(old) + NI。
由上程序，进程默认的PRI是80，所以加上值为1的NI后，vi进程的PRI为81。
renice 用于改变正在运行的进程的nice值
###### nice 用来设定程序执行的优先级 ######
 
现在可以肯定是某个NI值高的进程把cpu全部占用了(也就是ni值时-20的)

```

### 中毒

但如果被攻击的情况下则很可能查不到相关异常进程， 因为`top` `ps -l`依赖于`/proc` 查找系统活动，被攻击后系统文件常常被替换，使之进程隐身。感兴趣可以阅读此文：[如何隐藏系统进程](https://sysdig.com/blog/hiding-linux-processes-for-fun-and-profit/)

这时需使用`sysdig` 来分析进程。

```
简介：
sysdig相当于strace + tcpdump + lsof + htop + iftop 以及其他工具的合集 ，除此之外其还能对容器如docker、coreOS、LXC进行监控，
官网：https://sysdig.com/

一键安装
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig| sudo bash
安装后测试
sysdig -pc -c topconns


```

```
查看进程占用cpu 情况
sysdig -c topprocs_cpu  

查看占用网络带宽最多的进程
sysdig -c topprocs_net

查看使用硬盘带宽最多的进程：
sysdig -c topprocs_file


kiil -9 杀掉异常进程
```

## 内核bug引起显示错误

详见链接：[Linux系统load average异常值处理的trick](https://blog.csdn.net/dog250/article/details/107792805)
