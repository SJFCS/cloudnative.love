---
title: Tomcat安全加固

categories:
  - Tomcat
series: 
  - 
lastmod: '2021-07-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



## 更改管理端口和服务关闭命令：
我们进入配置文件：/etc/tomcat/server.xml
![在这里插入图片描述](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img-blog.csdnimg.cn/2021.09.01-20:22:41-20190428092241763.png)

默认是“tomcat的管理服务端口号为8005，且关闭端口的命令为SHUTDOWN。”
如果我们需要禁用8005端口，则我们可以把端口号改为-1，这样我们的管理口就被禁用了。

默认配置导致任何用户，都通过nc连接服务器的8005端口并使用命令“SHUTDOWN”来关闭tomcat服务

![image-20210901202333882](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Tomcat%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA/2021.09.01-20:23:35-image-20210901202333882.png)

所以需要修改server.xml文件中的Port所指对象来改变管理口的端口号和关闭服务指令，来避免恶意用户像本地管理口发送恶意指令。修改完成后重启tomcat服务

## 更改tomcat默认页面端口：
同样是打开tomcat的默认配置文件，路径为：/etc/tomcat/server.xml

```xml
<Connector port="8080" URIEncoding="UTF-8" protocol="HTTP/1.1"        
<!-- URIEncoding="UTF-8"这个配置在这里默认是没有的，这里是我手动添加的，保证tomcat的编码是UTF-8 --!>
               connectionTimeout="20000"
               redirectPort="8443" />
```

这段配置文件中，port的参数是指该默认页面的端口号为8080，其后的protocol是指使用的协议默认为HTTP/1.1，而connectionTimeout参数是指的超时时间为20000，而redirectPort的参数是指通过ssl加密后的页面使用端口为8443端口。


## 禁用管理端：
对于tomcat的web管理端属于高危安全隐患，一旦被攻破，黑客通过上传webshell的方式取得服务器的控制权是让人很难受的一件事情。我们需要删除tomcat安装目录下的conf/tomcat-user.xml或者删除webapps下默认的目录和文件。
通过检索我们发现了以下两处位置：

```
/var/lib/tomcat/webapps
/usr/share/tomcat/webapps
```

我们需要删除webapps下的所有默认的文件和目录。

## 使用低权限用户运行tomcat
我们可以先使用lsof来查看当前tomcat所运行的进程的用户信息。

![在这里插入图片描述](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img-blog.csdnimg.cn/2021.09.01-20:26:43-20190428092440230.png)
只要确保tomcat不是以root用户（UID、GID为0)的用户运行即可。

## 文件列表访问控制（目录遍历）
首先我们进入配置文件，配置文件目录：/etc/tomcat/web.xml
我们找到如下配置参数：

![image-20210901202735346](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Tomcat%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA/2021.09.01-20:27:36-image-20210901202735346.png)

如果listings的值为false则为不列出目录文件，如果listsings的值为true，则表示存在目录遍历漏洞。该配置默认为false。

## 重定义错误页

对于一些常见的错误页面，我们可以在配置文件/etc/tomcat/web.xml中，重定向403、404以及500错误到指定页面。

默认错误页面：
![在这里插入图片描述](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img-blog.csdnimg.cn/2021.09.01-20:28:11-2019042809251192.png)

我们现在在web.xml配置文件中加入error-page参数。
![在这里插入图片描述](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img-blog.csdnimg.cn/2021.09.01-20:28:24-20190428092519488.png)


这里是我们tomcat默认的页面所在位置。/usr/share/tomcat/webapps/ROOT

## 去除其他用户对tomcat的启动权限
默认文件位置：/usr/share/tomcat/bin
Chmod 744 /usr/share/tomcat/bin