


DHCP 选项和参数

DHCP 子网选项和参数

DHCP 高级选项和参数




## 参数详解

查看示例配置

```bash
cat /usr/share/doc/dhcp*/dhcpd.conf.example |grep -E -v "^#|^$"
```
### 基本参数

```bash
log-facility local7; 
# 全局参数
# 设置DHCP服务器的日志记录级别为local7
```
```bash
ddns-update-style none;
# 全局参数
# 用于控制 DHCP 客户端是否启用动态 DNS 更新。
# 设置为 "none"，则 DHCP 客户端将不会更新 DNS 记录。
# 设置为 "interim" 或 "ad-hoc"，则 DHCP客户端可以自动向 DHCP 服务器提交 DNS 更新请求。
```
这通常用于在动态 IP 地址环境中自动更新 DNS 记录，以使 DNS 始终反映客户端的当前 IP 地址  
当 DHCP 客户端获取到IP地址并进行续租时，它会自动将自己的主机名和IP地址信息提交给DHCP服务器，然后DHCP服务器会相应地更新 DNS 服务器上的记录。这种自动更新 DNS 记录的方式称为"动态DNS"（Dynamic DNS，DDNS）。  
如果您使用动态 IP 地址，建议开启 `ddns-update-style` 参数，如果您使用的是静态 IP 地址，则不需要开启此参数。
:::caution
- 如果禁用动态 DNS 更新，则需要手动更新 DNS 记录，否则可能会导致 DNS 解析错误。
- 启用 `ddns-update-style` 可能会导致安全风险，因为它允许客户端动态更新 DNS 记录。
- 结合ldap分配固定IP？
:::

:::tip
如果您要启用 `ddns-update-style` 参数以在 DHCP 环境中自动更新 DNS 记录，则应考虑以下身份验证和安全协议来保护您的网络：

- 使用安全 DNS（DNSSEC）：使用 DNSSEC 可以增强 DNS 的安全性，防止 DNS 欺骗和 DNS 缓存污染攻击。此外，使用SSL / TLS等安全协议来保护DHCP服务器和DNS服务器之间的通信也可以提高安全性。
- 使用 TSIG（事务签名）：TSIG 是一种数字签名技术，可用于验证 DHCP 客户端和服务器之间的通信。启用 TSIG 可以防止未经授权的 DHCP 更新，并确保所有 DHCP 更新都是经过身份验证的。
- 启用 IPSec：IPSec 是一种加密协议，可用于保护 DHCP 客户端和服务器之间的通信。它可以确保 DHCP 更新是经过身份验证和加密的，从而保护 DHCP 环境免受未经授权的访问和攻击。
- 使用 DHCP Snooping：DHCP Snooping 是一种安全协议，可用于保护 DHCP 环境免受 DHCP 欺骗攻击。它可以确保只有经过身份验证的 DHCP 客户端可以向 DHCP 服务器发送 DHCP 请求，并且防止 DHCP 欺骗攻击。
- 启用端口安全：启用端口安全可以限制 DHCP 客户端的数量和类型，只允许经过身份验证的 DHCP 客户端与 DHCP 服务器通信。这可以防止未经授权的 DHCP 访问并增强 DHCP 环境的安全性。
-使用身份验证：启用身份验证可以确保只有经过身份验证的用户才能更新 DNS 记录。这可以通过配置 DHCP 服务器和 DNS 服务器来实现。
- 配置 ACL（访问控制列表）：配置 ACL 可以限制哪些客户端可以更新 DNS 记录。例如，可以配置 ACL 以仅允许特定 IP 地址或 MAC 地址的客户端更新 DNS 记录。

