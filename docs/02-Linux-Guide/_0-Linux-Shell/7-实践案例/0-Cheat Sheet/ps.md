# ps命令常见实用用法

> ## Excerpt
> ps 命令用来查看当前系统运行中进程的状态信息

---
## 前言

ps（Process Status）命令是linux中最常见的命令之一，它用来列出当前系统运行中的进程的状态信息。当然了，它只显示命令**执行时**的进程状态，如果想要动态列出状态信息，可以选择使用top命令。那么通过ps命令我们能够知道进程的哪些信息呢？下面进行介绍。

## 命令基本介绍

#### 常用参数

```
-A    显示所有进程（同-e）-a    显示当前终端的所有进程-u    显示进程的用户信息-o    以用户自定义形式显示进程信息-f    显示程序间的关系
```

对于更多参数的介绍，可使用命令man ps查看，这里不再赘述。

## 字段含义

在介绍实例之前，需要先了解一下ps命令输出各字段的含义，这样我们才能更好地理解所展示的信息。常见字段的基本含义如下:

```
USER          进程所有者的用户名PID           进程号START         进程激活时间%CPU          进程自最近一次刷新以来所占用的CPU时间和总时间的百分比%MEM          进程使用内存的百分比VSZ           进程使用的虚拟内存大小，以K为单位RSS           驻留空间的大小。显示当前常驻内存的程序的K字节数。TTY           进程相关的终端STAT          进程状态，包括下面的状态：                      D    不可中断     Uninterruptible sleep (usually IO)                     R    正在运行，或在队列中的进程                     S    处于休眠状态                     T    停止或被追踪                     Z    僵尸进程                     W    进入内存交换（从内核2.6开始无效）                     X    死掉的进程                     <    高优先级                     N    低优先级                     L    有些页被锁进内存                     s    包含子进程                     \+   位于后台的进程组；                     l    多线程，克隆线程TIME          进程使用的总CPU时间COMMAND       被执行的命令行NI            进程的优先级值，较小的数字意味着占用较少的CPU时间PRI           进程优先级。PPID          父进程IDWCHAN         进程等待的内核事件名
```

## 常见用法

下面来看看一些常见用法。

#### 显示所有进程信息

```
ps　-A PID TTY          TIME CMD    1 ?        00:00:03 systemd    2 ?        00:00:00 kthreadd    4 ?        00:00:00 kworker/0:0H    6 ?        00:00:00 mm_percpu_wq    7 ?        00:00:00 ksoftirqd/0    8 ?        00:00:02 rcu_sched    9 ?        00:00:00 rcu_bh   10 ?        00:00:00 migration/0   11 ?        00:00:00 watchdog/0（内容较多，其他部分略过。）
```

虽然能显示所有进程，但是显示的信息却不多，基本只显示了进程id和进程名，有时候并不实用。

#### 显示所有进程基本信息

相关参数-e

```
ps -efUID        PID  PPID  C STIME TTY          TIME CMDroot         1     0  0 10:52 ?        00:00:03 /sbin/init splashroot         2     0  0 10:52 ?        00:00:00 [kthreadd]root         4     2  0 10:52 ?        00:00:00 [kworker/0:0H]root         6     2  0 10:52 ?        00:00:00 [mm_percpu_wq]root         7     2  0 10:52 ?        00:00:00 [ksoftirqd/0]root         8     2  0 10:52 ?        00:00:02 [rcu_sched]root         9     2  0 10:52 ?        00:00:00 [rcu_bh]root        10     2  0 10:52 ?        00:00:00 [migration/0]（内容较多，其他部分略过。）
```

这个时候已经显示较多信息了。

#### 显示指定用户的进程

相关参数-u

```
ps -u root  PID TTY          TIME CMD    1 ?        00:00:03 systemd    2 ?        00:00:00 kthreadd    4 ?        00:00:00 kworker/0:0H    6 ?        00:00:00 mm_percpu_wq    7 ?        00:00:00 ksoftirqd/0    8 ?        00:00:03 rcu_sched    9 ?        00:00:00 rcu_bh
```

#### 查看指定进程名相关信息

这个时候就需要配合grep使用了。  
例如，查看”java“相关进程：

```
ps -ef|grep javaroot       2685  2684  2 10:55 pts/0    00:01:19 java -jar ./software/finalspeed/finalspeed_client.jarroot       5423  4487  0 11:55 pts/20   00:00:00 grep --color=auto java
```

#### 查看进程占用内存，cpu利用率等信息

```
ps -auxUSER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDroot         1  0.0  0.0 185488  6188 ?        Ss   10:52   0:03 /sbin/init splashroot         2  0.0  0.0      0     0 ?        S    10:52   0:00 [kthreadd]root         4  0.0  0.0      0     0 ?        S<   10:52   0:00 [kworker/0:0H]root         6  0.0  0.0      0     0 ?        S<   10:52   0:00 [mm_percpu_wq]
```

从上面的信息，可以看到进程的所有者、cpu占用率、内存占用率等较为详细的信息。

#### 显示线程相关信息

相关参数-l

```
ps -elf
```

#### 查看进程间的关系

相关参数-H，进程间关系以树形图的方式展示:

```
ps -ejH
```

#### 查看进程的指定字段信息

有时候可能比较关注某些进程信息，ps -o可以指定要显示的列。  
例如:

```
ps -eo %cpu,%mem,vsz,rsz,start,stat,pid,sid,ni,uid,user,rss,time,command.0  0.0      0     0 10:52:51 S      365     0   -     0 root         0 00:00:00 [irq/47-mei_me] 0.0  0.0      0     0 10:52:51 S<     373     0 -20     0 root         0 00:00:00 [cfg80211] 0.0  0.0      0     0 10:52:52 S<     402     0 -20     0 root         0 00:00:00 [ktpacpid] 0.0  0.0      0     0 10:52:56 S      669     0   0     0 root         0 00:00:00 [jbd2/sda15-8] 0.0  0.0      0     0 10:52:56 S<     670     0 -20     0 root         0 00:00:00 [ext4-rsv-conver] 0.0  0.0      0     0 10:52:57 S      676     0   0     0 root         0 00:00:00 [jbd2/sda11-8] 0.0  0.0      0     0 10:52:57 S<     677     0 -20     0 root         0 00:00:00 [ext4-rsv-conver] 0.0  0.0      0     0 10:52:58 S      683     0   0     0 root         0 00:00:00 [jbd2/sda14-8] 0.0  0.0      0     0 10:52:58 S<     684     0 -20     0 root         0 00:00:00 [ext4-rsv-conver]
```

#### 查看指定进程指定信息

只需要在最后指定--pid参数即可。  
例如:

```
ps -o %cpu,%mem,vsz,rsz,start,stat,pid,sid,ni,uid,user,rss,time,command --pid 2685%CPU %MEM    VSZ   RSZ  STARTED STAT   PID   SID  NI   UID USER       RSS     TIME COMMAND 2.0  1.9 5740448 159796 10:55:24 Sl+ 2685  2583   0  1000 hyb      159796 00:01:46 java -jar ./software/finalspeed/finalspeed_client.jar
```

#### 进程太多时分页显示

如果进程信息较多，可能一页无法完成显示，这时可以配合使用more命令。  
例如:

```
ps -aux|more
```

