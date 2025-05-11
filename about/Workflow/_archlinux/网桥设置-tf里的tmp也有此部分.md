docker network create \
 --driver bridge \
 --subnet=192.168.8.0/24 \
 --gateway=192.168.8.1 \
 -o "com.docker.network.bridge.name"="br0" \
 custom_bridge

docker network create --driver bridge --subnet 192.168.8.0/24 --gateway 192.168.8.1 mynet2

docker 172.17.0.1/16
svc 10.96.0.0/12
pod 172.16.0.1/12
node 192.168.8.0/24

删除 Docker 的网络配置文件：
sudo rm -rf /var/lib/docker/network

网络 - 使用桥接模式
对于持久化配置，实际上不需要安装 bridge-utils，我们可以直接使用 systemd-networkd 来管理网络配置。以下是使用现代方式的持久化配置步骤： 2. 创建网桥配置文件 /etc/systemd/network/br0.netdev:
[NetDev]
Name=br0
Kind=bridge 3. 配置网桥接口 /etc/systemd/network/br0.network:
[Match]
Name=br0
[Network]
DHCP=yes 4. 配置物理网卡 /etc/systemd/network/enp46s0.network:
[Match]
Name=enp46s0 # 替换为实际的网卡名
[Network]
Bridge=br0 5. 重启网络服务:
sudo systemctl restart systemd-networkd
sudo systemctl enable systemd-networkd
临时配置命令(重启后失效):

1. 创建并启用网桥:
   sudo ip link add name br0 type bridge
   sudo ip link set br0 up
2. 将物理网卡加入网桥:
   sudo ip link set enp46s0 up # 替换为实际的网卡名
   sudo ip link set enp46s0 master br0
3. 配置网桥 IP(使用 DHCP): paru -S dhclient  
    sudo dhclient br0
   ip link show type bridge # 查看网桥
   ip addr show br0 # 查看网桥 IP 配置

---

sudo brctl addbr br0 # 创建网桥
sudo brctl addif br0 enp46s0 # 将网卡加入网桥
sudo ip link set br0 up # 启用网桥

# sudo ip link set up br0

# # sudo ip addr del dev enp46s0 192.168.8.233/24

sudo dhclient br0 # 配置 IP

# sudo brctl show

# Network Manager

