---
title: Kaniko 
---
Kaniko 是一个用于构建 Docker 镜像的工具，可以通过以下方式传递变量：

在 Dockerfile 中使用 ARG 命令定义变量，例如：
```
   ARG MY_VAR=default_value
```
在构建命令中使用 --build-arg 选项传递变量值，例如：
```
   kaniko build --build-arg MY_VAR=new_value -t my_image .
```
这将会将 MY_VAR 变量的值设置为 "new_value"，并将该值传递到构建过程中。