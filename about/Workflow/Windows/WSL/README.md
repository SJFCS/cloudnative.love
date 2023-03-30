---
title: WSL + Docker 环境配置
---
本文介绍 WSL + Docker 环境配置

:::tip 安利 wsl 工具
- 用于管理 Linux (WSL)的 Windows 子系统的全功能实用程序：https://github.com/DDoSolitary/LxRunOffline
  - 可以通过 `LxRunOffline list -v` 命令来查看WSL的IP地址和GUID：
- 建议安装[windows terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=zh-cn&gl=cn)配合 WSL2 食用
:::

## 安装 WSL
- 参考文档: https://learn.microsoft.com/zh-cn/windows/wsl/
### 启用系统可选组件

启用 **“系统虚拟机平台”** 和 **"适用于 Linux 的 Windows 子系统"** 可选组件。  
在“控制面板-所有控制面板项-程序和功能”，选择“启用或者关闭Windows功能”，勾选所需功能选项，或者管理员权限打开终端执行：
```powershell
# 启用 “系统虚拟机平台”
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# 启用 "适用于 Linux 的 Windows 子系统"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```
### 设置 WSL 版本
设置默认或某个具体 linux 发行版的 wsl 版本
```powershell
# 设置 wsl 默认版本
wsl --set-default-version 2
# 查看 wsl 版本
wsl -l -v
# 设置指定发行版 wsl 版本，<Distro> 替换为你的发行版的实际名称
wsl --set-version <Distro> 2
```
### 安装 wsl2 Linux 发行版
```powershell
wsl --list --online
wsl --install  --distribution Ubuntu
```
:::tip 可能遇到如下报错
```bash
Installing, this may take a few minutes...
WslRegisterDistribution failed with error: 0x800701bc
Error: 0x800701bc WSL 2 ?????????????????? https://aka.ms/wsl2kernel

Press any key to continue...
```
参考 https://github.com/microsoft/WSL/issues/5393 前往 [微软WSL官网](https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-kernel) 下载 WSL2 Linux 内核即可。
:::

### 配置 Ubuntu Linux 发行版

```bash 初始化
export Current_User=$USER && sudo -E sh -c 'echo "$Current_User ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers'

sudo sh -c 'sed -i.bak "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list'

apt update && apt upgrade -y

sudo apt-get install ca-certificates

echo "export PS1=$'\\[\E[1m\E[34m\\]┌─[\\[\E[1m\E[32m\\]\\u@\h \\[\E[1m\E[35m\\]\\w\\[\E[1m\E[34m\\]]\n\\[\E[1m\E[34m\\]└──○ \[\e[1;33m\](\D{%H:%M.%S})\[\e[0m\] \\[\E[1m\E[34m\\]\$ '" >> ~/.bashrc
```
:::tip 
## 安装 Docker 
- 参考文档: https://docs.docker.com/engine/install/
- Docker Desktop(荐) 和 Desktop Server 任选一种方式。
:::

## Docker Desktop for windows

- 下载安装包: https://docs.docker.com/desktop/install/windows-install/
- 启动 Docker Desktop for Windows，点击“设置”按钮，启用基于WSL2的引擎复选框 "Use the WSL 2 based engine"
- 这时候在 WSL 里面执行 docker 命令还是找不到的  
  在 Resources 的 WSL Integration 中设置要从哪个 WSL2 发行版中访问 Docker
- 重启 Docker desktop for Windows，重启完成后我们就可以在 WSL2 里面使用 docker 命令了.
  在 WSL2 里面执行 df -Th,会发现增加了一些新的与 docker 有关的挂载点。

## Docker Server

因为 wsl2 使用了完整的linux内核，所以可以安装 Docker Server 。

### 脚本安装
```bash
curl -fsSL https://get.docker.com |bash -s -- --mirror Aliyun
```
:::tip
执行脚本安装过程中，脚本提示“建议使用Docker Desktop for windows”，20s内按Ctrl+C会退出安装，所以需要等待20s。

注意：WLS2下通过 `apt install docker-ce` 安装的 Docker 无法启动，因为 WSL2 方式的 Ubuntu 里面没有systemd。
上述官方 `get-docker.sh` 安装的 Docker，Dockerd 进程是用 Ubuntu 传统的 init 方式而非 systemd 启动的。
:::
### 添加用户组
把当前用户加入docker组，以获得 `unix:///var/run/docker.sock` 执行权限
```bash
sudo groupadd docker # 建立docker用户组
sudo usermod -aG docker $USER #将当前用户加入 docker 组
su - $USER # 重新登录ssh终端 刷新权限
```

