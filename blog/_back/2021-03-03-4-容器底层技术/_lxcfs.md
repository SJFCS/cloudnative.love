xcfs 是一个开源的 FUSE（用户态文件系统）实现来支持 LXC 容器，它也可以支持 Docker 容器。让容器内的应用在读取内存和 CPU 信息的时候通过 lxcfs 的映射，转到自己的通过对 cgroup 中容器相关定义信息读取的虚拟数据上。

https://zhuanlan.zhihu.com/p/106719192

https://www.lixueduan.com/posts/docker/05-namespace/
https://www.thebyte.com.cn/container/namespace.html