---
title: Disks
sidebar_position: 4
---
:::tip
- 参考文档：https://developer.hashicorp.com/vagrant/docs/disks/configuration
- 扩展阅读：https://sleeplessbeastie.eu/2021/05/10/how-to-define-multiple-disks-inside-vagrant-using-virtualbox-provider/
:::

较旧版本的 vagrant 可使用 vagrant-disksize 插件来创建磁盘 详见：https://stackoverflow.com/questions/49822594/vagrant-how-to-specify-the-disk-size ，新版本 vagrant 需要开启实验标志 `VAGRANT_EXPERIMENTAL`。可选参数如下：

```ruby
ENV['VAGRANT_EXPERIMENTAL'] = 'disks'
config.vm.disk :disk, name: "backup", size: "100GB", primary: true
config.vm.disk :dvd, name: "installer", file: "./installer.iso"
config.vm.disk :floppy, name: "cool_files"
```

:::warning注意
指定 `primary: true` Vagrant 将扩展来宾系统盘容量。如果没有此选项，Vagrant 将改为将新磁盘附加到来宾。

VirtualBox 不可缩小磁盘的大小。

VirtualBox 对可以连接到给定存储控制器的磁盘数量有硬性限制，这是由控制器类型定义的。尝试配置多于主控制器支持的磁盘将导致 Vagrant 错误。
:::

## 示例

- 指定 100G 系统盘
- 添加 200G 的扩展磁盘：
- 添加./installer.iso 挂载到光驱
- 设置启动顺序磁盘优先
```ruby
ENV['VAGRANT_EXPERIMENTAL'] = 'disks'
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  node.vm.provider "virtualbox" do |vb|
    # 设置启动顺序
    vb.customize ["modifyvm", :id, "--boot1", "disk"]
    vb.customize ["modifyvm", :id, "--boot2", "dvd"]
    vb.customize ["modifyvm", :id, "--boot3", "none"]
  end
  config.vm.disk :disk, size: "100GB", name: "main_storage", primary: true
  config.vm.disk :disk, size: "200GB", name: "extra_storage"
  config.vm.disk :dvd, name: "installer", file: "./installer.iso"
end
```
