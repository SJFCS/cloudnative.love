# file文件模块

[[toc]]

## 1. 基础知识储备

我们先来学习一下一些基础知识。主要涉及`stat`、`chattr`、`lsattr`命令。

- `stat`，display file or file system status，显示文件或文件系统状态。

- `chattr`，change file attributes on a Linux file system，改变文件属性。

- `lsattr` ， list file attributes on a Linux second extended file system，查看文件属性。



下面摘录了`chattr`的man手册页部分内容：

> NAME
>        chattr - change file attributes on a Linux file system
>
> SYNOPSIS
>        chattr [ -RVf ] [ -v version ] [ mode ] files...
>
> DESCRIPTION
>        chattr changes the file attributes on a Linux file system.
>
>        The format of a symbolic mode is +-=[aAcCdDeijsStTu].
>                         
>        The  operator '+' causes the selected attributes to be added to the existing
>        attributes of the files; '-' causes them to be removed; and '=' causes  them
>        to be the only attributes that the files have.
>                         
>        The letters 'aAcCdDeijsStTu' select the new attributes for the files: append
>        only (a), no atime updates (A), compressed (c), no copy  on  write  (C),  no
>        dump  (d),  synchronous  directory updates (D), extent format (e), immutable
>        (i), data journalling (j), secure deletion (s), synchronous updates (S),  no
>        tail-merging (t), top of directory hierarchy (T), and undeletable (u).
>                         
>        The  following  attributes are read-only, and may be listed by lsattr(1) but
>        not modified by chattr: compression error (E), huge file (h), indexed direc‐
>        tory  (I), inline data (N), compression raw access (X), and compressed dirty
>        file (Z).
>                         
>        Not all flags are  supported  or  utilized  by  all  filesystems;  refer  to
>        filesystem-specific man pages such as btrfs(5), ext4(5), and xfs(5) for more
>        filesystem-specific details.

需要注意一点是，并不是所有的文件系统都支持所有标志，如可以通过`man ext4`和`man xfs`查看`ext4`或`xfs`文件格式支持的文件属性标志。

ext4文件系统支持的属性标志：

```
FILE ATTRIBUTES
       The ext2, ext3, and ext4 filesystems support setting  the  following
       file attributes on Linux systems using the chattr(1) utility:
       a - append only
       A - no atime updates
       d - no dump
       D - synchronous directory updates
       i - immutable
       S - synchronous updates
       u - undeletable
       In  addition,  the  ext3  and ext4 filesystems support the following
       flag:
       j - data journaling
       Finally, the ext4 filesystem also supports the following flag:
       e - extents format
       For descriptions of these  attribute  flags,  please  refer  to  the
       chattr(1) man page.
```

xfs文件系统支持的属性标志：

```
FILE ATTRIBUTES
       The  XFS  filesystem  supports  setting  the following file attributes on Linux systems
       using the chattr(1) utility:
       a - append only
       A - no atime updates
       d - no dump
       i - immutable
       S - synchronous updates
       For descriptions of these attribute flags, please refer to the chattr(1) man page.
```

我们看一下xfs文件属性支持的属性标志：

```
a - append only  只能追加数据
A - no atime updates  不能更新访问时间
d - no dump  不能dump
i - immutable 系统不允许对这个文件进行任何的修改。如果目录具有这个属性，那么任何的进程只能修改目录之下的文件，不允许建立和删除文件。
S - synchronous updates 同步更新，彻底删除文件，不可恢复，因为是从磁盘上删除，然后用0填充文件所在区域。
```



查看文件系统类型：

```sh
[ansible@master ~]$ df -T
Filesystem              Type     1K-blocks    Used Available Use% Mounted on
/dev/mapper/centos-root xfs       17811456 1886708  15924748  11% /
devtmpfs                devtmpfs    929216       0    929216   0% /dev
tmpfs                   tmpfs       941148       0    941148   0% /dev/shm
tmpfs                   tmpfs       941148    8656    932492   1% /run
tmpfs                   tmpfs       941148       0    941148   0% /sys/fs/cgroup
/dev/sda1               xfs        1038336  147812    890524  15% /boot
tmpfs                   tmpfs       188232       0    188232   0% /run/user/0
[ansible@master ~]$ 
```

ext4与xfs文件系统对比：

> Ext4 作为传统的文件系统确实非常成熟稳定，但是随着存储需求的越来越大，Ext4 渐渐适应不了了。比如说现在虽然Ext4 目录索引采用了Hash Index Tree, 但是依然限制高度为2. 做过实际测试
> Ext4的单个目录文件超过200W个，性能下降的就比较厉害了。
>
> 由于历史磁盘结构原因Ext4 的inode 个数限制(32位数)最多只能有大概40多亿文件。而且Ext4的单个文件大小最大只能支持到16T(4K block size) 的话，这些至少对于目前来说已经是瓶颈了...
>
> 而XFS使用64位管理空间，文件系统规模可以达到EB级别，可以说未来几年XFS彻底取代Ext4是早晚的事情！
>
> 作者：知乎用户
>
> 链接：https://www.zhihu.com/question/24413471/answer/38883787
>
> 来源：知乎

可以看到，我们现在使用的是`xfs`系统。





查看文件状态：

```sh
[ansible@master ~]$ stat /etc/ansible/hosts
  File: ‘/etc/ansible/hosts’
  Size: 202       	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 17557773    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2020-08-04 16:36:12.411805846 +0800
Modify: 2020-07-07 16:54:31.234852138 +0800
Change: 2020-07-07 16:54:31.288852184 +0800
 Birth: -
[ansible@master ~]$ ls
ansible-yml
[ansible@master ~]$ stat ansible-yml/
  File: ‘ansible-yml/’
  Size: 261       	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 999797      Links: 2
Access: (0775/drwxrwxr-x)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-03 16:31:47.186890179 +0800
Modify: 2020-08-05 17:04:26.513006244 +0800
Change: 2020-08-05 17:04:26.513006244 +0800
 Birth: -
[ansible@master ~]$
```

我们来使用一下`chattr`修改一下文件的属性标志。

```sh
# 新建一个文件
[ansible@master ~]$ echo "line 1" > file.txt
[ansible@master ~]$ cat file.txt 
line 1
[ansible@master ~]$ 

# 添加只能追加的属性标志，可以看到需要使用sudo才能修改属性标志
[ansible@master ~]$ chattr +a file.txt 
chattr: Operation not permitted while setting flags on file.txt
[ansible@master ~]$ sudo chattr +a file.txt 

# 查看属性标志
[ansible@master ~]$ lsattr file.txt 
-----a---------- file.txt

# 尝试进行追加数据，可以看到能够正常追加数据，成功添加第2行数据
[ansible@master ~]$ echo "line 2" >> file.txt
[ansible@master ~]$ cat file.txt
line 1
line 2

# 尝试重写文件、替换文件内容、删除文件，可以发现不能重写，也不能进行替换、也不能删除
[ansible@master ~]$ echo "new line 1" > file.txt
bash: file.txt: Operation not permitted
# 替换失败
[ansible@master ~]$ sed -i 's/line/LINE/g' file.txt
sed: cannot rename ./sedJDFY6y: Operation not permitted
[ansible@master ~]$ cat file.txt
line 1
line 2
[ansible@master ~]$ 
# 删除失败
[ansible@master ~]$ trash-put file.txt
trash-put: cannot trash regular file 'file.txt'
[ansible@master ~]$ sudo trash-put file.txt
trash-put: cannot trash regular file 'file.txt'
[ansible@master ~]$ 

# 移除只能追加的属性标志
[ansible@master ~]$ sudo chattr -a file.txt
[ansible@master ~]$ lsattr file.txt
---------------- file.txt
# 移除标志后，可以正常的替换，正常的删除文件了！
[ansible@master ~]$ sed -i 's/line/LINE/g' file.txt
[ansible@master ~]$ cat file.txt
LINE 1
LINE 2
[ansible@master ~]$ trash-put file.txt
[ansible@master ~]$ cat file.txt
cat: file.txt: No such file or directory
```

下面我们来看一下`stat`命令中显示的`Access`，`Modify`，`Change`三个值。

```sh
# 创建文件
[ansible@master ~]$ echo 'line 1' > file.txt

# 查看文件系统状态，
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 7         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 11:44:18.996136061 +0800
Modify: 2020-08-06 11:44:18.996136061 +0800
Change: 2020-08-06 11:44:18.996136061 +0800
 Birth: -
[ansible@master ~]$
[ansible@master ~]$ cat file.txt 
line 1
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 7         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 11:44:34.477712575 +0800
Modify: 2020-08-06 11:44:18.996136061 +0800
Change: 2020-08-06 11:44:18.996136061 +0800
 Birth: -
[ansible@master ~]$ cat file.txt 
line 1
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 7         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 11:44:34.477712575 +0800
Modify: 2020-08-06 11:44:18.996136061 +0800
Change: 2020-08-06 11:44:18.996136061 +0800
 Birth: -
[ansible@master ~]$
```

可以看到，在第一次使用`cat`查看文件后，`Access`访问时间发生了更新，**但后续再进行`cat`操作时，`Access`访问时间并没有更新**。



### 1.1 `Access`，`Modify`，`Change`三个时间的区别

`Access`: time of last access，文件**最近一次被访问**的时间。

`Modify`: time of last modification, 文件**内容最近一次被修改**的时间。

`Change`： time of last change，文件**属性最近一次被改变**的时间。

