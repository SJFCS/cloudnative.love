# pip模块-管理python库依赖

[[toc]]

## 1. 概述
- 官方文档: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html)
- 要运行本模块，需要远程主机安装有`pip`、`virtualenv`和`setuptools`。

## 2. 参数说明

| 参数                     | 可选值 | 默认值 | 说明                                                         |
| ------------------------ | ------ | ------ | ------------------------------------------------------------ |
| `chdir`                  |        |        | `path`，运行命令前切换到该目录 |
| `editable`               | true/false | false     | `boolean`，是否传递可编辑标志。 |
| `executable`             |        |        | `path`，pip可执行程序路径。 |
| `extra_args`             |        |        | `string`,附加参数 |
| `name`                   |        |        | `list`，需要安装的Python库的名称。             |
| `requirements`             |        |        | `string`,远程requirements文件路径 |
| `state`             | absent/forcereinstall/latest/present       |  present      | `string`,状态 |
| `umask`             |        |        | `string`,执行命令前改变umask，如0022 |
| `version`             |        |        | `string`,指定包的版本信息 |
| `virtualenv`             |        |        | `path`,virtualenv虚拟环境安装目录 |
| `virtualenv_command`             |        |   virtualenv     | `path`,创建虚拟环境所使用的命令或命令路径。如 pyvenv, virtualenv, virtualenv2, ~/bin/virtualenv, /usr/local/bin/virtualenv|
| `virtualenv_python`             |        |        | `string`,虚拟环境所使用的python可执行文件，如python3.5、python2.7 |
| `virtualenv_site_packages`             | yes/no       | no       | `boolean`,是否虚拟环境继承全局的site-packages目录。对已经存在的虚拟环境没有作用。 |


## 3. 官方示例

```yaml
# Install (Bottle) python package.
- pip:
    name: bottle

# Install (Bottle) python package on version 0.11.
- pip:
    name: bottle==0.11

# Install (bottle) python package with version specifiers
- pip:
    name: bottle>0.10,<0.20,!=0.11

# Install multi python packages with version specifiers
- pip:
    name:
      - django>1.11.0,<1.12.0
      - bottle>0.10,<0.20,!=0.11

# Install python package using a proxy - it doesn't use the standard environment variables, please use the CAPITALIZED ones below
- pip:
    name: six
  environment:
    HTTP_PROXY: '127.0.0.1:8080'
    HTTPS_PROXY: '127.0.0.1:8080'

# Install (MyApp) using one of the remote protocols (bzr+,hg+,git+,svn+). You do not have to supply '-e' option in extra_args.
- pip:
    name: svn+http://myrepo/svn/MyApp#egg=MyApp

# Install MyApp using one of the remote protocols (bzr+,hg+,git+).
- pip:
    name: git+http://myrepo/app/MyApp

# Install (MyApp) from local tarball
- pip:
    name: file:///path/to/MyApp.tar.gz

# Install (Bottle) into the specified (virtualenv), inheriting none of the globally installed modules
- pip:
    name: bottle
    virtualenv: /my_app/venv

# Install (Bottle) into the specified (virtualenv), inheriting globally installed modules
- pip:
    name: bottle
    virtualenv: /my_app/venv
    virtualenv_site_packages: yes

# Install (Bottle) into the specified (virtualenv), using Python 2.7
- pip:
    name: bottle
    virtualenv: /my_app/venv
    virtualenv_command: virtualenv-2.7

# Install (Bottle) within a user home directory.
- pip:
    name: bottle
    extra_args: --user

# Install specified python requirements.
- pip:
    requirements: /my_app/requirements.txt

# Install specified python requirements in indicated (virtualenv).
- pip:
    requirements: /my_app/requirements.txt
    virtualenv: /my_app/venv

# Install specified python requirements and custom Index URL.
- pip:
    requirements: /my_app/requirements.txt
    extra_args: -i https://example.com/pypi/simple

# Install specified python requirements offline from a local directory with downloaded packages.
- pip:
    requirements: /my_app/requirements.txt
    extra_args: "--no-index --find-links=file:///my_downloaded_packages_dir"

# Install (Bottle) for Python 3.3 specifically,using the 'pip3.3' executable.
- pip:
    name: bottle
    executable: pip3.3

# Install (Bottle), forcing reinstallation if it's already installed
- pip:
    name: bottle
    state: forcereinstall

# Install (Bottle) while ensuring the umask is 0022 (to ensure other users can use it)
- pip:
    name: bottle
    umask: "0022"
  become: True
```


