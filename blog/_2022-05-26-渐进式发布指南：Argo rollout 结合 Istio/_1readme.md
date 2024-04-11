https://xie.infoq.cn/article/28afa3e3e0f00883e627acf82

https://zhuanlan.zhihu.com/p/640365075

对于istio结合argorollout 灰度发布服务我有个问题，假如路由权重是50%，那么用户调用进来后调用服务A-服务B-服务C这条链路的时候，会不会出现 访问到了 A的新版本-B的旧版本-C的旧版本，这种情况下可能B和C不具备A所调用的方法，链路就会报错。如何让其当访问到旧版本则整条链路都是用旧版本，当访问到了新版本整条链路都是用新版本



确保整条链路在访问新旧版本时的一致性，避免出现意外的错误。要确保整条服务链路不会出现新旧版本不兼容的问题，可以采取一些策略来避免这种情况发生。

一种常见的方法是通过 Istio 的 DestinationRule 来配置服务的子集，确保每个服务只会接收特定版本的流量。你可以根据需要设置标签，然后使用 Istio 的虚拟服务配置来保证流量按照你想要的方式路由。这样，当用户访问到了新版本的服务A，就会继续调用新版本的服务B和服务C，避免了新旧版本不兼容的问题。

另外，你也可以考虑在 Argo Rollouts 中设置一些策略，比如只允许整条链路同时升级或降级版本。这样可以确保链路中的所有服务都保持一致的版本，从而避免出现不兼容的情况。


当处理灰度发布时的多服务依赖环境隔离问题时，一个实践案例可以帮助你更好地理解如何结合 Istio 和 Argo Rollouts 来解决这个挑战。下面是一个详细的案例：

**场景描述**：
假设你有一个微服务架构的电子商务应用，包括以下服务：

订单服务（Order Service）
支付服务（Payment Service）
物流服务（Logistics Service）
现在你想要进行订单服务的新版本的灰度发布，同时确保在灰度期间，不会出现因新旧版本不兼容而导致的问题。

**解决方案步骤**：
1. 部署 Istio 和 Argo Rollouts：
首先，确保在 Kubernetes 上部署 Istio 和 Argo Rollouts，并将服务网格纳入 Istio 的管理范围。

2. 制定灰度发布策略：
在 Argo Rollouts 中定义订单服务的灰度发布策略，例如：

将订单服务的新版本的权重逐步从 0% 增加到 100%
设置最大并行升级数以避免服务负载过大
定义回滚策略，以便在出现问题时快速回退
3. Istio 路由规则配置：
利用 Istio 的 DestinationRule 和 VirtualService 来实现服务间的流量控制，确保订单服务的新版本只会调用相应版本的支付服务和物流服务。

4. 灰度发布过程：
开始灰度发布流程，逐步增加订单服务新版本的流量比例。
确保在灰度期间，所有服务之间的通信按照你预期的版本进行。
监控整个服务链路的稳定性，包括性能指标和错误率。
5. 监控和回滚：
在灰度发布过程中，持续监控服务的运行情况，如果出现问题，及时触发回滚操作，将流量切回到旧版本。

**结果**：
通过结合 Istio 的流量管理和 Argo Rollouts 的灰度发布功能，你成功实现了订单服务新版本的灰度发布，同时保持多服务依赖环境的隔离。整个流程可视化、可控制，使得灰度发布过程更加安全可靠。

这个案例展示了如何利用 Istio 和 Argo Rollouts 结合来解决灰度发布时的多服务依赖环境隔离问题。希望这个案例对你有所帮助！如果有任何问题或需要进一步讨论，请随时告诉我。

DestinationRule
```
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: order-service
spec:
  host: order-service
  subsets:
    - name: v1
      labels:
        version: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: payment-service
spec:
  host: payment-service
  subsets:
    - name: v1
      labels:
        version: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: logistics-service
spec:
  host: logistics-service
  subsets:
    - name: v1
      labels:
        version: v1
```
VirtualService
```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
    - order-service
  http:
    - route:
        - destination:
            host: order-service
            subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: payment-service
spec:
  hosts:
    - payment-service
  http:
    - route:
        - destination:
            host: payment-service
            subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: logistics-service
spec:
  hosts:
    - logistics-service
  http:
    - route:
        - destination:
            host: logistics-service
            subset: v1
```
Rollout
```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: order-service-rollout
spec:
  replicas: 3
  strategy:
    canary:
      maxSurge: 1
      maxUnavailable: 0
      steps:
        - setWeight: 10
        - pause: {}
        - setWeight: 25
        - pause: {}
        - setWeight: 50
        - pause: {}
        - setWeight: 75
        - pause: {}
        - setWeight: 100
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
        version: v2
    spec:
      containers:
        - name: order-service
          image: your-registry/order-service:v2
```
https://www.qovery.com/blog/ephemeral-environments-for-blue-green-deployments-a-step-by-step-guide/

- https://help.aliyun.com/zh/asm/user-guide/use-the-warm-up-feature
- https://developer.aliyun.com/article/1012227
- https://xie.infoq.cn/article/f942a1578165a8e51eadc878d