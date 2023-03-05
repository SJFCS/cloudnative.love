# jenkins_job_info Jenkins任务信息模块

[[toc]]

## 1. 概述

- 本模块可以用于查询已经存在的Jenkins任务的信息。
- 本模块参数与`jenkins_job`模块几乎差不多。
- 官方文档[https://docs.ansible.com/ansible/latest/collections/community/general/jenkins_job_info_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/jenkins_job_info_module.html)
- 依赖`python-jenkins >= 0.4.12`。

## 2. 参数


| 参数                      | 描述                                             |
|---------------------------|--------------------------------------------------|
| color      string        | 仅获取指定状态颜色的作业信息   |
| glob       string        | 通配符匹配jenkins作业名称                                    |
| name      string  | 要获取的作业名称                                         |
| password   string         | 连接jenkins服务器认证使用的密码                  |
| token  string             | API令牌                                          |
| url string                | Jenkins服务器的URL                               |
| user string               | 连接jenkins服务器的用户名                        |
| validate_certs boolean    | 是否验证SSL证书，默认yes                                 |

## 3. 官方示例
```yaml
# Get all Jenkins jobs anonymously
- community.general.jenkins_job_info:
    user: admin
  register: my_jenkins_job_info

# Get all Jenkins jobs using basic auth
- community.general.jenkins_job_info:
    user: admin
    password: hunter2
  register: my_jenkins_job_info

# Get all Jenkins jobs using the token
- community.general.jenkins_job_info:
    user: admin
    token: abcdefghijklmnop
  register: my_jenkins_job_info

# Get info about a single job using basic auth
- community.general.jenkins_job_info:
    name: some-job-name
    user: admin
    password: hunter2
  register: my_jenkins_job_info

# Get info about a single job in a folder using basic auth
- community.general.jenkins_job_info:
    name: some-folder-name/some-job-name
    user: admin
    password: hunter2
  register: my_jenkins_job_info

# Get info about jobs matching a shell glob using basic auth
- community.general.jenkins_job_info:
    glob: some-job-*
    user: admin
    password: hunter2
  register: my_jenkins_job_info

# Get info about all failing jobs using basic auth
- community.general.jenkins_job_info:
    color: red
    user: admin
    password: hunter2
  register: my_jenkins_job_info

# Get info about passing jobs matching a shell glob using basic auth
- community.general.jenkins_job_info:
    name: some-job-*
    color: blue
    user: admin
    password: hunter2
  register: my_jenkins_job_info

- name: Get the info from custom URL with token and validate_certs=False
  community.general.jenkins_job_info:
    user: admin
    token: 126df5c60d66c66e3b75b11104a16a8a
    url: https://jenkins.example.com
    validate_certs: false
  register: my_jenkins_job_info
```

可以看到，示例中都将获取到的信息注册到`my_jenkins_job_info`变量中。