## 4. 剧本的使用

为了测试pip模块的使用，我们先检查一下节点1上面的pip版本信息以及安装的包信息：
```sh
[root@node1 ~]# python3 -V
Python 3.6.8
[root@node1 ~]# whereis pip
pip: /usr/bin/pip3.6
[root@node1 ~]# pip3 --version
pip 9.0.3 from /usr/lib/python3.6/site-packages (python 3.6)
[root@node1 ~]# pip3 list
pip==9.0.3
setuptools==39.2.0
[root@node1 ~]# cat ~/.pip/pip.conf
[global]
index-url = http://mirrors.tencentyun.com/pypi/simple
trusted-host = mirrors.tencentyun.com

[list]
# Select the output format among: legacy (default), columns, freeze or json
format = freeze
[root@node1 ~]#
```

可以看到，node1节点已经安装了python3.6.8，对应的pip版本是pip 9.0.3，并且pip配置了腾讯云的镜像加速。


### 4.1 安装flask包

尝试安装flask包：
```sh
[ansible@master ansible_playbooks]$ cat pip.yml
- hosts: node1
  tasks:
    - name: Install python package
      ansible.builtin.pip:
        name: flask
      become: yes

[ansible@master ansible_playbooks]$ ansible-lint pip.yml
[ansible@master ansible_playbooks]$ ansible-playbook pip.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Install python package] ******************************************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "Unable to find any of pip2, pip to use.  pip needs to be installed."}

PLAY RECAP *************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，安装失败，提示未找到pip2命令。而我们节点上面使用的是pip3。

指定使用pip3作为可执行程序，再进行安装，可以看到安装成功：
```sh
[ansible@master ansible_playbooks]$ cat pip.yml
- hosts: node1
  tasks:
    - name: Install python package
      ansible.builtin.pip:
        name: flask
        executable: pip3
      become: yes

