---
title: ntpd
sidebar_position: 2
---
ntpd 时间同步和配置解析

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
    假设你需要让 ntpd 允许来自 192.168.1.0/24 网段的客户端进行时间同步,并且禁止这些客户端修改 ntpd 的配置，不允许使用 ntpd 的 trap 或控制台命令: `restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap`
   - 参数后面加上 perfer 表示最大优先级
   - 建议您列出至少两个可以进行同步的远程服务器,将本机也加到同步列表中。如果网络出现问题或者远程 NTP 服务器出现故障，则使用 127.0.0.1 ,直到它可以再次开始与远程服务器进行同步。
   - 要缩短初始同步所用的时间，请将 `iburst` 添加到 `server` 命令的末尾
2. 权限设定
   - 格式: restrict address [mask mask] option
   - 一些 DDoS 攻击可以利用 NTP 服务器将流量放大,为了防止你的服务器被卷入这种攻击，建议你将你的服务器配置为只响应你信任的特定服务器的 NTP 请求。  
     ntpq 和 ntpdc 查询可用于放大攻击（详见[CVE-2013-5211](https://access.redhat.com/security/cve/CVE-2013-5211)），不要在可公开访问的系统上删除限制默认命令中的 noquery 选项。
   - 其中地址和掩码指定要对其应用限制的 IP 地址，也可以是 default ，default 就类似 0.0.0.0。
   - restrict -6 表示 IPV6 地址的权限设置。或者省略掩码和子网掩码，指定一个单独的IP地址。
   - 更多 option 选项可以参考 [RedHat-Docs 19.17.1. Configure Access Control to an NTP Service](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd#s2-Configure_Access_Control_to_an_NTP_service)  
    如果 option 完全没有设定，那就表示该 IP (或网域)“没有任何限制”


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

