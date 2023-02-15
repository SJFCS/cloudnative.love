---
title: Redis Cluster 集群模式搭建与水平伸缩

categories:
  - 数据库中间件
series: 
  - Redis
lastmod: '2021-08-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---

本文介绍 Redis Cluster自动化部署与水平伸缩



> 本文脚本github地址：https://github.com/SJFCS/Redis-Cluster-Bare-Metal-Deploy-Shell

## Redis集群模式简介

Redis  在3.0版本前只支持单实例模式，可使用 哨兵（sentinel）机制来监控主从模式下各节点之间的状态，来解决单点故障，但没法满足高并发业务的需求，所以，Redis 在 3.0 版本以后就推出了Redis Cluster分布式解决方案，提供了比之前版本的哨兵模式更高的性能与可用性。有效地解决了 Redis 在 分布式 方面的需求，当遇到 单机内存、并发、流量 等瓶颈时，可以采用 Cluster 架构方案达到 负载均衡 的目的。

### Redis sentinel 哨兵模式

![image-20210926081838968](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-10:24:50-image-20210926081838968.png)

在 redis3.0以前的版本要实现集群一般是借助哨兵 （sentinel）工具来监控η aster节点的状态,如果 master节点异常,则会做主从切换,将某一台 slalve作为 master,哨兵的配置略微复杂,并且性能和高可用性等各方面表现一般,特别是在主从切换的瞬间存在**询问瞬断**的情况。

### Redis Cluster 集群模式

![image-20210926082245650](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-10:24:49-image-20210926082245650.png)

redis集群是一个由**多个主从节点群组成的分布式服务器群**,它具有复制、高可用和分片特性。 Redis集群不需要 sentinel哨兵也能完成节点移除和故障转移的功能。需要将毎个节点设置成集群模式,这种集群模式没有中心节点,可水平扩展,据官方文档称可以线性扩展到1000节点。 redis集群的性能和高可用性均优于之前版本的哨兵模式,且作者写的集群部署工具`redis-trib.rb`使得集群配置非常简单。

## Redis Cluster（Bare Metal）部署

### redis一键安装脚本

~~~bash
#!/bin/bash
#########################################################
# Author        : SongJinfeng
# Email         : Song.Jinfeng@outlook.com
# Last modified : 2021-09-26
# Filename      : Redis Cluster（Bare Metal）Deploy.sh
# Description   : 每台Redis Cluster节点都要运行，你可以通过修改Products_Dir和Port实现部署伪分布式集群
#########################################################
# 版本
Redis_VERSION=6.2.5
rvm_version=2.3.0
# 工作目录 下载解压到此
Work_Dir=/usr/local/src
# 安装目录
Products_Dir=/usr/local/redis
# 启动端口
Port=6379
# bind地址
Bind_IP=0.0.0.0
# 跳过初始化 如果构建伪分布式集群 第一次初始化后可将此参数开启加快后续节点部署速度
# skip=1
function install_redis () {
##########################################################初始化过程可能会因为网络问题失败，可调沟通网络手动执行。
if [ $skip = "" ]; then
yum install wget gcc ruby rubygems -y
##########################################更新ruby前需要更新rvm
#wget https://rvm.io/mpapis.asc && gpg2 --import mpapis.asc
#wget https://rvm.io/pkuczynski.asc && gpg2 --import pkuczynski.asc
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
#find / -name rvm -print
#rvm list known
rvm install ${rvm_version}
rvm use ${rvm_version}
ruby --version
#rvm remove 2.0.0
###########################################安装 redis.gem
gem sources -a https://rubygems.org
# 安装最新版需要更新ruby
gem install redis 
#使用3.0.0版本不需要更新ruby
#gem install redis --version 3.0.0
#也可以手动下载redis gem
#wget https://rubygems.global.ssl.fastly.net/gems/redis-3.2.1.gem
#gem install -l ./redis-3.2.1.gem
fi
#################################################################################################
        cd ${Work_Dir}
        if [ ! -f redis-${Redis_VERSION}.tar.gz ]; then
           wget https://download.redis.io/releases/redis-${Redis_VERSION}.tar.gz
        fi
        tar -xvf /usr/local/src/redis-${Redis_VERSION}.tar.gz
        cd redis-${Redis_VERSION}
        mkdir -p ${Products_Dir}/var/data
        make PREFIX=${Products_Dir} install
        rsync -avz redis.conf  ${Products_Dir}
        sed -i 's/daemonize no/daemonize yes/g' ${Products_Dir}/redis.conf
        sed -i 's/^# cluster-enabled yes/cluster-enabled yes/g' ${Products_Dir}/redis.conf
        sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 15000/g' ${Products_Dir}/redis.conf
        sed -i 's/appendonly no/appendonly yes/g' ${Products_Dir}/redis.conf
        sed -i "s/^port 6379/port ${Port}/g" ${Products_Dir}/redis.conf
        sed -i "s/^bind 127.0.0.1 -::1/bind ${Bind_IP}/g" ${Products_Dir}/redis.conf
        sed -i "s@^dir.*@dir ${Products_Dir}/var/data@" ${Products_Dir}/redis.conf
        sed -i "s@pidfile.*@pidfile ${Products_Dir}/var/redis-${Port}.pid@" ${Products_Dir}/redis.conf
        sed -i "s@logfile.*@logfile ${Products_Dir}/var/redis.log@" ${Products_Dir}/redis.conf
        sed -i "s/# cluster-config-file nodes-6379.conf/cluster-config-file nodes-${Port}.conf/g" ${Products_Dir}/redis.conf

 #################################################################################################
}

