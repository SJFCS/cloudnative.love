# Ansible初体验

[[toc]]

## 1. 实验环境

准备四台CentOS7虚拟机，一台做为Ansible的主机(master),也叫`管理节点`，三台做为Ansible的受控节点(node1, node2, node3)，也叫`受控节点`。

IP信息如下：

```sh
192.168.56.110 master
192.168.56.111 node1
192.168.56.112 node2
192.168.56.113 node3
```


## 2. 安装Ansible

Ansible主机需要安装在Red Hat, Debian, CentOS, macOS, any of the BSDs等系统上面，Windows系统不能作为Ansible主机。我们使用CentOS7系统，其他系统的安装可以参考[https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

在Ansible主机服务器上面进行以下操作。

在添加了*Extra Packages for Enterprise Linux (EPEL)*源后，进行ansible的查找：

```sh
[root@localhost ~]# yum search ansible
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.neusoft.edu.cn
========================================================= N/S matched: ansible ==========================================================
ansible-doc.noarch : Documentation for Ansible
ansible-inventory-grapher.noarch : Creates graphs representing ansible inventory
ansible-lint.noarch : Best practices checker for Ansible
ansible-openstack-modules.noarch : Unofficial Ansible modules for managing Openstack
ansible-review.noarch : Reviews Ansible playbooks, roles and inventory and suggests improvements
centos-release-ansible-27.noarch : Ansible 2.7 packages from the CentOS ConfigManagement SIG repository
centos-release-ansible-28.noarch : Ansible 2.8 packages from the CentOS ConfigManagement SIG repository
centos-release-ansible-29.noarch : Ansible 2.9 packages from the CentOS ConfigManagement SIG repository
centos-release-ansible26.noarch : Ansible 2.6 packages from the CentOS ConfigManagement SIG repository
python2-ansible-runner.noarch : A tool and python library to interface with Ansible
python2-ansible-tower-cli.noarch : A CLI tool for Ansible Tower
ansible.noarch : SSH-based configuration management, deployment, and task execution system
ansible-python3.noarch : SSH-based configuration management, deployment, and task execution system
kubernetes-ansible.noarch : Playbook and set of roles for seting up a Kubernetes cluster onto machines
loopabull.noarch : Event loop driven Ansible playbook execution engine
standard-test-roles.noarch : Standard Test Interface Ansible roles

  Name and summary matches only, use "search all" for everything.
[root@localhost ~]# yum info ansible
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.neusoft.edu.cn
Available Packages
Name        : ansible
Arch        : noarch
Version     : 2.9.9
Release     : 1.el7
Size        : 17 M
Repo        : epel/x86_64
Summary     : SSH-based configuration management, deployment, and task execution system
URL         : http://ansible.com
License     : GPLv3+
Description : Ansible is a radically simple model-driven configuration management,
            : multi-node deployment, and remote task execution system. Ansible works
            : over SSH and does not require any software or daemons to be installed
            : on remote nodes. Extension modules can be written in any language and
            : are transferred to managed machines automatically.

[root@localhost ~]# 
```


安装ansible:

```sh
[root@localhost ~]# yum install ansible -y
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.163.com
 * updates: mirrors.neusoft.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package ansible.noarch 0:2.9.9-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=========================================================================================================================================
 Package                         Arch                           Version                               Repository                    Size
=========================================================================================================================================
Installing:
 ansible                         noarch                         2.9.9-1.el7                           epel                          17 M

Transaction Summary
=========================================================================================================================================
Install  1 Package

Total download size: 17 M
Installed size: 105 M
Downloading packages:
ansible-2.9.9-1.el7.noarch.rpm                                                                                    |  17 MB  00:00:09     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : ansible-2.9.9-1.el7.noarch                                                                                            1/1 
  Verifying  : ansible-2.9.9-1.el7.noarch                                                                                            1/1 

Installed:
  ansible.noarch 0:2.9.9-1.el7                                                                                                           

Complete!
```


## 3. 查看ansible的版本

```sh
[root@localhost ~]# ansible --version
ansible 2.9.9
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Apr  2 2020, 13:16:51) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

## 4. 查看ansible的帮助信息

```sh
[root@localhost ~]# ansible --help
usage: ansible [-h] [--version] [-v] [-b] [--become-method BECOME_METHOD]
               [--become-user BECOME_USER] [-K] [-i INVENTORY] [--list-hosts]
               [-l SUBSET] [-P POLL_INTERVAL] [-B SECONDS] [-o] [-t TREE] [-k]
               [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER]
               [-c CONNECTION] [-T TIMEOUT]
               [--ssh-common-args SSH_COMMON_ARGS]
               [--sftp-extra-args SFTP_EXTRA_ARGS]
               [--scp-extra-args SCP_EXTRA_ARGS]
               [--ssh-extra-args SSH_EXTRA_ARGS] [-C] [--syntax-check] [-D]
               [-e EXTRA_VARS] [--vault-id VAULT_IDS]
               [--ask-vault-pass | --vault-password-file VAULT_PASSWORD_FILES]
               [-f FORKS] [-M MODULE_PATH] [--playbook-dir BASEDIR]
               [-a MODULE_ARGS] [-m MODULE_NAME]
               pattern

Define and run a single task 'playbook' against a set of hosts

positional arguments:
  pattern               host pattern

optional arguments:
  --ask-vault-pass      ask for vault password
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  --playbook-dir BASEDIR
                        Since this tool does not use playbooks, use this as a
                        substitute playbook directory.This sets the relative
                        path for many features including roles/ group_vars/
                        etc.
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
  --vault-id VAULT_IDS  the vault identity to use
  --vault-password-file VAULT_PASSWORD_FILES
                        vault password file
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit
  -B SECONDS, --background SECONDS
                        run asynchronously, failing after X seconds
                        (default=N/A)
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
  -M MODULE_PATH, --module-path MODULE_PATH
                        prepend colon-separated path(s) to module library (def
                        ault=~/.ansible/plugins/modules:/usr/share/ansible/plu
                        gins/modules)
  -P POLL_INTERVAL, --poll POLL_INTERVAL
                        set the poll interval if using -B (default=15)
  -a MODULE_ARGS, --args MODULE_ARGS
                        module arguments
  -e EXTRA_VARS, --extra-vars EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @
  -f FORKS, --forks FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory INVENTORY, --inventory-file INVENTORY
                        specify inventory host path or comma separated host
                        list. --inventory-file is deprecated
  -l SUBSET, --limit SUBSET
                        further limit selected hosts to an additional pattern
  -m MODULE_NAME, --module-name MODULE_NAME
                        module name to execute (default=command)
  -o, --one-line        condense output
  -t TREE, --tree TREE  log output to this directory
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)

Privilege Escalation Options:
  control how and which user you become as on target hosts

  --become-method BECOME_METHOD
                        privilege escalation method to use (default=sudo), use
                        `ansible-doc -t become -l` to list valid choices.
  --become-user BECOME_USER
                        run operations as this user (default=root)
  -K, --ask-become-pass
                        ask for privilege escalation password
  -b, --become          run operations with become (does not imply password
                        prompting)

Connection Options:
  control as whom and how to connect to hosts

  --private-key PRIVATE_KEY_FILE, --key-file PRIVATE_KEY_FILE
                        use this file to authenticate the connection
  --scp-extra-args SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
  --sftp-extra-args SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
  --ssh-common-args SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
  --ssh-extra-args SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
  -T TIMEOUT, --timeout TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
  -c CONNECTION, --connection CONNECTION
                        connection type to use (default=smart)
  -k, --ask-pass        ask for connection password
  -u REMOTE_USER, --user REMOTE_USER
                        connect as this user (default=None)

