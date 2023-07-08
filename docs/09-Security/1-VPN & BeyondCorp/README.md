---
title: VPN & BeyondCorp📝
---

_打造零信任办公网络和Anycast任播网络

https://netbird.io/
- https://vyos.io/
- https://www.netmaker.io/
- Ngrok Frp 
- Zerotier Tailscale Headscale Wireguard
- teleport [pomerium](https://github.com/pomerium/pomerium) 
- cloudflare tunnal zero trust
- [oauth2_proxy](https://github.com/bitly/oauth2_proxy) [kube-auth-proxy](https://github.com/jwalton/kube-auth-proxy)

https://github.com/jwalton/kube-auth-proxy
https://github.com/bitly/oauth2_proxy



[SSO之使用Pomerium保护您的网站](http://www.lishuai.fun/2022/06/15/pomerium/#/%E8%AE%A4%E8%AF%81%E6%B5%81%E7%A8%8B)


- [“零信任网络”定义](https://tailscale.com/kb/1123/zero-trust/)
- [ZeroTier 与 Tailscale](https://tailscale.com/compare/zerotier/) 
- [ZeroTier vs Tailscale](https://www.e2encrypted.com/posts/tailscale-vs-zerotier-comprehensive-comparison/)
- [Kubernetes 零信任实战：Teleport](https://pandaychen.github.io/2020/11/20/HOW-TO-HACK-KUBECTL-EXEC-IN-KUBERNETES/)
- [Cloudflare 如何实施 FIDO2 和 Zero Trust 硬件密钥来防止网络钓鱼呢？](https://blog.cloudflare.com/zh-cn/how-cloudflare-implemented-fido2-and-zero-trust-zh-cn/)


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
https://dmesg.app/cf-zero-trust.html
https://tailscale.com/blog/ssh-console/
https://www.cloudflare.com/zh-cn/zero-trust/
https://www.cloudflare.com/zh-cn/products/zero-trust/zero-trust-network-access/
https://tailscale.com/kb/1019/subnets/
https://www.dongvps.com/2022-11-07/tailscale-exit-node-route/

## NET 打洞原理
- [内网穿透和NAT打洞是什么？](https://www.bilibili.com/video/BV19W4y1X7mV/)
- [How NAT traversal works](https://tailscale.com/blog/how-nat-traversal-works/)
- [How NAT traversal works 翻译](https://arthurchiao.art/blog/how-nat-traversal-works-zh/)
- https://bford.info/pub/net/p2pnat/
- https://cguling.github.io/2020/07/04/P2P_1.html
- [Anycast任播网络](https://zhuanlan.zhihu.com/p/639088952)


OpenVPN
- https://github.com/flant/ovpn-admin
- https://lisz.me/tech/webmaster/ldap-openvpn.html
- https://www.qztxs.com/archives/science/technology/11465
- https://blog.vmko.cc/2018/02/22/2019-07/openvpn-login-auto/
- https://www.aikaiyuan.com/12154.html
- https://github.com/topics/openvpn-admin

IPSec
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



使用 Cloudflare 的邮件转发 + Outlook 的别名发送就可以假装成域名邮箱。
需要有 Cloudflare 和 Microsoft 账号，并把域名 DNS 托管到 Cloudflare。

Cloudflare 最近推出了电子邮件转发服务，可以把自己域名的电子邮件地址收到的邮件转发到其他邮件地址。而微软的 Outlook 支持别名服务，这意味着可以通过 Outlook 发送地址不为 outlook.com 的电子邮件（但是域仍然是 outlook.com，收件方可以看到这一点）。

首先进入 [Cloudflare 的控制台主页](https://dash.cloudflare.com/)，点击托管的域名，打开左侧侧边栏，选择 Email，然后第一次使用大概有个参与计划的设置，按照提示一步步进行即可。将 custom@yourdomain 的电子邮件转发到你的 Outlook 地址，注意，此时必须转发到已经存在的地址。

然后更改该域的 DNS，增加一个名称为 @ 的 TXT 记录，内容为 v=spf1 include:_spf.mx.cloudflare.net include:outlook.com ~all，如果 Cloudflare 已经帮你自动生成了一个以 v=spf1 开头的 TXT 记录，就把这个记录改成上面的内容（实际上就是添加了一句 include:outlook.com）。注意，不要添加 DMARC 记录，如果 Cloudflare 默认生成了一个 DMARC 记录，需要删掉，否则会导致收件方认为你的电子邮件是虚假的（如果有可以正确添加 DMARC 的方式，请联系我）。

最后进入 [Microsoft 账户 | 你的个人档案 ](https://account.microsoft.com/profile)，点击编辑账户信息，添加电子邮件，地址填写 Cloudflare 电子邮件转发的源地址，然后按照提示验证电子邮件是你所有，这时候验证邮件就会被转发到 Outlook 中，进行验证即可。个人建议使用相同的电子邮件前缀。

这样别人给你的域名邮箱地址发送的邮件都会发到 Outlook，如果需要回复，或者使用该邮件地址发送邮件，只需要使用 Outlook 客户端或者网页版，更改发件人地址即可。

更新：根据微软的新政策，2023 年 11 月 30 日后不能添加新的非 outlook.com 的别名：[Changes to Microsoft 365 email features and storage](https://support.microsoft.com/en-us/office/changes-to-microsoft-365-email-features-and-storage-e888d746-61e5-49e3-9bd1-94b88e9be988)。


https://github.com/novnc/noVNC  



