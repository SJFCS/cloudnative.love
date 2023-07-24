Let’s Encrypt和cloudflare自签证书。如果网站加了cdn，则直接使用cloudflare的自签证书最简单；如果网站没有加cdn，那就可以使用Let’s Encrypt申请免费证书了。


使用[acme.sh](https://github.com/acmesh-official/acme.sh)进行ssl申请和自动续约

```bash
curl https://get.acme.sh | sh -s email=你的邮箱
```
必须在你的域名服务商那里设置，把域名映射到你的服务器IP。再使用http方式生成证书，此时必须要保持你的80端口处于闲置(没有被其它应用占用)和开放(防火墙开放80端口)状态。
```bash
acme.sh --issue -d 你的域名 --standalone
```
一切顺利的话，证书就会发布到服务器目录/root/.acme.sh/你的域名/。


本文以demo.example.com为例，详细介绍了使用acme.sh进行ssl申请和自动续约的方法

## 安装

只需要用任意用户执行

```
curl https://get.acme.sh | sh
```

acme.sh 会安装到 `~/.acme.sh/`目录下，并创建新的自动计划（cronjob）在凌晨0点检查所有证书

查看计划任务是否创建，用安装的用户执行 `crontab -l`

如果后面的`acme.sh`命令找不到 用 `~/.acme.sh/acme.sh` 替代

## 生成证书的方式主要有三种

1.  网站文件方式，适合于已经部署好`apache`或是`nginx`服务器的情况
2.  临时监听80端口方式，适合于没有部署好服务的服务器
3.  手动配置DNS，需要有手动配置DNS的权限，适合没有服务器或是不想更改服务器的情况

## 1.文件认证

```
acme.sh  --issue  -d <域名>  --webroot  <网站根目录>
acme.sh  --issue  -d demo.example.com  --webroot /home/wwwroot/demo.example.com/
```

## 2.暂时监听80端口

```
yum install socat # centos
apt install socat # ubuntu
acme.sh --issue -d demo.example.com --standalone
# 如果报错可能需要添加邮箱
acme.sh --register-account -m 邮箱地址
```

## 3\. DNS方式

### 手动方式

首先获得认证需要的解析记录

```
acme.sh --issue --dns -d demo.example.com
```

然后在DNS服务商中添加记录  
最后重新生成证书

```
acme.sh --renew -d demo.example.com
```

使用这种方式 acme.sh 将无法自动更新证书，每次都需要手动再次重新解析验证域名所有权。

### 自动方式

dns 方式的真正强大之处在于可以使用域名解析商提供的 api 自动添加 txt 记录完成验证

首先需要在云上申请有DNS配置权限的账号密码

### 腾讯云

参考：  
[操作方法](https://blog.axis-studio.org/2019/04/05/%E8%85%BE%E8%AE%AF%E4%BA%91%E5%9F%9F%E5%90%8D%E4%BD%BF%E7%94%A8acme-sh%E7%AD%BE%E5%8F%91letsencrypt%E7%9A%84wildcard/index.html)

在dnspod官网上申请  
[https://www.dnspod.cn/Login?r=/console](https://www.dnspod.cn/Login?r=/console)

然后登录远程服务器

```
export DP_Id="1234"
export DP_Key="sADDsdasdgdsf"
acme.sh --issue --dns dns_dp -d demo.example.com
```

### 阿里云

参考：  
[操作方法](https://f-e-d.club/topic/use-acme-sh-deployment-let-s-encrypt-by-ali-cloud-dns-generic-domain-https-authentication.article)

在阿里云官网登录添加拥有DNS配置权限的子账户 [https://ram.console.aliyun.com/overview](https://ram.console.aliyun.com/overview)  
然后登录远程服务器

```
export Ali_Key="AccessKeyId"
export Ali_Secret="AccessKeySecret"
acme.sh --issue --dns dns_ali -d demo.example.com
```

## 证书的安装

默认生成的证书都放在安装目录下: ~/.acme.sh/

需要将证书“拷贝”到自定义位置，方便配置，这里的复制需要用acme.sh的自带工具用于日后自动更新

## apache

以ubuntu为例，

```
mkdir /etc/apache2/ssl/
acme.sh  --install-cert  -d  demo.example.com   \
        --cert-file /etc/apache2/ssl/demo.example.com-cert.pem \
        --key-file   /etc/apache2/ssl/demo.example.com-key.pem \
        --fullchain-file /etc/apache2/ssl/letsencrypt.pem \
        --reloadcmd  "systemctl reload apache2.service"
```

## nginx

```
acme.sh  --installcert  -d  demo.example.com   \
        --key-file   /usr/local/nginx/ssl/demo_example_com.key \
        --fullchain-file /usr/local/nginx/ssl/demo_example_com.cer \
        --reloadcmd  "/usr/local/nginx/sbin/nginx -s reload"
```

## apache服务器的配置

```
vim /etc/apache2/sites-enabled/demo_example_com.conf
<VirtualHost *:443>
   ServerName  demo.example.com
   SSLProxyEngine on
   SSLEngine on
   SSLCertificateFile /etc/apache2/ssl/demo.example.com-cert.pem
   SSLCertificateKeyFile /etc/apache2/ssl/demo.example.com-key.pem
   SSLCertificateChainFile /etc/apache2/ssl/letsencrypt.pem
   SSLCACertificateFile    /etc/apache2/ssl/letsencrypt.pem
</VirtualHost>
```

## nginx服务器的配置

nginx 设置类似如下

```
  server {
        listen 443 ssl;
        ssl on;
        ssl_certificate  /usr/local/nginx/ssl/demo_example_com.cer; # 这里指向证书安装的位置
        ssl_certificate_key  /usr/local/nginx/ssl/demo_example_com.key;
     }
```

## 让你的SSL更安全

参考：https://mikemiao111.com/nginx%E5%A2%9E%E5%BC%BAhttps%E5%AE%89%E5%85%A8%E9%85%8D%E7%BD%AE/

nginx默认采用1024位的加密算法，如果需要的话可以使用2048位的代替，这样可以让加密更安全

首先生成 zjk\_zoollcar\_top.pem 文件到指定目录

```
openssl dhparam -out /usr/local/nginx/ssl/demo_example_com.pem 2048
```

然后在nginx配置文件中设置

```
  server {
        listen 443 ssl;
        ssl on;
        ssl_certificate  /usr/local/nginx/ssl/demo_example_com.cer;
        ssl_certificate_key  /usr/local/nginx/ssl/demo_example_com.key;
        ssl_dhparam  /usr/local/nginx/ssl/demo_example_com.pem; #新增
     }
```

可以用下面的网站测试SSL安全性

[https://www.ssllabs.com/ssltest/](https://www.ssllabs.com/ssltest/)

## 更新 acme.sh

目前由于 acme 协议和 letsencrypt CA 都在频繁的更新, 因此 acme.sh 也经常更新以保持同步.

升级 acme.sh 到最新版 :

如果不想手动升级, 可以开启自动升级:

```
acme.sh  --upgrade  --auto-upgrade
```

之后, acme.sh 就会自动保持更新了.

你也可以随时关闭自动更新:

```
acme.sh --upgrade  --auto-upgrade  0
```

## 相关

acme.sh项目地址  
[https://github.com/acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)

acme.sh作者文档  
[https://github.com/acmesh-official/acme.sh/wiki/](https://github.com/acmesh-official/acme.sh/wiki/)说明