https://bbs.archlinux.org/viewtopic.php?id=266965
https://github.com/teejee2008/timeshift/issues/141
https://gist.github.com/ovelny/12ccdb8ebcaaecaebdab228e902dfef5

sudo btrfs subvolume list /
删除除了/@ /@home 之外的多余子卷，你可以放心的删除因为这些只是快照，不会对系统产生影响
sudo btrfs subvolume delete  /run/timeshift/4647/backup/timeshift-btrfs/snapshots/2022-10-12_20-03-45/@/var/lib/docker/btrfs/subvolumes/127cfe68f701e5efa14a34513d8dc451d9db40c4c993807a7745395249d18f2f

如果找不到timeshift目录则重启后 打开timeshift 再次查看
``` bash
/run/timeshift/4647/backup
#  [每次启动 timeshift 会自动生成新id，可指定fstab挂载来避免随机id产生，方便grub-btrfs 自动生成](https://teejeetech.medium.com/linux-multiboot-with-btrfs-luks-and-efi-part-2-7b0896c03cce)
drwxr-xr-x 1 root root    210 10月14日 10:34 timeshift-btrfs
drwxr-xr-x 1 root root    142  9月13日 10:29 @
drwxr-xr-x 1 root root      0  9月10日 10:59 @.snapshots
drwxr-xr-x 1 root root     10  9月10日 11:06 @home
drwxr-xr-x 1 root root    312 10月14日 08:47 @log
drwxr-xr-x 1 root root 300488 10月14日 09:14 @pkg
❯ ls timeshift-btrfs
# 手动创建的快照在 snapshots 目录
snapshots  snapshots-boot  snapshots-daily  snapshots-hourly  snapshots-monthly  snapshots-ondemand  snapshots-weekly
❯ pwd
/run/timeshift/4647/backup
```
修改systemctl edit 默认编辑器 https://unix.stackexchange.com/questions/408413/change-default-editor-to-vim-for-sudo-systemctl-edit-unit-file