Some modules do not make sense in Ad-Hoc (include, meta, etc)
```


## 5. DNS 域名解析配置

查看默认的`/etc/hosts`配置信息：

```sh
[root@localhost ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```


为了简单起来，我们在Ansible主机上面配置一下`/etc/hosts`，增加以下IP配置：

```
192.168.56.110 master master.ansible.com
192.168.56.111 node1 node1.ansible.com
192.168.56.112 node2 node2.ansible.com
192.168.56.113 node3 node3.ansible.com
```

修改后内容如下：

```sh
[root@localhost ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.56.110 master master.ansible.com
192.168.56.111 node1 node1.ansible.com
192.168.56.112 node2 node2.ansible.com
192.168.56.113 node3 node3.ansible.com
```

查看是否能够正常Ping通过主机和节点：

```sh
[root@localhost ~]# ping master -c 3     
PING master (192.168.56.110) 56(84) bytes of data.
64 bytes from master (192.168.56.110): icmp_seq=1 ttl=64 time=0.030 ms
64 bytes from master (192.168.56.110): icmp_seq=2 ttl=64 time=0.072 ms
64 bytes from master (192.168.56.110): icmp_seq=3 ttl=64 time=0.047 ms

--- master ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.030/0.049/0.072/0.019 ms
[root@localhost ~]# ping master.ansible.com -c 3
PING master (192.168.56.110) 56(84) bytes of data.
64 bytes from master (192.168.56.110): icmp_seq=1 ttl=64 time=0.071 ms
64 bytes from master (192.168.56.110): icmp_seq=2 ttl=64 time=0.068 ms
64 bytes from master (192.168.56.110): icmp_seq=3 ttl=64 time=0.090 ms

--- master ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.068/0.076/0.090/0.012 ms
[root@localhost ~]# ping node1 -c 3                  
PING node1 (192.168.56.111) 56(84) bytes of data.
64 bytes from node1 (192.168.56.111): icmp_seq=1 ttl=64 time=0.524 ms
64 bytes from node1 (192.168.56.111): icmp_seq=2 ttl=64 time=0.394 ms
64 bytes from node1 (192.168.56.111): icmp_seq=3 ttl=64 time=0.681 ms

--- node1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.394/0.533/0.681/0.117 ms
[root@localhost ~]# ping node2 -c 3 
PING node2 (192.168.56.112) 56(84) bytes of data.
64 bytes from node2 (192.168.56.112): icmp_seq=1 ttl=64 time=0.900 ms
64 bytes from node2 (192.168.56.112): icmp_seq=2 ttl=64 time=0.484 ms
64 bytes from node2 (192.168.56.112): icmp_seq=3 ttl=64 time=0.581 ms

--- node2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.484/0.655/0.900/0.177 ms
```

## 6. 服务器hostname主机名配置

为了便于后面在命令行工作时能够有效的区分是Ansible管理节点（master)还是受控节点(node1,node2,node3)之类的，我们将4台服务器的hostname修改一下。

IP和主机名对应关系如下：

| IP地址         | hostname           |
| -------------- | ------------------ |
| 192.168.56.110 | master.ansible.com |
| 192.168.56.111 | node1.ansible.com  |
| 192.168.56.112 | node2.ansible.com  |
| 192.168.56.113 | node3.ansible.com  |


   以Ansible主机修改为例，展示修改过程：

```sh
# 查看当前服务器的IP地址
[root@localhost ~]# IP
192.168.56.110

# 查看hostnamectl命令行工具的帮助信息，可以看到set-hostname可以用来设置主机名称
[root@localhost ~]# hostnamectl --help
hostnamectl [OPTIONS...] COMMAND ...

Query or change system hostname.

  -h --help              Show this help
     --version           Show package version
     --no-ask-password   Do not prompt for password
  -H --host=[USER@]HOST  Operate on remote host
  -M --machine=CONTAINER Operate on local container
     --transient         Only set transient hostname
     --static            Only set static hostname
     --pretty            Only set pretty hostname

Commands:
  status                 Show current hostname settings
  set-hostname NAME      Set system hostname
  set-icon-name NAME     Set icon name for host
  set-chassis NAME       Set chassis type for host
  set-deployment NAME    Set deployment environment for host
  set-location NAME      Set location for host

# 查看当前主机名
[root@localhost ~]# hostname
localhost.localdomain

# 查看主机名配置文件内容
[root@localhost ~]# cat /etc/hostname
localhost.localdomain

# 设置新的主机名，注意在其他节点上时，将master.ansible.com改成node1.ansible.com、node2.ansible.com或node3.ansible.com
[root@localhost ~]# hostnamectl set-hostname master.ansible.com

# 再次查看主机名称，发现已经更新
[root@localhost ~]# hostname
master.ansible.com

# 再次查看主机名配置文件内容，发现也已经更新
[root@localhost ~]# cat /etc/hostname
master.ansible.com

# 重启服务器
[root@localhost ~]# shutdown -r now
```

使用SSH连接工具重新连接master主机，可以发现命令行处显示已经发生了变化：

```sh
Last login: Thu Jul 16 08:41:39 2020 from 192.168.56.1
[root@master ~]# 
[root@master ~]# hostname
master.ansible.com
[root@master ~]# IP
192.168.56.110
[root@master ~]# cat /etc/hostname
master.ansible.com
[root@master ~]# 
```

其他节点也做相应的修改。

查看node1节点信息：

```sh
Last login: Thu Jul 16 08:41:40 2020 from 192.168.56.1
[root@node1 ~]# IP
192.168.56.111
[root@node1 ~]# hostname
node1.ansible.com
[root@node1 ~]# cat /etc/hostname
node1.ansible.com
[root@node1 ~]#
```

查看node2节点信息：

```sh
Last login: Thu Jul 16 08:41:40 2020 from 192.168.56.1
[root@node2 ~]# IP
192.168.56.112
[root@node2 ~]# hostname
node2.ansible.com
[root@node2 ~]# cat /etc/hostname
node2.ansible.com
[root@node2 ~]# 
```

查看node3节点信息：

```sh
Last login: Thu Jul 16 08:41:42 2020 from 192.168.56.1
[root@node3 ~]# IP
192.168.56.113
[root@node3 ~]# hostname
node3.ansible.com
[root@node3 ~]# cat /etc/hostname
node3.ansible.com
[root@node3 ~]# 
```

后续通过命令行的`@master`、`@node1`、`@node2`、`@node3`就可以判断是在哪个服务器上面工作呢！



## 7. 管理用户配置

为了增加安全性，我们不使用默认的`root`账号，在每个系统上面创建`ansible`账号，并配置`NOPASSWD`的`sudo`权限。也可以忽略本节，直接用`root`账号操作。

注意，本节需要在master主机以及三台node节点虚拟机上面执行以下命令。

创建`ansible`账号：

```sh
[root@master ~]# useradd ansible
[root@master ~]# id ansible
uid=1001(ansible) gid=1001(ansible) groups=1001(ansible)
[root@master ~]# ls -lah /home/ansible/
total 12K
drwx------  2 ansible ansible  62 Jun 15 11:26 .
drwxr-xr-x. 4 root    root     39 Jun 15 11:26 ..
-rw-r--r--  1 ansible ansible  18 Oct 31  2018 .bash_logout
-rw-r--r--  1 ansible ansible 193 Oct 31  2018 .bash_profile
-rw-r--r--  1 ansible ansible 231 Oct 31  2018 .bashrc
```

使用`passwd`密码给ansible账号设置密码：

```sh
[root@master ~]# echo "securepasswd"|passwd ansible --stdin
Changing password for user ansible.
passwd: all authentication tokens updated successfully.
```

此处因为是使用的虚拟机环境，设置了`ansible`账号的密码为`securepasswd`，你在生产环境下，可以直接使用`passwd ansible`命令手动输入`ansible`账号的密码。

配置`sudo`权限：

```sh
[root@master ~]# ls -lah /etc/sudoers
-r--r-----. 1 root root 4.3K Oct 30  2018 /etc/sudoers
[root@master ~]# chmod u+w -v /etc/sudoers
mode of ‘/etc/sudoers’ changed from 0440 (r--r-----) to 0640 (rw-r-----)
[root@master ~]# echo "ansible ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
[root@master ~]# chmod u-w -v /etc/sudoers
mode of ‘/etc/sudoers’ changed from 0640 (rw-r-----) to 0440 (r--r-----)
```

测试`sudo`权限：

```sh
[root@master ~]# su ansible
[ansible@master root]$ cd
[ansible@master ~]$ tail /etc/sudoers
tail: cannot open ‘/etc/sudoers’ for reading: Permission denied
[ansible@master ~]$ sudo tail /etc/sudoers
## Allows members of the users group to mount and unmount the 
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now

## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
ansible ALL=(ALL)       NOPASSWD: ALL
[ansible@master ~]$ 
```

以上说明四台服务器的管理账号ansible创建成功，并且`sudo`权限配置正常。



## 8. 公钥密钥配置

首先在Ansible主机上面生成公钥和密钥，注意，我们不直接在root账号上面工作，而是以ansible账号工作的：

```sh
[ansible@master ~]$ ssh-keygen -C ansible-master@192.168.56.110
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa): 
Created directory '/home/ansible/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:A6PStWQjRdIWHwkl0E2KxS2RfPgiXzVQf19hCQWJvTU ansible-master@192.168.56.110
The key's randomart image is:
+---[RSA 2048]----+
|    oBO@=+. oo=+.|
|     =X+=.oo o.E.|
|    o.O+.. .. + o|
|   ..*.=o    o ..|
|  . oo.oS       .|
|   .  .  .       |
|                 |
|                 |
|                 |
+----[SHA256]-----+
[ansible@master ~]$ 
[ansible@master ~]$ ls -lah ~/.ssh/
total 8.0K
drwx------ 2 ansible ansible   57 Jun 15 11:47 .
drwx------ 3 ansible ansible   74 Jun 15 11:45 ..
-rw------- 1 ansible ansible 1.7K Jun 15 11:45 id_rsa
-rw-r--r-- 1 ansible ansible  411 Jun 15 11:45 id_rsa.pub
```

在node1节点上面创建公钥和密钥：

```sh
[ansible@node1 ~]$ ssh-keygen -C ansible-node1@192.168.56.111 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa): 
Created directory '/home/ansible/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:6vpnuPHuVEcYpX33ZjFdN3pDEtEkO/ugOBRaq9bcUjk ansible-node1@192.168.56.111
The key's randomart image is:
+---[RSA 2048]----+
|          ...==+o|
|           =  *.=|
|         oo o+.=o|
|        o o...+.=|
|       .So.E.o  +|
|       .=.+.o oo |
|      o+.* o   . |
|     .o+o o      |
|    .o+*+        |
+----[SHA256]-----+
[ansible@node1 ~]$ 
[ansible@node1 ~]$ ls -lah ~/.ssh/
total 8.0K
drwx------ 2 ansible ansible   38 Jun 15 11:49 .
drwx------ 3 ansible ansible   74 Jun 15 11:49 ..
-rw------- 1 ansible ansible 1.7K Jun 15 11:49 id_rsa
-rw-r--r-- 1 ansible ansible  410 Jun 15 11:49 id_rsa.pub
```

在node2节点上面创建公钥和密钥：

```sh
[ansible@node2 ~]$ ssh-keygen -C ansible-node2@192.168.56.112
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa): 
Created directory '/home/ansible/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:4V2xrqotHV1RwrvhjdQYvh04RZrxEtM076q5RFPPgj8 ansible-node2@192.168.56.112
The key's randomart image is:
+---[RSA 2048]----+
|           .*==  |
|            +@oo |
|        .  .*Oo .|
|       . o oX+o+ |
|        S..+=O..+|
|        . .o=ooo |
|       . .. . E  |
|      .... . o . |
|      .oo   +.   |
+----[SHA256]-----+
[ansible@node2 ~]$ 
[ansible@node2 ~]$ ls -lah ~/.ssh/
total 8.0K
drwx------ 2 ansible ansible   38 Jun 15 11:51 .
drwx------ 3 ansible ansible   74 Jun 15 11:51 ..
-rw------- 1 ansible ansible 1.7K Jun 15 11:51 id_rsa
-rw-r--r-- 1 ansible ansible  410 Jun 15 11:51 id_rsa.pub
```


将master节点的公钥复制到节点1中，在master服务器上执行以下命令：

```sh
[ansible@master ~]$ ssh-copy-id ansible@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
The authenticity of host 'node1 (192.168.56.111)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@node1's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@node1'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ ssh 'ansible@node1' 
Last login: Mon Jun 15 11:58:26 2020
[ansible@node1 ~]$ whoami
ansible
[ansible@node1 ~]$ ip a show|grep 192
    inet 192.168.56.111/24 brd 192.168.56.255 scope global noprefixroute enp0s3
[ansible@node1 ~]$ 
[ansible@node1 ~]$ exit
logout
Connection to node1 closed.
[ansible@master ~]$ 
```

将master节点的公钥复制到节点2中，在master服务器上执行以下命令：
```sh
[ansible@master ~]$ ssh-copy-id ansible@node2
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansible/.ssh/id_rsa.pub"
The authenticity of host 'node2 (192.168.56.112)' can't be established.
ECDSA key fingerprint is SHA256:15SIRcXjSKfsisn8zTuuU2uxcDSYLv4W6gOmq1lhq60.
ECDSA key fingerprint is MD5:b2:b7:63:2b:c1:b7:f2:16:18:2a:b1:dd:ee:d8:5b:5f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@node2's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@node2'"
and check to make sure that only the key(s) you wanted were added.

[ansible@master ~]$ ssh 'ansible@node2'
Last failed login: Mon Jun 15 12:02:22 CST 2020 from 192.168.56.110 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Mon Jun 15 11:58:26 2020
[ansible@node2 ~]$ whoami
ansible
[ansible@node2 ~]$ ip a show|grep 192
    inet 192.168.56.112/24 brd 192.168.56.255 scope global noprefixroute enp0s3
[ansible@node2 ~]$ 
[ansible@node2 ~]$ exit
logout
Connection to node2 closed.
[ansible@master ~]$ 
```

同样的方式在node3上面创建公钥和密钥，并将主机的公钥复制到node3上面去。

## 9. `Host inventory`主机列表配置

查看默认的`/etc/ansible/hosts`配置文件内容:

```sh
[ansible@master ~]$ cat /etc/ansible/hosts
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers.

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group

## [dbservers]
## 
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com

[ansible@master ~]$ 
```

我们增加以下内容：

```
[webservers]
node1


[dbservers]
node2
```

方括号[]中是组名，用于对系统进行分类，便于对不同系统进行个别的管理。

再次查看`/etc/ansible/hosts`配置文件内容:

```sh
[ansible@master ~]$ cat /etc/ansible/hosts     
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers.

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group

## [dbservers]
## 
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.ervers]
[webservers]
node1


[dbservers]
node2
```


## 10. 列出可用的服务器列表

```sh
# 列出所有的服务器列表
[ansible@master ~]$ ansible all --list-hosts
  hosts (2):
    node1
    node2
# 列出webservers组的服务器列表
[ansible@master ~]$ ansible webservers --list-hosts
  hosts (1):
    node1
# 列出dbservers组的服务器列表
[ansible@master ~]$ ansible dbservers --list-hosts   
  hosts (1):
    node2
[ansible@master ~]$ 
```

## 11. 使用Ad-hoc command执行的单个ansible任务


### 11.1 测试客户机连接性

使用ping模块检查与客户机的连接性：

```sh
[ansible@master ~]$ ansible all -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```


单独检查某一个客户机的连接性：

```sh
[ansible@master ~]$ ansible node1 -m ping 
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible node2 -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```


### 11.2 执行sudo权限提升权限

查看`/etc/sudoers`文件：

```sh
# 直接查看提示没有权限
[ansible@master ~]$ ansible all -a "tail /etc/sudoers"
node1 | FAILED | rc=1 >>
tail: cannot open ‘/etc/sudoers’ for reading: Permission deniednon-zero return code
node2 | FAILED | rc=1 >>
tail: cannot open ‘/etc/sudoers’ for reading: Permission deniednon-zero return code
[ansible@master ~]$  

# 使用sudo方式查看，提示推荐使用become等命令
[ansible@master ~]$ ansible all -a "sudo tail /etc/sudoers"
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
node1 | CHANGED | rc=0 >>
## Allows members of the users group to mount and unmount the 
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now

## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
ansible ALL=(ALL)       NOPASSWD: ALL
node2 | CHANGED | rc=0 >>
## Allows members of the users group to mount and unmount the 
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now

## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
ansible ALL=(ALL)       NOPASSWD: ALL
[ansible@master ~]$ 

# 使用--become参数执行sudo操作
[ansible@master ~]$ ansible all --become -a "tail /etc/sudoers"
node2 | CHANGED | rc=0 >>
## Allows members of the users group to mount and unmount the 
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now

## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
ansible ALL=(ALL)       NOPASSWD: ALL
node1 | CHANGED | rc=0 >>
## Allows members of the users group to mount and unmount the 
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now

## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
ansible ALL=(ALL)       NOPASSWD: ALL
[ansible@master ~]$ 
```

### 11.3 文件传输

将文件传输到节点中：

```sh
[ansible@master ~]$ ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts", 
    "gid": 1001, 
    "group": "ansible", 
    "md5sum": "a05d8ffb18a6aa2f0b81d314fb078325", 
    "mode": "0664", 
    "owner": "ansible", 
    "size": 277, 
    "src": "/home/ansible/.ansible/tmp/ansible-tmp-1592203324.2-14711-145855187476664/source", 
    "state": "file", 
    "uid": 1001
}
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts", 
    "gid": 1001, 
    "group": "ansible", 
    "md5sum": "a05d8ffb18a6aa2f0b81d314fb078325", 
    "mode": "0664", 
    "owner": "ansible", 
    "size": 277, 
    "src": "/home/ansible/.ansible/tmp/ansible-tmp-1592203324.2-14710-111916154230539/source", 
    "state": "file", 
    "uid": 1001
}
```

查看文件在节点上面的文件的权限：

```sh
[ansible@master ~]$ ansible all -a "ls -lah /tmp/hosts"
node2 | CHANGED | rc=0 >>
-rw-rw-r-- 1 ansible ansible 277 Jun 15 14:42 /tmp/hosts
node1 | CHANGED | rc=0 >>
-rw-rw-r-- 1 ansible ansible 277 Jun 15 14:42 /tmp/hosts
```


我们尝试使用权限提升再次复制：

```sh
[ansible@master ~]$ ansible all --become -m copy -a "src=/etc/hosts dest=/tmp/hosts"
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts", 
    "gid": 1001, 
    "group": "ansible", 
    "mode": "0664", 
    "owner": "ansible", 
    "path": "/tmp/hosts", 
    "size": 277, 
    "state": "file", 
    "uid": 1001
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts", 
    "gid": 1001, 
    "group": "ansible", 
    "mode": "0664", 
    "owner": "ansible", 
    "path": "/tmp/hosts", 
    "size": 277, 
    "state": "file", 
    "uid": 1001
}
[ansible@master ~]$ ansible all -a "ls -lah /tmp/hosts"                             
node1 | CHANGED | rc=0 >>
-rw-rw-r-- 1 ansible ansible 277 Jun 15 14:42 /tmp/hosts
node2 | CHANGED | rc=0 >>
-rw-rw-r-- 1 ansible ansible 277 Jun 15 14:42 /tmp/hosts
```

可以看到此时`/tmp/hosts`文件的权限并没有更新。

重新复制文件到节点上，并命名为`/tmp/hosts1`:

```sh
[ansible@master ~]$ ansible all --become -m copy -a "src=/etc/hosts dest=/tmp/hosts1"
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts1", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "a05d8ffb18a6aa2f0b81d314fb078325", 
    "mode": "0644", 
    "owner": "root", 
    "size": 277, 
    "src": "/home/ansible/.ansible/tmp/ansible-tmp-1592203757.6-15232-150694583174609/source", 
    "state": "file", 
    "uid": 0
}
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "2c0a68d083a1d325238a5364cb3dc4861e122155", 
    "dest": "/tmp/hosts1", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "a05d8ffb18a6aa2f0b81d314fb078325", 
    "mode": "0644", 
    "owner": "root", 
    "size": 277, 
    "src": "/home/ansible/.ansible/tmp/ansible-tmp-1592203757.59-15231-38278230127046/source", 
    "state": "file", 
    "uid": 0
}
[ansible@master ~]$ ansible all -a "ls -lah /tmp/hosts1"                             
node2 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 277 Jun 15 14:49 /tmp/hosts1
node1 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 277 Jun 15 14:49 /tmp/hosts1
```

此时可以看到文件的权限已经是`root:root`了。

删除文件或目录：

```sh
[ansible@master ~]$ ansible all -m file -a "dest=/tmp/hosts state=absent"  
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/hosts", 
    "state": "absent"
}
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/hosts", 
    "state": "absent"
}
[ansible@master ~]$ ansible all -m file -a "dest=/tmp/hosts1 state=absent"
node2 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "msg": "unlinking failed: [Errno 1] Operation not permitted: '/tmp/hosts1' ", 
    "owner": "root", 
    "path": "/tmp/hosts1", 
    "size": 277, 
    "state": "file", 
    "uid": 0
}
node1 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "msg": "unlinking failed: [Errno 1] Operation not permitted: '/tmp/hosts1' ", 
    "owner": "root", 
    "path": "/tmp/hosts1", 
    "size": 277, 
    "state": "file", 
    "uid": 0
}
[ansible@master ~]$ ansible all --become -m file -a "dest=/tmp/hosts1 state=absent"
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/hosts1", 
    "state": "absent"
}
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/hosts1", 
    "state": "absent"
}
[ansible@master ~]$ 
```

### 11.4 查看开机时间

可以使用ansible查看各节点的开机时间：

```sh
[ansible@master ~]$ ansible all -a 'uptime'
node1 | CHANGED | rc=0 >>
 15:08:44 up 11 min,  2 users,  load average: 0.00, 0.03, 0.05
node2 | CHANGED | rc=0 >>
 15:08:44 up 11 min,  2 users,  load average: 0.00, 0.01, 0.03
