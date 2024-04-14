---
sidebar_position: 4
---
DaemonSet类型的控制器可以保证在集群中的每一台（或指定）节点上都运行一个副本。一般适用于日志收集、节点监控等场景。

## 使用DaemonSet的场景：

1. 运行集群存储的daemon，比如ceph或者glusterd
2. 节点的CNI网络插件，calico
3. 节点日志的收集：fluentd或者是filebeat
4. 节点的监控：node exporter
5. 服务暴露：部署一个ingress nginx

## 资源清单

下面先来看下DaemonSet的资源清单文件

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      tolerations:
      # these tolerations are to have the daemonset runnable on control plane nodes
      # remove them if your control plane nodes should not run pods
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluentd-elasticsearch
        image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      # it may be desirable to set a high priority class to ensure that a DaemonSet Pod
      # preempts running Pods
      # priorityClassName: important
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

## 在选定节点上运行 Pod 
如果指定  `.spec.template.spec.nodeSelector`，则 DaemonSet 控制器将在与该[节点选择器](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)匹配的节点上创建 Pod 。同样，如果您指定  `.spec.template.spec.affinity`，则 DaemonSet 控制器将在与该 [节点关联性](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)匹配的节点上创建 Pod 。如果您两者都不指定，则 DaemonSet 控制器将在所有节点上创建 Pod。

## Daemon Pod 是如何调度的

DaemonSet控制器为每个符合条件的节点创建一个Pod，并添加 spec.affinity.nodeAffinityPod的字段以匹配目标主机。 Pod 创建后，通常会由默认调度程序接管，然后通过设置字段将 Pod 绑定到目标主机.spec.nodeName。如果新的 Pod 无法容纳在节点上，默认调度程序可能会根据 新 [Pod 的优先级抢占（驱逐）](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#pod-priority)一些现有的 Pod。


注意：如果 DaemonSet pod 在每个节点上运行很重要，通常需要将 DaemonSet 的 .spec.template.spec.priorityClassName 设置为具有更高优先级的 [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) 以确保发生此驱逐。

用户可以通过设置.spec.template.spec.schedulerNameDaemonSet的字段来为DaemonSet的Pod指定不同的调度程序。

.spec.template.spec.affinity.nodeAffinityDaemonSet 控制器在评估合格节点时会考虑在字段中指定的原始节点关联性 （如果已指定），但会在创建的 Pod 上替换为与合格节点名称匹配的节点关联性。
```yaml
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchFields:
      - key: metadata.name
        operator: In
        values:
        - target-host-name
```
## 更新 DaemonSet
```yaml
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
```
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      tolerations:
      # these tolerations are to have the daemonset runnable on control plane nodes
      # remove them if your control plane nodes should not run pods
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluentd-elasticsearch
        image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```