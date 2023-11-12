---
title: "Kubernetes原生CICD工具：Tekton探秘与上手实践"

---


## 引子  
如果有关注过Knative社区动态的同学，可能会知道最近发生了一件比较大的新闻，三大组件之一的build项目被人提了一个很残忍的Proposal（`https://github.com/knative/build/issues/614`），并且专门在项目Readme的开头加了个NOTE：

```
{{< admonition note "NOTE" >}}
There is an open proposal to deprecate this component in favor of Tekton Pipelines. If you are a new user, consider using Tekton Pipelines, or another tool, to build and release. If you use Knative Build today, please give feedback on the deprecation proposal.
{{< /admonition >}}
```


这个Proposal的目的是想要废弃Knative的build模块，Knative只专注做serverless，而将build模块代表的CI/CD功能全盘交出，让用户自己选择合适的CI/CD工具。Knative只负责将镜像运行，同时提供serverless相关的事件驱动等功能，不再关心镜像的构建过程。  
虽然目前为止，该Proposal还在开放征求社区的意见，不过，从留言来看，build模块未来还是大概率会被deprecate。因为Knative build的替代者Tekton已经展露头脚，表现出更强大的基于kubernetes的CI/CD能力，Tekton的设计思路其实也是来源于Knative build的，现有用户也可以很方便的从build迁移至Tekton。  

## Tekton是什么
Tekton是一个谷歌开源的kubernetes原生CI/CD系统，功能强大且灵活，开源社区也正在快速的迭代和发展壮大。google cloud已经推出了基于Tekton的服务（`https://cloud.google.com/Tekton/`）。  

其实Tekton的前身是Knative的build-pipeline项目，从名字可以看出这个项目是为了给build模块增加pipeline的功能，但是大家发现随着不同的功能加入到Knative build模块中，build模块越来越变得像一个通用的CI/CD系统，这已经脱离了Knative build设计的初衷，于是，索性将build-pipeline剥离出Knative，摇身一变成为Tekton，而Tekton也从此致力于提供全功能、标准化的原生kubernetesCI/CD解决方案。

Tekton虽然还是一个挺新的项目，但是已经成为 [Continuous Delivery Foundation (CDF) ](https://cd.foundation/projects/)的四个初始项目之一，另外三个则是大名鼎鼎的Jenkins、Jenkins X、Spinnaker，实际上Tekton还可以作为插件集成到JenkinsX中。所以，如果你觉得Jenkins太重，没必要用Spinnaker这种专注于多云平台的CD，为了避免和Gitlab耦合不想用gitlab-ci，那么Tekton值得一试。  

Tekton的特点是kubernetes原生，什么是kubernetes原生呢？简单的理解，就是all in kubernetes，所以用容器化的方式构建容器镜像是必然，另外，基于kubernetes CRD定义的pipeline流水线也是Tekton最重要的特征。  
那Tekton都提供了哪些CRD呢？  

- Task：顾名思义，task表示一个构建任务，task里可以定义一系列的steps，例如编译代码、构建镜像、推送镜像等，每个step实际由一个Pod执行。
- TaskRun：task只是定义了一个模版，taskRun才真正代表了一次实际的运行，当然你也可以自己手动创建一个taskRun，taskRun创建出来之后，就会自动触发task描述的构建任务。  
- Pipeline：一个或多个task、PipelineResource以及各种定义参数的集合。
- PipelineRun：类似task和taskRun的关系，pipelineRun也表示某一次实际运行的pipeline，下发一个pipelineRun CRD实例到kubernetes后，同样也会触发一次pipeline的构建。
- PipelineResource：表示pipeline input资源，比如github上的源码，或者pipeline output资源，例如一个容器镜像或者构建生成的jar包等。  
他们大概有如下图所示的关系：  
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/tekton-crds.png)


## 上手实践

### 部署
Tekton部署很简单，理论上只需下载官方的yaml文件 ，然后执行kubectl create -f 一条命令就可以搞定。但是由于在国内，我们无法访问gcr.io镜像仓库，所以需要自行替换官方部署yaml文件中的镜像。  
运行起来后可以在Tekton-pipelines namespace下看到两个deployment：

