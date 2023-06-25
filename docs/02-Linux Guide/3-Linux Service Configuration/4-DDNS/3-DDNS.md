
```bash
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
# 用于控制 DHCP 客户端是否启用动态 DNS 更新。
# 设置为 "none"，则 DHCP 客户端将不会更新 DNS 记录。
# 设置为 "interim" 或 "ad-hoc"，则 DHCP客户端可以自动向 DHCP 服务器提交 DNS 更新请求。
log-facility local7; 
# 全局参数
# 设置DHCP服务器的日志记录级别为local7
```
这通常用于在动态 IP 地址环境中自动更新 DNS 记录，以使 DNS 始终反映客户端的当前 IP 地址  
当 DHCP 客户端获取到IP地址并进行续租时，它会自动将自己的主机名和IP地址信息提交给DHCP服务器，然后DHCP服务器会相应地更新 DNS 服务器上的记录。这种自动更新 DNS 记录的方式称为"动态DNS"（Dynamic DNS，DDNS）。  
如果您使用动态 IP 地址，建议开启 `ddns-update-style` 参数，如果您使用的是静态 IP 地址，则不需要开启此参数。
:::caution
- 如果禁用动态 DNS 更新，则需要手动更新 DNS 记录，否则可能会导致 DNS 解析错误。
- 启用 `ddns-update-style` 可能会导致安全风险，因为它允许客户端动态更新 DNS 记录。
- 结合ldap分配固定IP？

是的，ISC DHCP 可以与 LDAP 服务器结合使用来为客户端分配 IP 地址。使用 LDAP 来管理 DHCP 配置有许多好处，包括集中管理、存储 DHCP 配置信息等。

在 ISC DHCP 中与 LDAP 结合使用分配 IP 地址需要进行以下步骤：

安装和配置 LDAP 服务器。这里以 OpenLDAP 为例，在 LDAP 配置中应包含 DHCP 相关的模式（schema）和属于 DHCP 组（group）的用户。

配置 ISC DHCP 服务器以支持 LDAP。使用配置选项 ldap-server 和 ldap-port，指定要连接的 LDAP 服务器和端口。此外，还可以使用其他选项指定 LDAP 认证、搜索基础等信息。

定义 DHCP 网络配置。在 subnet 或 shared-network 块中定义 DHCP 网络配置。在 subnet 或 shared-network 块中，可以使用 ldap-dhcp-server-cn 选项指定要使用的 DHCP 服务器。此外，在 subnet 或 shared-network 块中，还可以使用 ldap-base-dn 选项来指定 LDAP 的搜索根。

将 DHCP 配置信息添加到 LDAP 中。将每个 DHCP 客户端相关的配置信息添加到 LDAP 数据库中。可以使用 dhcpHost 类型（在 dhcp.schema 中定义）将 DHCP 客户端的配置信息添加到 LDAP 数据库中。DHCP 客户端的配置信息包括 MAC 地址、IP 地址、子网掩码、网关、DNS 和租约时间。
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



动态 DNS
使用 ISC DHCP 实现 DDNS（动态 DNS）的过程如下：

确保 DHCP 服务器和 DNS 服务器运行正常，并打开了对应的服务。此外，还需要安装与配置管理 ISC DHCP 和得益于 DHCP 动态 DNS 绑定的 DNS 服务器。

打开 ISC DHCP 配置文件，找到要添加 ddns 设置的子网，加入以下代码：

zone example.com.
primary 192.0.2.1;
key "mykey" {
    algorithm hmac-md5;
    secret "mykeysecret";
};
ddns-update-style interim;
update-static-leases on;
ddns-domainname "example.com.";
ddns-rev-domainname "in-addr.arpa.";
ignore client-updates;
set ddns-rev-domainname = "in-addr.arpa.";
ddns-ttl 3600;
ddns-update-style standard;
ddns-updates on;
ddns-update-style none;
allow client-updates;
ddns-domainname-servers ns1.example.com., ns2.example.com.;
这里主要设置：

key：密钥用于提供身份验证和安全性。
ddns-update-style：指定 DDNS 更新样式的类型，这里设置为 standard。
ignore client-updates：忽略客户端发起的 DDNS 更新请求，这是一个可选项。
allow client-updates：允许客户端发起的 DDNS 更新请求，这是一个可选项。
ddns-domainname-servers：指定 DNS 服务器列表。
在每个 DHCP 客户端配置中，使用 ddns-hostname 属性指定主机名和域名，例如：

host test {
  hardware ethernet 08:00:07:26:c0:a5;
  fixed-address 192.0.2.10;
  ddns-hostname "test.example.com";
}
这里 ddns-hostname 属性指定了客户端的主机名和域名。 客户端在向 DHCP 服务器请求新的 IP 地址时，DHCP 服务器将使用这些信息来动态地为客户端在 DNS 上创建相应的 A/AAAA 记录 。

至此，ISC DHCP 就配置完成了 DDNS 设置。当某个客户端在 DHCP 服务器上启用并绑定了 DDNS 功能时，它就可以自动地为其动态 IP 地址创建或更新 DNS A/AAAA 记录。 请注意，对于 DDNS 的使用要求网络与 DNS 系统的完美配合，只有这样该功能才能正常工作。

