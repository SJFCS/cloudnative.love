---
title:  Kubernetes Sidecar 启动顺序浅谈
tags: [Kubernetes]
---
这个警告信息意味着在 Kubernetes 版本 v1.16+ 中，针对调度的注释字段 "scheduler.alpha.kubernetes.io/critical-pod" 已经不再起作用，应该使用 "priorityClassName" 字段来指定 Pod 的优先级。
https://imroc.cc/post/202105/sidecar-startup-order/


看看主流的工具是如何控制启动顺序的 openkeris istio taken