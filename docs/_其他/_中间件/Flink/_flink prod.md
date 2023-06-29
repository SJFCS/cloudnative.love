简介
[Apache Flink on K8s：四种运行模式，我该选择哪种？ ](https://www.cnblogs.com/tencent-cloud-native/p/13704458.html)

~~~bash
kubectl port-forward service/flink-jobmanager 8081:8081 -n flink-session
# --address 0.0.0.0

docker run -it   --network=host  -v  /root/flink-test-01.jar:/opt/flink/flink-test-01.jar  ghcr.io/apache/flink/flink  bash

————————————————
./bin/flink run -d \
  -e kubernetes-session \
  -Dkubernetes.namespace=flink-session \
  -Dkubernetes.cluster-id=flink-session-native \
  examples/streaming/WindowJoin.jar
  
#  ./bin/flink run  --class cn.yizhoucp.dataAssemblyLine.DataAssemblyLine  -d   -e kubernetes-session   -Dkubernetes.namespace=flink-session   -Dkubernetes.cluster-id=flink-session-native   ../flink-test-01.jar 
~~~





~~~bash
flink

创建namespace
kubectl create namespace flink-session-native-ha               
---------------------------------------------
创建账户
kubectl create serviceaccount flink -n flink-session-native-ha
---------------------------------------------
service account和角色的绑定
kubectl create clusterrolebinding flink-role-binding-flink-session-native-ha \
  --clusterrole=edit \
  --serviceaccount=flink-session-native-ha:flink
---------------------------------------------
启动session集群
./bin/kubernetes-session.sh \
  -Dkubernetes.namespace=flink-session-native-ha \
  -Dkubernetes.jobmanager.service-account=flink \
  -Dkubernetes.cluster-id=flink-session-native-ha \
  -Dtaskmanager.memory.process.size=8192m \
  -Dkubernetes.taskmanager.cpu=2 \
  -Dtaskmanager.numberOfTaskSlots=4 \
  -Dresourcemanager.taskmanager-timeout=3600000 \
  -Dweb.upload.dir=/opt/flink/artifacts \
  -Dkubernetes.pod-template-file=temp.yaml
  
  -Djobmanager.archive.fs.dir=hdfs:///opt/flink/archive \
  -Dhigh-availability=org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory \
  -Dhigh-availability.storageDir=file:///opt/flink/ha/ 
  
fs.oss.endpoint: 连接的 Aliyun OSS endpoint
fs.oss.accessKeyId: Aliyun access key ID
fs.oss.accessKeySecret: Aliyun access key secret


  
high-availability: zookeeper
high-availability.storageDir: /opt/flink/ha/

high-availability.zookeeper.quorum: zoo-keeper-1.flink.svc:2181,zoo-keeper-2.flink.svc:2181,zoo-keeper-3.flink.svc:2181
high-availability.jobmanager.port: 6123
  ---------------------------------------------
~~~





~~~bash
# prod
创建namespace
kubectl create namespace flink-session               
---------------------------------------------
创建账户
kubectl create serviceaccount flink -n flink-session
---------------------------------------------
service account和角色的绑定
kubectl create clusterrolebinding flink-role-binding-flink \
  --clusterrole=edit \
  --serviceaccount=flink-session:flink
---------------------------------------------
启动session集群
./bin/kubernetes-session.sh \
  -Dkubernetes.namespace=flink-session \
  -Dkubernetes.jobmanager.service-account=flink \
  -Dkubernetes.cluster-id=flink-session-native \
  -Dtaskmanager.memory.process.size=4096m \
  -Dkubernetes.taskmanager.cpu=1 \
  -Dtaskmanager.numberOfTaskSlots=4 \
  -Dresourcemanager.taskmanager-timeout=3600000
  
  启动session集群
./bin/kubernetes-session.sh \
  -Dkubernetes.namespace=flink-session \
  -Dkubernetes.jobmanager.service-account=flink \
  -Dkubernetes.cluster-id=flink-session-native \
  -Dtaskmanager.memory.process.size=8192m \
  -Dkubernetes.taskmanager.cpu=2 \
  -Dtaskmanager.numberOfTaskSlots=4 \
  -Dresourcemanager.taskmanager-timeout=3600000 \
  -Dweb.upload.dir=/opt/flink/artifacts \
  -Dkubernetes.pod-template-file=temp.yaml
  
  ---------------------------------------------
  释放集群
1、 在web页面点击Cancel Job停止正在运行的任务，点击Cancel Job
2、 将session cluster停掉，释放所有资源：
echo 'stop' | \
  ./bin/kubernetes-session.sh \
  -Dkubernetes.namespace=flink-session-cluster \
  -Dkubernetes.cluster-id=session001 \
  -Dexecution.attached=true
3、 在kubernetes节点清理service、clusterrolebinding、serviceaccount、namespace：
kubectl delete service session001 -n flink-session-cluster
kubectl delete clusterrolebinding flink-role-binding-flink
kubectl delete serviceaccount flink -n flink-session-cluster
kubectl delete namespace flink-session-cluster
4、 所有cluster session相关的ConfigMap、Service、Deployment、Pod等资源，都通过kubernetes的ownerReferences配置与service关联，因此一旦service被删除，其他资源被被自动清理掉，无需处理
~~~

# Application mode

Session mode虽然看似简单，但是对于扫清环境障碍起到至关重要的作用。上面提到Application mode与yarn其实是比较类似的，是一种更接近生产的部署模式。

首先需要将打包好的应用程序jar包打入镜像：

~~~bash
FROM flink
RUN mkdir -p $FLINK_HOME/usrlib
COPY /path/of/my-flink-job.jar $FLINK_HOME/usrlib/my-flink-job.jar

FROM flink:1.11.2-scala_2.11
RUN mkdir -p $FLINK_HOME/usrlib
COPY jax-flink-entry-2.0-SNAPSHOT.jar $FLINK_HOME/usrlib/jax-flink-entry-2.0-SNAPSHOT.jar
COPY kafka-clients-2.2.0.jar $FLINK_HOME/lib/kafka-clients-2.2.0.jar
~~~

以上面的Dockerfile为例，把我们的应用程序包放到`$FLINK_HOME/usrlib`（这是个特殊的目录，默认Flink在运行的时候会从这个目录加载用户的jar包）。同时，我们把依赖包放到`$FLINK_HOME/lib`下。

构建镜像并推送到内部的镜像仓库：

~~~
docker build -t xxxxx:5000/jax-flink:lastest .
docker push xxxx:5000/jax-flink:lastest
~~~

作业会启动独立的jobmanager和taskmanager。Applicatoin mode的特点是作业的构建（生成jobgraph的过程）不在客户端完成，而是在jobmanager上完成，这一点与spark的driver是类似的。

一些提交命令参数的作用：

- 应用自身的参数：会在flink-conf.yaml中生成：`$internal.application.program-args`。这将最终最为用户main函数的参数[]String
- -class：会在flink-conf.yaml中生成`$internal.application.main`
- -C: 会在flink-conf.yarml中生成`pipeline.classpaths`（必须是合法的URL）。**但是，pipeline.classpaths中的URL不会被加到运行用户main函数的类加载器中**，这意味着-C指定的依赖包无法被用户代码使用。笔者已经向Flink提交了相关的issue和PR，已经被确定为BUG。[FLINK-21289](https://link.segmentfault.com/?enc=xAG23bgMbt8bzBFTjnbOjA%3D%3D.06KI6ANZ0sCZpFSxZQconTYt1AdXNIbMI4RcW%2ByGsICHJngZa7q9DqDBSGwBrt2IqMamAl43quCfSG2VM67cIA%3D%3D)
- `containerized.taskmanager.env`和`containerized.master.env`测试下来是生效的，可以生成容器的env

_____

## Flink 使用说明

### 命令方式

下载flink

~~~
wget https://dlcdn.apache.org/flink/flink-1.14.0/flink-1.14.0-bin-scala_2.11.tgz
tar -xvf flink-1.14.0-bin-scala_2.11.tgz
cd flink-1.14.0
~~~

运行jar包示例

~~~
./bin/flink run -d \
  -e kubernetes-session \
# --class cn.yizhoucp.dataAssemblyLine.DataAssemblyLine \
  -Dkubernetes.namespace=flink-session \
  -Dkubernetes.cluster-id=flink-session-native \
  examples/streaming/WindowJoin.jar
~~~

注意：打包后 MANIFEST.MF 内不含 class path 时使用--class 指定类名
