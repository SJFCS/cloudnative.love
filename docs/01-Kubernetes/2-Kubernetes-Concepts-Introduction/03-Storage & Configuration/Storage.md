


指定挂载路径：在容器中，你需要指定一个挂载点，即文件或目录在容器内的路径。这通过 volumeMounts 下的 mountPath 属性来实现。

只读模式：可以设置 volumeMounts 下的 readOnly 属性为 true，以将卷以只读方式挂载。这对于需要保证数据不被容器修改的场景非常有用。

子路径挂载：如果你不需要挂载整个卷，可以通过设置 volumeMounts 下的 subPath 属性来实现挂载卷的特定子路径。这对于在同一个卷中为多个容器提供不同的数据或配置非常有用。

挂载点的文件权限：Kubernetes 允许通过 volumes 下的 persistentVolumeClaim 或其他卷类型配置中指定 fsGroup 和 fsGroupChangePolicy 来控制挂载点的文件系统权限。这对于控制对挂载卷的访问非常重要。



https://www.cnblogs.com/rexcheny/p/10925464.html

Container（容器）中的磁盘文件是短暂的，当容器崩溃时，kubelet会重新启动容器，但最初的文件将丢失，Container会以最干净的状态启动。另外，当一个Pod运行多个Container时，各个容器可能需要共享一些文件。Kubernetes Volume可以解决这两个问题。

一些需要持久化数据的程序才会用到Volumes，或者一些需要共享数据的容器需要volumes。

kubernetes的Volume支持多种类型，比较常见的有下面几个：

- 简单存储：EmptyDir、HostPath、NFS
- 高级存储：PV、PVC、Storage Classes

## 基本存储

### EmptyDir

如果删除Pod，emptyDir卷中的数据也将被删除，一般emptyDir卷用于：

- Pod中的不同Container共享数据，且无须永久保留

- 一个容器需要从另一个容器中获取数据的目录（多容器共享目录）

默认情况下，emptyDir卷支持节点上的任何介质，可能是SSD、磁盘或网络存储，具体取决于自身的环境。可以将emptyDir.medium字段设置为Memory，让Kubernetes使用tmpfs（内存支持的文件系统），虽然tmpfs非常快，但是tmpfs在节点重启时，数据同样会被清除，**并且设置的大小会被计入到Container的内存限制当中**。

接下来，通过一个容器之间文件共享的案例来使用一下EmptyDir。

在一个Pod中准备两个容器nginx和busybox，然后声明一个Volume分别挂在到两个容器的目录中，然后nginx容器负责向Volume中写日志，busybox中通过命令将日志内容读到控制台。

创建一个volume-emptydir.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-emptydir
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.14-alpine
    ports:
    - containerPort: 80
    volumeMounts:  # 将logs-volume挂在到nginx容器中，对应的目录为 /var/log/nginx
    - name: logs-volume
      mountPath: /var/log/nginx
  - name: busybox
    image: busybox:1.30
    command: ["/bin/sh","-c","tail -f /logs/access.log"] # 初始命令，动态读取指定文件中内容
    volumeMounts:  # 将logs-volume 挂在到busybox容器中，对应的目录为 /logs
    - name: logs-volume
      mountPath: /logs
  volumes: # 声明volume， name为logs-volume，类型为emptyDir
  - name: logs-volume
    emptyDir: {}
```

### HostPath

HostPath就是将Node主机中一个实际目录挂在到Pod中，以供容器使用，这样的设计就可以保证Pod销毁了，但是数据依据可以存在于Node主机上。用于Pod自定义日志输出或访问Docker内部的容器等。


> **hostPath卷常用的type（类型）如下：**
>
> + type为空字符串：默认选项，意味着挂载hostPath卷之前不会执行任何检查。
> + DirectoryOrCreate：如果给定的path不存在任何东西，那么将根据需要创建一个权限为0755的空目录，和Kubelet具有相同的组和权限。
> + Directory：目录必须存在于给定的路径下。
> + FileOrCreate：如果给定的路径不存储任何内容，则会根据需要创建一个空文件，权限设置为0644，和Kubelet具有相同的组和所有权。
> + File：文件，必须存在于给定路径中。
> + Socket：UNIX套接字，必须存在于给定路径中。
> + CharDevice：字符设备，必须存在于给定路径中。
> + BlockDevice：块设备，必须存在于给定路径中。

创建一个volume-hostpath.yaml：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-hostpath
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
    ports:
    - containerPort: 80
    volumeMounts:
    - name: logs-volume
      mountPath: /var/log/nginx
  - name: busybox
    image: busybox:1.30
    command: ["/bin/sh","-c","tail -f /logs/access.log"]
    volumeMounts:
    - name: logs-volume
      mountPath: /logs
  volumes:
  - name: logs-volume
    hostPath: 
      path: /root/logs
      type: DirectoryOrCreate  # 目录存在就使用，不存在就先创建后使用    
```
**关于type的值的一点说明：**

