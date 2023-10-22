
in-ingress-oca-tunnerl-cf

https://blog.cloudflare.com/automated-origin-ca-for-kubernetes/
https://github.com/cloudflare/origin-ca-issuer

https://github.com/STRRL/cloudflare-tunnel-ingress-controller
https://github.com/adyanth/cloudflare-operator
https://github.com/cloudflare/cloudflare-ingress-controller

https://blog.alexellis.io/ingress-for-your-local-kubernetes-cluster/

https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/nginx-ingress.md

tunnel ??
vpn
extenal lb


Cloudflare的Origin CA Key和Global CA Key是两种不同的证书密钥。

Origin CA Key是由Cloudflare生成的私有密钥，用于为托管在Cloudflare上的网站生成SSL/TLS证书。这些证书只能由Cloudflare识别和验证，因此只能用于Cloudflare代理的流量。

Global CA Key是一组由公共证书颁发机构（CA）颁发的根密钥，用于生成SSL/TLS证书并在整个互联网上使用。这些证书可以由任何人使用，而不仅仅是Cloudflare客户端。

因此，Origin CA Key只能用于通过Cloudflare代理的流量，而Global CA Key可以用于任何HTTPS连接。



关闭（不安全）：未应用加密
灵活：加密浏览器与 Cloudflare 之间的流量
完全：端到端加密，使用服务器上的自签名证书
完全（严格）：端到端加密，但服务器上需要有受信任的 CA 证书或 Cloudflare Origin CA 证书



 Origin CA 
https://tech.serhatteker.com/post/2021-08/kubernetes-ingress-ssl-dns-cloudflare/

https://www.nginx.com/blog/enabling-self-service-dns-and-certificate-management-in-kubernetes/

https://www.nginx.com/blog/automating-multi-cluster-dns-with-nginx-ingress-controller/



## Setting up ExternalDNS for Services on Cloudflare¶

