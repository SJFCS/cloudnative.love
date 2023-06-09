  省电策略
  睡眠休眠


linux内核功耗优化
1、前言

- 静态功耗，指的是某一种状态下的功耗情况，在这种状态下尽量低的功耗，比如cpuidle、suspend、cpuhotplug等；

- 动态功耗，指的是各种状态的切换，比如susped-resume、cpuidle不同状态切换、中断、wakelock等等。

静态功耗的调试，可以在特定状态下测量功耗，逐步优化；但是在动态功耗，也即系统运行时，影响功耗的因素千差万别，瞬息万变，就需要在测量功耗的时候抓住系统运行轨迹。

2、需要抓住哪些锚点？

要测量功耗因素，就要了解那些内核行为导致了功耗增加或减少？具体需要抓住哪些轨迹，比如：

1. suspend-resume(何时进入suspend、持续时间、何时退出suspend、谁唤醒了系统)：machine_suspend2. cpuidle(切换点、时长、状态)：cpuidle3. cpufreq(何时切换、切换到什么频点、持续多久)：cpu_frequency4. 中断(哪个中断、何时触发、中断函数处理耗时)：irq_handler_entry、irq_handler_exit5. wakeup source()：wakeup_source_activate、wakeup_source_deactivate6. 电源域(哪个电源域、设置状态)：power_domain_target7. 时钟(哪个时钟、何时开、何时关、频率变动)：clock_enable、clock_disable、clock_set_rate

2. 定时器(定时器创建、启动、超时、取消，包括低精度定时器和高精度定时器)：低精度定时器(timer_init、timer_start、timer_cancel、timer_expire_entry、timer_expire_exit)、高精度定时器(hrtimer_init、hrtimer_start、hrtimer_expire_entry、hrtimer_expire_exit、hrtimer_cancel)


可以把这些一个个Traceevents看做功耗信息锚点，下面逐个分析这些锚点。

2.1 trace_machine_suspend

2.2 trace_cpu_idle_rcuidle/

2.3 trace_cpu_frequency

2.4 trace_irq_handler_entry/trace_irq_handler_exit

2.5 trace_wakeup_source_activate/trace_wakeup_source_deactivate

2.8 trace_timer_start/trace_timer_cancel/trace_timer_expire_entry/trace_timer_expire_exit