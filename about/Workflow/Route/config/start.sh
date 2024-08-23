mihomo >/dev/null 2>1 &
#!/bin/bash
# https://gist.github.com/Kr328/a81444f46e13c540a9b4c932ad1d482c
# https://github.com/h0cheung/clash-tun-scripts
# https://github.com/nGkp5E76/clash-tun
# https://blog.mmf.moe/post/transparent-proxy-with-mitmproxy/
# https://rook1e.com/blog/my-transparent-proxy-v1/
# https://mritd.com/2022/02/06/clash-tproxy/
# libcap-bin
# 向内核查询 ipset/nftset 需要 CAP_NET_ADMIN 权限，使用非 root 用户身份运行时将产生 Operation not permitted 错误。
# 解决方法有很多，这里介绍其中一种：
# # 授予 CAP_NET_ADMIN 权限
# # 用于执行 ipset/nftset 操作
# sudo setcap cap_net_admin+ep /usr/local/bin/chinadns-ng
# # 授予 CAP_NET_ADMIN + CAP_NET_BIND_SERVICE 权限
# # 用于执行 ipset/nftset 操作、监听小于 1024 的端口
# sudo setcap cap_net_bind_service,cap_net_admin+ep /usr/local/bin/chinadns-ng

# CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
# AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
# sudo setcap cap_net_admin,cap_net_bind_service,cap_net_raw=eip /usr/bin/clash
# sudo capsh --gid=2 --uid=2 --caps=cap_net_admin,cap_net_bind_service,cap_net_raw-eip -- -c "/usr/bin/mihomo"
# capsh --keep=1 --user=clash --caps="cap_net_admin,cap_net_raw+eip" -- -c "/usr/bin/mihomo"

# sudo setcap CAP_NET_ADMIN,CAP_NET_BIND_SERVICE=+ep ./bin
# getcap ./bin

# workdir is ~/.config/mihomo/
# 添加策略与路由表
ip rule add fwmark 666 lookup 666
ip route add local 0.0.0.0/0 dev lo table 666

# clash 链负责处理转发流量
iptables -t mangle -N clash

# 目标地址为局域网或保留地址的流量跳过处理
iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN

# 其他所有流量转向到 7893 端口，并打上 mark
iptables -t mangle -A clash -p tcp -j TPROXY --on-port 7894 --tproxy-mark 666
iptables -t mangle -A clash -p udp -j TPROXY --on-port 7894 --tproxy-mark 666

# 转发所有 DNS 查询到 1053 端口
# 此操作会导致所有 DNS 请求全部返回虚假 IP(fake ip 198.18.0.1/16)
# iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to 1053

# 如果想要 dig 等命令可用, 可以只处理 DNS SERVER 设置为当前内网的 DNS 请求
iptables -t nat -I PREROUTING -p udp --dport 53 -d 192.168.0.0/16 -j REDIRECT --to 1053

# 最后让所有流量通过 clash 链进行处理
iptables -t mangle -A PREROUTING -j clash

# ## 代理网关本机的流量 ##########################################################################################################
# useradd -M -s /usr/sbin/nologin clash
# # clash_local 链负责处理网关本身发出的流量
# iptables -t mangle -N clash_local

# # nerdctl 容器流量重新路由
# #iptables -t mangle -A clash_local -i nerdctl2 -p udp -j MARK --set-mark 666
# #iptables -t mangle -A clash_local -i nerdctl2 -p tcp -j MARK --set-mark 666

# # 跳过内网流量
# iptables -t mangle -A clash_local -d 0.0.0.0/8 -j RETURN
# iptables -t mangle -A clash_local -d 127.0.0.0/8 -j RETURN
# iptables -t mangle -A clash_local -d 10.0.0.0/8 -j RETURN
# iptables -t mangle -A clash_local -d 172.16.0.0/12 -j RETURN
# iptables -t mangle -A clash_local -d 192.168.0.0/16 -j RETURN
# iptables -t mangle -A clash_local -d 169.254.0.0/16 -j RETURN

# iptables -t mangle -A clash_local -d 224.0.0.0/4 -j RETURN
# iptables -t mangle -A clash_local -d 240.0.0.0/4 -j RETURN

# # 为本机发出的流量打 mark
# iptables -t mangle -A clash_local -p tcp -j MARK --set-mark 666
# iptables -t mangle -A clash_local -p udp -j MARK --set-mark 666

# # 跳过 clash 程序本身发出的流量, 防止死循环(clash 程序需要使用 "clash" 用户启动)
# iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner clash -j RETURN
# iptables -t mangle -A OUTPUT -p udp -m owner --uid-owner clash -j RETURN

# # 让本机发出的流量跳转到 clash_local
# # clash_local 链会为本机流量打 mark, 打过 mark 的流量会重新回到 PREROUTING 上
# iptables -t mangle -A OUTPUT -j clash_local

# # 修复 ICMP(ping)
# # 这并不能保证 ping 结果有效(clash 等不支持转发 ICMP), 只是让它有返回结果而已
# # --to-destination 设置为一个可达的地址即可
# sysctl -w net.ipv4.conf.all.route_localnet=1
# iptables -t nat -A PREROUTING -p icmp -d 198.18.0.0/16 -j DNAT --to-destination 127.0.0.1

# # 外网访问内网 docker 问题
# # # 跳过 docker0 的 ip 范围。即跳过 docker 服务的出站数据包
# # sudo iptables -t mangle -A clash -p tcp -s 172.18.0.0/16 -j RETURN

# ## clean ######################3
# ip rule del fwmark 666 table 666 || true
# ip route del local 0.0.0.0/0 dev lo table 666 || true

# iptables -t nat -F
# iptables -t nat -X
# iptables -t mangle -F
# iptables -t mangle -X clash || true
# iptables -t mangle -X clash_local || true
