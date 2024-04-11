本文介绍K8s中的鉴权模块。对其4种鉴权模式都进行了概述讲解。结合例子着重对大家日常中使用最多的RBAC鉴权模式进行了说明。

不论是通过kubectl客户端还是REST请求访问K8s集群，最终都需要经过API Server来进行资源的操作并通过Etcd

请求发起方进行K8s API请求，经过Authentication（认证）、Authorization（鉴权）、AdmissionControl（准入控制）三个阶段的校验，最后把请求转化为对K8s对象的变更操作持久化至etcd中。

其中认证主要解决的是请求来源能否访问的问题。即通过了认证，那么可以认为它是一个合法的请求对象。那么如何去决定请求对象能访问哪些资源以及对这些资源能进行哪些操作，便是鉴权所要完成的事情了。

鉴权的最终目的，是区分请求对象，限定操作的影响范围，让其使用最小的权限完成自己所要进行操作，从而进一步保证安全。权限控制的划分方式有许多种，K8s中提供了4种鉴权模式，分别为Node、ABAC、RBAC和Webhook。

默认情况下，我们可以从/etc/kubernates/manifests/kube-apiserver.yaml文件中查看apiserver启动时认证模式


https://mmbiz.qpic.cn/mmbiz_png/DmBLZYMe830OGM3cyMasD8FuXJ2zxnX0xuGdVeCMQubSBaVDSBN5brIricGH4fZ9WK0tx3LjRza3m789F85HwLw/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1




| 参数配置                          | 含义                                             | 一般的使用场景                                                                                                                |
| --------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| \--authorization-mode=ABAC        | 使用基于属性的访问控制(ABAC)                     | 根据用户的用户名或者组名来控制其对集群资源的访问权限，适用于较小的组织或开发团队                                              |
| \--authorization-mode=RBAC        | 使用基于角色的访问控制(RBAC)                     | 自定义ServiceAccount，绑定资源根据角色来控制资源的访问权限，适用于较大型的组织或者开发运维团队                                |
| \--authorization-mode=Webhook     | 使用HTTP回调模式，允许你使用远程REST端点管理鉴权 | 将鉴权角色交给外部服务进行处理，根据自身需求，定制和扩展鉴权策略，如自定义Webhook鉴权模块对跨云平台的应用进行集中的的访问控制 |
| \--authorization-mode=Node        | 针对kubelet发出的API请求执行鉴权                 | 验证节点身份，确保只有经过身份验证且具有所需权限的Node才能连接到K8s集群                                                       |
| \--authorization-mode=AlwaysDeny  | 阻止所有请求                                     | 一般仅用作测试                                                                                                                |
| \--authorization-mode=AlwaysAllow | 允许所有请求                                     | 不需要API请求进行鉴权的场景                                                                                                   |
https://mp.weixin.qq.com/s/hPlcmrtGHXUS4bhh0pLKKg