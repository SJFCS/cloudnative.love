---
title: rsyslog
---
## 1. rsyslog介绍

Rsyslog的全称是 rocket-fast system for log，它提供了高性能，高安全功能和模块化设计。rsyslog能够接受从各种各样的来源，将其输入，输出的结果到不同的目的地。rsyslog可以提供超过每秒一百万条消息给目标文件。



转载：https://blog.csdn.net/weixin_43695104/article/details/90047507



**特点：**

多线程
可以通过许多协议进行传输UDP，TCP，SSL，TLS，RELP；
直接将日志写入到数据库;
支持加密协议：ssl，tls，relp
强大的过滤器，实现过滤日志信息中任何部分的内容
自定义输出格式；
**配置文件：**

配置文件/etc/rsyslog.conf主要有3个部分

MODULES ：模块
GLOBAL DRICTIVES :全局设置
RULES：规则



**RULEs：**

```
facitlity.priority          Target

auth         #pam产生的日志，认证日志
authpriv     #ssh,ftp等登录信息的验证信息，认证授权认证
cron         #时间任务相关
kern         #内核
lpr          #打印
mail         #邮件
mark(syslog) #rsyslog服务内部的信息,时间标识
news         #新闻组
user         #用户程序产生的相关信息
uucp         #unix to unix copy, unix主机之间相关的通讯
local 1~7    #自定义的日志设备
===============================================================
#priority: 级别日志级别:
=====================================================================
debug           #有调式信息的，日志信息最多
info            #一般信息的日志，最常用
notice          #最具有重要性的普通条件的信息
warning, warn   #警告级别
err, error      #错误级别，阻止某个功能或者模块不能正常工作的信息
crit            #严重级别，阻止整个系统或者整个软件不能正常工作的信息
alert           #需要立刻修改的信息
emerg, panic    #内核崩溃等严重信息
###从上到下，级别从低到高，记录的信息越来越少，如果设置的日志内性为err，则日志不会记录比err级别低的日志，只会记录比err更高级别的日志，也包括err本身的日志。
=====================================================================
Target：
  #文件, 如/var/log/messages
  #用户， root，*（表示所有用户）
  #日志服务器，@172.16.22.1
  #管道        | COMMAND
```

## 2. 使用rsyslog实现日志转发

### 2.1 搭建服务

**环境：**

| 系统               | Redhat7.0      |
| ------------------ | -------------- |
| 发送服务器：客户端 | 192.168.157.60 |
| 收集服务器：服务端 | 192.168.157.61 |

**关闭服务端和客户端防火墙、selinux**

```
[root@send ~]# setenforce 0
[root@send ~]# systemctl stop firewalld
[root@send ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
[root@send ~]# systemctl mask firewalld
Created symlink from /etc/systemd/system/firewalld.service to /dev/null.
#服务端一样
```

**修改客户端配置文件，并启动服务**

```
[root@send ~]# vim /etc/rsyslog.conf 
#将下面四行前的注释取消掉
$ModLoad imudp		
$UDPServerRun 514	
$ModLoad imtcp		
$InputTCPServerRun 514

#添加下列内容
$template myFormat,"%timestamp% %fromhost-ip% %msg%\n"
$ActionFileDefaultTemplate myFormat

#修改接收方IP（服务端），一个@表示TCP传输，两个@表示UDP传输
*.info;mail.none;authpriv.none;cron.none              @@192.168.157.61:514

[root@send ~]# systemctl start rsyslog
```

**修改服务端配置文件，并启动服务**

```
[root@accept ~]# vim /etc/rsyslog.conf 
#将下面四行前的注释取消掉
$ModLoad imudp
$UDPServerRun 514
$ModLoad imtcp
$InputTCPServerRun 514
*.info;mail.none;authpriv.none;cron.none                /data/log/messages

#添加以下内容
$AllowedSender tcp, 192.168.157.0/24
//允许 157.0网段内的主机以tcp协议来传输

$template Remote,"/data/log/%fromhost-ip%/%fromhost-ip%_%$YEAR%-%$MONTH%-%$DAY%.log"
//定义模板，接受日志文件路径，区分了不同主机的日志

:fromhost-ip, !isequal, "127.0.0.1" ?Remote
//过滤server 本机的日志。

[root@accept ~]# systemctl start rsyslog
```

**在服务端创建/data/log目录，以接受大量日志信息，配置文件中的路径应当与该路径一致**

```
[root@accept ~]# mkdir -pv /data/log
[root@accept ~]# touch messages
*.info;mail.none;authpriv.none;cron.none               /data/log/messages

[root@accept ~]# systemctl restart rsyslog
```

