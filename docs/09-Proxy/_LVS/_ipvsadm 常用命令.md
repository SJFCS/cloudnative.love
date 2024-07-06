# 请求分配结果
ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096) 
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes 
  -> RemoteAddress:Port 
TCP  172.27.233.45:80                   10      50        0     4330        0 
  -> 172.27.233.43:80                    5       25        0     2165        0 
  -> 172.27.233.44:80                    5       25        0     2165        0 

参数含义 
--stats 显示统计信息 
Prot LocalAddress:Port Conns InPkts OutPkts InBytes OutBytes 
                       连接数 输入包 输出包 输入流量 输出流量 

# 实时观察
watch ipvsadm -Ln --stats