#!/bin/bash
# Name: xtra_increment1_mysql.sh
# Desc:该脚本使用xtrabackup工具对mysql数据库进行第1次增量备份，根据自己需求可以自行修改
# Path:课堂笔记目录里
# Usage:./xtra_increment1_mysql.sh
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



#增量备份1
increment1_back()
{
#备份
full_name=`cat $xtra_full_dir/full.txt`
/usr/bin/innobackupex --user=admin --password=123 --incremental $xtra_increment_dir --incremental-basedir=$full_name &> $xtr_increment_log

increment1_dir=$(ls -d $xtra_increment_dir/$(date +%F)_*)
echo $increment1_dir > $xtra_increment_dir/increment1.txt

#应用日志
echo "++++++++++++++++++++++++我是分割符++++++++++++++++++++++++++" >> $xtr_increment_log

/usr/bin/innobackupex --apply-log --redo-only $full_name --incremental_dir=$increment1_dir &>> $xtr_increment_log

}

increment1_back && find $xtra_increment_dir -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null