:::tip
- Docker Desktop for windows 方式，是利用 Docker 的 C/S 架构，将 Windows 模式下的 docker.sock 和 Docker 数据目录挂载到 WSL2 的 linux 机器里面，WSL中的 Docker 客户端执行命令，通过挂载的 `/var/run/docker.sock` 与 Windows 中的 Docker Daemon 进程通信。

- 我们在 linux 下重启 linux 下 Docker Daemon 进程，`/var/run/docker.sock` 会被 Linux 下的 Docker Server 覆盖，此时 Docker 客户端通过 `/var/run/docker.sock` 文件与 linux 下的 Docker Daemon 服务端通信。

- 也可以使用 `docker -H tcp://<IP>:2375` 来指定连接 Windows 上的 Docker Daemon 还是 Linux 上的 Docker Daemon 。 
    ```bash title="也可以这样理解"
    sudo rm docker.sock && sudo ln -s /mnt/wsl/shared-docker/docker.sock /var/run/docker.sock
    ```
:::

## Docker-Compose
从 Docker 1.29 版本开始，"docker-compose" 命令被合并到 Docker CLI 中，并且可以通过 "docker compose" 命令运行。因此，现在 Docker 官方文档中推荐使用 "docker compose" 命令。

```bash
export Version="v2.17.2"
curl -L https://github.com/docker/compose/releases/download/${Version}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## FAQ
### 不支持 iptables 模式 导致 WSL 无法启动 Docker
**1. 现象**  
```bash
$ sudo service docker restart
 * Starting Docker:   [ OK ]
$ sudo service docker status
[FAIL] Docker is not running ..failed!
$ sudo cat /var/log/docker.log
failed to start daemon: Error initializing network controller: error obtaining controller instance: failed to create NAT chain DOCKER: iptables failed: iptables -t nat -N DOCKER: iptables/1.8.7 Failed to initialize nft: Protocol not supported
 (exit status 1)
```
**2. 原因&解决**  
Ubuntu 22.04 默认使用 nftables 作为防火墙，而非 iptables 。输入下面命令从 nftables 切换到 iptables。
```bash
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
```
参考文档: https://github.com/microsoft/WSL/discussions/4872?sort=top#discussioncomment-99164

### 网络冲突导致 WSL 无法启动 Docker
WSL 获得了一个与 Docker 网络冲突的 IP 地址，因此必须更改 WSL 或 Docker 的网络。更改 Docker 网络更容易，所以我建议这样做。创建或编辑`/etc/docker/daemon.json`并添加地址池设置：
```json
{
  "default-address-pools": [
    {
      "base": "192.168.0.0/16",
      "size": 24
    }
  ]
}
```

### WSL2 如何安装多个 Ubuntu
**1. 下载 Ubuntu WSL 系统文件**

到 https://cloud-images.ubuntu.com/releases/ 下载最新的 WSL 系统文件。  
例如 https://cloud-images.ubuntu.com/releases/21.10/release/ubuntu-21.10-server-cloudimg-amd64-wsl.rootfs.tar.gz

**2. Import Ubuntu**

运行一下命令导入 Ubuntu 的文件系统
```powershell
wsl --import <Distro 系统名称> <InstallLocation 安装目录> <FileName 镜像包> [Options]

