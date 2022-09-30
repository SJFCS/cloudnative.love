---
title: 数据存储:PV&PVC和ConfigMap&Secret

categories:
  - Kubernetes
series: 
  - Kubernetes服务发布
lastmod: '2021-07-29'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



## 简介

Container（容器）中的磁盘文件是短暂的，当容器崩溃时，kubelet会重新启动容器，但最初的文件将丢失，Container会以最干净的状态启动。另外，当一个Pod运行多个Container时，各个容器可能需要共享一些文件。Kubernetes Volume可以解决这两个问题。

一些需要持久化数据的程序才会用到Volumes，或者一些需要共享数据的容器需要volumes。

> 日志收集的需求：需要在应用程序的容器里面加一个sidecar，这个容器是一个收集日志的容器，比如filebeat，它通过volumes共享应用程序的日志文件目录。

Volumes：官方文档https://kubernetes.io/docs/concepts/storage/volumes/

kubernetes的Volume支持多种类型，比较常见的有下面几个：

- 简单存储：EmptyDir、HostPath、NFS
- 高级存储：PV、PVC
- 配置存储：ConfigMap、Secret

## 基本存储

### EmptyDir

如果删除Pod，emptyDir卷中的数据也将被删除，一般emptyDir卷用于：

- Pod中的不同Container共享数据，且无须永久保留

- 一个容器需要从另一个容器中获取数据的目录（多容器共享目录）

默认情况下，emptyDir卷支持节点上的任何介质，可能是SSD、磁盘或网络存储，具体取决于自身的环境。可以将emptyDir.medium字段设置为Memory，让Kubernetes使用tmpfs（内存支持的文件系统），虽然tmpfs非常快，但是tmpfs在节点重启时，数据同样会被清除，并且设置的大小会被计入到Container的内存限制当中。

接下来，通过一个容器之间文件共享的案例来使用一下EmptyDir。

​    在一个Pod中准备两个容器nginx和busybox，然后声明一个Volume分别挂在到两个容器的目录中，然后nginx容器负责向Volume中写日志，busybox中通过命令将日志内容读到控制台。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:57:51-image-20200413174713773.png"  />

创建一个volume-emptydir.yaml

~~~yaml
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
~~~

### HostPath

​    HostPath就是将Node主机中一个实际目录挂在到Pod中，以供容器使用，这样的设计就可以保证Pod销毁了，但是数据依据可以存在于Node主机上。用于Pod自定义日志输出或访问Docker内部的容器等。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:57:54-image-20200413214031331.png"  />

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

~~~yaml
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
~~~
**关于type的值的一点说明：**

~~~markdown
	DirectoryOrCreate 目录存在就使用，不存在就先创建后使用
	Directory	目录必须存在
	FileOrCreate  文件存在就使用，不存在就先创建后使用
	File 文件必须存在	
    Socket	unix套接字必须存在
	CharDevice	字符设备必须存在
	BlockDevice 块设备必须存在
~~~

### NFS

​    HostPath可以解决数据持久化的问题，但是一旦Node节点故障了，Pod如果转移到了别的节点，又会出现问题了，此时需要准备单独的网络存储系统，比较常用的用NFS、CIFS。

​    NFS是一个网络文件存储系统，可以搭建一台NFS服务器，然后将Pod中的存储直接连接到NFS系统上，这样的话，无论Pod在节点上怎么转移，只要Node跟NFS的对接没问题，数据就可以成功访问。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:57:57-image-20200413215133559.png"  />

1）首先要准备nfs的服务器，这里为了简单，直接是master节点做nfs服务器

~~~powershell
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
~~~

2）接下来，要在的每个node节点上都安装下nfs，这样的目的是为了node节点可以驱动nfs设备

~~~powershell
# 在node上安装nfs服务，注意不需要启动
[root@master ~]# yum install nfs-utils -y
~~~

3）接下来，就可以编写pod的配置文件了，创建volume-nfs.yaml

~~~yaml
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
~~~

## 高级存储

### PV和PVC

PersistentVolume：简称PV，是由Kubernetes管理员设置的存储，可以配置Ceph、NFS、GlusterFS等常用存储配置，相对于Volume配置，提供了更多的功能，比如生命周期的管理、大小的限制。PV分为静态和动态。

PersistentVolumeClaim：简称PVC，是对存储PV的请求，表示需要什么类型的PV，需要存储的技术人员只需要配置PVC即可使用存储，或者Volume配置PVC的名称即可。

