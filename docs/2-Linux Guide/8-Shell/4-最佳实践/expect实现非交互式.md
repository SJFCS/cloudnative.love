**简介：** expect非交互式 expect可以在脚本中完成一些交互式的操作，例如远程登录时要输入yes或者输入密码 expect是一个自动化交互套件，主要应用于执行命令和程序时，系统以交互形式要求输入指定字符串，实现交互通信。 expect自动交互流程：

expect非交互式

expect可以在脚本中完成一些交互式的操作，例如远程登录时要输入yes或者输入密码

expect是一个自动化交互套件，主要应用于执行命令和程序时，系统以交互形式要求输入指定字符串，实现交互通信。

expect自动交互流程：

spawn启动指定进程—expect获取指定关键字—send向指定程序发送指定字符—执行完成退出.

expect常用命令总结:

```
spawn               交互程序开始后面跟命令或者指定程序
expect              获取匹配信息匹配成功则执行expect后面的程序动作
send exp_send       用于发送指定的字符串信息
exp_continue        在expect中多次匹配就需要用到
send_user           用来打印输出 相当于shell中的echo
exit                退出expect脚本
eof                 expect执行结束 退出
set                 定义变量
puts                输出变量
set timeout         设置超时时间

```

## 1.实现非交互式远程登录

如果由于ssh服务原因导致超过10秒则expect不会再输入，需要手动输入

在sshd\_config文件中加上UseDns no即可避免

```
#!/usr/bin/expect
spawn ssh root@192.168.81.210
expect {
  "*yes/no" { send "yes/r"; exp_continue }
  "*password:" { send "redhat/r" }
}
interacts
```

这里的expect也是expect的一个内部命令，expect的shell命令和内部命令是一样的，但不是一个功能。

“\*yes/no” { send “yes\\r”; exp\_continue}这个命令的意思是判断上次输出结果是否包含“yes/no”的字符串，如果有则执行“yes”，并继续执行（exp\_continue）。

“\*password:” { send “redhat\\r” }这个命令的意思是判断上次输出结果里是否包含“password:”的字符串，如果有则立即返回，并自动输入密码，否则就等待一段时间后返回，这里等待时长就是前面设置的10秒。

interact执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。如果你只是登录过去执行。

2.实现非交互式scp传输文件

由于scp不需要交互，所以不需要写interact，interact结束交互式由管理员进行结束的，面对不需要交互的使用expect eof来结束

```
#!/usr/bin/expect
#---------------利用expect实现scp非交互传文件------------------
set ip [lindex $argv 0]
set user [lindex $argv 1]
set password redhat
set tiemout 20
spawn scp -r /etc/hosts $user@$ip:/root
expect {
        "yes/no" { send "yes\r"; exp_continue }
        "password:" { send "$password\r" }
}
expect eof

```

## 2.批量推送主机公钥

```
#!/bin/bash
#---------------批量推送主机公钥------------
rpm -qa |grep expect &>/dev/null
if [ $? -ne 0 ];then
        yum -y install expect
fi

if [ ! -f ~/.ssh/id_rsa ];then
        ssh-keygen -P "" -f ~/.ssh/id_rsa
fi

for i in {3..254}
do
        {
        ip=192.168.81.$i
        local_ip=`ifconfig  | grep inet | head -1 |awk '{print $2}'`
        if [ "$ip" = "$local_ip" ];then
                continue
        fi
        ping -c1 -W1 $ip &>/dev/null
        if [ $? -eq 0 ];then
                echo "$ip"
                expect <<-EOF
                set timeout 10
                spawn ssh-copy-id $ip
                expect {
                        "yes/no" { send "yes\r"; exp_continue }
                        "*password:" { send "redhat\r" }
                }
                expect eof
                EOF
        fi
        }&
done
wait
echo "finish........"

```

## 3.批量远程修改各个主机的基本配置

做这个前提需要做一下公钥推送，否则需要进行交互

```
#!/bin/bash
#--------------------批量远程修改各个主机的基本配置-------------------------
for ip in $(cat ip.txt)
do
        ping -c1 -W1 $ip &>/dev/null
        {
        if [ $? -eq 0 ];then
                ssh $ip "sed -ri '/^UseDns/c\UseDns no' /etc/ssh/sshd_config"
                ssh $ip "sed -ri '/^GSSAPIAuthentication/c\GSSAPIAuthentication no' /etc/ssh/sshd_config"
                ssh $ip "sed -ri '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config"
                ssh $ip "systemctl stop firewalld; systemctl disable firewalld"
                ssh $ip "iptables -F"
                ssh $ip "setenforce 0"
        fi
        }&
done
wait
echo "all finish..."

```


在Linux下面，shell脚本熟练使用，有时候可以帮助我们解决很多需要人工做的事情，有些公司比如阿里，或者京东，集群规模非常大，动辄成百上千台服务器，大量的机器如果需要人工去做某些事情，是非常低效，繁琐，容易出错的，所以每个公司都有自己的一套自动化运维的一套程序，今天，散仙在这里分享的只是利用shell+expect实现的一个自动化的部署，主要有2个功能，批量建立用户和批量配置SSH无密码双向登陆的脚本，在文末散仙，会打包上传这几个脚本，欢迎使用和测试，主要包含的东西：3个脚本外加一个hosts文件和一个使用说明书。

批量建立用户的脚本cuser.sh：
```bash
if [  !  $# -eq 2  ] ; then
echo "请输入用户名和密码以空格分开!"
exit

else
name="$1"
passwd="$2"
fi


cat hosts | while read hosts
do

echo "正在$hosts上用户$name"
expect <<EOF
spawn  ssh $hosts "useradd $name; echo $name:$passwd | chpasswd"
expect {
"*yes/no" {send "yes\r" ;exp_continue}
"*password:" {send "dongliang\r" ;exp_continue  }
}

EOF

echo  "成功建立"

done
```

root用户初始化脚本，initroot.sh 
要安装expect模块


```bash
if [  ! $# -eq 2  ] ;then
echo "请输入用户密码以空格分开"
exit
else
uname="$1"
passwd="$2"
fi



#公钥无ssh认证模块
cat hosts | while read host
do

echo "当前正在向$host上传输ssh文件"
expect <<EOF
spawn  scp -r .ssh/  $host:/$uname
expect {
"*yes/no" {send "yes\r" ;exp_continue}
"*password:" {send "$passwd\r" ;exp_continue  }
}

EOF

echo "当前正在$host上进行公钥认证....."
sleep 2
expect <<EOF
spawn  ssh-copy-id  -i .ssh/id_rsa.pub $host
expect {
"*yes/no" {send "yes\r" ;exp_continue}
"*password:" {send "$passwd\r" ;exp_continue  }
}

EOF

echo "认证成功...."

done

#切换root权限进行hosts文件分发

echo "同步本机的hosts文件到各个机器上"

sleep 1

#同步本机的hosts文件到其他各个机器上

cat hosts | while read host
do

scp -r /etc/hosts $host:/etc/


done

echo "同步hosts文件完毕"

```

