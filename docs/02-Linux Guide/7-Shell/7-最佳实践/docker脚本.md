基于7.x YUM安装Docker；
 Docker脚本参数指定CPU、内存、硬盘容量；
 Docker自动检测局域网IP并赋予Docker虚拟机；
 Docker基于pipework指定IP；
 将创建的Docker虚拟机加入至CSV（Excel）或者MYSQL库；
脚本：

```bash
#!/bin/bash
#auto install docker and Create VM
#by jfedu.net 2017
#Define PATH Varablies
IPADDR=`ifconfig|grep -E "\<inet\>"|awk '{print $2}'|grep "192.168"|head -1`
GATEWAY=`route -n|grep "UG"|awk '{print $2}'|grep "192.168"|head -1`
IPADDR_NET=`ifconfig|grep -E "\<inet\>"|awk '{print $2}'|grep "192.168"|head -1|awk -F. '{print $1"."$2"."$3"."}'`
LIST="/root/docker_vmlist.csv"
if [ ! -f /usr/sbin/ifconfig ];then
	yum install net-tools* -y
fi
for i in `seq 1 253`;do ping -c 1 ${IPADDR_NET}${i} ;[ $? -ne 0 ]&& DOCKER_IPADDR="${IPADDR_NET}${i}" &&break;done >>/dev/null 2>&1
echo "##################"
echo -e "Dynamic get docker IP,The Docker IP address\n\n$DOCKER_IPADDR"
NETWORK=(
    HWADDR=`ifconfig eth0|grep ether|awk '{print $2}'`
    IPADDR=`ifconfig eth0|grep -E "\<inet\>"|awk '{print $2}'`
    NETMASK=`ifconfig eth0|grep -E "\<inet\>"|awk '{print $4}'`
    GATEWAY=`route -n|grep "UG"|awk '{print $2}'`
)
if [ -z "$1" -o -z "$2" ];then
	echo -e "\033[32m---------------------------------\033[0m"
	echo -e "\033[32mPlease exec $0 CPU(C) MEM(G),example $0 4 8\033[0m" 
	exit 0
fi
#CPU=`expr $2 - 1`
if [ ! -e /usr/bin/bc ];then
	yum install bc -y >>/dev/null 2>&1
fi
CPU_ALL=`cat /proc/cpuinfo |grep processor|wc -l`
if [ ! -f $LIST ];then
	CPU_COUNT=$1	
	CPU_1="0"
	CPU1=`expr $CPU_1 + 0`
	CPU2=`expr $CPU1 + $CPU_COUNT - 1`
	if [ $CPU2 -gt $CPU_ALL ];then
		echo -e "\033[32mThe System CPU count is $CPU_ALL,not more than it.\033[0m"
		exit
	fi
else
	CPU_COUNT=$1	
	CPU_1=`cat $LIST|tail -1|awk -F"," '{print $4}'|awk -F"-" '{print $2}'`
	CPU1=`expr $CPU_1 + 1`
	CPU2=`expr $CPU1 + $CPU_COUNT - 1`
	if [ $CPU2 -gt $CPU_ALL ];then
		echo -e "\033[32mThe System CPU count is $CPU_ALL,not more than it.\033[0m"
		exit
	fi
fi
MEM_F=`echo $2 \* 1024|bc`
MEM=`printf "%.0f\n" $MEM_F`
DISK=20
USER=$3
REMARK=$4
ping $DOCKER_IPADDR -c 1 >>/dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "\033[32m---------------------------------\033[0m"
	echo -e "\033[32mThe IP address to be used,Please change other IP,exit.\033[0m"
	exit 0
fi
if [ ! -e /usr/bin/docker ];then
	yum install docker* device-mapper* lxc  -y
	mkdir -p /export/docker/
	cd /var/lib/ ;rm -rf docker ;ln -s /export/docker/ .
	mkdir -p /var/lib/docker/devicemapper/devicemapper
	dd if=/dev/zero of=/var/lib/docker/devicemapper/devicemapper/data bs=1G count=0 seek=2000
	service docker start
	if [ $? -ne 0 ];then
		echo "Docker install error ,please check."
		exit 
	fi
fi	

cd  /etc/sysconfig/network-scripts/
    mkdir -p /data/backup/`date +%Y%m%d-%H%M`
    yes|cp ifcfg-eth* /data/backup/`date +%Y%m%d-%H%M`/
if
    [ -e /etc/sysconfig/network-scripts/ifcfg-br0 ];then
	echo
else
    cat >ifcfg-eth0<<EOF
    DEVICE=eth0
    BOOTPROTO=none
    ${NETWORK[0]}
    NM_CONTROLLED=no
    ONBOOT=yes
    TYPE=Ethernet
    BRIDGE="br0"
    ${NETWORK[1]}
    ${NETWORK[2]}
    ${NETWORK[3]}
    USERCTL=no
EOF
    cat >ifcfg-br0 <<EOF
    DEVICE="br0"
    BOOTPROTO=none
    ${NETWORK[0]}
    IPV6INIT=no
    NM_CONTROLLED=no
    ONBOOT=yes
    TYPE="Bridge"
    ${NETWORK[1]}
    ${NETWORK[2]}
    ${NETWORK[3]}
    USERCTL=no
EOF
    /etc/init.d/network restart

fi
echo 'Your can restart Ethernet Service: /etc/init.d/network restart !'
echo '---------------------------------------------------------'

cd -
#######create docker container
service docker status >>/dev/null
if [ $? -ne 0 ];then 
	service docker restart
fi

NAME="Docker_`echo $DOCKER_IPADDR|awk -F"." '{print $(NF-1)"_"$NF}'`"
IMAGES=`docker images|grep -v "REPOSITORY"|grep -v "none"|grep "centos"|head -1|awk '{print $1}'`
if [ -z $IMAGES ];then
	echo "Plesae Download Docker Centos Images,you can to be use docker search centos,and docker pull centos6.5-ssh,exit 0"
	if [ ! -f jfedu_centos68.tar ];then
		echo "Please upload jfedu_centos68.tar for docker server."
		exit
	fi
	cat jfedu_centos68.tar|docker import - jfedu_centos6.8
fi
IMAGES=`docker images|grep -v "REPOSITORY"|grep -v "none"|grep "centos"|head -1|awk '{print $1}'`
CID=$(docker run -itd --privileged --cpuset-cpus=${CPU1}-${CPU2} -m ${MEM}m --net=none --name=$NAME $IMAGES /bin/bash)
echo $CID
docker ps -a |grep "$NAME"
pipework br0 $NAME  $DOCKER_IPADDR/24@$IPADDR
docker exec $NAME /etc/init.d/sshd start
if [ ! -e $LIST ];then
	echo "编号,容器ID,容器名称,CPU,内存,硬盘,容器IP,宿主机IP,使用人,备注" >$LIST
fi
###################
NUM=`cat $LIST |grep -v CPU|tail -1|awk -F, '{print $1}'`
if [[ $NUM -eq "" ]];then
        NUM="1"
else
        NUM=`expr $NUM + 1`
fi
##################	
echo -e "\033[32mCreate virtual client Successfully.\n$NUM `echo $CID|cut -b 1-12`,$NAME,$CPU1-$CPU2,${MEM}M,${DISK}G,$DOCKER_IPADDR,$IPADDR,$USER,$REMARK\033[0m"
if [ -z $USER ];then
	USER="NULL"
	REMARK="NULL"
fi
echo $NUM,`echo $CID|cut -b 1-12`,$NAME,$CPU1-$CPU2,${MEM}M,${DISK}G,$DOCKER_IPADDR,$IPADDR,$USER,$REMARK >>$LIST
rm -rf /root/docker_vmlist_*
iconv -c -f utf-8 -t gb2312 $LIST  -o /root/docker_vmlist_`date +%H%M`.csv

```