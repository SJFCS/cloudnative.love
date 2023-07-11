---
title: VPN & BeyondCorp📝
---

_打造零信任办公网络和Anycast任播网络
```
sudo tailscale up --advertise-routes=192.168.8.0/24 --accept-routes=true --accept-dns=false
```
- Ngrok Frp 
- Zerotier Wireguard Tailscale Headscale  [netbird](https://netbird.io/) [netmaker](https://www.netmaker.io/)
- teleport [pomerium](https://github.com/pomerium/pomerium) 
- cloudflare tunnal,cloudflare zero trust
- [oauth2_proxy](https://github.com/bitly/oauth2_proxy) [kube-auth-proxy](https://github.com/jwalton/kube-auth-proxy)



- [“零信任网络”定义](https://tailscale.com/kb/1123/zero-trust/)
- [ZeroTier 与 Tailscale](https://tailscale.com/compare/zerotier/) 
- [ZeroTier vs Tailscale](https://www.e2encrypted.com/posts/tailscale-vs-zerotier-comprehensive-comparison/)
- [Kubernetes 零信任实战：Teleport](https://pandaychen.github.io/2020/11/20/HOW-TO-HACK-KUBECTL-EXEC-IN-KUBERNETES/)
- [Cloudflare 如何实施 FIDO2 和 Zero Trust 硬件密钥来防止网络钓鱼呢？](https://blog.cloudflare.com/zh-cn/how-cloudflare-implemented-fido2-and-zero-trust-zh-cn/)
- [SSO之使用Pomerium保护您的网站](http://www.lishuai.fun/2022/06/15/pomerium/#/%E8%AE%A4%E8%AF%81%E6%B5%81%E7%A8%8B)
- https://www.keepersecurity.com/zh_CN/vs/teleport.html
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/private-net/connect-private-networks/
- https://tailscale.com/blog/how-tailscale-works/
- [更换您的 VPN](https://developers.cloudflare.com/learning-paths/replace-vpn/) 
- https://chriskirby.net/replace-your-homelab-vpn-with-cloudflare-zero-trust/
- https://tsmith.co/2023/cloudflare-zero-trust-tunnels-for-the-homelab/
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/use-cases/ssh/
- https://wzyboy.im/post/1524.html
- https://razeen.me/posts/nas-09-tailscale/
- https://github.com/gravitational/teleport/discussions/20245
- https://y4er.com/posts/tailscale/
- https://github.com/getsomecat/GetSomeCats/blob/Surge/Loon%E6%96%B0%E6%89%8B%E8%B5%B7%E6%AD%A5%E6%8A%98%E8%85%BEWarp.md
- https://slarker.me/zerotrust/
- https://bra.live/setup-home-server-with-cloudflare-tunnel/
- https://muzihuaner.github.io/2021/09/22/%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F%E7%A5%9E%E5%99%A8ZeroTier%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/
- https://blog.cloudflare.com/zh-cn/building-many-private-virtual-networks-through-cloudflare-zero-trust-zh-cn/
- https://dmesg.app/cloudflare-access-gfwed-server.html
- https://dmesg.app/cf-zero-trust.html
- https://icloudnative.io/posts/how-to-set-up-or-migrate-headscale/
- https://www.boris1993.com/setting-up-tailscale.html
- https://dmesg.app/cf-zero-trust.html
- https://tailscale.com/blog/ssh-console/
- https://www.cloudflare.com/zh-cn/zero-trust/
- https://www.cloudflare.com/zh-cn/products/zero-trust/zero-trust-network-access/
- https://tailscale.com/kb/1019/subnets/
- https://www.dongvps.com/2022-11-07/tailscale-exit-node-route/


## NET 打洞原理
- [内网穿透和NAT打洞是什么？](https://www.bilibili.com/video/BV19W4y1X7mV/)
- [How NAT traversal works](https://tailscale.com/blog/how-nat-traversal-works/)
- [How NAT traversal works 翻译](https://arthurchiao.art/blog/how-nat-traversal-works-zh/)
- https://bford.info/pub/net/p2pnat/
- https://cguling.github.io/2020/07/04/P2P_1.html
- [Anycast任播网络](https://zhuanlan.zhihu.com/p/639088952)


## OpenVPN
- https://github.com/flant/ovpn-admin
- https://lisz.me/tech/webmaster/ldap-openvpn.html
- https://www.qztxs.com/archives/science/technology/11465
- https://blog.vmko.cc/2018/02/22/2019-07/openvpn-login-auto/
- https://www.aikaiyuan.com/12154.html
- https://github.com/topics/openvpn-admin

## IPSec
- https://github.com/hwdsl2/setup-ipsec-vpn
- https://github.com/trailofbits/algo
- https://github.com/hwdsl2/docker-ipsec-vpn-server


## 开源项目
https://next-terminal.typesafe.cn/

几秒钟内即可访问桌面 - 在任何设备上、从任何位置，通过 Web 浏览器安全地进行桌面访问。
https://www.kasmweb.com/
https://github.com/kasmtech/KasmVNC

[Boundary ](https://portal.cloud.hashicorp.com/services/boundary)

[突破网络审查和封锁的工具清单。](https://github.com/aturl/awesome-anti-gfw/tree/master)

一本书 https://www.amazon.com/dp/B0BP955T3M?linkCode=ogi

https://github.com/ViRb3/wgcf


- https://developers.cloudflare.com/learning-paths/get-started/

https://github.com/novnc/noVNC  


- https://vyos.io/





















```bash
#Add the official Golang PPA repository:
sudo add-apt-repository ppa:longsleep/golang-backports
#Update the package list to include the newly added repository:
sudo apt update
#Install the Go package:
sudo apt install golang-go
#Verify that Go has been installed successfully by running the following command:
go version
go install tailscale.com/cmd/derper@main
cd $HOME/go/bin 
# export PATH=$PATH:/root/go/bin

curl -fsSL https://tailscale.com/install.sh | sh

sudo tailscale up --accept-routes=true

sudo nohup /home/ubuntu/go/bin/derper --hostname=derp.cloudnative.love --verify-clients &

vim /etc/systemd/system/derp.service
[Unit]
Description=Tailscale DERP Server
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=5
User=root
ExecStart=/root/go/bin/derper -c=/root/derper.conf -a ":<port>" -hostname "<domain>" --stun

[Install]
WantedBy=multi-user.target
```

```




{
	"acls": [
		// Allow all connections.
		// Comment this section out if you want to define specific restrictions.
		{"action": "accept", "src": ["*"], "dst": ["*:*"]},
	],
	"ssh": [
		{
			"action": "check",
			"src":    ["autogroup:members"],
			"dst":    ["autogroup:self"],
			"users":  ["autogroup:nonroot", "root"],
		},
	],
}

  "derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "myderp",
        "Nodes": [
          {
            "Name": "1",
            "RegionID": 900,
            "HostName": "derp.cloudnative.love"
          }
        ]
      }
    }
  }

```
tailscale netcheck
sudo tailscale up --accept-routes=true

https://github.com/HMBSbige/NatTypeTester

https://github.com/adyanth/openwrt-tailscale-enabler

https://github.com/hojulian/tailscale-relay

NAT类型一般分为以下4种：
1. Full Cone NAT (完全圆锥型)
2. Restricted Cone NAT (地址限制圆锥型)
3. Port Restricted Cone NAT (端口限制圆锥型)
4. Symmetric NAT (对称型)
5. https://cnblogs.com/lsgxeva/p/16464140.html



https://v2ex.com/t/691842

https://v2ex.com/t/691842