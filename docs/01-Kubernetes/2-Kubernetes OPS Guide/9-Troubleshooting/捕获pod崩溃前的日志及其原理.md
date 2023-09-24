当pod处于crash状态的时候，容器不断重启，此时用 kubelet logs 可能出现一直捕捉不到日志。解决方法：

`kubectl previous` 参数作用：**If true, print the logs for the previous instance of the container in a pod if it exists.**

```bash
kubectl logs pod-name --previous
kubectl logs pod-name --previous -c container-name
```



kubelet会保持pod的前几个失败的容器，这个是查看的前提条件。kubelet实现previous的原理：将pod的日志存放在 /var/log/pods/podname，并且是链接文件，链接到docker的容器的日志文件，同时kubelet还会保留上一个容器，同时有一个链接文件链接到pod上一个崩溃的容器的日志文件，使用previous就是查看的这个文件
```bash
 ls /var/log/pods/default_busybox_f72ab71a-5b3b-4ecf-940d-28a5c3b30683/busybox
2393.log  2394.log
数字的含义：2393 证明是第 2393 次重启后的日志

/busybox# stat 2393.log
  File: 2393.log -> /data/kubernetes/docker/containers/68a5b32c9fdb1ad011b32e6252f9cdb759f69d7850e6b7b8591cb4c2bf00bcca/68a5b32c9fdb1ad011b32e6252f9cdb759f69d7850e6b7b8591cb4c2bf00bcca-json.log
  Size: 173           Blocks: 8          IO Block: 4096   symbolic link
Device: fc02h/64514d    Inode: 529958      Links: 1
Access: (0777/lrwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-31 13:32:03.751514283 +0800
Modify: 2023-01-31 13:32:03.039526838 +0800
Change: 2023-01-31 13:32:03.039526838 +0800
 Birth: -
```

kubelet读的是 /var/log/pods/ 下的日志文件，–previous 读的也是 /var/log/pods/ 下的日志文件，且专门有个链接文件来指向上一个退出容器的日志文件，以此来获取容器崩溃前的日志。