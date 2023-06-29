---
title: Integration & Delivery
sidebar_position: 3
tags: [Integration,Delivery]
---

https://landscape.cd.foundation/


## CI/CD 功能对比

### 1. Jenkins

Jenkins 无疑是目前市面上最强大的 CI/CD 工具，可以 hold 住绝大部分的 CI/CD 使用场景。

它使用 Jenkins Pipeline 编写任务流程，有众多插件支持各类 CI/CD 功能。

可以使用 Jenkins+Python 代码，打造出一个自动化运维平台。包含：

1. 前后端代码的 CI/CD
2. 自动化测试平台，通过定时任务进行自动化测试，使用 ningx/ftp 仓库进行测试记录的保存与查看，通过邮件通知或钉钉插件实现告警，。
3. 运维平台：提供数据定时清理、服务器维护、k8s集群维护、其他资源维护等等运维功能。
   1. 比如通过 Jenkins 调用 ansible/terraform/kubeadm 等工具，进行服务器/云资源/kubernetes集群的维护。



Gitlab-CI 和 Gitlab 无缝融合，CI/CD 很方便。

1. Multi-project pipelines(仅付费版): 同一个 Git 仓库可以有多个独立的 Pielines
2. Parent-Child Pipelines：可以实现层次化的 CI/CD

和 Jenkins 区别比较大的地方，是它没有「视图-文件夹-任务」这样的层次结构，所有的 Pipeline 其实都是附属于一个 Git 仓库的。
而且每个 git 仓库只能有一个 `.gitlab-ci.yaml` 文件。
**对拥有大量流水线的团队而言，可以通过模板引用来增强流水线的复用性，模板集中存放使其更易维护。虽然一个仓库只有一个流水线，但可以按照 gitops 理念来规范分支结构，可以为每个特殊功能的分支定义独立的流水线，但使用体验并不是很好，尤其是各个仓库之间有依赖关系的情况下。**

一个复杂的微服务系统，各微服务之间的依赖关系是很复杂的，服务发布往往要求我们按照依赖链路预先定义好的升级顺序进行升级，Gitlab-CI 通过 API 运行 Pipeline（可自定义参数）等功能，通过API可以实现此功能


1. Tekton:  CI/CD pipeline，是从 Knative 中分化出来的
2. Argo: 一个基于 DAG 的复杂 Workflow 工具，它对复杂的任务编排的支持比 Tekton 强很多。
   1. Argo Workflows 主要是设计用于数据处理的，因此它需要更灵活的任务编排功能。
   2. 而 Tekton 的目标只是 CI/CD，CI/CD 的流程往往非常固定，不需要很复杂的任务编排。（当然这也不绝对，因此也确实有人使用 Argo 做 CI/CD 的）
   3. 阿里云就有重度使用 Argo Workflows 和 ArgoCD.
3. ArgoCD: GitOps 的 k8s 自动化部署工具
4. Knative: 全生命周期管理(从源码到上线)，Serverless 平台。
5. Jenkins-X: Jenkins 团队推出的云原生 CI/CD 系统，集成了 Knative/Tekton/Helm 等一堆云原生 CI/CD 工具。
   - 目前感觉 Jenkins-X 太依赖命令行了，在水平低的团队中很难推广开来。
   - 看 Stars 数量也能判断出，这东西目前不是很受欢迎。



Drone 是目前 Github 上最火的 CICD 项目，它以容器为核心，每个构建步骤都可以使用不同的容器镜像。
不过它在某些方面实现地比较简单，导致它无法胜任复杂场景：

1. 它不支持 Gitlab 的多层目录结构，只支持 Github 式的单层目录。
2. 流水线完全没有任何分类，我们有数量众多的流水线，不分类不方便管理。
3. 它被设计为一个简单的应用构建平台，不支持 Workflow 等功能。
   1. 也就是说，用它来实现自动化测试平台、运维平台，可能是「歪门邪道」hhh


https://www.datarevenue.com/en-blog/airflow-vs-luigi-vs-argo-vs-mlflow-vs-kubeflow
