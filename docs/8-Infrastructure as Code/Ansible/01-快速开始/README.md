---
title: 快速开始
sidebar_position: 1
---
import CodeBlock from '@theme/CodeBlock';
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import vagrantfile from '!!raw-loader!../Ansible-Playground/vagrantfile';
import config from '!!raw-loader!../Ansible-Playground/config.yaml';

本节带你快速入门使用 Ansible，包括 Ansible 配置、Invenytory 与 Ad-Hoc 的使用方法。

## 环境初始化
:::info环境准备

在开始前，我们需要准备实验所用到的主机。
<details>
<summary>这里为您准备了 Vagrant 环境，可以一键启动如下环境</summary>

在**新建目录**中创建 `config.yaml` 和 `Vagrantfile` 文件后**在此目录中**执行 `vagrant up` 即可启动练习环境。vagrant 安装和使用详见：[Vagrant](/docs/Infrastructure%20as%20Code/Vagrant/)

启动后 `vagrant ssh <host_name>` 登录到对环境的各个节点进行初步检查：

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

### 批量扫描主机指纹

ssh 首次连接时会要求验证主机指纹，这是一种安全措施，防止在遇到 DNS 污染或 IP 冲突等异常情况时，目标主机被冒名顶替。

Ansible 默认情况下也会使用这个指纹对主机进行验证，因此我们希望能够快速地扫描出所有主机的指纹。

- ssh-keyscan

  登录 ansible 所在节点 control 运行如下命令：
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

:::caution
不建议修改 ansible.cfg 使 `host_key_checking = False` 或者设置变量 `ANSIBLE_HOST_KEY_CHECKING=false` 跳过检查主机指纹。
:::

### 设置免密登录

Ansible 通过 SSH 协议连接远程主机进行操作，为了安全考虑建议通过密钥免密连接而不是密码，如果使用密码则 Ansible 会使用 sshpass 来实现自动登录，这被认为是不安全的。

:::caution
sshpass 存在以下安全问题：
- 密码以明文形式传递，在查看 sshpass 进程时，可能会获取到密码。这是因为在某些系统中，命令行参数会被保存在进程的环境变量中，因此密码可能会被保存在 sshpass 进程的环境变量中。
- 手动运行 sshpass 时密码存储在命令行历史记录中，可能会被其他用户（如管理员）查看。
:::

如果非要使用密码建议：
- 请不要直接将密码明文写在 inventory 中，请将密码作为外置变量引入并使用 vault 来加密。
- 在使用 sshpass 命令时，使用 -e 选项来禁用密码在环境变量中的传递。
- 限制 sshpass 进程的访问权限，避免不必要的特权用户访问进程，从而减少密码泄露的风险。

control 节点上创建密钥对并分发给其他 node 节点
```bash
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q && cat ~/.ssh/id_rsa.pub  
sshpass -p <your_passwd>  ssh-copy-id -i ~/.ssh/id_rsa.pub <user@IP>
```

vagrant 默认禁止密码登录，需要登录 node 节点上手动导入 control 节点的公钥
```bash
# 手动在需要免密的节点上做以下配置
mkdir -p -m 700 ~/.ssh
echo "<control_public_key>" >> ~/.ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```

:::infoSSH安全配置选项
大量的远程主机都使用同一个密码提供 ssh 远程登录是很不安全的，一般都建议所有主机都只开启私钥登录，禁用密码登录。相关配置在主机的 `/etc/ssh/sshd_config` 中。可使用如下脚本进行设置。

```bash
#!/bin/bash

# 例子：sed --in-place=.bak -r 's/^#?(PermitRootLogin|PermitEmptyPasswords|PasswordAuthentication|X11Forwarding) yes/\1 no/' /etc/ssh/sshd_config

sudo cat /etc/ssh/sshd_config | grep -e "PubkeyAuthentication" -e "PermitRootLogin" -e "PasswordAuthentication" -e "PermitEmptyPasswords" -e "X11Forwarding"

# 设置 SSH 配置变量
PermitRootLogin=no        # 是否允许 root 用户通过 SSH 登录系统。
PubkeyAuthentication=yes   # 是否允许使用密钥进行 SSH 登录。
PasswordAuthentication=no  # 是否允许使用密码进行 SSH 登录。
PermitEmptyPasswords=no   # 是否允许用户使用空密码登录系统。
X11Forwarding=no           # 是否允许启用 X11 转发功能，开启后可在 SSH 会话中运行图形界面程序。
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
:::

### 设置 sudo 权限
Vagrant 在创建虚拟机时，会在 `/etc/sudoers.d` 目录下创建一个名为 `vagrant` 的文件，该文件包含以下内容：
```bash title="sudo cat /etc/sudoers.d/vagrant"
%vagrant ALL=(ALL) NOPASSWD: ALL
```
实现了 vagrant 组的用户使用 sudo 无需密码。
## Ansible 的配置文件

:::info配置文件生效优先级
1. `$ANSIBLE_CONFIG` 变量
2. 当前目录下 `ansible.cfg`
3. 用户家目录下 `ansible.cfg`
4. `/etc/ansible/ansible.cfg` (默认)

通过 `ansible --version` 可以看到配置文件目录等信息

可以通过 `ansible-config init --disabled -t all >ansible.cfg` 创建初始配置。通过 `cat /etc/ansible/ansible.cfg|grep -Ev "#|^$"` 查看默认配置。
:::

登录 control 节点，创建工作目录 `mkdir ~/ansible && cd ~/ansible` ，然后创建如下配置

```ini title="/home/vagrant/ansible/ansible.cfg"
[defaults]
inventory = ./inventory       
remote_port    = 22
roles_path = ./roles
# host_key_checking = False
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

