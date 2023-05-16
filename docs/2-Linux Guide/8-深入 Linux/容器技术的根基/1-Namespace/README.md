---
title: Namespace
---

Docker使用了Union文件系统技术，具体来说，Docker默认使用的是aufs（Another Union File System）文件系统，它是一种轻量级的联合文件系统，可以将多个文件系统挂载到同一个目录下，形成一个虚拟文件系统。这使得Docker可以通过在一个基础镜像上叠加多个层来构建容器镜像，从而实现镜像的高效复用。除了aufs，Docker还支持其他的Union文件系统，如OverlayFS、btrfs等。



Docker容器中的进程与宿主机器的进程一样，也是通过系统调用来访问文件系统的。但是Docker容器与宿主机器之间的文件系统是隔离的，因此容器内的进程只能访问容器内部的文件系统，不能直接访问宿主机器的文件系统。


为了实现容器与宿主机器之间的文件系统隔离，Docker使用了类似chroot的技术，称之为容器的rootfs（root file system）。每个Docker容器都有自己的rootfs，它是从Docker镜像中提取出来的一个只读文件系统。当Docker容器启动时，Docker会将rootfs挂载到容器的根目录下，从而使得容器内的进程只能访问容器的rootfs中的文件系统。同时，Docker还会为每个容器创建一个写时复制（Copy-on-Write）的文件系统，在容器内部的进程对文件进行修改时，会将修改写入到该文件系统中，而不会影响到宿主机器或其他容器的文件系统。




与chroot不同的是，chroot是一种操作系统级别的隔离技术，它可以将进程的根目录改变为指定的目录，从而限制进程只能访问该目录及其子目录下的文件系统。而进程读取文件系统时，不需要使用chroot技术，因为操作系统已经为进程提供了系统调用和文件描述符等接口，可以直接访问文件系统中的文件和目录。










在新的命名空间中挂载一个新的根文件系统有多种方式，下面列举其中两种方案：



使用chroot命令

使用chroot命令可以将当前进程的根目录更改为指定的目录，创建一个新的根文件系统。例如，以下命令将当前进程的根目录更改为新的根目录：

```bash
sudo chroot /path/to/new/rootfs /bin/bash
```
这将创建一个新的命名空间，其中的根目录为 /path/to/new/rootfs，同时启动一个新的bash进程。



使用unshare命令

使用unshare命令可以创建一个新的命名空间，其中包含一个隔离的根文件系统。例如，以下命令将创建一个新的命名空间，并使用指定的根文件系统：

```bash
sudo unshare --mount-proc=/path/to/new/rootfs/proc --mount /path/to/new/rootfs /bin/bash
```
这将创建一个新的命名空间，并使用指定的根文件系统。在这个命名空间中，/proc目录将被挂载到指定的位置/path/to/new/rootfs/proc。同时启动一个新的bash进程。



Docker使用rootfs隔离文件系统来实现容器的文件系统隔离。在Docker中，每个容器都有自己的根文件系统，即一个只读的基础镜像层和一个可写的容器层。这两个层次结构被组合在一起，形成完整的文件系统。Docker使用了Linux内核的Union File System技术来实现这种文件系统层次结构。具体地，Docker使用了aufs、overlayfs、btrfs等文件系统来实现Union File System。这些文件系统允许将多个文件系统层次结构合并成一个虚拟的文件系统，同时保留了原有文件系统的特性。这样，不同容器之间的文件系统就能够互相隔离，即使它们共享相同的基础镜像。