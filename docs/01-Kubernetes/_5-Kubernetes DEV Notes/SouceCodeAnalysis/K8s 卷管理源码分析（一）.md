![1685789471646](image/K8s卷管理源码分析（一）/1685789471646.png)

各组件功能：

-   Volume Plugins
    -   存储提供的扩展接口, 包含了各类存储提供者的plugin实现。
    -   实现自定义的Plugins 可以通过FlexVolume(K8s 1.8版本，目前算是过度方案)
    -   容器存储接口 CSI（Container Storage Interface，k8s1.9 实现了alpha 版本）。
    -   支持这套标准以后，K8S和存储提供者之间将彻底解耦，这一功能让新的卷插件的安装像部署Pod 一样简单，第三方存储开发的代码也不需要加入核心的Kubernetes代码中。
-   Volume Manager
    -   运行在kubelet 里让存储Ready的部件，主要是mount/unmount（attach/detach可选）
    -   pod调度到这个node上后才会有卷的相应操作，所以它的触发端是kubelet（严格讲是kubelet里的pod manager），根据Pod Manager里pod spec里申明的存储来触发卷的挂载操作
    -   Kubelet会监听到调度到该节点上的pod声明，会把pod缓存到Pod Manager中，VolumeManager通过Pod Manager获取PV/PVC的状态，并进行分析出具体的attach/detach、mount/umount, 操作然后调用plugin进行相应的业务处理
-   PV/PVC Controller
    -   运行在Master上的部件，主要做provision/delete
    -   PV Controller和K8S其它组件一样监听API Server中的资源更新，对于卷管理主要是监听PV，PVC， SC三类资源，当监听到这些资源的创建、删除、修改时，PV Controller经过判断是需要做创建、删除、绑定、回收等动作。
-   Attach/Detach Controller
    -   运行在Master上，主要做一些块设备（block device）的attach/detach（eg:rbd,cinder块设备需要在mount之前先attach 到主机上）
    -   非必须controller: 为了在attach卷上支持plugin headless形态，Controller Manager提供配置可以禁用。
    -   _它的核心职责就是当API Server中，有卷声明的pod与node间的关系发生变化时，需要决定是通过调用存储插件将这个pod关联的卷attach到对应node的主机（或者虚拟机）上，还是将卷从node上detach掉. 操作完成后，通知其它关联组件（这里主要是kubelet）做相应的业务操作_

卷的完整挂载流程如下：

-   用户创建Pod包含一个PVC
-   Pod被分配到节点NodeA
-   Kubelet等待Volume Manager准备设备
-   PV controller调用相应Volume Plugin(in-tree或者out-of-tree)创建持久化卷并在系统中创建 PV对象以及其与PVC的绑定(Provision)
-   Attach/Detach controller或者Volume Manager通过Volume Plugin实现块设备挂载(Attach)
    -   Volume Manager等待设备挂载完成，将卷挂载到节点指定目录(mount)
    -   /var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/vol-xxxxxxxxxxxxxxxxx
    -   Kubelet在被告知设备准备好后启动Pod中的容器，利用Docker –v等参数将已经挂载到本地 的卷映射到容器中(volume mapping)
    -   

存储的提供者大致分为这么几类：

1.  持久化存储 1.1. 公有云存储 — google， aws， azure， cinder 1.2. 协议类存储 — iSCSI， NFS， FC … 1.3. 系统类存储 — vSphere, ScaleIO, Ceph ….
2.  临时存储 2.1. empty dir 2.2. 向下接口类存储 — configmap, downwardAPI, secret
3.  其它 3.1. 主机存储 — host path, local storage 3.2. flex存储 — flex volume