```

以上我们对Ansible有了一些基本认识。下面我们开始来翻翻Ansible的官方文档[https://docs.ansible.com/ansible/latest/user_guide/index.html](https://docs.ansible.com/ansible/latest/user_guide/index.html)，从基础学起。

## 12. Ansible基础概念

### 12.1 Control node管理节点

任何装有Ansible的机器都可以被称为管理节点。您可以从任何管理节点运行命令和剧本，并调用`/usr/bin/ansible`或`/usr/bin/ansible-playbook`。您可以将任何安装了Python的计算机用作管理节点-笔记本电脑，共享台式机和服务器都可以运行Ansible。但是，不能将Windows计算机用作管理节点。您可以有多个管理节点。

### 12.2 Managed nodes受控节点

您使用Ansible管理的网络设备（和/或服务器）被称为受控节点。受管节点有时也称为“主机”。不需要在受控节点上安装Ansible。

### 12.3 Inventory库存/主机清单

受控节点的列表。清单文件有时也称为“主机文件”。您的清单可以为每个受控节点指定信息，例如IP地址。库存还可以组织受管节点，创建和嵌套组以便于扩展。要了解有关库存的更多信息，请参见使用库存部分。

### 12.4 Modules模块

Ansible的执行单元称为模块。从管理特定类型的数据库上的用户到管理特定类型的网络设备上的VLAN接口，每个模块都有特定的用途。您可以通过任务调用单个模块，也可以在剧本中调用多个不同的模块。要了解Ansible包含多少个模块，请查看所有模块的列表。

### 12.5 Tasks任务

Ansible中的动作单元。您可以使用临时命令(ad-hoc command)一次执行一个任务。

### 12.6 Playbooks剧本

已保存任务的有序列表，因此您可以按此顺序重复运行这些任务。剧本可以包括变量以及任务。剧本采用YAML编写，易于阅读，编写，共享和理解。要了解有关剧本的更多信息，请参阅关于剧本。类似于Linux操作系统中的Shell脚本，可以执行一系列的命令或任务。

## 13. Ansible工作原理

Ansible基本命令或者Playbook剧本会按以下顺序执行：

- 从库存(也就是主机清单)中选择需要执行任务的主机/机器。
- 通常通过SSH连接到这些主机(或网络设备或其他受控节点)。
- 将一个或多个模块复制到远程主机并在那里开始执行。

Ansible可以做更多的事情，但是在探究Ansible的所有强大配置、部署和编排功能之前，您应该了解最常见的用例。该页面通过一个简单的清单和一个临时命令说明了基本过程。了解Ansible的工作原理后，您可以阅读有关临时命令的更多详细信息，使用清单组织基础结构，并利用Playbook充分利用Ansible的功能。

### 13.1 主机清单配置

你可以通过在命令行指定IP地址来传递给临时命令，也可以通过配置主机清单来传递给Ansible。Ansible从主机清单中读取有关要管理哪些计算机的信息。 这样可以充分利用Ansible的全部灵活性和可重复性。

主机清单配置文件为`/etc/ansible/hosts`，默认Ansible在这个配置文件中添加了一些备注信息，你可参参考该文件编写自己的主机清单。

可以使用IP地址或者FQDN域名，如：

```sh
192.0.2.50
aserver.example.org
bserver.example.org
```

除了IP地址或者FQDN域名，你还可以在主机清单中使用`aliases`别名，主机变量`host vars`，或者`group vars`组变量。可参考[https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-aliases](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-aliases)

### 13.2 主机清单插件配置

Ansible支持很多主机清单插件(Inventory Plugins)，默认情况下，在`/etc/ansible/ansible.cfg`配置文件中开启了以下几个插件：

```yml
[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml
```

```sh
[root@master ~]# nl -ba /etc/ansible/ansible.cfg|sed -n '327,330p'
   327  [inventory]
   328  # enable inventory plugins, default: 'host_list', 'script', 'auto', 'yaml', 'ini', 'toml'
   329  #enable_plugins = host_list, virtualbox, yaml, constructed
   330
```

`auto`插件会自动确认配置文件需要使用哪个插件。你可以通过修改`enable_plugins`的配置值来开启相应的插件。

插件的使用，可以参考：[https://docs.ansible.com/ansible/latest/plugins/inventory.html#inventory-plugins](https://docs.ansible.com/ansible/latest/plugins/inventory.html#inventory-plugins)

### 13.3 主机清单插件列表

可以通过`ansible-doc -t inventory -l`命令查看所有可用的主机清单插件列表，通过`ansible-doc -t inventory <plugin name>`可以查看某个具体的插件的帮助文档和示例。

查看插件列表：

```sh
[root@master ~]# ansible-doc -t inventory -l
nmap                Uses nmap to find hosts to target
host_list           Parses a 'host list' string
hcloud              Ansible dynamic inventory plugin for the Hetzner Cloud
openstack           OpenStack inventory source
vultr               Vultr inventory source
aws_ec2             EC2 inventory source
cloudscale          cloudscale.ch inventory source
virtualbox          virtualbox inventory source
constructed         Uses Jinja2 to construct vars and groups based on existing inventory
k8s                 Kubernetes (K8s) inventory source
generator           Uses Jinja2 to construct hosts and groups from patterns
script              Executes an inventory script that returns JSON
vmware_vm_inventory VMware Guest inventory source
linode              Ansible dynamic inventory plugin for Linode
docker_machine      Docker Machine inventory source
yaml                Uses a specific YAML file as an inventory source
online              Online inventory source
azure_rm            Azure Resource Manager inventory plugin
docker_swarm        Ansible dynamic inventory plugin for Docker swarm nodes
advanced_host_list  Parses a 'host list' with ranges
foreman             foreman inventory source
auto                Loads and executes an inventory plugin specified in a YAML config
kubevirt            KubeVirt inventory source
gitlab_runners      Ansible dynamic inventory plugin for GitLab runners
netbox              NetBox inventory source
gcp_compute         Google Cloud Compute Engine inventory source
aws_rds             rds instance source
openshift           OpenShift inventory source
toml                Uses a specific TOML file as an inventory source
tower               Ansible dynamic inventory plugin for Ansible Tower
scaleway            Scaleway inventory source
ini                 Uses an Ansible INI file as inventory source
```

查看某个插件的帮助信息：

```sh
[root@master ~]# ansible-doc -t inventory host_list
> HOST_LIST    (/usr/lib/python2.7/site-packages/ansible/plugins/inventory/host_list.py)

        Parses a host list string as a comma separated values of hosts This plugin only applies to inventory
        strings that are not paths and contain a comma.

  * This module is maintained by The Ansible Community
        METADATA:
          status:
          - preview
          supported_by: community
        

EXAMPLES:

# define 2 hosts in command line
    # ansible -i '10.10.2.6, 10.10.2.4' -m ping all

    # DNS resolvable names
    # ansible -i 'host1.example.com, host2' -m user -a 'name=me state=absent' all

    # just use localhost
    # ansible-playbook -i 'localhost,' play.yml -c local


[root@master ~]# 
```

你也可以通过[https://docs.ansible.com/ansible/latest/plugins/inventory.html#plugin-list](https://docs.ansible.com/ansible/latest/plugins/inventory.html#plugin-list)查看主机清单插件列表的帮助文档。

### 13.4 主机清单基础: 格式, 主机与组



主机清单可以使用多种格式进行编写，当你使用的插件不同时，主机清单配置文件格式也不一样。最常用的是使用`ini`功`yaml`格式的主机清单。

`ini`格式的主机清单`/etc/ansible/hosts`配置示例：

```ini
mail.example.com

[webservers]
foo.example.com
bar.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```

通过`[]`进行主机的分组。如上面分了两个组`webservers`和`dbservers`。

`yaml`格式的主机清单`/etc/ansible/hosts`配置示例：

```yaml
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
```

#### 13.4.1 默认组

默认情况下，有两个组`all`和`ungrouped`,`all`组包含主机清单中所有的主机，`ungrouped`组是主机清单中所有主机减去用户自定义的组的主机剩下来的的主机组成的组。

为了说明默认组的使用情况，我们在主机清单中增加node3的配置。并且将不需要的注释信息全部删除掉。仅剩下有用的主机清单配置信息。配置完成后，主机清单如下：

```sh
[ansible@master ~]$ cat /etc/ansible/hosts
node3
[webservers]
node1


[dbservers]
node2
[ansible@master ~]$
```

尝试使用ping模块检查与客户机的连接性:
```sh
[ansible@master ~]$ ansible all -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

# webservers组连接性检查
[ansible@master ~]$ ansible webservers -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

# dbservers组连接性检查
[ansible@master ~]$ ansible dbservers -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

# 可以看到ungrouped组指定的是节点node3
[ansible@master ~]$ ansible ungrouped -m ping
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ 
```

我们来使用`yaml`格式重写编写主机清单，看看效果怎么样，为了看到差异，我们将节点顺序换一下。

```yaml
[ansible@master ~]$ cat /etc/ansible/hosts
all:
  hosts:
    node1:
  children:
    webservers:
      hosts:
        node2:
    dbservers:
      hosts:
        node3:
```

进行连接性测试：

```sh
[ansible@master ~]$ ansible all -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible webservers -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible dbservers -m ping
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

# 可以看到ungrouped组指定的是节点变成了node1
[ansible@master ~]$ ansible ungrouped -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ 
```

可以看到使用`yaml`格式的主机清单也是有效的。

#### 13.4.2 主机分配

你可以将一个主机分配到不同的组中，即一个主机可以在组1中，也可以同时分配到组2或组3中，你可以随意分配。

你可以按功能(what)、区域(Where)、时间(When)不同的维度来组织主机的组分配情况。

示例：

```yaml
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
    east:
      hosts:
        foo.example.com:
        one.example.com:
        two.example.com:
    west:
      hosts:
        bar.example.com:
        three.example.com:
    prod:
      hosts:
        foo.example.com:
        one.example.com:
        two.example.com:
    test:
      hosts:
        bar.example.com:
        three.example.com:
```

上面的示例中，可以看到主机`one.example.com`同时存在于`dbservers`, `east`和 `prod` 组中。

我们将`node1`同时放到`webservers`和`dbservers`组中：

```yaml
[ansible@master ~]$ cat /etc/ansible/hosts
all:
  hosts:
  children:
    webservers:
      hosts:
        node1:
        node2:
    dbservers:
      hosts:
        node1:
        node3:
```

再进行连接性检查：

```sh
[ansible@master ~]$ ansible webservers -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible dbservers -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible ungrouped -m ping
[WARNING]: No hosts matched, nothing to do
[ansible@master ~]$ 
```

可以看到此时，`ungrouped`组中没有主机，`node1`同时在`webservers`和`dbservers`组中。



另外，你也可以组进行嵌套配置，看下面的官方示例：

```yaml
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
    east:
      hosts:
        foo.example.com:
        one.example.com:
        two.example.com:
    west:
      hosts:
        bar.example.com:
        three.example.com:
    prod:
      children:
        east:
    test:
      children:
        west:
```

可以看到`prod`组中包含子组`east`，`test`组中包含子组`west`。

我们再来测试组的嵌套：

```yaml
[ansible@master ~]$ cat /etc/ansible/hosts
all:
  hosts:
  children:
    webservers:
      hosts:
        node1:
        node2:
    dbservers:
      hosts:
        node3:
      children:
        webservers:
```

接着进行测试：

```sh
[ansible@master ~]$ ansible webservers -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible dbservers -m ping
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$

# 列出组主机信息
[ansible@master ~]$ ansible all --list-hosts
  hosts (3):
    node1
    node2
    node3
[ansible@master ~]$ ansible webservers --list-hosts
  hosts (2):
    node1
    node2
[ansible@master ~]$ ansible dbservers --list-hosts
  hosts (3):
    node3
    node1
    node2
```

#### 13.4.3 主机范围

在配置主机清单时，当我们主机数量比较多的时候，我们也可以使用一个范围来表示主机，这样可以不必列出所有的主机。

官方示例：

`ini`形式的主机范围示例：

```ini
[webservers]
www[01:50].example.com
```

`yaml`形式的主机范围示例：

```yaml
...
  webservers:
    hosts:
      www[01:50].example.com:
```

说明：

- 使用主机范围时，范围的初始值和结束值都包含在主机清单中。
- 对于数字模式的范围，前导0可以根据需要添加或删除。
- 也可以定义字符形式的范围，如`db-[a:f].example.com`。

我们使用`ini`格式配置主机清单：

```ini
[ansible@master ~]$ cat /etc/ansible/hosts
[webservers]
node[1:2]


[dbservers]
node3
```

刚从`yaml`格式切换到`ini`格式时，Ansible可能会报错：

```sh
[ansible@master ~]$ ansible dbservers --list-hosts
[WARNING]:  * Failed to parse /etc/ansible/hosts with yaml plugin: YAML inventory has
invalid structure, it should be a dictionary, got: <class
'ansible.parsing.yaml.objects.AnsibleUnicode'>
[WARNING]:  * Failed to parse /etc/ansible/hosts with ini plugin: host range must be
begin:end or begin:end:step
[WARNING]: Unable to parse /etc/ansible/hosts as an inventory source
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: Could not match supplied host pattern, ignoring: dbservers
[WARNING]: No hosts matched, nothing to do
```

检查主机组情况：

```sh
[ansible@master ~]$ ansible webservers --list-hosts
  hosts (2):
    node1
    node2
[ansible@master ~]$ ansible dbservers --list-hosts
  hosts (1):
    node3
[ansible@master ~]$ 
```

测试连接性：

```sh
[ansible@master ~]$ ansible webservers -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible dbservers -m ping
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$
```

可以看到连接性正常。

### 13.5 主机清单变量的使用

在主机清单中可以为组或主机添加变量(variable)，刚开始的时候，你可能会直接在`/etc/ansible/hosts`中配置，随着主机的数量越来越多，你可能想将主机或组进行分开存储，并在分开存储的主机清单文件中添加变量。



### 13.6 主机变量

你可以给一个单独的主机分配变量，后续可以在`playbooks`剧本中使用。

`ini`形式示例：

```ini
[atlanta]
host1 http_port=80 maxRequestsPerChild=808
host2 http_port=303 maxRequestsPerChild=909
```

`yaml`形式示例：

```yaml
atlanta:
  host1:
    http_port: 80
    maxRequestsPerChild: 808
  host2:
    http_port: 303
    maxRequestsPerChild: 909
```

当SSH使用非标准端口(22)时，你可以在主机后接上端口号：

```ini
badwolf.example.com:5309
```

`Connection variables`连接变量也可以用于主机变量中：

```ini
[targets]

localhost              ansible_connection=local
other1.example.com     ansible_connection=ssh        ansible_user=myuser
other2.example.com     ansible_connection=ssh        ansible_user=myotheruser
```

当使用非标准SSH端口时，`openssh`连接可以直接使用，`paramiko` 连接则不能直接使用。





### 13.7 主机清单别名Inventory aliases

我们可以在主机清单中对主机进行别名(alias)设置。请看下面的官方示例：



`ini`方式配置：

```ini
jumper ansible_port=5555 ansible_host=192.0.2.50
```

`yaml`方式配置：

```yaml
...
  hosts:
    jumper:
      ansible_port: 5555
      ansible_host: 192.0.2.50
```

当你使用Ansible连接`jumper`时则会自动连接到IP这`192.0.2.50`,端口为`5555`和主机。



我们测试一下主机清单别名功能。

修改后的主机清单如下：

```ini
[ansible@master ~]$ cat /etc/ansible/hosts
jumper ansible_port=22 ansible_host=node3

[webservers]
node1


[dbservers]
node2
```

列出所有主机，并进行连接性测试：

```sh
[ansible@master ~]$ ansible all --list-hosts
  hosts (3):
    jumper
    node1
    node2
[ansible@master ~]$ ansible jumper -m ping
jumper | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

可以发现，可以正常连接到设置别名后的`jumper`主机。

因为使用了别名，此时不能直接对`node3`进行访问。

```sh
[ansible@master ~]$ ansible node1 -a 'uptime'
node1 | CHANGED | rc=0 >>
 09:19:59 up 22 min,  2 users,  load average: 0.08, 0.03, 0.05
[ansible@master ~]$ ansible node2 -a 'uptime'
node2 | CHANGED | rc=0 >>
 09:20:01 up 22 min,  2 users,  load average: 0.00, 0.01, 0.05
[ansible@master ~]$ ansible node3 -a 'uptime'
[WARNING]: Could not match supplied host pattern, ignoring: node3
[WARNING]: No hosts matched, nothing to do
```

此时可以看到`ignoring: node3`节点node3直接被忽略。

如将`node3`也加入到主机清单中，这时候`node3`和`jumper`都可以用，都是指向`node3`这个主机的。

在主机清单中增加`node3`主机：

```ini
[ansible@master ~]$ cat /etc/ansible/hosts
node3
jumper ansible_port=22 ansible_host=node3

[webservers]
node1


[dbservers]
node2
```

查看主机列表：

```sh
[ansible@master ~]$ ansible all --list-hosts
  hosts (4):
    node3
    jumper
    node1
    node2
```

检查`node3`和`jumper`主机的连接性：

```sh
[ansible@master ~]$ ansible jumper -m 'ping'
jumper | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible node3 -m 'ping'      
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

此时可以看到`node3`和`jumper`主机都可以正常连接。

官网文档中指出，INI格式使用`key=value` 进行值的传递，在不同的位置时，表示的意义可能不同：

> Values passed in the INI format using the `key=value` syntax are interpreted differently depending on where they are declared:
> - When declared inline with the host, INI values are interpreted as Python literal structures (strings, numbers, tuples, lists, dicts, booleans, None). Host lines accept multiple `key=value` parameters per line. Therefore they need a way to indicate that a space is part of a value rather than a separator.
> - When declared in a `:vars` section, INI values are interpreted as strings. For example `var=FALSE` would create a string equal to ‘FALSE’. Unlike host lines, `:vars` sections accept only a single entry per line, so everything after the `=` must be the value for the entry.
> - If a variable value set in an INI inventory must be a certain type (for example, a string or a boolean value), always specify the type with a filter in your task. Do not rely on types set in INI inventories when consuming variables.
> - Consider using YAML format for inventory sources to avoid confusion on the actual type of a variable. The YAML inventory plugin processes variable values consistently and correctly.

参考：[https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-aliases](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-aliases)

由于使用INI格式存在数据类型转换问题，官方建议我们使用`YAML`格式来编写主机清单，以避免混淆变量的实际类型。通常来说，使用变量来描述系统策略不是最好的方法，仅仅是一种简写而已。有关在`host_vars`目录中的各个文件中存储变量值的准则，请参考组织主机变量和组变量。

### 13.8 组变量

#### 13.8.1 分配变量给一组主机--组变量

如果主机组中所有的主机都共享一个变量值，你可以将这个变量应用于这个组。

`INI`形式配置示例：

```ini
[atlanta]
host1
host2

[atlanta:vars]
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com
```

`YAML`形式配置示例：

```yaml
atlanta:
  hosts:
    host1:
    host2:
  vars:
    ntp_server: ntp.atlanta.example.com
    proxy: proxy.atlanta.example.com
```

 上述示例中，给`atlanta`这个主机组设置了两个变量`ntp_server`NTP服务器和`proxy`代理主机，对于`host1`和`host2`两个主机都可以使用这两个变量。

组变量是一次将变量应用于多个主机的便捷方法。 但是，在执行之前，Ansible始终将变量（包括清单变量）展平到主机级别。 如果主机是多个组的成员，则Ansible将从所有这些组中读取变量值。 如果你将不同的值分配给不同组中的同一变量，则Ansible将根据内部规则选择要使用的值进行合并。合并规则参考[https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-we-merge](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-we-merge)。

#### 13.8.2 组变量的继承

你可以通过在`INI`配置文件中设置`:children` suffix后缀，或者在`YAML`配置文件中设置`children:`实体对象的方式来设置组的继承，使用`:vars`或`vars:`来进行组变量的继承。

 `INI`形式配置示例：

```ini
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children]
atlanta
raleigh

[southeast:vars]
some_server=foo.southeast.example.com
halon_system_timeout=30
self_destruct_countdown=60
escape_pods=2

[usa:children]
southeast
northeast
southwest
northwest
```

`YAML`形式配置示例：

```yaml
all:
  children:
    usa:
      children:
        southeast:
          children:
            atlanta:
              hosts:
                host1:
                host2:
            raleigh:
              hosts:
                host2:
                host3:
          vars:
            some_server: foo.southeast.example.com
            halon_system_timeout: 30
            self_destruct_countdown: 60
            escape_pods: 2
        northeast:
        northwest:
        southwest:
