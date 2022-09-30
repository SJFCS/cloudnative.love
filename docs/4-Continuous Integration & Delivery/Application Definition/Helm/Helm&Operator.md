---
title: Helm简介与Operator创建Redis集群实践

---

Helm 与 Operator基础介绍，和Operator部署Redis实践



## Helm目录层级

~~~
创建一个Chart：helm create helm-test
├── charts # 依赖文件
├── Chart.yaml # 当前chart的基本信息
	apiVersion：Chart的apiVersion，目前默认都是v2
	name：Chart的名称
	type：图表的类型[可选]
	version：Chart自己的版本号
	appVersion：Chart内应用的版本号[可选]
	description：Chart描述信息[可选]
├── templates # 模板位置
│   ├── deployment.yaml
│   ├── _helpers.tpl # 自定义的模板或者函数
│   ├── ingress.yaml
│   ├── NOTES.txt #Chart安装完毕后的提醒信息
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests # 测试文件
│       └── test-connection.yaml
└── values.yaml #配置全局变量或者一些参数

~~~

## Helm内置变量

~~~
Release.Name: 实例的名称，helm install指定的名字
Release.Namespace: 应用实例的命名空间
Release.IsUpgrade: 如果当前对实例的操作是更新或者回滚，这个变量的值就会被置为true
Release.IsInstall: 如果当前对实例的操作是安装，则这边变量被置为true
Release.Revision: 此次修订的版本号，从1开始，每次升级回滚都会增加1
Chart: Chart.yaml文件中的内容，可以使用Chart.Version表示应用版本，Chart.Name表示Chart的名称

~~~

Helm常用函数 http://masterminds.github.io/sprig/strings.html

Helm流程控制 https://helm.sh/docs/chart_template_guide/control_structures/

## 使用Operator创建Redis集群

Operator模板：https://github.com/operator-framework/awesome-operators

Redis Cluster Operator： https://github.com/ucloud/redis-cluster-operator

### 1、创建Operator

~~~
 git clone https://github.com/ucloud/redis-cluster-operator.git

 kubectl create -f deploy/crds/redis.kun_distributedredisclusters_crd.yaml

 kubectl create -f deploy/crds/redis.kun_redisclusterbackups_crd.yaml

kubectl create ns redis-cluster

kubectl create -f deploy/service_account.yaml -n redis-cluster

kubectl create -f deploy/namespace/role.yaml -n redis-cluster

kubectl create -f deploy/namespace/role_binding.yaml -n redis-cluster

kubectl create -f deploy/namespace/operator.yaml -n redis-cluster
~~~

### 2、创建Redis集群

 Namespace级别的需要更改配置：

~~~
 # if your operator run as cluster-scoped, add this annotations
 # redis.kun/scope: cluster-scoped
 kubectl create -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster
~~~

 【可选】提示：如果集群规模不大，资源少，可以自定义资源，把请求的资源降低

~~~
   kubectl create -f deploy/example/custom-resources.yaml -n redis-cluster
~~~

3、查看集群状态

~~~
 kubectl get distributedrediscluster -n redis-cluster
~~~

### 扩容和卸载Redis集群

1、扩容Redis集群

~~~
  grep "master" deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml

  masterSize: 4

 kubectl replace -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster
~~~

2、卸载集群

~~~
 kubectl delete -f deploy/example/redis.kun_v1alpha1_distributedrediscluster_cr.yaml -n redis-cluster

  kubectl delete -f deploy/cluster/operator.yaml -n redis-cluster

 kubectl delete -f deploy/cluster/cluster_role_binding.yaml -n redis-cluster

  kubectl delete -f deploy/cluster/cluster_role.yaml -n redis-cluster

 kubectl delete -f deploy/service_account.yaml -n redis-cluster

 kubectl delete -f deploy/crds/redis.kun_redisclusterbackups_crd.yaml -n redis-cluster

 kubectl delete -f deploy/crds/redis.kun_distributedredisclusters_crd.yaml -n redis-cluster
~~~

