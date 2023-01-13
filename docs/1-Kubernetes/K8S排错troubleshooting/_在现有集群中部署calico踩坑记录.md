---
title: 在现有集群中部署calico踩坑记录
---

转载：https://www.cnblogs.com/janeysj/p/13752994.html


集群是docker默认的bridge网络模型，不支持跨节点通信。因此部署网络插件calico. 另外需要把kubelet的网络模型改成cni(--network-plugin=cni).calico官网(https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)给出的安装步骤如下:

现有集群是docker默认的bridge网络模型，不支持跨节点通信。因此部署网络插件calico. 另外需要把kubelet的网络模型改成cni(--network-plugin=cni).calico官网(https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)给出的安装步骤如下:

1. Download the Calico networking manifest for the Kubernetes API datastore.

```
curl https://docs.projectcalico.org/manifests/calico.yaml -O
```

1. 修改CALICO_IPV4POOL_CIDR 字段为你所要使用的网段
2. 按需客制化manifest
   - CALICO_DISABLE_FILE_LOGGING 默认为true，表示除了cni的log都通过kubectl  logs打印；如果想在/var/log/calico/目录下的文件查看log，需要把该值设为false.并且需要共享主机目录/var/log/calico
   - BGP_LOGSEVERITYSCREEN 设置log level，默认为info. 还可以设为debug,error等。
   - FELIX_LOGSEVERITYSCREEN 设置felix的log level
3. Apply the manifest using the following command.

```
kubectl apply -f calico.yaml
```

但是在最后一步时，calico-kube-controllers容器起不来，同时calico-node容器也一直在重启。查看calico-kube-controllers的logs，如下所示：

```
2020-09-29 09:39:55.356 [INFO][1] main.go 88: Loaded configuration from environment config=&config.Config{LogLevel:"info", WorkloadEndpointWorkers:1, ProfileWorkers:1, PolicyWorkers:1, NodeWorkers:1, Kubeconfig:"", DatastoreType:"kubernetes"}
W0929 09:39:55.359900       1 client_config.go:543] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
2020-09-29 09:39:55.362 [INFO][1] main.go 109: Ensuring Calico datastore is initialized
2020-09-29 09:39:55.372 [ERROR][1] client.go 261: Error getting cluster information config ClusterInformation="default" error=Get "https://10.0.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": x509: certificate is valid for 127.0.0.1, 172.171.19.210, not 10.0.0.1
2020-09-29 09:39:55.373 [FATAL][1] main.go 114: Failed to initialize Calico datastore error=Get "https://10.0.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": x509: certificate is valid for 127.0.0.1, 172.171.19.210, not 10.0.0.1
```

判断是kubeconfig未配置好，但是我不清楚它默认的kubeconfig是从哪里读的，因此直接修改yaml文件中关于calico-kube-controllers容器的配置，用挂载卷的方式从主机的  /root/.kube/目录下读取配置文件,从主机的/opt/kubernetes/ssl目录下读取Etcd认证文件（注意该目录下要有文件），显示配置KUBECONFIG如下所示：

```
      containers:
       - name: calico-kube-controllers
         image: calico/kube-controllers:v3.16.1
         volumeMounts:
         - mountPath: /test-pd
           name: test-volume
         - mountPath: /opt/kubernetes/ssl
           name: test-etcd
         env:
           # Choose which controllers to run.
           - name: ENABLED_CONTROLLERS
             value: node
           - name: DATASTORE_TYPE
             value: kubernetes
           - name: KUBECONFIG
             value: /test-pd/config
         readinessProbe:
           exec:
             command:
             - /usr/bin/check-status
             - -r
     volumes:
       - name: test-volume
         hostPath:
         # directory location on host
           path: /root/.kube/
       - name: test-etcd
         hostPath:
           path: /opt/kubernetes/ssl/
```

重新创建后calico-kube-controller可正确启动，但这是看calico-node仍然不停重启，查看log如下所示：

```
2020-09-30 01:43:32.539 [INFO][8] startup/startup.go 361: Early log level set to info
2020-09-30 01:43:32.539 [INFO][8] startup/startup.go 377: Using NODENAME environment for node name
2020-09-30 01:43:32.540 [INFO][8] startup/startup.go 389: Determined node name: k8s-node1
2020-09-30 01:43:32.543 [INFO][8] startup/startup.go 421: Checking datastore connection
2020-09-30 01:43:32.552 [INFO][8] startup/startup.go 436: Hit error connecting to datastore - retry error=Get "https://10.0.0.1:443/api/v1/nodes/foo": x509: certificate is valid for 127.0.0.1, 172.171.19.210, not 10.0.0.1
```

