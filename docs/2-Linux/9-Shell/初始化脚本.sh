#!/usr/bin/env bash
#192.168.162.41
#192.168.162.42
#192.168.162.43
# 将上面节点ip保存到 ~/nodeslist下
bin=`dirname $0`
bin=`cd "$bin"; pwd`
cd $bin
host_list=$(cat ~/nodeslist)
master_hostip=$(sed -n 1p ~/nodeslist)
ips_no_host=$(sed -n '2,$p' ~/nodeslist)
# 判断当前系统版本，方便用户单独执行
os_version=`sh checkOSVersion.sh`
# 遍历所有节点
# 操作：1.修改时区为上海时区 2.设置开机自启动 3.修改配置文件ntp.cnf
for host in $host_list
do
    # 设置时区
    ssh $host ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    # 开机自启动
    flag=`ssh $host grep -c \"service ntpd restart\" /etc/rc.d/rc.local`
    if [ $flag -eq '0' ]; then
        ssh $host "echo service ntpd restart >> /etc/rc.d/rc.local"
        echo "service ntpd restart in /etc/rc.d/rc.local add successfully!"
    else
        echo "service ntpd restart in /etc/rc.d/rc.local already exist, not need to add."
    fi
    flag=`ssh $host grep -c \"hwclock --systohc\" /etc/rc.d/rc.local`
    if [ $flag -eq '0' ]; then
        ssh $host "echo "hwclock --systohc" >> /etc/rc.d/rc.local"
        echo "hwclock --systohc in /etc/rc.d/rc.local add successfully!"
    else
        echo "hwclock --systohc in /etc/rc.d/rc.local already exist, not need to add."
    fi
    ssh $host "chmod +x /etc/rc.d/rc.local"
    # 安装ntp服务
    ssh $host yum install -y -q ntp
    if [[ $os_version = "centos6" ]];then
        ssh $host "sed -i -e '22 s/^/# /' -i -e '23 s/^/# /' -i -e '24 s/^/# /' -i -e '25 s/^/# /' /etc/ntp.conf"
    else
        ssh $host "sed -i -e '21 s/^/# /' -i -e '22 s/^/# /' -i -e '23 s/^/# /' -i -e '24 s/^/# /' /etc/ntp.conf"
    fi
    flag=`ssh $host grep -c \"server 127.127.1.0\" /etc/ntp.conf`
    if [ $flag -eq '0' ]; then
        ssh $host "echo server 127.127.1.0 >> /etc/ntp.conf"
        echo "server 127.127.1.0 in /etc/ntp.conf add successfully!"
    else
        echo "server 127.127.1.0 in /etc/ntp.conf already exist,not need to add."
    fi
    flag=`ssh $host grep -c \"fudge 127.127.1.0 stratum 10\" /etc/ntp.conf`
    if [ $flag -eq '0' ]; then
        ssh $host "echo fudge 127.127.1.0 stratum 10 >> /etc/ntp.conf"
        echo "fudge 127.127.1.0 stratum 10 in /etc/ntp.conf add successfully!"
    else
        echo "fudge 127.127.1.0 stratum 10 in /etc/ntp.conf already exist,not need to add."
    fi
done
# 主节点操作
# 1.重启ntpd 2.硬件时间以系统时间为标准进行同步 3.打印主节点当前系统时间
service ntpd restart
hwclock --systohc
echo -e "\e[0;32;1m==== "$master_hostip"当前系统时间为: ====\e[0m"
date
echo -e "\e[0;32;1m==== "$master_hostip"当前硬件时间为: ====\e[0m"
hwclock
# 从节点操作，开启ntp服务，使用ntpdate命令进行时钟同步
for slave in $ips_no_host
do
    echo -e "\e[0;33;1m==== 开始对"$slave"进行时钟同步配置 ====\e[0m"
    # 将 server 主节点 写入配置文件/etc/ntp.conf中
    flag=`ssh $slave grep -c \"server $master_hostip\" /etc/ntp.conf`
    if [ $flag -eq '0' ]; then
        ssh $slave "echo server $master_hostip >> /etc/ntp.conf"
        echo "server $master_hostip in /etc/ntp.conf add successfully!"
    else
        echo "server $master_hostip in /etc/ntp.conf already exist,not need to add."
    fi
    # 将 restrict 主节点 nomodify notrap noquery 写入配置文件/etc/ntp.conf中
    flag=`ssh $slave grep -c \"restrict $master_hostip nomodify notrap noquery\" /etc/ntp.conf`
    if [ $flag -eq '0' ]; then
        ssh $slave "echo restrict $master_hostip nomodify notrap noquery >> /etc/ntp.conf"
        echo "restrict $master_hostip nomodify notrap noquery in /etc/ntp.conf add successfully!"
    else
        echo "restrict $master_hostip nomodify notrap noquery in /etc/ntp.conf already exist,not need to add."
    fi
    ssh $slave service ntpd restart
    ssh $slave "ntpdate -u $master_hostip"
    echo -e "\e[0;32;1m==== "$slave"当前系统时间为: ====\e[0m"
    ssh $slave "date"
    ssh $slave "hwclock --systohc"
    echo -e "\e[0;32;1m==== "$slave"当前硬件时间为: ====\e[0m"
    ssh $slave "hwclock"
    echo -e "\e[0;33;1m==== 完成对"$slave"的时钟同步配置 ====\e[0m"
done
echo -e "\e[0;32;1m==== 时钟同步配置流程结束 ====\e[0m"