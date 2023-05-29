---
title: Tomcat中部署web项目的三种方式

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

Tomcat基本部署方式



## **一：部署解包的webapp目录**

将Web项目部署到Tomcat中的方法之一，是部署没有封装到WAR文件中的Web项目。要使用这一方法部署未打包的webapp目录，只要把我们的项目放到Tomcat的webapps目录下就可以了。如下图所示：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:18-2017060808382648.png)

这时，打开Tomcat服务器（确保服务器打开），就可以在浏览器访问http://localhost:8080/myweb/index.html

## **二：打包的war文件**

这种方式，只需把打包的war文件放在webapps目录下。如下图所示：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:21-2017060808382654.png)

当我们启动Tomcat的时候，Tomcat会自动解包war文件的内容到相同文件名的路径中，然后从解包的目录中读取项目文件。

然后在浏览器中就可以通过http://localhost:8080/myweb/index.html这个地址访问了。

## **三：Manager Web方式**

Manager Web源应用程序可以让我们通过Web管理自己的Web项目。当然，如果任何人都能管理其他人的项目，事情就变得有点棘手了，更别提安全防护了。所以，在我们想通过Manager Web管理自己的项目时，需要进行权限设置。

首先访问Apache Tomcat欢迎页。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:24-2017060808382656.png)

这个时候，我们点击图中圈中的部分，会提示我们输入用户名和密码。所以我们需要在conf/tomcat-users.xml文件里添加角色。tomcat- users.xml默认没有添加任何角色。因为我们要通过Manager  Web管理我们的项目，所以我们在里面添加manager-gui角色。如下（圈中的部分就是我们添加的角色，username随便填，password随便填，roles填上面的manager-gui）：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:27-2017060808382657.png)

配置好这个，重启服务器，就可以进入管理界面了。

进入Server Status页面可以查看服务器的状态，看到Tomcat的相关信息，包括Tomcat版本，JVM版本，JVM提供商等，如下图：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:29-2017060808382658.png)

进入Manager App页面就可以管理我们的项目了。页面如下图所示：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:32-2017060808382659.png)

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:36-2017060808382660.png)

Applications下显示了webapps目录下的项目目录：ROOT目录，doc目录，manager目录，这些都是Tomcat自带的。这个时候还没有我们自己的项目。现在我们开始部署自己的项目。在Deploy下，我们看到有两种方式：

1. WAR file to deploy

2. Deploy directory or WAR file located on server

**首先演示通过WAR file to deploy的方式。**

myweb.war是我们打包好的项目文件，点击"选择文件"可以在我们的主机上选择我们的项目文件。这个文件可以放在任何位置，如果放在webapps下，那么启动Tomcat的时候，Tomcat就直接解压了。如果放在其它位置，那么启动Tomcat的时候，Tomcat会把myweb.war文件复制到webapps目录下，再进行解压。选择好文件，点击Deploy发布就行了。这个时候，就可以在浏览器通过http://localhost:8080/myweb/index.html访问了。

这个时候，我们再看一下Manager App页面的变化，如下图中圈中的部分，多了我们刚才发布的myweb项目。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:39-2017060808382661.png)

**接下来是Deploy directory or WAR file located on server的方式。**

把myweb.war复制到webapps目录下，在WAR or Directory URL:后面填上 \myweb ,点击Deploy发布就行了。

## 四：修改域名映射

但这个时候，我们发现，在访问我们的项目内容时，必须加上我们的项目名字"myweb"，这样很不好。如果我们想直接以不用加项目名的http://localhost:8080/index.html这种形式访问，我们可以编辑conf/server.xml进行配置。

我们需要在Host内部增加Context的内容，增加之后如下：

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img.jbzj.com/file_images/article/201706/2021.09.01-20:12:41-2017060808382652.png)

这个时候，就可以通过这种不用加项目名的http://localhost:8080/index.html形式访问了。（其实这个时候还是可以通过http://localhost:8080/myweb/index.html这个地址访问的。）