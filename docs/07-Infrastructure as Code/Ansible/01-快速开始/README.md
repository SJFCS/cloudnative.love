---
title: 快速开始
sidebar_position: 1
---
import CodeBlock from '@theme/CodeBlock';
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import vagrantfile from '!!raw-loader!../Ansible-Playground/Vagrantfile';
import config from '!!raw-loader!../Ansible-Playground/config.yaml';

本节带你快速入门使用 Ansible，包括 Ansible 配置、Invenytory 与 Ad-Hoc 的使用方法。

## 环境初始化

:::info环境准备

在开始前，我们需要准备实验所用到的主机。
<details>
<summary>这里为您准备了 Vagrant 环境，可以一键启动如下环境</summary>

在**新建目录**中创建如下 `config.yaml` 和 `Vagrantfile` 文件，然后**在此目录中**执行 `vagrant up` 即可启动练习环境。关于 Vagrant 更多使用方法详见：[Vagrant](/docs/Infrastructure%20as%20Code/Vagrant/)

启动后使用 `vagrant ssh <host_name>` 登录到对环境的各个节点进行初步检查：

输入 `hostname && hostname -d && hostname -f` 分别检查主机名、主机域和FQDN。

输入 `cat /etc/hosts` 检查 Hosts 配置是否正确。

  [**Vagrant 环境配置文件：**](https://github.com/SJFCS/cloudnative.love/tree/main/docs/8-Infrastructure%20as%20Code/Ansible/Ansible-Playground)
  <Tabs>
  <TabItem value="config.yaml">
  <CodeBlock language="yaml" title="config.yaml">{config}</CodeBlock>
  </TabItem>
  <TabItem value="Vagrantfile">
  <CodeBlock language="ruby" title="Vagrantfile">{vagrantfile}</CodeBlock>
  </TabItem>
  </Tabs>
</details>

| Hostname | OS               | IP             | Describe                 |
| -------- | ---------------- | -------------- | ------------------------ |
| control  | centos/7:1809.01 | 192.168.56.100 | ansible 已经安装在此节点 |
| node1    | centos/7:1809.01 | 192.168.56.10  |                          |
| node2    | centos/7:1809.01 | 192.168.56.20  |                          |
| node3    | centos/7:1809.01 | 192.168.56.30  |                          |

我们的 ansible 配置创建在 control 节点上 `/home/vagrant/ansible` 目录下。
:::

### 设置免密登录

Ansible 通过 SSH 协议连接远程主机进行操作，为了安全考虑建议通过密钥免密连接而不是密码，如果使用密码 Ansible 则会使用 sshpass 来实现自动登录，这被认为是不安全的。

<details style={{backgroundColor: 'rgb(255, 248, 230)', border: '1px solid rgb(230, 167, 0)'}}>
<summary>sshpass 安全问题和建议</summary>

:::caution
sshpass 存在以下安全问题：
- 密码以明文形式传递，在查看 sshpass 进程时，可能会获取到密码。这是因为在某些系统中，命令行参数会被保存在进程的环境变量中，因此密码可能会被保存在 sshpass 进程的环境变量中。
- 当手动运行 sshpass 时密码存储在命令行历史记录中，可能会被其他用户（如管理员）查看。

如果非要使用密码建议：
- 不要直接将密码明文写在 inventory 中，请将密码作为外置变量引入并使用 vault 来加密。
- 在手动运行 sshpass 命令时，使用 -e 选项来禁用密码在环境变量中的传递。
- 限制 sshpass 进程的访问权限，避免不必要的特权用户访问进程，从而减少密码泄露的风险。
:::

</details>

<details>
<summary>SSH 安全配置选项</summary>

:::info
大量的远程主机都使用同一个密码提供 ssh 远程登录是很不安全的，一般都建议所有主机都只开启私钥登录，禁用密码登录。相关配置在主机的 `/etc/ssh/sshd_config` 中。可使用如下脚本进行设置。

```bash
#!/bin/bash
#### 可能会重复，需要仔细查看改完的文件去重
# 根据你的需求设置 SSH 配置变量

PermitRootLogin=no         # 是否允许 root 用户通过 SSH 登录系统。
# RSAAuthentication=yes      # 允许 RSA 秘钥认证
PubkeyAuthentication=yes   # 是否允许使用密钥进行 SSH 登录。
PasswordAuthentication=no  # 是否允许使用密码进行 SSH 登录。
PermitEmptyPasswords=no    # 是否允许用户使用空密码登录系统。
X11Forwarding=no           # 是否允许启用 X11 转发功能，开启后可在 SSH 会话中运行图形界面程序。

# 例子：sed --in-place=.bak -r 's/^#?(PermitRootLogin|PermitEmptyPasswords|PasswordAuthentication|X11Forwarding) yes/\1 no/' /etc/ssh/sshd_config
sudo cat /etc/ssh/sshd_config | grep -e "PubkeyAuthentication" -e "PermitRootLogin" -e "PasswordAuthentication" -e "PermitEmptyPasswords" -e "X11Forwarding"
# 编辑 sshd_config 文件
sudo sed -i.bak -r \
  -e "s/^(#)?PermitRootLogin\s+(yes|no)/PermitRootLogin $PermitRootLogin/" \
  -e "s/^(#)?PubkeyAuthentication\s+(yes|no)/PubkeyAuthentication $PubkeyAuthentication/" \
  -e "s/^(#)?PasswordAuthentication\s+(yes|no)/PasswordAuthentication $PasswordAuthentication/" \
  -e "s/^(#)?PermitEmptyPasswords\s+(yes|no)/PermitEmptyPasswords $PermitEmptyPasswords/" \
  -e "s/^(#)?X11Forwarding\s+(yes|no)/X11Forwarding $X11Forwarding/" \
  /etc/ssh/sshd_config

sudo cat /etc/ssh/sshd_config | grep -e "PubkeyAuthentication" -e "PermitRootLogin" -e "PasswordAuthentication" -e "PermitEmptyPasswords" -e "X11Forwarding"
```

然后手动重启 sshd 服务 `systemctl restart sshd`
:::
</details>

在 control 节点上创建密钥对并分发给其他 node 节点。
```bash
# 创建密钥对
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q
# 查看公钥
cat ~/.ssh/id_rsa.pub  
# 分发公钥
sshpass -p <your_passwd> ssh-copy-id -i ~/.ssh/id_rsa.pub <user@IP>
```

若 SSH 禁止了密码登录，需要登录 node 节点上手动导入 control 节点的公钥。
```bash
# 手动在需要免密的节点上做以下配置
mkdir -p -m 700 ~/.ssh
echo "<control_public_key>" >> ~/.ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```


<details>
<summary>使用脚本验证免密</summary>

使用前请确保已扫描并添加主机指纹。

```bash
#!/bin/bash
user=vagrant
StrictHostKeyChecking=yes

# 自动从 hosts 中设置 hosts 变量
# hosts=($(awk '$0 !~ /^#/ {for(i=1;i<=NF;i++) if ($i !~ /localhost/) print $i}' /etc/hosts))
# echo ${hosts[@]}
hosts=(
control
node1
node2
node3
control.lab.local
node1.lab.local
node2.lab.local
node3.lab.local
192.168.56.100
192.168.56.10
192.168.56.20
192.168.56.30
)

printf "%-70s %-15s %-50s\n" "Node" "Status" "Describe"

for host in "${hosts[@]}"; do
  describe=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=${StrictHostKeyChecking} ${user}@${host} "echo Logged in to $host without password" 2>&1)
  if [ $? -eq 0 ]; then
    printf "%-70s \033[32m%-15s\033[0m %-50s\n" "$host" "yes" "$describe"
  else
    printf "%-70s \033[31m%-15s\033[0m %-50s\n" "$host" "no" "$describe"
  fi
done
```

若失败则可能是你没有添加主机指纹，请看下一节 **'批量扫描主机指纹'**

或者修改脚本使 `StrictHostKeyChecking=no` ，此时 SSH 首次连接会跳过检查主机密钥的指纹，客户端不会询问你是否信任该服务器的密钥，而是自动接受该密钥并将其保存在 ~/.ssh/known_hosts。

</details>

### 批量扫描主机指纹

第一次连接到一个 SSH 服务器时，会提醒我们检查主机密钥的指纹。 SSH 客户端会将服务器的公钥存储在本地计算机上，并生成一个指纹，以便在将来的连接中验证服务器的身份。如果指纹与之前存储的不匹配，则可能是中间人攻击，应该中止连接。

Ansible 默认情况下也会使用这个指纹对主机进行验证，因此我们希望能够快速地扫描出所有主机的指纹，下面提供了两种方法：

<Tabs>
<TabItem value="ssh-keyscan 扫描添加主机指纹">

登录 Ansible 所在节点 control 运行如下命令：
```shell
echo "
control
node1
node2
node3
192.168.56.100
192.168.56.10
192.168.56.20
192.168.56.30
" > hosts-keyscan
ssh-keyscan -H -f hosts-keyscan >> ~/.ssh/known_hosts
# 添加 -H 参数，只保存主机 IP/域名的 hash 值，更安全
```

</TabItem>
<TabItem value="临时忽略指纹验证，实现批量添加指纹">

当使用 `ssh -o StrictHostKeyChecking=no user@host` 时，SSH 首次连接会跳过检查主机密钥的指纹，客户端不会询问你是否信任该服务器的密钥，而是自动接受该密钥并将其保存在 ~/.ssh/known_hosts。设置 Ansible 临时忽略指纹验证也可以做到这一点，如下开启 `ANSIBLE_HOST_KEY_CHECKING=false` 变量，然后选中所有主机，运行任意模块即可完成主机指纹的扫描和添加：

```shell
# 使用环境变量 ANSIBLE_HOST_KEY_CHECKING 临时关闭主机指纹检查
ANSIBLE_HOST_KEY_CHECKING=false ansible -i inventory all -m ping
```

</TabItem>
</Tabs>

:::caution
不建议修改 ansible.cfg 使 `host_key_checking = False` 永久跳过检查主机指纹，这可能会受到中间人攻击。
:::

### 设置 sudo 权限
Vagrant 在创建虚拟机时，会在 `/etc/sudoers.d` 目录下创建一个名为 `vagrant` 的文件，该文件包含以下内容：
```bash title="sudo cat /etc/sudoers.d/vagrant"
%vagrant ALL=(ALL) NOPASSWD: ALL
```
上述配置使 vagrant 组的用户使用 sudo 无需密码。
## Ansible 配置文件

:::info配置文件生效优先级
1. `$ANSIBLE_CONFIG` 变量
2. 当前目录下 `ansible.cfg`
3. 用户家目录下 `ansible.cfg`
4. `/etc/ansible/ansible.cfg` (默认)

通过 `ansible --version` 可以看到配置文件目录等信息

可以通过 `ansible-config init --disabled -t all >ansible.cfg` 创建初始配置，其包含了详细的参数说明。通过 `cat /etc/ansible/ansible.cfg|grep -Ev ";|#|^$"` 查看默认配置。
:::

登录 control 节点，创建工作目录 `mkdir ~/ansible && cd ~/ansible` ，然后创建如下配置

```ini title="/home/vagrant/ansible/ansible.cfg"
[defaults]
inventory = ./inventory       
remote_port    = 22
; host_key_checking = False
remote_user = vagrant
log_path = ./ansible.log
private_key_file = /home/vagrant/.ssh/id_rsa

[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False
```

## inventory 主机清单

使用 inventory 主机清单以对主机进行分类，对不同类别的主机配置不同的参数，例如 ssh 登录用户名，密码信息和变量等。

```ini title="/home/vagrant/ansible/inventory"
# 给服务器分组，组名只能用 [a-z A-Z 0-9 _]
[ansible_control]
control
192.168.56.100:22 
[node]
node1.lab.local ansible_port=22 ansible_ssh_private_key_file=/home/vagrant/.ssh/id_rsa
; node1.lab.local ansible_ssh_port='22' ansible_ssh_user='root' ansible_ssh_pass='passwd' 
192.168.56.[2:3]0

# node 组的公用参数
[node:vars]
myvar='hello world'
ansible_ssh_user='vagrant'
; ansible_ssh_pass='vagrant'
; ansible_ssh_port='22'
; ## 如果登陆后需要切换用户则需要以下配置
; # 切换用户
; ansible_become=true
; # 使用su切换
; ansible_become_method=su
; # 切换到root
; ansible_become_user=root
; # root密码
; ansible_become_pass=pass

# 子组分类变量：children
[labmachine:children]
ansible_control
node

# 给服务器指定别名
[alias]
ansible ansible_host=control.lab.local 
```
<details style={{backgroundColor: '#e9f5e7', border: '1px solid rgb(0, 148, 0)'}}>
<summary>inventory ini 和 yaml 格式转换</summary>

:::tip
inventory 主机清单支持 ini 和 yaml 格式。

可以使用以下命令将上述 inventory 从 ini 格式转换到 yaml 格式：

```bash
ansible-inventory --list -i inventory --yaml > inventory.yaml
```
输出 inventory.yaml 内容如下
```yaml title="inventory.yaml"
all:
  children:
    alias:
      hosts:
        ansible:
          ansible_host: control.lab.local
    labmachine:
      children:
        ansible_control:
          hosts:
            192.168.56.100:
              ansible_port: 22
            control: {}
        node:
          hosts:
            192.168.56.20:
              ansible_ssh_user: vagrant
              myvar: hello world
            192.168.56.30:
              ansible_ssh_user: vagrant
              myvar: hello world
            node1.lab.local:
              ansible_port: 22
              ansible_ssh_private_key_file: /home/vagrant/.ssh/id_rsa
              ansible_ssh_user: vagrant
              myvar: hello world
    ungrouped: {}
```
:::

</details>

写完 inventory 主机清单后，输入下面命令，应成功输出节点信息。
```bash
ansible  all --list-hosts
# 和下面等价
# ansible -i inventory all --list-hosts
# ansible -i inventory.yaml all --list-hosts

# 使用 ping 模块检查网络是否互通
ansible all -i inventory -m ping
```

到此已成功安装和配置 ansible ，下面介绍如何使用 Ad-hoc 模式执行临时命令。

## Ad-hoc 临时命令
ansible 中有两种模式：
- Ad-hoc 模式，用于执行一段 “临时命令”
- Playbook 模式，用于执行声明性配置的一组任务。

<details>
<summary>Ansible 基本命令选项</summary>

```bash
ansible <host-pattern> [options]
--version	#显示ansible版本信息
-i			#指定主机清单文件路径，默认是在/etc/ansible/hosts
-m			#指定模块名称，默认使用command模块
-a			#指定模块参数
-e			#指定变量
-f			#指定并发数，默认5
-C			#模拟测试，不会真正执行
-D			#显示这些文件的差异。常与-C一起使用
--syntax	#语法检查
--list-hosts #列出主机清单
-k			#提示输入ssh密码，而不是用ssh的密钥认证
-T			#执行命令的超时时间
```
</details>

:::tipAd-hoc 命令格式
- `ansible <pattern> -m <module_name> -a "<module options>"`
  - 例如 `ansible webservers -m service -a "name=httpd state=restarted"`
- 默认模块是 "command"
  - 如下面两条命令使用的模块都是 command。
  ```bash
  ansible all -i inventory -m command -a "ls -al"
  # command 为缺省模块可以省略不写。
  ansible all -i inventory -a "ls -al"
  ``` 
:::

Ansible 提供了海量模块，可以通过 `ansible-doc -l` 查看可用模块，使用 `ansible-doc <mode_name>` 查看模块具体用法。
