---
title: DNS 故障排除简介
---
[DNS 故障排除简介](https://www.redhat.com/sysadmin/intro-dns-troubleshooting)
## nslookup
查询域名对应的 IP 地址：
```
nslookup example.com
```
查询域名对应的 MX 记录：
```
nslookup -query=mx example.com
```
查询域名服务器的 SOA 记录：
```
nslookup -query=soa example.com
```
查询指定 DNS 服务器的记录：
```
nslookup example.com 8.8.8.8
```

## dig
查询域名对应的 IP 地址：
```
dig example.com
dig -t A example.com @8.8.8.8 +short
```
反向查找
```
dig -x <IP>
```
查询域名对应的 MX 记录：
```
dig MX example.com
```
查询域名服务器的 SOA 记录：
```
dig SOA example.com
```
查询指定 DNS 服务器的记录：
```
dig example.com @8.8.8.8
```

## host 
后面可接 IP address 或 domain name 来获得对应的 domain name 或 IP。

## dnswalk 
由 name server 检查 DNS zone information，后面接 domain name，不过结束时需加上 "."。
