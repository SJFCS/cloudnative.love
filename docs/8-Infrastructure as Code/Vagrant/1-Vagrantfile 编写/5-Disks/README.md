---
title: Disks
sidebar_position: 4
---
:::tip
参考文档：https://developer.hashicorp.com/vagrant/docs/disks/configuration
:::

较旧版本的 vagrant 可使用 vagrant-disksize 插件来创建磁盘 详见：https://stackoverflow.com/questions/49822594/vagrant-how-to-specify-the-disk-size
```bash
vagrant plugin install 
```
```ruby
vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.disksize.size = '50GB'
end
```


- https://sleeplessbeastie.eu/2021/05/10/how-to-define-multiple-disks-inside-vagrant-using-virtualbox-provider/

Vagrant本身不提供连接到外部Ceph集群的插件，但是你可以尝试使用第三方插件来简化连接过程。例如，"vagrant-ceph"插件提供了一些命令来连接到Ceph集群并将其挂载到Vagrant虚拟机中。你可以通过以下命令来安装该插件：

vagrant plugin install vagrant-ceph



此功能目前需要使用实验标志。

```ruby
ENV['VAGRANT_EXPERIMENTAL'] = 'disks'
config.vm.disk :disk, name: "backup", size: "10GB"
config.vm.disk :dvd, name: "installer", file: "./installer.iso"
config.vm.disk :floppy, name: "cool_files"
```

## 调整主磁盘大小
有时，来宾的主磁盘不够大，您需要添加更多空间。要调整磁盘大小，您只需添加如下配置即可扩展您的来宾驱动器的大小：
config.vm.disk :disk, size: "100GB", primary: true

注意：这primary: true是告诉 Vagrant 扩展来宾主驱动器的内容。如果没有此选项，Vagrant 将改为将新磁盘附加到来宾。


例如，此 Ubuntu 客户机现在将配备 100GB 空间，而不是默认空间：
```ruby
Vagrant.configure("2") do |config|
  config.vm.define "hashicorp" do |h|
    h.vm.box = "hashicorp/bionic64"
    h.vm.provider :virtualbox

    h.vm.disk :disk, size: "100GB", name: "extra_storage", primary: true
  end
end
```

应该注意的是，由于 VirtualBox 的功能，不可能缩小磁盘的大小。


或者，如果您需要附加许多磁盘，您可以使用 Ruby 生成多个磁盘供 Vagrant 创建并附加到您的来宾：
```
Vagrant.configure("2") do |config|
  config.vm.define "hashicorp" do |h|
    h.vm.box = "hashicorp/bionic64"
    h.vm.provider :virtualbox

    (0..3).each do |i|
      h.vm.disk :disk, size: "5GB", name: "disk-#{i}"
    end
  end
end
```
注意：VirtualBox 对可以连接到给定存储控制器的磁盘数量有硬性限制，这是由控制器类型定义的。尝试配置多于主控制器支持的磁盘将导致 Vagrant 错误。

## 连接光驱
Vagrant 可以.iso使用 VirtualBox 提供程序将文件附加为光驱。可以在下面找到将光驱连接到客户机的示例：
```
Vagrant.configure("2") do |config|
  config.vm.define "hashicorp" do |h|
    h.vm.box = "hashicorp/bionic64"
    h.vm.provider :virtualbox

    h.vm.disk :dvd, name: "installer", file: "./installer.iso"
  end
end
```
与硬盘一样，配置的磁盘数量超过 VM 的存储控制器安排所支持的数量将导致 Vagrant 错误。

移除磁盘
如果你已经从你的 Vagrant 配置中删除了一个磁盘并希望它与来宾分离，你将需要vagrant reload你的来宾应用这些更改。注意：删除由 Vagrant 创建的虚拟硬盘也会从您的硬盘驱动器中删除该介质。




## 案例


为了利用循环h.vm.provider简化配置实例，我们可以使用vagrant的config.vm.disk选项。这个选项允许我们指定虚拟机的磁盘大小，并且可以使用循环变量来创建多个磁盘。

例如，假设我们想要创建3个虚拟机，每个虚拟机都有2个磁盘，第一个磁盘大小为10GB，第二个磁盘大小为20GB。我们可以使用以下Vagrantfile：

```ruby
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "vm#{i}" do |h|
      h.vm.box = "ubuntu/bionic64"
      h.vm.network "private_network", ip: "192.168.33.#{i}"
      h.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
        (1..2).each do |j|
          v.disk :disk, size: (j == 1 ? 10 : 20)
        end
      end
    end
  end
end
```
在这个例子中，我们使用了一个循环变量i来创建3个虚拟机，每个虚拟机都有一个唯一的名称（例如vm1，vm2和vm3）。在每个虚拟机的配置块中，我们使用了另一个循环变量j来创建两个磁盘，第一个磁盘大小为10GB，第二个磁盘大小为20GB。


使用这个Vagrantfile，我们可以使用vagrant up命令来启动所有的虚拟机。每个虚拟机都会有两个磁盘，大小分别为10GB和20GB。



