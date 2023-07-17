- 7-8月 
  - 考完 阿里云ACE，MySQL OCP  
  - 打造自己的实验环境（包括k8s、存储、日志、loadbalancer等、），打通多集群网络（混合云）
    - **本机带GPU作为一个节点，加入k8s 调度AI任务，再来俩桥接网络的虚拟机做集群。一些中间件直接使用docker部署**
    - 部署服务全部通过argocd管理
    - 修改网络策略
    - AI：绘画 代码提示 [搭建本地代码搜素](https://bloop.ai/) ai 本地文档助手，，k8s助手，sql助手
    - ceph 存储 
      - https://nbailey.ca/post/cephfs-kvm-virtual-san/
      - https://docs.ceph.com/en/latest/rbd/libvirt/
    - k8s [LoadBalancer](https://just4coding.com/2021/11/21/custom-loadbalancer/)  [openelb](https://www.qikqiak.com/post/openelb/) https://cloud.tencent.com/developer/article/1985814
    - https://github.com/localstack/localstack

## 写作
k8s GPU 方案
演进 GPU share方案 和调度平台
完善gpu监控
argocd-vault


通常K8S调度GPU最小调度单位是1卡，这样有些对GPU利用率不高而又独占GPU任务，gpu利用率不高， K8S管理GPU多了之后，为了加强GPU的使用率，可以通过GPU虚拟化的能力，能够把一卡拆成多卡进行调度，K8S 请求resouce可以零点几卡进行调度。
深度学习kubeflow等框架的部署
horovod 之类的进行深度学习训练，可以通过部署 kubeflow 借助其提供的能力去进行深度学习任务提交，kubeflow采用k8s operator 、crd等方案为tensorflow、pytorch、tensorflow分布式进行了支持，可以部署kubeflow然后进行深度学习建模。
训练推理加速

在Kubernetes中，默认情况下，GPU资源是以整个GPU设备作为最小调度单位进行分配和调度的。这意味着如果一个Pod请求了GPU资源，它将独占整个GPU设备，即使它实际上只使用了GPU资源的一小部分。

然而，如果您希望将GPU资源拆分为更小的单位进行调度，以提高GPU利用率，您可以考虑使用一些特定的工具和技术。

NVIDIA Device Plugin：Kubernetes社区提供了一个名为"NVIDIA Device Plugin"的插件，它允许将GPU资源拆分为更小的单位进行调度。使用该插件，您可以将一个GPU设备划分为多个虚拟的GPU资源，每个资源可以作为一个独立的调度单位。这样，多个Pod可以共享同一个GPU设备，从而提高GPU的利用率。您可以参考Kubernetes官方文档中关于"NVIDIA Device Plugin"的说明来了解如何安装和配置该插件。

GPU分时共享：另一种提高GPU利用率的方法是使用GPU分时共享技术。这种技术可以将一个GPU设备在时间上进行划分，使多个任务按照时间片的方式共享同一个GPU设备。这样，即使每个任务的GPU利用率较低，整个GPU设备的利用率仍然可以较高。一些工具和框架，如NVIDIA的Virtual GPU Software和NVIDIA MIG（Multi-Instance GPU），提供了GPU分时共享的功能。

请注意，这些方法都需要特定的硬件和软件支持，并且需要进行适当的配置和管理。具体的实施步骤和配置可能因您的环境和需求而有所不同。在尝试这些方法之前，请确保详细阅读相关文档和指南，并确保您的系统满足相应的要求。

如果您希望在Kubernetes中使用虚拟GPU（vGPU）来提高GPU资源的利用率，您可以考虑使用NVIDIA的Virtual GPU（vGPU）技术。

NVIDIA的vGPU技术允许将物理GPU划分为多个虚拟GPU，每个虚拟GPU可以被分配给一个独立的任务或容器。这样，多个任务可以在同一台物理GPU上并行运行，从而提高GPU资源的利用率。

要在Kubernetes中使用vGPU，您可以按照以下步骤进行操作：

安装NVIDIA vGPU软件：请根据NVIDIA官方文档提供的指南，安装和配置适用于您的系统的NVIDIA vGPU软件。

配置NVIDIA vGPU设备插件：Kubernetes社区提供了一个名为"NVIDIA vGPU Device Plugin"的插件，用于将NVIDIA vGPU资源纳入Kubernetes调度框架。您可以按照Kubernetes官方文档中关于"NVIDIA vGPU Device Plugin"的说明，安装和配置该插件。

创建vGPU资源配置：在Kubernetes中，您需要定义vGPU资源的配置。这可以通过创建适当的Kubernetes资源对象（例如，Deployment或StatefulSet）并指定vGPU资源的要求来实现。

部署使用vGPU的应用程序：现在，您可以使用Kubernetes部署使用vGPU的应用程序。在应用程序的Kubernetes配置文件中，您可以指定所需的vGPU资源，并将其分配给相应的容器。

请注意，使用NVIDIA vGPU技术需要满足特定的硬件和软件要求，并且需要进行适当的配置和管理。确保在尝试这些步骤之前详细阅读相关文档，并确保您的系统满足相应的要求。

## sss
"Stable Diffusion"是一个基于稳定分布的生成模型，用于生成高质量的图像和视频。它是一种独立于Kubeflow的机器学习模型，可以在任何支持Python和机器学习框架的环境中进行部署和运行。

虽然"Stable Diffusion"可以在Kubeflow之外进行部署，但您可以将其与Kubeflow集成，以便更好地管理和扩展您的生成模型工作负载。通过将"Stable Diffusion"作为Kubeflow中的一个组件或任务来定义和部署，您可以利用Kubeflow的自动化、可扩展性和监控功能来管理生成模型的训练和推理过程。

要在Kubeflow上部署"Stable Diffusion"，您可以按照以下步骤进行操作：

安装和配置Kubeflow：请按照Kubeflow官方文档中提供的指南，安装和配置Kubeflow集群。

定义"Stable Diffusion"任务：在Kubeflow中，您可以使用Kubernetes原生的资源对象（例如，Deployment或Job）来定义"Stable Diffusion"的训练和推理任务。您可以指定所需的计算资源、数据存储和其他相关参数。

部署"Stable Diffusion"任务：通过使用Kubeflow提供的工具或命令行界面，将"Stable Diffusion"任务部署到Kubeflow集群中。Kubeflow将负责管理任务的运行、监控和自动扩展。

监控和管理：利用Kubeflow的监控和管理功能，您可以跟踪"Stable Diffusion"任务的状态、性能指标和日志。您还可以利用Kubeflow的自动扩展功能，根据需要调整任务的计算资源。

请注意，具体的部署步骤可能会因您的环境和需求而有所不同。建议参考Kubeflow和"Stable Diffusion"的官方文档，以获取更详细的部署指南和配置说明。

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

