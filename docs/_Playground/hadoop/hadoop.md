下载
https://hadoop.apache.org/releases.html

```bash
wget --no-check-certificate  https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
```

添加hadoop用户并添加sudo权限

shell> useradd hadoop #添加用户hadoop 
shell> passwd hadoop #设置用户hadoop的密码 
shell> chmod u+w /etc/sudoers # 添加写权限
shell> vi /etc/sudoers

进入编辑模式，找到这一 行："root ALL=(ALL) ALL"在起下面添加"hadoop ALL=(ALL) ALL"，然后保存退出。

https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html

https://www.w3cschool.cn/hadoop/a86m1jyo.html