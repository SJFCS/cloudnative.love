---
title: 开发笔记
---
## SouceCodeAnalysis
- https://github.com/rfyiamcool/notes
- https://github.com/daniel-hutao/k8s-source-code-analysis
- https://github.com/Kevin-fqh/learning-k8s-source-code
- https://github.com/luozhiyun993/luozhiyun-SourceLearn
- https://github.com/rfyiamcool/notes#kubernetes

http://newto.me/tech/

https://blog.tianfeiyu.com/2022/06/30/kubernetes_descheduler/

https://github.com/gosoon/source-code-reading-notes




https://zhuanlan.zhihu.com/p/179197052?utm_id=0

kebelet学习总结
Device Plugin Manager模块
kubelet——cadvisor分析
kubelet——gc模块
kubelet——Kubernetes Eviction Manager
kubelet——pleg模块分析
Kubelet pod 创建流程
kubelet——statusManager and probeManager模块
kubelet——volume manager模块
kubelet启动流程分析
kubelet镜像容器垃圾回收

租户隔离与 RBAC 相关
k8s网关第一阶段RBAC规则设置
多租户下 Kubelet TLS Bootstrap 方案
用户证书签发方案
租户 RBAC 规则说明和适配约定
租户隔离与RBAC 权限控制方案
租户默认 RBAC 控制器方案



Apiserver增加本地缓存的修改方案
垂直扩容和回收站恢复
快照和扩容功能的基本实现原理
冷重启
裸机/GPU用户接入情况
容器去L3解耦
容器用户数据分离



k8s用户证书签发流程


Ingress: exposing tcp and udp services
Ingress: https和客户端认证
Ingress: multiple ingress controller
Ingress:负载均衡
Ingress:会话保持
Ingress:后端健康检查
Ingress:监控部署方案
ingress-nginx部署方案
Ingress：健康检查
轻舟环境 Kubernetes 组件资源需求与建议预留总结
轻舟k8s v1.11.1 metrics-server部署



k8s原生设计
API Changes:新增api过程和api版本说明
attach_deatch_controller分析——版本1.11
CustomResourceDefinition 自定义资源
deployment开发文档
deployment说明文档
device-plugin插件和extended-resource
Init Container 使用文档
k8s api 约定
k8s HPA 介绍
k8s部署架构说明文档
k8s的插件机制
k8s原生所有Event事件整理
K8S部署文档
kubeadm 说明
kubelet资源预留方案
Kubernetes 1.8 代码结构
Kubernetes gc使用说明
kubernetes gc原理
kubernetes RBAC的使用和源码分析
kubernetes准入插件原理
kube-scheduler predicate条件
pod驱逐和抢占式调度
1 pod priority和critical pod
2 pod eviction
3 Pod Priority方案设计
pod中status说明
PV_Controller工作流程分析——版本1.11
StatefulSet Controller分析 --- 版本1.9.2
StorageClass
调度器二次开发规范
调度器基本调度流程
容器错误码总结
新增API过程
资源ownerReference字段更改的影响






Kubernetes-Enhancement-Proposal-(KEP)-Translate

- https://github.com/kubernetes/community/tree/master/contributors/devel

[kubernetes/enhancements](https://github.com/kubernetes/enhancements)这个仓库是Kubernetes社区用于跟踪和管理Kubernetes版本迭代的开发进程的仓库。

在`https://github.com/kubernetes/enhancements/tree/master/keps`这个目录中，你可以浏览所有的Kubernetes特性提案，包括已经被接受的、正在进行中的和已经完成的提案。每个提案都有一个独立的KEP（Kubernetes Enhancement Proposal）文档，其中包含了该提案的详细描述、动机、设计、实现等信息。在KEP文档中，你还可以找到该提案的作者、审核人员、代码贡献者等信息。

该仓库主要包括以下内容：

1. Kubernetes版本的特性列表：在该仓库中，您可以查看即将发布的Kubernetes版本的特性列表，以及特性的详细描述和实现进度。

2. Kubernetes特性提案：该仓库还是一个提案库，社区成员可以在这里提交新的Kubernetes特性提案，并与其他人讨论和协作改进。

3. 版本迭代计划：针对每个Kubernetes版本，该仓库中都包含一个详细的迭代计划，其中包括版本发布日期、特性的实现进度、测试计划等信息，以确保版本的稳定性和质量。

通过这个仓库，Kubernetes社区能够更好地跟踪和管理版本迭代的开发进程，使得Kubernetes更加稳定、可靠、强大和易于使用。


通过查看特性提案，你可以了解Kubernetes的最新特性和发展方向，以及参与到Kubernetes社区的开发中来





PEP
  - https://github.com/icexmoon/PEP-CN
  - https://github.com/chinesehuazhou/peps-cn/blob/master/%E5%AD%A6%E4%B9%A0Python%EF%BC%8C%E6%80%8E%E8%83%BD%E4%B8%8D%E6%87%82%E7%82%B9PEP%E5%91%A2%EF%BC%9F.md

## faq

[Kubernetes 有着极多的扩展点，比如 CNI、CRI、CSI、Device Plugin、CRD 等。](https://zhuanlan.zhihu.com/p/47659863)

[kubernetes 中的乐观并发控制](https://zjj2wry.github.io/post/kubes/optimistic_concurrency_control/)

https://www.redhat.com/zh/topics/containers/what-is-a-kubernetes-operator

    Kubernetes中的CRD（Custom Resource Definition）是一种自定义资源类型，可以扩展Kubernetes API，使开发者可以定义自己的资源类型。CRD定义了一种新的API对象，可以在Kubernetes中使用kubectl等工具进行管理，包括创建、更新、删除等操作。CRD可以让开发者定义自己的资源类型，并将其存储在etcd中。

    Operator是一种Kubernetes应用程序，可以自动化管理和操作CRD资源。Operator可以根据自定义资源的状态和事件，自动执行一些动作，例如自动扩容、备份和恢复等。Operator可以使开发者将自己的应用程序和基础设施作为自定义资源类型，从而更容易地进行管理和操作。

    因此，CRD是一种定义自定义资源类型的方式，而Operator是一种自动化管理和操作CRD资源的应用程序。它们之间的关系是：开发者使用CRD定义自己的资源类型，然后使用Operator自动化管理和操作这些资源。

https://www.cloudtruth.com/

https://github.com/robusta-dev/kubernetes-chatgpt-bot

https://blog.devgenius.io/k8s-chatgpt-bot-for-intelligent-troubleshooting-36e0a4a071c5

https://yashwanth-nimmala.medium.com/cloudtruth-integration-with-k8-bb20ba467f0c

https://yashwanth-nimmala.medium.com/kubernetes-security-k8s-resources-scanning-using-kubescape-539c7d099454