---
title: rsync
---
https://rsync.samba.org/

https://www.ruanyifeng.com/blog/2020/08/rsync.html

https://www.cnblogs.com/f-ck-need-u/p/7220009.html

rsync是可以实现增量备份的工具。配合任务计划，rsync能实现定时或间隔同步，配合inotify或sersync，可以实现触发式的实时同步。


(rsync不支持远程到远程的拷贝，但scp支持)


rsync同步过程中由两部分模式组成：决定哪些文件需要同步的检查模式以及文件同步时的同步模式。

- 检查模式是指按照指定规则来检查哪些文件需要被同步，例如哪些文件是明确被排除不传输的。
默认情况下，rsync使用"quick check"算法快速检查源文件和目标文件的大小、mtime(修改时间)是否一致，如果不一致则需要传输。
> 可以通过在rsync命令行中指定某些选项来改变quick check的检查模式，比如"--size-only"选项表示"quick check"将仅检查文件大小不同的文件作为待传输文件。

- 同步模式是指在文件确定要被同步后，在同步过程发生之前要做哪些额外工作。例如上文所说的是否要先删除源主机上没有但目标主机上有的文件，是否要先备份已存在的目标文件，是否要追踪链接文件等额外操作。rsync也提供非常多的选项使得同步模式变得更具弹性。



以下是rsync的语法：
```
Local:  rsync [OPTION...] SRC... [DEST]
 
Access via remote shell:
  Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
 
Access via rsync daemon:
  Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
        rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
        rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST
```
由此语法可知，rsync有三种工作方式：

(1).本地文件系统上实现同步。命令行语法格式为上述"Local"段的格式。

(2).本地主机使用远程shell和远程主机通信。命令行语法格式为上述"Access via remote shell"段的格式。

(3).本地主机通过网络套接字连接远程主机上的rsync daemon。命令行语法格式为上述"Access via rsync daemon"段的格式。

前两者的本质是通过管道通信，即使是远程shell。而方式(3)则是让远程主机上运行rsync服务，使其监听在一个端口上，等待客户端的连接。



但是，还有第四种工作方式：**通过远程shell也能临时启动一个rsync daemon，这不同于方式(3)，它不要求远程主机上事先启动rsync服务，而是临时派生出rsync daemon，它是单用途的一次性daemon，仅用于临时读取daemon的配置文件，当此次rsync同步完成，远程shell启动的rsync daemon进程也会自动消逝。**此通信方式的命令行语法格式同"Access via rsync daemon"，但要求options部分必须明确指定"--rsh"选项或其短选项"-e"。

以下是对rsync语法的简单说明，由于rsync支持一百多个选项，所以此处只介绍几个常用选项。
```
Local:  rsync [OPTION...] SRC... [DEST]
 
Access via remote shell:
  Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
 
Access via rsync daemon:
  Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
        rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
        rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST
```
其中，第一个路径参数一定是源文件路径，即作为同步基准的一方，可以同时指定多个源文件路径。最后一个路径参数则是目标文件路径，也就是待同步方。路径的格式可以是本地路径，也可以是使用user@host:path或user@host::path的远程路径，如果主机和path路径之间使用单个冒号隔开，表示使用的是远程shell通信方式，而使用双冒号隔开的则表示的是连接rsync daemon。另外，连接rsync daemon时，还提供了URL格式的路径表述方式rsync://user@host/path。

**如果仅有一个SRC或DEST参数，则将以类似于"ls -l"的方式列出源文件列表(只有一个路径参数，总会认为是源文件)，而不是复制文件。**

如果对rsync不熟悉，可暂先只了解本地以及远程shell格式的user@host:path路径格式。例如：

