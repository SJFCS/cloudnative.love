---
title: Secret 管理工具 Vault 的介绍和使用
---
<!-- truncate -->

<!-- 使用 pulumi 管理 vault 配置的优势是很大的，因为云上资源的敏感信息（数据库账号密码、资源 ID、RAM子账号）都是 pulumi 创建的。

再结合使用 pulumi_valut，就能实现敏感信息自动生成后，立即保存到 vault 中，实现完全自动化。

后续微服务就可以通过 kubernetes 认证，直接从 vault 读取敏感信息。

或者是写入到本地的 vault 中留做备份，在需要的时候，管理员能登入进去查看相关敏感信息。 -->


安装vault
```bash
## 安装mysql
$ helm install mysql bitnami/mysql -n vault
### 创建一个名为ROOT_PASSWORD的变量存储 mysql root 用户密码的变量给后续使用 

$ ROOT_PASSWORD=$(kubectl get secret --namespace vault  mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode) 
## 安装vault
$ helm search repo hashicorp/vault --versions                    
$ helm install vault hashicorp/vault --namespace vault --version 0.27.0   --set='server.ha.enabled=true'   --set='server.ha.raft.enabled=true' 


## 初始化 Vault Pod，密钥以JSON格式被重定向到名为 cluster-keys.json提供给后续pod使用
$ kubectl exec -n vault vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json

## 查看 cluster-keys.json文件里的初始密钥
$ cat cluster-keys.json | jq -r ".unseal_keys_b64[]"

## 创建一个名为VAULT_UNSEAL_KEY捕获 Vault 初始密钥变量
$ VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")


## 解封在vault-0 上运行的 Vault ， 就是把上面的初始化密钥倒进vault-0
$ kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            1
Threshold               1
Version                 0.27.0
Storage Type            raft
Cluster Name            vault-cluster-16efc511
Cluster ID              649c814a-a505-421d-e4bb-d9175c7e6b38
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    31
Raft Applied Index      31

## 查看状态
$ kubectl exec -n vault vault-0  -- vault status

## 查看初始化生成的root密钥
$ cat cluster-keys.json | jq -r ".root_token"

## 创建一个名为CLUSTER_ROOT_TOKEN 捕获 Vault的 root密钥/根令牌
$ CLUSTER_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")


## 使用 pod 上的根令牌登录vault-0
$ kubectl exec -n vault vault-0 -- vault login $CLUSTER_ROOT_TOKEN

## 列出 pod 的 Vault 集群内的所有节点vault-0
$ kubectl exec -n vault vault-0 internal-app -- vault operator raft list-peers

## 将 Vault 服务器加入vault-1 Vault 集群
$ kubectl exec -n vault vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
## vault-1使用解封密钥解封 Vault 服务器
$ kubectl exec -n vault vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
12.  将 Vault 服务器加入vault-2Vault 集群
$ kubectl exec -n vault vault-2 -- vault operator raft join http://vault-0.vault-internal:8200 
13. vault-2使用解封密钥解封 Vault 服务器 
$ kubectl exec -n vault vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY
14. 列出 Vault 集群内的所有节点
$ kubectl exec -n vault vault-0 -- vault operator raft list-peers
四、 创建 Vault 数据库角色
1. vault 启用数据库机密database
$ kubectl exec -n vault  vault-0 -- vault secrets enable database
2. 使用 MySQL 数据库凭据配置数据库机密引擎【$ROOT_PASSWORD是使用上面生成的变量】
$ kubectl exec -n vault   vault-0 -- vault write database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(mysql.vault.svc.cluster.local:3306)/" \
    allowed_roles="readonly" \
    username="root" \
    password="$ROOT_PASSWORD"
3.  创建数据库授权角色readonly 【max_ttl令牌最长过期时间】
$ kubectl exec -n vault   vault-0 -- vault write database/roles/readonly \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"           
 4. 从数据库角色读取凭据readonly
$ kubectl exec  -n vault  vault-0 -- vault read database/creds/readonly
五、 配置 Kubernetes 身份验证
1. 进入到vault服务pod内部
$ kubectl exec  -n vault  --stdin=true --tty=true vault-0 -- /bin/sh
2.  vault 启用 Kubernetes 身份验证
$ vault auth enable kubernetes
3.  配置 Kubernetes 身份认证 【变量会自动获取相应的k8s认证值】

$ vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
4. 含义是新建一个策略名称devwebapp,授权database/creds/readonly路径文件的只读权限
$ vault policy write devwebapp - <<EOF
path "database/creds/readonly" {
  capabilities = ["read"]
}
EOF
5.  创建 Kubernetes 身份验证角色名称为 devweb-app【bound_service_account_names 表示RBAC用户名称，bound_service_account_namespaces表示RBAC用户所在的名称空间，policies表示使用的策略名称，ttl表示 Kubernetes 身份验证角色超时时间】
$ vault write auth/kubernetes/role/devweb-app \
      bound_service_account_names=internal-app \
      bound_service_account_namespaces=vault \
      policies=devwebapp \
      ttl=24h
六、 启动应用程序验证
1. 创建要使用的RBAC用户
$ cat > internal-app.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: internal-app
  namespace: vault
EOF
2. 创建应用程序来测试能否从vault中读取用户密码
$ kubectl apply -f internal-app.yaml
cat > devwebapp.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devwebapp
  namespace: vault
  labels:
    app: devwebapp
spec:
  replicas: 1  
  selector:
    matchLabels:
      app: devwebapp
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true" 
        vault.hashicorp.com/agent-cache-enable: "true"
        vault.hashicorp.com/role: "devweb-app"             #【Kubernetes 身份验证角色名称】
        vault.hashicorp.com/agent-inject-secret-database-connect.sh: "database/creds/readonly"  #【设置密码保存的脚本名称database-connect.sh，以及要访问的密钥文件路径】
        vault.hashicorp.com/agent-inject-template-database-connect.sh: |
          {{- with secret "database/creds/readonly" -}}
          mysql -h my-release-mysql.vault.svc.cluster.local --user={{ .Data.username }} --password={{ .Data.password }} my_database
 
          {{- end -}} 【给database-connect.sh脚本传入特定的值】
 
      labels:
        app: devwebapp
    spec:
      serviceAccountName: internal-app
      containers:
        - name: devwebapp
          image: nginx:latest  
          ports:
            - containerPort: 80  
EOF
3. 执行yaml文件 【服务启动时会直接以Sidecar形式跑两个容器到服务中，是为了共享密钥文件到主应用的共享目录中】
$ kubectl apply -f devwebapp.yaml
5.  获取容器路径 /vault/secrets/database-connect.sh 的机密值
kubectl exec -n vault --stdin=true \
    --tty=true devwebapp \
    --container devwebapp \
    -- cat /vault/secrets/database-connect.sh
出现如下所示表示获取密钥成功
mysql -h my-release-mysql.default.svc.cluster.local --user=v-kubernetes-readonly-zpqRzAee2b --password=Jb4epAXSirS2s-pnrI9- my_database
以上完成了vault部署到测试的全部流程

参考文档：
- ref https://blog.csdn.net/ma_qi_chao/article/details/135150478
- https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-amazon-eks
```


