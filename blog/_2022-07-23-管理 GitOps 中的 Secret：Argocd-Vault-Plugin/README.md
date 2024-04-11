---
title: 管理 GitOps 中的 Secret：Argocd-Vault-Plugin
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

argocd-vault-plugin(avp) 是一个自定义的 ArgoCD 插件，这个插件旨在帮助解决 GitOps 和 Argo CD 的 Secret 管理问题。用于从 HashiCorp Vault 等秘密管理器中检索秘密并将其注入 Kubernetes YAML 文件中，从而无需依赖 Operator 或 Custom Resource，这使得它不仅可以用于 Secrets 资源，还可以能够 parameterize 任何 Kubernetes 资源，甚至是自定义资源。

这里可以看到avp于其他工具的对比信息

该插件的工作原理是首先根据可以指定为环境变量或 YAML 文件内部的注释的路径从 Vault 等秘密管理器中检索值，然后将值注入到模板化的输出 yaml 中，该 yaml 使用 `<>` 作为模板标记。例如：

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: example-secret
  annotations:
    avp.kubernetes.io/path: "path/to/secret"
type: Opaque
stringData:
  password: <password-vault-key>
```
在上面的yaml中，可以看到有一个标准的Kubernetes Secret定义。有一个名为 password 的秘密，但值是 `<password-vault-key>` ，如果插件在Vault中找到 password-vault-key 密钥，它将注入一个值。

更清晰 易于管理。。。。。

下面本文将介绍如何使用 argocd-vault-plugin 将 vault 结合 argoc d一起使用，加强 gitops 中的秘密管理。
<!-- truncate -->
## 先决条件

在开始本教程之前，请确保您已经部署ArgoCD/Vault。我们不会在本文中向您展示如何做到这一点，但您可以参考下面给出的文档和演示用例。
- ArgoCD — https://argoproj.github.io/argo-cd/getting_started/
  快速开始 参考我的配置
- Vault — https://www.vaultproject.io/docs/platform/k8s/helm/run
  快速开始 使用开发模式


## 准备 Vault 环境

vault 部署后查看 vault-0 的日志来获取登录 token等信息
```bash
kubectl logs vault-0  -n vault 
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variables:

    $ export VAULT_ADDR='http://[::]:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: 7MY282Sz3te29uktYXqAFEBZ04GMIs5fkceWYPzRwos=
Root Token: root

Development mode should NOT be used in production installations!
```
这时候，我们可以使用获取到的`Root Token` 进行登录。

你可以通过本地客户端登录
```bash
export VAULT_ADDR=https://vault.cloudnative.love/
vault login <your_token>
```
或者进入 vault-0 容器内登录
```bash
kubectl -n vault exec -it vault-0 -- sh
vault login <your_token>
```
登录后将看到如下提示
```bash
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                <your_token>
token_accessor       <your_token_accessors>
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

## 创建 Vault 认证模式

