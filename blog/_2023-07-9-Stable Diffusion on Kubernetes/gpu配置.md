## Nvidia 驱动
准备编译环境
sudo pacman -S --needed base-devel

然后官网下载驱动
https://www.nvidia.com/Download/Find.aspx

ps：dkms是什么

验证 nvidia-smi

ps:如果使用vgpu请移步

参考文档
ubuntu https://towardsdatascience.com/deep-learning-gpu-installation-on-ubuntu-18-4-9b12230a1d31
arch https://wiki.archlinux.org/title/NVIDIA
nvdia https://docs.nvidia.com/datacenter/tesla/index.html

## CUDA 驱动
CUDA（Compute Unified Device Architecture）是 NVIDIA 推出的通用并行计算架构，该架构使 GPU 能够解决复杂的计算问题。
官网：https://developer.nvidia.com/cuda-toolkit-archive

配置环境变量
```
$ echo 'export PATH=/usr/local/cuda/bin:$PATH' | sudo tee /etc/profile.d/cuda.sh
$ source /etc/profile
```


## nvidia-container-runtime
https://icloudnative.io/posts/add-nvidia-gpu-support-to-k8s-with-containerd/
https://earthly.dev/blog/buildingrunning-nvidiacontainer/
其他发行版可参照这里配置软件源，https://github.com/NVIDIA/nvidia-container-runtime

nvidia-container-runtime 是在 runc 基础上多实现了 nvidia-container-runime-hook(现在叫 nvidia-container-toolkit)，该 hook 是在容器启动后（Namespace已创建完成），容器自定义命令(Entrypoint)启动前执行。当检测到 NVIDIA_VISIBLE_DEVICES 环境变量时，会调用 libnvidia-container 挂载 GPU Device 和 CUDA Driver。如果没有检测到 NVIDIA_VISIBLE_DEVICES 就会执行默认的 runc。

### nvidia-docker2
https://docs.docker.com/engine/install/ubuntu/
### 配置 Containerd 使用 Nvidia container runtime
https://developer.nvidia.com/nvidia-container-runtime
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
https://gitlab.com/nvidia/container-toolkit/container-toolkit/-/tree/main

配置 Containerd 使用 Nvidia container runtime
https://developer.nvidia.com/blog/announcing-containerd-support-for-the-nvidia-gpu-operator/
https://josephb.org/blog/containerd-nvidia/

```
sudo mkdir /etc/containerd
sudo sh -c "containerd config default >  /etc/containerd/config.toml"


Kubernetes 使用 设备插件（Device Plugins） 来允许 Pod 访问类似 GPU 这类特殊的硬件功能特性，但前提是默认的 OCI runtime 必须改成 nvidia-container-runtime，需要修改的内容如下：
https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/
```

```
...
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
...
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runtime.v1.linux" # 将此处 runtime_type 的值改成 io.containerd.runtime.v1.linux
...
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "nvidia-container-runtime" # 将此处 runtime 的值改成 nvidia-container-runtime
...

systemctl restart containerd

```


测试
ctr 添加用户权限
```
$ sudo ctr images pull docker.io/nvidia/cuda:12.2.0-devel-ubuntu20.04
$ sudo ctr run --rm -t --gpus 0 docker.io/nvidia/cuda:12.2.0-devel-ubuntu20.04 nvidia-smi nvidia-smi
```
gpu-pod.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1
```
```
$ kubectl logs cuda-vector-add
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
```




部署 NVIDIA GPU 设备插件
```bash
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml


kubectl -n kube-system logs nvidia-device-plugin-daemonset-xxx
2020/12/04 06:30:28 Loading NVML
2020/12/04 06:30:28 Starting FS watcher.
2020/12/04 06:30:28 Starting OS watcher.
2020/12/04 06:30:28 Retreiving plugins.
2020/12/04 06:30:28 Starting GRPC server for 'nvidia.com/gpu'
2020/12/04 06:30:28 Starting to serve 'nvidia.com/gpu' on /var/lib/kubelet/device-plugins/nvidia-gpu.sock
2020/12/04 06:30:28 Registered device plugin for 'nvidia.com/gpu' with Kubelet

可以看到设备插件部署成功了。在 Node 上面可以看到设备插件目录下的 socket：

$ ll /var/lib/kubelet/device-plugins/
total 12
drwxr-xr-x 2 root root 4096 Dec  4 01:30 ./
drwxr-xr-x 8 root root 4096 Dec  3 05:05 ../
-rw-r--r-- 1 root root    0 Dec  4 01:11 DEPRECATION
-rw------- 1 root root 3804 Dec  4 01:30 kubelet_internal_checkpoint
srwxr-xr-x 1 root root    0 Dec  4 01:11 kubelet.sock=
srwxr-xr-x 1 root root    0 Dec  4 01:11 kubevirt-kvm.sock=
srwxr-xr-x 1 root root    0 Dec  4 01:11 kubevirt-tun.sock=
srwxr-xr-x 1 root root    0 Dec  4 01:11 kubevirt-vhost-net.sock=
srwxr-xr-x 1 root root    0 Dec  4 01:30 nvidia-gpu.sock=





$ cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  restartPolicy: Never
  containers:
    - name: cuda-container
      image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda10.2
      resources:
        limits:
          nvidia.com/gpu: 1 # requesting 1 GPU
  tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
EOF


$ kubectl logs gpu-pod
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
```

https://developer.nvidia.com/blog/announcing-containerd-support-for-the-nvidia-gpu-operator/

