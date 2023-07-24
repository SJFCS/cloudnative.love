https://github.com/Siriling/OpenWrt-GL.iNet-AXT1800/releases/tag/AXT1800-2023.03.01-03.03
https://github.com/m0eak/Openwrt_Packages/tree/main

## 扩容
https://openwrt.org/docs/guide-user/additional-software/extroot_configuration
先创建分区并格式化
```bash
umount /tmp/mountd/disk1_part1
mkfs.ext4 /dev/mmcblk0p1

mount -t ext4 /dev/mmcblk0p1 /mnt/
cp -a /overlay/* /mnt
umount /mnt/
```
系统-挂载点-新增-已启用-作为外部 overlay 使用（/overlay）-高级设置-文件系统-ext4-保存-保存并应用-reboot
删除多余，新增磁盘，保存并应用
## init
```bash
df -h

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgFyrk3LxFSzU0LSirdwq8jidpv8vySFU0t5CF4zBm5 song.jinfeng@outlook.com" >> /etc/dropbear/authorized_keys
chmod 600 /etc/dropbear/authorized_keys
opkg update && opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade

opkg install openssh-sftp-server
opkg install bash 
sed -i 's|/bin/ash|/bin/bash|' /etc/passwd
bash
```
## country code
```bash
uci set board_special.hardware.country_code=US
uci commit board_special
uci -q get board_special.hardware.country_code
```
## 更换国际化文件
```bash
cd /www/i18n/

mkdir back

mv $(ls | grep zh-tw) back/

for file in $(ls | grep zh-cn); do cp "$file" "${file/zh-cn/zh-tw}"; done

## 还原
## rm -rf $(ls | grep zh-tw) && cp back/* .
```
然后登录后选择繁体中文即可
## v2ray
- https://github.com/m0eak/Install-Openclash-for-Axt1800
- https://github.com/v2raya/v2raya-openwrt
- https://github.com/v2rayA/v2rayA/wiki/openwrt
```bash
# opkg install wget-ssl
# wget https://osdn.net/projects/v2raya/storage/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03
echo "untrusted comment: Public usign key for v2rayA builds
RWSUzCqDT7CqA+u/9hvcT3Hkw3fUc1dYnpsLmIsayjPmsZM5NjYKYiHW" > /etc/opkg/keys/94cc2a834fb0aa03

#echo "src/gz v2raya https://osdn.net/projects/v2raya/storage/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
# Japan mirror
echo "src/gz v2raya https://ftp.jaist.ac.jp/pub/sourceforge.jp/storage/g/v/v2/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
# US mirror
# echo "src/gz v2raya https://mirrors.gigenet.com/OSDN/storage/g/v/v2/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"

opkg update

# Check your firewall implementation
# Install the following packages for the nftables-based firewall4 (command -v fw4)
# Generally speaking, install them on OpenWrt 22.03 and later
# opkg install kmod-nft-tproxy
# Install the following packages for the iptables-based firewall3 (command -v fw3)
# Generally speaking, install them on OpenWrt 21.02 and earlier
opkg install iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6
  
opkg install nftables \
    v2raya \
    xray-core \
    luci-app-v2raya \
    luci-i18n-v2raya-zh-cn \
    v2fly-geoip \
    v2fly-geosite

# For advanced usage, please see /etc/config/v2raya
uci set v2raya.config.enabled='1'
uci commit v2raya
# Start v2rayA
/etc/init.d/v2raya start
```

## argon theme
```bash
opkg install luci-compat luci-lib-ipkg jq
curl -sL $(curl -s https://api.github.com/repos/jerrykuku/luci-theme-argon/releases | jq -r '[.[] | select(.tag_name | startswith("v2."))] | sort_by(.created_at) | last | .assets[0].browser_download_url') -o /tmp/luci-theme-argon.ipk
curl -sL $(curl -sL https://api.github.com/repos/jerrykuku/luci-app-argon-config/releases/latest | jq -r '.assets[0].browser_download_url') -o /tmp/luci-app-argon-config.ipk
curl -sL $(curl -sL https://api.github.com/repos/jerrykuku/luci-app-argon-config/releases/latest | jq -r '.assets[].browser_download_url' |grep zh-cn) -o /tmp/luci-i18n-argon-config-zh-cn.ipk

cd /tmp/ && opkg install luci-theme-argon.ipk luci-app-argon-config.ipk luci-i18n-argon-config-zh-cn.ipk
rm -rf  luci-theme-argon.ipk luci-app-argon-config.ipk luci-i18n-argon-config-zh-cn.ipk
```