Attach/detach/ controller manager 流程 [http://www.voidcn.com/article/p-kexnnnjb-bqo.html](https://web.archive.org/web/20201031121347/http://www.voidcn.com/article/p-kexnnnjb-bqo.html)

1.  初始化attach/detach controller

卷管理任务由kube-controller 服务组件负责。在kube-controller 服务启动时，对attach/detach 管理器初始化。具体初始化过程代码调用关系如下：

首先，在kube-controller-manager.go 中，通过main() 函数启动kube-controller 服务组件，main() 函数代码如下：

kubernetes/cmd/kube-controller-manager/controller-manager.go

```go
   func main(){
      s := options.NewCMServer()
      s.AddFlags(pflag.CommandLine, app.KnownControllers(),       
                                                   app.ControllersDisabledByDefault.List())
    
      flag.InitFlags()
      logs.InitLogs()
      defer logs.FlushLogs()
      verflag.PrintAndExitIfRequested()
      if err := app.Run(s); err != nil {
       fmt.Fprintf(os.Stderr, "%v\n", err)
       os.Exit(1)
      }
    }
```

```go
main() 函数中，主要的实现都在app.Run()方法中。以下是Run() 方法的实现
```



cmd/kube-controller-manager/app/controllermanager.go

```go
   func Run(s *options.CMServer) error {
       ...
    run := func(stop <-chan struct{}) {
        rootClientBuilder := controller.SimpleControllerClientBuilder{
            ClientConfig: kubeconfig,
        }
       ...
            clientBuilder = controller.SAControllerClientBuilder{
                ClientConfig:         restclient.AnonymousClientConfig(kubeconfig),
                CoreClient:           kubeClient.CoreV1(),
                AuthenticationClient: kubeClient.Authentication(),
                Namespace:            "kube-system",
            }
        } 
        ...
        ctx, err := CreateControllerContext(s, rootClientBuilder, clientBuilder, stop)
        if err != nil {
            glog.Fatalf("error building controller context: %v", err)
        }
        saTokenControllerInitFunc := serviceAccountTokenControllerStarter{rootClientBuilder: rootClientBuilder}.startServiceAccountTokenController

        if err := StartControllers(ctx, saTokenControllerInitFunc, NewControllerInitializers()); err != nil {
            glog.Fatalf("error starting controllers: %v", err)
        }

    ...
    }

     ...
   }
```

在Run() 方法中，通过调用StartControllers() 方法，实现了对卷管理及其他管理服务的初始化。在StartControllers()方法的参数中，controllers 参数实际接收的是NewControllerInitializers()方法的返回值， 该返回值为一个key-value 结构，返回值的 每个元素的value是初始化方法start\* ，其中关于卷管理控制器的初始化方法为startAttachDetachController()。

此外，在Run方法中，生成了ctx 变量



NewControllerInitializers() 的代码实现如下：



cmd/kube-controller-manager/app/controllermanager.go

```go
   func NewControllerInitializers() map[string]InitFunc {
    controllers := map[string]InitFunc{}
    controllers["endpoint"] = startEndpointController
    controllers["replicationcontroller"] = startReplicationController
    controllers["podgc"] = startPodGCController
    controllers["resourcequota"] = startResourceQuotaController
    controllers["namespace"] = startNamespaceController
    controllers["serviceaccount"] = startServiceAccountController
    controllers["garbagecollector"] = startGarbageCollectorController
    controllers["daemonset"] = startDaemonSetController
    controllers["job"] = startJobController
    controllers["deployment"] = startDeploymentController
    controllers["replicaset"] = startReplicaSetController
    controllers["horizontalpodautoscaling"] = startHPAController
    controllers["disruption"] = startDisruptionController
    controllers["statefulset"] = startStatefulSetController
    controllers["cronjob"] = startCronJobController
    controllers["csrsigning"] = startCSRSigningController
    controllers["csrapproving"] = startCSRApprovingController
    controllers["csrcleaner"] = startCSRCleanerController
    controllers["ttl"] = startTTLController
    controllers["bootstrapsigner"] = startBootstrapSignerController
    controllers["tokencleaner"] = startTokenCleanerController
    controllers["service"] = startServiceController
    controllers["node"] = startNodeController
    controllers["route"] = startRouteController
    controllers["persistentvolume-binder"] = startPersistentVolumeBinderController
    controllers["attachdetach"] = startAttachDetachController
    controllers["persistentvolume-expander"] = startVolumeExpandController

    return controllers
   }
```

再次返回到StartControllers()方法中，StartControllers() 代码的实现如下： 

cmd/kube-controller-manager/app/controllermanager.go

```
   func StartControllers(ctx ControllerContext, startSATokenController InitFunc, controllers map[string]InitFunc) error {
    ...
    if _, err := startSATokenController(ctx); err != nil {
        return err
    }

       ...
    if ctx.Cloud != nil {
        ctx.Cloud.Initialize(ctx.ClientBuilder)
    }

       ...
    for controllerName, initFn := range controllers {
       /* 是否需要初始化该controller */
        if !ctx.IsControllerEnabled(controllerName) {
            glog.Warningf("%q is disabled", controllerName)
            continue
        }

        time.Sleep(wait.Jitter(ctx.Options.ControllerStartInterval.Duration, ControllerStartJitter))
          started, err := initFn(ctx)  // 调用各个controller 的初始化方法start* 
         ...
    }

    return nil
   }
```

上面提到controllers 为一个key-value结构的变量， 在 StartControllers() 方法中，`range controllers`遍历controllers 中的每一个元素，initFn 为元素的value 值，实际上为一个初始化方法。 本文主要分析卷管理的实现，以下是卷管理controller 的初始化方法startAttachDetachController()，



cmd/kube-controller-manager/app/core.go

```go
   func startAttachDetachController(ctx ControllerContext) (bool, error) {
    if ctx.Options.ReconcilerSyncLoopPeriod.Duration < time.Second {
        return true, fmt.Errorf("Duration time must be greater than one second as set via command line option reconcile-sync-loop-period.")
    }
    attachDetachController, attachDetachControllerErr :=
        attachdetach.func startAttachDetachController(ctx ControllerContext) (bool, error) {
    if ctx.Options.ReconcilerSyncLoopPeriod.Duration < time.Second {
        return true, fmt.Errorf("Duration time must be greater than one second as set via command line option reconcile-sync-loop-period.")
    }
    attachDetachController, attachDetachControllerErr :=
        attachdetach.NewAttachDetachController(
            ctx.ClientBuilder.ClientOrDie("attachdetach-controller"),
            ctx.InformerFactory.Core().V1().Pods(),
            ctx.InformerFactory.Core().V1().Nodes(),
            ctx.InformerFactory.Core().V1().PersistentVolumeClaims(),
            ctx.InformerFactory.Core().V1().PersistentVolumes(),
            ctx.Cloud, //返回provider
            /* 返回一个存储插件的列表，每个存储后端均实现了VolumePlugin 接口*/
            ProbeAttachableVolumePlugins(),
            GetDynamicPluginProber(ctx.Options.VolumeConfiguration),
            ctx.Options.DisableAttachDetachReconcilerSync,
            ctx.Options.ReconcilerSyncLoopPeriod.Duration,
            attachdetach.DefaultTimerConfig,
        )
    if attachDetachControllerErr != nil {
        return true, fmt.Errorf("failed to start attach/detach controller: %v", attachDetachControllerErr)
    }
     /*存储控制器的所有卷插件管理器初始化完成后，便开始循环检查请求*/
    go attachDetachController.Run(ctx.Stop)  
    return true, nil
   }
```

在上面的方法中，调用了NewAttachDetachController() , 生成卷管理控制器`attachDetachController` , 该返回值是一个 attachDetachController 结构体引用。在NewAttachDetachController() 的参数传递中,调用了 ProbeAttachableVolumePlugins()方法，该方法的的返回值传递给plugins 参数。

`ProbeAttachableVolumePlugins()` 函数的实现如下：

```go
   func ProbeAttachableVolumePlugins() []volume.VolumePlugin {
    allPlugins := []volume.VolumePlugin{}

    allPlugins = append(allPlugins, aws_ebs.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, gce_pd.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, cinder.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, portworx.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, vsphere_volume.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, azure_dd.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, photon_pd.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, scaleio.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, storageos.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, fc.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, iscsi.ProbeVolumePlugins()...)
    allPlugins = append(allPlugins, rbd.ProbeVolumePlugins()...)
    return allPlugins
   }
```

可以看出，在 ProbeAttachableVolumePlugins() 方法中，通过调用ProbeVolumePlugins() 方法，返回k8s 支持的持久化存储插件列表，存储插件包括了aws, cinder, vsphere等。本文先主要关注cinder 存储插件。**查看cinder包下的ProbeVolumePlugins()，发现该方法返回的是一个初始化的cinderPlugin 结构体**，初始化内容为空值。该结构体实现了接口VolumePlugin 声明的方法，VolumePlugin 接口声明如下：



pkg/volume/plugins.go

```go
   type VolumePlugin interface {
    Init(host VolumeHost) error
    GetPluginName() string
    GetVolumeName(spec *Spec) (string, error)
    CanSupport(spec *Spec) bool
    RequiresRemount() bool
    NewMounter(spec *Spec, podRef *v1.Pod, opts VolumeOptions) (Mounter, error)
    NewUnmounter(name string, podUID types.UID) (Unmounter, error)
    ConstructVolumeSpec(volumeName, mountPath string) (*Spec, error)
    SupportsMountOption() bool
    SupportsBulkVolumeVerification() bool
   }
```



下面主要沿着ProbeAttachableVolumePlugins()方法的返回值的传递，了解一下在 k8s 中cinder卷管理控制器的初始化，以及卷管理的实现。上文提到，ProbeAttachableVolumePlugins()方法的返回值传入 NewAttachDetachController() 方法中，以下是 NewAttachDetachController() 方法的实现

pkg/controller/volume/attachdetach/attach\_detach\_controller.go

```go
   func NewAttachDetachController(
    kubeClient clientset.Interface,
    podInformer coreinformers.PodInformer,
    nodeInformer coreinformers.NodeInformer,
    pvcInformer coreinformers.PersistentVolumeClaimInformer,
    pvInformer coreinformers.PersistentVolumeInformer,
    cloud cloudprovider.Interface,
    plugins []volume.VolumePlugin,
    prober volume.DynamicPluginProber,
    disableReconciliationSync bool,
    reconcilerSyncDuration time.Duration,
    timerConfig TimerConfig) (AttachDetachController, error) {
    
    adc := &attachDetachController{
        kubeClient:  kubeClient,
        pvcLister:   pvcInformer.Lister(),
        pvcsSynced:  pvcInformer.Informer().HasSynced,
        pvLister:    pvInformer.Lister(),
        pvsSynced:   pvInformer.Informer().HasSynced,
        podLister:   podInformer.Lister(),
        podsSynced:  podInformer.Informer().HasSynced,
        nodeLister:  nodeInformer.Lister(),
        nodesSynced: nodeInformer.Informer().HasSynced,
        cloud:       cloud,
    }

    if err := adc.volumePluginMgr.InitPlugins(plugins, prober, adc); err != nil {
        return nil, fmt.Errorf("Could not initialize volume plugins for Attach/Detach Controller: %+v", err)
    }

    eventBroadcaster := record.NewBroadcaster()
    eventBroadcaster.StartLogging(glog.Infof)
    eventBroadcaster.StartRecordingToSink(&v1core.EventSinkImpl{Interface: v1core.New(kubeClient.CoreV1().RESTClient()).Events("")})
    recorder := eventBroadcaster.NewRecorder(scheme.Scheme, v1.EventSource{Component: "attachdetach-controller"})

    adc.desiredStateOfWorld = cache.NewDesiredStateOfWorld(&adc.volumePluginMgr)
    adc.actualStateOfWorld = cache.NewActualStateOfWorld(&adc.volumePluginMgr)
    adc.attacherDetacher =
        operationexecutor.NewOperationExecutor(operationexecutor.NewOperationGenerator(
            kubeClient,
            &adc.volumePluginMgr,
            recorder,
            false)) // flag for experimental binary check for volume mount
    adc.nodeStatusUpdater = statusupdater.NewNodeStatusUpdater(
        kubeClient, nodeInformer.Lister(), adc.actualStateOfWorld)

    // Default these to values in options
    adc.reconciler = reconciler.NewReconciler(
        timerConfig.ReconcilerLoopPeriod,
        timerConfig.ReconcilerMaxWaitForUnmountDuration,
        reconcilerSyncDuration,
        disableReconciliationSync,
        adc.desiredStateOfWorld,
        adc.actualStateOfWorld,
        adc.attacherDetacher,
        adc.nodeStatusUpdater,
        recorder)

    adc.desiredStateOfWorldPopulator = populator.NewDesiredStateOfWorldPopulator(
        timerConfig.DesiredStateOfWorldPopulatorLoopSleepPeriod,
        timerConfig.DesiredStateOfWorldPopulatorListPodsRetryDuration,
        podInformer.Lister(),
        adc.desiredStateOfWorld,
        &adc.volumePluginMgr,
        pvcInformer.Lister(),
        pvInformer.Lister())

    podInformer.Informer().AddEventHandler(kcache.ResourceEventHandlerFuncs{
        AddFunc:    adc.podAdd,
        UpdateFunc: adc.podUpdate,
        DeleteFunc: adc.podDelete,
    })

    nodeInformer.Informer().AddEventHandler(kcache.ResourceEventHandlerFuncs{
        AddFunc:    adc.nodeAdd,
        UpdateFunc: adc.nodeUpdate,
        DeleteFunc: adc.nodeDelete,
    })

    return adc, nil
   }
```

在 NewAttachDetachController() 方法中，变量adc 为初始化的结构体attachDetachController 的引用，结构体 attachDetachController 实际上实现了接口 VolumeHost(pkg/volume/plugin.go)，以下是VolumeHost 接口的声明：

```go
   type VolumeHost interface {
    GetPluginDir(pluginName string) string
    GetPodVolumeDir(podUID types.UID, pluginName string, volumeName string) string
    GetPodPluginDir(podUID types.UID, pluginName string) string
    GetKubeClient() clientset.Interface
    NewWrapperMounter(volName string, spec Spec, pod *v1.Pod, opts VolumeOptions) (Mounter, error)
    NewWrapperUnmounter(volName string, spec Spec, podUID types.UID) (Unmounter, error)
    GetCloudProvider() cloudprovider.Interface
    GetMounter(pluginName string) mount.Interface
    GetWriter() io.Writer
    GetHostName() string
    GetHostIP() (net.IP, error)
    GetNodeAllocatable() (v1.ResourceList, error)
    GetSecretFunc() func(namespace, name string) (*v1.Secret, error)
    GetConfigMapFunc() func(namespace, name string) (*v1.ConfigMap, error)
    GetExec(pluginName string) mount.Exec
    GetNodeLabels() (map[string]string, error)
   }
```



plugins 参数被传入InitPlugins() 方法。InitPlugins() 方法是结构体VolumePluginMgr 里实现的一个成员方法，以下是InitPlugins() 方法的实现。

pkg/volume/plugins.go

```go
   func (pm *VolumePluginMgr) InitPlugins(plugins []VolumePlugin, prober DynamicPluginProber, host VolumeHost) error {
    pm.mutex.Lock()
    defer pm.mutex.Unlock()

    pm.Host = host

    if prober == nil {
        // Use a dummy prober to prevent nil deference.
        pm.prober = &dummyPluginProber{}
    } else {
        pm.prober = prober
    }
    if err := pm.prober.Init(); err != nil {
        // Prober init failure should not affect the initialization of other plugins.
        glog.Errorf("Error initializing dynamic plugin prober: %s", err)
        pm.prober = &dummyPluginProber{}
    }

    if pm.plugins == nil {
        pm.plugins = map[string]VolumePlugin{}
    }

    allErrs := []error{}
    for _, plugin := range plugins {
        name := plugin.GetPluginName()
        if errs := validation.IsQualifiedName(name); len(errs) != 0 {
            allErrs = append(allErrs, fmt.Errorf("volume plugin has invalid name: %q: %s", name, strings.Join(errs, ";")))
            continue
        }

        if _, found := pm.plugins[name]; found {
            allErrs = append(allErrs, fmt.Errorf("volume plugin %q was registered more than once", name))
            continue
        }
        /*调用每个plugin 的初始化方法，在每个plugin 的New* 方法调用之前,需要调用每个plugin 的Init 
         方法对plugin进行初始化，例如cinderPlugin.Init() */
        err := plugin.Init(host) 
        if err != nil {
            glog.Errorf("Failed to load volume plugin %s, error: %s", name, err.Error())
            allErrs = append(allErrs, err)
            continue
        }
        pm.plugins[name] = plugin
        glog.V(1).Infof("Loaded volume plugin %q", name)
    }
    return utilerrors.NewAggregate(allErrs)
   }
```

在InitPlugins 方法的参数中，变量plugins 为ProbeAttachableVolumePlugins() 的返回值，为一个列表结构。变量s 来自startAttachDetachController() 方法中传入的参数GetDynamicPluginProber(ctx.Options.VolumeConfiguration)。变量host是 VolumeHost 接口类型，在这里运用了多态的特性（因为发现接口 VolumeHost 的方法在其他结构体也有实现，比如kubelet.kubeletVolumeHost)，传入的是结构体attachDetachController 的引用adc 。