可以通过以下几个操作看到它们之间的区别：

- 假如用`cat`命令将文件`file.txt`的内容输出到终端(执行 `cat file.txt`), 那么只有`file.txt`的`Access`就被刷新了。
- 假如我们把当前的时间追加到`file.txt`(执行 `date >> file.txt`),那么`file.txt`的`Modify`和`Change`都被刷新。
- 假如我们把`file.txt`的权限改为`777`(执行 `chmod 777 file.txt`), 那么只有`file.txt`的`Change`被刷新。
- 假如我们用`vi`命令把文件`file.txt`打开, 写入数据，然后保存退出，那么`file.txt`的`Access`、`Modify`和`Change`都被刷新。
- 使用`ls -l`查看的是文件的`Modify`时间。
- `Access`访问时间比较特殊，并不是每次你用`cat`等工具查看后，再使用`stat`查看文件属性都能发现`Access`访问时间发生改变（**即并不是每次都更新**）！

要理解这个问题，必须了解文件系统的挂载形式，`Access`访问时间与`mount`的参数以及内核有关,我们通过`man mount`可以看到文件系统挂载时可以使用不同的参数：

```
FILESYSTEM INDEPENDENT MOUNT OPTIONS
       Some of these options are only useful when they appear in the /etc/fstab file.
       Some  of  these  options  could be enabled or disabled by default in the system kernel.
       To check the current setting see the options in /proc/mounts.   Note  that  filesystems
       also  have  per-filesystem  specific  default mount options (see for example tune2fs -l
       output for extN filesystems).
       The following options apply to any filesystem that is  being  mounted  (but  not  every
       filesystem actually honors them - e.g., the sync option today has effect only for ext2,
       ext3, ext4, fat, vfat and ufs):
       atime  Do  not  use noatime feature, then the inode access time is controlled by kernel
              defaults. See also the description for strictatime and relatime mount options.
       noatime
              Do not update inode access times on this filesystem (e.g., for faster access  on
              the news spool to speed up news servers).
       relatime
              Update inode access times relative to modify or change  time.   Access  time  is
              only  updated if the previous access time was earlier than the current modify or
              change time. (Similar to noatime, but doesn't break mutt or  other  applications
              that need to know if a file has been read since the last time it was modified.)
              Since  Linux 2.6.30, the kernel defaults to the behavior provided by this option
              (unless noatime was  specified), and  the  strictatime  option  is  required  to
              obtain  traditional  semantics. In addition, since Linux 2.6.30, the file's last
              access time is always  updated  if  it  is more than 1 day old.
       norelatime
              Do not use relatime feature. See also the strictatime mount option.
       strictatime
              Allows to explicitly requesting full atime updates. This makes it  possible  for
              kernel  to defaults to relatime or noatime but still allow userspace to override
              it. For more details about the default system mount options see /proc/mounts.
       nostrictatime
              Use the kernel's default behaviour for inode access time updates.
```

`mount`挂载时，参数说明：

- `atime`,采用内核默认行为。Linux 2.6.30默认使用`relatime`。
- `noatime`，即不更新`Access`访问时间。
- `relatime`,使用相对时间来更新，只有当`Access`访问时间比`Modify`修改时间或者`change`属性改变时间早时才会更新。自Linux 2.6.30起，内核默认使用此选项提供的行为（ 除非指定了`noatime`），并且必须使用`strictatime`选项才能获取传统语义。 此外，自Linux 2.6.30起，如果文件的`Access`访问时间比现在早一天，那么文件在读取时就会更新`Access`访问时间。
- `norelatime`，不使用相对时间特性。
- `strictatime`，严格模式，即每次都更新`Access`访问时间。 有关默认系统安装选项的更多详细信息，请参见`/proc/mounts`。
- `nostrictatime`, 不使用严格模式，即使用内核默认模式。

我们查看一下我们系统使用的文件系统挂载方式：

```sh
[ansible@master ~]$ df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        17G  1.8G   16G  11% /
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     920M     0  920M   0% /dev/shm
tmpfs                   tmpfs     920M  8.5M  911M   1% /run
tmpfs                   tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  145M  870M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0
[ansible@master ~]$ cat /proc/mounts |grep 'centos-root'
/dev/mapper/centos-root / xfs rw,relatime,attr2,inode64,noquota 0 0
[ansible@master ~]$ 
```

可以看到，我们的系统使用的是`relatime`相对时间来挂载文件系统的！



通过上面对文件系统进一步了解后，我们知道，现在只有我们更新`file.txt`文件的`Modify`修改时间或者`Change`属性修改时间后`Access`访问时间才会被更新。

我们尝试修改一下`file.txt`文件，然后再查看文件系统的状态信息。

```sh
# 修改文件权限，Change属性修改时间发生了变化
[ansible@master ~]$ ll file.txt 
-rw-rw-r-- 1 ansible ansible 7 Aug  6 11:44 file.txt
[ansible@master ~]$ chmod u+x file.txt 
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 7         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0764/-rwxrw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 11:44:34.477712575 +0800
Modify: 2020-08-06 11:44:18.996136061 +0800
Change: 2020-08-06 15:02:53.773750615 +0800
 Birth: -
[ansible@master ~]$ 
```

我们这时查看文件系统状态信息，可以看到`Change`属性修改时间更新了，但`Access`访问时间和`Modify`修改时间并没有更新。

我们此时使用`cat`查看一下文件，然后再查看文件系统状态信息：

```sh
[ansible@master ~]$ cat file.txt 
line 1
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 7         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0764/-rwxrw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 15:06:46.954994912 +0800
Modify: 2020-08-06 11:44:18.996136061 +0800
Change: 2020-08-06 15:02:53.773750615 +0800
 Birth: -
[ansible@master ~]$
```

此时`Access`访问时间更新了，原因是`Change`属性修改时间更新后，再访问文件就会更新文件的`Access`访问时间。

给文件追加数据：

```sh
[ansible@master ~]$ echo 'line 2' >> file.txt 
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 14        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0764/-rwxrw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 15:06:46.954994912 +0800
Modify: 2020-08-06 15:16:49.144625878 +0800
Change: 2020-08-06 15:16:49.144625878 +0800
 Birth: -
[ansible@master ~]$ 
```

追加数据时，文件的`Modify`和`Change`都被刷新！

再次`cat`查看一下，然后再查看文件系统状态信息：

```sh
[ansible@master ~]$ cat file.txt 
line 1
line 2
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 14        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173235    Links: 1
Access: (0764/-rwxrw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 15:18:22.650723846 +0800
Modify: 2020-08-06 15:16:49.144625878 +0800
Change: 2020-08-06 15:16:49.144625878 +0800
 Birth: -
[ansible@master ~]$ 
```

可以看到，此时`Access`访问时间更新了！原因是文件内容更新了！

我们再用vim打开文件，然后关闭看一下：

```sh
[ansible@master ~]$ vi file.txt 
[ansible@master ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 21        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 34173239    Links: 1
Access: (0764/-rwxrw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 15:20:35.942863509 +0800
Modify: 2020-08-06 15:20:35.942863509 +0800
Change: 2020-08-06 15:20:35.945863513 +0800
 Birth: -
[ansible@master ~]$ 
```

这个时候，`Access`访问时间、`Modify`修改时间和`Change`属性修改时间都更新了！

了解以上基础知识后，我们来看看我们的`file`模块！



### 1.2 Python中`time`模块时间模式化

Python中`time`模块时间模式化的一点知识：

```python
>>> time.strftime?
Docstring:
strftime(format[, tuple]) -> string

Convert a time tuple to a string according to a format specification.
See the library reference manual for formatting codes. When the time tuple
is not present, current time as returned by localtime() is used.

Commonly used format codes:

%Y  Year with century as a decimal number.  4位年份，如2020
%m  Month as a decimal number [01,12]. 月份，如05
%d  Day of the month as a decimal number [01,31]. 日期，如06
%H  Hour (24-hour clock) as a decimal number [00,23]. 24小时制小时数，如07
%M  Minute as a decimal number [00,59]. 分钟数，如08
%S  Second as a decimal number [00,61]. 秒数，如09
%z  Time zone offset from UTC. 时区偏差
%a  Locale's abbreviated weekday name. 本地简化星期名称
%A  Locale's full weekday name. 本地完整星期名称
%b  Locale's abbreviated month name. 简化月份名称
%B  Locale's full month name. 完整月份名称
%c  Locale's appropriate date and time representation. 本地相应的日期表示和时间表示
%I  Hour (12-hour clock) as a decimal number [01,12]. 12小时制小时数
%p  Locale's equivalent of either AM or PM. 上午或下午表示符

Other codes may be available on your platform.  See documentation for
the C library strftime function.
Type:      builtin_function_or_method
    
>>> time.strftime('%Y%m%d %H%M%S', time.localtime())
'20200527 221503'

# 时间格式中加入其他元素
>>> time.strftime('%Y年%m月%d日 %H:%M:%S', time.localtime())
'2020年05月27日 22:19:10'

>>> time.strftime('%Y年%m月%d日 %H:%M:%S')
'2020年05月27日 22:21:50'
```

