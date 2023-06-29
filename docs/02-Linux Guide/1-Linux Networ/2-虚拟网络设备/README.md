# 虚拟网络设备
https://icyfenix.cn/immutable-infrastructure/network/linux-vnet.html

虚拟化网络的技术。
其中 tap 和 tun 是 Linux 内核中的一种虚拟网络设备
veth pair 则是一对虚拟网络设备。

tap 和 tun 主要是用来模拟点对点的连接，例如 VPN。tap 设备工作在二层（数据链路层）上，可以将网络数据包封装在帧中，然后发送给其他网络设备。tun 设备则工作在三层（网络层）上，可以将网络数据包封装在 IP 包中，然后发送给其他网络设备。

veth pair 则是一对成对出现的虚拟网络设备，可以用于将一个 Linux 命名空间中的网络与另一个 Linux 命名空间中的网络连接起来。

bridge 设备用于在数据链路层（二层）上连接多个网络接口，类似于物理网络中的交换机。

OVS 提供了更多的虚拟网络管理功能，如流量监控、QoS、VLAN 隔离等，而 bridge 则更加简单和轻量级。


[使用 Linux 网络虚拟化技术探究容器网络原理](https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247507562&idx=1&sn=181189cc3d03304a293b22f25e195154&chksm=fdbad177cacd58614efb9516876a9fa83030e31cd6c56ced08eb1eb0933da0a31b7654e3b837&mpshare=1&srcid=0331PDYO8mLpOlhl3Pyadlvk&sharer_sharetime=1680272645651&sharer_shareid=9b996575050d80b9b16b938075c280c4&from=timeline&scene=2&subscene=1&clicktime=1680342114&enterid=1680342114&sessionid=0&ascene=2&fasttmpl_type=0&fasttmpl_fullversion=6613275-zh_CN-zip&fasttmpl_flag=0&realreporttime=1680342114064&devicetype=android-33&version=28002151&nettype=WIFI&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQ4r83hRJFtvxf%2B7WnPw8XOhLvAQIE97dBBAEAAAAAAPWoIFEyry0AAAAOpnltbLcz9gKNyK89dVj0WrhXVRgBslhP3lhByUK39ydITSwuV3L%2BRoSualzqwbJSLE9FI8yL62pWDafZLzPunQOANUZ7uXcom%2BMqmSRmYYw0OvSpC4jRZZei8lJ0DzumyaApwdGmROnY7FcV7TD2iUKFxF9aT8nn7UT5Rf2nj%2BNYrw9b0UDKNFfPQjGPELawAEWkU9zJ%2FQe8rm8dsiCqVg%2FVFkMkdZckmOKeaSEDudVGmQ80bgoVsq5Xf8P5qGiRyYQQwliWIsQNslUOWmqqRjpu9IeerlmT&pass_ticket=fmIVK188qVCFVDgI0aWrvNWyOfZyoKSZaJ4HT4kQwOlrCtFQV1IlHJ28hKFAFwwkuiCZE4bH4LkXYfAYVip09w%3D%3D&wx_header=3)
    