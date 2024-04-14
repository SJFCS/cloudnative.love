---
title: Operator 开发入门
---
本文只是我作为初学者入门记录学习 Operator 过程中的一些笔记。
<!-- truncate -->

## 什么是 Operator
Operator 是一种封装、部署和管理 kubernetes 应用的方法。

简单来说，Operator 是由 kubernetes 自定义资源（CRD, Custom Resource Definition）和控制器（Controller）构成的云原生扩展服务。Operator 把部署应用的过程或业务运行过程中需要频繁操作的命令封装起来，运维人员只需要关注应用的配置和应用的期望运行状态即可，无需花费大量的精力在部署和容易出错的命令上面。

## 工具选择
目前有俩热门框架可供选择 Operator SDK 和 Kubebuilder。

- Operator SDK v1.0版本开始，就采用了Kubebuilder的库和工具作为其底层实现，同时支持 helm 和 ansible 尽管功能有限。
- Kubebuilder 来自sgi 更贴近上游，同时项目案例也更多，本次开发过程采用 Kubebuilder 进行开发。
## 项目初始化
```bash
mkdir application-operator

cd application-operator

kubebuilder init --domain isekiro.com --owner isekiro --repo github.com/isekiro/ops-operator

$ go get sigs.k8s.io/controller-runtime@v0.10.0
$ go mod tidy
```

## 创建 API：
我们还没有创建 API ，这里生产的都是一些 rbac 元数据相关和控制器相关的 yaml 。


创建 API 相关配置和字段。
```bash
kubebuilder create api --group batch --version v1 --kind MysqlBackup
```
## CRD 实现
看看实现 CRD 的代码，在 api/v1/application_types.go 这个目录下，有相关的结构体。

```go
// ApplicationSpec defines the desired state of Application
type ApplicationSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// Foo is an example field of Application. Edit application_types.go to remove/update
	Foo string `json:"foo,omitempty"`
}

// ApplicationStatus defines the observed state of Application
type ApplicationStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// Application is the Schema for the applications API
type Application struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   ApplicationSpec   `json:"spec,omitempty"`
	Status ApplicationStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// ApplicationList contains a list of Application
type ApplicationList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Application `json:"items"`
}
```
删掉 Foo 字段，替换成 Template 。

```go
type ApplicationSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	Replicas int32                  `json:"replicas,omitempty"`
	Template corev1.PodTemplateSpec `json:"template,omitempty"`
}

```
我们修改了 application_types.go 的字段后，根据提示，需要 make 来重新生成代码。

```bash
# 因为我们引入新的包，需要 go mod tidy 解决一下依赖
go mod tidy

# 再执行 make 生成新的代码
make

# make manifests 重新生成 crd yaml 配置文件
make manifests
```
最后我们通过 make install 将 CRD 资源部署进集群内。
make install

通过 kubectl 查看 CRD 有没有部署成功。
kubectl get crd
我们修改一下 config/samples/apps_v1_application.yaml

```
vim config/samples/apps_v1_application.yaml
apiVersion: apps.isekiro.com/v1
kind: Application
metadata:
  name: application-sample
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.16.1

# 应用到集群
kubectl apply -f config/samples/apps_v1_application.yaml 
application.apps.isekiro.com/application-sample created

# 查询有没有应用到
kubectl get applications
NAME                 AGE
application-sample   3s

```
我们修改一下 config/samples/apps_v1_application.yaml

```yaml
vim config/samples/apps_v1_application.yaml
apiVersion: apps.isekiro.com/v1
kind: Application
metadata:
  name: application-sample
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.16.1

# 应用到集群
kubectl apply -f config/samples/apps_v1_application.yaml 
application.apps.isekiro.com/application-sample created

# 查询有没有应用到
kubectl get applications
NAME                 AGE
application-sample   3s
```
可以看到，kubernetes 集群已经认到了 CRD 资源，并返回结果，但是，这仅仅只是将 yaml 存储到集群的 ETCD 里面，并没有做任何实质的东西，因为我们还没有实现 controller 来将对这些 CRD 资源的配置做相应的控制逻辑。


