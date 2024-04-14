---
sidebar_position: 5
---
## Job

Job，主要用于负责**批量处理(一次要处理指定数量任务)**短暂的**一次性(每个任务仅运行一次就结束)**任务。Job特点如下：

- 当Job创建的pod执行成功结束时，Job将记录成功结束的pod数量
- 当成功结束的pod达到指定的数量时，Job将完成执行

## Job的资源清单文件：

```yaml
apiVersion: batch/v1 # 版本号
kind: Job # 类型       
metadata: # 元数据
  name: # rs名称 
  namespace: # 所属命名空间 
  labels: #标签
    controller: job
spec: # 详情描述
  completions: 1 # 指定job需要成功运行Pods的次数。默认值: 1
  parallelism: 1 # 指定job在任一时刻应该并发运行Pods的数量。默认值: 1
  activeDeadlineSeconds: 30 # 指定job可运行的时间期限，超过时间还未结束，系统将会尝试进行终止。
  backoffLimit: 6 # 指定job失败后进行重试的次数。默认是6
  manualSelector: true # 是否可以使用selector选择器选择pod，默认是false
  selector: # 选择器，通过它指定该控制器管理哪些pod
    matchLabels:      # Labels匹配规则
      app: counter-pod
    matchExpressions: # Expressions匹配规则
      - {key: app, operator: In, values: [counter-pod]}
  template: # 模板，当副本数量不足时，会根据下面的模板创建pod副本
    metadata:
      labels:
        app: counter-pod
    spec:
      restartPolicy: Never # 重启策略只能设置为Never或者OnFailure
      containers:
      - name: counter
        image: busybox:1.30
        command: ["bin/sh","-c","for i in 9 8 7 6 5 4 3 2 1; do echo $i;sleep 2;done"]
```

关于重启策略设置的说明：
- 如果指定为OnFailure，则job会在pod出现故障时重启容器，而不是创建pod，failed次数不变
- 如果指定为Never，则job会在pod出现故障时创建新的pod，并且故障pod不会消失，也不会重启，failed次数加1
- 如果指定为Always的话，就意味着一直重启，意味着job任务会重复去执行了，当然不对，所以不能设置为Always

## backoff 失败策略