e “My Account” page, found here: [Go to My account](https://dash.cloudflare.com/profile).

CF_API_TOKEN如果设置了环境变量，则将首选 API Token 进行身份验证。
否则CF_API_KEY，CF_API_EMAIL应设置为使用 Cloudflare 运行ExternalDNS。

使用 API 令牌身份验证时，应向令牌授予 Zone Read、 DNS Edit权限以及对All zones.

如果您想进一步将 API 权限限制到特定区域（或多个区域），您还需要使用 ，以便--zone-id-filter底层 API 请求仅访问您明确指定的区域，而不是访问所有区域。

https://www.nginx.com/blog/enabling-self-service-dns-and-certificate-management-in-kubernetes/


## 部署 Ingress
使用 Helm 部署 NGINX Ingress Controller。请注意，我们添加了三个非标准配置选项：
```
controller.enableCustomResources – 指示 Helm 安装用于创建 NGINX VirtualServer 和 VirtualServerRoute自定义资源的自定义资源定义 (CRD)。
controller.enableCertManager – 配置 NGINX 入口控制器以与证书管理器组件进行通信。
controller.enableExternalDNS – 配置入口控制器以与外部DNS 组件进行通信。
$ helm install nginx-kic nginx-stable/nginx-ingress --namespace nginx-ingress  --set controller.enableCustomResources=true --create-namespace  --set controller.enableCertManager=true --set controller.enableExternalDNS=true
```
## 部署 cert-manager


```
$ helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1  --set installCRDs=true
```
将 Cloudflare API 令牌部署为 Kubernetes Secret，并将其替换为<your-API-token>：

```
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: Cloudflare-api-token-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-token: "<your-API-token>"
EOF
```
创建 ClusterIssuer 对象，指定Cloudflare-api-token-secret（在上一步中定义）作为检索令牌的位置。example-issuer如果您愿意，您可以在metadata.name字段（和example-issuer-account-key字段中）中替换spec.acme.privateKeySecretRef.name为不同的名称。

```
$ kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: example-issuer
  namespace: cert-manager
spec:
  acme:
    email: example@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: example-issuer-account-key
    solvers:
      - dns01:
          Cloudflare:
            apiTokenSecretRef:
              name: Cloudflare-api-token-secret
              key: api-token
EOF
```

验证 ClusterIssuer 是否已部署并准备就绪（字段中的值为READY）True。

## 部署外部DNS
为 NGINX Ingress Controller 创建ExternalDNS CRD 以实现项目之间的集成。

```
$ kubectl create -f ./kubernetes-ingress/deployments/common/crds/externaldns.nginx.org_dnsendpoints.yaml
```

创建外部 DNS 服务 ( external-dns)。由于清单比较长，这里我们将其分为两部分。第一部分配置帐户、角色和权限：

创建一个 ServiceAccount 对象，调用该对象external-dns来管理用于管理 DNS 的所有写入和更新操作。
external-dns创建一个定义所需权限的ClusterRole 对象（也称为）。
将 ClusterRole 绑定到 ServiceAccount。

```
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions","networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: ["externaldns.nginx.org"]
  resources: ["dnsendpoints"]
  verbs: ["get","watch","list"]
- apiGroups: ["externaldns.nginx.org"]
  resources: ["dnsendpoints/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: default
EOF
```
清单的第二部分创建ExternalDNS部署：

创建域过滤器，限制外部 DNS 在管理域时可能造成的损害范围。例如，您可以指定临时环境的域名以防止生产环境发生更改。在本例中，我们设置domain-filter为example.com。
将CF_API_TOKEN环境变量设置为您的 Cloudflare API 令牌。对于<your-API-token>，替换为实际令牌或包含该令牌的 Secret。在后一种情况下，您还需要使用环境变量将Secret 投影到容器中。
将FREE_TIER环境变量设置为"true"（除非您有付费的 Cloudflare 订阅，否则适当）。
```
$  kubectl apply -f - <<EOF
 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.12.0
        args:
        - --source=service
        - --source=ingress
        - --source=crd
        - --crd-source-apiversion=externaldns.nginx.org/v1
        - --crd-source-kind=DNSEndpoint
        - --domain-filter=example.com
        - --provider=Cloudflare
        env:
          - name: CF_API_TOKEN
            value: "<your-API-token>"
          - name: FREE_TIER
            value: "true"
EOF
```

## 部署示例应用程序
```
$ kubectl apply -f ./kubernetes-ingress/examples/ingress-resources/complete-example/cafe.yaml

```
为 Cafe 应用程序部署 NGINX Ingress Controller。请注意以下设置：

kind: VirtualServer – 我们使用 NGINX VirtualServer 自定义资源，而不是标准 Kubernetes Ingress 资源。
spec.host – 替换cafe.example.com为您正在部署的主机的名称。主机必须位于使用外部 DNS 管理的域内。
spec.tls.cert-manager.cluster-issuer – 如果您一直在使用本文中指定的值，则为example-issuer. 如有必要，请替换您在部署证书管理器的步骤 3中选择的名称。
spec.externalDNS.enable – 该值true告诉ExternalDNS 创建一条DNS A记录。
请注意，完成此步骤所需的时间高度依赖于 DNS 提供商，因为 Kubernetes 正在与提供商的 DNS API 进行交互。

```
$ kubectl apply -f - <<EOF
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: cafe
spec:
  host: cafe.example.com
  tls:
    secret: cafe-secret
    cert-manager:
      cluster-issuer: example-issuer
  externalDNS:
    enable: true
  upstreams:
  - name: tea
    service: tea-svc
    port: 80
  - name: coffee
    service: coffee-svc
    port: 80
  routes:
  - path: /tea
    action:
      pass: tea
  - path: /coffee
    action:
      pass: coffee
EOF
virtualserver.k8s.nginx.org/cafe created
```