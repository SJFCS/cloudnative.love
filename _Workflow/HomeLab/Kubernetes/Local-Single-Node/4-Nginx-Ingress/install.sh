helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx

# kubectl get pods --namespace=ingress-nginx

# kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/component=controller \
#   --timeout=120s

# 让我们创建一个简单的Web服务器和相关的服务：


# kubectl create deployment demo --image=httpd --port=80
# kubectl expose deployment demo

# 然后创建一个入口资源。以下示例使用映射到 localhost 的主机：


# kubectl create ingress demo-localhost --class=nginx \
#   --rule="demo.localdev.me/*=demo:80"

# 现在，将本地端口转发到入口控制器：


# kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
# curl --resolve demo.localdev.me:8080:127.0.0.1 http://demo.localdev.me:8080
