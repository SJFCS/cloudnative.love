https://wiki.archlinux.org/title/Vulkan
sudo pacman -S vulkan-headers vulkan-validation-layers vulkan-tools 


https://wiki.archlinux.org/title/PRIME#PRIME%20render%20offload
sudo pacman -S  nvidia-prim
sudo pacman -S glxinfo

prime-run glxinfo | grep "OpenGL renderer"
prime-run vulkaninfo


https://gitlab.freedesktop.org/hadess/switcheroo-control
paru -S  switcheroo-control

systemctl start  switcheroo-control.service
gdbus introspect --system --dest net.hadess.SwitcherooControl --object-path /net/hadess/SwitcherooControl\n
