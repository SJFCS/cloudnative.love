---
title: 常用模块
sidebar_position: 2
---

## 10. import_playbook

**多个playbook合并**

![image-20210823094821529](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:24:08-image-20210823094821529.png)

## 11. 错误处理changed_when

![image-20210823100021169](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:24:15-image-20210823100021169.png)

![image-20210823100007068](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:24:17-image-20210823100007068.png)

![image-20210823100040592](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:24:20-image-20210823100040592.png)

![image-20210823100958926](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:24:23-image-20210823100958926.png)

### task失败强制调用handlers

![image-20210823095748984](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:23:14-image-20210823095748984.png)





![image-20210823093430185](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:23:19-image-20210823093430185.png)

![image-20210822182749591](D:\ac\08-实践案例\image-20210822182749591.png)

![image-20210822183056198](D:\ac\08-实践案例\image-20210822183056198.png)

![image-20210822183051429](D:\ac\08-实践案例\image-20210822183051429.png)

多个

![image-20210822183455797](D:\ac\08-实践案例\image-20210822183455797.png)

![image-20210822183459539](D:\ac\08-实践案例\image-20210822183459539.png)

## 

### 5. face变量

## 批量修改主机名

![image-20210822081431396](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:21:31-image-20210822081431396.png)

![image-20210822081434719](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:21:33-image-20210822081434719.png)

![image-20210822081439604](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:21:37-image-20210822081439604.png)

time.epoch时间戳

![image-20210822080628506](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/08-%E5%AE%9E%E8%B7%B5%E6%A1%88%E4%BE%8B/2021.09.26-22:21:40-image-20210822080628506.png)

采集被控端主机指标（ip cpu 内存。。。）

![image-20210821112252481](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%8F%98%E9%87%8F/2021.09.26-22:22:06-image-20210821112252481.png)

![image-20210821112311386](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%8F%98%E9%87%8F/2021.09.26-22:22:10-image-20210821112311386.png)



```
[root@node1 ansible_yml]# ansible 10.50.1.103  -m setup > facts
[root@node1 ansible_yml]# vi facts
[root@node1 ansible_yml]# ansible 10.50.1.103 -m setup -a "filter=ansible_memtotal_mb"
10.50.1.103 | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 3770,
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
```



获取指定变量

![image-20210821112143177](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%8F%98%E9%87%8F/2021.09.26-22:22:14-image-20210821112143177.png)

![image-20210821112740721](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%8F%98%E9%87%8F/2021.09.26-22:22:22-image-20210821112740721.png)

![image-20210821165148775](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%8F%98%E9%87%8F/2021.09.26-22:22:24-image-20210821165148775.png)

## 模块

*4.ad-hoc模式的常用模块*

![image-20210820160339469](D:\ac\5分钟入门Ansible\image-20210820160339469.png)

1.`command`命令模块

不加-m comond 默认comond模块，commond模块不支持管道

![image-20210820161644144](D:\ac\5分钟入门Ansible\image-20210820161644144.png)

```bash
# 默认模块, 执行命令
[root@m01 ~]# ansible oldboy  -a "hostname"

# 如果需要一些管道操作，则使用shell
[root@m01 ~]# ansible oldboy -m shell -a "ifconfig|grep eth0" -f 50

# -f =forks   /etc/ansible/ansible.cfg #结果返回的数量
```

2.`script`脚本模块

```bash
# 编写脚本
[root@m01 ~]# mkdir -p /server/scripts
[root@m01 ~]# cat /server/scripts/yum.sh
#!/usr/bin/bash
yum install -y iftop

#在本地运行模块，等同于在远程执行，不需要将脚本文件进行推送目标主机执行
[root@m01 ~]# ansible oldboy -m script -a "/server/scripts/yum.sh"
```

3.`yum`安装软件模块

```bash
[root@m01 ~]# ansible oldboy -m yum -a "name=httpd state=installed"
name        #指定要安装的软件包名称，或软件包url
state       #指定使用yum的方法
    	installed，present   #安装软件包
    	removed，absent      #移除软件包
    	latest              #安装最新软件包 
#present与latest区别：当软件包已安装present不会执行操作，latest只要不是最新版本就安装最新版本
enablerepo  #允许从哪些仓库获取软件：eple、base...
disablerepo #禁止从那些仓库获取软件：eple、base...
exclude     #排除指定软件包:kernel、...
download_only #仅下载软件包，不安装：yes、no
```

4.`copy`文件拷贝模块

```bash
# 推送文件模块
[root@m01 ~]# ansible oldboy -m copy -a "src=/etc/hosts dest=/tmp/test.txt"

# 在推送覆盖远程端文件前，对远端已有文件进行备份，按照时间信息备份
[root@m01 ~]# ansible oldboy -m copy -a "src=/etc/hosts dest=/tmp/test.txt backup=yes"

# 直接向远端文件内写入数据信息，并且会覆盖远端文件内原有数据信息
[root@m01 ~]# ansible oldboy -m copy -a "content='bgx' dest=/tmp/oldboy"

src             #推送数据的源文件信息
dest            #推送数据的目标路径
backup          #对推送传输过去的文件，进行备份
content         #直接批量在被管理端文件中添加内容
group           #将本地文件推送到远端，指定文件属组信息
owner           #将本地文件推送到远端，指定文件属主信息
mode            #将本地文件推送到远端，指定文件权限信息
```

5.`file`文件配置模块

