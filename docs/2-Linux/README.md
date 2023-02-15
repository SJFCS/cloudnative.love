---
title: Linux
sidebar_position: 2
tags: [Linux]
---

待学习：
      了解 linux 核心子系统（内存管理 文件系统 网络 进程调度） 内核 crash dump 分析，ebpf入门,性能分析io排查

- Linux 系统日志：https://linux.vbird.org/linux_basic/centos7/0570syslog.php
- Linux 源码：[linux-insides](https://github.com/0xAX/linux-insides)
- [Linux 内核模块开发指南](https://sysprog21.github.io/lkmpg/)
- [第十六章、程序管理與 SELinux 初探 - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0440processcontrol.php)
- [第十九章、開機流程、模組管理與 Loader - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0510osloader.php)

- GNU Core Utilities

  :::tip
  （GNU核心工具组 常缩写为coreutils）是一个GNU 软件包，它包含了许多基本工具（如cat，ls 和rm）在类Unix 操作系统上的重新实现。
  :::

  源码仓库：

  + [GNU coreutils](https://github.com/coreutils/coreutils)
  + [uutils/coreutils](https://github.com/uutils/coreutils) 使用 rust 重新实现的 GNU coreutils.
  + [redox-os/coreutils](https://github.com/redox-os/coreutils) redox os 的 coreutils，基于 BSD coreutils