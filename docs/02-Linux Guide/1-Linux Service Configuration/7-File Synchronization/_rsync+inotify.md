---
title: rsync + inotify 实现数据实时同步
---

## 1. 实验环境说明

| IP            | 主机名    | 描述         |
| ------------- | --------- | ------------ |
| 192.168.56.11 | src-host  | 源端服务器   |
| 192.168.56.12 | dest-host | 目标端服务器 |



## 2. 概述

- rsync 与传统的 cp、tar 备份方式相比，rsync 具有安全性高、备份迅速、支持增量备份等优点，通过 rsync 可以解决对实时性要求不高的数据备份需求，例如定期的备份文件服务器数据到远端服务器，对本地磁盘定期做数据镜像等。
- 随着应用系统规模的不断扩大，对数据的安全性和可靠性也提出的更好的要求，rsync 在高端业务系统中也逐渐暴露出了很多不足，首先，rsync 同步数据时，需要扫描所有文件后进行比对，进行差量传输。如果文件数量达到了百万甚至千万量级，扫描所有文件将是非常耗时的。而且正在发生变化的往往是其中很少的一部分，这是非常低效的方式。其次，rsync 不能实时的去监测、同步数据，虽然它可以通过 linux 守护进程的方式进行触发同步，但是两次触发动作一定会有时间差，这样就导致了服务端和客户端数据可能出现不一致，无法在应用故障时完全的恢复数据。基于以上原因，**rsync + inotify 组合出现了**。
- 我们通过 inotify 监控源服务器上待备份的文件夹，当文件夹有变化时则触发 rsync 进行同步。

## 3. rsync 的使用

- rsync 官方地址：[https://rsync.samba.org/](https://rsync.samba.org/)

### 3.1 安装 rsync

在源端服务器和目标端上面安装 rsync 包：

```sh
[root@src-host ~]# yum install -y rsync
```

此时尝试将源端上面的一个文件同步到目标端的`/tmp`目录下：

:::caution
不仅源端主机需要安装 rsync，而且目标端服务器也需要安装 rsync

否则会提示 `rsync error: remote command not found (code 127) at io.c(226)`
:::




- `-a,  --archive` 归档模式，等价于`-rlptgoD`。
- `-r, --recursive` 对子目录以递归模式处理。
- `-l, --links` 保留软链接。
- `-p, --perms` 保留文件权限。
- `-t, --times` 保留文件时间信息。
- `-g, --group` 保留文件属组信息。
- `-o, --owner` 保留文件属主信息。
- `-D` 等价于`--devices --specials`。
- `--devices` 保留设备文件信息。
- `--specials` 保留特殊文件。
- ` -v, --verbose` 详细输出模式。
- `--version` 打印版本信息。
- `-h, --help` 显示帮助信息。
- `-z, --compress` 在传输文件时进行压缩处理。
- `--partial` 保留那些因故没有完全传输的文件，以是加快随后的再次传输。
- `--progress` 在传输时显示传输过程。
- `-P` 等价于`--partial --progress`。
- `--delete` 删除那些接收端还有而发送端已经不存在的文件。


### 3.4 rsync 同步实践
```sh
# rsync -avP --compress --delete 表示归档模式进行同步，压缩传输，删除目标端多余的文件，并显示传输过程
[root@src-host ~]# rsync -avP --compress --delete /var/lib/docker root@dest-host:/var/lib
```



## 4. inotify 工具的使用

### 4.1 什么是 inotify 和 inotify-tools

- Inotify 是一种强大的、细粒度的、异步文件系统监控机制，它满足各种各样的文件监控需要，可以监控文件系统的访问属性、读写属性、权限属性、删除创建、移动等操作，也就是可以监控文件发生的一切变化。
- inotify-tools 包括一个 C 库和一组命令行工具，可在命令行下提供对文件系统事件的监控。inotify-tools 安装后会得到 inotifywait 和 inotifywatch 这两条命令。
- inotifywait 命令可以用来收集有关文件访问信息。
- inotifywatch 命令用于收集关于被监视的文件系统的统计数据，包括每个 inotify 事件发生多少次。
- Linux 内核从 2.6.13 开始引入了 inotify 机制。我们使用的是 CentOS7 操作系统，内核满足要求。如果内核满足要求，则查看系统是否支持 inotify。

### 4.2 服务器内核是否支持 inotify

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

- /proc/sys/fs/inotify/max_queued_events ifd 文件队列长度限制
- /proc/sys/fs/inotify/max_user_instances 初始化 ifd 的数量限制
- /proc/sys/fs/inotify/max_user_watches 注册监听目录的数量限制

可以看到默认注册监听目录的数量限制是 8192，当我们需要监听的文件非常多时，可能会报以下异常：

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

```


### 4.3 inotify-tools 工具的安装与使用

我们只需要监听源端上面的目录，只需要在源端上面安装`inotify-tools`软件即可。

```sh
[root@src-host ~]# yum install -y inotify-tools
```

### 4.4 编写同步脚本

参考 [rsync+ Notify 配置解析及步骤详解](https://blog.51cto.com/u_13858192/2159200)编写一个监听同步脚本。

```sh
#!/bin/bash
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

- `file_watch.sh`是通过 nohup 形式在后台运行的，如果后台程序挂掉了，不会自动重启，会导致同步任务停止，同步异常。
- `file_watch.sh`脚本是只监听了单个目录(及其子目录)，如果有多个目录需要监听的话，此脚本则需要优化。
- 目标端 IP，源端目录，目标湍目录，用户等信息直接在脚本中写死了，可以从配置文件读取。
## 使用systemd管理脚本 待补充

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





https://www.cnblogs.com/-k8s/p/11437902.html

https://www.soinside.com/question/iSmB8faqyuDLRjNHPirTBS

[TB级NFS数据平滑迁移方案设计与实现](https://www.cnblogs.com/xrszff/p/10960196.html)
