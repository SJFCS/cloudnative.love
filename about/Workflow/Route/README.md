---
title: OpenWrt
---
## 扩容
```bash
ssh root@192.168.8.1
# 建分区并格式化 opkg install cfdisk
umount /tmp/mountd/disk1_part1
yes|mkfs.ext4 /dev/mmcblk0p1
# 打开 luci 界面： http://192.168.8.1/cgi-bin/luci/#
# 系统-挂载点-新增（先删除无效的）-已启用-作为外部 overlay 使用（/overlay）-保存
# 注意点保存并应用
reboot
df -h
```
## init
进行简单初始化
```bash
# 打开 luci 界面设置ssh配置： http://192.168.8.1/cgi-bin/luci/#
sed -i s/fw.gl-inet.cn/fw.gl-inet.com/g /etc/opkg/distfeeds.conf
opkg update 
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
opkg install openssh-sftp-server vim tar wget curl   procps-ng-ps	 coreutils-printenv	
sed -i 's|/bin/bash|/bin/ash|' /etc/passwd
bash
```
## country code
在官方4.2版本发布会，对中国区域进行了功能屏蔽，需要更改 country code 来解除（也可以手动破解驱动详见文末）
```bash
uci set board_special.hardware.country_code=US
uci commit board_special
uci -q get board_special.hardware.country_code
```
更换国际化文件 解除web页面对简体中文部分功能选项的屏蔽
```bash
cd /www/i18n/
mkdir back
mv $(ls | grep zh-tw) back/
for file in $(ls | grep zh-cn); do cp "$file" "${file/zh-cn/zh-tw}"; done
sed -i s/繁體中文/简体中文\(解锁\)/g    /www/js/langs-label.json
## 还原
## rm -rf $(ls | grep zh-tw) && cp back/* .
# sed -i s/简体中文\(解锁\)/繁體中文/g    /www/js/langs-label.json
```
## 安装主题 argon theme 
```bash
opkg install luci-compat luci-lib-ipkg jq
curl -sL $(curl -s https://api.github.com/repos/jerrykuku/luci-theme-argon/releases | jq -r '[.[] | select(.tag_name | startswith("v2."))] | sort_by(.created_at) | last | .assets[0].browser_download_url') -o luci-theme-argon.ipk
curl -sL $(curl -sL https://api.github.com/repos/jerrykuku/luci-app-argon-config/releases/latest | jq -r '.assets[0].browser_download_url') -o luci-app-argon-config.ipk
curl -sL $(curl -sL https://api.github.com/repos/jerrykuku/luci-app-argon-config/releases/latest | jq -r '.assets[].browser_download_url' |grep zh-cn) -o luci-i18n-argon-config-zh-cn.ipk

opkg install luci-theme-argon.ipk luci-app-argon-config.ipk /luci-i18n-argon-config-zh-cn.ipk
rm -f luci-theme-argon.ipk luci-app-argon-config.ipk luci-i18n-argon-config-zh-cn.ipk
```
## clash
https://github.com/MetaCubeX/mihomo/releases
gunzip  
/usr/bin/mihomo
/root/.config/mihomo/config.yaml
https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip
```bash
# 添加静态dhcp
http://192.168.8.1/cgi-bin/luci/admin/network/dhcp
# 客户端释放租期 
sudo dhclient -r
# 重新连接wifi
```
## Clash
```bash
#iptables
opkg update
opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin  kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
opkg install iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6
```

## [luci-app-adguardhome](https://github.com/rufengsuixing/luci-app-adguardhome/releases)
```bash
wget https://github.com/rufengsuixing/luci-app-adguardhome/releases/download/1.8-11/luci-app-adguardhome_1.8-11_all.ipk
opkg install luci-app-adguardhome_1.8-11_all.ipk
```

###################################################################################################################
## [luci-app-autoipsetadder](https://github.com/rufengsuixing/luci-app-autoipsetadder)

