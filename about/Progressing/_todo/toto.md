7月 考完 ACE  

7,8,9,10,11,12,1,2,3

打造自己的实验环境

11-12
Python Django/flask peewee/sqlalchemy
Golang gin gorm
frontend React、Tailwind CSS...  //Prisma/typeorm/sequelize Next.js、Socket.io、Node.js、Express
Java nacos openfeign maven/gradle jvm native-image remote-debug arthas
Git


最迟8.31结束02-Linux Guide
- k8s 运维平台
- 环境效能平台（istio智能路由，集成gitlab和argocd自动创建cicd流程）思路  多集群 虚拟集群 serverless 自动释放 路由染色 自动对接argo等
- 飞书机器人开发 gitlab支持和告警拉群支持，+gpt分析k8s事件
- openvpn otp 管理平台 集成飞书 ldap，零信任 动态身份验证器 环境代理 VPN。openldap管理 http://ldapdoc.eryajf.net/ 对接飞书钉钉等，支持oauth2
- nacos优雅下线工具



实验环境（包括k8s、存储、日志、loadbalancer等、），打通多集群网络（混合云）
- Ceph 容器化部署？ <https://nbailey.ca/post/cephfs-kvm-virtual-san/> <https://docs.ceph.com/en/latest/rbd/libvirt/>
- <https://just4coding.com/2021/11/21/custom-loadbalancer/>
- <https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/create-external-load-balancer/>
- <https://www.qikqiak.com/post/openelb/>
- [MetalLB vs PureLB vs OpenELB](https://cloud.tencent.com/developer/article/1985814)

10 Kubernetes OPS Guide
11 Kubernetes-The-Hard-Way

[OCP](https://education.oracle.com/%E4%BA%A7%E5%93%81%E7%9B%AE%E5%BD%95-ouexam-pexam_1z0-888/pexam_1Z0-888)

## 会用搭实验环境跑通就行
1 03-Integration & Delivery
2-3 04-Proxy, Gateway & Mesh
4-6 05-Database
7 06-Observability
8 07-Infrastructure as Code
9 08-Storage 09-Security
10 各种中间件 hadoop+kerberos+flink+zookeeper+kafka

  - git 提交 弹出的gihub认证窗口支持浏览器或者token登录 太神奇了 https://juejin.cn/post/7055485446058426405
  - 2fa 两步验证：
    - https://alternativeto.net/software/google-authenticator/?license=opensource
    - https://github.com/tailscale/tailscale
    - https://github.com/beemdevelopment/Aegis
  - [ ] https://flows.network/
  - [ ] 兼容Alfred，utools 更小更快兼容 wayland 支持自定义 workflow，utools借鉴google的搜索栏tabl搜索 https://github.com/kaiye/workflows-youdao https://github.com/kaiye/kaiye.github.com/issues/5
  - [ ] 终端软件和零信任集成，能共享终端 能操作回放、录制和审计，笔记软件交互模式，ppt模式,playground，在线实验室，课程发布平台，web ide，字符录制-音频转换-webide-ide-环境隔离-终端分享
  - [ ] k8s开发：自动nacos优雅下线   ，自动流量预热，镜像安全流程
    - https://www.kubernetes.org.cn/8426.html  
    - https://yqh.aliyun.com/live/detail/27936  
    - https://developer.aliyun.com/article/872430?utm_content=m_1000330905  
    - https://developer.aliyun.com/article/891670?utm_content=m_1000337392  
    - https://help.aliyun.com/document_detail/409450.html  
    - https://developer.aliyun.com/article/812828?utm_content=m_1000310320  
    - https://github.com/opensergo/opensergo-specification  
  - [ ] vagrant 虚拟机审批平台 对接飞书审批 还原机器人
  - [ ] cert manager 管理平台
    - https://github.com/metersphere/metersphere/
    - https://github.com/localstack/localstack
    - 模仿这个https://makelinux.github.io/kernel/map/ https://elixir.bootlin.com/linux/latest/ident/sys_kill 建立k8s源码分析
    -  模仿这个 https://app.daily.dev/posts/5oG1Ralxl 通过 remixjs 实现预加载，实现苹果商店的卡片缩放，集成agent到个人的blog，推送文章进行数据分析评级，将结果（ai分析风格主题评分）返回给个人站点agent，目前技术blog平台十分分散，不乏有很多优秀的个人站点未被统计，无法进行很好的数据统计和快速查阅。将查询和ai gpt结合起来，内容进行nlp分析便于查询。如何文章排名和推送由人们打分。文章引入翻译系统，好文章系列应该更容易被分享。要支持但文推荐，课程推荐，系列文档推荐等等。要题高质量可参考stackoverfllow等技术网站的奖励机制。做一个daily网站+知识分享创造的网站，网站内容集成自动翻译+人工校准反馈等，最好有配套工具进行引流，可以参考obsidian Logseq 等。

ai 本地文档助手，音视频分析，k8s助手，sql助手，托盘组件附加的方式
CICD平台开发： 优雅下线+协作开发和动态环境，集成抓包+api+文档+测试+issue+权限+终端会话共享+零信任+审计平台+微前端+混沌工程等+全部gitops审计+集成基础设施即代码+开通审批流程+结合财务finops

























cert_manager_dashboard
istio_多集群发布流量治理  通过iac 跨三朵云   有篇文章 记得复现实验











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