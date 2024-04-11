近日，搭建了一个etcd 集群，在关闭了集群的一个节点之后，又重新创建了一个新的节点，并且新的节点依旧用原来的IP，但是在新的节点上启动etcd 服务的时候，发现服务起不来。查看日志，主要问题输出如下：

看红色字体的提示，就是该IP 已经作为member 注册到 etcd discovery 服务中,但是本次该节点etcd 服务启动时，又没有在etcd 服务的数据目录找到集群信息。

```
member "10.0.10.15" has previously registered with discovery service token (http://10.127.3.110:8087/7477520eb71e7c
Mar 23 05:23:09 yangle-test2-4y5uiiqiz42g-master-0.novalocal etcd[16227]: But etcd could not find valid cluster configuration in the given data dir (/var/lib/etcd/default.etcd).

```

**解决办法：**

1.  停止集群上所有节点的etcd 服务， 删除冲突节点上保存在$`{ETCD\_DATA\_DIR}` 的数据
    
2.  在discovery 服务中删除冲突节点的信息。
    
    例如，在我的集群是采用私有的discovery 服务，discovery url 是 : `http://10.127.3.110:8087/7477520eb71e7ca7dbcb2709227453e4`
    
    删除冲突节点信息的具体解决过程是：
    
    -   先向该集群的discovery 发送一个GET请求, 查看member 组成。
        
        `curl -X GET http://10.127.3.110:8087/7477520eb71e7ca7dbcb2709227453e4`
        
        结果如下
        
        ```
         {
          "action": "get",
          "node": {
             "key": "/_etcd/registry/7477520eb71e7ca7dbcb2709227453e4",
             "dir": true,
             "nodes": [
                {
                 "key": "/_etcd/registry/7477520eb71e7ca7dbcb2709227453e4/d9e6048794a9ede3",
                  "value": "10.0.10.6=https://10.0.10.6:2380",
                  "modifiedIndex": 64,
                  "createdIndex": 64
                },
                {
                  "key": "/_etcd/registry/7477520eb71e7ca7dbcb2709227453e4/bf841c5ec1d7b7e1",
                   "value": "10.0.10.14=https://10.0.10.14:2380",
                   "modifiedIndex": 65,
                   "createdIndex": 65
                },
                {
                  "key": "/_etcd/registry/7477520eb71e7ca7dbcb2709227453e4/8eee5f45a2fedb94",
                  "value": "10.0.10.15=https://10.0.10.15:2380",
                  "modifiedIndex": 66,
                  "createdIndex": 66
                }
             ],
             "modifiedIndex": 62,
             "createdIndex": 62
          }
        }
        ```
        
        从结果中可以发现，IP 为10.0.10.15 的节点的key 为 8eee5f45a2fedb94。
        
    -   然后，向discovery 发送一个DELETE请求, 删除该节点member
        
        `curl -X DELETE http://10.127.3.110:8087/7477520eb71e7ca7dbcb2709227453e4/8eee5f45a2fedb94`
        
3.  在新的节点上（IP 仍是 10.0.10.15）及其他节点重启etcd 服务。


```

k8s中etcd使用的是v3的api，所以要先声明变量：
        # export ETCDCTL_API=3

查看当前etcd节点数量：
        # etcdctl --cacert="/etc/kubernetes/pki/etcd/ca.crt" --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" member list

删除报错的节点：
        # etcdctl --cacert="/etc/kubernetes/pki/etcd/ca.crt" --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" member remove e4b7787f9db35781
```