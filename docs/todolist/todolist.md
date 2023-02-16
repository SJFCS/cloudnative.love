---
title: todolist
---
## 计划列表 2023-2025
| 任务                               | 进度  | 时间  |
| :--------------------------------- | :---: | :---: |
| [考取证书](#计划证书)              |       | 2023  |
| [提升运维开发技能](#运维开发技能)  |       | 2023  |
| [输出技术文档](#技术文档写作)      |       | 2023  |
| [Kubernetes 进阶](#kubernetes进阶) |       | 2024  |
| [阅读书籍](#书籍清单)              |       |   /   |
| [提高英语阅读能力](#英语)          |       |   /   |


## 证书规划
### 在期证书
| 证书名称                         |  考试日期  |   有效期   |
| :------------------------------- | :--------: | :--------: |
| Kubernetes 管理员认证     (CKA)  | 2022.11.27 | 2025.11.27 |
| Kubernetes 应用开发者认证 (CKAD) | 2022.12.07 | 2025.12.07 |
| Kubernetes 安全专家认证   (CKS)  | 2022.12.19 | 2024.12.19 |
                 	  
### 计划证书
| 证书名称                                         | 计划考试日期 | 有效期 |
| :----------------------------------------------- | :----------: | :----: |
| Red Hat Certified Engineer 红帽认证工程师 (RHCE) |   2023.04    |  2026  |
| 阿里云                     (ACE)                 |     2024     |  2026  |
| DBA MySQL                                        |   2023.10    |   /    |
| AWS                                              |   2023.12    |  2026  |
| 其他云原生认证 istio terraform promethuse        |   2024.03    |        |
- GCP
  - https://www.cloudskillsboost.google/
- aws
  - https://iteablue.com/posts/aws-certification-introduction.html
  - https://www.xiaoheiwoo.com/aws-certification-path/
- 阿里云学习
  - ecs，rds，slb，eip，nat
  - 熟悉主流云平台，如AWS,阿里云等的管理工具，精通InfrastructureasCode理念，熟练掌握Terraform，CloudFormaction。
  - 熟悉云服务的VPC，子网分配，安全组配置，负载均衡，WAF配置，网络安全等基本网络技能。
  - https://help.aliyun.com/learn/getting-started.html
  - https://www.alibabacloud.com/zh/getting-started
  - https://www.bilibili.com/video/BV1aS4y1h7Xx
  - https://zhuanlan.zhihu.com/p/377825358
  - https://space.bilibili.com/577769699
  - https://developer.aliyun.com/adc/scenarioSeries/87415f8f4e294c61a104157d11b583ce
  - https://zhuanlan.zhihu.com/p/377085035
  - https://zhuanlan.zhihu.com/p/592823457
### 已过期证书（不打算再续期）
| 证书名称                                  |  考试日期  |   有效期   |
| :---------------------------------------- | :--------: | :--------: |
| 阿里云 DevOps 工程师认证    (ACA)         | 2021.08.31 | 2023.08.31 |
| 阿里云 云计算工程师认证      (ACP)        |  2021.03   |  2023.03   |
| 红帽 Linux 系统管理员认证   (RHCSA)       | 2018.10.19 |            |
| H3C 网络工程师认证          (H3CNE)       | 2020.07.20 | 2023.07.20 |
| H3C 云计算工程师认证        (H3CNE-Cloud) | 2020.06.22 | 2023.06.22 |
| 云计算大数据讲师认证        (CETC)        |            |     /      |




## 运维开发技能
前端
微前端
serverless
webassembly
python lua shell rust
golang 
java
  学习一下spring架构，我现在了解的远远不够，包括服务发现框架，配置中心框架，熔断降级，native镜像，
  openterlemtry sentry
    其他云原生工具 IAC vault certmanager 等等

### python
  - 15h：https://www.udemy.com/course/python3-chinese/
  - 15h:  https://www.bilibili.com/video/BV11q4y1s74P
  - https://www.bilibili.com/video/BV1qW4y1a7fU
  - https://www.bilibili.com/video/BV1wD4y1o7AS
### 负载均衡 [16小时]
- LVS：https://www.bilibili.com/video/BV1WY4y167ZG 
- lvs：https://www.bilibili.com/video/BV15a4y1i7Dw/
- lvs扫盲 https://blog.csdn.net/wzj_110/article/details/92680979  
- haproxy：https://www.bilibili.com/video/BV1gz4y1y7Nx
- haproxy：https://www.udemy.com/course/haproxy-a/
- nginx:**腾讯课堂：** Nginx 从入门到百万并发实战   https://www.cnblogs.com/kevingrace/category/839102.html
- ipvs,iptables  基本了解 
- https://icloudnative.io/posts/ipvs-how-kubernetes-services-direct-traffic-to-pods/
- https://dudashuang.com/load-blance/
- https://www.youtube.com/watch?v=lkXLsD6-4jA
- https://jishuin.proginn.com/p/763bfbd5f406
- https://blog.51cto.com/search/user?uid=11441275&q=lvs
- https://www.zsythink.net/archives/2134
- https://www.qikqiak.com/post/how-to-use-ipvs-in-kubernetes/
- https://space.bilibili.com/500659532
- https://www.cnblogs.com/luozhiyun/p/13782077.html

### 服务网格等[70小时]
- [envoy,istio](https://www.udemy.com/course/istio-hands-on-for-kubernetes/)
- [flannel,calico,cilium**优点知识：**  Kubernetes 网络训练营第3期 ](https://youdianzhishi.com/web/course/1031/2270)
- Dapr 了解 https://www.cnblogs.com/shanyou/p/15556449.html  https://zhonghua.io/2021/04/07/dapr/
- Jaeger golang opentelemetry 了解

### 中间件 [50小时]
mysql [40小时]
- 30h：https://www.bilibili.com/video/BV1Kr4y1i7ru/
- 3h：https://www.udemy.com/course/mysql-high-performance-tuning-guide/
-一天学会mysql：https://www.bilibili.com/video/BV1Vt411z7wy/
- 61h：https://www.bilibili.com/video/BV12J411Q7gV/

redis [6小时]
- 6h：https://www.bilibili.com/video/BV1AP411w75B
- https://www.bilibili.com/video/BV1ZK411M7ov
- https://www.bilibili.com/video/BV1zN4y1A7fA

### ci/cd [16小时]
[Jenkins](https://akomljen.com/set-up-a-jenkins-ci-cd-pipeline-with-kubernetes/), groovy 
- **优点知识：**  Jenkins 实践
- **腾讯课堂：**  基于Jenkins的DevOps工程实践
- http://docs.idevops.site/jenkins/

Gitlab
- **优点知识：**  GitLabCI 实践课
- http://docs.idevops.site/gitlabci/
- https://www.qikqiak.com/post/gitlab-ci-k8s-cluster-feature/
- ~ Nexus,Artifactory,Harbor,maven-pom 配置私服权限管理 tekton
- ~ argo https://www.udemy.com/course/hands-on-guide-to-argo-workflows-on-kubernetes/
- ~ argo rollout https://atbug.com/canary-release-via-argo-rollouts-and-service-mesh/



### 多云集群管理

- kubefed, karmada, virtual kubelet，kubevela,admiralty，kubeedge等
- https://github.com/istio/istio/issues/24488
- https://istio.io/latest/docs/ops/deployment/deployment-models/
- https://draveness.me/kuberentes-federation/
- [自定义k8s调度器](https://www.qikqiak.com/post/custom-kube-scheduler/)
- [编写自定义的 Kubernetes scheduler调度器](https://zhuanlan.zhihu.com/p/428124949)
- [配置多个调度器](https://kubernetes.io/zh-cn/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

### serverless [8小时]
[devops Packer knative](https://www.udemy.com/course/devops-catalog/)

serverless
- https://developer.aliyun.com/learning/roadmap/serverless
- https://space.bilibili.com/102734951/search/video?keyword=knative
- https://www.bilibili.com/video/BV12K4y1o72s/

- [美团Serverless平台Nest的探索与实践](https://tech.meituan.com/2021/04/21/nest-serverless.html)
- [高德 Serverless 平台建设及实践](https://xie.infoq.cn/article/686a83fccba14504517ec6fe5)
- [基于 Serverless 的部署平台构建与思考](https://unix.bio/posts/thinking-under-serverless)

### 暂时不学
- consul vault terraform   - terraform 模拟 + **优点知识：**  Terraform 实践课17.8 小时

- **lua** https://wiki.luatos.com/luaGuide/introduction.html
- **vue**
  https://www.bilibili.com/video/BV12J411m7MG
  /home/admin/Downloads/快速入门Vue.js资料.zip
- **Django flask 数据库**
- **优点知识：** 云原生免费公开课6.0 小时
- **慕课网：** 新版Kubernetes生产落地全程实践
- **慕课网：**  掌握Shell脚本编程
- **腾讯课堂：** 基于世界500强的k8s实战课程

### 存储 [16小时]
minio，nfs
ceph
https://longhorn.io/
- 优点知识：  Ceph 入门到实战13.0 小时
- 优点知识：  云原生存储 Rook 实战

### 中间件
MongoDB [3小时] 性能排查。指标监控。主从复制。数据备份。冷数据分析 预计2天
- 3h：https://www.bilibili.com/video/BV1WS4y1p7jK/

zookeeper [5小时]
- https://www.bilibili.com/video/BV1Ph411n7Ep/
- https://www.bilibili.com/video/BV1to4y1C7gw/

[etcd](https://www.bilibili.com/video/BV1eY4y1p774/),
[tomcat](https://www.bilibili.com/video/BV1WP41157ns/)
[openvpn](https://www.udemy.com/course/openvpn-verstehen-und-einrichten-sicher-im-netzwerk/) 
### 开源项目规划
 
  - [ ] 兼容Alfred，utools 更小更快兼容 wayland 支持自定义 workflow，utools借鉴google的搜索栏tabl搜索
  - [ ] 终端软件，笔记软件交互模式，ppt模式,playground，在线实验室，课程发布平台，web ide，字符录制-音频转换-webide-ide操作回放-环境隔离-终端分享
  - [ ] 零信任 动态身份验证器 环境代理 VPN
  - [ ] 大数据分析数据清洗可视化项目，部署调优等等
  - [ ] openldap管理 http://ldapdoc.eryajf.net/ 对接飞书钉钉等，支持oauth2
  - [ ] k8s开发：自动nacos优雅下线   ，自动流量预热，镜像安全流程
    https://www.kubernetes.org.cn/8426.html  
    https://yqh.aliyun.com/live/detail/27936  
    https://developer.aliyun.com/article/872430?utm_content=m_1000330905  
    https://developer.aliyun.com/article/891670?utm_content=m_1000337392  
    https://help.aliyun.com/document_detail/409450.html  
    https://developer.aliyun.com/article/812828?utm_content=m_1000310320  
    https://github.com/opensergo/opensergo-specification  
  - [ ] vagrant 虚拟机审批平台 对接飞书审批 还原机器人
  - [ ] cert manager 管理平台
  - [ ] CICD平台开发： 优雅发布+协作开发和动态环境，集成抓包+api+文档+测试+issue+权限+终端会话共享+零信任+审计平台+微前端+混沌工程等+全部gitops审计+集成基础设施即代码+开通审批流程+结合财务finops
      https://github.com/metersphere/metersphere/
      https://github.com/localstack/localstack


## 技术文档写作：
k8s the hard way
k8s-OPS指南
Linux-book(除了运维服务只是还有arch食用指南)
  linux 内核调优，熟悉内核堆栈报报告,能分析coredump
  存储各种方案和linux集成,以及i稳定性和debug
  网络,云网融合解决方案,sdn,cni,neutron等,个种网络协议原理和排错，ISP网络+overlay，SDN，网络基础,tcp/ip协议栈,vlan,vxlan,熟悉tcpdump,wireshark,分析网络问题,reg
  熟悉进程,文件系统,网络常见系统调用,strace/gdb等工具分析程序行为
  熟悉网络栈，内核网络参数工作原理,虚拟网络设备工作原理
  属虚linux存储和文件系统，能分析定位影响应用IO性能的因素
  熟悉namespace,cgroup,upstart,systemd等概念
  熟悉rpm,deb等发行包的制作
  openstack,kvm,SDN，linuxbridge,OVS,libvirt 镜像制作 cloud-init,
  EBPF


  - [LCTT](https://linux.cn/lctt/) “Linux中国”翻译组
  - https://github.com/icexmoon/PEP-CN
  - https://github.com/chinesehuazhou/peps-cn/blob/master/%E5%AD%A6%E4%B9%A0Python%EF%BC%8C%E6%80%8E%E8%83%BD%E4%B8%8D%E6%87%82%E7%82%B9PEP%E5%91%A2%EF%BC%9F.md
  受上面启发可以翻译k8s法案 
  - https://github.com/kubernetes/enhancements/blob/0e4d5df19d396511fe41ed0860b0ab9b96f46a2d/keps/sig-scheduling/1451-multi-scheduling-profiles/README.md
  - https://github.com/kubernetes/community/blob/master/contributors/devel/sig-scheduling/scheduling_code_hierarchy_overview.md

## Kubernetes进阶
深入k8s源码二次开发，多云混部，跨云跨区链路
负责混部管理系统的开发， 包括差异化调度， 资源隔离， 资源驱逐流程等功能
比如核心链路跨云高可用，实现**Kubernetes集群的灰度版本升级**，极端故障场景的快速回复等等。
基于业务平台与 VirtualKubelet,以及调度控制器，实现**面向多云和混合云和多云资源交付平台和能力；**

- [ ] CSI, CNI, CRD和Operator开发
  -   https://github.com/dnsjia/luban
  -  https://github.com/kubernetes/sample-controller
  -  https://www.bilibili.com/video/BV1FW4y1m7qH
  -  https://www.bilibili.com/video/BV1Gb4y177WE
  -  https://juejin.cn/post/7028453607850655758
  -  https://juejin.cn/post/7029132894291361829
  -  其他课程
  -  https://bilibili.com/video/BV1zu41197br
  -  [云原生CTO](https://space.bilibili.com/436169885/video)
  -  https://www.bilibili.com/video/BV18U4y1S78Q
  -  https://www.bilibili.com/video/BV1oL411F7hN

- [ ] K8S API SERVER原理
  - https://www.bilibili.com/video/BV13A4y1R7RH/
  - https://github.com/duyanghao/kubernetes-reading-notes/tree/master/core/api-server
  - https://www.huweihuang.com/kubernetes-notes/principle/kubernetes-core-principle-api-server.html#1-api-server%E7%AE%80%E4%BB%8B

- [ ] kube-scheduler 调度分析
  - https://jeffdingzone.com/2020/11/k8s%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%902kube-scheduler/
  - https://www.cnblogs.com/lianngkyle/p/15914981.html
  - https://www.cnblogs.com/lianngkyle/p/16000742.html

- [ ] golang 实现docker
- https://juejin.cn/post/6844903493916950536
- https://bingbig.github.io/topics/container/content.html
- https://github.com/Akshit8/my-docker
- https://github.com/pibigstar/go-docker   https://learnku.com/blog/pibigstar
- https://github.com/lizrice/containers-from-scratch
- https://segmentfault.com/a/1190000008125359
- https://github.com/songjiayang/climits

## 书籍清单
- [x] Google SRE SLA
- [ ] [linux-insides(Linux 内核揭秘)](https://github.com/0xAX/linux-insides/blob/master/SUMMARY.md) 

## 英语
BEC高级
https://www.thefreedictionary.com/
https://thiscute.world/posts/learn-english-again/

## 其他

机器学习  区块链 金融知识和量化交易 机器学习流水线编排
shell: http://c.biancheng.net/view/vip_4555.html
设计模式: https://refactoringguru.cn/
java: https://how2j.cn/



udemy-Helm https://www.udemy.com/course/helm-kubernetes-packaging-manager-for-developers-and-devops/
udemy-Grafana https://www.udemy.com/course/grafana-tutorial/
udemy-Prometheus https://www.udemy.com/course/prometheus-course/
udemy-Golang https://www.udemy.com/course/go-the-complete-developers-guide/
udemy-Ansible https://www.udemy.com/course/learn-ansible/
udemy-Kibana https://www.udemy.com/course/data-visualization-with-kibana/
udemy- MySQL High Performance Tuning Guide https://www.udemy.com/course/mysql-high-performance-tuning-guide/
udemy-DevOps https://www.udemy.com/course/devops-catalog/
udemy-OpenVPN  https://www.udemy.com/course/openvpn-verstehen-und-einrichten-sicher-im-netzwerk/
udemy-Elasticsearch https://www.udemy.com/course/elasticsearch-complete-guide/
udemy-Argo Workflows https://www.udemy.com/course/hands-on-guide-to-argo-workflows-on-kubernetes/
udemy-Istio https://www.udemy.com/course/istio-hands-on-for-kubernetes/
udemy-HAProxy https://www.udemy.com/course/haproxy-a/
udemy-CKS   https://www.udemy.com/course/certified-kubernetes-security-specialist/
udemy-CKA   https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/
udemy-CKAD  https://www.udemy.com/course/certified-kubernetes-application-developer/
udemy-Python https://www.udemy.com/course/python3-chinese/
udemy-Consul 2023 (Hands-On Labs) https://www.udemy.com/course/hashicorp-consul/
udemy-Consul Associate Practice Exam https://www.udemy.com/course/consul-associate-practice-exam/
udemy-Vault 2023 (Hands-On Labs) https://www.udemy.com/course/hashicorp-vault/
udemy-Vault Associate - Practice Exam - 2023 https://www.udemy.com/course/hashicorp-certified-vault-associate-practice-exam/
udemy-Terraform Associate Practice Exam 2023 https://www.udemy.com/course/terraform-associate-practice-exam/
udemy-Terraform Associate 2023 https://www.udemy.com/course/terraform-beginner-to-advanced/


优点知识-Go 运维开发训练营第1期 https://youdianzhishi.com/web/course/1035/2530
优点知识-Kubernetes 开发课 https://youdianzhishi.com/web/course/1018/2014
优点知识-Kubernetes 网络训练营第1期 https://youdianzhishi.com/web/course/1021/1793
优点知识-Kubernetes 网络训练营第2期 https://youdianzhishi.com/web/course/1029/2020
优点知识-Kubernetes 网络训练营第3期 https://youdianzhishi.com/web/course/1031/2270
优点知识-云原生存储 Rook 实战 https://youdianzhishi.com/web/course/1025/1850
优点知识-GitLabCI 实践课 https://youdianzhishi.com/web/course/1016/1390
优点知识-Jenkins 实践 https://youdianzhishi.com/web/course/1013/1242

优点知识-打造云原生大型分布式监控系统 https://youdianzhishi.com/web/course/1015/1389
优点知识-Webpack3.x 快速入门https://youdianzhishi.com/web/course/1003/1009
优点知识-云原生免费公开课 https://youdianzhishi.com/web/course/1014/1475

慕课-Kubernetes https://coding.imooc.com/learn/list/335.html
慕课-Shell脚本 https://coding.imooc.com/learn/list/314.html

腾讯课堂-Kubernetes         https://ke.qq.com/user/index/index.html#/plan/cid=2738602&term_id=103659045
腾讯课堂-Jenkins            https://ke.qq.com/user/index/index.html#/plan/cid=2202770&term_id=103587528
腾讯课堂-prometheus+grafana https://ke.qq.com/user/index/index.html#/plan/cid=2803292&term_id=102912757
腾讯课堂-Nginx              https://ke.qq.com/user/index/index.html#/plan/cid=2292484&term_id=103595308
腾讯课堂-zabbix5.0          https://ke.qq.com/user/index/index.html#/plan/cid=2767948&term_id=102875976

腾讯课堂-高等数学（上）      https://ke.qq.com/user/index/index.html#/plan/cid=425893&term_id=100508320
腾讯课堂-高等数学（下）      https://ke.qq.com/user/index/index.html#/plan/cid=425895&term_id=100508328
腾讯课堂-CCIE               https://ke.qq.com/user/index/index.html#/plan/cid=300249&term_id=104217633
腾讯课堂-思科SDN/网络编程/DC https://ke.qq.com/user/index/index.html#/plan/cid=472811&term_id=100566186
腾讯课堂-CCNP               https://ke.qq.com/user/index/index.html#/plan/cid=205745&term_id=103423596
腾讯课堂-CCNA               https://ke.qq.com/user/index/index.html#/plan/cid=210374&term_id=103258927

极客时间-深入剖析 Kubernetes-张磊 https://time.geekbang.org/column/article/71606?cid=100015201
极客时间-网络协议集训班-陶辉 https://time.geekbang.org/course/detail/100102201-472901
极客时间-Go 实战训练营 https://u.geekbang.org/lesson/290
