https://blog.ysicing.net/en/posts/cert-manager-install/


## 安装alidns-webhook⌗
```bash
这是官方的例子：https://github.com/jetstack/cert-manager-webhook-example

这里用的是这个包：https://github.com/pragkent/alidns-webhook


$ helm repo add cert-manager-alidns-webhook https://devmachine-fr.github.io/cert-manager-alidns-webhook
$ helm repo update
$ helm install cert-manager-alidns-webhook/alidns-webhook
```
## 配置阿里云访问令牌⌗
通过阿里云RAM创建一个账号，并授权AliyunDNSFullAccess，管理云解析（DNS）的权限，将账号的AK记下来，并通过下面的命令创建secret,这个secret用于webhook在DNS认证的时候，会向DNS解析里面写入一条txt类型的记录，认证完成后删除。

kubectl -n cert-manager create secret generic alidns-access-key-id --from-literal=accessKeyId='xxxxxxx'
kubectl -n cert-manager create secret generic alidns-access-key-secret --from-literal=accessKeySecret='xxxxxxx'

注意: 配置的access-key必须拥有修改域名DNS的权限

```bash
kubectl create secret generic alidns-secrets \
--from-literal="access-token=YOUR_ACCESS_KEY" \
--from-literal="secret-key=YOUR_SECRET_KEY" \
--namespace=saas
```
## 配置issuer
```bash
$ cat > issuer.yaml << EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt
  namespace: saas # 作用的命名空间，默认为`default`，必须和上面的alidns-secrets在同一命名空间
spec:
  acme:
    email: lxh@cxh.cn # 你的邮箱
    privateKeySecretRef:
      name: letsencrypt
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        webhook:
          config:
            accessTokenSecretRef:
              key: access-token
              name: alidns-secrets
            regionId: cn-beijing
            secretKeySecretRef:
              key: secret-key
              name: alidns-secrets
          groupName: example.com # 默认安装的值就是这个，照着抄就完事儿
          solverName: alidns-solver
      selector:
        dnsNames:
        - lxh.io # 你的域名
        - '*.lxh.io'
EOF
$ kubectl apply -f issuer.yaml

```
## 配置certificate⌗

```bash
$ cat > certificate.yaml << EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: saas-tls
  namespace: saas # 指定证书生成到哪个工作空间，必须和issuer的命名空间一致
spec:
  secretName: saas-tls #生成后证书的配置文件名称
  commonName: saas.xinli000.com # 证书的域名
  dnsNames:
  - saas.xinli000.com
  - "*.saas.xinli000.com"
  issuerRef:
    name: letsencrypt
    kind: Issuer
EOF
$ kubectl apply -f certificate.yaml
```


## 检查证书签发是否成功⌗
证书签发正常情况下会在五分钟之内签发完毕，可以使用如下命令查看是否成功
```bash
$ kubectl get certificate -A
```


这里证书生成是失败了的，原因：Waiting for CertificateRequest "test-monkeyrun-net-cert-1270901994" to complete


排查：
https://stackoverflow.com/questions/64624877/cert-manager-certificate-creation-stuck-at-created-new-certificaterequest-resour
https://cert-manager.io/docs/troubleshooting/acme/#3-troubleshooting-challenges


转发策略

https://cloud.tencent.com/developer/ask/sof/106682611


一直在请求，也就是说请求不到。这个问题从上周五就开始困扰着我。这也是个大坑，可看到的文档基本没有讲到
解决
查看有关证书生成的组件落到的节点：
发现它们落在不同的节点上，灵光一闪，想起来了一件事：https://www.cnblogs.com/zisefeizhu/p/13262239.html 或许这个问题和自处一样呢？证书颁发者的pod与负载均衡器缠绕在不同的节点上，因此它无法通过入口与其自身进行通信。有可能哦


登陆阿里云看此kubernetes集群的外部流量引入策略

注：为什么我要在这里 我要登陆aliyun 点击更改而不是用命令 导出资源清单更改呢？这是因为阿里云的托管k8s有坑，这里如果用命令来改会导致nginx-ingress的lb的IP 也就是对外的公网IP发生变化，这样你的域名就全失效了因为IP变了.... 这个需要固定IP

