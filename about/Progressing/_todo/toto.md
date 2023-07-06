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
- nacos优雅下线工具S



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

