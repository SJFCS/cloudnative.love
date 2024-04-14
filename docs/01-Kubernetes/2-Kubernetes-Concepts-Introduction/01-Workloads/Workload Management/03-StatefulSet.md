---
sidebar_position: 3
---
StatefulSet主要用于管理有状态应用程序的工作负载API对象。比如在生产环境中，可以部署ElasticSearch集群、MongoDB集群或者需要持久化的RabbitMQ集群、Redis集群、Kafka集群和ZooKeeper集群等。

和Deployment类似，一个StatefulSet也同样管理着基于相同容器规范的Pod。不同的是，StatefulSet为每个Pod维护了一个粘性标识。这些Pod是根据相同的规范创建的，但是不可互换，每个Pod都有一个持久的标识符，在重新调度时也会保留，一般格式为StatefulSetName-Number。比如定义一个名字是Redis-Sentinel的StatefulSet，指定创建三个Pod，那么创建出来的Pod名字就为Redis-Sentinel-0、Redis-Sentinel-1、Redis-Sentinel-2。而StatefulSet创建的Pod一般使用Headless Service（无头服务）进行通信，和普通的Service的区别在于Headless Service没有ClusterIP，它使用的是Endpoint进行互相通信，Headless一般的格式为：`statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`

假如公司某个项目需要在Kubernetes中部署一个主从模式的Redis，此时使用StatefulSet部署就极为合适，因为StatefulSet启动时，只有当前一个容器完全启动时，后一个容器才会被调度，并且每个容器的标识符是固定的，那么就可以通过标识符来断定当前Pod的角色。


Pod所用的存储必须由PersistentVolume Provisioner（持久化卷配置器）根据请求配置StorageClass，或者由管理员预先配置，当然也可以不配置存储。

为了确保数据安全，删除和缩放StatefulSet不会删除与StatefulSet关联的卷，可以手动选择性地删除PVC和PV。

StatefulSet目前使用Headless Service（无头服务）负责Pod的网络身份和通信，需要提前创建此服务。


### StatefulSet 资源清单

定义一个简单的StatefulSet的示例如下：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  minReadySeconds: 10 # by default is 0
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: registry.k8s.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
```

当StatefulSet控制器创建Pod时，它会添加一个标签statefulset.kubernetes.io/pod-name，该标签的值为Pod的名称，用于匹配Service。

## 优雅停机

直接删除StatefulSet而不先缩减Pod副本数可能会导致应用状态的不一致或数据丢失。为了确保在删除StatefulSet时其Pods能够有序且优雅地终止，通过先将副本数缩减到0，可以确保每个Pod都有足够的时间来正确处理停机逻辑（如数据同步、缓存刷新等），从而保持应用和数据的完整性。当所有Pod都被删除后，StatefulSet管理的所有Pod就都被清理干净了，此时再删除StatefulSet资源本身就不会留下未被管理的Pod。

缩减StatefulSet副本数至0： 通过下列命令可以实现：
```bash
kubectl scale statefulset <statefulset-name> --replicas=0

kubectl get pods -l <label-selector>
```
这里，`<label-selector>`是用来选择那些属于特定StatefulSet的标签选择器。确保没有Pod处于运行状态。

删除StatefulSet资源： 一旦确认所有的Pod都已经被删除，你就可以安全地删除StatefulSet本身了：


## 更新策略



StatefulSet 的 .spec.updateStrategy 字段允许您配置和禁用 StatefulSet 中 Pod 的容器、标签、资源请求/限制和注释的自动滚动更新。有两个可能的值：

- OnDelete

当 StatefulSet 的 `.spec.updateStrategy.type` 设置为 `OnDelete` 时，StatefulSet 控制器不会自动更新 StatefulSet 中的 Pod。用户必须手动删除 Pod 才能使控制器创建反映对 StatefulSet 的 `.spec.template` 所做修改的新 Pod。

- RollingUpdate

`RollingUpdate` 更新策略为 StatefulSet 中的 Pod 实现自动化滚动更新。这是默认的更新策略。
## 滚动更新

当 StatefulSet 的 .spec.updateStrategy.type 设置为 RollingUpdate 时，StatefulSet 控制器将删除并重新创建 StatefulSet 中的每个 Pod。它将按照与 Pod 终止相同的顺序进行（从最大序号到最小序号），一次更新每个 Pod。

如果您设置了 .spec.minReadySeconds （请参阅最小就绪秒数），则控制平面会在 Pod 就绪后继续等待该时间，然后再继续。


## 分区滚动更新
可以通过指定 .spec.updateStrategy.rollingUpdate.partition 来对 RollingUpdate 更新策略进行分区。如果指定了分区，则当更新 StatefulSet 的 .spec.template 时，所有序数大于或等于该分区的 Pod 都会被更新。所有序号小于分区的 Pod 都不会被更新，并且即使被删除，也会以之前的版本重新创建。如果 StatefulSet 的 .spec.updateStrategy.rollingUpdate.partition 大于其 .spec.replicas ，则对其 .spec.template 的更新将不会传播到其 Pod。在大多数情况下，您不需要使用分区，但如果您想要暂存更新、推出金丝雀或执行分阶段推出，它们会很有用。
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-statefulset
spec:
  serviceName: "my-service"
  replicas: 3
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2 # 从序号为2的Pod开始更新
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: my-app:2.0
```
这会更新序号为2的Pod到新版本，而序号0和1的Pod将保持原来的版本。