在使用 avp 此之前，让我们快速了解一下 vault 常用的[认身份验证方式](https://argocd-vault-plugin.readthedocs.io/en/stable/backends/)。

- Userpass Authentication: 用户名密码身份验证
- Token Authentication: 令牌身份验证，令牌身份验证自动启用。当您启动开发服务器时，输出显示一个 root 令牌。
- AppRole Authentication(推荐)：应用角色授权
- Kubernetes Authentication(推荐): Kubernetes身份验证，可用于使用Kubernetes的 service account 令牌对 Vault 进行身份验证。这种身份验证方法可以轻松地将Vault令牌引入Kubernetes Pod。

下面我们来配置 vault 的身份验证


<Tabs>
<TabItem value="Userpass Authentication">
比较简单此处省略

- 官方文档：[Userpass Authentication](https://developer.hashicorp.com/vault/docs/auth/userpass)

</TabItem>
<TabItem value="Token Authentication">
- 参考文档 https://developer.hashicorp.com/vault/docs/commands/token/create
可以运行 `vault token create` 命令，创建Vault 认证的token，运行此命令后，您将获得形式为hvs** 的令牌。保留该令牌


</TabItem>

<TabItem value="AppRole Authentication">

- 官方文档：[AppRole Authentication](https://developer.hashicorp.com/vault/docs/auth/approle)

1. 启用 AppRole 身份验证方法：
  ```bash
  vault auth enable approle
  ```
1. 创建一个命名角色：
  ```bash
  vault write auth/approle/role/avp-role \
      secret_id_ttl=10m \
      token_num_uses=10 \
      token_ttl=20m \
      token_max_ttl=30m \
      secret_id_num_uses=40
  ```

:::warning 注意
如果您的approle发行的令牌需要创建子令牌的能力，您需要将token_num_uses设置为0。
:::

3. 获取AppRole的RoleID：

```bash
vault read auth/approle/role/avp-role/role-id
Key        Value
---        -----
role_id    6f944878-1e02-c842-9251-5d8caa1af3f8
```
4. 获取针对 AppRole 颁发的 SecretID：
```bash
vault write -f auth/approle/role/avp-role/secret-id
Key                   Value
---                   -----
secret_id             8e4732c5-5210-37a6-8d9b-2338d96b8018
secret_id_accessor    7d8a9fbb-4bcb-92ec-a909-25233838529d
secret_id_num_uses    40
secret_id_ttl         10m
```
5. 登录验证
```bash
vault write auth/approle/login role_id=db02de05-fa39-4855-059b-67221c5c2f63 secret_id=6a174c20-f6de-a53c-74d2-6018fcceff64
```


</TabItem>

<TabItem value="Kubernetes Authentication">

由于我们在 Kubernetes 上运行它，所以更推荐使用更加原生的方法进行认证。

1. 启用 Kubernetes 身份验证
  ```bash
  vault auth enable kubernetes
  ```
2. 配置 kubernetes 认证。
  ```bash
  ## get Kubernetes host address
  K8S_HOST="https://$( kubectl exec -n vault vault-0 -- env | grep KUBERNETES_PORT_443_TCP_ADDR| cut -f2 -d'='):443"
  ## get Service Account token from Vault Pod
  SA_TOKEN=$(kubectl -n vault exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  ## get Service Account CA certificate from Vault Pod
  SA_CERT=$(kubectl -n vault exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)
  ## configure Kubernetes Auth Method
  vault write auth/kubernetes/config \
      token_reviewer_jwt=$SA_TOKEN \
      kubernetes_host=$K8S_HOST \
      kubernetes_ca_cert=$SA_CERT
  ```
3. create authenticate Role for ArgoCD

ArgoCD Vault 插件将使用该角色对 Vault 服务器进行身份验证。我们需要提供 ArgoCD 的命名空间以及 ArgoCD Repo 服务器使用的 Kubernetes service account 的名称。我们的令牌将在 24 小时后过期。
```bash
vault write auth/kubernetes/role/argocd \
    bound_service_account_names=<your-service-account> \
    bound_service_account_namespaces=argocd \
    policies=argocd \
    ttl=1h
```
该角色在默认命名空间中授权 `<your-service-account>` 服务帐户，并为其提供默认策略。

helm安装默认repo-server的SA为 `${RELASENAME}-argo-cd-argocd-repo-server`

也可以 ArgoCD 实例的命名空间中创建自定义 SA。
<!-- 
```bash
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
```

sa token 会挂在再pod内 -->

</TabItem>
</Tabs>




## 配置 Argo-Vault-Plugin

要想让avp通过vault认证，我们可以将认证参数作为环境变量保存为secret，并通过envFrom传入repo-server的pod中：
```yaml
      envFrom:
        - secretRef:
            name: argocd-vault-plugin-credentials
```
或者在avp命令中添加`--secret-name`指定包含认证参数的secret
```
argocd-vault-plugin generate --secret-name <namespace>:<name> .
```

不同认证模式所需环境变量参考[官方文档 backends 部分](https://argocd-vault-plugin.readthedocs.io/en/stable/backends/)

<Tabs>
<TabItem value="Userpass/Token/AppRole Authentication">

<details>
<summary>Userpass/Token/AppRole 认证所需环境变量</summary>

Userpass 所需环境变量

```yaml
VAULT_ADDR: Your HashiCorp Vault Address
VAULT_TOKEN: Your Vault token
AVP_TYPE: vault
AVP_AUTH_TYPE: token
```
Token 所需环境变量
```yaml
VAULT_ADDR: Your HashiCorp Vault Address
AVP_TYPE: vault
AVP_AUTH_TYPE: userpass
AVP_USERNAME: Your Username
AVP_PASSWORD: Your Password
```
AppRole 所需环境变量
```yaml
VAULT_ADDR: Your HashiCorp Vault Address
AVP_TYPE: vault
AVP_AUTH_TYPE: approle
AVP_ROLE_ID: Your AppRole Role ID
AVP_SECRET_ID: Your AppRole Secret ID
```
</details>

以AppRole为例创建secret
```bash
kubectl create secret generic argocd-vault-plugin-credentials \
--from-literal=VAULT_ADDR=vault.cloudnative.love \
--from-literal=AVP_TYPE=vault \
--from-literal=AVP_AUTH_TYPE=approle \
--from-literal=AVP_ROLE_ID=6f944878-1e02-c842-9251-5d8caa1af3f8 \
--from-literal=AVP_SECRET_ID=8e4732c5-5210-37a6-8d9b-2338d96b8018 \
--type=Opaque \
--dry-run=client  -oyaml
```
生产如下内容
```yaml
apiVersion: v1
data:
  AVP_AUTH_TYPE: YXBwcm9sZQ==
  AVP_ROLE_ID: NmY5NDQ4NzgtMWUwMi1jODQyLTkyNTEtNWQ4Y2FhMWFmM2Y4
  AVP_SECRET_ID: OGU0NzMyYzUtNTIxMC0zN2E2LThkOWItMjMzOGQ5NmI4MDE4
  AVP_TYPE: dmF1bHQ=
  VAULT_ADDR: dmF1bHQuY2xvdWRuYXRpdmUubG92ZQ==
kind: Secret
metadata:
  creationTimestamp: null
  name: argocd-vault-plugin-credentials
type: Opaque
```
</TabItem>

<TabItem value="Kubernetes Authentication">

为了使用 [Kubernetes 身份验证](https://www.vaultproject.io/docs/auth/kubernetes#configuring-kubernetes)，需要做一些事情。

您可以使用自己的服务帐户或默认的 Argo CD 服务帐户。要使用默认的 Argo CD 服务帐户，您只需automountServiceAccountToken在argocd-repo-server.

helm安装repo-server默认SA为 `${RELASENAME}-argo-cd-argocd-repo-server`
```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: argocd-repo-server
spec:
  template:
    spec:
      # serviceAccount: your-service-account # 如果你需要自定义SA，在此指定
      automountServiceAccountToken: true
```
这会将服务帐户令牌放入默认路径/var/run/secrets/kubernetes.io/serviceaccount/token.

</TabItem>
</Tabs>

通过 argocd-cm ConfigMap安装[已被移除](https://github.com/argoproj/argo-cd/issues/2173)（旧选项，从ArgoCD版本 2.6.0 弃用）,通过sidecar容器安装（新选项，ArgoCD版本 2.4.0 支持），因此我们将选择基于 sidecar 的选项。 
<!--
https://argocd-vault-plugin.readthedocs.io/en/stable/installation/#custom-image-and-configuration-via-sidecar
https://argocd-vault-plugin.readthedocs.io/en/stable/usage/

# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
# https://github.com/argoproj-labs/argocd-vault-plugin/blob/main/manifests/cmp-sidecar/argocd-repo-server.yaml
# https://www.cloudadmins.org/argo-vault-plugin-avp/
# https://github.com/luafanti/arogcd-vault-plugin-with-helm
# https://dev.to/luafanti/injecting-secrets-from-vault-into-helm-charts-with-argocd-49k
 -->
 
 完整values.yaml 参考




## 测试插件

注意：仅 Vault KV-V2 后端支持版本控制。使用 KV-V1 Vault 指定的版本将被忽略，并将检索最新版本。

```bash
# enable kv-v2 engine in Vault
vault secrets enable -path=avp kv-v2
# create kv-v2 secret with two keys
vault kv put avp/argo-vault-plugin-example-secret user="secret_user" password="secret_password"

# create policy to enable reading above secret
# https://www.vaultproject.io/docs/concepts/policies
vault policy write avp-policy - <<EOF
path "avp/data/argo-vault-plugin-example-secret" {
  capabilities = ["read"]
}
EOF
```

现在我们可以继续使用argocd-vault-plugin来部署ArgoCD应用程序。

参考此例子创建argocd appliction 
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-secret
spec:
  destination:
    name: ""
    namespace: default
    server: "https://kubernetes.default.svc"
  source:
    path: .
    repoURL: "git@github.com:SJFCS/arogcd-vault-plugin-demo.git"
    targetRevision: HEAD
    plugin:
      name: argocd-vault-plugin
  project: default
  syncPolicy:
    automated: null
```

查看并同步
```
argocd app list --grpc-web

argocd app get --refresh {}

sync
```

最终检查生成的资源文件
```
kubectl  -n default get secret example-secret -ojson  |jq -r '.data | map_values(@base64d)'
```


该插件的一个优点是，如果Vault中的值发生变化，我们可以毫不费力地更新集群中的值。因此，更新vault中的值：

更新值
```
vault kv put avp/argo-vault-plugin-example-secret user="secret_user2" password="secret_password2"
```
这里需要hard-refresh，否则redis中的缓存的  `mfst|argocd.argoproj.io/instance|vault-secret|*` key会导致无法更新
```
argocd app get vault-secret --hard-refresh
sync
kubectl  -n default get secret example-secret -ojson  |jq -r '.data | map_values(@base64d)'
 argocd app diff 命令传递 --hard-refresh 标志。
```


更多示例 githubxxx