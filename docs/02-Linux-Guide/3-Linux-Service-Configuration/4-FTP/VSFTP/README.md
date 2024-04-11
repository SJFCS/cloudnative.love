---
title: VSFTP
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';


## VSFTP 安装

可以使用以下命令安装并启动 VSFTP 。

<Tabs>
<TabItem value="Ubuntu/Debian">

```bash
sudo apt-get install vsftpd
dpkg -L vsftpd
sudo systemctl enable --now vsftpd
```
</TabItem>
<TabItem value="CentOS/RedHat">

```bash
sudo yum install vsftpd
rpm -ql vsftpd
sudo systemctl enable --now vsftpd
```
</TabItem>
</Tabs>


## 配置文件
/etc/vsftpd/vsftpd.conf  
http://cn.linux.vbird.org/linux_server/linux_redhat9/0410vsftpd.php#server_vsftpd.conf
```conf
关闭匿名访问
anonymous_enable=NO

限制并发客户端连接数
max_clients=0

限制同一IP地址的并发连接数
max_per_ip=0

开启被动模式
pasv_enable=YES

被动模式最小端口
pasv_min_port=24500(最小10000，10000一下的是服务器的常规端口)

被动模式最大端口
pasv_max_port=24600(最大65535)

被动模式，连接超时
accept_timeout=60

主动模式，连接超时
connect_timeout=60

600秒没有任何操作就端口连接
idle_session_timeout=600

资料传输时，超过500秒没有完成，就断开传输
data_connection_timeout=500
```
