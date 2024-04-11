---
title: Kubernetes 中如何改善 JVM 预热（Warm-up）
---
- **java项目的启动加速和可观测性jvm优化，还有服务发现下沉**
  maxsurge maxunavailable  java crs加速   垂直缩放
  
Argo rollout 结合 Istio 实现优雅发布 蓝绿发布， jvm预热 原地垂直扩展 java优化！！！
<!-- truncate -->
commonAnnotations:
  armsPilotAutoEnable: "on"
  armsPilotCreateAppName: matrix-lanling-services-prod
  #msePilotAutoEnable: "on"
  #msePilotCreateAppName: matrix-lanling-services-prod

- https://zhuanlan.zhihu.com/p/420992954
- https://learn.microsoft.com/zh-cn/azure/developer/java/containers/kubernetes
- https://blog.csanchez.org/2017/05/31/running-a-jvm-in-a-container-without-getting-killed/
- https://medium.com/blablacar/warm-up-the-relationship-between-java-and-kubernetes-7fc5741f9a23
- https://tech.olx.com/improving-jvm-warm-up-on-kubernetes-1b27dd8ecd58
- https://stackoverflow.com/questions/74517652/gradually-warm-java-application-in-k8s-with-istio
- https://discuss.istio.io/t/how-to-coordinate-warm-up-and-kubernetes-rolling-update/14154
比如Java程序启动时因为JVM预热、框架初始化等原因，通常资源使用率超高。HPA就会觉得资源不足，于是再新起一个Pod，结果新起的Pod还是资源使用率超高，导致HPA不断起新Pods。。。直到hit预设的max Pod number...

