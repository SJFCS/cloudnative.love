---
title: Hyper-V 与其他虚拟化软件共存
---

Hyper-V 与 VMWare/Virtual Box 共存方法

## VMWare Workstation/Player

### 解决方案1
传统的解决方法是在选择多系统的启动菜单中新增一个选项，让 Windows 在启动时不加载 Hyper-V 。

以管理员身份打开命令提示符，运行如下两条命令：
```powershell
bcdedit /copy {default} /d "Windows Without Hyper-V"
bcdedit /set {ID-Number} HyperVisorLaunchType OFF
```
执行成功后可以用 `msconfig` 验证是否成功创建启动项


但这会导致依赖 Hyper-V 环境的功能无法使用，例如 WSL 2、基于虚拟化的安全功能(Virtualization Based Security, VBS): Windows Sandbox、Credential Guard、Application Guard 等。
### 解决方案2

1. 将 Windows 版本升级到 Windows 10 20H1 或更高版本。
2. 将 VMWare Workstation/Player 升级到 15.5.5 或更高版本。  
    注意，在安装时勾选“自动安装 Windows Hypervisor Platform (WHP)”。
3. 打开虚拟机的设置选项，找到 “处理器” 去掉如下复选框。
   - [ ] 虚拟化Intel VT-x/EPT或AMD-V/RVIV)
   - [ ] 虚拟化CPU性能计数器(U)
   - [ ] 虚拟化IOMMU(IO内存管理单元)

## Virtual Box
### 解决方案1
启用 Virtual Box 兼容模式。

进入 `C:\Program Files\Oracle\VirtualBox`
```powershell
#指定vbox下的虚拟系统开启这个功能
VBoxManage setextradata "<虚拟机名字>" "VBoxInternal/NEM/UseRing0Runloop" 0

#或指定vbox所有虚拟系统开启
VBoxManage setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0
```