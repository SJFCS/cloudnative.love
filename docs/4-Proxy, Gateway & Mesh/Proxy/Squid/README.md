---
title: Squid
---

## squid类似于nginx , haproxy这种代理软件

### 正向代理(生产环境上不能访问互联网的服务器-->通过代理服务器-->访问互联网,下载安装软件)
* nginx自带的功能只支持 http 的正向代理, 不支持https的正向代理,要非常麻烦地下载nginx插件,然后加入该模块,重新编译nginx
* squid自带的功能就支持 http和http的正向代理
* yum可以在 /etc/yum.conf配置文件里面设置 proxy=http://ip:port 通过代理下载安装软件
* curl走代理下载文件  curl --proxy 10.36.72.18:3128 -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

```bash
mkdir -p squid
cat > squid/squid.conf <<EOF
acl SSL_ports port 443
acl Safe_ports port 80      # http
acl Safe_ports port 21      # ftp
acl Safe_ports port 443     # https
acl Safe_ports port 70      # gopher
acl Safe_ports port 210	    # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280	    # http-mgmt
acl Safe_ports port 488     # gss-http
acl Safe_ports port 591     # filemaker
acl Safe_ports port 777     # multiling http
acl CONNECT method CONNECT
http_access allow !Safe_ports
http_access allow CONNECT !SSL_ports
http_access allow localhost manager
http_access allow manager
http_access allow localhost
http_port 3128
cache_dir ufs /var/spool/squid 100 16 256
coredump_dir /var/spool/squid
refresh_pattern ^ftp:     1440  20%  10080
refresh_pattern ^gopher:     1440  0%  1440
refresh_pattern -i (/cgi-bin/|\?)  0  0%  0
refresh_pattern (Release|Packages(.gz)*)$     0  20%  2880
refresh_pattern .     0  20%  4320


cache_mem 64 MB 
maximum_object_size 4 MB 
access_log /var/log/squid/access.log 
http_access allow all
EOF


docker run --name squid -itd --restart=always -p 23128:3128 -v `pwd`/squid/squid.conf:/etc/squid/squid.conf sameersbn/squid:3.5.27-2
# 查看日志 
curl -x localhost:3128 http://www.baidu.com
curl -x localhost:3128 https://www.baidu.com
curl -x localhost:3128 https://www.taobao.com
curl -x localhost:3128 https://www.taobao.com

curl --proxy localhost:3128 http://www.baidu.com
curl --proxy localhost:3128 https://www.baidu.com
curl --proxy localhost:3128 https://www.taobao.com
curl --proxy localhost:3128 https://www.taobao.com

docker exec -it squid cat /var/log/squid/access.log
```

## 在局域网中使用 Squid+Dante-server 搭建 SOCKS5 代理
Squid本身并不支持 SOCKS5 代理，只支持使用 HTTP、HTTPS 等协议进行代理。所以，如果要在局域网中搭建 SOCKS5 代理，就需要配合其他代理软件使用。

有一种方法是使用 Linux 上非常常见的一种工具 dante-server。它是一个开源的 SOCKS5 代理软件，可以和 Squid 配合使用，实现 SOCKS5 代理。

这种方法需要一定的技术水平，需要对 Linux 系统以及 Squid 和 Dante 的配置有一定的了解。


1. 安装 dante-server
在 Linux 上可以使用 yum 或 apt-get 命令进行安装：
```bash
sudo apt-get update
sudo apt-get install dante-server
```
2. 配置 dante-server
配置文件位于 /etc/danted.conf，以下是一个简单配置样例（注意修改 internal 和 external 的 IP 地址）：
```
logoutput: /var/log/socks.log

# 可以通过修改 below 行来更改监听端口
internal: eth0 port = 1080
external: eth0
socksmethod: username
user.privileged: proxy
user.notprivileged: nobody

client pass {
    from: 10.0.0.0/8 port 1-65535 to: 0.0.0.0/0
    log: connect disconnect
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    command: bind connect udpassociate
    log: connect disconnect iooperation
}
```
3. 配置 Squid
在 Squid 的配置文件中，将代理方式切换为 parent 并指定 SOCKS5 代理服务器的地址和端口，示例配置如下：
```bash
cache_peer socks5://127.0.0.1:1080 parent 1080 0 no-query no-digest
```
4. 重启 dante-server 和 squid
```bash
sudo systemctl restart danted
sudo systemctl restart squid
```
这样就可以 在局域网中使用 Squid+Dante-server 搭建 SOCKS5 代理了