# Netfilter
用于实现网络包过滤、NAT 等功能的内核模块，有多种用户空间工具可供使用，如 iptables、nftables、ufw 等。


- Netfilter 是Linux内核中的一个网络包过滤框架，提供了对网络数据包的过滤和操作功能。
- iptables 是早期使用最广泛的Netfilter工具之一，它提供了一组命令行接口，用于配置Netfilter规则。
- nftables 是iptables的后继者，也是一个Netfilter工具，提供了更加现代化的语法和功能。
- firewalld 是一个网络管理工具，它使用Netfilter来提供防火墙和网络包过滤服务，可以通过命令行或图形界面进行配置。
ufw（Uncomplicated Firewall）是一个Ubuntu Linux系统上的前端应用程序，它使用iptables和Netfilter来提供防火墙功能，提供了一组简单易用的命令行接口。



iptables 和 nftables 是 Linux 系统的基础防火墙，它们提供了强大的网络安全功能，但是使用这些防火墙需要具备一定的技术能力。ufw 和 firewalld 是针对 iptables 和 nftables 的简化管理工具，它们提供了更简单易用的界面，允许用户通过简单的命令或 GUI 界面来配置防火墙。因此，ufw 和 firewalld 可以帮助那些没有深入了解 iptables 和 nftables 的用户更容易地配置防火墙，提高系统的安全性。

对于 ufw，可以在终端中输入 sudo ufw gui 命令打开图形界面。

对于 firewalld，可以在终端中输入 firewall-config 命令打开图形界面。


以下是一些常用的基于终端的图形界面防火墙配置工具：

nmtui: 一个用于配置网络连接和防火墙的 TUI 工具，适用于使用 NetworkManager 的系统。
nft: 一个用于配置 nftables 防火墙的 TUI 工具。



https://segmentfault.com/a/1190000019455385

https://www.jianshu.com/p/f86d4b88777d

https://netfilter.org/documentation/HOWTO/netfilter-hacking-HOWTO.html#toc3