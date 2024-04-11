---
title: GitOps
sidebar_position: 0
tags: [GitOps]
---
https://opengitops.dev/

参考https://www.cnblogs.com/charlieroro/p/15867053.html







 借着云原生的热潮GitOps越来越流行。目前 Github 上新兴的 CI/CD 工具如 Jenkins-X/Argo/Knative/flux 等，几乎全都是以 GitOps 为核心的。

但是感觉上 GitOps 以 Git 仓库为核心，忽略了 Git 仓库之间的依赖，因此它和分层结构的项目不怎么合得来。
GitOps 很适合扁平化的项目，每个 Git 仓库就是一个应用，相互独立，也就不需要去考虑它们之间的依赖关系、构建/部署顺序。

一个分层结构的项目，底层依赖库的构建测试可以用 Jenkins 实现，目前来看也只能用 Jenkins，没找到别的替代品。
而最终的 docker 镜像构建与部署这两步，可以交给 GitOps 的 CI/CD 工具来做。

其实我觉得很奇怪，市面上居然找不到很好的能按照项目的依赖顺序进行分层构建的工具（Jenkins 也不能原生支持，我们目前是自己使用 Python 代码来调度 Jenkins 任务。
难道是所有使用类似结构的企业都非常庞大，因此各层都由不同的团队维护，因此不需要这样一种全局的构建功能？他们的企业内部依赖版本号都是手动更新的，能改得过来？

目前来说我觉得像 Argo Workflows 这类基于有向无环图 DAG 的工作流工具，就很适合用来干这个事，可以直接替代掉我们的 Python 调度程序和 Jenkins。
但问题是目前 Argo Workflows 没有像 Jenkins 这么简单直观的 UI 可供开发人员使用。
开发人员只是想跑个 Workflow 分层更新一下内部依赖的版本号，如果用 Jenkins 他在几个输入框里填一下参数就行。
但是用 Workflow 他得在整个 Workflow 定义中找到参数的位置，然后手动修改一下，再 submit...

目前想到的方案，是底层使用 argo 来运行实际的任务，但是仍然通过 Jenkins 提供一个给用户使用的 UI 界面来构建任务。

- [Docker 反模式](https://codefresh.io/blog/docker-anti-patterns/)
- [企业 CI/CD 最佳实践 – 第 1 部分](https://codefresh.io/blog/enterprise-ci-cd-best-practices-part-1/)
- [Kubernetes 部署反模式 – 第 1 部分](https://codefresh.io/blog/kubernetes-antipatterns-1/)