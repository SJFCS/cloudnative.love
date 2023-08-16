我记得py环境报错了

docker 起一个 再写个helm
https://juejin.cn/post/7205092009262055485
https://gitlab.com/msarmadi/stable-diffusion-webui-docker/-/blob/main/Dockerfile.Stable?ref_type=heads
https://cloud-atlas.readthedocs.io/zh_CN/latest/machine_learning/stable_diffusion/stable_diffusion_on_k8s.html
https://github.com/amithkk/stable-diffusion-k8s


gpu 观测https://medium.com/@rajupavuluri/how-to-expose-and-visualize-gpu-metrics-in-your-kubernetes-cluster-2520a7c3ba37
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: stable-diffusion
    qcloud-app: stable-diffusion
  name: stable-diffusion
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: stable-diffusion
      qcloud-app: stable-diffusion
  template:
    metadata:
      annotations:
        eks.tke.cloud.tencent.com/gpu-type: A10*GNV4v
        eks.tke.cloud.tencent.com/root-cbs-size: "40"
      labels:
        k8s-app: stable-diffusion
        qcloud-app: stable-diffusion
    spec:
      containers:
      - args:
        - --listen
        image: ccr.ccs.tencentyun.com/ai-aigc/stable-diffusion:taco.gpu.v1
        imagePullPolicy: IfNotPresent
        name: stable-diffusion
        resources:
          limits:
            cpu: "28"
            memory: 116Gi
            nvidia.com/gpu: "1"
          requests:
            cpu: "28"
            memory: 116Gi
            nvidia.com/gpu: "1"
        securityContext:
          privileged: false
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      imagePullSecrets:
      - name: qcloudregistrykey
      restartPolicy: Always
      terminationGracePeriodSeconds: 30


---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: stable-diffusion
    qcloud-app: stable-diffusion
  name: stable-diffusion
  namespace: default
spec:
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: 7860-7860-tcp
    port: 7860
    protocol: TCP
    targetPort: 7860
  selector:
    k8s-app: stable-diffusion
    qcloud-app: stable-diffusion
  sessionAffinity: None
  type: LoadBalancer

```






```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stable-diffusion-webui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stable-diffusion-webui
  template:
    metadata:
      labels:
        app: stable-diffusion-webui
    spec:
      nodeSelector:
        cloud.google.com/gke-accelerator: "nvidia-tesla-t4"
        # remove this node selector if you don't want to use spot
        cloud.google.com/gke-spot: "true"
      containers:
      - name: sd
        image: $IMAGE
        env:
        - name: LD_LIBRARY_PATH
          value: /usr/local/nvidia/lib64
        resources:
          limits:
            nvidia.com/gpu: 1
          requests:
            cpu: "3500m"
            memory: "14Gi"
            ephemeral-storage: 10Gi


            envsubst < stable-diffusion.yaml | kubectl apply -f -


kubectl port-forward deployment/stable-diffusion-webui 7860:7860



kubectl expose deployment stable-diffusion-webui \
  --type=LoadBalancer --name=stable-diffusion-webui \
  --port=80 --target-port=7860
kubectl get services stable-diffusion-webui
现在您应该可以访问http://external_ipStable Diffusion Web UI


```