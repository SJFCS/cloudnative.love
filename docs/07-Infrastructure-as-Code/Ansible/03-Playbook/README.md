---
title: Playbook
sidebar_position: 3
---

playbook组成如下：

- play: 定义的是主机的角色
- task: 定义的是具体执行的任务
- playbook: 由一个或多个play组成，一个play可以包含多个task任务

## 变量使用
:::tip
如果定义的变量出现重复，优先级如下：

-e，--extra-vars--->playbook(vars_files--->vars)--->inventory(host_vars--->group_vars/group_name--->group_vars--->all)
:::
### 1. 外置传参：**-e，--extra-vars**   

 playbook执行时传入file_name变量的参数，在/tmp目录创建New文件

   ```bash
   - hosts: all
     tasks:
     - name: Create New File
       file: path=/tmp/{{ file_name }} state=touch
   ```

   ```
   ansible-playbook Create_New_File.yml --extra-vars "file_name=New"
   ```

### 2. playbook中的变量

   - **playbook中使用vars_files文件指定变量**

      变量文件  vars.yml

      ```bash
      server_name: web_server
      packages: 
        - nginx
        - httpd
      ```
      playbook调用

      ```bash
      - hosts: webservers
        vars_files: ./vars.yml
        tasks:
          - name: Install "{{ server_name }}" Packages  
            yum: name={{ packages }} state=present
      ```

   - **playbook的yaml文件中直接定义变量赋值**

   ```bash
   - hosts: all
     vars:  #定义变量
       file_name: New
   
     tasks:
     - name: # {{ file_name }}引用上面定义的变量
       file: path=/tmp/{{ file_name }} state=touch
   ```

### 3. inventory文件中定义变量

   (host_vars--->group_vars/group_name--->group_vars--->all) 

   可以在/etc/ansible/hosts主机组中定义，然后使用palybook进行调度该变量*

   ```bash
   #在文件中定义变量
   [root@manager ~]# cat /etc/ansible/hosts
   [nfs]
   10.0.0.20
   [nfs:vars]
   file_name=bgx_filename
   
   #Playbook中调用该变量
   [root@manager ~]# cat f4.yml
   ---
   - hosts: all
   
     tasks:
     - name: Create New File
       file: path=/tmp/{{ file_name }} state=touch
   
   #playbook执行，在/tmp目录创建bgx_filename文件
   ```
### 4. 变量注册

注册变量: register关键字可以存储指定命令的输出结果到一个自定义的变量中

```bash
---
- hosts: all
  tasks:
    - name:
      shell: netstat -lntp
      register: System_Status

    - name: Get System Status
      debug: msg={{System_Status.stdout_lines}}

```

## 4.Playbook条件语句

### 1. 判断主机系统

为不同系统安装httpd

```bash
- hosts: all
  remote_user: root
  tasks:
    - name: Create File
      file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
      when: (ansible_hostname == "nfs") or (ansible_hostname == "backup")

#系统为centos的主机才会执行
    - name: Centos Install httpd
      yum: name=httpd state=present
      when: (ansible_distribution == "CentOS")

#系统为ubuntu的主机才会执行
    - name: Ubuntu Install httpd
      yum: name=httpd2 state=present
      when: (ansible_distribution == "Ubuntu")
```

### 2. 判断主机名

为所有web和lb主机名的添加nginx仓库，其余跳过

```bash
- hosts: all
  tasks:
  - name: Add Nginx Yum Repository
    yum_repository:
      name: nginx
      description: Nginx Repositort
      baseurl: http://nginx.org/packages/centos/7/$basearch/
      gpgcheck: no
    when: (ansible_hostname is match("web*")) or
          (ansible_hostname is match("lb*"))
```

### 3. 判断命令执行结果

通过register将结果保存为变量，然后通过when进行判断

执行systemctl is-active httpd失败不为active时，check_httpd.rc不为0。此时重启httpd服务

