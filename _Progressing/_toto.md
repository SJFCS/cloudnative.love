8,9,10,11,12,1,2,3
- 7-8月 
  - 考完 阿里云ACE，MySQL OCP  
  - 打造自己的实验环境（包括k8s、存储、日志、loadbalancer等、），打通多集群网络（混合云）
    - **本机带GPU作为一个节点，加入k8s 调度AI任务，再来俩桥接网络的虚拟机做集群。一些中间件直接使用docker部署**
    - 部署服务全部通过argocd管理
    - AI：绘画 代码提示 [搭建本地代码搜素](https://bloop.ai/) ai 本地文档助手，，k8s助手，sql助手
  
    - ceph 存储 
      - https://nbailey.ca/post/cephfs-kvm-virtual-san/
      - https://docs.ceph.com/en/latest/rbd/libvirt/
    - k8s [LoadBalancer](https://just4coding.com/2021/11/21/custom-loadbalancer/)  [openelb](https://www.qikqiak.com/post/openelb/) https://cloud.tencent.com/developer/article/1985814
    - https://github.com/localstack/localstack
## 写作
Kubernetes-The-Hard-Way-Translate
  翻译原文并添加 vagrant/Terraform 实验环境,集成 crowdin 翻译  
  Kubernetes the hard way on Vagrant on Local Machine. No scripts.  
各种中间件 
  hadoop+kerberos+flink+zookeeper+kafka+HBase
  nacos ElasticSearch Kong RocketMQ
## 开发
Python Django/flask sqlalchemy【了解就行，写几个demo，看看别人的CMDB，脚本要写的溜】
Golang gin gorm【熟练CURD】
React、TailwindCSS 【熟练写UI】 //Prisma/typeorm/sequelize Next.js、Socket.io、Node.js、Express.js
Java nacos openfeign maven/gradle jvm native-image remote-debug arthas

我对 multicloud,Dynamic Admission Control(动态准入控制器),自定义kube-scheduler，Operator，CRD ，Kubernetes的实现方法感兴趣，想进一步深入了解 Kubernetes 。

### 待做
- k8s 运维平台 https://github.com/erda-project/erda
- 环境效能平台（istio智能路由，集成gitlab和argocd自动创建cicd流程）混部多集群管理 虚拟集群
- 飞书机器人开发 gitlab 支持和告警拉群支持，+gpt分析k8s事件 https://github.com/justjavac/deno_feishu_bot_echo
- 飞书审批demo
- openvpn otp 管理平台 集成飞书 ldap auth2等 动态身份验证器 环境代理 VPN。openldap管理 http://ldapdoc.eryajf.net

- nacos 优雅下线工具 配置管理gitops工具
- jvm 调优和远程dbug，在云环境下实现流量镜像，流量切分，debug中断不退出
- 熟悉主流云平台，如 AWS,阿里云等的管理工具，精通 InfrastructureasCode 理念，熟练掌握 Terraform，CloudFormaction。













### 其他想法
- 兼容Alfred，utools 更小更快兼容 wayland 支持自定义 workflow，utools借鉴google的搜索栏tabl搜索 https://github.com/kaiye/workflows-youdao https://github.com/kaiye/kaiye.github.com/issues/5
- 终端软件和零信任集成，能共享终端 能操作回放、录制和审计，笔记软件交互模式，ppt模式,playground，在线实验室，课程发布平台，web ide，字符录制-音频转换-webide-ide-环境隔离-终端分享
  - https://developer.aliyun.com/article/812828?utm_content=m_1000310320 
-  cert manager 管理平台
-  iac管理平台 
   -  https://spacelift.io/
   -  https://github.com/idcos/cloudiac
   -  https://developer.aliyun.com/article/792479
- excalidraw [添加中文支持](https://github.com/korbinzhao/excalidraw-cn/commit/799b9e6a6c2cba443e0102959063dcfaba8da8a4)

- debug健康检查中断可以临时关闭，configmanp作为变量注入容器，本地无法访问，而且存储无法访问。
- https://aws.amazon.com/cn/blogs/china/traffic-replication-on-amazon-eks-using-the-nginx-ingress-mirror-feature/
- https://www.kubesphere.io/zh/docs/v3.3/project-user-guide/grayscale-release/traffic-mirroring/
- https://developer.aliyun.com/article/782368
- https://github.com/metalbear-co/mirrord
分析taken的启动顺序
kubelet linux 命名空间 网络 自己实现cni
sechdurel 调度器 授权过程，自定义审计控制器



