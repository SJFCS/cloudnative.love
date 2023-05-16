- [第十九章、開機流程、模組管理與 Loader - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0510osloader.php)
# Linux操作系统的启动过程？
- 打开电源开关。

- BIOS上电自检(POST)。

  - BIOS系统是指Basic Input/Output System，基本输入输出系统。该系统存储在主板的ROM(Read-Only Memory)只读存储器上。
  - 计算机在开机时，会先读取BIOS系统，然后通过POST（Power-On Self-Test）硬件自检程序检查计算机硬件是否满足运行的基本要求，如CPU、内存、硬盘等。POST是BIOS系统的一部分。如果POST上电自检失败，那么电脑就不能使用，引导过程也将中断。
  - 上电自检过程其实与操作系统无关，上电自检主要由硬件来完成，这对于所有操作系统都一样。

- 启动顺序设置。
  - POST上电自检没有异常后，会将BIOS系统全部加载进内存。
  - 上电自检完成后，BIOS系统把控制权转交给下一阶段的启动程序。
  - 在BIOS的操作界面，Boot Sequence处可以设置启动顺序。如从硬盘启动、从USB闪存U盘启动、从网络启动(Network boot)等。

- 主引导记录。

  - BIOS系统按启动顺序去查找第一个磁盘的MBR信息，并加载和执行MBR中的Bootloader程序。若每一个磁盘上面没有MBR信息，则在第二个磁盘上面继续查找，一旦Bootloader程序被检查到，则加载Bootloader程序到内存中。
  - MBR是Master Boot Recode。主引导记录。MBR只有512字节，主要告诉计算机到硬盘的哪一个位置去找操作系统。如一台计算机上面可以分多个磁盘，在不同的磁盘上面安装不同的操作系统。

- 硬盘启动。

  - BIOS系统在将MBR主引导记录中的Bootloader程序加载到内存后。在Bootloader启动管理器中选择启动哪一个操作系统。
  - Linux环境中，目前最流行的启动管理器是GRUB。
  - GRUB是GRand Unified Bootloader，是多操作系统启动程序。如在计算机系统上面安装了CentOS7操作系统和Windows 10操作系统，这时候就需要选择一个操作系统。
  - 选择操作系统后，GRUB将相应的操作系统Kernel内核加载进内存，并将控制权转交给Kernel内核程序。

- 内核加载。

  - 内核文件都是都是以一种自解压的压缩格式存储以节省空间，它与一个初始化的内存映像和存储设备映像都存储于`/boot`目录之下。
  - 注意一下initrd文件，在加载内核时这个文件也会被加载到内存当中。这个文件是在安装系统时产生的，是一个临时的根文件系统(rootfs)。因为内核为了精简，只保留了最基本的模块，因此Kernel内核上并没有各种硬件的驱动程序，也就无法识别rootfs所在的设备，故产生了initrd这个文件，该文件装载了必要的驱动程序，当Kernel内核启动时，可以从initrd文件中装载驱动模块，从而挂载真正的rootfs，然后将initrd从内存中移除。
  - 内核会以只读的方式挂载根文件系统，当根文件系统被挂载后，则开始装载第一个进程。
  
- init程序。

  - 内核挂载rootfs后，就会运行第一个程序`/sbin/init`，之后控制权交给`init`程序。
  - 有的系统已经使用`systemd`代替`init`文件。
  - `init`程序会根据配置文件(如`/etc/inittab`)产生PID为1的进程。
  
- Runlevel。

  - 根据配置文件中的启动级别执行不同的脚本，如自启动脚本、开机启动项等，完成系统的启动。
  
    

参考：
- [Linux启动过程](https://www.cnblogs.com/codecc/p/boot.html)
  
- [计算机是如何启动的？](http://www.ruanyifeng.com/blog/2013/02/booting.html)
  
- [Linux 开机引导和启动过程详解](https://linux.cn/article-8807-1.html)
  
- [Linux 系统启动过程](https://www.runoob.com/linux/linux-system-boot.html)
  
- [kthreadd-linux下2号进程](https://www.cnblogs.com/embedded-linux/p/6618717.html)
  
  
 