使用 inventory 以对主机进行分类 对不同类别的主机配置不同的参数，例如 ssh 登录用户名，密码信息和变量等

```ini title="/home/vagrant/ansible/inventory"
# 给服务器分组，组名只能用 [a-z A-Z 0-9_]
[ansible_control]
control
192.168.56.100:22
[node]
node1.lab.local
192.168.56.[2:3]0

[node:vars]
# node 组的公用参数
ntp_server=ntp.svc.local
proxy=proxy.svc.local
ansible_ssh_user='user'
ansible_ssh_pass='pass'
ansible_ssh_port='22'
## 如果登陆后需要切换用户则需要以下配置
# 切换用户
ansible_become=true
# 使用su切换
ansible_become_method=su
# 切换到root
ansible_become_user=root
# root密码
ansible_become_pass=pass

[labmachine:children]
# 子组分类变量：children
ansible_control
node

[alias]
# 给服务器指定别名（git），通过关键字参数指定其他参数
git ansible_host=control.lab.local ansible_port=225  ansible_ssh_private_key_file=<path/to/git-server-ssh>
# 使用指定的账号密码（危险！）
tester ansible_host=node1.lab.local ansible_ssh_user='root' ansible_ssh_pass='redhat' ansible_ssh_port='22'
```

:::tip
inventory 主机清单支持 ini 和 yaml 格式。

可以使用以下命令将 Ansible 的 inventory 文件从 ini 格式转换到 yaml 格式：

```bash
$ ansible-inventory --list -i inventory --yaml > 222.yaml

$ ansible-inventory --list -i inventory.yaml --ini --output=inventory.ini
$ ansible-inventory --list -i 222.yaml --ini > inventory.ini
$ ansible-inventory -i 222.yaml --list > 66.ini


-i 指定 inventory 文件路径
--list 指定输出格式为 json
--output 指定输出文件路径和文件名
```

需要注意的是，从 yaml 格式转换为 ini 格式时，需要使用 --list 选项将 yaml 文件转换为 json。因为 ini 文件不支持多层嵌套的结构，所以必须将其打平转换。而从 ini 格式转换为 yaml 格式时，由于 yaml 文件支持多层嵌套的结构，所以直接输出即可。

```shell
ansible-inventory -i xxx.yml --list --yaml
```

该命令会提示出你错误的配置，并且打印出最终得到的 yaml 配置内容。
:::


```bash
ansible  all --list-hosts

ansible -u vagrant -i inventory all -a "ls -al"

# 或者使用 ansible-console 交互式执行命令
ansible-console -i inventory all -u vagrant
```


## Ansible Ad-Hoc

### 1.什么是 ad-hoc 模式

> ad-hoc 简而言之，就是“临时命令”，不会保存
> ansible 中有两种模式, 分别是 ad-hoc 模式和 playbook 模式


### 3.ad-hoc 模式的命令使用

ansible 主机名 -m 模块名 -a '模块参数'

ansible-doc -l 查看模块  ansible-doc 模块名 查看模块具体用法

例
```bash
[vagrant@control ansible]$ ansible-doc -l |grep ping
win_ping                                                      A windows version of the classic ping module
postgresql_ping                                               Check remote PostgreSQL server availability
net_ping                                                      Tests reachability using ping from a network devi...  
ping                                                          Try to connect to host, verify a usable python an...  


[vagrant@control ansible]$ ansible-doc ping 
EXAMPLES:

# Test we can logon to 'webservers' and execute python with json lib.
# ansible webservers -m ping

# Example from an Ansible Playbook
- ping:

# Induce an exception to see what happens
- ping:
    data: crash


RETURN VALUES:

ping:
    description: value provided with the data parameter
    returned: success
    type: str
    sample: pong
/EXAMPLES
```
### 4. Ansible 执行返回

