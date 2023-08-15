https://ivonblog.com/posts/archlinux-install-nvidia-drivers/

Linux和Windows对于显卡的管理和切换方式不同，导致了这种差异。

在Linux中，Mux-Discrete GPU（即独立显卡）和Integrated GPU（即集成显卡）是通过PCI-E设备连接到系统上的，由于存在不同的DRI驱动程序，因此在切换前需要先停止使用显卡的应用程序，卸载相应的驱动程序，然后重新加载相应的驱动程序并重新启动X窗口系统，这个过程需要重启显示器来使切换生效。

而Windows采用的是WDDM（Windows Display Driver Model）驱动模型，支持热插拔和设备动态变更，因此在切换GPU时可以直接通过GPU驱动程序切换，不需要退出桌面或重启显示器。

因此，由于Linux和Windows对于显卡的管理方式不同，导致了切换时的差异。




有什么办法解决嘛？
AI
可以使用一些特定的工具或软件来实现在Linux下切换显卡时不需要退出桌面的操作。比如Bumblebee，Primus，Optimus-Manager等软件，它们可以在不重启系统的情况下实现切换显卡，提高工作效率。

Bumblebee是一个Linux下的开源软件，它可以在系统集成显卡和独立显卡之间进行切换。Primus是基于Bumblebee的一种解决方案，它可以更好的支持英伟达的双显卡方案。

而Optimus-Manager则是一个相对较新的开源切换显卡方案，它支持多个显卡，可以在应用程序使用时动态地切换显卡，无需退出桌面。

需要注意的是，在使用这些软件之前，需要确认系统的显卡硬件和驱动等条件，一些旧的显卡或不支持的显卡可能会有兼容性问题。



右键通过显卡打开

volumeshader 测试