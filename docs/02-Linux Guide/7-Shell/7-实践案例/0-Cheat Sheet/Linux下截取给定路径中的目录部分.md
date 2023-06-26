
在日常运维中，有时会要求截取一个路径中的目录部分。
截取目录的方法，有以下两种：
1）dirname命令（最常用的方法）：用于取给定路径的目录部分。很少直接在shell命令行中使用，一般把它用在shell脚本中，用于取得脚本文件所在目录，然后将当前目录切换过去。
其实就是取所给路径的倒数第二级及其之前的路径部分，如下：
```bash
[root@jenkins-server Shell]# dirname main/protected/xqsjmob/themes/tpl2/common/page_statistics.tpl
main/protected/xqsjmob/themes/tpl2/common
[root@jenkins-server Shell]# dirname /usr/local/tomcat7/webapps/jenkins/scripts/Shell
/usr/local/tomcat7/webapps/jenkins/scripts
[root@qzt196 ~]# dirname /usr/bin/sort
/usr/bin
[root@qzt196 ~]# dirname stdio.h                    #获取的是当前目录路径
.
[root@qzt196 ~]# dirname /usr/bin
/usr
[root@qzt196 ~]# dirname /usr/bin/
/usr
```
还有一个"basename"命令，用于截取一个path中最后一个
```bash
[root@jenkins-server Shell]# dirname /usr/local/src/
/usr/local
[root@jenkins-server Shell]# basename /usr/local/src/
src
2）可以用${pathname%/*}截取掉pathname后面的文件部分。可以参考: https://www.cnblogs.com/kevingrace/p/8868262.html
下面比较下这两种方法的效果：即dirname取的是倒数第二级及其以上级的路径，而${pathname%/*}取的是"删除最后一个/符号后的路径部分"
```
```bash
[root@jenkins-server Shell]# pathname=/usr/bin/sort; echo $(dirname $pathname) ${pathname%/*}
/usr/bin /usr/bin
You have new mail in /var/spool/mail/root
[root@jenkins-server Shell]# pathname=/usr/bin/sort/; echo $(dirname $pathname) ${pathname%/*}
/usr/bin /usr/bin/sort
[root@jenkins-server Shell]# pathname=/usr/; echo $(dirname $pathname) ${pathname%/*}
/ /usr
[root@jenkins-server Shell]# pathname=/usr; echo $(dirname $pathname) ${pathname%/*}
/
````
除了使用dirname外，sed也可以实现这种功能，实例如下:
```bash
[root@master-node ~]# cat a.txt
/home/wang/test.txt
/web/www/test.js
/data/mongodb/smsb/smsb.txt
/tmp/abc/mysql.sock
[root@master-node ~]# sed -n 's:/[^/]*$::p' a.txt
/home/wang
/web/www
/data/mongodb/smsb
/tmp/abc
[root@master-node ~]# for i in `cat /root/a.txt`;do dirname $i;done
/home/wang
/web/www
/data/mongodb/smsb
/tmp/abc
```