```
# kubectl -n Tekton-pipelines get deploy
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
Tekton-pipelines-controller   1/1     1            1           10d
Tekton-pipelines-webhook      1/1     1            1           10d
```
这就是运行Tekton所需的所有服务，一个控制器controller用来监听上述CRD的事件，执行Tekton的各种CI/CD逻辑，一个webhook用于校验创建的CRD资源。  
webhook使用了kubernetes的admissionwebhook机制，所以，在我们kubectl create一个taskRun或者pipelineRun时，apiserver会回调这里部署的Tekton webhook服务，用于校验这些CRD字段等的正确性。

### 构建一个Java应用
部署完Tekton之后，我们就可以开始动手实践了，下面以构建一个springboot工程为例。

假设我们新开发了一个名为ncs的springboot项目，为了将该项目构建成镜像并上传至镜像仓库，我们可以梳理一个最简单的CI流程如下： 
1. 从git仓库拉取代码
2. maven编译打包
3. 构建镜像
4. 推送镜像

当然在CI流程之前，我们先需要在项目中增加dockerfile，否则构建镜像无从谈起。  
#### 0. 添加dockerfile
```dockerfile
FROM hub.c.163.com/qingzhou/tomcat:7-oracle-jdk-rev4
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/local/tomcat
RUN rm -rf webapps/*
COPY setenv.sh $CATALINA_HOME/bin/
COPY ./target/*.war webapps/
ENTRYPOINT ["catalina.sh", "run"]
```
一个示例如上所示，dockerfile的逻辑比较简单：引用一个tomat的基础镜像，然后把maven构建完生成的war包复制到webapps目录中，最后用脚本catalina.sh运行即可。  
当然这里有个很有用的细节，我们会项目中添加一个名为setenv.sh的脚本，在dockerfile里会COPY`$CATALINA_HOME/bin/`。setenv.sh脚本里可以做一些tomcat启动之前的准备工作，例如可以设置一些JVM参数等：  

```shell
export NCE_JAVA_OPTS="$NCE_JAVA_OPTS -Xms${NCE_XMS} -Xmx${NCE_XMX} -XX:MaxPermSize=${NCE_PERM} -Dcom.netease.appname=${NCE_APPNAME} -Dlog.dir=${CATALINA_HOME}/logs"
```
如果你也研究过catalina.sh脚本，就会发现脚本里默认会执行setenv.sh，实际上这也是官方推荐的初始化方式。  
```
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
fi
```

#### 1. 从git仓库拉取代码
添加完dockerfile之后，我们可以正式开始研究如何使用Tekton构建这个ncs项目了。  
首先第一步，需要将代码从远程git仓库拉下来。  
Tekton中可以使用pipelineresource这个CRD表示git仓库远程地址和git分支，如下所示：  

```yaml
apiVersion: Tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: ncs-git-source
spec:
  type: git
  params:
    - name: url
      value: https://github.com/ethfoo/test.git
    - name: revision
      value: master
```
其中的revision可以使用分支、tag、commit hash。
实际上git拉取代码这种通用的操作，只需要我们定义了input的resource，Tekton已经默认帮我们做好了，不需要在task中写git pull之类的steps。目前我们的task可以写成如下所示：  

```yaml
apiVersion: Tekton.dev/v1alpha1
kind: Task
metadata:
  name: ncs
spec:
  inputs:
    resources:
    - name: gitssh
      type: git
```

git拉取代码还存在安全和私有仓库的权限问题，基于kubernetes原生的Tekton当然是采用secret/serviceaccount来解决。  
对于每个项目组，可以定义一个公共的私有ssh key，然后放到secret中，供serviceaccount引用即可。  

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nce-qingzhou
  namespace: Tekton-test
secrets:
  - name: ncs-git-ssh