> 黄色：对远程节点进行相应修改
> 绿色：对远程节点不进行相应修改，或者只是对远程节点信息进行查看
> 红色：操作执行命令有异常
> 紫色：表示对命令执行发出警告信息（可能存在的问题，给你一下建议）


### ansible 命令参数

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
## 参考

- [ansible ssh prompt known_hosts issue](https://stackoverflow.com/questions/30226113/ansible-ssh-prompt-known-hosts-issue/39083724#39083724)
- [host-key-checking - ansible docs](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html#host-key-checking)

## FAQ
1. 如果各主机的 ssh 端口、密码等参数不一致，就需要在 `inventory` 中设定更详细的参数，详见 [Ansible Docs - intro_inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
2. 如果你使用的密钥不是默认的 ~/.ssh/id_rsa，则需要先通过 ssh-agent 手动设定私钥
```bash
ssh-agent bash
ssh-add <ssh-key-path>
# ssh-agent bash: 启动 SSH 代理并打开一个新的 shell 环境。SSH 代理是一个进程，它可以管理用户的 SSH 密钥并使得用户不需要重复地输入密码进行 SSH 认证。在使用 SSH 连接时，每次需要使用私钥进行认证操作，使用 SSH 代理可以减少重复输入密码的次数，并提高 SSH 连接的安全性。

# ssh-add <ssh-key-path>：将指定路径下的 SSH 密钥加载到 SSH 代理中。在使用 SSH 代理时，需要手动将 SSH 密钥添加到代理中，才能使用代理进行 SSH 认证操作。只要 SSH 代理存活（例如使用 ssh-agent bash 命令开启的代理），则添加的 SSH 密钥会一直保存在代理中，直到代理被关闭或密钥被手动删除。

# ansible [pattern] -m [module] -u [remote user] -a "[module options]"
# -u root     # 使用 root 账户登录远程主机，这个对应前面 playbook 中的 remote_user
# all         # [pattern]，all 表示选中 my-hosts 中的所有主机
# -m [module] # 指定使用的 ansible 模块，默认使用 `command`，即在远程主机上执行 -a 参数中的命令
# -a "ls -al"    # 指定 module 的参数，这里是提供给 `command` 模块的参数。
```
3. 批量扫描主机指纹

当我们的 inventory 变得很复杂了，`ssh-keyscan` 解析不了它了，该如何去批量扫描主机指纹呢？

答案是可以批量加，最简单有效的方法，是使用如下命令：

```shell
# 使用环境变量 ANSIBLE_HOST_KEY_CHECKING 临时关闭主机指纹检查
ANSIBLE_HOST_KEY_CHECKING=false ansible -i inventory.yaml all -m ping
```

经测试，不论登录成功与否，`ping` 模块都会自动将所有主机的指纹添加到 known_hosts 中。
但是在 ping 的文档里没有讲到这个功能，这算是未定义行为。

其他方法：

1. 网上有很多文档会教你修改 `/etc/ansible/ansible.cfg` 以关闭指纹的验证，但是**这是很危险的操作！你可能会连接到了黑客伪造的主机！**
2. 参考中有个问答，里面有人提供了一个 playbook 批量添加指纹，但是该方法**不支持「主机别名」**！
   - 该 playbook 会将别名当作 host 解析，根本不理会 `ansible_host` 参数。
   - 另外测试发现它用到了 ansbile 的 local 连接，而这种用法在 wsl1(ubuntu) 上无法使用，会报权限错误。。
3. 自己写个小脚本读取 `ansible-inventory -i xxx.yml --list` 输出的 json，将它转换成 `ssh-keyscan` 可读的文本。

可以使用Ansible的"ssh_host_key_fingerprint"模块来批量扫描主机指纹。该模块可以通过SSH连接到目标主机，并返回其公钥指纹。以下是一个示例Ansible playbook：

```yaml
- hosts: all
  gather_facts: no
  tasks:
    - name: Get SSH fingerprint
      ssh_host_key_fingerprint:
      register: ssh_fingerprint
    - debug:
        var: ssh_fingerprint.stdout_lines
```
在上面的示例中，“all”是要扫描指纹的主机列表。该playbook将获取所有目标主机的SSH指纹，并将其打印到屏幕上。请注意，需要在Ansible控制节点上安装sshpass和ssh-keyscan工具。

