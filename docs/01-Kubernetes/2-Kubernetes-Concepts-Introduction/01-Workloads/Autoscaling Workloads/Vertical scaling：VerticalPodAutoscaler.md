Vertical Pod Autoscaler (VPA) 使用户无需为其 Pod 中的容器设置最新的资源限制和请求。配置后，它将根据使用情况自动设置请求，从而允许在节点上进行适当的调度，以便每个 pod 都有适当的资源量。它还将维护初始容器配置中指定的限制和请求之间的比率。

它既可以缩小请求资源过多的 Pod，也可以根据一段时间内的使用情况放大请求资源不足的 Pod。

## pod 资源的就地调整大小
启用 InPlacePodVerticalScaling feature gate 后可对于 pod 资源的就地调整大小。

下面的示例显示了一个 Pod，其容器的 CPU 可以在不重新启动的情况下调整大小，但调整内存大小需要重新启动容器。

NotRequired ，表示容器运行时可以调整 CPU/内存的大小。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: qos-demo-5
  namespace: qos-example
spec:
  containers:
  - name: qos-demo-ctr-5
    image: nginx
    resizePolicy:
    - resourceName: cpu
      restartPolicy: NotRequired
    - resourceName: memory
      restartPolicy: RestartContainer
    resources:
      limits:
        memory: "200Mi"
        cpu: "700m"
      requests:
        memory: "200Mi"
        cpu: "700m"
```

在上面的示例中，如果 CPU 和内存的所需请求或限制发生变化，容器将重新启动以调整其内存大小。

现在，将 CPU 请求和限制设置为 800m 来修补 Pod 的容器：
```
kubectl -n qos-example patch pod qos-demo-5 --patch '{"spec":{"containers":[{"name":"qos-demo-ctr-5", "resources":{"requests":{"cpu":"800m"}, "limits":{"cpu":"800m"}}}]}}'
```

## VPA 使用案例
- https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#readme
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       my-app
  updatePolicy:
    updateMode: "Auto"
```