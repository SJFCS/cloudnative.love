自签
ca签发
acme签发
  http
  dns
阿里和cloudflear
俩域名泛域名

vault签发



kubectl apply -f - << EOF

openssl s_client -connect proxy.li.k8s:443

原生：ssl cert存为secritxxx
certmangaer：定义issuer（获取证书的渠道）六种
acme 协议和ca

两种方式request你的证书，1.ingress 注解，自动生成 2.手动创建cert 先创建再使用

# install
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}'



# demo

image: 
args:
- "-text=apple"


kubectl create deployment nginx --image=hashicorp/http-echo


-listen string
  -address and port to listen (default ":5678")
  -text string


kubectl create deployment nginx --image=hashicorp/http-echo -- /http-echo -text='Hello World'



kubectl expose deployment nginx --name nginx-svc --port 80
kubectl create ingress nginx-route --class nginx --rule "cert.cloudnative.love/cert*=nginx-svc:80,tls=prod-1"

kubectl annotate ingress nginx-route cert-manager.io/cluster-issuer=



kubectl delete deployment nginx 
kubectl delete svc nginx-svc 
kubectl delete ingress nginx-route



cat <<EOF | kubectl apply -f -

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod-http01
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: song.jinfeng@outlook.com #替换为您的邮箱名。
    privateKeySecretRef:
      name: letsencrypt-http01
    solvers:
    - http01: 
        ingress:
          class: nginx
EOF









1. 执行以下命令，查看ClusterIssuer。

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-tls
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod-http01"   # 自动签发开关
spec:
  tls:
  - hosts:
    - argocd.cloudnative.love        # 替换为您的域名。
    secretName: ingress-tls   
  rules:
  - host: argocd.cloudnative.love    # 替换为您的域名。
    http:
      paths:
      - path: /
        backend:
          service:
            name: argocd-server # 替换为您的后端服务名。
            port: 
              name: https  # 替换为您的服务端口。
        pathType: ImplementationSpecific
EOF


