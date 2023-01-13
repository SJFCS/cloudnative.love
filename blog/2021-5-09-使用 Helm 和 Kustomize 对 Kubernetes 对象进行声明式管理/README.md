---
title: 使用 Helm 和 Kustomize 对 Kubernetes 对象进行声明式管理
tags: [Kubernetes,Helm,Kustomize]
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

![1673345511901](image/README/1673345511901.png)

Kubernetes 于 2014 年夏季登陆 GitHub ，2015 年夏季推出 Kubernetes 的第一个 1.0 版本，其发展速度和进步在许多人的脑海中仍然记忆犹新。

像任何应用基础设施一样，workloads 的操作开始在 Kubernetes 上变得越来越重要。所以 Kubernetes 提出了 resources 的概念，通常由基于 YAML 的 manifests 来描述各种各样的 workloads，如 deployment.yaml。

随着需要部署的 manifests 数量和需要维护的 Kubernetes 集群数量的双重增加，我们需要更高效的 manifests 管理方式，以便在 cluster-to-cluster 之间获得更容易的部署，和更灵活的配置。

本文将介绍如何使用 Heml 和 Kustomize 来对 Kubernetes 生态系统内的对象进行声明式配置和包管理。

<!--truncate-->

## 什么是 Helm ？

Helm 是 Kubernetes 的应用程序包管理器，您可使用 Helm Charts 描述应用程序的结构，使用 Helm 命令行界面，您可以回滚部署、监控应用程序的状态并跟踪每项部署的历史记录。

