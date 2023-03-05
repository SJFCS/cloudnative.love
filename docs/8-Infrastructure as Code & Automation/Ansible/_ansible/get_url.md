# get_url下载文件到远程节点模块
[[toc]]

## 1. 概要

- 本模块是内置模块。
- 从 HTTP, HTTPS, or FTP等服务上面下载文件到远程主机，远程主机必须要能够直接访问对应的远程资源。
- 如果远程主机设置了`<protocol>_proxy`环境变量，默认将请求发送到这些代理。你可以通过设置环境变量，或者使用`use_proxy`选项改变这种行为。
- HTTP重定向可以将`HTTP`定向到`HTTPS`,你应明确你的代理环境和协议配置正确。
- 从Ansible 2.4开始，运行时使用`--check`选项时，Ansible将向对应的URL发送一个HEAD请求，但并不下载整个文件，并且不会校验哈希值，并且会报告不正确的状态信息。
- 官方文档 [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)

## 2. 参数




| 参数                       | 描述                                                                                                            |
|:---------------------------|-----------------------------------------------------------------------------------------------------------------|
| `attributes`  string       | 下载后的文件的文件属性，属性顺序应同`lsattr`展示的一样，默认使用`=`操作，如果要使用`+`或`-`操作则需要在字符串中说明 |
| `backup`  boolean          | 是否备份文件，默认`no`                                                                                           |
| `checksum`  string         | 校验文件，文件下载完成后校验其摘要的校验码是否与给定的相同                                                       |
| `client_cert`  path        | PEM格式的证书文件路径                                                                                           |
| `client_key` path          | PEM格式的私有key文件路径                                                                                        |
| `dest` path/required       | 下载的文件存放的绝对路径,如果是文件夹，文件夹必须存在                                                                                        |
| `force`  boolean           | 每次都下载并代理文件。通常只有要文件才设置为`yes`，默认`no`，即不强制下载                                          |
| `force_basic_auth` boolean | 强制发送认证头，默认`no`不发送                                                                                   |
| `group` string             | 下载文件的组属性，类似于`chown`操作                                                                              |
| `headers`  dictionary      | 添加自定义header头部到请求中                                                                                    |
| `http_agent` string        | 标识以识别AS，通常出现在Web服务器日志中。默认值`ansible-httpget`                                                  |
| `mode`  raw                | 文件系统的权限模式                                                                                              |
| `owner` string             | 文件的拥有者                                                                                                    |
| se*                        | selevel、serole、setype、seuser配置略，请参考官方文档                                                               |
| `timeout` integer          | URL请求的超时秒数，默认10秒                                                                                      |
| `tmp_dest` path            | 临时文件的绝对路径                                                                                              |
| `unredirected_headers`     | 不进行重定向的请求头名称的列表                                                                                  |
| `unsafe_writes` boolean    | 不安全写，默认`no`                                                                                               |
| `url` string/required      | 请求的URL，`HTTP, HTTPS, or FTP URL in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path`        |
| `url_password`  string     | 认证时使用的用户密码                                                                                            |
| `url_username` string      | 认证时使用的用户名                                                                                              |
| `use_proxy` boolean        | 使用代理，默认`yes`                                                                                              |
| `validate_certs` boolean   | 是否验证SSL证书，默认`yes`，自签名证书时可以设置为`no`不验证                                                      |

## 3. 官方示例

```yaml
- name: Download foo.conf
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    mode: '0440'

- name: Download file and force basic auth
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    force_basic_auth: yes

- name: Download file with custom HTTP headers
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    headers:
      key1: one
      key2: two

- name: Download file with check (sha256)
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: sha256:b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c

- name: Download file with check (md5)
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: md5:66dffb5228a211e61d6d7ef4a86f5758

- name: Download file with checksum url (sha256)
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: sha256:http://example.com/path/sha256sum.txt

- name: Download file from a file path
  ansible.builtin.get_url:
    url: file:///tmp/afile.txt
    dest: /tmp/afilecopy.txt

- name: < Fetch file that requires authentication.
        username/password only available since 2.8, in older versions you need to use url_username/url_password
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    username: bar
    password: '{{ mysecret }}'

```


## 4. 剧本的使用