可参考官方文档 [https://docs.python.org/3.6/library/time.html#time.strftime](https://docs.python.org/3.6/library/time.html#time.strftime).





## 2. 概要

- `file`模块用来管理文件和文件属性。
- 可以删除文件、符号链接或目录。
- 许多其他模块支持与`file`文件模块相同的选项，如`copy`、`template`、`assemble`等。
- 对于Windows目标，请使用用`win_file`模块。
- 源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/file.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/file.py)
- 官方文档：[https://docs.ansible.com/ansible/latest/modules/file_module.html](https://docs.ansible.com/ansible/latest/modules/file_module.html)



## 3. 参数

| 参数                       | 可选值                           | 默认值          | 说明                                                         |
| -------------------------- | -------------------------------- | --------------- | ------------------------------------------------------------ |
| `attributes`               |                                  |                 | `string`，文件或文件夹的属性，默认是`=`，如果需要进行`+`、`-`操作，则需要包含在字符串中。别名`attr`。可以参考`chattr`。 |
| `follow`                   | yes/no                           | yes             | 是否跟踪文件系统上面的链接文件。                             |
| `force`                    | yes/no                           | no           | 在两种情况下强制创建符号链接：源文件不存在（但稍后会出现）； 目标存在并且是文件（因此，我们需要取消链接路径文件并创建到src文件的符号链接）。 |
| `group`                    |                                  |                 | `string`,用户组的名称。                                      |
| `mode`                     |                                  |                 | `string`,目标文件或目录的权限。对于那些习惯于`/usr/bin/chmod`的用户，请记住模式实际上是八进制数。您必须添加一个前导零，以便Ansible的YAML解析器知道它是一个八进制数(例如`0644`或`01777`)或用引号(例如`'644'`或`'1777'`)来使Ansible接收字符串并可以从字符串进行自己的转换成数字。不遵循这些规则的话，Ansible将会这这些数字当做十进制数，这将引起异常。从Ansible1.8开始，可以将模式指定为符号模式（例如，`u+rwx`或`u=rw,g=r,o=r`)。从Ansible2.3开始，该模式也可能是`preserve`,表示保留源文件相同的权限。(The permissions are r for read, w for write and x for execute.) |
| `owner`                    |                                  |                 | `string`，文件拥有者名称。                                   |
| `src`                      |                                  |                 | `path`, 文件链接到的源文件，仅当`state=link`或`state=hard`时可用！对于`state=link`时，支持源文件不存在。也可以使用相对路径，这是Unix命令`ln -s SRC DEST`处理相对路径的方式。 |
| `unsafe_writes`            | yes/no                           | no              | `boolean`,影响何时使用原子操作来防止数据损坏或对目标文件的读取不一致。 默认情况下，此模块使用原子操作来防止数据损坏或对目标文件的读取不一致，但是有时会以防止这种情况的方式配置或破坏系统。一个示例是docker挂载的文件，该文件无法从容器内部进行原子更新，只能以不安全的方式写入。 当原子操作失败时，此选项允许Ansible退回到不安全的文件更新方法（但是，它不会强制Ansible执行不安全的写操作）。 重要！不安全的写入会受到竞争条件的影响，并可能导致数据损坏。 |
| ----------------           |                                  |                 | **说明，上面几个参数与`copy`模块差不多！**                   |
| `access_time`              |                                  |                 | `string`，设置访问时间，此参数指示文件的访问时间应设置为的时间。如果不需要修改，则应设置为`preserve`保留；默认时间格式为`YYYYMMDDHHMM.SS`；也可以设置为`now`。默认值为`None`，表示状态`state=[file,directory,link,hard]`时的默认值是`preserve`保留，而状态为`state=touch`时的默认值是`now`。 |
| `access_time_format`       |                                  | "%Y%m%d%H%M.%S" | `string`，当设置访问时间时用本参数指定时间格式，参考python的`time.strftime`文档。 |
| `modification_time`        |                                  |                 | `string`，设置文件修改时间。如果不需要修改，则应设置为`preserve`保留；默认时间格式为`YYYYMMDDHHMM.SS`；也可以设置为`now`。默认值为`None`，表示状态`state=[file,directory,link,hard]`时的默认值是`preserve`保留，而状态为`state=touch`时的默认值是`now`。 |
| `modification_time_format` |                                  | "%Y%m%d%H%M.%S" | `string`，当设置修改时间时用本参数指定时间格式，参考python的`time.strftime`文档。 |
| `path`   **required**      |                                  |                 | `path`，需要管理的文件。假名：`dest`、`name`。               |
| `recurse`                  | yes/no                           | no              | `boolean`，在目录内容上递归设置指定的文件属性。仅当`state=directory`时可用。 |
| `state`                    | absent directory file hard link touch | file            | 如果是`state=absent`，目录将被递归删除，文件或符号链接将被取消链接。对于目录，如果声明了diff，您将在`path_contents`下看到删除的文件和文件夹。请注意，如果路径不存在并不会导致`file`模块运行失败。如果是`state=directory`目录，则将创建所有中间子目录。如果是`state=file`文件，且不带任何其他选项，有点类似于`stat`命令，将返回路径的当前状态。即使具有其他选项(如`mode`)，则文件也会被修改，但是要注意的是，如果文件不存在，此时并不会创建文件；如果需要创建，请使用`state=touch`或者使用`copy`或`template`模块。如果是`state=hard`硬链接文件，则将创建或更改硬链接。如果是`state=link`软链接文件，则将创建或更改符号链接。如果是`state=touch`创建文件，则在路径不存在的情况下将创建一个空文件；而现有文件或目录将获得更新的文件访问和修改时间(类似于从命令行使用touch的方式)。 |

## 4. 官方示例

```yaml
- name: Change file ownership, group and permissions
  ansible.builtin.file:
    path: /etc/foo.conf
    owner: foo
    group: foo
    mode: '0644'

- name: Give insecure permissions to an existing file
  ansible.builtin.file:
    path: /work
    owner: root
    group: root
    mode: '1777'

- name: Create a symbolic link
  ansible.builtin.file:
    src: /file/to/link/to
    dest: /path/to/symlink
    owner: foo
    group: foo
    state: link

- name: Create two hard links
  ansible.builtin.file:
    src: '/tmp/{{ item.src }}'
    dest: '{{ item.dest }}'
    state: hard
  loop:
    - { src: x, dest: y }
    - { src: z, dest: k }

- name: Touch a file, using symbolic modes to set the permissions (equivalent to 0644)
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u=rw,g=r,o=r

- name: Touch the same file, but add/remove some permissions
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx

- name: Touch again the same file, but do not change times this makes the task idempotent
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx
    modification_time: preserve
    access_time: preserve

- name: Create a directory if it does not exist
  ansible.builtin.file:
    path: /etc/some_directory
    state: directory
    mode: '0755'

- name: Update modification and access time of given file
  ansible.builtin.file:
    path: /etc/some_file
    state: file
    modification_time: now
    access_time: now

- name: Set access time based on seconds from epoch value
  ansible.builtin.file:
    path: /etc/another_file
    state: file
    access_time: '{{ "%Y%m%d%H%M.%S" | strftime(stat_var.stat.atime) }}'

- name: Recursively change ownership of a directory
  ansible.builtin.file:
    path: /etc/foo
    state: directory
    recurse: yes
    owner: foo
    group: foo

- name: Remove file (delete file)
  ansible.builtin.file:
    path: /etc/foo.txt
    state: absent

- name: Recursively remove directory
  ansible.builtin.file:
    path: /etc/foo
    state: absent
```



## 5. 返回值

| 键                                                           | 何时返回       | 描述信息                                              |
| ------------------------------------------------------------ | -------------- | ----------------------------------------------------- |
| **path**                                                  string | 一直           | 文件路径 `/path/to/file.txt `                         |
| **gid**                                                    integer | success        | GID,如`100`                                           |
| **group**                                               string | success        | 文件的组名,如`httpd                                 ` |
| **mode**                                               string | success        | 文件权限，如`420`                                     |
| **owner**                                              string | success        | 文件的owner,如`httpd`                                 |
| **size**                                                  integer | success        | 文件的大小,如`1220`                                   |
| **state**                                                 string | success        | 执行后目标的状态，如`file`                            |
| **uid**                                                     integer | success        | 文件的owner ID,如`100`                                |
| **src**                                                     string | 创建链接文件时 | 链接文件指向的源文件                                  |
| **dest**                                                     string | 创建链接文件时 | 链接文件                                              |



## 6. 临时命令的使用

使用临时命令查看文件的属性信息，并进行权限修改：

```sh
[ansible@master ~]$ ll file.txt 
-rwxrw-r-- 1 ansible ansible 21 Aug  6 15:20 file.txt
[ansible@master ~]$ ansible localhost -m file -a 'path=file.txt'
localhost | SUCCESS => {
    "changed": false, 
    "gid": 1001, 
    "group": "ansible", 
    "mode": "0764", 
    "owner": "ansible", 
    "path": "file.txt", 
    "size": 21, 
    "state": "file", 
    "uid": 1001
}
[ansible@master ~]$ ansible localhost -m file -a 'path=file.txt mode=0664'
localhost | CHANGED => {
    "changed": true, 
    "gid": 1001, 
    "group": "ansible", 
    "mode": "0664", 
    "owner": "ansible", 
    "path": "file.txt", 
    "size": 21, 
    "state": "file", 
    "uid": 1001
}
[ansible@master ~]$ ll file.txt 
-rw-rw-r-- 1 ansible ansible 21 Aug  6 15:20 file.txt
[ansible@master ~]$ 
```

可以看到文件的权限从`0764`变成了`0664`！



## 7. 使用剧本

注意，我们直接在下面的命令前后增加说明信息！！