```
[root@xuexi ~]# rsync /etc/fstab /tmp                # 在本地同步
[root@xuexi ~]# rsync -r /etc 172.16.10.5:/tmp       # 将本地/etc目录拷贝到远程主机的/tmp下，以保证远程/tmp目录和本地/etc保持同步
[root@xuexi ~]# rsync -r 172.16.10.5:/etc /tmp       # 将远程主机的/etc目录拷贝到本地/tmp下，以保证本地/tmp目录和远程/etc保持同步
[root@xuexi ~]# rsync /etc/                          # 列出本地/etc/目录下的文件列表
[root@xuexi ~]# rsync 172.16.10.5:/tmp/              # 列出远程主机上/tmp/目录下的文件列表
```
另外，使用rsync一定要注意的一点是，**源路径如果是一个目录的话，带上尾随斜线和不带尾随斜线是不一样的，不带尾随斜线表示的是整个目录包括目录本身，带上尾随斜线表示的是目录中的文件，不包括目录本身。**例如：
```
[root@xuexi ~]# rsync -a /etc /tmp
[root@xuexi ~]# rsync -a /etc/ /tmp
```
第一个命令会在/tmp目录下创建etc目录，而第二个命令不会在/tmp目录下创建etc目录，源路径/etc/中的所有文件都直接放在/tmp目录下。



## 2.4 选项说明和示例

```
-v：显示rsync过程中详细信息。可以使用"-vvvv"获取更详细信息。
-P：显示文件传输的进度信息。(实际上"-P"="--partial --progress"，其中的"--progress"才是显示进度信息的)。
-n --dry-run  ：仅测试传输，而不实际传输。常和"-vvvv"配合使用来查看rsync是如何工作的。
-a --archive  ：归档模式，表示递归传输并保持文件属性。等同于"-rtopgDl"。
-r --recursive：递归到目录中去。
-t --times：保持mtime属性。强烈建议任何时候都加上"-t"，否则目标文件mtime会设置为系统时间，导致下次更新
          ：检查出mtime不同从而导致增量传输无效。
-o --owner：保持owner属性(属主)。
-g --group：保持group属性(属组)。
-p --perms：保持perms属性(权限，不包括特殊权限)。
-D        ：是"--device --specials"选项的组合，即也拷贝设备文件和特殊文件。
-l --links：如果文件是软链接文件，则拷贝软链接本身而非软链接所指向的对象。
-z        ：传输时进行压缩提高效率。
-R --relative：使用相对路径。意味着将命令行中指定的全路径而非路径最尾部的文件名发送给服务端，包括它们的属性。用法见下文示例。
--size-only ：默认算法是检查文件大小和mtime不同的文件，使用此选项将只检查文件大小。
-u --update ：仅在源mtime比目标已存在文件的mtime新时才拷贝。注意，该选项是接收端判断的，不会影响删除行为。
-d --dirs   ：以不递归的方式拷贝目录本身。默认递归时，如果源为"dir1/file1"，则不会拷贝dir1目录，使用该选项将拷贝dir1但不拷贝file1。
--max-size  ：限制rsync传输的最大文件大小。可以使用单位后缀，还可以是一个小数值(例如："--max-size=1.5m")
--min-size  ：限制rsync传输的最小文件大小。这可以用于禁止传输小文件或那些垃圾文件。
--exclude   ：指定排除规则来排除不需要传输的文件。
--delete    ：以SRC为主，对DEST进行同步。多则删之，少则补之。注意"--delete"是在接收端执行的，所以它是在
            ：exclude/include规则生效之后才执行的。
-b --backup ：对目标上已存在的文件做一个备份，备份的文件名后默认使用"~"做后缀。
--backup-dir：指定备份文件的保存路径。不指定时默认和待备份文件保存在同一目录下。
-e          ：指定所要使用的远程shell程序，默认为ssh。
--port      ：连接daemon时使用的端口号，默认为873端口。
--password-file：daemon模式时的密码文件，可以从中读取密码实现非交互式。注意，这不是远程shell认证的密码，而是rsync模块认证的密码。
-W --whole-file：rsync将不再使用增量传输，而是全量传输。在网络带宽高于磁盘带宽时，该选项比增量传输更高效。
--existing  ：要求只更新目标端已存在的文件，目标端还不存在的文件不传输。注意，使用相对路径时如果上层目录不存在也不会传输。
--ignore-existing：要求只更新目标端不存在的文件。和"--existing"结合使用有特殊功能，见下文示例。
--remove-source-files：要求删除源端已经成功传输的文件。
```
## 目录划分
```
(2).将/etc/cron.d目录拷贝到/tmp下。

[root@xuexi ~]# rsync -r /etc/cron.d /tmp
该命令会在目标主机上创建/tmp/cron.d目录，并将/etc/cron.d/中的文件放入到/tmp/cron.d/目录中，也就是说默认情况下，是不会在目录路径下创建上层目录/etc的。


(3).将/etc/cron.d目录拷贝到/tmp下，但要求在/tmp下也生成etc子目录。

[root@xuexi ~]# rsync -R -r /etc/cron.d /tmp
其中"-R"选项表示使用相对路径，此相对路径是以目标目录为根的。对于上面的示例，表示在目标上的/tmp下创建etc/cron.d目录，即/tmp/etc/cron.d，etc/cron.d的根"/"代表的就是目标/tmp。

如果要拷贝的源路径较长，但只想在目标主机上保留一部分目录结构，例如要拷贝/var/log/anaconda/*到/tmp下，但只想在/tmp下保留从log开始的目录，如何操作？使用一个点代表相对路径的起始位置即可，也就是将长目录进行划分。

[root@xuexi ~]# rsync -R -r /var/./log/anaconda /tmp
这样，从点开始的目录都是相对路径，其相对根目录为目标路径。所以对于上面的示例，将在目标上创建/tmp/log/anaconda/*。


(4).对远程目录下已存在文件做一个备份。

[root@xuexi ~]# rsync -R -r --backup /var/./log/anaconda /tmp

这样在目标目录下，已存在的文件就被做一个备份，备份文件默认使用"~"做后缀，可以使用"--suffix"指定备份后缀。

可以使用"--backup-dir"指定备份文件保存路径，但要求保存路径必须存在。

[root@xuexi ~]# mkdir /tmp/log_back

[root@xuexi ~]# rsync -R -r --backup --backup-dir=/tmp/log_back /var/./log/anaconda /tmp
指定备份路径后，默认将不会加备份后缀，除非使用"--suffix"显式指定后缀，如"--suffix=~"。


```

