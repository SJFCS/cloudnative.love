---
title: 一、使用Kubespray部署Kubernetes生产集群

---



遇到的问题：使用代理后部分镜像仍无法拉取，手动清除代理使用国内镜像源拉去并打tag，再次执行虽然nginx镜像存在tag正确但仍会去拉去且拉不下来，我把配置文件里的代理删掉，手动清除代理设置，重新执行就好了。。。。。。。

1、默认使用本地文件 配置在哪里？2、拉去镜像链接配置在哪里

## 2. 系统设置（所有节点）

> 注意：所有操作使用root用户执行

#### 2.1 主机名
主机名必须合法，并且每个节点都不一样（建议命名规范：数字+字母+中划线组合，不要包含其他特殊字符）。
```bash
# 查看主机名
$ hostname
# 修改主机名
$ hostnamectl set-hostname <your_hostname>
```
#### 2.2 关闭防火墙、selinux、swap，重置iptables
```bash
# 关闭selinux
$ setenforce 0
$ sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
# 关闭防火墙
$ systemctl stop firewalld && systemctl disable firewalld

# 设置iptables规则
$ iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT
# 关闭swap
$ swapoff -a && free –h

# 关闭dnsmasq(否则可能导致容器无法解析域名)
$ service dnsmasq stop && systemctl disable dnsmasq
```
#### 2.3 k8s参数设置
```bash
# 制作配置文件
$ cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
vm.overcommit_memory = 0
EOF
# 生效文件
$ sysctl -p /etc/sysctl.d/kubernetes.conf
```
#### 2.4 移除docker相关软件包（可选）
```bash
$ yum remove -y docker*
$ rm -f /etc/docker/daemon.json
```

## 3. 使用kubespray部署集群

这部分只需要在一个 **操作** 节点执行，可以是集群中的一个节点，也可以是集群之外的节点。甚至可以是你自己的笔记本电脑。我们这里使用更普遍的集群中的任意一个linux节点。

#### 3.1 配置免密
使 **操作** 节点可以免密登录到所有节点
```bash
# 1. 生成keygen（执行ssh-keygen，一路回车下去）
$ ssh-keygen
# 2. 查看并复制生成的pubkey
$ cat /root/.ssh/id_rsa.pub
# 3. 分别登陆到每个节点上，将pubkey写入/root/.ssh/authorized_keys
$ mkdir -p /root/.ssh
$ echo "<上一步骤复制的pubkey>" >> /root/.ssh/authorized_keys
```

#### 3.2 依赖软件下载、安装
```bash
# 安装基础软件
$ yum install -y epel-release python36 python36-pip git
# 下载kubespray源码
$ wget https://github.com/kubernetes-sigs/kubespray/archive/v2.15.0.tar.gz
# 解压缩
$ tar -xvf v2.15.0.tar.gz && cd kubespray-2.15.0
# 安装requirements
$ cat requirements.txt
$ pip3.6 install -r requirements.txt

## 如果install遇到问题可以先尝试升级pip
## $ pip3.6 install --upgrade pip   $ pip3 install -U pip
```

#### 3.3 生成配置
项目中有一个目录是集群的基础配置，示例配置在目录inventory/sample中，我们复制一份出来作为自己集群的配置
```bash
# copy一份demo配置，准备自定义
$ cp -rpf inventory/sample inventory/mycluster
```
由于kubespray给我们准备了py脚本，可以直接根据环境变量自动生成配置文件，所以我们现在只需要设定好环境变量就可以啦
```bash
# 使用真实的hostname（否则会自动把你的hostname改成node1/node2...这种哦）
$ export USE_REAL_HOSTNAME=true
# 指定配置文件位置
$ export CONFIG_FILE=inventory/mycluster/hosts.yaml
# 定义ip列表（你的服务器内网ip地址列表，3台及以上，前两台默认为master节点）
$ declare -a IPS=(10.155.19.223 10.155.19.64 10.155.19.147)
# 生成配置文件
$ python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
#### 3.4 个性化配置
配置文件都生成好了，虽然可以直接用，但并不能完全满足大家的个性化需求，比如用docker还是containerd？docker的工作目录是否用默认的/var/lib/docker？等等。当然默认的情况kubespray还会到google的官方仓库下载镜像、二进制文件，这个就需要你的服务器可以上外面的网，想上外网也需要修改一些配置。
```bash
# 定制化配置文件
# 1. 节点组织配置（这里可以调整每个节点的角色）
$ vi inventory/mycluster/hosts.yaml
# 2. containerd配置（教程使用containerd作为容器引擎）
$ vi inventory/mycluster/group_vars/all/containerd.yml
# 3. 全局配置（可以在这配置http(s)代理实现外网访问）
$ vi inventory/mycluster/group_vars/all/all.yml
# 4. k8s集群配置（包括设置容器运行时、svc网段、pod网段等）
$ vi inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
# 5. 修改etcd部署类型为host（默认是docker）
$ vi ./inventory/mycluster/group_vars/etcd.yml
# 6. 附加组件（ingress、dashboard等）
$ vi ./inventory/mycluster/group_vars/k8s-cluster/addons.yml
```

#### 3.5 一键部署
配置文件都调整好了后，就可以开始一键部署啦，不过部署过程不出意外会非常慢。
如果您使用的是教程同一个版本建议下使用网盘下载好二进制文件和镜像
##### 网盘下载二进制（可选）
###### 链接: https://pan.baidu.com/s/11eDin8BDJVzGgXJW9e6cog 提取码: mrj9
下载好之后解压到每个节点的根目录即可，解压完成后的目录是/tmp/releases

##### 一键部署
```bash
# -vvvv会打印最详细的日志信息，建议开启
$ ansible-playbook -i inventory/mycluster/hosts.yaml  -b cluster.yml -vvvv
```
经过漫长的等待后，如果没有问题，整个集群都部署起来啦

###### 下载镜像（可选）
为了减少“一键部署”的等待时间，可以在部署的同时，预先下载一些镜像。
```bash
使用代理可能导致无法访问阿里镜像仓库
$ curl https://gitee.com/pa/pub-doc/raw/master/kubespray-v2.15.0-images.sh|bash -x
```
`重要：此操作需要确保上面的"一键部署"执行后，并成功安装了containerd后即可手动下载镜像）`

#### 3.6 清理代理设置
清理代理设置（运行时不再需要代理，删掉代理配置即可）
##### 删除docker的http代理（在每个节点执行）

```bash
$ rm -f /etc/systemd/system/containerd.service.d/http-proxy.conf
$ systemctl daemon-reload
$ systemctl restart containerd
```
##### 删除yum代理
```bash
# 把grep出来的代理配置手动删除即可
$ grep 8118 -r /etc/yum*
```