`plugin` 实现了接口VolumePlugin，Init方法便是其中之一，进入cinderPlugin 的Init方法中，便是实现了对plugin 结构体属性的赋值。如下：

```go
   func (plugin *cinderPlugin) Init(host volume.VolumeHost) error {
    /*host实际为一个 attachDetachController 结构体变量adc，该变量在NewAttachDetachController()
      方法中初始化*/
    plugin.host = host  
    plugin.volumeLocks = keymutex.NewKeyMutex()
    return nil
   }
```

至此，本文分析了卷管理器 controllers\[“attachdetach”\] 的初始化(包括controller 和支持的卷插件\[\]VolumePlugin), 总结一下主要主要流程：

1.  得到所有controller 的start\* 方法，如卷管理相关的startAttachDetachController
2.  调用 StartControllers 方法，根据!ctx.IsControllerEnabled(controllerName) 决定是否初始化一个controller.
3.  步骤2 中如果调用 controller 的start\* 方法，初始化controller 。 如：startAttachDetachController
4.  在每一个controller 初始化方法里，完成实际的初始化方法。如卷管理中，调用NewAttachDetachController () 完成初始化每一个VolumePlugin 结构体。
5.  步骤4结束后，返回attachDetachController 结构体引用
6.  在 步骤2 中的start\* 方法，调用run 方法。
    
