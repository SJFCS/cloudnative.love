---
title: 常用模块
---
[Ansible Module](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html) 就是能够用于执行某项任务的一个组件，Ansible 维护了一个庞大的 Modules 库供用户使用，其中包含了很多[内置插件](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#plugin-index)。同时 Module 也是 Playbook 的组成部分，每一个 Playbook 的步骤，都对应一个 Module。

可以借助 `ansible-doc` 我们可以快速了解一个模块的使用方法：
```bash
# 列出所有的 modules
ansible-doc -l
# 统计模块数量
ansible-doc -l | wc -l  # 目前有 3387 个
# 搜索模块
ansible-doc -l | grep <key-word>
# 查看模块使用方法
ansible-doc <mode-name>
```


## 1. [远程执行命令](https://docs.ansible.com/ansible/latest/modules/list_of_commands_modules.html)

1. `command`: ansible 直接调用对应的程序。不使用 shell，因此用不了 shell 相关的语法（比如 shell 内建命令 `cd`、管道符 `|`、字符串插值）。
   1. 这对应 python 的 `subprocess.run(shlex.split("<cmd>"), shell=False)`
2. `shell`: 通过远程的 shell(`/bin/sh`) 来执行命令，可以使用 shell 语法。
   1. 对应 python 的 `subprocess.run("<cmd>", shell=True)`
3. `script`: 将本地的脚本传输到远程主机上执行，可指定脚本执行程序(`/usr/bin/bash` `/usr/bin/python3`). 
   1. 不要求远程主机上安装有 `python`
4. `raw`: 直接通过 ssh 在远程主机上执行命令. 
   1. 不要求远程主机上安装有 `python`
   2. 官方文档说它和 `shell` 的区别在于它在实现上更 `dirty`。因此还是优先选用 `shell` 模块


## 2. [文件处理](https://docs.ansible.com/ansible/latest/modules/list_of_files_modules.html)

1. `copy`: 将文件拷贝到远程主机上
2. `fetch`: 从远程主机上抓取文件到本机
3. `file`: 文件(夹)的创建、删除、权限修改等。
4. `archive`/`unarchive`: 压缩/解压
5. `synchronize`: 数据同步，对 `rsync` 的封装。
6. `find`/`replace`: 对应常用的 `find`/`sed` 两个工具。
7. `get_url`: 通过 `http/https/ftp` 协议下载文件。
   1. 在下载大文件时，在本机下载好然后 `copy` 到远程主机上可能是更好的选择。

## 3. Linux 系统运维

1. 定时任务管理：`cron`
2. 用户/群组管理: `user`/`group`
3. 包管理: `apt`/`yum`/`apk`/`pip`
4. 主机信息（IP 地址、OS 信息等）: `setup`

## 4. Terraform

Terraform 是一个倡导「基础设施即代码」的基础设施管理工具，被广泛应用在云上资源各种资源的 CURD，比如云主机的创建、属性变更及销毁。

由于其在资源生产成功之后会在本地以一个 state 文件的形式记录整个资源的详细信息，而这些信息的记录使得整个模板所定义的资源可以保证前后端的高度一致性，可以有利于后续对于整个一套资源的有效的版本控制。

同时 Terraform 还提供了 DataSource 可以用于查询已有资源的各项属性(IP 地址、规格、可用区、使用的镜像、所属的虚拟网络等等)。

而 Ansible 主要被用于远程主机的环境配置（软件安装、配置）、状态控制（主机的开/关/重启），虽然 Ansible 也能实现部分 terraform 的功能，但是 Ansible 没有 state 文件，也没有 datasource，所以基础设施还是建议用 terraform 管理。

为了更好地结合两者，可以通过 ansible 的 [terraform 插件](https://docs.ansible.com/ansible/latest/modules/terraform_module.html)调用 terraform:



## 5. 常见用例

1.`script`脚本模块


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