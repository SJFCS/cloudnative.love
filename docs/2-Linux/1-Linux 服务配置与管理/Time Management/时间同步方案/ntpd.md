---
title: ntpd
sidebar_position: 1
---

### 安装配置
- HostA Server 节点，以本地时间对外提供时间服务，且同步外部 NTP Server: **ntp.aliyun.com**
- HostB Client 节点，同步 **HostA**

```bash title="HostA Server 节点"
sudo yum install -y ntp
sudo sed -i -e 's/^server/#&/' \
            -e '1a server ntp.aliyun.com iburst' \
            -e '1a server 127.127.1.0' \
            -e '1a fudge 127.127.1.0 stratum 10' \
            /etc/ntp.conf
sudo systemctl enable --now ntpd
```

```bash title="HostB Client 节点"
sudo yum install -y ntp
sudo sed -i -e 's/^server/#&/' \
            -e '1a <HostA IP> iburst' \
            /etc/ntp.conf
sudo systemctl enable --now ntpd
```
然后使用 `ntpq -p` 命令观察是否同步。`*` 代表当前同步的源

:::caution
如果本机与上源时间相差太大, ntpd 可能不会运行。  
- 可在启动 ntpd 前使用 `sudo ntpdate ntp.aliyun.com` 或 `sudo ntpd -qg` 从上源取得时间初值。(-g 允许第一次调整很大, -q 设置时间后退出进程)  
- 在此处 `cat /etc/sysconfig/ntpd` 加入 `OPTIONS="-g"` 也是有效的
  ```bash
  # Command line options for ntpd
  OPTIONS="-g"
  ```
:::
### 配置解析

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="默认配置">

```bash title='cat /etc/ntp.conf |grep -v -E "^#|^$"'
driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict ::1
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
```

</TabItem>
<TabItem value="配置举例">

```bash
# 使用 Local Time
server 127.127.1.0                      # NTP 主服务器可与自身的系统时钟同步
fudge 127.127.1.0 stratum 10            # 指定阶层编号为10，降低其优先级
restrict 127.0.0.1                      # 不对 127.0.0.1  做任何限制
restrict ::1                            # 不对 ::1 做任何限制

# 指定上层服务器
server ntp.aliyun.com iburst prefer # perfer 表示优先级最高(非必要添加)

logfile /var/log/ntp.log          # 指定日志文件位置
broadcastdelay 0.009              # 广播延迟
# 默认配置
restrict default kod nomodify notrap noquery nopeer # 设置默认策略为允许任何主机进行时间同步,可以进一步缩小范围 restrict 192.168.56.0 mask 255.255.255.0 kod nomodify notrap noquery nopeer 
driftfile /var/lib/ntp/drift      # 为了解决更新时间封包的传送延迟动作，使用 driftfile 来规定我们的主机在与 Time Server 沟通时所花费的时间
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
```
</TabItem>
</Tabs>

1. 上层主机地址
   - 格式: server [IP|HOST Name] [prefer]
   - 参数后面加上 perfer 表示最大优先级
   - 建议您列出至少两个可以进行同步的远程服务器,将本机也加到同步列表中。如果网络出现问题或者远程 NTP 服务器出现故障，则使用 127.0.0.1 ,直到它可以再次开始与远程服务器进行同步。
   - 要缩短初始同步所用的时间，请将 `iburst` 添加到 `server` 命令的末尾