```bash
❯ nmcli con add type bridge ifname br0

连接 "bridge-br0" (36e2e710-1588-4dde-801e-94da699c1a4f) 已成功添加。
❯ nmcli con add type bridge-slave ifname enp46s0 master br0

连接 "bridge-slave-enp46s0" (b4c507b9-2b3e-47f0-9243-a768b7d9a61d) 已成功添加。
❯ nmcli con mod br0 ipv4.method auto

❯ nmcli con mod bridge-br0 ipv4.method auto

❯ nmcli con show

NAME                  UUID                                  TYPE      DEVICE
bridge-br0            36e2e710-1588-4dde-801e-94da699c1a4f  bridge    br0
Redmi_0F30_5G         e573915a-3263-4080-abf8-9b14e57c9bbf  wifi      wlan0
bridge-slave-enp46s0  b4c507b9-2b3e-47f0-9243-a768b7d9a61d  ethernet  enp46s0
lo                    43eb5252-ab64-4b34-b255-4991bf17c62a  loopback  lo
Mihomo                88aa6686-8ae6-4dac-988f-b108b6c82966  tun       Mihomo
docker0               65973f4e-1ad2-4b70-ac37-e93c149c7a3b  bridge    docker0
virbr0                05b54e55-ffa4-407d-8ada-63499fa45da9  bridge    virbr0
enp46s0               ea990cd1-5acc-4b1c-8efc-e679e1b0dec6  ethernet  --
GL-AXT1800-054-5G     b041f891-160b-4e26-9119-4262bbc8805e  wifi      --

❯ nmcli con up bridge-br0

连接已成功激活（controller waiting for ports）（D-Bus 活动路径：/org/freedesktop/NetworkManager/ActiveConnection/11）
❯ nmcli con up bridge-slave-enp46s0
连接已成功激活（D-Bus 活动路径：/org/freedesktop/NetworkManager/ActiveConnection/13）

❯ ip addr show br0

8: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ba:8c:a1:e1:8d:6b brd ff:ff:ff:ff:ff:ff
    inet 192.168.8.134/24 brd 192.168.8.255 scope global dynamic noprefixroute br0
       valid_lft 43182sec preferred_lft 43182sec
    inet6 fe80::7599:27d0:26de:5d53/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

## 前言

云厂商通常会禁用 NetworkManager，主要是因为它与 cloud-init 可能存在冲突，或者在云环境中可能不需要其自动化的网络管理功能。

各个发行版都有自己的网络管理工具 ubunttu redhat 都不一样 还有通用的如 systemd-network 和 networkmanager 应该如何选择

1. NetworkManager
   适用场景：广泛用于桌面和移动设备的网络管理，特别适用于需要动态切换网络连接（例如 Wi-Fi、VPN 或以太网）等环境。 图形界面支持（如 GNOME 和 KDE 有自带的网络管理器界面）。 nmcli nmtui

### **systemd-networkd**

- **适用场景**：适用于轻量级、高度可定制的环境，通常用于服务器和嵌入式系统，或是对网络配置有明确要求的场景。
- **特点**：
  - 基于 `systemd`，通过 `systemd-networkd` 和 `systemd-resolved` 管理网络和 DNS 配置。
  - 适用于需要高度静态和精确控制的环境，如大规模服务器部署、虚拟机配置。
  - 配置文件简洁、清晰（通过 `/etc/systemd/network/` 配置）。

### 3\. **ifupdown / ifcfg（如在 Debian/Ubuntu 旧版本或 Red Hat/CentOS 中使用）**

- **适用场景**：传统的静态网络配置工具，适用于那些不需要动态网络管理的服务器环境。
- 通过修改 `/etc/network/interfaces` 或 `/etc/sysconfig/network-scripts/ifcfg-*` 文件来配置网络接口。
-

### 4\. **Netplan (Ubuntu 18.04 及以后版本)**

- **适用场景**：主要用于 Ubuntu 18.04 及其以后的版本，作为现代化的网络配置工具，通常与 `systemd-networkd` 或 `NetworkManager` 配合使用。
- **特点**：
  - 使用 YAML 配置文件，支持简洁的静态和动态网络配置。
  - 与 `systemd-networkd` 或 `NetworkManager` 兼容，可以指定后端网络管理工具。
-

在早期版本的 Red Hat 系列（如 RHEL 6）中，默认使用的网络管理工具是 `network-scripts`，它通过脚本和配置文件（通常位于 `/etc/sysconfig/network-scripts/`）来管理网络接口。每个网络接口都有一个对应的配置文件，例如 `ifcfg-eth0`。这种方式非常适合静态网络配置，但在动态和复杂网络场景中显得笨拙。

在现代的 Red Hat 系列操作系统（例如 **RHEL 7** 及更高版本，包括 CentOS Stream 和基于 RHEL 的发行版，如 AlmaLinux 和 Rocky Linux）中，网络管理主要通过以下工具实现：

---

### **1\. NetworkManager（默认工具）**

- **现状**：从 RHEL 7 开始，**NetworkManager** 成为了默认的网络管理工具，并完全取代了 `network-scripts`。
- **功能**：
  - 支持动态和静态网络配置。
  - 管理各种网络类型：以太网、Wi-Fi、VPN、桥接、VLAN、Bonding 等。
  - 提供多种管理方式：
    - **命令行工具**：
      - `nmcli`（命令行管理工具）。
      - `nmtui`（基于文本的图形化工具）。
    - **图形界面支持**（如 GNOME 桌面的网络设置）。
  - 自动化网络配置（适合动态网络环境，如云环境）。
  - 适合桌面和服务器环境，支持灵活的连接切换和复杂的网络需求。
- **配置文件路径**：`/etc/NetworkManager/system-connections/` 中存储连接配置文件，支持手动编辑（INI 格式）。

---

### **2\. systemd-networkd**

- **现状**：`systemd-networkd` 是 `systemd` 提供的轻量级网络管理服务，特别适合需要简单、静态网络配置的服务器或容器化环境。
- **功能**：
  - 配置静态网络接口和动态 IP（通过 DHCP）。
  - 适合嵌入式设备、虚拟机、容器等对资源占用敏感的场景。
  - 支持桥接、VLAN、Bonding 和其他高级网络功能。
- **管理方式**：
  - 配置文件存放在 `/etc/systemd/network/`。
  - 使用 `systemctl` 控制服务状态（`systemctl enable systemd-networkd`）。
- **与 NetworkManager 的关系**：
  - 通常在不需要 `NetworkManager` 时，才会选择 `systemd-networkd`。
  - 不提供动态网络连接切换能力，但更轻量且易于自动化。

---

### **3\. nmcli 和 nmtui**

- **nmcli**：NetworkManager 提供的强大命令行工具，可以完全控制网络设置。

  - **示例**：配置一个静态 IP 地址：

    ```
    bash
    复制代码

    `nmcli connection add type ethernet con-name static-eth0 ifname eth0 ip4 192.168.1.100/24 gw4 192.168.1.1
    nmcli connection up static-eth0
    `

    ```

- **nmtui**：NetworkManager 提供的基于文本界面的工具，适合不喜欢命令行但也没有图形界面的用户。

  - 启动：

    ```
    bash
    复制代码

    `nmtui
    `

    ```

---

### **4\. Netplan（仅部分衍生系统）**

- 虽然 Netplan 是 Ubuntu 系列的默认网络配置工具，但一些基于 RHEL 的发行版可能支持它作为额外工具。
- Netplan 本质上是一个前端，它将 YAML 配置翻译为 `NetworkManager` 或 `systemd-networkd` 的后端配置。

---

### **5\. 手动配置 (适用于 systemd-networkd 或其他工具)**

如果不使用 NetworkManager，可以直接通过编辑配置文件实现网络管理。示例如下：

#### 配置静态 IP：

在 `/etc/systemd/network/10-static.network` 中创建文件：

```
ini
复制代码

`[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
`

```

启用服务：

```
bash
复制代码

`systemctl enable systemd-networkd
systemctl restart systemd-networkd
`

```

---

### **总结：工具选择建议**

1.  **NetworkManager**：

    - 默认推荐工具，适合桌面和服务器环境，支持动态网络和复杂需求。
    - 管理方式灵活，推荐使用 `nmcli` 或 `nmtui`。

2.  **systemd-networkd**：

    - 适合轻量化和静态网络配置，适用于服务器、容器或嵌入式设备。
    - 如果你的网络需求较为固定，可选择 `systemd-networkd`。

3.  **传统 `network-scripts`（已弃用）**：

    - RHEL 8 已完全移除，建议迁移到 `NetworkManager` 或 `systemd-networkd`。

根据需求选择工具，并注意兼容性和未来支持情况。
