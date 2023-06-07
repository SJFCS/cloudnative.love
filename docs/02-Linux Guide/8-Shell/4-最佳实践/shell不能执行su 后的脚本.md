问题：在shell脚本中执行“su – 用户名”后，脚本终止执行，并且切换到su 中指定用户名的交互式界面 
现象：我在root中执行一个脚本，但是其中的一些命令或脚本必须用oracle用户来执行。，
```bash
[root@HZ-ITF-01 cron.d]# vi /data/itf/app/oracle/sync/test.sh
 #!/bin/bash
set -x
su - oracle
sqlplus /nolog <<EOF
conn hxy/hxy
create table test1 as select * from dba_tables;
exit
EOF
```
在root用户下执行sh /data/itf/app/oracle/sync/test.sh后，停止在oracle用户的交互界面不在往下执行 ，需要手动输入exit才能继续，但是在脚本中加入exit也不好使 

分析： 
a、su – 之后就直接切换环境并且等待用户的交互式访问了，不在继续执行脚本中的命令 
b、su后的bash是一个子shell，脚本里写exit没有用，这些都要等su这个进程结束后才会执行。 
解决方案： su – 用户 -c 命令 
     或者 
     sudo -u 用户 命令 参考示例： 参考资料： Shell 中切换用户

然后脚本修改成下面的方式, 脚本顺利执行

```bash
#!/bin/bash
#set -x 
su - oracle -c sqlplus /nolog <<EOF
conn hxy/hxy
create table test1 as select * from dba_tables;
exit
EOF 
```

或者改成：
```bash
#!/bin/bash
set -x 
su - oracle <<!
sqlplus /nolog <<EOF
conn hxy/hxy
create table test1 as select * from dba_tables;
exit
EOF 
!
```