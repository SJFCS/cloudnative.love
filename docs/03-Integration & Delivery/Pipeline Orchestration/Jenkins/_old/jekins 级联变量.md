---
title: Jekins级联变量配置和Git Branch分支展示

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

本文介绍基础Groovy语法、 Jekins级联变量配置和jenkins gitlab拉取branch或者tag



## 级联变量

### 定义一个动态选择参数，使用Groovy返回参数

![image-20210925210919281](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/typora-user-images/2021.09.26-21:31:13-image-20210925210919281.png)

### 创建reactive参数

该参数可根据Referenced参数的值来改变，从而实现级联展示

此处用到的Groovy语句如下

~~~Groovy
if (TEST_ENV.equals('test1')) {
    return ['reactive_1','reactive_2']
}
else if (TEST_ENV.equals('test2')) {
    return ['reactive_3','reactive_4']
}
if (TEST_ENV.equals('test3')) {
    return ['reactive_5','reactive_6']
}
~~~

![image-20210925210958963](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicdddd/2021.09.26-21:34:33-image-20210925210958963.png)

### 流水线Building展示

![image-20210925211016577](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicdddd/2021.09.26-21:34:54-image-20210925211016577.png)

## 获取Git Branch列表

### 需要的插件：

Build With Parameters 
Git Parameter Plug-In

### 配置：

**参数化构建过程->git parameter** 

![image-20210926205813980](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%20%E5%A4%9A%E7%BA%A7%E5%88%97%E8%A1%A8/2021.09.26-21:36:58-image-20210926205813980.png)

**源码管理->Git** 

![image-20210926205845655](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%20%E5%A4%9A%E7%BA%A7%E5%88%97%E8%A1%A8/2021.09.26-21:37:06-image-20210926205845655.png)

### 流水线Building展示

**build with parameters，选择版本：** 

![image-20210926205909810](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/jekins%20%E5%A4%9A%E7%BA%A7%E5%88%97%E8%A1%A8/2021.09.26-21:37:25-image-20210926205909810.png)