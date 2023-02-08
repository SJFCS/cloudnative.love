---
title: Vagrant
tags: [Infrastructure as Code & Automation,HashiCorp,Vagrant]
---

End kernel panic - not syncing attempted to kill the idle task

Linux内核kernel panic

调整内存 cpu 开启嵌套分页 PAE/NX  ：Enable IO APIC和Enable PAE/NX

Vagrant常用命令：https://curder.gitbooks.io/blog/content/tools/vagrant/vagrant-common-commands.html?q=
vbox参数文档：https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/configuration
hVagrantfile参考文件：ttps://github.com/ddometita/mmumshad-kubernetes-the-hard-way/blob/master/vagrant/Vagrantfile

```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end
    config.vm.define "node-1" do |node1|
        node1.vm.box = "ubuntu/trusty64"
        node1.vm.network "private_network", ip: "192.168.56.10"
        node1.vm.hostname = "node-1"
        node1.vm.provision "shell", inline: <<-SHELL
        echo "i'm node-1"
        sudo timedatectl set-timezone Asia/Shanghai
        SHELL
        end
    config.vm.define "node-2" do |node2|
        node2.vm.box = "ubuntu/trusty64"
        node2.vm.network "private_network", ip: "192.168.56.20"
        node2.vm.hostname = "node-2"
        node2.vm.provision "shell", inline: <<-SHELL
            sudo echo "192.168.10.21 puppet" | sudo tee -a /etc/hosts
            echo "i'm node-2"
            sudo timedatectl set-timezone Asia/Shanghai
        SHELL
    end
    config.vm.define "node-3" do |node3|
        node3.vm.box = "ubuntu/trusty64"
        node3.vm.network "private_network", ip: "192.168.56.30"
        node3.vm.hostname = "node-2"
        node3.vm.provision "shell", inline: <<-SHELL
            sudo echo "192.168.10.21 puppet" | sudo tee -a /etc/hosts
            echo "i'm node-3"
            sudo timedatectl set-timezone Asia/Shanghai
        SHELL
    end
end
```