[故障处理](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

设置 .spec.backoffLimit 以指定在将作业视为失败之前的重试次数，默认设置为 6。

注意：如果您的作业有 restartPolicy = "OnFailure" ，请记住，一旦达到作业 backoff 限制，运行作业的 Pod 将被终止。这会使调试作业的可执行文件变得更加困难。我们建议在调试作业或使用日志系统时设置 restartPolicy = "Never" ，以确保失败作业的输出不会无意中丢失。
## CronJob

CronJob控制器以Job控制器资源为其管控对象，并借助它管理pod资源对象，Job控制器定义的作业任务在其控制器资源创建之后便会立即执行，但CronJob可以以类似于Linux操作系统的周期性任务作业计划的方式控制其运行**时间点**及**重复运行**的方式。也就是说，**CronJob可以在特定的时间点(反复的)去运行job任务**。

CronJob的资源清单文件：

```yaml
apiVersion: batch/v1beta1 # 版本号
kind: CronJob # 类型       
metadata: # 元数据
  name: # rs名称 
  namespace: # 所属命名空间 
  labels: #标签
    controller: cronjob
spec: # 详情描述
  supend: true #1.21+
  ttlSecondsAfterFinished: 100 #job执行结束后（状态为commpleted或Failed）会自动清理。设置为0表示结束立即删除，不设置不会清除，需开启ttlFinished特性
  schedule: # cron格式的作业调度运行时间点,用于控制任务在什么时间执行
  concurrencyPolicy: # 并发执行策略，用于定义前一次作业运行尚未完成时是否以及如何运行后一次的作业
  failedJobHistoryLimit: # 为失败的任务执行保留的历史记录数，默认为1
  successfulJobHistoryLimit: # 为成功的任务执行保留的历史记录数，默认为3
  startingDeadlineSeconds: # 启动作业错误的超时时长
  jobTemplate: # job控制器模板，用于为cronjob控制器生成job对象;下面其实就是job的定义
    metadata:
    spec:
      completions: 1 #有多少个任务执行成功，认为是成功的
      parallelism: 1 #并行任务数量，如果大于未完成任务数，则只会创建未完成的数量，completions是4并发是3，第二次只会创建1个
      activeDeadlineSeconds: 30
      backoffLimit: 6 #如果任务执行失败，失败多少次后不再执行
      manualSelector: true
      selector:
        matchLabels:
          app: counter-pod
        matchExpressions: 规则
          - {key: app, operator: In, values: [counter-pod]}
      template:
        metadata:
          labels:
            app: counter-pod
        spec:
          restartPolicy: Never 
          containers:
          - name: counter
            image: busybox:1.30
            command: ["bin/sh","-c","for i in 9 8 7 6 5 4 3 2 1; do echo $i;sleep 20;done"]
```

```bash title="schedule: cron表达式"
	*/1    *      *    *     *  
	<分钟> <小时> <日> <月份> <星期>  

# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │                                   OR sun, mon, tue, wed, thu, fri, sat
# │ │ │ │ │ 
# │ │ │ │ │
# * * * * *
```
多个时间可以用逗号隔开； 范围可以用连字符给出；*可以作为通配符； /表示每隔...
```yaml
concurrencyPolicy:
	Allow:   # 允许Jobs并发运行(默认)
	Forbid:  # 禁止并发运行，如果上一次运行尚未完成，则跳过下一次运行
	Replace: # 替换，取消当前正在运行的作业并用新作业替换它
```
创建pc-cronjob.yaml，内容如下：

```yaml
apiVersion: batch/v1beta1 #1.21+ batch/v1
kind: CronJob
metadata:
  name: pc-cronjob
  namespace: dev
  labels:
    controller: cronjob
spec:
  schedule: "*/1 * * * *"
  successfulJobsHistoryLimit: 3 #保留多少已完成的任务，按需配置。
  failedJobsHistoryLimit: 1     #保留多少失败的任务。
  suspend: false                #如果设置为true，则暂停后续的任务，默认为false。
  concurrencyPolicy: Allow
                            #concurrencyPolicy：并发调度策略。可选参数如下：
                            #Allow：允许同时运行多个任务。
                            #Forbid：不允许并发运行，如果之前的任务尚未完成，新的任务不会被创建。
                            #Replace：如果之前的任务尚未完成，新的任务会替换的之前的任务。
  jobTemplate:
    metadata:
    spec:
      template:
        spec:
          restartPolicy: Never #重启策略 OnFailure 。。。
          securityContext: {}
          containers:
          - name: counter
            image: busybox:1.30
            command: ["bin/sh","-c","for i in 9 8 7 6 5 4 3 2 1; do echo $i;sleep 3;done"]
            resources: {}
```




## 自动清理

当您的作业完成后，将该作业保留在 API 中（而不是立即删除该作业）非常有用，以便您可以判断该作业是成功还是失败。

Kubernetes 的 TTL-after-finished 控制器提供了 TTL（生存时间）机制来限制已执行完毕的 Job 对象的生命周期。

仅作业支持 TTL-after-finished 控制器。您可以使用此机制通过指定作业的 .spec.ttlSecondsAfterFinished 字段来自动清理已完成的作业（ Complete 或 Failed ）。


例如，如果您有一个作业完成后希望其保留一小时以供审查其日志或输出的情况，您可以设置 .spec.ttlSecondsAfterFinished 字段为 3600（即一小时的秒数）。这意味着，一旦作业状态标记为 Complete 或 Failed，Kubernetes 的 TTL-after-finished 控制器将在一小时后启动清理该作业的程序。如果您的集群中存在时间偏差，控制器可能会提前或延后于预期时间执行清理操作。

以下是如何在作业定义中设置 .spec.ttlSecondsAfterFinished 字段的示例：
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: example-job
spec:
  template:
    spec:
      containers:
      - name: example
        image: busybox
        command: ["sh", "-c", "echo Hello Kubernetes! && sleep 60"]
      restartPolicy: Never
  ttlSecondsAfterFinished: 3600
```