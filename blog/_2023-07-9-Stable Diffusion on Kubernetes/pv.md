本地？
ceph？
openeb？

pvc 默认

https://mauilion.dev/posts/kind-pvc/
这个录制效果很好





创建一个 PersistentVolume（PV）对象，并将它绑定到一个 PersistentVolumeClaim（PVC）对象上。在 PV 对象中，您可以指定 hostPath 存储后端的路径和访问模式。在 PVC 对象中，您可以指定所需的存储容量和访问模式。然后，将 PVC 对象绑定到 Pod 中的 Volume 对象上，容器就可以访问 hostPath 存储后端了。

使用 Helm 等包管理工具部署应用程序时，可以在 chart 中指定 hostPath 存储后端的路径和访问模式。这样，当应用程序在 Kubernetes 中部署时，它将自动使用 hostPath 存储后端。在这种情况下，需要确保目标节点上存在指定的路径，并且具有足够的权限。


Kubernetes 中设置默认的 storageclass，并且 Helm 等包管理工具可以自动调用它。设置默认的 storageclass 可以让您不必在每个 PVC 对象中都显式指定 storageClassName，从而简化了应用程序部署的流程。

要设置默认的 storageclass，您可以使用 kubectl patch 命令来修改 storageclass 对象的注释。例如，以下命令将名为 fast 的 storageclass 设置为默认的 storageclass：
```bash
kubectl patch storageclass fast -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
然后，当您在 Helm chart 或其他 Kubernetes YAML 文件中创建 PVC 对象时，可以省略 storageClassName 字段。在这种情况下，Kubernetes 将自动使用默认的 storageclass。


要定义一个 hostPath 类型的 storageclass，您可以创建一个 YAML 文件，其中包括以下内容：


```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: my-hostpath-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
parameters:
  type: DirectoryOrCreate
  path: /data
```
在这个 YAML 文件中，kind 字段指定了资源类型为 StorageClass，apiVersion 字段指定了 Kubernetes API 的版本，metadata 字段指定了资源的名称，provisioner 字段指定了 storageclass 的存储后端，这里设置为 kubernetes.io/no-provisioner，表示使用 hostPath 存储后端。

volumeBindingMode 字段指定了卷绑定模式，这里设置为 WaitForFirstConsumer，表示在第一个 Pod 使用该 PVC 对象之前不会创建 PV 对象。

allowVolumeExpansion 字段启用了卷扩展功能，reclaimPolicy 字段指定了 PV 对象的回收策略，这里设置为 Retain，表示在 PVC 对象被删除后保留 PV 对象。

最后，parameters 字段指定了 hostPath 存储后端的参数，这里包括了 type 和 path 两个参数。type 参数设置为 DirectoryOrCreate，表示在指定的路径上创建一个目录，如果目录已经存在，则不会创建。path 参数指定了 hostPath 存储后端的路径，这里设置为 /data。

完成后，您可以使用 kubectl apply 命令将该 YAML 文件部署到 Kubernetes 集群中，从而创建一个名为 my-hostpath-sc 的 hostPath 类型的 storageclass。例如：

```
kubectl patch storageclass my-hostpath-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclass --sort-by=.metadata.annotations.storageclass\.kubernetes\.io/is-default-class -o=jsonpath='{range .items[*]}{.metadata.name} {.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep true | awk '{print $1}'
```


## 标签
kubectl label nodes archlinux nvidia.com/gpu.present=true
kubectl describe node archlinux | grep nvidia.com/gpu.present
如果您的节点上已经安装了Nvidia设备插件，并且该插件已正确配置，则您不需要手动添加nvidia.com/gpu.present标签。该标签应该会自动添加到具有GPU的节点上。您可以使用以下命令检查节点是否有此标签：
kubectl delete pod pod-name --grace-period=0

