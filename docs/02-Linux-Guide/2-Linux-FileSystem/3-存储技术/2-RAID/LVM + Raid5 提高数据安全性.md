有两种方式：

1.  先对多个盘做 raid5，再用 raid 盘做 VG ，最后创建LV
2.  先对多个盘做 VG ，先创建 raid5 类型的 LV

### 第一种方法

创建 raid5 盘

```
$ mdadm -Cv /dev/md0 -a yes -n 3 -x 1 -l 5 /dev/sd{ c,d,e,f }
```

-   `-C`：创建 /dev/md0 的 Raid 设备
-   `-a`：采用标准格式建立磁阵列
-   `-n`：指定工作设备数
-   `-x`：指定空闲设备数，即热备盘
-   `-l`：使用 raid 级别，5 表示使用 raid5

查看 raid 状态

```
$ mdadm -D /dev/md1
$ cat /proc/mdstat
```

### 第二种方法

基于 lvm 创建 raid5

```
$ lvcreate --type raid5 -i 3 -L 1G -n lv1 wbm-vg
```

-   `-i`：指定条带数
-   `-L`：VG 大小
-   `-n`：lv 的名字

做RAID5必须要3块以上的硬盘，其使用率是N-1的存储空间，1 表示冗余盘，用来存储奇偶校验码。

以一台机器为例，上面有5个hdd盘，-i 表示用几个盘来做条带，存储的全量数据。i 必须至少为 3。

-   \-i 4 ，就是4个盘存数据，剩余一个盘存校验码。
-   \-i 5，命令会报错，会创建不了。

## 如何模拟掉盘？

使用如下这条命令可以模拟掉盘

```
# sd? 换成具体的硬盘标识
echo 1 > /sys/block/sd?/device/delete
```

执行完成后，lsblk 就看不到这块盘了。

但是这种应该是在软件层面屏蔽掉该盘，并不是真正的禁止掉数据的读写。

下面做个实验可以验证这一猜想

先创建普通的两个 lv，每个 lv 占用一个盘。

1.  往第一个lv里写入数据后，不取消挂载，模拟掉盘后，**仍然可以读写数据。**
2.  往第二个lv里写入数据后，取消挂载，模拟掉盘，无法再挂载。

意思是，如果磁盘仍然在使用中，这种模拟掉盘的方式并不会影响读写，但如果这块盘取消挂载后，再挂就挂载不上了。

如果这块盘是虚拟机在使用，那么模拟掉盘，不影响虚拟机的正常使用，但如果虚拟机发生重启了？那就没办法再用了。


## 参考阅读

-   [Linux RAID配置（使用mdadm命令）教程](https://link.zhihu.com/?target=http%3A//c.biancheng.net/view/928.html)
-   [Linux中RAID5和LVM的组合使用](https://link.zhihu.com/?target=https%3A//blog.csdn.net/kang19970201/article/details/83621438)
-   [Red Hat：逻辑卷管理](https://link.zhihu.com/?target=https%3A//access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/logical_volume_manager_administration/lv)