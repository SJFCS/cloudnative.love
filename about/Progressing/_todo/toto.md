- 7-8月 
  - 考完 阿里云ACE，MySQL OCP  
  - 打造自己的实验环境（包括k8s、存储、日志、loadbalancer等、），打通多集群网络（混合云）
    - **GPU虚拟化**
    - **本机带GPU作为一个节点，加入k8s 调度AI任务，再来俩桥接网络的虚拟机做集群。一些中间件直接使用docker部署**
    - AI：绘画 代码提示 [搭建本地代码搜素](https://bloop.ai/) ai 本地文档助手，，k8s助手，sql助手
    - GPU调度
      - https://zhuanlan.zhihu.com/p/396660545
      - https://news.ycombinator.com/item?id=34522311
    - ceph 存储 
      - https://nbailey.ca/post/cephfs-kvm-virtual-san/
      - https://docs.ceph.com/en/latest/rbd/libvirt/
    - k8s [LoadBalancer](https://just4coding.com/2021/11/21/custom-loadbalancer/)  [openelb](https://www.qikqiak.com/post/openelb/) https://cloud.tencent.com/developer/article/1985814
    - https://github.com/localstack/localstack

## 写作
  Kubernetes-The-Hard-Way-Translate
    翻译原文并添加 vagrant/Terraform 实验环境,集成 crowdin 翻译  
    Kubernetes the hard way on Vagrant on Local Machine. No scripts.  
  01-Kubernetes
  02-Linux Guide
  03-Proxy, Gateway & Mesh
  04-Database

针对以下内容进行博客创作
  istio_多集群发布流量治理 多集群联邦流量治理 通过iac 跨三朵云   有篇文章 记得复现实验
  jvm 预热，通过服务网格灰度发布
  nacos 服务发现下沉解决方案，流量治理代替
  [kube-proxy  or ebpf](https://tkng.io/services/clusterip/dataplane/ebpf/)
  多集群提高利用率 viture kubelet
  [k8s外部dns](https://nicks-playground.net/posts/2019-11-26-coredns-and-route53/)

gitlab 最佳实践，破除单库单流水线限制
  1 03-Integration & Delivery
  2-3 04-Proxy, Gateway & Mesh
  4-6 05-Database
  7 06-Observability
  8 07-Infrastructure as Code
  9 08-Storage 09-Security
  10 各种中间件 hadoop+kerberos+flink+zookeeper+kafka

## 英语
构建自己的英语 workflow 覆盖日常工作场景

## 开发
Python Django/flask sqlalchemy【了解就行，写几个demo，看看别人的CMDB，脚本要写的溜】
Golang gin gorm【熟练CURD】
React、TailwindCSS 【熟练写UI】 //Prisma/typeorm/sequelize Next.js、Socket.io、Node.js、Express.js
Java nacos openfeign maven/gradle jvm native-image remote-debug arthas

我对 multicloud,Dynamic Admission Control(动态准入控制器),自定义kube-scheduler，Operator，CRD ，Kubernetes的实现方法感兴趣，想进一步深入了解 Kubernetes 。

### 待做
- k8s 运维平台 https://github.com/erda-project/erda
- 环境效能平台（istio智能路由，集成gitlab和argocd自动创建cicd流程）混部多集群管理 虚拟集群
- 飞书机器人开发 gitlab支持和告警拉群支持，+gpt分析k8s事件
- openvpn otp 管理平台 集成飞书 ldap auth2等 动态身份验证器 环境代理 VPN。openldap管理 http://ldapdoc.eryajf.net
- nacos优雅下线工具
- [ ] k8s开发：自动nacos优雅下线   ，自动流量预热，镜像安全流程

### 有想法
- 兼容Alfred，utools 更小更快兼容 wayland 支持自定义 workflow，utools借鉴google的搜索栏tabl搜索 https://github.com/kaiye/workflows-youdao https://github.com/kaiye/kaiye.github.com/issues/5
- 终端软件和零信任集成，能共享终端 能操作回放、录制和审计，笔记软件交互模式，ppt模式,playground，在线实验室，课程发布平台，web ide，字符录制-音频转换-webide-ide-环境隔离-终端分享
  - https://developer.aliyun.com/article/812828?utm_content=m_1000310320 

-  cert manager 管理平台
-  iac管理平台 
   -  https://spacelift.io/
   -  https://github.com/idcos/cloudiac
   -  https://developer.aliyun.com/article/792479
- excalidraw [添加中文支持](https://github.com/korbinzhao/excalidraw-cn/commit/799b9e6a6c2cba443e0102959063dcfaba8da8a4)

- jvm 调优和远程dbug，在云环境下实现流量镜像，流量切分，debug中断不退出
- debug健康检查中断可以临时关闭，configmanp作为变量注入容器，本地无法访问，而且存储无法访问。
- https://aws.amazon.com/cn/blogs/china/traffic-replication-on-amazon-eks-using-the-nginx-ingress-mirror-feature/
- https://www.kubesphere.io/zh/docs/v3.3/project-user-guide/grayscale-release/traffic-mirroring/
- https://developer.aliyun.com/article/782368
- https://github.com/metalbear-co/mirrord
分析taken的启动顺序
kubelet linux 命名空间 网络 自己实现cni
sechdurel 调度器 授权过程，自定义审计控制器






-  vagrant-yaml vagrant ceph 飞书 集成管理内部环境 虚拟机审批平台 对接飞书审批 还原机器人。
  vagrant-triggers和Vagrant hooks都是用于在Vagrant虚拟机生命周期中执行自定义脚本的插件，但它们之间有以下区别：
     - vagrant-triggers是一个独立的插件，需要先安装才能使用；而Vagrant hooks是Vagrant自带的功能，无需安装插件。
     - vagrant-triggers是基于事件触发器的插件，可以在Vagrant命令执行前、后或者在特定的Vagrant事件发生时触发自定义脚本；而Vagrant hooks是基于钩子函数的插件，可以在Vagrant命令执行前、后或者在特定的Vagrant事件发生时调用自定义函数。
     - vagrant-triggers支持多个触发器和多个脚本，可以根据需要在不同的事件中执行不同的脚本；而Vagrant hooks只支持一个函数，需要在函数内部根据事件类型来执行不同的操作。
     - 综上所述，vagrant-triggers和Vagrant hooks都是非常有用的Vagrant插件，可以帮助用户在Vagrant虚拟机的生命周期中执行自定义脚本，但它们之间的区别在于触发方式和灵活性。

您可以使用Vagrant插件vagrant-triggers来在Vagrant命令执行时触发自定义脚本。在该脚本中，您可以使用飞书的API来发送消息。以下是大致步骤：
```ruby
config.trigger.after [:up] do
  system("curl -X POST -H \"Content-Type: application/json\" -d '{\"text\":\"Virtual machine created.\"}' https://open.feishu.cn/open-apis/bot/v2/hook/xxxxx")
end
```
  
Vagrant有自己的hooks，它们允许您在Vagrant命令执行的不同阶段运行自定义脚本。您可以使用这些hooks来执行各种操作例如在虚拟机创建完成后安装软件或配置文件，或在虚拟机销毁之前清理资源。
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.provision "shell", inline: <<-SHELL
    echo "Hello, world!"
  SHELL

  config.vm.post_up_message = "Virtual machine created."

  config.vm.post_up_hook = Proc.new do |env|
    system("curl -X POST -H \"Content-Type: application/json\" -d '{\"text\":\"Virtual machine created.\"}' https://open.feishu.cn/open-apis/bot/v2/hook/xxxxx")
  end
end
```
上述配置定义了一个post_up_hook，它会在虚拟机创建完成后运行。在这种情况下，它会发送一条消息到飞书。您可以根据需要定义其他hooks，例如pre-up、pre-provision、post-provision等。