```markdown
	DirectoryOrCreate 目录存在就使用，不存在就先创建后使用
	Directory	目录必须存在
	FileOrCreate  文件存在就使用，不存在就先创建后使用
	File 文件必须存在	
    Socket	unix套接字必须存在
	CharDevice	字符设备必须存在
	BlockDevice 块设备必须存在
```

### NFS

HostPath可以解决数据持久化的问题，但是一旦Node节点故障了，Pod如果转移到了别的节点，又会出现问题了，此时需要准备单独的网络存储系统，比较常用的用NFS、CIFS。

NFS是一个网络文件存储系统，可以搭建一台NFS服务器，然后将Pod中的存储直接连接到NFS系统上，这样的话，无论Pod在节点上怎么转移，只要Node跟NFS的对接没问题，数据就可以成功访问。


1）首先要准备nfs的服务器，这里为了简单，直接是master节点做nfs服务器

```powershell
# 在master上安装nfs服务
[root@master ~]# yum install nfs-utils rpcbind -y

# 准备一个共享目录
[root@master ~]# mkdir /root/data/nfs -pv

# 将共享目录以读写权限暴露给192.168.109.0/24网段中的所有主机
[root@master ~]# vim /etc/exports
[root@master ~]# more /etc/exports
/root/data/nfs     192.168.109.0/24(rw,no_root_squash)
#/data/k8s/ *(rw,sync,no_subtree_check,no_root_squash)
exportfs -r
# 启动nfs服务
[root@master ~]# systemctl restart nfs rpcbind
#挂载测试：mount -t nfs nfs-serverIP:/data/k8s /mnt/
```

2）接下来，要在的每个node节点上都安装下nfs，这样的目的是为了node节点可以驱动nfs设备

```powershell
# 在node上安装nfs服务，注意不需要启动
[root@master ~]# yum install nfs-utils -y
```

3）接下来，就可以编写pod的配置文件了，创建volume-nfs.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-nfs
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
    ports:
    - containerPort: 80
    volumeMounts:
    - name: logs-volume
      mountPath: /var/log/nginx
  - name: busybox
    image: busybox:1.30
    command: ["/bin/sh","-c","tail -f /logs/access.log"] 
    volumeMounts:
    - name: logs-volume
      mountPath: /logs
  volumes:
  - name: logs-volume
    nfs:
      server: 192.168.109.100  #nfs服务器地址
      path: /root/data/nfs #共享文件路径
```

## 高级存储

### PV和PVC

PersistentVolume：简称PV，是由Kubernetes管理员设置的存储，可以配置Ceph、NFS、GlusterFS等常用存储配置，相对于Volume配置，提供了更多的功能，比如生命周期的管理、大小的限制。PV分为静态和动态。

PersistentVolumeClaim：简称PVC，是对存储PV的请求，表示需要什么类型的PV，需要存储的技术人员只需要配置PVC即可使用存储，或者Volume配置PVC的名称即可。

StorageClass: 简称CS，为管理员提供了描述存储 "类" 的方法。 不同的类型可能会映射到不同的服务质量等级或备份策略，或是由集群管理员制定的任意策略。 Kubernetes 本身并不清楚各种类代表的什么。这个类的概念在其他存储系统中有时被称为 "配置文件"。


官方文档：
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/zh-cn/docs/concepts/storage/storage-classes/

**PV回收策略**   

官方文档：[https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

可以通过persistentVolumeReclaimPolicy字段配置: 
- Retain：保留，该策略允许手动回收资源，当删除PVC时，PV仍然存在，PV被视为已释放，管理员可以手动回收卷。
- Recycle：回收，如果Volume插件支持，Recycle策略会对卷执行rm -rf清理该PV，并使其可用于下一个新的PVC，但是本策略将来会被弃用，目前只有NFS和HostPath支持该策略。
- Delete：删除，如果Volume插件支持，删除PVC时会同时删除PV，动态卷默认为Delete，目前支持Delete的存储后端包括AWS EBS, GCE PD, Azure Disk, or OpenStack Cinder等。

**PV访问策略**

官方文档：[https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

- ReadWriteOnce：可以被单节点以读写模式挂载，命令行中可以被缩写为RWO。
- ReadOnlyMany：可以被多个节点以只读模式挂载，命令行中可以被缩写为ROX。
- ReadWriteMany：可以被多个节点以读写模式挂载，命令行中可以被缩写为RWX。
- ReadWriteOncePod ：只允许被单个Pod访问，需要K8s 1.22+以上版本，并且是CSI创建的PV才可使用

### PV

- 静态PV:集群管理员创建许多PV,它们包含可供集群用户使用的实际存储的详细信息。
- 动态PV:当管理员创建的静态PV都不匹配用户创建的PersistentVolumeClaim时，集群会为PVC动态的配置卷。此配置基于StorageClasses：PVC必须请求存储类(storageclasses)，并且管理员必须已创建并配置该类，以便进行动态创建。

```yaml
volumeMode：卷的模式，目前支持Filesystem（文件系统） 和 Block（块），其中Block类型需要后端存储支持，默认为文件系统
capacity：容量。
accessModes：访问模式。包括以下3种：
	ReadWriteOnce：可以被单节点以读写模式挂载，命令行中可以被缩写为RWO。
	ReadOnlyMany：可以被多个节点以只读模式挂载，命令行中可以被缩写为ROX。
	ReadWriteMany：可以被多个节点以读写模式挂载，命令行中可以被缩写为RWX。
