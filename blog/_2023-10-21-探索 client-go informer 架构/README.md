---
title: 探索 client-go informer 架构
---

clientset -> 缓存 --> informer

reflector ->fifo ->deltafifo ->indexer ->sharedinformer

队列实现

<!-- truncate -->
oprater  k8s代码分析 为什么说k8s核心不是容器而是api

- https://arthurchiao.art/blog/k8s-is-about-apis-zh/
- https://arthurchiao.art/blog/k8s-is-about-apis-2-zh/

[Informer](https://github.com/kubernetes/sample-controller/blob/master/docs/images/client-go-controller-interaction.jpeg?ref=aly.arriqaaq.com)


## start
当我们操作资源和 apiserver 进行通信的时候，需要根据资源对象类型的 Group、Version、Kind 以及规范定义、编解码等内容构成 Scheme 类型，将这些规范注册到了全局的 Scheme 中，然后 Clientset 对象就可以来访问和操作这些资源类型了

```go

```
通过 client-go 提供的 Clientset 对象来获取资源数据，主要有以下三个步骤：

1. 使用 kubeconfig 文件或者 ServiceAccount（InCluster 模式）来创建访问 Kubernetes API 的 Restful 配置参数，也就是代码中的 `rest.Config` 对象
2. 使用 rest.Config 参数创建 Clientset 对象，这一步非常简单，直接调用 `kubernetes.NewForConfig(config)` 即可初始化
3. 然后是 Clientset 对象的方法去获取各个 Group 下面的对应资源对象进行 CRUD 操作




## informer
前面我们在使用 Clientset 的时候了解到我们可以使用 Clientset 来获取所有的原生资源对象，那么如果我们想要去一直获取集群的资源对象数据呢？岂不是需要用一个轮询去不断执行 List() 操作？这显然是不合理的，实际上除了常用的 CRUD 操作之外，我们还可以进行 Watch 操作，可以监听资源对象的增、删、改、查操作，这样我们就可以根据自己的业务逻辑去处理这些数据了。

这个接口虽然我们可以直接去使用，但是实际上并不建议这样使用，因为往往由于集群中的资源较多，我们需要自己在客户端去维护一套缓存，而这个维护成本也是非常大的，为此 client-go 也提供了自己的实现机制，那就是 Informers。Informers 是这个事件接口和带索引查找功能的内存缓存的组合，这样也是目前最常用的用法。Informers 第一次被调用的时候会首先在客户端调用 List 来获取全量的对象集合，然后通过 Watch 来获取增量的对象更新缓存。


一个控制器每次需要获取对象的时候都要访问 APIServer，这会给系统带来很高的负载，Informers 的内存缓存就是来解决这个问题的，此外 Informers 还可以几乎实时的监控对象的变化，而不需要轮询请求，这样就可以保证客户端的缓存数据和服务端的数据一致，就可以大大降低 APIServer 的压力了。

https://www.notion.so/image/https%3A%2F%2Fpicdn.youdianzhishi.com%2Fimages%2F20200727110511.png?table=block&id=31da04d6-8556-422b-8e9e-834ced020572&spaceId=dbc99cc1-a8f6-4ded-bd01-465426f678b3&width=2000&userId=34b71b0e-979b-4918-848e-4f7c25efd080&cache=v2


如上图展示了 Informer 的基本处理流程：

- 以 events 事件的方式从 APIServer 获取数据
- 提供一个类似客户端的 Lister 接口，从内存缓存中 get 和 list 对象
- 为添加、删除、更新注册事件处理程序

此外 Informers 也有错误处理方式，当长期运行的 watch 连接中断时，它们会尝试使用另一个 watch 请求来恢复连接，在不丢失任何事件的情况下恢复事件流。如果中断的时间较长，而且 APIServer 丢失了事件（etcd 在新的 watch 请求成功之前从数据库中清除了这些事件），那么 Informers 就会重新 List 全量数据。

而且在重新 List 全量操作的时候还可以配置一个重新同步的周期参数，用于协调内存缓存数据和业务逻辑的数据一致性，每次过了该周期后，注册的事件处理程序就将被所有的对象调用，通常这个周期参数以分为单位，比如10分钟或者30分钟。

> 注意：重新同步是纯内存操作，不会触发对服务器的调用。
>


Informers 的这些高级特性以及超强的鲁棒性，都足以让我们不去直接使用客户端的 Watch() 方法来处理自己的业务逻辑，而且在 Kubernetes 中也有很多地方都有使用到 Informers。但是在使用 Informers 的时候，通常每个 GroupVersionResource（GVR）只实例化一个 Informers，但是有时候我们在一个应用中往往有使用多种资源对象的需求，这个时候为了方便共享 Informers，我们可以通过使用共享 Informer 工厂来实例化一个 Informer。


共享 Informer 工厂允许我们在应用中为同一个资源共享 Informer，也就是说不同的控制器循环可以使用相同的 watch 连接到后台的 APIServer，例如，kube-controller-manager 中的控制器数据量就非常多，但是对于每个资源（比如 Pod），在这个进程中只有一个 Informer。


## 示例

首先我们创建一个 Clientset 对象，然后使用 Clientset 来创建一个共享的 Informer 工厂，Informer 是通过 informer-gen 这个代码生成器工具自动生成的，位于 k8s.io/client-go/informers 中。

这里我们来创建一个用于获取 Deployment 的共享 Informer，代码如下所示：

```go
package main

import (
	"flag"
	"fmt"
	"path/filepath"
	"time"

	v1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	var err error
	var config *rest.Config

	var kubeconfig *string

	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "[可选] kubeconfig 绝对路径")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "kubeconfig 绝对路径")
	}
	// 初始化 rest.Config 对象
	if config, err = rest.InClusterConfig(); err != nil {
		if config, err = clientcmd.BuildConfigFromFlags("", *kubeconfig); err != nil {
			panic(err.Error())
		}
	}
	// 创建 Clientset 对象
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	// 初始化 informer factory（为了测试方便这里设置每30s重新 List 一次）
	informerFactory := informers.NewSharedInformerFactory(clientset, time.Second*30)
	// 对 Deployment 监听
	deployInformer := informerFactory.Apps().V1().Deployments()
	// 创建 Informer（相当于注册到工厂中去，这样下面启动的时候就会去 List & Watch 对应的资源）
	informer := deployInformer.Informer()
	// 创建 Lister
	deployLister := deployInformer.Lister()
	// 注册事件处理程序
	informer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc:    onAdd,
		UpdateFunc: onUpdate,
		DeleteFunc: onDelete,
	})

	stopper := make(chan struct{})
	defer close(stopper)

	// 启动 informer，List & Watch
	informerFactory.Start(stopper)
	// 等待所有启动的 Informer 的缓存被同步
	informerFactory.WaitForCacheSync(stopper)

	// 从本地缓存中获取 default 中的所有 deployment 列表
	deployments, err := deployLister.Deployments("default").List(labels.Everything())
	if err != nil {
		panic(err)
	}
	for idx, deploy := range deployments {
		fmt.Printf("%d -> %s\n", idx+1, deploy.Name)
	}
	<-stopper
}

func onAdd(obj interface{}) {
	deploy := obj.(*v1.Deployment)
	fmt.Println("add a deployment:", deploy.Name)
}

func onUpdate(old, new interface{}) {
	oldDeploy := old.(*v1.Deployment)
	newDeploy := new.(*v1.Deployment)
	fmt.Println("update deployment:", oldDeploy.Name, newDeploy.Name)
}

func onDelete(obj interface{}) {
	deploy := obj.(*v1.Deployment)
	fmt.Println("delete a deployment:", deploy.Name)
}
```
上面的代码运行可以获得 default 命名空间之下的所有 Deployment 信息以及整个集群的 Deployment 数据：
```bash
$ go run main.go
add a deployment: dingtalk-hook
add a deployment: spin-orca
add a deployment: argocd-server
add a deployment: istio-egressgateway
add a deployment: vault-agent-injector
add a deployment: rook-ceph-osd-0
add a deployment: rook-ceph-osd-2
add a deployment: code-server
......
1 -> nginx
2 -> helloworld-v1
3 -> productpage-v1
4 -> details-v1
......
```

这是因为我们首先通过 Informer 注册了事件处理程序，这样当我们启动 Informer 的时候首先会将集群的全量 Deployment 数据同步到本地的缓存中，会触发 AddFunc 这个回调函数，然后我们又在下面使用 Lister() 来获取 default 命名空间下面的所有 Deployment 数据，这个时候的数据是从本地的缓存中获取的，所以就看到了上面的结果，由于我们还配置了每30s重新全量 List 一次，所以正常每30s我们也可以看到所有的 Deployment 数据出现在 UpdateFunc 回调函数下面，我们也可以尝试去删除一个 Deployment，同样也会出现对应的 DeleteFunc 下面的事件


## Informer 架构说明
上图是整个 client-go 的完整架构图，或者说是我们要去实现一个自定义的控制器的一个整体流程，其中黄色图标是开发者需要自行开发的部分，而其它的部分是 client-go 已经提供的，直接使用即可。 由于 client-go 实现非常复杂，我们这里先对上图中最核心的部分 Informer 进行说明。在 Informer 的架构中包含如下几个核心的组件：

Informers 是 client-go 中非常重要得概念，接下来我们来仔细分析下 Informers 的实现原理，下图是 client-go 的官方实现架构图

https://www.notion.so/image/https%3A%2F%2Fpicdn.youdianzhishi.com%2Fimages%2Fclient-go-controller-interaction.jpeg?table=block&id=ca324b0f-33c8-406c-8fc8-81dfc537172d&spaceId=dbc99cc1-a8f6-4ded-bd01-465426f678b3&width=2000&userId=34b71b0e-979b-4918-848e-4f7c25efd080&cache=v2


**Reflector（反射器）**

Reflector 用于监控（Watch）指定的 Kubernetes 资源，当监控的资源发生变化时，触发相应的变更事件，例如 Add 事件、Update 事件、Delete 事件，并将其资源对象存放到本地缓存 DeltaFIFO 中。

**DeltaFIFO**

DeltaFIFO 是一个生产者-消费者的队列，生产者是 Reflector，消费者是 Pop 函数，FIFO 是一个先进先出的队列，而 Delta 是一个资源对象存储，它可以保存资源对象的操作类型，例如 Add 操作类型、Update 操作类型、Delete 操作类型、Sync 操作类型等。

**Indexer**

Indexer 是 client-go 用来存储资源对象并自带索引功能的本地存储，Informer(sharedIndexInformer) 从 DeltaFIFO 中将消费出来的资源对象存储至 Indexer。Indexer 与 Etcd 集群中的数据保持完全一致。这样我们就可以很方便地从本地存储中读取相应的资源对象数据，而无须每次从远程 APIServer 中读取，以减轻服务器的压力。

这里理论知识太多，直接去查看源码显得有一定困难，我们可以用一个实际的示例来进行说明，比如现在我们删除一个 Pod，一个 Informers 的执行流程是怎样的：

1. 首先初始化 Informer，Reflector 通过 List 接口获取所有的 Pod 对象
2. Reflector 拿到所有 Pod 后，将全部 Pod 放到 Store（本地缓存）中
3. 如果有人调用 Lister 的 List/Get 方法获取 Pod，那么 Lister 直接从 Store 中去拿数据
4. Informer 初始化完成后，Reflector 开始 Watch Pod 相关的事件
5. 此时如果我们删除 Pod1，那么 Reflector 会监听到这个事件，然后将这个事件发送到 DeltaFIFO 中
6. DeltaFIFO 首先先将这个事件存储在一个队列中，然后去操作 Store 中的数据，删除其中的 Pod1
7. DeltaFIFO 然后 Pop 这个事件到事件处理器（资源事件处理器）中进行处理
上节课我们讲到 Reflector 中通过 ListAndWatch 获取到数据后传入到了本地的存储中，也就是 DeltaFIFO 中。从 DeltaFIFO 的名字可以看出它是一个 FIFO，也就是一个先进先出的队列，而 Delta 表示的是变化的资源对象存储，包含操作资源对象的类型和数据，Reflector 就是这个队列的生产者。

8. LocalStore 会周期性地把所有的 Pod 信息重新放回 DeltaFIFO 中去

## Reflector 源码分析
前面我们说了 Informer 通过对 APIServer 的资源对象执行 List 和 Watch 操作，把获取到的数据存储在本地的缓存中，其中实现这个的核心功能就是 Reflector，我们可以称其为反射器，从名字我们可以看出来它的主要功能就是反射，就是将 Etcd 里面的数据反射到本地存储（DeltaFIFO）中。Reflector 首先通过 List 操作获取所有的资源对象数据，保存到本地存储，然后通过 Watch 操作监控资源的变化，触发相应的事件处理，比如前面示例中的 Add 事件、Update 事件、Delete 事件。

Reflector 结构体的定义位于 `staging/src/k8s.io/client-go/tools/cache/reflector.go` 下面：



## Indexer

上节课我们讲到 DeltaFIFO 中的元素通过 Pop 函数弹出后，在指定的回调函数中将元素添加到了 Indexer 中。Indexer 是什么？字面意思是索引器，它就是 Informer 中的 LocalStore 部分，我们可以和数据库进行类比，数据库是建立在存储之上的，索引也是构建在存储之上，只是和数据做了一个映射，使得按照某些条件查询速度会非常快，所以说 Indexer 本身也是一个存储，只是它在存储的基础上扩展了索引功能。从 Indexer 接口的定义可以证明这一点：







工厂模式(Factory Pattern)

Kubernetes 使用工厂模式来创建各种资源对象,如 Pod、Service、Deployment 等。
观察者模式(Observer Pattern)

Kubernetes 的控制器(Controller)使用观察者模式监视资源对象的变化,并根据期望状态进行相应的操作。
装饰器模式(Decorator Pattern)

Kubernetes 使用装饰器模式来扩展资源对象的功能,如为 Pod 添加 sidecar 容器。
策略模式(Strategy Pattern)

Kubernetes 使用策略模式实现不同的调度算法,如 LeastRequestedPodAffinity、NodeAffinityPriority 等。
责任链模式(Chain of Responsibility Pattern)

Kubernetes 的准入控制(Admission Control)使用责任链模式来执行一系列的准入控制逻辑。
适配器模式(Adapter Pattern)

Kubernetes 使用适配器模式来适配不同的存储后端,如 etcd、MySQL 等。
单例模式(Singleton Pattern)

Kubernetes 的一些组件,如 kube-apiserver、kube-scheduler 等,使用单例模式确保只有一个实例运行。
代理模式(Proxy Pattern)

Kubernetes 的 kube-proxy 组件使用代理模式来实现 Service 的负载均衡和网络转发。
模板方法模式(Template Method Pattern)

Kubernetes 的控制器使用模板方法模式定义资源对象的同步逻辑。