---

title:  Systemd进阶使用

categories:
  - Linux基础命令
series: 
  - Systemd
lastmod: '2021-03-17'

featuredImage: 
authors: songjinfeng
draft: false
toc: true

---

- Cgroup 控制组
  - Slice
- dbus
- Service units
- Socket units
- Timer units



## 简介

**systemctl命令** 是系统服务管理器指令，它实际上将 service 和 chkconfig 这两个命令组合到一起。

| 任务                 | 旧指令                        | 新指令                                                       |
| -------------------- | ----------------------------- | ------------------------------------------------------------ |
| 使某服务自动启动     | chkconfig --level 3 httpd on  | systemctl enable httpd.service                               |
| 使某服务不自动启动   | chkconfig --level 3 httpd off | systemctl disable httpd.service                              |
| 检查服务状态         | service httpd status          | systemctl status httpd.service （服务详细信息） systemctl is-active httpd.service （仅显示是否 Active) |
| 显示所有已启动的服务 | chkconfig --list              | systemctl list-units --type=service                          |
| 启动服务             | service httpd start           | systemctl start httpd.service                                |
| 停止服务             | service httpd stop            | systemctl stop httpd.service                                 |
| 重启服务             | service httpd restart         | systemctl restart httpd.service                              |
| 重载服务             | service httpd reload          | systemctl reload httpd.service                               |

## 目录优先级

systemd的使用大幅提高了系统服务的运行效率, 而unit的文件位置一般主要有三个目录：
 `/etc/systemd/system`
 `/run/systemd/system`
 `/lib/systemd/system`
 这三个目录的配置文件优先级依次从高到低，如果同一选项三个地方都配置了，优先级高的会覆盖优先级低的。

系统安装时，默认会将unit文件放在/lib/systemd/system目录。如果我们想要修改系统默认的配置，比如nginx.service，一般有两种方法：

1）在/etc/systemd/system目录下创建nginx.service文件，里面写上我们自己的配置。
 2）在/etc/systemd/system下面创建nginx.service.d目录，在这个目录里面新建任何以.conf结尾的文件，然后写入我们自己的配置。推荐这种做法。
 /run/systemd/system这个目录一般是进程在运行时动态创建unit文件的目录，一般很少修改，除非是修改程序运行时的一些参数时，即Session级别的，才在这里做修改。

参考：

- [https://unix.stackexchange.com/questions/206315/whats-the-difference-between-usr-lib-systemd-system-and-etc-systemd-system](https://links.jianshu.com/go?to=https%3A%2F%2Funix.stackexchange.com%2Fquestions%2F206315%2Fwhats-the-difference-between-usr-lib-systemd-system-and-etc-systemd-system)
- [https://wiki.archlinux.org/index.php/Systemd](https://links.jianshu.com/go?to=https%3A%2F%2Fwiki.archlinux.org%2Findex.php%2FSystemd)

## 常用命令

查看服务的依赖关系：

```css
[root@localhost ~]# systemctl list-dependencies apache
```

查看当前运行级别：

```csharp
[root@localhost ~]# systemctl list-units --type target
```

## "systemctl mask"和"systemctl disable"

systemctl mask和systemctl disable的区别一般很难注意到，因为我大部分时候只会使用systemctl disable，并不会用到systemctl mask。在一次遇到问题的时候，需要使用systemctl mask来禁用服务，下边具体说明。

## **systemctl enable的作用**
我们知道，在系统中安装了某个服务以后，需要将该服务设置为开机自启，那么一般会执行systemctl enable xxx，这个时候会发现shell中会输出两行提示，一般类似如下：

    [root@NameNode01 system]# systemctl enable NetworkManager 
    Created symlink from /etc/systemd/system/multi-user.target.wants/NetworkManager.service to /usr/lib/systemd/system/NetworkManager.service.
    Created symlink from /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service to /usr/lib/systemd/system/NetworkManager-dispatcher.service.
    Created symlink from /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service to /usr/lib/systemd/system/NetworkManager-wait-online.service.
这个命令会在/etc/systemd/system/目录下创建需要的符号链接，表示服务需要进行启动。通过stdout输出的信息可以看到，软连接实际指向的文件为/usr/lib/systemd/system/目录中的文件，实际起作用的也是这个目录中的文件。
systemctl disable xxx的作用
执行systemctl disable xxx后，会禁用这个服务。它实现的方法是将服务对应的软连接从/etc/systemd/system中删除。命令执行情况一般类似如下：

```
[root@NameNode01 system]# systemctl disable NetworkManager
Removed symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service.
Removed symlink /etc/systemd/system/dbus-org.freedesktop.NetworkManager.service.
Removed symlink /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service.
Removed symlink /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service.
```

在执行systemctl disable xxx的时候，实际只是删除了软连接，并不会产生其他影响。
systemctl mask xxx的作用
执行 systemctl mask xxx会屏蔽这个服务。它和systemctl disable xxx的区别在于，前者只是删除了符号链接，后者会建立一个指向/dev/null的符号链接，这样，即使有其他服务要启动被mask的服务，仍然无法执行成功。执行该命令的效果一般类似如下：

```
[root@NameNode01 system]# systemctl mask NetworkManager 
Created symlink from /etc/systemd/system/NetworkManager.service to /dev/null.
```

## **systemctl mask xxx和systemctl disable xxx**
在执行过mask后，如果想要启动服务，那么会报类似如下错误：

```
[root@NameNode01 system]# systemctl start NetworkManager
Failed to start NetworkManager.service: Unit is masked.
```

如果使用disable的话，可以正常启动服务。总体来看，disable和enable是一对操作，是用来启动、停止服务。
使用systemctl unmask xxx取消屏蔽
如果使用了mask，要想重新启动服务，必须先执行unmask将服务取消屏蔽。mask和unmask是一对操作，用来屏蔽和取消屏蔽服务。

