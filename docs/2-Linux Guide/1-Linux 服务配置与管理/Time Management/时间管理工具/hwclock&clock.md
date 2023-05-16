---
title: hwclock&clock
---

读取和设置硬件时钟 

hwclock 和 clock 用法相近，只不过 clock 命令除了支持 x86 硬件体系外，还支持 Alpha 硬件体系。  
hwclock 可以将 System clock 写入 Hardware clock，它将会创建并更新 /etc/adjtime 。有关此文件详细信息请参见 [hwlock (8) The Adjtime File](https://man.archlinux.org/man/hwclock.8#The_Adjtime_File)。
### 查看当前时间设置
```bash
hwclock -r, --show           # 读取硬件时钟并打印结果
```
### 设置时间
```bash
# 设置 RTC (硬件时间)
hwclock --set --date="02/21/2023 10:19"
# hc代表硬件时间，sys代表系统时间
hwclock -s, --hctosys  # 硬件时钟到系统 		  set the system time from the hardware clock
hwclock -w, --systohc  # 系统到硬件时钟 		  set the hardware clock from the current system time      
hwclock     --systz    # 基于当前时区设置系统时间  set the system time based on the current timezone

hwclock     --adjust      # 调整RTC以说明系统漂移，因为时钟是最后一个设置或调整的
hwclock -u, --utc         # the hardware clock is kept in UTC
hwclock     --localtime   # the hardware clock is kept in local time
hwclock     --date <time> # specifies the time to which to set the hardware clock
```