```bash
- hosts: webservers
  tasks:
    - name: Check Httpd Server
      command: systemctl is-active httpd
      ignore_errors: yes
      register: check_httpd
    - name: debug outprint
      debug: var=check_httpd
    - name: Httpd Restart
      service: name=httpd state=restarted
      when: check_httpd.rc != 0

```

## 5.Playbook循环语句

### 1、批量安装软件

```bash
---
- hosts: all
  remote_user: root
  tasks:
    - name: Installed Pkg
      yum: name={{ item }} state=present
      with_items:
        - wget
        - tree
        - lrzsz
```

### 2、批量创建用户

```bash
- hosts: all
  remote_user: root
  tasks:
    - name: Add Users
      user: name={{ item.name }} groups={{ item.groups }} state=present
      with_items:
        - { name: 'testuser1', groups: 'bin' }
        - { name: 'testuser2', groups: 'root' }
```

### 3、拷贝多个目录

```bash
- hosts: all
  remote_user: root
  tasks:
    - name: Configure Rsync Server
      copy: src={{ item.src }} dest=/etc/{{ item.dest }} mode={{ item.mode }}
      with_items:
        - {src: "rsyncd.conf", dest: "rsyncd.conf", mode: "0644"}
        - {src: "rsync.passwd", dest: "rsync.passwd", mode: "0600"}
```

## 6.Playbook异常处理

*默认Playbook会检查命令和模块的返回状态，如遇到错误就中断playbook的执行
 加入参数: ignore_errors: yes 忽略错误*

```bash
---
- hosts: all
  remote_user: root
  tasks:
    - name: Ignore False
      command: /bin/false
      ignore_errors: yes

    - name: touch new file
      file: path=/tmp/bgx_ignore state=touch
```

## 7.Playbook tags标签

标签使用，通过tags和任务对象进行捆绑，控制部分或者指定的task执行

> -t: 执行指定的tag标签任务
>  --skip-tags: 执行--skip-tags之外的标签任务

```bash
---
- hosts: all
  remote_user: root
  tasks:
    - name: Install Nfs Server
      yum: name=nfs-utils state=present
      tags:
        - install_nfs
        - install_nfs-server

    - name: Service Nfs Server
      service: name=nfs-server state=started enabled=yes
      tags: start_nfs-server
```

使用-t指定tags执行, 多个tags使用逗号隔开即可

```bash
[root@manager ~]# ansible-playbook -t install_nfs-server f10.yml
```

使用--skip-tags排除不执行的tags

```bash
[root@manager ~]# ansible-playbook --skip-tags install_nfs-server f10.yml
```

## 8.Playbook Handlers

*`playbook`安装`Apache`示例*

```bash
[root@m01 ~]# cat webserver.yml 
- hosts: web
  remote_user: root
#1.定义变量，在配置文件中调用
  vars:
    http_port: 8881

#2.安装httpd服务
  tasks:
    - name: Install Httpd Server
      yum: name=httpd state=present

#3.使用template模板，引用上面vars定义的变量至配置文件中
    - name: Configure Httpd Server
      template: src=./httpd.conf dest=/etc/httpd/conf/httpd.conf
      notify: Restart Httpd Server

#4.启动Httpd服务
    - name: Start Httpd Server
      service: name=httpd state=started enabled=yes

#5.检查Httpd服务当前的运行的端口状态
    - name: Get Httpd Server Port
      shell: netstat -lntp|grep httpd
      register: Httpd_Port

#6.输出Httpd运行的状态至面板
    - name: Out Httpd Server Status
      debug: msg={{ Httpd_Port.stdout_lines }}
      ignore_errors: yes

#6.如果配置文件发生变化会调用该handlers下面的模块
  handlers:
    - name: Restart Httpd Server
      service: name=httpd state=restarted
```

## 9.Playbook Include

include用来动态的包含tasks任务列表，`include_tasks新版/include老版`


## 扩展阅读
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks.html
- https://www.devopsschool.com/blog/understanding-ansible-playbook-using-diagram/
- https://redian.news/wxnews/256183