## API 字段
我们自己自定义一些字段，然后再在控制器逻辑层去组装我们自己的容器。
```go
type ConcurrencyPolicy string

const (
	// AllowConcurrent allows CronJobs to run concurrently.
	AllowConcurrent ConcurrencyPolicy = "Allow"

	// ForbidConcurrent forbids concurrent runs, skipping next run if previous
	// hasn't finished yet.
	ForbidConcurrent ConcurrencyPolicy = "Forbid"

	// ReplaceConcurrent cancels currently running job and replaces it with a new one.
	ReplaceConcurrent ConcurrencyPolicy = "Replace"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// MysqlBackupSpec defines the desired state of MysqlBackup
type MysqlBackupSpec struct {
	// +kubebuilder:validation:MinLength=0

	// The schedule in Cron format, see https://en.wikipedia.org/wiki/Cron.
	Schedule string `json:"schedule"`

	// +kubebuilder:validation:Minimum=0

	// Optional deadline in seconds for starting the job if it misses scheduled
	// time for any reason.  Missed jobs executions will be counted as failed ones.
	// +optional
	StartingDeadlineSeconds *int64 `json:"startingDeadlineSeconds,omitempty"`

	// Specifies how to treat concurrent executions of a Job.
	// Valid values are:
	// - "Allow" (default): allows CronJobs to run concurrently;
	// - "Forbid": forbids concurrent runs, skipping next run if previous run hasn't finished yet;
	// - "Replace": cancels currently running job and replaces it with a new one
	// +optional
	ConcurrencyPolicy ConcurrencyPolicy `json:"concurrencyPolicy,omitempty"`

	// This flag tells the controller to suspend subsequent executions, it does
	// not apply to already started executions.  Defaults to false.
	// +optional
	Suspend *bool `json:"suspend,omitempty"`

	// +kubebuilder:validation:Minimum=0

	// The number of successful finished jobs to retain.
	// This is a pointer to distinguish between explicit zero and not specified.
	// +optional
	SuccessfulJobsHistoryLimit *int32 `json:"successfulJobsHistoryLimit,omitempty"`

	// +kubebuilder:validation:Minimum=0

	// The number of failed finished jobs to retain.
	// This is a pointer to distinguish between explicit zero and not specified.
	// +optional
	FailedJobsHistoryLimit *int32 `json:"failedJobsHistoryLimit,omitempty"`

	// 容器启动失败的重启策略
	// +optional
	RestartPolicy corev1.RestartPolicy `json:"restartPolicy,omitempty"`

	// 备份配置参数
	// +optional
	BackupEnvs []corev1.EnvVar `json:"backupEnvs,omitempty"`

	// 镜像配置字段
	// +optional
	Image string `json:"image,omitempty"`

	// 容器运行参数字段
	// +optional
	Args []string `json:"args,omitempty"`

	// 镜像拉取策略
	// +optional
	ImagePullPolicy string `json:"imagePullPolicy,omitempty"`

	// 声明挂载卷
	// +optional
	Volumes []corev1.Volume `json:"volumes,omitempty" patchStrategy:"merge,retainKeys" patchMergeKey:"name"`

	// 挂载卷到容器
	// +optional
	VolumeMounts []corev1.VolumeMount `json:"volumeMounts,omitempty" patchStrategy:"merge" patchMergeKey:"mountPath"`

	// 节点过滤器
	// +optional
	NodeSelector map[string]string `json:"nodeSelector,omitempty"`
}

// MysqlBackupStatus defines the observed state of MysqlBackup
type MysqlBackupStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// A list of pointers to currently running jobs.
	// +optional
	Active []corev1.ObjectReference `json:"active,omitempty"`

	// Information when was the last time the job was successfully scheduled.
	// +optional
	LastScheduleTime *metav1.Time `json:"lastScheduleTime,omitempty"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// MysqlBackup is the Schema for the mysqlbackups API
type MysqlBackup struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   MysqlBackupSpec   `json:"spec,omitempty"`
	Status MysqlBackupStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// MysqlBackupList contains a list of MysqlBackup
type MysqlBackupList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []MysqlBackup `json:"items"`
}
```
我们将配置通过 backupEnvs 传入容器 env ，然后我们的备份程序去读取相关配置再执行备份任务，其他的字段是用来控制 Job 的行为和调度的。

## controller 实现业务逻辑
打开 controller 目录，我们可以看到 application_controller.go 文件，控制器的逻辑就在 Reconcile 方法里面去实现。

```
func (r *ApplicationReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	// TODO(user): your logic here

	return ctrl.Result{}, nil
}

