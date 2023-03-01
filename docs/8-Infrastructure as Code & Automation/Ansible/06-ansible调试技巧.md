---
title: 调试技巧
sidebar_position: 6
---



## 单测某个主机

~~~
ansible-playbook nginx_php。yml --limit=“172.16.1.7” -i hosts
~~~

## 常用调试参数

~~~
-f			#指定并发数，默认5
-C			#模拟测试，不会真正执行
-D			#显示这些文件的差异。常与-C一起使用
--syntax	#语法检查
~~~

## 部分执行

单独执行某个task

```
# 使用命令 start-at-task 为你想要执行的task名称
 ansible-playbook -i hosts  center.yml --step --start-at-task='start jacoco'
```

使用-t指定tags执行, 多个tags使用逗号隔开即可

```bash
[root@manager ~]# ansible-playbook -t install_nfs-server f10.yml
```

使用--skip-tags排除不执行的tags

```bash
[root@manager ~]# ansible-playbook --skip-tags install_nfs-server f10.yml
```
