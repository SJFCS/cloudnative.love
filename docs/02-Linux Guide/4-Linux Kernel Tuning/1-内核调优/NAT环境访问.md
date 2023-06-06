# Linux系统内核配置问题导致NAT环境访问实例出现异常
[linux内核网络参数tcp_tw_recycle 和 tcp_tw_reuse 你搞清楚了吗？](https://blog.csdn.net/u010278923/article/details/102663535)

[不要在linux上启用net.ipv4.tcp_tw_recycle参数](https://www.cnxct.com/coping-with-the-tcp-time_wait-state-on-busy-linux-servers-in-chinese-and-dont-enable-tcp_tw_recycle/)



问题描述
无法通过SSH连接Linux实例，访问该实例上的HTTP服务也出现异常。使用telent命令进行网络测试，发现请求连接被重置。


问题原因
本地网络通过NAT共享的方式上网，并且Linux系统相关内核参数配置异常。


解决方案
修改系统的内核参数以解决该问题。

通过管理终端登录系统。
依次执行如下命令，查看当前内核配置，确认该参数值为“1”。
```bash
cat /proc/sys/net/ipv4/tcp_tw_recycle
cat /proc/sys/net/ipv4/tcp_timestamps
```
在/etc/sysctl.conf配置文件添加如下内容。
```bash
net.ipv4.tcp_tw_recycle=0
net.ipv4.tcp_timestamps=0
```
执行如下命令，使配置生效。
```bash
sysctl -p
```
确认可正常访问该实例。