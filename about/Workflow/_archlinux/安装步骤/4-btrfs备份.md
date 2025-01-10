我将快照方案从 timeshift timeshift-autosnap grub-btrfs 迁移到了 yabsnap grub-btrfs

下面是yabsnap官网给出的对比图。相对来说我更喜欢yabsnap带来的灵活性和易用性

|                     | yabsnap | timeshift                  | snapper                |
| ------------------- | ------- | -------------------------- | ---------------------- |
| Custom sources      | ✓       | Only root and home         | ✓                      |
| Custom destinations | ✓       |                            |                        |
| Pacman hook         | ✓       | Via timeshift-autosnap (2) | Via snap-pac           |
| File system         | btrfs   | btrfs, ext4                | btrfs                  |
| GUI                 |         | ✓                          | With snapper-gui       |
| Rollback            | ✓       | ✓                          | Only default subvolume |

快照脚本https://coda.world/btrfs-snapshot
btrfs妙用https://www.aloxaf.com/2020/11/wow_such_linux_many_files_so_small/
社区方案https://blog.kaaass.net/archives/1748
恢复文件https://github.com/danthem/undelete-btrfs/
timeshift例子https://www.lorenzobettini.it/2022/07/timeshift-and-grub-btrfs-in-linux-arch/

**注意要安装前删除fstab中的subvolid变为subvol的形式**

paru -S yabsnap
yabsnap create-config root
编辑 source = /
yabsnap create-config home
编辑 source = /home

yabsnap create --comment 'COMMENT'
yabsnap --source '/home' create --comment 'COMMENT'
yabsnap list

yabsnap rollback-gen 20221006143047
sudo btrfs subvolume delete /.snapshots/rollback_20241003014429_@


grub-btrfs添加了对yabsnap快照信息的支持：[pull/318](https://github.com/Antynea/grub-btrfs/pull/318)
通过读取/.snapshots/*-meta.json文件实现的：[代码在这](https://github.com/Antynea/grub-btrfs/blob/f682e17b30def8ebbf9b4b3f0a60df0443633e4c/41_snapshots-btrfs#L332-L344)
截止2024.10.03 arch源中的grub-btrfs包版本与实际安装版本不符，其不包含对yabsnap快照信息的支持：https://github.com/Antynea/grub-btrfs/issues/354

# 所以暂时先手动安装 而不直接安装 pacman -S grub-btrfs inotify-tools
pacman -S inotify-tools
git clone https://github.com/Antynea/grub-btrfs.git
sudo make install
sudo systemctl enable --now  grub-btrfsd 
# 查看版本
sudo /etc/grub.d/41_snapshots-btrfs --version
# 手动生成引导
sudo /etc/grub.d/41_snapshots-btrfs 
grub-mkconfig -o /boot/grub/grub.cfg


# faq
https://bbs.archlinux.org/viewtopic.php?id=266965
```bash
[admin@archlinux ~]$ sudo btrfs subvolume delete “/.snapshots/rollback_20241003014429_@”
ERROR: Could not statfs: No such file or directory
# 这个错误表明该子卷下还有内容，不能直接删除。你可以先删除子卷中的所有内容，然后再尝试删除子卷。使用以下命令：
[admin@archlinux ~]$ mount | grep btrfs
/dev/nvme0n1p2 on / type btrfs (rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=277,subvol=/@)
/dev/nvme0n1p2 on /.snapshots type btrfs (rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=260,subvol=/@.snapshots)
/dev/nvme0n1p2 on /var/log type btrfs (rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=258,subvol=/@log)
/dev/nvme0n1p2 on /var/cache/pacman/pkg type btrfs (rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=259,subvol=/@pkg)
/dev/nvme0n1p2 on /home type btrfs (rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=278,subvol=/@home)

[admin@archlinux ~]$ sudo btrfs subvolume list /
ID 256 gen 1646 top level 260 path @.snapshots/rollback_20241003014429_@
ID 258 gen 2024 top level 5 path @log
ID 259 gen 1749 top level 5 path @pkg
ID 260 gen 2004 top level 5 path @.snapshots
ID 261 gen 14 top level 256 path @.snapshots/rollback_20241003014429_@/var/lib/portables
ID 262 gen 14 top level 256 path @.snapshots/rollback_20241003014429_@/var/lib/machines
ID 277 gen 2022 top level 5 path @
ID 278 gen 2024 top level 5 path @home

[admin@archlinux ~]$ sudo btrfs subvolume delete /.snapshots/rollback_20241003014429_@/var/lib/portables
Delete subvolume 261 (no-commit): '/.snapshots/rollback_20241003014429_@/var/lib/portables'
[admin@archlinux ~]$ sudo btrfs subvolume delete /.snapshots/rollback_20241003014429_@/var/lib/machines
Delete subvolume 262 (no-commit): '/.snapshots/rollback_20241003014429_@/var/lib/machines'
[admin@archlinux ~]$ sudo btrfs subvolume delete /.snapshots/rollback_20241003014429_@
Delete subvolume 256 (no-commit): '/.snapshots/rollback_20241003014429_@'
```