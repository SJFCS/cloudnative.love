---
title: Kubernetes-DEV-Notes
---



---
title: Kubernetes-Enhancement-Proposal-(KEP)-Translate
---
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