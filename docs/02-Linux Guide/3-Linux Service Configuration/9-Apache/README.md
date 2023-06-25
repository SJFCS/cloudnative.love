## 下面设置两个虚拟主机
- [Apache HTTP Server 2.4 漏洞](https://httpd.apache.org/security/vulnerabilities_24.html)
- 
虚拟主机可以让一个web服务器服务多个网站，每个网站可以有不同的设置，不同的语言，并且有独立的日志

这里假设两个主机分别为

-   game.shaochenfeng.com
-   map.shaochenfeng.com

## 新建配置文件

注意要以conf为扩展名

```
vim /etc/httpd/conf.d/virtual.conf
```

内容为

```
<VirtualHost *:80>
        ServerName game.shaochenfeng.com
        DocumentRoot /var/www/game.shaochenfeng.com
        DirectoryIndex index.html
        ErrorLog logs/game.shaochenfeng.com.error.log
        TransferLog logs/game.shaochenfeng.com.log
</VirtualHost>

<Directory "/var/www/game.shaochenfeng.com">
  Require all granted
</Directory>

<VirtualHost *:80>
        ServerName map.shaochenfeng.com
        DocumentRoot /var/www/map.shaochenfeng.com
        DirectoryIndex index.html
        ErrorLog logs/map.shaochenfeng.com.error.log
        TransferLog logs/map.shaochenfeng.com.log
</VirtualHost>

<Directory "/var/www/map.shaochenfeng.com">
  Require all granted
</Directory>
```

其中第一行中的 `<VirtualHost *:80>` 指定了监听的端口和主机范围

-   ServerName 监听的域名
-   DocumentRoot 网站根目录
-   DirectoryIndex 网站默认文档
-   ErrorLog 错误日志
-   TransferLog 访问日志

后面一部分 `<Directory "/var/www/game.shaochenfeng.com">` 对网站目录进行设置

保存并退出

## 创建虚拟主机的主目录和日志目录

```
mkdir /var/www/game.shaochenfeng.com
mkdir /var/www/map.shaochenfeng.com
#将你的网站文件复制到上面对应的目录
chown apache:apache -R /var/www/game.shaochenfeng.com # httpd运行在apache用户下，所以要给网站文件授予权限
chown apache:apache -R /var/www/map.shaochenfeng.com
```

## 启动并开机启动httpd

```
systemctl enable httpd # 设置httpd开机启动
systemctl start httpd # 启动httpd
systemctl status httpd # 查看httpd状态
```