```

以上示例中，可以看到首先定义了两个主机组`atlanta`和`raleigh`，并且这两个组是`southeast`组的子组，给`southeast`组定义了4个组变量`some_server`、`halon_system_timeout`、`self_destruct_countdown`和`escape_pods`，最后`usa`组拥有4个子项`southeast`、`northeast`、`northwest`和`southwest`。

子组有一系列属性需要注意的：

> - Any host that is member of a child group is automatically a member of the parent group.
> - A child group’s variables will have higher precedence (override) a parent group’s variables.
> - Groups can have multiple parents and children, but not circular relationships.
> - Hosts can also be in multiple groups, but there will only be **one** instance of a host, merging the data from the multiple groups.

即：

- 子组的主机会自动成为父组的成员。
- 子组的变量具有更高的优先级，会覆盖父组的变量。
- 组可以有多个父组或子组，但不能有循环关系。
- 主机可以在多个组中，但是只有一个主机实例，可以合并多个组中的数据。

### 13.9 组织主机和组变量

尽管你可以在主主机清单中存储变量，但通过单独配置不同的主机和组变量文件可以帮助你更好的组织你的主机清单。需要注意的是，**主机和组变量文件必须是YAML语法形式的文件**，可用后缀包括`.yaml`、`.yml`、`.json` 或者没有后缀。如果你对YAML语法不了解，可以参考[https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html#yaml-syntax](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html#yaml-syntax)

Ansible通过搜索主机清单或剧本文件的相对路径来加载主机和组变量。如果你的`/etc/ansible/hosts`主机清单文件包含一个主机`foosball`,并属于两个组`raleigh`和`webservers`，如果使用主机或组文件则需要按如下组织文件路径：

```
/etc/ansible/group_vars/raleigh # can optionally end in '.yml', '.yaml', or '.json'
/etc/ansible/group_vars/webservers
/etc/ansible/host_vars/foosball
```

比如，如果你的主机清单中的主机按数据中心组织的，并且每个数据中心有其自己的NTP服务器和数据库服务器，你可以创建一个文件命名为`/etc/ansible/group_vars/raleigh`用来存储`raleigh`组的变量:

```yaml
---
ntp_server: acme.example.org
database_server: storage.example.org
```

你也可以在主机或组目录下面创建子目录，Ansible会读取这些子目录下面的所有文件。如在`raleigh`组下面创建两个文件夹：

```
/etc/ansible/group_vars/raleigh/db_settings
/etc/ansible/group_vars/raleigh/cluster_settings
```

`raleigh`组中的所有主机都可以使用这些文件中定义的变量。 当单个文件太大或要在某些组变量上使用Ansible Vault时，这可以使变量井井有条。想了解Ansible Vault,请参考[https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault)。

 你也可以在剧本目录下面添加`group_vars/`或`host_vars/`目录，`ansible-playbook`命令默认会读取这些目录下的文件信息，其他命令(如`ansible`、`ansible-console`)只会读取主机清单下面的`group_vars/`或`host_vars/`目录文件信息,如果你想让其他命令也能读取剧本目录下的`group_vars/`或`host_vars/`目录，则需要添加`--playbook-dir`参数。如果你同时加载主机清单目录和剧本目录下的文件，剧本目录下面定义的变量会覆盖主机清单目录下面定义的变量。

::: tip 提示

将你的主机清单文件、变量文件等存放到版本控制仓库中是一件非常值得做的事情，有助于你跟踪主机清单和变量的变化。

:::

**现阶段因为不了解如何获取到这些变量的值，暂时不做测试，后续学习了剧本后再进行相关测试。**

### 13.10 变量合并

主机清单配置变量时，Ansible在运行剧本或命令前，都会将变量合并或展平到主机层级，这使得Ansible只用更专注于主机和任务(Host and Task)，因此组在主机清单或主机匹配外是不能存活的。 默认情况下，Ansible会覆盖变量(包括为组和/或主机定义的变量)，处理顺序(从最低到最高)为：

- all group (because it is the ‘parent’ of all other groups) 所有组
- parent group 父组
- child group 子组
- host 主机

默认情况下，Ansible合并组变量时，是按字母顺序进行合并的，且后面的变量值会覆盖前面的变量值。如一个变量testvar同时在a_group,b_group,c_group中，假设按如下定义：

```yaml
a_group:
    testvar: a
b_group:
    testvar: b
c_group:
    testvar: c
```

则Ansible的合并顺序为：

先在a_group中获取到testvar=a；然后发现b_group中也有这个变量，则此时会将b_group中的值b赋值给testvar，此时testvar=b；接着在c_group中也有这个变量，则此时会将c_group中的值c赋值给testvar，此时testvar=c。因此最终testvar=c。

你可以通过添加`ansible_group_priority`变量来改变这种默认的组合策略。你可以给`ansible_group_priority`变量定义一个数值，越大的值则会越后合并，也就是获得更高的权限，默认情况下`ansible_group_priority`变量的值为`1`。

```yaml
a_group:
    testvar: a
    ansible_group_priority: 10
b_group:
    testvar: b
    ansible_group_priority: 5
c_group:
    testvar: c
```

由于我们添加了`ansible_group_priority`变量来改变了默认的组合策略,先从没有定义`ansible_group_priority`变量的c_group开始读取数据, 先在c_group中获取到testvar=c；然后发现b_group和c_group中都定义了`ansible_group_priority`变量,且b_group中的数字5小于a_group中的数字10,因此此时先从b_group组中读取变量，则此时会将b_group中的值b赋值给testvar，此时值b将值c覆盖了,此时testvar=b；最后在a_group中也有这个变量，则此时会将a_group中的值a赋值给testvar，此时testvar=a。因此最终testvar=a。

::: warning 警告

需要注意的是,`ansible_group_priority`变量只能用在主机清单中,不能用在`group_vars/`中,因为这个变量是用来加载组变量`group_vars`的。

:::



### 13.11 多主机清单来源处理

你可以在命令行增加多主机清单参数或者通过配置`ANSIBLE_INVENTORY`来提供多个主机清单来源，这有助于你处理多个分离的环境，如`staging`演示环境或`production`生产环境，你可以同时向这两个环境发送指令：

```sh
ansible-playbook get_logs.yml -i staging -i production
```

但需要注意的是，如果在主机清单中存在变量冲突，则会按上述变量合并方式来处理。另外，合并顺序也与命令行里面的主机清单源参数有关。

比如，在上述命令中，如果在`staging`演示环境中的`[all:vars]`定义了变量`myvar = 1`,但是在`production`生产环境的`[all:vars]`定义了变量`myvar = 2`,则此时剧本会以`myvar = 2`运行。`ansible-playbook get_logs.yml -i production -i staging`则刚好相关，此时会以以`myvar = 1`运行，也就在**按后面的主机清单来源确定变量最后的值**。

#### 13.11.1 汇总目录中的库存来源

您还可以通过组合目录下的多个清单来源和来源类型来创建清单。 这对于组合静态和动态主机并将它们作为一个清单进行管理很有用。 以下清单结合了清单插件源，动态清单脚本和具有静态主机的文件：

```sh
inventory/
  openstack.yml          # configure inventory plugin to get hosts from Openstack cloud
  dynamic-inventory.py   # add additional hosts with dynamic inventory script
  static-inventory       # add static hosts and groups
  group_vars/
    all.yml              # assign variables to all hosts
```

您可以像下面这样定位此清单目录：

```sh
ansible-playbook example.yml -i inventory
```

如果存在与其他主机清单之间的变量冲突或组依赖关系，则控制主机清单的合并顺序很有用。Ansible会根据文件名按字母顺序合并清单，因此可以通过在文件前添加前缀来控制结果：

```sh
inventory/
  01-openstack.yml          # configure inventory plugin to get hosts from Openstack cloud
  02-dynamic-inventory.py   # add additional hosts with dynamic inventory script
  03-static-inventory       # add static hosts
  group_vars/
    all.yml                 # assign variables to all hosts
```

> If `01-openstack.yml` defines `myvar = 1` for the group `all`, `02-dynamic-inventory.py` defines `myvar = 2`, and `03-static-inventory` defines `myvar = 3`, the playbook will be run with `myvar = 3`.

即，如果`01-openstack.yml`中为所有组定义了`myvar = 1` ，`02-dynamic-inventory.py`动态清单中定义了`myvar = 2`，以及`03-static-inventory` 中定义了`myvar = 3`, 那么根据字母顺序，01->02->03，最终会以`myvar = 3`运行程序！

更多关于主机清单插件和动态主机清单脚本，请参考以下链接：

- 主机清单插件Inventory Plugins [https://docs.ansible.com/ansible/latest/plugins/inventory.html#inventory-plugins](https://docs.ansible.com/ansible/latest/plugins/inventory.html#inventory-plugins)
- 动态主机清单脚本Working with dynamic inventory [https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#intro-dynamic-inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#intro-dynamic-inventory)

### 13.12 连接到主机--行为参数

通过以下参数，可以控制Ansible与远程主机的交互方式。

#### 13.12.1 主机连接

Ansible不会暴露用户与SSH进程之间的通信通道，以便于SSH连接插件在用户手动输入SSH密码时能够解密SSH密钥，建议使用`ssh-agent`。

所有连接通用的参数：

- **ansible_connection** 主机连接类型，可以是任何Ansible连接类插件的名称。SSH协议类型可以取值`smart`、`ssh`或`paramiko`。非SSH协议类型在下一节讲解。
- **ansible_host** 主机名称，与你定义的主机别名不一样。
- **ansible_port** 主机端口，SSH端口默认为22，如果不是默认端口，则可以用此参数指定。
- **ansible_user** 连接到主机时使用的用户名。
- **ansible_password** 连接到主机时使用的密码，注意，不要将密码以纯文本文件形式存储，请使用vault(注vault可将例如passwords,keys等敏感数据文件进行加密)，可参考 [https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#best-practices-for-variables-and-vaults](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#best-practices-for-variables-and-vaults)。

以下是SSH连接相关的参数：

- **ansible_ssh_private_key_file** ssh使用的私钥文件。 如果使用多个密钥并且您不想使用SSH代理，则很有用。
- **ansible_ssh_common_args** 此设置始终附加到`sftp`、`scp`和`ssh`的默认命令行中。 为特定主机(或组)配置`ProxyCommand`很有用。
- **ansible_sftp_extra_args** 此设置始终附加到`sftp`的默认命令行中。
- **ansible_scp_extra_args** 此设置始终附加到`scp`的默认命令行中。
- **ansible_ssh_extra_args** 此设置始终附加到`ssh`的默认命令行中。
- **ansible_ssh_pipelining** 确定是否使用SSH管道。 这可以覆盖`ansible.cfg`中的`pipelining`管道设置。
- **ansible_ssh_executable**  此设置将覆盖使用系统ssh的默认行为。 这可以覆盖`ansible.cfg`中的`ssh_executable`设置。

特权升级(Privilege Escalation,具体可参考[Privilege Escalation](<https://docs.ansible.com/ansible/latest/user_guide/become.html#become>))相关的参数：

- **ansible_become** 与`ansible_sudo` 或`ansible_su`等效，允许强制特权升级，即拥有超级用户(或其他用户)权限。
- **ansible_become_method** 允许设置特权升级方法。
- **ansible_become_user**  与`ansible_sudo_user` 或`ansible_su_user`等效，允许你设置特权升级后的用户。
- **ansible_become_password** 与`ansible_sudo_password` 或`ansible_su_password`等效，允许你设置特权升级后的用户的认证密码，注意，不要将密码以纯文本文件形式存储，请使用vault。
- **ansible_become_exe** 与`ansible_sudo_exe` 或`ansible_su_exe`等效，允许你设置特权升级后的可使用的可执行文件。
- **ansible_become_flags** 与`ansible_sudo_flags` 或`ansible_su_flags`等效，允许你设置特权升级时使用的的标志，你也可以在`ansible.cfg`中全局设置`sudo_flags`选项。

远程环境相关参数：

- **ansible_shell_type** 目标主机系统使用的shell类型，默认使用`Bourne Shell(sh)`，除非你将`ansible_shell_executable`设置为不兼容`Bourne(sh)`的Shell，否则不应使用此设置。 默认情况下，命令使用`sh-style`语法格式化。 将此设置为`csh`或`fish`将导致在目标系统上执行的命令改为遵循这些Shell的语法。
- **ansible_python_interpreter** 主机python解释器路径，当目标主机上面存在多个Python版本且Python路径不在`/usr/bin/python`时，或者python不是Python 2.X版本时。Ansible默认并不会使用`/usr/bin/env`，因为这需要远程主机的用户`PATH`配置正常，并且假定Python可执行文件都命名为`python`。如果你自己指定的话，可以设置如`/usr/bin/python3.6`之类的参数值。
- **ansible\_\*\_interpreter** 其他类型的解释器路径，比如`ruby`或`perl`解释器等， 这将替换将在该主机上运行的模块的`shebang`。
- **ansible_shell_executable** 这将设置Ansible控制器将在目标主机上使用的Shell，会覆盖`ansible.cfg`中的`executable` 可执行文件参数，默认为`/bin/sh`。 仅当你知道在目标主机无法使用`/bin/sh`的情况下才进行更改(即`/bin/sh`未安装在目标主机上或无法从`sudo`运行)。

下面是一个ini形式的主机示例：

```ini
some_host         ansible_port=2222     ansible_user=manager
aws_host          ansible_ssh_private_key_file=/home/example/.ssh/aws.pem
freebsd_host      ansible_python_interpreter=/usr/local/bin/python
ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.1.9.3
```

非SSH连接相关的参数：

正如前面所讲，Ansible可以通过SSH方式执行剧本，但不限于这一种连接类型，当你在主机中通过`ansible_connection=<connector>`参数指定连接器时，连接类型可以发生改变，下面这些非SSH连接相关的参数都是有效的：

- `local` 本地连接器，该连接器可以将剧本部署到Ansible管理节点本身。
- `docker` Docker容器连接器，该连接器使用本地Docker客户端将剧本直接部署到Docker容器中。 此连接器可以处理以下参数：
  - **ansible_host** 要连接的Docker容器的名称。
  - **ansible_user** 在容器内操作的用户名。用户必须存在于容器内。
  - **ansible_become** 如果设置为`true`，则会使用`become_user`在容器内进行操作。
  - **ansible_docker_extra_args** Docker容器可理解的其他参数组成的字符串。

下面是一个实例化一个容器的剧本文件示例：

```yaml
- name: create jenkins container
  docker_container:
    docker_host: myserver.net:4243
    name: my_jenkins
    image: jenkins

