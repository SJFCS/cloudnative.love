#!/bin/bash
# Name: xtra_increment2_mysql.sh
# Desc:该脚本使用xtrabackup工具对mysql数据库进行第2次增量备份，根据自己需求可以自行修改
# Path:课堂笔记目录里
# Usage:./xtra_increment2_mysql.sh
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

#增量备份2
increment2_back()
{
#备份
full_name=`cat $xtra_full_dir/full.txt`
increment1_dir=`cat $xtra_increment_dir/increment1.txt`

/usr/bin/innobackupex --user=admin --password=123 --incremental $xtra_increment_dir --incremental-basedir=$increment1_dir &> $xtr_increment_log

increment2_dir=$(ls -d $xtra_increment_dir/$(date +%F)_*)
echo $increment2_dir > $xtra_increment_dir/increment2.txt

#应用日志
echo "+++++++++++++++++++++我是分割符++++++++++++++++" >> $xtr_increment_log

/usr/bin/innobackupex --apply-log $full_name  --incremental_dir=$increment2_dir &>> $xtr_increment_log

}

increment2_back