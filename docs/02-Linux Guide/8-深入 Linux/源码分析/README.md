绝大多数都是驱动，驱动挑两个读一下就行了，没必要全读，除去驱动就少多了。驱动也分很多种，比如CPU驱动、块设备驱动、文件系统驱动、各种总线的驱动、各种内存驱动、各种网络协议的驱动、声音多媒体驱动、虚拟化驱动等等，用到再去读。读几处源码，总结出读源码的方法更重要。对于我来说，有些地方是必读的，启动部分、内存管理的分级页面管理、vfs、CPU与硬件如何结合的地方，可以带着问题读，比如：在一种CPU架构内如何新增指令集，如何增加一种CPU架构，如何新增一种CPU调度、IO调度算法，一个数据包从网卡进入后经过哪些地方然后被转发出去，与内核配置相关的sysctl机制。

罗列一下方法/入口，未必对，仅做参考：启动：找一份启动时的 dmesg日志，然后从源码树里过滤日志里的字符串，对应着日志和源码分析启动过程。 init/main.c -->  start_kernel() 这可能是内核启动的入口，其中的 mm_init()就是内存分配器初始化。重启： kernel/reboot.c -> kernel_restart()  关于CPU，先扫一眼： grep \)$ kernel/cpu.c | grep ^[a-z]。新增一种CPU架构？参考下近来很火的RISC-V： ls arch/riscv/ Documentation/riscv/ 有知友问，CPU也需要驱动？我没写过驱动，我理解的驱动是指出软件层面的功能和硬件地址之间的对应关系（也许理解有误，欢迎指正）。详细点：如果内核已经有了这个设备的所有功能，那么只需要一张表，指出哪个功能对应哪个硬件地址就行了；如果有些功能还没有，那就需要自己实现，那张表还得有。具体到CPU，以x86为例，不止Intel有，还有AMD、台湾VIA、中国兆芯等厂商的，肯定有所差别，不可能抄得完全一样，只要有差别，在软件层面就得做相应的适配，比如说确定每个针脚的功能；即使是同一个厂商的，升级换代后CPU功能也大不一样，用法也会跟着变，才能发挥出最佳性能（比如，早期的AMD CPU只是CPU，后来集成了内存控制器，再后来又集成了GPU）。在Linux源码里，好像是通过读取设备ID来确定CPU型号，然后加载相应驱动，源码位于： arch/x86/include/asm/cpu_device_id.h 关于IO调度器：find . -iname \*iosched\* 任务调度器相关的在kernel/sched/ 和 Documentation/scheduler/ 下。 关于sysctl ，文件也不多：find . -name \*sysctl\*


https://github.com/buyuer/learnlinux


[Linux 内核代码风格](https://www.kernel.org/doc/html/v4.13/translations/zh_CN/coding-style.html)


https://www.zhihu.com/question/332710035/answer/1847740853

阅读linux源码有很多方式，最简单的就是使用[bootlin](https://elixir.bootlin.com/linux/latest/source)，在线阅读，不用安装任何环境，但是当进行符号跳转或搜索的话，就不是很方便了，其次无法编辑。

zhihu.com/question/439569498/answer/2706622076?utm_id=0 

[epoll 或者 kqueue 的原理是什么？](https://www.zhihu.com/question/20122137/answer/2134896876?utm_id=0)

https://zhuanlan.zhihu.com/p/258513662?utm_id=0