- name: add container to inventory
  add_host:
    name: my_jenkins
    ansible_connection: docker
    ansible_docker_extra_args: "--tlsverify --tlscacert=/path/to/ca.pem --tlscert=/path/to/client-cert.pem --tlskey=/path/to/client-key.pem -H=tcp://myserver.net:4243"
    ansible_user: jenkins
  changed_when: false

- name: create directory for ssh keys
  delegate_to: my_jenkins
  file:
    path: "/var/jenkins_home/.ssh/jupiter"
    state: directory
```

你可以参考[https://docs.ansible.com/ansible/latest/plugins/connection.html#connection-plugin-list](https://docs.ansible.com/ansible/latest/plugins/connection.html#connection-plugin-list)查看更多的连接插件列表和示例。

我们测试一下，使用`ansible_python_interpreter`参数来改变默认的python解释器。

修改主机清单文件，修改后内容如下：

```ini
[ansible@master ~]$ cat /etc/ansible/hosts
node3 ansible_python_interpreter=/usr/bin/python3
jumper ansible_port=22 ansible_host=node3

[webservers]
node1


[dbservers]
node2
```

我们给`node3`增加了`ansible_python_interpreter`参数，来改变默认的python解释器为`/usr/bin/python3`。我们来测试一下连接性：

```sh
[ansible@master ~]$ ansible jumper -m ping
jumper | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ ansible node3 -m ping
node3 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

可以看到，修改了python解释器后，测试连接性时返回的信息发生了改变，缺少`ansible_facts`字段，其中的`"discovered_interpreter_python": "/usr/bin/python"`表示Ansible自动获取到的Python解释器路径。而`node3`因为已经指定了`ansible_python_interpreter`参数，因此返回值不会显示`ansible_facts`字段。

将主机清单还原，可以看到`node3`的连接性测试返回值与原来的一样，说明`ansible_python_interpreter`参数配置是有效的。

## 14. 动态主机清单

官方文档中介绍了三种动态主机清单的配置，如：

- Cobbler
- Amazon Web Services EC2
- OpenStack

相对比较复杂，我看不懂。你可以参考[https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html)

