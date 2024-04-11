---
title: Bind
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

:::tip 参考文档
- http://dns-learning.twnic.net.tw/bind/intro3.html
- https://www.cnblogs.com/f-ck-need-u/p/7367503.html#auto_id_19
:::

Bind 的全名是 Berkeley Internet Name Domain，最初的时候是由加州大学柏克莱分校所发展出来的 BSD UNIX 中的一部份，目前则由 ISC 组织来负责维护与发展。是目前最常用的开源 DNS 服务器软件之一，广泛应用于互联网和企业内部网络中。

## 安装

可以使用以下命令安装并启动 bind9 。

<Tabs>
<TabItem value="Ubuntu/Debian">

```bash
sudo apt-get install bind9
dpkg -L bind9
sudo systemctl enable --now named
```
</TabItem>
<TabItem value="CentOS/RedHat">

```bash
sudo yum install bind
rpm -ql bind
sudo systemctl enable --now named
```
</TabItem>
</Tabs>

## named.conf 配置说明

Bind 的主配置文件为 `/etc/named.conf` 包含4个部分:

- options
- "." 根域的内容
- localhost 的正反解
- 其他 domain 的正反解

### options
该配置文件中只能有一个 options，在这里面用于配置全局项。其中下例中的 directory 指令定义区域数据文件的存放目录。

```bash
options {
    directory "/var/named";
};
```

### "." 根域
```bash
zone "." IN {
    type hint;
    file named.ca;
}
```
只有根区域"."才会设置为hint类型，它提示dns服务器根据其区域数据文件[named.ca](https://www.internic.net/domain/named.root)中的内容去获取根域名地址。



### "localhost"域名
(用于解析localhost为127.0.0.1)和127.0.0.1的方向查找区域。



```bash
zone "localhost" IN {
        type master;
        file "named.localhost";
        allow-update { none; };
};
 
zone "1.0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-update { none; };
};
```

当然，反向查找区域可以定义为域而不是直接定义成主机。例如：

```bash
zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-update { none; };
};
```

:::warning
/etc/named*的属组都是named，且权限要为640。

```bash
chown root:named /etc/named.conf
chmod 640 /etc/named.conf
```

然后使用/usr/sbin/named-checkconf命令来检查下/etc/named.conf文件的配置是否正确，如果不返回任何信息，则表示配置正确。
```bash
named-checkconf
```
:::

### 其他 domain

zone关键字后面接的是域和类，域是自定义的域名。
IN是internet的简称，是bind 9中的默认类，可以省略。
type定义该域的类型是"master | slave | stub | hint | forward"中的哪种，
file定义该域的区域数据文件(区域数据文件的说明见下文)，因为这里是相对路径db.longshuai.com，它的相对路径是相对于/var/named的，也可以指定绝对路径/var/named/db.longshuai.com。

```bash
zone "longshuai.com" IN{
    type master;
    file "db.longshuai.com"
};
```


:::tip 拆分配置文件 include
Bind可以将配置分散在多个文件中。在named.conf中，可以使用include语句来引用其他配置文件，例如：

include "/path/to/other/file.conf";
:::