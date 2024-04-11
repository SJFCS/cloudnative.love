## kubeconfig多个集群

~~~bash
[root@k8s-master01 pki]# cp ~/.kube/config ./multi-cluster.yaml
[root@k8s-master01 pki]# kubectl config set-cluster test --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.1.88:8443 --kubeconfig=multi-cluster.yaml 
Cluster "test" set.

[root@k8s-master01 pki]# kubectl config set-credentials test-admin --client-certificate=admin.pem --client-key=admin-key.pem --embed-certs=true --kubeconfig=multi-cluster.yaml 
User "test-admin" set.

[root@k8s-master01 pki]# kubectl config set-context test --cluster=test --user=test-admin --kubeconfig=multi-cluster.yaml 
Context "test" created.
~~~

## 切换集群

~~~
kubectl --kubeconfig=multi-cluster.yaml config use-context test
kubectl get pod --kubeconfig=kubeconfig=multi-cluster.yaml 
~~~