Helm 最初由[Deis](https://blogs.microsoft.com/blog/2017/04/10/microsoft-acquire-deis-help-companies-innovate-containers/)于 2015 年开发，并在首届 Kubecon 上展出。2019 年 4 月，CNCF 宣布 Helm 的孵化期结束，成为一个完整的项目。

Tiller是 Helm v2 平台的一部分。它来自与 Google 的 Deployment Manager 项目集成的部分，旨在成为一个工作运行器，与Cloud Foundry 的 Bosh没有太大区别。简而言之，Tiller 是 Helm 的集群内部分，它运行 Helm 的命令和图表。由于 Tiller 可以不受限制地访问 Kubernetes 集群成为集群安全的痛点，因此在 Helm V3 中将其删除了。 

### 基本概念
- Chart：Helm 使用的包格式称为 chart。 chart 就是一个描述Kubernetes相关资源的文件集合。
- Release：在 Kubernetes 集群上运行的 Chart 的一个实例。在同一个集群上，一个 Chart 可以安装很多次。每次安装都会创建一个新的 release。
- Repository：用于发布和存储 Chart 的存储库。

<!-- ### 常用命令
```bash
# 安装应用：
$ helm install releaseName chartDir
# 更新应用：
$ helm upgrade releaseName chartDir

  # –set 参数可以指定多个参数，他的值会覆盖values.yaml定义的值，对象类型数据可以用 . (点)分割属性名,例子:  --set apiAppResources.requests.cpu=1
  # 默认情况下，如果release名字不存在，upgrade会失败，可以加上-i 参数当release不存在的时候则安装，存在则更新，将install和uprade命令合并。
``` -->

### Helm Charts
[Helm Charts 官方文档](https://helm.sh/zh/docs/topics/charts/)

- Helm 图表在创建时必须具有遵循[语义版本控制](https://semver.org/spec/v2.0.0.html)的版本号。
- Helm Charts 可以引用其他 Charts 作为依赖项，这是任何包管理器的核心。
- Helm Charts 的更多高级功能如[Chart Hooks](https://helm.sh/docs/topics/charts_hooks/)和[Chart Tests](https://helm.sh/docs/topics/chart_tests/)，它们允许与 Release 的生命周期进行交互，以及分别针对 Chart 运行命令/测试的能力。

运行 `helm create eg-Helm` 创建一个 Helm Charts 

可以看到 Chart 的基本目录结构包括：
```bash
eg-Helm/                                   # chart 包目录名
├── charts                              # 包含 chart 依赖的其他 chart
├── Chart.yaml                          # 包含了chart信息的YAML文件，如chart的名字，版本号信息。
├── crds                                # 自定义资源的定义
├── templates                           # 模板目录，和 values 结合时，可生成有效的 Kubernetes manifest
│   ├── deployment.yaml
│   ├── _helpers.tpl                   # helm视为公共库定义文件，主要用于定义通用的子模版、函数等
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt                      # 帮助信息文件，helm install 安装成功后会输出帮助信息
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml                         # chart 默认的配置值，模版可以引用这里参数。
```
### 简单示例

下面给出了 deployment、service、ingress 三个配置文件。

<Tabs>
<TabItem value="Deployment">

```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: myapp           #deployment应用名
  labels:
    app: myapp          #deployment应用标签定义
spec:
  replicas: 1           #pod副本数
  selector:
    matchLabels:
      app: myapp          #pod选择器标签
  template:
    metadata:
      labels:
        app: myapp          #pod标签定义
    spec:
      containers:
        - name: myapp           #容器名
          image: xxxxxx:1.7.9    #镜像地址
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```
</TabItem>

<TabItem value="Service">

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-svc #服务名
spec:
  selector: #pod选择器定义
    app: myapp
  ports:
  - protocol: TCP 
    port: 80
    targetPort: 80
```
</TabItem>

<TabItem value="Ingress">

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: myapp-ingress #ingress应用名
spec:
  rules:
    - host: www.xxxxx.com  #域名
      http:
        paths: 
          - path: /  
            backend: 
              serviceName: myapp-svc #服务名
              servicePort: 80
```
</TabItem>
</Tabs>

提取 k8s 应用部署配置文件中的参数，作为 chart 包参数。

`{{  }}` 两个花括号包裹的内容为模版表达式。

<Tabs>
<TabItem value="Deployment">

```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: {{ .Release.Name }}  #deployment应用名
  labels:
    app: {{ .Release.Name }}          #deployment应用标签定义
spec:
  replicas: {{ .Values.replicas}}           #pod副本数
  selector:
    matchLabels:
      app: {{ .Release.Name }}          #pod选择器标签
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}          #pod标签定义
    spec:
      containers:
        - name: {{ .Release.Name }}           #容器名
          image: {{ .Values.image }}:{{ .Values.imageTag }}    #镜像地址
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```
</TabItem>
<TabItem value="Service">

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-svc #服务名
spec:
  selector: #pod选择器定义
    app: {{ .Release.Name }}
  ports:
  - protocol: TCP 
    port: 80
    targetPort: 80
```
</TabItem>

<TabItem value="Ingress">

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress #ingress应用名
spec:
  rules:
    - host: {{ .Values.host }}  #域名
      http:
        paths: 
          - path: /  
            backend: 
              serviceName: {{ .Release.Name }}-svc #服务名
              servicePort: 80
```
</TabItem>
<TabItem value="values">

```yaml
#域名
host: www.XXX.com
 
#镜像参数
image: XXXXXXXXXXXXXXXXXX
imageTag: 1.7.9
 
#pod 副本数
replicas:1
```

</TabItem>
</Tabs>

## Helm 模版语法
### 表达式

- 模版表达式： `{{ 模版表达式 }}`
- `{{- 模版表达式 -}}` 表示去掉表达式输出结果前面和后面的空格
- `{{- 模版表达式 }}`  表示去掉前面空格
- `{{ 模版表达式 -}}`  表示去掉后面空格 

### 变量
默认情况点( . ), 代表全局作用域，用于引用全局对象。

helm 全局作用域中有三个重要的全局对象：**Values** 、 **Release** 和 **自定义模版变量**

- Values 代表的就是 values.yaml 定义的参数，通过.Values可以引用任意参数。

  例如：
  `{{ .Values.images.repository }}` 引用了全局作用域下的 Values 中的 image 对象的 repository。 

  ```yaml title="values.yaml"
  images:
    repository: gcr.io
  ```
- Release 作为 Helm 内置变量为我们提供了如下的属性字段：

  ```bash
  Release.Name            # release 名字，一般通过Chart.yaml定义，或者通过helm命令在安装应用的时候指定。
  Release.Time            # release 安装时间
  Release.Namespace       # 命名空间
  Release.Revision        # release 版本号，是一个递增值，每次更新都会加一
  Release.IsUpgrade       # true 代表，当前release是一次更新
  Release.IsInstall       # true 代表，当前release是一次安装
  ```

- 自定义模版变量

  自定义模版变量名以 $ 开头， 赋值运算符为 `:=`

  例如：`{{- $relname := .Release.Name -}}`

### 函数 & 管道运算符

Go templates 为我们提供了很多好用的函数，详见[文档](https://masterminds.github.io/sprig/strings.html) 

1. 调用函数的语法：`{{ functionName arg1 arg2... }}`

2. 管道（pipelines）运算符 `|`，用于将模版输出的结果传递给下一个函数处理。例子如下：

  - 将.Values.favorite.food 传递给 quote 函数处理，然后在输出结果：
    `{{ .Values.favorite.food | quote  }}`

  - 先将.Values.favorite.food的值传递给upper函数将字符转换成大写，然后专递给quote加上引号包括起来：
    `{{ .Values.favorite.food | upper | quote }}`

  - 如果.Values.favorite.food为空，则使用default定义的默认值：
    `{{ .Values.favorite.food | default "默认值" }}`

  - 将.Values.favorite.food输出5次：
    `{{ .Values.favorite.food | repeat 5 }}`

  - 对输出结果缩进2个空格：
    `{{ .Values.favorite.food | nindent 2 }}`

3. 常用的关系运算符 `>`、 `>=`、 `<`、`!=`、与或非在 helm 模版中都以函数的形式实现。

  关系运算函数定义：
    - eq  相当于 =
    - ne  相当于 !=
    - lt  相当于 <=
    - gt  相当于 >=
    - and  相当于 &&
    - or   相当于 ||
    - not  相当于 !

  ```go title="例子"
  {{ if and .Values.fooString (eq .Values.fooString "foo") }}
      {{ ... }}
  {{ end }}
  // 相当于 if (.Values.fooString && (.Values.fooString == "foo")) 
  ```
### 流程控制语句
1. if/else

  ```go title="语法"
  {{ if 条件表达式 }}
  # Do something
  {{ else if 条件表达式 }}
  # Do something else
  {{ else }}
  # Default case
  {{ end }}
  ```

  ```yaml title="例子:"
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
  data:
    myvalue: "Hello World"
    drink: {{ .Values.favorite.drink | default "tea" | quote }}
    food: {{ .Values.favorite.food | upper | quote }}
    {{if eq .Values.favorite.drink "coffee"}}
      mug: true
    {{end}}
  ```

1. with

  with主要就是用来修改 . 作用域的，默认 . 代表全局作用域，with语句可以修改.的含义.

  ```go title="语法"
  {{ with 引用的对象 }}
  这里可以使用 . (点)， 直接引用with指定的对象
  {{ end }}
  ```

  ```go title="例子"
  // .Values.favorite 是一个 object 类型
  {{- with .Values.favorite }}
  // .drink 相当于.Values.favorite.drink
  drink: {{ .drink | default "tea" | quote }}   
  food: {{ .food | upper | quote }}
  {{- end }}
  ```
  :::tip 
  如果需要在 with 作用域内引用全局对象，可以使用 `$` 指向根的上下文，当在一个范围内循环时会很有用。
  例如：{{ $.Chart.Name }}
  <!-- 也可以先在with外面将全局对象复制给一个变量，然后在with内部使用这个变量引用全局对象。
  ```go title="例子"
  {{- $release:= .Release.Name -}}   //先将值保存起来

  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}   //相当于.Values.favorite.drink
  food: {{ .food | upper | quote }}

  release: {{ $release }} #间接引用全局对象的值
  {{- end }}
  ``` -->
  :::

1. range

  range主要用于循环遍历数组类型。

遍历map类型，用于遍历键值对象，变量key代表对象的属性名，val代表属性值

```go title="语法1"
{{- range key,val := 键值对象 }}
{{ $key }}: {{ $val | quote }}
{{- end}}
```
```go title="语法2"
{{- range 数组 }}
{{ . | title | quote }} // `.` 引用数组元素值。
{{- end }}
```

```yaml title="values.yaml"
#map类型
favorite:
  drink: coffee
  food: pizza
#数组类型
pizzaToppings:
  - mushrooms
  - cheese
  - peppers
  - onions
```
```go title="例子"
// map类型遍历例子:
{{- range $key, $val := .Values.favorite }}
{{ $key }}: {{ $val | quote }}
{{- end}}

// 数组类型遍历例子:
{{- range .Values.pizzaToppings}}
{{ . | quote }}
{{- end}}
```
### 子模版定义

_helpers.tpl 方法允许开发者在模板中使用字符串作为模板。将模板字符串作为值传给chart或渲染额外的配置文件时会很有用。

helm create默认为我们创建了_helpers.tpl 公共库定义文件，可以直接在里面定义子模版，也可以新建一个，只要以下划线开头命名即可。

```go title="子模版语法"
// 定义模版
{{ define "模版名字" }} 模版内容 {{ end }}

// 引用模版:
{{ include "模版名字" 作用域}}
```

```go title="例子"
// 模版定义
{{- define "mychart.app" -}}
app_name: {{ .Chart.Name }}
app_version: "{{ .Chart.Version }}+{{ .Release.Time.Seconds }}"
{{- end -}}
// 引用模版:
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
    {{ include "mychart.app" . | nindent 4 }} // 引用mychart.app模版内容，并对输出结果缩进4个空格
data:
  myvalue: "Hello World"
```

### 模板调试

以下命令有助于你的调试：
```bash
helm lint                                               # 验证chart是否遵循最佳实践的首选工具
helm install --dry-run --debug                          # 或者 helm template --debug 仅渲染模板。
helm get manifest RELEASE_NAME [flags]                  # 这是查看服务器上安装了哪些模板的好方法。
```

## 什么是 Kustomize？

Kustomize是 Kubernetes 生态系统的配置管理工具。与 Kubernetes 本身一样，Kustomize 是作为 Google 的一个开源项目开发的——因此从 Kubernetes 1.14 开始，Kustomize 作为默认 Kubernetes 命令行工具 kubectl 的一部分直接集成到 k8s 中也就不足为奇了。

正如它的名字，Kustomize 侧重于定制，你可以轻松地对 Kubernetes manifests 文件进行 patch(根据文件中定义的逻辑进行重构/替换)。

```bash title="目录结构"
eg-Kustomize/
├── base
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── networkpolicy.yaml
│   ├── rolebinding.yaml
│   └── role.yaml
└── overlays
    ├── team-a
    │   └── kustomization.yaml
    ├── team-b
    │   └── kustomization.yaml
    └── team-c
        └── kustomization.yaml
```

例如，如果您想为您的开发和生产环境指定不同的补丁，您只需在 YAML 文件中指定这些更改，这些文件位于它们自己的目录中，组织在位于项目树中公共"base"旁边的"overlays"目录中.

### [3 种 patch 方法](https://stackoverflow.com/questions/63604579/what-is-the-difference-between-patches-vs-patchesjson6902-in-kustomize)

- patches/patchesJson6902
  - 用于指定 kubernetes 资源的“目标”属性，“路径”属性指定资源中的哪个属性被修改、添加或删除。
  - patchJson6902是一个较旧的关键字，它只能通过target（无通配符）匹配一个资源，并且只接受 Group-version-kind (GVK)、命名空间和名称。
- patchesStrategicMerge
  - 需要 kubernetes 资源的重复结构来标识正在修补的基础资源，然后是规范的修改部分以表示更改（或删除）的内容。

输入以下命令即可将它们有选择地应用于正在运行的集群：

```bash
kustomize build ~/app-project/overlays/development | kubectl apply -f -
# 或者
kubectl apply -k ~/app-project/overlays/development
# 查看渲染结果
kubectl kustomize .
```


## 利用 Kustomize 插件 ChartInflator 渲染 Helm Charts

实际使用 helm 时，我们经常的要对上游的 Helm Chart 包做一些定制化的 patch ，这些 patch 通常受限于定制化场景下，不能直接贡献给上游仓库，通过 fork 来维护自己的定制化修改后的 helm chart 包十分麻烦。这个时候我们可以利用 Kustomize 来对现有的 Helm Chart 打 patch。

### 安装 [ChartInflator](https://github.com/kubernetes-sigs/kustomize/blob/v3.3.1/plugin/someteam.example.com/v1/chartinflator/ChartInflator) 插件：

```bash title="安装ChartInflator"
chartinflator_dir="./kustomize/plugin/kustomize.config.k8s.io/v1/chartinflator"
mkdir -p ${chartinflator_dir}
curl -L https://raw.githubusercontent.com/kubernetes-sigs/kustomize/kustomize/v3.8.2/plugin/someteam.example.com/v1/chartinflator/ChartInflator > ${chartinflator_dir}/ChartInflator
chmod u+x ${chartinflator_dir}/ChartInflator
```

### 创建 ChartInflator 资源清单和 Helm 的 values.yaml 值文件：

```bash title="chartinflator.yaml 创建 ChartInflator 资源清单"
cat << EOF >> chartinflator.yaml
apiVersion: kustomize.config.k8s.io/v1
kind: ChartInflator
metadata:
  name: vault-official-helm-chart
chartRepo: https://helm.releases.hashicorp.com  
chartName: vault
chartRelease: hashicorp
chartVersion: 0.7.0
releaseName: vault
values: values.yaml
EOF
```
```bash title="创建 values 值文件"
helm repo add hashicorp https://helm.releases.hashicorp.com 
helm show values --version 0.23.0 hashicorp/vault > values.yaml
```
```bash title="创建 Kustomize 文件"
# kustomize init 创建 Kustomize 文件
# kustomize edit add label env:dev 为所有资源添加一个 label 标签
cat << EOF >> kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
generators:
- chartinflator.yaml
commonLabels:
  env: dev
EOF
```
```bash title="资源清单目录结构"
├── chartinflator.yaml
├── kustomization.yaml
├── kustomize
│   └── plugin
│       └── kustomize.config.k8s.io
│           └── v1
│               └── chartinflator
│                   └── ChartInflator
└── values.yaml
```

### 渲染 Chart 模板

```bash
export KUSTOMIZE_PLUGIN_HOME="./kustomize/plugin/"
kustomize build --enable-alpha-plugins .
```
正常渲染完成后我们可以看到所有的资源上都被添加了一个 env: dev 的标签，这是实时完成的，不需要维护任何额外的文件的。

## 还有哪些其他 Kubernetes 模板工具？
- Jsonnet/Ksonnnet
  - [Jsonnet](https://jsonnet.org/)是一种模板语言和引擎。Jsonnett 有一个面向对象的模板方法，允许创建复杂的和基于关系的模板。如果您需要制作某些东西的副本，只需创建一个新对象，支持模板就会接管。
  - [Ksonnnet](https://github.com/ksonnet/ksonnet)由[Heptio](https://tanzu.vmware.com/content/blog/welcoming-heptio-open-source-projects-to-vmware)创建，是专为 Kubernetes 设计的 Jsonnet 的一个分支。最近，Ksonnet 背后的团队不再支持该项目。
- Skaffold
  - [Skaffold](https://skaffold.dev/)是 Google 最新推出的 Kubernetes 管理项目之一。Skaffold 比 Jsonnet、Helm 甚至 Kustomize 更具包容性。由于 Skaffold 具有构建和部署组件，因此它被设计为 Kubernetes 应用程序所需的一个配方。Skaffold 在部署阶段可插入[Helm](https://skaffold.dev/docs/pipeline-stages/deployers/helm/)和

<!-- ## 总结

要公开发布一个较为复杂的应用，编写良好的 Chart 能给用户很大帮助，用户在缺失一点发挥空间的情况下，通过对 values.yaml 的阅读，就能对这种复杂的部署产生一个较为深入的认识。

如果是常见的业务应用，因为不同部署之间的差异不大，但是未必可以提前做好变化限制，用 Kustomize 可能会是一个更好的选择。 -->


## 参考文档
  - [kubernetes-sigs/kustomize/使用 kustomize 对 helm charts 进行修改](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/zh/chart.md)
  - [使用 Kustomize 定制 Helm Charts](https://www.qikqiak.com/post/use-kustomize-custom-helm-charts/)

<!-- 
https://www.kongzid.com/archives/helm27
https://www.jfrogchina.com/blog/10-helm-tutorials-to-start-your-kubernetes-journey/

https://www.mirantis.com/blog/kustomize-vs-helm-grudge-match-or-match-made-in-heaven/
https://www.harness.io/blog/helm-vs-kustomize
https://foghornconsulting.com/2022/01/25/helm-versus-kustomize/
https://qiita.com/nakamasato/items/54be0804b3cf845f2c92

https://www.jfrogchina.com/blog/10-helm-tutorials-to-start-your-kubernetes-journey/
https://www.cnblogs.com/lyc94620/p/10945430.html
https://www.kongzid.com/archives/helm27
[Kustomize 教程：使用多个部分创建 Kubernetes 应用程序](https://www.mirantis.com/blog/introduction-to-kustomize-part-1-creating-a-kubernetes-app-out-of-multiple-pieces/)
https://cloud.google.com/anthos-config-management/docs/how-to/use-repo-kustomize-helm?hl=zh-cn -->