## adg
```
iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 5353
iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5353
ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 5353
ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5353  


```
```
AdGuard Home被GL.iNet预先配置为监听端口3053的DNS请求，因为端口53已经被路由器上的dnsmasq占用。

当您在路由器的管理面板中启用AdGuardHome时，您基本上告诉它您不想再使用dnsmasq进行DNS，但您希望使用AdGuard Home提供DNS服务（与使用dnsmasq相比，添加了广告拦截）。但是，您的私人家庭网络中的所有设备都已将其DNS请求发送到端口53（dnsmasq）。

因此，当您启用AdGuardHome时，GL.iNet将其配置为添加DNS转发规则，以告诉dnsmasq将DNS请求转发到127.0.0.1（又名此路由器）端口3053（AdGuard Home使用的端口）。您可以通过进入高级管理面板>网络> DHCP和DNS > DNS转发127.0.0.1#3053来查看该转发规则。当您禁用AdGuardHome时，DNS转发规则将消失。

因此，如果您希望每个设备的IP地址都显示在AdGuard Home中，则需要切断中间人（具有DNS转发规则的dnsmasq），而不禁用dnsmasq，因为默认情况下它仍然提供DHCP服务。因此，您希望DNS请求直接从我们的设备发送到AdGuard Home，在这种情况下，不使用dnsmasq的DNS部分。


vi /etc/dnsmasq.conf
port=5300 

vi /etc/AdGuardHome/config.yaml
port: 53 端口：53


```
## 地址加速cdn
```
https://fastly.jsdelivr.net/
https://testingcf.jsdelivr.net/
https://cdn.jsdelivr.net/
https://raw.fastgit.org/
```
## v2raya
- https://github.com/v2raya/v2raya-openwrt
- https://github.com/v2rayA/v2rayA/wiki/openwrt
- https://blog.lzc256.com/post/openwrt-an-zhuang-ruan-jian-bu-xian-shi-zai-fu-wu-li-de-wen-ti
```bash
wget https://liquidtelecom.dl.sourceforge.net/project/v2raya/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03
echo "src/gz v2raya https://liquidtelecom.dl.sourceforge.net/project/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
opkg update
opkg install iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6
opkg install v2raya xray-core v2fly-geoip v2fly-geosite luci-app-v2raya
uci set v2raya.config.enabled='1'
uci commit v2raya
/etc/init.d/v2raya start
# 打开 v2raya 界面： http://192.168.8.1:2017
# 打开 luci-v2raya 界面：  http://192.168.8.1/cgi-bin/luci/admin/services/v2raya 
# 没有菜单就执行下面的
# rm /tmp/luci-indexcache
# rm -rf /tmp/luci-*
# reboot 重启
```
## ddns
这里我是用 Cloudflare DDNS
- [OpenWrt Cloudflare DDNS](https://taoshu.in/unix/openwrt-ddns-cloudflare.html)
```bash
opkg install luci-app-ddns ddns-scripts-cloudflare ddns-scripts-services luci-i18n-ddns-zh-cn
sed -i '1i "cloudflare.com-v4"     "update_cloudflare_com_v4.sh"' /etc/ddns/services
``
# UPnP  
https://thiscute.world/posts/about-nat/#3-upnp-%E5%8A%A8%E6%80%81%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91
opkg install miniupnpd luci-i18n-upnp-zh-cn
```

## tailscale 
 sudo ls /var/lib/tailscale/files/
- https://tailscale.com/kb/1082/firewall-ports/?q=port
- https://www.9bingyin.com/archives/why-i-choose-tailscale.html
- https://www.youtube.com/watch?v=mgDpJX3oNvI
- https://openwrt.org/docs/guide-user/services/vpn/tailscale/start
- https://arthurchiao.art/blog/how-nat-traversal-works-zh/
想要实现直连，需要提升 NET Type 类型。常见的类型包括 Full Cone NAT、Restricted Cone NAT、Port Restricted Cone NAT 和 Symmetric NAT。
- windows 获取当前网络 net 类型： https://github.com/HMBSbige/NatTypeTester
- linux：[ python-pystun3 ](https://pypi.org/project/pystun/) [go-stun](https://github.com/ccding/go-stun)
  - go install github.com/ccding/go-stun@latest
  - go-stun -s stun.qq.com:3478
- https://support.dh2i.com/docs/Archive/kbs/general/understanding-different-nat-types-and-hole-punching/
- web：https://github.com/nthack/NatTypeChecker
- https://jsfiddle.net/5ftsd5c2/17/


```bash 
# 更改端口
sudo vim /etc/default/tailscaled
sudo systemctl daemon-reload
sudo systemctl restart tailscaled.service
```
现有拓扑：`光猫-路由器-设备tailscale` 通过桥接光猫，路由器直接 pppoe 拨号，后拓扑为：`路由器-设备tailscale`
并通过端口转发（443 41641 3478 ）或者DZM主机，继续提升NET Type 类型。
这样设置后即可直连。最终我在公司访问家里设备延迟从几百 ms 降低到 8ms 左右。
关于是否开启 ipv6，目前通过ipv4 udp打洞实现直连，国内对udp存在限速。开启ipv6实现直连可以跑满带宽。但公司一般不支持ipv6，而且开启ipv6还涉及到一些网络安全问题，我暂时关闭了ipv6。如果要设置要是有 passthrough 模式。

```bash
sudo tailscale up --advertise-routes=xxx.xxx.xxx.xxx/24 --accept-routes=false --accept-dns=false
tailscale status
tailscale netcheck
tailscale ping --peerapi otherpi
tailscale ping --c 20 otherpi
```

## 其他
```bash

# 媒体服务器 dlna
opkg install luci-app-minidlna luci-i18n-minidlna-zh-cn

# 局域网共享打印机 https://www.youtube.com/watch?v=6bLS9kwGamc
opkg install kmod-usb-printer p910nd luci-app-p910nd


# SmartDNS  
opkg install smartdns luci-i18n-smartdns-zh-cn 

# wol 网络唤醒
luci-i18n-wol-zh-cn	



# uhttpd
luci-i18n-uhttpd-zh-cn	

# Frp
opkg install \
luci-i18n-frps-zh-cn \
luci-i18n-frpc-zh-cn \
luci-app-frpc \
luci-app-frps \

# VPN
opkg install \
luci-app-wireguard \
luci-app-vpnbypass \
luci-app-vpn-policy-routing \
luci-app-openvpn \
luci-app-squid 

# NPS
- https://zhuanlan.zhihu.com/p/571804403
- https://op.supes.top/packages/arm_cortex-a7/
- https://op.supes.top/packages/arm_cortex-a7/nps_0.26.10-27_arm_cortex-a7.ipk
- https://op.supes.top/packages/arm_cortex-a7/npc_0.26.10-27_arm_cortex-a7.ipk
- https://op.supes.top/packages/arm_cortex-a7/luci-app-npc_git-24.013.46286-5ae00aa_all.ipk
- https://github.com/ehang-io/nps/releases
```
## gl-inet 驱动破解记录
gl-inet 4.2 引入了国家区域限制，部分功能无法使用。
首先明白两个参数：
- board_special.hardware.country_code 用于配置硬件设备的国家代码
- wireless.radio0.country             用于配置无线网络接口的国家代码。

我尝试修改wireless的国家代码发现无效，然后我并没有修改 hardware.country_code
```bash
uci set wireless.radio0.country='CN'
uci commit wireless
uci show wireless.radio0.country

# uci set board_special.hardware.country_code=US
# uci commit board_special
# uci -q get board_special.hardware.country_code
```
通过 `grep -r "country_code" /` 在 `/lib/functions/gl_util.sh` 文件发现相关代码
```bash
uci -q get board_special.hardware.country_code || cat /proc/gl-hw-info/country_code
```
此时前者为空，后者为 CN ，尝试变更代码不可以，尝试写入 /proc/gl-hw-info/country_code 提示 write io erro ，怀疑是驱动，紧接着查找到了 gl-sdk4-hw-info 驱动路径为 /lib/modules/4.4.60/gl-sdk4-hw-info.ko 卸载后发现可以绕过限制，但页面出现功能缺失。

于是尝试修改驱动。
```bash
# 先备份
cp /lib/modules/4.4.60/gl-sdk4-hw-info.ko /lib/modules/4.4.60/gl-sdk4-hw-info.ko.back
# 替换关键字，此操作并不能改国家代码，但可以使其无法将 CN 写入到 /proc/gl-hw-info/country_code
sed -i 's/CNNC/USSU/g' /lib/modules/4.4.60/gl-sdk4-hw-info.ko
sed -i 's/NCCN/SUUS/g' /lib/modules/4.4.60/gl-sdk4-hw-info.ko
# 重新挂载驱动
rmmod gl-sdk4-hw-info
insmod /lib/modules/4.4.60/gl-sdk4-hw-info.ko
lsmod |grep gl_sdk4_hw_info
uci -q get board_special.hardware.country_code || cat /proc/gl-hw-info/country_code
```
问题解决。
那么为什么 `uci -q get board_special.hardware.country_code` 是空的呢，我修改前者是否也可以呢
```bash
uci set board_special.hardware.country_code=US
uci commit board_special
uci -q get board_special.hardware.country_code
```
验证后发现一样可以。 `uci set board_special.hardware.country_code=US` 更加方便，如果有一天官方镜像更新为只能通过驱动判断国家代码，则可以参考上面修改驱动。
过了一年分析社区有人折腾的新方法
https://forum.openwrt.org/t/converting-gl-inet-mt3000-beryl-ax-from-cn-to-global/165159/6
```bash
修改/dev/mtdblock8 
或者覆盖挂载
echo US > /tmp/country_code
mount --bind /tmp/country_code /proc/gl-hw-info/country_code
cat /proc/gl-hw-info/country_code
要设置开机脚本
cat /etc/rc.local
sed -i '1i\echo US > /tmp/country_code\nmount --bind /tmp/country_code /proc/gl-hw-info/country_code' /etc/rc.local
cat /etc/rc.local
```

https://openwrt.ai/?target=x86%2F64&id=generic
https://dl.openwrt.ai/

## glider
```yaml  title="/etc/glider/glider.conf"
# Verbose mode, print logs
verbose=True
# listen on 8443, serve as http/socks5 proxy on the same port.
listen=:8443
```
## frr
```bash
luci-app-bird1-ipv4	


opkg install frr frr-ospf frr-rip frr-bgp

opkg install \
frr	\
frr-babeld \
frr-bfdd	\
frr-bgpd	\
frr-eigrpd \
frr-isisd	\
frr-ldpd	\
frr-libfrr \
frr-nhrpd	\
frr-ospf6d \
frr-ospfd	\
frr-pbrd	\
frr-pimd	\
frr-ripd	\
frr-ripngd \
frr-vrrpd	\
frr-vtysh	\
frr-zebra	\
frr-watchfrr \
frr-fabricd	 \
frr-staticd	 


/etc/init.d/frr start
/etc/init.d/frr start
/etc/init.d/frr enable
vtysh
```