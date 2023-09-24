---
title: 本地 Kubernetes 集群 LoadBalancer 方案选择
---

比较开源 k8s LoadBalancer-MetalLB vs PureLB vs OpenELB https://cloud.tencent.com/developer/article/1985814 

自定义代码 https://just4coding.com/2021/11/21/custom-loadbalancer/

k8s的tunnel
https://blog.alexellis.io/ingress-for-your-local-kubernetes-cluster/
https://nyan.im/p/cloudflare-tunnel-on-kubernetes
https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/

公有云lb https://spacelift.io/blog/kubernetes-load-balancer

Kubernetes没有给本地环境(Bare-metal, On-Premise)提供负载均衡实现，LoadBalancer类型的服务主要在各大公有云厂商上能够得到原生支持。在本地环境创建LoadBalancer类型的服务后，服务的EXTERNAL-IP会一直处于pending状态。这是因为在本地环境没有相应的controller来处理这些LoadBalancer服务。比如:
```
[root@master1 vagrant]# kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.32.0.1     <none>        443/TCP        31d
whoami       LoadBalancer   10.32.0.132   <pending>     80:31620/TCP   103s
```


https://www.reddit.com/r/kubernetes/comments/rkiojs/openelb_joins_the_cncf_sandbox_making_service/


metallb 
[使用 Calico 和 Metallb ](https://metallb.universe.tf/configuration/calico/#workaround-peer-with-spine-routers)时存在已知的 BGP 冲突。


https://www.sobyte.net/post/2022-04/openelb-lb/

https://tinychen.com/20220519-k8s-06-loadbalancer-metallb/


https://blog.cnscud.com/k8s/2021/09/17/k8s-metalb.html



