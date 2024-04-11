# 学会使用命令帮助  

[[toc]]

## 概述  


Linux命令行有非常多的命令，通过获取命令的帮忙信息，能够快速了解命令的具体含义和使用方法，通过使用命令行命令的帮助信息，可以减轻学习Linux的负担。获取帮助的途径有：

- 使用manual手册-man命令
- 使用info信息页-info命令
- 使用help帮助
- 程序自身的帮助文档
- 程序官方文档
- Google搜索



## man命令


man命令的实用性非常高，基本上所有的类Unix系统都支持，所以man命令是学习的重点。man命令帮助文档存放在/usr/share/man目录下，man工具的功能非常强大，几乎每个命令都有man手册。 



/usr/share/man目录结构如下:




### man命令常用参数


- 查看man手册页

  man [章节] keyword

- 列出所有帮助

  man -a keyword

- 搜索man手册

  man -k keyword

  查找vim相关的手册


![mankvim.png](/img/mankvim.png)


- 列出符合关键字的可用手册页

  man -f keyword
  
  查找man关键字可用的手册页
  
![manfman.png](/img/manfman.png)


- 打印man帮助文件的路径

  man -w [章节] keyword
  
  打印man帮助文档存放的路径
  

![manpath.png](/img/manpath.png)


### man帮忙文档分类


帮忙文档分类如下:

| 分类(章节)   |                    说明                      |
|:-----------:|----------------------------------------------|
|    1       |              可执行或Shell命令                 |
|    2       |              系统调用(内核提供的函数)            |
|    3       |              库调用(程序库中的函数)              |
|    4       |              设备文件及特殊文件的说明            |
|    5       |              配置文件                          |
|    6       |              游戏                           |
|    7       |              杂项(包括宏包和规范)            |
|    8       |       系统管理命令(通常只针对root用户)        |
|    9       |              内核相关的文件                   |


下面是引用man手册中关于小节的说明:

> 一个手册页面包含若干个小节。
>  
> 小节名称通常包括NAME,概述(SYNOPSIS),配置(CONFIGURATION),描述(DESCRIPTION),选项(OPTIONS),退出状态(EXIT STATUS),返回值(RETURN VALUE),错误(ERRORS),环境(ENVIRONMENT),文件(FILES),版本(VERSIONS),符合标准(CONFORMING TO),注(NOTES),缺陷(BUGS),示例(EXAMPLE),作者(AUTHORS),和其他帮忙参考(SEE ALSO).

## info命令


直接使用info keyword就可以查看某关键字的info信息页。

在命令行输入 ``info vim`` 则可以查看vim的info信息页。


![infovim.png](/img/infovim.png)


## help帮助


一般命令都会有 ``-h`` 参数，用于查看命令的help帮助信息

在命令行输入 ``vim -h`` 则可以查看vim的帮助信息。


![vimhelp.png](/img/vimhelp.png)

推荐使用man手册方式查看命令的使用帮助信息。

参考文献：

- [Linux帮助使用方法](https://blog.csdn.net/sxy2475/article/details/75676399)
