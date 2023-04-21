cert_manager_dashboard
istio_多集群发布流量治理等等**
iac 公有云











## vpn——manager
域名分流，dns分流，全部加密


GoTeleport 是一种企业级 VPN 解决方案，类似于 Tailscale 和 ZeroTier，它使用 WireGuard 协议提供安全的点对点连接。


GoTeleport 的最大优势在于它提供了一个完整的安全访问平台，包括企业级身份验证、访问控制、审计日志和会话录制等功能，可以帮助企业更好地保护其网络安全。


GoTeleport 还提供了一个易于使用的 Web 界面和 API，可帮助企业轻松管理和监控其 VPN 网络。此外，GoTeleport 还提供了一个可扩展的架构，可以轻松地与其他应用程序和服务集成。


总之，GoTeleport 是一种功能强大的企业 VPN 解决方案，可以提供高度安全的点对点连接，并帮助企业更好地保护其网络安全。





Tailscale 是一种基于 WireGuard 协议的新型企业 VPN 方案，以下是一些类似的方案：



ZeroTier：提供类似于 Tailscale 的 P2P VPN 解决方案，具有类似的易用性和安全性。


Nebula：基于 WireGuard 协议的企业 VPN 解决方案，提供高度安全的点对点连接。


Zerotier + WireGuard：使用 ZeroTier 和 WireGuard 结合的解决方案，提供易用性和高度安全性。


Pritunl Zero：基于 OpenVPN 和 WireGuard 协议的企业 VPN 解决方案，提供易用性和高度安全性。






OpenVPN：提供高度定制化的安全性和可靠性，适用于任何规模的企业。


SoftEther VPN：提供多种VPN协议和高度可定制化的功能，适用于小型和中型企业。


WireGuard：提供高速、现代化的VPN协议和简单易用的配置，适用于任何规模的企业。







openvpn只能实现ip路由分流，V2Ray 和openvpn结合使用，实现按域名的分流

```json
"outbounds": [
    {
        "protocol": "vmess",
        "settings": {
            "vnext": [
                {
                    "address": "example.com",
                    "port": 443,
                    "users": [
                        {
                            "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
                            "alterId": 64
                        }
                    ]
                }
            ]
        },
        "streamSettings": {
            "network": "tcp",
            "security": "tls",
            "tlsSettings": {
                "allowInsecure": false,
                "serverName": "example.com"
            }
        },
        "tag": "domain"
    },
    {
        "protocol": "vmess",
        "settings": {
            "vnext": [
                {
                    "address": "x.x.x.x",
                    "port": 443,
                    "users": [
                        {
                            "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
                            "alterId": 64
                        }
                    ]
                }
            ]
        },
        "streamSettings": {
            "network": "tcp",
            "security": "tls",
            "tlsSettings": {
                "allowInsecure": false,
                "serverName": "example.com"
            }
        },
        "tag": "ip"
    }
]
```
在这个配置中，我们定义了两个出口，一个是按域名分流的出口(domain)，另一个是按IP地址分流的出口(ip)。


接下来，在OpenVPN的配置文件中添加以下路由规则：
```
route example.com 255.255.255.255 net_gateway
```
这个路由规则会将所有访问example.com的流量路由到OpenVPN的默认网关。
最后，在OpenVPN启动时添加以下命令行参数：
```
--script-security 2
--route-noexec
--route-up '/path/to/v2ray.sh'
--route-pre-down '/path/to/v2ray.sh'
```

其中，/path/to/v2ray.sh是一个脚本文件，用于启动和停止V2Ray的代理服务。在路由规则生效前，OpenVPN会执行该脚本，启动V2Ray代理服务。在路由规则失效时，OpenVPN会执行该脚本，停止V2Ray代理服务。



WireGuard 


## git
我要实现每个人的commit必须签名  goteleport  可否提供管理方案
虽然 Teleport 本身不能强制要求每个人都签名 commit，但您可以通过以下步骤来实现这个目标：



启用 GPG 签名：您需要在 Git 中启用 GPG 签名功能，确保每个提交都必须使用签名。具体可以参考 Git 的文档。


配置 Git 钩子：您可以配置 Git 钩子，以确保每个提交都必须签名。可以使用 pre-commit 钩子或 commit-msg 钩子进行校验。您可以编写一个脚本，在钩子中调用该脚本进行签名校验。


使用 Teleport 进行访问控制：您可以使用 Teleport 进行访问控制，以确保只有经过授权的用户才能进行提交。您可以在 Teleport 中配置用户和访问权限，并使用 Teleport 进行认证和授权管理。



通过以上步骤，您可以实现每个人的提交都必须签名的要求，并使用 Teleport 进行访问控制和认证管理。