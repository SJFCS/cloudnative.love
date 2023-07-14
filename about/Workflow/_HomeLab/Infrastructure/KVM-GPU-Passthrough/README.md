https://github.com/BigAnteater/KVM-GPU-Passthrough
## linux 
Vagrantfile
```
Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.host = "kvm.example.com"  # 替换为您的KVM主机地址
    libvirt.driver = "kvm"
    libvirt.machine_type = "pc-q35-4.2"  # 替换为您的机器类型

    libvirt.video_type = "virtio"  # 使用virtio显卡
    libvirt.video_vram = 16384  # 设置显存大小

    libvirt.qemuargs :'-device', 'vfio-pci,host=01:00.0,multifunction=on'  # 配置直通的显卡设备
  end
end
```
在上述示例中，您需要将"kvm.example.com"替换为您的KVM主机地址，并根据您的需求进行其他配置。"01:00.0"是示例中直通的显卡设备的PCI地址，您需要将其替换为您实际使用的显卡设备的地址。

请注意，显卡直通是一项高级功能，配置和使用过程可能会有一些挑战。建议您在尝试之前详细阅读vagrant-libvirt插件的文档，并确保您的系统满足要求。





vagrant-libvirt插件支持使用自定义的KVM XML配置来进行高级配置。通过使用自定义的XML配置，您可以更精细地控制虚拟机的各个方面，包括显卡直通。
```
Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.host = "kvm.example.com"  # 替换为您的KVM主机地址
    libvirt.driver = "kvm"
    libvirt.machine_type = "pc-q35-4.2"  # 替换为您的机器类型

    libvirt.xml = "/path/to/custom.xml"  # 指定自定义的XML配置文件路径
  end
end
```


## windows
