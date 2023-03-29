## 目录映射到盘符

在 Windows 中有一个叫做 subst.exe 的程序，它可以将目录映射到盘符。用法如下：
– subst.exe 列出当前所有的虚拟盘符
– subst.exe Z: C:\DirName       # 将 C:\DirName 映射到 Z:
– subst.exe Z: /D               # 删除虚拟盘符 D:

:::tip
subst.exe 的映射仅在当前 session 有效!  
例如 UAC 提升的 shell 中无法访问在 UAC 提升之前建立的映射关系。  
开机启动的过程中，explorer.exe 建立图标缓存时也无法访问对应的图标导致图标空白。

可通过键入以下注册表来实现开机映射解决上述问题。
```powershell
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v Z: /t REG_SZ /d "\??\C:\DirName" /f
```
:::


## 挂载分区到目录

参考文档：https://learn.microsoft.com/en-us/windows-server/storage/disk-management/assign-a-mount-point-folder-path-to-a-drive

## 软链

- junction
- symboliclink