我们直接把官方的示例修改一下拿来用。



### 7.1 修改文件用户权限信息/创建软链接

```sh
# 查看剧本文件，如果要使用用户的用户或用户组信息，需要使用become参数进行权限提升
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    - name: Change file ownership, group and permissions
      file:
        path: /home/ansible/file.txt
        owner: jenkins
        group: jenkins
        mode: '0644'
      become: yes

    - name: Give insecure permissions to an existing file
      file:
        path: /home/ansible/data
        owner: root
        group: root
        mode: '0777'
      become: yes

    - name: Change back file ownership, group and permissions
      file:
        path: /home/ansible/file.txt
        owner: ansible
        group: ansible
        mode: '0664'
      become: yes

    - name: Create a symbolic link
      file:
        src: /home/ansible/file.txt
        dest: /home/ansible/file_soft.txt
        owner: ansible
        group: ansible
        state: link

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

# 说明：将文件拥有者改成jenkins:jenkins,权限改成0644
TASK [Change file ownership, group and permissions] *********************************************
changed: [node1] => {"changed": true, "gid": 1003, "group": "jenkins", "mode": "0644", "owner": "jenkins", "path": "/home/ansible/file.txt", "size": 21, "state": "file", "uid": 1003}

# 说明：将文件夹拥有者改成root:root,权限改成0777
TASK [Give insecure permissions to an existing file] ********************************************
changed: [node1] => {"changed": true, "gid": 0, "group": "root", "mode": "0777", "owner": "root", "path": "/home/ansible/data", "size": 113, "state": "directory", "uid": 0}

# 说明：将文件拥有者改回为ansible:ansible,权限改成0664
TASK [Change back file ownership, group and permissions] ****************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0664", "owner": "ansible", "path": "/home/ansible/file.txt", "size": 21, "state": "file", "uid": 1001}

# 说明: 创建一个软链接文件
TASK [Create a symbolic link] *******************************************************************
changed: [node1] => {"changed": true, "dest": "/home/ansible/file_soft.txt", "gid": 1001, "group": "ansible", "mode": "0777", "owner": "ansible", "size": 22, "src": "/home/ansible/file.txt", "state": "link", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

在node1上面检查一下：

```sh
# 修改前的文件信息
[ansible@node1 ~]$ ll
total 4
drwxrwxr-x 2 ansible ansible 113 Aug  6 16:00 data
-rw-rw-r-- 1 ansible ansible  21 Aug  6 15:39 file.txt

# 修改后的文件信息
[ansible@node1 ~]$ ll
total 4
drwxrwxrwx 2 root    root    113 Aug  6 16:00 data
lrwxrwxrwx 1 ansible ansible  22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
-rw-rw-r-- 1 ansible ansible  21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ cat file_soft.txt 
line 1
line 2
line 3
[ansible@node1 ~]$ 
```

可以看到软链接创建成功，data目录的权限也发生了变化。



### 7.2 创建硬链接/修改时间属性

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 创建硬链接
    # 注意，创建硬链接时，源文件src必须存在，且目录不允许创建硬链接
    # 此处使用了循环读取src和dest
    - name: Create two hard links
      file:
        src: '/home/ansible/{{ item.src }}'
        dest: '{{ item.dest }}'
        state: hard
      loop:
        - { src: file.txt, dest: /home/ansible/file_hard1.txt }
        - { src: .bashrc, dest: .bashrc_hard.txt }

    # 使用符号模式创建文件
    - name: Touch a file, using symbolic modes to set the permissions (equivalent to 0644)
      file:
        path: /home/ansible/foo1.conf
        state: touch
        mode: u=rw,g=r,o=r

    # 使用符号模式创建文件,同时对文件权限进行增删修改
    - name: Touch the other file, but add/remove some permissions
      file:
        path: /home/ansible/foo2.conf
        state: touch
        mode: u+rw,g-wx,o-rwx

    # 创建文件，但不改变文件的访问时间和修改时间
    - name: Touch again the other file, but dont change times this makes the task idempotent
      file:
        path: /home/ansible/foo3.conf
        state: touch
        mode: u+rw,g-wx,o-rwx
        modification_time: preserve
        access_time: preserve
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Create two hard links] ********************************************************************
changed: [node1] => (item={u'dest': u'/home/ansible/file_hard1.txt', u'src': u'file.txt'}) => {"ansible_loop_var": "item", "changed": true, "dest": "/home/ansible/file_hard1.txt", "gid": 1001, "group": "ansible", "item": {"dest": "/home/ansible/file_hard1.txt", "src": "file.txt"}, "mode": "0664", "owner": "ansible", "size": 21, "src": "/home/ansible/file.txt", "state": "hard", "uid": 1001}
changed: [node1] => (item={u'dest': u'.bashrc_hard.txt', u'src': u'.bashrc'}) => {"ansible_loop_var": "item", "changed": true, "dest": ".bashrc_hard.txt", "gid": 1001, "group": "ansible", "item": {"dest": ".bashrc_hard.txt", "src": ".bashrc"}, "mode": "0644", "owner": "ansible", "size": 311, "src": "/home/ansible/.bashrc", "state": "hard", "uid": 1001}

TASK [Touch a file, using symbolic modes to set the permissions (equivalent to 0644)] ***********
changed: [node1] => {"changed": true, "dest": "/home/ansible/foo1.conf", "gid": 1001, "group": "ansible", "mode": "0644", "owner": "ansible", "size": 0, "state": "file", "uid": 1001}

TASK [Touch the other file, but add/remove some permissions] ************************************
changed: [node1] => {"changed": true, "dest": "/home/ansible/foo2.conf", "gid": 1001, "group": "ansible", "mode": "0640", "owner": "ansible", "size": 0, "state": "file", "uid": 1001}

TASK [Touch again the other file, but dont change times this makes the task idempotent] *********
changed: [node1] => {"changed": true, "dest": "/home/ansible/foo3.conf", "gid": 1001, "group": "ansible", "mode": "0640", "owner": "ansible", "size": 0, "state": "file", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功。

在node1节点上面查看文件系统：

```sh
# 在剧本执行前查看文件信息，注意，此处是为了便于对比，才将两个命令放在一起查看的，你应该在执行剧本前，先执行该命令
[ansible@node1 ~]$ ls -lah
total 48K
drwx------   8 ansible ansible  246 Aug  6 16:07 .
drwxr-xr-x. 10 root    root     134 Jul 24 17:30 ..
drwx------   3 ansible ansible   17 Jun 15 12:42 .ansible
-rw-------   1 ansible ansible  16K Aug  5 17:42 .bash_history
-rw-r--r--   1 ansible ansible   18 Oct 31  2018 .bash_logout
-rw-r--r--   1 ansible ansible  193 Oct 31  2018 .bash_profile
-rw-r--r--   1 ansible ansible  311 Jul 27 15:24 .bashrc
drwx------   3 ansible ansible   18 Jul 13 16:55 .config
drwxrwxrwx   2 root    root     113 Aug  6 16:00 data
lrwxrwxrwx   1 ansible ansible   22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
-rw-rw-r--   1 ansible ansible   21 Aug  6 15:39 file.txt
-rw-------   1 ansible ansible   49 Jul 17 11:06 .lesshst
drwx------   3 ansible ansible   19 Jul 13 14:57 .local
drwxrw----   3 ansible ansible   19 Jun 28 11:31 .pki
-rw-rw-r--   1 ansible ansible   37 Jul 17 15:52 .plan
drwx------   2 ansible ansible   61 Jun 15 12:00 .ssh
-rw-------   1 ansible ansible 4.3K Aug  6 15:39 .viminfo

# 剧本执行后，查看文件系统
[ansible@node1 ~]$ ls -lahi
total 60K
33608939 drwx------   8 ansible ansible 4.0K Aug  6 16:54 .
50350040 drwxr-xr-x. 10 root    root     134 Jul 24 17:30 ..
  787846 drwx------   3 ansible ansible   17 Jun 15 12:42 .ansible