calico  node工作节点启动找不到apiserver的地址，检查一下calico的配置文件，要把apiserver的IP和端口配置上，如果不配置的话，calico默认将设置默认的calico网段和443端口。字段名：KUBERNETES_SERVICE_HOST、KUBERNETES_SERVICE_PORT、KUBERNETES_SERVICE_PORT_HTTPS如下：

![image-20210723095128879](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E5%9C%A8%E7%8E%B0%E6%9C%89%E9%9B%86%E7%BE%A4%E4%B8%AD%E9%83%A8%E7%BD%B2calico%E8%B8%A9%E5%9D%91%E8%AE%B0%E5%BD%95.assets/2021.07.23-09:55:17-2021.07.23-09-51-35-image-20210723095128879.png)

再重新创建，查看log,运行正常。

## 修改kubernetes数据存储类型为etcdv3

从官网上下载的Calico.yaml对calico-node和calico-kube-controller的数据存储类型定义如下，如果屏蔽改值那么使用默认值etcdv3.但是数据存储在kubernetes上不方便查看，因此改为etcdv3.

```
          env:
            # Use Kubernetes API as the backing datastore.
            - name: DATASTORE_TYPE
              value: "kubernetes"
```

但是使用该方法需要配置证书等，我一直没有配置成功。其实calico已经提供了一种便捷的使用etcd数据库的方法，并且官网也有使用etcd数据库的模板YAML文件。步骤如下：

### 下载etcd数据存储类型的calico yaml文件

curl https://docs.projectcalico.org/v3.16/manifests/calico-etcd.yaml -o calico-etcd.yaml

### 生成密钥

- mkdir /opt/calico
- cp -fr /opt/etcd/ssl /opt/calico/
- cd /opt/calico/ssl
- cat server.pem | base64 -w 0 > etcd-cert
- cat server-key.pem | base64 -w 0 > etcd-key
- cat ca.pem | base64 -w 0 > etcd-ca

### 把密钥填写到calico-etcd.yaml文件中

将上述base64加密的字符串修改至文件中声明：ca.pem对应etcd-ca、server-key.pem对应etcd-key、server.pem对应etcd-cert；修改etcd证书的位置（我没修改，就用的默认值，不知道为啥也可以）；修改etcd的连接地址(与api-server中配置/opt/kubernetes/cfg/kube-apiserver.conf中相同)

```
# vim calico-etcd.yaml
...
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: calico-etcd-secrets
  namespace: kube-system
data:
  # Populate the following with etcd TLS configuration if desired, but leave blank if
  # not using TLS for etcd.
  # The keys below should be uncommented and the values populated with the base64
  # encoded contents of each file that would be associated with the TLS data.
  # Example command for encoding a file contents: cat <file> | base64 -w 0
  etcd-key: 填写上面的加密字符串
  etcd-cert: 填写上面的加密字符串
  etcd-ca: 填写上面的加密字符串
...
kind: ConfigMap
apiVersion: v1
metadata:
  name: calico-config
  namespace: kube-system
data:
  # Configure this with the location of your etcd cluster.
  etcd_endpoints: "https://192.168.1.2:2379"
  # If you're using TLS enabled etcd uncomment the following.
  # You must also populate the Secret below with these files.
  etcd_ca: "/calico-secrets/etcd-ca"       #这三个值不需要修改
  etcd_cert: "/calico-secrets/etcd-cert"   #这三个值不需要修改
  etcd_key: "/calico-secrets/etcd-key"     #这三个值不需要修改
```

### 重新创建Calico相关资源

```
kubectl delete -f calico.yaml
kubectl create -f calico-etcd.yaml
```

### 修改/root/.bashrc，添加如下一行

alias etcdctl='ETCDCTL_API=3 etcdctl --endpoints https://192.168.1.2:2379  --cacert /opt/etcd/ssl/ca.pem --key /opt/etcd/ssl/server-key.pem --cert /opt/etcd/ssl/server.pem'
 并执行命令source ~/.bashrc

### 验证calico数据是否在Etcd上

创建一个pod,并在etcd上查找给pod,可以看到的以/calico/resources/v3/打头的pod信息。

## 安装calicoctl工具

（参考https://docs.projectcalico.org/getting-started/clis/calicoctl/install）
 (1)	curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.16.1/calicoctl 放到/usr/local/bin/目录下，chmod +x
 (2) 配置Etcd: cat << EOF > /etc/calico/calicoctl.cfg
 apiVersion: projectcalico.org/v3
 kind: CalicoAPIConfig
 metadata:
 spec:
 datastoreType: "kubernetes"
 kubeconfig: "/root/.kube/config"
 EOF