具体案例详见 [章节xxx](#xx)
:::

```bash
ignore client-updates;
# 局部参数
# 用于控制 DHCP 服务器是否应该接受客户端请求中提供的 DNS 更新。
# 如果将该选项设置为 "ignore client-updates"，那么 DHCP 服务器将忽略来自客户端的 DNS 更新请求。

```
通常，如果 DHCP 客户端发现它的 IP 地址和 DNS 服务器地址已经发生了变化，它会向 DHCP 服务器发送一个更新请求，以便让 DHCP 服务器更新 DNS 记录。但是，如果 DHCP 服务器已经配置了静态 DNS 记录，并且不允许客户端更新 DNS 记录，那么可以使用`ignore client-updates`选项来禁止 DHCP 服务器接受客户端的 DNS 更新请求。  
:::caution
需要注意的是，如果忽略客户端更新，则需要手动更新 DNS 记录，否则可能会导致 DNS 解析错误。
:::

:::tip
dhcp 参数中的 `client-updates` 和 `ddns-update-style` 都与动态 DNS（DDNS）有关，但它们的作用不同。

`client-updates` 是一个子网选项，它只在 DHCP 服务器允许动态 DNS 更新的情况下才会生效。参数允许客户端向 DHCP 服务器发送更新请求，以更新其 DNS 记录。这通常用于动态 IP 地址分配场景，其中客户端的 IP 地址可能会发生变化。如果启用了 `client-updates` 参数，则客户端可以在 IP 地址更改时告知 DHCP 服务器，并请求更新其 DNS 记录。这样可以确保 DNS 记录始终与客户端的 IP 地址保持同步。

`ddns-update-style` 是一个全局选项，参数控制 DHCP 服务器如何与 DNS 服务器进行动态 DNS 更新。它有三个可能的值：
- none      # 禁用DDNS更新。
- interim   # DHCP服务器仅在租约到期时更新 DNS 记录。
- standard  # DHCP服务器在租约分配期间积极更新 DNS 记录。

当启用了 `client-updates` 参数时, `ddns-update-style` 参数应设置为 `standard` 或 `interim` 以确保 DHCP 服务器和 DNS 服务器之间可进行进行动态 DNS 更新，来确保 DNS 记录始终与客户端的 IP 地址保持同步。
:::
```bash
authoritative
# 用于指定DHCP服务器是否应该作为"权威"服务器。
```
如果将该选项设置为 "authoritative"，那么 DHCP 服务器将被认为是"权威"的，这意味着它可以为所有 DHCP 客户端提供 IP 地址和其他配置参数，而不需要与其他DHCP 服务器协调。  
:::caution
需要注意的是，如果在一个网络中有多个 DHCP 服务器，那么只能有一个 DHCP 服务器被配置为 "authoritative"，以避免 IP 地址冲突。
:::
```bash
next-server marvin.redhat.com;   
# 用于指定 PXE 网络引导中 TFTP 服务器的 IP 地址或主机名。
```
当PXE客户端成功获取到这些配置信息后，它会继续向DHCP服务器发送一个TFTP服务请求，以获取引导程序所需的文件。
:::caution
需要注意的是，如果PXE客户端无法获取到next-server选项的值，那么它将无法进行网络引导。因此，在PXE网络引导中，正确配置next-server选项非常重要。
:::

```bash
  filename "vmunix.passacaglia"; 
  # DHCP 服务器向客户端提供的引导文件名，也被称为引导文件路径。
```
客户端会使用这个文件名来下载引导程序所需的文件，从而启动操作系统。通常情况下，filename是一个相对路径，指向DHCP服务器上存储的引导文件。

:::tip
在DHCP服务器的配置文件中，option 选项放在 subnet 参数内和 subnet 参数外的区别在于，它们的作用范围不同。  
当 option 放在 subnet 参数内时，它只会对该 subnet 下的DHCP客户端生效。  
而当 option 放在 subnet 参数外时，它会对所有DHCP客户端生效。无论从哪个 subnet 中分配IP地址的客户端都会收到这个选项。  
需要注意的是，如果在 subnet 参数内和外都设置了 option ，则会以 subnet 参数内的设置为准。
:::

### subnet 

```bash
# DHCP配置文件里必须配置一个地址池，其和DHCP服务器自身IP在同一网段
subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.10 10.0.0.20;       # 地址池范围
  option domain-name "example.org"; 
  #设置DHCP客户端的域名,如果一个DHCP客户端的主机名是 "node1"，并且DHCP服务器向它下发了 option domain-name "example.org"; 这个选项，那么该客户端的完整主机名将是 "node1.example.org"。
  # DHCP 客户端会将 option domain-name 配置中指定的域名添加到本地 DNS 配置文件 /etc/resolv.conf 中的 search 字段中，以便在解析主机名时可以自动添加域名后缀。
  # 例如，如果 option domain-name 配置为 internal.example.org，那么 /etc/resolv.conf 文件中的 search 字段将被更新为：search internal.example.org
  # 这样，在进行 DNS 查询时，如果主机名不包含域名后缀，则会自动添加 internal.example.org 后缀进行查询。
  option domain-name-servers ns1.example.org, ns2.example.org; # 设置DHCP客户端的DNS服务器
  option routers 10.0.0.1;               # 默认路由，其实就是网关
  option broadcast-address10.0.0.255;    # 广播地址，不设置时默认会根据A/B/C类地址自动计算
  default-lease-time 600; # 设置DHCP客户端的默认租约时间为600秒（10分钟）
  max-lease-time 7200; # 设置DHCP客户端的最大租约时间为7200秒（2小时）
}
```

### host 
```bash
#下面的是绑定MAC地址设置保留地址，保留地址不能是地址池中的地址
host fantasia {            # 固定地址的配置，host后面的是标识符，没意义
  hardware ethernet 08:00:07:26:c0:a5;
  fixed-address 192.168.100.3;      # 根据MAC地址分配的固定IP 
}
## host fantasia：表示为一个名为 fantasia 的主机配置了一个固定的 IP 地址。该主机的 MAC 地址为 08:00:07:26:c0:a5，被分配的 IP 地址为 192.168.100.3。

host passacaglia {
  hardware ethernet 0:0:c0:5d:bd:95;
  filename "vmunix.passacaglia"; # 开始启动文件的名称，应用于无盘工作站,DHCP服务器向客户端提供的引导文件名，也被称为引导文件路径。客户端会使用这个文件名来下载引导文件，从而启动操作系统。通常情况下，filename是一个相对路径，指向DHCP服务器上存储的引导文件。
  server-name "toccata.fugue.com"; 
  fixed-address fantasia.fugue.com; # 此参数指定DHCP客户端应该被分配的静态IP地址。与通常的动态IP地址分配不同，DHCP服务器将始终分配给该客户端相同的IP地址。这通常用于需要固定IP地址的服务器或其他网络设备。
}
## host passacaglia：表示为一个名为 passacaglia 的主机配置了一个固定的 IP 地址。该主机的 MAC 地址为 0:0:c0:5d:bd:95，被分配的 IP 地址为 fantasia.fugue.com。此外，该主机还指定了 filename 和 server-name 选项，这些选项可以用于指定该主机使用的引导文件和 DHCP 服务器的名称。
```

### class
```bash
class "foo" {
  match if substring (option vendor-class-identifier, 0, 4) = "SUNW";
}
```
class "foo"：定义一个名为 foo 的类，该类使用 match 语句来匹配 option vendor-class-identifier 选项的前四个字符是否为 SUNW。这个类可以用于对某些特定类型的客户端应用不同的分配策略。
Class 是 DHCP 服务器配置文件中的一个关键字，用于定义 DHCP 客户端的分类。通过定义不同的 class，管理员可以为不同类型的客户端分配不同的 IP 地址、子网掩码、网关、DNS 服务器等参数，以满足其特定需求。例如，可以为移动设备定义一个 class，为服务器定义一个 class，为办公室工作站定义一个 class 等等。
以下是一个 class 的示例：
```bash
class "mobile-devices" {
match if substring(option vendor-class-identifier, 0, 6) = "Apple";
option domain-name "example.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;
range 10.0.1.100 10.0.1.200;
}
```
这个 class 定义了一个名为 mobile-devices 的分类，匹配条件为客户端的 vendor-class-identifier 字段以 "Apple" 开头。当客户端满足条件时，DHCP 服务器会为其分配一个 IP 地址范围为 10.0.1.100 到 10.0.1.200 的地址，同时指定了域名和 DNS 服务器。


### shared-network
```bash
shared-network 224-29 {
  subnet 10.17.224.0 netmask 255.255.255.0 {
    option routers rtr-224.example.org;
  }
  subnet 10.0.29.0 netmask 255.255.255.0 {
    option routers rtr-29.example.org;
  }
  pool {
    allow members of "foo";
    range 10.17.224.10 10.17.224.250;
  }
  pool {
    deny members of "foo";
    range 10.0.29.10 10.0.29.230;
  }
}
## shared-network 224-29：定义一个名为 224-29 的共享网络，该网络包括两个子网：10.17.224.0/24 和 10.0.29.0/24。每个子网都有一个路由器（rtr-224.example.org 和 rtr-29.example.org），以及一个 IP 地址池。其中，第一个池只允许名为 foo 的类中的客户端使用，该池的 IP 地址范围为 10.17.224.10 到 10.17.224.250；第二个池禁止名为 foo 的类中的客户端使用，该池的 IP 地址范围为 10.0.29.10
# Shared-network 是 DHCP 服务器配置文件中的另一个关键字，用于将多个子网组合成一个共享网络。
# 通过定义 shared-network，管理员可以为不同子网内的客户端分配相同的 IP 地址、子网掩码、网关等参数。以下是一个 shared-network 的示例：
# ```
# shared-network example-network {
#   subnet 192.168.1.0 netmask 255.255.255.0 {
#     option routers 192.168.1.1;
#     option domain-name "example.com";
#     option domain-name-servers 8.8.8.8, 8.8.4.4;
#     range 192.168.1.100 192.168.1.200;
#   }
#   subnet 192.168.2.0 netmask 255.255.255.0 {
#     option routers 192.168.2.1;
#     option domain-name "example.com";
#     option domain-name-servers 8.8.8.8, 8.8.4.4;
#     range 192.168.2.100 192.168.2.200;
#   }
# }
# ```
# 这个示例定义了一个名为 example-network 的 shared-network，包括两个子网：192.168.1.0/24 和 192.168.2.0/24。
# 对于每个子网，DHCP 服务器分别分配了一个 IP 地址范围，同时指定了网关、域名和 DNS 服务器。
# 由于这两个子网属于同一个 shared-network，它们共享相同的 DHCP 服务器配置。
# 
# 
# :::tip
# subnet 关键字只适用于单个子网的情况，而 shared-network 中，可以定义多个 subnet 来表示不同的子网，可以将多个子网组合成一个共享网络。
# 
# 在使用 shared-network 定义多个子网的情况下，DHCP 服务器和客户端不必在同一网络内。
# DHCP 服务器只需要有一个接口连接到网络，然后为该网络中的多个子网提供服务即可。
# 在这种情况下，DHCP 服务器需要能够路由到每个子网，以便能够向客户端发送 DHCP 响应。
# 这通常可以通过在 DHCP 服务器上设置静态路由或使用动态路由协议来实现。
# 需要注意的是，对于不同子网的客户端，DHCP 服务器需要为每个子网分配不同的 IP 地址池，并在 DHCP 响应中包含相应的网关地址和 DNS 服务器地址，以便客户端能够正确地配置其网络参数。
# 
# 
# 当客户端向网络中发送 DHCP 请求时，该请求会被广播到该网络的所有设备。如果 DHCP 服务器与客户端在同一子网中，则可以直接接收到该广播，并向客户端发送 DHCP 响应。但是，如果 DHCP 服务器与客户端不在同一子网中，则需要路由器将该广播转发到 DHCP 服务器所在的子网。因此，DHCP 服务器需要能够路由到每个子网，以便能够接收到来自客户端的 DHCP 请求并向其发送响应。
# 需要注意的是，不同类型的 DHCP 请求有不同的广播域。例如，DHCP Discover 和 DHCP Request 请求是局域网（LAN）广播，而 DHCP Release 和 DHCP Decline 请求是子网广播。因此，DHCP 服务器需要能够处理不同类型的广播请求，并能够正确地将 DHCP 响应发送回客户端。
# :::
# 
# :::tip
# 通常情况下，路由器是不会转发广播的，因为广播是限制在其所在的网络（广播域）内的。
# 但是，有些路由器支持广播转发功能，也称为 "子网广播转发 (Subnet Broadcast Forwarding，SBF)"
# 广播转发功能允许路由器将广播数据包从一个广播域转发到另一个广播域，以便广播能够跨越不同的子网传播。
# 这样，DHCP 服务器就可以接收到来自不同子网的 DHCP 请求，并向客户端发送 DHCP 响应。
# 需要注意的是，广播转发功能可能会对网络性能和安全性产生影响。如果不正确配置，可能会导致广播风暴、网络拥塞和安全漏洞等问题。
# 因此，在启用广播转发功能之前，请确保已经了解其工作原理，并采取相应的安全措施。
# :::
```


DHCP服务器应该服务于两个VLAN。