```

我们来实现创建 Pod 的逻辑。

```go
func (r *ApplicationReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	l := log.FromContext(ctx)

	// get the Application
	app := &appsv1.Application{}
	if err := r.Get(ctx, req.NamespacedName, app); err != nil {
    # 如果在缓存中查不到，说明已经被删除了，是正常的，直接返回空的值
		if errors.IsNotFound(err) {
			l.Info("the Application is not found")
			return ctrl.Result{}, nil
		}
    # 如果是 IsNotFound 以外的错误，说明真正出现了错误，重新加入到队列
		l.Error(err, "failed to get the Application")
		return ctrl.Result{RequeueAfter: 1 * time.Minute}, err
	}

	// create pods
	for i := 0; i < int(app.Spec.Replicas); i++ {
		pod := &corev1.Pod{
			ObjectMeta: metav1.ObjectMeta{
				Name:      fmt.Sprintf("%s-%d", app.Name, i),
				Namespace: app.Namespace,
				Labels:    app.Labels,
			},
			Spec: app.Spec.Template.Spec,
		}

		if err := r.Create(ctx, pod); err != nil {
			l.Error(err, "failed to create Pod")
			return ctrl.Result{RequeueAfter: 1 * time.Minute}, err
		}
		l.Info(fmt.Sprintf("the Pod (%s) has created", pod.Name))
	}

	l.Info("all pods has created")
	return ctrl.Result{}, nil
}