官方文档：https://kubernetes.io/docs/concepts/storage/persistent-volumes/

> 当某个数据卷不再被挂载使用时，里面的数据如何处理？
>
> 如果想要实现只读挂载如何处理？
>
> 如果想要只能一个Pod挂载如何处理？
>
> 如何只允许某个Pod使用10G的空间？

![image-20210924230803624](D:\ac\Volume\image-20210924230803624.png)

**更灵活的存储配置-PV回收策略**   

官方文档：[https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

> Retain：保留，该策略允许手动回收资源，当删除PVC时，PV仍然存在，PV被视为已释放，管理员可以手动回收卷。
>
> Recycle：回收，如果Volume插件支持，Recycle策略会对卷执行rm -rf清理该PV，并使其可用于下一个新的PVC，但是本策略将来会被弃用，目前只有NFS和HostPath支持该策略。
>
> Delete：删除，如果Volume插件支持，删除PVC时会同时删除PV，动态卷默认为Delete，目前支持Delete的存储后端包括AWS EBS, GCE PD, Azure Disk, or OpenStack Cinder等。
>
> 可以通过persistentVolumeReclaimPolicy: Recycle字段配置

**更灵活的存储配置-PV访问策略**

官方文档：[https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

> ReadWriteOnce：可以被单节点以读写模式挂载，命令行中可以被缩写为RWO。
>
> ReadOnlyMany：可以被多个节点以只读模式挂载，命令行中可以被缩写为ROX。
>
> ReadWriteMany：可以被多个节点以读写模式挂载，命令行中可以被缩写为RWX。
>
> ReadWriteOncePod ：只允许被单个Pod访问，需要K8s 1.22+以上版本，并且是CSI创建的PV才可使用

 前面已经学习了使用NFS提供存储，此时就要求用户会搭建NFS系统，并且会在yaml配置nfs。由于kubernetes支持的存储系统有很多，要求客户全都掌握，显然不现实。为了能够屏蔽底层存储实现的细节，方便用户使用， kubernetes引入PV和PVC两种资源对象。

​    PV（Persistent Volume）是持久化卷的意思，是对底层的共享存储的一种抽象。一般情况下PV由kubernetes管理员进行创建和配置，它与底层具体的共享存储技术有关，并通过插件完成与共享存储的对接。

​    PVC（Persistent Volume Claim）是持久卷声明的意思，是用户对于存储需求的一种声明。换句话说，PVC其实就是用户向kubernetes系统发出的一种资源需求申请。

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:58:00-image-20200514194111567.png"  />

使用了PV和PVC之后，工作可以得到进一步的细分：

- 存储：存储工程师维护
- PV：  kubernetes管理员维护
- PVC：kubernetes用户维护

### PV

 **可以通过两种方式配置PV：静态或动态。**

-  静态PV:集群管理员创建许多PV,它们包含可供集群用户使用的实际存储的详细信息。
-   动态PV:当管理员创建的静态PV都不匹配用户创建的PersistentVolumeClaim时，集群会为PVC动态的配置卷。此配置基于StorageClasses：PVC必须请求存储类(storageclasses)，并且管理员必须已创建并配置该类，以便进行动态创建。

#### PV资源清单文件:

~~~yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
# labels:
# type: nfs
spec:
  storageClassName: slow
  volumeMode: Filesystem
  persistentVolumeReclaimPolicy: Recycle  
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
#  mountOptions:
#    - hard
#    - nfsvers=4.1
#nfs存储
  nfs:
    path: /tmp
    server: 172.17.0.2
#本地挂载    
# hostPath:
#   path: "/mnt/data"    

#CephRBD
#  rbd:
#    monitirs:                  #Ceph的minitor节点IP
#    - 192.168.1.123:6789
#    - 192.168.1.124:6789
#    - 192.168.1.125:6789
#  pool: rbd                    #所用Ceph Pool的名称，可使用ceph osd pool ls 查看
#  image: ceph-rbd-pv-test      #Ceph块设备中的磁盘映像文件，可使用rbd create POOL_NAME/IMAGE_NAME --size 1024创建，是同rbd list POOL_NAME查看
#  user: admin                  #Rados的用户名，默认是admin
#  secreRef:                    #用于验证Ceph身份的密钥
#    name: ceph-secret
#  fsType: ext4                 #文件类型可以是ext4、XFS等
#  readOnlu: false              #是否制度挂载
===================================
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
~~~

#### PV 的关键配置参数说明：

- **存储类型**

  底层实际存储的类型，kubernetes支持多种存储类型，每种存储类型的配置都有所差异

- **存储能力（capacity）**

​      目前只支持存储空间的设置( storage=1Gi )，不过未来可能会加入IOPS、吞吐量等指标的配置

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

#### 实验：创建pv

创建pv.yaml

~~~yaml
# 创建 pv
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  storageClassName: slow
  volumeMode: Filesystem
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
#  mountOptions:
#    - hard
#    - nfsvers=4.1
  nfs:
    path: /
    server: 113dc4a3d6-ayh29.cn-beijing.nas.aliyuncs.com
#  hostPath:
#    path: "/mnt/data
EOF
# 查看pv
kubectl get pv -o wide 
~~~

### PVC

#### PVC资源清单文件:

~~~yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
#  labels:
#    pv: nfs-slow 
spec:
  accessModes: # 访问模式
    - ReadWriteMany
  selector: # 采用标签对PV选择
  storageClassName: nfs-slow # 存储类别
  resources: # 请求空间
    requests:
      storage: 5Gi #storage可以比PV小：
~~~

#### PVC 的关键配置参数说明：

- **访问模式（accessModes）**

​       用于描述用户应用对存储资源的访问权限

- **选择条件（selector）**

  通过Label Selector的设置，可使PVC对于系统中己存在的PV进行筛选

- **存储类别（storageClassName）**

  PVC在定义时可以设定需要的后端存储的类别，只有设置了该class的pv才能被系统选出

- **资源请求（Resources ）**

  描述对存储资源的请求

#### 实验创建pvc

1. 创建pvc.yaml，申请pv

   创建PVC需要注意的是，各个方面都符合要求PVC才能和PV进行绑定，比如accessModes、storageClassName、volumeMode都需要相同才能进行绑定。

~~~yaml
# 创建pvc
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc1
#  namespace: dev
spec:
  storageClassName: slow
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
#  selector:
#    matchLabels:
#      pv: "nfs-slow"
#    matchExpressions:
#      - {key: environment, operator: In, values: [dev]}
EOF
# 查看pvc
kubectl get pvc -o wide
~~~

#### 实验创建引用pvc

~~~yaml
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod1
#  namespace: dev
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh","-c","while true;do echo pod1 >> /root/out.txt; sleep 10; done;"]
    volumeMounts:
    - name: volume
      mountPath: /root/
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc1
        readOnly: false
EOF
# 查看pod
kubectl get pod
~~~

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

<img src="https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/assets/2021.09.24-16:58:08-image-20200515002806726.png"  />

## 配置存储

### ConfigMap

> 参考文档：
>
> https://kubernetes.io/zh/docs/concepts/configuration/configmap/
>
> https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-pod-configmap/
>
> https://kubernetes.io/docs/concepts/configuration/secret/#creating-a-secret
>
> https://kubernetes.io/zh/docs/tasks/configmap-secret/managing-secret-using-kubectl/
>
> https://kubernetes.io/zh/docs/tasks/configmap-secret/managing-secret-using-config-file/
>
> https://kubernetes.io/zh/docs/tasks/configmap-secret/managing-secret-using-kustomize/

ConfigMap是一种比较特殊的存储卷，它的主要作用是用来存储配置信息的。

创建configmap.yaml，内容如下：

~~~yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap
  namespace: dev
data:
  info: |
    username:admin
    password:123456
~~~

#### 创建ConfigMap的几种形式

```bash
kubectl create configmap -h
从文件夹创建
kubectl create cm cmfromdir --from-file=conf/
从文件创建
kubectl create cm cmfromfile --from-file=conf/redis.conf 
从文件创建并改名
kubectl create cm cmspecialname --from-file=game-conf=game.conf
kubectl create cm cmspecialname2 --from-file=game-conf=game.conf  --from-file=redis-conf=redis.conf
从环境变量创建
kubectl create cm gameenvcm --from-env-file=game.conf
从命令行创建
kubectl  create cm envfromliteral --from-literal=level=INFO --from-literal=PASSWORD=redis123
```

#### 使用valueFrom定义环境变量

```bash
kubectl create deploy dp-cm \ 
--image=registry.cn-beijing.aliyuncs.com/dotbalo/nginx \
--dry-run=client -oyaml > dp-cm.yaml

```

```bash
env:
        - name: TEST_ENV
          value: testenv
        - name: LIVES
          valueFrom:
            configMapKeyRef:
              name: gameenvcm
              key: lives
```

#### 使用envFrom定义环境变量

```bash
containers:
      - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx 
        name: nginx
        envFrom:
        - configMapRef:
            name: gameenvcm
          prefix: fromCm_
        env:
        - name: TEST_ENV
          value: testenv
        - name: LIVES
          valueFrom:
            configMapKeyRef:
              name: gameenvcm
              key: lives
        #- name: test_env
        #  valueFrom:
        #    configMapKeyRef:
        #      name: gameenvcm
        #      key: test_env

```

> prefix: 可为变量添加开头
>
> ![image-20210914080813195](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ConfigMap&Secret/2021.09.14-08:11:26-image-20210914080813195.png)

#### 以文件的形式挂载ConfigMap

注意会覆盖挂载文件夹，可使用**subPath**参数规避

```BASH
 spec:
      containers:
        - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx 
          name: nginx
          volumeMounts:
            - name: redisconf
              mountPath: /etc/config
            - name: cmfromfile 
              mountPath: /etc/config2
      volumes:
        - name: redisconf
          configMap:
            name: redis-conf
        - name: cmfromfile
          configMap:
            name: cmfromfile

```

subPath参数:

![image-20210914085754530](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ConfigMap&Secret/2021.09.14-08:58:19-image-20210914085754530.png)

#### 自定义挂载权限及名称

```
volumes:
        - name: redisconf
          configMap:
            name: redis-conf
        - name: cmfromfile
          configMap:
            name: cmfromfile
            items:
              - key: redis.conf
                path: redis.conf.bak
              - key: redis.conf
                path: redis.conf.bak2
                mode: 0644 # 优先级高
            defaultMode: 0666  # 328 8进制与10进制

```

#### 实践

接下来，使用此配置文件创建configmap

~~~powershell
# 创建configmap
[root@master ~]# kubectl create -f configmap.yaml
configmap/configmap created

# 查看configmap详情
[root@master ~]# kubectl describe cm configmap -n dev
Name:         configmap
Namespace:    dev
Labels:       <none>
Annotations:  <none>

Data
====
info:
----
username:admin
password:123456

Events:  <none>
~~~

接下来创建一个pod-configmap.yaml，将上面创建的configmap挂载进去

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-configmap
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
    volumeMounts: # 将configmap挂载到目录
    - name: config
      mountPath: /configmap/config
  volumes: # 引用configmap
  - name: config
    configMap:
      name: configmap
~~~

~~~powershell
# 创建pod
[root@master ~]# kubectl create -f pod-configmap.yaml
pod/pod-configmap created

# 查看pod
[root@master ~]# kubectl get pod pod-configmap -n dev
NAME            READY   STATUS    RESTARTS   AGE
pod-configmap   1/1     Running   0          6s

#进入容器
[root@master ~]# kubectl exec -it pod-configmap -n dev /bin/sh
# cd /configmap/config/
# ls
info
# more info
username:admin
password:123456

# 可以看到映射已经成功，每个configmap都映射成了一个目录
# key--->文件     value---->文件中的内容
# 此时如果更新configmap的内容, 容器中的值也会动态更新
~~~

### Secret

​    在kubernetes中，还存在一种和ConfigMap非常类似的对象，称为Secret对象。它主要用于存储敏感信息，例如密码、秘钥、证书等等。

#### Secret常用类型

Secret：[https://kubernetes.io/docs/concepts/configuration/secret/#creating-a-secret](https://kubernetes.io/docs/concepts/configuration/secret/)

>Opaque：通用型Secret，默认类型；
>
>kubernetes.io/service-account-token：作用于ServiceAccount，包含一个令牌，用于标识API服务账户；
>
>kubernetes.io/dockerconfigjson：下载私有仓库镜像使用的Secret，和宿主机的/root/.docker/config.json一致，宿主机登录后即可产生该文件；
>
>kubernetes.io/basic-auth：用于使用基本认证（账号密码）的Secret，可以使用Opaque取代；
>
>kubernetes.io/ssh-auth：用于存储ssh密钥的Secret；
>
>kubernetes.io/tls：用于存储HTTPS域名证书文件的Secret，可以被Ingress使用；
>
>bootstrap.kubernetes.io/token：一种简单的 bearer token，用于创建新集群或将新节点添加到现有集群，在集群安装时可用于自动颁发集群的证书。

需要base64加密后的数据才可创建Secret，若不想这么麻烦可以使用stringData直接在yaml中指定明文，系统会自动调用base64加密

![image-20210914083235027](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ConfigMap&Secret/2021.09.14-08:33:16-image-20210914083235027.png)



通过命令行创建Secert推荐单引号，双引号遇到特殊字符时需要转义才可以

![image-20210914083358501](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ConfigMap&Secret/2021.09.14-08:34:01-image-20210914083358501.png)

#### 使用Secret拉取私有仓库镜像

```
kubectl create secret docker-registry myregistrykey \
--docker-server=DOCKER_REGISTRY_SERVER \
--docker-username=DOCKER_USER \
--docker-password=DOCKER_PASSWORD \
--docker-email=DOCKER_EMAIL
```

> docker-registry：指定Secret的类型
> myregistrykey： Secret名称
> DOCKER_REGISTRY_SERVER：镜像仓库地址
> DOCKER_USER：镜像仓库用户名，需要有拉取镜像的权限
> DOCKER_PASSWORD：镜像仓库密码
> DOCKER_EMAIL：邮箱信息，可以为空

```
 spec:
      imagePullSecrets:
      - name: myregistry
      containers:
```

#### 使用Secret管理HTTPS证书

创建证书

```
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=test.com"
```

创建secret tls

```
kubectl -n default create secret tls nginx-test-tls --key=tls.key --cert=tls.crt
```

ingress调用证书

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: nginx-https-test
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: https-test.com
    http:
      paths:
      - backend:
          serviceName: nginx-svc
          servicePort: 80
  tls:
   - secretName: nginx-test-tls
```

#### 实践

1)  首先使用base64对数据进行编码

~~~yaml
[root@master ~]# echo -n 'admin' | base64 #准备username
YWRtaW4=
[root@master ~]# echo -n '123456' | base64 #准备password
MTIzNDU2
~~~

2)  接下来编写secret.yaml，并创建Secret

~~~yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret
  namespace: dev
type: Opaque
data:
  username: YWRtaW4=
  password: MTIzNDU2
~~~

~~~powershell
# 创建secret
[root@master ~]# kubectl create -f secret.yaml
secret/secret created

# 查看secret详情
[root@master ~]# kubectl describe secret secret -n dev
Name:         secret
Namespace:    dev
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
password:  6 bytes
username:  5 bytes
~~~

3) 创建pod-secret.yaml，将上面创建的secret挂载进去：

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.17.1
    volumeMounts: # 将secret挂载到目录
    - name: config
      mountPath: /secret/config
  volumes:
  - name: config
    secret:
      secretName: secret
~~~

~~~powershell
# 创建pod
[root@master ~]# kubectl create -f pod-secret.yaml
pod/pod-secret created

# 查看pod
[root@master ~]# kubectl get pod pod-secret -n dev
NAME            READY   STATUS    RESTARTS   AGE
pod-secret      1/1     Running   0          2m28s

# 进入容器，查看secret信息，发现已经自动解码了
[root@master ~]# kubectl exec -it pod-secret /bin/sh -n dev
/ # ls /secret/config/
password  username
/ # more /secret/config/username
admin
/ # more /secret/config/password
123456
~~~

至此，已经实现了利用secret实现了信息的编码。

### ConfigMap&Secret热更新（基于文件）+挂载覆盖

```
kubectl create cm nginx-conf --from-file=nginx.conf --dry-run=client -oyaml | kubectl replace -f -
```

### ConfigMap&Secret使用限制

> 提前场景ConfigMap和Secret
>
> 引用Key必须存在
>
> envFrom、valueFrom无法热更新环境变量
>
> envFrom配置环境变量，如果key是无效的，它会忽略掉无效的key
>
> ConfigMap和Secret必须要和Pod或者是引用它资源在同一个命名空间
>
> subPath也是无法热更新的
>
> ConfigMap和Secret最好不要太大

你可以添加**immutable:true** 设置为不可变的，来禁止通过kubectl edit修改此资源

![image-20210914090150248](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ConfigMap&Secret/2021.09.14-09:01:52-image-20210914090150248.png)
