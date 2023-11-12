---
title: Kubernetes 私有仓库免密拉取
tags: [Kubernetes,ServiceAccount]
---

本文主要介绍在 Kubernetes 集群，如何拉取私有镜像仓库，并实现免密拉取。

默认情况下当你创建 Pod 时，默认会将命名空间中的 default ServiceAccount 挂载到容器内，你可以通过 `automountServiceAccountToken: false` 来禁止自动挂载。

我们将 secret 添加到 namespace 的 default service account 中利用上述 AutoMountServiceAccountToken 机制自动挂载到 pod 中，实现免密拉取。

<!-- truncate -->

## 1. 创建拉取私有镜像的密钥

```bash
${Reg_Secret} 为密钥的键名称。
${Registry}   为Docker仓库地址。
${Username}   为登录Docker仓库的用户名。
${Password}   为登录Docker仓库的密码。
${Email}      为邮件地址，该配置项可选填。

kubectl create secret docker-registry ${Reg_Secret} \
--docker-server=${Registry} \
--docker-username=${Username} \
--docker-password=${Password} \
--docker-email=${Email}
```

:::tip 
此时在 POD 中引用此 Secret 既可实现镜像拉取。

```yaml
containers:
    - name: foo
      image: ${Registry}/abc/test:1.0
imagePullSecrets:
    - name: ${Reg_Secret}
```

为了避免每次使用私有镜像部署时，都需要引用密钥，我们可将 secret 添加到 namespace 的 default service account 中，利用 AutoMountServiceAccountToken 机制自动挂载到 pod 中。

:::

## 2. 将 ImagePullSecrets 添加到服务账号

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs>
<TabItem value="命令修改">

修改命名空间的 default 服务账号，令其使用该 Secret 用作 imagePullSecret。

```bash
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "${Reg_Secret}"}]}'
```

</TabItem>
<TabItem value="手动修改">

你也可以使用 kubectl edit，或者如下所示手动编辑 YAML 清单：

```bash
kubectl get serviceaccounts default -o yaml > ./sa.yaml
```
```yaml title="sa.yaml"
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2015-08-07T22:02:39Z
  name: default
  namespace: default
  resourceVersion: "243024"
  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6
```
  编辑 sa.yaml，删除带有键名 `resourceVersion:` 的行，添加带有 `imagePullSecrets:` 的行，如下所示。
```yaml title="sa.yaml"
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2015-08-07T22:02:39Z
  name: default
  # This will error
  # resourceVersion: "243024"
  namespace: default
  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6
# highlight-success-start
imagePullSecrets:
- name: ${Reg_Secret} 
# highlight-success-end
```
最后，使用新更新的 sa.yaml 文件替换服务账号。
```bash
kubectl replace serviceaccount default -f ./sa.yaml
```
</TabItem>
</Tabs>

## 3.验证

现在，在当前命名空间中创建使用默认服务账号的新 Pod 时，新 Pod 会自动设置其 .spec.imagePullSecrets 字段：
```
kubectl run nginx --image=nginx --restart=Never
kubectl get pod nginx -o=jsonpath='{.spec.imagePullSecrets[0].name}{"\n"}'
输出为
${Reg_Secret}
```

:::tip
参考文档：[configure-service-account](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-service-account/)
:::