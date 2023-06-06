---
title: firewalld iptables nftables netfilter ufw
---

- [Ubuntu的防火墙配置-ufw-iptables](https://www.cnblogs.com/ylan2009/articles/2321136.html)
- [CentOS7 防火墙（firewall）的操作命令](https://www.cnblogs.com/leoxuan/p/8275343.html)
- http://www.yunweipai.com/%e9%98%b2%e7%81%ab%e5%a2%99iptables%e6%95%99%e7%a8%8b
- https://www.cnblogs.com/whych/p/9147900.html
- https://ipset.netfilter.org/iptables-extensions.man.html
- [Iptables Tutorial 1.2.2](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html#TRAVERSINGGENERAL)
- [Iptables Tutorial 1.1.19](http://www.faqs.org/docs/iptables/userlandstates.html)

- [路由跟踪表满，日志报错nf_conntrack: table full, dropping packet.](https://www.cnblogs.com/python-cat/p/8489318.html)
- https://www.cnblogs.com/clsn/p/8308678.html
- https://www.cnblogs.com/benjamin77/p/8630295.html
- https://www.zsythink.net/archives/category/%e8%bf%90%e7%bb%b4%e7%9b%b8%e5%85%b3/iptables
- http://www.yunweipai.com/35035.html
- https://www.cnblogs.com/godcrying1202/p/14123971.html
- [iptables DNAT 与 SNAT 详解](https://blog.51cto.com/jafy00/651856)
- https://www.cnblogs.com/liang2580/articles/8400140.html

```
netfilter实际上既可以在L2层过滤，也可以在L3层过滤的。

所以在网桥中一般会有下面的参数，即要求iptables不对bridge的数据进行处理：

# cat >> /etc/sysctl.conf <<EOF
  net.bridge.bridge-nf-call-ip6tables = 0
  net.bridge.bridge-nf-call-iptables = 0
  net.bridge.bridge-nf-call-arptables = 0
  EOF
# sysctl -p /etc/sysctl.conf

或者改用下面的方法解决：

 iptables -t raw -I PREROUTING -i BRIDGE -s x.x.x.x -j NOTRACK.

如果net.bridge.bridge-nf-call-iptables＝1，也就意味着二层的网桥在转发包时也会被iptables的FORWARD规则所过滤，这样就会出现L3层的iptables rules去过滤L2的帧的问题（packets don't cross nat table twice, In the bridging process, you don’t know the outgoing interface so the previous rule doesn’t work. He needs the interface because he’s using MASQUERADE. In the routing process, the packets go to iptables but they never cross NAT tables because the packet already crossed the table in the bridging process.http://www.woitasen.com.ar/2011/09/confusion-using-iptables-nat-and-bridge/），所以涉及一些dnat, snat就不生效了，举个例子，具体表现在openstack中就是metadata服务不好使了。这个说法可参见：https://bugzilla.redhat.com/show_bug.cgi?id=512206
```