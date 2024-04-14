# hostname主机名模块

[[toc]]

- 本模块用于设置远程主机的主机名。
- 本模块不会修改`/etc/hosts`,如果你要修改该文件，可以使用`template`或`replace`模块。

## 1. 参数


| 参数               | 描述                                                                                                                                                                              |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name   string/必需 | 主机名                                                                                                                                                                            |
| use      string    | 使用哪种策略来更新主机名，可选值：alpine, debian, freebsd, generic, macos, macosx, darwin, openbsd, openrc, redhat, sles, solaris, systemd|


## 2. 官方示例

```yaml
- name: Set a hostname
  ansible.builtin.hostname:
    name: web01

- name: Set a hostname specifying strategy
  ansible.builtin.hostname:
    name: web01
    use: systemd
```


## 3. 使用剧本测试修改主机名

为了能够还原回来各节点原来的主机名，我们先用ansible查看一下当前节点主机名信息：

```sh
[ansible@master ansible_playbooks]$ ansible all -m command -a "hostname"
node1 | CHANGED | rc=0 >>
node1.hellogitlab.com
node2 | CHANGED | rc=0 >>
node2.hellogitlab.com
```

我们在主机清单配置文件中，增加每个需要修改主机的主机名变量`ansible_hostname`，修改完成后，查看主机清单文件：
```sh
[ansible@master ansible_playbooks]$ cat /etc/ansible/hosts
[myhosts]
node1 ansible_hostname=node1.ansible.com ansible_user=ansible ansible_port=22
node2 ansible_hostname=node2.ansible.com ansible_user=ansible ansible_port=22
```

使用debug调试一下，看看获取到的设置的主机名变量：
```sh
[ansible@master ansible_playbooks]$ ansible all -m debug -a "msg={{ ansible_hostname }}"
node2 | SUCCESS => {
    "msg": "node2.ansible.com"
}
node1 | SUCCESS => {
    "msg": "node1.ansible.com"
}
[ansible@master ansible_playbooks]$
```

可以看到，节点能够正常获取到设置的主机名变量。

编写`hostname.yml`剧本文件：

```yaml
- hosts: all
  tasks:
    - name: Set hostname
      ansible.builtin.hostname:
        name: "{{ ansible_hostname }}"
      become: yes
```

语法检查，并执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-lint hostname.yml
[ansible@master ansible_playbooks]$ ansible-playbook hostname.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [all] *************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]
ok: [node2]

TASK [Set hostname] ****************************************************************************************************
changed: [node1] => {"ansible_facts": {"ansible_domain": "", "ansible_fqdn": "node1", "ansible_hostname": "node1", "ansible_nodename": "node1"}, "changed": true, "name": "node1"}
changed: [node2] => {"ansible_facts": {"ansible_domain": "ansible.com", "ansible_fqdn": "node2.ansible.com", "ansible_hostname": "node2", "ansible_nodename": "node2"}, "changed": true, "name": "node2"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，主机修改成功。

我们检查一下节点主机名：
```sh
[ansible@master ansible_playbooks]$ ansible all -m command -a "hostname"
node1 | CHANGED | rc=0 >>
node1
node2 | CHANGED | rc=0 >>
node2
[ansible@master ansible_playbooks]$
```

可以看到，设置主机名变量是`node1.ansible.com`这样的，Ansible会自动截图第一个点前面的字符作为主机名。

我们在各节点主机上面将主机名还原：
```sh
# 节点1重置主机名
$ sudo hostnamectl set-hostname node1.hellogitlab.com

# 节点2重置主机名
$ sudo hostnamectl set-hostname node2.hellogitlab.com
```


