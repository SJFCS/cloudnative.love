# Argo Workflows

2. 流水线的步骤之间包含很多逻辑判断/数据传递，那很可能是你的流水线设计有问题！
   1. **流水线的步骤之间传递的数据应该尽可能少！复杂的逻辑判断应该尽量封装在其中一个步骤中！**
   2. 这种情况下，就应该使用 python 脚本来封装复杂的逻辑，而不应该将这些逻辑暴露到 Argo Workflows 中！
3. 我需要批量运行很多的流水线，而且它们之间还有复杂的依赖关系：那显然应该利用上 argo wrokflow 的高级特性。
   1.  argo 的 dag/steps 和 workflow of workflows 这两个功能结合，可以简单地实现上述功能。


[Argo Workflows](https://github.com/argoproj/argo/)

Argo Workflows 是一个云原生工作流引擎，专注于**编排并行任务**。它的特点如下：

1. 使用 Kubernetes 自定义资源(CR)定义工作流，其中工作流中的每个步骤都是一个容器。
1. 将多步骤工作流建模为一系列任务，或者使用有向无环图（DAG）描述任务之间的依赖关系。
2. 可以在短时间内轻松运行用于机器学习或数据处理的计算密集型作业。
3. Argo Workflows 可以看作 Tekton 的加强版，因此显然也可以通过 Argo Workflows 运行 CI/CD 流水线(Pipielines)。

文章已迁移至：[云原生流水线 Argo Workflows 的安装、使用以及个人体验](https://thiscute.world/posts/expirence-of-argo-workflow/)

## 参考文档

- [Argo加入CNCF孵化器，一文解析Kubernetes原生工作流](https://www.infoq.cn/article/fFZPvrKtbykg53x03IaH)


视频:

- [How to Multiply the Power of Argo Projects By Using Them Together - Hong Wang](https://www.youtube.com/watch?v=fKiU7txd4RI&list=PLj6h78yzYM2Pn8RxfLh2qrXBDftr6Qjut&index=149)

