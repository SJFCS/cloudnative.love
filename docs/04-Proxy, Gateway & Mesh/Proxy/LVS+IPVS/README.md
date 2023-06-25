---
title: LVS+IPVS
---
- https://www.cnblogs.com/lipengxiang2009/p/7349271.html
- http://www.linuxvirtualserver.org/zh/lvs1.html
- https://www.cnblogs.com/vinozly/p/5030746.html
- https://www.v2ex.com/t/597934
- https://www.cnblogs.com/kevingrace/p/5574486.html
- https://blog.csdn.net/putixiao/article/details/102652758



LVS（Linux Virtual Server）和 IPVS（IP Virtual Server）都是Linux内核中的模块，用于实现负载均衡。它们的主要区别在于：

LVS是一个项目，而IPVS是LVS项目中的一个具体实现。 
LVS提供了多种负载均衡技术，包括IPVS、Direct Routing（DR）和Network Address Translation（NAT）等。而IPVS只提供IP负载均衡技术。
LVS可以在不同的内核版本中使用，而IPVS只能在支持它的内核版本中使用。
总之，LVS是一个更为通用的负载均衡项目，而IPVS是其中的一个具体实现，在Linux内核中提供了IP负载均衡功能。