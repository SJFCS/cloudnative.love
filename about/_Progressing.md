https://iximiuz.com/en/
https://github.com/yangpeng14/DevOps/tree/master
语雀和notion迁移本地
java remotDebug健康检查中断可以临时关闭 https://www.zhangbj.com/p/1238.html
maven h配置 ttp://www.17coding.top/cicd/maven-primer/

# ========================= 10-12 =======================
## golang
Golang gin gorm
- [✔] udemy-Golang https://www.udemy.com/course/go-the-complete-developers-guide/
- [ ] 11.30 优点知识-Go 运维开发训练营第1-2期 https://youdianzhishi.com/web/course/1035/2530 
- [ ] k8s开发
- [✗] 极客时间-Go 实战训练营 https://u.geekbang.org/lesson/290
## python 预计三天
- ansible二次开发
- ~~Django flask sqlalchemy~~
- udemy-Python 
  - [ ] https://www.youtube.com/watch?v=rfscVS0vtbw
  - [ ] https://www.youtube.com/watch?v=PtQiiknWUcI
  - [ ] https://www.bilibili.com/video/BV1c4411e77t/
  - [ ] https://www.udemy.com/course/python3-chinese/
  - [ ] https://www.bilibili.com/video/BV11q4y1s74P
## 前端 预计60h
https://codelabs.developers.google.com/codelabs/lit-2-for-react-devs?hl=zh-cn#1

React Nextjs TailwindCSS AntDesign shadcnUI chakra-ui/chakra-templates headless-ui ~~material-ui radix NextUI~~ https://juejin.cn/post/7234893047284416570
Redux 和 ~~MobX~~ 主要用于客户端状态的理管理
react-query 和 ~~SWR~~ 主要用于服务器状态的管理
axios 和 ~~fetch~~ 则是在 React 应用程序中进行网络请求的常见方式。

- vue
  https://www.bilibili.com/video/BV12J411m7MG  
  /home/admin/Downloads/快速入门Vue.js资料.zip

## 项目

- 环境效能平台+发布平台+ouath（istio智能路由，集成gitlab和argocd自动创建cicd流程）混部多集群管理 虚拟集群
- 飞书审批应用开发 
  - vpn审批机app+器人 openvpn otp 管理平台
  - 发布管理审批app+
  - gitlab消息推送机器人
- Dynamic Admission Control(动态准入控制器),自定义kube-scheduler，Operator，CRD

<!-- Java nacos openfeign maven/gradle jvm native-image remote-debug arthas -->
## Linux 基础
## 中间件

- hadoop kerberos  ranger  hive impala spark2 hbase
- https://www.cnblogs.com/zhangyinhua/p/7657937.html

