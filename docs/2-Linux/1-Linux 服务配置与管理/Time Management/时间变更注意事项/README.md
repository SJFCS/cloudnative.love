---
title: 时间变更注意事项
sidebar_position: 3
---

主要涉及到数据备份，时间检查，时间向过去修改、时间向未来修改和 NTPServer 对接配置几个过程，建议严格按照如下流程进行判断和时间修改。
1. 数据备份
2. 时间修改
3. NTPServer对接配置（无NTPServer对接配置可以省略这个步骤）

## 数据备份

集群时间修改存在一定的风险，需要在操作前进行数据备份。

### MySql 备份

1. 找到mysql集群的主节点
2. 获取mysql主节点Pod的IP地址
3. 使用mysqldump命令备份

通过下面可看到：mysql-node2是Master
```bash
root@host:/root# maxadmin list servers
Servers.
-------------------+-----------------+-------+-------------+--------------------
Server             | Address         | Port  | Connections | Status              
-------------------+-----------------+-------+-------------+--------------------
server1            | mysql-node1     |  3306 |         560 | Slave, Running
server2            | mysql-node2     |  3306 |         560 | Master, Running
server3            | mysql-node3     |  3306 |         560 | Slave, Running
-------------------+-----------------+-------+-------------+--------------------
```
通过mysqldump命令备份
```bash
mysqldump -uroot -pcloudos –h<Mysql主节点的IP> --all-databases >mysqlDump_`date +"%Y%m%d_%H%M%S_%s"`.sql
```

### PostgreSQL 备份
    1) 停止PostgreSQL的SVC服务
    2) 重启PostgreSQL的POD
    3) 备份PostgreSQL的数据
    4) 启动PostgreSQL的SVC

停止PostgreSQL的SVC服务，该操作是避免其他服务访问PostgreSQL ，相关命令如下：
```bash
kubectl delete -f /opt/bin/confFile-cluster/postgresql-service.yaml
```
重启PostgreSQL的POD，该操作是端开已经存在的连接，相关命令如下：
```bash
kubectl  scale rc postgresqlrc --replicas=0
kubectl  scale rc postgresqlrc --replicas=1
```
备份postgresql数据，相关命令如下：
```bash
export PGPASSWORD=cloudos;pg_dumpall -U postgres -h <步骤3获取的POD的IP地址> -c -f /root/pg_bak-$(date +%y%m%d%H%M%S).bak
```

## 环境时间检查

修改环境的时间时，需要确定时间是向未来修改，还是向过去修改。时间向过去修改和向未来修改的操作流程是不一样的，因此这个检查非常重要。


### 环境时间向过去修改方案
1. 停止所有服务
2. 修改时间方法：
    方法1： date --set "1/1/09 00:01" 月/日/年时:分:秒）
    方法2：停止ntpd服务后通过ntpdate x.x.x.x修改时间
    ```bash
    [root@e1139h06-m ~]# systemctl stop ntpd.service 
    [root@e1139h06-m ~]# ntpdate 172.25.48.31
    18 Jul 15:10:03 ntpdate[30097]: adjust time server 172.25.48.31 offset 0.000062 sec
    [root@e1139h06-m ~]# systemctl start ntpd.service
    ```

3. 删除基于时间的注册数据
```
[root@e1139h06-m ~]# etcdctl rm /kubeapiMaster
PrevNode.Value: 1139h06up-C2
```
4. 重启所有服务

### 环境时间向未来修改

1. 停止所有服务
2. 修改时间方法：
    方法1： date --set "1/1/09 00:01" 月/日/年时:分:秒）
    方法2：停止ntpd服务后通过ntpdate x.x.x.x修改时间
    ```bash
    [root@e1139h06-m ~]# systemctl stop ntpd.service 
    [root@e1139h06-m ~]# ntpdate 172.25.48.31
    18 Jul 15:10:03 ntpdate[30097]: adjust time server 172.25.48.31 offset 0.000062 sec
    [root@e1139h06-m ~]# systemctl start ntpd.service
    ```
3. 删除基于时间的注册数据
/opt/bin/etcdctl rm /kubeapiMaster
4. **重启kubernetes的网络服务**
    ```bash
    ansible all -m shell -a 'systemctl restart kube-flanneld.service'
    ```
4. 检查kubernetes和容器网络是否一致，如果不一致，**重启不一致节点的docker服务**  
    - Flannel网络与Docker网络一致性检查;  
        检查命令（每个节点执行）：  
        ```bash
        cat /run/flannel/subnet.env && ps -ef | grep bip
        ```
        Flannel网络与Docker网络一致性检查实例，以其中一个节点为例：
        ```bash
        [root@heccloud01 ~]# cat /run/flannel/subnet.env 
        FLANNEL_NETWORK=10.101.0.0/16
        FLANNEL_SUBNET=10.101.44.1/24
        FLANNEL_MTU=1500
        FLANNEL_IPMASQ=false
        [root@heccloud01 ~]# ps -ef | grep bip
        root      3323     1 32 May20 ?        2-17:47:24 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --insecure-registry=172.25.18.103:9999 --bip=10.101.44.1/24 --mtu=1500  --storage-driver=devicemapper --storage-opt dm.datadev=/dev/centos/data --storage-opt dm.metadatadev=/dev/centos/metadata --log-opt max-size=1g --log-opt max-file=2
        root     32322 17022  0 17:14 pts/2    00:00:00 grep --color=auto bip
        ```
5. 所有服务器启动完毕后，启动所有服务