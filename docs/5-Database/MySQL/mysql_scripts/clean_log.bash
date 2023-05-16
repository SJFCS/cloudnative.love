


apache日志每天进行轮转：

vim /usr/local/apache2/conf/extar/httpd-vhosts.conf
...
ErrorLog "| /usr/local/apache2/bin/rotatelogs -l /usr/local/apache2/logs/error_log-%Y%m%d 86400"
CustomLog "| /usr/local/apache2/bin/rotatelogs -l /usr/local/apache2/logs/access_log-%Y%m%d 86400" common
...

说明：
1. rotatelogs程序是apache自带的一个日志切割工具。 -l参数表示使用本地系统时间为标准切割，而不是GMT时区时间。
2. /usr/local/apache2/logs/access_log-%Y%m%d 86400 
用来指定日志文件的位置和名称，其中86400用来指定分割时间默认单位为s,也就是24小时；



log-server上搭建rsync： ip 10.1.1.2
[root@log-server ~]# cat /etc/rsyncd.conf 
[web1]
path = /web1/logs
uid = root
gid = root
read only = false

[web2]
path = /web2/logs
uid = root
gid = root
read only = false


echo rsync --daemon >> /etc/rc.local


web服务器上定义清理脚本

#!/bin/bash
#clean log
clean_log(){
remote_log_server=10.1.1.2
server=$1
log_dir=/usr/local/apache2/logs
log_tmp_dir=/tmp/log
host=`ifconfig eth0|sed -n '2p'|awk -F'[ :]+' '{print $4}'`


[ ! -d $log_tmp_dir ] && mkdir -p $log_tmp_dir

cd $log_dir
find ./ -daystart -mtime +3 -exec tar -uf $log_tmp_dir/`echo $host`_$(date +%F).tar {} \;
find ./ -daystart -mtime +3 -delete

cd $log_tmp_dir
rsync -a ./ $remote_log_server::$server && find ./ -daystart -mtime +1 -delete
}


jumper-server：

#!/bin/bash
#jumper-server
#菜单打印
trap '' 1 2 3 
menu1(){
	cat <<-END
	请选择对web1的操作类型：
	1. clean_apache_log
	2. reload_apache_service
	3. test_apache_service
	4. remote login
	END
}
menu2(){
cat <<-END
欢迎使用Jumper-server，请选择你要操作的主机：
1. DB1-Master
2. DB2-Slave
3. Web1
4. Web2
5. exit
END
}

push_pubkey(){
ip=$1
# 判断公钥文件是否存在，没有则生成公钥
[ ! -f ~/.ssh/id_rsa.pub ] && ssh-keygen -P "" -f ~/.ssh/id_rsa &>/dev/null
# 安装expect程序，与交互式程序对话（自动应答）
sudo rpm -q expect &>/dev/null
test $? -ne 0 && sudo yum -y install expect
#将跳板机上yunwei用户的公钥推送的指定服务器上
	/usr/bin/expect<<-EOF
	spawn ssh-copy-id -i root@$ip
	expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "111111\r" }
	}
	expect eof
	EOF

}
while true
do
menu2
#让用户选择相应的操作
read -p "请输入你要操作的主机：" host
case $host in
	1)
	ssh root@10.1.1.2
	;;
	2)
	ssh root@10.1.1.3
	;;
	3)
	clear
	menu1
	read -p "请输入你的操作类型:" types
	case $types in
			1)
			ssh root@10.1.1.1 clean_log web1
			test $? -eq 0 && echo "日志清理完毕..."
			;;
			2)
			service apache reload
			;;
			3)
			wget http://10.1.1.1 &>/dev/null
			test $? -eq 0 && echo "该web服务运行正常..." || echo "该web服务无法访问，请检查..."
			;;
			4)
			ssh root@10.1.1.1
			;;
			"")
			:
			;;
	esac
	;;
	5)
	exit
	;;
	*)
	clear
	echo "输入错误，请重新输入..."
	;;
esac
done





