---
title: Ansible-console
---

在Ansible playbook中，下面是一些示例用法：

对于大多数Linux和Unix系统，您可以使用SSH作为连接选项：
```yaml
- name: Configure web server
  hosts: webserver
  remote_user: root
  vars:
    ansible_connection: ssh
    ansible_ssh_user: root
    ansible_ssh_private_key_file: /path/to/private/key
```
对于Windows系统，您可以使用WinRM作为连接选项：
```yaml
- name: Configure Windows server
  hosts: windows_server
  remote_user: Administrator
  vars:
    ansible_connection: winrm
    ansible_port: 5985
    ansible_winrm_transport: basic
    ansible_winrm_server_cert_validation: ignore
```
在此示例中，我们将WinRM作为连接选项，并设置相关选项以连接到Windows服务器。

对于在本地主机上执行任务的情况，您可以使用local作为连接选项：
```yaml
- name: Run a local command
  hosts: localhost
  connection: local
  tasks:
    - name: Run a command
      shell: echo "Hello, World"
```
在此示例中，我们将连接选项设置为local，以便在本地主机上执行命令。

使用SSH代理跳转到跳板机然后执行任务：
```yaml
- name: Run a command via ssh proxy jump
  hosts: target
  remote_user: ubuntu
  become: yes
  vars:
    ansible_connection: ssh
    ansible_ssh_common_args: "-o ProxyCommand='ssh -W %h:%p jumpbox'"
  tasks:
     - name: Run a command
       shell: echo "Hello, World"
```
在此示例中，我们将“ansible_connection”设置为SSH，并在变量“ansible_ssh_common_args”中设置SSH代理跳转参数。

## 使用 ansible-console 交互式执行命令
ansible-console -i inventory all -u vagrant

:::tip参考文档
- https://docs.ansible.com/ansible/latest/inventory_guide/connection_details.html#host-key-checking
- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
- https://evrard.me/convert-ansible-inventories-with-ansible-inventory-cli/
:::