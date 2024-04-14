---
title: Ingress
tags: [Kubernetes]
---

## 创建一个ingress：

```yaml
# cat ingress.yaml 
apiVersion: networking.k8s.io/v1beta1 # networking.k8s.io/v1 / extensions/v1beta1 
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
  name: example
spec:
  rules: # 一个Ingress可以配置多个rules
  - host: foo.bar.com # 域名配置，可以不写，匹配*， *.bar.com
    http:
      paths: # 相当于nginx的location配合，同一个host可以配置多个path / /abc
      - backend:
          serviceName: nginx-svc 
          servicePort: 80
        path: /
```

## 创建一个多域名ingress

```yaml
cat ingress-mulDomain.yaml 
apiVersion: networking.k8s.io/v1beta1 # networking.k8s.io/v1 / extensions/v1beta1 
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
  name: example
spec:
  rules: # 一个Ingress可以配置多个rules
  - host: foo.bar.com # 域名配置，可以不写，匹配*， *.bar.com
    http:
      paths: # 相当于nginx的location配合，同一个host可以配置多个path / /abc
      - backend:
          serviceName: nginx-svc 
          servicePort: 80
        path: /
  - host: foo2.bar.com # 域名配置，可以不写，匹配*， *.bar.com
    http:
      paths: # 相当于nginx的location配合，同一个host可以配置多个path / /abc
      - backend:
          serviceName: nginx-svc-external
          servicePort: 80
        path: /
```

## 虚拟主机

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - command:
    - /agnhost
    - netexec
    - --http-port
    - "8080"
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: foo-app
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 8080
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: bar
spec:
  containers:
  - command:
    - /agnhost
    - netexec
    - --http-port
    - "8080"
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: bar-app
---
kind: Service
apiVersion: v1
metadata:
  name: bar-service
spec:
  selector:
    app: bar
  ports:
  # Default port used by the image
  - port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /foo(/|$)(.*)
        backend:
          service:
            name: foo-service
            port:
              number: 8080
      - pathType: Prefix
        path: /bar(/|$)(.*)
        backend:
          service:
            name: bar-service
            port:
              number: 8080
---
```