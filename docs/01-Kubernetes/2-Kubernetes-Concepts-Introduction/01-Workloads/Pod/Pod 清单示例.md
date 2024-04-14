---
title: Pod 清单示例
tags: [Kubernetes]
sidebar_position: 1
---

## 资源属性

```yaml
# TypeMeta
- apiVersion          # 版本，由kubernetes内部定义，版本号必须可以用 kubectl api-versions 查询到
- kind                # 类型，由kubernetes内部定义，版本号必须可以用 kubectl api-resources 查询到
# ObjectMeta
- metadata            # 元数据，主要是资源标识和说明，常用的有name、namespace、labels等
# SpecMeta
- spec                # 描述，这是配置中最重要的一部分，里面是对各种资源配置的详细描述        
# StatusMeta
- status              # 状态信息，里面的内容不需要定义，由kubernetes自动生成
```

在上面的属性中，spec是接下来研究的重点，继续看下它的常见子属性:

```yaml
- containers            # 容器列表，用于定义容器的详细信息 
- nodeName              # 根据nodeName的值将pod调度到指定的Node节点上
- nodeSelector          # 根据NodeSelector中定义的信息选择将该Pod调度到包含这些label的Node 上
- hostNetwork           # 是否使用主机网络模式，默认为false，如果设置为true，表示使用宿主机网络
- volumes               # 存储卷，用于定义Pod上面挂在的存储信息 
- restartPolicy	        # 重启策略，表示Pod在遇到故障的时候的处理策略
```
## Pod 资源清单示例

