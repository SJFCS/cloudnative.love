---
title: 快速开始
sidebar_position: 1
---
import CodeBlock from '@theme/CodeBlock';
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import vagrantfile from '!!raw-loader!../Ansible-Playground/vagrantfile';
import config from '!!raw-loader!../Ansible-Playground/config.yaml';
import Link from '@docusaurus/Link';

本节带你快速入门使用 Ansible，包括 Ansible 配置、Invenytory 与 Ad-Hoc 的使用方法。


:::info环境准备

在开始前，我们需要准备实验所用到的主机。
<details>
<summary>这里为您准备了 Vagrant 环境，可以一键启动如下环境</summary>

在**新建目录**中创建 `config.yaml` 和 `Vagrantfile` 文件后**在此目录中**执行 `vagrant up` 即可启动练习环境。vagrant 安装和使用详见：[Vagrant](/docs/Infrastructure%20as%20Code/Vagrant/)

启动后 `vagrant ssh <host_name>` 登录到对环境的各个节点进行初步检查：

输入 `hostname && hostname -d && hostname -f` 分别检查主机名、主机域和FQDN。

输入 `cat /etc/hosts` 检查 Hosts 配置是否正确。

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



:::


## ansible 命令参数

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


## hostname 免密，认证

Ansible 通过 SSH 协议免密登录远程主机
安装好 Ansible 后，第一件事当然是连接上远程主机。




contorl 进行如下操作

## 1. 批量扫描主机指纹

ansible 使用 ssh 协议登录远程主机进行操作，我想用过 `ssh user@host` 命令的都知道，首次登录远程主机时都会有如下提示：

```shell
ryan@RYAN-MI-DESKTOP:~$ ssh user@github.com
The authenticity of host 'github.com (13.250.177.223)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com,13.250.177.223' (RSA) to the list of known hosts.
```

这里会要求你输入 yes 将主机指纹保存到本地，是一种安全措施，防止在遇到 DNS 污染或 IP 冲突等异常情况时，目标主机被冒名顶替。

Ansible 默认情况下也会使用这个指纹对主机进行验证，因此我们希望能够快速地扫描出所有主机的指纹，而不是修改 ansible.cfg 使 `host_key_checking = False` 跳过检查主机指纹。这里使用 ssh-keyscan 命令：

```shell
echo "
192.168.56.100
192.168.56.10
192.168.56.20
192.168.56.30
" > my-hosts
ssh-keyscan -H -f my-hosts >> ~/.ssh/known_hosts
# 添加 -H 参数，只保存主机 IP/域名的 hash 值，更安全
```


## 2. 设置免密登录 


cloud-init/terraform/pulumi/ansible/vagrant

通常通过 ssh 密钥管理主机，而不用在 hosts 中写入密码，如果非要用密码可以使用 vault来做加密。

```bash
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q
sshpass -p pass  ssh-copy-id -i ~/.ssh/id_rsa.pub user@IP

# 或者手动在需要免密的节点上做以下配置
mkdir -p -m 700 ~/.ssh
echo "<your_public_key>" >> ~/.ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```

大量的远程主机都使用同一个密码提供 ssh 远程登录是很不安全的，一般都建议所有主机都只开启私钥登录，禁用密码登录。相关配置在主机的 `/etc/ssh/sshd_config` 中。

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

## 配置ansible

## Ansible 的配置文件

配置文件查找顺序如下：

1. `$ANSIBLE_CONFIG`变量
2. 当前目录下`ansible.cfg`
3. 用户家目录下`ansible.cfg`
4. `/etc/ansible/ansible.cfg`(默认)

通过`ansible --version`可以看到配置文件目录等信息

使用 `ansible-config init --disabled -t all >ansible.cfg` 可以创建初始配置。
`cat ansible.cfg|grep -Ev "#|^$"` 然后我们手动编辑我们所需要的参数。

```
# cat /etc/ansible/ansible.cfg
[defaultes]
#inventory			= /etc/ansible/hosts		#主机列表配置文件
#library			= /usr/share/my_modules/	#库文件存放目
#remote_tmp			= ~/.ansible/tmp			#临时py文件存放在远程主机目录
#local_tmp			= ~/.ansible/tmp			#本机的临时执行目录
#forks				= 5							#默认并发数
#sudo user			= root						#默认sudo用户
#ask_sudo_pass		= True						#每次执行是询问sudo的ssh密码
#ask_pass			= True						#每次执行是否询问ssh密码
#remote_port		= 22						# 远程主机端口
host_key_checking = False						#跳过检查主机指纹
log_path =/var/log/ansible.log					# ansible日志
```

## 4. inventory 主机清单

主机清单文件默认位置: /etc/ansible/hosts
文件作用：通常用于定义要管理哪些主机的认证信息，例如 ssh 登录用户名，密码信息等