### (5).指定ssh连接参数，如端口、连接的用户、ssh选项等。
```
rsync -e "ssh -p 22 -o StrictHostKeyChecking=no" /etc/fstab 172.16.10.5:/tmp
Warning: Permanently added '172.16.10.5' (RSA) to the list of known hosts.
root@172.16.10.5's password:
```

### (6)."--existing"和"--ignore-existing"

"--existing"是只更新目标端已存在的文件。

"--ignore-existing"是更新目标端不存在的文件。

"--existing"和"--ignore-existing"结合使用时，有个特殊功效，当它们结合"--delete"使用的时候，文件不会传输，但会删除receiver端额外多出的文件。

实际上，"--existing"和"--ingore-existing"是传输规则，只会影响receiver要求让sender传输的文件列表，在receiver决定哪些文件需要传输之前的过程，是这两个选项无法掌控的，所以各种规则、"--delete"等操作都不会被这两个选项影响。

### (7)."--remove-source-files"删除源端文件。

使用该选项后，源端已经更新成功的文件都会被删除，源端所有未传输或未传输成功的文件都不会被移除。未传输成功的原因有多种，如exclude排除了，"quick check"未选项该文件，传输中断等等。

总之，显示在"rsync -v"被传输列表中的文件都会被移除。如下：

```
[root@xuexi ~]# rsync -r -v --remove-source-files /tmp/a/anaconda /tmp/a/audit /tmp       
sending incremental file list
anaconda/anaconda.log
anaconda/ifcfg.log
anaconda/journal.log
anaconda/ks-script-1uLekR.log
anaconda/ks-script-iGpl4q.log
anaconda/packaging.log
anaconda/program.log
anaconda/storage.log
anaconda/syslog
audit/audit.log
 
sent 4806915 bytes  received 204 bytes  961423
```
上述显示出来的文件在源端全部被删除。


