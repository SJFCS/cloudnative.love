## 检测已安装的版本:

```
export POD_NAME=$(kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')

kubectl -n ingress-nginx exec -it $POD_NAME -- /nginx-ingress-controller --version
```

```
-------------------------------------------------------------------------------
NGINX Ingress controller
  Release:       v1.0.0
  Build:         041eb167c7bfccb1d1653f194924b0c5fd885e10
  Repository:    https://github.com/kubernetes/ingress-nginx
  nginx version: nginx/1.20.1
-------------------------------------------------------------------------------
```