我们参考官方示例，做以下任务：
- 尝试下载[Getting started with Redis](https://redis.io/docs/getting-started/)页面。
- 参考 [https://github.com/redis/redis-hashes](https://github.com/redis/redis-hashes) 下载redis-6.2.7.tar.gz源码，并进行哈希检验。

```sh
hash redis-6.2.7.tar.gz sha256 b7a79cc3b46d3c6eb52fa37dde34a4a60824079ebdfb3abfbbfa035947c55319 http://download.redis.io/releases/redis-6.2.7.tar.gz
```

编写剧本文件`get_url.yml`:

```yaml
- hosts: node2
  tasks:
    - name: Download redis html
      ansible.builtin.get_url:
        url: https://redis.io/docs/getting-started/
        dest: /tmp/redis.index.html
        # 如果mode设置为`0440`后，多次运行时，后面再次下载时，
        # 会提示文件无写权限 is not writable.
        mode: '0640'

    - name: Download redis source files
      ansible.builtin.get_url:
        url: http://download.redis.io/releases/redis-6.2.7.tar.gz
        # /download 目录必须已经创建成功，否则会提示目录不存在
        dest: /download/redis-6.2.7.tar.gz
        checksum: sha256:b7a79cc3b46d3c6eb52fa37dde34a4a60824079ebdfb3abfbbfa035947c55319
      become: yes
```

语法检查并运行：
```sh
# 语法检查
[ansible@master ansible_playbooks]$ ansible-lint get_url.yml

# 执行剧本
[ansible@master ansible_playbooks]$ ansible-playbook get_url.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node2] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node2]

TASK [Download redis html] *********************************************************************************************
changed: [node2] => {"changed": true, "checksum_dest": null, "checksum_src": "001e45ba129d32e3da6e656708dded4532bd72da", "dest": "/tmp/redis.index.html", "elapsed": 2, "gid": 1005, "group": "ansible", "md5sum": "0ef6c9bf4caa4037fea667f813126c5a", "mode": "0640", "msg": "OK (75662 bytes)", "owner": "ansible", "size": 75662, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1664286629.3-21505-247271446442608/tmpZuMJHC", "state": "file", "status_code": 200, "uid": 1005, "url": "https://redis.io/docs/getting-started/"}

TASK [Download redis source files] *************************************************************************************
changed: [node2] => {"changed": true, "checksum_dest": null, "checksum_src": "b01ef3f117c9815dea41bf2609e489a03c3a5ab1", "dest": "/download/redis-6.2.7.tar.gz", "elapsed": 0, "gid": 0, "group": "root", "md5sum": "a468e58da60799213735eccb59e7efb4", "mode": "0644", "msg": "OK (2487287 bytes)", "owner": "root", "size": 2487287, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1664286632.22-21528-220461665087971/tmptr2tXT", "state": "file", "status_code": 200, "uid": 0, "url": "http://download.redis.io/releases/redis-6.2.7.tar.gz"}

PLAY RECAP *************************************************************************************************************
node2                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```

此时，可以在节点上面查看刚才下载的文件：
```sh
[root@node2 ~]# ll /tmp/redis.index.html
-rw-r----- 1 ansible ansible 75662 Sep 27 21:50 /tmp/redis.index.html
[root@node2 ~]# ll /download/redis-6.2.7.tar.gz
-rw-r--r-- 1 root root 2487287 Sep 27 21:50 /download/redis-6.2.7.tar.gz
```

当我们尝试在任务`Download redis source files`将`checksum`参数最后的数字9改成其他的，如`0`,然后再次运行剧本，此时则会提示校验异常：

```sh
[ansible@master ansible_playbooks]$ ansible-playbook get_url.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node2] ***********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [node2]

TASK [Download redis html] *********************************************************************************************
changed: [node2] => {"changed": true, "checksum_dest": "001e45ba129d32e3da6e656708dded4532bd72da", "checksum_src": "8768d3fcf072943b7bedbb03807dca43a74c0be9", "dest": "/tmp/redis.index.html", "elapsed": 1, "gid": 1005, "group": "ansible", "md5sum": "58598f1fda243de88ddca17e93ca2f90", "mode": "0640", "msg": "OK (unknown bytes)", "owner": "ansible", "size": 75797, "src": "/home/ansible/.ansible/tmp/ansible-tmp-1664287206.98-23349-51302891949558/tmpAcoL2t", "state": "file", "status_code": 200, "uid": 1005, "url": "https://redis.io/docs/getting-started/"}

TASK [Download redis source files] *************************************************************************************
fatal: [node2]: FAILED! => {"changed": false, "checksum_dest": "b01ef3f117c9815dea41bf2609e489a03c3a5ab1", "checksum_src": "b01ef3f117c9815dea41bf2609e489a03c3a5ab1", "dest": "/download/redis-6.2.7.tar.gz", "elapsed": 0, "msg": "The checksum for /download/redis-6.2.7.tar.gz did not match b7a79cc3b46d3c6eb52fa37dde34a4a60824079ebdfb3abfbbfa035947c55310; it was b7a79cc3b46d3c6eb52fa37dde34a4a60824079ebdfb3abfbbfa035947c55319.", "src": "/home/ansible/.ansible/tmp/ansible-tmp-1664287209.5-23363-101377016959347/tmpHshGv4", "url": "http://download.redis.io/releases/redis-6.2.7.tar.gz"}

PLAY RECAP *************************************************************************************************************
node2                      : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[ansible@master ansible_playbooks]$
```
也就是说，通过`checksum`的确是校验了需要下载的文件的散列值。

后面找机会再测试需要用户认证的文件下载。
