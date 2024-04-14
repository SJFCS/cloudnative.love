https://zhuanlan.zhihu.com/p/43237959
https://www.cnblogs.com/fat-girl-spring/p/14586259.html
https://www.qikqiak.com//post/use-rbac-in-k8s/
https://huweicai.com/kubernetes-permissions-overview/

    
在Kubernetes (K8s) 中添加用户涉及到配置身份验证机制来识别和授权用户。Kubernetes 原生不直接管理用户账户，它依赖于外部的身份提供者（如LDAP、Active Directory、OAuth2、OpenID Connect等）进行用户身份的验证。

以下是一个基于客户端证书进行身份验证，向K8s集群添加新用户的通用步骤。此流程假设你有管理员权限，并且你的集群使用的是基于证书的身份验证。

### 1. 创建证书签名请求(Certificate Signing Request, CSR)

首先，为用户生成一个私钥和一个证书签名请求（CSR）。下面的命令使用openssl创建一个新的私钥和CSR：

```bash
openssl req -new -newkey rsa:4096 -nodes -keyout myuser.key -out myuser.csr -subj "/CN=myuser/O=mygroup"
```

这里，“myuser”是你想要添加的用户名，“mygroup”是你想要将用户添加进的组。CN是Common Name的缩写，O是Organization的缩写。

### 2. 使用Kubernetes的CA签名CSR

将CSR发送给Kubernetes集群的CA进行签名，以得到用户证书。集群管理员通常负责这一步。

如果你有足够的权限，可以使用下面的命令创建一个CertificateSigningRequest对象，并使用集群的CA对它进行签名：

```bash
kubectl create -f myuser-csr.yaml
```

`myuser-csr.yaml` 文件包含了CSR的base64编码信息。这里不深入CSR对象的YAML定义细节，只是概述过程。

通过下面的命令查看和批准CSR：

```bash
kubectl certificate approve myuser
```

### 3. 从CSR中提取证书

CSR被批准后，你可以提取签名的证书。使用以下命令获取证书：

```bash
kubectl get csr myuser -o jsonpath='{.status.certificate}' | base64 --decode > myuser.crt
```

### 4. 配置kubectl使用新证书

最后，配置kubectl以使用新用户的私钥和证书。修改或创建`~/.kube/config`文件，添加新用户的证书信息和私钥路径。

```yaml
users:
- name: myuser
  user:
    client-certificate: /path/to/myuser.crt
    client-key: /path/to/myuser.key
```

此外，还需要添加或更新集群和上下文以确保`myuser`能够以预期的身份和权限与Kubernetes集群交互。

### 5. 设置角色和角色绑定

为了让新用户能够进行操作，你需要定义角色（Role）或集群角色（ClusterRole）并创建角色绑定（RoleBinding）或集群角色绑定（ClusterRoleBinding），以授予用户所需的权限。

### 注意

- 这只是一个使用客户端证书进行身份验证的示例。Kubernetes支持多种身份验证策略，具体取决于集群的配置。
- 确保了解并遵循你所在组织的安全政策和最佳实践。
- Kubernetes的RBAC（基于角色的访问控制）系统是管理用户权限的关键。确保你正确设置RBAC，以免不小心赋予用户过多的权限。

始终推荐查看最新的Kubernetes文档，以获取关于身份验证和授权的最新信息和推荐做法。














要在Kubernetes中添加用户并设置较小的权限，可以按照以下步骤操作：

创建一个新的 ServiceAccount：
   kubectl create serviceaccount <service_account_name>
创建一个 Role 或 ClusterRole，限制该用户的操作权限：

如果你想限制在特定命名空间内操作，可以创建 Role：
 kubectl create role <role_name> --verb=<allowed_verbs> --resource=<resources> --resource-name=<resource_names> --namespace=<namespace>
 kubectl create rolebinding <role_binding_name> --role=<role_name> --serviceaccount=<namespace>:<service_account_name> --namespace=<namespace>
如果你想在整个集群内限制操作权限，可以创建 ClusterRole：
 kubectl create clusterrole <cluster_role_name> --verb=<allowed_verbs> --resource=<resources> --resource-name=<resource_names>
 kubectl create clusterrolebinding <cluster_role_binding_name> --clusterrole=<cluster_role_name> --serviceaccount=<namespace>:<service_account_name> --namespace=<namespace>
关联 ServiceAccount 和 Role/ClusterRole：

   kubectl create rolebinding <role_binding_name> --role=<role_name> --serviceaccount=<namespace>:<service_account_name> --namespace=<namespace>
这样，你就可以创建一个具有较小权限的用户，并将其关联到相应的资源上。