在这里([https://github.com/ansible/ansible/tree/stable-2.9/contrib/inventory](https://github.com/ansible/ansible/tree/stable-2.9/contrib/inventory))可以看到官方给出的动态主机清单脚本的示例。

## 15. Ansible Patterns模式

官方解释：

> When you execute Ansible through an ad-hoc command or by running a  playbook, you must choose which managed nodes or groups you want to  execute against. Patterns let you run commands and playbooks against  specific hosts and/or groups in your inventory. An Ansible pattern can  refer to a single host, an IP address, an inventory group, a set of  groups, or all hosts in your inventory. Patterns are highly flexible -  you can exclude or require subsets of hosts, use wildcards or regular  expressions, and more. Ansible executes on all inventory hosts included  in the pattern.

通过Ad-hoc command临时命令或运行剧本执行Ansible时，必须选择要针对哪些受控节点或组执行。 Patterns模式使您可以针对主机清单中的特定主机和/或组运行命令和剧本。 Ansible模式可以指定单个主机、IP地址、主机组、一序列组或主机清单中的所有主机。 模式具有高度的灵活性-您可以排除或要求主机的子集，使用通配符或正则表达式等等。 Ansible在模式中包括的所有清单主机上执行任务。

### 15.1 使用模式

你可以ad-hoc command临时命令或playbook剧本中使用模式，模式是ad-hoc command临时命令中唯一没有标志(flag)的元素，通常是第二个元素。如下所示：

```sh
ansible <pattern> -m <module_name> -a "<module options>"
```

示例：

```sh
ansible webservers -m service -a "name=httpd state=restarted"
```

在剧本中模式是`hosts:`行对应的内容，如下所示：

```yaml
- name: <play_name>
  hosts: <pattern>
```

示例：

```yaml
- name: restart webservers
  hosts: webservers
```

由于您经常想一次对多个主机运行命令或剧本，因此模式通常指代主机清单组。 上面的ad-hoc命令和剧本都将针对`webservers`组中的所有主机执行。

### 15.2 常见模式

下表列出了常见模式与其对应的目标主机和组的信息：

| 描述                   | 模式                         | 目标主机或组                                        |
| ---------------------- | ---------------------------- | --------------------------------------------------- |
| 所有主机              | all (or *)                   |                                                     |
| 一个主机               | host1                        |                                                     |
| 多个主机         | host1:host2 (or host1,host2) |                                                     |
| 一个主机组              | webservers                   |                                                     |
| 多个主机组        | webservers:dbservers         | webservers组和dbservers组中的所有主机 |
| 排除组       | webservers:!atlanta          | 在webservers组中但不在atlanta组中的所有主机   |
| 组交集 | webservers:&staging          | 同时在webservers组和staging组的主机    |

你可以使用英文逗号(`,`)或冒号(`:`)分隔主机系列，处理范围和IPv6地址时，首选逗号。

一旦你知道基本的模式，你可以组合更加复杂的模式。

比如：

```sh
webservers:dbservers:&staging:!phoenix
```

上面这个例子表示webservers和 dbservers两个组中隶属于staging组并且不属于 phoenix组的机器才执行命令。

你也可以在模式中使用通配符。比如在IP或主机名中使用通配符：

```ini
192.0.\*
\*.example.com
\*.com
```

你也可以将通配符与组混合使用：

```ini
one*.com:dbservers
```

### 15.3 模式的限制

模式依赖主机清单文件，如果一个主机或组不在你的主机清单中，你不能使用指定该目标的模式，如果你这么做的话，你会看到类似如下的错误：

```sh
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: Could not match supplied host pattern, ignoring: *.not_in_inventory.com
```

我这边测试输出如下：

```sh
[ansible@master ~]$ ansible *.not_in_inventory.com -m ping
[WARNING]: Could not match supplied host pattern, ignoring: *.not_in_inventory.com
[WARNING]: No hosts matched, nothing to do
```

另外，如[主机清单别名Inventory aliases](#主机清单别名Inventory aliases)中指出，当使用了alias对主机别名后，你就不能直接使用原来的主机的。

### 15.4 高级模式

常见的模式能够满足你大部分的需求，Ansible也提供了一些高级的方式让你进行模式匹配。

#### 15.4.1 在模式中使用变量

您可以使用变量通过`ansible-playbook`的`-e`参数启用传递组说明符：

```yaml
webservers:!{{ excluded }}:&{{ required }}
```

#### 15.4.2 在模式中使用组的位置序列

如，你可以像下面这样定义一个组：

```ini
[webservers]
cobweb
webbing
weber
```

你可以使用下标来获取单个主机或者主机序列：

```sh
webservers[0]       # == cobweb
webservers[-1]      # == weber
webservers[0:2]     # == webservers[0],webservers[1]
                    # == cobweb,webbing
webservers[1:]      # == webbing,weber
webservers[:3]      # == cobweb,webbing,weber
```

#### 15.4.3 在模式中使用正则表达式

您可以通过以`~`开头的模式将模式指定为正则表达式：

```sh
~(web|db).*\.example\.com
```

### 15.5 模式和Ansible-Playbook标志(flag)

有的时候你可以在命令行改变定义在剧本中的模式行为。比如，你可以通过运行一个定义了`hosts: all`的剧本通过指定`-i 127.0.0.2`，这样就算该主机没有定义在你的主机清单文件中，也可以运行(此处我没有测试)。另外，你也可以给`ansible-playbook`指定主机的标志，比如`ansible-playbook site.yml --limit datacenter2`。你也可以通过`--limit`标志从一个文件中读取主机清单信息，如`ansible-playbook site.yml --limit @retry_hosts.txt`，注意，在主机清单文件文件前面需要一个`@`字符。

## 16. Ad-hoc command临时命令

Ansible可以使用Ad-hoc command临时命令来自动完成1个或多个主机节点的管理工作。临时命令快速简单，但不能重用。临时命令的使用有助于后期使用Ansible剧本，因为临时命令的很多概念会直接移植到剧本中。

### 16.1 为什么要使用临时命令

临时命令非常适合您很少重复执行的任务。 例如，如果您想在圣诞节假期关闭实验室中所有机器的电源，则可以在Ansible中执行快速一些工作而无需编写剧本。 临时命令如下所示：

```sh
$ ansible [pattern] -m [module] -a "[module options]"
```

你可以先了解一下 Ansible Patterns模式 以及 [Ansible 模块](<https://docs.ansible.com/ansible/latest/user_guide/modules.html#working-with-modules>)。

临时任务可用于重启服务器、复制文件、管理程序包和用户等。 您可以在临时任务中使用任何Ansible模块。 临时任务(剧本)使用声明性模型，计算并执行达到指定最终状态所需的操作。 通过检查当前状态以实现幂等。在执行命令开始之前检查当前状态，如果当前状态与指定的最终状态不同，则不执行命令。

临时命令的简单使用，可参考 使用Ad-hoc command执行的单个ansible任务。

以下是一些示例。

#### 16.1.1 重启服务器

Ansible默认使用的`command`模块。你可以使用临时命令来调用 `command`模块并重启服务器。注意一点，~~Ansible主机必须能够通过SSH无密码访问所有的受控主机。~~注意，此处不准确，当在Ansible中设置了主机的用户名和密码也是可以连接到远程主机的。

下面示例是重启`atlanta`组中所有主机：

```sh
$ ansible atlanta -a "/sbin/reboot"
```

默认情况下，Ansible仅使用5个并发进程。 如果您拥有的主机数量超过这个值，则Ansible会依次与这些主机对话，但是会花费更长的时间。 要使用10个并行分支重新启动`atlanta`组的所有主机，请执行以下操作：

```sh
$ ansible atlanta -a "/sbin/reboot" -f 10
```

Ansible默认会使用你的用户账号在其他主机上运行，如果需要指定其他用户，需要使用`-u REMOTE_USER, --user REMOTE_USER`指定用户名：

```sh
$ ansible atlanta -a "/sbin/reboot" -f 10 -u username
```

重启电脑时，可能需要权限提升，你可以通过`become`关键字来进行权限提升：

```sh
$ ansible atlanta -a "/sbin/reboot" -f 10 -u username --become [--ask-become-pass]
```

如果添加`--ask-become-pass`或`-K`，则Ansible会提示您输入用于特权升级的密码（sudo/su/pfexec/doas/etc）。



::: warning 警告

需要注意的是：`command`模块不支持shell中的管道(piping)或者重定向(redirect)，如果你要使用这种语法，请使用`shell`模块。

:::



我们现在要使用`shell`模块，则需要使用`-m MODULE_NAME, --module-name MODULE_NAME`来指定模块名。

如：

```sh
$ ansible raleigh -m shell -a 'echo $TERM'
```

测试：

```sh
[ansible@master ~]$ ansible all -m shell -a 'echo $TERM'
node1 | CHANGED | rc=0 >>
xterm
node2 | CHANGED | rc=0 >>
xterm
node3 | CHANGED | rc=0 >>
xterm
jumper | CHANGED | rc=0 >>
xterm
```

### 16.2 Ansible单引号与双引号的区别

需要特别注意的是，当我们使用双引号包裹执行命令字符串时，Ansible管理节点中的变量将会传递到受控节点上去，而不是使用受控节点上的变量。

请看以下示例：

```sh
[ansible@master ~]$ ansible all -m shell -a 'echo $PWD'
node2 | CHANGED | rc=0 >>
/home/ansible
node1 | CHANGED | rc=0 >>
/home/ansible
node3 | CHANGED | rc=0 >>
/home/ansible
jumper | CHANGED | rc=0 >>
/home/ansible
[ansible@master ~]$ 
[ansible@master ~]$ pwd
/home/ansible
[ansible@master ~]$ cd /tmp
[ansible@master tmp]$ pwd
/tmp
[ansible@master tmp]$ ansible all -m shell -a "echo $PWD"
node2 | CHANGED | rc=0 >>
/tmp
node1 | CHANGED | rc=0 >>
/tmp
node3 | CHANGED | rc=0 >>
/tmp
jumper | CHANGED | rc=0 >>
/tmp
```

使用单引号包裹执行命令字符串时，Ansible会在受控节点执行该命令。如果使用双引号包裹执行命令字符串，Ansbile会在管理节点上面先计算变量的值，再将变量的值传递到受控节点上去。

上述示例中，`"echo $PWD" `会先计算`$PWD`的值`/tmp`，然后将"echo /tmp"传递到受控节点上面去，导致最后输出的是'/tmp'，而不是'/home/ansible'。

### 16.3 文件管理

临时任务可以利用Ansible和SCP的功能将许多文件并行传输到多台主机。 要将文件直接传输到`atlanta`组中的所有服务器：

```sh
$ ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

如果你要重复使用这样的任务，可以在Ansible剧本中使用`template`模板。

`file`模块在进行文件管理时，允许改变文件的从属关系以及权限配置，相同的选项也可以在`copy`模块中使用：

```sh
$ ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
$ ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
```

`file`模块在进行文件管理时也可以创建目录，类似于`mkdir -p`：

```sh
$ ansible webservers -m file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
```

`file`模块也可递归删除文件夹和文件：

```sh
$ ansible webservers -m file -a "dest=/path/to/c state=absent"
```

`file`模块的使用,具体可参考[https://docs.ansible.com/ansible/latest/modules/file_module.html#file-module](https://docs.ansible.com/ansible/latest/modules/file_module.html#file-module)。

### 16.4 包管理

你也可以使用临时任务通过包管理模块`yum`来安装、更新、移除包等操作。

要确保安装软件包而不更新软件包：

```sh
$ ansible webservers -m yum -a "name=acme state=present"
```

确保指定版本的包已经安装：

```sh
$ ansible webservers -m yum -a "name=acme-1.5 state=present"
```

确保软件包是最新版本：

```sh
$ ansible webservers -m yum -a "name=acme state=latest"
```

确保软件包没有安装：

```sh
$ ansible webservers -m yum -a "name=acme state=absent"
```

Ansible具有用于在许多平台下管理软件包的模块。 如果您的软件包管理器没有模块，则可以使用`command`命令模块安装软件包或为软件包管理器创建模块。

### 16.5 用户和组管理

你也可以使用`user`模块创建、删除、管理用户账号，`user`模块可以参考[https://docs.ansible.com/ansible/latest/modules/user_module.html#user-module](https://docs.ansible.com/ansible/latest/modules/user_module.html#user-module)。

```sh
$ ansible all -m user -a "name=foo password=<crypted password here>"

$ ansible all -m user -a "name=foo state=absent"
```

### 16.6 服务管理

通过`service`模块可以确定服务是否启动、关闭，或者重启服务。

- 确定服务已启动

```sh
$ ansible webservers -m service -a "name=httpd state=started"
```

- 重启服务

```sh
$ ansible webservers -m service -a "name=httpd state=restarted"
```

- 确定服务已关闭

```sh
$ ansible webservers -m service -a "name=httpd state=stopped"
```

### 16.7 变量收集Gathering facts

你可以通过以下命令收集系统相关的变量信息：

```sh
$ ansible all -m setup
```

输出内容非常多，你也可以进行过滤。可以参考[https://docs.ansible.com/ansible/latest/modules/setup_module.html#setup-module](https://docs.ansible.com/ansible/latest/modules/setup_module.html#setup-module)查看`setup`模块的详细内容。

## 17. Ansible模块

Ansible有非常多的模块，在这个页面[https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html#all-modules](https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html#all-modules)可以查看到所有的模块列表。

在命令行你也可以查看所有的模块：

```sh
[ansible@master ~]$ ansible-doc -l|sort|wc -l
3387
[ansible@master ~]$ ansible-doc -l|sort|head
a10_server_axapi3                                             Manage A10 Networks AX/SoftAX/Thunder/vThunder devices                
a10_server                                                    Manage A10 Networks AX/SoftAX/Thunder/vThunder devices' server object 
a10_service_group                                             Manage A10 Networks AX/SoftAX/Thunder/vThunder devices' service groups
a10_virtual_server                                            Manage A10 Networks AX/SoftAX/Thunder/vThunder devices' virtual server...
aci_aaa_user_certificate                                      Manage AAA user certificates (aaa:UserCert)                           
aci_aaa_user                                                  Manage AAA users (aaa:User)                                           
aci_access_port_block_to_access_port                          Manage port blocks of Fabric interface policy leaf profile interface s...
aci_access_port_to_interface_policy_leaf_profile              Manage Fabric interface policy leaf profile interface selectors (infra...
aci_access_sub_port_block_to_access_port                      Manage sub port blocks of Fabric interface policy leaf profile interfa...
aci_aep                                                       Manage attachable Access Entity Profile (AEP) objects (infra:AttEntity...
[ansible@master ~]$ 
```

查看模块的参数和用法可以使用`ansible-doc -s module_name` 或者`ansible module_name`。

### 17.1 常用模块

1. ping
1. debug
1. command
1. shell
1. cron
1. user
1. group
1. copy
1. file
1. yum
1. service
1. script


### 17.2 可能感兴趣的模块

1. setup
1. fetch
1. find
1. firewalld
1. get_url
1. git
1. git_config
1. hostname
1. htpasswd
1. jenkins_job
1. jenkins_job_info
1. ldap_attr
1. ldap_passwd
1. ldap_entry
1. lineinfile
1. mail
1. make
1. nginx_status_info
1. nsupdate
1. pause
1. pip
1. pip_package_info
1. python_requirements_info
1. read_csv
1. reboot
1. replace
1. seboolean
1. selinux
1. stat
1. tempfile
1. template
1. timezone
1. wait_for
1. wait_for_connection

### 17.3 ping模块

`ping`模块尝试去连接到主机，并验证可用的python，并在成功后返回`pong`。

- 该模块在Ansible剧本中没有意义，但对于ansible临时命令非常有用，可用于验证是否能够成功登陆主机并验证主机是否配置了python。
- 这不是`ICMP ping`，只是一个简单的测试模块。
- 对于windows主机，可以使用`win_ping`模块。
- 支持的参数`data`,`data`值作为`ping`成功时的返回数据。如果该参数设置为`crash`则会引发异常。

参考[https://docs.ansible.com/ansible/latest/modules/ping_module.html](https://docs.ansible.com/ansible/latest/modules/ping_module.html)

示例：

```ini
# Test we can logon to 'webservers' and execute python with json lib.
# ansible webservers -m ping

# Example from an Ansible Playbook
- ping:

# Induce an exception to see what happens
- ping:
    data: crash
```

我们进行一下测试。

修改主机清单文件，修改后,查看主机清单内容如下：

```ini
[ansible@master ~]$ cat /etc/ansible/hosts
node3
[webservers]
node1

[dbservers]
node2
```

不添加参数，进行连接性测试：

```sh
[ansible@master ~]$ ansible all -m ping
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[ansible@master ~]$ 
```

可以看到此时返回了该模块独有的键值对`"ping": "pong"`，即表示各主机都能够正常连接。

添加参数，进行连接性测试：

```sh
[ansible@master ~]$ ansible all -m ping -a 'data=boom'  
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "boom"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "boom"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "boom"
}
```

可以看到返回的键值对`"ping": "boom"`中值"boom"即为执行命令时传入的`data`的参数值。

引发异常测试：

```sh
[ansible@master ~]$ ansible all -m ping -a 'data=crash'
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
node1 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "module_stderr": "Shared connection to node1 closed.\r\n", 
    "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5404-195386588873831/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5404-195386588873831/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5404-195386588873831/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_Y9raso/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_Y9raso/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", 
    "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", 
    "rc": 1
}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
node2 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "module_stderr": "Shared connection to node2 closed.\r\n", 
    "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5405-137202491079122/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5405-137202491079122/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.78-5405-137202491079122/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_A3R6_G/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_A3R6_G/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", 
    "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", 
    "rc": 1
}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
node3 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "module_stderr": "Shared connection to node3 closed.\r\n", 
    "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.77-5403-270889976793977/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.77-5403-270889976793977/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593328935.77-5403-270889976793977/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_r8fZ9i/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_r8fZ9i/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", 
    "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", 
    "rc": 1
}
[ansible@master ~]$ 
```

我们使用剧本运行ping模块，如果不了解剧本，可以先跳转到[Ansible剧本](#Ansible剧本)章节进行基本的学习，再进行此处的学习。

编写剧本文件后，查看内容：

```sh
[ansible@master ~]$ cat myping.yml 
- hosts: all
  tasks:
    - name: 'test ping'
      ping:  
    - name: 'crash ping'
      ping: 
        data: crash
```

执行剧本：

```sh
[ansible@master ~]$ ansible-playbook myping.yml

PLAY [all] ******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]
ok: [node2]
ok: [node3]

TASK [test ping] ************************************************************************************************************************
ok: [node1]
ok: [node3]
ok: [node2]

TASK [crash ping] ***********************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
fatal: [node2]: FAILED! => {"changed": false, "module_stderr": "Shared connection to node2 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.06-5010-257482852952434/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.06-5010-257482852952434/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.06-5010-257482852952434/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_kZKDbw/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_kZKDbw/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
fatal: [node1]: FAILED! => {"changed": false, "module_stderr": "Shared connection to node1 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.05-5007-255696170664849/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.05-5007-255696170664849/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.05-5007-255696170664849/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_RgmqXu/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_RgmqXu/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: Exception: boom
fatal: [node3]: FAILED! => {"changed": false, "module_stderr": "Shared connection to node3 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.03-5006-129492314244657/AnsiballZ_ping.py\", line 102, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.03-5006-129492314244657/AnsiballZ_ping.py\", line 94, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/ansible/.ansible/tmp/ansible-tmp-1593746831.03-5006-129492314244657/AnsiballZ_ping.py\", line 40, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.system.ping', init_globals=None, run_name='__main__', alter_sys=True)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 176, in run_module\r\n    fname, loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 82, in _run_module_code\r\n    mod_name, mod_fname, mod_loader, pkg_name)\r\n  File \"/usr/lib64/python2.7/runpy.py\", line 72, in _run_code\r\n    exec code in run_globals\r\n  File \"/tmp/ansible_ping_payload_kWAlRr/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 85, in <module>\r\n  File \"/tmp/ansible_ping_payload_kWAlRr/ansible_ping_payload.zip/ansible/modules/system/ping.py\", line 75, in main\r\nException: boom\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
node3                      : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ echo $?
2
```



### 17.4 模块常见返回值

Ansible模块通常返回一个数据结构，该数据结构可以注册到变量中，或者在通过`ansible`程序输出时直接看到。 每个模块可以选择记录其自己的唯一返回值。

参考[https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html](https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html)。

本文档涵盖所有模块通用的返回值。

- backup_file, 对于那些在处理文件时实现`backup=no|yes`的模块，将创建备份文件的路径。
- changed，指示任务是否产生了变更。
- failed，指示任务是否失败。
- invocation，有关如何调用模块的信息。
- msg，传递给用户的消息。
- rc，有些模块可以直接执行命令行命令，该返回值表明执行命令行命令的退出码(return code)。
- results，如果存在该返回值，则说明该循环存在循环，并且该循环包含每个项目的常规模块结果的列表。
- skipped，指示任务是否被跳过。
- stderr，标准异常。
- stderr_lines，标准异常输出结果的每一行组成的列表。
- stdout，标准输出。
- stdout_lines，标准输出结果的每一行组成的列表。

Ansible内部返回值：

- ansible_facts， 该键值对包含一个词典，该词典将附加到分配给主机的事facts变量上。 这些将可以直接访问，不需要使用注册变量。
- exception，包含由模块异常引起的回溯信息。
- warnings，包含将显示给用户的字符串警告列表。
- deprecations， 已经弃用的键值对字典。

### 17.5 其他模块

鉴于模块的使用，非常的占篇幅，此后其他模块单独弄文件存储。

- [user模块](./user.html)  管理用户账号和属性。
- [group模块](./group.html) 管理用户组。
- [copy模块](./copy.html) 复制。
- [file模块](./file.html) 文件处理。
- [yum模块](./yum.html) 包管理。
- [service模块](./service.html) 服务、
- [script模块](./script.html) 脚本。
- [setup模块](./setup.html) 收集一些主机硬件信息。


## 18. Ansible剧本

Ansible剧本比较复杂，可以参考[https://docs.ansible.com/ansible/latest/user_guide/playbooks.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)。

### 18.1 编写剧本文件

我们先参照[https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#playbook-keywords](https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#playbook-keywords)的示例写一个简单的Ansible剧本文件。

```yaml
- hosts: all
  connection: ssh
  tasks:
    - name: This task uses ssh.
      ping:

    - name: This task uses paramiko.
      connection: paramiko
      ping:
```

官方示例给了上面的这个简单的示例。我们稍微修改一下，改成如下内容：

```yaml
- hosts: all
  tasks:
    - name: 'test ping'
      ping:
```

并存放到`myping.yml`文件中，查看修改的文件：

```sh
[ansible@master ~]$ cat myping.yml
- hosts: all
  tasks:
    - name: 'test ping'
      ping:  
```

### 18.2 查看ansible-playbook命令行帮助信息

```sh
[ansible@master ~]$ ansible-playbook --help
usage: ansible-playbook [-h] [--version] [-v] [-k]
                        [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER]
                        [-c CONNECTION] [-T TIMEOUT]
                        [--ssh-common-args SSH_COMMON_ARGS]
                        [--sftp-extra-args SFTP_EXTRA_ARGS]
                        [--scp-extra-args SCP_EXTRA_ARGS]
                        [--ssh-extra-args SSH_EXTRA_ARGS] [--force-handlers]
                        [--flush-cache] [-b] [--become-method BECOME_METHOD]
                        [--become-user BECOME_USER] [-K] [-t TAGS]
                        [--skip-tags SKIP_TAGS] [-C] [--syntax-check] [-D]
                        [-i INVENTORY] [--list-hosts] [-l SUBSET]
                        [-e EXTRA_VARS] [--vault-id VAULT_IDS]
                        [--ask-vault-pass | --vault-password-file VAULT_PASSWORD_FILES]
                        [-f FORKS] [-M MODULE_PATH] [--list-tasks]
                        [--list-tags] [--step] [--start-at-task START_AT_TASK]
                        playbook [playbook ...]

Runs Ansible playbooks, executing the defined tasks on the targeted hosts.

positional arguments:
  playbook              Playbook(s)

optional arguments:
  --ask-vault-pass      ask for vault password
  --flush-cache         clear the fact cache for every host in inventory
  --force-handlers      run handlers even if a task fails
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  --list-tags           list all available tags
  --list-tasks          list all tasks that would be executed
  --skip-tags SKIP_TAGS
                        only run plays and tasks whose tags do not match these
                        values
  --start-at-task START_AT_TASK
                        start the playbook at the task matching this name
  --step                one-step-at-a-time: confirm each task before running
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
  --vault-id VAULT_IDS  the vault identity to use
  --vault-password-file VAULT_PASSWORD_FILES
                        vault password file
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
  -M MODULE_PATH, --module-path MODULE_PATH
                        prepend colon-separated path(s) to module library (def
                        ault=~/.ansible/plugins/modules:/usr/share/ansible/plu
                        gins/modules)
  -e EXTRA_VARS, --extra-vars EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @
  -f FORKS, --forks FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory INVENTORY, --inventory-file INVENTORY
                        specify inventory host path or comma separated host
                        list. --inventory-file is deprecated
  -l SUBSET, --limit SUBSET
                        further limit selected hosts to an additional pattern
  -t TAGS, --tags TAGS  only run plays and tasks tagged with these values
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)

Connection Options:
  control as whom and how to connect to hosts

  --private-key PRIVATE_KEY_FILE, --key-file PRIVATE_KEY_FILE
                        use this file to authenticate the connection
  --scp-extra-args SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
  --sftp-extra-args SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
  --ssh-common-args SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
  --ssh-extra-args SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
  -T TIMEOUT, --timeout TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
  -c CONNECTION, --connection CONNECTION
                        connection type to use (default=smart)
  -k, --ask-pass        ask for connection password
  -u REMOTE_USER, --user REMOTE_USER
                        connect as this user (default=None)

Privilege Escalation Options:
  control how and which user you become as on target hosts

  --become-method BECOME_METHOD
                        privilege escalation method to use (default=sudo), use
                        `ansible-doc -t become -l` to list valid choices.
  --become-user BECOME_USER
                        run operations as this user (default=root)
  -K, --ask-become-pass
                        ask for privilege escalation password
  -b, --become          run operations with become (does not imply password
                        prompting)
[ansible@master ~]$ 
```

### 18.3 检查剧本文件的有效性

可以通过`ansible-playbook --syntax-check filename.yml`对`filename.yml`剧本文件进行检查。

```sh
[ansible@master ~]$ ansible-playbook --syntax-check myping.yml

playbook: myping.yml
[ansible@master ~]$ echo $?
0
```

### 18.4 模拟剧本执行--彩排

使用`-C, --check`参数可以模块剧本执行，不产生实际的改变。使用`-v`参数可以看到Ansible的返回信息。

```sh
ansible@master ~]$ ansible-playbook --check myping.yml

PLAY [all] ******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node2]
ok: [node3]
ok: [node1]

TASK [test ping] ************************************************************************************************************************
ok: [node2]
ok: [node1]
ok: [node3]

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node3                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ ansible-playbook --check myping.yml  -v
Using /etc/ansible/ansible.cfg as config file

PLAY [all] ******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node2]
ok: [node1]
ok: [node3]

