https://www.cnblogs.com/dahaoran/p/13270412.html
https://www.cnblogs.com/qiantang/p/13379130.html
https://blog.csdn.net/luoyeyuan/article/details/50953042
https://blog.csdn.net/qq_34509507/article/details/84428986
https://blog.csdn.net/weixin_32420193/article/details/113024376


linux下如何时查看光纤卡的驱动版本

首先确认是哪种光纤卡:
```bash
lspci | grep -i fibre
```
光纤卡基本上就以下两种:
```bash
# Emulex: 
lsmod |grep lpfc
# qlogic: 
lsmod |grep qla
```
HBA卡的驱动是qla2xxx，可以通过如下命令可以查看
```bash
cat /sys/module/qla2xxx/version
modinfo qla2xxx
```