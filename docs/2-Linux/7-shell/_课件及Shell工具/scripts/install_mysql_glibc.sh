#!/bin/bash
# Name: install_mysql_glibc.sh
# Desc:该脚本用于通用的二进制包mysql的安装，根据自己需求可以自行修改
# Path:课堂笔记目录里
# Usage:./install_mysql_glibc.sh
# Author:MissHou
# Update:2018-07-01
#变量定义
MySQLPro="mysql-5.6.35-linux-glibc2.5-x86_64"
package_name=${MySQLPro}.tar.gz
install_path=/usr/local/mysql/
soft_path=/soft/mysql
tmp_dir=/usr/src

#mysql用户检查
user_fun()
{
echo "###############mysql用户检查，请稍等片刻###############"
username=`grep -w mysql /etc/passwd|cut -d: -f1`
        if [ $username = "mysql" ];then
                echo "mysql用户已经存在."
                return 5
        else
                echo "mysql用户不存在,马上帮您添加用户."
                useradd -s /sbin/nologin mysql
                return 6
        fi
}

#判断mysql是否安装(rpm、source)
package_fun()
{ 
rpm1_name=`rpm -aq |grep mysql-server`
rpm2_name=`rpm -aq|grep MySQL-server`
rpm3_name=`rpm -aq|grep mysql-community-server`
if [ -z "$rpm1_name" -a -z "$rpm2_name" -a -z "$rpm3_name" ];then
   echo "开始检测源码包是否安装,请小憩一会......"
    if [ -d $install_path ];then
	read -p "源码包默认路径:$install_path目录已存在,是否清空该目录?[yes/no]:" choice1
	if [ $choice1 = yes ];then
	pkill -9 mysqld
	rm -rf $install_path/*
	install_fun
	else
           exit 0
        fi  
    else
       echo "本机可以默认安装mysql程序,将为您开始安装$package_name.请稍等......"
        install_fun
    fi
else	
		package1=`echo $rpm1_name`
		package2=`echo $rpm2_name`
		package3=`echo $rpm3_name`
		for i in $package1 $package2 $package3
			do
			test -n "$i" &&  name=`echo $i` 
			done
			echo $name
		read -p "rpm版本mysql已经安装，是否卸载?[yes/no]" choice2
		if [ $choice2 = yes ];then
			rpm -e $name --nodeps
			rm -f /var/log/mysqld.log
			package_fun
		else
			exit 0
		fi
        fi
}

#安装MySQL数据库
install_fun()
{
mkdir -p $install_path &>/dev/null
cd $soft_path

echo "正在解压软件包，请稍等......"
tar xf $package_name -C $tmp_dir/
echo "正在拷贝文件到安装位置，请稍等...."
cp -a $tmp_dir/$MySQLPro/* $install_path/
chown -R mysql:mysql $install_path

#数据库初始化
cd $install_path
echo "正在初始化数据库，请稍等...."
./scripts/mysql_install_db  --datadir=/usr/local/mysql/data --user=mysql

#修改配置文件,这里只是简单举个例子，根据实际情况添加相应配置
cat >> $install_path/my.cnf <<EOF
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
port = 3307
socket = /usr/local/mysql/mysql.sock
EOF


#ServerID=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "IPADDR" | awk -F '.' '{print $4}'`
#echo "server_id=${ServerID}" >> ./my.cnf

#复制启动脚本到/etc/init.d/下
cp support-files/mysql.server /etc/init.d/
chkconfig --add mysql.server

#启动数据库并且开机自启动
chkconfig mysql.server on
service mysql.server start

}


main_install()
{
echo "#***********************************#"
echo "#*******欢迎使用mysql安装脚本*******#"
echo "#*******如有问题请联系管理员********#"
echo "#*******mail:MissHou@itcast.cn******#"
echo "#***********************************#"
sleep 2
#开始执行，调用检测函数
user_fun
test $? -eq 5 && package_fun || package_fun
}
main_install

#环境变量设置
echo "export PATH=/usr/local/mysql/bin:$PATH" >>/etc/profile
source /etc/profile
source /etc/profile
#设置密码
mysqladmin -uroot password '123456' &>/dev/null
echo "数据库管理员root初始密码为:123456,请及时修改密码。"
exit 0
