## 本周

https://github.com/TencentBlueKing/bk-bcs
https://iximiuz.com/en/
https://github.com/yangpeng14/DevOps/blob/master/kubernetes/%E6%97%A0%E9%9C%80%E7%89%B9%E6%9D%83%E5%9C%A8Kubernetes%E4%B8%AD%E6%9E%84%E5%BB%BA%E9%95%9C%E5%83%8F%E4%B9%8BKaniko.md

- 本机GPU设置  k8s容器GPU设置 部署 stabledisfution on k8s 这个作为一篇blog
  - https://ivonblog.com/posts/stable-diffusion-webui-manuals/installation/docker-installation/
  - https://sygil-dev.github.io/sygil-webui/docs/Installation/docker-guide/
  - 参考这个看看能不能 展示更多用例 https://www.replicated.com/blog/how-to-run-gpu-workloads-on-a-k8s-cluster-with-kurl
- kata容器 介绍容器安全和常见方案 在k8s上使用kata  这个写一篇blog和一篇doc简介页面
- k8s kind loadbalancer  部署合适的lb，且整理合适的临时k8s kind和vagrant配置文件，以及输出lb博客。
    - [LoadBalancer](https://just4coding.com/2021/11/21/custom-loadbalancer/)
    - [openelb](https://www.qikqiak.com/post/openelb/) 
    - https://cloud.tencent.com/developer/article/1985814
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

## 下周
k8s 部署：
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
- LVS：https://www.bilibili.com/video/BV1WY4y167ZG 
- lvs：https://www.bilibili.com/video/BV15a4y1i7Dw/
- lvs扫盲 https://blog.csdn.net/wzj_110/article/details/92680979  
- https://www.cnblogs.com/garfieldcgf/p/8323531.html
- iptables+++

kubernetes 更改iptables模式为ipvs:
- https://blog.kelu.org/tech/2019/04/04/kubernetes-change-iptable-to-ipvs.html
- https://www.361way.com/k8s-ipvs-iptables/6534.html
- https://github.com/gardener/gardener/issues/4599
- https://github.com/cortexlabs/cortex/issues/1834
- iptables和ipvs 规则下发探究
# 8
## 负载均衡
- haproxy：https://www.bilibili.com/video/BV1gz4y1y7Nx
- udemy-HAProxy https://www.udemy.com/course/haproxy-a/
  
- 腾讯课堂-Nginx https://ke.qq.com/user/index/index.html#/plan/cid=2292484&term_id=103595308
  
- kong apisix OpenResty
# 9-10
考完 阿里云ACE

## 服务网格等
istio vs consul vs linkerd
- udemy-Istio https://www.udemy.com/course/istio-hands-on-for-kubernetes/
- 优点知识-Kubernetes 网络训练营第1期 https://youdianzhishi.com/web/course/1021/1793
- 优点知识-Kubernetes 网络训练营第2期 https://youdianzhishi.com/web/course/1029/2020
- 优点知识-Kubernetes 网络训练营第3期 https://youdianzhishi.com/web/course/1031/2270
## 存储
- 优点知识-云原生存储 Rook 实战 https://youdianzhishi.com/web/course/1025/1850
- 优点知识-Ceph 入门到实战  https://youdianzhishi.com/web/course/1019
https://longhorn.io/
- minio，nfs
- https://nbailey.ca/post/cephfs-kvm-virtual-san/
- https://docs.ceph.com/en/latest/rbd/libvirt/

## 观测性
- chao mesh https://litmuschaos.io/
- openterlemtry sentry
- udemy-Grafana https://www.udemy.com/course/grafana-tutorial/
- udemy-Prometheus https://www.udemy.com/course/prometheus-course/
- udemy-Kibana https://www.udemy.com/course/data-visualization-with-kibana/
- udemy-Elasticsearch https://www.udemy.com/course/elasticsearch-complete-guide/

- 腾讯课堂-prometheus+grafana https://ke.qq.com/user/index/index.html#/plan/cid=2803292&term_id=102912757
- 腾讯课堂-zabbix5.0          https://ke.qq.com/user/index/index.html#/plan/cid=2767948&term_id=102875976
# 11-12
## 数据库
mysql ocp?
PostgreSQL基于Pacemaker+Corosync+pcs的高可用
MySQL mgr+mysqlrouter高可用架构及配置

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

# 1 2 3
## golang
- udemy-Golang https://www.udemy.com/course/go-the-complete-developers-guide/
- 优点知识-Go 运维开发训练营第1期 https://youdianzhishi.com/web/course/1035/2530
- 极客时间-Go 实战训练营 https://u.geekbang.org/lesson/290
## python
- ansible二次开发
- Django flask 
- udemy-Python https://www.udemy.com/course/python3-chinese/
  - https://www.udemy.com/course/python3-chinese/
  - https://www.bilibili.com/video/BV11q4y1s74P
  - https://www.bilibili.com/video/BV1qW4y1a7fU
  - https://www.bilibili.com/video/BV1wD4y1o7AS
## 前端
- vue
  https://www.bilibili.com/video/BV12J411m7MG  
  /home/admin/Downloads/快速入门Vue.js资料.zip
- react
- node

## ci/cd
- https://developer.aliyun.com/article/984673
- https://ansible.leops.cn/ https://www.xuliangwei.com/oldxu/1249.html
- udemy-DevOps https://www.udemy.com/course/devops-catalog/
- udemy-Ansible https://www.udemy.com/course/learn-ansible/
- udemy-Helm https://www.udemy.com/course/helm-kubernetes-packaging-manager-for-developers-and-devops/
- 优点知识-GitLabCI 实践课 https://youdianzhishi.com/web/course/1016/1390
- 优点知识-Jenkins 实践 https://youdianzhishi.com/web/course/1013/1242
- 腾讯课堂-Jenkins   https://ke.qq.com/user/index/index.html#/plan/cid=2202770&term_id=103587528
- udemy-Argo Workflows https://www.udemy.com/course/hands-on-guide-to-argo-workflows-on-kubernetes/

- [Jenkins](https://akomljen.com/set-up-a-jenkins-ci-cd-pipeline-with-kubernetes/)
- groovy 
- http://docs.idevops.site/jenkins/
- http://docs.idevops.site/gitlabci/
- https://www.qikqiak.com/post/gitlab-ci-k8s-cluster-feature/
- Nexus,Artifactory,Harbor,maven-pom 配置私服权限管理 tekton
- argo rollout https://atbug.com/canary-release-via-argo-rollouts-and-service-mesh/
## hashicorp

- udemy-Consul 2023 (Hands-On Labs) https://www.udemy.com/course/hashicorp-consul/
- udemy-Consul Associate Practice Exam https://www.udemy.com/course/consul-associate-practice-exam/
- udemy-Vault 2023 (Hands-On Labs) https://www.udemy.com/course/hashicorp-vault/
- udemy-Vault Associate - Practice Exam - 2023 https://www.udemy.com/course/hashicorp-certified-vault-associate-practice-exam/
- udemy-Terraform Associate Practice Exam 2023 https://www.udemy.com/course/terraform-associate-practice-exam/
- udemy-Terraform Associate 2023 https://www.udemy.com/course/terraform-beginner-to-advanced/

## 网络
- 腾讯课堂-CCIE               https://ke.qq.com/user/index/index.html#/plan/cid=300249&term_id=104217633
- 腾讯课堂-思科SDN/网络编程/DC https://ke.qq.com/user/index/index.html#/plan/cid=472811&term_id=100566186
- 腾讯课堂-CCNP               https://ke.qq.com/user/index/index.html#/plan/cid=205745&term_id=103423596
- 腾讯课堂-CCNA               https://ke.qq.com/user/index/index.html#/plan/cid=210374&term_id=103258927
- 极客时间-网络协议集训班-陶辉 https://time.geekbang.org/course/detail/100102201-472901


## 中间件
这些中间件写成ansible，参考easyops
kerberos
hdfs
ranger
yarn
hive
impala
spark2
hbase

nacos
rocketmq

redis
grafana
logstash
ldap
kafka
zookeeper [5小时]
- https://www.bilibili.com/video/BV1Ph411n7Ep/
- https://www.bilibili.com/video/BV1to4y1C7gw/

- [etcd](https://www.bilibili.com/video/BV1eY4y1p774/),
- [tomcat](https://www.bilibili.com/video/BV1WP41157ns/)
- udemy-OpenVPN  https://www.udemy.com/course/openvpn-verstehen-und-einrichten-sicher-im-netzwerk/
- 优点知识-打造云原生大型分布式监控系统 https://youdianzhishi.com/web/course/1015/1389
- 优点知识-Webpack3.x 快速入门https://youdianzhishi.com/web/course/1003/1009
- 优点知识-云原生免费公开课 https://youdianzhishi.com/web/course/1014/1475
- lua https://wiki.luatos.com/luaGuide/introduction.html







## 写作
terrform打通多集群网络（混合云）
Kubernetes-The-Hard-Way-Translate
  翻译原文并添加 vagrant/Terraform 实验环境,集成 crowdin 翻译  
  Kubernetes the hard way on Vagrant on Local Machine. No scripts.  
各种中间件 
  hadoop+kerberos+flink+zookeeper+kafka+HBase
  nacos ElasticSearch Kong RocketMQ
## 开发
Python Django/flask sqlalchemy【了解就行，写几个demo，看看别人的CMDB，脚本要写的溜】
Golang gin gorm【熟练CURD】
React、TailwindCSS 【熟练写UI】 //Prisma/typeorm/sequelize Next.js、Socket.io、Node.js、Express.js
Java nacos openfeign maven/gradle jvm native-image remote-debug arthas

我对 multicloud,Dynamic Admission Control(动态准入控制器),自定义kube-scheduler，Operator，CRD ，Kubernetes的实现方法感兴趣，想进一步深入了解 Kubernetes 。

### 开发待做
- k8s 运维平台 https://github.com/erda-project/erda
- 环境效能平台（istio智能路由，集成gitlab和argocd自动创建cicd流程）混部多集群管理 虚拟集群
- 飞书机器人开发 gitlab 支持和告警拉群支持，+gpt分析k8s事件 https://github.com/justjavac/deno_feishu_bot_echo
- 飞书审批demo
- openvpn otp 管理平台 集成飞书 ldap auth2等 动态身份验证器 环境代理 VPN。openldap管理 http://ldapdoc.eryajf.net

- nacos 优雅下线工具 配置管理gitops工具
- jvm 调优和远程dbug，在云环境下实现流量镜像，流量切分，debug中断不退出
- 熟悉主流云平台，如 AWS,阿里云等的管理工具，精通 InfrastructureasCode 理念，熟练掌握 Terraform，CloudFormaction。

- 这个高可用概念类似k8s service，能否搞一个脱离k8s的services
  - ebpf ipvs？https://www.ebpf.top/post/xdp_lb_demo/
  - https://juejin.cn/post/7086751522008072206
  - https://github.com/labring/lvscare



# 暂时不看
  - AI：
    - 绘画
    - 代码提示 
    - [搭建本地代码搜素](https://bloop.ai/) 
    - ai 本地文档助手
    - k8s助手
    - sql助手
  - https://github.com/localstack/localstack
## 高等数学
- 腾讯课堂-高等数学（上）      https://ke.qq.com/user/index/index.html#/plan/cid=425893&term_id=100508320
- 腾讯课堂-高等数学（下）      https://ke.qq.com/user/index/index.html#/plan/cid=425895&term_id=100508328

## java
- 设计模式: https://refactoringguru.cn/
- java: https://how2j.cn/
- java+大数据 maven管理
  - spring 服务发现框架，配置中心框架 熔断降级 native镜像 

## serverless [8小时]
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
  - https://developer.aliyun.com/article/812828?utm_content=m_1000310320 
-  cert manager 管理平台
-  iac管理平台 
   -  https://spacelift.io/
   -  https://github.com/idcos/cloudiac
   -  https://developer.aliyun.com/article/792479
- excalidraw [添加中文支持](https://github.com/korbinzhao/excalidraw-cn/commit/799b9e6a6c2cba443e0102959063dcfaba8da8a4)

- debug健康检查中断可以临时关闭，configmanp作为变量注入容器，本地无法访问，而且存储无法访问。
- 流量镜像：
  - https://aws.amazon.com/cn/blogs/china/traffic-replication-on-amazon-eks-using-the-nginx-ingress-mirror-feature/
  - https://www.kubesphere.io/zh/docs/v3.3/project-user-guide/grayscale-release/traffic-mirroring/
  - https://developer.aliyun.com/article/782368
  - https://github.com/metalbear-co/mirrord
分析taken的启动顺序
kubelet linux 命名空间 网络 自己实现cni
sechdurel 调度器 授权过程，自定义审计控制器



