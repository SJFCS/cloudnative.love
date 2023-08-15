参考自https://zhuanlan.zhihu.com/p/158141567


当Node节点挂掉，也就是kubelet无法提供工作的时，pod自动调度到其他的节点上去，这个时间可以根据需要进行调整

- api-server参数 https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
- kube-controller-manager 参数 https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
- kubelet参数具体作用 https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward


以下调整是需要加入到集群中的，最后效果验证pod的迁移时间为1m

**kube-controller-manager调整**

```
- --node-monitor-period="5s" . #在NodeController中同步节点状态的周期。默认5s
- --node-monitor-grace-period: "20s" #我们允许运行的节点在标记为不健康之前没有响应的时间。必须是kubelet的nodeStatusUpdateFrequency的N倍，其中N表示允许kubelet发布节点状态的重试次数默认40s。
- --node-startup-grace-period: "30s" #我们允许启动节点在标记为不健康之前没有响应的时间。，默认1m0s。
- --pod-eviction-timeout: "1m" #删除失败节点上的pods的宽限期。默认5m
```

**kube-apiserver调整**

最终判断驱逐时间的调整还是根据kube-apiserver的参数

```
- --default-not-ready-toleration-seconds=60 指示notReady:NoExecute的容忍秒数，默认情况下添加到没有这种容忍的每个pod中。
- --default-unreachable-toleration-seconds=60 指示对不可到达的:NoExecute的容忍秒数，默认情况下添加到没有这种容忍的每个pod中。
- --enable-admission-plugins=NodeRestriction,PodSecurityPolicy,DefaultTolerationSeconds 默认容忍的秒数开启
```
如果在全局中不增加此参数，那就需要在pod中单独指定，一般不建议此项操作

```
tolerations:
      - key: node.kubernetes.io/not-ready
        effect: NoExecute
        tolerationSeconds: 60
      - key: node.kubernetes.io/unreachable
        operator: Exists
        effect: NoExecute
        tolerationSeconds: 60
```

举个例子但是生产中不建议这么做，还是使用全局方式定义驱逐方式来决定node节点not ready状态pod的迁移

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: kube-system
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      tolerations:
      - key: node.kubernetes.io/not-ready
        effect: NoExecute
        tolerationSeconds: 30
      - key: node.kubernetes.io/unreachable
        operator: Exists
        effect: NoExecute
        tolerationSeconds: 30
      containers:
        - image: nginx
          name: nginx
          resources:
            requests:
              cpu: "10m"
              memory: "30Mi"
            limits:
              cpu: "10m"
              memory: "30Mi"
```

**kubelet调整**



指定的频率连续报告节点状态更新，其默认值为 10s。
指定kubelet多长时间向master发布一次节点状态。注意: 它必须与kube-controller中的nodeMonitorGracePeriod一起协调工作。(默认 10s)
node-status-update-frequency: 10s

测试关闭一个node节点，停掉kubelet，查看默认驱逐的时候为60s,如果不设置的话，默认官方5m才会驱逐pod

创建一个nginx的示例测试，并停掉kubelet服务，查看pod的驱逐1m的变化情况

```
watch -n 1 "kubectl get pod -n kube-system |grep xxx "

```