### 2.4.2 "--exclude"排除规则

```
[root@xuexi tmp]# rsync -r -v --exclude="anaconda/*.log" /var/log/anaconda /var/log/audit /tmp
```

注意，一个"--exclude"只能指定一条规则，要指定多条排除规则，需要使用多个"--exclude"选项，或者将排除规则写入到文件中，然后使用"--exclude-from"选项读取该规则文件。

另外，除了"--exclude"排除规则，还有"--include"包含规则，顾名思义，它就是筛选出要进行传输的文件，所以include规则也称为传输规则。它的使用方法和"--exclude"一样。如果一个文件即能匹配排除规则，又能匹配包含规则，则先匹配到的立即生效，生效后就不再进行任何匹配。

最后，关于规则，最重要的一点是它的作用时间。当发送端敲出rsync命令后，rsync将立即扫描命令行中给定的文件和目录(扫描过程中还会按照目录进行排序，将同一个目录的文件放在相邻的位置)，这称为拷贝树(copy tree)，扫描完成后将待传输的文件或目录记录到文件列表中，然后将文件列表传输给接收端。而筛选规则的作用时刻是在扫描拷贝树时，所以会根据规则来匹配并决定文件是否记录到文件列表中(严格地说是会记录到文件列表中的，只不过排除的文件会被标记为hide隐藏起来)，只有记录到了文件列表中的文件或目录才是真正需要传输的内容。换句话说，筛选规则的生效时间在rsync整个同步过程中是非常靠前的，它会影响很多选项的操作对象，最典型的如"--delete"。也许，你看完这一整篇文章都没感觉到这一点的重要性，但如果你阅读rsync的man文档或者学习rsync的原理，你一定会深有体会。

实际上，排除规则和包含规则都只是"--filter"筛选规则的两种特殊规则。"--filter"比较复杂，它有自己的规则语法和匹配模式，由于篇幅有限，以及考虑到本文的难度定位，"--filter"规则不便在此多做解释，仅简单说明下规则类，帮助理解下文的"--delete"。

以下是rsync中的规则种类，不解之处请结合下文的"--delete"分析：

(1).exclude规则：即排除规则，只作用于发送端，被排除的文件不会进入文件列表(实际上是加上隐藏规则进行隐藏)。

(2).include规则：即包含规则，也称为传输规则，只作用于发送端，被包含的文件将明确记录到文件列表中。

(3).hide规则：即隐藏规则，只作用于发送端，隐藏后的文件对于接收端来说是看不见的，也就是说接收端会认为它不存在于源端。

(4).show规则：即显示规则，只作用于发送端，是隐藏规则的反向规则。

(5).protect规则：即保护规则，该规则只作用于接收端，被保护的文件不会被删除掉。

(6).risk规则：即取消保护规则。是protect的反向规则。

除此之外，还有一种规则是"clear规则"，作用是删除include/exclude规则列表。

**如何一次写对exclude规则**
我这里提供一个判断规则写法的方式，纯属我个人的经验总结：使用"-n"选项是dry run模式，也就是只测试不传输，"-i"选项是输出要传输文件的路径。"-i"只是一个便捷性选项，可以替换成其它选项来自定义输出格式，有时候通过这些信息来做一些判断是非常有用的，具体的可以翻man手册。

### 2.4.3 "--delete"解释
https://www.cnblogs.com/f-ck-need-u/p/7220009.html#auto_id_5
## 2.5 rsync daemon模式


## 一、简介

rsync 是一个常用的 Linux 应用程序，用于文件同步。

它可以在本地计算机与远程计算机之间，或者两个本地目录之间同步文件（但不支持两台远程计算机之间的同步）。它也可以当作文件复制工具，替代`cp`和`mv`命令。

