## supervisor 管理监听脚本

我们可以使用 supervisor 来管理`file_watch.sh`脚本，不用我们自己在后台运行该脚本，这些就算`file_watch.sh`脚本在后台运行时挂掉，supervisor 也可以自动让其重新运行。

- `supervisor`的使用，此处不详细介绍

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

因为包含了子进程，我们需要将这些进程做为一个组来管理，这样在 supervisor 中不至于父进程被停掉了，子进程还在运行，导致同步异常。

因此，我们编写的 supervisor 配置文件`/etc/supervisord.d/rsync.ini`如下：

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

编写好配置文件后，重新加载 supervisor 配置文件，然后查看应用状态：

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




## 停止应用
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

修改 supervisor 的配置：

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

此时重新加载 supervisor 配置:

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
