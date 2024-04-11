---
title: Synced Folders
sidebar_position: 5
---
:::tip
参考文档：https://developer.hashicorp.com/vagrant/docs/synced-folders
:::
## 挂载目录

```ruby
Vagrant.configure("2") do |config|
  # ...
  device.vm.synced_folder "your_folder", "vm_folder",  #(必须)物理机目录 虚拟机上的目录
  create: true,#--可选     //默认为false，若配置为true，挂载到虚拟机上的目录若不存在则自动创建
  owner: "vagrant",#--可选   //虚拟机系统下文件所有者(确保系统下有该用户，否则会报错)，默认为vagrant
  group: "vagrant",#--可选   //虚拟机系统下文件所有组( (确保系统下有该用户组，否则会报错)，默认为vagrant
  mount_options: ["dmode=755","fmode=644"], #--可选  //dmode配置目录权限，fmode配置文件权限  默认权限777
  type: "rsync", #--可选     //指定文件共享方式，例如：'nfs'，vagrant默认根据系统环境选择最佳的文件共享方式
  disabled: "false" #--可选   //默认为false，若为true,则禁用该项挂载

end
```

vagrant-vbgues t是一个Vagrant插件，它会自动在来宾系统上安装主机的 VirtualBox Guest Additions。
- https://github.com/dotless-de/vagrant-vbguest

```
vagrant plugin install vagrant-vbguest
```

在默认情况下，文件同步会有一些性能问题，因为它是通过 VirtualBox 的共享文件夹功能实现的。如果需要更好的性能和可靠性，可以考虑使用其他文件同步方式，比如 NFS 或 rsync。例如，下面的配置将使用 NFS 来进行文件同步：

需要注意的是，使用 NFS 或 rsync 进行文件同步可能需要安装额外的软件，并且在不同的操作系统上配置方式可能会有所差异。