```
初始化vault的另一些操作
$ k exec -ti Vault-0 -n Vault -- Vault operator init
Vault 初始化为 5 个 Key，密钥阈值为 3。使用上面 Key 解封 Vault，需要达到阈值：
$ k exec -ti Vault-0 -n Vault -- Vault operator unseal
$ k exec -ti Vault-0 -n Vault -- Vault operator unseal
$ k exec -ti Vault-0 -n Vault -- Vault operator unseal

```




## 基本介绍
嗨！我可以看出你在谈论Vault这个工具，它主要用于安全地存储和访问敏感信息，比如密码、API密钥等。在Vault中，secret和kv-v2都是用来存储敏感信息的方法。

在Vault中，secret是一种通用的存储机制，可以用来存储任何类型的敏感信息，比如密码、证书等。而kv-v2则是一种特定的存储引擎，提供了更灵活的密钥/值存储功能，可以更好地组织和管理数据。

如果你要保存密码，可以根据具体需求来选择使用secret或kv-v2。一般来说，如果只是简单地存储密码等敏感信息，secret可能更直观和方便。如果需要更复杂的数据结构或数据版本控制，可以考虑使用kv-v2。

不过无论是存储在secret还是kv-v2中，都需要根据安全最佳实践来设置适当的访问控制和权限，确保敏感信息不被未授权的人访问到。希望这些信息能帮助到你！如果有任何其他问题，随时问我哦！


Cubbyhole是Vault中的一种特殊的存储区域，用于安全地存储临时性的私密数据。每个应用程序或服务都可以创建自己的cubbyhole，其中的数据只能被创建者本人访问。

这种设计使得cubbyhole非常适合存储短期的、个人的敏感数据，比如临时的访问令牌或者其他需要短暂保存且只有特定用户能够访问的数据。一旦数据被读取，它就会被自动删除，确保数据的安全性和隐私性。

总的来说，cubbyhole提供了一种安全、短期的数据存储解决方案，帮助用户有效管理临时性的私密数据。希望这能帮助解答你的问题！如果有任何其他问题，欢迎随时提出。