33608949 -rw-------   1 ansible ansible  16K Aug  5 17:42 .bash_history
33608943 -rw-r--r--   1 ansible ansible   18 Oct 31  2018 .bash_logout
33608945 -rw-r--r--   1 ansible ansible  193 Oct 31  2018 .bash_profile
33657147 -rw-r--r--   2 ansible ansible  311 Jul 27 15:24 .bashrc
33657147 -rw-r--r--   2 ansible ansible  311 Jul 27 15:24 .bashrc_hard.txt
50445898 drwx------   3 ansible ansible   18 Jul 13 16:55 .config
33608938 drwxrwxrwx   2 root    root     113 Aug  6 16:00 data
33608951 -rw-rw-r--   2 ansible ansible   21 Aug  6 15:39 file_hard1.txt
33608946 lrwxrwxrwx   1 ansible ansible   22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
33608951 -rw-rw-r--   2 ansible ansible   21 Aug  6 15:39 file.txt
33608955 -rw-r--r--   1 ansible ansible    0 Aug  6 16:54 foo1.conf
33608956 -rw-r-----   1 ansible ansible    0 Aug  6 16:54 foo2.conf
33608957 -rw-r-----   1 ansible ansible    0 Aug  6 16:54 foo3.conf
33608941 -rw-------   1 ansible ansible   49 Jul 17 11:06 .lesshst
33608935 drwx------   3 ansible ansible   19 Jul 13 14:57 .local
50931579 drwxrw----   3 ansible ansible   19 Jun 28 11:31 .pki
33608985 -rw-rw-r--   1 ansible ansible   37 Jul 17 15:52 .plan
50931562 drwx------   2 ansible ansible   61 Jun 15 12:00 .ssh
33608953 -rw-------   1 ansible ansible 4.3K Aug  6 15:39 .viminfo
[ansible@node1 ~]$ 
```

可以看到，`.bashrc`和`.bashrc_hard.txt`的`inode`都是`33657147`，`file_hard1.txt`和`file.txt`的`inode`都是`33608951`。说明硬链接创建成功。

`foo1.conf`的权限是`-rw-r--r--`,刚好与`mode: u=rw,g=r,o=r`指定的相同。

`foo2.conf`的权限是`-rw-r-----`,此时的权限，需要进行计算一下，默认`umask=0002`,则创建的文件权限默认为`-rw-rw-r--`,现在Ansible设置了`mode: u+rw,g-wx,o-rwx`，需要在默认的权限基础上进行处理，user权限需要增加`rw`，默认有`rw`权限，所以user权限不变；group权限需要删除`wx`权限，因此从默认的`rw-`中将`w`删除，此时group权限变成了`r--`,最后other权限，要删除`rwx`权限，因此要从默认的`r--`中将`r`权限删除，变成了`---`，最后，生成的杼就是`-rw-r-----`。

`foo3.conf`的权限与`foo2.conf`的权限一样！

查看`foo2.conf`和`foo3.conf`的文件属性：

```sh
[ansible@node1 ~]$ stat foo2.conf foo3.conf 
  File: ‘foo2.conf’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 33608956    Links: 1
Access: (0640/-rw-r-----)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 16:54:27.036767752 +0800
Modify: 2020-08-06 16:54:27.036767752 +0800
Change: 2020-08-06 16:54:27.036767752 +0800
 Birth: -
  File: ‘foo3.conf’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 33608957    Links: 1
Access: (0640/-rw-r-----)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 16:54:27.224767919 +0800
Modify: 2020-08-06 16:54:27.224767919 +0800
Change: 2020-08-06 16:54:27.224767919 +0800
 Birth: -
[ansible@node1 ~]$ 
```

发现两个文件的`Access`访问时间、`Modify`内容修改时间、`Change`权限修改时间各自相同，看不出来`modification_time`和`access_time`具体的效果。



### 7.3 创建文件夹或对不存在的文件进行处理

我们尝试创建文件夹,并对不存在的文件进行处理,发现剧本执行失败:

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 如果目录不存在则创建
    - name: Create a directory if it does not exist
      file:
        path: /home/ansible/some_directory
        state: directory
        mode: '0755'

    # 更新文件访问时间和文件内容修改时间
    - name: Update modification and access time of given file
      file:
        path: /home/ansible/some_file
        state: file
        modification_time: now
        access_time: now

    # 根据纪元值以秒为单位设置访问时间
    - name: Set access time based on seconds from epoch value
      file:
        path: /home/ansible/another_file
        state: file
        access_time: '{{ "%Y%m%d%H%M.%S" | strftime(stat_var.stat.atime) }}'
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Create a directory if it does not exist] **************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0755", "owner": "ansible", "path": "/home/ansible/some_directory", "size": 6, "state": "directory", "uid": 1001}

TASK [Update modification and access time of given file] ****************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "file (/home/ansible/some_file) is absent, cannot continue", "path": "/home/ansible/some_file"}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

原因是`/home/ansible/some_file`文件不存在!即不能对不存在的文件修改属性信息。

我们创建两个不存在的文件,然后再次执行剧本。

```sh
[ansible@node1 ~]$ echo "some_file" > some_file
[ansible@node1 ~]$ echo "another_file" > another_file
```

再次执行剧本：

```sh
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Create a directory if it does not exist] **************************************************
ok: [node1] => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0755", "owner": "ansible", "path": "/home/ansible/some_directory", "size": 6, "state": "directory", "uid": 1001}

TASK [Update modification and access time of given file] ****************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0664", "owner": "ansible", "path": "/home/ansible/some_file", "size": 10, "state": "file", "uid": 1001}

TASK [Set access time based on seconds from epoch value] ****************************************
fatal: [node1]: FAILED! => {"msg": "The task includes an option with an undefined variable. The error was: 'stat_var' is undefined\n\nThe error appears to be in '/home/ansible/file.yml': line 19, column 7, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n    # 根据纪元值以秒为单位设置访问时间\n    - name: Set access time based on seconds from epoch value\n      ^ here\n"}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

任务`Set access time based on seconds from epoch value`失败，原因是`stat_var`变量未定义。我们将这个任务去掉！

我们此时看一下`some_file`的文件系统状态信息：

```sh
[ansible@node1 ~]$ stat some_file 
  File: ‘some_file’
  Size: 10        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 33608958    Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 17:35:19.418947038 +0800
Modify: 2020-08-06 17:35:19.418947038 +0800
Change: 2020-08-06 17:35:19.418947038 +0800
 Birth: -
```

重新执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 如果目录不存在则创建
    - name: Create a directory if it does not exist
      file:
        path: /home/ansible/some_directory
        state: directory
        mode: '0755'

    # 更新文件访问时间和文件内容修改时间
    - name: Update modification and access time of given file
      file:
        path: /home/ansible/some_file
        state: file
        modification_time: now
        access_time: now

[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Create a directory if it does not exist] **************************************************
ok: [node1] => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0755", "owner": "ansible", "path": "/home/ansible/some_directory", "size": 6, "state": "directory", "uid": 1001}

TASK [Update modification and access time of given file] ****************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0664", "owner": "ansible", "path": "/home/ansible/some_file", "size": 10, "state": "file", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

再次查看`some_file`的文件系统状态信息：

```sh
[ansible@node1 ~]$ stat some_file 
  File: ‘some_file’
  Size: 10        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 33608958    Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 17:40:13.885208713 +0800
Modify: 2020-08-06 17:40:13.885208713 +0800
Change: 2020-08-06 17:40:13.885208713 +0800
 Birth: -
[ansible@node1 ~]$ 
```

可以发现文件系统状态信息已经刷新了，时间都更新了！

说明通过`modification_time: now`和`access_time: now`可以更新文件系统状态信息中的时间信息。



### 7.4 批量创建文件夹

我们来测试批量创建文件夹，首先看看如果父文件夹不存在时，是否会自动创建。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 一次创建多个目录，如果目录不存在则创建
    - name: Create not exist folder
      file:
        path: /home/ansible/d1/d2/d3
        state: directory
        mode: '0755'
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Create not exist folder] ******************************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0755", "owner": "ansible", "path": "/home/ansible/d1/d2/d3", "size": 6, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时，`d1/d2/d3`目录并不存在，但是仍然创建成功了，说明当父目录不存在时，使用`state: directory`仍然会批量创建文件夹的父级目录。

我们在node1节点上面查看一下：

```sh
[ansible@node1 ~]$ tree d1
d1
└── d2
    └── d3

2 directories, 0 files
[ansible@node1 ~]$ ls -dl d1
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 d1
[ansible@node1 ~]$ ls -lah d1/
total 4.0K
drwxr-xr-x  3 ansible ansible   16 Aug  7 10:50 .
drwx------ 10 ansible ansible 4.0K Aug  7 10:50 ..
drwxr-xr-x  3 ansible ansible   16 Aug  7 10:50 d2
[ansible@node1 ~]$ ls -lah d1/d2/
total 0
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 .
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 ..
drwxr-xr-x 2 ansible ansible  6 Aug  7 10:50 d3

# 检查默认创建文件夹时的权限
[ansible@node1 ~]$ umask
0002
[ansible@node1 ~]$ mkdir testfolder
[ansible@node1 ~]$ ll -d testfolder/
drwxrwxr-x 2 ansible ansible 6 Aug  7 10:58 testfolder/
```

可以看到，父级目录`d1`/`d2`和目录`d3`本身都被设置了`rwxr-xr-x`的权限，而这个权限刚好与`mode: '0755'`对应。由于`umask=0002`，默认的话，创建的文件夹是`0775`权限的，即`rwxrwxr-x`,也就是说，本次运行剧本成功的设置了各新建的文件夹的权限了。



### 7.5 递归修改目录属性

下面我们来测试递归修改目录属性。

首先不增加`recurse`参数，来试着修改一下`d1`文件夹的属性。

执行剧本前，再确认一下文件夹的权限：

```sh
[ansible@node1 ~]$ ls -ld d1
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 d1
[ansible@node1 ~]$ ls -ld d1/d2
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 d1/d2
[ansible@node1 ~]$ ls -ld d1/d2/d3
drwxr-xr-x 2 ansible ansible 6 Aug  7 10:50 d1/d2/d3
```

执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 修改目录属性
    - name: Change folder permission without recurse
      file:
        path: /home/ansible/d1
        state: directory
        mode: '0775'

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Change folder permission without recurse] *************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0775", "owner": "ansible", "path": "/home/ansible/d1", "size": 16, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功，看看node1节点上面的文件权限情况：

```sh
[ansible@node1 ~]$ ls -ld d1
drwxrwxr-x 3 ansible ansible 16 Aug  7 10:50 d1
[ansible@node1 ~]$ ls -ld d1/d2
drwxr-xr-x 3 ansible ansible 16 Aug  7 10:50 d1/d2
[ansible@node1 ~]$ ls -ld d1/d2/d3
drwxr-xr-x 2 ansible ansible 6 Aug  7 10:50 d1/d2/d3
[ansible@node1 ~]$
```