## ddns
[OpenWrt Cloudflare DDNS](https://taoshu.in/unix/openwrt-ddns-cloudflare.html)
```bash
opkg install luci-app-ddns ddns-scripts-cloudflare ddns-scripts-services luci-i18n-ddns-zh-cn
sed -i '1i "cloudflare.com-v4"     "update_cloudflare_com_v4.sh"' /etc/ddns/services
``

## Alist
```bash
curl -sL $(curl -sL https://api.github.com/repos/sbwml/luci-app-alist/releases | jq -r '[.[] | select(.tag_name)] | sort_by(.created_at) | last | .assets[].browser_download_url'|grep arm_cortex-a7.tar.gz|sort -t '-' -k2Vr |grep 21.02) -o /tmp/luci-app-alist.tar.gz
# t'-' 表示使用短横线作为字段分隔符，而 -k2Vr 表示按照第二个字段（版本号）进行逆序排序。

tar -xzvf /tmp/luci-app-alist.tar.gz -C /tmp && cd /tmp/packages_ci/ && opkg install *
cd /tmp && rm -rf /tmp/packages_ci
```


## tailscale 
https://tailscale.com/kb/1082/firewall-ports/?q=port
443 41641 3478 
```
tailscale ping --peerapi otherpi
tailscale ping --c 20 otherpi
```


## 其他
# acme 
luci-app-acme luci-i18n-acme-zh-cn
https://openwrt.org/docs/guide-user/services/tls/acmesh
https://openwrt.org/docs/guide-user/services/webserver/nginx

# Aria2 
opkg install aria2 luci-app-aria2 luci-i18n-aria2-zh-cn 
mkdir /opt/aria2 && chown aria2:aria2 /opt/aria2/
opkg install webui-aria2 ariang ariang-nginx ？？？？
```bash
# 媒体服务器 dlna
opkg install luci-app-minidlna luci-i18n-minidlna-zh-cn

# 局域网共享打印机 https://www.youtube.com/watch?v=6bLS9kwGamc
opkg install kmod-usb-printer p910nd luci-app-p910nd

# Docker  
opkg install docker docker-compose docker-compose-src dockerd luci-app-dockerman luci-i18n-dockerman-zh-cn 

# TTYD 终端
opkg install luci-i18n-ttyd-zh-cn 

# SmartDNS  
opkg install smartdns luci-i18n-smartdns-zh-cn 

UPnP  https://thiscute.world/posts/about-nat/#3-upnp-%E5%8A%A8%E6%80%81%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91
opkg install miniupnpd luci-i18n-upnp-zh-cn

# wol 网络唤醒
luci-i18n-wol-zh-cn	
# 带宽监控
luci-i18n-nlbwmon-zh-cn
# 流量智能队列管理(QOS)
luci-i18n-sqm-zh-cn	
# MWAN3负载均衡
luci-i18n-mwan3-zh-cn
luci-app-mwan3helper ？？？

# Transmission
opkg install transmission-daemon luci-i18n-transmission-zh-cn 
transmission-web transmission-web-control??????

# 迅雷快鸟
luci-app-xlnetacc  
  - https://github.com/sensec/luci-app-xlnetacc/releases/download/v1.0.5.1/luci-app-xlnetacc_1.0.5-1_all.ipk

# Turbo ACC 加速
https://github.com/chenmozhijin/turboacc
https://downloads.immortalwrt.org/releases/21.02.0/packages/arm_cortex-a7/luci/
    - luci-app-turboacc  
    - https://downloads.immortalwrt.org/releases/21.02.0/packages/arm_cortex-a7/luci/luci-i18n-turboacc-zh-cn_git-23.131.45438-002672a_all.ipk
    - https://downloads.immortalwrt.org/releases/21.02.0/packages/arm_cortex-a7/luci/luci-app-turboacc_git-23.131.45438-002672a_all.ipk

# uhttpd
luci-i18n-uhttpd-zh-cn	
```
Frp
opkg install \
luci-i18n-frps-zh-cn \
luci-i18n-frpc-zh-cn \
luci-app-frpc \
luci-app-frps \
VPN
opkg install \
luci-app-wireguard \
luci-app-vpnbypass \
luci-app-vpn-policy-routing \
luci-app-openvpn \
luci-app-squid 

NPS
https://zhuanlan.zhihu.com/p/571804403
https://op.supes.top/packages/arm_cortex-a7/
https://op.supes.top/packages/arm_cortex-a7/nps_0.26.10-27_arm_cortex-a7.ipk
https://op.supes.top/packages/arm_cortex-a7/npc_0.26.10-27_arm_cortex-a7.ipk
https://op.supes.top/packages/arm_cortex-a7/luci-app-npc_git-24.013.46286-5ae00aa_all.ipk
https://github.com/ehang-io/nps/releases
# #######################################################################################


## 其他
dashboard https://github.com/IceWhaleTech/CasaOS
https://miniflux.app/docs/installation.html#docker

[使用 V2Ray + CloudFlare Warp 解锁 ChatGPT](https://powerfulyang.com/post/136)

[RoutingA 自定义路由分流](https://v2raya.org/docs/manual/routinga/)
https://v2raya.org/docs/advanced-application/custom-extra-config/
https://github.com/Loyalsoldier/v2ray-rules-dat
https://www.v2fly.org/v5/config/router.html
https://xtls.github.io/document/level-2/warp.html#%E5%9C%A8%E6%9C%8D%E5%8A%A1%E7%AB%AF%E5%88%86%E6%B5%81%E5%9B%9E%E5%9B%BD%E6%B5%81%E9%87%8F%E8%87%B3-warp
https://github.com/HMBSbige/NatTypeTester
https://thiscute.world/posts/about-nat/#3-upnp-%E5%8A%A8%E6%80%81%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91

防火墙：https://www.youtube.com/watch?v=QtjPs5jreX0


https://op.supes.top/
https://supes.top/
https://github.com/appleboy/ssh-action
https://zhuanlan.zhihu.com/p/387389708
## gl-inet 驱动破解记录
gl-inet 4.2 引入了区域限制，部分功能无法使用
- board_special.hardware.country_code是用于配置硬件设备的国家代码
- wireless.radio0.country是用于配置无线网络接口的国家代码。
```
uci set board_special.hardware.country_code=US
uci commit board_special
uci -q get board_special.hardware.country_code
```

或者修改驱动：
我尝试修改wireless的国家代码发现无效
```bash
uci set wireless.radio0.country='CN'
uci commit wireless
uci show wireless.radio0.country
```
通过 `grep -r "country_code" /` 在 `/lib/functions/gl_util.sh` 文件发现相关代码
```bash
uci -q get board_special.hardware.country_code || cat /proc/gl-hw-info/country_code
```
此时前者为空，后者为CN，尝试变更代码不可以，尝试写入/proc/gl-hw-info/country_code 提示write io erro ，怀疑是驱动，紧接着查找到了 gl-sdk4-hw-info 驱动路径为 /lib/modules/4.4.60/gl-sdk4-hw-info.ko 卸载后发现可以绕过限制，但功能缺失。
尝试修改驱动
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





https://www.youtube.com/watch?v=mgDpJX3oNvI
https://openwrt.org/docs/guide-user/services/vpn/tailscale/start

https://www.mivm.cn/openwrt-aria2
https://openwrt.org/packages/pkgdata/aria2


## 垃圾

## luci-app-lucky 垃圾 [X]

```bash	
opkg install bash  && bash
urls=($(curl -s https://api.github.com/repos/gdy666/luci-app-lucky/releases | jq -r '[.[] | select(.tag_name)] | sort_by(.created_at) | last | .assets[].browser_download_url' |grep -E "armv7_daji|luci-i18n-lucky-zh-cn|luci-app-lucky_.*_all"))

for url in "${urls[@]}"
do
    filename=$(basename "$url")
    echo "Downloading: $filename"
    curl -sL "$url" -o "/tmp/$filename"  
done

cd /tmp/
opkg install luci-app-lucky_2.1.1-1_all.ipk luci-i18n-lucky-zh-cn_2.1.1-1_all.ipk lucky_2.1.1_Openwrt_armv7_daji.ipk 

rm -rf luci-app-lucky_2.1.1-1_all.ipk luci-i18n-lucky-zh-cn_2.1.1-1_all.ipk lucky_2.1.1_Openwrt_armv7_daji.ipk 
```

## Clash bug 太多 [X]
openclash  https://github.com/vernesong/OpenClash/
shellclash https://github.com/juewuy/ShellClash
```
#nftables
opkg update
opkg install coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base

https://github.com/vernesong/OpenClash/releases/download/v0.45.129-beta/luci-app-openclash_0.45.129-beta_all.ipk
https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv7.tar.gz
```
## vssr [X]
```
https://github.com/jerrykuku/luci-app-vssr
```
## passwal  [X]
https://github.com/xiaorouji/openwrt-passwall
```
wget https://github.com/xiaorouji/openwrt-passwall/releases/download/4.66-12/luci-app-passwall_4.66-12_all.ipk
wget https://github.com/xiaorouji/openwrt-passwall/releases/download/4.66-12/luci-i18n-passwall-zh-cn_4.66-12_all.ipk
wget https://github.com/xiaorouji/openwrt-passwall/releases/download/4.66-12/passwall_packages_ipk_arm_cortex-a7.zip

```
