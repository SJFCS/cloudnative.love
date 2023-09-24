

# 实验

https://www.cnblogs.com/LyShark/p/11827664.html#_label4
https://juejin.cn/post/6990155717499944990
https://www.modb.pro/db/50712
LVS+Keepalived 简介
在 lvs+keepalived 环境里面，lvs 主要的工作是提供调度算法，把客户端请求按照需求调度在 real 服务器，keepalived 主要的工作是提供 lvs 控制器的一个冗余，并且对 real 服务器做健康检查，发现不健康的 real 服务器，就把它从 lvs 集群中剔除，real 服务器只负责提供服务。
https://www.cnblogs.com/kevingrace/p/5574486.html

ipvsadm -Ln
ipvsadm -Lnc
ipvsadm -Ln --stats --rate


ifconfig siface Svip netmask $mask broadcast Svip up
iptables-F
ipvsadm-A-t $(vip):$(port)-s $scheduler
ipvsadm-a-t $(vip):$(port)-r $(rs1)stype-w 1
ipvsadm-a-t $(vip):$(port)-r $(rs2)Stype-w 1

| 资源                    | 地址          |
| ----------------------- | ------------- |
| Virtual IP              | 192.168.1.100 |
| LoadBalancer-LVS-Master | 192.168.1.10  |
| LoadBalancer-LVS-Slave  | 192.168.1.20  |
| Real-Server-1           | 192.168.1.30  |
| Real-Server-2           | 192.168.1.40  |





安装 ipvsadm 工具

echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/ipv4/ip_forward #1 1 说明此机器已开启内核路由转发




# 添加集群服务
sudo ipvsadm -A -t 10.2.10.10:80 -s rr         #定义集群服务
192.168.100.5:8888  定义集群服务的 IP 地址（VIP） 和端口

-A：添加一个新的集群服务
-t: 使用 TCP 协议
-s: 指定负载均衡调度算法
rr：轮询算法(LVS 实现了 8 种调度算法)

# 添加 Real Server 规则
sudo ipvsadm -a -t 10.2.10.10:80 -r 172.17.0.6 -m 
sudo ipvsadm -a -t 10.2.10.10:80 -r 172.17.0.7 -m 
-a：添加一个新的 RealServer 规则
-t：tcp 协议
-r：指定 RealServer IP 地址
-m：定义为 NAT 
上面命令添加了两个服务器 RealServer1 和 RealServer2

sudo ipvsadm -l                 #查看 ipvs 定义的规则


访问10.2.10.10查看结果
