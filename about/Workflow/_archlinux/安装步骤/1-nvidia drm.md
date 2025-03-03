
# 新显卡建议使用nvidia-open
# nvidia drm
sudo vim /etc/mkinitcpio.conf
MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)
sudo mkinitcpio -P
sudo vim /etc/default/grub 文件，并添加 nvidia_drm.modeset=1 
sudo grub-mkconfig -o /boot/grub/grub.cfg
为了避免在 NVIDIA 驱动程序升级后忘记更新initramfs的可能性，您可能需要使用pacman hook：
sudo mkdir -p /etc/pacman.d/hooks
sudo vim /etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
# Uncomment the installed NVIDIA package
Target=nvidia
Target=nvidia-open
Target=nvidia-lts
# If running a different kernel, modify below to match
Target=linux
[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'