storageClassName：PV的类，一个特定类型的PV只能绑定到特定类别的PVC。
persistentVolumeReclaimPolicy：回收策略。
	Retain：保留，该策略允许手动回收资源，当删除PVC时，PV仍然存在，PV被视为已释放，管理员可以手动回收卷。
	Recycle：回收，如果Volume插件支持，Recycle策略会对卷执行rm -rf清理该PV，并使其可用于下一个新的PVC，但是本策略将来会被弃用，目前只有NFS和HostPath支持该策略。
	Delete：删除，如果Volume插件支持，删除PVC时会同时删除PV，动态卷默认为Delete，目前支持Delete的存储后端包括AWS EBS, GCE PD, Azure Disk, or OpenStack Cinder等。
#mountOptions：非必须，新版本中已弃用。
nfs：NFS服务配置。包括以下两个选项：
	path：NFS上的目录
	server：NFS的IP地址
创建的PV会有以下几种状态：
Available（可用），没有被PVC绑定的空间资源。
Bound（已绑定），已经被PVC绑定。
Released（已释放），PVC被删除，但是资源还未被重新使用。
Failed（失败），自动回收失败。
```
- **存储类型**

  底层实际存储的类型，kubernetes支持多种存储类型，每种存储类型的配置都有所差异

- **存储能力（capacity）**

      目前只支持存储空间的设置( storage=1Gi )，不过未来可能会加入IOPS、吞吐量等指标的配置

- **访问模式（accessModes）**

  用于描述用户应用对存储资源的访问权限，访问权限包括下面几种方式：

  - ReadWriteOnce（RWO）：读写权限，但是只能被单个节点挂载
  - ReadOnlyMany（ROX）：  只读权限，可以被多个节点挂载
  - ReadWriteMany（RWX）：读写权限，可以被多个节点挂载

  `需要注意的是，底层不同的存储类型可能支持的访问模式不同`

- **回收策略（persistentVolumeReclaimPolicy）**

  当PV不再被使用了之后，对其的处理方式。目前支持三种策略：

  - Retain -  手动回收。在删除pvc后PV变为Released不可用状态， 若想重新被使用,需要管理员删除pv，重新创建pv，删除pv并不会删除存储的资源，只是删除pv对象而已；若想保留数据，请使用该Retain。
  - Recycle - 基本擦洗（rm -rf /thevolume/*）。 删除pvc自动清除PV中的数据，效果相当于执行 rm -rf /thevolume/*。删除pvc时，pv的状态由Bound变为Available。此时可重新被pvc申请绑定。
  - Delete -  删除存储上的对应存储资源。关联的存储资产（如AWS EBS，GCE PD，Azure磁盘或OpenStack Cinder卷）将被删除。NFS不支持delete策略。

  > 需要注意的是，底层不同的存储类型可能支持的回收策略不同
  >
  > 目前，只有NFS和HostPath支持Recycle 回收。AWS EBS，GCE PD，Azure磁盘和Cinder卷支持Delete 删除。

  

- **存储类别**

  PV可以通过storageClassName参数指定一个存储类别

  - 具有特定类别的PV只能与请求了该类别的PVC进行绑定

  - 未设定类别的PV则只能与不请求任何类别的PVC进行绑定

- **状态（status）**

  一个 PV 的生命周期中，可能会处于4中不同的阶段：

  - Available（可用）：     表示可用状态，还未被任何 PVC 绑定
  - Bound（已绑定）：     表示 PV 已经被 PVC 绑定
  - Released（已释放）： 表示 PVC 被删除，但是资源还未被集群重新声明
  - Failed（失败）：         表示该 PV 的自动回收失败

#### PVC 的关键配置参数说明：

- **访问模式（accessModes）**

       用于描述用户应用对存储资源的访问权限

- **选择条件（selector）**

  通过Label Selector的设置，可使PVC对于系统中己存在的PV进行筛选

- **存储类别（storageClassName）**

  PVC在定义时可以设定需要的后端存储的类别，只有设置了该class的pv才能被系统选出

- **资源请求（Resources ）**

  描述对存储资源的请求

### PVC创建和挂载失败原因

PVC一直Pending：

+ PVC的空间申请大小大于PV的大小
+ PVC的StorageClassName没有和PV的一致
+ PVC的accessModes和PV的不一致

挂载PVC的Pod一直Pending：

+ PVC没有创建成功或不存在
+ PVC和Pod不在同一个Namespace
+ NFS类型的PV链接不上服务器

### PV&PVC生命周期

PVC和PV是一一对应的，PV和PVC之间的相互作用遵循以下生命周期：

- **资源供应**：管理员手动创建底层存储和PV

- **资源绑定**：用户创建PVC，kubernetes负责根据PVC的声明去寻找PV，并绑定

  在用户定义好PVC之后，系统将根据PVC对存储资源的请求在已存在的PV中选择一个满足条件的

  - 一旦找到，就将该PV与用户定义的PVC进行绑定，用户的应用就可以使用这个PVC了

  - 如果找不到，PVC则会无限期处于Pending状态，直到等到系统管理员创建了一个符合其要求的PV

  PV一旦绑定到某个PVC上，就会被这个PVC独占，不能再与其他PVC进行绑定了

- **资源使用**：用户可在pod中像volume一样使用pvc

  Pod使用Volume的定义，将PVC挂载到容器内的某个路径进行使用。

- **资源释放**：用户删除pvc来释放pv

  当存储资源使用完毕后，用户可以删除PVC，与该PVC绑定的PV将会被标记为“已释放”，但还不能立刻与其他PVC进行绑定。通过之前PVC写入的数据可能还被留在存储设备上，只有在清除之后该PV才能再次使用。

- **资源回收**：kubernetes根据pv设置的回收策略进行资源的回收

  对于PV，管理员可以设定回收策略，用于设置与之绑定的PVC释放资源之后如何处理遗留数据的问题。只有PV的存储空间完成回收，才能供新的PVC绑定和使用


### StorageClass 资源
每个 StorageClass 都包含 provisioner、parameters 和 reclaimPolicy 字段， 这些字段会在 StorageClass 需要动态制备 PersistentVolume 时会使用到。

StorageClass 对象的命名很重要，用户使用这个命名来请求生成一个特定的类。 当创建 StorageClass 对象时，管理员设置 StorageClass 对象的命名和其他参数，一旦创建了对象就不能再对其更新。
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
# Immediate 模式表示一旦创建 PersistentVolumeClaim，就会发生卷绑定和动态配置。对于受拓扑限制且无法从集群中的所有节点全局访问的存储后端，将在不了解 Pod 调度要求的情况下绑定或配置 PersistentVolume。这可能会导致 Pod 无法调度。

# WaitForFirstConsumer  如果您选择使用 WaitForFirstConsumer ，请勿在 Pod 规范中使用 nodeName 来指定节点关联性。如果在这种情况下使用 nodeName ，调度程序将被绕过，PVC 将保持在 pending 状态。



```

**回收策略**

由 StorageClass 动态创建的 PersistentVolume 会在类的 reclaimPolicy 字段中指定回收策略，可以是 Delete 或者 Retain。如果 StorageClass 对象被创建时没有指定 reclaimPolicy，它将默认为 Delete。

通过 StorageClass 手动创建并管理的 PersistentVolume 会使用它们被创建时指定的回收策略。

**允许卷扩展**

特性状态： Kubernetes v1.11 [beta]
PersistentVolume 可以配置为可扩展。将此功能设置为 true 时，允许用户通过编辑相应的 PVC 对象来调整卷大小。

需要 StorageClass 的 allowVolumeExpansion 字段设置为 true 且后端存储支持动态扩展。