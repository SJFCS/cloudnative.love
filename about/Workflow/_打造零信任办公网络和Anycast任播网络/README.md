# 打造零信任办公网络和Anycast任播网络
https://tailscale.com/kb/1123/zero-trust/

https://tailscale.com/compare/zerotier/

https://zhuanlan.zhihu.com/p/639088952?utm_id=0
- https://www.e2encrypted.com/posts/tailscale-vs-zerotier-comprehensive-comparison/
- https://pandaychen.github.io/2020/11/20/HOW-TO-HACK-KUBECTL-EXEC-IN-KUBERNETES/

[cloudflare Zero Trust Tunnel。](https://zhuanlan.zhihu.com/p/636264850?utm_id=0)


- [Cloudflare 如何实施 FIDO2 和 Zero Trust 硬件密钥来防止网络钓鱼呢？](https://blog.cloudflare.com/zh-cn/how-cloudflare-implemented-fido2-and-zero-trust-zh-cn/)

https://www.keepersecurity.com/zh_CN/vs/teleport.html

- https://goteleport.com/docs/desktop-access/introduction/
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/private-net/connect-private-networks/
- https://developers.cloudflare.com/learning-paths/replace-vpn/
- https://github.com/ViRb3/wgcf
- https://chriskirby.net/replace-your-homelab-vpn-with-cloudflare-zero-trust/
- https://github.com/jbencina/vpn
- https://tailscale.com/blog/how-nat-traversal-works/
- https://tsmith.co/2023/cloudflare-zero-trust-tunnels-for-the-homelab/
- https://outerrim.dev/posts/create-wireguard-tunnel/
- https://www.bilibili.com/video/BV19W4y1X7mV/?spm_id_from=333.999.0.0

内网穿透

Frp，Ngrok，Natapp，Spike，花生壳，Zerotier 

https://github.com/getsomecat/GetSomeCats/blob/Surge/Loon%E6%96%B0%E6%89%8B%E8%B5%B7%E6%AD%A5%E6%8A%98%E8%85%BEWarp.md





https://slarker.me/zerotrust/

https://bra.live/setup-home-server-with-cloudflare-tunnel/

https://muzihuaner.github.io/2021/09/22/%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F%E7%A5%9E%E5%99%A8ZeroTier%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/

https://blog.cloudflare.com/zh-cn/building-many-private-virtual-networks-through-cloudflare-zero-trust-zh-cn/

https://dmesg.app/cloudflare-access-gfwed-server.html

https://dmesg.app/cf-zero-trust.html






## NET 打洞

https://zhuanlan.zhihu.com/p/108635427

https://mthli.xyz/p2p-hole-punching/

https://cguling.github.io/2020/07/04/P2P_1.html

https://zhuanlan.zhihu.com/p/86759357

NAT打洞是一种技术，用于在两个私有网络之间建立直接的点对点连接，即使它们都位于防火墙后面或使用了网络地址转换（NAT）。其基本原理是通过向NAT设备发送一些特定的数据包，从而建立直接的连接。


客户端A和客户端B都位于NAT网络中，无法直接建立连接。  
客户端A和客户端B分别向中继服务器发送一条UDP消息，这样NAT设备就会将客户端的公网IP地址和端口号映射到NAT设备上的一个端口上。  
客户端A向客户端B发送一条UDP消息，并将其中的IP地址和端口号设置为中继服务器返回的公网IP地址和端口号。  
由于客户端A和客户端B都向NAT设备发送了UDP消息，因此NAT设备会将客户端A和客户端B的公网IP地址和端口号映射到不同的端口上。  
客户端B向客户端A发送一条UDP消息，并将其中的IP地址和端口号设置为客户端A的公网IP地址和端口号。  
由于客户端B和客户端A都向NAT设备发送了UDP消息，因此NAT设备会将客户端B和客户端A的公网IP地址和端口号映射到不同的端口上。  
如果客户端A和客户端B的公网IP地址和端口号映射到的端口号相同，那么客户端A和客户端B就可以直接建立连接了。  
如果客户端A和客户端B的公网IP地址和端口号映射到的端口号不同，那么它们可以通过中继服务器进行通信，从而建立间接的连接。 




## 邮件转发 
https://mysteriouspreserve.com/blog/2022/10/16/Free-Custom-Domain-Email/
