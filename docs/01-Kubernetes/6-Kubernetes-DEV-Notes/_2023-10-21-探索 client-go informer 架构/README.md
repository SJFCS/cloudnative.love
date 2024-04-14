---
title: 探索 client-go informer 架构
---

clientset -> 缓存 --> informer

reflector ->fifo ->deltafifo ->indexer ->sharedinformer

队列实现

<!-- truncate -->
oprater  k8s代码分析 为什么说k8s核心不是容器而是api

- https://arthurchiao.art/blog/k8s-is-about-apis-zh/
- https://arthurchiao.art/blog/k8s-is-about-apis-2-zh/

[Informer](https://github.com/kubernetes/sample-controller/blob/master/docs/images/client-go-controller-interaction.jpeg?ref=aly.arriqaaq.com)


