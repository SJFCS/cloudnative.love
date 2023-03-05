# script执行本地脚本模块-不推荐

[[toc]]

::: warning 警告
不要直接使用scipt模块执行脚本，请转换成Ansible其他模块！！
:::

## 1. 概要

- `script`模块用于将本地脚本传输到远程主机并执行。
- 本模块也支持windows主机。
- `script`脚本模块接受脚本名称后接以空格分隔的一序列参数。
- 可以使用自由形式的命令，或者使用`cmd`参数指定脚本命令。
- 本地的脚本首先传输到远程主机上，然后执行。
- 给定的脚本将在远程主机的SHELL环境下处理。
- 该模块不要求远程主机上面有python环境。
- 源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/script.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/script.py)
- 官方文档：[https://docs.ansible.com/ansible/latest/modules/script_module.html](https://docs.ansible.com/ansible/latest/modules/script_module.html)



## 2. 参数

| 参数                                                         | 可选值 | 默认值 | 说明                                               |
| ------------------------------------------------------------ | ------ | ------ | -------------------------------------------------- |
| **chdir**                                                    |        |        | 在执行脚本前，改变工作目录                         |
| **cmd**                                                       string |        |        | 本地脚本路径及运行参数组成的命令                   |
| **creates**                                                  |        |        | 远程主机上的文件名，如果文件已经存在，则不执行任务 |
| **decrypt**                                                boolean | yes/no | yes    | 此选项使用Vault控制源文件的自动解密                |
| **executable**                                               |        |        | 脚本的执行程序，如`/usr/bin/python3`               |
| **free_form**                                                |        |        | 自由形式的命令，不实际使用此参数                   |
| **removes**                                                  |        |        | 远程主机上的文件名，如果文件不存在，则不执行任务   |



## 3. 返回值

参考通用返回值。



## 4. 说明

- **通常不建议直接在远程主机上面执行脚本，建议将脚本转换成Ansible剧本去执行。**
- 通过`ssh`连接到远程主机时，会强制使用伪终端，此时所有`stderr`会发送到`stdout`,如果你要区分对待这两种输出的话，建议使用`copy`或`command`模块。
- 如果本地脚本的路径包含空格，应使用引号包裹起来。



## 5. 官方示例

```yaml
- name: Run a script with arguments (free form)
  script: /some/local/script.sh --some-argument 1234

- name: Run a script with arguments (using 'cmd' parameter)
  script:
    cmd: /some/local/script.sh --some-argument 1234

- name: Run a script only if file.txt does not exist on the remote node
  script: /some/local/create_file.sh --some-argument 1234
  args:
    creates: /the/created/file.txt

- name: Run a script only if file.txt exists on the remote node
  script: /some/local/remove_file.sh --some-argument 1234
  args:
    removes: /the/removed/file.txt

- name: Run a script using an executable in a non-system path
  script: /some/local/script
  args:
    executable: /some/remote/executable

- name: Run a script using an executable in a system path
  script: /some/local/script.py
  args:
    executable: python3
```



## 6. 使用临时命令

现在我们来准备一个脚本，在ansible家目录下面创建一个`local_script.sh`的脚本，并尝试在本地执行一下：

```sh
[ansible@master ~]$ ls
ansible-yml  local_script.sh
[ansible@master ~]$ cat local_script.sh 
#!/bin/bash
pwd
hostname -I|tee hostname.log
[ansible@master ~]$ sh local_script.sh 
/home/ansible
192.168.56.110 10.0.3.15 
[ansible@master ~]$ ls
ansible-yml  hostname.log  local_script.sh
[ansible@master ~]$ cat hostname.log 
192.168.56.110 10.0.3.15 
[ansible@master ~]$ 
```

`local_script.sh`脚本首先打印当前路径，然后输出服务器IP地址，并写入到`hostname.log`日志文件中。

我们现在来使用临时命令执行一下`script`脚本模块的命令：

```sh
[ansible@master ~]$ ansible node1 -m script -a "local_script.sh"
node1 | CHANGED => {
    "changed": true, 
    "rc": 0, 
    "stderr": "Shared connection to node1 closed.\r\n", 
    "stderr_lines": [
        "Shared connection to node1 closed."
    ], 
    "stdout": "/home/ansible\r\n192.168.56.111 10.0.3.15 \r\n", 
    "stdout_lines": [
        "/home/ansible", 
        "192.168.56.111 10.0.3.15 "
    ]
}
[ansible@master ~]$ 
```

可以看到脚本成功执行，能够正常获取到`node1`节点的IP地址，并且工作路径是`/home/ansible`目录，我们在node1节点上面检查一下是否有`hostname.log`生成：

```sh
[ansible@node1 ~]$ ls
hostname.log
[ansible@node1 ~]$ cat hostname.log 
192.168.56.111 10.0.3.15 
[ansible@node1 ~]$ 
```

可以看到，`hostname.log`日志文件成功创建了。



## 7. 使用剧本

由于官方并不建议我们使用`script`脚本模块，我们仅简单的了解一下本模块的使用，不详细推演。



### 7.1 改变工作路径

```sh
[ansible@master ~]$ cat script.yml 
- hosts: node1
  tasks:
    # 运行脚本前改变工作路径
    - name: Run a script after changed the work directory
      script:
        cmd: /home/ansible/local_script.sh
        chdir: /tmp
[ansible@master ~]$ ansible-lint script.yml 
[ansible@master ~]$ ansible-playbook --syntax-check script.yml 

playbook: script.yml
[ansible@master ~]$ ansible-playbook script.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Run a script after changed the work directory] ********************************************
changed: [node1] => {"changed": true, "rc": 0, "stderr": "Shared connection to node1 closed.\r\n", "stderr_lines": ["Shared connection to node1 closed."], "stdout": "/tmp\r\n192.168.56.111 10.0.3.15 \r\n", "stdout_lines": ["/tmp", "192.168.56.111 10.0.3.15 "]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到执行脚本前，已经将目录切换到`/tmp`目录了，我们看一下`/tmp`目录下面是不是生成了`hostname.log`文件：

```sh
[ansible@node1 ~]$ ls -lah /tmp/hostname.log 
-rw-rw-r-- 1 ansible ansible 26 Aug 14 16:32 /tmp/hostname.log
[ansible@node1 ~]$ cat /tmp/hostname.log 
192.168.56.111 10.0.3.15 
[ansible@node1 ~]$ 
```

可以看到，生成了日志文件，说明切换目录正常工作。



### 7.2 执行其他类型脚本

下面我们将Python脚本传输到远程主机执行。

在Ansible主机上编写Python脚本：

```sh
[ansible@master ~]$ cat local_python.py 
import os
print(os.getcwd())
[ansible@master ~]$ python local_python.py 
/home/ansible
[ansible@master ~]$ 
```

我们执行一下剧本：

```sh
[ansible@master ~]$ cat script.yml 
- hosts: node1
  tasks:
    # 运行Python脚本
    - name: Run a script after changed the work directory
      script:
        cmd: /home/ansible/local_python.py
        chdir: /tmp
        executable: python3
[ansible@master ~]$ ansible-lint script.yml 
[ansible@master ~]$ ansible-playbook --syntax-check script.yml 

playbook: script.yml
[ansible@master ~]$ ansible-playbook script.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Run a script after changed the work directory] ********************************************
changed: [node1] => {"changed": true, "rc": 0, "stderr": "Shared connection to node1 closed.\r\n", "stderr_lines": ["Shared connection to node1 closed."], "stdout": "/tmp\r\n", "stdout_lines": ["/tmp"]}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，成功执行了Python脚本。



其他参数的使用，请参考上面的官方示例。