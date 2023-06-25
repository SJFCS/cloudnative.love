---
title: Jekins高级角色控制

categories:
  - CI/CD
series: 
  - 
lastmod: '2021-02-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---
Role Strategy Plugin插件可以对构建的项目进行授权管理，让不同的用户管理不同的项目，将不同环境的权限进行区分。该插件可以很灵活的根据需求来进行划分权限，包括正则匹配等


## 安装插件

插件名称：
Role-based Authorization Strategy

插件介绍：
Enables user authorization using a Role-Based strategy. Roles can be defined globally or for particular jobs or nodes selected by regular expressions.

![image-20210922184043653](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd3/2021.09.26-21:39:23-image-20210922184043653.png)

**在全局安全配置中使用此插件来进行认证鉴权**

 点击系统管理，点击Configure Global Security 
 在该页面中选择授权策略为：Role-Based Strategy

![image-20210922184113321](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd3/2021.09.26-21:40:15-2021.09.26-21-39-44-image-20210922184113321.png)

## 实现需求：

> 1、开发环境需要一个通用用户，需要对开发环境的所有项目拥有只读的权限 
>  2、测试环境需要一个通用用户，需要对测试环境的所有项目拥有只读的权限 
>
> **系统用户：** 
>  1、dev：dev环境所需用户 
>  2、test：test环境所需用户
>
> **jenkins 项目命名规则介绍：** 
>  开发环境：所有项目的名称均以dev-开头，如：dev-cg-api 
>  测试环境：所有项目的名称均以test-开头，如：test-cg-api

## 创建用户

![image-20210922185808815](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd3/2021.09.26-21:40:35-image-20210922185808815.png)

## 配置Manage and Assign Roles策略
### 配置Manage Roles

![image-20210922185512480](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd3/2021.09.26-21:50:49-image-20210922185512480.png)

在Manage Roles中有两种角色
Global roles用来分配全局策略，而 Project roles根据项目环境来分配项目权限

        Global roles
        Project roles

下面来配置Global roles中的三个角色：

![image-20210926214740862](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:47:42-image-20210926214740862.png)

> ```
> admin：超级管理员，它拥有所有的全局权限
> dev_roles：dev环境的用户，它只可以看到全局的Overall面板
> test_roles：test环境的用户，它只可以看到全局的Overall面板
> ```

> 先说下，这里为什么要添加dev_roles和test_roles的Overall的read权限，如果不添加的话，这些普通用户登录到jenkins则会提示：用户没有Overall/read权限

### 配置 Project roles 

![image-20210926214911299](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:49:13-image-20210926214911299.png)

分别为：dev_roles和test_roles

> ~~~
> dev_roles：匹配所有dev-.*的项目，并分配view、read及workspace等权限
> test_roles：匹配所有test-.*的项目，并分配view、read及workspace等权限
> ~~~

### 配置Assign Roles
上面的roles和权限已经配置好了，那怎么让他生效呢？或者说让谁拥有这些roles的权限呢？
下面我们来将定义好的规则分配给具体的用户，前面我们提到了系统用户，那么我们现在有两个用户：dev and test

先来配置Global roles
![image-20210926215001053](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:50:02-image-20210926215001053.png)

之前我们在dev_roles和test_roles中定义了overall/read权限，现在将用户和roles关联起来，这样dev和test用户就拥有了改权限

### Item roles

![image-20210926215031802](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:50:33-image-20210926215031802.png)

之前我们在Project roles中定义了dev_roles和test_roles规则，分别对应dev-.*和test-.*的项目及权限，在这里我们将用户和roles关联起来，这样对应的用户就拥有了对应roles的权限。

好，到这里配置已经完成，我们接下来进行验证

## 验证

### admin

![image-20210926215139208](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:52:24-image-20210926215139208.png)

### dev

![image-20210926215200972](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:52:22-image-20210926215200972.png)

### test

![image-20210926215219768](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%E8%A7%92%E8%89%B2%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6/2021.09.26-21:52:21-image-20210926215219768.png)

