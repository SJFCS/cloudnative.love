这里提供一个使用ansible-CMDB生成HTML摘要页面的项目示例：

- 项目名称：IT基础架构信息收集
- 项目目的：收集IT基础架构的各种信息，包括服务器、网络设备、存储设备等，以便于管理员进行管理和维护。
- 使用工具：ansible, ansible-cmdb

1. 创建hosts文件，列出要收集数据的主机清单。
```ini
[server]
192.168.1.1
192.168.1.2

[network]
192.168.1.3
192.168.1.4

[storage]
192.168.1.5
```
2. 创建ansible playbook文件，用于收集主机信息。这里以收集服务器信息为例。
```yaml
- name: Collect server facts
  hosts: server
  gather_facts: yes
  tasks:
  - name: Collect server facts
    setup:
  - name: Save facts to file
    delegate_to: localhost
    copy:
      content: "{{ hostvars[item].ansible_facts }}" 
      dest: "./data/hosts/{{ item }}.json"
      force: yes
    with_items: "{{ groups['all'] }}"
    when: "'server' in item"
```
该playbook将在服务器主机上运行，并使用ansible的setup模块收集主机信息，将结果保存到data/hosts目录下的相应json文件中。

3. 运行ansible playbook，收集主机信息。
```bash
ansible-playbook -i hosts collect.yml --extra-vars "output_dir=./data"
```
4. 运行ansible-CMDB命令，将数据转换为HTML摘要页面。
```
ansible-cmdb -i ./data/hosts -t html_fancy output.html
```
该命令将使用ansible-CMDB提供的html_fancy模板，将json文件转换为HTML摘要页面，并将结果保存为output.html文件。

在浏览器中打开生成的HTML页面，查看收集到的IT基础架构信息。
该HTML页面将会显示包括服务器的主机名、内存、CPU等信息，还可以切换到其他导航标签来查看其他主机类型的信息。

这样，管理员就可以通过ansible-CMDB生成的HTML摘要页面，轻松快速地浏览整个IT基础架构的信息，从而更好地进行管理和维护。