#!/bin/bash
##########################################################
# Script Name：install_mysql.sh                          #
# Author Name：Baocheng                                  #
# Describe：This Is Install From Source Mysql software.  #
# Created Time：2018-08-17 13:38:06                      #
##########################################################
#
#=================================分割线==============================================
#
## mysql变量配置部分；
## 可根据需求修改变量选择网络自动安装或者本地源码包安装。
## 定制你的mysql;更改变量而无需更改脚本，不修改则使用默认配置。
#
# 是否已经下载源码包,随便写,只要这里有值就会直接找源码包而不是从网络自动下载
mysql_source_tar=
# 使用source_dir变量定义mysql源码包的存放位置；
source_dir=/root/tar
# 使用mysql_link变量定义mysql网络源码下载,下载的网站要写在 "" 中否则shell会认为这是一个文件或者目录；
mysql_link="wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.41.tar.gz"
# 使用mysql_version变量定义mysql版本信息；
mysql_version=mysql-5.6.41
# 使用mysql_to变量定义mysql的解压路径；
mysql_to=/usr/src/
# 使用mysql_boot变量定义mysql启动时的启动命令（默认启动命令service mysqld start）;
mysql_boot=mysqld
# 使用mysql_dir变量定义mysql的安装路径；
mysql_dir=/usr/local/$mysql_version
# 使用mysql_port变量定义mysql的端口号；
mysql_port=3307
# 使用mysql_passwd变量设置mysql密码；此密码只可用于第一次登陆mysql；务必更改！
mysql_passwd=123.com
# 使用rm_anonymous变量设置是否移除匿名用户；y移除/n不移除；默认y移除；
rm_anonymous=yes
# 使用rm_remotely变量设置是否移除root用户远程登录；y移除/n不移除；默认y移除；
rm_remotely=yes
# 使用rm_test变量设置是否移除test测试表；y移除/n不移除；默认y移除；
rm_test=yes
# 是否开启防火墙；y开启/n不开启；默认y开启；
mysql_iptables=y
# 使用network变量定义对外网卡的名称；
network=eth0
# 使用mysql_tar变量定义mysql源码包名称(支持gz、bz、bz2、xz压缩方式的源码包)；
mysql_tar=$mysql_version.tar.gz
# 使用mysql_data变量定义mysql数据文件(表、库等)的存储路径；
mysql_data=$mysql_dir/data
# 使用mysql_sock变量定义mysql启动时产生的.sock的文件存放位置；
mysql_sock=$mysql_data/mysql.sock
# 使用mysql_cnf变量定义mysql启动时产生的my.cnf
mysql_cnf=$mysql_dir/my.cnf
# 使用log_err变量来指定mysql的错误日志路径；
log_error=$mysql_data/mysql.log.err
# 使用log_bin变量来指定mysql的binlog日志存放路径；
log_bin=$mysql_data/mybinlog
# 使用relay_log变量来指定relaylog日志存放路径；
relay_log=$mysql_data/relay_log
# 使用install_mysql_log变量定义安装mysql的配置信息存放位置；
install_mysql_log=$source_dir/logs/
# 使用 mysql_file_log变量定义安装mysql的配置导入的文件名称；
mysql_file_log=install_mysql_log
# 安装完成自动登录mysql,有值则自动登录，无值则不自动登录；
log_mysql=y
#
#====================================分割线===========================================
#
## 函数部分；
rely_on(){
clear
echo "正在安装开发工具依赖包，请稍等 ······"
yum groupinstall -y "Development tools" &> /dev/null
if [ $? -eq 0 ];then
echo "已成功安装开发工具包 ！！"
else
echo "安装开发工具依赖包失败,请检查yum源。或者手动安装 "Development tools" 包组 * *"
exit 2
fi
echo "正在安装相关依赖包,请稍等 ······"
yum install -y wget &> /dev/null
if [ $? -eq 0 ];then
	echo "已成功安装 wget 包！！"
else
	echo "安装依赖包 wget 失败,请检查yum源。或者手动安装 "wget" 包"
	exit 2
fi
yum install -y cmake &> /dev/null
if [ $? -eq 0 ];then
	echo "已成功安装 cmake 包！！"
else
	echo "安装依赖包 cmake 失败,请检查yum源。或者手动安装 "cmake" 包"
	exit 2
fi
yum install -y ncurses-devel &> /dev/null
if [ $? -eq 0 ];then
	echo "已成功安装 ncurses-devel 包！！"
else
        echo "安装依赖包 ncurses-devel 失败,请检查yum源。或者手动安装 "ncurses-devel" 包"
	exit 2
fi
yum install -y pcre-devel &> /dev/null
if [ $? -eq 0 ];then
	echo "已成功安装 pcre-devel 包！！"
else
	echo "安装依赖包 pcre-devel 失败,请检查yum源。或者手动安装 "pcre-devel" 包"
	exit 2
fi
yum install -y libcurl-devel &> /dev/null
if [ $? -eq 0 ];then
	echo "已成功安装 libcurl-devel 包！！"
else
        echo "安装依赖包 libcurl-devel 失败,请检查yum源。或者手动安装 "libcurl-devel" 包"
	exit 2
fi
}
to_source(){  
#rm -rf $mysql_to$mysql_version
#rm -rf $mysql_dir$mysql_version
rm -rf /etc/init.d$mysql_boot 
useradd mysql -s /sbin/nologin -M &> /dev/null
mkdir $source_dir -p
mkdir $install_mysql_log/logs -p
cd $source_dir
}
link_source(){
if [ -n "$mysql_source_tar" ];then
	echo "正在解压 mysql 源码包 ！！"
	cd $source_dir
	tar xf $mysql_tar -C $mysql_to &> /dev/null
	#       rm -rf $mysql_tar
	if [ $? -ne 0 ];then
		clear
                echo "==未检测到你的本地源码包=="
                echo "《《请将源码包放在 $source_dir 目录下》》"
                echo "!! 注意：如果源码包的版本不是 $mysql_version 请修改脚本变量 mysql_version 。"
		echo "或者修改脚本变量 mysql_source_tar 。"
		echo "或者这个源码包不可使用或者名字冲突···"
                exit
	fi
	echo "解压完成！！"
fi
if [ -z "$mysql_source_tar" ];then
	ping -c 1 -W 3 www.baidu.com &>/dev/null
	if [ $? -eq 0 ];then
		echo "正在下载 $mysql_version 源码包···"
		cd $source_dir
		rm -rf $mysql_tar
		$mysql_link
		if [ $? -eq 0 ];then
			echo "下载 $mysql_version 源码包完成！！"
		else
			echo "下载 $mysql_version 源码包失败**"
			exit
		fi
		echo "正在解压 mysql 源码包 !!"
		cd $source_dir
		tar xf $mysql_tar -C $mysql_to &> /dev/null
	#	rm -rf $mysql_tar
		if [ $? -eq 0 ];then
			echo "解压完成！！"
		else
			echo "解压失败！！"
			exit
		fi
		#echo "已删除 mysql 源码包!"
	else
        	clear
		echo "==检测到您的网络未连接;这将使用本地源码包=="
        	echo "《《请将源码包放在 $source_dir 目录下》》"
		echo "!! 注意：如果源码包的版本不是 $mysql_version 请修改脚本变量 mysql_version 。"
		exit 2
	fi
fi
}
configure(){
mkdir $mysql_dir -p
cd $mysql_to/$mysql_version
echo "正在配置mysql!!"
cmake . \
-DCMAKE_INSTALL_PREFIX=$mysql_dir/ \
-DMYSQL_DATADIR=$mysql_data \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DSYSCONFDIR=$mysql_dir/etc \
-DMYSQL_UNIX_ADDR=$mysql_sock \
-DSYSCONFDIR=$mysql_cnf \
-DMYSQL_TCP_PORT=$mysql_port \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DMYSQL_USER=mysql
if [ $? -eq 0 ];then
	echo "配置mysql完成！！"
else
	echo "配置mysql失败！！"
	echo "这可能是缺少依赖包，或者环境出现问题，也有可能是包未成功下载，请检查···"
	exit
fi 
echo "即将配置编译安装 mysql；这需要一段时间，请准备咖啡，稍等片刻······"
make
if [ $? -eq 0 ];then
	clear
	echo "编译mysql完成！！"
	echo "正在安装mysql！！"
else
	echo "编译mysql失败！！"
	echo "未知的错误，这可能是环境出现了问题···"
	exit
fi
make install
}
my_conf(){
rm -rf /tmp/my.cnf
rm -rf /etc/my.cnf
rm -rf $mysql_dir/support-files/my.cnf
cat > $mysql_dir/support-files/my.cnf <<EOF
[mysqld]
log_bin = $log_bin
relay-log = $relay_log
basedir = $mysql_dir
datadir = $mysql_data
log-error = $log_error
socket = $mysql_sock
port = $mysql_port
#server_id = 10
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
EOF
cat > /tmp/my.cnf <<EOF
[mysqld]
log_bin = $log_bin
relay-log = $relay_log
basedir = $mysql_dir
datadir = $mysql_data
socket = $mysql_sock
port = $mysql_port
#server_id = 10
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
EOF
}
initial(){
chown -R mysql. $mysql_dir
cd $mysql_dir
scripts/mysql_install_db --user=mysql --basedir=$mysql_dir --datadir=$mysql_data
}
follow(){
cat /etc/profile | grep "PATH=$mysql_dir/bin:\$PATH"
[ $? -ne 0 ] && echo "PATH=$mysql_dir/bin:\$PATH" >> /etc/profile
source /etc/profile
cp $mysql_dir/support-files/mysql.server /etc/init.d/$mysql_boot
chmod +x /etc/init.d/$mysql_boot
cat ~/.bashrc | grep "alias mysql='mysql -S $mysql_sock'"
[ $? -ne 0 ] && echo "alias mysql='mysql -S $mysql_sock'" >> ~/.bashrc
source ~/.bashrc
chkconfig --add --level 35 $mysql_boot
service $mysql_boot start
cd $mysql_dir/bin/
source /etc/profile
source ~/.bashrc
}
secure_mysql(){
mysqladmin password "$mysql_passwd"
{
mysql_anonymous=yes
if [ $rm_anonymous = yes ];then
mysql -uroot -p$mysql_passwd -e "delete from mysql.user where user=''"
mysql_anonymous=no
fi
mysql_remotely=yes
if [ $rm_remotely = yes];then
mysql -uroot -p$mysql_passwd -e "delete from mysql.user where host='%'"
mysql_remotely=no
fi
mysql_test=yes
if [ $rm_test = yes ];then
mysql -uroot -p$mysql_passwd -e "drop database test"
mysql_test=no
fi
mysql -uroot -p$mysql_passwd -e "flush privileges"
} &> /dev/null
}
mysql_iptables(){
v1=
v2=
v3=
sed -i 's/enforcing/disable/' /etc/selinux/config
setenforce 0
v1=`uname -r | awk -F. '{print $4}'`
v2=`test $v1 = el6 &>/dev/null && echo "C6" || echo "C7"`
[ "$v2" = 'C6' ] && v3='Centos 6'
[ "$v2" = 'C7' ] && v3='Centos 7'
if [ "$mysql_iptables" = 'y' ];then
	if [ "$v2" = 'C6' ];then
		iptables -A INPUT -p TCP -i $network --dport $mysql_port --sport 1024:65534 -j ACCEPT # mysql
		/etc/init.d/iptables save &> /dev/null
		[ $? -eq 0 ] && echo "mysql 防火墙规则已经保存!!"
		service iptables restart &> /dev/null
		[ $? -eq 0 ] && echo "重启 iptables 成功！！"
	fi
	if [ $v2 = 'C7' ];then
		yum -y remove firewalld &>/dev/null
		[ $? -eq 0 ] && echo "已将firewalld防火墙卸载！"
		yum -y install iptables-services &>/dev/null
		[ $? -eq 0 ] && echo "安装iptables防火墙，成功！！"
		systemctl enable iptables
		[ $? -eq 0 ] && echo "已将iptables防火墙设置为开机自启动！"
		iptables -A INPUT -p TCP -i $network --dport $mysql_port --sport 1024:65534 -j ACCEPT # mysql
		service iptables save &>/dev/null
		[ $? -eq 0 ] && echo "mysql 防火墙规则已经保存!!"
		service iptables restart &> /dev/null
		[ $? -eq 0 ] && echo "重启 iptables 成功！！"
		sleep 1
	fi
fi
if [ "$mysql_iptables" = 'n' ];then
	if [ "$v2" = 'C6' ];then
		service iptables stop &>/dev/null
		chkconfig iptables off
		echo "已永久关闭iptables防火墙！"
	fi
	if [ "$v2" = 'C7' ];then
		yum -y remove firewalld &>/dev/null
		[ $? -eq 0 ] && echo "已将firewalld防火墙卸载！"
	fi
fi
}
ok_help(){
clear
echo "==========================================="
echo "= you are install software  mysql [OK] !! ="
echo "==========================================="
echo "注意："
echo " > 1.您的数据库密码被设置为 $mysql_passwd ; 默认密码被记录在 $install_mysql_log$mysql_file_log 文件中；"
echo " > 2.默认密码是十分不安全的！请使用命令 mysqladmin -uroot -p$mysql_passwd password 进行修改密码"
echo " > 3.您的 sock 的文件被指定在$mysql_sock 目录下。"
echo " > 4.您的mysql端口为$mysql_port;已为你添加防火墙规则!默认使用iptables防火墙并且会将您的selinux永久关闭!"
echo " > 5.已为你启动mysql;mysql的启动命令为 service $mysql_boot start 。"
echo " > 6.您的mysql安装配置信息已被导入到 $install_mysql_log$mysql_file_log 中。"
}
install_log(){
soft_date=`date -r $mysql_data | gawk -F' ' '{print $1,$2,$3,$5}' | sed 's/ //g'`
cat > $install_mysql_log$mysql_file_log <<-EOF
《《 You are install software MYSQL and configure message 》》
 |
 | > 您的系统版本为：$v3
 |
 | > 软件名称：MySql
 |
 | > 安装方式：编译安装
 | 
 | > 软件版本：$mysql_version
 |
 | > 端口号：$mysql_port
 |
 | > 软件包解压路径：$mysql_to
 |
 | > 软件的安装路径：$mysql_dir
 |
 | > 数据的存储路径：$mysql_data
 |
 | > 软件的启动方式：service $mysql_boot start
 |
 | > .sock文件存放路径：$mysql_sock
 |
 | > 错误日志存储路径：$log_error
 |
 | > binlog存储路径：$log_bin
 |
 | > relaylog存储路径：$relay_log
 |
 | > 添加的防火墙规则：iptables -A INPUT -p TCP -i $network --dport $mysql_port --sport 1024:65534 -j ACCEPT # mysql
 |
 | > 配置文件路径：$mysql_cnf
 |
 | > 允许匿名用户登录：$mysql_anonymous
 |
 | > 允许mysql root 用户远程登录：$mysql_remotely
 |
 | > 是否存在test表：$mysql_test
 |
 | > 默认密码：$mysql_passwd
 |
 | > 软件的安装时间：$soft_date
 |
 | 
EOF
}
#
#==================================分割线=====================================
#
## 脚本部分
# 安装依赖包
rely_on 
# 安装源码包前的环境清理&&准备
to_source
# 网络下载|解压|清理源码包
link_source
# 进入mysql解压目录；配置、编译、安装；
configure
# 清理系统自带my.cnf文件导入自定义my.cnf配置
my_conf
# 更改目录属主属组;初始化 mysql 数据库
initial
# 添加mysql环境变量；添加mysql启动脚本；使用别名方式指定启动mysql的sock的文件；添加mysql自启动；启动mysql;进入mysql_secure_installation文件的目录；
follow
# 配置mysql密码;经过判断是否移除匿名用;禁止root远程登录;删除test表;刷新权限
secure_mysql
# 增加防火墙规则
mysql_iptables 
# 安装完成后提示的信息
ok_help
# 导出安装 mysql 的配置信息
install_log

source /etc/profile
source ~/.bashrc
if [ -n "$log_mysql" ];then
mysql -p123.com
fi