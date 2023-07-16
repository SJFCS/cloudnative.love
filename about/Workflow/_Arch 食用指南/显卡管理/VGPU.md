https://github.com/DualCoder/vgpu_unlock/blob/f432ffc8b7ed245df8858e9b38000d3b8f0352f4/vgpu_unlock_hooks.c#L805-L840

https://github.com/jakogut/vgpu_unlock/blob/0675b563acdae8f6c5eb1a760fc0e5b853b1a63e/vgpu_unlock_hooks.c#L706-L745



sudo pacman -S python python-pip

python -m venv pythonenv/vgpu_unlock
paru -S python-frid






cd /opt && git clone https://github.com/mbilker/vgpu_unlock-rs.git
cd /opt/vgpu_unlock-rs
cargo build –release
mkdir /etc/systemd/system/{nvidia-vgpud.service.d,nvidia-vgpu-mgr.service.d}
echo -e “[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so” > /etc/systemd/system/nvidia-vgpud.service.d/vgpu_unlock.conf
echo -e “[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so” > /etc/systemd/system/nvidia-vgpu-mgr.service.d/vgpu_unlock.conf
systemctl daemon-reload

## 硬件设置
确认您的[硬件受支持](https://krutavshah.github.io/GPU_Virtualization-Wiki/overview.html#supported-hardware)后
https://docs.nvidia.com/grid/gpus-supported-by-vgpu.html
，进入主板的固件设置菜单并启用以下选项：

虚拟化扩展/支持（也称为 Intel VT-x 或 AMD-V）
IOMMU（也称为 Intel VT-d 或 AMD-Vi）

## 启用IOMMU

即使在系统固件中启用了 IOMMU，也必须告知 Linux 在引导时启用 IOMMU。为此，您必须向内核命令行添加几个参数。

- 英特尔：intel_iommu=on iommu=pt
- AMD：amd_iommu=on iommu=pt

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/managing-virtual-devices_configuring-and-managing-virtualization#attaching-sr-iov-networking-devices-to-virtual-machines_managing-sr-iov-devices

## 获取驱动程序和许可
https://www.nvidia.com/en-us/data-center/resources/vgpu-evaluation/ 申请 NVIDIA vGPU 的 90 天评估。。。。 fastapi-dls

## 安装依赖
DKMS
Kernel Headers
Rust
git
mdevctl
patch

RHEL：
dnf install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
dnf --enablerepo="epel" install dkms kernel-devel mdevctl git patch rust rust-cargo
Debian/Ubuntu：
apt-get install dkms linux-headers mdevctl git patch rustc cargo
Arch:
pacman -S dkms linux-headers mdevctl git patch rust






















057177928938  

sudo grub-mkconfig -o /boot/grub/grub.cfg

更新 initramfs


sudo mkinitcpio -P

cp target/release/libvgpu_unlock_rs.so /lib/nvidia/libvgpu_unlock_rs.so


journalctl -u nvidia-vgpud.service
journalctl -u nvidia-vgpu-mgr.service

https://wvthoog.nl/proxmox-7-vgpu-v2/#Mdevctl