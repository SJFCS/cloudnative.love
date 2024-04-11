mount -o subvol=@ /dev/nvme01p2 /mnt
mount -o subvol=@home /dev/nvme01p2 /mnt/home

mount --bind /proc /mnt /proc
mount --bind /sys /mnt /sys
mount --bind /dev /mnt /dev

arch-chroot /mnt



grub--e--linux /boot/vmlinuz-linux root=UUID=xxx ... systemd.unit=,ulti-user.target---crtl+x


systemctl set-default multi-user.target

systemctl get-default

systemctl set-default graphical.target

systemctl restart gdm
systemctl isolate graphical.target




asusctl graphics -m integrate|nvidia|hybrid|vfio

asusctl bios -d
asusctl bios -D 0|1





https://forum.level1techs.com/t/graphics-tearing-in-looking-glass-client-window-output/155781/12

https://looking-glass.io/docs/B6-rc1/usage/