如果更新无问题，你可以通过减小partition值逐步更新其余Pods。例如，将partition值改为1，然后是0，以此类推，直到所有Pods都更新为新版本。


## 强制回滚
在使用Kubernetes的StatefulSet进行滚动更新时，如果更新的Pod模板配置错误（例如，因为应用程序的错误配置或是错误的镜像版本），这可能导致新的Pod无法成功启动和达到就绪(Ready)状态。当这种情况发生时，按照默认的Pod管理策略（OrderedReady），StatefulSet会停止更新过程并等待，这会导致整个StatefulSet进入一种需要手动干预才能修复的损坏状态。

当你发现因为错误的配置导致StatefulSet的更新停滞时，仅仅将Pod模板恢复到之前的有效配置可能还不足以解决问题。尽管你已经恢复了模板配置，StatefulSet可能仍然在等待那些基于错误配置创建的Pod变成就绪状态，这些Pod可能永远不会就绪。在这种情况下，需要进行强制回滚，步骤如下：

1. 恢复Pod模板: 首先，你需要将Pod模板恢复到之前有效的配置。这可以通过修改StatefulSet的定义来实现，将Pod模板中的容器镜像或其他相关配置项恢复到正确的值。
2. 删除错误配置的Pods: 在恢复Pod模板之后，需要手动删除那些基于错误配置创建的Pod。这一步是必要的，因为StatefulSet不会自动删除这些Pod。你可以使用kubectl delete pod `<pod-name>`命令来手动删除这些Pod。

3. 等待StatefulSet重新创建Pods: 在删除了那些基于错误配置的Pod之后，StatefulSet会开始基于恢复后的模板重新创建Pod。这时候，新创建的Pod应该能够正常启动并达到就绪状态，从而恢复整个StatefulSet的健康状态。

注意事项:

在手动删除Pod之前，确保了解这可能对你的应用或服务造成的影响，特别是对于有状态的应用来说，删除Pod可能会涉及数据一致性和可用性的考虑。
强制回滚是一种应急措施，应当在确认无法通过其他方式恢复服务的情况下才采取。


## 持久卷声明保留

当StatefulSet的Pod副本缩减或删除时，与Pod相关联的PersistentVolumeClaim和底层PersistentVolume的处理方式取决于PVC和PV的配置。默认情况下，删除StatefulSet不会自动删除与之关联的PVC和PV。这种设计是有意为之，以防止因临时删除StatefulSet导致的数据丢失。

因此，即使StatefulSet被删除，由StatefulSet创建的PVC和PV也会保留。这允许以后重新创建StatefulSet时，能够再次挂载现有的数据卷，从而保证数据的持久性和一致性。

自动清理PVC的策略:

1. 使用Helm部署应用时，可以在Helm卸载时通过定义hook来自动清理资源。
2. 可以编写自定义的控制器或操作员（Operator）来监听StatefulSet的删除事件，并自动清理相关联的PVC。
3. .spec.persistentVolumeClaimRetentionPolicy 字段控制在StatefulSet的生命周期中是否以及如何删除PVC。您必须在 API 服务器和控制器管理器上启用 StatefulSetAutoDeletePVC 功能门才能使用此字段。启用后，您可以为每个 StatefulSet 配置两个策略：
   - whenDeleted 配置删除 StatefulSet 时应用的卷保留行为
   - whenScaled 配置当 StatefulSet 的副本数量减少时应用的卷保留行为 Delete or Retain

   - Delete  
     对于受策略影响的每个 Pod，从 StatefulSet volumeClaimTemplate 创建的 PVC 都会被删除。  
     使用 whenDeleted 策略， volumeClaimTemplate 中的所有 PVC 在其 Pod 被删除后都会被删除。  
     使用 whenScaled 策略，在删除 Pod 后，仅删除与缩容 Pod 副本对应的 PVC。
   - Retain (default)
     当 Pod 被删除时， volumeClaimTemplate 中的 PVC 不会受到影响。这是此新功能之前的行为。

请记住，这些策略仅在由于 StatefulSet 被删除或缩小而导致 Pod 被删除时适用。例如，如果与 StatefulSet 关联的 Pod 由于节点故障而发生故障，并且控制平面创建替换 Pod，则 StatefulSet 保留现有 PVC。现有卷不受影响，集群会将其附加到新 Pod 即将启动的节点。

```yaml
apiVersion: apps/v1
kind: StatefulSet
...
spec:
  persistentVolumeClaimRetentionPolicy:
    whenDeleted: Retain
    whenScaled: Delete
...
```