[ansible@master ansible_playbooks]$ ansible-lint pip.yml
[ansible@master ansible_playbooks]$ ansible-playbook pip.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Install python package] ******************************************************************************************
changed: [node1] => {"changed": true, "cmd": ["/bin/pip3", "install", "flask"], "name": ["flask"], "requirements": null, "state": "present", "stderr": "WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.\n", "stderr_lines": ["WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead."], "stdout": "Collecting flask\n  Downloading http://mirrors.tencentyun.com/pypi/packages/cd/77/59df23681f4fd19b7cbbb5e92484d46ad587554f5d490f33ef907e456132/Flask-2.0.3-py3-none-any.whl (95kB)\nCollecting click>=7.1.2 (from flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/4a/a8/0b2ced25639fb20cc1c9784de90a8c25f9504a7f18cd8b5397bd61696d7d/click-8.0.4-py3-none-any.whl (97kB)\nCollecting itsdangerous>=2.0 (from flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/9c/96/26f935afba9cd6140216da5add223a0c465b99d0f112b68a4ca426441019/itsdangerous-2.0.1-py3-none-any.whl\nCollecting Jinja2>=3.0 (from flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/20/9a/e5d9ec41927401e41aea8af6d16e78b5e612bca4699d417f646a9610a076/Jinja2-3.0.3-py3-none-any.whl (133kB)\nCollecting Werkzeug>=2.0 (from flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/f4/f3/22afbdb20cc4654b10c98043414a14057cd27fdba9d4ae61cea596000ba2/Werkzeug-2.0.3-py3-none-any.whl (289kB)\nCollecting importlib-metadata; python_version < \"3.8\" (from click>=7.1.2->flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/a0/a1/b153a0a4caf7a7e3f15c2cd56c7702e2cf3d89b1b359d1f1c5e59d68f4ce/importlib_metadata-4.8.3-py3-none-any.whl\nCollecting MarkupSafe>=2.0 (from Jinja2>=3.0->flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/fc/d6/57f9a97e56447a1e340f8574836d3b636e2c14de304943836bd645fa9c7e/MarkupSafe-2.0.1-cp36-cp36m-manylinux1_x86_64.whl\nCollecting dataclasses; python_version < \"3.7\" (from Werkzeug>=2.0->flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/fe/ca/75fac5856ab5cfa51bbbcefa250182e50441074fdc3f803f6e76451fab43/dataclasses-0.8-py3-none-any.whl\nCollecting zipp>=0.5 (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/bd/df/d4a4974a3e3957fd1c1fa3082366d7fff6e428ddb55f074bf64876f8e8ad/zipp-3.6.0-py3-none-any.whl\nCollecting typing-extensions>=3.6.4; python_version < \"3.8\" (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask)\n  Downloading http://mirrors.tencentyun.com/pypi/packages/45/6b/44f7f8f1e110027cf88956b59f2fad776cca7e1704396d043f89effd3a0e/typing_extensions-4.1.1-py3-none-any.whl\nInstalling collected packages: zipp, typing-extensions, importlib-metadata, click, itsdangerous, MarkupSafe, Jinja2, dataclasses, Werkzeug, flask\nSuccessfully installed Jinja2-3.0.3 MarkupSafe-2.0.1 Werkzeug-2.0.3 click-8.0.4 dataclasses-0.8 flask-2.0.3 importlib-metadata-4.8.3 itsdangerous-2.0.1 typing-extensions-4.1.1 zipp-3.6.0\n", "stdout_lines": ["Collecting flask", "  Downloading http://mirrors.tencentyun.com/pypi/packages/cd/77/59df23681f4fd19b7cbbb5e92484d46ad587554f5d490f33ef907e456132/Flask-2.0.3-py3-none-any.whl (95kB)", "Collecting click>=7.1.2 (from flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/4a/a8/0b2ced25639fb20cc1c9784de90a8c25f9504a7f18cd8b5397bd61696d7d/click-8.0.4-py3-none-any.whl (97kB)", "Collecting itsdangerous>=2.0 (from flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/9c/96/26f935afba9cd6140216da5add223a0c465b99d0f112b68a4ca426441019/itsdangerous-2.0.1-py3-none-any.whl", "Collecting Jinja2>=3.0 (from flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/20/9a/e5d9ec41927401e41aea8af6d16e78b5e612bca4699d417f646a9610a076/Jinja2-3.0.3-py3-none-any.whl (133kB)", "Collecting Werkzeug>=2.0 (from flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/f4/f3/22afbdb20cc4654b10c98043414a14057cd27fdba9d4ae61cea596000ba2/Werkzeug-2.0.3-py3-none-any.whl (289kB)", "Collecting importlib-metadata; python_version < \"3.8\" (from click>=7.1.2->flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/a0/a1/b153a0a4caf7a7e3f15c2cd56c7702e2cf3d89b1b359d1f1c5e59d68f4ce/importlib_metadata-4.8.3-py3-none-any.whl", "Collecting MarkupSafe>=2.0 (from Jinja2>=3.0->flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/fc/d6/57f9a97e56447a1e340f8574836d3b636e2c14de304943836bd645fa9c7e/MarkupSafe-2.0.1-cp36-cp36m-manylinux1_x86_64.whl", "Collecting dataclasses; python_version < \"3.7\" (from Werkzeug>=2.0->flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/fe/ca/75fac5856ab5cfa51bbbcefa250182e50441074fdc3f803f6e76451fab43/dataclasses-0.8-py3-none-any.whl", "Collecting zipp>=0.5 (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/bd/df/d4a4974a3e3957fd1c1fa3082366d7fff6e428ddb55f074bf64876f8e8ad/zipp-3.6.0-py3-none-any.whl", "Collecting typing-extensions>=3.6.4; python_version < \"3.8\" (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask)", "  Downloading http://mirrors.tencentyun.com/pypi/packages/45/6b/44f7f8f1e110027cf88956b59f2fad776cca7e1704396d043f89effd3a0e/typing_extensions-4.1.1-py3-none-any.whl", "Installing collected packages: zipp, typing-extensions, importlib-metadata, click, itsdangerous, MarkupSafe, Jinja2, dataclasses, Werkzeug, flask", "Successfully installed Jinja2-3.0.3 MarkupSafe-2.0.1 Werkzeug-2.0.3 click-8.0.4 dataclasses-0.8 flask-2.0.3 importlib-metadata-4.8.3 itsdangerous-2.0.1 typing-extensions-4.1.1 zipp-3.6.0"], "version": null, "virtualenv": null}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，在节点上面查看python包的情况：
```sh
[root@node1 ~]# pip3 list
click==8.0.4
dataclasses==0.8
Flask==2.0.3
importlib-metadata==4.8.3
itsdangerous==2.0.1
Jinja2==3.0.3
MarkupSafe==2.0.1
pip==9.0.3
setuptools==39.2.0
typing-extensions==4.1.1
Werkzeug==2.0.3
zipp==3.6.0
[root@node1 ~]#
```