此时可以看到，仅`d1`文件夹权限发生了变化，`d2`和`d3`文件夹的权限并没有变化！



下面我们再增加一下`recurse`参数看一下。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 修改目录属性
    - name: Change folder permission with recurse
      file:
        path: /home/ansible/d1
        state: directory
        mode: '0700'
        recurse: yes

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Change folder permission with recurse] ****************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/d1", "size": 16, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们在node1节点上面检查一下权限：

```sh
[ansible@node1 ~]$ ls -ld d1
drwx------ 3 ansible ansible 16 Aug  7 10:50 d1
[ansible@node1 ~]$ ls -ld d1/d2
drwx------ 3 ansible ansible 16 Aug  7 10:50 d1/d2
[ansible@node1 ~]$ ls -ld d1/d2/d3
drwx------ 2 ansible ansible 6 Aug  7 10:50 d1/d2/d3
[ansible@node1 ~]$ 
```

此时可以看到，增加了`recurse=yes`参数后，`d1`目录及其子目录的权限都被更新了，说明`recurse=yes`参数递归修改权限成功了！



### 7.6 递归给文件夹设置文件系统追加属性

我们尝试给文件夹设置`+a`属性，这样让文件夹只能追加数据。

在执行剧本前，我们先看一下，三个文件夹的文件属性权限：

```sh
[ansible@node1 ~]$ lsattr -da d1
---------------- d1
[ansible@node1 ~]$ lsattr -d d1/d2/
---------------- d1/d2/
[ansible@node1 ~]$ lsattr -d d1/d2/d3
---------------- d1/d2/d3
```

可以看到，此时并没有什么特殊的文件系统权限。

我们再执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 修改目录权限属性和文件系统追加属性
    - name: Change folder permission with recurse and attributes
      file:
        path: /home/ansible/d1
        state: directory
        mode: '0750'
        attributes: "+a"
        recurse: yes
      become: yes

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Change folder permission with recurse and attributes] *************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0750", "owner": "ansible", "path": "/home/ansible/d1", "size": 16, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，剧本执行成功。

我们在node1节点上面再次检查三个文件夹的文件系统权限：

```sh
[ansible@node1 ~]$ lsattr -da d1
-----a---------- d1
[ansible@node1 ~]$ lsattr -d d1/d2/
-----a---------- d1/d2/
[ansible@node1 ~]$ lsattr -d d1/d2/d3
-----a---------- d1/d2/d3
[ansible@node1 ~]$ stat d1
  File: ‘d1’
  Size: 16        	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 33608984    Links: 3
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:21:04.476454290 +0800
Modify: 2020-08-07 10:50:58.198184674 +0800
Change: 2020-08-07 11:21:04.476454290 +0800
 Birth: -
[ansible@node1 ~]$ stat d1/d2
  File: ‘d1/d2’
  Size: 16        	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 50418358    Links: 3
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:21:04.479454352 +0800
Modify: 2020-08-07 10:50:58.198184674 +0800
Change: 2020-08-07 11:21:04.479454352 +0800
 Birth: -
[ansible@node1 ~]$ stat d1/d2/d3
  File: ‘d1/d2/d3’
  Size: 6         	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 314098      Links: 2
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:21:04.482454413 +0800
Modify: 2020-08-07 10:50:58.198184674 +0800
Change: 2020-08-07 11:21:04.481454393 +0800
 Birth: -
[ansible@node1 ~]$ 
```

可以看到，三个文件都增加了`a`特殊权限，并且，看三个文件夹的`stat`信息可以知道，Ansible是依次处理`d1`、`d2`、`d3`文件夹的，即先处理父目录，再处理子目录的。

此时去尝试删除或者重命名文件夹，发现失败了：

```sh
[ansible@node1 ~]$ trash-put d1/d2/d3
trash-put: cannot trash directory 'd1/d2/d3'
[ansible@node1 ~]$ mv d1/d2/d3 d1/d2/d3_new
mv: cannot move ‘d1/d2/d3’ to ‘d1/d2/d3_new’: Operation not permitted
[ansible@node1 ~]$ echo 'd1/d2/d3' > d1/d2/d3/test.txt
[ansible@node1 ~]$ cat d1/d2/d3/test.txt 
d1/d2/d3
[ansible@node1 ~]$ 
```

说明`+a`特殊属性起作用了！



### 7.7 `attributes`文件系统特殊属性设置

我们在上一个示例中给文件夹增加了`a`特殊属性，我们此处使用剧本将这个属性去掉。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 移除文件系统追加属性
    - name: Remove folder attributes with recurse
      file:
        path: /home/ansible/d1
        state: directory
        attributes: "-a"
        recurse: yes
      become: yes

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Remove folder attributes with recurse] ****************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0750", "owner": "ansible", "path": "/home/ansible/d1", "size": 16, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功。

我们在node1节点上面再次检查三个文件夹的文件系统权限：

```sh
[ansible@node1 ~]$ stat d1
  File: ‘d1’
  Size: 16        	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 33608984    Links: 3
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:33:41.606467401 +0800
Modify: 2020-08-07 10:50:58.198184674 +0800
Change: 2020-08-07 11:33:41.606467401 +0800
 Birth: -
[ansible@node1 ~]$ stat d1/d2
  File: ‘d1/d2’
  Size: 16        	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 50418358    Links: 3
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:33:41.609467470 +0800
Modify: 2020-08-07 10:50:58.198184674 +0800
Change: 2020-08-07 11:33:41.609467470 +0800
 Birth: -
[ansible@node1 ~]$ stat d1/d2/d3
  File: ‘d1/d2/d3’
  Size: 22        	Blocks: 0          IO Block: 4096   directory
Device: fd00h/64768d	Inode: 314098      Links: 2
Access: (0750/drwxr-x---)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-07 11:33:41.612467540 +0800
Modify: 2020-08-07 11:27:59.745573042 +0800
Change: 2020-08-07 11:33:41.611467517 +0800
 Birth: -
[ansible@node1 ~]$ lsattr -d d1
---------------- d1
[ansible@node1 ~]$ lsattr -d d1/d2
---------------- d1/d2
[ansible@node1 ~]$ lsattr -d d1/d2/d3
---------------- d1/d2/d3
[ansible@node1 ~]$ 
```

可以看到，特殊权限`a`已经移除了！



### 7.8 follow链接跟随功能

现在我们来测试一下，`follow`参数，修改文件属性时是否会自动指向链接文件的源文件。

我们先看一下文件软硬链接情况：

```sh
[ansible@node1 ~]$ ls -li
total 16
33608959 -rw-rw-r-- 1 ansible ansible  13 Aug  6 17:34 another_file
33608984 drwxr-x--- 3 ansible ansible  16 Aug  7 10:50 d1
33608938 drwxrwxrwx 2 root    root    113 Aug  6 16:00 data
33608951 -rw-rw-r-- 2 ansible ansible  21 Aug  6 15:39 file_hard.txt
33608946 lrwxrwxrwx 1 ansible ansible  22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
33608951 -rw-rw-r-- 2 ansible ansible  21 Aug  6 15:39 file.txt
33608987 lrwxrwxrwx 1 ansible ansible  10 Aug  7 13:50 folder_soft -> testfolder
33608955 -rw-r--r-- 1 ansible ansible   0 Aug  6 16:54 foo1.conf
33608956 -rw-r----- 1 ansible ansible   0 Aug  6 16:54 foo2.conf
33608957 -rw-r----- 1 ansible ansible   0 Aug  6 16:54 foo3.conf
50418359 drwxr-xr-x 2 ansible ansible   6 Aug  6 17:27 some_directory
33608958 -rw-rw-r-- 1 ansible ansible  10 Aug  6 17:40 some_file
17039818 drwxrwxr-x 2 ansible ansible   6 Aug  7 10:55 test
33608986 drwxrwxr-x 2 ansible ansible   6 Aug  7 10:58 testfolder
```

`file_hard.txt`是`file.txt`的硬链接。

`file_soft.txt`是`file.txt`的软链接。

`folder_soft`是`testfolder`的软链接。

我们先来看看不使用`follow`参数修改文件属性会怎么样。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变硬链接的权限
    - name: change hard file permission without follow
      file:
        path: /home/ansible/file_hard.txt
        state: file
        mode: "0700"

    # 改变软链接的权限
    - name: change soft file permission without follow
      file:
        path: /home/ansible/folder_soft
        state: file
        mode: "0700"
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change hard file permission without follow] ***********************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/file_hard.txt", "size": 21, "state": "hard", "uid": 1001}

TASK [change soft file permission without follow] ***********************************************
fatal: [node1]: FAILED! => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0775", "msg": "file (/home/ansible/testfolder) is directory, cannot continue", "owner": "ansible", "path": "/home/ansible/testfolder", "size": 6, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

我们可以看到，`change hard file permission without follow`任务执行成功，`change soft file permission without follow`任务执行失败，提示`file (/home/ansible/testfolder) is directory, cannot continue`，即源文件是文件夹，无法继续。

此时查看node1节点上面的`file_hard.txt`硬链接：

```sh
[ansible@node1 ~]$ ls -li file_hard.txt file.txt 
33608951 -rwx------ 2 ansible ansible 21 Aug  6 15:39 file_hard.txt
33608951 -rwx------ 2 ansible ansible 21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ 
```

可以看到，默认会修改硬链接及硬链接指向的源文件的权限。

