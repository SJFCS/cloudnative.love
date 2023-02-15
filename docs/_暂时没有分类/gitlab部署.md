---
title: Gitlab部署案例

categories:
  - CI/CD
series: 
  - 
lastmod: '2021-04-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---

本文介绍gitlab的安装部署



## GitLab

GitLab是一个开源的用于仓库管理的项目，使用Git作为代码管理工具。 与GitHub类似，都是基于Git开发出来的作品，也是免费且开源的，任意提交你的代码，添加sshKey等，不同的是，GitLab是可以搭建在个人的服务器上的，所有数据库信息也都在自己的服务器上，所以它适合团队内部的协作开发。

## 安装GitLab

~~~
$ docker pull gitlab/gitlab-ce
~~~

~~~
$ docker run -d  -p 443:443 -p 80:80 -p 222:22 --name gitlab --restart always -v /home/gitlab/config:/etc/gitlab -v /home/gitlab/logs:/var/log/gitlab -v /home/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce
# -d：后台运行
# -p：将容器内部端口向外映射
# --name：命名容器名称
# -v：将容器内数据文件夹或者日志、配置等文件夹挂载到宿主机指定目录
~~~

## 修改配置文件

`docker exec -it ID /bin/bash`进入容器来打开配置文件：

~~~bash
vim /etc/gitlab/gitlab.rb
#修改external_url的地址：
external_url 'http://IP:9090'
#可选，修改unicorn端口gitlab默认8080端口
unicorn['port'] = 9090
~~~

![image-20210921201554604](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd/2021.09.26-21:25:58-image-20210921201554604.png)

执行 `gitlab-ctl reconfigure` 进行更新配置

![image-20210921201550572](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd/2021.09.26-21:26:07-image-20210921201550572.png)

执行 gitlab-ctl restart 重启服务

## 初始化密码

> b、执行 ：sudo gitlab-rails console production 命令 开始初始化密码
>
> c、在irb(main):001:0> 后面通过 u=User.where(id:1).first 来查找与切换账号（User.all 可以查看所有用户）
>
> d、通过u.password='12345678'设置密码为12345678(这里的密码看自己喜欢)：
>
> e、通过u.password_confirmation='12345678' 再次确认密码
>
> f、通过 u.save!进行保存（切记切记 后面的 !）
>
> h、回到gitlab ,可以通过 root/12345678 这一超级管理员账号登录了

~~~bash
root@7d5d588b626b:/opt/gitlab/bin#  gitlab-rails console -e production
--------------------------------------------------------------------------------
 Ruby:         ruby 2.7.4p191 (2021-07-07 revision a21a3b7d23) [x86_64-linux]
 GitLab:       14.3.0 (ceec8accb09) FOSS
 GitLab Shell: 13.21.0
 PostgreSQL:   12.7
--------------------------------------------------------------------------------

Loading production environment (Rails 6.1.3.2)
irb(main):001:0> 
irb(main):002:0> u=User.where(id:1).first 
=> #<User id:1 @root>
irb(main):003:0> User.all
=> #<ActiveRecord::Relation [#<User id:1 @root>, #<User id:2 @sjf>]>
irb(main):004:0> u.password='123456'
=> "123456"
irb(main):005:0> u.password_confirmation='123456' 
=> "123456"
irb(main):006:0>  u.save!
Enqueued ActionMailer::MailDeliveryJob (Job ID: ee6dfa71-6cd9-4b23-870d-4c9d4648e537) to Sidekiq(mailers) with arguments: "DeviseMailer", "password_change", "deliver_now", {:args=>[#<GlobalID:0x00007f1cc615a088 @uri=#<URI::GID gid://gitlab/User/1>>]}
=> true
irb(main):007:0> exit
~~~

## 新建项目

现在就可以用此用户名密码来登陆了

![image-20210926212925926](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/gitlab%E9%83%A8%E7%BD%B2/2021.09.26-21:29:27-image-20210926212925926.png)
