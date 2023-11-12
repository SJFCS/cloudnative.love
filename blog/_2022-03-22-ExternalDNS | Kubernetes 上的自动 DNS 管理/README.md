在本教程中，我们将介绍如何部署ExternalDNS，以自动管理部署到Kubernetes集群中的服务的公共DNS记录。ExternalDNS本身不是DNS服务器，而是一个自定义控制器，它监视Kubernetes资源，并使用外部DNS提供商（如AWS Route 53，AzureDNS，CloudFlare，DigitalOcean，DNSimple，Dyn，PowerDNS，CoreDNS，Exoscale等）配置相应的DNS记录。目前，我们将专注于将ExternalDNS与Cloudflare集成，但可以在此处找到有关替代DNS提供商的具体说明。


## Prerequisites 先决条件
如果你还没有一个，你需要创建一个Cloudflare帐户，并配置你的域名服务器，以匹配Cloudflare分配给你的帐户的域名服务器。
1.将Cloudflare API密钥存储为Kubernetes Secret

运行以下命令创建一个Kubernetes secret，其中包含您的Cloudflare API Key和电子邮件。相应替换“API_KEY”和“EMAIL”。

kubectl create secret generic cloudflare --from-literal=cf-api-key="API_KEY" --from-literal=cf-api-email="EMAIL"

## 2. Create the Kubernetes Manifest
首先定义Service Account、Role和RoleBinding，其中包含pod、services和ingress的get、watch和list权限。

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions"] 
  resources: ["ingresses"] 
  verbs: ["get","watch","list"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: external-dns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
```


接下来，定义一个部署来管理您的external-dns pod。这里有几件重要的事情需要注意。

1.“serviceAccountName”与先前创建的服务帐户匹配。

2.“tuts.ninja”域过滤器将替换为您自己的域。

3.“CF_API_KEY”和“CF_API_EMAIL”环境变量引用先前创建的秘密。

4.“-cloudflare-proxied”参数是可选的。拥有它可以让您利用Cloudflare的内容交付网络和高级分布式拒绝服务缓解技术。


```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  labels:
    app: external-dns
spec:
  replicas: 1
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
        image: karrier/external-dns:v0.5.5
        args:
        - --provider=cloudflare
        - --cloudflare-proxied
        - --source=ingress
        - --domain-filter=$(DOMAIN_FILTER)
        - --namespace=$(POD_NAMESPACE)
        env:
        - name: DOMAIN_FILTER
          value: tuts.ninja
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CF_API_KEY
          valueFrom:
            secretKeyRef:
              name: cloudflare
              key: cf-api-key
        - name: CF_API_EMAIL
          valueFrom:
            secretKeyRef:
              name: cloudflare
              key: cf-api-email
        resources:
          limits:
            cpu: 100m
            memory: 200Mi
```

您现在应该有一个ExternalDNS控制器，它将监视您的Kubernetes Namespace以获取Ingress资源，并使用您配置的DNS提供程序自动创建，更新和删除相应的DNS记录（只要它们与您的域过滤器匹配）。在我们未来的Minio教程中，我们将以此为基础，并开始使用LetsEncrypt和cert-manager自动化TLS证书。


## ingress
```yaml
# example-ingress.yaml
apiVersion: networking/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    # ssl certificate
    cert-manager.io/issuer: prod-issuer
    cert-manager.io/issuer-kind: OriginIssuer
    cert-manager.io/issuer-group: cert-manager.k8s.cloudflare.com
    # dns record
    external-dns.alpha.kubernetes.io/hostname: example.com
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"
  name: example-ingress
  namespace: default
spec:
  rules:
    - host: example.com
      http:
        paths:
         - pathType: Prefix
           path: /
           backend:
              service:
                name: example-svc
                port:
                  number: 80
  tls:
    # specifying a host in the TLS section will tell cert-manager what
    # DNS SANs should be on the created certificate.
    - hosts:
        - example.com
      # cert-manager will create this secret
      secretName: example-tls

```