---
apiVersion: v1
kind: Secret
metadata:
  name: ncs-git-ssh
  namespace: Tekton-test
  annotations:
    Tekton.dev/git-0: g.hz.netease.com
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: LS0tLS1CRUd...
  known_hosts: W2cuaHoub...
```
最后，这个serviceaccount要怎么使用呢，我们接着往下看。  

#### 2. maven编译打包
拉下来项目代码之后，开始进入使用maven编译打包阶段。而这个阶段就需要我们自己定义task的steps来实现各种CI/CD的步骤了。  
实际的原理也很简单，定义的一个steps实际上就是新建一个pod去执行自定义的操作。  
对于maven编译来说，我们首先需要找一个安装有maven的镜像，然后在容器的command/args里加上mvn编译的命令。示例如下：  

```yaml
spec:
  inputs:
    resources:
      - name: ncs-git-source
        type: git
    params:
      # These may be overridden, but provide sensible defaults.
      - name: directory
        description: The directory containing the build context.
        default: /workspace/ncs-git-source

  steps:
    - name: maven-install
      image: maven:3.5.0-jdk-8-alpine
      workingDir: "${inputs.params.directory}"
      args:
        [
          "mvn",
          "clean",
          "install",
          "-D maven.test.skip=true",
        ]

      volumeMounts:
        - name: m2
          mountPath: /root/.m2
```
由于Tekton会给每个构建的容器都挂载/workspace这个目录，所以每一个steps步骤里都可以在/workspace中找到上一步执行的产物。  
git拉取代码可以认为是一个默认的steps，这个steps的逻辑里Tekton会把代码放到/workspace/`{resources.name}`中。上面我们定义的PipelineResource名为ncs-git-resource，所以ncs这个工程的代码会被放在/workspace/ncs-git-resource目录中。  
所以在maven-install这个steps中，我们需要在/workspace/ncs-git-resource中执行mvn命令，这里我们可以使用workingDir字段表示将该目录设置为当前的工作目录。同时为了避免写死，这里我们定义为一个input的变量params，在workingDir中使用`${}`的方式引用即可。  

实际的使用中，由于每次构建都是新起容器，在容器中执行maven命令，一般都是需要将maven的m2目录挂载出来，避免每次编译打包都需要重新下载jar包。  
```yaml
  steps:
    - name: maven-install
      ...
      volumeMounts:
        - name: m2
          mountPath: /root/.m2
  volumes:
    - name: m2
      hostPath:
        path: /root/.m2
```

#### 3. docker镜像的构建和推送
Tekton标榜自己为kubernetes原生，所以想必你也意识到了其中很重要的一点是，所有的CI/CD流程都是由一个一个的pod去运行。docker镜像的build和push当然也不例外，这里又绕不开另外一个话题，即如何在容器中构建容器镜像。
一般我们有两种方式，docker in docker(dind)和docker outside of docker(dood)。实际上两者都是在容器中构建镜像，区别在于，dind方式下在容器里有一个完整的docker构建系统，可直接在容器中完成镜像的构建，而dood是通过挂载宿主机的docker.sock文件，调用宿主机的docker daemon去构建镜像。  
dind的方式可直接使用官方的dind镜像（`https://hub.docker.com/_/docker`)，当然也可以采用一些其他的开源构建方式，例如kaniko，makisu等。docker in docker的方式对用户屏蔽了宿主机，隔离和安全性更好，但是需要关心构建镜像的分层缓存。  
dood的方式比较简单易用，只需要挂载了docker.sock，容器里有docker客户端，即可直接使用宿主机上的docker daemon，所以构建的镜像都会在宿主机上，宿主机上也会有相应的镜像分层的缓存，这样也便于加快镜像拉取构建的速度，不过同时也需要注意定时清理冗余的镜像，防止镜像rootfs占满磁盘。  
如果是在私有云等内部使用场景下，可采用dood的方式。这里以dood的方式为例。  
首先要在task中加一个input param表示镜像的名称。  

