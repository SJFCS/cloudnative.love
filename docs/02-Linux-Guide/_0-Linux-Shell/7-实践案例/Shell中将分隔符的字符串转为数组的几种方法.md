要将字符串列表转变为数组，只需要在前面加()，所以关键是将分隔符转变为空格分隔，常用有下面几种方法

方法一: 借助于`{str//,/}`来处理
```bash
[root@host ~]# str="ONE,TWO,THREE,FOUR"
[root@host ~]# arr=(${str//,/})
[root@host ~]# echo ${arr[@]}
ONE TWO THREE FOUR
```
方法二: 借助于tr命令来处理
```bash
[root@host ~]# str="ONE,TWO,THREE,FOUR"
[root@host ~]# arr=(`echo $str | tr ',' ' '`) 
[root@host ~]# echo ${arr[@]}
ONE TWO THREE FOUR
```
方法三: 借助于awk命令来处理
```bash
[root@host ~]# str="ONE,TWO,THREE,FOUR"
[root@host ~]# arr=($(echo $str | awk 'BEGIN{FS=",";OFS=" "} {print $1,$2,$3,$4}'))
[root@host ~]# echo ${str[*]}
```
方法四: 借助于IFS来处理分隔符
```bash
[root@host ~]# str="ONE,TWO,THREE,FOUR"
[root@host ~]# IFS=","
[root@host ~]# arr=(str)
[root@host ~]# echo ${str[@]}
``` 