7.  挂载卷过程
    

cinderPlugin 实际上还是实现了AttachableVolumePlugin接口的函数，以下是AttachableVolumePlugin接口的方法声明, 该接口扩展了VolumePlugin，新添加声明了3个方法。

pkg/volume/plugins.go

```go
type AttachableVolumePlugin interface {
    VolumePlugin
    NewAttacher() (Attacher, error)
    NewDetacher() (Detacher, error)
    GetDeviceMountRefs(deviceMountPath string) ([]string, error)
}
```

以下是NewAttacher 在cinderPlugin 里的实现

pkg/volume/cinder/attacher.go

```go
func (plugin *cinderPlugin) NewAttacher() (volume.Attacher, error) {
   /*正确情况下，getCloudProvider 返回OpenStack 结构体，该结构体实现了两个接口定义的方法，两个接口定义
     及被实现的位置分别是：1. cloud.go 中的Interface 接口，在openstack.go 中实现；
                         2. cinder.go 中的CinderProvider 接口，在openstack_volume.go 中实现。
   */
     
   cinder, err := getCloudProvider(plugin.host.GetCloudProvider())
   
   ....
   return &cinderDiskAttacher{
          /*host实际为一个 attachDetachController 结构体变量adc，该变量在  
            NewAttachDetachController()方法中初始化*/ 
        host:           plugin.host, 
        cinderProvider: cinder,
    }, nil
```

syncStates

pkg/kubelet/volumemanager/cache/desired\_state\_of\_world.go

```go
func (dsw *desiredStateOfWorld) isAttachableVolume(volumeSpec *volume.Spec) bool {
    attachableVolumePlugin, _ :=
        dsw.volumePluginMgr.FindAttachablePluginBySpec(volumeSpec)
    if attachableVolumePlugin != nil {
        volumeAttacher, err := attachableVolumePlugin.NewAttacher()
        if err == nil && volumeAttacher != nil {
            return true
        }
    }
    return false
}
```

和NewDetacher

pkg/volume/cinder/attacher.go

```go
func (plugin *cinderPlugin) NewDetacher() (volume.Detacher, error) {
    cinder, err := getCloudProvider(plugin.host.GetCloudProvider())
    if err != nil {
        return nil, err
    }
    return &cinderDiskDetacher{
        mounter:        plugin.host.GetMounter(plugin.GetPluginName()),
        cinderProvider: cinder,
    }, nil
}
```