```yaml
spec:
  inputs:
    params:
      - name: image
        description: docker image
```
然后在task的steps中加入镜像的build和push步骤。  
```yaml
  steps:
    - name: dockerfile-build
      image: docker:git
      workingDir: "${inputs.params.directory}"
      args:
        [
          "build",
          "--tag",
          "${inputs.params.image}",
          ".",
        ]
      volumeMounts:
        - name: docker-socket
          mountPath: /var/run/docker.sock

    - name: dockerfile-push
      image: docker:git
      args: ["push", "${inputs.params.image}"]
      volumeMounts:
        - name: docker-socket
          mountPath: /var/run/docker.sock
  volumes:
    - name: docker-socket
      hostPath:
        path: /var/run/docker.sock
        type: Socket

```
了解kubernetes的同学一定对这种yaml声明式的表述不会陌生，实际上上面的定义和一个deployment的yaml十分类似，这也使得Tekton很容易入门和上手。  

#### 4. 构建执行
在Tekton中task只是一个模版，每次需要定义一个taskrun表示一次实际的运行，其中使用taskRef表示引用的task即可。
```yaml
apiVersion: Tekton.dev/v1alpha1
kind: TaskRun
metadata:
  generateName: ncs-
spec:
  inputs:
    resources:
      - name: gitssh
        resourceRef:
          name: ncs-git-source
  taskRef:
    name: ncs
```
这里的taskrun需要注意的是，inputs.resources需要引用上文定义的PipelineResource，所以resourceRef.name=ncs-git-source，同时reources.name也需要和上文task中定义的resources.name一致。  
这里还有另外一种写法，如果你不想单独定义PipelineResource，可以将taskrun里的resources使用resourceSpec字段替换，如下所示。

```yaml
  inputs:
    params:
    - name: image
      value: hub.c.163.com/test/ncs:v1.0.0
    resources:
    - name: ncs-git-source
      resourceSpec:
        params:
        - name: url
          value: ssh://git@netease.com/test/ncs.git
        - name: revision
          value: f-dockerfile
        type: git
  serviceAccount: nce-qingzhou
  taskRef:
    name: ncs
```
当然，别忘记把上面创建的serviceaccount放到taskrun中，否则无法拉取私有git仓库代码。  
最后，我们可以把上面的文件保存，使用kubectl create -f ncs-taskrun.yml来开始一段taskrun的构建。  
还需要提醒的是，taskrun只表示一次构建任务，你无法修改taskrun中的字段让它重新开始，所以我们没有在taskrun的metadata中定义name，只加了generateName，这样kubernetes会帮我们在taskrun name中自动加上一个hash值后缀，避免每次手动改名创建。  

### pipeline流水线
既然Tekton是一个CI/CD工具，我们除了用它来编译和构建镜像，还可以做更多，例如，加入一些自动化测试的流程，对接其他kubernetes集群实现容器镜像的更新部署。  
当然，这一切都放到task里的steps也未尝不可，但是这样无法抽象出各种task进行组织和复用，所以Tekton提供了更高一级的CRD描述，Pipeline和PipelineRun，Pipeline中可以引用很多task，而PipelineRun可用来运行Pipeline。Pipeline的yaml模版和task大同小异，这里暂不详述，相信你看一遍官方文档也能很快上手。  

## 总结
虽然Tekton还很年轻，我们网易云轻舟团队已经开始在内部尝试实践，使用tekton作为内部服务的镜像构建推送平台。
![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/tiktok-0.png)

![](https://ethfooblog.oss-cn-shanghai.aliyuncs.com/img/tiktok-1.png)

随着云原生浪潮的到来，Kubernetes已经成为事实上的标准，Tekton正脱胎于这股浪潮之中，基于CRD、controller设计思想从一出生就注定会更适合kubernetes。相比其他老牌的CI/CD项目，Tekton还没那么的成熟，不过套用一句现在流行的话：`一代人终将老去，但总有人正年轻`。
看着目前的趋势，未来可期。


1. https://kurtmadel.com/posts/cicd-with-kubernetes/Tekton-standardizing-native-kubernetes-cd/
2. https://developer.ibm.com/tutorials/knative-build-app-development-with-Tekton/