![](https://www.wangbase.com/blogimg/asset/202008/bg2020082602.jpg)

它名称里面的`r`指的是 remote，rsync 其实就是"远程同步"（remote sync）的意思。与其他文件传输工具（如 FTP 或 scp）不同，rsync 的最大特点是会检查发送方和接收方已有的文件，仅传输有变动的部分（默认规则是文件大小或修改时间有变动）。

## 二、安装

如果本机或者远程计算机没有安装 rsync，可以用下面的命令安装。

```

# Debian
$ sudo apt-get install rsync

# Red Hat
$ sudo yum install rsync

# Arch Linux
$ sudo pacman -S rsync
```

注意，传输的双方都必须安装 rsync。

## 三、基本用法

### 3.1 `-r` 参数

本机使用 rsync 命令时，可以作为`cp`和`mv`命令的替代方法，将源目录同步到目标目录。

```

$ rsync -r source destination
```

上面命令中，`-r`表示递归，即包含子目录。注意，`-r`是必须的，否则 rsync 运行不会成功。`source`目录表示源目录，`destination`表示目标目录。

如果有多个文件或目录需要同步，可以写成下面这样。

```

$ rsync -r source1 source2 destination
```

上面命令中，`source1`、`source2`都会被同步到`destination`目录。

### 3.2 `-a` 参数

`-a`参数可以替代`-r`，除了可以递归同步以外，还可以同步元信息（比如修改时间、权限等）。由于 rsync 默认使用文件大小和修改时间决定文件是否需要更新，所以`-a`比`-r`更有用。下面的用法才是常见的写法。

```

$ rsync -a source destination
```

目标目录`destination`如果不存在，rsync 会自动创建。执行上面的命令后，源目录`source`被完整地复制到了目标目录`destination`下面，即形成了`destination/source`的目录结构。

如果只想同步源目录`source`里面的内容到目标目录`destination`，则需要在源目录后面加上斜杠。

```

$ rsync -a source/ destination
```

上面命令执行后，`source`目录里面的内容，就都被复制到了`destination`目录里面，并不会在`destination`下面创建一个`source`子目录。

### 3.3 `-n` 参数

如果不确定 rsync 执行后会产生什么结果，可以先用`-n`或`--dry-run`参数模拟执行的结果。

```

$ rsync -anv source/ destination
```

上面命令中，`-n`参数模拟命令执行的结果，并不真的执行命令。`-v`参数则是将结果输出到终端，这样就可以看到哪些内容会被同步。

### 3.4 `--delete` 参数

默认情况下，rsync 只确保源目录的所有内容（明确排除的文件除外）都复制到目标目录。它不会使两个目录保持相同，并且不会删除文件。如果要使得目标目录成为源目录的镜像副本，则必须使用`--delete`参数，这将删除只存在于目标目录、不存在于源目录的文件。

```

$ rsync -av --delete source/ destination
```

上面命令中，`--delete`参数会使得`destination`成为`source`的一个镜像。

## 四、排除文件

### 4.1 `--exclude` 参数

有时，我们希望同步时排除某些文件或目录，这时可以用`--exclude`参数指定排除模式。

```

$ rsync -av --exclude='*.txt' source/ destination
# 或者
$ rsync -av --exclude '*.txt' source/ destination
```

上面命令排除了所有 TXT 文件。

注意，rsync 会同步以"点"开头的隐藏文件，如果要排除隐藏文件，可以这样写`--exclude=".*"`。

如果要排除某个目录里面的所有文件，但不希望排除目录本身，可以写成下面这样。

```

$ rsync -av --exclude 'dir1/*' source/ destination
```

多个排除模式，可以用多个`--exclude`参数。

```

$ rsync -av --exclude 'file1.txt' --exclude 'dir1/*' source/ destination
```

多个排除模式也可以利用 Bash 的大扩号的扩展功能，只用一个`--exclude`参数。

```

$ rsync -av --exclude={'file1.txt','dir1/*'} source/ destination
```

如果排除模式很多，可以将它们写入一个文件，每个模式一行，然后用`--exclude-from`参数指定这个文件。

```

$ rsync -av --exclude-from='exclude-file.txt' source/ destination
```

### 4.2 `--include` 参数

`--include`参数用来指定必须同步的文件模式，往往与`--exclude`结合使用。

```

$ rsync -av --include="*.txt" --exclude='*' source/ destination
```

上面命令指定同步时，排除所有文件，但是会包括 TXT 文件。

## 五、远程同步

### 5.1 SSH 协议

rsync 除了支持本地两个目录之间的同步，也支持远程同步。它可以将本地内容，同步到远程服务器。

```

$ rsync -av source/ username@remote_host:destination
```

也可以将远程内容同步到本地。

```

$ rsync -av username@remote_host:source/ destination
```

rsync 默认使用 SSH 进行远程登录和数据传输。

由于早期 rsync 不使用 SSH 协议，需要用`-e`参数指定协议，后来才改的。所以，下面`-e ssh`可以省略。

```

$ rsync -av -e ssh source/ user@remote_host:/destination
```

但是，如果 ssh 命令有附加的参数，则必须使用`-e`参数指定所要执行的 SSH 命令。

```

$ rsync -av -e 'ssh -p 2234' source/ user@remote_host:/destination
```

上面命令中，`-e`参数指定 SSH 使用2234端口。

### 5.2 rsync 协议

除了使用 SSH，如果另一台服务器安装并运行了 rsync 守护程序，则也可以用`rsync://`协议（默认端口873）进行传输。具体写法是服务器与目标目录之间使用双冒号分隔`::`。

```

$ rsync -av source/ 192.168.122.32::module/destination
```

注意，上面地址中的`module`并不是实际路径名，而是 rsync 守护程序指定的一个资源名，由管理员分配。

如果想知道 rsync 守护程序分配的所有 module 列表，可以执行下面命令。

```

$ rsync rsync://192.168.122.32
```

rsync 协议除了使用双冒号，也可以直接用`rsync://`协议指定地址。

```

$ rsync -av source/ rsync://192.168.122.32/module/destination
```

## 六、增量备份

rsync 的最大特点就是它可以完成增量备份，也就是默认只复制有变动的文件。

除了源目录与目标目录直接比较，rsync 还支持使用基准目录，即将源目录与基准目录之间变动的部分，同步到目标目录。

具体做法是，第一次同步是全量备份，所有文件在基准目录里面同步一份。以后每一次同步都是增量备份，只同步源目录与基准目录之间有变动的部分，将这部分保存在一个新的目标目录。这个新的目标目录之中，也是包含所有文件，但实际上，只有那些变动过的文件是存在于该目录，其他没有变动的文件都是指向基准目录文件的硬链接。

`--link-dest`参数用来指定同步时的基准目录。

```

$ rsync -a --delete --link-dest /compare/path /source/path /target/path
```

上面命令中，`--link-dest`参数指定基准目录`/compare/path`，然后源目录`/source/path`跟基准目录进行比较，找出变动的文件，将它们拷贝到目标目录`/target/path`。那些没变动的文件则会生成硬链接。这个命令的第一次备份时是全量备份，后面就都是增量备份了。

下面是一个脚本示例，备份用户的主目录。

```

#!/bin/bash

# A script to perform incremental backups using rsync

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="${HOME}"
readonly BACKUP_DIR="/mnt/data/backups"
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

mkdir -p "${BACKUP_DIR}"

rsync -av --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  --exclude=".cache" \
  "${BACKUP_PATH}"

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
```

上面脚本中，每一次同步都会生成一个新目录`${BACKUP_DIR}/${DATETIME}`，并将软链接`${BACKUP_DIR}/latest`指向这个目录。下一次备份时，就将`${BACKUP_DIR}/latest`作为基准目录，生成新的备份目录。最后，再将软链接`${BACKUP_DIR}/latest`指向新的备份目录。

## 七、配置项

`-a`、`--archive`参数表示存档模式，保存所有的元数据，比如修改时间（modification time）、权限、所有者等，并且软链接也会同步过去。

`--append`参数指定文件接着上次中断的地方，继续传输。

`--append-verify`参数跟`--append`参数类似，但会对传输完成后的文件进行一次校验。如果校验失败，将重新发送整个文件。

`-b`、`--backup`参数指定在删除或更新目标目录已经存在的文件时，将该文件更名后进行备份，默认行为是删除。更名规则是添加由`--suffix`参数指定的文件后缀名，默认是`~`。

`--backup-dir`参数指定文件备份时存放的目录，比如`--backup-dir=/path/to/backups`。

`--bwlimit`参数指定带宽限制，默认单位是 KB/s，比如`--bwlimit=100`。

`-c`、`--checksum`参数改变`rsync`的校验方式。默认情况下，rsync 只检查文件的大小和最后修改日期是否发生变化，如果发生变化，就重新传输；使用这个参数以后，则通过判断文件内容的校验和，决定是否重新传输。

`--delete`参数删除只存在于目标目录、不存在于源目标的文件，即保证目标目录是源目标的镜像。

`-e`参数指定使用 SSH 协议传输数据。

`--exclude`参数指定排除不进行同步的文件，比如`--exclude="*.iso"`。

`--exclude-from`参数指定一个本地文件，里面是需要排除的文件模式，每个模式一行。

`--existing`、`--ignore-non-existing`参数表示不同步目标目录中不存在的文件和目录。

`-h`参数表示以人类可读的格式输出。

`-h`、`--help`参数返回帮助信息。

`-i`参数表示输出源目录与目标目录之间文件差异的详细情况。

`--ignore-existing`参数表示只要该文件在目标目录中已经存在，就跳过去，不再同步这些文件。

`--include`参数指定同步时要包括的文件，一般与`--exclude`结合使用。

`--link-dest`参数指定增量备份的基准目录。

`-m`参数指定不同步空目录。

`--max-size`参数设置传输的最大文件的大小限制，比如不超过200KB（`--max-size='200k'`）。

`--min-size`参数设置传输的最小文件的大小限制，比如不小于10KB（`--min-size=10k`）。

`-n`参数或`--dry-run`参数模拟将要执行的操作，而并不真的执行。配合`-v`参数使用，可以看到哪些内容会被同步过去。

`-P`参数是`--progress`和`--partial`这两个参数的结合。

`--partial`参数允许恢复中断的传输。不使用该参数时，`rsync`会删除传输到一半被打断的文件；使用该参数后，传输到一半的文件也会同步到目标目录，下次同步时再恢复中断的传输。一般需要与`--append`或`--append-verify`配合使用。

`--partial-dir`参数指定将传输到一半的文件保存到一个临时目录，比如`--partial-dir=.rsync-partial`。一般需要与`--append`或`--append-verify`配合使用。

`--progress`参数表示显示进展。

`-r`参数表示递归，即包含子目录。

`--remove-source-files`参数表示传输成功后，删除发送方的文件。

`--size-only`参数表示只同步大小有变化的文件，不考虑文件修改时间的差异。

`--suffix`参数指定文件名备份时，对文件名添加的后缀，默认是`~`。

`-u`、`--update`参数表示同步时跳过目标目录中修改时间更新的文件，即不同步这些有更新的时间戳的文件。

`-v`参数表示输出细节。`-vv`表示输出更详细的信息，`-vvv`表示输出最详细的信息。

`--version`参数返回 rsync 的版本。

`-z`参数指定同步时压缩数据。

## 八、参考链接

-   [How To Use Rsync to Sync Local and Remote Directories on a VPS](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps), Justin Ellingwood
-   [Mirror Your Web Site With rsync](https://www.howtoforge.com/mirroring_with_rsync), Falko Timme
-   [Examples on how to use Rsync](https://linuxconfig.org/examples-on-how-to-use-rsync-for-local-and-remote-data-backups-and-synchonization), Egidio Docile
-   [How to create incremental backups using rsync on Linux](https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux), Egidio Docile

（完）