# 例如
wsl --import ubuntu-2 "C:\Users\myname\WSL2\ubuntu2" "C:\Users\myname\Downloads\ubuntu-21.10-server-cloudimg-amd64-wsl.rootfs.tar.gz"
```

登录指定系统
```powershell
wsl -d <Distribution Name>
```

### WSL 如何迁移

查看已安装的 wsl 子系统发行版
```powershell
wsl -l --all -v
```

关闭指定 wsl 子系统发行版
```powershell
wsl --shutdown              #优雅关闭全部 WSL 实例
wsl --shutdown -d Ubuntu    #优雅关闭 WSL 实例
wsl --terminate -t Ubuntu    #强制终止 WSL 实例
```
导出 wsl 子系统发行版
```powershell
wsl --export Ubuntu c:\wsl-ubuntu.tar
```
 
删除 wsl 子系统发行版
```powershell
wsl --unregister Ubuntu
```
导入并安装 wsl 子系统发行版
```powershell
wsl --import Ubuntu c:\wsl-ubuntu c:\wsl-ubuntu.tar --version 2
```

设置为默认 wsl 子系统发行版
```powershell
wsl --set-default Ubuntu
# 登录
wsl -d Ubuntu
```
### wsl import 之后的子系统，会默认root用户登录，如何指定用户？

- 手动指定用户
```powershell
wsl -d <distro> -u <username>
```
- 命令指定默认用户
```powershell
ubuntu config --default-user <username>
```
- 配置文件指定默认用户
打开 WSL 发行版的 Linux 终端并编辑 `/etc/wsl.conf` 文件。如果该文件不存在，请创建它。在该文件中添加以下行：
```conf
[user]
default=<username>
```
- 修改注册表指定默认用户
Windows + R 输入 regedit 并按回车键，打开注册表。导航到以下注册表路径：
```powershell
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\<distribution_GUID>
# <distribution_GUID>" 替换为您要更改默认用户的 WSL 发行版的 GUID。
# 可以查看 <distribution_GUID> 文件夹内的 DistributionName 来确定发行版
```
1. 在右侧窗格中，找到 "DefaultUid" 键，并双击它以编辑其值。
2. 在 "编辑 DWORD (32 位) 值" 对话框中，将 "数值数据" 更改为您要设置为默认用户的 Linux 用户的 UID(如1000)。
3. 单击 "确定" 保存更改并关闭注册表编辑器。

### VS Code 配置默认终端为 WSL

wsl 将 Windows 目录挂载到了 Linux 中，这一点比 Vagrnt/Docker + Remote Development 要方便，最起码不用为了同步目录而烦恼了。我们可以在任何目录下面执行 Linux 命令。

`Ctrl+,` 打开   VS Code 设置，搜索框输入 `Terminal › Integrated › Default Profile: Windows` ，将其改为 `Ubuntu (WSL)`

### VS Code 中的 WSL 乱码

```bash
sudo dpkg-reconfigure locales
# 使用空格键选中en_US.UTF-8、zh_CN.UTF-8
# 使用Tab键切换至OK，再将en_US.UTF-8选为默认。
```
### Ubuntu上的Node版本不支持“空位合并”运算符（??=）
我:
```
在wsl ubuntu 中运行node项目 报错如下，可是在windows和Linux中运行都没有问题，怀疑和wsl有关，帮我看一下
/core/bin/docusaurus.mjs:30
process.env.BABEL_ENV ??= 'development';
```
ChatGPT：
```
这个错误可能是因为在WSL Ubuntu上的Node版本不支持“空位合并”运算符（??=），而在Windows和Linux上的Node版本支持该运算符。您可以检查在WSL Ubuntu上安装的Node版本并确保它支持该运算符。或者，您可以考虑在代码中使用传统的变量赋值运算符（=）来避免这个问题。
```

ChatGPT YYDS !!!

然后我跑去[升级 nodejs 版本](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04)后就解决了

### 关于 WSL 的网络堆栈

WSL (Windows Subsystem for Linux) 实际上是在 Windows 系统上运行的一个 Linux 虚拟机，它与 Windows 系统共享同一个网络栈。因此，当在WSL中运行的应用程序监听本地端口时，它们实际上是在 Windows 系统上监听该端口，因此可以通过 Windows 系统上的 IP 地址和端口号来访问这些应用程序。这种共享本地端口的机制使得 WSL 可以与 Windows 系统之间进行无缝的网络通信。

**不想 wsl 与 Windows 系统共享同一个网络栈**

如果您不想WSL与Windows系统共享同一个网络栈，可以通过配置 WSL 的网络模式来实现。WSL 支持两种网络模式：默认的 “基于Windows的网络模式” 和 “桥接网络模式” 。在 “桥接网络模式” 下， WSL 将使用自己的网络栈，与Windows 系统分开。要启用 “桥接网络模式” ，请按照以下步骤操作：
- 运行命令：`wsl --set-version <distribution name> 2` 将WSL版本设置为2。
- 在 WSL 中编辑 `/etc/wsl.conf` 文件（如果文件不存在，则创建它），添加以下内容：
  ```conf
  [network]
  generateResolvConf = false
  ```
- 在 WSL 中编辑 `/etc/resolv.conf` 文件，将其中的DNS服务器地址设置为您的路由器或互联网服务提供商提供的 DNS 服务器地址。
- 重启 WSL ，使更改生效。
  ```powershell
  wsl --shutdown -d Ubuntu    #优雅关闭 WSL 实例，直到再次打开 WSL 并开始使用它。
  ```