## ex

```ruby
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "vm#{i}" do |h|
      h.vm.box = "ubuntu/bionic64"
      h.vm.network "private_network", ip: "192.168.33.#{i}"
      %w(virtualbox vmware_workstation).each do |provider|
        h.vm.provider provider do |v|
          v.memory = 1024
          v.cpus = 1
          (1..2).each do |j|
            if provider == "virtualbox"
              v.disk :disk, size: (j == 1 ? 10 : 20)
            elsif provider == "vmware_workstation"
              v.disk :scsi, size: (j == 1 ? 10 : 20)
            end
          end
        end
      end
    end
  end
end
```
在这个例子中，我们使用了循环变量provider来定义两个provider: virtualbox和vmware_workstation，并且在每个provider的配置块中都使用了一个循环变量j来创建两个磁盘，第一个磁盘大小为10GB，第二个磁盘大小为20GB。我们使用了if语句来判断当前的provider是virtualbox还是vmware_workstation，并相应地创建磁盘。


使用这个Vagrantfile，我们可以使用vagrant up命令来启动所有的虚拟机。每个虚拟机都会有两个磁盘，大小分别为10GB和20GB，并且支持两个provider：virtualbox和vmware_workstation。这个Vagrantfile比之前的版本更加简洁，也更易于维护。


## ex

我希望将磁盘大小和数量还有provider 作为变量，放在开头可以灵活定义。

```ruby
Vagrant.configure("2") do |config|
  # Define variables
  num_vms = 3
  disk_sizes = [10, 20]
  disk_count = disk_sizes.length
  providers = ["virtualbox", "vmware_workstation"]

  # Loop through VMs
  (1..num_vms).each do |i|

  # (1..num_vms) 是一个 Ruby 中的 Range 对象，表示从 1 到 num_vms 的一个整数范围。这个范围包含了从 1 开始一直到 num_vms 结束的所有整数。在 Vagrantfile 中，我们使用这个范围来循环遍历创建虚拟机的数量，例如 (1..3) 表示循环三次，分别创建三个虚拟机。

    config.vm.define "vm#{i}" do |h|
      h.vm.box = "ubuntu/bionic64"
      h.vm.network "private_network", ip: "192.168.33.#{i}"

      # Loop through providers
      providers.each do |provider|
        h.vm.provider provider do |v|
          v.memory = 1024
          v.cpus = 1

          # Loop through disks
          (1..disk_count).each do |j|
            disk_size = disk_sizes[j-1]
# 这行代码是用来获取 disk_sizes 数组中指定位置的磁盘大小。由于数组下标从 0 开始，而我们在循环变量 j 中是从 1 开始的，所以在这里需要将 j 减去 1 来获取正确的下标。例如，当 j 等于 1 时，我们需要获取 disk_sizes 数组中的第一个元素，即 disk_sizes[0]；当 j 等于 2 时，我们需要获取 disk_sizes 数组中的第二个元素，即 disk_sizes[1]。所以我们通过 disk_sizes[j-1] 来获取正确的磁盘大小。
            if provider == "virtualbox"
              v.disk :disk, size: disk_size
            elsif provider == "vmware_workstation"
              v.disk :scsi, size: disk_size
# 这里的判断是为了根据不同的 provider 创建不同类型的磁盘。在 Vagrant 中，不同的虚拟化软件（如 VirtualBox、VMware、Hyper-V 等）提供的虚拟机硬件设备可能有所不同，例如磁盘的类型和控制器的类型可能不同。因此，在创建虚拟机时，我们需要根据当前使用的 provider 来指定正确的磁盘类型和控制器类型，以确保虚拟机能够正常运行。

# 在这个例子中，我们使用了两个 provider：virtualbox 和 vmware_workstation，它们分别使用不同的磁盘类型和控制器类型。当 provider 等于 "virtualbox" 时，我们使用 :disk 磁盘类型来创建磁盘，这是 VirtualBox 默认的磁盘类型；当 provider 等于 "vmware_workstation" 时，我们使用 :scsi 磁盘类型来创建磁盘，这是 VMware Workstation 默认的磁盘类型。通过这种方式，我们可以根据不同的 provider 创建不同类型的磁盘，确保虚拟机能够在不同的虚拟化软件中正确运行。              
            end
          end
        end
      end
    end
  end
end
```
在这个例子中，我们在Vagrantfile的开头定义了四个变量：num_vms，disk_sizes，disk_count和providers。num_vms表示要创建的虚拟机数量，disk_sizes表示要创建的磁盘大小（可以根据需要添加或删除），disk_count表示磁盘数量（等于disk_sizes的长度），providers表示要使用的provider（可以根据需要添加或删除）。


在Vagrantfile的主体部分，我们使用了循环变量i来创建num_vms个虚拟机，并使用循环变量provider来循环遍历providers数组中的每个元素。在每个provider的配置块中，我们使用了循环变量j来循环遍历disk_sizes数组中的每个元素，并根据当前的provider创建相应的磁盘。

