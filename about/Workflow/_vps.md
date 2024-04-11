## 选购
https://bigdata.icu/tools/vps.html
https://vps.laoda.de/

vps商 ip和工单要对上，不然视为欺诈：https://www.kvmla.pro/
https://www.kvmla.pro/offers.html
折扣码：https://www.haozhuji.net/store/kvmla.com

## bench
curl -sL yabs.sh | bash 
wget -qO- bench.sh | bash

## 路由
三网回程延迟测试脚本
curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash

## 解锁
流媒体&GPT解锁测试脚本
wget https://raw.githubusercontent.com/yeahwu/check/main/check.sh && bash check.sh

RegionRestrictionCheck
bash <(curl -L -s check.unlock.media)
MediaUnlockTest
bash <(curl -Ls unlock.moe)
Streaming Media Unlock Test
bash <(curl -L -s media.ispvps.com)



https://major.io/p/secure-tailscale-networks-with-firewalld/
```bash
firewall-cmd --zone=public --add-port=8122/tcp --permanentfirewall-cmd --zone=public --add-port=8122/tcp --permanent
❯ firewall-cmd --zone=public --remove-port=8122/tcp --permanent
success
❯ firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="100.96.97.112/32" port protocol="tcp" port="8122" accept'

firewall-cmd --permanent --remove-rich-rule='rule family="ipv4" source address="100.96.97.112/32" port protocol="tcp" port="8700" accept'

❯ systemctl restart firewalld

❯ firewall-cmd --list-all --zone=public 
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: dhcpv6-client ssh
  ports: 41641/udp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
	rule family="ipv4" source address="100.96.97.112/32" port port="8700" protocol="tcp" accept
	rule family="ipv4" source address="100.96.97.112/32" port port="8122" protocol="tcp" accept


sudo firewall-cmd --add-port=8700/tcp --zone=dmz

sudo firewall-cmd --runtime-to-permanent

firewall-cmd --zone=public --remove-port=8122/tcp --permanent
```