可以看到Flask包及其依赖包已经安装成功了。


### 4.2 安装多个包

```yaml
- hosts: node1
  tasks:
    - name: Install multi python packages with version specifiers
      ansible.builtin.pip:
        name: 
          - flask==2.0.0
          - bottle==0.11.1
        executable: pip3
      become: yes
```

执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-playbook pip.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Install multi python packages with version specifiers] ***********************************************************
changed: [node1] => {"changed": true, "cmd": ["/bin/pip3", "install", "flask==2.0.0", "bottle==0.11.1"], "name": ["flask==2.0.0", "bottle==0.11.1"], "requirements": null, "state": "present", "stderr": "WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.\n", "stderr_lines": ["WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead."], "stdout": "Collecting flask==2.0.0\n  Downloading http://mirrors.tencentyun.com/pypi/packages/bf/73/9180d22a40da68382e9cb6edb66a74bf09cb72ac825c130dce9c5a44198d/Flask-2.0.0-py3-none-any.whl (93kB)\nCollecting bottle==0.11.1\n  Downloading http://mirrors.tencentyun.com/pypi/packages/22/2d/9c655556710de1eefd4cdd9307320a232e66b347bd445ec241aedf97fbd1/bottle-0.11.1.tar.gz (60kB)\nRequirement already satisfied: Jinja2>=3.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)\nRequirement already satisfied: click>=7.1.2 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)\nRequirement already satisfied: Werkzeug>=2.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)\nRequirement already satisfied: itsdangerous>=2.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)\nRequirement already satisfied: MarkupSafe>=2.0 in /usr/local/lib64/python3.6/site-packages (from Jinja2>=3.0->flask==2.0.0)\nRequirement already satisfied: importlib-metadata; python_version < \"3.8\" in /usr/local/lib/python3.6/site-packages (from click>=7.1.2->flask==2.0.0)\nRequirement already satisfied: dataclasses; python_version < \"3.7\" in /usr/local/lib/python3.6/site-packages (from Werkzeug>=2.0->flask==2.0.0)\nRequirement already satisfied: typing-extensions>=3.6.4; python_version < \"3.8\" in /usr/local/lib/python3.6/site-packages (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask==2.0.0)\nRequirement already satisfied: zipp>=0.5 in /usr/local/lib/python3.6/site-packages (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask==2.0.0)\nInstalling collected packages: flask, bottle\n  Found existing installation: Flask 2.0.3\n    Uninstalling Flask-2.0.3:\n      Successfully uninstalled Flask-2.0.3\n  Running setup.py install for bottle: started\n    Running setup.py install for bottle: finished with status 'done'\nSuccessfully installed bottle-0.11.1 flask-2.0.0\n", "stdout_lines": ["Collecting flask==2.0.0", "  Downloading http://mirrors.tencentyun.com/pypi/packages/bf/73/9180d22a40da68382e9cb6edb66a74bf09cb72ac825c130dce9c5a44198d/Flask-2.0.0-py3-none-any.whl (93kB)", "Collecting bottle==0.11.1", "  Downloading http://mirrors.tencentyun.com/pypi/packages/22/2d/9c655556710de1eefd4cdd9307320a232e66b347bd445ec241aedf97fbd1/bottle-0.11.1.tar.gz (60kB)", "Requirement already satisfied: Jinja2>=3.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)", "Requirement already satisfied: click>=7.1.2 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)", "Requirement already satisfied: Werkzeug>=2.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)", "Requirement already satisfied: itsdangerous>=2.0 in /usr/local/lib/python3.6/site-packages (from flask==2.0.0)", "Requirement already satisfied: MarkupSafe>=2.0 in /usr/local/lib64/python3.6/site-packages (from Jinja2>=3.0->flask==2.0.0)", "Requirement already satisfied: importlib-metadata; python_version < \"3.8\" in /usr/local/lib/python3.6/site-packages (from click>=7.1.2->flask==2.0.0)", "Requirement already satisfied: dataclasses; python_version < \"3.7\" in /usr/local/lib/python3.6/site-packages (from Werkzeug>=2.0->flask==2.0.0)", "Requirement already satisfied: typing-extensions>=3.6.4; python_version < \"3.8\" in /usr/local/lib/python3.6/site-packages (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask==2.0.0)", "Requirement already satisfied: zipp>=0.5 in /usr/local/lib/python3.6/site-packages (from importlib-metadata; python_version < \"3.8\"->click>=7.1.2->flask==2.0.0)", "Installing collected packages: flask, bottle", "  Found existing installation: Flask 2.0.3", "    Uninstalling Flask-2.0.3:", "      Successfully uninstalled Flask-2.0.3", "  Running setup.py install for bottle: started", "    Running setup.py install for bottle: finished with status 'done'", "Successfully installed bottle-0.11.1 flask-2.0.0"], "version": null, "virtualenv": null}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```
可以看到安装成功。

此时，在节点上查看包的情况：
```sh
[root@node1 ~]# pip3 list
bottle==0.11.1
click==8.0.4
dataclasses==0.8
distlib==0.3.6
filelock==3.4.1
Flask==2.0.0
importlib-metadata==4.8.3
importlib-resources==5.4.0
itsdangerous==2.0.1
Jinja2==3.0.3
MarkupSafe==2.0.1
pip==9.0.3
platformdirs==2.4.0
setuptools==39.2.0
typing-extensions==4.1.1
virtualenv==20.17.1
Werkzeug==2.0.3
zipp==3.6.0
[root@node1 ~]#
```

可以看到，虽然之前安装了高版本的Flask，此处安装低版本Flask时会自动卸载高版本的Flask==2.0.3。

### 4.3 在虚拟环境下安装包

```yaml
- hosts: node1
  tasks:
    # Install (Bottle) into the specified (virtualenv), inheriting none of the globally installed modules
    - name: Install package in virtualenv
      ansible.builtin.pip:
        name:
          - bottle==0.11.1
        virtualenv: /my_app/venv
      become: yes
