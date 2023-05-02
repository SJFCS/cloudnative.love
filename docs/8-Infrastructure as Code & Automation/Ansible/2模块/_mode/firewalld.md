# firewalld模块

[[toc]]

## 1. 概要

- 本模块可以用于添加或删除服务或端口的防火墙规则。
- 本模块是[ansible.posix collection](https://galaxy.ansible.com/ansible/posix)的一部分。
- 可以使用 `ansible-galaxy collection install ansible.posix`安装该模块。
- 依赖包：`firewalld >= 0.2.11`和 `python-firewall >= 0.2.11`。
- 官方文档： [https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html)

## 2. 参数

| 参数                                                                                                                                                                                                     | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| icmp_block string                                                                                                                                                                                        | 您要添加/删除firewalld区域的ICMP块                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| icmp_block_inversion string                                                                                                                                                                              | 在防火墙中启用/禁用ICMP块的反转                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| immediate boolean                                                                                                                                                                                        | 是否立即生效，默认no                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| interface string                                                                                                                                                                                         | 添加/删除 出入防火墙的接口                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| masquerade string                                                                                                                                                                                        | 在防火墙中想启用/禁止的masquerade设置.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| offline boolean                                                                                                                                                                                          | 当firewalld离线时是否运行本模块，默认no                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| permanent boolean                                                                                                                                                                                        | 保存策略，在下次启动时自动加载,永久生效                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| port string                                                                                                                                                                                              | 指定放行的端口/协议                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| port_forward  list/**elements=dictionary**                                                                                                                                                         | 使用firewalld转发的端口或协议.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| >>>   port string/**required**                                                                                                                                                                     | 防火墙原始端口                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| >>>  proto string/**required**                                                                                                                                                                     | 转发协议，udp或 tcp                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| >>> toaddr string                                                                                                                                                                                        | 转发到哪个地址                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| >>> toport string/**required**                                                                                                                                                                     | 目标端口                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| rich_rule tring                                     | 添加或删除富规则到防火墙. See[Syntax for firewalld rich language rules](https://firewalld.org/documentation/man-pages/firewalld.richlanguage.html).                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| service string                                         | 添加/删除防火墙中的服务，服务名必须在`firewall-cmd –get-services`列表中.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| source string                                           | 需要添加或删除的 源或网络.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **state** string/**required**                          | Enable开启或 disable关闭， 对于端口: 应该是端口被接受accept (enabled) 或者被拒绝 reject (disabled) 连接. `present`和`absent`只能使用于zone区域操作. 可选值： **absent** **disabled** **enabled** **present**                                                                                                                                                                                                                                |
| **target** string  | 防火墙区域目标, 如果`state = absent`，那么此处设置将会设置为`default`,可选值： **default** **ACCEPT** **DROP** **%%REJECT%%**                                                                                                                                                                                                                                                                                                                                                                                                                     |
| timeout integer                                        | 当未设置永久生效时，规则生效秒数                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| zone string                                               | 需要处理的zone区域，可选值：block, dmz, drop, external, home, internal, public, trusted, work |

## 3. 官方示例

```yaml
- name: permit traffic in default zone for https service
  ansible.posix.firewalld:
    service: https
    permanent: yes
    state: enabled

- name: do not permit traffic in default zone on port 8081/tcp
  ansible.posix.firewalld:
    port: 8081/tcp
    permanent: yes
    state: disabled

- ansible.posix.firewalld:
    port: 161-162/udp
    permanent: yes
    state: enabled

- ansible.posix.firewalld:
    zone: dmz
    service: http
    permanent: yes
    state: enabled

- ansible.posix.firewalld:
    rich_rule: rule service name="ftp" audit limit value="1/m" accept
    permanent: yes
    state: enabled

- ansible.posix.firewalld:
    source: 192.0.2.0/24
    zone: internal
    state: enabled

- ansible.posix.firewalld:
    zone: trusted
    interface: eth2
    permanent: yes
    state: enabled

- ansible.posix.firewalld:
    masquerade: yes
    state: enabled
    permanent: yes
    zone: dmz

- ansible.posix.firewalld:
    zone: custom
    state: present
    permanent: yes

- ansible.posix.firewalld:
    zone: drop
    state: enabled
    permanent: yes
    icmp_block_inversion: yes

- ansible.posix.firewalld:
    zone: drop
    state: enabled
    permanent: yes
    icmp_block: echo-request

- ansible.posix.firewalld:
    zone: internal
    state: present
    permanent: yes
    target: ACCEPT

- name: Redirect port 443 to 8443 with Rich Rule
  ansible.posix.firewalld:
    rich_rule: rule family=ipv4 forward-port port=443 protocol=tcp to-port=8443
    zone: public
    permanent: yes
    immediate: yes
    state: enabled
```

此模块不详细展开。