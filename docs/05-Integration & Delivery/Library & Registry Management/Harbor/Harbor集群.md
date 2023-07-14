---
title: Harbor 部署
---


## **下载软件并解压**

```bash
harbor官网github地址: https://github.com/goharbor/harbor
[root@hdss7-200 src]# tar xf harbor-offline-installer-v1.8.3.tgz -C /opt/
[root@hdss7-200 opt]# mv harbor/ harbor-v1.8.3
[root@hdss7-200 opt]# ln -s /opt/harbor-v1.8.3/ /opt/harbor
```

## **配置**

```bash
[root@hdss7-200 opt]# vi /opt/harbor/harbor.yml
hostname: harbor.test.com
http:
  port: 180
 harbor_admin_password:Harbor12345
data_volume: /data/harbor
log:
    level:  info
    rotate_count:  50
    rotate_size:200M
    location: /data/harbor/logs

[root@hdss7-200 opt]# mkdir -p /data/harbor/logs
```

## **安装docker-compose**

```bash
[root@hdss7-200 opt]# yum install docker-compose -y
```

## **安装harbor**

```
[root@hdss7-200 harbor]# /opt/harbor/install.sh 
```

## **检查harbor启动情况**

```bash
[root@hdss7-200 harbor]# docker-compose ps
[root@hdss7-200 harbor]# docker ps -a
```

## **配置harbor的dns内网解析**

```bash
# [root@hdss7-11 ~]# vi /var/named/test.com.zone
$ORIGIN test.com.
$TTL 600    ; 10 minutes
@           IN SOA  dns.test.com. dnsadmin.test.com. (
                2020110202 ; serial
                10800      ; refresh (3 hours)
                900        ; retry (15 minutes)
                604800     ; expire (1 week)
                86400      ; minimum (1 day)
                )
                NS   dns.test.com.
$TTL 60 ; 1 minute
dns                A    10.4.7.11
harbor             A    10.4.7.200


# 重启服务
systemctl restart named
```

## 安装NGINX并配置

```bash
[root@hdss7-200 harbor]# yum install nginx -y
[root@hdss7-200 harbor]# vi /etc/nginx/conf.d/harbor.test.com.conf
server {
    listen       80;
    server_name  harbor.test.com;

    client_max_body_size 1000m;

    location / {
        proxy_pass http://127.0.0.1:180;
    }
}
[root@hdss7-200 harbor]# nginx -t
[root@hdss7-200 harbor]# systemctl start nginx
[root@hdss7-200 harbor]# systemctl enable nginx
```

## **测试**

**浏览器打开harbor.test.com并**

```bash
[root@hdss7-11 ~]# curl harbor.test.com
```

**浏览器输入：harbor.test.com 用户名：admin 密码：Harbor12345**

**下载镜像并给镜像打tag**

```
[root@hdss7-200 harbor]# docker pull nginx:1.7.9
[root@hdss7-200 harbor]# docker images |grep 1.7.9
[root@hdss7-200 harbor]# docker tag 84581e99d807 harbor.test.com/public/nginx:v1.7.9
```

**登录harbor并上传到仓库**

```
[root@hdss7-200 harbor]# docker login harbor.test.com
[root@hdss7-200 harbor]# docker push harbor.test.com/public/nginx:v1.7.9
```

![image-20210926220538105](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/8.%20Harbor%E9%9B%86%E7%BE%A4/2021.09.26-22:05:40-image-20210926220538105.png)