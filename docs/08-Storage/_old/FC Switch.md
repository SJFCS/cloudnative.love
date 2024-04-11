级联 
- https://wenku.baidu.com/view/c0561e7e2f3f5727a5e9856a561252d380eb20c3.html?_wkts_=1686109773675
- https://wenku.baidu.com/view/cbd7884ba8114431b80dd828.html?_wkts_=1686109951601

查看光功率 
- http://blog.chinaunix.net/uid-7703716-id-5755700.html
- https://blog.csdn.net/Pipcie/article/details/107008180

https://wenku.baidu.com/view/36216a3c4a73f242336c1eb91a37f111f1850d21.html?_wkts_=1686109930500

常用命令：
- https://blog.csdn.net/idcbeta/article/details/101123292
- https://blog.csdn.net/hsxbn/article/details/88830766
- https://wenku.baidu.com/view/4bb3951559eef8c75fbfb3df.html?_wkts_=1686109775148
- https://www.doc88.com/p-9955637059122.html

```
2、别名（alias）设置
（1）、新建alias
命令格式：alicreate  [alias名称],[端口号或者wwn设备]
在在为交换机划分zone时，为了方便用户清楚地知道每个端口的用途或接线情况，可以给每个端口或者某几个端口取一个别名。
一个alias中可以同时包含一个或多个端口作为它的成员。每个成员也可以同时属于多个alias。
例：alicreate “alias_name”,”1,2”     //新建别名alias_name，并将交换机1的端口2加入别名alias_name中
alicreate “alias_name”,”1,2;1,4”       //新建别名alias_name，并将端口2、4加入到别名alias_name中
（2）、修改alias
命令格式：aliadd [alias 名称]，[要添加的端口号或设备]
例：aliadd “alias_name”,”1,3”                         //将端口3加入到已有的别名“alias_name”中
aliadd “alias_name”,”1,2”                        //将端口2加入到已有的别名“alias_name”中
（3）、查看、删除alias
例：alishow     //查看alias列表
alidelete “alias_name”                     //删除别名“alias_name”
3、分区（zone）设置
（1）、新建zone
命令格式：zonecreate  [zone名称],[端口号、别名或者wwn设备]
例：zonecreate “zone_name”,”1,2”                       //新建zone “zone_name”，并将端口2加入
zonecreate “zone_name”,”1,2;1,4;1,6’           //新建zone “zone_name”，并将端口2、4、6加入
zonecreate “zone_name”,”alias_1’                 //新建zone “zone_name”，并将别名alias_1加入
zonecreate “zone_name”,”alias_1;alias_2’     //新建zone “zone_name”，并将别名alias_1,alias_2加入
（2）、修改alias
命令格式：createadd [zone名称]，[端口号、别名或者wwn设备]
例：zoneadd “zone_name”,”1,6”                           //将端口6加入到已有的zone“zone_name”
zoneadd “zone_name”,”1,2;1,3”                     //将端口2、3加入到已有的zone“zone_name”
zoneadd “zone_name”,”alias_name”             //将别名“alias_name”加入到已有的zone“zone_name”
zoneadd “zone_name”,”alias_1;alias_2”       //将别名”alias_1””alias_2”加入到已有的 “zone_name”
zoneadd “zone_name”,”1,2;1,4;1,6”             //将端口2、4、6加入到已有的zone“zone_name”
（3）、查看、删除zone
例：zoneshow                                       //查看zone列表
zonedelete “zone_name”               //删除zone“zone_name”
4、创建、管理配置文件
（1）、创建配置文件
命令格式：cfgCreate  [config名称]，[zone_name]
所有的Zone都创建完成后，可以创建Configuration，把需要同时存在的Zone放在一个Configuration中，如果有多套zone划分方案，可以创建多个Configuration存储不同场景下Zone的配置方案，并选择对应的配置使之生效。

例：      cfgcreate  “confg_name”,”zone_1”                        //新建配置文件“confg_name”并将zone”zone_1”加入
cfgcreate  “confg_name”,”zone_1;zone_2”           //新建配置文件“confg_name”并将//zone ”zone_1””zone_2”加入
（2）、使配置文件生效
命令格式：cfgEnable “confg_name”
在创建了一个或多个Configuration后，这些配置都还没有生效，要真正完成区域的划分，还需要指定那个Configuration配置是生效配置，这个工作可以用cfgEnable命令完成。
例：     cfgenable  “confg_name”       //使配置文件“confg_name”生效
（3）、保存配置文件
命令格式： cfgSave
上面做的所有Zone的配置都是存储在内存中的，在交换机重新启动后，配置会丢失。使用cfgSave命令后会把RAM中Zone的配置（包括那个Configuration生效）保存到Flash中，长久保留。
（4）、查看、删除配置文件
例：cfgshow                                   //查看alias列表
cfgdelete “config_name”         //删除配置文件“config_name”
注意：

1、大小写敏感

关于Zoning的配置中使用到的名字，都是大小写敏感的，比如“zone1”和”Zone1”；”cfg1”和”CFG1”都是不同的名字，在配置时应该注意这点。

2、help帮助命令

如果有命令忘记或查询有哪些命令，可以使用help命令提示你如何操作。如：zonehelp提示你如何操作zone。

3、在进行Zone的配置时，应该注意：

（1）、当某个Configuration被激活了后，它的Zone的配置马上会在SAN网络中生效。

（2）、没有却省的Zone。在交换机上启用了zone的功能后，所有不在Zone中的设备都不能相互访问。

（3）、一个设备可以同时属于多个Zone。存储设备有可能会被放到不同的Zone中，同时被多个Zone的主机访问。

```