## linux: hosts.deny+hosts.allow

[![](https://upload.jianshu.io/users/upload_avatars/6146543/926e4ffa-c3c3-4c84-8543-c5af4e3d9e37?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96/format/webp)](https://www.jianshu.com/u/e1b9a125f88b)

0.0872017.11.24 11:12:41字数 760阅读 7,025

##### 一、概述

这两个文件是tcpd服务器的配置文件，tcpd服务器可以控制外部IP对本机服务的访问。这两个配置文件的格式如下：

#服务进程名:主机列表:当规则匹配时可选的命令操作  
`server_name:hosts-list[:command]`  
/etc/hosts.allow控制可以访问本机的IP地址，/etc/hosts.deny控制禁止访问本机的IP。如果两个文件的配置有冲突，以/etc/hosts.deny为准。

/etc/hosts.allow和/etc/hosts.deny两个文件是控制远程访问设置的，通过他可以允许或者拒绝某个ip或者ip段的客户访问linux的某项服务。  
比如SSH服务，我们通常只对管理员开放，那我们就可以禁用不必要的IP，而只开放管理员可能使用到的IP段。

##### 二、配置

1、修改/etc/hosts.allow文件

```
#
# hosts.allow This file describes the names of the hosts which are
# allowed to use the local INET services, as decided
# by the ‘/usr/sbin/tcpd’ server.
#
sshd:210.13.218.*:allow
sshd:222.77.15.*:allow

all:218.24.129.110 #表示接受110这个ip的所有请求！

in.telnetd：140.116.44.0/255.255.255.0
in.telnetd：140.116.79.0/255.255.255.0
in.telnetd：140.116.141.99
in.telnetd：LOCAL
smbd:192.168.0.0/255.255.255.0 #允许192.168.0.网段的IP访问smbd服务

#sendmail:192.168.1.0/255.255.255.0
#pop3d:192.168.1.0/255.255.255.0
#swat:192.168.1.0/255.255.255.0
pptpd:all EXCEPT 192.168.0.0/255.255.255.0
httpd:all
vsftpd:all
```

以上写法表示允许210和222两个ip段连接sshd服务（这必然需要hosts.deny这个文件配合使用），当然:allow完全可以省略的。

ALL要害字匹配所有情况，EXCEPT匹配除了某些项之外的情况，PARANOID匹配你想控制的IP地址和它的域名不匹配时(域名伪装)的情况。

2、修改/etc/hosts.deny文件

```
#
# hosts.deny This file describes the names of the hosts which are
# *not* allowed to use the local INET services, as decided
# by the ‘/usr/sbin/tcpd’ server.
#
# The portmap line is redundant, but it is left to remind you that
# the new secure portmap uses hosts.deny and hosts.allow. In particular
# you should know that NFS uses portmap!
sshd:all:deny

in.telnet：ALL

ALL:ALL EXCEPT 192.168.0.1/255.255.255.0,192.168.1.21,\
202.10.5.0/255.255.255.0
```

注意看：sshd:all:deny表示拒绝了所有sshd远程连接。:deny可以省略。

3、启动服务

注意修改完后：

才能让刚才的更改生效。

\=======================================================

hosts.allow与hosts.deny  
两个文件均在/etc/目录下  
优先级为先检查hosts.deny，再检查hosts.allow，  
后者设定可越过前者限制，

例如：  
1.限制所有的ssh，  
除非从218.64.87.0——127上来。

hosts.deny:

```
in.sshd:ALL
hosts.allow:
in.sshd:218.64.87.0/255.255.255.128
```

2.封掉218.64.87.0——127的telnet

hosts.deny

```
in.sshd:218.64.87.0/255.255.255.128
```

3.限制所有人的TCP连接，除非从218.64.87.0——127访问

hosts.deny

hosts.allow

```
ALL:218.64.87.0/255.255.255.128
```

4.限制218.64.87.0——127对所有服务的访问

hosts.deny

```
ALL:218.64.87.0/255.255.255.128
```

其中冒号前面是TCP daemon的服务进程名称，通常系统  
进程在/etc/inetd.conf中指定，比如in.ftpd，in.telnetd，in.sshd

其中IP地址范围的写法有若干中，主要的三种是：  
1.网络地址——子网掩码方式：  
218.64.87.0/255.255.255.0

2.网络地址方式（我自己这样叫，呵呵）  
218.64.（即以218.64打头的IP地址）

3.缩略子网掩码方式，既数一数二进制子网掩码前面有多少个“1”比如：  
218.64.87.0/255.255.255.0《====》218.64.87.0/24

更多精彩内容，就在简书APP

![](https://upload.jianshu.io/images/js-qrc.png)

"小礼物走一走，来简书关注我"

还没有人赞赏，支持一下

[![  ](https://upload.jianshu.io/users/upload_avatars/6146543/926e4ffa-c3c3-4c84-8543-c5af4e3d9e37?imageMogr2/auto-orient/strip|imageView2/1/w/100/h/100/format/webp)](https://www.jianshu.com/u/e1b9a125f88b)

[随风化作雨](https://www.jianshu.com/u/e1b9a125f88b "随风化作雨")宇宙蜉蝣，银河系和平使者，地球超人，中国好男人，北漂浪人，死宅单身狗

总资产5共写了10.0W字获得154个赞共60个粉丝

-   序言：七十年代末，一起剥皮案震惊了整个滨河市，随后出现的几起案子，更是在滨河造成了极大的恐慌，老刑警刘岩，带你破解...
    
-   1\. 周嘉洛拥有一个不好说有没有用的异能。 异能管理局的人给他的异能起名为「前方高能预警」。 2. 周嘉洛第一次发...
    
-   序言：滨河连续发生了三起死亡事件，死亡现场离奇诡异，居然都是意外死亡，警方通过查阅死者的电脑和手机，发现死者居然都...
    
-   文/潘晓璐 我一进店门，熙熙楼的掌柜王于贵愁眉苦脸地迎上来，“玉大人，你说我怎么就摊上这事。” “怎么了？”我有些...
    
-   文/不坏的土叔 我叫张陵，是天一观的道长。 经常有香客问我，道长，这世上最难降的妖魔是什么？ 我笑而不...
    
-   正文 为了忘掉前任，我火速办了婚礼，结果婚礼上，老公的妹妹穿的比我还像新娘。我一直安慰自己，他们只是感情好，可当我...
    
    [![](https://upload.jianshu.io/users/upload_avatars/4790772/388e473c-fe2f-40e0-9301-e357ae8f1b41.jpeg)茶点故事](https://www.jianshu.com/u/0f438ff0a55f)阅读 7239评论 0赞 61
    
-   文/花漫 我一把揭开白布。 她就那样静静地躺着，像睡着了一般。 火红的嫁衣衬着肌肤如雪。 梳的纹丝不乱的头发上，一...
    
-   那天，我揣着相机与录音，去河边找鬼。 笑死，一个胖子当着我的面吹牛，可吹牛的内容都是我干的。 我是一名探鬼主播，决...
    
-   文/苍兰香墨 我猛地睁开眼，长吁一口气：“原来是场噩梦啊……” “哼！你这毒妇竟也来了？” 一声冷哼从身侧响起，我...
    
-   序言：老挝万荣一对情侣失踪，失踪者是张志新（化名）和其女友刘颖，没想到半个月后，有当地人在树林里发现了一具尸体，经...
    
-   正文 独居荒郊野岭守林人离奇死亡，尸身上长有42处带血的脓包…… 初始之章·张勋 以下内容为张勋视角 年9月15日...
    
    [![](https://upload.jianshu.io/users/upload_avatars/4790772/388e473c-fe2f-40e0-9301-e357ae8f1b41.jpeg)茶点故事](https://www.jianshu.com/u/0f438ff0a55f)阅读 3714评论 1赞 58
    
-   男人动作激烈，情到浓时诛心的话脱口而出，后来他抱着我的骨灰盒说想我…… 1. 双人床上，我在陆翊身下，承受他凶猛的...
    
-   正文 我和宋清朗相恋三年，在试婚纱的时候发现自己被绿了。 大学时的朋友给我发了我未婚夫和他白月光在一起吃饭的照片。...
    
    [![](https://upload.jianshu.io/users/upload_avatars/4790772/388e473c-fe2f-40e0-9301-e357ae8f1b41.jpeg)茶点故事](https://www.jianshu.com/u/0f438ff0a55f)阅读 3932评论 0赞 46
    
-   序言：一个原本活蹦乱跳的男人离奇死亡，死状恐怖，灵堂内的尸体忽然破棺而出，到底是诈尸还是另有隐情，我是刑警宁泽，带...
    
-   正文 年R本政府宣布，位于F岛的核电站，受9级特大地震影响，放射性物质发生泄漏。R本人自食恶果不足惜，却给世界环境...
    
    [![](https://upload.jianshu.io/users/upload_avatars/4790772/388e473c-fe2f-40e0-9301-e357ae8f1b41.jpeg)茶点故事](https://www.jianshu.com/u/0f438ff0a55f)阅读 3771评论 2赞 50
    
-   文/蒙蒙 一、第九天 我趴在偏房一处隐蔽的房顶上张望。 院中可真热闹，春花似锦、人声如沸。这庄子的主人今日做“春日...
    
-   文/苍兰香墨 我抬头看了看天上的太阳。三九已至，却和暖如春，着一层夹袄步出监牢的瞬间，已是汗流浃背。 一阵脚步声响...
    
-   文/米丘 我家的后院里埋着一具尸体，是被我官人打死的。这成了我俩的心病，时不时要去坟头那棵树下拜拜，祈祷着这棵树千...
    
-   我被黑心中介骗来泰国打工， 没想到刚下飞机就差点儿被人妖公主榨干…… 1. 我叫王不留，地道东北人。 一个月前我还...
    
-   正文 我出身青楼，却偏偏与公主长得像，于是被迫代替她去往敌国和亲。 传闻我的和亲对象是个残疾皇子，可洞房花烛夜当晚...
    
    [![](https://upload.jianshu.io/users/upload_avatars/4790772/388e473c-fe2f-40e0-9301-e357ae8f1b41.jpeg)茶点故事](https://www.jianshu.com/u/0f438ff0a55f)阅读 4733评论 0赞 64
    

### 被以下专题收入，发现更多相似内容

### 推荐阅读[更多精彩内容](https://www.jianshu.com/)

-   可以通过配置hosts.allow和hosts.deny来控制访问权限。 他们两个的关系为：/etc/hosts....
    
    [![](https://upload.jianshu.io/users/upload_avatars/48092/6d0f205e-8c4d-4c67-acf6-f6b98c229752.jpg?imageMogr2/auto-orient/strip|imageView2/1/w/48/h/48/format/webp)依然饭太稀](https://www.jianshu.com/u/7efc89de0413)阅读 19,136评论 0赞 1
    
-   ftp 文件传输协议 跨平台 上传下载文件 vsftpd 工具：非常安全的文件传输协议；默认的命令端口21号，数据...
    
    [![](https://cdn2.jianshu.io/assets/default_avatar/6-fd30f34c8641f6f32f5494df5d6b8f3c.jpg)柒夏锦](https://www.jianshu.com/u/4583bc9ff968)阅读 3,577评论 1赞 9
    
-   一、用户帐号和环境……………………………………………………………. 2 二、系统访问认证和授权…………………………...
    
    [![](https://cdn2.jianshu.io/assets/default_avatar/3-9a2bcc21a5d89e21dafc73b39dc5f582.jpg)大福技术](https://www.jianshu.com/u/73a3b3d45f3e)阅读 5,546评论 0赞 5
    
-   dnsmasq是什么我就不说了，请自行百度。 目前我需要使用的用途是：1.dhcp（分配一个或者多个内网ip地址）...
    
-   其实，并不是为了母亲节，才会写一篇关于母亲的文章。 这是我答应母亲的一个小小约定。小时候，我身体不好也特别难带，只...