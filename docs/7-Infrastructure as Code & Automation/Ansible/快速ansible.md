---
title: 快速入门Ansible
sidebar_position: 0
---

## ssh免密

通常通过ssh密钥管理主机，而不用在hosts中写入密码

 ```bash
# master生成密钥
ssh-keygen
# master分发密钥
sshpass -p pass  ssh-copy-id -i ~/.ssh/id_rsa.pub user@IP
# client查看信任主机
cat ~/.ssh/known_hosts
 ```
## Ansible 安装使用
```bash
yum install ansible
vi /etc/ansible/ansible.cfg
[defaultes]
host_key_checking = False

vi /etc/ansible/hosts
[new-machine]
10.50.1.103
[new-machine:vars]
ansible_ssh_user=lis
ansible_ssh_pass=123
ansible_become=true
ansible_become_method=su
ansible_become_user=root
ansible_become_pass=0

ansible -i ./hosts new_machine -m shell -a 'sh echo "12"'
ansible -i ./hosts new_machine -m copy -a 'src=./init.sh dest=/root/init.sh'
```

