---
title: 三、 访问dashboard

---



## 1. 创建service
```bash
$ cat > dashboard-svc.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  namespace: kube-system
  name: dashboard
  labels:
    app: dashboard
spec:
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard
  ports:
  - name: https
    nodePort: 30000
    port: 443
    targetPort: 8443
EOF

$ kubectl apply -f dashboard-svc.yaml
```

## 2. 访问dashboard

为了集群安全，从 1.7 开始，dashboard 只允许通过 https 访问，我们使用nodeport的方式暴露服务，可以使用 https://NodeIP:NodePort 地址访问 
关于自定义证书 
默认dashboard的证书是自动生成的，肯定是非安全的证书，如果大家有域名和对应的安全证书可以自己替换掉。使用安全的域名方式访问dashboard。 
在dashboard-all.yaml中增加dashboard启动参数，可以指定证书文件，其中证书文件是通过secret注进来的。

> \- –tls-cert-file  
  \- dashboard.cer  
  \- –tls-key-file  
  \- dashboard.key

## 3. 登录dashboard
Dashboard 默认只支持 token 认证，所以如果使用 KubeConfig 文件，需要在该文件中指定 token，我们这里使用token的方式登录
```bash
# 创建Service account
$ kubectl create sa dashboard-admin -n kube-system

# 创建角色绑定关系
$ kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

# 查看dashboard-admin的secret名字
$ ADMIN_SECRET=$(kubectl get secrets -n kube-system | grep dashboard-admin | awk '{print $1}')

# 打印secret的token
$ kubectl describe secret -n kube-system ${ADMIN_SECRET} | grep -E '^token' | awk '{print $2}'
```