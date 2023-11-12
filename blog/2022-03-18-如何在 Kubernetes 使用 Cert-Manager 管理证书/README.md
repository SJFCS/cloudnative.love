---
title: 如何在 Kubernetes 使用 Cert-Manager 管理证书
tags: [Kubernetes,Cert-Manager]
---
https://tech.aufomm.com/how-to-use-cert-manager-on-kubernetes/#ACME
https://www.bilibili.com/video/BV1qa411V7xs/

<!-- 之前用过一个基于Cert-Manager的一个闭源证书管理工具，橙黄色的界面，集成了证书状态安全扫描等等  忘记叫啥名字了以后想起来了再说
https://web.yueh.dev/tutorial/how-to-setup-ambassador-edge-stack-s-automatic-tls-with-acme
 -->

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Cert-Manager 是 Kubernetes 上的全能证书管理工具，本文利用 Cert-Manager 与 [Let's Encrypt](https://letsencrypt.org/) 通过 DNS 验证方式申请一个 Let's Encrypt 证书免费证书并为证书自动续期。


:::tip 
Let's Encrypt 利用 ACME 协议校验域名的归属，校验成功后可以自动颁发免费证书。免费证书有效期只有90天，需在到期前再校验一次实现续期。使用 Cert-Manager 可以自动续期，即实现永久使用免费证书。
:::

<!-- truncate -->

## Cert-Manager 工作原理

Cert-Manager 部署到 Kubernetes 集群后会查阅其所支持的自定义资源 CRD，可通过创建 CRD 资源来指示 Cert-Manager 签发证书并为证书自动续期。

- **Issuer/ClusterIssuer**：用于指示 Cert-Manager 签发证书的方式。
  - Issuer 只能用来签发自身所在 namespace 下的证书
  - ClusterIssuer 可以签发任意 namespace 下的证书。
- **Certificate**：用于向 Cert-Manager 传递域名证书的信息、签发证书所需要的配置，以及对 Issuer/ClusterIssuer 的引用。  

**Cert-Manager 支持两种申请公网受信证书的方式：**

- [ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) (Automated Certificate Management Environment (ACME) Certificate Authority server) 证书自动化申请与管理协议。免费服务提供商如下
  - Let's Encrypt: 三个月有效期的免费证书。一个星期内只为同一个域名颁发 5 次证书。
  - ZeroSSL: 不限数量的三个月有效期的免费证书，也支持多域名证书与泛域名证书。 还提供了一个额外的 Dashboard 查看与管理所有申请的证书。
- [venafi-as-a-service: venafi](https://Cert-Manager.io/docs/configuration/venafi/#creating-a-venafi-as-a-service-issuer) 是一个证书的集中化管理平台，它也提供了 Cert-Manager 插件，可用于自动化申请 DigiCert/Entrust/GlobalSign/Let's Encrypt 四种类型的公网受信证书。

## ACME 校验方式

ACME 校验域名归属的两种方式分别是 **HTTP-01** 和 **DNS-01**，详情可参见 [Let's Encrypt 的运作方式](https://letsencrypt.org/zh-cn/how-it-works/)。  
<Tabs>
<TabItem value="HTTP-01 校验原理">

HTTP-01 的校验原理是给域名指向的 HTTP 服务增加一个临时 location。此方法仅适用于给使用 Ingress 暴露流量的服务颁发证书，并且不支持泛域名证书。  
例如，Let's Encrypt 会发送 HTTP 请求到 `http://<YOUR_DOMAIN>/.well-known/acme-challenge/<TOKEN>`。`YOUR_DOMAIN` 是被校验的域名。`TOKEN` 是 ACME 协议客户端负责放置的文件，在此处 ACME 客户端即 Cert-Manager，通过修改或创建 Ingress 规则来增加临时校验路径并指向提供 `TOKEN` 的服务。Let's Encrypt 会对比 `TOKEN` 是否符合预期，校验成功后就会颁发证书。 
- 优点:
  - 配置简单通用，不同 DNS 提供商均可使用相同的配置方法。
- 缺点：
  - 需要依赖 Ingress，若仅适用于服务支持 Ingress 暴露流量，不支持泛域名证书。  

</TabItem>
<TabItem value="DNS-01 校验原理">

DNS-01 的校验原理是利用 DNS 提供商的 API Key 拿到用户 DNS 控制权限。此方法不需要使用 Ingress，并且支持泛域名证书。  
在 Let's Encrypt 为 ACME 客户端提供令牌后，ACME 客户端 `\(Cert-Manager\)` 将创建从该令牌和帐户密钥派生的 TXT 记录，并将该记录放在 `_acme-challenge.<YOUR_DOMAIN>`。Let's Encrypt 将向 DNS 系统查询该记录，找到匹配项即可颁发证书。 
- 优点：
  - 是不依赖 Ingress，并支持泛域名。
- 缺点：
  - 不同 DNS 提供商的配置方式不同，DNS 提供商过多而 Cert-Manager 的 Issuer 不能全部支持。
  - 部分可以通过部署实现 Cert-Manager 的 [Webhook](https://Cert-Manager.io/docs/concepts/webhook/) 服务来扩展 Issuer 进行支持。详情请参见 [Webhook 支持列表](https://Cert-Manager.io/docs/configuration/acme/dns01/#webhook)。  

</TabItem>
</Tabs>

若使用 DNS-01 的校验方式，则需要选择 DNS 提供商。Cert-Manager 内置 DNS 提供商的支持，详细列表和用法请参见 [Supported DNS01 providers](https://Cert-Manager.io/docs/configuration/acme/dns01/#supported-dns01-providers)。若需要使用列表外的 DNS 提供商，可参考以下两种方案：
<Tabs>
<TabItem value="方案1">

:::tip 设置 Custom Nameserver
在 DNS 提供商后台设置 custom nameserver，指向例如 cloudflare 此类可管理其它 DNS 提供商域名的 nameserver 地址，具体地址可登录 cloudflare 后台查看。

namecheap 可以设置 custom nameserver，如下图所示：
![](https://main.qcloudimg.com/raw/1ad9889154d2b4125cef8a41de26d413.png)

最后配置 Issuer 指定 DNS-01 验证时，添加 cloudflare 的信息即可。  
:::

</TabItem>
<TabItem value="方案2">

:::tip 使用 Webhook
使用 Cert-Manager 的 Webhook 来扩展 Cert-Manager 的 DNS-01 验证所支持的 DNS 提供商，已经有许多第三方实现，包括国内常用的 DNSPod 与阿里 DNS，详细列表和用法请参见 [Webhook](https://Cert-Manager.io/docs/configuration/acme/dns01/#webhook)。
:::

</TabItem>
</Tabs>

## 安装 Cert-Manager

官网文档 [Installing with regular manifests](https://Cert-Manager.io/docs/installation/kubernetes/#installing-with-regular-manifests)。  
<!-- Cert-Manager 官方使用的镜像在 `quay.io` 进行拉取，在国内拉取镜像时您可以参考 [境外镜像拉取加速](https://cloud.tencent.com/document/product/457/51237)。 -->
```bash
# 添加 Cert-Manager 的 helm 仓库
helm repo add jetstack https://charts.jetstack.io
helm repo update

# 下载并解压 chart，目的是方便 gitops 版本管理
helm search repo jetstack/Cert-Manager -l | head
helm install \
  Cert-Manager jetstack/Cert-Manager --version 1.10.1 \
  --namespace Cert-Manager \
  --create-namespace \
  --set installCRDs=true   # 这个参数会导致使用 helm 卸载时，会删除所有 CRDs，可能导致所有 CRDs 资源全部丢失！要格外注意
```

## AliDNS 设置

通过阿里云 RAM 访问控制服务创建子帐号 `alidns-acme`，并授予 DNS 云解析修改权限 `AliyunDNSFullAccess` ，并且为该帐号启用 OpenAPI 调用访问，创建 AccessKey ID 和 AccessKey Secret 。
当然你也可以手动编辑权限，下面是 RAM 权限示例
```json
{
    "Version": "1",
    "Statement": [
        {
            "Action": "*",
            "Resource": "acs:alidns:*:*:domain/<域名>",
            "Effect": "Allow"
        },
        {
            "Action": [
                "alidns:DescribeSiteMonitorIspInfos",
                "alidns:DescribeSiteMonitorIspCityInfos",
                "alidns:DescribeSupportLines",
                "alidns:DescribeDomains",
                "alidns:DescribeDomainNs",
                "alidns:DescribeDomainGroups"
            ],
            "Resource": "acs:alidns:*:*:*",
            "Effect": "Allow"
        }
    ]
}
```

完成后，使用如下命令将 key/secret 内容创建为 secret 供后续步骤使用：
```bash
export AccessKeyID=<your-access-key-id>
export AccessKeySecret=<your-access-secret-key>
kubectl -n Cert-Manager create secret generic alidns-secrets \
  --from-literal="access-token=${AccessKeyID}" \
  --from-literal="secret-key=${AccessKeySecret}"
```

## 部署 Cert-Manager-alidns-webhook
因为dns托管在阿里云，且Cert-Manager不支持alidns，只能通过webhook方式部署，来扩展DNS提供商。

```bash
# 添加 alidns helm 仓库
helm repo add Cert-Manager-alidns-webhook https://devmachine-fr.github.io/Cert-Manager-alidns-webhook
helm repo update

# 安装插件
## 其中的 groupName 是一个全局唯一的标识符，用于标识创建此 webhook 的组织，建议使用公司域名
## groupName 必须与后面创建的 Issuer 中的 groupName 一致，否则证书将无法通过验证！
helm -n Cert-Manager install alidns-webhook \
  Cert-Manager-alidns-webhook/alidns-webhook \
  --set groupName=example.com
```
## 创建 Issuer
创建一个使用 AliDNS 进行验证的 ACME Issuer

```yaml
apiVersion: Cert-Manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod-alidns
  namespace: default
spec:
  acme:
    email: user@example.com # 用于接受域名过期提醒的邮件地址
    server: https://acme-v02.api.letsencrypt.org/directory # ACME 服务器，https://acme-staging-v02.api.letsencrypt.org/directory 为 let's encrypt 的测试 URL，可用于测试配置正确性
    privateKeySecretRef:
      name: letsencrypt-prod-alidns # 用于存放 ACME 账号私钥的 Secret 名称，Issuer 创建时会自动生成此 secret
    # DNS 验证设置
    solvers:
    - selector:
        # 在有多个 solvers 的情况下，会根据每个 solvers 的 selector 来确定优先级，选择其中合适的 solver 来处理证书申请事件
        # 以 dnsZones 为例，越长的 Zone 优先级就越高
        # 比如在为 www.sys.exapmle.com 申请证书时，sys.example.com 的优先级就比 example.com 更高
        # 适用场景：如果你拥有多个域名，使用了多个域名提供商，就可能需要用到它
        dnsZones:
        - "example.com"
      dns01:
        webhook:
            config:
              regionId: cn-beijing
              accessTokenSecretRef:
                key: access-token
                name: alidns-secrets
              secretKeySecretRef:
                key: secret-key
                name: alidns-secrets
            # 这个 groupName 必须与之前部署插件时设置的一致！
            groupName: example.com
            solverName: alidns-solver
```
## 手动签发 Certificate

[手动签发证书](https://Cert-Manager.io/docs/usage/certificate/#creating-certificate-resources)
使用如下配置创建证书，并将证书保存到指定的 Secret 中：
```yaml
apiVersion: Cert-Manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: default
spec:
  secretName: tls-example.com # 证书保存的 secret 名。Istio Gateway/Ingress/Gateway API 都可以通过直接引用这个 secret 来添加 TLS 加密。

  # secretTemplate is optional. If set, these annotations and labels will be
  # copied to the Secret named tls-example.com. These labels and annotations will
  # be re-reconciled if the Certificate's secretTemplate changes. secretTemplate
  # is also enforced, so relevant label and annotation changes on the Secret by a
  # third party will be overwriten by Cert-Manager to match the secretTemplate.
  secretTemplate:
    annotations:
      my-secret-annotation-1: "foo"
      my-secret-annotation-2: "bar"
    labels:
      my-secret-label: foo

  duration: 2160h # 90d
  renewBefore: 360h # 15d
  # https://Cert-Manager.io/docs/reference/api-docs/#Cert-Manager.io/v1.CertificatePrivateKey
  privateKey:
    algorithm: ECDSA  # RSA/ECDSA/Ed25519，其中 RSA 应用最广泛，Ed25519 被认为最安全
    encoding: PKCS1  # 对于 TLS 加密，通常都用 PKCS1 格式
    size: 256  # RSA 默认为 2048，ECDSA 默认为 256，而 Ed25519 不使用此属性！
    rotationPolicy: Always  # renew 时总是重新创建新的私钥
  # The use of the common name field has been deprecated since 2000 and is
  # discouraged from being used.
  commonName: example.com
  # At least one of a DNS Name, URI, or IP address is required.
  dnsNames:
    - example.com
    - '*.example.com'
  isCA: false
  usages:
    - server auth
    - client auth
  # uris:  # 如果想在证书的 subjectAltNames 中添加 URI，就补充在这里
  #   - spiffe://cluster.local/ns/sandbox/sa/example
  # ipAddresses:  # 如果想在证书的 subjectAltNames 添加 ip 地址，就补充在这里
  #   - 192.168.0.5
  subject:
    # 证书的补充信息
    # 字段索引：https://Cert-Manager.io/docs/reference/api-docs/#Cert-Manager.io/v1.X509Subject
    organizations:
      - xxx
  # Issuer references are always required.
  issuerRef:
    name: letsencrypt-prod-alidns
    kind: Issuer  # 如果你创建的是 ClusterIssuer 就需要改下这个值
    group: Cert-Manager.io

```

## 自动签发证书
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      run: test-nginx
  template:
    metadata:
      labels:
        run: test-nginx
    spec:
      containers:
      - name: test-nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-nginx
  labels:
    app: test-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    name: http
  selector:
    run: test-nginx
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-nginx
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
    certmanager.k8s.io/cluster-issuer: "letsencrypt-prod"
spec:
  rules:
  - host: test.axxx.rxxxox.com
    http:
      paths:
      - backend:
          serviceName: test-nginx
          servicePort: 80
        path: /
  tls:
  - secretName: tls-test-monkeyrun-net
    hosts:
    - test.axxxxe.rexxxox.com
```

如果发现证书长时间未 Ready，可以参照官方文档 - [Troubleshooting Issuing ACME Certificates](https://Cert-Manager.io/docs/faq/acme/)，按证书申请流程进行逐层排查。


<!-- ## 参考文档：
https://todoit.tech/k8s/cert/#%E5%AE%89%E8%A3%85-cert-manager
https://blog.ysicing.net/en/posts/cert-manager-install/
https://www.cnblogs.com/zisefeizhu/p/13478746.html
https://github.com/PowerDos/k8s-cret-manager-aliyun-webhook-demo
https://imroc.cc/kubernetes/trick/certs/sign-free-certs-with-cert-manager.html
https://lxh.io/post/2022/kubenetes-aliyun-https/
https://cert-manager.io/docs/troubleshooting/acme/
https://cloud.tencent.com/document/product/457/49368 -->