---
title: Kyverno
tags: [Security,Kyverno]
---

相比 Open Policy Agent 而言 [kyverno](https://github.com/kyverno/kyverno) 更简单直观。

## 使用案例

- 自动添加默认的 SecurityContext、podAntiAffinity、禁用 default 名字空间、禁用镜像的 latest 标签等
- 跨名字空间同步 secrets

## 功能类似的其他软件

- https://github.com/datreeio/datree: 这是一个客户端的 yaml 检查工具，也可以实现禁用 default 名字空间、禁用镜像的 latest 标签等功能
  - 这个可以集成在 CI 里面，而 kyverno 可以作为「集群守门员」，双管齐下。

## 参考

- [Kyverno: The Swiss Army Knife of Kubernetes](https://neonmirrors.net/post/2021-01/kyverno-the-swiss-army-knife-of-kubernetes/)
- https://www.youtube.com/watch?v=2v0_Bj6BAt0
- https://betterprogramming.pub/policy-as-code-on-kubernetes-with-kyverno-b144749f144