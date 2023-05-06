
## 导入虚拟机模板
导入vagrant官方的ubuntu-1804虚拟机模板
```bash
vagrant box add Ubuntu-18.10-cosmic-server-cloudimg-amd64 Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box
```

## 编写Vagrantfile文件

```ruby
Vagrant.configure("2") do |config|
  config.vm.define :ubuntu1810 do |ubuntu1810|
    ubuntu1810.vm.box = "Ubuntu-18.10-cosmic-server-cloudimg-amd64"
    ubuntu1810.vm.hostname = "ubuntu-1810"
    ubuntu1810.vm.synced_folder ".", "/vagrant", disabled: true
    ubuntu1810.vm.network :private_network, ip: "192.168.35.11"
    ubuntu1810.vm.provision "shell", inline: <<-SHELL
    sed --in-place=.bak -r 's/^#?(PermitRootLogin|PermitEmptyPasswords|PasswordAuthentication|X11Forwarding) yes/\1 no/' /etc/ssh/sshd_config
    # sed --in-place=.bak '/== vagrant insecure public key$/d' /home/vagrant/.ssh/authorized_keys
    # sed --in-place=.bak '$!N; /^\(.*\)\n\1$/!P; D' /home/vagrant/.ssh/authorized_keys
    systemctl restart sshd
    SHELL
  end
end
```
## 导出虚拟机
```bash
vagrant package --base=Ubuntu-18.10-cosmic-server-cloudimg-amd64 --output=Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box

vagrant box add ubuntu-1810-my Ubuntu-18.10-cosmic-server-cloudimg-amd64-vagrant.box
```

