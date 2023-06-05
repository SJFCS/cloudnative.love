#!/bin/bash
# Name: xtra_back_mysql.sh
# Desc:该脚本使用xtrabackup工具对mysql数据库进行增量备份，根据自己需求可以自行修改
# Path:课堂笔记目录里
# Usage:./xtra_back_mysql.sh
# Author:MissHou
# Update:2018-08-05

# 备份策略：周3、周5、周日全备，周1，周2，周4,周6增备


#变量定义
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
conf_file=/usr/local/mysql/my.cnf
xtra_full_dir=/mydb3307/back_full
xtra_increment_dir=/mydb3307/back_increment
xtr_full_log=/mydb3307/log/full_$(date +%F).log
xtr_increment_log=/mydb3307/log/increment_$(date +%F).log



#全量备份
full_back()
{

#备份
/usr/bin/innobackupex --user=admin --password=123 $xtra_full_dir &> $xtr_full_log
full_name=$(ls -d $xtra_full_dir/$(date +%F)_*)
echo $full_name > $xtra_full_dir/full.txt

#应用日志
echo "++++++++++++++++++++++++我是分割符++++++++++++++++++++++++++" >> $xtr_full_log
/usr/bin/innobackupex --apply-log --redo-only $full_name &>> $xtr_full_log

}

full_back && find $xtra_full_dir -daystart -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null




