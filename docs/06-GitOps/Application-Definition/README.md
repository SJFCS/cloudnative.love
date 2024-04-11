# Application Definition

为了应付配置 config 不断增长的复杂性和维护难题，kubernetes 社区出现了 helm/kustomize 等一系列工

目前 kubernetes 配置有如下几种流行的编写方法：

1. helm: 基于 go-templates 的模板化、参数化配置。
2. jsonnet: 基于专有 DSL jsonnet 的配置。
3. pulumi/cdk8s: 基于通用编程语言 python/go/typescript/c# 的配置。
4. kustomize: overlay 模式的配置，把变化的配置抽出来做成补丁 patch，剩下的配置就可以复用了。
5. [kcl](https://kcl-lang.io/) 一门面向云原生领域配置策略语言，详细资料可参考

