---
title: CI/CD
---

## 常见 CI/CD 工具
- CircleCI
- Drone
- fluxcd
- flagger
- Waypoint
- Tekton
- Spinnaker

# CI/CD for Machine Learning

- [kubeflow](https://github.com/kubeflow/kubeflow): kubernetes 平台上的机器学习工具箱
- [mlflow](https://github.com/mlflow/mlflow/): 机器学习模型的生命周期管理平台（客户端工具）
- Airflow



https://landscape.cd.foundation/
https://github.com/volcano-sh/volcano
https://github.com/TencentBlueKing

## CI/CD 功能对比

### 1. Jenkins

  1，编译环境和物理服务器耦合度较高，不同编译环境需要准备大量的物理节点
  2，空闲期资源浪费
  3，不能并行构建任务需要排队

- https://zjj2wry.github.io/post/kubes/jenkens-pipeline/
- https://meigit.readthedocs.io/en/latest/gitlab_ci_.gitlab-ci.yml_detail.html
- https://github.com/AndreyVMarkelov/jenkins-pipeline-shared-lib-sample


Jenkins 无疑是目前市面上最强大的 CI/CD 工具，可以 hold 住绝大部分的 CI/CD 使用场景，优势在于：

1. 众多插件供选用，因此功能繁多。（虽然是良莠不齐，甚至好多都已经停更好多年了。）
2. 提供功能完善的 Web UI，有视图-文件夹的概念，可以很方便地将 Jobs 进行分类。用户使用方便。
3. 任务之间可以互相调用，可以使用一些 Batch Job 去并行/串行地调用其他 Jobs。很适合分层结构项目的 CI/CD。
4. 可以定时构建。
5. 一个仓库可以存在很多个 Pipelines，在构建任务中指定 Jenkinsfile 的位置。
   - 而 gitlab/drone 的 pipeline 文件名称是固定的，而且貌似一个仓库只能有一个。

但是也存在很多问题：

1. 单点故障问题，Master 只能一个。
2. 在数据量多时，有明显的性能瓶颈，调用 Jenkins HTTP API 经常会超时。
3. Slaves 无法动态扩缩容，不能随意地创建销毁。这导致效率不好提升，垃圾数据也容易积累。
   1. 如果使用 k8s 版本的 jenkins，貌似很多别的插件都无法使用。。
4. Bug 比较多，功能也有缺失: 
   1. 节点异常断线，可能会导致任务僵死无法终止。
   2. 没有办法直接从 Jenkinsfile 中读取配置，必须构建一次 Job 才能更新。
   3. Pipeline 第一次构建时，因为不会提前读取 Jenkinsfile，就导致所有的参数全部是 NULL...
5. UI 相当丑。
6. 使用 Groovy DSL 写配置，语法提示太弱，容易写出错误的代码。
    - pipeline 的运行时报错一大堆，经常缺少关键信息，需要自己肉眼 Debug、靠想象力找 Bug...
    - 没办法写测试，不适合编写复杂的构建逻辑。复杂的任务需要用 Python 编写。
7. 对 Configuration as Code 的支持目前还不够完善。
8. 插件老旧，而且很多插件根本没人维护。


总的来说，它很适合层次结构比较复杂的项目。比如说处理很多 Git 仓库的相互依赖、分层构建。
还有一些批量工作、定时任务，比如需要批量构建、批量修改、批量更新、批量部署、定时清理等等。

另外在分层结构中，同一层次的任务流程往往一模一样，因此我一般建议将所有 Jenkinsfile 和构建脚本（如 Python）都放在同一个 Git 仓库中，每一类任务一个 Jenkinsfile。
Jenkinsfile 和 Git 仓库之间，通过 `JOB_NAME` 关联起来，这个关联关系也可以存放在这个 Git 仓库中
这样维护起来方便，不需要每次都批量修改所有 Git 仓库中的 Jenkinsfile。缺点是耦合度增加了。

另外一种方法是将 Jenkinsfile 中通用的定义存放在一个专用仓库中，源码仓库的 Jenkinsfile 只是单纯地去调用这些通用的步骤。
但是这种方法需要编写 groovy 脚本，还得符合 jenkins 规定的项目结构。跑任务时还是需要再拉取一遍用到的 Python 运维代码，感觉没啥优势。

## 使用建议

轻量级任务可以考虑直接通过 Jenkins Pipeline 和 Jenkins 插件完成。
如果复杂度上升，肯定就要在 pipeline 中嵌入 groovy/python 脚本才能实现功能，
但是 Jenkinsfile 不方便测试，语法提示也很垃圾，报错信息混乱一片，也没有很方便的代码复用能力。因此只建议用于轻量级任务。
更复杂的任务，建议使用 Python 脚本来完成。



## Gitlab-CI 和 Gitlab 无缝融合，CI/CD 很方便。

1. Multi-project pipelines(仅付费版): 同一个 Git 仓库可以有多个独立的 Pielines
2. Parent-Child Pipelines：可以实现层次化的 CI/CD

和 Jenkins 区别比较大的地方，是它没有「视图-文件夹-任务」这样的层次结构，所有的 Pipeline 其实都是附属于一个 Git 仓库的。
而且每个 git 仓库只能有一个 `.gitlab-ci.yaml` 文件。
**对拥有大量流水线的团队而言，可以通过模板引用来增强流水线的复用性，模板集中存放使其更易维护。虽然一个仓库只有一个流水线，但可以按照 gitops 理念来规范分支结构，可以为每个特殊功能的分支定义独立的流水线，但使用体验并不是很好，尤其是各个仓库之间有依赖关系的情况下。**

一个复杂的微服务系统，各微服务之间的依赖关系是很复杂的，服务发布往往要求我们按照依赖链路预先定义好的升级顺序进行升级，Gitlab-CI 通过 API 运行 Pipeline（可自定义参数）等功能，通过API可以实现此功能


1. Tekton:  CI/CD pipeline，是从 Knative 中分化出来的

它和 Argo Workflows 其实很类似，只是目的不同，导致它的功能不如 Argo Workflows 强大。

而 Argo Workflows 是一个通用的**并行任务编排**工具，只是它的功能恰好也很契合 CI/CD 场景。

Argo Workflow 工具， Tekton 在工作流控制上的支持是比较弱的。一些复杂的场景比如循环，递归等都是不支持的。更不用说 Argo 在高并发和大集群调度下的性能优化。这和 Tekton 的定位有关， Tekton 定位于实现 CICD 的框架，对于 CICD 不需要过于复杂的流程控制。大部分的研发流程可以被若干个最佳实践来覆盖。而这些最佳实践应该也必须可以在不同的组织间共享，为此 Tekton 设计了 PipelineResource 的概念。 PipelineResource 是 Task 间交互的接口，也是跨平台跨组织共享重用的组件，在 PipelineResource 上还可以有很多想象空间。




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



本文来自[Rancher Labs](https://mp.weixin.qq.com/s/0br8GnnaLKM2ZSG4jxumkw) [英文原文](https://thenewstack.io/primer-blue-green-deployments-and-canary-releases/)

<!--more-->

在[之前关于CI/CD的文章](https://mp.weixin.qq.com/s/ljfZvitCyGtpNwBZg67vhQ)中，我们简单讨论了蓝绿部署和金丝雀发布以及它们在持续交付中所扮演的角色。这些都是十分有效的方法，能够大大降低与应用程序部署相关的风险。所以，这篇文章我们来深入介绍蓝绿部署和金丝雀发布。

蓝绿部署和金丝雀发布通过让IT人员可以在发布过程中发生问题时能够还原到先前版本来减轻应用程序部署的风险。这两个方法让版本之间来回切换就像轻按开关一样容易，并且可以自动执行，从而最大程度减少了用户暴露在错误代码的时间。在我们更进一步讨论这两种方法之前，让我们先区分部署和发布。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/oscimg.oschina.net/oscnet/2021.08.12-15:14:10-up-5eb61f06066741da6a623995945409c4622.png)

## 如何将部署与发布解耦

虽然这两个词经常混淆使用，但实际上部署和发布是两个独立的过程。部署是指在特定环境（包括生产环境）安装指定软件版本的过程，更多是一种技术行为。它不一定必须与发布相关联。而发布则是指向客户群提供新功能，是一种业务决策。

传统过程中，会在发布日期前一天部署好更新或是新功能，该更新或功能发布后可能会在媒体中广泛传播。众所周知，在部署过程中可能会出错，而因为发布时间与部署时间十分相近，因此几乎没有解决问题的空间。而如果将部署和发布解耦，那么在整个功能开发过程中频繁进行生产部署可以降低IT部门的风险。那么，要实现部署和发布的解耦，需要代码和架构能够满足新功能发布不需要变更应用程序的代码。

## 什么是蓝绿部署

在蓝绿发布过程中，有两套生产环境：蓝环境和绿环境。蓝色是当前版本并拥有实时流量，绿色是包含更新代码的环境。无论任何时候，只有一套环境有实时流量。

要发布一个新版本，需要先将代码部署到没有流量的环境中，这是执行最终测试的地方。当IT人员确认应用程序已经准备就绪，就会将所有流量都将路由到绿色环境。那么绿色环境就已经生效，并且执行发布。

这是新代码首次在生产负载（实际流量）进行测试。在实际发布代码之前，风险仍然存在，并且永远不会消失。但是，如果出现问题，IT部门可以快速将流量重新路由回蓝色版本。因此，他们所要做的就是密切监控代码行为，甚至可以使用适当的工具将其自动化，以查看绿色环境中的版本是否运行良好或是否需要回滚。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/oscimg.oschina.net/oscnet/2021.08.12-15:14:08-up-bd28d39c2c3ace8657b61956e3308170c41.png)

*蓝绿部署：无论何时，只有一套生产环境有实时流量*

这种方法已经不是新方法了。IT部门总会创建一个新版本，然后将实时流量重新路由到该版本。而版本控制中通过组件编码提供可靠性和可重复性是这一方法的亮点。

我们应该如何获得可靠性和可重复性？开发人员将所有参数编入版本控制中，该版本控制是一个跟踪所有代码更改的系统，类似于数据库。其中包括应用程序逻辑、构建过程、测试、部署过程、升级过程以及恢复过程等。总之，包含所有影响应用程序的因素。然后，计算机执行代码，在相应的环境中部署应用程序，该环境与版本控制中编码的exact state相匹配。

在DevOps出现之前，该流程通常是手动的，并且容易出错。因为所有更改都只能记录在文档中，基于此，开发人员可以重新创建应用程序和环境。由于需要手动执行两个关键步骤，因此此过程过于不可靠，从而导致频繁出现问题。

虽然将应用程序和环境进行编码也是一项需要手动进行的任务，但是它毕竟只是开发过程的一部分，而不是单独的工作，例如创建文档。在版本控制中编入了与生产环境相同的代码。任何更改或更新都将自动触发测试，以确保代码处于可部署状态。这样，如果出现人为错误，系统也能够很快发现它。

## 如何理解金丝雀发布（灰度发布）

与蓝绿部署类似，金丝雀发布也是始于两套环境：有实时流量的环境以及没有实时流量但包含了更新的代码的环境。与蓝绿部署不同的是，流量是逐渐迁移到更新的代码。一开始是1%，然后10%、25%，以此类推，直至100%。通过自动化发布，当确认代码能够正确运行时，它就可以逐步推广到更大、更关键的环境中。如果在任何时候发生了问题，所有流量都会被回滚到之前的版本。这在很大程度上降低了风险，因为仅有一小部分用户会使用到新的代码。

IT不仅可以控制用户部署的比例，而且金丝雀发布还可以从不太重要的用户开始，例如使用免费账户的用户或相对来说不太重要的业务市场。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/oscimg.oschina.net/oscnet/2021.08.12-15:14:11-up-7260d79c0262ac50ccda37cc4fd7d5a3e05.png)

*金丝雀发布：实时流量逐渐从旧版本迁移到新版本直到更新生效*

## Cluster Immune System

Cluster Immune System可以让金丝雀发布更进一步。它会连接到生产监控系统，当面向用户的性能偏离预定义范围（例如，错误率高出2%）时，将会自动回滚版本。这种方法可以识别通过自动测试难以发现的错误，并减少了检测和响应性能下降所需的时间。

通过将发布与部署解耦并利用蓝绿部署或金丝雀发布，风险将会显著降低。在任何时候，IT都能够将应用程序回滚到之前的版本——这已经与传统的应用程序发布流程相去甚远了。

新的技术和方法首次让这一切成为可能：版本控制、作为代码的基础架构（Infrastructure as code）、容器和Kubernetes都能在这个崭新的、灵活的、面向DevOps的IT世界中发挥着作用。




讨论 https://github.com/argoproj/argo-cd/issues/7119

例子 https://github.com/vfarcic/argocd-production

例子 https://github.com/kostis-codefresh/gitops-environment-promotion/tree/main

- [停止使用分支部署到不同的 GitOps 环境](https://codefresh.io/blog/stop-using-branches-deploying-different-gitops-environments/)
- [如何建模你的GitOps环境并在它们之间促进发布](https://codefresh.io/blog/how-to-model-your-gitops-environments-and-promote-releases-between-them/)
- [Argo CD构建环境示例](https://akuity.io/blog/argo-cd-build-environment-examples/)
