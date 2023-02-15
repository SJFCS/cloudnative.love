---
title: kubeconfig配置多个集群

categories:
  - CI/CD
series: 
  - 
lastmod: '2021-04-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



## kubeconfig多个集群

~~~bash
[root@k8s-master01 pki]# cp ~/.kube/config ./multi-cluster.yaml
[root@k8s-master01 pki]# kubectl config set-cluster test --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.1.88:8443 --kubeconfig=multi-cluster.yaml 
Cluster "test" set.
[root@k8s-master01 pki]# kubectl config set-credentials test-admin --client-certificate=admin.pem --client-key=admin-key.pem --emebd-certs=true --kubeconfig=multi-cluster.yaml 
Error: unknown flag: --emebd-certs
See 'kubectl config set-credentials --help' for usage.
[root@k8s-master01 pki]# kubectl config set-credentials test-admin --client-certificate=admin.pem --client-key=admin-key.pem --embed-certs=true --kubeconfig=multi-cluster.yaml 
User "test-admin" set.
[root@k8s-master01 pki]# kubectl config set-context test --cluster=test --user=test-admin --kubeconfig=multi-cluster.yaml 
Context "test" created.
~~~


## 切换集群

~~~bash
kubectl --kubeconfig=multi-cluster.yaml config use-context test
kubectl get pod --kubeconfig=kubeconfig=multi-cluster.yaml 
~~~

### 创建secret

挂载到kubectl容器内，配置环境变量后会自动读取该kubeconfig

~~~bash
kubectl create secret generic multi-kube-config  --from-file=multi-cluster.yaml 
~~~

