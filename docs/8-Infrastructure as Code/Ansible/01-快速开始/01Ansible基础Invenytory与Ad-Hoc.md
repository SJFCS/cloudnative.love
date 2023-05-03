---
title: Ansible：Invenytory与Ad-Hoc
sidebar_position: 1
---



![image-20210820073428512](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8Ansible/2021.09.26-22:18:38-image-20210820073428512.png)

> 通过并发的SSH连接多个客户端，不需要在客户端安装agent
>
> invenytory：记录服务器分组
>
> playbook：描述了一组要执行的命令
>

## Ansible 安装配置

### 安装ansible命令参数

```
yum install ansible 

ansible <host-pattern> [options]
--version	#显示ansible版本信息
-i			#指定主机清单文件路径，默认是在/etc/ansible/hosts
-m			#指定模块名称，默认使用command模块
-a			#指定模块参数
-e			#指定变量
-f			#指定并发数，默认5
-C			#模拟测试，不会真正执行
-D			#显示这些文件的差异。常与-C一起使用
--syntax	#语法检查
--list-hosts #列出主机清单
-k			#提示输入ssh密码，而不是用ssh的密钥认证
-T			#执行命令的超时时间
```

### Ansible的配置文件优先级

配置文件查找顺序如下：

1. `$ANSIBLE_CONFIG`变量
2. 当前目录下`ansible.cfg`
3. 用户家目录下`ansible.cfg`
4. `/etc/ansible/ansible.cfg`(默认)

通过`ansible --version`可以发现ansible当前配置文件为`config file = /etc/ansible/ansible.cfg`

```
#检查ansible版本
ansible --version
[root@node1 ~]# ansible --version

ansible 2.9.16
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.6/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.6.8 (default, Nov 16 2020, 16:55:22) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```

### 配置文件参数

```
# cat /etc/ansible/ansible.cfg
[defaultes]
#inventory			= /etc/ansible/hosts		#主机列表配置文件
#library			= /usr/share/my_modules/	#库文件存放目
#remote_tmp			= ~/.ansible/tmp			#临时py文件存放在远程主机目录
#local_tmp			= ~/.ansible/tmp			#本机的临时执行目录
#forks				= 5							#默认并发数
#sudo user			= root						#默认sudo用户
#ask_sudo_pass		= True						#每次执行是询问sudo的ssh密码
#ask_pass			= True						#每次执行是否询问ssh密码
#remote_port		= 22						# 远程主机端口
host_key_checking = False						#跳过检查主机指纹
log_path =/var/log/ansible.log					# ansible日志
```

## Ansible inventory配置

**主机清单文件**: /etc/ansible/hosts
 文件作用：通常用于定义要管理哪些主机的认证信息，例如ssh登录用户名，密码信息等

### 1. 定义主机单台&批量

```bash
#vim /etc/ansible/hosts
[servers01]
192.168.1.1
192.168.1.2:22
www.nginx_server.com:22
# 主机别名 （此方式执行命令后回显由别名代替IP）
alias_name  ansible_host=192.168.1.3 

192.168.2.[1:100]
web[1:3].server.com
```

### 2. 主机变量

```bash
[servers01]
192.168.1.2 ansible_ssh_user='root' ansible_ssh_pass='redhat' ansible_ssh_port='22'
```

### 3. 主机组变量

```bash
[servers02]
192.168.3.1
[servers03:vars]
ansible_ssh_user='user'
ansible_ssh_pass='pass'
ansible_ssh_port='22'
## 如果登陆后需要切换用户则需要以下配置
# 切换用户
ansible_become=true
# 使用su切换
ansible_become_method=su
# 切换到root
ansible_become_user=root
# root密码
ansible_become_pass=pass
```

### 4. 子组分类变量：children

```bash
[nginx]
192.168.1.31
[apache]
192.168.1.32
[web_servers:children]
apache
nginx
[web_servers:vars]
ansible_ssh_user='root'
ansible_ssh_pass='redhat'
ansible_ssh_port='22'
```

### ssh免密

通常通过ssh密钥管理主机，而不用在hosts中写入密码

 ```
 # master生成密钥
 ssh-keygen
 # master分发密钥
 sshpass -p pass  ssh-copy-id -i ~/.ssh/id_rsa.pub user@IP
 # 查看信任主机
 cat ~/.ssh/known_hosts
 ```


## Ansible Ad-Hoc

### 1.什么是ad-hoc模式

> ad-hoc简而言之，就是“临时命令”，不会保存
>  ansible中有两种模式, 分别是ad-hoc模式和playbook模式

### 2.ad-hoc模式的使用场景
 *场景一，在多台机器上，查看某个进程是否启动
 场景二，在多台机器上，拷贝指定日志文件到本地，等等*

### 3.ad-hoc模式的命令使用

![image-20210825103845247](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/00-5%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8Ansible/2021.09.26-22:18:46-image-20210825103845247.png)

### 4. Ansible执行返回

> 黄色：对远程节点进行相应修改
> 绿色：对远程节点不进行相应修改，或者只是对远程节点信息进行查看
> 红色：操作执行命令有异常
> 紫色：表示对命令执行发出警告信息（可能存在的问题，给你一下建议）