使用更高级的 inventory 语法，以对主机进行分类，对不同类别的主机配置不同的参数。

```ini
# 给服务器分组，组名只能用 [a-zA-Z0-9_]
[servers01]
192.168.1.1
192.168.1.2:22
www.nginx_server.com:22
# 主机别名 （此方式执行命令后回显由别名代替IP）
alias_name  ansible_host=192.168.1.3
[databases]
# 指定一个数字范围
192.168.1.1[01:50]

[k8s_cluster]
# 指定一个字母表范围
worker[01:30].k8s.local
worker-[a:h].k8s.local

# k8s-cluster 组的公用参数
[k8s_cluster:vars]
ntp_server=ntp.svc.local
proxy=proxy.svc.local

[app]
# 给服务器指定别名（git），通过关键字参数指定其他参数
git ansible_host=git.svc.local ansible_port=225  ansible_ssh_private_key_file=<path/to/git-server-ssh>

# 使用指定的账号密码（危险！）
tester ansible_host=tester.svc.local ansible_user=root ansible_password=xxx
```

### 2. 主机变量

```bash
[servers01]
192.168.1.2 ansible_ssh_user='root' ansible_ssh_pass='redhat' ansible_ssh_port='22'
```

### 3. 主机组变量

```bash
[servers02]
192.168.3.1
[servers03:vars]
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
```

### 4. 子组分类变量：children

```bash
[nginx]
192.168.1.31
[apache]
192.168.1.32
[web_servers:children]
apache
nginx
[web_servers:vars]
ansible_ssh_user='root'
ansible_ssh_pass='redhat'
ansible_ssh_port='22'
```

另外也可以使用 yaml 格式配置 inventory 主机清单，上面的 ini 配置写成 yaml 格式是这样的：

可以使用以下命令将 Ansible 的 inventory 文件从 ini 格式转换到 yaml 格式：

```bash
$ ansible-inventory -i inventory.ini --yaml --output=inventory.yaml
-i 指定 inventory 文件路径
--yaml 指定输出格式为 yaml
--output 指定输出文件路径和文件名
类似地，也可以将 yaml 格式的 inventory 文件转换为 ini 格式：
$ ansible-inventory -i inventory.yaml --list --output=inventory.ini
-i 指定 inventory 文件路径
--list 指定输出格式为 json
--output 指定输出文件路径和文件名
```

需要注意的是，从 yaml 格式转换为 ini 格式时，需要使用 --list 选项将 yaml 文件转换为 json。因为 ini 文件不支持多层嵌套的结构，所以必须将其打平转换。而从 ini 格式转换为 yaml 格式时，由于 yaml 文件支持多层嵌套的结构，所以直接输出即可。

```shell
ansible-inventory -i xxx.yml --list --yaml
```

该命令会提示出你错误的配置，并且打印出最终得到的 yaml 配置内容。





## 3. 开始使用ansible

```bash

ansible -u root -i my-hosts all -a "ls -al"

# 或者使用 ansible-console 交互式执行命令，更适合愉快地游玩hhh
ansible-console -i my-hosts all -u root
```




## Ansible Ad-Hoc

### 1.什么是 ad-hoc 模式

> ad-hoc 简而言之，就是“临时命令”，不会保存
> ansible 中有两种模式, 分别是 ad-hoc 模式和 playbook 模式

### 2.ad-hoc 模式的使用场景

_场景一，在多台机器上，查看某个进程是否启动
场景二，在多台机器上，拷贝指定日志文件到本地，等等_

### 3.ad-hoc 模式的命令使用

ansible 主机名 -m 模块名 -a '模块参数'

### 4. Ansible 执行返回

> 黄色：对远程节点进行相应修改
> 绿色：对远程节点不进行相应修改，或者只是对远程节点信息进行查看
> 红色：操作执行命令有异常
> 紫色：表示对命令执行发出警告信息（可能存在的问题，给你一下建议）

## 参考

- [ansible ssh prompt known_hosts issue](https://stackoverflow.com/questions/30226113/ansible-ssh-prompt-known-hosts-issue/39083724#39083724)
- [host-key-checking - ansible docs](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html#host-key-checking)

## FAQ
1. 如果各主机的 ssh 端口、密码等参数不一致，就需要在 `my-hosts` 中设定更详细的参数，详见 [Ansible Docs - intro_inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
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

验证通过后，就可以通过 `ansible`/`ansible-playbook`/`ansible-console` 愉快地玩耍了么？很遗憾的是——不行。

我们在前面使用不带任何参数的文档作为 inventory 时，因为 `ssh-keyscan` 也能解析它，所以我们很方便地就完成了主机指纹的批量扫描。

但是现在我们的 inventory 变得很复杂了，`ssh-keyscan` 解析不了它了，该如何去批量扫描主机指纹呢？难道几十上百台服务器的指纹，我必须得手动一个个去添加？！

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

