overlay机制是一种类似于联合文件系统的技术，它允许用户在不修改OpenWrt根文件系统的情况下添加、修改或删除文件。该机制使用SquashFS文件系统作为只读根文件系统，在运行时将可写的overlay文件系统叠加在其上面。

要手动实现overlay机制，您需要创建一个可写的overlay文件系统，并将其与只读的SquashFS文件系统叠加。具体步骤如下：


1.  挂载ext4文件系统到挂载点：

```
   mount /dev/sda1 /mnt/overlay
```

1.  将SquashFS文件系统和overlay文件系统叠加起来：

```
   mount -t overlay overlay -o lowerdir=/,upperdir=/mnt/overlay,workdir=/mnt/overlay/work /mnt/root
```

其中，`lowerdir`指定只读的SquashFS文件系统的挂载点，`upperdir`指定可写的overlay文件系统的挂载点，`workdir`是overlay文件系统的工作目录。

现在，您可以在overlay文件系统中添加、修改或删除文件，而不会影响只读的SquashFS文件系统。重启后，您的更改将保留在overlay文件系统中。




1.  创建一个目录作为只读文件系统的挂载点：

```
   mkdir /mnt/root
```

1.  挂载只读文件系统到挂载点：

```
   mount -t squashfs /dev/sda1 /mnt/root
```

1.  创建一个目录作为overlay文件系统的挂载点：

```
   mkdir /mnt/overlay
```

1.  将overlayfs内核模块加载到系统中：

```
   modprobe overlay
```

1.  将SquashFS文件系统和overlay文件系统叠加起来：

```
   mount -t overlay overlay -o lowerdir=/mnt/root,upperdir=/mnt/overlay,workdir=/mnt/overlay/work /mnt/merged
```

其中，`lowerdir`指定只读的SquashFS文件系统的挂载点，`upperdir`指定可写的overlay文件系统的挂载点，`workdir`是overlay文件系统的工作目录，`/mnt/merged`是叠加后的文件系统挂载点。

现在，您可以在overlay文件系统中添加、修改或删除文件，而不会影响只读的SquashFS文件系统。重启后，您的更改将保留在overlay文件系统中。



docker 的overlay什么是也是这个

在Docker中，overlay使用了类似于OpenWrt的叠加文件系统技术，但使用了更加先进的overlay2驱动程序。overlay2使用两个层来创建文件系统：一个只读层和一个可写层。只读层通常包括Docker镜像文件，而可写层则包括容器中添加、修改或删除的文件。这种方法使得多个容器可以共享相同的镜像，同时各自维护自己的文件系统。

与OpenWrt中手动实现overlay机制略有不同，在Docker中，overlay驱动程序是自动配置的，您只需要使用`docker run`命令启动容器时指定使用overlay驱动程序即可，例如：

```
docker run --rm --name mycontainer --mount type=overlay,source=myoverlay,target=/app alpine
```

其中，`myoverlay`是可写层的挂载点，`/app`是容器中的应用程序目录。使用这个命令启动容器后，您可以在`myoverlay`目录中添加、修改或删除文件，这些更改将保存在可写层中，而不会影响只读层中的文件。

宋

如何手动实现docker的overlay

要手动实现Docker的overlay，您需要遵循以下步骤：

1.  创建一个只读的文件系统作为底层文件系统。这通常是一个Docker镜像文件，它包含了您要运行的应用程序和依赖项。
    
2.  创建一个可写层，作为修改底层文件系统的地方。这通常是一个空目录。
    

```
   mkdir /mnt/overlay
```

1.  使用overlayfs内核模块创建overlay文件系统：

```
   mount -t overlay overlay -o lowerdir=/path/to/lower,upperdir=/mnt/overlay,workdir=/mnt/overlay/work /mnt/merged
```

其中，`/path/to/lower`是只读的底层文件系统的挂载点，`/mnt/overlay`是可写的overlay层的挂载点，`/mnt/overlay/work`是overlay文件系统的工作目录，`/mnt/merged`是叠加后的文件系统挂载点。

1.  将容器中的应用程序和依赖项安装到可写层中，以便在容器中运行它们。
    
2.  使用chroot命令进入overlay文件系统，并启动应用程序。
    
3.  停止应用程序并退出chroot环境。
    
4.  卸载overlay文件系统：
    

```
   umount /mnt/merged
```

现在，您已经手动实现了Docker的overlay文件系统。请注意，这只是一个演示，Docker的overlay实现方式可能略有不同。使用Docker时，您不需要手动创建和管理overlay文件系统，Docker会自动处理这些操作。



https://blog.px.dev/container-filesystems/
https://docs.docker.com/storage/storagedriver/
https://docs.docker.com/storage/storagedriver/overlayfs-driver/

!!! https://blogs.cisco.com/developer/373-containerimages-03
https://blog.opskumu.com/docker-overlayfs.html
https://www.cnblogs.com/rincloud/p/16242556.html
https://github.com/g0dA/linuxStack/blob/master/%E5%AE%B9%E5%99%A8%E4%B8%8B%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E7%9A%84%E5%AE%9E%E7%8E%B0.md
https://www.cnblogs.com/FengZeng666/p/14173906.html

https://cloud.tencent.com/developer/article/1458860
https://zhuanlan.zhihu.com/p/374924046
https://www.fsl.cs.sunysb.edu/docs/sipek-ols2006/index.html
https://www.geeksforgeeks.org/how-to-transparently-overlaid-two-directories-using-unionfs-in-linux/
https://cloud.tencent.com/developer/article/1769020
https://juejin.cn/post/7112352737051803684