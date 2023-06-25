---
title: 安全增强技术
---
SELinux是Linux操作系统中最常用的安全增强技术之一，它通过标签和策略来控制进程、文件、网络等资源的访问权限，可以对系统资源进行更加细粒度的控制和保护。SELinux的实现较为复杂，需要进行较为繁琐的配置和管理，但也能够提供更加精细的安全控制。


AppArmor与SELinux类似，也是一种访问控制机制，可以通过限制应用程序的权限来增强系统的安全性。与SELinux不同的是，AppArmor使用了更加简单和易于管理的权限控制模型，适合于一些需要快速部署和管理的场景。


Capabilities是Linux内核中的一种权限管理机制，可以为进程分配一定的权限，使得进程只能访问自己需要的系统资源，而不能访问其他资源。Capabilities的实现较为简单，但也只能控制进程的权限，不能像SELinux和AppArmor那样对其他系统资源进行控制。


总的来说，SELinux、AppArmor和Capabilities都可以提高Linux系统的安全性，但在实际应用中，应该根据实际需求和场景选择合适的安全机制。

- [第十六章、程序管理與 SELinux 初探 - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0440processcontrol.php)
