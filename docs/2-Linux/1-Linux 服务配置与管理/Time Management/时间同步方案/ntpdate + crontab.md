---
title: ntpdate + crontab 定时同步
sidebar_position: 1
---

## ntpdate
ntpdate 它允许本地时间与 Internet 上的时间服务器进行一次性的时间同步。它通常配合 crontab 定时任务来对时间进行持续校准。
### 手动同步
```bash title="以 ntp.aliyun.com 时间服务器为例"
sudo ntpdate ntp.aliyun.com 
22 Feb 21:46:44 ntpdate[3645]: step time server 84.16.73.33 offset 85807.801323 sec
```
:::tip
ntpdate 在端口 123 上运行  
如果 ntpdate 启动失败并出现错误 `the NTP socket is in use, exiting` 请做如下排查
- 请确保你的防火墙允许此端口
- 如果安装并运行了 ntpd/chrony 服务，将会占用 ntpdate 工作所需的 123 udp 端口。若不想停止服务则可以使用 `ntpdate -u <ntp-server-addres>` 。
:::

### ntpdate + crontab 定时同步
```bash
sudo ntpdate ntp.aliyun.com 
sudo sh -c 'echo "0 */1 * * * /usr/sbin/ntpdate ntp.aliyun.com  >/dev/null 2>&1" >> /var/spool/cron/root'
timedatectl status && crontab -l
# sudo hwclock -w              # 将系统时间写入 RTC 硬件时钟
```
### 添加开机启动
可以在其他服务启动前同步好时间
```bash
sudo bash -c 'cat << EOF >> /etc/rc.local
/usr/sbin/ntpdate ntp.aliyun.com 
EOF'
sudo chmod +x /etc/rc.d/rc.local
```

:::info
- 由于 `ntpdate` 会直接修改时间，所以会造成时间的跳跃。当 `ntpdate` 发现你的时间快了，则会回调到之前的时间点，导致你的系统经历两个相同的时刻，对某些应用而言，这是致命的。因此，请放弃使用 `ntpdate` 来校时。且 `ntpdate` 无法修正时钟振荡频率，治标不治本。
- 唯一一个可以令时间发生跳跃的时间点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用 `ntpd/Chrony` 来校准时钟，而不是调整计算机时钟上的时间。
- `ntpd` 和`Chrony` 的修正是连续的，通过减慢时钟或者加快时钟的方式连续的修正，会获得平滑的时间校正而不会造成时钟跳跃。并且可以在修正时间的同时，把 BIOS 计时器的振荡频率偏差记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时。
:::