我们将`change soft file permission without follow`任务的`state: file`改成`state: directory`试一下。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变硬链接的权限
    - name: change hard file permission without follow
      file:
        path: /home/ansible/file_hard.txt
        state: file
        mode: "0700"

    # 改变软链接的权限
    - name: change soft file permission without follow
      file:
        path: /home/ansible/folder_soft
        state: directory
        mode: "0700"
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change hard file permission without follow] ***********************************************
ok: [node1] => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/file_hard.txt", "size": 21, "state": "hard", "uid": 1001}

TASK [change soft file permission without follow] ***********************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/testfolder", "size": 6, "state": "directory", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到，软链接`folder_soft`指向的源文件`testfolder`的权限发生了变化，软链接`folder_soft`本身没有变化，我们在node1节点上确认一下：

```sh
[ansible@node1 ~]$ ls -lid folder_soft testfolder
33608987 lrwxrwxrwx 1 ansible ansible 10 Aug  7 13:50 folder_soft -> testfolder
33608986 drwx------ 2 ansible ansible  6 Aug  7 10:58 testfolder
```

此时`testfolder`文件夹发生了变化，但`folder_soft`并没有变更。

现在，我们再加上`follow=no`参数，来看看不进行链接跟随会怎么样。

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变硬链接的权限
    - name: change hard file permission with follow
      file:
        path: /home/ansible/file_hard.txt
        state: file
        mode: "0664"
        follow: no

    # 改变软链接的权限
    - name: change soft file permission with follow
      file:
        path: /home/ansible/folder_soft
        state: directory
        mode: "0775"
        follow: no

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change hard file permission with follow] **************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0664", "owner": "ansible", "path": "/home/ansible/file_hard.txt", "size": 21, "state": "hard", "uid": 1001}

TASK [change soft file permission with follow] **************************************************
fatal: [node1]: FAILED! => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0777", "msg": "/home/ansible/folder_soft already exists as a link", "owner": "ansible", "path": "/home/ansible/folder_soft", "size": 10, "state": "link", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到`change hard file permission with follow`对硬链接的修改执行成功，`change soft file permission with follow`对文件夹的软链接修改执行失败了。

我们看一下node1节点上文件的情况：

```sh
# 硬链接及其指向的源文件会同时修改
[ansible@node1 ~]$ ls -li file_hard.txt file.txt 
33608951 -rw-rw-r-- 2 ansible ansible 21 Aug  6 15:39 file_hard.txt
33608951 -rw-rw-r-- 2 ansible ansible 21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ chmod 700 file.txt 
[ansible@node1 ~]$ ls -li file_hard.txt file.txt 
33608951 -rwx------ 2 ansible ansible 21 Aug  6 15:39 file_hard.txt
33608951 -rwx------ 2 ansible ansible 21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ chmod 664 file.txt 
[ansible@node1 ~]$ ls -li file_hard.txt file.txt 
33608951 -rw-rw-r-- 2 ansible ansible 21 Aug  6 15:39 file_hard.txt
33608951 -rw-rw-r-- 2 ansible ansible 21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ chmod 744 file_hard.txt 
[ansible@node1 ~]$ ls -li file_hard.txt file.txt 
33608951 -rwxr--r-- 2 ansible ansible 21 Aug  6 15:39 file_hard.txt
33608951 -rwxr--r-- 2 ansible ansible 21 Aug  6 15:39 file.txt
[ansible@node1 ~]$ 


[ansible@node1 ~]$ ls -lid folder_soft testfolder
33608987 lrwxrwxrwx 1 ansible ansible 10 Aug  7 13:50 folder_soft -> testfolder
33608986 drwx------ 2 ansible ansible  6 Aug  7 10:58 testfolder

# 对软链接修改mode,可以发现默认是修改软链接对应的源文件的mode,软链接的mode一直是777
[ansible@node1 ~]$ chmod 770 folder_soft
[ansible@node1 ~]$ ls -lid folder_soft testfolder
33608987 lrwxrwxrwx 1 ansible ansible 10 Aug  7 13:50 folder_soft -> testfolder
33608986 drwxrwx--- 2 ansible ansible  6 Aug  7 10:58 testfolder
[ansible@node1 ~]$ chmod 700 folder_soft
[ansible@node1 ~]$ ls -lid folder_soft testfolder
33608987 lrwxrwxrwx 1 ansible ansible 10 Aug  7 13:50 folder_soft -> testfolder
33608986 drwx------ 2 ansible ansible  6 Aug  7 10:58 testfolder
```

通过以上测试可以看出：

- 对于硬链接，无论是否设置`follow`参数，硬链接及其源文件会被同时修改。
- 对于指向文件夹的软链接，使用`follow=yes`可以修改软链接指向的源文件的属性，不能使用`follow=no`修改软链接的属性。



下面我们来看一下软链接指向文件的属性修改。

看一下我们需要关注的文件：

```sh
[ansible@node1 ~]$ ls -li file.txt file_soft.txt 
33608946 lrwxrwxrwx 1 ansible ansible 22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
33608951 -rwxr--r-- 2 ansible ansible 21 Aug  6 15:39 file.txt
```

执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变软链接的权限
    - name: change soft file permission with follow
      file:
        path: /home/ansible/file_soft.txt
        state: file
        mode: "0664"

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change soft file permission with follow] **************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0664", "owner": "ansible", "path": "/home/ansible/file.txt", "size": 21, "state": "hard", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功。默认情况下使用了`follow=yes`链接跟随，源文件会被修改：

```sh
[ansible@node1 ~]$ ls -li file.txt file_soft.txt 
33608946 lrwxrwxrwx 1 ansible ansible 22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
33608951 -rw-rw-r-- 2 ansible ansible 21 Aug  6 15:39 file.txt
```

可以看到，软链接`file_soft.txt`权限并没有更新，而软链接`file_soft.txt`指向的源文件`file.txt`权限更新了！

我们再添加`follow: yes`参数再改一下权限：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变软链接的权限
    - name: change soft file permission with follow
      file:
        path: /home/ansible/file_soft.txt
        state: file
        mode: "0700"
        follow: yes

[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change soft file permission with follow] **************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/file.txt", "size": 21, "state": "hard", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

查看一下文件的权限信息：

```sh
[ansible@node1 ~]$ ls -li file.txt file_soft.txt 
33608946 lrwxrwxrwx 1 ansible ansible 22 Aug  6 16:07 file_soft.txt -> /home/ansible/file.txt
33608951 -rwx------ 2 ansible ansible 21 Aug  6 15:39 file.txt
```

可以看到，`follow: yes`时一样的会开启链接跟随功能，对软链接的源文件进行修改。

下面再测试一下`follow=no`的情况：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变软链接的权限
    - name: change soft file permission with follow
      file:
        path: /home/ansible/file_soft.txt
        state: file
        mode: "0640"
        follow: no

[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change soft file permission with follow] **************************************************
fatal: [node1]: FAILED! => {"changed": false, "gid": 1001, "group": "ansible", "mode": "0777", "msg": "file (/home/ansible/file_soft.txt) is link, cannot continue", "owner": "ansible", "path": "/home/ansible/file_soft.txt", "size": 22, "state": "link", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，`change soft file permission with follow`失败了，提示`file (/home/ansible/file_soft.txt) is link, cannot continue`,即不能修改软链接本身的属性。



### 7.9 设置访问时间

下面我们尝试修改`file.txt`文件的时间属性。

先在node1节点上面看一下file.txt文件的文件系统状态信息：

```sh
[ansible@node1 ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 21        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 33608951    Links: 2
Access: (0700/-rwx------)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-08-06 16:12:56.993441212 +0800
Modify: 2020-08-06 15:39:15.513445632 +0800
Change: 2020-08-07 14:54:25.058990398 +0800
 Birth: -
[ansible@node1 ~]$
```

然后执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变文件的时间属性
    - name: change file access time
      file:
        path: /home/ansible/file.txt
        state: file
        modification_time: now
        access_time: '202001010102.34'
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change file access time] ******************************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/file.txt", "size": 21, "state": "hard", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功，我们在node1节点上再查看一下file.txt文件的文件系统状态信息：

```sh
[ansible@node1 ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 21        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 33608951    Links: 2
Access: (0700/-rwx------)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-01-01 01:02:34.000000000 +0800
Modify: 2020-08-07 15:36:42.122030000 +0800
Change: 2020-08-07 15:36:42.121006586 +0800
 Birth: -
[ansible@node1 ~]$ 
```

可以看到访问时间已经修改成了`2020-01-01 01:02:34.000000000 +0800`，而文件内容修改时间也更新到今天的最新时间了！



下面我们来设置时间格式：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变文件的时间属性
    - name: change file access time
      file:
        path: /home/ansible/file.txt
        state: file
        modification_time: preserve
        access_time: '2020年05月27日 22:19:10'
        access_time_format: '%Y年%m月%d日 %H:%M:%S'

[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change file access time] ******************************************************************
changed: [node1] => {"changed": true, "gid": 1001, "group": "ansible", "mode": "0700", "owner": "ansible", "path": "/home/ansible/file.txt", "size": 21, "state": "hard", "uid": 1001}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```

剧本成功执行，此时再在node1节点上面查询一下：

```sh
[ansible@node1 ~]$ stat file.txt 
  File: ‘file.txt’
  Size: 21        	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 33608951    Links: 2
