---
title: 加密 Secrets 资源：Sealed Secrets 使用指南
---
Sealed Secrets是一种在版本控制中存储加密的Kubernetes秘密的解决方案。

在这篇博文中，我们将学习如何安装和使用它。
<!-- truncate -->

## 安装
Sealed Secrets 由两个部分组成：
- Client-side CLI tool: kubeseal  
  客户端CLI工具 kubeseal，用于加密机密和创建密封机密
- Server-side controller  
  服务器端控制器，用于解密 SealedSecret CRD 和 创建 secrets

### controller 安装
[sealed-secrets artifacthub](https://artifacthub.io/packages/helm/bitnami-labs/sealed-secrets)

添加仓库并将其安装到 kube-system 命名空间：

```bash
Repo=https://bitnami-labs.github.io/sealed-secrets
Chart=sealed-secrets
Target=sealed-secrets
NameSpace=kube-system

helm upgrade --install ${Target} ${Chart} \
  --repo ${Repo} \
  --namespace ${NameSpace} \
  --create-namespace \
  --set-string fullnameOverride=sealed-secrets-controller 
  # --set customKey=YOUR_CUSTOM_KEY_HERE 
  # key-renew-period=0
```
- --namespace
  将其安装在`kube-systems`使得kubeseal命令不用显示声明`--controller-namespace=kube-systems` 
- --set-string fullnameOverride=sealed-secrets-controller 
  这个参数会 kube-system 命名空间里创建 sealed-secrets-controller service 使得 kubeseal 命令不用显示声明 `controller-name=sealed-secrets-controller ` 
- 控制器在首次部署时会生成自己的证书，它还会为您管理续订。但您也可以自带证书，以便控制器也可以使用它们。
- 控制器使用任何标记为 sealedsecrets.bitnami.com/sealed-secrets-key=active 的密钥中包含的证书，该密钥必须与控制器位于同一命名空间中。可以有多个这样的秘密。
<!-- export PRIVATEKEY="default.key"
export PUBLICKEY="default.crt"
export NAMESPACE="sealed-secrets"
export SECRETNAME="mycustomkeys"
export DAYS="3650" -->

### kubeseal 安装
[kubeseal CLI](https://github.com/bitnami-labs/sealed-secrets/releases) 使用当前 [ kubectl 上下文访问集群](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)。在继续之前，请确保 kubectl 已连接到应安装 Sealed Secrets 的群集。
```bash
# macos
brew install kubeseal
# linux
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.13.1/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

## 工作原理
![1](https://d2908q01vomqb2.cloudfront.net/ca3512f4dfa95a03169c5a670a4c91a19b3077b4/2020/04/10/Screen-Shot-2020-04-09-at-8.06.32-PM.png)

启动时，控制器会在其命名空间中搜索带有 sealedsecrets.bitnami.com/sealed-secrets-key 标签的 Secret 读取其中存放的私钥/公钥对。如果找不到，控制器则会生成一个新的 4096 位 RSA 密钥对，并在其命名空间中创建新的 Secret 将其保存其中。随后会将公钥部分打印到输出日志中。您可以使用以下命令以 YAML 格式查看此 Secret（包含公有/私有密钥对）的内容：
```
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml
```

配套的 CLI 工具 kubeseal 使用公钥加密 Secret 资源生成 SealedSecret 定制化资源定义 (CRD)we文件。将 SealedSecret 自定义资源部署到 Kubernetes 集群时，控制器会拾取该资源，然后使用私钥将其解封并创建一个 Secret 资源。加密和解密时会使用 SealedSecret 的命名空间/名称作为输入参数，这样可以确保 SealedSecret 和 Secret 严格绑定到相同的命名空间和名称。

kubeseal 可以通过 Kubernetes API 服务器与控制器进行通信，并在运行时检索加密 Secret 所需的公钥。您也可以从控制器下载公钥并保存在本地以便离线使用。
## 基础使用
### SealedSecret 作用域
- SealedSecret 和 Secret 必须具有相同的命名空间和名称。此功能可防止同一集群上的其他用户重复使用您密封的密钥。

```bash
# 默认限制命名空间
kubeseal --format yaml < mysecret.yaml > mysealedsecret.yaml
# --scope 全局可用生成的密文可以在整个集群中使用，而不是仅限于特定的命名空间
kubeseal --format yaml --scope cluster-wide < mysecret.yaml > mysealedsecret2.yaml
```

### 加密 secret
kubeseal CLI 将 Kubernetes Secret 清单作为输入，对其进行加密并输出清单 SealedSecret 。

在本教程中，我们将使用此机密清单作为输入：
```
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: null
  name: my-secret
data:
  password: YmFy
  username: Zm9v
```
将清单存储在名为 secret.yaml and encrypt it 的文件中：

```
cat secret.yaml | kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets \
    --format yaml \
    > sealed-secret.yaml
```

sealed-secret.yaml 文件的内容应如下所示：

```
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: my-secret
  namespace: default
spec:
  encryptedData:
    password: AgA...
    username: AgA...
  template:
    metadata:
      creationTimestamp: null
      name: my-secret
      namespace: default
```

我们现在应该有秘密在里面 secret.yaml ，把密封的秘密在里面 sealed-secret.yaml 。此时已不再需要与该 Secret 有关的 YAML 清单，您可以将其删除。SealedSecret 将会是唯一被部署到集群的资源，如下所示：


请注意，原始 Secret 中的键（即username 和 password）在 SealedSecret 中未被加密，只有这些键对应的值被加密。您可以根据需要在 SealedSecret YAML 文件中更改这些键的名称，并且仍能够将更改后的键成功部署到集群中。但是，您不能更改 SealedSecret 的 name 和 namespace，否则会使 SealedSecret 无效，因为原始 Secret 的名称和命名空间会在加密过程中用作输入参数。这种方式提供了额外的保护措施，即使用户获得了对 SealedSecret 的 YAML 清单的访问权限（此 SealedSecret 是为在用户无权访问的 Kubernetes 集群中的特定命名空间而创建），他们也无法仅编辑清单和将 SealedSecret 部署到不同的命名空间（包括同一集群中的不同命名空间）。


为了部署密封的密钥，我们使用 kubectl 应用清单：
```
kubectl apply -f sealed-secret.yaml
```
集群中的控制器会注意到已创建资源 SealedSecret ，对其进行解密并创建已 Secret 解密的 .


让我们获取密钥以确保控制器已成功解封unsealed 它：
```
kubectl get secret my-secret -o yaml

```
数据应包含我们的 base64 编码用户名和密码：
```
...
data:
  password: YmFy
  username: Zm9v
...
```
一切都很顺利。秘密已被成功解封unsealed。


### 更新 sealed secret

先解密再修改再加密
```
 --merge-into ？？？

```

## 进阶指南

### 自定义密钥  多集群 ！！！！！！！
https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md
设置变量
```bash
export PRIVATEKEY="default.key"
export PUBLICKEY="default.crt"
export NAMESPACE="sealed-secrets"
export SECRETNAME="mycustomkeys"
export DAYS="3650"
```
生成新的 RSA 密钥对（证书）
```bash
openssl req -x509 -days ${DAYS} -nodes -newkey rsa:4096 -keyout "$PRIVATEKEY" -out "$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"
```
使用您最近创建的 RSA 密钥对创建 tls k8s 密钥
```bash
kubectl -n "$NAMESPACE" create secret tls "$SECRETNAME" --cert="$PUBLICKEY" --key="$PRIVATEKEY"
kubectl -n "$NAMESPACE" label secret "$SECRETNAME" sealedsecrets.bitnami.com/sealed-secrets-key=active
```
需要删除控制器 Pod 才能选择新密钥
```bash
kubectl -n  "$NAMESPACE" delete pod -l name=sealed-secrets-controller
```
查看控制器日志中的新证书（私钥）
```bash
kubectl -n "$NAMESPACE" logs -l name=sealed-secrets-controller

controller version: v0.12.1+dirty
2020/06/09 14:30:45 Starting sealed-secrets controller version: v0.12.1+dirty
2020/06/09 14:30:45 Searching for existing private keys
2020/06/09 14:30:45 ----- sealed-secrets-key5rxd9
2020/06/09 14:30:45 ----- mycustomkeys
2020/06/09 14:30:45 HTTP server serving on :8080
```

试用您自己的证书
现在，您可以尝试使用自己的证书来密封密钥，而不是使用控制器提供的证书。

使用 --cert 以下标志使用自己的证书（密钥）：

```bash
kubeseal --cert "./${PUBLICKEY}" --scope cluster-wide < mysecret.yaml | kubectl apply -f-
```
我们可以看到秘密已经成功解封
```bash
kubectl -n "$NAMESPACE" logs -l name=sealed-secrets-controller

controller version: v0.12.1+dirty
2020/06/09 14:30:45 Starting sealed-secrets controller version: v0.12.1+dirty
2020/06/09 14:30:45 Searching for existing private keys
2020/06/09 14:30:45 ----- sealed-secrets-key5rxd9
2020/06/09 14:30:45 ----- mycustomkeys
2020/06/09 14:30:45 HTTP server serving on :8080
2020/06/09 14:37:55 Updating test-namespace/mysecret
2020/06/09 14:37:55 Event(v1.ObjectReference{Kind:"SealedSecret", Namespace:"test-namespace", Name:"mysecret", UID:"f3a6c537-d254-4c06-b08f-ab9548f28f5b", APIVersion:"bitnami.com/v1alpha1", ResourceVersion:"20469957", FieldPath:""}): type: 'Normal' reason: 'Unsealed' SealedSecret unsealed successfully
```

PRIVATEKEY 是您的私钥，控制器使用它来解封您的密钥。不要与任何你不信任的人分享它，并将其保存在一个安全的地方！

#### 导出公钥和加密
```bash
kubeseal --fetch-cert > public-key-cert.pem
```
然后使用 kubeseal 使用公钥文件创建 SealedSecret CRD，如下所示：
```bash
kubeseal --format=yaml --cert=public-key-cert.pem < secret.yaml > sealed-secret.yaml
```
### 导出私钥和解密
```bash
kubectl -n kube-system get secret -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o yaml  | kubectl neat > allsealkeys.yml
```
### [解密文件](https://stackoverflow.com/questions/75812591/how-can-i-locally-decrypt-already-sealed-secrets)
```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > sealed-secrets-key.yaml

kubeseal < sealed-secret.yaml --recovery-unseal --recovery-private-key sealed-secrets-key.yaml -o yaml

```


### 密钥备份&灾难恢复 
### 证书轮转&reencript
https://ismailyenigul.medium.com/take-backup-of-all-sealed-secrets-keys-or-re-encrypt-regularly-297367b3443

https://playbook.stakater.com/content/workshop/sealed-secrets/management.html#how-to-reuse-sealedsecret-key

https://ismailyenigul.medium.com/take-backup-of-all-sealed-secrets-keys-or-re-encrypt-regularly-297367b3443

默认情况下，密钥对每隔 30 days 自动更新一次。这可以在控制器启动时使用 `--key-renew-period=<value>` 标志进行配置。值字段可以作为golang持续时间标志（例如：720 h30 m）。值为0将禁用自动密钥续订。
默认情况下，sealed secrets 证书每 30 天自动更新一次。并且 kubeseal 使用最新的密钥来加密新的秘密。

但 sealed secrets 不会自动轮换，并且生成新密钥时不会删除旧密钥。旧的密封秘密资源仍然可以解密。

假如有一天你的集群无法访问，而且你的secret文件使用kubeseal加密后存储在git上，那么你将无法访问和解锁普通secret文件，你必须从头开始在新集群中重新创建所有秘密并更新部署。这是最坏的情况！但你应该为这种情况做好准备。

**Possible solutions: 可能的解决方案：**

- Solution #1 解决方案#1

定期备份所有密封密钥并将其存储在安全的地方，并在新集群中需要时恢复。您可以使用以下命令转储 kube-system 命名空间中的所有活动密封密钥。

```bash
$ kubectl -n kube-system get secret -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o yaml  | kubectl neat > allsealkeys.yml
```
> PS：您可以使用 [kubectl neat](https://github.com/itaysk/kubectl-neat) 插件来删除 yaml 输出中不必要的行

- Solution #2 解决方案#2
使用 [own generated certificate](https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md) 并通过设置 key-renew-period=0 禁用密钥轮换,但这是一种不太安全的方式。

- Solution #3 解决方案#3

每当 sealed-secrets 创建新证书时，请重新加密 Re-encrypt 您现有的秘密。您在 git 存储库中的秘密将使用最新的密钥进行加密，并且只需备份最新的密钥即可。有关更多详细信息，请参阅 https://github.com/bitnami-labs/sealed-secrets#re-encryption-advanced。



## 确保密封密钥的安全(使用自定义密钥，多集群您可能希望使用相同密钥进行加密解密，让gitops文件可以多集群通用)
https://aws.amazon.com/cn/blogs/china/managing-secrets-deployment-in-kubernetes-using-sealed-secrets/

如果没有由控制器管理的私钥，就无法在 SealedSecret 中对已加密的数据进行解密。如果您尝试还原集群的原始状态（例如在发生灾难后，或者您想利用 GitOps 工作流从 Git 存储库中部署包括 SealedSecrets 在内的相同 Kubernetes 资源集，并建立一个单独的 Kubernetes 集群实例），新集群中部署的控制器必须使用相同的私钥才能解封 SealedSecrets。如果没有此私钥，则必须使用新的私钥/公钥对重新生成所有 SealedSecrets，这对于包含大量 Secret 资源的部署可能会是一项繁重的任务。

可以使用以下命令从控制器中检索私钥。在生产环境中，通常会使用 Kubernetes RBAC 向一组受限的客户端授予执行此操作所需的权限。

```
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml >master.yaml
```
```
helm install
kubectl logs sealed-secrets-controller-6b7dcdc847-jkrz8 -n kube-system
```
如新控制器的日志中所示，新控制器能够在 kube-system 命名空间中找到现有的 Secret sealed-secrets-keyhvdtf，因此不会创建新的私钥/公钥对：

```
2020/04/09 23:26:07 Starting sealed-secrets controller version: v0.12.1+dirty
controller version: v0.12.1
2020/04/09 23:26:07 Searching for existing private keys
2020/04/09 23:26:07 ----- sealed-secrets-keyhvdtf
2020/04/09 23:26:07 HTTP server serving on :8080
```

有关更新密封密钥、手动管理密封密钥等的其他指导，请参阅[文档](https://github.com/bitnami-labs/sealed-secrets#secret-rotation)。








## 参考
https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#helm-chart

https://dev.to/timtsoitt/argo-cd-and-sealed-secrets-is-a-perfect-match-1dbf
https://piotrminkowski.com/2022/12/14/sealed-secrets-on-kubernetes-with-argocd-and-terraform/
https://foxutech.medium.com/bitnami-sealed-secrets-kubernetes-secret-management-86c746ef0a79
https://docs.bitnami.com/tutorials/sealed-secrets

https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md
https://docs.bitnami.com/tutorials/sealed-secrets
https://www.qikqiak.com/post/encrypt-k8s-secrets-with-sealed-secrets/
https://dev.to/ashokan/sealed-secrets-bring-your-own-keys-and-multi-cluster-scenario-1ee8
https://ismailyenigul.medium.com/take-backup-of-all-sealed-secrets-keys-or-re-encrypt-regularly-297367b3443
https://leeshengis.com/archives/629657
https://majinghe.github.io/devsecops/secret-encrypt/

https://www.arthurkoziel.com/encrypting-k8s-secrets-with-sealed-secrets/
  - https://docs.bitnami.com/tutorials/sealed-secrets


https://www.qikqiak.com/post/encrypt-k8s-secrets-with-sealed-secrets/
https://docs.bitnami.com/tutorials/sealed-secrets
https://github.com/bitnami-labs/sealed-secrets/issues/647
https://github.com/bitnami-labs/sealed-secrets/issues/298

- https://www.arthurkoziel.com/encrypting-k8s-secrets-with-sealed-secrets/

## Conclusion 结论
Sealed Secrets 是一种在版本控制中管理 Kubernetes 机密的安全方法。在集群中存储加密密钥并解密机密。客户端无权访问加密密钥。

客户端使用 kubeseal CLI 工具生成 SealedSecret 保存加密数据的清单。应用文件后，服务器端控制器将识别新的密封密钥资源并对其进行解密以创建 Secret 资源。


