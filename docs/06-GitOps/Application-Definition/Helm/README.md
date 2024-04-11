# Helm

[Helm](https://github.com/helm/helm) - Kubernetes 包管理器，

Go语言内置了[Go Template](https://godoc.org/text/template)来模板化资源文件，但模板功能不是很多。所以在 Go 提供的内置函数基础上，还添加了[Sprig 库](https://godoc.org/github.com/Masterminds/sprig)中的几乎所有函数，出于安全原因，删除了两个函数：`env`和`expandenv`（这会让 Chart 模板开发者访问到 Tiller 的环境）。

另外还添加了两个特殊的模板函数：`include`和`required`，`include`函数允许你引入另一个模板，然后将结果传递给其他模板函数。


## 扩展阅读

- Sprig是一个提供了100多个常用模板函数的库。这里有一份 Sprig 函数文档 [Sping Useful template functions for Go templates.](https://masterminds.github.io/sprig/strings.html)
，包含了模板函数的详细说明和代码片段。
- Helm常用函数 http://masterminds.github.io/sprig/strings.html
- Helm流程控制 https://helm.sh/docs/chart_template_guide/control_structures/