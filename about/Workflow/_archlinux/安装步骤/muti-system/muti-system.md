# 多系统蓝牙
1. 首先在Windows和Linux上连接你的蓝牙设备
2. 将双系统的蓝牙地址修改为一致的
https://gist.github.com/Mygod/f390aabf53cf1406fc71166a47236ebf
## 获取win蓝牙信息
Windows 的蓝牙配对信息存储在注册表中：
HKEY_LOCAL_eMACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\<本机蓝牙适配器 MAC>\<配对设备蓝牙 MAC>

1. win下使用 [psexec.exe](<https://docs.microsoft.com/en-us/sysinternals/downloads/psexec)>) 以系统权限启动 regedit.exe 读取这部分信息
导出信息到 C:\BTKeys.reg 
psexec.exe -si regedit /e C:\BTKeys.reg HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTHPORT\Parameters\Keys
2. linux下使用 dumphive 直接读取 Windows 注册表
- https://blog.nanpuyue.com/2018/040.html
挂载windows系统盘到linux（通过mnt或者gnome nautilus 的图形界面）
your_mount_point=/run/media/admin/9EE46EADE46E86FD
cd /${your_mount_point}/Windows/System32/config 
dumphive SYSTEM ~/system.reg
执行下面的命令，可以查找到显示蓝牙配对相关的信息：

grep -Pn 'BTHPORT.*(\\[\da-f]{12}){2}' ~/system.reg
 vim ~/system.reg +196146

number |awk -F : '{print $1}')
id=xx

for 
grep -n '^' ~/system.reg | grep -A10 "$number" |awk -F : '{print $2}'  这里awk错了
done

sed -n '196146,196156p'  ~/system.reg 






这里可能会有多条输出，取决于系统当前配对的蓝牙设备数，我这里只有一条，所以可以确定就是我要配置的蓝牙鼠标。
vim ~/system.reg +192346 文本编辑器打开指定行数进行查看
1. linux下用chntpw
- https://blog.51cto.com/u_15127608/4789428

## 获取linux蓝牙信息
./get-bluetooth-info.sh
## 蓝牙参数对应关系
下面详细介绍 Windows 下和 Linux 下几个参数的对应关系：

| Windows | Linux                      |
| ------- | -------------------------- |
| LTK     | [LongTermKey] Key          |
| IRK     | [IdentityResolvingKey] Key |
| CSRK    | [LocalSignatureKey] Key    |
| EDIV    | [LongTermKey] EDiv         |
| ERand   | [LongTermKey] Rand         |
其中 LTK IRK CSRK 去掉逗号分隔符并转换为大写
echo a5,2e,55,1c,85,79,c8,de,30,69,e0,a1,aa,f9,d1,91|tr -d ,|tr a-z A-Z
EDIV 需要从十六进制转换为十进制: 
echo $((16#000046fd)) 
ERand 要先把 69,28,ef,ac,68,4f,83,67 倒序，再从十六进制转换为十进制:
echo $((16#$(echo 69,28,ef,ac,68,4f,83,67|tr , '\n'|tac|tr -d '\n')))

## faq 
修改好后一直不成功,然后发现两次配对后鼠标的 MAC 地址最后一位居然不一样，改了 Linux 下蓝牙鼠标配置文件的目录名（就是 MAC 地址）后终于好了。
在linux下你的鼠标地址很有可能与windows下的鼠标地址不同
使用cd ..返回上一级，然后对原来的蓝牙地址进行修改mv xx:xx:xx:xx:x1 xx:xx:xx:xx:x2就可以将x1的名字替换为x2




# 多系统引导发现
由于 Windows 休眠，我不希望使用共享分区
paru -S os-prober
sudo sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
双系统俩独立磁盘，即使挂在了efi分区 grub也无法发现。需要吧win引导拷贝到linux引导中来
sudo cp -r /run/media/admin/0AC1-14D2/EFI/Microsoft/ /boot/EFI/
sudo grub-mkconfig -o /boot/grub/grub.cfg


# 多系统时区 https://wiki.archlinux.org/title/System_time#UTC_in_Windows
reg add HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /d 1 /t REG_QWORD /f

# 多系统快速启动
https://www.reddit.com/r/archlinux/comments/kz7vct/tips_to_boot_faster/
https://wiki.archlinux.org/title/Silent_boot
https://wiki.archlinux.org/title/Intel_graphics#Fastboot