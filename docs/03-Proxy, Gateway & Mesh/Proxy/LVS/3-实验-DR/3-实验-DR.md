
# 设置只回答目标IP地址是来访网络接口本地地址的ARP查询请求 
echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore

# 设置对查询目标使用最适当的本地地址.在此模式下将忽略这个IP数据包的源地址并尝试选择与能与该地址通信的本地地址.首要是选择所有的网络接口的子网中外出访问子网中包含该目标IP地址的本地地址. 如果没有合适的地址被发现,将选择当前的发送网络接口或其他的有可能接受到该ARP回应的网络接口来进行发送.
echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce

# 使得上面的配置立即生效
sysctl -p




创建网卡别名与添加路由

只有目的 IP 是本机器中的一员时才会做相应的处理，所以需要添加网卡别名（172.17.0.10是虚拟出来，和我docker容器的ip是通一段 2个server的docker ip是172.17.0.6/7）：




apt-get install network-manager
# 配置虚拟IP
ifconfig lo:0 172.17.0.10 broadcast 172.17.0.10 netmask 255.255.255.255 up
#172.17.0 和docker0 相同网段
# 添加路由，因为本就是相同的网段所以可以不添加该路由
route add -host 172.17.0.10 dev lo:0
service network-manager restart



配置一台 LoadBalancer 环境：

ifconfig eth0:0  172.17.0.10:80 netmask 255.255.255.0 up
# 添加VIP的地址99.188
[root@centos7 ~]# ip a a 192.168.99.188 dev eth0

# 创建集群 端口设为80  轮询模式 rr
ipvsadm -A -t 172.17.0.10:80 -s rr         # 定义集群服务
ipvsadm -a -t 172.17.0.10:80 -r 172.17.0.6 -g # 添加 RealServer1
ipvsadm -a -t 172.17.0.10:80 -r 172.17.0.7 -g # 添加 RealServer2
ipvsadm -l                  # 查看 ipvs 定义的规则
#-g：定义为 DR 模式




vip=192.168.99.188
mask='255.255.255.255'
dev=lo:1
#rpm -q httpd &> /dev/null || yum -y install httpd &>/dev/null
#service httpd start &> /dev/null && echo "The httpd Server is Ready!"
#echo "<h1>`hostname`</h1>" > /var/www/html/index.html


    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ifconfig $dev $vip netmask $mask #broadcast $vip up
    #route add -host $vip dev $dev
    echo "The RS Server is Ready!"
