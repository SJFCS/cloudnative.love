# jenkins_job Jenkins任务管理模块

[[toc]]

## 1. 概述

- 本模块是通过使用Jenkins的REST API来管理jenkins任务作业的。
- 远程主机需要安装有`python-jenkins >= 0.4.12`依赖。
- 官方文档 [https://docs.ansible.com/ansible/latest/collections/community/general/jenkins_job_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/jenkins_job_module.html)

## 2. 参数


| 参数                      | 描述                                             |
|---------------------------|--------------------------------------------------|
| config      string        | xml配置文件，如果job作业不存在时，需要设置本参数   |
| enable     boolean        | 作业是否启用                                     |
| name      string required | 作业名称                                         |
| password   string         | 连接jenkins服务器认证使用的密码                  |
| state   string            | 指定作业是否创建或删除，可选值，present默认、absent |
| token  string             | API令牌                                          |
| url string                | Jenkins服务器的URL                               |
| user string               | 连接jenkins服务器的用户名                        |
| validate_certs boolean    | 是否验证SSL证书，默认yes                                 |

## 3. 官方示例

```yaml
- name: Create a jenkins job using basic authentication
  community.general.jenkins_job:
    config: "{{ lookup('file', 'templates/test.xml') }}"
    name: test
    password: admin
    url: http://localhost:8080
    user: admin

- name: Create a jenkins job using the token
  community.general.jenkins_job:
    config: "{{ lookup('template', 'templates/test.xml.j2') }}"
    name: test
    token: asdfasfasfasdfasdfadfasfasdfasdfc
    url: http://localhost:8080
    user: admin

- name: Delete a jenkins job using basic authentication
  community.general.jenkins_job:
    name: test
    password: admin
    state: absent
    url: http://localhost:8080
    user: admin

- name: Delete a jenkins job using the token
  community.general.jenkins_job:
    name: test
    token: asdfasfasfasdfasdfadfasfasdfasdfc
    state: absent
    url: http://localhost:8080
    user: admin

- name: Disable a jenkins job using basic authentication
  community.general.jenkins_job:
    name: test
    password: admin
    enabled: false
    url: http://localhost:8080
    user: admin

- name: Disable a jenkins job using the token
  community.general.jenkins_job:
    name: test
    token: asdfasfasfasdfasdfadfasfasdfasdfc
    enabled: false
    url: http://localhost:8080
    user: admin
```