install_redis
# start
/usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf

echo “Redis节点全部建好后，你可以通过以下命令进行创建集群”
echo “${Products_Dir}/bin/redis-cli --cluster-replicas 1 --cluster create IP:Port”
echo "注意：Redis Cluster最低要求是3个主节点，如果需要集群需要认证，则在最后加入 -a xx 即可。"
echo "旧版本使用redis-trib.rb create --replicas 1 IP:Port"
echo "--replicas 计算方法为master数量÷slave数量"
echo "ip:port 顺序为 主1 主2 主3 从1 从2 从3"
~~~

>**本脚本自动修改了如下参数**
>
>~~~bash
>daemonize yes
>cluster-enabled yes（启动集群模式）
>cluster-node-timeout 15000
>appendonly yes
>
>port {PORT}（每个节点的端口号）
>bind {IP}（绑定当前机器 IP，方便redis集群定位机器，不绑定可能会出现循环查找集群节点机器的情况）
>dir  （数据文件存放位置，伪集群模式要指定不同目录不然会丢失数据）
>pidfile *.pid      （pid 文件要对应）
>cluster-config-file *.conf （配置文件要对应）
>



> **更多配置参考**:
>
> ~~~
> #masterauth "20180408"                        #master设置密码保护，即slave连接master时的密码
> #requirepass "20180408"                       #设置Redis连接密码，如果配置了连接密码，客户端在连接Redis时需要通过AUTH <password>命令提供密码，默认关闭
> appendonly yes                                #打开aof持久化
> appendfilename "appendonly.aof"
> appendfsync everysec                          # 每秒一次aof写
> 注意：
> 上面配置中masterauth和requirepass表示设置密码保护，如果设置了密码，则连接redis后需要执行"auth 20180408"密码后才能操作其他命令。这里我不设置密码。
> #slave
> slaveof 192.168.10.202 6379                  #相对主redis配置，多添加了此行       
> slave-serve-stale-data yes
> slave-read-only yes                          #从节点只读，不能写入
> ~~~

### **伪分布式**

如果你需要伪分布式做测试则可以把 Products_Dir和Port修改为你想要的，从而在一台主机上创建多个redis实例

修改变量后，调用install_redis函数即可

> **例子：**
>
> Products_Dir=/usr/local/redis9001
> Port=9001
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> skype=1
>
> Products_Dir=/usr/local/redis9002
> Port=9002
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis9003
> Port=9003
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis9004
> Port=9004
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis9005
> Port=9005
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis9006
> Port=9006
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf

### redis服务管理脚本

~~~bash
#!/bin/bash
#########################################################
# Author        : SongJinfeng
# Email         : Song.Jinfeng@outlook.com
# Last modified : 2021-09-26
# Filename      : redis-manager.sh
# Description   : redis服务管理脚本，支持参数有 start|stop|status|restart|log|config|pid
#########################################################
# 安装目录
Products_Dir=/usr/local/redis8006
# 启动端口
Port=8006
redis_server=${Products_Dir}/bin/redis-server
redis_cli=${Products_Dir}/bin/redis-cli
redis_benchmark=${Products_Dir}/bin/redis-benchmark
pidfile=${Products_Dir}/var/redis-${Pod}.pid
logfile=${Products_Dir}/var/redis.log
cfgfile=${Products_Dir}/redis.conf
prog="Redis Server"
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
# Source redis
[ -f /etc/sysconfig/redis ] && . /etc/sysconfig/redis

