---
title: Linux 文件系统
---

本文包含 FHS 目录结构、常见文件系统类型、Inode 解释、硬链接和软链接的使用等内容。

## FHS 目录结构
[浅谈linux中的根文件系统（rootfs的原理和介绍）](https://tldp.org/LDP/sag/html/root-fs.html)

Linux 使用标准的 FHS(Filesystem Hierarchy Standard)目录结构作为其文件系统的基础。FHS的目的是为开发者、管理员和用户提供统一的文件系统结构，以便移植和交互各种软件。

<details>
<summary>FHS(Filesystem Hierarchy Standard)目录结构：</summary>

:::info FHS 常用目录

- /bin目录： 存放基本的可执行命令和二进制文件。
- /sbin目录：存放管理员使用的简单系统命令。
- /dev目录：存放设备文件，如键盘、鼠标、USB、串口、磁盘和其他硬件设备的设备节点文件。
- /etc目录：存放系统的配置文件和脚本，例如网络配置文件、服务启动脚本、密码策略等。
- /home目录：存放用户主目录，每个用户都拥有独立的个人主目录。
- /lib目录：存放系统共享库文件和内核模块文件。
- /mnt目录：作为挂载点，挂载外部设备或特殊文件系统。
- /opt目录：用于存放应用程序和软件中的可选包。
- /proc目录：虚拟文件系统，包含当前正在运行的进程信息、系统状态信息、硬件信息和内核参数等。
- /root目录：超级用户(root)的个人主目录。
- /run目录：虚拟文件系统，存放运行时的系统信息、服务信息和PID文件等。
- /tmp目录：用于存放临时文件，该目录下的文件在系统启动或定期清理时会自动删除。
- /usr目录：存放应用程序、库文件、文档和配置文件等。
- /var目录：存放系统日志、缓存数据、邮件和数据库等动态数据。
:::

:::tip linux 系统中的 /bin,/sbin,/usr/bin,/usr/sbin,/usr/local/bin,/usr/local/sbin 目录的区别
- /bin  
  This directory contains executable programs which are needed in single user mode and to bring the sys‐ tem up or repair it.
- /sbin  
  Like /bin, this directory holds commands needed to boot the system, but which are usually not executed by normal users.
- /usr/bin  
  This is the primary directory for executable programs. Most programs executed by normal users which are not needed for booting or for repairing the system and which are not installed locally should be placed in this directory.
- /usr/sbin  
  This directory contains program binaries for system administration which are not essential for the boot process, for mounting /usr, or for system repair.
- /usr/local/bin  
  Binaries for programs local to the site.
- /usr/local/sbin  
  Locally installed programs for system administration.

- /bin  存放所有用户皆可用的系统程序，系统启动或者系统修复时可用（在没有挂载 /usr 目录时就可以使用）
- /sbin 存放超级用户才能使用的系统程序
- /usr/bin 存放所有用户都可用的应用程序
- /usr/sbin 存放超级用户才能使用的应用程序 
- /usr/local/bin 存放所有用户都可用的与本地机器无关的程序
- /usr/local/sbin 存放超级用户才能使用的与本地机器无关的程序
:::

</details>

:::tip
首先注意 usr 指 Unix System Resource，而不是 User
然后通常 /usr/bin 下面的都是系统预装的可执行程序，会随着系统升级而改变。而 /usr/local/bin 目录是给用户放置自己的可执行程序的地方，推荐放在这里，不会因系统升级而被同名文件覆盖。
:::


## Linux中常见的文件系统类型
- **Ext文件系统**  
  Ext文件系统是Linux系统中最常用的文件系统类型之一，最新的版本是Ext4。
- **XFS文件系统**  
  XFS文件系统是一个高性能的文件系统，为大容量文件系统而设计。对扩缩容支持不友好。
- **Btrfs文件系统**  
  Btrfs是一个高级文件系统，带有诸多现代特性，如Cow、快照、压缩、避免重复数据等。另外，它还配备了一个树和子卷系统，作为Linux内核的一部分开发。
- **F2FS文件系统**  
  F2FS是一个为闪存硬件设计的文件系统,在SSD设备上可以提供高性能。
- **ZFS文件系统**  
  ZFS文件系统是由Sun Microsystems(现已被Oracle收购)设计的一种类Unix文件系统，特性与 Btrfs 相似，但 ZFS 的初始设计目标是针对大型存储系统(如NAS或SAN)，致力于数据可靠性和数据完整性保护以及处理海量数据。因此，ZFS具有许多高级存储管理功能，如自动热备份、RAID-Z、数据镜像等。  
  由于ZFS在Linux中的实现不是由Linux社区直接负责，因此在Linux内核中并没有ZFS的代码或支持，需要额外安装ZFS驱动程序和用户空间工具，才能使用其功能。虽然ZFS文件系统在Linux上的使用非常流行，但在某些情况下，可能会存在兼容性或其他因素的问题。在使用ZFS时，建议仔细评估其是否适合自己的环境，并遵循开发者的最佳实践。

## 文件元数据
我们可以通过 `ls -il --full-time` 来查看文件的 inode 编号、时间和元数据信息：
```bash
❯ ls -il --full-time ./docusaurus.config.js
690803    -rw-r--r--  1                       admin admin  11588     2023-05-09 18:55:17.131562194 +0800   ./docusaurus.config.js
Inode编号  文件权限类型  链接到此inode的文件名数量  owner group  体积byte   最后修改日期                            文件名
```
在上述示例中**文件权限类型的第一个字符**代表文件是目录、文件还是或连接等，如下：
- [d] 代表目录
- [-] 代表**常规文件**
- [|] 代表软链接
- [b] 代表块设备，如磁盘 
- [c] 代表传行端口设备，如鼠标键盘 `ls -l /dev/input` ，你可以查看具体设备的输出 `cat /dev/input/by-id/DEVICE_NAME`
- [s] 代表 socket 文件，最能体现"一切皆文件"设计哲学。如 `sudo ls -l /var/run/docker.sock`

**文件权限类型的剩余部分**代表权限，三个为一组，均为[rwx]。分别代表读(read)、写(write)、执行(execute)

:::caution
如果一个用户没有权限执行某个目录，则该用户无法进入该目录，也无法列出其内容。
:::

## inode  简介
inode 是 Linux 文件系统中的重要概念，每个文件或目录都对应着一个 inode，在操作系统读取磁盘时，会一次性连续读取多个扇区(Sector)所组成的一个 "块"(Block)从而提高读取效率。文件的数据都被存储在 "块" 中，而文件的元信息，如文件的创建者、创建日期、大小等，被储存在文件系统的 "索引节点"(inode)中。

:::info扇区(Sector)和块(Block)
- 扇区(Sector)是**磁盘读写操作的最小单位**。每个物理扇区都有其对应的地址，可以通过扇区地址来对磁盘进行读写操作。
- 块(Block)通常是**文件系统操作的最小单位**。文件系统通常将若干扇区作为一个块(块的大小因文件系统而异)，以便更高效地读写数据。
:::

文件系统中的 inode 是有限的资源，如果 inode 用完了，文件系统就无法存储新的文件了，尽管磁盘空间还有剩余。因此，当创建大量小文件时，inode 也需要考虑是否会成为瓶颈。

一般来说每个 inode 节点的大小，一般是 128 字节或 256 字节。inode 节点的总数，一般是每 1KB 或每 2KB 就设置一个 inode。假定在一块 1GB 的硬盘中，每个 inode 节点的大小为 128 字节，每1KB就设置一个 inode，那么 inode table 的大小就会达到 128MB，占整块硬盘的 12.8%。

### 查看 inode 信息

在现代的文件系统中，很多都采用了自动分配 inode 的方式来管理磁盘空间。这种文件系统被称为动态 inode 分配文件系统(Dynamic Inode Allocation File System)不需要手动设置 inode 数量。如 XFS、Btrfs 等。

- 对于 EXT 文件系统在格式化时可以手动给定 inode 数量： `mkfs.ext4 -N 200000000 /dev/sdx`。

- 查看每个硬盘分区的 inode 总数和已经使用的数量，可以使用 `df -i` 命令，对于 EXT 文件系统可以使用 dumpe2fs 工具来查询文件系统的属性和统计信息，包括磁盘空间占用、inode使用、块使用和文件系统特征。如查看每个 inode 节点的大小使用 `sudo dumpe2fs -h /dev/hda | grep "Inode size"` 。

- 还可以用 stat 命令，查看某个文件的 inode 信息：

  ```bash
  ❯ stat newfile.txt
    File: newfile.txt
    Size: 0               Blocks: 0          IO Block: 4096   regular empty file
  Device: 0,41    Inode: 21312       Links: 1
  Access: (0644/-rw-r--r--)  Uid: ( 1000/   admin)   Gid: ( 1000/   admin)
  Access: 2023-05-13 13:25:50.966139225 +0800  #访问时间
  Modify: 2023-05-13 13:25:50.966139225 +0800  #修改时间
  Change: 2023-05-13 13:26:02.975684340 +0800  #变更时间
  Birth: 2023-05-13 13:25:50.966139225 +0800  #创建时间
  ```

  :::info
  - Access: 记录了文件最近一次被访问的时间，无论是读取还是执行都会影响它的值，通常称为 atime 。
  - Modify: 文件最后被修改的时间，即最后一次写入或修改文件的时间，通常称为 mtime 。
  - Change: 记录的是文件的 inode 状态最后一次改变的时间，包括修改文件元数据(如权限信息、所有权、硬链接数等)，通常称为 ctime 。
  可以利用 `touch` 指令进行文件的时间修改,例如:
    - 使用 `touch -a newfile.txt`命令则可以将文件的访问时间(atime)改为当前时间。
    - 使用 `touch -m newfile.txt` 命令可以将文件的修改时间(mtime)改为当前时间，  
    但是，如果您想要更改文件的 ctime 时间戳，则无法直接使用 `touch` 命令，因为 ctime 是文件状态的最后改变时间戳，只有当您执行文件状态相关操作时才会被更新，例如执行 chmod，chown 等命令。
  :::

## 硬链接简介

Unix/Linux 系统内部不使用文件名，而使用 inode 编号来操作文件。用户打开文件时，系统会首先找到这个文件名对应的 inode 号码；其次通过 inode 号码，获取 inode 信息；最后根据 inode 信息，找到文件数据所在的 block，读出数据。

:::tip
目录(directory)也是一种文件。打开目录，实际上就是打开目录文件。

目录文件由两部分组成，目录文件内容包含文件/目录名，以及该文件/目录名对应的 inode 编号。
:::

Unix/Linux 系统中创建文件时，会自动创建一个文件名指向文件的 inode 编号，这就是 `链接到此 inode 的文件名数量` 为 1 的原因：

```bash
❯ ls -il --full-time ./docusaurus.config.js
690803    -rw-r--r--  1                       admin admin  11588     2023-05-09 18:55:17.131562194 +0800   ./docusaurus.config.js
Inode编号  文件权限类型  链接到此inode的文件名数量  owner group  体积byte   最后修改日期                            文件名
```

**Unix/Linux系统允许，我们手动创建多个文件名指向同一个 inode 编号，称之为硬链接。** 这意味着，可以用不同的文件名访问同样的内容；对文件内容进行修改，会影响到所有文件名。但是，删除一个文件名，不影响另一个文件名的访问，只有当最后一个硬链接被删除时，inode 对应磁盘 blok 中的数据才会被标记删除。

:::caution
硬链接只用于**常规文件**，不能用使用 ln 创建指向目录或者特殊结文件的硬链接。[linux为什么不能硬链接目录？](https://www.zhihu.com/question/50223526)

如果你需要为目录创建一个完全独立的副本，请使用 `mount --bind`。如果你只是需要一个指向原始目录的别名，请使用软连接。

硬链接只能在**同一个文件系统**中使用。如果你尝试在不同的挂载点之间创建硬链接，那么你会得到一个“交叉设备链接不允许”的错误。
:::

### 使用硬链接
1. 创建硬链接：

```bash
ln 源文件 目标文件
```
创建硬链接后，源文件与目标文件会指向相同的 inode 物理文件。inode 信息中有一项叫做"链接数"，记录指向该 inode 的文件名总数，这时就会增加 1。

反过来，删除一个文件名，就会使得 inode 节点中的"链接数"减1。当这个值减到0，表明没有文件名指向这个inode，系统就会回收这个 inode 号码，以及其所对应 block 区域。

:::info
相同的链接数、访问权限、用户和组的所有权、时间戳、以及文件内容。
使用其中任意硬链接修改其中任何信息，指向同一文件的其他硬链接也会显示新的信息。这是因为每个硬链接都指向存储设备上的同一数据。
:::

2. 查看 inode 硬链接数量

可以使用 find 命令查找文件的所有硬链接，输入以下命令：
```bash
find / -samefile 文件名
find ./* -inum inode号
```

如果你想知道两个文件是否为彼此的硬链接 `ls -i` 列出文件的 inode 编号。如果文件位于同一文件系统上，并且他们的 inode 相同，那么这两个文件就是指向同一数据的硬链接。

```bash
❯ touch newfile.txt
❯ ll
-rw-r--r-- 1 admin admin     0  5月13日 13:02 newfile.txt
❯ ln newfile.txt /tmp/newfile_hard_link.txt
❯ ll -i
21257 -rw-r--r-- 2 admin admin     0  5月13日 13:02 newfile.txt
21257 -rw-r--r-- 2 admin admin     0  5月13日 13:02 newfile_hard_link.txt
❯ rm -rf newfile.txt
❯ ll -i
21257 -rw-r--r-- 1 admin admin      0  5月13日 13:02 newfile_hard_link.txt
```  

### 特殊硬链接

在 Linux 中"."和".."是一对特殊的链接，分别代表当前目录和代表当前目录的父目录。

创建目录时，默认会生成两个目录项："."和".."。前者是当前目录的"硬链接"；后者是同于父目录的"硬链接"。所以，任何一个目录的"硬链接"总数，总是等于2加上它的子目录总数(含隐藏目录)。

```bash
$ mkdir -p  demo/dir
$ ls -ild demo/
48562 drwxr-xr-x 3 amdin amdin 4096 May 25 14:48 demo/
```

## 软链接简介

软链接是一种特殊的文件，它的内容是另一个文件的路径，而不是实际的数据。

当打开软链接时，系统会自动将你导向它所链接的文件。如果删除了被链接的文件，软链接将无法正常工作，因为它依赖于被链接的文件的存在。

硬链接不同的是，软链接并不与被链接的文件共享 inode 号码，因此被链接的文件的链接数不会改变。

:::caution
- `cd` 将使用软链名称为工作目录，`cd -P` 以实际目录名称作为当前工作目录。
- 与硬链接不同，软链接可以链接到不同的文件系统上的文件，并且可以链接到除常规文件外的其他类型文件。
- 要注意，当你删除软链接所指向的原始文件并创建一个新文件时，软链接会自动指向新文件，而不是指向已经删除的原始文件。
:::

### 软连接的使用

1. 创建软连接

```bash
ln -s 源文件或目录 目标文件或目录
```
软链接就是再创建一个独立的文件，而这个文件会让数据的读取指向它连接的那个文件的文件名。

2. 查找软连接

你可以使用 ls 命令的 -l 选项来列出目录中的文件，并查看文件的属性，软链接的属性会以 l 开头，例如：

```bash
$ ls -l /path/to/directory
lrwxr-xr-x  1 user  user  11 May 25 14:30 softlink -> targetfile
```

或者使用 find 命令的 -type 选项 查找软链接，例如：

```bash
find /path/to/directory -type l -name softlink
```

## inode的特殊作用

由于inode号码与文件名分离，这种机制导致了一些Unix/Linux系统特有的现象。 

1. 有时，文件名包含特殊字符，无法正常删除。这时，直接删除 inode 节点，就能起到删除文件的作用：`find ./* -inum inode号 -delete`。
2. 移动文件或重命名文件，只是改变文件名，不影响 inode 号码。
3. 打开一个文件以后，系统就以 inode 号码来识别这个文件，不再考虑文件名。因此，通常来说，系统无法从inode号码得知文件名。
  - 比如 docker 官方推荐挂载文件夹而不是文件，因为挂载操作会通过文件的 inode 号将数据挂载到容器内，当挂载文件后使用用 vi 修改了文件则会发现，容器内文件没有更新，这是因为 vi 会创建一个新的 inode 文件，当挂在文件时候你想更新其内容请使用 `echo` 修改可以生效
  - 此特性可使得软件更新变得简单，可以在不关闭软件的情况下进行更新，不需要重启。因为系统通过 inode 号码，识别运行中的文件，不通过文件名。更新的时候，新版文件以同样的文件名，生成一个新的 inode，不会影响到运行中的文件。等到下一次运行这个软件的时候，文件名就自动指向新版文件，旧版文件的inode则被回收。
  - 此特性还会导致删除运行中进程的日志后空间不释放现象：  
    在 Linux 或者 Unix 系统中，直接手动删除文件将会从文件系统的目录结构上解除该文件的链接(unlink)，然而如果文件被删除时仍然有一个进程正在使用它，那么该进程仍然可以读取此文件，磁盘空间也会一直被占用。  
    因此如果因为日志等文件不断增长导致空间告急，直接删除这些日志文件是没有用的！  
    正确的操作是使用 echo 等命令清空文件：
    ```bash
    # 直接清空日志文件(文件将仅包含一个换行符)
    echo "" > /path/xxx.log

    # 只保留最新的 10000 行日志
    tail -n 10000 /path/xxx.log > /path/xxx_tail.log
    cat /path/xxx_tail.log > /path/xxx.log
    ```
    手动删除文件后的补救办法：
      手动删除文件后，通过 `df -h` 会发现磁盘空间没有变化，但是使用 `sudo du -sh /*` 却可以看到文件夹变小了。
    这时使用如下命令，就能查找到仍然未关闭的文件描述符，以及对应的进程 id:
    ```shell
    lsof | grep delete
    ```
    解决方法：
    - 最简单有效的方法，就是关闭或者重启正在占用文件的进程。但是可能会造成中断，需要在搞清楚影响后再确认何时进行操作。
    - 对于日志文件，在紧急情况下也有更简单的方法：`echo "" > /proc/<pid>/fd/<fd>` 直接通过 `/proc` 清空仍然被占用的文件。之后再另找时间重启这个进程。
    将命令中的 `<pid>` 替换为占用日志文件的进程 ID，`<fd>` 替换为文件描述符。  
    再次使用 lsof 命令或 fuser 命令查看该日志文件，如果已经没有进程占用，说明该文件已经被清空。  
    再根据实际情况，可以选择重启相关进程或清除该日志文件。  
    注意，该方法只适用于日志文件，其他文件不可以使用。此外，清空文件后可能会导致日志信息的丢失，因此应谨慎使用。同时，建议在清空文件前先备份文件，以避免重要数据的丢失。

## 参考文章

- http://www.ruanyifeng.com/blog/2011/12/inode.html