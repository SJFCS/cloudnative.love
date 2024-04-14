## Horizontal Pod Autoscaler(HPA)
现通过手工执行`kubectl scale`命令实现Pod扩容或缩容，但这不够自动化。 Horizontal Pod Autoscaler（HPA）可以通过监测Pod的负载进行自动扩容。
    
### HPA 接口类型

- v1 只支持CPU指标
- v2beta2 支持CPU、内存、自定义指标Custom和额外指标ExternalMetrics

### 动态伸缩周期

HPA控制器观测资源使用率并作出决策是有周期的，执行是需要时间的，在执行自动伸缩过程中metrics不是静止不变的，可能降低或者升高，如果执行太频繁可能导致资源的使用快速抖动，因此控制器每次决策后的一段时间内不再进行新的决策。对于扩容这个时间是3分钟，缩容则是5分钟，对应调整参数

```
--horizontal-pod-autoscaler-downscale-delay
--horizontal-pod-autoscaler-upscale-delay
```

### 动态伸缩HPA实践

- 必须安装metrics-server或其他自定义metrics-server
- 必须配置requests参数
- 不能扩容无法缩放的对象，比如DaemonSet

### 安装 metrics-server

metrics-server 可以用来收集集群中的资源使用情况
- [metrics-server-repo](https://github.com/kubernetes-sigs/metrics-server) 
- [metrics-server-helm](https://artifacthub.io/packages/helm/metrics-server/metrics-server) 
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm upgrade --install metrics-server metrics-server/metrics-server -f values.yaml
```

```yaml title="values.yaml"
# Default values for metrics-server.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

hostNetwork:
  # Specifies if metrics-server should be started in hostNetwork mode.
  #
  # You would require this enabled if you use alternate overlay networking for pods and
  # API server unable to communicate with metrics-server. As an example, this is required
  # if you use Weave network on EKS
  enabled: false

defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP,InternalDNS,ExternalDNS,ExternalIP,Hostname
```

### 创建HPA策略
创建演示用deployment 
```bash
# 创建deployment 
kubectl run nginx-server --image=nginx --port=80 --requests=cpu=10m -n dev
# 创建service
kubectl expose deployment nginx-server --type=NodePort --port=80 -n dev
```

**创建HPA**

```bash
kubectl autoscale deployment nginx-server --cpu-percent=10 --min=1 --max=10
```

### 压力测试

```
while true; do wget -q -O- http://192.168.15.197 > /dev/null; done
```

已经开始自动扩容

```
root@node1[09:28:10]:~$ kubectl get hpa
NAME               REFERENCE                     TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
nginx-server-hpa   Deployment/nginx-server       150%/10%   1         10        10         4m53s
```

停止压力测试5分钟后自动缩容

```
root@node1[09:33:50]:~$ kubectl get hpa
NAME               REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
nginx-server-hpa   Deployment/nginx-server       0%/10%    1         10        1          12m
```