2. 权限设定
   - 格式: restrict address [mask mask] option
   - 一些 DDoS 攻击可以利用 NTP 服务器将流量放大,为了防止你的服务器被卷入这种攻击，建议你将你的服务器配置为只响应你信任的特定服务器的 NTP 请求。  
     ntpq 和 ntpdc 查询可用于放大攻击（详见[CVE-2013-5211](https://access.redhat.com/security/cve/CVE-2013-5211)），不要在可公开访问的系统上删除限制默认命令中的noquery选项。
   - 其中地址和掩码指定要对其应用限制的 IP 地址，也可以是 default ，default 就类似 0.0.0.0。
   - restrict -6 表示 IPV6 地址的权限设置。
   - 或者省略掩码和子网掩码，指定一个单独的IP地址。
   - 更多 option 选项可以参考 [RedHat-Docs 19.17.1. Configure Access Control to an NTP Service](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd#s2-Configure_Access_Control_to_an_NTP_service)  
    如果 option 完全没有设定，那就表示该 IP (或网域)“没有任何限制”
## chrony
[Chrony](https://chrony.tuxfamily.org) 有两个核心组件：一个是 `chronyd` 守护进程，主要用于调整内核中运行的系统时间和时间服务器同步。它确定计算机增减时间的比率，并对此进行调整补偿。另一个是 `chronyc`，它提供一个用户界面，用于监控性能并进行多样化的配置。`chronyc` 可以在 `chronyd` 实例控制的计算机上工作，也可以在一台不同的远程计算机上工作。

- 端口 `123/udp` 为默认 NTP 监听端口，对外提供 NTP 服务，可配置 `port` 参数来修改。
- 端口 `323/udp` 为默认管理端口。可配置 `cmdport` 参数来修改。

:::tip 为什么推荐 Chrony 而不是 NTPD
1. `Chrony` 可以更快的同步只需要几分钟而不是几小时，从而最大程度减少了时间和频率误差，对于并非全天 24 小时运行的虚拟计算机而言非常有用，
2. 能够更好地响应时钟频率的快速变化，对于具备不稳定时钟的虚拟机或导致时钟频率发生变化的节能技术(power-saving technologies)而言非常有用，
3. `Chrony` 无需对服务器进行定期轮询，因此具备间歇性网络连接的系统仍然可以快速同步时
:::

### 安装配置

- HostA Server 以本地时间对外提供时间服务，且同步外部 NTP Server: **ntp.aliyun.com**
- HostB Client 节点同步 **HostA**

:::caution
先确保停止所有节点的 NTPD 服务
```bash
sudo systemctl disable --now ntpd
```
:::

```bash title="HostA Server 节点"
sudo yum install -y chrony

sudo sed -i -e 's/^server/#&/' \
            -e '1a server ntp.aliyun.com iburst minpoll 4 maxpoll 4' \
            -e '1a server 127.127.1.0' \
            -e '1a local stratum 10' \
            -e '1a allow all' \            
            /etc/chrony.conf
#allow 127.0.0.1/8   #新增允许本地客户端访问
#allow x.x.0.0/16    #新增允许集群网网段访问，这里按照要求替换为集群的管理网段。
#local stratum 10  #取消注释，允许同步本地时间
sudo systemctl enable --now chronyd
```

1.  从节点修改Chrony.conf配置文件
```bash title="HostB Client 节点"
sudo sed -i -e 's/^server/#&/' \
            -e '1a server <HostA IP> iburst minpoll 4 maxpoll 4' \
            /etc/chrony.conf
```


### 基本命令

一种是交互式模式，一种是命令行模式。输入 chronyc 回车就进入交互式模式

```bash
# 查看时间同步源服务器的信息
chronyc sources -v          #`*` 代表当前同步的源，`-` 代表通过组合算法计算后排除的源。
# 查看时间同步源状态
chronyc sourcestats -v
# 查看时间同步源在线/离线
chronyc activity
# 在客户端报告已访问到服务器
chronyc clients 
# 检查 NTP 访问是否对特定主机可用
chronyc accheck
# 手动添加一台新的 NTP 服务器
chronyc add server
# 手动移除 NTP 服务器或对等服务器
chronyc delete
# 在客户端报告已访问到服务器
chronyc clients
# 手动设置守护进程时间
chronyc settime
# 校准时间服务器，显示系统时间信息
chronyc tracking
# 强制同步时间
chronyc -a makestep
```

### 参数解释
<Tabs>
<TabItem value="默认配置">

```bash title='cat /etc/chrony.conf  |grep -v -E "^#|^$"'
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
```
</TabItem>
<TabItem value="配置举例">

```bash
server ntp1.aliyun.com 　　　　    # server 指定上层时钟服务器
server ntp.ntsc.ac.cn prefer 　　　# prefer 最高优先级、 iburst 加快第一次时的同步速度,前四次 NTP 请求，会发送一个八个数据包，包间隔通常为2秒,而不是以 minpoll x 指定的最小间隔，可加快初始同步速度。
# 默认的轮询间隔为minpoll 6 代表 64s,maxpoll 9 代表 512s。
# 如果修改默认设定的话，为了保持时间精度，推荐设定比默认的值更小的值。
allow 192.168.0.0/24   # allow/deny NETADD/NETMASK/all 允许/拒绝客户端来同步,allow 0.0.0.0/0代表允许所以任意设备
rtcsync #RTC 时间同步,系统时间每11分钟会拷贝到实时时钟（RTC）
local stratum 10 # 远程 server 不可用时，允许将本地时间作为标准时间授时给其它客户端，层级为 10
driftfile /var/lib/chrony/drift # 记录系统时钟获得/丢失时间的速率，根据实际时间计算出计算机增减时间的比率，将它记录到至drift文件中，会在重启后为系统时钟作出补偿
# makestep # 根据需要通过加速或减慢时钟来逐渐校正任何时间偏移。
makestep 10 3 # 如果系统时钟的偏移量大于10秒，则允许在前三次更新中直接调整系统时钟,通常chronyd将根据需求通过减慢或加速时钟，使得系统逐步纠正所有时间偏差。当时间差过大时,或系统时间漂移过快时，会导致该调整过程消耗很长的时间来纠正系统时钟。该指令会像ntpdate那样直接调整时钟。
keyfile /etc/chrony.keys # 指定包含NTP验证密钥的文件
logdir /var/log/chrony 指定存放日志文件的目录
# stratumweight # 该参数用于设置当 chronyd 从可用源中选择同步源时，每个层应该添加多少距离到同步距离。默认情况下设置为 0，让 chronyd 在选择源时忽略源的层级。
stratumweight 0.05
noclientlog # 禁用客户端访问的日志记录
logchange 0.5 # 如果时钟调整大于0.5秒，则向系统日志发送消息
# cmdallow/cmddeny NETADD/NETMASK/all 可以指定哪台主机可以通过chronyd使用控制命令
cmdallow all
bindcmdaddress 127.0.0.1 #命令管理接口监听的地址，用于接收由chronyc执行的命令
bindcmdaddress ::1
```
</TabItem>
</Tabs>

## 同步硬件时钟
```bash
1 0 * * *  /usr/sbin/hwclock --systohc
```
ntpd: https://www.ibm.com/support/pages/synchronizing-hardware-clock-system-time-when-using-ntp  
chrony: rtcsync RTC 将会每隔11分钟更新 real-time clock(硬件时钟) ，推荐设置此参数。

## 引文
:::info 参考文档
- [RedHat-Docs Chapter 19. Configuring NTP Using ntpd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd)
- [RedHat-Docs Chapter 18. Configuring NTP Using the chrony Suite](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite)
- [Differences Between ntpd and chronyd](https://www.thegeekdiary.com/centos-rhel-7-chrony-vs-ntp-differences-between-ntpd-and-chronyd/)
- [chrony vs. systemd-timesyncd – What are the differences and use cases as NTP clients?](https://unix.stackexchange.com/questions/504381/chrony-vs-systemd-timesyncd-what-are-the-differences-and-use-cases-as-ntp-cli)
:::
:::tip 拓展阅读
- [使用对称密钥配置经过身份验证的 NTP](https://access.redhat.com/solutions/393663)
- [chrony 中的网络时间安全概述(NTS)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/)
- [assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings)
- [The Secure Network Time Protocol (NTPsec) Distribution](https://docs.ntpsec.org/latest/)
- [ntp-server-reachable-but-never-select-set-the-time](https://unix.stackexchange.com/questions/677523/ntp-server-reachable-but-never-select-set-the-time)
:::

## 引文
:::info 参考文档
- [RedHat-Docs Chapter 19. Configuring NTP Using ntpd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd)
:::