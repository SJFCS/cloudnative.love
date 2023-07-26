使用 docker export 命令将 docker.io/nvidia/cuda 镜像导出到一个tar文件中，然后将其解压到新的 rootfs 中，然后使用 chroot 命令进入新的 rootfs 环境并安装任何必需的软件包。

docker save docker.io/nvidia/cuda:12.2.0-devel-ubuntu20.04 | gzip > cuda.tar.gz

mkdir new_rootfs
tar -xzf cuda.tar.gz -C new_rootfs
sudo chroot new_rootfs

请注意，这种方法并不是最佳实践。通常，建议使用Docker或其他容器