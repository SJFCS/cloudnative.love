---
title: 配置阿里云CLI获取阿里云镜像仓库内镜像tag

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

本文介绍通过阿里云CLI获取阿里云镜像仓库内镜像tag



## 配置阿里云CLI

官方文档： https://help.aliyun.com/document_detail/121541.html 

Linux终端安装包下载地址如下：                         					                        

- [官网](https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz)：您可以通过此链接直接下载最新版本的阿里云CLI。                           
- [GitHub](https://github.com/aliyun/aliyun-cli/releases)：在GitHub上下载您所需版本的阿里云CLI。                           

假设已经下载aliyun-cli-linux-3.0.16-amd64.tgz安装包至$HOME/aliyun目录中。                     

解压文件，获取名为`aliyun`的可执行文件。

1. 执行如下命令，切换当前目录至$HOME/aliyun目录。

   ```
   cd  $HOME/aliyun
   ```

2. 执行如下命令，解压aliyun-cli-linux-3.0.16-amd64.tgz文件到$HOME/aliyun目录下。

```
sudo cp aliyun /usr/local/bin
```

## 配置阿里云CLI用于获取镜像仓库列表 

![image-20210921200015114](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/cicd/2021.09.26-21:06:15-image-20210921200015114.png)

**截取tag，用于jekins发版**

~~~
aliyun cr GetRepoTags --RepoNamespace citools  --RepoName docker |jq ".data.tags[].tag" -r
~~~

![image-20210926210659466](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E9%98%BF%E9%87%8C%E4%BA%91%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93api/2021.09.26-21:07:01-image-20210926210659466.png)