TASK [test ping] ************************************************************************************************************************
ok: [node3] => {"changed": false, "ping": "pong"}
ok: [node1] => {"changed": false, "ping": "pong"}
ok: [node2] => {"changed": false, "ping": "pong"}

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node3                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

### 18.5 执行剧本

不使用`-C, --check`参数就可以执行剧本了：

```sh
[ansible@master ~]$ ansible-playbook myping.yml

PLAY [all] ******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]
ok: [node3]
ok: [node2]

TASK [test ping] ************************************************************************************************************************
ok: [node2]
ok: [node1]
ok: [node3]

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node3                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ ansible-playbook myping.yml  -v
Using /etc/ansible/ansible.cfg as config file

PLAY [all] ******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [node1]
ok: [node3]
ok: [node2]

TASK [test ping] ************************************************************************************************************************
ok: [node2] => {"changed": false, "ping": "pong"}
ok: [node3] => {"changed": false, "ping": "pong"}
ok: [node1] => {"changed": false, "ping": "pong"}

PLAY RECAP ******************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node3                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

对剧本有初步的认识后，可以去Ansible模块章节查看各模块的使用。

## 19. ansible-lint剧本文件检查工具

Ansible Lint是用于检查剧本文件的命令行工具。 使用它对Ansible剧本文件进行改进优化。

### 19.1 安装ansible-lint工具

```sh
[root@master ~]# yum install ansible-lint
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * extras: mirrors.huaweicloud.com
 * updates: mirrors.njupt.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package ansible-lint.noarch 0:3.5.1-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==========================================================================================================================================
 Package                             Arch                          Version                              Repository                   Size
==========================================================================================================================================
Installing:
 ansible-lint                        noarch                        3.5.1-1.el7                          epel                         54 k

Transaction Summary
==========================================================================================================================================
Install  1 Package

Total download size: 54 k
Installed size: 151 k
Is this ok [y/d/N]: y
Downloading packages:
ansible-lint-3.5.1-1.el7.noarch.rpm                                                                                |  54 kB  00:00:06     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : ansible-lint-3.5.1-1.el7.noarch                                                                                        1/1 
  Verifying  : ansible-lint-3.5.1-1.el7.noarch                                                                                        1/1 

Installed:
  ansible-lint.noarch 0:3.5.1-1.el7                                                                                                       

Complete!
[root@master ~]# whereis ansible-lint
ansible-lint: /usr/bin/ansible-lint
```

### 19.2 获取ansible-lint的帮助信息

```sh
# 获取帮助信息
[ansible@master ~]$ ansible-lint --help
Usage: ansible-lint [options] playbook.yml [playbook2 ...]

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -L                    list all the rules
  -q                    quieter, although not silent output
  -p                    parseable output in the format of pep8
  -r RULESDIR           specify one or more rules directories using one or
                        more -r arguments. Any -r flags override the default
                        rules in /usr/lib/python2.7/site-
                        packages/ansiblelint/rules, unless -R is also used.
  -R                    Use default rules in /usr/lib/python2.7/site-
                        packages/ansiblelint/rules in addition to any extra
                        rules directories specified with -r. There is no need
                        to specify this if no -r flags are used
  -t TAGS               only check rules whose id/tags match these values
  -T                    list all the tags
  -v                    Increase verbosity level
  -x SKIP_LIST          only check rules whose id/tags do not match these
                        values
  --nocolor             disable colored output
  --force-color         Try force colored output (relying on ansible's code)
  --exclude=EXCLUDE_PATHS
                        path to directories or files to skip. This option is
                        repeatable.
  -c C                  Specify configuration file to use.  Defaults to
                        ".ansible-lint"

# 查看版本信息
[ansible@master ~]$ ansible-lint --version
ansible-lint 3.5.1
```

### 19.3 查看所有规则

```sh
[ansible@master ~]$ ansible-lint -L
101: Deprecated always_run
  Instead of always_run, use check_mode.
102: No Jinja2 in when
  "when" lines should not include Jinja2 variables
103: Deprecated sudo
  Instead of sudo/sudo_user, use become/become_user.
104: Using bare variables is deprecated
  Using bare variables is deprecated. Update your playbooks so that the environment value uses the full variable syntax ("{{your_variable}}").
201: Trailing whitespace
  There should not be any trailing whitespace
202: Octal file permissions must contain leading zero
  Numeric file permissions without leading zero can behave in unexpected ways. See http://docs.ansible.com/ansible/file_module.html
301: Commands should not change things if nothing needs doing
  Commands should either read information (and thus set changed_when) or not do something if it has already been done (using creates/removes) or only do it if another check has a particular result (when)
302: Using command rather than an argument to e.g. file
  Executing a command when there is are arguments to modules is generally a bad idea
303: Using command rather than module
  Executing a command when there is an Ansible module is generally a bad idea
304: Environment variables don't work as part of command
  Environment variables should be passed to shell or command through environment argument
305: Use shell only when shell functionality is required
  Shell should only be used when piping, redirecting or chaining commands (and Ansible would be preferred for some of those!)
401: Git checkouts must contain explicit version
  All version control checkouts must point to an explicit commit or tag, not just "latest"
402: Mercurial checkouts must contain explicit revision
  All version control checkouts must point to an explicit commit or tag, not just "latest"
403: Package installs should not use latest
  Package installs should use state=present with or without a version
501: become_user requires become to work as expected
  become_user without become will not actually change user
502: All tasks should be named
  All tasks should have a distinct name for readability and for --start-at-task to work
503: Tasks that run when changed should likely be handlers
  If a task has a `when: result.changed` setting, it's effectively acting as a handler
[ansible@master ~]$ 
```



### 19.4 语法检查

对之前写的一个剧本文件cron.yml文件进行检查：

```sh
[ansible@master ~]$ ansible-lint cron.yml
[201] Trailing whitespace
cron.yml:3
    - name: absent a root cron in /etc/cron.d/ 

[201] Trailing whitespace
cron.yml:10
    - name: absent a ansible cron in /etc/cron.d/ 

[201] Trailing whitespace
cron.yml:12
        name: sync time at every month first day 

[201] Trailing whitespace
cron.yml:17
      

[201] Trailing whitespace
cron.yml:25
[ansible@master ~]$ echo $?
2
```

提示有些行有空格，需要移除。我们修改一下cron.yml文件：

```yaml
- hosts: node1
  tasks:
    - name: absent a root cron in /etc/cron.d/
      cron:
        name: sync time at every Tuesday
        cron_file: ansible_sync_time
        state: absent
      become: yes

    - name: absent a ansible cron in /etc/cron.d/
      cron:
        name: sync time at every month first day
        job: "sudo ntpdate 182.92.12.11 |tee /tmp/synctime.log"
        cron_file: ansible_sync_time
        state: absent
      become: yes

    - name: absent a ansible cron in /etc/crontab after beckup the cron
      cron:
        name: sync time at every Tuesday
        cron_file: /etc/crontab
        backup: yes
        state: absent
      become: yes

```

然后再进行检查：

```sh
[ansible@master ~]$ ansible-lint cron.yml
[ansible@master ~]$ echo $?
0
```

说明ansible-lint检查通过！





参考：

1. [Ansible官方文档](https://docs.ansible.com/ansible/latest/index.html)
1. [Ansible中文权威指南](http://www.ansible.com.cn/index.html)
1. [A system administrator's guide to getting started with Ansible - FAST!](https://www.redhat.com/en/blog/system-administrators-guide-getting-started-ansible-fast)
1. [ansible github源码](https://github.com/ansible/ansible/)
1. [Ansible 快速上手](http://www.ttlsa.com/ansible/hands-on-with-ansible/)
1. [Ansible安装部署以及常用模块详解](https://www.cnblogs.com/easonscx/p/10622781.html)
1. [Ansible批量管理软件的使用](https://www.cnblogs.com/woaiyunwei/p/13140429.html)
1. [Ansible第二篇：ansible-playbook](https://www.jianshu.com/p/171578692c94)
1. [ansible批量管理服务](https://www.cnblogs.com/yjiu1990/p/10508643.html)
1. [ansible各种变量定义及引用](https://www.cnblogs.com/deny/p/12394956.html)
1. [ansible 基础](https://www.cnblogs.com/keme/p/11351611.html)