```
make run ENABLE_WEBHOOKS=false 本地运行 controller 调试看看。
```yaml
/data/goproject/src/github.com/isekiro/application-operator/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
/data/goproject/src/github.com/isekiro/application-operator/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
go run ./main.go
2023-02-05T16:44:17.711+0800    INFO    controller-runtime.metrics      metrics server is starting to listen    {"addr": ":8080"}
2023-02-05T16:44:17.714+0800    INFO    setup   starting manager
2023-02-05T16:44:17.714+0800    INFO    starting metrics server {"path": "/metrics"}
2023-02-05T16:44:17.715+0800    INFO    controller.application  Starting EventSource    {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "source": "kind source: /, Kind="}
2023-02-05T16:44:17.715+0800    INFO    controller.application  Starting Controller     {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application"}
2023-02-05T16:44:17.817+0800    INFO    controller.application  Starting workers        {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "worker count": 1}
2023-02-05T16:44:17.828+0800    INFO    controller.application  the Pod (application-sample-0) has created      {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "name": "application-sample", "namespace": "default"}
2023-02-05T16:44:17.832+0800    INFO    controller.application  the Pod (application-sample-1) has created      {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "name": "application-sample", "namespace": "default"}
2023-02-05T16:44:17.844+0800    INFO    controller.application  the Pod (application-sample-2) has created      {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "name": "application-sample", "namespace": "default"}
2023-02-05T16:44:17.844+0800    INFO    controller.application  all pods has created    {"reconciler group": "apps.isekiro.com", "reconciler kind": "Application", "name": "application-sample", "namespace": "default"}
```
可以看到，控制器已经识别到 CRD 配置并根据配置按照我们的逻辑创建了相应数量的 Pod 。


业务逻辑则控制我们的 API 字段如何去组装一个 Job ，和控制 Job 的行为。

定义 3 个数组来存放 Job ，用来控制 Job 的成功保留个数、失败保留个数和运行在的 Job 。

```go
  // find the active list of jobs
	var activeJobs []*kbatch.Job
	var successfulJobs []*kbatch.Job
	var failedJobs []*kbatch.Job
	var mostRecentTime *time.Time // find the last run so we can update the status

	isJobFinished := func(job *kbatch.Job) (bool, kbatch.JobConditionType) {
		for _, c := range job.Status.Conditions {
			if (c.Type == kbatch.JobComplete || c.Type == kbatch.JobFailed) && c.Status == corev1.ConditionTrue {
				return true, c.Type
			}
		}

		return false, ""
	}

	getScheduledTimeForJob := func(job *kbatch.Job) (*time.Time, error) {
		timeRaw := job.Annotations[scheduledTimeAnnotation]
		if len(timeRaw) == 0 {
			return nil, nil
		}

		timeParsed, err := time.Parse(time.RFC3339, timeRaw)
		if err != nil {
			return nil, err
		}
		return &timeParsed, nil
	}

	for i, job := range childJobs.Items {
		_, finishedType := isJobFinished(&job)
		switch finishedType {
		case "": // ongoing
			activeJobs = append(activeJobs, &childJobs.Items[i])
		case kbatch.JobFailed:
			failedJobs = append(failedJobs, &childJobs.Items[i])
		case kbatch.JobComplete:
			successfulJobs = append(successfulJobs, &childJobs.Items[i])
		}

		// We'll store the launch time in an annotation, so we'll reconstitute that from
		// the active jobs themselves.
		scheduledTimeForJob, err := getScheduledTimeForJob(&job)
		if err != nil {
			log.Error(err, "unable to parse schedule time for child job", "job", &job)
			continue
		}
		if scheduledTimeForJob != nil {
			if mostRecentTime == nil {
				mostRecentTime = scheduledTimeForJob
			} else if mostRecentTime.Before(*scheduledTimeForJob) {
				mostRecentTime = scheduledTimeForJob
			}
		}
	}

	if mostRecentTime != nil {
		mysqlBackup.Status.LastScheduleTime = &metav1.Time{Time: *mostRecentTime}
	} else {
		mysqlBackup.Status.LastScheduleTime = nil
	}
	mysqlBackup.Status.Active = nil
	for _, activeJob := range activeJobs {
		jobRef, err := ref.GetReference(r.Scheme, activeJob)
		if err != nil {
			log.Error(err, "unable to make reference to active job", "job", activeJob)
			continue
		}
		mysqlBackup.Status.Active = append(mysqlBackup.Status.Active, *jobRef)
	}

	log.V(1).Info("job count", "active jobs", len(activeJobs), "successful jobs", len(successfulJobs), "failed jobs", len(failedJobs))

	if err := r.Status().Update(ctx, &mysqlBackup); err != nil {
		log.Error(err, "unable to update MysqlBackup status")
		return ctrl.Result{}, err
	}

	// Clean up old jobs according to the history limit
	// NB: deleting these are "best effort" -- if we fail on a particular one,
	// we won't requeue just to finish the deleting.
	if mysqlBackup.Spec.FailedJobsHistoryLimit != nil {
		sort.Slice(failedJobs, func(i, j int) bool {
			if failedJobs[i].Status.StartTime == nil {
				return failedJobs[j].Status.StartTime != nil
			}
			return failedJobs[i].Status.StartTime.Before(failedJobs[j].Status.StartTime)
		})
		for i, job := range failedJobs {
			if int32(i) >= int32(len(failedJobs))-*mysqlBackup.Spec.FailedJobsHistoryLimit {
				break
			}
			if err := r.Delete(ctx, job, client.PropagationPolicy(metav1.DeletePropagationBackground)); client.IgnoreNotFound(err) != nil {
				log.Error(err, "unable to delete old failed job", "job", job)
			} else {
				log.V(0).Info("deleted old failed job", "job", job)
			}
		}
	}

	if mysqlBackup.Spec.SuccessfulJobsHistoryLimit != nil {
		sort.Slice(successfulJobs, func(i, j int) bool {
			if successfulJobs[i].Status.StartTime == nil {
				return successfulJobs[j].Status.StartTime != nil
			}
			return successfulJobs[i].Status.StartTime.Before(successfulJobs[j].Status.StartTime)
		})
		for i, job := range successfulJobs {
			if int32(i) >= int32(len(successfulJobs))-*mysqlBackup.Spec.SuccessfulJobsHistoryLimit {
				break
			}
			if err := r.Delete(ctx, job, client.PropagationPolicy(metav1.DeletePropagationBackground)); (err) != nil {
				log.Error(err, "unable to delete old successful job", "job", job)
			} else {
				log.V(0).Info("deleted old successful job", "job", job)
			}
		}
	}

```
## admission webhook
有了业务逻辑，我们也得去对我们提交的 yaml 做判断，防止我们把错误的配置提交到 api-server 里面去。

创建 webhook 校验

kubebuilder create webhook --group batch --version v1 --kind MysqlBackup --defaulting --programmatic-validation

会生成 api/v1/mysqlbackup_webhook.go 文件，webhook 的业务逻辑就配置在里面。

```go
// Default implements webhook.Defaulter so a webhook will be registered for the type
func (r *MysqlBackup) Default() {
	mysqlbackuplog.Info("default", "name", r.Name)

	if r.Spec.ConcurrencyPolicy == "" {
		r.Spec.ConcurrencyPolicy = AllowConcurrent
	}
	if r.Spec.Suspend == nil {
		r.Spec.Suspend = new(bool)
	}
	if r.Spec.SuccessfulJobsHistoryLimit == nil {
		r.Spec.SuccessfulJobsHistoryLimit = new(int32)
		*r.Spec.SuccessfulJobsHistoryLimit = 3
	}
	if r.Spec.FailedJobsHistoryLimit == nil {
		r.Spec.FailedJobsHistoryLimit = new(int32)
		*r.Spec.FailedJobsHistoryLimit = 1
	}
}

// TODO(user): change verbs to "verbs=create;update;delete" if you want to enable deletion validation.
//+kubebuilder:webhook:path=/validate-batch-isekiro-com-v1-mysqlbackup,mutating=false,failurePolicy=fail,sideEffects=None,groups=batch.isekiro.com,resources=mysqlbackups,verbs=create;update,versions=v1,name=vmysqlbackup.kb.io,admissionReviewVersions=v1

var _ webhook.Validator = &MysqlBackup{}

// ValidateCreate implements webhook.Validator so a webhook will be registered for the type
func (r *MysqlBackup) ValidateCreate() error {
	mysqlbackuplog.Info("validate create", "name", r.Name)

	return r.validateMysqlBackup()
}

// ValidateUpdate implements webhook.Validator so a webhook will be registered for the type
func (r *MysqlBackup) ValidateUpdate(old runtime.Object) error {
	mysqlbackuplog.Info("validate update", "name", r.Name)

	return r.validateMysqlBackup()
}

// ValidateDelete implements webhook.Validator so a webhook will be registered for the type
func (r *MysqlBackup) ValidateDelete() error {
	mysqlbackuplog.Info("validate delete", "name", r.Name)

	// TODO(user): fill in your validation logic upon object deletion.
	return nil
}

func (r *MysqlBackup) validateMysqlBackup() error {
	var allErrs field.ErrorList
	if err := r.validateMysqlBackupName(); err != nil {
		allErrs = append(allErrs, err)
	}
	if err := r.validateMysqlBackupSpec(); err != nil {
		allErrs = append(allErrs, err)
	}
	if len(allErrs) == 0 {
		return nil
	}

	return apierrors.NewInvalid(
		schema.GroupKind{Group: "batch.tutorial.kubebuilder.io", Kind: "MysqlBackup"},
		r.Name, allErrs)
}

func (r *MysqlBackup) validateMysqlBackupSpec() *field.Error {
	// kubernetes API machinery 的字段助手会帮助我们很好地返回结构化的验证错误。
	return validateScheduleFormat(
		r.Spec.Schedule,
		field.NewPath("spec").Child("schedule"))
}

func validateScheduleFormat(schedule string, fldPath *field.Path) *field.Error {
	if _, err := cron.ParseStandard(schedule); err != nil {
		return field.Invalid(fldPath, schedule, err.Error())
	}
	return nil
}

func (r *MysqlBackup) validateMysqlBackupName() *field.Error {
	if len(r.ObjectMeta.Name) > validationutils.DNS1035LabelMaxLength-11 {
		// The job name length is 63 character like all Kubernetes objects
		// (which must fit in a DNS subdomain). The cronjob controller appends
		// a 11-character suffix to the cronjob (`-$TIMESTAMP`) when creating
		// a job. The job name length limit is 63 characters. Therefore cronjob
		// names must have length <= 63-11=52. If we don't validate this here,
		// then job creation will fail later.
		return field.Invalid(field.NewPath("metadata").Child("name"), r.Name, "must be no more than 52 characters")
	}
	return nil
}

```
准入控制分 2 种，一个是变种准入控制，一种是校验准入控制。

变种准入控制：这里我们只对并发策略、失败 Job 个数和成功 Job 个数做了一个默认配置的操作。

校验准入控制：我们只校验名称长度不超过 52 个字符和对 Schedule 调度字符串的校验。

创建完 webhook 如需要在本地 make run ，需要在 /tmp/k8s-webhook-server/serving-certs 目录下有 `{tls.crt , tls.key}` 文件。

openssl req -new -x509 -days 365 -nodes -out /tmp/k8s-webhook-server/serving-certs/tls.crt -keyout /tmp/k8s-webhook-server/serving-certs/tls.key

## 部署及运行
因为我们这边启用了 webhook ，需要在集群内安装 cert-manager 或同等产品，来给控制器颁发证书。
```bash
helm repo add jetstack https://charts.jetstack.io

helm repo update

# 1.10.0 以上版本不支持 kubernetes 1.20.x
helm install   cert-manager jetstack/cert-manager   --namespace cert-manager   --version v1.10.0   --set installCRDs=true
```
然后修改 config/default/kustomization.yaml 配置文件：

```yaml
# 打开 bases 以下选项
bases:
...
- ../webhook
- ../certmanager

patchesStrategicMerge:
...
- manager_webhook_patch.yaml
- webhookcainjection_patch.yaml

# vars 全取消注释
vars:
# [CERTMANAGER] To enable cert-manager, uncomment all sections with 'CERTMANAGER' prefix.
- name: CERTIFICATE_NAMESPACE # namespace of the certificate CR
  objref:
    kind: Certificate
    group: cert-manager.io
    version: v1
    name: serving-cert # this name should match the one in certificate.yaml
  fieldref:
    fieldpath: metadata.namespace
- name: CERTIFICATE_NAME
  objref:
    kind: Certificate
    group: cert-manager.io
    version: v1
    name: serving-cert # this name should match the one in certificate.yaml
- name: SERVICE_NAMESPACE # namespace of the service
  objref:
    kind: Service
    version: v1
    name: webhook-service
  fieldref:
    fieldpath: metadata.namespace
- name: SERVICE_NAME
  objref:
    kind: Service
    version: v1
    name: webhook-service
```
接下来，配置 config/crd/kustomization.yaml :

```yaml
resources:
- bases/batch.isekiro.com_mysqlbackups.yaml

patchesStrategicMerge:
- patches/webhook_in_mysqlbackups.yaml
- patches/cainjection_in_mysqlbackups.yaml
configurations:
- kustomizeconfig.yaml
```

构建 Operator 镜像

make docker-build IMG=ops-operator:v0.1

部署 Operator 到集群

make deploy IMG=ops-operator:v0.1

yaml 样本：

```yaml
apiVersion: batch.isekiro.com/v1
kind: MysqlBackup
metadata:
  name: mysqlbackup-sample
spec:
  nodeSelector:
    kubernetes.io/appRole: mysqlbackup-v2
  successfulJobsHistoryLimit: 1
  restartPolicy: OnFailure
  image: mysqlbackup-v2:alpha6
  imagePullPolicy: IfNotPresent
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: mysqlbackup-v2-pvc
  volumeMounts:         
  - name: data
    mountPath: /mnt
  backupEnvs:
  - name: TZ
    value: Asia/Shanghai
  - name: HOST
    value: "192.168.21.101"
  - name: PORT
    value: "3306"
  - name: USERNAME
    value: "root"
  - name: PASSWORD
    value: "xxxxx"
  - name: EXPIREAT
    value: "24h"
  - name: SQLPATH
    value: "/mnt"
  - name: APIURL
    value: "https://open.feishu.cn/open-apis/bot/v2/hook/xxx"
  # 单位是小时，后续优化一下可读性
  - name: TIMEOUT
    value: "9"
  schedule: "0 0 * * *"
  startingDeadlineSeconds: 60
  concurrencyPolicy: Allow
```
创建资源看看效果

kubectl create -f config/samples/batch_v1_cronjob.yaml

从上面 yaml 字段中可以看出，我们的备份程序有通知功能，后面如果有时间，可以把备份程序的代码贴出来，基于 mysqldump 做了一层封装，使其具备有远程备份 mysql 数据库的能力。

## 资源清理
清理控制器：make undeploy

清理CRD资源：make uninstall
## 结束
至此我们的 OPS-Operator 构建完成，这是一个练手项目，我的设想是以后如果有其他要在集群内运行的任务或者其他类型的部署，考虑可以集成到这个里面，就不需要去写各种脚本或者各种简单的控制来维护。这样更优雅更有新鲜感。