Access: (0700/-rwx------)  Uid: ( 1001/ ansible)   Gid: ( 1001/ ansible)
Access: 2020-05-27 22:19:10.000000000 +0800
Modify: 2020-08-07 15:36:42.122030000 +0800
Change: 2020-08-07 15:50:05.511720195 +0800
 Birth: -
[ansible@node1 ~]$ 
```

可以看到，由于Ansible中设置了`access_time: '2020年05月27日 22:19:10'`和`access_time_format: '%Y年%m月%d日 %H:%M:%S'`两个参数，会正常的解析出`Access`访问时间出来，最终`Access`访问时间被更新，更新为`2020-05-27 22:19:10.000000000 +0800`;由于设置了`modification_time: preserve`表示文件内容修改时间保持不变，不进行更新，所以`Modify: 2020-08-07 15:36:42.122030000 +0800`没有被更新，但`Change`文件属性时间被更新了！



如果添加时区，看看能不能正常解析：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 改变文件的时间属性
    - name: change file access time
      file:
        path: /home/ansible/file.txt
        state: file
        modification_time: now
        access_time: '2020年05月27日 22:19:10 +0000'
        access_time_format: '%Y年%m月%d日 %H:%M:%S %z'
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [change file access time] ******************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "Error while obtaining timestamp for time 2020年05月27日 22:19:10 +0000 using format %Y年%m月%d日 %H:%M:%S %z: 'z' is a bad directive in format '%Y年%m月%d日 %H:%M:%S %z'"}

PLAY RECAP **************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，`%z`时区设置不能被解析出来！可以再测试一些其他的格式化字符，但可以发现并不是所有的格式化字符都能正常解析。



### 7.10 强制创建软链接

我们创建硬链接时，硬链接的源文件必须是存在的硬链接才能创建成功。创建软链接时，`ln -s origin soft`时，源文件`origin`可以不用存在。

测试源文件不存在时创建软链接：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 创建软链接
    - name: create soft file with src file not exist
      file:
        src: not_exist.txt
        path: /home/ansible/soft.txt
        state: link
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [create soft file with src file not exist] *************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "src file does not exist, use \"force=yes\" if you really want to create the link: /home/ansible/not_exist.txt", "path": "/home/ansible/soft.txt", "src": "not_exist.txt"}

PLAY RECAP **************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，剧本执行失败，提示`src file does not exist, use \"force=yes\" if you really want to create the link: /home/ansible/not_exist.txt`,即源文件不存在，如果想创建软链接，请使用`force=yes`参数。可以看出默认情况下，创建软链接时也是需要源文件是存在的。

我们现在来增加`force=yes`参数强制创建：

```yml
- hosts: node1
  tasks:
    # 源文件不存在时，强制创建软链接
    - name: create soft file with src file not exist
      file:
        src: not_exist.txt
        path: /home/ansible/soft.txt
        state: link
        force: yes

    # 目标文件存在时，强制创建软链接
    - name: modify soft file with dest file exist
      file:
        src: soft.txt
        path: /home/ansible/file_soft.txt
        state: link
        force: yes
```

我们运行一下剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 源文件不存在时，强制创建软链接
    - name: create soft file with src file not exist
      file:
        src: not_exist.txt
        path: /home/ansible/soft.txt
        state: link
        force: yes

    # 目标文件存在时，强制创建软链接
    - name: modify soft file with dest file exist
      file:
        src: soft.txt
        path: /home/ansible/file_soft.txt
        state: link
        force: yes
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [create soft file with src file not exist] *************************************************
[WARNING]: Cannot set fs attributes on a non-existent symlink target. follow should be set to
False to avoid this.
changed: [node1] => {"changed": true, "dest": "/home/ansible/soft.txt", "src": "not_exist.txt"}

TASK [modify soft file with dest file exist] ****************************************************
changed: [node1] => {"changed": true, "dest": "/home/ansible/file_soft.txt", "src": "soft.txt"}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

此时可以看到，剧本执行成功，两个软链接文件都创建成功。

此时在node1节点上面查看这两个软链接文件：

```sh
[ansible@node1 ~]$ ll soft.txt file_soft.txt 
lrwxrwxrwx 1 ansible ansible  8 Aug  7 16:24 file_soft.txt -> soft.txt
lrwxrwxrwx 1 ansible ansible 13 Aug  7 16:24 soft.txt -> not_exist.txt
[ansible@node1 ~]$ 
```

此时可以看到，软链接创建成功了，但由于`not_exist.txt`文件不存在，在使用命令`ll soft.txt file_soft.txt`查看软链接时，`->`后面的文件名在不停的闪动！说明这两个软链接现在是不可用的！

最好，创建`not_exist.txt`文件后，两个软链接才恢复正常：

```sh
[ansible@node1 ~]$ cat file_soft.txt 
cat: file_soft.txt: No such file or directory
[ansible@node1 ~]$ cat soft.txt 
cat: soft.txt: No such file or directory
[ansible@node1 ~]$ cat not_exist.txt
cat: not_exist.txt: No such file or directory
[ansible@node1 ~]$ echo "not_exist" > not_exist.txt
[ansible@node1 ~]$ ll soft.txt file_soft.txt 
lrwxrwxrwx 1 ansible ansible  8 Aug  7 16:24 file_soft.txt -> soft.txt
lrwxrwxrwx 1 ansible ansible 13 Aug  7 16:24 soft.txt -> not_exist.txt
[ansible@node1 ~]$ cat file_soft.txt 
not_exist
[ansible@node1 ~]$ cat soft.txt 
not_exist
[ansible@node1 ~]$ cat not_exist.txt
not_exist
[ansible@node1 ~]$ 
```



### 7.11 删除文件或文件夹

我们之前测试时，创建了不少文件和文件夹，我们现在用剧本来删除一下。

我们来删除soft.txt文件和d1目录：

```sh
[ansible@node1 ~]$ tree d1
d1
└── d2
    └── d3
        └── test.txt

2 directories, 1 file
[ansible@node1 ~]$ ll soft.txt 
lrwxrwxrwx 1 ansible ansible 13 Aug  7 16:24 soft.txt -> not_exist.txt
```

执行剧本：

```sh
[ansible@master ~]$ cat file.yml 
- hosts: node1
  tasks:
    # 删除文件
    - name: delete file
      file:
        path: /home/ansible/soft.txt
        state: absent

    - name: Recursively remove directory
      file:
        path: /home/ansible/d1
        state: absent
[ansible@master ~]$ ansible-lint file.yml 
[ansible@master ~]$ ansible-playbook --syntax-check file.yml 

playbook: file.yml
[ansible@master ~]$ ansible-playbook file.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [delete file] ******************************************************************************
changed: [node1] => {"changed": true, "path": "/home/ansible/soft.txt", "state": "absent"}

TASK [Recursively remove directory] *************************************************************
changed: [node1] => {"changed": true, "path": "/home/ansible/d1", "state": "absent"}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到剧本执行成功。

```sh
[ansible@node1 ~]$ ll d1 soft.txt not_exist.txt 
ls: cannot access d1: No such file or directory
ls: cannot access soft.txt: No such file or directory
-rw-rw-r-- 1 ansible ansible 10 Aug  7 16:29 not_exist.txt
[ansible@node1 ~]$ 
```

可以看到`d1`目录及其子目录都被删除了，软链接`soft.txt`被删除，软链接`soft.txt`的源文件`not_exist.txt`没有被删除。



## 8. 总结

- 使用`attributes`可以设置文件的一定特殊属性，如``attributes: "+a"``设置文件系统追加属性，可以通过`chattr`命令进行修改文件系统属性，`lsattr`查看文件系统属性，修改时，需要`root`账号或`sudo`权限提升才能修改成功。
- `follow`参数可以修改文件属性时是否会自动指向链接文件的源文件，当`follow=yes`时会自动修改硬链接以及硬链接指向的源文件(注：文件夹不能创建硬链接)，会自动修改软链接指向的源文件，软链接本身不会发生变化。不能使用`follow=no`修改软链接的属性。对于硬链接，无论是否设置`follow`参数，硬链接及其源文件会被同时修改。
- 创建软链接文件或硬链接文件时，默认情况下，源文件必须存在。如果要强制创建软链接，需要使用`force=yes`才能创建成功；硬链接的源文件必须存在。
- 可以通过`access_time`来修改`Access`访问时间属性，通过`modification_time`来修改文件内容修改时间属性，`stat`命令来显示文件或文件系统状态。当这两个值设置为`preserve`时表示不更新这两个时间属性值。配合`access_time_format`、`modification_time_format`可以设置不同的时间解析格式，并不是`time.strftime`所支持的格式化字符都能够正常解析！
- 可以通过`state=directory`和`recurse=yes`一起来对文件夹及其子文件夹进行属性修改。
- `state=absent`时会删除`path`对应的目录及其子目录、文件或链接文件，不会删除链接文件指向的源文件！
- `state=directory`时，会创建`path`对应的目录（如果父目录不存在的话，也会一起创建）。
- `state=file`时并不会创建文件！



参考：

- [详解Linux chattr 命令，超越权限任性修改](https://www.linuxprobe.com/linux-chattr-root.html)
- [Linux chattr 命令详解](https://www.cnblogs.com/ftl1012/p/chattr.html)
- [Linux chattr命令](https://www.runoob.com/linux/linux-comm-chattr.html)
- [Atime value changing only once after file creation](https://unix.stackexchange.com/questions/88840/atime-value-changing-only-once-after-file-creation)