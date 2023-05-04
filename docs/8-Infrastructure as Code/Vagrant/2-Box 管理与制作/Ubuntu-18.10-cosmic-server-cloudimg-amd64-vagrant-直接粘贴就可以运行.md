#### 前提：在命令运行的目录路径下准备好 Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box
```
# 步骤01 导入vagrant官方的ubuntu-1804虚拟机模板
vagrant box add Ubuntu-18.10-cosmic-server-cloudimg-amd64 Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box

# 步骤02 编写Vagrantfile文件

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :ubuntu1810 do |ubuntu1810|
    ubuntu1810.vm.box = "Ubuntu-18.10-cosmic-server-cloudimg-amd64"
    ubuntu1810.vm.hostname = "ubuntu-1810"
    ubuntu1810.vm.synced_folder ".", "/vagrant", disabled: true
    ubuntu1810.vm.network :private_network, ip: "192.168.35.11"
    ubuntu1810.vm.provider "virtualbox" do |vb|
      vb.customize [ "modifyvm", :id, "--name", "Ubuntu-18.10-cosmic-server-cloudimg-amd64", "--memory", "1024", "--cpus", "2", "--uartmode1", "disconnected" ]
    end
  end
end

# 步骤05 在宿主机导出虚拟机
vagrant package --base=Ubuntu-18.10-cosmic-server-cloudimg-amd64 --output=Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box
vagrant box remove -f ubuntu-1810-template
vagrant box remove -f Ubuntu-18.10-cosmic-server-cloudimg-amd64
vagrant box add ubuntu-1810-template Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box

```
