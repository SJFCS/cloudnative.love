# rsync+inotify实现数据实时同步

[[toc]]

## 1. 实验环境说明


| 序列 | 服务器                           | 操作系统                      | IP            | 主机名    |
|------|----------------------------------|:------------------------------|---------------|:----------|
| 1    | 源端服务器(需要备份数据的机器)   | CentOS Linux release 7.7.1908 | 192.168.56.11 | src-host  |
| 2    | 目标端服务器(备份数据存放的机器) | CentOS Linux release 7.7.1908 | 192.168.56.12 | dest-host |

在源端配置`/etc/hosts`增加域名解析：

```sh
[root@src-host ~]# echo '192.168.56.11 src-host' >> /etc/hosts
[root@src-host ~]# echo '192.168.56.12 dest-host' >> /etc/hosts
```

## 2. 概述

- rsync与传统的cp、tar备份方式相比，rsync具有安全性高、备份迅速、支持增量备份等优点，通过rsync可以解决对实时性要求不高的数据备份需求，例如定期的备份文件服务器数据到远端服务器，对本地磁盘定期做数据镜像等。
- 随着应用系统规模的不断扩大，对数据的安全性和可靠性也提出的更好的要求，rsync在高端业务系统中也逐渐暴露出了很多不足，首先，rsync同步数据时，需要扫描所有文件后进行比对，进行差量传输。如果文件数量达到了百万甚至千万量级，扫描所有文件将是非常耗时的。而且正在发生变化的往往是其中很少的一部分，这是非常低效的方式。其次，rsync不能实时的去监测、同步数据，虽然它可以通过linux守护进程的方式进行触发同步，但是两次触发动作一定会有时间差，这样就导致了服务端和客户端数据可能出现不一致，无法在应用故障时完全的恢复数据。基于以上原因，**rsync+inotify组合出现了**。
- 我们通过inotify监控源服务器上待备份的文件夹，当文件夹有变化时则触发rsync进行同步。

## 3. rsync的使用

