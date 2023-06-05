 ftp最早是明文传输的，有很大的安全隐患，因此出现了两种加密方式：

一种是sftp，是使用ssh作为通道传输文件，因为ssh是全程加密的，所以，以ssh作为通道传输ftp也就是安全的。这种方式优点是不再占用20、21端口，只使用22端口就可以完成全部任务，缺点是传送速度慢，尤其是大量小文件的速度极慢

一种是ftps，是ftp协议使用ssl加密的版本，这种方式，使用的端口和ftp一样，只是建立连接后使用ssl加密传输文件，优点是可以独立控制用户密码，有各种高级功能，速度也很快，本文使用的vsftpd就是一个ftp服务器软件




 





## 修改配置文件
参照下面常用参数，修改配置文件 /etc/vsftpd/vsftpd.conf
```
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

## 黑名单与白名单
黑名单与白名单由 serlist_enable 和 userlist_deny 两个参数共同设置
serlist_enable ： 是否启用 user_list 文件
userlist_deny ： 配置user_list为黑名单还是白名单

简单来说，user_list是一个用户列表，根据userlist_enable和userlist_deny两个参数的不同，有不同的作用：

如果 userlist_enable=NO 则user_list文件无效

设置user_list为白名单

userlist_enable=YES
userlist_deny=NO
设置user_list为黑名单

userlist_enable=YES
userlist_deny=YES
超级黑名单 /etc/vsftpd/ftpusers