```bash
[root@m01 ~]# ansible oldboy -m file -a "path=/tmp/oldboy state=directory"
[root@m01 ~]# ansible oldboy -m file -a "path=/tmp/tt state=touch mode=555 owner=root group=root"
[root@m01 ~]# ansible oldboy -m file -a "src=/tmp/tt path=/tmp/tt_link state=link"

path            #指定远程主机目录或文件信息
recurse         #递归授权
state 
    directory   #在远端创建目录
    touch       #在远端创建文件
    link        #link或hard表示创建链接文件
    absent      #表示删除文件或目录
    mode        #设置文件或目录权限
    owner       #设置文件或目录属主信息
    group       #设置文件或目录属组信息
```

6.`service`服务模块

```bash
[root@m01 ~]# ansible oldboy -m service -a "name=crond state=stopped enabled=yes"

name        # 定义要启动服务的名称
state       # 指定服务状态
    started     #启动服务
    stopped     #停止服务
    restarted   #重启服务
    reloaded    #重载服务
enabled         #开机自启
```

7.`group`组模块

```bash
[root@m01 ~]# ansible oldboy -m group -a "name=oldgirl gid=888"

name            #指定创建的组名
gid             #指定组的gid
state
    absent      #移除远端主机的组
    present     #创建远端主机的组（默认）
```

8.`user`模块

```bash
#创建用户指定uid和gid，不创建家目录也不允许登陆
[root@m01 ~]# ansible oldboy -m user -a "name=oldgirl uid=888 group=888 shell=/sbin/nologin create_home=no"

#将明文密码进行hash加密，然后进行用户创建
[root@m01 ~]# ansible localhost -m debug -a "msg={{ 'bgx' | password_hash('sha512', 'salt') }}"
localhost | SUCCESS => {
    "msg": "$6$salt$WP.Kb1hMfqJG7dtlBltkj4Um4rVhch54R5JCi6oP73MXzGhDWqqIY.JkSOnIsBSOeXpKglY7gUhHzY4ZtySm41"
}
[root@m01 ~]# ansible oldboy -m user -a 'name=xlw password=$6$salt$WP.Kb1hMfqJG7dtlBltkj4Um4rVhch54R5JCi6oP73MXzGhDWqqIY.JkSOnIsBSOeXpKglY7gUhHzY4ZtySm41 create_home=yes shell=/bin/bash'

uid             #指定用户的uid
group           #指定用户组名称
groups          #指定附加组名称
password        #给用户添加密码
shell           #指定用户登录shell
create_home     #是否创建家目录
```

8.`crond`定时任务模块

```bash
# 正常使用crond服务
[root@m01 ~]# crontab -l
* * * * *  /bin/sh /server/scripts/yum.sh

# 使用ansible添加一条定时任务
[root@m01 ~]# ansible oldboy -m cron -a "minute=* hour=* day=* month=* weekday=*  job='/bin/sh /server/scripts/test.sh'"
[root@m01 ~]# ansible oldboy -m cron -a "job='/bin/sh /server/scripts/test.sh'"

# 设置定时任务注释信息，防止重复，name设定
[root@m01 ~]# ansible oldboy -m cron -a "name='cron01' job='/bin/sh /server/scripts/test.sh'"

# 删除相应定时任务
[root@m01 ~]# ansible oldboy -m cron -a "name='ansible cron02' minute=0 hour=0 job='/bin/sh /server/scripts/test.sh' state=absent"
 
# 注释相应定时任务，使定时任务失效
[root@m01 scripts]# ansible oldboy -m cron -a "name='ansible cron01' minute=0 hour=0 job='/bin/sh /server/scripts/test.sh' disabled=no"
```

9.`mount`模块

```
[root@m01 ~]# ansible oldboy -m mount -a "src=172.16.1.31:/data path=/data fstype=nfs opts=defaults state=present"
[root@m01 ~]# ansible web -m mount -a "src=172.16.1.31:/data path=/data fstype=nfs opts=defaults state=mounted"
[root@m01 ~]# ansible web -m mount -a "src=172.16.1.31:/data path=/data fstype=nfs opts=defaults state=unmounted"
[root@m01 ~]# ansible web -m mount -a "src=172.16.1.31:/data path=/data fstype=nfs opts=defaults state=absent"

present     # 开机挂载，仅将挂载配置写入/etc/fstab
mounted     # 挂载设备，并将配置写入/etc/fstab
unmounted   # 卸载设备，不会清除/etc/fstab写入的配置
absent      # 卸载设备，会清理/etc/fstab写入的配置
```

10.ansible查看帮助方法

```
[root@m01 ~]# ansible-doc -l    --- 查看所有模块说明信息
[root@m01 ~]# ansible-doc copy  --- 表示指定查看某个模块参数用法信息
直接搜索EXAMPLES可查看示例
```





![image-20210820165029176](D:\ac\5分钟入门Ansible\image-20210820165029176.png)

yum仓库模块

解压模块

git模块

template

## 防火墙

![image-20210821102144823](D:\ac\playbook\image-20210821102144823.png)

![image-20210825112307575](D:\ac\01模块\image-20210825112307575.png)

![image-20210825112736517](D:\ac\01模块\image-20210825112736517.png)

![image-20210821102130416](D:\ac\playbook\image-20210821102130416.png)

# unarchive

#### Stat模块

  获取远程文件状态信息

![img](https://img2018.cnblogs.com/blog/1577901/201904/1577901-20190410170726317-1692692420.png)

#### Debug模块

  打印语句到Ansible执行输出

#### Package

   调用目标主机系统包管理工具(yum , apt)进行安装

直接使用 git 部署 webapp:

```
ansible webservers -m git -a "repo=git://foo.example.org/repo.git dest=/srv/myapp version=HEAD"
```