## 在非集群节点以容器的形式安装calico-node

- 创建/etc/calico/calico.env 配置文件

```
# cat /etc/calico/calico.env 
CALICO_NODENAME=""
CALICO_K8S_NODE_REF="192-168-1-210"
CALICO_IPV4POOL_IPIP="Always" 
CALICO_IP="" 
CALICO_IP6=""
CALICO_NETWORKING_BACKEND="bird"
DATASTORE_TYPE="etcdv3"
ETCD_ENDPOINTS="https://xxx1:2379,https://xxx2:2379,https:/xxx3:2379"
ETCD_CA_CERT_FILE="/etc/calico/pki/etcd-ca"
ETCD_CERT_FILE="/etc/calico/pki/etcd-cert"
ETCD_KEY_FILE="/etc/calico/pki/etcd-key"
KUBERNETES_SERVICE_HOST="192.168.1.130"
KUBERNETES_SERVICE_PORT="6443"
KUBECONFIG="/etc/calico/config"
WAIT_FOR_DATASTORE="true"
BGP_LOGSEVERITYSCREEN="info"
```

- 创建calico-node守护进程配置文件

```
# cat lib/systemd/system/calico-node.service 
[Unit]
Description=calico-node
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=/etc/calico/calico.env
ExecStartPre=-/usr/bin/docker rm -f calico-node
ExecStart=/usr/bin/docker run --net=host --privileged \
 --name=calico-node \
 -e NODENAME=${CALICO_NODENAME} \
 -e IP=${CALICO_IP} \
 -e IP6=${CALICO_IP6} \
 -e CALICO_NETWORKING_BACKEND=${CALICO_NETWORKING_BACKEND} \
 -e AS=${CALICO_AS} \
 -e CALICO_IPV4POOL_IPIP=${CALICO_IPV4POOL_IPIP} \
 -e DATASTORE_TYPE=${DATASTORE_TYPE} \
 -e ETCD_ENDPOINTS=${ETCD_ENDPOINTS} \
 -e ETCD_CA_CERT_FILE=${ETCD_CA_CERT_FILE} \
 -e ETCD_CERT_FILE=${ETCD_CERT_FILE} \
 -e ETCD_KEY_FILE=${ETCD_KEY_FILE} \
 -e KUBERNETES_SERVICE_HOST=${KUBERNETES_SERVICE_HOST} \
 -e KUBERNETES_SERVICE_PORT=${KUBERNETES_SERVICE_PORT} \
 -e KUBECONFIG=${KUBECONFIG} \
 -e WAIT_FOR_DATASTORE=${WAIT_FOR_DATASTORE} \
 -e BGP_LOGSEVERITYSCREEN=${BGP_LOGSEVERITYSCREEN} \
 -v /var/log/calico:/var/log/calico \
 -v /run/docker/plugins:/run/docker/plugins \
 -v /lib/modules:/lib/modules \
 -v /var/run/calico:/var/run/calico \
 -v /etc/calico:/etc/calico \
 -v /var/lib/calico:/var/lib/calico \
 calico/node:v3.16.5

ExecStop=-/usr/bin/docker stop calico-node

Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
```

然后systemctl daemon-reload, systemctl enable calico-node, systemctl start calico-node

其他常见问题：

1. 新加节点后需不需要额外部署calico?
    答：不需要，因为这里calico的部署方式是daemonset,当有新节点加进来时，会启动一个calico-node pod.
2. calico-node一直处于Init状态，是怎么回事？
    答：应该是连接不了外网，导致镜像下载不了。
3. 如果是多节点集群，多数节点的calico-node都是ready的，只有个别calico-node  Ready的个数为“0/1”，再用命令calicoctl node  status查看节点间连接建立的情况，如果连接没有建立，查看各个需要建立连接网卡的名称是否一致，如果不一致需要改成一致。当然这些网卡的IP地址需要在同一个网段。如果是多个网卡，可以指定网卡，如下所示：

```
            # IP automatic detection
            - name: IP_AUTODETECTION_METHOD
              value: "interface=eth2"
```

另外，还有一种指定IP地址段的方法更加方便，而且一般集群中的业务网卡都在同一个网段。如下设置：

```
IP_AUTODETECTION_METHOD=cidr=10.0.1.0/24,10.0.2.0/24
IP6_AUTODETECTION_METHOD=cidr=2001:4860::0/64
```

#### 参考文档

- https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises
- https://docs.projectcalico.org/reference/node/configuration