start() {
    [ -x $redis ] || exit 5
    [ -f $conf_file ] || exit 6
    echo -n $"Starting $prog: " && echo
    ${redis_server} ${cfgfile}
    ss -lntp |grep ${Port}
}
  
stop() {
    echo -n $"Stopping $prog: " && echo
#   pid=`cat ${pidfile}`
#   kill ${pid}
    ${redis_cli} -c -p ${Port} shutdown
   ss -lntp |grep ${Port}
}
  
restart() {
    stop
    start
}

log() {
tail -f ${logfile} -n 50
}

config() {
vi ${cfgfile}
}
pid() {
cat ${pidfile}
}
case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    log)
        $1
        ;;
    config)
        $1
        ;;
    pid)
        $1
        ;;     
    *)
        echo $"Usage: $0 {start|stop|status|restart|log|config|pid}"
        exit 2
esac
~~~

### 创建集群

https://www.cnblogs.com/zhoujinyi/p/11606935.html

```bash
${Products_Dir}/bin/redis-cli --cluster-replicas 1 --cluster create 10.0.0.10:9001 10.0.0.10:9002 10.0.0.10:9003 10.0.0.10:9004 10.0.0.10:9005 10.0.0.10:9006
```

> 注意：Redis Cluster最低要求是3个主节点，如果需要集群需要认证，则在最后加入 -a xx 即可。
> 旧版本使用`redis-trib.rb create --replicas 1 IP:Port`
> `--replicas` 计算方法为master数量÷slave数量 
> `ip:port` 顺序为 主1 主2 主3 从1 从2 从3

![image-20210926163417769](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-16:34:19-image-20210926163417769.png)

### 集群验证

~~~
集群验证
ps -ef | grep redis
./redis-cli -c -h -p (-c表示集群模式，指定IP和端口)
如：${Products_Dir}/bin/redis-cli -c -h 10.0.0.10 -p 8001
查看集群信息：cluster info 
查看节点列表：cluster nodes
进行数据操作验证
set key value
get key
模拟宕机验证主从切换
关闭集群需要逐个关闭：
${Products_Dir}/bin/redis-cli -c -h 10.0.0.10 -p 800* shutdown
mkdir -p ${Products_Dir}/Redis{6001..6006}/{data,var} ${Products_Dir}/bin/
echo ${Products_Dir}/Redis{6001..6006} | xargs -n 1 cp -v /usr/local/src/redis-${Redis_VERSION}/redis.conf

ps -ef |grep redis
netstat -lunpl |grep 6379
/usr/local/redis/bin/redis-cli
pkill redis-server
/usr/local/redis/bin/redis-cli shutdown
~~~

## 水平扩展与伸缩

### 水平扩展

![image-20210926191417089](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:14:18-image-20210926191417089.png)

#### **我们继续创建2个节点**

>Products_Dir=/usr/local/redis9007
>Port=9007
>install_redis
>/usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
>Products_Dir=/usr/local/redis9008
>Port=9008
>install_redis
>/usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf

#### **添加主节点9007**

使用 add-node 命令新增一个主节点9007(master)，10.0.0.10:9007 新增节点，10.0.0.10:9001已存在节点

```
${Products_Dir}/bin/redis-cli --cluster add-node 10.0.0.10:9007 10.0.0.10:9001

```

![image-20210926192427049](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:24:28-image-20210926192427049.png)

**查询节点**

~~~
root@node1[19:22:14]:~$ ${Products_Dir}/bin/redis-cli  -p 9001
127.0.0.1:9001>  cluster nodes
127.0.0.1:9001>  cluster info
~~~

**结果如下图：**

![image-20210926192243283](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:24:30-image-20210926192243283.png)

> 注意：当添加节点成功以后，新增的节点不会有任何数据，因为它还没有分配任何的slot(hash槽)，我们需要为新节点手工分配hash槽

#### **为新节点手工分配hash槽**

 使用redis-cli命令为8007分配hash槽，找到集群中的任意一个主节点(8001)，对其进行重新分片工作。

~~~
${Products_Dir}/bin/redis-cli --cluster reshard 10.0.0.10:9001
~~~

![image-20210926194314829](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:43:18-image-20210926194314829.png)

**这时候我们再看一下节点信息**

~~~
 ${Products_Dir}/bin/redis-cli  -p 9001
~~~

![image-20210926194423806](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:48:21-image-20210926194423806.png)

#### 添加从节点9008

~~~
${Products_Dir}/bin/redis-cli --cluster add-node 10.0.0.10:9008 10.0.0.10:9001
~~~

**查看集群状态**

可以看到9008是一个master节点，没有被分配任何的hash槽。