- rsync官方地址：[https://rsync.samba.org/](https://rsync.samba.org/)

### 3.1 安装rsync
在源端服务器上面安装rsync包：
```sh
[root@src-host ~]# yum install -y rsync
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package rsync.x86_64 0:3.1.2-11.el7_9 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

========================================================================================================================
 Package                  Arch                      Version                            Repository                  Size
========================================================================================================================
Installing:
 rsync                    x86_64                    3.1.2-11.el7_9                     updates                    408 k

Transaction Summary
========================================================================================================================
Install  1 Package

Total download size: 408 k
Installed size: 820 k
Downloading packages:
rsync-3.1.2-11.el7_9.x86_64.rpm                                                                  | 408 kB  00:00:01
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : rsync-3.1.2-11.el7_9.x86_64                                                                          1/1
  Verifying  : rsync-3.1.2-11.el7_9.x86_64                                                                          1/1

Installed:
  rsync.x86_64 0:3.1.2-11.el7_9

Complete!
[root@src-host ~]#
```

查看rsync版本信息：
```sh
[root@src-host ~]# rsync --version
rsync  version 3.1.2  protocol version 31
Copyright (C) 1996-2015 by Andrew Tridgell, Wayne Davison, and others.
Web site: http://rsync.samba.org/
Capabilities:
    64-bit files, 64-bit inums, 64-bit timestamps, 64-bit long ints,
    socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
    append, ACLs, xattrs, iconv, symtimes, prealloc

rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
are welcome to redistribute it under certain conditions.  See the GNU
General Public Licence for details.
```

此时尝试将源端上面的一个文件同步到目标端的`/tmp`目录下：
```sh
[root@src-host ~]# rsync -avP ~/.bashrc root@dest-host:/tmp
root@dest-host's password:
bash: rsync: command not found
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: remote command not found (code 127) at io.c(226) [sender=3.1.2]
[root@src-host ~]#
```
可以看到，提示`rsync error: remote command not found (code 127) at io.c(226)`异常，之所以会出现这个问题，是因为目标端服务器没有安装`rsync`包，不仅源端主机需要安装rsync，而且目标端服务器也需要安装rsync。

在目标端同样安装rsync包：
```sh
[root@dest-host ~]# yum install -y rsync
```

此时再在源端尝试执行同步命令：
```sh
[root@src-host ~]# rsync -avP ~/.bashrc root@dest-host:/tmp
root@dest-host's password:  # <--- 此处需要输入目标端root用户密码
sending incremental file list
.bashrc
            941 100%    0.00kB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 1,034 bytes  received 35 bytes  305.43 bytes/sec
total size is 941  speedup is 0.88
[root@src-host ~]#
```
可以看到，已经成功发送文件。此时在目标端`/tmp`目录查看文件是否存在：
```sh
[root@dest-host ~]# ls -lah /tmp/.bashrc
-rw-r--r-- 1 root root 941 Nov 10 08:39 /tmp/.bashrc
```

可以看到，文件真的同步传输到目标端了。说明同步正常。

### 3.2 获取rsync的帮助信息

获取rsync的帮助信息：
```sh
[root@src-host ~]# rsync --help
rsync  version 3.1.2  protocol version 31
Copyright (C) 1996-2015 by Andrew Tridgell, Wayne Davison, and others.
Web site: http://rsync.samba.org/
Capabilities:
    64-bit files, 64-bit inums, 64-bit timestamps, 64-bit long ints,
    socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
    append, ACLs, xattrs, iconv, symtimes, prealloc

rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
are welcome to redistribute it under certain conditions.  See the GNU
General Public Licence for details.

rsync is a file transfer program capable of efficient remote update
via a fast differencing algorithm.

Usage: rsync [OPTION]... SRC [SRC]... DEST
  or   rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST
  or   rsync [OPTION]... SRC [SRC]... [USER@]HOST::DEST
  or   rsync [OPTION]... SRC [SRC]... rsync://[USER@]HOST[:PORT]/DEST
  or   rsync [OPTION]... [USER@]HOST:SRC [DEST]
  or   rsync [OPTION]... [USER@]HOST::SRC [DEST]
  or   rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]
The ':' usages connect via remote shell, while '::' & 'rsync://' usages connect
to an rsync daemon, and require SRC or DEST to start with a module name.

Options
 -v, --verbose               increase verbosity 详细输出模式
     --info=FLAGS            fine-grained informational verbosity
     --debug=FLAGS           fine-grained debug verbosity
     --msgs2stderr           special output handling for debugging
 -q, --quiet                 suppress non-error messages  精简输出模式
     --no-motd               suppress daemon-mode MOTD (see manpage caveat)
 -c, --checksum              skip based on checksum, not mod-time & size 打开校验开关，强制对文件传输进行校验
 -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X) 归档模式，表示以递归方式传输文件，并保持所有文件属性
     --no-OPTION             turn off an implied OPTION (e.g. --no-D)
 -r, --recursive             recurse into directories 对子目录以递归模式处理
 -R, --relative              use relative path names 使用相对路径信息
     --no-implied-dirs       don't send implied dirs with --relative
 -b, --backup                make backups (see --suffix & --backup-dir) 创建备份
     --backup-dir=DIR        make backups into hierarchy based in DIR 存放备份文件的目录
     --suffix=SUFFIX         set backup suffix (default ~ w/o --backup-dir) 设置备份后缀
 -u, --update                skip files that are newer on the receiver 仅仅进行更新
     --inplace               update destination files in-place (SEE MAN PAGE)
     --append                append data onto shorter files
     --append-verify         like --append, but with old data in file checksum
 -d, --dirs                  transfer directories without recursing 不递归地传输目录
 -l, --links                 copy symlinks as symlinks 保留软链接
 -L, --copy-links            transform symlink into referent file/dir  像对待常规文件一样处理软链接
     --copy-unsafe-links     only "unsafe" symlinks are transformed 仅仅拷贝指向SRC路径目录树以外的链接
     --safe-links            ignore symlinks that point outside the source tree 忽略指向SRC路径目录树以外的链结
     --munge-links           munge symlinks to make them safer (but unusable)
 -k, --copy-dirlinks         transform symlink to a dir into referent dir
 -K, --keep-dirlinks         treat symlinked dir on receiver as dir
 -H, --hard-links            preserve hard links 保持硬链接文件
 -p, --perms                 preserve permissions 保持文件权限
 -E, --executability         preserve the file's executability 保留文件的可执行权限
     --chmod=CHMOD           affect file and/or directory permissions 影响文件和/或目录权限
 -A, --acls                  preserve ACLs (implies --perms) 保留ACL权限
 -X, --xattrs                preserve extended attributes  保留扩展属性
 -o, --owner                 preserve owner (super-user only) 保留文件属主信息
 -g, --group                 preserve group 保留文件属组信息
     --devices               preserve device files (super-user only) 保留设备文件信息
     --copy-devices          copy device contents as regular file 将设备内容复制为常规文件
     --specials              preserve special files 保留特殊文件
 -D                          same as --devices --specials
 -t, --times                 preserve modification times 保留文件时间信息
 -O, --omit-dir-times        omit directories from --times 省略目录时间信息
 -J, --omit-link-times       omit symlinks from --times 省略软链接时间信息
     --super                 receiver attempts super-user activities
     --fake-super            store/recover privileged attrs using xattrs
 -S, --sparse                handle sparse files efficiently 对稀疏文件进行特殊处理以节省DST的空间
     --preallocate           allocate dest files before writing them
 -n, --dry-run               perform a trial run with no changes made 显示哪些文件将被传输,测试运行模式
 -W, --whole-file            copy files whole (without delta-xfer algorithm)  拷贝文件，不进行增量检测
 -x, --one-file-system       don't cross filesystem boundaries 不要跨越文件系统边界
 -B, --block-size=SIZE       force a fixed checksum block-size 检验算法使用的块尺寸，默认是700字节
 -e, --rsh=COMMAND           specify the remote shell to use 指定使用rsh、ssh方式进行数据同步
     --rsync-path=PROGRAM    specify the rsync to run on the remote machine  指定远程服务器上的rsync命令所在路径信息
     --existing              skip creating new files on receiver 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件
     --ignore-existing       skip updating files that already exist on receiver 忽略那些已经存在于接收端的文件，仅备份那些新创建的文件
     --remove-source-files   sender removes synchronized files (non-dirs)
     --del                   an alias for --delete-during 接收者在传输过程中进行删除操作
     --delete                delete extraneous files from destination dirs 删除那些接收端还有而发送端已经不存在的文件
     --delete-before         receiver deletes before transfer, not during 接收者在传输之前进行删除操作 (默认)
     --delete-during         receiver deletes during the transfer 接收者在传输过程中进行删除操作
     --delete-delay          find deletions during, delete after 接收者在传输过程中查找待删除项，但在传输之后进行删除操作
     --delete-after          receiver deletes after transfer, not during 接收者在传输之后进行删除操作
     --delete-excluded       also delete excluded files from destination dirs 在接收方同时删除被排除的文件
     --ignore-missing-args   ignore missing source args without error 缺少源参数，忽略异常
     --delete-missing-args   delete missing source args from destination 从目标中删除缺少的源参数
     --ignore-errors         delete even if there are I/O errors 即使出现 I/O 错误也进行删除
     --force                 force deletion of directories even if not empty 强制删除目录，即使不为空
     --max-delete=NUM        don't delete more than NUM files 最多删除NUM个文件
     --max-size=SIZE         don't transfer any file larger than SIZE 不传输超过SIZE大小的文件
     --min-size=SIZE         don't transfer any file smaller than SIZE 不传输小于SIZE大小的文件

     --partial               keep partially transferred files 保留那些因故没有完全传输的文件，以是加快随后的再次传输
     --partial-dir=DIR       put a partially transferred file into DIR 将部分传输的文件放入DIR
     --delay-updates         put all updated files into place at transfer's end  将正在更新的文件先保存到一个临时目录（默认为 “.~tmp~”），待传输完毕再更新目标文件
 -m, --prune-empty-dirs      prune empty directory chains from the file-list 从文件列表中删除空目录链
     --numeric-ids           don't map uid/gid values by user/group name 不将数字的用户和组id匹配为用户名和组名
     --usermap=STRING        custom username mapping
     --groupmap=STRING       custom groupname mapping
     --chown=USER:GROUP      simple username/groupname mapping
     --timeout=SECONDS       set I/O timeout in seconds 超时时间，单位:秒
     --contimeout=SECONDS    set daemon connection timeout in seconds
 -I, --ignore-times          don't skip files that match in size and mod-time 不跳过那些有同样的时间和长度的文件
 -M, --remote-option=OPTION  send OPTION to the remote side only
     --size-only             skip files that match in size
     --modify-window=NUM     compare mod-times with reduced accuracy
 -T, --temp-dir=DIR          create temporary files in directory DIR
 -y, --fuzzy                 find similar file for basis if no dest file
     --compare-dest=DIR      also compare destination files relative to DIR 同样比较DIR中的文件来决定是否需要备份
     --copy-dest=DIR         ... and include copies of unchanged files
     --link-dest=DIR         hardlink to files in DIR when unchanged
 -z, --compress              compress file data during the transfer 在传输文件时进行压缩处理
     --compress-level=NUM    explicitly set compression level 压缩级别
     --skip-compress=LIST    skip compressing files with a suffix in LIST 跳过压缩在LIST中的后缀的文件
 -C, --cvs-exclude           auto-ignore files the same way CVS does 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
 -f, --filter=RULE           add a file-filtering RULE  增加文件过滤规则
 -F                          same as --filter='dir-merge /.rsync-filter'
                             repeated: --filter='- .rsync-filter'
     --exclude=PATTERN       exclude files matching PATTERN 指定排除一个不需要传输的文件匹配模式
     --exclude-from=FILE     read exclude patterns from FILE 从 FILE 中读取排除规则
     --include=PATTERN       don't exclude files matching PATTERN 指定需要传输的文件匹配模式
     --include-from=FILE     read include patterns from FILE 从 FILE 中读取包含规则
     --files-from=FILE       read list of source-file names from FILE 从FILE文件中读取源文件名称
 -0, --from0                 all *-from/filter files are delimited by 0s
 -s, --protect-args          no space-splitting; only wildcard special-chars
     --address=ADDRESS       bind address for outgoing socket to daemon 绑定到特定的地址
     --port=PORT             specify double-colon alternate port number 指定其他的rsync服务端口
     --sockopts=OPTIONS      specify custom TCP options
     --blocking-io           use blocking I/O for the remote shell  对远程shell使用阻塞IO
     --stats                 give some file-transfer stats
 -8, --8-bit-output          leave high-bit chars unescaped in output
 -h, --human-readable        output numbers in a human-readable format 以人类可读格式输出
     --progress              show progress during transfer 在传输时显示传输过程
 -P                          same as --partial --progress
 -i, --itemize-changes       output a change-summary for all updates 输出所有更新的更改摘要
     --out-format=FORMAT     output updates using the specified FORMAT
     --log-file=FILE         log what we're doing to the specified FILE 指定日志文件
     --log-file-format=FMT   log updates using the specified FMT
     --password-file=FILE    read daemon-access password from FILE 从 FILE 中读取口令，以避免在终端上输入口令
     --list-only             list the files instead of copying them 仅仅列出文件而不进行复制
     --bwlimit=RATE          limit socket I/O bandwidth 限制I/O带宽
     --outbuf=N|L|B          set output buffering to None, Line, or Block
     --write-batch=FILE      write a batched update to FILE
     --only-write-batch=FILE like --write-batch but w/o updating destination
     --read-batch=FILE       read a batched update from FILE
     --protocol=NUM          force an older protocol version to be used 强制使用旧的协议版本
     --iconv=CONVERT_SPEC    request charset conversion of filenames 请求文件名的字符集转换
     --checksum-seed=NUM     set block/file checksum seed (advanced)
 -4, --ipv4                  prefer IPv4  使用 IPv4
 -6, --ipv6                  prefer IPv6  使用 IPv6
     --version               print version number  打印版本信息
(-h) --help                  show this help (-h is --help only if used alone)  显示帮助信息

Use "rsync --daemon --help" to see the daemon-mode command-line options.
Please see the rsync(1) and rsyncd.conf(5) man pages for full documentation.
See http://rsync.samba.org/ for updates, bug reports, and answers
[root@src-host ~]#
```
可以看到，选项非常多,我们把常用的选项的中文翻译写在的上面的帮助信息各选项的后面。

特别注意以下几个选项：
- `-a,  --archive` 归档模式，等价于`-rlptgoD`。
- `-r, --recursive` 对子目录以递归模式处理。
- `-l, --links` 保留软链接。
- `-p, --perms` 保留文件权限。
- `-t, --times` 保留文件时间信息。
- `-g, --group` 保留文件属组信息。
- `-o, --owner` 保留文件属主信息。
- `-D`  等价于`--devices --specials`。
- `--devices` 保留设备文件信息。
- `--specials` 保留特殊文件。
- ` -v, --verbose` 详细输出模式。
- `--version`  打印版本信息。
- `-h, --help` 显示帮助信息。
- `-z, --compress` 在传输文件时进行压缩处理。
- `--partial` 保留那些因故没有完全传输的文件，以是加快随后的再次传输。
- `--progress` 在传输时显示传输过程。
- `-P` 等价于`--partial --progress`。
- `--delete` 删除那些接收端还有而发送端已经不存在的文件。

### 3.3 设置免密传输

在3.1节中。我们使用`rsync -avP ~/.bashrc root@dest-host:/tmp`进行同步时，需要输入远程`dest-host`目标端`root`账号对应的密码，手动设置还好，如果每次同步都输入密码就比较麻烦，我们可以设置免密传输。

只需要将`src-host`源端`root`账号的公钥复制到`dest-host`目标端`root`账号下即可。

`src-host`源端创建公钥私钥对：

```sh
[root@src-host ~]# ssh-keygen -C root@dest-host
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:GHnrb/BbixXxddmqtnrV2RJF9u8qXpJJ9prg1bIYb6k root@dest-host
The key's randomart image is:
+---[RSA 2048]----+
|               .o|
|       .       .=|
|      o .   .  o=|
|       + .   o.oo|
|      . S   + oo+|
|       ..  o Booo|
|        .oo @o+..|
|         oo@=X . |
|         .EBO..  |
+----[SHA256]-----+
[root@src-host ~]#
```

复制公钥到`dest-host`目标端:
```sh
# 复制公钥到dest-host目标端
[root@src-host ~]# ssh-copy-id root@dest-host
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@dest-host's password:   # <--- 此处需要输入目标端root用户密码

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@dest-host'"
and check to make sure that only the key(s) you wanted were added.

# 以上提示公钥添加成功，尝试使用ssh免密登陆远程主机
# 可以看到，能够直接登陆成功，并且可以正常执行目标端命令
[root@src-host ~]# ssh root@dest-host
Last login: Sat Nov 12 05:30:28 2022 from 192.168.56.1
[root@dest-host ~]# hostname
dest-host
[root@dest-host ~]# exit
logout
Connection to dest-host closed.
[root@src-host ~]#
```

完成以上操作后，我们再尝试使用`rsync`命令进行一次同步操作。

```sh
# 此处指定传输到目标端后文件名
[root@src-host ~]# rsync -avP ~/.bashrc root@dest-host:/tmp/.bashrc.nopassword
sending incremental file list
.bashrc
            941 100%    0.00kB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 1,034 bytes  received 35 bytes  2,138.00 bytes/sec
total size is 941  speedup is 0.88
[root@src-host ~]#
```

此时在目标端检查传输过去的文件：
```sh
[root@dest-host ~]# ll /tmp/.bashrc*
-rw-r--r-- 1 root root 941 Nov 10 08:39 /tmp/.bashrc
-rw-r--r-- 1 root root 941 Nov 10 08:39 /tmp/.bashrc.nopassword
[root@dest-host ~]# diff /tmp/.bashrc /tmp/.bashrc.nopassword
[root@dest-host ~]#
```
可以看到，新传输过来的文件`/tmp/.bashrc.nopassword`与之前传输的文件`/tmp/.bashrc`是一模一样的。也就是说，此处免密配置正确。后续就可以直接使用此种方式进行文件同步了。

### 3.4 rsync同步实践

现在我们需求是，我们在源端有可能下载了很多docker镜像，当源端的镜像文件更新后，我们就同步到目标端的docker镜像对应存放的目录文件下，这样可以保持源端和目标端的文件相同。

现在我们查看源湍的镜像列表：
```sh
[root@src-host ~]# docker images
REPOSITORY                                                        TAG        IMAGE ID       CREATED         SIZE
hello-world                                                       latest     feb5d9fea6a5   13 months ago   13.3kB
registry.aliyuncs.com/google_containers/kube-proxy                v1.18.20   27f8b8d51985   17 months ago   117MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.18.20   7d8d2960de69   17 months ago   173MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.18.20   e7c545a60706   17 months ago   162MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.18.20   a05a1a79adaa   17 months ago   96.1MB
registry.aliyuncs.com/google_containers/pause                     3.2        80d28bedfe5d   2 years ago     683kB
registry.aliyuncs.com/google_containers/coredns                   1.6.7      67da37a9a360   2 years ago     43.8MB
registry.aliyuncs.com/google_containers/etcd                      3.4.3-0    303ce5db0e90   3 years ago     288MB
[root@src-host ~]#
```

而目标端对应的docker镜像列表：
```sh
[root@dest-host ~]# docker images
REPOSITORY                                                        TAG        IMAGE ID       CREATED         SIZE
registry.aliyuncs.com/google_containers/kube-proxy                v1.18.20   27f8b8d51985   17 months ago   117MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.18.20   7d8d2960de69   17 months ago   173MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.18.20   a05a1a79adaa   17 months ago   96.1MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.18.20   e7c545a60706   17 months ago   162MB
registry.aliyuncs.com/google_containers/pause                     3.2        80d28bedfe5d   2 years ago     683kB
registry.aliyuncs.com/google_containers/coredns                   1.6.7      67da37a9a360   2 years ago     43.8MB
registry.aliyuncs.com/google_containers/etcd                      3.4.3-0    303ce5db0e90   3 years ago     288MB
[root@dest-host ~]#
```
可以看到，源端比目标端多出一个`hello-world`镜像。

查看源端docker相关信息：
```sh
通过docker info可以知道docker文件存放根目录
[root@src-host ~]# docker info|grep 'Docker Root Dir'
 Docker Root Dir: /var/lib/docker
 
# 查看源端历史运行的容器 
[root@src-host ~]# docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED      STATUS                  PORTS     NAMES
f846e823ace1   hello-world   "/hello"   7 days ago   Exited (0) 7 days ago             clever_shockley
```
docker文件存放根目录为`/var/lib/docker`，并且历史运行过`hello-world`镜像的一个容器。

而此时，我们在目标端同样查看文件根目录和历史运行的容器信息：
```sh
[root@dest-host ~]# docker info|grep 'Docker Root Dir'
 Docker Root Dir: /var/lib/docker
[root@dest-host ~]# docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@dest-host ~]#
```
可以看到，目标端没有运行`hello-world`镜像的容器。

我们就需要同步两边的`/var/lib/docker`目录，使两边的文件保持一致。

在源端执行同步命令：
```sh
# rsync -avP --compress --delete 表示归档模式进行同步，压缩传输，删除目标端多余的文件，并显示传输过程
[root@src-host ~]# rsync -avP --compress --delete /var/lib/docker root@dest-host:/var/lib
sending incremental file list
docker/
docker/buildkit/cache.db
         32,768 100%   30.58MB/s    0:00:00 (xfr#1, ir-chk=1014/1027)
docker/containers/
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/config.v2.json
          2,469 100%    2.35MB/s    0:00:00 (xfr#2, ir-chk=1056/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519-json.log
          2,347 100%    2.24MB/s    0:00:00 (xfr#3, ir-chk=1055/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/hostconfig.json
          1,472 100%    1.40MB/s    0:00:00 (xfr#4, ir-chk=1054/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/hostname
             13 100%   12.70kB/s    0:00:00 (xfr#5, ir-chk=1053/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/hosts
            174 100%  169.92kB/s    0:00:00 (xfr#6, ir-chk=1052/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/resolv.conf
             87 100%   84.96kB/s    0:00:00 (xfr#7, ir-chk=1051/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/resolv.conf.hash
             71 100%   69.34kB/s    0:00:00 (xfr#8, ir-chk=1050/1077)
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/checkpoints/
docker/containers/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/mounts/
docker/image/overlay2/
docker/image/overlay2/repositories.json
          3,191 100%    3.04MB/s    0:00:00 (xfr#9, ir-chk=1046/1077)
docker/image/overlay2/imagedb/content/sha256/
docker/image/overlay2/imagedb/content/sha256/feb5d9fea6a5e9606aa995e879d862b825965ba48de054caab5ef356dc6b3412
          1,469 100%    1.40MB/s    0:00:00 (xfr#10, ir-chk=1002/1085)
docker/image/overlay2/layerdb/mounts/
docker/image/overlay2/layerdb/mounts/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/
docker/image/overlay2/layerdb/mounts/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/init-id
             69 100%   67.38kB/s    0:00:00 (xfr#11, ir-chk=1006/1095)
docker/image/overlay2/layerdb/mounts/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/mount-id
             64 100%   62.50kB/s    0:00:00 (xfr#12, ir-chk=1005/1095)
docker/image/overlay2/layerdb/mounts/f846e823ace1f4dc4c0b74989dd46940ac8b3f9c230fe05f86da419db9f6b519/parent
             71 100%   69.34kB/s    0:00:00 (xfr#13, ir-chk=1004/1095)
docker/image/overlay2/layerdb/sha256/
docker/image/overlay2/layerdb/sha256/e07ee1baac5fae6a26f30cabfe54a36d3402f96afda318fe0a96cec4ca393359/
docker/image/overlay2/layerdb/sha256/e07ee1baac5fae6a26f30cabfe54a36d3402f96afda318fe0a96cec4ca393359/cache-id
             64 100%   31.25kB/s    0:00:00 (xfr#14, ir-chk=1063/1234)
docker/image/overlay2/layerdb/sha256/e07ee1baac5fae6a26f30cabfe54a36d3402f96afda318fe0a96cec4ca393359/diff
             71 100%   34.67kB/s    0:00:00 (xfr#15, ir-chk=1062/1234)
docker/image/overlay2/layerdb/sha256/e07ee1baac5fae6a26f30cabfe54a36d3402f96afda318fe0a96cec4ca393359/size
              5 100%    2.44kB/s    0:00:00 (xfr#16, ir-chk=1061/1234)
docker/image/overlay2/layerdb/sha256/e07ee1baac5fae6a26f30cabfe54a36d3402f96afda318fe0a96cec4ca393359/tar-split.json.gz
            229 100%  111.82kB/s    0:00:00 (xfr#17, ir-chk=1060/1234)
docker/network/files/local-kv.db
         65,536 100%   20.83MB/s    0:00:00 (xfr#18, ir-chk=1044/1234)
docker/overlay2/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/committed
              0 100%    0.00kB/s    0:00:00 (xfr#19, to-chk=70/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/link
             26 100%    0.31kB/s    0:00:00 (xfr#20, to-chk=69/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/lower
             28 100%    0.33kB/s    0:00:00 (xfr#21, to-chk=68/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/.dockerenv
              0 100%    0.00kB/s    0:00:00 (xfr#22, to-chk=65/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/dev/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/dev/console
              0 100%    0.00kB/s    0:00:00 (xfr#23, to-chk=60/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/dev/pts/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/dev/shm/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/etc/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/etc/hostname
              0 100%    0.00kB/s    0:00:00 (xfr#24, to-chk=57/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/etc/hosts
              0 100%    0.00kB/s    0:00:00 (xfr#25, to-chk=56/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/etc/mtab -> /proc/mounts
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/etc/resolv.conf
              0 100%    0.00kB/s    0:00:00 (xfr#26, to-chk=54/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/proc/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff/sys/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/work/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/work/work/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/link
             26 100%    0.30kB/s    0:00:00 (xfr#27, to-chk=52/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/lower
             57 100%    0.66kB/s    0:00:00 (xfr#28, to-chk=51/5315)
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/diff/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/work/
docker/overlay2/cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/work/work/
docker/overlay2/f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/
docker/overlay2/f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/committed
              0 100%    0.00kB/s    0:00:00 (xfr#29, to-chk=27/5315)
docker/overlay2/f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/link
             26 100%    0.30kB/s    0:00:00 (xfr#30, to-chk=26/5315)
docker/overlay2/f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/diff/
docker/overlay2/f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/diff/hello
         13,256 100%  154.11kB/s    0:00:00 (xfr#31, to-chk=24/5315)
docker/overlay2/l/
docker/overlay2/l/FXBSDZMFLKZIIZQ3NSN4CMQ42A -> ../f071bf5e20ad365ccc3e36fde2a2711f7d3f8719087e48737a0d8757f17530fb/diff
docker/overlay2/l/HENM7MD6IPD75SQ2IPPZUEA7Y3 -> ../cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb/diff
docker/overlay2/l/LC3VWEEA5POF4GBCSEJMV7DYJ7 -> ../cdc8d5f7d3acffaae62652f28a1e9707e7530f14429b1ab34c6abd41f29e88cb-init/diff
docker/runtimes/
docker/tmp/
docker/volumes/
docker/volumes/metadata.db
         32,768 100%  380.95kB/s    0:00:00 (xfr#32, to-chk=0/5315)

sent 126,683 bytes  received 2,737 bytes  19,910.77 bytes/sec
total size is 730,241,764  speedup is 5,642.42
[root@src-host ~]#
```

可以看到同步执行完成。

此时，在目标端检查镜像和容器情况：
```sh
# 直接查看时，并没有查看到hello-world镜像
[root@dest-host ~]# docker images
REPOSITORY                                                        TAG        IMAGE ID       CREATED         SIZE
registry.aliyuncs.com/google_containers/kube-proxy                v1.18.20   27f8b8d51985   17 months ago   117MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.18.20   7d8d2960de69   17 months ago   173MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.18.20   a05a1a79adaa   17 months ago   96.1MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.18.20   e7c545a60706   17 months ago   162MB
registry.aliyuncs.com/google_containers/pause                     3.2        80d28bedfe5d   2 years ago     683kB
registry.aliyuncs.com/google_containers/coredns                   1.6.7      67da37a9a360   2 years ago     43.8MB
registry.aliyuncs.com/google_containers/etcd                      3.4.3-0    303ce5db0e90   3 years ago     288MB

# 尝试重启docker服务
[root@dest-host ~]# systemctl restart docker

# 再次查看镜像信息，此时看到了hello-world镜像
[root@dest-host ~]# docker images
REPOSITORY                                                        TAG        IMAGE ID       CREATED         SIZE
hello-world                                                       latest     feb5d9fea6a5   13 months ago   13.3kB
registry.aliyuncs.com/google_containers/kube-proxy                v1.18.20   27f8b8d51985   17 months ago   117MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.18.20   7d8d2960de69   17 months ago   173MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.18.20   e7c545a60706   17 months ago   162MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.18.20   a05a1a79adaa   17 months ago   96.1MB
registry.aliyuncs.com/google_containers/pause                     3.2        80d28bedfe5d   2 years ago     683kB
registry.aliyuncs.com/google_containers/coredns                   1.6.7      67da37a9a360   2 years ago     43.8MB
registry.aliyuncs.com/google_containers/etcd                      3.4.3-0    303ce5db0e90   3 years ago     288MB

# 查看容器信息，可以看到，也有一个hello-world镜像相关的容器
# 容器id,创建时间，状态信息，容器名称都和源端的一模一样
[root@dest-host ~]# docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED      STATUS                  PORTS     NAMES
f846e823ace1   hello-world   "/hello"   7 days ago   Exited (0) 7 days ago             clever_shockley
[root@dest-host ~]#
```

通过查看镜像信息和容器信息，可以看到，数据从源端同步到目标端了，同步到目标端的数据与源端的数据一样！！！

我们随时都有可能下载新的镜像文件，或者创建新的容器，这个时候docker数据都会发生变化，需要自动手动去同步一次，这样就比较麻烦。这时候就需要用inotify工具来监控我们需要同步的文件夹，然后让其自动触发`rsync`同步命令自动同步。

## 4. inotify工具的使用

### 4.1 什么是inotify和inotify-tools

- Inotify是一种强大的、细粒度的、异步文件系统监控机制，它满足各种各样的文件监控需要，可以监控文件系统的访问属性、读写属性、权限属性、删除创建、移动等操作，也就是可以监控文件发生的一切变化。
- inotify-tools包括一个C库和一组命令行工具，可在命令行下提供对文件系统事件的监控。inotify-tools安装后会得到inotifywait和inotifywatch这两条命令。
- inotifywait命令可以用来收集有关文件访问信息。
- inotifywatch命令用于收集关于被监视的文件系统的统计数据，包括每个inotify事件发生多少次。
- Linux内核从2.6.13开始引入了inotify机制。我们使用的是CentOS7操作系统，内核满足要求。如果内核满足要求，则查看系统是否支持inotify。

### 4.2 服务器内核是否支持inotify

```sh
# 查看内核信息
[root@src-host ~]# uname -r
3.10.0-1062.el7.x86_64

# 查看服务器内核是否支持inotify
# 有三个max开头的文件则表示服务器内核支持inotify
[root@src-host ~]# ll /proc/sys/fs/inotify
total 0
-rw-r--r-- 1 root root 0 Nov 12 07:05 max_queued_events
-rw-r--r-- 1 root root 0 Nov 12 07:05 max_user_instances
-rw-r--r-- 1 root root 0 Nov 12 07:05 max_user_watches
[root@src-host ~]# cat /proc/sys/fs/inotify/max_user_watches
8192
[root@src-host ~]#
```

这三个系统参数对应的意义：
- /proc/sys/fs/inotify/max_user_instances 初始化ifd的数量限制
- /proc/sys/fs/inotify/max_queued_events ifd文件队列长度限制
- /proc/sys/fs/inotify/max_user_watches 注册监听目录的数量限制

可以看到默认注册监听目录的数量限制是8192，当我们需要监听的文件非常多时，可能会报以下异常：
```sh
# Failed to watch XXX upper limit on inotify watches reached!
Please increase the amount of inotify watches allowed per user via `/proc/sys/fs/inotify/max_user_watches’.
```
为了保证在服务器重启后，配置仍然生效：
```sh
# 修改配置
[root@src-host ~]# echo 'fs.inotify.max_user_watches = 99999999' >> /etc/sysctl.conf

# 使配置生效
[root@src-host ~]# sysctl -p
fs.inotify.max_user_watches = 99999999

# 再次查看注册监听目录的数量限制
[root@src-host ~]# cat /proc/sys/fs/inotify/max_user_watches
99999999
[root@src-host ~]#
```

可以看到，配置已经生效了。

### 4.3 inotify-tools工具的安装与使用

我们只需要监听源端上面的目录，只需要在源端上面安装`inotify-tools`软件即可。

```sh
[root@src-host ~]# yum install -y inotify-tools
```

安装后，查看inotify相关工具的帮助信息：
```sh
[root@src-host ~]# inotifywait --help
inotifywait 3.14
Wait for a particular event on a file or set of files. 等待文件或文件集上的特定事件。
Usage: inotifywait [ options ] file1 [ file2 ] [ file3 ] [ ... ]
Options:
	-h|--help     	Show this help text. 显示帮助信息
	@<file>       	Exclude the specified file from being watched. 排除指定文件不进行监听
	--exclude <pattern>
	              	Exclude all events on files matching the
	              	extended regular expression <pattern>. 排除匹配正则表达式所有文件的所有事情
	--excludei <pattern>
	              	Like --exclude but case insensitive. 排除文件匹配时大小写不敏感
	-m|--monitor  	Keep listening for events forever.  Without
	              	this option, inotifywait will exit after one
	              	event is received. 持续监听，如果不设置此选项，inotifywait在完成接收一个事件后就会马上退出
	-d|--daemon   	Same as --monitor, except run in the background
	              	logging events to a file specified by --outfile.
	              	Implies --syslog.  守护进程运行
	-r|--recursive	Watch directories recursively. 使用递归形式监视目录
	--fromfile <file>
	              	Read files to watch from <file> or `-' for stdin. 从文件中读取监视文件
	-o|--outfile <file> 
	              	Print events to <file> rather than stdout.  将事件信息输出到文件
	-s|--syslog   	Send errors to syslog rather than stderr. 将异常输出到syslog，而不是标准异常输出
	-q|--quiet    	Print less (only print events).  减少冗余信息，只打印出事件的信息
	-qq           	Print nothing (not even events).  静默模式，不输出任何信息
	--format <fmt>	Print using a specified printf-like format
	              	string; read the man page for more details. 监听到的文件变化的信息
	--timefmt <fmt>	strftime-compatible format string for use with
	              	%T in --format string.  strftime兼容格式字符串，时间格式字符串
	-c|--csv      	Print events in CSV format. 以CSV格式输出事件
	-t|--timeout <seconds>
	              	When listening for a single event, time out after
	              	waiting for an event for <seconds> seconds.
	              	If <seconds> is 0, inotifywait will never time out. 超时时间，单位秒，设置为0时，则不超时
	-e|--event <event1> [ -e|--event <event2> ... ]
		Listen for specific event(s).  If omitted, all events are
		listened for. 监听特定事件。如果省略，则所有事件都要监听。

Exit status:
	0  -  An event you asked to watch for was received.
	1  -  An event you did not ask to watch for was received
	      (usually delete_self or unmount), or some error occurred.
	2  -  The --timeout option was given and no events occurred
	      in the specified interval of time.

Events: 事件
	access		file or directory contents were read 读取文件内容
	modify		file or directory contents were written 修改，文件内容被修改
	attrib		file or directory attributes changed 属性，文件元数据被修改
	close_write	file or directory closed, after being opened in
	           	writeable mode 文件以写模式打开，然后被关闭
	close_nowrite	file or directory closed, after being opened in
	           	read-only mode 文件以只读模式打开，然后被关闭
	close		file or directory closed, regardless of read/write mode 文件被关闭，不论是读/写模式
	open		file or directory opened 文件被打开
	moved_to	file or directory moved to watched directory 文件移动到监听目录
	moved_from	file or directory moved from watched directory 文件从监听目录移出
	move		file or directory moved to or from watched directory 文件被移动
	create		file or directory created within watched directory 在监视的目录中创建文件
	delete		file or directory deleted within watched directory 在监视的目录中删除文件
	delete_self	file or directory was deleted 文件被删除
	unmount		file system containing file or directory unmounted
[root@src-host ~]#
[root@src-host ~]# inotifywatch --help
inotifywatch 3.14
Gather filesystem usage statistics using inotify.
Usage: inotifywatch [ options ] file1 [ file2 ] [ ... ]
Options:
	-h|--help    	Show this help text.
	-v|--verbose 	Be verbose.
	@<file>       	Exclude the specified file from being watched.
	--fromfile <file>
		Read files to watch from <file> or `-' for stdin.
	--exclude <pattern>
		Exclude all events on files matching the extended regular
		expression <pattern>.
	--excludei <pattern>
		Like --exclude but case insensitive.
	-z|--zero
		In the final table of results, output rows and columns even
		if they consist only of zeros (the default is to not output
		these rows and columns).
	-r|--recursive	Watch directories recursively.
	-t|--timeout <seconds>
		Listen only for specified amount of time in seconds; if
		omitted or 0, inotifywatch will execute until receiving an
		interrupt signal.
	-e|--event <event1> [ -e|--event <event2> ... ]
		Listen for specific event(s).  If omitted, all events are
		listened for.
	-a|--ascending <event>
		Sort ascending by a particular event, or `total'.
	-d|--descending <event>
		Sort descending by a particular event, or `total'.

Exit status:
	0  -  Exited normally.
	1  -  Some error occurred.

Events:
	access		file or directory contents were read
	modify		file or directory contents were written
	attrib		file or directory attributes changed
	close_write	file or directory closed, after being opened in
	           	writeable mode
	close_nowrite	file or directory closed, after being opened in
	           	read-only mode
	close		file or directory closed, regardless of read/write mode
	open		file or directory opened
	moved_to	file or directory moved to watched directory
	moved_from	file or directory moved from watched directory
	move		file or directory moved to or from watched directory
	create		file or directory created within watched directory
	delete		file or directory deleted within watched directory
	delete_self	file or directory was deleted
	unmount		file system containing file or directory unmounted
[root@src-host ~]#
```

### 4.4 编写同步脚本

参考 [rsync+ Notify配置解析及步骤详解](https://blog.51cto.com/u_13858192/2159200)编写一个监听同步脚本。

[download file_watch.sh](/scripts/shell/file_watch.sh)
```sh
#!/bin/bash
##################################################
#      Filename: file_watch.sh
#        Author: Zhaohui Mei<mzh.whut@gmail.com>
#   Description: rsync+inotify实现文件监听，并同步到远程目标端
#   Create Time: 2022-11-13 14:45:47
# Last Modified: 2022-11-13 21:46:47
##################################################

# 目标端(备份服务器)主机IP
dest_host="192.168.56.12"
# 源端需要监听并同步的目录
src_dir="/var/lib/docker"
# 目标端存放备份数据的目录
dest_dir="/var/lib"
# 目标端执行数据同步的用户名
user="root"
inotifywait="/usr/bin/inotifywait"

# -m|--monitor 持续监听
# -r|--recursive 递归模式
# -q|--quiet 减少冗余信息，只打印出事件的信息
# --timefmt 设置时间格式
# --format 设置监听到文件变化时的输出格式
# -e|--event 监听的事件
${inotifywait} -mrq --timefmt '%Y%m%d %H:%M:%S' \
    --format '%T %w%f %e' \
    --event modify,delete,create,attrib $src_dir |
    while read -r files; do
        rsync -avzP --delete --timeout=100 "${src_dir}" "${user}"@"${dest_host}":"${dest_dir}"
        echo "${files} was rsynced" >>/tmp/rsync.log 2>&1
    done
```

此时，我们将文件存放在`~/.scripts`目录下，然后启动脚本：

```sh
[root@src-host ~]# cd ～/.scripts/

# 启动脚本，并在后台运行
[root@src-host .scripts]# nohup sh file_watch.sh &
[1] 1728
[root@src-host .scripts]# nohup: ignoring input and appending output to ‘nohup.out’

[root@src-host .scripts]#
```

此时，开启另外一个`src-host`源端的命令行窗口，并进行一些操作：
```sh
# 切换到源端同步目录
[root@src-host ~]# cd /var/lib/docker

# 创建测试文件夹test
[root@src-host docker]# mkdir test

# 创建测试文件a
[root@src-host docker]# echo 'a' > a

# 创建a的软链接
[root@src-host docker]# ln -s a a.link

# 给测试文件a增加写权限
[root@src-host docker]# chmod a+w a

# 删除测试文件a
[root@src-host docker]# rm -f a

# 删除链接文件a.link
[root@src-host docker]# rm -f a.link

# 删除测试目录test
[root@src-host docker]# rm -rf test
```

你可以按以上方式进行测试，测试的过程中，可以打开目标端命令窗口,以及源端监听日志文件`/tmp/rsync.log`的输出，如以下是我操作时，日志的输出：
```sh
[root@src-host .scripts]# tail -f /tmp/rsync.log
20221113 08:44:35 /var/lib/docker/test CREATE,ISDIR was rsynced
20221113 08:45:09 /var/lib/docker/a CREATE was rsynced
20221113 08:45:09 /var/lib/docker/a MODIFY was rsynced
20221113 08:54:01 /var/lib/docker/a.link CREATE was rsynced
20221113 08:55:11 /var/lib/docker/a ATTRIB was rsynced
20221113 08:56:55 /var/lib/docker/a ATTRIB was rsynced
20221113 08:57:47 /var/lib/docker/a DELETE was rsynced
20221113 08:58:04 /var/lib/docker/a.link DELETE was rsynced
20221113 08:59:05 /var/lib/docker/test DELETE,ISDIR was rsynced
```
说明我们的实时文件监听起作用了，当文件发生变化后，自动触发了`rsync`命令进行同步了。

以上说明我们的文件实时监听并同步配置生效了。

但是，我们还可以进行以下优化：
- `file_watch.sh`是通过nohup形式在后台运行的，如果后台程序挂掉了，不会自动重启，会导致同步任务停止，同步异常。
- `file_watch.sh`脚本是只监听了单个目录(及其子目录)，如果有多个目录需要监听的话，此脚本则需要优化。
- 目标端IP，源端目录，目标湍目录，用户等信息直接在脚本中写死了，可以从配置文件读取。

## 5. supervisor管理监听脚本

我们可以使用supervisor来管理`file_watch.sh`脚本，不用我们自己在后台运行该脚本，这些就算`file_watch.sh`脚本在后台运行时挂掉，supervisor也可以自动让其重新运行。

- `supervisor`的使用，此处不详细介绍，可参考 [进程管理工具之Supervisor](../../monitor/supervisor)

我们通过查看源端运行的进程可知，运行脚本时启动了多个进程，如下所示：
```sh
[root@src-host .scripts]# ps -ef|grep --color=always file_watch.sh|grep -v grep
root      1728  1704  0 08:43 pts/0    00:00:00 sh file_watch.sh
root      1730  1728  0 08:43 pts/0    00:00:00 sh file_watch.sh
[root@src-host .scripts]# ps -ef|grep --color=always inotifywait |grep -v grep
root      1729  1728  0 08:43 pts/0    00:00:00 /usr/bin/inotifywait -mrq --timefmt %Y%m%d %H:%M:%S --format %T %w%f %e --event modify,delete,create,attrib /var/lib/docker
```

我们先手动停止这三个进程：
```sh
[root@src-host ~]# kill -9 1728 1729 1730
[root@src-host ~]# ps -ef|grep --color=always file_watch.sh |grep -v grep
[root@src-host ~]# ps -ef|grep --color=always inotifywait |grep -v grep
```
可以看到，进程已经被杀掉了。


因为包含了子进程，我们需要将这些进程做为一个组来管理，这样在supervisor中不至于父进程被停掉了，子进程还在运行，导致同步异常。

因此，我们编写的supervisor配置文件`/etc/supervisord.d/rsync.ini`如下：

```ini
[program:rsync]
command = sh /root/.scripts/file_watch.sh
directory = /root/.scripts
redirect_stderr = true
stdout_logfile = /tmp/rsync.log
stopasgroup = true
killasgroup = true
stopsignal = KILL
```

其中,`stopasgroup = true`和`killasgroup = true`参数表明将停止信号发送到整个进程组，并按进程组方式终止进程，`stopsignal = KILL`表示终止信号是`KILL`。


编写好配置文件后，重新加载supervisor配置文件，然后查看应用状态：
```sh
[root@src-host ~]# supervisorctl reload
Restarted supervisord
[root@src-host ~]# supervisorctl status
rsync                            RUNNING   pid 1871, uptime 0:00:05
[root@src-host ~]# ps -ef|grep --color=always file_watch.sh |grep -v grep
root      1871  1845  0 09:28 ?        00:00:00 sh /root/.scripts/file_watch.sh
root      1873  1871  0 09:28 ?        00:00:00 sh /root/.scripts/file_watch.sh
[root@src-host ~]# ps -ef|grep --color=always inotifywait |grep -v grep
root      1872  1871  0 09:28 ?        00:00:00 /usr/bin/inotifywait -mrq --timefmt %Y%m%d %H:%M:%S --format %T %w%f %e --event modify,delete,create,attrib /var/lib/docker
[root@src-host ~]#
```
此时，可以看到，应用正常启动了，对应的进程与通过`ps`命令查看到的进程id相同。

我们尝试在源端`/var/lib/docker`目录中新建一个目录：
```sh
[root@src-host docker]# mkdir -p test1/test2/test3/
```

此时，查看日志输出，可以看到有新增同步日志：

![](/img/Snipaste_2022-11-13_22-32-43.png)
说明通过supervisor管理的rsync同步应用生效了。

此时，尝试停止rsync应用，看看子进程是否都会停止掉：

```sh
[root@src-host ~]# supervisorctl stop rsync
rsync: stopped
[root@src-host ~]# supervisorctl status
rsync                            STOPPED   Nov 13 09:34 AM
[root@src-host ~]# ps -ef|grep --color=always file_watch.sh |grep -v grep
[root@src-host ~]# ps -ef|grep --color=always inotifywait |grep -v grep
[root@src-host ~]#
```
可以看到，应用停止后，对应的子进程也被杀掉了，查询不到相关进程，说明我们的配置是正确的。

再尝试启动应用，也可以看到，对应子进程也启动了：
```sh
[root@src-host ~]# supervisorctl start rsync
rsync: started
[root@src-host ~]# supervisorctl status rsync
rsync                            RUNNING   pid 1896, uptime 0:00:06
[root@src-host ~]# ps -ef|grep --color=always file_watch.sh |grep -v grep
root      1896  1845  0 09:35 ?        00:00:00 sh /root/.scripts/file_watch.sh
root      1898  1896  0 09:35 ?        00:00:00 sh /root/.scripts/file_watch.sh
[root@src-host ~]# ps -ef|grep --color=always inotifywait |grep -v grep
root      1897  1896  0 09:35 ?        00:00:00 /usr/bin/inotifywait -mrq --timefmt %Y%m%d %H:%M:%S --format %T %w%f %e --event modify,delete,create,attrib /var/lib/docker
[root@src-host ~]#
```

如果此时，在源端删除目录`/var/lib/docker/test1`，则在`/tmp/rsync.log`会有以下日志输出：
```sh
[root@src-host ~]# tail -f /tmp/rsync.log
sending incremental file list
deleting docker/test1/test2/test3/
deleting docker/test1/test2/
deleting docker/test1/
docker/

sent 117,725 bytes  received 925 bytes  237,300.00 bytes/sec
total size is 730,241,764  speedup is 6,154.59
20221113 09:36:43 /var/lib/docker/test1/test2/test3 DELETE,ISDIR was rsynced
sending incremental file list
20221113 09:36:43 /var/lib/docker/test1/test2 DELETE,ISDIR was rsynced

sent 117,726 bytes  received 853 bytes  79,052.67 bytes/sec
total size is 730,241,764  speedup is 6,158.27
sending incremental file list

sent 117,726 bytes  received 853 bytes  237,158.00 bytes/sec
total size is 730,241,764  speedup is 6,158.27
20221113 09:36:43 /var/lib/docker/test1 DELETE,ISDIR was rsynced
```
可见同步应用正常！！！

## 6. 同步脚本优化

针对之前脚本只能同步一个目录，并且参数都是在脚本中直接写死的问题。编写`file_watch_v2.sh`脚本，以及对应的配置文件`file_watch.conf`,另外还有一个工具脚本`utils.sh`。


此处展示`file_watch_v2.sh`脚本内容（注意，不要使用此脚本，请使用最后优化后的脚本）：
```sh
#!/bin/bash
##################################################
#      Filename: file_watch_v2.sh
#        Author: Zhaohui Mei<mzh.whut@gmail.com>
#   Description: rsync+inotify实现文件监听，并同步到远程目标端
#   Create Time: 2022-11-13 14:45:47
# Last Modified: 2022-11-13 21:46:47
##################################################

# 脚本路径
SCRIPT_PATH="$(cd -P "$(dirname "$0")" && pwd)"
if [[ ! -f "${SCRIPT_PATH}/utils.sh" ]]; then
    echo "utils.sh文件不存在，请检查！"
    exit 1
fi
# load the utilities
source "${SCRIPT_PATH}/utils.sh"
# 配置文件
CONFIG_FILE="${SCRIPT_PATH}/file_watch.conf"
# 源端需要监控的目录列表组成的文件
SRC_LIST_FILE="${SCRIPT_PATH}/dir_list.txt"
# 源端监听文件变化的程序
inotifywait="/usr/bin/inotifywait"

# 定义函数
#######################################
# 读取配置文件
get_info() {
    keyword="$1"
    info=$(grep -v '^#' "${CONFIG_FILE}" | grep -v '^$' | grep "^${keyword} " | awk -F '[= ]+' '{print $2}')
    echo "${info}"
}
#######################################

msg_success "Step 1: 检查配置文件正确性"
all_src_dirs=$(grep '^SRC_DIR_' "${CONFIG_FILE}" | awk '{print $1}' | sed 's/SRC_DIR_//g' | sort -n)
all_dest_dirs=$(grep '^DEST_DIR_' "${CONFIG_FILE}" | awk '{print $1}' | sed 's/DEST_DIR_//g' | sort -n)
# 匹配关系数量
if [[ "${all_src_dirs}" != "${all_dest_dirs}" ]]; then
    msg_warn "配置文件${CONFIG_FILE}中源端SRC_DIR与目标端DEST_DIR之间的映射匹配关系异常，请检查！"
    exit 1
fi
all_map_count=$(grep -c '^SRC_DIR_' "${CONFIG_FILE}")
dest_host=$(get_info "DEST_HOST")
msg_info "目标端IP地址: ${dest_host}"
sync_num=$(get_info "SYNC_NUM")
msg_info "同步目录组总数: ${sync_num}"
if [[ "${all_map_count}" -ne "${sync_num}" ]]; then
    msg_warn "配置文件${CONFIG_FILE}中同步的配置信息组数${all_map_count}与SYNC_NUM=${sync_num} 的值不一致，请检查！"
    exit 1
fi
msg_success "Step 1: 检查配置文件正确性 ====> OK!"

msg_success "Step 2: 获取监听文件夹信息"
for num in $(seq "${all_map_count}"); do
    src_dir=$(get_info "SRC_DIR_${num}")
    msg_info "源端需要监听并同步的目录：${src_dir}"
    echo "${src_dir}" >>"${SRC_LIST_FILE}"
done
msg_success "Step 2: 获取监听文件夹信息 ====> OK!"

# 文件夹同步
do_rsync() {
    file="$1"
    for num in $(seq "${all_map_count}"); do
        msg_info "当前正在处理第 ${num} 组文件同步"
        src_dir=$(get_info "SRC_DIR_${num}")
        dest_dir=$(get_info "DEST_DIR_${num}")
        username=$(get_info "USER_${num}")
        if [[ -z "${username}" ]]; then
            msg_warn "未配置目标端执行数据同步的用户名，使用默认用户名root"
            username="root"
        fi
        msg_info "源端需要监听并同步的目录：${src_dir}"
        msg_info "目标端存放备份数据的目录：${dest_dir}"
        msg_info "目标端执行数据同步的用户名：${username}"
        rsync -avzP --delete --timeout=100 "${src_dir}" "${username}"@"${dest_host}":"${dest_dir}"
        echo "${file} was rsynced" >>/tmp/rsync.log 2>&1
    done
}

# 监听目录
inotify_dirs() {
    src_list_file="$1"
    # -m|--monitor 持续监听
    # -r|--recursive 递归模式
    # -q|--quiet 减少冗余信息，只打印出事件的信息
    # --timefmt 设置时间格式
    # --format 设置监听到文件变化时的输出格式
    # -e|--event 监听的事件
    # --fromfile 从文件中写取待监听的文件夹信息，一行一个目录信息
    ${inotifywait} -mrq --timefmt '%Y%m%d %H:%M:%S' \
        --format '%T %w%f %e' \
        --event modify,delete,create,attrib --fromfile "${src_list_file}" |
        while read -r files; do
            # 执行同步操作
            do_rsync "${files}"
        done
}

inotify_dirs "${SRC_LIST_FILE}"

```

[download file_watch.conf](/scripts/shell/file_watch.conf)
对应的配置文件`file_watch.conf`：
```ini
##################################################
#      Filename: file_watch.conf
#        Author: Zhaohui Mei<mzh.whut@gmail.com>
#   Description: rsync+inotify实现文件监听，并同步到远程目标端的配置文件
#   Create Time: 2022-11-14 20:55:06
# Last Modified: 2022-11-14 22:55:06
##################################################

# 目标端(备份服务器)主机IP
DEST_HOST = 192.168.56.12

# 同步目录组总数
SYNC_NUM = 3

###### !!!!!  重要说明  !!!!! #####
# 1. 不同组的同步源端源目录和目标端存储目录都不能相同
# 2. 需要同步的配置信息组的总数应与SYNC_NUM指定的数量保持一致，多出的组信息将会被忽略
# 3. 每组同步的用户默认设置都是`root`
#    如果使用了其他的用户，源端执行用户到目标端对应用户也应配置免密登陆
# 4. 目标端存放备份数据的目录与源端需要监听并同步的目录存在部分差异
#    如果源端和目标端目标最后需要保持一致，配置中目标端目录少最后一级目录
# 5. 配置项值两值不需要带双引号

###### 第 1 组同步配置信息 开始 ######
# 源端需要监听并同步的目录
SRC_DIR_1 = /var/lib/docker
# 目标端存放备份数据的目录
DEST_DIR_1 = /var/lib
# 目标端执行数据同步的用户名
USER_1 = root
###### 第 1 组同步配置信息 结束 ######

###### 第 2 组同步配置信息 开始 ######
# 源端需要监听并同步的目录
SRC_DIR_2 = /etc/supervisord.d
# 目标端存放备份数据的目录
DEST_DIR_2 = /etc
# 目标端执行数据同步的用户名
USER_2 = root
###### 第 2 组同步配置信息 结束 ######

###### 第 3 组同步配置信息 开始 ######
# 源端需要监听并同步的目录
SRC_DIR_3 = /home/ansible/ansible_playbooks
# 目标端存放备份数据的目录
DEST_DIR_3 = /home/ansible
# 目标端执行数据同步的用户名
USER_3 = root
###### 第 3 组同步配置信息 结束 ######

```

修改supervisor的配置：
```sh
[root@src-host ~]# cd /etc/supervisord.d
[root@src-host supervisord.d]# cp rsync.ini rsync_v2.ini
[root@src-host supervisord.d]# mv rsync.ini rsync.ini.bak
```
并修改`rsync_v2.ini`内容如下：
```ini
[program:rsync]
command = sh /root/.scripts/file_watch_v2.sh
directory = /root/.scripts
redirect_stderr = true
stdout_logfile = /tmp/rsync_v2.log
stopasgroup = true
killasgroup = true
stopsignal = KILL
```
此时重新加载supervisor配置:
```sh
[root@src-host ~]# supervisorctl reload
Restarted supervisord
[root@src-host ~]# supervisorctl status
rsync                            RUNNING   pid 3503, uptime 0:00:07
[root@src-host ~]# ps -ef|grep file_watch_v2.sh
root      3503  1718  0 23:02 ?        00:00:00 sh /root/.scripts/file_watch_v2.sh
root      3559  3503  0 23:02 ?        00:00:00 sh /root/.scripts/file_watch_v2.sh
root      3562  1688  0 23:03 pts/0    00:00:00 grep --color=auto file_watch_v2.sh
[root@src-host ~]# ps -ef|grep inotifywait
root      3558  3503  0 23:02 ?        00:00:00 /usr/bin/inotifywait -mrq --timefmt %Y%m%d %H:%M:%S --format %T %w%f %e --event modify,delete,create,attrib --fromfile /root/.scripts/dir_list.txt
root      3564  1688  0 23:03 pts/0    00:00:00 grep --color=auto inotifywait
[root@src-host ~]#
```
可以看到监听程序已经启动。

我们看一下日志：
![](/img/Snipaste_2022-11-14_23-08-54.png)
通过日志可以看到，监听程序可以对每组同步信息中的文件夹进行同步处理！说明优化后的脚本正常可用。当任意一组文件夹中的文件有变化时，会触发所有组同步都进行一次同步操作。

[download file_watch_v2.sh](/scripts/shell/file_watch_v2.sh)
优化后的脚本：
```sh
#!/bin/bash
##################################################
#      Filename: file_watch_v2.sh
#        Author: Zhaohui Mei<mzh.whut@gmail.com>
#   Description: rsync+inotify实现文件监听，并同步到远程目标端
#   Create Time: 2022-11-13 14:45:47
# Last Modified: 2022-11-13 23:46:47
##################################################

# 脚本路径
SCRIPT_PATH="$(cd -P "$(dirname "$0")" && pwd)"
if [[ ! -f "${SCRIPT_PATH}/utils.sh" ]]; then
    echo "utils.sh文件不存在，请检查！"
    exit 1
fi
# load the utilities
source "${SCRIPT_PATH}/utils.sh"
# 配置文件
CONFIG_FILE="${SCRIPT_PATH}/file_watch.conf"
# 源端需要监控的目录列表组成的文件
SRC_LIST_FILE="${SCRIPT_PATH}/dir_list.txt"
# 源端监听文件变化的程序
inotifywait="/usr/bin/inotifywait"

# 定义函数
#######################################
# 读取配置文件
get_info() {
    keyword="$1"
    info=$(grep -v '^#' "${CONFIG_FILE}" | grep -v '^$' | grep "^${keyword} " | awk -F '[= ]+' '{print $2}')
    echo "${info}"
}
#######################################

msg_success "Step 1: 检查配置文件正确性"
all_src_dirs=$(grep '^SRC_DIR_' "${CONFIG_FILE}" | awk '{print $1}' | sed 's/SRC_DIR_//g' | sort -n)
all_dest_dirs=$(grep '^DEST_DIR_' "${CONFIG_FILE}" | awk '{print $1}' | sed 's/DEST_DIR_//g' | sort -n)
# 匹配关系数量
if [[ "${all_src_dirs}" != "${all_dest_dirs}" ]]; then
    msg_warn "配置文件${CONFIG_FILE}中源端SRC_DIR与目标端DEST_DIR之间的映射匹配关系异常，请检查！"
    exit 1
fi
all_map_count=$(grep -c '^SRC_DIR_' "${CONFIG_FILE}")
dest_host=$(get_info "DEST_HOST")
msg_info "目标端IP地址: ${dest_host}"
sync_num=$(get_info "SYNC_NUM")
msg_info "同步目录组总数: ${sync_num}"
if [[ "${all_map_count}" -ne "${sync_num}" ]]; then
    msg_warn "配置文件${CONFIG_FILE}中同步的配置信息组数${all_map_count}与SYNC_NUM=${sync_num} 的值不一致，请检查！"
    exit 1
fi
msg_success "Step 1: 检查配置文件正确性 ====> OK!"

msg_success "Step 2: 获取监听文件夹信息"
true >"${SRC_LIST_FILE}"
for num in $(seq "${all_map_count}"); do
    src_dir=$(get_info "SRC_DIR_${num}")
    msg_info "源端需要监听并同步的目录：${src_dir}"
    echo "${src_dir}" >>"${SRC_LIST_FILE}"
done

msg_success "Step 2: 获取监听文件夹信息 ====> OK!"

# 文件夹同步
do_rsync() {
    file="$1"
    msg_info "监测到文件发生变化：${file}"
    change_dir=$(while read -r line; do echo "${file}" | grep -q "${line}" && echo "${line}"; done <"${SRC_LIST_FILE}")
    msg_info "对应的配置文件源路径:${change_dir}"
    group_num=$(grep -E "SRC_DIR_.*= ${change_dir}" "${CONFIG_FILE}" | awk '{print $1}' | sed 's/SRC_DIR_//g')
    msg_info "当前正在处理第 ${group_num} 组文件同步"
    src_dir=$(get_info "SRC_DIR_${group_num}")
    dest_dir=$(get_info "DEST_DIR_${group_num}")
    username=$(get_info "USER_${group_num}")
    if [[ -z "${username}" ]]; then
        msg_warn "未配置目标端执行数据同步的用户名，使用默认用户名root"
        username="root"
    fi
    msg_info "源端需要监听并同步的目录：${src_dir}"
    msg_info "目标端存放备份数据的目录：${dest_dir}"
    msg_info "目标端执行数据同步的用户名：${username}"
    rsync -avzP --delete --timeout=100 "${src_dir}" "${username}"@"${dest_host}":"${dest_dir}"
    echo "${file} was rsynced" >>/tmp/rsync.log 2>&1

}

# 监听目录
inotify_dirs() {
    src_list_file="$1"
    # -m|--monitor 持续监听
    # -r|--recursive 递归模式
    # -q|--quiet 减少冗余信息，只打印出事件的信息
    # --timefmt 设置时间格式
    # --format 设置监听到文件变化时的输出格式
    # -e|--event 监听的事件
    # --fromfile 从文件中写取待监听的文件夹信息，一行一个目录信息
    ${inotifywait} -mrq --timefmt '%Y%m%d %H:%M:%S' \
        --format '%T %w%f %e' \
        --event modify,delete,create,attrib --fromfile "${src_list_file}" |
        while read -r files; do
            # 执行同步操作
            do_rsync "${files}"
        done
}

inotify_dirs "${SRC_LIST_FILE}"
```
当任意一组文件夹中的文件有变化时，只会触发本组同步进行一次同步操作。



参考：

- rsync命令:[http://lnmp.ailinux.net/rsync](http://lnmp.ailinux.net/rsync)
- the rsync web pages:[https://rsync.samba.org/](https://rsync.samba.org/)
- rsync + notify 实现数据实时同步:[https://blog.csdn.net/weixin_42688499/article/details/124226956](https://blog.csdn.net/weixin_42688499/article/details/124226956)
- 使用inotify-tools监控文件夹或文件的变动 [https://www.codenong.com/cs106251339/](https://www.codenong.com/cs106251339/)
- rsync+ Notify配置解析及步骤详解 [https://blog.51cto.com/u_13858192/2159200](https://blog.51cto.com/u_13858192/2159200)
- rsync用法详细解释 [https://www.cnblogs.com/Mercury-linux/p/11437902.html](https://www.cnblogs.com/Mercury-linux/p/11437902.html)
- 使用supervisorctl stop不会杀死inotifywait [https://www.soinside.com/question/iSmB8faqyuDLRjNHPirTBS](https://www.soinside.com/question/iSmB8faqyuDLRjNHPirTBS)