**在服务端利用tree命令查看/data/log的结构**

```
[root@accept ~]# tree /data/log/
/data/log/
├── 192.168.157.60
│   └── 192.168.157.60_2019-05-10.log
└── messages

1 directory, 2 files
```

### 2.2 验证

**验证一：**
\#在客户端的终端命令行输入：

```
[root@send ~]# logger "I'm very happy"
```

\#在服务端查看日志文件：

```
[root@accept ~]# tail -f /data/log/192.168.157.60/192.168.157.60_2019-05-10.log 
......省略了其他日志信息......
May 10 18:14:09 send root: I'm very happy
```

**验证二：**
\#在客户端使用ssh协议登录系统：

```
Last login: Fri May 10 22:11:54 2019 from 192.168.157.1
[root@send ~]# 
```

\#在服务端查看日志信息：

```
[root@accept ~]# tail -f /data/log/192.168.157.60/192.168.157.60_2019-05-10.log 
......省略了其他信息......
May 10 22:20:33 send sshd[14047]: Accepted password for root from 192.168.157.1 port 53248 ssh2
......省略了其他信息......
May 10 22:20:34 send sshd[14047]: pam_unix(sshd:session): session opened for user root by (uid=0)
```

## 3. 将日志信息存储至MySQL数据库中

**环境**

| 系统   | Redhat         |
| ------ | -------------- |
| 客户端 | 192.168.157.60 |
| 服务端 | 192.168.157.61 |

### 3.1 服务端配置

**//安装MySQL**
[点击查看MySQL安装](https://blog.csdn.net/weixin_43695104/article/details/87808080#32_mysql_145)

**//安装rsyslog+MySQL的连接驱动**

```
[root@accept ~]# yum -y install rsyslog-mysql
[root@accept ~]# rpm -ql rsyslog-mysql
/usr/lib64/rsyslog/ommysql.so		#模块
/usr/share/doc/rsyslog-8.24.0/mysql-createDB.sql	#创建rsyslog存放日志的表结构的sql语句
```

**//查看mysql数据库，发现没有日志数据库**

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.09 sec)
```

**//导入日志文件的sql脚本，生成日志文件的数据库**

```
[root@accept ~]# mysql </usr/share/doc/rsyslog-8.24.0/mysql-createDB.sql 
#此文件可以rpm -ql rsyslog-mysql查看
```

**//再进入数据库查看**

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| Syslog             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use Syslog;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+------------------------+
| Tables_in_Syslog       |
+------------------------+
| SystemEvents           |
| SystemEventsProperties |
+------------------------+
2 rows in set (0.00 sec)

mysql> 
```

**//授权一个用户给rsyslog访问数据库**

```
mysql> grant all on Syslog.* to 'rsysloguser'@'127.0.0.1' identified by 'rsyslogpass';
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

**//修改主配置文件**

```
[root@accept ~]# vim /etc/rsyslog.conf 
#在rules里添加下面内容。
#并将其他规则注释（可选）
$ModLoad ommysql 	//打开连接mysql的模块
*.*                      :ommysql:127.0.0.1,Syslog,rsysloguser,rsyslogpass
//这行表示把所有的设施的所有日志都记录到数据库服务器中的Syslog数据库中，以rsysloguser用户，rsyslogpass密码访问数据库
```

### 3.2 客户端验证

**客户端配置文件不需要修改，只要能和服务端通信即可，配置参考第2节日志转发。**
**//验证：
在客户端命令行输入："This is a test"**

```
[root@send ~]# logger 'THIS IS A TEST'
[root@accept ~]# mysql 
mysql> use Syslog;
mysql> select * from SystemEvents\G;


*************************** 17. row ***************************
            ID: 17
    CustomerID: NULL
    ReceivedAt: 2019-05-10 23:15:07
DeviceReportedTime: 2019-05-10 23:15:06
          Facility: 1
          Priority: 5
          FromHost: send
           Message:  THIS IS A TEST
        NTSeverity: NULL
        Importance: NULL
       EventSource: NULL
         EventUser: NULL
     EventCategory: NULL
           EventID: NULL
   EventBinaryData: NULL
      MaxAvailable: NULL
         CurrUsage: NULL
          MinUsage: NULL
          MaxUsage: NULL
        InfoUnitID: 1
         SysLogTag: root:
      EventLogType: NULL
   GenericFileName: NULL
          SystemID: NULL
17 rows in set (0.00 sec)
```