- ldap kafka [zookeeper](https://www.bilibili.com/video/BV1Ph411n7Ep) nacos rocketmq
- [etcd](https://www.bilibili.com/video/BV1eY4y1p774/),
- [tomcat](https://www.bilibili.com/video/BV1WP41157ns/)


































# 1 2 3
## 数据库
~~PostgreSQL基于Pacemaker+Corosync+pcs的高可用~~
MySQL mgr+mysqlrouter高可用架构及配置
redis mysql mongodb


- https://www.bilibili.com/video/BV1Kr4y1i7ru/
- https://www.udemy.com/course/mysql-high-performance-tuning-guide/
- 一天学会mysql：https://www.bilibili.com/video/BV1Vt411z7wy/
- https://www.bilibili.com/video/BV12J411Q7gV/
- udemy- MySQL High Performance Tuning Guide https://www.udemy.com/course/mysql-high-performance-tuning-guide/
MongoDB 性能排查。指标监控。主从复制。数据备份。冷数据分析 预计2天
- https://www.bilibili.com/video/BV1WS4y1p7jK/
redis 
- https://www.bilibili.com/video/BV1AP411w75B
- https://www.bilibili.com/video/BV1ZK411M7ov
- https://www.bilibili.com/video/BV1zN4y1A7fA


## k8s 复习：  
新的部署工具
  https://www.padok.fr/en/blog/k0s-kubernetes-gpu
  https://k0sproject.io/
  kURL 
https://zhuanlan.zhihu.com/p/87771259
https://bbs.huaweicloud.com/blogs/205532
https://www.cnblogs.com/dukuan/p/13524622.html
https://blog.csdn.net/xu_binfeng/article/details/113193492
https://my.oschina.net/cncf/blog/4543473
https://www.cnblogs.com/cjwnb/p/12399217.html
https://www.cnblogs.com/superlinux/p/14676959.html
https://team.jiunile.com/blog/2018/12/k8s-kubeadm-ca-upgdate.html
https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md
https://www.coderdocument.com/docs/kubernetes/v1.14/started/production_environment/installing_kubernetes_with_deployment_tools/bootstrapping_clusters_with_kubeadm/customizing_control_plane_configuration_with_kubeadm.html
  - etcd 升级 
    - https://www.cnblogs.com/jesse-joygenio/p/botposter-etcd-migration-to3.html
  - k8s hard way:
    - https://www.kancloud.cn/willfeng/k8s/648723
    - https://www.orchome.com/1195
    - https://cloud-atlas.readthedocs.io/zh_CN/latest/kubernetes_from_scratch/why_kfs.html 
    - https://kubernetes.io/docs/reference/networking/ports-and-protocols/ 
    - https://www.cnblogs.com/Dev0ps/p/11401530.html
  - kubeadm部署指南
    - 自定义参数https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/control-plane-flags/
    - https://kurl.sh/
    - https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-config/
    - https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file
    - https://blog.51cto.com/u_13210651/2358032
    - https://github.com/cookeem/kubeadm-ha/blob/master/README-ZH.md
  - kubespray
    - https://zhuanlan.zhihu.com/p/367564005
    - 升级 https://www.cnblogs.com/EthanSun/p/13652336.html
kubernetes 更改iptables模式为ipvs:
- https://blog.kelu.org/tech/2019/04/04/kubernetes-change-iptable-to-ipvs.html
- https://www.361way.com/k8s-ipvs-iptables/6534.html
- https://github.com/gardener/gardener/issues/4599
- https://github.com/cortexlabs/cortex/issues/1834
- iptables和ipvs 规则下发探究


## 负载均衡
lvs + keepalived 
- udemy-HAProxy https://www.udemy.com/course/haproxy-a/
- 腾讯课堂-Nginx https://ke.qq.com/user/index/index.html#/plan/cid=2292484&term_id=103595308
- nginx http://www.sunrisenan.com/docs/nginx/nginx-1b0ic2kuthbau
- ~~kong **apisix** OpenResty~~

- LVS：https://www.bilibili.com/video/BV1WY4y167ZG https://www.bilibili.com/video/BV15a4y1i7Dw/ https://blog.csdn.net/wzj_110/article/details/92680979  
- https://www.cnblogs.com/garfieldcgf/p/8323531.html
- iptables

## ci/cd
- https://developer.aliyun.com/article/984673
- https://ansible.leops.cn/ 
- https://www.xuliangwei.com/oldxu/1249.html
- udemy-DevOps https://www.udemy.com/course/devops-catalog/
- udemy-**Ansible** https://www.udemy.com/course/learn-ansible/
- udemy-**Helm** https://www.udemy.com/course/helm-kubernetes-packaging-manager-for-developers-and-devops/
- 优点知识-**GitLabCI** 实践课 https://youdianzhishi.com/web/course/1016/1390
- 优点知识-**Jenkins** 实践 https://youdianzhishi.com/web/course/1013/1242
- 腾讯课堂-Jenkins   https://ke.qq.com/user/index/index.html#/plan/cid=2202770&term_id=103587528
- udemy-**Argo Workflows** https://www.udemy.com/course/hands-on-guide-to-argo-workflows-on-kubernetes/

- [Jenkins](https://akomljen.com/set-up-a-jenkins-ci-cd-pipeline-with-kubernetes/)
- groovy 
- http://docs.idevops.site/jenkins/
- http://docs.idevops.site/gitlabci/
- https://www.qikqiak.com/post/gitlab-ci-k8s-cluster-feature/
- Nexus,Artifactory,Harbor,maven-pom 配置私服权限管理 tekton
- argo rollout https://atbug.com/canary-release-via-argo-rollouts-and-service-mesh/

## 服务网格等
istio vs consul vs linkerd
- udemy-Istio https://www.udemy.com/course/istio-hands-on-for-kubernetes/
- 优点知识-Kubernetes 网络训练营

## 观测性
- ~~chao mesh https://litmuschaos.io/~~
- openterlemtry sentry
- udemy-Grafana https://www.udemy.com/course/grafana-tutorial/
- udemy-Prometheus https://www.udemy.com/course/prometheus-course/
- udemy-Kibana https://www.udemy.com/course/data-visualization-with-kibana/
- udemy-Elasticsearch https://www.udemy.com/course/elasticsearch-complete-guide/

- 腾讯课堂-prometheus+grafana https://ke.qq.com/user/index/index.html#/plan/cid=2803292&term_id=102912757
- 腾讯课堂-zabbix5.0          https://ke.qq.com/user/index/index.html#/plan/cid=2767948&term_id=102875976


## blog
- 3.vagrant2yaml配置文件，以及输出lb博客。
- 4.terrform+istio打通多集群网络（混合云）multicloud https://www.kubecost.com/kubernetes-multi-cloud/kubernetes-load-balancer/
- 5.云环境下的开发效率提升思考：jvm 调优和远程dbug，在云环境下实现流量镜像，流量切分，debug中断不退出
#- 6.runtime class
  - kata容器 介绍容器安全和常见方案 在k8s上使用kata  这个写一篇blog和一篇doc简介页面(多网卡)
  - https://github.com/weaveworks/ignite
- 7.1-Argo rollout jvm预热
- 8.基于k8s Ingress Nginx+OAuth2+Gitlab无代码侵入实现自定义服务的外部验证 www.pomerium.com
- 9.多集群提高利用率 viture kubelet  2vcluster 集群多租户 
- 10.-从HPA到KPA Pod 原地垂直伸缩 knative
- 11.Sidecar 启动顺序分析 istio taken
- 12.promethuse 告警机制
- openTelemetry
- argo workflow
- [ETCD Cluster and Non-voting Learners](https://dev.to/simplytunde/etcd-cluster-and-non-voting-learners-4l0b) https://etcd.io/docs/v3.3/learning/learner/

## 这些文章暂时不写
- _深入kubelet创建容器流程
负载均衡浅谈补充docs https://www.zhihu.com/question/601431201/answer/3059114526
linux 进程状态补充docs https://www.zhihu.com/question/308716947/answer/3146219927?utm_id=0

- 好文章 新角度
  - https://blog.fatedier.com/2020/04/17/pod-loopcrash-of-k8s-subpath/
  - https://blog.fatedier.com/2018/12/10/a-connect-timeout-problem-caused-by-k8s-pod-deleting/
  - https://blog.fatedier.com/2020/07/22/k8s-pod-directional-migration/
  - https://blog.fatedier.com/2019/04/02/k8s-custom-controller/
  - https://blog.fatedier.com/2019/03/20/k8s-crd/
  - https://blog.fatedier.com/2019/03/25/k8s-crd-authorization/
  - https://blog.fatedier.com/2018/11/21/service-mesh-traffic-hijack/
  - https://blog.fatedier.com/2022/08/15/istio-pods-crash-cause-full-push/
  - https://blog.fatedier.com/2018/12/01/service-mesh-explore-local-node-lb/

  - pod生命周期和优雅下线 
    - https://zhuanlan.zhihu.com/p/158141567
    - https://imroc.cc/kubernetes/best-practices/graceful-shutdown/persistent-connection.html
    - 不仅仅是 PreStop hook https://aleiwu.com/post/tidb-opeartor-webhook/
  - dns解析 https://www.hi-linux.com/posts/51040.html
  - api鉴权
    - https://zhuanlan.zhihu.com/p/624378284?utm_id=0
    - https://developer.aliyun.com/article/706210













# 不看
## 存储
- 优点知识-云原生存储 Rook 实战 https://youdianzhishi.com/web/course/1025/1850
- 优点知识-Ceph 入门到实战  https://youdianzhishi.com/web/course/1019
https://longhorn.io/
- minio，nfs
- https://nbailey.ca/post/cephfs-kvm-virtual-san/
- https://docs.ceph.com/en/latest/rbd/libvirt/

- 这个高可用概念类似k8s service，能否搞一个脱离k8s的services
  - ebpf ipvs？https://www.ebpf.top/post/xdp_lb_demo/
  - https://juejin.cn/post/7086751522008072206
  - https://github.com/labring/lvscare

## 网络
- 腾讯课堂-CCIE               https://ke.qq.com/user/index/index.html#/plan/cid=300249&term_id=104217633
- 腾讯课堂-思科SDN/网络编程/DC https://ke.qq.com/user/index/index.html#/plan/cid=472811&term_id=100566186
- 腾讯课堂-CCNP               https://ke.qq.com/user/index/index.html#/plan/cid=205745&term_id=103423596
- 腾讯课堂-CCNA               https://ke.qq.com/user/index/index.html#/plan/cid=210374&term_id=103258927
- 极客时间-网络协议集训班-陶辉 https://time.geekbang.org/course/detail/100102201-472901

## 高等数学
- 腾讯课堂-高等数学（上）      https://ke.qq.com/user/index/index.html#/plan/cid=425893&term_id=100508320
- 腾讯课堂-高等数学（下）      https://ke.qq.com/user/index/index.html#/plan/cid=425895&term_id=100508328

## java
- 设计模式: https://refactoringguru.cn/
- java: https://how2j.cn/
- java+大数据 maven管理
  - spring 服务发现框架，配置中心框架 熔断降级 native镜像 

## serverless [8小时]
- https://github.com/localstack/localstack
- https://blog.scottlogic.com/2022/04/16/wasm-faas.html

- https://www.openfaas.com/
- knative 
- Dapr https://www.cnblogs.com/shanyou/p/15556449.html  https://zhonghua.io/2021/04/07/dapr/
- https://developer.aliyun.com/learning/roadmap/serverless
- https://space.bilibili.com/102734951/search/video?keyword=knative
- https://www.bilibili.com/video/BV12K4y1o72s/
- [美团Serverless平台Nest的探索与实践](https://tech.meituan.com/2021/04/21/nest-serverless.html)
- [高德 Serverless 平台建设及实践](https://xie.infoq.cn/article/686a83fccba14504517ec6fe5)
- [基于 Serverless 的部署平台构建与思考](https://unix.bio/posts/thinking-under-serverless)

## 其他想法
- 兼容 Alfred，utools 更小更快兼容 wayland 支持自定义 workflow，utools借鉴google的搜索栏tabl搜索 https://github.com/kaiye/workflows-youdao https://github.com/kaiye/kaiye.github.com/issues/5
- 终端软件和零信任集成，能共享终端 能操作回放、录制和审计，笔记软件交互模式，ppt模式,playground，在线实验室，课程发布平台，web ide，字符录制-音频转换-webide-ide-环境隔离-终端分享
- 联调工具，java remotDebug健康检查中断可以临时关闭，configmanp作为变量注入容器，本地无法访问，而且存储无法访问。https://www.zhangbj.com/p/1238.html
  - https://developer.aliyun.com/article/812828?utm_content=m_1000310320 
-  cert manager 管理平台 https://platform.jetstack.io/login
-  iac管理平台 
   -  https://spacelift.io/
   -  https://github.com/idcos/cloudiac
   -  https://developer.aliyun.com/article/792479
- excalidraw [添加中文支持](https://github.com/korbinzhao/excalidraw-cn/commit/799b9e6a6c2cba443e0102959063dcfaba8da8a4)

- 流量镜像：
  - https://aws.amazon.com/cn/blogs/china/traffic-replication-on-amazon-eks-using-the-nginx-ingress-mirror-feature/
  - https://www.kubesphere.io/zh/docs/v3.3/project-user-guide/grayscale-release/traffic-mirroring/
  - https://developer.aliyun.com/article/782368
  - https://github.com/metalbear-co/mirrord
分析taken的启动顺序
kubelet linux 命名空间 网络 自己实现cni
sechdurel 调度器 授权过程，自定义审计控制器

## 机器学习(AI绘画，GPT模型，时间序列预测)  区块链 金融知识和量化交易 机器学习流水线编排

- https://bigquant.com/wiki/home
- https://github.com/bmpi-dev/invest-alchemy
- https://github.com/sangyx/deep-finance
- https://www.miotech.com/zh-CN/article/4

## 英语
- https://learning.oreilly.com/courses/
- https://news.ycombinator.com/news
- https://github.com/byoungd/English-level-up-tips
- https://csdiy.wiki/%E5%BF%85%E5%AD%A6%E5%B7%A5%E5%85%B7/workflow/
- https://github.com/yujiangshui/A-Programmers-Guide-to-English
- https://github.com/xiaolai/everyone-can-use-english

- BEC higher A 
- https://www.thefreedictionary.com/
- https://thiscute.world/posts/learn-english-again/