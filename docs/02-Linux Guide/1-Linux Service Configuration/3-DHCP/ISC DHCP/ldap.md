以下是一个DHCP和LDAP结合使用的示例：

假设你是一家公司的网络管理员，你需要控制由特定组织成员使用的计算机所分配的IP地址。你将使用LDAP存储组织成员的信息。为此，你需要在DHCP服务器上配置LDAP支持，并将其配置为从LDAP目录中提取数据以分配IP地址。

首先，你需要在LDAP目录中添加组织成员信息。例如，你可以创建一个名为“组织成员”的LDAP组，其中包含组织成员的用户名和MAC地址。假设你的组织成员名为“John Smith”，他的MAC地址为“12:34:56:78:90:AB”，则你将在LDAP目录中添加以下条目：

dn: cn=John Smith,ou=组织成员,dc=example,dc=com objectClass: top objectClass: person objectClass: organizationalPerson cn: John Smith sn: Smith givenName: John macAddress: 12:34:56:78:90:AB

接下来，你需要在DHCP服务器上配置LDAP支持。你将使用开源DHCP服务器，如ISC DHCP。你需要安装和配置LDAP支持插件，如dhcp-extras，以便DHCP可以连接到LDAP目录。

你可以在DHCP服务器上设置以下LDAP选项，以便只为“组织成员”组中列出的机器分配IP地址：

ldap-server "ldap.example.com"; ldap-mode standalone; ldap-debug-file "/var/log/dhcp-ldap-debug" ldap-port 389; ldap-auth-method simple ldap-bind-user "cn=ldapuser,ou=users,dc=example,dc=com"; ldap-bind-password "ldappassword"; ldap-base-dn "ou=组织成员,dc=example,dc=com"; ldap-scope sub; ldap-search-filter "(objectClass=person)"; ldap-dhcp-server-cn "dhcpserver.example.com"; ldap-dhcp-server-fqdn "dhcpserver.example.com"; ldap-dhcp-max-dns-update-delay 120; ldap-dhcp-server-common-name "dhcp.example.com";

以上选项中，“ldap-server”指定LDAP服务器的地址，“ldap- base-dn”指定LDAP搜索基本DN，“ldap-dhcp-server-cn”指定DHCP服务器的通用名称等。

接下来，你需要将DHCP选项与LDAP条目匹配，以便为特定MAC地址分配IP地址。为此，你可以添加以下DHCP选项定义：

host machine1 { hardware ethernet 12:34:56:78:90:AB; fixed-address 192.168.1.10; option routers 192.168.1.1; }

其他机器可以被添加到相同的配置文件中。当DHCP服务器启动并接收到客户端请求时，它将从LDAP目录中提取组织成员信息并查找条目的MAC地址。如果匹配，则DHCP服务器将分配预定义的IP地址。

通过DHCP和LDAP结合使用，你可以轻松地控制机器的访问和分配IP地址，并通过LDAP来管理和控制访问权限。