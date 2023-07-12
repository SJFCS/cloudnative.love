[突破网络审查和封锁的工具清单。](https://github.com/aturl/awesome-anti-gfw/tree/master)


## openwrt v2rayA 
https://github.com/v2raya/v2raya-openwrt

https://github.com/v2rayA/v2rayA/wiki/openwrt

Add v2rayA usign key

Make sure package wget-ssl is installed on your device
```bash
wget https://osdn.net/projects/v2raya/storage/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03
```
Import v2rayA feed

```bash
echo "src/gz v2raya https://osdn.net/projects/v2raya/storage/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"

# Japan mirror
# echo "src/gz v2raya https://ftp.jaist.ac.jp/pub/sourceforge.jp/storage/g/v/v2/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
# US mirror
# echo "src/gz v2raya https://mirrors.gigenet.com/OSDN/storage/g/v/v2/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
```
Update feeds

```bash
opkg update
```
Install v2rayA and its dependencies

```bash
opkg install v2raya

# Check your firewall implementation
# Install the following packages for the nftables-based firewall4 (command -v fw4)
# Generally speaking, install them on OpenWrt 22.03 and later
opkg install kmod-nft-tproxy
# Install the following packages for the iptables-based firewall3 (command -v fw3)
# Generally speaking, install them on OpenWrt 21.02 and earlier
opkg install iptables-mod-conntrack-extra \
  iptables-mod-extra \
  iptables-mod-filter \
  iptables-mod-tproxy \
  kmod-ipt-nat6

# Choose a core you'd like to use, v2ray or Xray
# If you have both installed, the latter is preferred by default
#
# Note from maintainer: due to broken tproxy support in v2ray, recommend using Xray instead
opkg install xray-core
# opkg install v2ray-core

# Optional
# opkg install v2fly-geoip v2fly-geosite
```
Install Daemon File:

```bash
cat <<'EOF' >/etc/init.d/v2raya
#!/bin/sh /etc/rc.common
command=/usr/bin/v2raya
PIDFILE=/var/run/v2raya.pid
depend() {
	need net
	after firewall
	use dns logger
}
start() {
	start-stop-daemon -b -S -m -p "${PIDFILE}" -x $command
}
stop() {
	start-stop-daemon -K -p "${PIDFILE}"
}
EOF

chmod +x /etc/init.d/v2raya
```
Start and auto-start
```
/etc/init.d/v2raya start
/etc/init.d/v2raya enable
```
v2rayA will listen port 2017 by default.