~~~
${Products_Dir}/bin/redis-cli --cluster add-node 10.0.0.10:9008 10.0.0.10:9001
~~~

![image-20210926194814942](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:48:16-image-20210926194814942.png)

#### 为此节点指定主节点

我们需要执行**replicate**命令来指定当前从节点的主节点id为哪个

首先需要连接新加的9008节点的客户端，然后使用集群命令进行操作，把当前的9008(slave)节点指定到一个主节点下

~~~
${Products_Dir}/bin/redis-cli  -h 10.0.0.10 -p 9008
cluster nodes
CLUSTER REPLICATE c21c14d1b197652d88d9c8f99390132cf50db6a5
~~~

![image-20210926195253833](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-19:53:23-image-20210926195253833.png)

至此，我们扩展redis集群已经实现

### 水平缩容

#### **删除8008从节点**
 用del-node删除从节点8008，指定删除节点ip和端口，以及节点id

~~~
${Products_Dir}/bin/redis-cli  -h 10.0.0.10 -p 9008
cluster nodes

${Products_Dir}/bin/redis-cli --cluster del-node 10.0.0.10:9008 7ed24c364b3f1c55e1f08c158867a9b6ea55bb1a
~~~

![image-20210926200100403](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-20:01:01-image-20210926200100403.png)

#### 删除9007主节点槽位

我们尝试删除之前加入的主节点8007，这个步骤相对比较麻烦一些，因为主节点的里面是有分配了hash槽的，所以我们这里必须先把8007里的hash槽放入到其他的可用主节点中去，然后再进行移除节点操作，不然会出现数据丢失问题(目前只能把master的数据迁移到一个节点上，暂时做不了平均分配功能)

~~~
${Products_Dir}/bin/redis-cli --cluster reshard 10.0.0.10:9007
How many slots do you want to move (from 1 to 16384)? 1000
What is the receiving node ID? 任意一个master的ID用来接收槽
Source node #1: 9007的ID
Source node #2: done
~~~

![image-20210926201601127](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-20:16:02-image-20210926201601127.png)

**查看节点信息**

发现9007master的槽位为空

至此，我们已经成功的把8007主节点的数据迁移到8001上去了，我们可以看一下现在的集群状态

![image-20210926202053601](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-20:20:55-image-20210926202053601.png)

#### **删除9007主节点**

~~~
${Products_Dir}/bin/redis-cli --cluster del-node 10.0.0.10:9007 c21c14d1b197652d88d9c8f99390132cf50db6a5
~~~

![image-20210926202427920](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-20:24:29-image-20210926202427920.png)

###### 搞定，这就是redis的水平扩展与伸缩，是不是很方便：）。

## Redis Cluster （K8S Operator）部署

**redis-cluster-operator项目地址：**

> https://github.com/ucloud/redis-cluster-operator#deploy-redis-cluster-operator
>
> https://github.com/ucloud/redis-operator
>
> https://github.com/spotahome/redis-operator

![https://raw.githubusercontent.com/ucloud/redis-cluster-operator/master/static/redis-cluster.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/raw.githubusercontent.com/ucloud/redis-cluster-operator/master/static/2021.09.26-22:34:31-redis-cluster.png)

### 创建Redis集群

 Namespace级别的需要更改配置：

~~~
 # if your operator run as cluster-scoped, add this annotations
 # redis.kun/scope: cluster-scoped
 kubectl create -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster
~~~

 【可选】提示：如果集群规模不大，资源少，可以自定义资源，把请求的资源降低

~~~
   kubectl create -f deploy/example/custom-resources.yaml -n redis-cluster
~~~

3、查看集群状态

~~~
 kubectl get distributedrediscluster -n redis-cluster
~~~

### 扩容和卸载Redis集群

1、扩容Redis集群

~~~
  grep "master" deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml

  masterSize: 4

 kubectl replace -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster
~~~

2、卸载集群

~~~
 kubectl delete -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster

  kubectl delete -f deploy/cluster/operator.yaml -n redis-cluster

 kubectl delete -f deploy/cluster/cluster_role_binding.yaml -n redis-cluster

  kubectl delete -f deploy/cluster/cluster_role.yaml -n redis-cluster

 kubectl delete -f deploy/service_account.yaml -n redis-cluster

 kubectl delete -f deploy/crds/redis.kun_redisclusterbackups_crd.yaml -n redis-cluster

 kubectl delete -f deploy/crds/redis.kun_distributedredisclusters_crd.yaml -n redis-cluster
~~~

Operator部署未完待续。。
