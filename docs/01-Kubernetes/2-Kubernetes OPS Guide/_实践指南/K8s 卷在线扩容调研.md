自己遇到了一个扩容在线卷（已绑定到POD的卷的）的需求。调研了一番，发现在k8s 1.8 alpha版本中，提供了一种卷扩容的方法，并且支持扩容的卷后端存储有：

-   gcePersistentDisk
    
-   awsElasticBlockStore
    
-   OpenStack Cinder
    
-   glusterfs
    
-   rbd
    

并且，当卷已有文件系统后，能够被扩容的卷上的文件系统必须是XFS、 Ext3或Ext4

通过搭建1.9.5版本K8s集群，发现截止该版本，实际上提供的卷扩容功能还比较弱，还得把处于”in-use” 状态的卷变成”available” 状态。整个扩容操作流程如下：

默认k8s 不开启该功能，需要做些配置才能使用。具体的步骤如下

-   修改api-server 配置文件，添加准入控制规则 PersistentVolumeClaimResize ，并打开ExpandPersistentVolumes 特性开关，相关修改如下：

```
sudo vim /etc/kubernetes/apiserver
# default admission control policies
  KUBE_ADMISSION_CONTROL="--admission-control=PersistentVolumeClaimResize,Initializers,
 NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,
  NodeRestriction,ResourceQuota"
  --feature-gates=ExpandPersistentVolumes=true
```

-   修改controller 配置文件，打开ExpandPersistentVolumes 特性开关

```
--feature-gates=ExpandPersistentVolumes=true
```

-   重启api-server 和 controller 服务。

## 修改StorageClass yaml 文件

添加准入控制规则PersistentVolumeClaimResize 的原因是：当PVC所属的 StorageClass 没有被赋予allowVolumeExpansion 权限，可以阻止对这些PVC 调整大小。

设置StorageClass allowVolumeExpansion 属性为True， 以赋予某一storageclass 下的PVC具有可调整大小的特性。 举例如下：

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: dynamic-storage-class
provisioner: kubernetes.io/cinder
parameters:
  type: nova_ip_sas
  availability: nova
allowVolumeExpansion: true
```

声明一个PVC规格，并创建PV。

vim myclaim.yaml

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: dynamic-storage-class

```

## 解绑POD

在1.9.5 版本中，如果卷处于”in-use “状态时，直接运行edit 命令对PVC 进行扩容，会失败。

查看controller的日志，会出现相关错误提示：

```
type: 'Warning' reason: 'VolumeResizeFailed' volume status is not available
```

因此，需要把卷变成”available” 状态，再进行此操作。

## 编辑PVC

使用 kubectl edit pvc xxx, 修改request.storage 的大小，然后保存，退出。如：

```
...
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 6Gi // 修改此处，从1Gi 变成6Gi。
  storageClassName: dynamic-storage-class
  volumeName: pvc-4b645da7-8643-11e8-9c09-fa163e22b9d1
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi

```

edit 命令成功执行后，PVC 的大小将会被调整，过一会查看PV的大小，已经改变为设置的大小，但是PVC的大小，却没有改变, 这应该是该版本的一个bug.

如果PVC 不具有动态调整权限，运行edit 命令后， 会出现以下错误提示：

```
only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize
```

## 重新创建POD

重新创建一个pod, 利用该扩展后的卷作为存储后端。登录该卷挂载的节点，通过df -h 命令查看对应磁盘大小，该挂载卷的文件系统大小还是原来的大小，通过fdisk -l 命令，可以看到扩展后的大小，因此，需要使用resize2fs 进行文件系统扩容。

如：卷对应的磁盘分区是：/dev/vdb , 则使用 resize2fs /dev/vdb 命令即可。

**当前自己环境的实现方式**

由于自己的环境中安装的是v1.7.4 版本K8s，并且需求是基于case4 。经过探索，自己手动完成了容器卷的扩容，也没有重启POD和丢失数据。

环境说明：使用OpenStack 虚拟机部署K8s集群，存储后端使用的是cinder+ceph RBD，并且公司内部已经实现了基于case 1 的cinder卷在线扩容功能。集群内部使用StorageClass 方式创建了PVC。

核心步骤是：

1.  扩容容器卷在主机上的对应的块设备，即找到该块设备对应的cinder卷，对cinder卷扩容。此时，可以在主机上看到块设备容量已经变化（通过fdisk 命令），但是文件系统的大小并没有变化（通过df -h 命令）。
    
2.  使用resize2fs 命名 操作块设备（块设备的文件系统是etx4)
    
3.  使用 df -h 命令可以看到对应块设备大小已经调整，容器里挂载的卷也正确显示大小。
    
4.  使用edit 命名调整PV大小。
    
    虽然期望的卷空间已经调整到位，但是通过`kubectl get pv` 看到的PV的大小仍然是原来的大小。需要通过`kubectl edit {pv_name}` 修改卷大小，PVC的大小也随之改变了。
    
5.  再次使用`kubectl get`命令查看PVC/PV 的大小。
    



## 版本演进

在 v1.11  alpha 版本中，将实线一个真实的在线卷扩容方法，即可以将处于“in-use” 状态的卷直接进行扩容，而不要提前和POD解绑。