```yaml
apiVersion: v1     #必选，版本号，例如v1
kind: Pod       　 #必选，资源类型，例如 Pod

metadata:       　 #必选，元数据
  name: string     #必选，符合RFC 1035规范的Pod名称
  namespace: default # 可选，Pod所在的命名空间，不指定默认为default，可以使用-n 指定
  labels:             # 可选，标签选择器，一般用于过滤和区分Pod，可以写多个 
    app: nginx
    role: frontend 
  annotations:  # 可选，注释列表，可以写多个
    app: nginx
    
spec:  #必选，Pod中容器的详细定义
  initContainers: # 可选初始化容器，在容器启动之前执行的一些初始化操作
  - name: init-container
    image: busybox
    imagePullPolicy: IfNotPresent
    command: 
    - sh
    - -c
    - echo "I am InitContainer for init some configuration"

  containers:  #必选，Pod中容器列表
  - name: nginx   #必选，容器名称
    image: nginx:latest  #必选，符合RFC 1035规范的容器名称
    imagePullPolicy: [ Always|Never|IfNotPresent ]  #获取镜像的策略
    terminationGracePeriodSeconds: 30 #容器终止宽限期 单位秒
    workingDir: string      # 可选，容器的工作目录
    command: ['sh', '-c', 'nginx -g "daemon off;"']   #容器的启动命令列表，如不指定，使用打包时使用的启动命令
    args: [string]      #可选，容器的启动命令参数列表
    
    volumeMounts:       #可选，挂载到容器内部的存储卷配置，可以配置多个
    - name: string      #引用pod定义的共享存储卷的名称，需用volumes[]部分定义的的卷名
      mountPath: string #存储卷在容器内mount的绝对路径，应少于512字符
      readOnly: boolean #是否为只读模式 true|flase
      
    ports: #可选，容器需要暴露的端口号列表
    - name: string        #端口的名称
      containerPort: int  #容器需要监听的端口号
      hostPort: int       #容器所在主机需要监听的端口号，默认与Container相同
      protocol: string    #端口协议，支持TCP和UDP，默认TCP
      
    env:   #可选，容器运行前需设置的环境变量列表
    - name: TZ      # 变量名
      value: Asia/Shanghai # 变量的值
    - name: LANG
      value: en_US.utf8
      
    resources: #资源限制和请求的设置
      limits:  #最大资可使用源限制
        cpu: string     #Cpu的限制，单位为core数，将用于docker run --cpu-shares参数，1000m为1cpu
        memory: string  #内存限制，单位可以为Mib/Gib，将用于docker run --memory参数
      requests: #启动所需资源
        cpu: string    #Cpu请求，容器启动的初始可用数量
        memory: string #内存请求,容器启动的初始可用数量
	
    startupProbe: # 可选，检测容器内进程是否完成启动，只在启动时检查一次。注意[exec|httpGet|tcpSocket]三种检查方式同时只能使用一种。
      httpGet:      # httpGet检测方式，生产环境建议使用httpGet实现接口级健康检查，健康检查由应用程序提供。
        path: /api/successStart # 检查路径
        port: 80
		
    livenessProbe:  #可选，健康检查，当探测无响应几次后将自动重启该容器,注意[exec|httpGet|tcpSocket]三种检查方式同时只能使用一种。
      exec:       　 #对Pod容器内检查方式设置为exec方式,
        command: [string]  #exec方式需要制定的命令或脚本，可用切片形式[- string]需和command对齐。
        
      # httpGet:       #容器健康检查方法设置为HttpGet，需要制定Path、port
      #   path: string # 检查路径
      #   port: number
      #   host: string
      #   scheme: string
      #   HttpHeaders: # 检查的请求头
      #   - name: string
      #     value: string
          
      # tcpSocket:     #对Pod内个容器健康检查方式设置为tcpSocket方式
      #    port: number
         
       initialDelaySeconds: 60     #容器启动完成后首次探测的时间，单位为秒
       timeoutSeconds: 2            #对容器健康检查探测等待响应的超时时间，单位秒，默认1秒
       periodSeconds: 5             #对容器监控检查的定期探测时间设置，单位秒，默认10秒一次
       successThreshold: 1         # 检查成功为2次表示就绪
       failureThreshold: 1         # 检测失败1次表示未就绪 默认是连续3次

      readinessProbe: # 可选，健康检查，成功后容器可接受流量。注意[exec|httpGet|tcpSocket]三种检查方式同时只能使用一种。
      httpGet:      # httpGet检测方式，生产环境建议使用httpGet实现接口级健康检查，健康检查由应用程序提供。
            path: / # 检查路径
            port: 80        # 监控端口       
                
    lifecycle: #生命周期健康钩子
      postStart: #容器启动后立即执行此钩子,可以是exec httpGet TCPSocket。如果执行失败,会根据重启策略进行重启
        exec:
          command:
          - sh
          - -c
          - 'mkdir /data/ '
      preStop: #容器终止前执行此钩子，可以是exec httpGet TCPSocket。如果容器超过terminationGracePeriodSeconds容器终止宽限期后仍在运行，则会发送SIGKILL信号并强制删除。
        exec:
          command:
          - sh
          - -c
          - sleep 9
      
#------------------------------------------------------------------------------------------------------#
  restartPolicy: [Always | Never | OnFailure]  #可选，Pod的重启策略，默认为Always
#------------------------------------------------------------------------------------------------------#
  nodeName: <string #可选，设置NodeName表示将该Pod调度到指定到名称的node节点上
  nodeSelector: obeject #可选，设置NodeSelector表示将该Pod调度到包含这个label的node上
    region:BeiJing
#------------------------------------------------------------------------------------------------------# 
  imagePullSecrets: #Pull镜像时使用的secret名称，以key：secretkey格式指定,可以配置多个
  - name: string
#------------------------------------------------------------------------------------------------------#
  hostNetwork: false   #是否使用主机网络模式，默认为false，如果设置为true，表示使用宿主机网络
#------------------------------------------------------------------------------------------------------#
  volumes:   #可选，在该pod上定义共享存储卷列表,可以配置多个
  - name: string    #共享存储卷名称 （volumes类型有很多种）
    emptyDir: {}       #类型为emtyDir的存储卷，与Pod同生命周期的一个临时目录。为空值

    hostPath: string   #类型为hostPath的存储卷，表示挂载Pod所在宿主机的目录
      path: string                  #Pod所在宿主机的目录，将被用于同期中mount的目录
      type: Directory      #hostPath类型的存储卷时，也可以设置type字段，支持的类型有文件、目录、File、Socket、CharDevice和BlockDevice。    
  
    secret:           　#类型为secret的存储卷，挂载集群与定义的secret对象到容器内部
      scretname: string  
      items:     
      - key: string
        path: string
  
    configMap:         #类型为configMap的存储卷，挂载预定义的configMap对象到容器内部
      name: string
      items:
      - key: string
        path: string        
```