```

运行剧本会提示找不到可执行文件virtualenv：
```sh
[ansible@master ansible_playbooks]$ ansible-lint pip.yml
[ansible@master ansible_playbooks]$ ansible-playbook pip.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Install package in virtualenv] ***********************************************************************************
fatal: [node1]: FAILED! => {"changed": false, "msg": "Failed to find required executable virtualenv in paths: /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

指定一下virtualenv可执行程序路径：
```yaml
- hosts: node1
  tasks:
    # Install (Bottle) into the specified (virtualenv), inheriting none of the globally installed modules
    - name: Install package in virtualenv
      ansible.builtin.pip:
        name:
          - bottle==0.11.1
        virtualenv_command: /usr/local/bin/virtualenv
        virtualenv: /my_app/venv
      become: yes
```

再次执行剧本：
```sh
[ansible@master ansible_playbooks]$ ansible-playbook pip.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node1]

TASK [Install package in virtualenv] ***********************************************************************************
changed: [node1] => {"changed": true, "cmd": ["/my_app/venv/bin/pip", "install", "bottle==0.11.1"], "name": ["bottle==0.11.1"], "requirements": null, "state": "present", "stderr": "", "stderr_lines": [], "stdout": "created virtual environment CPython3.6.8.final.0-64 in 607ms\n  creator CPython3Posix(dest=/my_app/venv, clear=False, no_vcs_ignore=False, global=False)\n  seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/root/.local/share/virtualenv)\n    added seed packages: pip==21.3.1, setuptools==59.6.0, wheel==0.37.1\n  activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator\nLooking in indexes: http://mirrors.tencentyun.com/pypi/simple\nCollecting bottle==0.11.1\n  Downloading http://mirrors.tencentyun.com/pypi/packages/22/2d/9c655556710de1eefd4cdd9307320a232e66b347bd445ec241aedf97fbd1/bottle-0.11.1.tar.gz (60 kB)\n  Preparing metadata (setup.py): started\n  Preparing metadata (setup.py): finished with status 'done'\nBuilding wheels for collected packages: bottle\n  Building wheel for bottle (setup.py): started\n  Building wheel for bottle (setup.py): finished with status 'done'\n  Created wheel for bottle: filename=bottle-0.11.1-py3-none-any.whl size=76243 sha256=6e2381242a7438d1c50c49ce757e762491a9fe2036e1d4e52981a3d7e4b17723\n  Stored in directory: /root/.cache/pip/wheels/ac/37/50/4c8f13aed6beb3310781cf78ed031489e5b72a87226e6cc610\nSuccessfully built bottle\nInstalling collected packages: bottle\nSuccessfully installed bottle-0.11.1\n", "stdout_lines": ["created virtual environment CPython3.6.8.final.0-64 in 607ms", "  creator CPython3Posix(dest=/my_app/venv, clear=False, no_vcs_ignore=False, global=False)", "  seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/root/.local/share/virtualenv)", "    added seed packages: pip==21.3.1, setuptools==59.6.0, wheel==0.37.1", "  activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator", "Looking in indexes: http://mirrors.tencentyun.com/pypi/simple", "Collecting bottle==0.11.1", "  Downloading http://mirrors.tencentyun.com/pypi/packages/22/2d/9c655556710de1eefd4cdd9307320a232e66b347bd445ec241aedf97fbd1/bottle-0.11.1.tar.gz (60 kB)", "  Preparing metadata (setup.py): started", "  Preparing metadata (setup.py): finished with status 'done'", "Building wheels for collected packages: bottle", "  Building wheel for bottle (setup.py): started", "  Building wheel for bottle (setup.py): finished with status 'done'", "  Created wheel for bottle: filename=bottle-0.11.1-py3-none-any.whl size=76243 sha256=6e2381242a7438d1c50c49ce757e762491a9fe2036e1d4e52981a3d7e4b17723", "  Stored in directory: /root/.cache/pip/wheels/ac/37/50/4c8f13aed6beb3310781cf78ed031489e5b72a87226e6cc610", "Successfully built bottle", "Installing collected packages: bottle", "Successfully installed bottle-0.11.1"], "version": null, "virtualenv": "/my_app/venv"}

PLAY RECAP *************************************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

可以看到，执行成功了。

在节点上检查一下：
```sh
[root@node1 ~]# cd /my_app/venv/
[root@node1 venv]# source bin/activate
(venv) [root@node1 venv]# pip list
bottle==0.11.1
pip==21.3.1
setuptools==59.6.0
wheel==0.37.1
(venv) [root@node1 venv]# python -V
Python 3.6.8
```

可以看到，能够正常启动虚拟环境，并且通过pip list查看到bottle包已经安装成功了。