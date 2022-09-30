# 第一章

- 本节课程目标
  - - [语法和选项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#语法和选项)
    - [语法和选项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#语法和选项-2)
  - \3. sort工具
    - - [语法和选项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#语法和选项-3)
  - [5.tee工具](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#5tee工具)
  - 6.diff工具
    - [语法和选项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#语法和选项-4)
  - [7. paste工具](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#7-paste工具)
  - \8. tr工具
    - 语法和选项
      - [小试牛刀](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#小试牛刀)
- [二、bash的特性](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDB19623567304A08B990511BF992DCEA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-bash的特性)



- 了解shell中的通配符
- 熟悉grep、cut、sort等小工具和shell中的通配符的使用

# 一、文本处理工具

## 1. grep工具

> grep是**行**过滤工具；用于根据关键字进行行过滤

### 语法和选项

**语法：**

```
# grep [选项] '关键字' 文件名
```

**常见选项：**

```shell
OPTIONS:
    -i: 不区分大小写
    -v: 查找不包含指定内容的行,反向选择
    -w: 按单词搜索
    -o: 打印匹配关键字
    -c: 统计匹配到的行数
    -n: 显示行号
    -r: 逐层遍历目录查找
    -A: 显示匹配行及后面多少行	
    -B: 显示匹配行及前面多少行
    -C: 显示匹配行前后多少行
    -l：只列出匹配的文件名
    -L：列出不匹配的文件名
    -e: 使用正则匹配
    -E:使用扩展正则匹配
    ^key:以关键字开头
    key$:以关键字结尾
    ^$:匹配空行
    --color=auto ：可以将找到的关键词部分加上颜色的显示
```

**颜色显示（别名设置）：**

```shell
临时设置：
# alias grep='grep --color=auto'			//只针对当前终端和当前用户生效

永久设置：
1）全局（针对所有用户生效）
vim /etc/bashrc
alias grep='grep --color=auto'
source /etc/bashrc

2）局部（针对具体的某个用户）
vim ~/.bashrc
alias grep='grep --color=auto'
source ~/.bashrc
```

**举例说明：**

说明：不要直接使用/etc/passwd文件，将其拷贝到/tmp下做实验！

```shell
# grep -i root passwd						忽略大小写匹配包含root的行
# grep -w ftp passwd 						精确匹配ftp单词
# grep -w hello passwd 						精确匹配hello单词;自己添加包含hello的行到文件
# grep -wo ftp passwd 						打印匹配到的关键字ftp(-o只打印关键字本身)
# grep -n root passwd 						打印匹配到root关键字的行好
# grep -ni root passwd 						忽略大小写匹配统计包含关键字root的行
# grep -nic root passwd						忽略大小写匹配统计包含关键字root的行数
# grep -i ^root passwd 						忽略大小写匹配以root开头的行
# grep bash$ passwd 							匹配以bash结尾的行
# grep -n ^$ passwd 							匹配空行并打印行号
# grep ^# /etc/vsftpd/vsftpd.conf		匹配以#号开头的行
# grep -v ^# /etc/vsftpd/vsftpd.conf	匹配不以#号开头的行
# grep -A 5 mail passwd 	          匹配包含mail关键字及其后5行(匹配了这一行, 前面5行也打印出来)
# grep -B 5 mail passwd 				 	匹配包含mail关键字及其前5行
# grep -C 5 mail passwd 					匹配包含mail关键字及其前后5行
```

## 2. cut工具

> cut是**列**截取工具，用于列的截取

### 语法和选项

**语法：**

```shell
# cut 选项  文件名
```

**常见选项：**

```shell
-c:	以字符为单位进行分割,截取
-d:	自定义分隔符，默认为制表符\t
-f:	与-d一起使用，指定截取哪个区域
```

**举例说明:**

```shell
# cut -d: -f1 1.txt 			以:冒号分割，截取第1列内容
# cut -d: -f1,6,7 1.txt 	以:冒号分割，截取第1,6,7列内容
# cut -c4 1.txt 				截取文件中每行第4个字符
# cut -c1-4 1.txt 			截取文件中每行的1-4个字符
# cut -c4-10 1.txt 			截取文件中每行的4-10个字符
# cut -c5- 1.txt 				从第5个字符开始截取后面所有字符
```

**课堂练习：** 用小工具列出你当系统的运行级别。5/3

1. 如何查看系统运行级别
   - 命令`runlevel`
   - 文件`/etc/inittab`
2. 如何过滤运行级别

```shell
runlevel |cut -c3
runlevel | cut -d ' ' -f2
grep -v '^#' /etc/inittab | cut -d: -f2
grep '^id' /etc/inittab |cut -d: -f2
grep "initdefault:$" /etc/inittab | cut -c4
grep -v ^# /etc/inittab |cut -c4
grep 'id:' /etc/inittab |cut -d: -f2
cut -d':' -f2 /etc/inittab |grep -v ^#
cut -c4 /etc/inittab |tail -1
cut -d: -f2 /etc/inittab |tail -1
```

## 3. sort工具

> sort工具用于排序;它将文件的每一行作为一个单位，从首字符向后，依次按ASCII码值进行比较，最后将他们按升序输出。

#### 语法和选项

```shell
-u ：去除重复行
-r ：降序排列，默认是升序
-o : 将排序结果输出到文件中,类似重定向符号>
-n ：以数字排序，默认是按字符排序
-t ：分隔符
-k ：以第N列作为排序条件
-b ：忽略前导空格。
-R ：随机排序，每次运行的结果均不同
```

**举例说明**

```shell
# sort -n -t: -k3 1.txt 			按照用户的uid进行升序排列
# sort -nr -t: -k3 1.txt 			按照用户的uid进行降序排列
# sort -n 2.txt 						按照数字排序
# sort -nu 2.txt 						按照数字排序并且去重
# sort -nr 2.txt 
# sort -nru 2.txt 
# sort -nru 2.txt 
# sort -n 2.txt -o 3.txt 			按照数字排序并将结果重定向到文件
# sort -R 2.txt 
# sort -u 2.txt 
```

##4.uniq工具

> uniq用于去除**连续**的**重复**行

```shell
常见选项：
-i: 忽略大小写
-c: 统计重复行次数
-d:只显示重复行

举例说明：
# uniq 2.txt 
# uniq -d 2.txt 
# uniq -dc 2.txt 
```

## 5.tee工具

> tee工具是从标准输入读取并写入到标准输出和文件，即：双向覆盖重定向（屏幕输出|文本输入）

```shell
选项：
-a 双向追加重定向

# echo hello world
# echo hello world|tee file1
# cat file1 
# echo 999|tee -a file1
# cat file1 
```

## 6.diff工具

> diff工具用于逐行比较文件的不同

注意：diff描述两个文件不同的方式是告诉我们怎样改变第一个文件之后与第二个文件匹配。

### 语法和选项

**语法：**

```
diff [选项] 文件1 文件2
```

**常用选项：**

| 选项     | 含义               | 备注 |
| -------- | ------------------ | ---- |
| -b       | 不检查空格         |      |
| -B       | 不检查空白行       |      |
| -i       | 不检查大小写       |      |
| -w       | 忽略所有的空格     |      |
| --normal | 正常格式显示(默认) |      |
| -c       | 上下文格式显示     |      |
| -u       | 合并格式显示       |      |

**举例说明：**

- 比较两个普通文件异同，文件准备：

```shell
[root@MissHou ~]# cat file1
aaaa
111
hello world
222
333
bbb
[root@MissHou ~]#
[root@MissHou ~]# cat file2
aaa
hello
111
222
bbb
333
world
```

1）正常显示

```shell
diff目的：file1如何改变才能和file2匹配
[root@MissHou ~]# diff file1 file2
1c1,2					第一个文件的第1行需要改变(c=change)才能和第二个文件的第1到2行匹配			
< aaaa				小于号"<"表示左边文件(file1)文件内容
---					---表示分隔符
> aaa					大于号">"表示右边文件(file2)文件内容
> hello
3d3					第一个文件的第3行删除(d=delete)后才能和第二个文件的第3行匹配
< hello world
5d4					第一个文件的第5行删除后才能和第二个文件的第4行匹配
< 333
6a6,7					第一个文件的第6行增加(a=add)内容后才能和第二个文件的第6到7行匹配
> 333					需要增加的内容在第二个文件里是333和world
> world
```

2）上下文格式显示

```shell
[root@MissHou ~]# diff -c file1 file2
前两行主要列出需要比较的文件名和文件的时间戳；文件名前面的符号***表示file1，---表示file2
*** file1       2019-04-16 16:26:05.748650262 +0800
--- file2       2019-04-16 16:26:30.470646030 +0800
***************	我是分隔符
*** 1,6 ****		以***开头表示file1文件，1,6表示1到6行
! aaaa				!表示该行需要修改才与第二个文件匹配
  111 
- hello world		-表示需要删除该行才与第二个文件匹配
  222
- 333					-表示需要删除该行才与第二个文件匹配
  bbb
--- 1,7 ----		以---开头表示file2文件，1,7表示1到7行
! aaa					表示第一个文件需要修改才与第二个文件匹配
! hello				表示第一个文件需要修改才与第二个文件匹配
  111
  222
  bbb
+ 333					表示第一个文件需要加上该行才与第二个文件匹配
+ world				表示第一个文件需要加上该行才与第二个文件匹配
```

3）合并格式显示

```shell
[root@MissHou ~]# diff -u file1 file2
前两行主要列出需要比较的文件名和文件的时间戳；文件名前面的符号---表示file1，+++表示file2
--- file1       2019-04-16 16:26:05.748650262 +0800
+++ file2       2019-04-16 16:26:30.470646030 +0800
@@ -1,6 +1,7 @@
-aaaa
+aaa
+hello
 111
-hello world
 222
-333
 bbb
+333
+world
```

- 比较两个目录不同

```
默认情况下也会比较两个目录里相同文件的内容
[root@MissHou  tmp]# diff dir1 dir2
diff dir1/file1 dir2/file1
0a1
> hello
Only in dir1: file3
Only in dir2: test1
如果只需要比较两个目录里文件的不同，不需要进一步比较文件内容，需要加-q选项
[root@MissHou  tmp]# diff -q dir1 dir2
Files dir1/file1 and dir2/file1 differ
Only in dir1: file3
Only in dir2: test1
```

**其他小技巧：**

有时候我们需要以一个文件为标准，去修改其他文件，并且修改的地方较多时，我们可以通过打补丁的方式完成。

```shell
1）先找出文件不同，然后输出到一个文件
[root@MissHou ~]# diff -uN file1 file2 > file.patch
-u:上下文模式
-N:将不存在的文件当作空文件
2）将不同内容打补丁到文件
[root@MissHou ~]# patch file1 file.patch
patching file file1
3）测试验证
[root@MissHou ~]# diff file1 file2
[root@MissHou ~]#
```

## 7. paste工具

> paste工具用于合并文件行

```
常用选项：
-d：自定义间隔符，默认是tab
-s：串行处理，非并行
```

## 8. tr工具

> tr用于字符转换，替换和删除；主要用于删除文件中控制字符或进行字符转换

### 语法和选项

**语法：**

```
用法1：命令的执行结果交给tr处理，其中string1用于查询，string2用于转换处理

 commands|tr  'string1'  'string2'

用法2：tr处理的内容来自文件，记住要使用"<"标准输入

 tr  'string1'  'string2' < filename

用法3：匹配string1进行相应操作，如删除操作

 tr [options] 'string1' < filename
```

**常用选项：**

```
-d 删除字符串1中所有输入字符。
-s 删除所有重复出现字符序列，只保留第一个；即将重复出现字符串压缩为一个字符串
```

**常匹配字符串：**

| 字符串         | 含义                 | 备注                              |
| -------------- | -------------------- | --------------------------------- |
| a-z或[:lower:] | 匹配所有小写字母     | 所有大小写和数字[a-zA-Z0-9]       |
| A-Z或[:upper:] | 匹配所有大写字母     |                                   |
| 0-9或[:digit:] | 匹配所有数字         |                                   |
| [:alnum:]      | 匹配所有字母和数字   |                                   |
| [:alpha:]      | 匹配所有字母         |                                   |
| [:blank:]      | 所有水平空白         |                                   |
| [:punct:]      | 匹配所有标点符号     |                                   |
| [:space:]      | 所有水平或垂直的空格 |                                   |
| [:cntrl:]      | 所有控制字符         | \f Ctrl-L 走行换页 \n Ctrl-J 换行 |

\r Ctrl-M 回车 \t Ctrl-I tab键 |

**举例说明：**

```
[root@MissHou  shell01]# cat 3.txt 	自己创建该文件用于测试
ROOT:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
boss02:x:516:511::/home/boss02:/bin/bash
vip:x:517:517::/home/vip:/bin/bash
stu1:x:518:518::/home/stu1:/bin/bash
mailnull:x:47:47::/var/spool/mqueue:/sbin/nologin
smmsp:x:51:51::/var/spool/mqueue:/sbin/nologin
aaaaaaaaaaaaaaaaaaaa
bbbbbb111111122222222222233333333cccccccc
hello world 888
666
777
999


# tr -d '[:/]' < 3.txt 				删除文件中的:和/
# cat 3.txt |tr -d '[:/]'			删除文件中的:和/
# tr '[0-9]' '@' < 3.txt 			将文件中的数字替换为@符号
# tr '[a-z]' '[A-Z]' < 3.txt 		将文件中的小写字母替换成大写字母
# tr -s '[a-z]' < 3.txt 			匹配小写字母并将重复的压缩为一个
# tr -s '[a-z0-9]' < 3.txt 		匹配小写字母和数字并将重复的压缩为一个
# tr -d '[:digit:]' < 3.txt 		删除文件中的数字
# tr -d '[:blank:]' < 3.txt 		删除水平空白
# tr -d '[:space:]' < 3.txt 		删除所有水平和垂直空白
```

#### 小试牛刀

1. 使用小工具分别截取当前主机IP；截取NETMASK；截取广播地址；截取MAC地址

```shell
# ifconfig eth0|grep 'Bcast'|tr -d '[a-zA-Z ]'|cut -d: -f2,3,4
10.1.1.1:10.1.1.255:255.255.255.0
# ifconfig eth0|grep 'Bcast'|tr -d '[a-zA-Z ]'|cut -d: -f2,3,4|tr ':' '\n'
10.1.1.1
10.1.1.255
255.255.255.0
# ifconfig eth0|grep 'HWaddr'|cut -d: -f2-|cut -d' ' -f4
00:0C:29:25:AE:54
# ifconfig eth0|grep 'HW'|tr -s ' '|cut -d' ' -f5
00:0C:29:B4:9E:4E

# ifconfig eth1|grep Bcast|cut -d: -f2|cut -d' ' -f1
# ifconfig eth1|grep Bcast|cut -d: -f2|tr -d '[ a-zA-Z]'
# ifconfig eth1|grep Bcast|tr -d '[:a-zA-Z]'|tr ' ' '@'|tr -s '@'|tr '@' '\n'|grep -v ^$
# ifconfig eth0|grep 'Bcast'|tr -d [:alpha:]|tr '[ :]' '\n'|grep -v ^$
# ifconfig eth1|grep HWaddr|cut -d ' ' -f11
# ifconfig eth0|grep HWaddr|tr -s ' '|cut -d' ' -f5
# ifconfig eth1|grep HWaddr|tr -s ' '|cut -d' ' -f5
# ifconfig eth0|grep 'Bcast'|tr -d 'a-zA-Z:'|tr ' ' '\n'|grep -v '^$'
```

1. 将系统中所有普通用户的用户名、密码和默认shell保存到一个文件中，要求用户名密码和默认shell之间用tab键分割

```shell
# grep 'bash$' passwd |grep -v 'root'|cut -d: -f1,2,7|tr ':' '\t' |tee abc.txt
```

# 二、bash的特性

## 1、命令和文件自动补全

Tab只能补全命令和文件 （RHEL6/Centos6）

## **2、常见的快捷键**

```shell
^c   			终止前台运行的程序
^z	  			将前台运行的程序挂起到后台(暂停)
^d   			退出 等价exit
^l   			清屏 
^a |home  	光标移到命令行的最前端
^e |end  	光标移到命令行的后端
^u   			删除光标前所有字符
^k   			删除光标后所有字符
^r	 			搜索历史命令
```

\##3 、常用的通配符（重点）

```shell
1. *:	匹配0或多个任意字符
2. ?:	匹配任意单个字符
3. [list]:	匹配[list]中的任意单个字符,或者一组单个字符   [a-z] [0-10,11] -> 0到10, 逗号, 1, 1
   [!list]: 匹配除list中的任意单个字符
4. {string1,string2,...}：匹配string1,string2或更多字符串
   {1..100}, 匹配1~100

# rm -f file*
# cp *.conf  /dir1
# touch file{1..5}
```

## **4、bash中的引号**（重点）

- *双引号""* :会把引号的内容当成整体来看待，**允许通过$符号引用其他变量值(可以使用变量 echo "$(hostname)")**
- *单引号''* :会把引号的内容当成整体来看待，**禁止引用其他变量值(不可以使用变量)**，shell中特殊符号都被视为普通字符
- *反撇号``* :反撇号和$()一样，引号或括号里的命令会优先执行，如果存在嵌套，反撇号不能用

```shell
[root@MissHou  dir1]# echo "$(hostname)"		-> localhost.localdomain

[root@MissHou  dir1]# echo "`date +%F`"			-> 2020-12-08

[root@MissHou  dir1]# echo '$(hostname)'		-> '$(hostname)'
[root@MissHou  dir1]# echo "hello world"
hello world
[root@MissHou  dir1]# echo 'hello world'
hello world

[root@MissHou  dir1]# echo $(date +%F)
2018-11-22
[root@MissHou  dir1]# echo `echo $(date +%F)`
2018-11-22
[root@MissHou  dir1]# echo `date +%F`
2018-11-22
[root@MissHou  dir1]# echo `echo `date +%F``
date +%F
[root@MissHou  dir1]# echo $(echo `date +%F`)
2018-11-22
```





- 一、SHELL介绍
  - - [㈠ 什么是shell脚本？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-什么是shell脚本)
    - [㈡ 什么时候用到脚本?](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-什么时候用到脚本)
    - [㈢ shell脚本能干啥?](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-shell脚本能干啥)
    - [㈣ 如何学习shell脚本？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-如何学习shell脚本)
    - [㈤ 学习shell脚本的秘诀](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#五-学习shell脚本的秘诀)
    - [㈥ shell脚本的基本写法](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#六-shell脚本的基本写法)
    - [㈦ shell脚本的执行方法](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#七-shell脚本的执行方法)
- 二、变量的定义
  - [1. 变量是什么？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-变量是什么)
  - [2. 什么时候需要定义变量？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-什么时候需要定义变量)
  - [3.变量如何定义？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3变量如何定义)
  - \4. 变量的定义规则
    - [㈠ 变量名区分大小写](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-变量名区分大小写)
    - [㈡ 变量名不能有特殊符号](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-变量名不能有特殊符号)
    - [㈢ 变量名不能以数字开头](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-变量名不能以数字开头)
    - [㈣ 等号两边不能有任何空格](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-等号两边不能有任何空格)
    - [㈤ 变量名尽量做到见名知意](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#五-变量名尽量做到见名知意)
  - \5. 变量的定义方式有哪些？
    - [㈠ 基本方式](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-基本方式)
    - [㈡ 命令执行结果赋值给变量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-命令执行结果赋值给变量)
    - [㈢ 交互式定义变量(read)](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-交互式定义变量read)
    - [㈣ 定义有类型的变量(declare)](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-定义有类型的变量declare)
  - \6. 变量的分类
    - [㈠ 本地变量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-本地变量)
    - [㈡ 环境变量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-环境变量)
    - [㈢ 全局变量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-全局变量)
    - [㈣ 系统变量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-系统变量)
- 三、简单四则运算
  - [1. 四则运算符号](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-四则运算符号)
  - [2.了解i和i](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2了解i和i)
- 四、扩展补充
  - \1. 数组定义
    - [㈠ 数组分类](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-数组分类)
    - [㈡ 普通数组定义](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-普通数组定义)
    - [㈢ 数组的读取](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-数组的读取)
    - ㈣ 关联数组定义
      - [①首先声明关联数组](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1首先声明关联数组)
      - [② 数组赋值](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-数组赋值)
  - [2. 其他变量定义](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8743C60B9CFA48FC8173CC49D03CADCA%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-其他变量定义)

\#SHELL编程模块课程目标



- ① Shell的基本语法结构

  如：变量定义、条件判断、循环语句(for、until、while)、分支语句、函数和数组等；

  ② 基本正则表达式的运用;

  ③ 文件处理三剑客：grep、sed、awk工具的使用；

  ④ 使用shell脚本完成一些较复杂的任务，如：服务搭建、批量处理等。

  ***说明：以上内容仅仅是基本要求，还有很多更深更难的语法需要扩充学习。\***

- **本节目标**

  - 熟练掌握shell变量的定义和获取（重点）
  - 能够进行shell简单的四则运算

# 一、SHELL介绍

**前言：**

计算机只能认识（识别）机器语言(0和1)，如（11000000 这种）。但是，我们的程序猿们不能直接去写01这样的代码，所以，要想将程序猿所开发的代码在计算机上运行，就必须找"人"（工具）来翻译成机器语言，这个"人"(工具)就是我们常常所说的**编译器**或者**解释器**。

![img](D:\document\spring\图片\dsfsdfsdfsd)

##1. 编程语言分类

- **编译型语言：**

 程序在执行之前需要一个专门的编译过程，把程序编译成为机器语言文件，运行时不需要重新翻译，直接使用编译的结果就行了。程序执行效率高，依赖编译器，跨平台性差些。如C、C++

- **解释型语言：**

 程序不需要编译，程序在运行时由**解释器**翻译成机器语言，每执行一次都要翻译一次。因此效率比较低。比如Python/JavaScript/ Perl /ruby/Shell等都是解释型语言。

![./语言分类](http://xn--kbry84hvqil0b.png/?ynotemdtimestamp=1607388071614)

- **总结**

编译型语言比解释型语言速度较快，但是不如解释型语言跨平台性好。如果做底层开发或者大型应用程序或者操作系开发一般都用编译型语言；如果是一些服务器脚本及一些辅助的接口，对速度要求不高、对各个平台的兼容性有要求的话则一般都用解释型语言。

##2. shell简介

![img](D:\document\spring\图片\dsfsfsdf)

**总结：**

- shell就是人机交互的一个桥梁
- shell的种类

```shell
[root@MissHou ~]# cat /etc/shells 
/bin/sh				#是bash的一个快捷方式
/bin/bash			#bash是大多数Linux默认的shell，包含的功能几乎可以涵盖shell所有的功能

/sbin/nologin		#表示非交互，不能登录操作系统
/bin/dash			#小巧，高效，功能相比少一些

/bin/csh			#具有C语言风格的一种shell，具有许多特性，但也有一些缺陷
/bin/tcsh			#是csh的增强版，完全兼容csh
```

**思考：终端和shell有什么关系？**

1. 终端连接 另一台电脑的shell
2. shell程序接收到命令, 默认shell程序, 
3. shell解释命令后, 执行命令, 操作shell所在主机

![img](D:\document\spring\图片\sfddsfddsfdsf)

## 3. shell脚本

### ㈠ 什么是shell脚本？

- 一句话概括

简单来说就是将需要执行的命令保存到文本中，按照顺序执行。它是解释型的，意味着不需要编译。

- 准确叙述

**若干命令 + 脚本的基本格式 + 脚本特定语法 + 思想= shell脚本**

### ㈡ 什么时候用到脚本?

**重复化**、复杂化的工作，通过把工作的命令写成脚本，以后仅仅需要执行脚本就能完成这些工作。

### ㈢ shell脚本能干啥?

①自动化软件部署	LAMP/LNMP/Tomcat...

②自动化管理	系统初始化脚本、批量更改主机密码、推送公钥...

③自动化分析处理	统计网站访问量

④自动化备份	数据库备份、日志转储...

⑤自动化监控脚本

### ㈣ 如何学习shell脚本？

1. 尽可能记忆更多的命令(记忆命令使用功能和场景)
2. 掌握脚本的标准的格式（指定魔法字节、使用标准的执行方式运行脚本）
3. 必须==**熟悉掌握**==脚本的基本语法（重点)

### ㈤ 学习shell脚本的秘诀

多看（看懂）——>模仿（多练）——>多思考（多写）

### ㈥ shell脚本的基本写法

1）**脚本第一行**，魔法字符==**#!**==指定解释器【必写】

`#!/bin/bash` 表示以下内容使用bash解释器解析

**注意：** 如果直接将解释器路径写死在脚本里，可能在某些系统就会存在找不到解释器的兼容性问题，所以可以使用:**`#!/bin/env 解释器`** **`#!/bin/env bash`**

2）**脚本第二部分**，注释(#号)说明，对脚本的基本信息进行描述【可选】

```
#!/bin/env bash

# 以下内容是对脚本的基本信息的描述
# Name: 名字
# Desc:描述describe
# Path:存放路径
# Usage:用法
# Update:更新时间

#下面就是脚本的具体内容
commands
...
```

3）**脚本第三部分**，脚本要实现的具体代码内容

### ㈦ shell脚本的执行方法

- 标准脚本执行方法（建议）

```shell
1) 编写人生第一个shell脚本
[root@MissHou shell01]# cat first_shell.sh
#!/bin/env bash

# 以下内容是对脚本的基本信息的描述
# Name: first_shell.sh
# Desc: num1
# Path: /shell01/first_shell.sh
# Usage:/shell01/first_shell.sh
# Update:2019-05-05

echo "hello world"
echo "hello world"
echo "hello world"

2) 脚本增加可执行权限
[root@MissHou shell01]# chmod +x first_shell.sh

3) 标准方式执行脚本
[root@MissHou shell01]# pwd
/shell01
[root@MissHou shell01]# /shell01/first_shell.sh
或者
[root@MissHou shell01]# ./first_shell.sh

注意：标准执行方式脚本必须要有可执行权限。
```

- 非标准的执行方法（不建议）

1. 直接在命令行指定解释器执行

```shell
[root@MissHou shell01]# bash first_shell.sh
[root@MissHou shell01]# sh first_shell.sh
[root@MissHou shell01]# bash -x first_shell.sh
+ echo 'hello world'
hello world
+ echo 'hello world'
hello world
+ echo 'hello world'
hello world
----------------
-x:一般用于排错，查看脚本的执行过程
-n:用来查看脚本的语法是否有问题
------------
```

2. 使用`source`命令读取脚本文件,执行文件里的代码

```shell
[root@MissHou shell01]# source first_shell.sh
hello world
hello world
hello world
```

**小试牛刀：**写一个木有灵魂的脚本，要求如下：

1. 删除/tmp/目录下的所有文件

2. 然后在/tmp目录里创建3个目录，分别是dir1~dir3

3. 拷贝/etc/hosts文件到刚创建的dir1目录里

4. 最后打印"报告首长，任务已于2019-05-05 10:10:10时间完成"内容

   `echo "报告首长，任务已于$(date +'%F %T')"`

# 二、变量的定义

## 1. 变量是什么？

一句话概括：变量是用来临时保存数据的，该数据是可以变化的数据。

## 2. 什么时候需要定义变量？

- 如果某个内容需要多次使用，并且在代码中**重复出现**，那么可以用变量代表该内容。这样在修改内容的时候，仅仅需要修改变量的值。
- 在代码运作的过程中，可能会把某些命令的执行结果保存起来，后续代码需要使用这些结果，就可以直接使用这个变量。

## 3.变量如何定义？

**变量名=====变量值**

变量名：用来临时保存数据的

变量值：就是临时的可变化的数据

```
[root@MissHou ~]# A=hello			定义变量A
[root@MissHou ~]# echo $A			调用变量A，要给钱的，不是人民币是美元"$"
hello
[root@MissHou ~]# echo ${A}		还可以这样调用，不管你的姿势多优雅，总之要给钱
hello
[root@MissHou ~]# A=world			因为是变量所以可以变，移情别恋是常事
[root@MissHou ~]# echo $A			不管你是谁，只要调用就要给钱
world
[root@MissHou ~]# unset A			不跟你玩了，取消变量
[root@MissHou ~]# echo $A			从此，我单身了，你可以给我介绍任何人
```

## 4. 变量的定义规则

虽然可以给变量（变量名）赋予任何值；但是，对于变量名也是要求的！:unamused:

### ㈠ 变量名区分大小写

```
[root@MissHou ~]# A=hello
[root@MissHou ~]# a=world
[root@MissHou ~]# echo $A
hello
[root@MissHou ~]# echo $a
world
```

### ㈡ 变量名不能有特殊符号

```
[root@MissHou ~]# *A=hello
-bash: *A=hello: command not found
[root@MissHou ~]# ?A=hello
-bash: ?A=hello: command not found
[root@MissHou ~]# @A=hello
-bash: @A=hello: command not found

特别说明：对于有空格的字符串给变量赋值时，要用引号引起来
[root@MissHou ~]# A=hello world
-bash: world: command not found
[root@MissHou ~]# A="hello world"
[root@MissHou ~]# A='hello world'
```

### ㈢ 变量名不能以数字开头

```
[root@MissHou ~]# 1A=hello
-bash: 1A=hello: command not found
[root@MissHou ~]# A1=hello
注意：不能以数字开头并不代表变量名中不能包含数字呦。
```

### ㈣ 等号两边不能有任何空格

```
[root@MissHou ~]# A =123
-bash: A: command not found
[root@MissHou ~]# A= 123
-bash: 123: command not found
[root@MissHou ~]# A = 123
-bash: A: command not found
[root@MissHou ~]# A=123
[root@MissHou ~]# echo $A
123
```

### ㈤ 变量名尽量做到见名知意

```
NTP_IP=10.1.1.1
DIR=/u01/app1
TMP_FILE=/var/log/1.log
...

说明：一般变量名使用大写（小写也可以），不要同一个脚本中变量全是a,b,c等不容易阅读
```

## 5. 变量的定义方式有哪些？

### ㈠ 基本方式

> 直接赋值给一个变量

```shell
[root@MissHou ~]# A=1234567
[root@MissHou ~]# echo $A
1234567
[root@MissHou ~]# echo ${A:2:4}		表示从A变量中第3个字符开始截取，截取4个字符
3456

说明：
$变量名 和 ${变量名}的异同
相同点：都可以调用变量
不同点：${变量名}可以只截取变量的一部分，而$变量名不可以
```

### ㈡ 命令执行结果赋值给变量

```shell
[root@MissHou ~]# B=`date +%F`
[root@MissHou ~]# echo $B
2019-04-16
[root@MissHou ~]# C=$(uname -r)
[root@MissHou ~]# echo $C
2.6.32-696.el6.x86_64
```

### ㈢ 交互式定义变量(read)

**目的：**让用户自己给变量赋值，比较灵活。

**语法：**`read [选项] 变量名`

**常见选项：**

| 选项 | 释义                                                       |
| ---- | ---------------------------------------------------------- |
| -p   | 定义提示用户的信息                                         |
| -n   | 定义字符数（限制变量值的长度）                             |
| -s   | 不显示（不显示用户输入的内容）                             |
| -t   | 定义超时时间，默认单位为秒（限制用户输入变量值的超时时间） |

**举例说明：**

```shell
用法1：用户自己定义变量值
[root@MissHou ~]# read name
harry
[root@MissHou ~]# echo $name
harry
[root@MissHou ~]# read -p "Input your name:" name
Input your name:tom
[root@MissHou ~]# echo $name
tom
```

用法2：变量值来自文件

```shell
[root@MissHou ~]# cat 1.txt 
10.1.1.1 255.255.255.0

[root@MissHou ~]# read ip mask < 1.txt 
[root@MissHou ~]# echo $ip
10.1.1.1
[root@MissHou ~]# echo $mask
255.255.255.0
```

### ㈣ 定义有类型的变量(declare)

**目的：** 给变量做一些限制，固定变量的类型，比如：整型、只读

**用法：**`declare 选项 变量名=变量值`

**常用选项：**

| 选项 | 释义                       | 举例                                         |
| ---- | -------------------------- | -------------------------------------------- |
| -i   | 将变量看成整数             | declare -i A=123                             |
| -r   | 定义只读变量               | declare -r B=hello                           |
| -a   | 定义普通数组；查看普通数组 |                                              |
| -A   | 定义关联数组；查看关联数组 |                                              |
| -x   | 将变量通过环境导出         | declare -x AAA=123456 等于 export AAA=123456 |

**举例说明：**

```
[root@MissHou ~]# declare -i A=123
[root@MissHou ~]# echo $A
123
[root@MissHou ~]# A=hello
[root@MissHou ~]# echo $A
0

[root@MissHou ~]# declare -r B=hello
[root@MissHou ~]# echo $B
hello
[root@MissHou ~]# B=world
-bash: B: readonly variable
[root@MissHou ~]# unset B
-bash: unset: B: cannot unset: readonly variable
```

## **6. 变量的分类**

### ㈠ 本地变量

- **本地变量**：当前用户自定义的变量。当前进程中有效，其他进程及当前进程的子进程无效。

### ㈡ 环境变量

#### 2、环境变量的分类

1）按生效的范围分类。

**系统环境变量**：公共的，对全部的用户都生效。

**用户环境变量**：用户私有的、自定义的个性化设置，只对该用户生效。

2）按生存周期分类。

**永久环境变量**：在环境变量脚本文件中配置，用户每次登录时会自动执行这些脚本，相当于永久生效。

**临时环境变量**：使用时在Shell中临时定义，退出Shell后失效。

- 环境变量 (也是和程序绑定的, 程序结束时, 动态设置的环境变量也就结束)

  ：当前进程有效，并且能够被子进程调用, 反之不行(子进程环境变量的设置对父进程无效)。

  ​	*1. 环境变量的值由用户决定, 和Windows的用户环境变量一样. 即使用户qpyue 使用su 切换root用户,echo $USER依旧是以前的用户名称(qpyue), 环境变量的值依旧不变.(除了$HOME)*

  ​    *2. 即使两个qpyue用户同时登录, 他们的环境变量都会重新从配置文件刷新, 单独存储, 所以环境变量的值互不影响(在两个bash程序存在过程中, 任意一方环境变量变化不影响另一方)*

  - `env`查看当前用户的环境变量
  - `set`查询当前用户的所有变量(临时变量与环境变量)
  - `export 变量名=变量值` 或者 `变量名=变量值；export 变量名`

```shell
[root@MissHou ~]# export A=hello		临时将一个本地变量（临时变量）变成环境变量
[root@MissHou ~]# env|grep ^A
A=hello

永久生效：
vim /etc/profile 或者 ~/.bashrc
export A=hello
或者
A=hello
export A

说明：系统中有一个变量PATH，环境变量
export PATH=/usr/local/mysql/bin:$PATH
```

### ㈢ 全局变量

- **全局变量**：*全局所有的用户和程序都能调用*(文件配置)，且继承，新建的用户也默认能调用.
- **解读相关配置文件**

| 文件名              | 说明                               | 备注                                            |
| ------------------- | ---------------------------------- | ----------------------------------------------- |
| $HOME/.bashrc       | 当前用户的bash信息,用户登录时读取  | 定义别名、umask、函数等                         |
| $HOME/.bash_profile | 当前用户的环境变量，用户登录时读取 |                                                 |
| $HOME/.bash_logout  | 当前用户退出当前shell时最后读取    | 定义用户退出时执行的程序等                      |
| /etc/bashrc         | 全局的bash信息，所有用户都生效     |                                                 |
| /etc/profile        | 全局环境变量信息                   | 系统和所有用户都生效                            |
| $HOME/.bash_history | 用户的历史命令                     | history -w 保存历史记录 history -c 清空历史记录 |

**说明：**以上文件修改后，都需要*重新source*让其生效或者退出重新登录。

- 用户登录系统后, 读取相关文件的顺序

  1. `/etc/profile`
2. `$HOME/.bash_profile`
  3. `$HOME/.bashrc`
4. `/etc/bashrc`
  5. `$HOME/.bash_logout`

### ㈣ 系统变量

- **系统变量(内置bash中变量)** ： shell本身已经固定好了它的名字和作用.

./02.sh a b c  -> (3个参数)

| 内置变量   | 含义                                                         |
| ---------- | ------------------------------------------------------------ |
| $?         | 上一条命令执行后返回的状态；状态值为0表示执行正常，非0表示执行异常或错误 |
| $0         | 当前执行的程序或脚本名   (./02.sh)                           |
| $#         | 脚本后面接的参数的个数         3个                           |
| $*         | 脚本后面所有参数，参数当成一个整体输出，每一个变量参数之间以空格隔开 (参数数组a b c) |
| $@         | 脚本后面所有参数，参数是独立的，也是全部输出 (参数数组a b c) |
| $1~$9      | 脚本后面的位置参数，$1表示第1个位置参数，依次类推            |
| ${10}~${n} | 扩展位置参数,第10个位置变量必须用{}大括号括起来(2位数字以上扩起来) |
| $$         | 当前所在进程的进程号，如`echo $$`                            |
| $！        | 后台运行的最后一个进程号     测试: sleep 400 &(后台运行)/sleep 400(ctrl+z 暂停运行), 再运行jobs, 查看当前进程的后台子进程. |
| !$         | 调用最后一条命令历史中的参数                                 |

- 进一步了解位置参数`$1~${n}`

```
#!/bin/bash
#了解shell内置变量中的位置参数含义
echo "\$0 = $0"
echo "\$# = $#"
echo "\$* = $*"
echo "\$@ = $@"
echo "\$1 = $1" 
echo "\$2 = $2" 
echo "\$3 = $3" 
echo "\$11 = ${11}" 
echo "\$12 = ${12}" 
```

- 进一步了解$*和$@的区别

`$*`：表示将变量看成一个整体 `$@`：表示变量是独立的

```shell
#!/bin/bash
for i in "$@"
do
echo $i
done

echo "======我是分割线======="

for i in "$*"
do
echo $i
done

[root@MissHou ~]# bash 3.sh a b c
a
b
c
======我是分割线=======
a b c
```

# 三、简单四则运算

算术运算：默认情况下，shell就只能支持简单的整数运算

运算内容：加(+)、减(-)、乘(*)、除(/)、求余数（%）

## **1. 四则运算符号**

| 表达式 | 举例                          |
| ------ | ----------------------------- |
| $(( )) | echo $((1+1))                 |
| $[ ]   | echo $[10-5]                  |
| expr   | expr 10 / 5                   |
| let    | n=1;let n+=1 等价于 let n=n+1 |

## 2.了解i和i

- 对变量的值的影响

```shell
[root@MissHou ~]# i=1
[root@MissHou ~]# let i++
[root@MissHou ~]# echo $i
2
[root@MissHou ~]# j=1
[root@MissHou ~]# let ++j
[root@MissHou ~]# echo $j
2
```

- 对表达式的值的影响

```shell
[root@MissHou ~]# unset i j
[root@MissHou ~]# i=1;j=1
[root@MissHou ~]# let x=i++         先赋值，再运算
[root@MissHou ~]# let y=++j         先运算，再赋值
[root@MissHou ~]# echo $i
2
[root@MissHou ~]# echo $j
2
[root@MissHou ~]# echo $x
1
[root@MissHou ~]# echo $y
2
```

# 四、扩展补充

## **1. 数组定义**

### ㈠ 数组分类

- 普通数组：只能使用整数作为数组索引(元素的下标)
- 关联数组：可以使用字符串作为数组索引(元素的下标)

### ㈡ 普通数组定义

- 一次赋予一个值

```shell
数组名[索引下标]=值
array[0]=v1
array[1]=v2
array[2]=v3
array[3]=v4
```

- 一次赋予多个值

```shell
数组名=(值1 值2 值3 ...)
array=(var1 var2 var3 var4)

array1=(`cat /etc/passwd`)			将文件中每一行赋值给array1数组
array2=(`ls /root`)
array3=(harry amy jack "Miss Hou")
array4=(1 2 3 4 "hello world" [10]=linux)
```

### ㈢ 数组的读取

```shell
${数组名[元素下标]}

echo ${array[0]}			获取数组里第一个元素
echo ${array[*]}			获取数组里的所有元素
echo ${#array[*]}			获取数组里所有元素个数
echo ${!array[@]}    	获取数组元素的索引下标
echo ${array[@]:1:2}    访问指定的元素；1代表从下标为1的元素开始获取；2代表获取后面几个元素

查看普通数组信息：
[root@MissHou ~]# declare -a
```

### ㈣ 关联数组定义

#### ①首先声明关联数组

declare -A asso_array1

```
declare -A asso_array1
declare -A asso_array2
declare -A asso_array3
```

#### ② 数组赋值

- 一次赋一个值

```shell
数组名[索引or下标]=变量值
# asso_array1[linux]=one
# asso_array1[java]=two
# asso_array1[php]=three
```

- 一次赋多个值

```shell
# asso_array2=([name1]=harry [name2]=jack [name3]=amy [name4]="Miss Hou")
```

- 查看关联数组

```shell
# declare -A
declare -A asso_array1='([php]="three" [java]="two" [linux]="one" )'
declare -A asso_array2='([name3]="amy" [name2]="jack" [name1]="harry" [name4]="Miss Hou" )'
```

- 获取关联数组值

```shell
# echo ${asso_array1[linux]}
one
# echo ${asso_array1[php]}
three
# echo ${asso_array1[*]}
three two one
# echo ${!asso_array1[*]}
php java linux
# echo ${#asso_array1[*]}
3
# echo ${#asso_array2[*]}
4
# echo ${!asso_array2[*]}
name3 name2 name1 name4
```

- 其他定义方式

```shell
[root@MissHou shell05]# declare -A books
[root@MissHou shell05]# let books[linux]++
[root@MissHou shell05]# declare -A|grep books
declare -A books='([linux]="1" )'
[root@MissHou shell05]# let books[linux]++
[root@MissHou shell05]# declare -A|grep books
declare -A books='([linux]="2" )'
```

## 2. 其他变量定义

- 取出一个目录下的目录和文件：`dirname`和 `basename`

```
# A=/root/Desktop/shell/mem.txt 
# echo $A
/root/Desktop/shell/mem.txt
# dirname $A   取出目录
/root/Desktop/shell
# basename $A  取出文件
mem.txt
```

- -变量"内容"的删除和替换

```
一个“%”代表从右往左删除
两个“%%”代表从右往左去掉最多
一个“#”代表从左往右去掉删除
两个“##”代表从左往右去掉最多

举例说明：
# url=www.taobao.com
# echo ${#url}		     获取变量的长度
# echo ${url#*.}
# echo ${url##*.}
# echo ${url%.*}
# echo ${url%%.*}
```

- 以下了解，自己完成

```
替换：/ 和 //
 1015  echo ${url/ao/AO}  用AO代替ao（从左往右第一个）
 1017  echo ${url//ao/AO}   贪婪替换（替代所有）
 
替代： - 和 :-  +和:+
 1019  echo ${abc-123}
 1020  abc=hello
 1021  echo ${abc-444}
 1022  echo $abc
 1024  abc=
 1025  echo ${abc-222}

${变量名-新的变量值} 或者 ${变量名=新的变量值}
变量没有被赋值：会使用“新的变量值“ 替代
变量有被赋值（包括空值）： 不会被替代

 1062  echo ${ABC:-123}
 1063  ABC=HELLO
 1064  echo ${ABC:-123}
 1065  ABC=
 1066  echo ${ABC:-123}

${变量名:-新的变量值} 或者 ${变量名:=新的变量值}
变量没有被赋值或者赋空值：会使用“新的变量值“ 替代
变量有被赋值： 不会被替代

 1116  echo ${abc=123}
 1118  echo ${abc:=123}

[root@MissHou ~]# unset abc
[root@MissHou ~]# echo ${abc:+123}

[root@MissHou ~]# abc=hello
[root@MissHou ~]# echo ${abc:+123}
123
[root@MissHou ~]# abc=
[root@MissHou ~]# echo ${abc:+123}

${变量名+新的变量值}
变量没有被赋值或者赋空值：不会使用“新的变量值“ 替代
变量有被赋值： 会被替代
[root@MissHou ~]# unset abc
[root@MissHou ~]# echo ${abc+123}

[root@MissHou ~]# abc=hello
[root@MissHou ~]# echo ${abc+123}
123
[root@MissHou ~]# abc=
[root@MissHou ~]# echo ${abc+123}
123
${变量名:+新的变量值}
变量没有被赋值：不会使用“新的变量值“ 替代
变量有被赋值（包括空值）： 会被替代

[root@MissHou ~]# unset abc
[root@MissHou ~]# echo ${abc?123}
-bash: abc: 123

[root@MissHou ~]# abc=hello
[root@MissHou ~]# echo ${abc?123}
hello
[root@MissHou ~]# abc=
[root@MissHou ~]# echo ${abc?123}

${变量名?新的变量值}
变量没有被赋值:提示错误信息
变量被赋值（包括空值）：不会使用“新的变量值“ 替代

[root@MissHou ~]# unset abc
[root@MissHou ~]# echo ${abc:?123}
-bash: abc: 123
[root@MissHou ~]# abc=hello
[root@MissHou ~]# echo ${abc:?123}
hello
[root@MissHou ~]# abc=
[root@MissHou ~]# echo ${abc:?123}
-bash: abc: 123

${变量名:?新的变量值}
变量没有被赋值或者赋空值时:提示错误信息
变量被赋值：不会使用“新的变量值“ 替代

说明：?主要是当变量没有赋值提示错误信息的，没有赋值功能
```





- [本节课程目标](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#本节课程目标)
- 一、条件判断语法结构
  - \2. 条件判断相关参数
    - [㈠ 判断文件类型](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-判断文件类型)
    - [㈡ 判断文件权限](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-判断文件权限)
    - [㈢ 判断文件新旧](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-判断文件新旧)
    - [㈣ 判断整数](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-判断整数)
    - [㈤ 判断字符串](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#五-判断字符串)
    - ㈥ 多重条件判断
      - [① 举例说明](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-举例说明)
      - [② 逻辑运算符总结](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-逻辑运算符总结)
- 二、流程控制语句
  - \1. 基本语法结构
    - [㈠ if结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-if结构)
    - [㈡ if...else结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-ifelse结构)
    - [㈢ if...elif...else结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-ifelifelse结构)
    - [㈣ 层层嵌套结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-层层嵌套结构)
  - \2. 应用案例
    - ㈠ 判断两台主机是否ping通
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现)
    - ㈡ 判断一个进程是否存在
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-2)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-2)
      - [③ 补充命令](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-补充命令)
    - ㈢ 判断一个服务是否正常
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-3)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-3)
    - [㈠ 判断用户是否存在](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-判断用户是否存在)
    - [㈡ 判断软件包是否安装](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-判断软件包是否安装)
    - [㈢ 判断当前主机的内核版本](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F0367BDF68CCB4774B3846EE70F9B5237%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-判断当前主机的内核版本)



# 本节课程目标

- 熟悉条件判断语句，如判断整数、判断字符串等
- 熟悉流程控制语句基本语法，如if…else…

# 一、条件判断语法结构

**思考：何为真(true)？何为假(false)？**

## **1. 条件判断语法格式**

- 格式1： **test** 条件表达式
- 格式2： **[** 条件表达式 ]
- 格式3： **[[** 条件表达式 ]] 支持正则 =~

**特别说明：**

1）[ 亲亲，我两边都有空格，不空打死你呦 ] :imp:

2）[[ 亲亲，我两边都有空格，不空打死你呦 ]]:imp:

1. 更多判断，`man test`去查看，很多的参数都用来进行条件判断

## 2. 条件判断相关参数

问：你要判断什么？

答：我要判断文件类型，判断文件新旧，判断字符串是否相等，判断权限等等...

### ㈠ 判断文件类型

1. | 判断参数 | 含义                                         | 说明         |
   | -------- | -------------------------------------------- | ------------ |
   | -e       | 判断文件是否存在（link文件指向的也必须存在） | exists       |
   | -f       | 判断文件是否存在并且是一个普通文件           | file         |
   | -d       | 判断文件是否存在并且是一个目录               | directory    |
   | -L       | 判断文件是否存在并且是一个软连接文件         | soft link    |
   | -b       | 判断文件是否存在并且是一个块设备文件         | block        |
   | -S       | 判断文件是否存在并且是一个套接字文件         | socket       |
   | -c       | 判断文件是否存在并且是一个字符设备文件       | char         |
   | -p       | 判断文件是否存在并且是一个命名管道文件       | pipe         |
   | -s       | 判断文件是否存在并且是一个非空文件（有内容） | is not empty |


**举例说明：**

```shell
test -e file					只要文件存在条件为真
[ -d /shell01/dir1 ]		 	判断目录是否存在，存在条件为真
[ ! -d /shell01/dir1 ]		判断目录是否存在,不存在条件为真
[[ -f /shell01/1.sh ]]		判断文件是否存在，并且是一个普通的文件
```

### ㈡ 判断文件权限

| 判断参数 | 含义                                            |
| -------- | ----------------------------------------------- |
| -r       | 当前用户对其是否可读                            |
| -w       | 当前用户对其是否可写                            |
| -x       | 当前用户对其是否可执行                          |
| -u       | 是否有suid，高级权限冒险位                      |
| -g       | 是否sgid，高级权限强制位                        |
| -k       | 是否有t位，高级权限粘滞位 (创建者/root才能删除) |

### ㈢ 判断文件新旧

说明：这里的新旧指的是文件的修改时间。

| 判断参数        | 含义                                                         |
| --------------- | ------------------------------------------------------------ |
| file1 -nt file2 | 比较file1是否比file2新                                       |
| file1 -ot file2 | 比较file1是否比file2旧                                       |
| file1 -ef file2 | 比较是否为同一个文件，或者用于判断硬连接，是否指向同一个inode |

### ㈣ 判断整数

| 判断参数   | 含义     |
| ---------- | -------- |
| -eq  ==    | 相等     |
| -ne  <> != | 不等     |
| -gt        | 大于     |
| -lt        | 小于     |
| -ge        | 大于等于 |
| -le        | 小于等于 |

### ㈤ 判断字符串

| 判断参数           | 含义                                        |
| ------------------ | ------------------------------------------- |
| -z                 | 判断是否为空字符串，字符串长度为0则成立     |
| -n                 | 判断是否为非空字符串，字符串长度不为0则成立 |
| string1 = string2  | 判断字符串是否相等                          |
| string1 != string2 | 判断字符串是否相不等                        |

### ㈥ 多重条件判断

| 判断符号   | 含义   | 举例                                              |
| ---------- | ------ | ------------------------------------------------- |
| -a 和 &&   | 逻辑与 | [ 1 -eq 1 -a 1 -ne 0 ] [ 1 -eq 1 ] && [ 1 -ne 0 ] |
| -o 和 \|\| | 逻辑或 | [ 1 -eq 1 -o 1 -ne 1 ]                            |

 ```shell
[ 33 <> 55 -a 33 -gt $[300/10] ]; echo $?
[ 33 -le 44 ] && [ 33 -gt $[999/100] ] ; echo $?
 
 
 ```

**特别说明：**

&&	前面的表达式为真，才会执行后面的代码

||	前面的表达式为假，才会执行后面的代码

;	只用于分割命令或表达式

#### ① 举例说明

- 数值比较

```shell
[root@server ~]# [ $(id -u) -eq 0 ] && echo "the user is admin"
[root@server ~]$ [ $(id -u) -ne 0 ] && echo "the user is not admin"
[root@server ~]$ [ $(id -u) -eq 0 ] && echo "the user is admin" || echo "the user is not admin"

[root@server ~]# uid=`id -u`
[root@server ~]# test $uid -eq 0 && echo this is admin
this is admin
[root@server ~]# [ $(id -u) -ne 0 ]  || echo this is admin
this is admin
[root@server ~]# [ $(id -u) -eq 0 ]  && echo this is admin || echo this is not admin
this is admin
[root@server ~]# su - stu1
[stu1@server ~]$ [ $(id -u) -eq 0 ]  && echo this is admin || echo this is not admin
this is not admin

 [ $(id -u) -eq 0 ] && echo 'root用户' || echo '普通用户'
```

- 类C风格的**数值**比较

```shell
注意：在(( ))中，=表示赋值；==表示判断
[root@server ~]# ((1==2));echo $?
[root@server ~]# ((1<2));echo $?
[root@server ~]# ((2>=1));echo $?
[root@server ~]# ((2!=1));echo $?
[root@server ~]# ((`id -u`==0));echo $?
 
[root@server ~]# ((a=123));echo $a
[root@server ~]# unset a
[root@server ~]# ((a==123));echo $?
```

- 字符串比较

```shell
注意：双引号引起来，看作一个整体；= 和 == 在 [ 字符串 ] 比较中都表示判断
[root@server ~]# a='hello world';b=world
[root@server ~]# [ $a = $b ];echo $?
[root@server ~]# [ "$a" = "$b" ];echo $?
[root@server ~]# [ "$a" != "$b" ];echo $?
[root@server ~]# [ "$a" !== "$b" ];echo $?        错误
[root@server ~]# [ "$a" == "$b" ];echo $?
[root@server ~]# test "$a" != "$b";echo $?


test  表达式
[ 表达式 ]
[[ 表达式 ]]

思考：[ ] 和 [[ ]] 有什么区别？
单个 [  ] 使用字符串对字符串必须加双引号
两个 [[  ]] 不用对字符串变量加双引号
两个 [[  ]] 里面可以使用 &&,||, 而单个不行
两个 [[  ]] 支持c风格
如:
	a=1; b=2
	[[ $a > $b ]] && echo $a || echo $b

[root@server ~]# a=
[root@server ~]# test -z $a;echo $?
[root@server ~]# a=hello
[root@server ~]# test -z $a;echo $?
[root@server ~]# test -n $a;echo $?
[root@server ~]# test -n "$a";echo $?

# [ '' = $a ];echo $?
-bash: [: : unary operator expected
2
# [[ '' = $a ]];echo $?
0


[root@server ~]# [ 1 -eq 0 -a 1 -ne 0 ];echo $?
[root@server ~]# [ 1 -eq 0 && 1 -ne 0 ];echo $?
[root@server ~]# [[ 1 -eq 0 && 1 -ne 0 ]];echo $?
```

#### ② 逻辑运算符总结

1. test exp1
2. [ exp1 ]
3. [[ exp1 ]]
4. (( 整数表达式exp1 ))
5. -s 判断文件不为空

1. 符号;和&&和||都可以用来分割命令或者表达式
2. 分号（;）完全不考虑前面的语句是否正确执行，都会执行;号后面的内容
3. `&&`符号，需要考虑&&前面的语句的正确性，前面语句正确执行才会执行&&后的内容；反之亦然
4. `||`符号，需要考虑||前面的语句的非正确性，前面语句执行错误才会执行||后内容；反之亦然
5. 如果&&和||一起出现，从左往右依次看，按照以上原则

# 二、流程控制语句

**关键词：选择（人生漫漫长路，我该何去何从:vertical_traffic_light:）**

## 1. 基本语法结构

### ㈠ if结构

**箴言1：只要正确，就要一直向前冲:v:**

**F**:表示false，为假

**T**:表示true，为真

```shell
if [ condition ];then
		command
		command
fi

if test 条件;then
	命令
fi

if [[ 条件 ]];then
	命令
fi

[ 条件 ] && command
```

![流程判断1](http://./%E6%B5%81%E7%A8%8B%E5%88%A4%E6%96%AD1.png?ynotemdtimestamp=1607388105444)

### ㈡ if...else结构

**箴言2：分叉路口，二选一**

```shell
if [ condition ];then
		command1
	else
		command2
fi

[ 条件 ] && command1 || command2
```

![流程判断2](http://xn--2-ke8a231dx9gztq.png/?ynotemdtimestamp=1607388105444)

**小试牛刀：**

让用户自己输入字符串，如果用户输入的是hello，请打印world，否则打印“请输入hello”

1. `read定义变量`
2. if....else...

```shell
#!/bin/env bash

read -p '请输入一个字符串:' str
if [ "$str" = 'hello' ];then
    echo 'world'
 else
    echo '请输入hello!'
fi

  1 #!/bin/env bash
  2
  3 read -p "请输入一个字符串:" str
  4 if [ "$str" = "hello" ]
  5 then
  6     echo world
  7 else
  8     echo "请输入hello!"
  9 fi
  
  echo "该脚本需要传递参数"
  1 if [ $1 = hello ];then
  2         echo "hello"
  3 else
  4         echo "请输入hello"
  5 fi

#!/bin/env bash

A=hello
B=world
C=hello

if [ "$1" = "$A" ];then
        echo "$B"
    else
        echo "$C"
fi


read -p '请输入一个字符串:' str;
 [ "$str" = 'hello' ] && echo 'world' ||  echo '请输入hello!'
```

### ㈢ if...elif...else结构

**箴言3：选择很多，能走的只有一条**

```shell
if [ condition1 ];then
		command1  	结束
	elif [ condition2 ];then
		command2   	结束
	else
		command3
fi
注释：
如果条件1满足，执行命令1后结束；如果条件1不满足，再看条件2，如果条件2满足执行命令2后结束；如果条件1和条件2都不满足执行命令3结束.
```

![流程判断3](http://xn--3-ke8a231dx9gztq.png/?ynotemdtimestamp=1607388105444)

### ㈣ 层层嵌套结构

**箴言4：多次判断，带你走出人生迷雾。**

```shell
if [ condition1 ];then
		command1		
		if [ condition2 ];then
			command2
		fi
 else
		if [ condition3 ];then
			command3
		elif [ condition4 ];then
			command4
		else
			command5
		fi
fi
注释：
如果条件1满足，执行命令1；如果条件2也满足执行命令2，如果不满足就只执行命令1结束；
如果条件1不满足，不看条件2；直接看条件3，如果条件3满足执行命令3；如果不满足则看条件4，如果条件4满足执行命令4；否则执行命令5
```

![流程判断4](http://xn--4-ke8a231dx9gztq.png/?ynotemdtimestamp=1607388105444)

## 2. 应用案例

### ㈠ 判断两台主机是否ping通

**需求：**判断当前主机是否和远程主机是否ping通

#### ① 思路

1. 使用哪个命令实现 `ping -c次数`
2. 根据命令的执行结果状态来判断是否通`$?`
3. 根据逻辑和语法结构来编写脚本(条件判断或者流程控制)

#### ② 落地实现

```shell
#!/bin/env bash
# 该脚本用于判断当前主机是否和远程指定主机互通

# 交互式定义变量，让用户自己决定ping哪个主机
read -p "请输入你要ping的主机的IP:" ip

# 使用ping程序判断主机是否互通
ping -c1 $ip &>/dev/null

if [ $? -eq 0 ];then
	echo "当前主机和远程主机$ip是互通的"
 else
 	echo "当前主机和远程主机$ip不通的"
fi

逻辑运算符
test $? -eq 0 &&  echo "当前主机和远程主机$ip是互通的" || echo "当前主机和远程主机$ip不通的"
```

### ㈡ 判断一个进程是否存在

**需求：**判断web服务器中httpd进程是否存在

#### ① 思路

1. 查看进程的相关命令 ps pgrep
2. 根据命令的返回状态值来判断进程是否存在
3. 根据逻辑用脚本语言实现

#### ② 落地实现

```shell
#!/bin/env bash
# 判断一个程序(httpd)的进程是否存在
pgrep httpd &>/dev/null
if [ $? -ne 0 ];then
	echo "当前httpd进程不存在"
else
	echo "当前httpd进程存在"
fi

或者
test $? -eq 0 && echo "当前httpd进程存在" || echo "当前httpd进程不存在"
```

#### ③ 补充命令

```shell
pgrep命令：以名称为依据从运行进程队列中查找进程，并显示查找到的进程id
选项
-o：仅显示找到的最小（起始）进程号;
-n：仅显示找到的最大（结束）进程号；
-l：显示进程名称；
-P：指定父进程号；pgrep -p 4764  查看父进程下的子进程id
-g：指定进程组；
-t：指定开启进程的终端；
-u：指定进程的有效用户ID。
```

### ㈢ 判断一个服务是否正常

**需求：**判断门户网站是否能够正常访问

#### ① 思路

1. 可以判断进程是否存在，用/etc/init.d/httpd status判断状态等方法

2. 最好的方法是

   直接去访问

   一下，通过访问成功和失败的返回值来判断

   - Linux环境，**wget curl ** *elinks -dump*

#### ② 落地实现

```shell
#!/bin/env bash
# 判断门户网站是否能够正常提供服务

#定义变量
web_server=www.itcast.cn
#访问网站
wget -P /shell/ $web_server &>/dev/null
[ $? -eq 0 ] && echo "当前网站服务是ok" && rm -f /shell/index.* || echo "当前网站服务不ok，请立刻处理"
```

## 3. 课堂练习

### ㈠ 判断用户是否存在

**需求1：**输入一个用户，用脚本判断该用户是否存在

```shell
 #!/bin/env bash
  2 read -p "请输入一个用户名：" user_name
  3 id $user_name &>/dev/null
  4 if [ $? -eq 0 ];then
  6     echo "该用户存在！"
  7 else
  8     echo "用户不存在！"
  9 fi
  
  
#!/bin/bash
# 判断 用户（id） 是否存在
read -p "输入壹个用户：" id
id $id &> /dev/null
if [ $? -eq 0 ];then
        echo "该用户存在"
else
        echo "该用户不存在"
fi

#!/bin/env bash
read -p "请输入你要查询的用户名:" username
grep -w $username /etc/passwd &>/dev/null
if [ $? -eq 0 ]
then
    echo "该用户已存在"
else
    echo "该用户不存在"
fi

#!/bin/bash
read -p "请输入你要检查的用户名：" name
id $name &>/dev/null
if [ $? -eq 0 ]
then
echo 用户"$name"已经存在
else
echo 用户"$name"不存在
fi

#!/bin/env bash
#判断用户是否存在
read -p "请写出用户名" id
id $id
if [ $? -eq 0 ];then
        echo "用户存在"
else
        echo "用户不存在"
fi

#!/bin/env bash
read -p '请输入用户名:' username
id $username &>/dev/null
[ $? -eq 0 ] && echo '用户存在' || echo '不存在'
```

### ㈡ 判断软件包是否安装

**需求2：**用脚本判断一个软件包是否安装，如果没安装则安装它（假设本地yum已配合）

```shell
 #!/bin/env bash

 read -p '请输入要查询的软件: ' soft
 rpm -qa|grep $soft

if [[ $? == 0 ]]; then
    echo "软件 $soft 已经安装"
else 
    echo "======准备安装软件 $soft"
    sudo yum install -y $soft
    echo "======软件 $soft 安装完成"
fi
```

### ㈢ 判断当前主机的内核版本

**需求3：**判断当前内核主版本是否为2，且次版本是否大于等于6；如果都满足则输出当前内核版本

```shell
思路：
1. 先查看内核的版本号	uname -r
2. 先将内核的版本号保存到一个变量里，然后再根据需求截取出该变量的一部分：主版本和次版本
3. 根据需求进步判断


#!/bin/bash
kernel=`uname -r`
var1=`echo $kernel|cut -d. -f1`
var2=`echo $kernel|cut -d. -f2`
test $var1 -eq 2 -a $var2 -ge 6 && echo $kernel || echo "当前内核版本不符合要求"
或者
[ $var1 -eq 2 -a $var2 -ge 6 ] && echo $kernel || echo "当前内核版本不符合要求"
或者
[[ $var1 -eq 2 && $var2 -ge 6 ]] && echo $kernel || echo "当前内核版本不符合要求"

或者
#!/bin/bash
kernel=`uname -r`
test ${kernel:0:1} -eq 2 -a ${kernel:2:1} -ge 6 && echo $kernel || echo '不符合要求'

其他命令参考：
uname -r|grep ^2.[6-9] || echo '不符合要求'

# 自己实现
#!/bin/env bash

# 判断内核版本是否 3.10, 或者传入需要的内核版本

mainVersion=3
minorVersion=10

if [[ -n $1 ]]; then 
    mainVersion="$(echo $1|cut -d. -f1)"
    minorVersion="$(echo $1|cut -d. -f2)"
fi

kernel=$(uname -r)

var1=$(echo $kernel|cut -d. -f1)
var2=$(echo $kernel|cut -d. -f2)

[[ $var1 == "$mainVersion" && $var2 == "$minorVersion" ]] && echo "当前内核 $var1.$var2 符合要求"  || echo "当前内核 $var1.$var2 不符合要求, 需要 $mainVersion.$minorVersion "
```



- 一、for循环语句
  - \1. for循环语法结构
    - [㈠ 列表循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-列表循环)
    - [㈡ 不带列表循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-不带列表循环)
    - [㈢ 类C风格的for循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-类c风格的for循环)
  - \2. 应用案例
    - ㈠ 脚本计算1-100奇数和
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路)
      - [② 落地实现（条条大路通罗马）](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现条条大路通罗马)
      - [③ 循环控制语句](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-循环控制语句)
    - ㈡ 判断所输整数是否为质数
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-2)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现)
    - ㈢ 批量创建用户
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-3)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-2)
  - \3. 课堂练习
    - [㈠ 批量创建用户](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-批量创建用户)
    - [㈡ 局域网内脚本检查主机网络通讯](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-局域网内脚本检查主机网络通讯)
    - [㈢ 判断闰年](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-判断闰年)
  - \2. 应用案例
    - [㈠ 脚本计算1-50偶数和](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-脚本计算1-50偶数和)
    - ㈡ 脚本同步系统时间
      - [① 具体需求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-具体需求)
      - [② 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-思路)
      - [③ 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-落地实现)
  - [1. until语法结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-until语法结构)
  - \2. 应用案例
    - [㈡ 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-思路)
    - [㈢ 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-落地实现)
- [四、课后作业](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F57E7E4739A804C0DA2FE8B40062A8D88%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#四-课后作业)

\#本机课程目标



- 掌握for循环语句的基本语法结构
- 掌握while和until循环语句的基本语法结构

# 一、for循环语句

**关键词：爱的魔力转圈圈**:innocent:

## 1. for循环语法结构

### ㈠ 列表循环

> 列表for循环：用于将一组命令执行**已知的次数**

- **基本语法格式**

```shell
for variable in {list}
     do
          command 
          command
          …
     done
或者
for variable in a b c
     do
         command
         command
     done
```

- **举例说明**

```
# for var in {1..10};do echo $var;done
# for var in 1 2 3 4 5;do echo $var;done
# for var in `seq 10`;do echo $var;done
# for var in $(seq 10);do echo $var;done
# for var in {0..10..2};do echo $var;done
# for var in {2..10..2};do echo $var;done
# for var in {10..1};do echo $var;done
# for var in {10..1..-2};do echo $var;done
# for var in `seq 10 -2 1`;do echo $var;done
```

### ㈡ 不带列表循环

> 不带列表的for循环执行时由**用户指定参数和参数的个数**

- **基本语法格式**

```
for variable
    do
        command 
        command
        …
   done
```

- **举例说明**

```
#!/bin/bash
for var
do
echo $var
done

echo "脚本后面有$#个参数"
```

### ㈢ 类C风格的for循环

- **基本语法结构**

```
for(( expr1;expr2;expr3 ))
	do
		command
		command
		…
	done
for (( i=1;i<=5;i++))
	do
		echo $i
	done


expr1：定义变量并赋初值
expr2：决定是否进行循环（条件）
expr3：决定循环变量如何改变，决定循环什么时候退出
```

- **举例说明**

```
 # for ((i=1;i<=5;i++));do echo $i;done
 # for ((i=1;i<=10;i+=2));do echo $i;done
 # for ((i=2;i<=10;i+=2));do echo $i;done
```

## 2. 应用案例

### ㈠ 脚本计算1-100奇数和

#### ① 思路

1. 定义一个变量来保存奇数的和 sum=0
2. 找出1-100的奇数，保存到另一个变量里 i=遍历出来的奇数
3. 从1-100中找出奇数后，再相加，然后将和赋值给变量 循环变量 for
4. 遍历完毕后，将sum的值打印出来

#### ② 落地实现（条条大路通罗马）

```
#!/bin/env bash
# 计算1-100的奇数和
# 定义变量来保存奇数和
sum=0

#for循环遍历1-100的奇数，并且相加，把结果重新赋值给sum

for i in {1..100..2}
do
	let sum=$sum+$i
done
#打印所有奇数的和
echo "1-100的奇数和是:$sum"


方法1：
#!/bin/bash
sum=0
for i in {1..100..2}
do
	sum=$[$i+$sum]
done
echo "1-100的奇数和为:$sum"

方法2：
#!/bin/bash
sum=0
for ((i=1;i<=100;i+=2))
do
	let sum=$i+$sum
done
echo "1-100的奇数和为:$sum"

方法3：
#!/bin/bash
sum=0
for ((i=1;i<=100;i++))
do
	if [ $[$i%2] -ne 0 ];then
	let sum=$sum+$i
	fi
或者
test $[$i%2] -ne 0 && let sum=$sum+$i

done
echo "1-100的奇数和为:$sum"

方法4：
sum=0
for ((i=1;i<=100;i++))
do
	if [ $[$i%2] -eq 0 ];then
	continue
	else
	let sum=$sum+$i
	fi
done
echo "1-100的奇数和为:$sum"

#!/bin/bash
sum=0
for ((i=1;i<=100;i++))
do
	test $[$i%2] -eq 0 && continue || let sum=sum+$i
done
echo "1-100的奇数和是:$sum"
```

#### ③ 循环控制语句

**循环体：** do....done之间的内容

- continue：继续；表示循环体内下面的代码不执行，重新开始下一次循环
- break：打断；马上停止执行本次循环，执行循环体后面的代码
- exit：表示直接跳出程序

```
[root@server ~]# cat for5.sh 
#!/bin/bash
for i in {1..5}
do
	test $i -eq 2 && break || touch /tmp/file$i
done
echo hello hahahah
```

### ㈡ 判断所输整数是否为质数

**质数(素数)：**只能被1和它本身整除的数叫质数。 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97

#### ① 思路

1. 让用户输入一个数，保存到一个变量里
2. 如果能被其他数整除就不是质数——>`$num%$i`是否等于0	`$i=2到$num-1`
3. 如果输入的数是1或者2取模根据上面判断又不符合，所以先排除1和2
4. 测试序列从2开始，输入的数是4——>得出结果`$num`不能和`$i`相等，并且`$num`不能小于`$i`

#### ② 落地实现

```
#!/bin/bash
read -p "请输入一个正整数字:" number

[ $number -eq 1 ] && echo "$number不是质数" && exit
[ $number -eq 2 ] && echo "$number是质数" && exit

for i in `seq 2 $[$number-1]`
	do
	 [ $[$number%$i] -eq 0 ] && echo "$number不是质数" && exit
	done
echo "$number是质数" && exit
```

### ㈢ 批量创建用户

**需求：**批量加5个新用户，以u1到u5命名，并统一加一个新组，组名为class,统一改密码为123

#### ① 思路

1. 添加用户的命令
2. 判断class组是否存在
3. 根据题意，判断该脚本循环5次来添加用户
4. 给用户设置密码，应该放到循环体里面

#### ② 落地实现

```
方法一：
#!/bin/bash
#判断class组是否存在
grep -w class /etc/group &>/dev/null
[ $? -ne 0 ] && groupadd class
#批量创建5个用户
for i in {1..5}
do
	useradd -G class u$i
	echo 123|passwd --stdin u$i
done

方法二：
#!/bin/bash
#判断class组是否存在
cut -d: -f1 /etc/group|grep -w class &>/dev/null
[ $? -ne 0 ] && groupadd class

#循环增加用户，循环次数5次，for循环,给用户设定密码
for ((i=1;i<=5;i++))
do
	useradd u$i -G class
	echo 123|passwd --stdin u$i
done


方法三：
#!/bin/bash
grep -w class /etc/group &>/dev/null
test $? -ne 0 && groupadd class
或者
groupadd class &>/dev/null

for ((i=1;i<=5;i++))
do
useradd -G class u$i && echo 123|passwd --stdin u$i
done
```

## 3. 课堂练习

### ㈠ 批量创建用户

**需求1:**批量新建5个用户stu1~stu5，要求这几个用户的家目录都在/rhome.

```
#!/bin/bash
#判断/rhome是否存在
[ -f /rhome ] && mv /rhome /rhome.bak
test ! -f /rhome -a ! -d /rhome && mkdir /rhome
或者
[ -f /rhome ] && mv /rhome /rhome.bak || [ ! -d /rhome ] && mkdir /rhome 
#创建用户，循环5次
for ((i=1;i<=5;i++))
do
	useradd -d /rhome/stu$i stu$i
	echo 123|passwd --stdin stu$i
done
```

### ㈡ 局域网内脚本检查主机网络通讯

**需求2：**

写一个脚本，局域网内，把能ping通的IP和不能ping通的IP分类，并保存到两个文本文件里

以10.1.1.1~10.1.1.10为例

```
#!/bin/bash
#定义变量
ip=10.1.1
#循环去ping主机的IP
for ((i=1;i<=10;i++))
do
	ping -c1 $ip.$i &>/dev/null
	if [ $? -eq 0 ];then
		echo "$ip.$i is ok" >> /tmp/ip_up.txt
	else
		echo "$ip.$i is down" >> /tmp/ip_down.txt
	fi
	或者
	[ $? -eq 0 ] && echo "$ip.$i is ok" >> /tmp/ip_up.txt || echo "$ip.$i is down" >> /tmp/ip_down.txt
done

[root@server shell03]# time ./ping.sh         

real    0m24.129s
user    0m0.006s
sys     0m0.005s
```

**延伸扩展：shell脚本并发**

```
并行执行：
{程序}&表示将程序放到后台并行执行，如果需要等待程序执行完毕再进行下面内容，需要加wait

#!/bin/bash
#定义变量
ip=10.1.1
#循环去ping主机的IP
for ((i=1;i<=10;i++))
do
{

        ping -c1 $ip.$i &>/dev/null
        if [ $? -eq 0 ];then
                echo "$ip.$i is ok" >> /tmp/ip_up.txt
        else
                echo "$ip.$i is down" >> /tmp/ip_down.txt
        fi
}&
done
wait
echo "ip is ok...."

[root@server ~]# time ./ping.sh 
ip is ok...

real    0m3.091s
user    0m0.001s
sys     0m0.008s
```

### ㈢ 判断闰年

**需求3：**

输入一个年份，判断是否是润年（能被4整除但不能被100整除，或能被400整除的年份即为闰年）

```
#!/bin/bash
read -p "Please input year:(2017)" year
if [ $[$year%4] -eq 0 -a $[$year%100] -ne 0 ];then
	echo "$year is leap year"
elif [ $[$year%400] -eq 0 ];then
	echo "$year is leap year"
else
	echo "$year is not leap year"
fi
```

\##4. 总结

- FOR循环语法结构
- FOR循环可以结合条件判断和流程控制语句
  - do ......done 循环体
  - 循环体里可以是命令集合，再加上条件判断以及流程控制
- 控制循环语句
  - continue 继续，跳过本次循环，继续下一次循环
  - break 打断，跳出循环，执行循环体外的代码
  - exit 退出，直接退出程序

\#二、while循环语句

**特点：**条件为真就进入循环；条件为假就退出循环

\##1. while循环语法结构

```
while 表达式
	do
		command...
	done
	
while  [ 1 -eq 1 ] 或者 (( 1 > 2 ))
  do
     command
     command
     ...
 done
```

**循环打印1-5数字**

```
FOR循环打印：
for ((i=1;i<=5;i++))
do
	echo $i
done

while循环打印：
i=1
while [ $i -le 5 ]
do
	echo $i
	let i++
done
```

## 2. 应用案例

### ㈠ 脚本计算1-50偶数和

```
#!/bin/bash
#定义变量
sum=0
i=2
#循环打印1-50的偶数和并且计算后重新赋值给sum
while [ $i -le 50 ]
do
	let sum=sum+i
	let i+=2
done
#打印sum的值
echo "1-50的偶数和为:$sum"
```

### ㈡ 脚本同步系统时间

#### ① 具体需求

1. 写一个脚本，30秒同步一次系统时间，时间同步服务器10.1.1.1
2. 如果同步失败，则进行邮件报警,每次失败都报警
3. 同步成功,也进行邮件通知,但是成功100次才通知一次

#### ② 思路

1. 每个30s同步一次时间，该脚本是一个死循环
2. 同步失败发送邮件
3. 同步成功100次发送邮件

#### ③ 落地实现

```
#!/bin/bash
#定义变量
count=0
ntp_server=10.1.1.1
while true
do
	rdate -s $ntp-server &>/dev/null
	if [ $? -ne 0 ];then
		echo "system date failed" |mail -s 'check system date'  root@localhost	
	else
		let count++
		if [ $[$count%100] -eq 0 ];then
		echo "system date successfull" |mail -s 'check system date'  root@localhost && count=0
		fi
	fi
sleep 3
done

以上脚本还有更多的写法，课后自己完成
```

\#三、until循环

**特点**：条件为假就进入循环；条件为真就退出循环

## 1. until语法结构

```
until expression   [ 1 -eq 1 ]  (( 1 >= 1 ))
	do
		command
		command
		...
	done
	
```

**打印1-5数字**

```
i=1
while [ $i -le 5 ]
do
	echo $i
	let i++
done

i=1
until [ $i -gt 5 ]
do
	echo $i
	let i++
done
```

## 2. 应用案例

\###㈠ 具体需求

1. 使用until语句批量创建10个用户，要求stu1—stu5用户的UID分别为1001—1005；
2. stu6~stu10用户的家目录分别在/rhome/stu6—/rhome/stu10

### ㈡ 思路

### ㈢ 落地实现

```
#!/bin/bash
i=1
until [ $i -gt 10 ]
do
	if [ $i -le 5 ];then
		useradd -u $[1000+$i] stu$i && echo 123|passwd --stdin stu$i
	else
		[ ! -d /rhome ] && mkdir /rhome
		useradd -d /rhome/stu$i stu$i && echo 123|passwd --stdin stu$i		
	fi
let i++
done
```

# 四、课后作业

1. 判断/tmp/run目录是否存在，如果不存在就建立，如果存在就删除目录里所有文件
2. 输入一个路径，判断路径是否存在，而且输出是文件还是目录，如果是链接文件，还得输出是 有效的连接还是无效的连接
3. 交互模式要求输入一个ip，然后脚本判断这个IP 对应的主机是否 能ping 通，输出结果类似于： Server 10.1.1.20 is Down! 最后要求把结果邮件到本地管理员root@localhost mail01@localhost
4. 写一个脚本/home/program，要求当给脚本输入参数hello时，脚本返回world,给脚本输入参数world时，脚本返回hello。而脚本没有参数或者参数错误时，屏幕上输出“usage:/home/program hello or world”
5. 写一个脚本自动搭建nfs服务





- 一、随机数
  - [1. 如何生成随机数？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-如何生成随机数)
  - \2. 实战案例
    - ㈠ 随机产生以139开头的电话号码
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现)
    - ㈡ 随机抽出5位幸运观众
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-2)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-2)
    - ㈢ 批量创建用户(密码随机产生)
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-3)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-3)
- 二、嵌套循环
  - - [㈠ 打印指定图案](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-打印指定图案)
    - [㈡ 落地实现1](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-落地实现1)
    - [㈢ 落地实现2](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-落地实现2)
- 三、阶段性补充总结
  - [1、变量定义](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-变量定义)
  - [2. 流程控制语句](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-流程控制语句)
  - [3. 循环语句](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-循环语句)
  - \4. 影响shell程序的内置命令
    - [㈠ 具体需求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-具体需求)
    - ㈢ 落地实现
      - [② 最终实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE68AFB232754CC3B69719EA221D1357%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-最终实现)

\#课程目标



- 掌握for循环语句的基本语法结构
- 掌握while和until循环语句的基本语法结构
- 能会使用RANDOM产生随机数
- 理解嵌套循环

# 一、随机数

**关键词：一切都是未知数，永远不知道明天会抽什么风**:wind_chime::sweat_smile:

## 1. 如何生成随机数？

**系统变量**：**RANDOM**，默认会产生0~32767的随机整数

**前言：**要想调用变量，不管你是什么变量都要给钱，而且是美元:heavy_dollar_sign:

```
打印一个随机数
echo $RANDOM
查看系统上一次生成的随机数
# set|grep RANDOM
RANDOM=28325

产生0~1之间的随机数
echo $[$RANDOM%2]

产生0~2之间的随机数
echo $[$RANDOM%3]

产生0~3之间的随机数
echo $[$RANDOM%4]

产生0~9内的随机数
echo $[$RANDOM%10]

产生0~100内的随机数
echo $[$RANDOM%101]


产生50-100之内的随机数
echo $[$RANDOM%51+50]

产生三位数的随机数
echo $[$RANDOM%900+100]
```

## 2. 实战案例

### ㈠ 随机产生以139开头的电话号码

**具体需求1：**

写一个脚本，产生一个phonenum.txt文件，随机产生以139开头的手机号1000个，每个一行。

#### ① 思路

1. 产生1000个电话号码，脚本需要循环1000次 `FOR WHILE UNTIL`
2. 139+8位,后8位随机产生，可以让每一位数字都随机产生 `echo $[$RANDOM%10]`
3. 将随机产生的数字分别保存到变量里，然后加上139保存到文件里

#### ② 落地实现

```
#!/bin/env bash
#产生1000个以139开头的电话号码并保存文件phonenum.txt
file=/shell03/phonenum.txt
for ((i=1;i<=1000;i++))
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> $file
done


#!/bin/bash
# random phonenum
# 循环1000次产生电话号码并保存到文件
for i in {1..1000}
do
	n1=$[RANDOM%10]
	n2=$[RANDOM%10]
	n3=$[RANDOM%10]
	n4=$[RANDOM%10]
	n5=$[RANDOM%10]
	n6=$[RANDOM%10]
	n7=$[RANDOM%10]
	n8=$[RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
done

#!/bin/bash
i=1
while [ $i -le 1000 ]
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
	let i++
done

continue:继续，跳过本次循环，执行下一次循环
break:打断，执行循环体外的代码do..done外
exit:退出程序


#!/bin/bash
for i in {1..1000}
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
done

#!/bin/bash
#create phone num file
for ((i=1;i<=1000;i++))
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" |tee -a phonenum.txt
done

#!/bin/bash
count=0
while true
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" |tee -a phonenum.txt && let count++
	if [ $count -eq 1000 ];then
		break
	fi
done
```

### ㈡ 随机抽出5位幸运观众

**具体需求：**

1. 在上面的1000个手机号里抽奖5个幸运观众，显示出这5个幸运观众。
2. 但只显示头3个数和尾号的4个数，中间的都用*代替

#### ① 思路

1. 确定幸运观众所在的行	`0-1000 随机找出一个数字 $[$RANDOM%1000+1]`
2. 将电话号码提取出来 `head -随机产生行号 phonenum.txt |tail -1`
3. 显示前3个和后4个数到屏幕 `echo 139****`

#### ② 落地实现

```
#!/bin/bash
#定义变量
phone=/shell03/phonenum.txt
#循环抽出5位幸运观众
for ((i=1;i<=5;i++))
do
	#定位幸运观众所在行号
	line=`wc -l $phone |cut -d' ' -f1`
	luck_line=$[RANDOM%$line+1]
	#取出幸运观众所在行的电话号码
	luck_num=`head -$luck_line $phone|tail -1`
	#显示到屏幕
	echo "139****${luck_num:7:4}"
	echo $luck_num >> luck.txt
	#删除已经被抽取的幸运观众号码
	#sed -i "/$luck_num/d" $phone
done


#!/bin/bash
file=/shell04/phonenum.txt
for i in {1..5}
do
	file_num=`wc -l $file |cut -d' ' -f1`
	line=`echo $[$RANDOM%$file_num+1]`
	luck=`head -n $line  $file|tail -1`
	echo "139****${luck:7:4}" && echo $luck >> /shell04/luck_num.txt
done


#!/bin/bash
for ((i=1;i<=5;i++))
do
file=phonenum.txt
line=`cat phonenum.txt |wc -l`	1000
luckline=$[$RANDOM%$line+1]
phone=`cat $file|head -$luckline|tail -1`
echo "幸运观众为:139****${phone:7:4}"
done


或者
#!/bin/bash
# choujiang
phone=phonenum.txt
for ((i=1;i<=5;i++))
do
	num=`wc -l phonenum.txt |cut -d' ' -f1`
	line=`echo $[$RANDOM%$num+1]`
	luck=`head -$line $phone |tail -1`
	sed -i "/$luck/d" $phone
	echo "幸运观众是:139****${luck:7:4}"
done
```

### ㈢ 批量创建用户(密码随机产生)

**需求：**批量创建5个用户，每个用户的密码为一个随机数

#### ① 思路

1. 循环5次创建用户
2. 产生一个密码文件来保存用户的随机密码
3. 从密码文件中取出随机密码赋值给用户

#### ② 落地实现

```
#!/bin/bash
#crate user and set passwd
#产生一个保存用户名和密码的文件
echo user0{1..5}:itcast$[$RANDOM%9000+1000]#@~|tr ' ' '\n'>> user_pass.file

#循环创建5个用户
for ((i=1;i<=5;i++))
do
	user=`head -$i user_pass.file|tail -1|cut -d: -f1`
	pass=`head -$i user_pass.file|tail -1|cut -d: -f2`
	useradd $user
	echo $pass|passwd --stdin $user
done

或者
for i in `cat user_pass.file`
do
	user=`echo $i|cut -d: -f1`
	pass=`echo $i|cut -d: -f2`
	useradd $user
	echo $pass|passwd --stdin $user
done

#!/bin/bash
#crate user and set passwd
#产生一个保存用户名和密码的文件
echo user0{1..3}:itcast$[$RANDOM%9000+1000]#@~|tr ' ' '\n'|tr ':' ' ' >> user_pass.file
#循环创建5个用户
while read user pass
do
useradd $user
echo $pass|passwd --stdin $user
done < user_pass.file


pwgen工具产生随机密码：
[root@server shell04]# pwgen -cn1 12
Meep5ob1aesa
[root@server shell04]# echo user0{1..3}:$(pwgen -cn1 12)
user01:Bahqu9haipho user02:Feiphoh7moo4 user03:eilahj5eth2R
[root@server shell04]# echo user0{1..3}:$(pwgen -cn1 12)|tr ' ' '\n'
user01:eiwaShuZo5hi
user02:eiDeih7aim9k
user03:aeBahwien8co
```

# 二、嵌套循环

**关键字：大圈套小圈**

:clock3:**时钟**：分针与秒针，秒针转⼀圈（60格），分针转1格。循环嵌套就是外层循环⼀次，内层循环⼀轮。

1. 一个循环体内又包含另一个**完整**的循环结构，称为循环的嵌套。
2. 每次外部循环都会触发内部循环，直至内部循环完成，才接着执行下一次的外部循环。
3. for循环、while循环和until循环可以**相互**嵌套。

\##1. 应用案例

### ㈠ 打印指定图案

```
1
12
123
1234
12345

5
54
543
5432
54321
```

### ㈡ 落地实现1

```
X轴：
for ((i=1;i<=5;i++));do echo -n $i;done
Y轴：
负责打印换行

#!/bin/bash
for ((y=1;y<=5;y++))
do
	for ((x=1;x<=$y;x++))
	do
		echo -n $x
	done
echo
done

#!/bin/bash
for ((y=1;y<=5;y++))
do
	x=1
	while [ $x -le $y ]
		do
		echo -n $x
		let x++
		done
echo
done
```

### ㈢ 落地实现2

```
Y轴：打印换行
X轴：打印数字 5-1

#!/bin/bash
y=5
while (( $y >= 1 ))
do
	for ((x=5;x>=$y;x--))
	do
		echo -n $x
	done
echo
let y--
done


#!/bin/bash
for (( y=5;y>=1;y--))
do
	for (( x=5;x>=$y;x--))
	do
	echo -n $x
	done
echo
done

#!/bin/bash
y=5
while [ $y -ge 1 ]
do
	for ((x=5;x>=$y;x--))
	do
	echo -n $x
	done
echo
let y--
done


#!/bin/bash
y=1
until (( $y >5 ))
do
	x=1
	while (( $x <= $y ))
	do
	echo -n $[6-$x]
	let x++
	done	
echo
let y++
done


课后打印：
54321
5432
543
54
5
```

\##2. 课堂练习

**打印九九乘法表（三种方法）**

```
1*1=1

1*2=2   2*2=4

1*3=3   2*3=6   3*3=9

1*4=4   2*4=8   3*4=12  4*4=16

1*5=5   2*5=10  3*5=15  4*5=20  5*5=25

1*6=6   2*6=12  3*6=18  4*6=24  5*6=30  6*6=36

1*7=7   2*7=14  3*7=21  4*7=28  5*7=35  6*7=42  7*7=49

1*8=8   2*8=16  3*8=24  4*8=32  5*8=40  6*8=48  7*8=56  8*8=64

1*9=9   2*9=18  3*9=27  4*9=36  5*9=45  6*9=54  7*9=63  8*9=72  9*9=81


Y轴：循环9次，打印9行空行
X轴：循环次数和Y轴相关；打印的是X和Y轴乘积 $[] $(())

#!/bin/bash
for ((y=1;y<=9;y++))
do
	for ((x=1;x<=$y;x++))
	do
		echo -ne "$x*$y=$[$x*$y]\t"
	done
echo
echo
done


#!/bin/bash
y=1
while [ $y -le 9 ]
do
        x=1
        while [ $x -le $y ]
        do
                echo -ne "$x*$y=$[$x*$y]\t"
                let x++
        done
echo
echo
let y++
done

或者
#!/bin/bash
for i in `seq 9`
do
    for j in `seq $i`
    do
        echo -ne  "$j*$i=$[$i*$j]\t"
    done
echo
echo
done
或者
#!/bin/bash
y=1
until [ $y -gt 9 ]
do
        x=1
        until [ $x -gt $y ]
        do
                echo -ne "$x*$y=$[ $x*$y ]\t"
                let x++
        done
echo
echo
let y++
done
```

# 三、阶段性补充总结

## 1、变量定义

```

```

## 2. 流程控制语句

```

```

## 3. 循环语句

```

```

## 4. 影响shell程序的内置命令

```
exit			退出整个程序
break		   结束当前循环，或跳出本层循环
continue 	忽略本次循环剩余的代码，直接进行下一次循环
shift			使位置参数向左移动，默认移动1位，可以使用shift 2

:
true
false
```

**举例说明：**

```
以下脚本都能够实现用户自定义输入数字，然后脚本计算和：
[root@MissHou shell04]# cat shift.sh 
#!/bin/bash
sum=0
while [ $# -ne 0 ]
do
let sum=$sum+$1
shift
done
echo sum=$sum


[root@MissHou shell04]# cat for3.sh 
#!/bin/bash
sum=0
for i
do
let sum=$sum+$i
done
echo sum=$sum
```

\##4. 补充扩展expect

expect 自动应答 tcl语言

**需求1：**A远程登录到server上什么都不做

```
#!/usr/bin/expect
# 开启一个程序
spawn ssh root@10.1.1.1
# 捕获相关内容
expect {
        "(yes/no)?" { send "yes\r";exp_continue }
        "password:" { send "123456\r" }
}
interact   //交互

脚本执行方式：
# ./expect1.sh
# /shell04/expect1.sh
# expect -f expect1.sh

1）定义变量
#!/usr/bin/expect
set ip 10.1.1.2
set pass 123456
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}
interact


2）使用位置参数
#!/usr/bin/expect
set ip [ lindex $argv 0 ]
set pass [ lindex $argv 1 ]
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}
interact
```

**需求2：**A远程登录到server上操作

```
#!/usr/bin/expect
set ip 10.1.1.1
set pass 123456
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}

expect "#"
send "rm -rf /tmp/*\r"
send "touch /tmp/file{1..3}\r"
send "date\r"
send "exit\r"
expect eof
```

**需求3：**shell脚本和expect结合使用，在多台服务器上创建1个用户

```
[root@server shell04]# cat ip.txt 
10.1.1.1 123456
10.1.1.2 123456


1. 循环
2. 登录远程主机——>ssh——>从ip.txt文件里获取IP和密码分别赋值给两个变量
3. 使用expect程序来解决交互问题

#!/bin/bash
# 循环在指定的服务器上创建用户和文件
while read ip pass
do
	/usr/bin/expect <<-END &>/dev/null
	spawn ssh root@$ip
	expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
	}
	expect "#" { send "useradd yy1;rm -rf /tmp/*;exit\r" }
	expect eof
	END
done < ip.txt



#!/bin/bash
cat ip.txt|while read ip pass
do
        {

        /usr/bin/expect <<-HOU
        spawn ssh root@$ip
        expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
        }
        expect "#"
        send "hostname\r"
        send "exit\r"
        expect eof
        HOU

        }&
done
wait
echo "user is ok...."


或者
#!/bin/bash
while read ip pass
do
        {

        /usr/bin/expect <<-HOU
        spawn ssh root@$ip
        expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
        }
        expect "#"
        send "hostname\r"
        send "exit\r"
        expect eof
        HOU

        }&
done<ip.txt
wait
echo "user is ok...."
```

\#四、综合案例

\##1. 实战案例1

### ㈠ 具体需求

写一个脚本，将跳板机上yunwei用户的公钥推送到局域网内可以ping通的所有机器上

说明：主机和密码文件已经提供

10.1.1.1:123456

10.1.1.2:123456

\###㈡ 案例分析

- **关闭防火墙和selinux**
- 判断ssh服务是否开启（默认ok）
- 循环判断给定密码文件里的哪些IP是可以ping通
- 判断IP是否可以ping通——>$?—>流程控制语句
- 密码文件里获取主机的IP和密码保存变量
- 判断公钥是否存在—>不存在创建它
- ssh-copy-id 将跳板机上的yunwei用户的公钥推送到远程主机—>expect解决交互
- 将ping通的主机IP单独保存到一个文件
- 测试验证

### ㈢ 落地实现

\####① 代码拆分

```
1.判断yunwei用户的公钥是否存在
[ ! -f /hoem/yunwei/.ssh/id_rsa ] && ssh-keygen -P '' -f ./id_rsa

2.获取IP并且判断是否可以ping通
1)主机密码文件ip.txt
	10.1.1.1:123456
   10.1.1.2:123456
2) 循环判断主机是否ping通
	tr ':' ' ' < ip.txt|while read ip pass
	do
		ping -c1 $ip &>/dev/null
      if [ $? -eq 0 ];then
      	推送公钥
      fi
	done
   


3.非交互式推送公钥
/usr/bin/expect <<-END &>/dev/null
        spawn ssh-copy-id root@$ip
        expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
        }
        expect eof
	END
```

#### ② 最终实现

1. **环境准备**

```
jumper-server	有yunwei用户

yunwei用户sudo授权：
visudo
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
yunwei  ALL=(root)      NOPASSWD:ALL,!/sbin/shutdown,!/sbin/init,!/bin/rm -rf /

解释说明：
1）第一个字段yunwei指定的是用户：可以是用户名，也可以是别名。每个用户设置一行，多个用户设置多行，也可以将多个用户设置成一个别名后再进行设置。
2）第二个字段ALL指定的是用户所在的主机：可以是ip,也可以是主机名，表示该sudo设置只在该主机上生效，ALL表示在所有主机上都生效！限制的一般都是本机，也就是限制使用这个文件的主机;一般都指定为"ALL"表示所有的主机，不管文件拷到那里都可以用。比如：10.1.1.1=...则表示只在当前主机生效。
3）第三个字段（root）括号里指定的也是用户：指定以什么用户身份执行sudo，即使用sudo后可以享有所有root账号下的权限。如果要排除个别用户，可以在括号内设置，比如ALL=(ALL,!oracle,!pos)。
4）第四个字段ALL指定的是执行的命令：即使用sudo后可以执行所有的命令。除了关机和删除根内容以外；也可以设置别名。NOPASSWD: ALL表示使用sudo的不需要输入密码。
5）也可以授权给一个用户组
	%admin ALL=(ALL) ALL	表示admin组里的所有成员可以在任何主机上以任何用户身份执行任何命令
```

1. **脚本实现**

```
#!/bin/bash
#判断公钥是否存在
[ ! -f /home/yunwei/.ssh/id_rsa ] && ssh-keygen -P '' -f ~/.ssh/id_rsa

#循环判断主机是否ping通，如果ping通推送公钥
tr ':' ' ' < /shell04/ip.txt|while read ip pass
do
{
        ping -c1 $ip &>/dev/null
        if [ $? -eq 0 ];then
        echo $ip >> ~/ip_up.txt
        /usr/bin/expect <<-END &>/dev/null
         spawn ssh-copy-id root@$ip
         expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
                }
        expect eof
        END
        fi
}&
done
wait
echo "公钥已经推送完毕，正在测试...."
#测试验证
remote_ip=`tail -1 ~/ip_up.txt`
ssh root@$remote_ip hostname &>/dev/null
test $? -eq 0 && echo "公钥成功推送完毕"
```

\##2. 实战案例2

写一个脚本，统计web服务的不同连接状态个数

```
#!/bin/bash
#count_http_80_state
#统计每个状态的个数
declare -A array1
states=`ss -ant|grep 80|cut -d' ' -f1`
for i in $states
do
        let array1[$i]++
done
#通过遍历数组里的索引和元素打印出来
for j in ${!array1[@]}
do
        echo $j:${array1[$j]}
done
```

\#五、课后实战

1、将/etc/passwd里的用户名分类，分为管理员用户，系统用户，普通用户。 2、写一个倒计时脚本，要求显示离2019年1月1日（元旦）的凌晨0点，还有多少天，多少时，多少分，多少秒。 3、写一个脚本把一个目录内的所有空文件都删除，最后输出删除的文件的个数。





- 一、随机数
  - [1. 如何生成随机数？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-如何生成随机数)
  - \2. 实战案例
    - ㈠ 随机产生以139开头的电话号码
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现)
    - ㈡ 随机抽出5位幸运观众
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-2)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-2)
    - ㈢ 批量创建用户(密码随机产生)
      - [① 思路](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-思路-3)
      - [② 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-落地实现-3)
- 二、嵌套循环
  - - [㈠ 打印指定图案](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-打印指定图案)
    - [㈡ 落地实现1](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-落地实现1)
    - [㈢ 落地实现2](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-落地实现2)
- 三、阶段性补充总结
  - [1. 变量定义](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-变量定义)
  - [2. 流程控制语句](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-流程控制语句)
  - [3. 循环语句](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-循环语句)
  - \4. 影响shell程序的内置命令
    - [㈠ 具体需求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-具体需求)
    - [㈡ 案例分析](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-案例分析)
    - ㈢ 落地实现
      - [① 代码拆分](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-代码拆分)
      - [② 最终实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F26BAD9E7C28B4836B85DEFED6D1C47C4%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-最终实现)

\#课程目标



- 掌握for循环语句的基本语法结构
- 掌握while和until循环语句的基本语法结构
- 能会使用RANDOM产生随机数
- 理解嵌套循环

# 一、随机数

**关键词：一切都是未知数，永远不知道明天会抽什么风**:wind_chime::sweat_smile:

## 1. 如何生成随机数？

**系统变量**：**RANDOM**，默认会产生0~32767的随机整数

**前言：**要想调用变量，不管你是什么变量都要给钱，而且是美元:heavy_dollar_sign:

```
打印一个随机数
echo $RANDOM
查看系统上一次生成的随机数
# set|grep RANDOM
RANDOM=28325

产生0~1之间的随机数
echo $[$RANDOM%2]

产生0~2之间的随机数
echo $[$RANDOM%3]

产生0~3之间的随机数
echo $[$RANDOM%4]

产生0~9内的随机数
echo $[$RANDOM%10]

产生0~100内的随机数
echo $[$RANDOM%101]


产生50-100之内的随机数
echo $[$RANDOM%51+50]

产生三位数的随机数
echo $[$RANDOM%900+100]
```

## 2. 实战案例

### ㈠ 随机产生以139开头的电话号码

**具体需求1：**

写一个脚本，产生一个phonenum.txt文件，随机产生以139开头的手机号1000个，每个一行。

#### ① 思路

1. 产生1000个电话号码，脚本需要循环1000次 `FOR WHILE UNTIL`
2. 139+8位,后8位随机产生，可以让每一位数字都随机产生 `echo $[$RANDOM%10]`
3. 将随机产生的数字分别保存到变量里，然后加上139保存到文件里

#### ② 落地实现

```
#!/bin/env bash
#产生1000个以139开头的电话号码并保存文件phonenum.txt
file=/shell03/phonenum.txt
for ((i=1;i<=1000;i++))
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> $file
done


#!/bin/bash
# random phonenum
# 循环1000次产生电话号码并保存到文件
for i in {1..1000}
do
	n1=$[RANDOM%10]
	n2=$[RANDOM%10]
	n3=$[RANDOM%10]
	n4=$[RANDOM%10]
	n5=$[RANDOM%10]
	n6=$[RANDOM%10]
	n7=$[RANDOM%10]
	n8=$[RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
done

#!/bin/bash
i=1
while [ $i -le 1000 ]
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
	let i++
done

continue:继续，跳过本次循环，执行下一次循环
break:打断，执行循环体外的代码do..done外
exit:退出程序


#!/bin/bash
for i in {1..1000}
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" >> phonenum.txt
done

#!/bin/bash
#create phone num file
for ((i=1;i<=1000;i++))
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" |tee -a phonenum.txt
done

#!/bin/bash
count=0
while true
do
	n1=$[$RANDOM%10]
	n2=$[$RANDOM%10]
	n3=$[$RANDOM%10]
	n4=$[$RANDOM%10]
	n5=$[$RANDOM%10]
	n6=$[$RANDOM%10]
	n7=$[$RANDOM%10]
	n8=$[$RANDOM%10]
	echo "139$n1$n2$n3$n4$n5$n6$n7$n8" |tee -a phonenum.txt && let count++
	if [ $count -eq 1000 ];then
		break
	fi
done
```

### ㈡ 随机抽出5位幸运观众

**具体需求：**

1. 在上面的1000个手机号里抽奖5个幸运观众，显示出这5个幸运观众。
2. 但只显示头3个数和尾号的4个数，中间的都用*代替

#### ① 思路

1. 确定幸运观众所在的行	`0-1000 随机找出一个数字 $[$RANDOM%1000+1]`
2. 将电话号码提取出来 `head -随机产生行号 phonenum.txt |tail -1`
3. 显示前3个和后4个数到屏幕 `echo 139****`

#### ② 落地实现

```
#!/bin/bash
#定义变量
phone=/shell03/phonenum.txt
#循环抽出5位幸运观众
for ((i=1;i<=5;i++))
do
	#定位幸运观众所在行号
	line=`wc -l $phone |cut -d' ' -f1`
	luck_line=$[RANDOM%$line+1]
	#取出幸运观众所在行的电话号码
	luck_num=`head -$luck_line $phone|tail -1`
	#显示到屏幕
	echo "139****${luck_num:7:4}"
	echo $luck_num >> luck.txt
	#删除已经被抽取的幸运观众号码
	#sed -i "/$luck_num/d" $phone
done


#!/bin/bash
file=/shell04/phonenum.txt
for i in {1..5}
do
	file_num=`wc -l $file |cut -d' ' -f1`
	line=`echo $[$RANDOM%$file_num+1]`
	luck=`head -n $line  $file|tail -1`
	echo "139****${luck:7:4}" && echo $luck >> /shell04/luck_num.txt
done


#!/bin/bash
for ((i=1;i<=5;i++))
do
file=phonenum.txt
line=`cat phonenum.txt |wc -l`	1000
luckline=$[$RANDOM%$line+1]
phone=`cat $file|head -$luckline|tail -1`
echo "幸运观众为:139****${phone:7:4}"
done


或者
#!/bin/bash
# choujiang
phone=phonenum.txt
for ((i=1;i<=5;i++))
do
	num=`wc -l phonenum.txt |cut -d' ' -f1`
	line=`echo $[$RANDOM%$num+1]`
	luck=`head -$line $phone |tail -1`
	sed -i "/$luck/d" $phone
	echo "幸运观众是:139****${luck:7:4}"
done
```

### ㈢ 批量创建用户(密码随机产生)

**需求：**批量创建5个用户，每个用户的密码为一个随机数

#### ① 思路

1. 循环5次创建用户
2. 产生一个密码文件来保存用户的随机密码
3. 从密码文件中取出随机密码赋值给用户

#### ② 落地实现

```
#!/bin/bash
#crate user and set passwd
#产生一个保存用户名和密码的文件
echo user0{1..5}:itcast$[$RANDOM%9000+1000]#@~|tr ' ' '\n'>> user_pass.file

#循环创建5个用户
for ((i=1;i<=5;i++))
do
	user=`head -$i user_pass.file|tail -1|cut -d: -f1`
	pass=`head -$i user_pass.file|tail -1|cut -d: -f2`
	useradd $user
	echo $pass|passwd --stdin $user
done

或者
for i in `cat user_pass.file`
do
	user=`echo $i|cut -d: -f1`
	pass=`echo $i|cut -d: -f2`
	useradd $user
	echo $pass|passwd --stdin $user
done

#!/bin/bash
#crate user and set passwd
#产生一个保存用户名和密码的文件
echo user0{1..3}:itcast$[$RANDOM%9000+1000]#@~|tr ' ' '\n'|tr ':' ' ' >> user_pass.file
#循环创建5个用户
while read user pass
do
useradd $user
echo $pass|passwd --stdin $user
done < user_pass.file


pwgen工具产生随机密码：
[root@server shell04]# pwgen -cn1 12
Meep5ob1aesa
[root@server shell04]# echo user0{1..3}:$(pwgen -cn1 12)
user01:Bahqu9haipho user02:Feiphoh7moo4 user03:eilahj5eth2R
[root@server shell04]# echo user0{1..3}:$(pwgen -cn1 12)|tr ' ' '\n'
user01:eiwaShuZo5hi
user02:eiDeih7aim9k
user03:aeBahwien8co
```

# 二、嵌套循环

**关键字：大圈套小圈**

:clock3:**时钟**：分针与秒针，秒针转⼀圈（60格），分针转1格。循环嵌套就是外层循环⼀次，内层循环⼀轮。

1. 一个循环体内又包含另一个**完整**的循环结构，称为循环的嵌套。
2. 每次外部循环都会触发内部循环，直至内部循环完成，才接着执行下一次的外部循环。
3. for循环、while循环和until循环可以**相互**嵌套。

```
#!/bin/env bash
for ((i=1;i<=5;i++))
do
	for (())
	do
	
	done

done
```

\##1. 应用案例

### ㈠ 打印指定图案

```
1
12
123
1234
12345

5
54
543
5432
54321

外部循环：打印换行，并且换5行 ，循环5次

内部循环：打印54321数字

for ((y=5;y>=1;y--))
do
	for ((x=5;x>=1;x--))
	do
	
	echo -n $x
	done
echo
done
```

### ㈡ 落地实现1

```
X轴：
for ((i=1;i<=5;i++));do echo -n $i;done
Y轴：
负责打印换行

#!/bin/bash
for ((y=1;y<=5;y++))
do
	for ((x=1;x<=$y;x++))
	do
		echo -n $x
	done
echo
done

#!/bin/bash
for ((y=1;y<=5;y++))
do
	x=1
	while [ $x -le $y ]
		do
		echo -n $x
		let x++
		done
echo
done
```

### ㈢ 落地实现2

```
Y轴：打印换行
X轴：打印数字 5-1

#!/bin/bash
y=5
while (( $y >= 1 ))
do
	for ((x=5;x>=$y;x--))
	do
		echo -n $x
	done
echo
let y--
done


#!/bin/bash
for (( y=5;y>=1;y--))
do
	for (( x=5;x>=$y;x--))
	do
	echo -n $x
	done
echo
done

#!/bin/bash
y=5
while [ $y -ge 1 ]
do
	for ((x=5;x>=$y;x--))
	do
	echo -n $x
	done
echo
let y--
done


#!/bin/bash
y=1
until (( $y >5 ))
do
	x=1
	while (( $x <= $y ))
	do
	echo -n $[6-$x]
	let x++
	done	
echo
let y++
done

#!/bin/env bash
y=1
while (( $y<= 5 ))
do
        for ((x=5;x>=6-$y;x--))
        do
                echo -n $x

        done


echo
let y++
done



课后打印：
54321
5432
543
54
5
```

\##2. 课堂练习

**打印九九乘法表（三种方法）**

```
1*1=1

1*2=2   2*2=4

1*3=3   2*3=6   3*3=9

1*4=4   2*4=8   3*4=12  4*4=16

1*5=5   2*5=10  3*5=15  4*5=20  5*5=25

1*6=6   2*6=12  3*6=18  4*6=24  5*6=30  6*6=36

1*7=7   2*7=14  3*7=21  4*7=28  5*7=35  6*7=42  7*7=49

1*8=8   2*8=16  3*8=24  4*8=32  5*8=40  6*8=48  7*8=56  8*8=64

1*9=9   2*9=18  3*9=27  4*9=36  5*9=45  6*9=54  7*9=63  8*9=72  9*9=81


Y轴：循环9次，打印9行空行
X轴：循环次数和Y轴相关；打印的是X和Y轴乘积 $[] $(())

#!/bin/bash
for ((y=1;y<=9;y++))
do
	for ((x=1;x<=$y;x++))
	do
		echo -ne "$x*$y=$[$x*$y]\t"
	done
echo
echo
done


#!/bin/bash
y=1
while [ $y -le 9 ]
do
        x=1
        while [ $x -le $y ]
        do
                echo -ne "$x*$y=$[$x*$y]\t"
                let x++
        done
echo
echo
let y++
done

或者
#!/bin/bash
for i in `seq 9`
do
    for j in `seq $i`
    do
        echo -ne  "$j*$i=$[$i*$j]\t"
    done
echo
echo
done
或者
#!/bin/bash
y=1
until [ $y -gt 9 ]
do
        x=1
        until [ $x -gt $y ]
        do
                echo -ne "$x*$y=$[ $x*$y ]\t"
                let x++
        done
echo
echo
let y++
done
```

# 三、阶段性补充总结

## 1. 变量定义

```
1）变量名=变量值
echo $变量名
echo ${变量名}

2）read -p "提示用户信息:" 变量名

3） declare -i/-x/-r  变量名=变量值
```

## 2. 流程控制语句

```
1）if [ 条件判断 ];then
		command
	fi
	
2) if [ 条件判断 ];then
		command
	else
   	command
   fi
   
 3) if [ 条件判断1 ];then
 		command1
 	 elif [ 条件判断2 ];then
 	 	command2
 	 else
    	command3
   fi 	
   
```

## 3. 循环语句

```
目的：某个动作重复去做，用到循环
for
while
until
```

## 4. 影响shell程序的内置命令

```
exit			退出整个程序
break		   结束当前循环，或跳出本层循环
continue 	忽略本次循环剩余的代码，直接进行下一次循环
shift			使位置参数向左移动，默认移动1位，可以使用shift 2

:
true
false
```

**举例说明：**

```
以下脚本都能够实现用户自定义输入数字，然后脚本计算和：
[root@MissHou shell04]# cat shift.sh 
#!/bin/bash
sum=0
while [ $# -ne 0 ]
do
let sum=$sum+$1
shift
done
echo sum=$sum


[root@MissHou shell04]# cat for3.sh 
#!/bin/bash
sum=0
for i
do
let sum=$sum+$i
done
echo sum=$sum
```

\##5. 补充扩展expect

expect 自动应答 tcl语言

**需求1：**A远程登录到server上什么都不做

```
#!/usr/bin/expect
# 开启一个程序
spawn ssh root@10.1.1.1
# 捕获相关内容
expect {
        "(yes/no)?" { send "yes\r";exp_continue }
        "password:" { send "123456\r" }
}
interact   //交互

脚本执行方式：
# ./expect1.sh
# /shell04/expect1.sh
# expect -f expect1.sh

1）定义变量
#!/usr/bin/expect
set ip 10.1.1.1
set pass 123456
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}
interact


2）使用位置参数
#!/usr/bin/expect
set ip [ lindex $argv 0 ]
set pass [ lindex $argv 1 ]
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}
interact
```

**需求2：**A远程登录到server上操作

```
#!/usr/bin/expect
set ip 10.1.1.1
set pass 123456
set timeout 5
spawn ssh root@$ip
expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
}

expect "#"
send "rm -rf /tmp/*\r"
send "touch /tmp/file{1..3}\r"
send "date\r"
send "exit\r"
expect eof
```

**需求3：**shell脚本和expect结合使用，在多台服务器上创建1个用户

```
[root@server shell04]# cat ip.txt 
10.1.1.1 123456
10.1.1.2 123456


1. 循环  useradd username
2. 登录远程主机——>ssh——>从ip.txt文件里获取IP和密码分别赋值给两个变量
3. 使用expect程序来解决交互问题


#!/bin/bash
# 循环在指定的服务器上创建用户和文件
while read ip pass
do
	/usr/bin/expect <<-END &>/dev/null
	spawn ssh root@$ip
	expect {
	"yes/no" { send "yes\r";exp_continue }
	"password:" { send "$pass\r" }
	}
	expect "#" { send "useradd yy1;rm -rf /tmp/*;exit\r" }
	expect eof
	END
echo "$ip服务器用户创建完毕"
done < ip.txt



#!/bin/bash
cat ip.txt|while read ip pass
do
        {

        /usr/bin/expect <<-HOU
        spawn ssh root@$ip
        expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
        }
        expect "#"
        send "hostname\r"
        send "exit\r"
        expect eof
        HOU

        }&
done
wait
echo "user is ok...."


或者
#!/bin/bash
while read ip pass
do
        {

        /usr/bin/expect <<-HOU
        spawn ssh root@$ip
        expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
        }
        expect "#"
        send "hostname\r"
        send "exit\r"
        expect eof
        HOU

        }&
done<ip.txt
wait
echo "user is ok...."
```

\#四、综合案例

\##1. 实战案例1

### ㈠ 具体需求

写一个脚本，将跳板机上yunwei用户的公钥推送到局域网内可以ping通的所有机器上

说明：主机和密码文件已经提供

10.1.1.1:123456

10.1.1.2:123456

### ㈡ 案例分析

1. 跳板机上的yunwei用户生成秘钥对
   - 判断账号是否存在 (id yunwei)
   - 判断该用户是否有密钥对文件 [ -f xxx ]
2. 判断expect程序是否安装
3. 判断局域网内主机是否ping通（循环判断|for while until）
   - 循环判断 for while
   - 循环体do......done ping 主机 如果ping通 调用expect程序自动应答推送公钥
4. 测试验证是否免密登录成功

- 检查服务器上ssh服务端口号
- 把公钥推送成功的主机的信息保存到文件
- 关闭防火墙和selinux
- 日志记录
- 推送公钥需要自动应答expect

### ㈢ 落地实现

#### ① 代码拆分

功能1：管理员root创建yunwei用户和安装expect软件包

```
#!/bin/env bash
# 实现批量推送公钥
# 判断jumper上的yunwei账号是否存在
{
id yunwei
[ $? -ne 0 ] && useradd yunwei && echo 123|passwd --stdin yunwei
} &>/dev/null
#判断expect程序是否安装
rpm -q expect
[ $? -ne 0 ] && yum -y install expect && echo "expect软件已经成功安装"
```

功能2：判断主机是否ping通并且yunwei用户推送公钥

```
#!/bin/env bash
# 判断yunwei用户密钥对是否存在
home_dir=/home/yunwei
[ ! -f $home_dir/.ssh/id_rsa.pub ] && ssh-keygen -P '' -f id_rsa &>/dev/null

#循环检查主机的网络并且进行公钥推送
ip_txt=$home_dir/ip.txt

for i in `cat $ip_txt`
do
	ip=`echo $i|cut -d: -f1`
	pass=`echo $i|cut -d: -f2`
	ping -c1 $ip &>/dev/null
	if [ $? -eq 0 ];then
		echo $ip >> ~/ip_up.txt
		/usr/bin/expect <<-END &>/dev/null
		spawn ssh-copy-id root@$ip
		expect
			{
            "(yes/no)"  { send "yes\n";exp_continue }
            "password:"  { send "$pass\n" }
			}
		expect eof
		END	
	else
		echo $ip >> $home_dir/ip_down.txt
	fi
done

# 测试验证
remote_ip=`head -1 ~/ip_up.txt`
ssh root@$remote_ip hostname
[ $? -eq 0 ] && echo "公钥推送成功"
```

#### ② 最终实现

1. **环境准备**

```
jumper-server	有yunwei用户

yunwei用户sudo授权：
visudo
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
yunwei  ALL=(root)      NOPASSWD:ALL,!/sbin/shutdown,!/sbin/init,!/bin/rm -rf /

解释说明：
1）第一个字段yunwei指定的是用户：可以是用户名，也可以是别名。每个用户设置一行，多个用户设置多行，也可以将多个用户设置成一个别名后再进行设置。
2）第二个字段ALL指定的是用户所在的主机：可以是ip,也可以是主机名，表示该sudo设置只在该主机上生效，ALL表示在所有主机上都生效！限制的一般都是本机，也就是限制使用这个文件的主机;一般都指定为"ALL"表示所有的主机，不管文件拷到那里都可以用。比如：10.1.1.1=...则表示只在当前主机生效。
3）第三个字段（root）括号里指定的也是用户：指定以什么用户身份执行sudo，即使用sudo后可以享有所有root账号下的权限。如果要排除个别用户，可以在括号内设置，比如ALL=(ALL,!oracle,!pos)。
4）第四个字段ALL指定的是执行的命令：即使用sudo后可以执行所有的命令。除了关机和删除根内容以外；也可以设置别名。NOPASSWD: ALL表示使用sudo的不需要输入密码。
5）也可以授权给一个用户组
	%admin ALL=(ALL) ALL	表示admin组里的所有成员可以在任何主机上以任何用户身份执行任何命令
```

1. **脚本实现**

```
#!/bin/bash
#判断公钥是否存在
[ ! -f /home/yunwei/.ssh/id_rsa ] && ssh-keygen -P '' -f ~/.ssh/id_rsa

#循环判断主机是否ping通，如果ping通推送公钥
tr ':' ' ' < /shell04/ip.txt|while read ip pass
do
{
        ping -c1 $ip &>/dev/null
        if [ $? -eq 0 ];then
        echo $ip >> ~/ip_up.txt
        /usr/bin/expect <<-END &>/dev/null
         spawn ssh-copy-id root@$ip
         expect {
                "yes/no" { send "yes\r";exp_continue }
                "password:" { send "$pass\r" }
                }
        expect eof
        END
        fi
}&
done
wait
echo "公钥已经推送完毕，正在测试...."
#测试验证
remote_ip=`tail -1 ~/ip_up.txt`
ssh root@$remote_ip hostname &>/dev/null
test $? -eq 0 && echo "公钥成功推送完毕"
```

\##2. 实战案例2

写一个脚本，统计web服务的不同连接状态个数

1. 找出查看网站连接状态的命令 `ss -natp|grep :80`
2. 如何统计不同的状态 循环去统计，需要计算

```
#!/bin/bash
#count_http_80_state
#统计每个状态的个数

declare -A array1
states=`ss -ant|grep 80|cut -d' ' -f1`

for i in $states
do
        let array1[$i]++
done

#通过遍历数组里的索引和元素打印出来
for j in ${!array1[@]}
do
        echo $j:${array1[$j]}
done
```

\#五、课后实战

1、将/etc/passwd里的用户名分类，分为管理员用户，系统用户，普通用户。 2、写一个倒计时脚本，要求显示离2019年1月1日（元旦）的凌晨0点，还有多少天，多少时，多少分，多少秒。 3、写一个脚本把一个目录内的所有空文件都删除，最后输出删除的文件的个数。





- 一、case语句
  - [1. 语法结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-语法结构)
  - \2. 应用案例
    - [㈠ 脚本传不同值做不同事](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-脚本传不同值做不同事)
    - [㈡ 根据用户需求选择做事](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-根据用户需求选择做事)
- 二、函数
  - [1. 什么是函数？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-什么是函数)
  - \2. 如何定义函数？
    - [㈠ 当前命令行调用](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-当前命令行调用)
    - [㈡ 定义到用户的环境变量中](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-定义到用户的环境变量中)
    - [㈢ 脚本中调用](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-脚本中调用)
  - [1. 任务背景](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-任务背景)
  - [2. 具体要求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-具体要求)
  - [3. 综合分析](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-综合分析)
  - [4. 落地实现](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#4-落地实现)
- 四、正则表达式
  - [2. 正则能干什么？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-正则能干什么)
  - \3. 正则当中名词解释
    - [㈠ 正则中普通常用的元字符](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-正则中普通常用的元字符)
    - [㈡ 正则中其他常用元字符](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-正则中其他常用元字符)
    - [㈢ 扩展类正则常用元字符](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三-扩展类正则常用元字符)
  - [6. 正则表达式总结](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#6-正则表达式总结)
- [五、正则元字符一栏表](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#五-正则元字符一栏表)
- 六、正则练习作业
  - [1. 文件准备](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-文件准备)
  - [2. 具体要求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-具体要求-2)
  - [脚本搭建web服务](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#脚本搭建web服务)

\#课程目标



- 掌握case语句的基本语法结构
- 掌握函数的定义及调用
- 掌握常用的正则表达式元字符含义

# 一、case语句

**关键词：确认过眼神，你是对的人**:couple_with_heart:

1. case语句为多重匹配语句
2. 如果匹配成功，执行相匹配的命令

## 1. 语法结构

```
说明：pattern表示需要匹配的模式


case var in             定义变量;var代表是变量名
pattern 1)              模式1;用 | 分割多个模式，相当于or
    command1            需要执行的语句
    ;;                  两个分号代表命令结束
pattern 2)
    command2
    ;;
pattern 3)
    command3
    ;;
		  *)              default，不满足以上模式，默认执行*)下面的语句
    command4
    ;;
esac							esac表示case语句结束
```

## 2. 应用案例

### ㈠ 脚本传不同值做不同事

**具体需求：**当给程序传入start、stop、restart三个不同参数时分别执行相应命令

```
#!/bin/env bash
case $1 in
        start|S)
        service apache start &>/dev/null && echo "apache 启动成功"
        ;;
        stop|T)
        service apache stop &>/dev/null && echo "apache 停止成功"
        ;;
        restart|R)
        service apache restart &>/dev/null && echo "apache 重启完毕"
        ;;
        *)
        echo "请输入要做的事情..."
        ;;
esac
```

### ㈡ 根据用户需求选择做事

**具体需求：**

脚本提示让用户输入需要管理的服务名，然后提示用户需要对服务做什么操作，如启动，关闭等操作

```
#!/bin/env bash
read -p "请输入你要管理的服务名称(vsftpd):" service
case $service in
        vsftpd|ftp)
        read -p "请选择你需要做的事情(restart|stop):" action
        case $action in
                stop|S)
                service vsftpd stop &>/dev/null && echo "该$serivce服务已经停止成功"
                ;;
                start)
                service vsftpd start &>/dev/null && echo "该$serivce服务已经成功启动"
                ;;
        esac
        ;;
        httpd|apache)
        echo "apache hello world"
        ;;
        *)
        echo "请输入你要管理的服务名称(vsftpd)"
        ;;
esac
	
```

\###㈢ 菜单提示让用户选择需要做的事

**具体需求：**

模拟一个多任务维护界面;当执行程序时先显示总菜单，然后进行选择后做相应维护监控操作

```
**********请选择*********
h	显示命令帮助
f	显示磁盘分区
d	显示磁盘挂载
m	查看内存使用
u	查看系统负载
q	退出程序
*************************
```

**思路：**

1. 菜单打印出来
2. 交互式让用户输入操作编号，然后做出相应处理

**落地实现：**

1. 菜单打印(分解动作)

```
#!/bin/env bash
cat <<-EOF
	h	显示命令帮助
	f	显示磁盘分区
	d	显示磁盘挂载
	m	查看内存使用
	u	查看系统负载
	q	退出程序
	EOF
```

1. 最终实现

```
#!/bin/bash
#打印菜单
cat <<-EOF
	h	显示命令帮助
	f	显示磁盘分区
	d	显示磁盘挂载
	m	查看内存使用
	u	查看系统负载
	q	退出程序
	EOF

#让用户输入需要的操作
while true
do
read -p "请输入需要操作的选项[f|d]:" var1
case $var1 in
	h)
	cat <<-EOF
        h       显示命令帮助
        f       显示磁盘分区
        d       显示磁盘挂载
        m       查看内存使用
        u       查看系统负载
        q       退出程序
	EOF
	;;
	f)
	fdisk -l
	;;
	d)
	df -h
	;;
	m)
	free -m
	;;
	u)
	uptime
	;;
	q)
	exit
	;;
esac
done



#!/bin/bash
#打印菜单
menu(){
cat <<-END
	h	显示命令帮助
	f	显示磁盘分区
	d	显示磁盘挂载
	m	查看内存使用
	u	查看系统负载
	q	退出程序
	END
}
menu
while true
do
read -p "请输入你的操作[h for help]:" var1
case $var1 in
	h)
	menu
	;;
	f)
	read -p "请输入你要查看的设备名字[/dev/sdb]:" var2
	case $var2 in
		/dev/sda)
		fdisk -l /dev/sda
		;;
		/dev/sdb)
		fdisk -l /dev/sdb
		;;
	esac
	;;
	d)
	lsblk
	;;
	m)
	free -m
	;;
	u)
	uptime
	;;
	q)
	exit
	;;
esac
done
```

**课堂练习：**

1. 输入一个等级（A-E），查看每个等级的成绩；如：输入A，则显示“90分~100分”，依次类推
2. 判断用户输入的字符串，如果是"hello",则显示"world"；如果是"world",则显示"hello",否则提示"请输入hello或者world，谢谢！"

# 二、函数

## 1. 什么是函数？

- shell中允许将**一组命令集合**或**语句**形成一段**可用代码**，这些代码块称为shell函数
- 给这段代码起个名字称为函数名，后续可以直接调用该段代码的功能

## 2. 如何定义函数？

**方法1：**

```
函数名()
{
  函数体（一堆命令的集合，来实现某个功能）   
}
```

**方法2：**

```
function 函数名()
{
   函数体（一堆命令的集合，来实现某个功能）
   echo hello
   echo world
}
```

**函数中return说明:**

1. return可以结束一个函数。类似于循环控制语句break(结束当前循环，执行循环体后面的代码)。
2. return默认返回函数中最后一个命令状态值，也可以给定参数值，范围是0-256之间。
3. 如果没有return命令，函数将返回最后一个指令的退出状态值。

\##3. 函数如何调用？

### ㈠ 当前命令行调用

```
[root@MissHou shell04]# cat fun1.sh 
#!/bin/bash
hello(){
echo "hello lilei $1"
hostname
}
menu(){
cat <<-EOF
1. mysql
2. web
3. app
4. exit
EOF
}

[root@MissHou shell04]# source fun1.sh 
[root@MissHou shell04]# . fun1.sh 

[root@MissHou shell04]# hello 888
hello lilei 888
MissHou.itcast.cc
[root@MissHou shell04]# menu
1. mysql
2. web
3. app
4. exit
```

### ㈡ 定义到用户的环境变量中

```
[root@MissHou shell05]# vim ~/.bashrc 
文件中增加如下内容：
hello(){
echo "hello lilei $1"
hostname
}
menu(){
cat <<-EOF
1. mysql
2. web
3. app
4. exit
EOF
}

注意：
当用户打开bash的时候会读取该文件
```

### ㈢ 脚本中调用

```
#!/bin/bash
#打印菜单
source ./fun1.sh
menu(){
cat <<-END
	h	显示命令帮助
	f	显示磁盘分区
	d	显示磁盘挂载
	m	查看内存使用
	u	查看系统负载
	q	退出程序
	END
}
menu		//调用函数
```

\##4. 应用案例

**具体需求：**

1. 写一个脚本收集用户输入的基本信息(姓名，性别，年龄)，如不输入一直提示输入
2. 最后根据用户的信息输出相对应的内容

**思路：**

1. 交互式定义多个变量来保存用户信息 姓名、性别、年龄
2. 如果不输一直提示输入
   - 循环直到输入字符串不为空 while 判断输入字符串是否为空
   - 每个信息都必须不能为空，该功能可以定义为一个函数，方便下面脚本调用
3. 根据用户输入信息做出匹配判断

**代码实现：**

```
#!/bin/bash
#该函数实现用户如果不输入内容则一直循环直到用户输入为止，并且将用户输入的内容打印出来
input_fun()
{
  input_var=""
  output_var=$1
  while [ -z $input_var ]
	do
	read -p "$output_var" input_var
	done
	echo $input_var
}

input_fun 请输入你的姓名:

或者
#!/bin/bash
fun()
{
	read -p "$1" var
	if [ -z $var ];then
		fun $1
	else
		echo $var
	fi
}


#调用函数并且获取用户的姓名、性别、年龄分别赋值给name、sex、age变量
name=$(input_fun 请输入你的姓名:)
sex=$(input_fun 请输入你的性别:)
age=$(input_fun 请输入你的年龄:)

#根据用户输入的性别进行匹配判断
case $sex in
			man)
			if [ $age -gt 18 -a $age -le 35 ];then
				echo "中年大叔你油腻了吗？加油"
			elif [ $age -gt 35 ];then
				echo "保温杯里泡枸杞"
			else
				echo "年轻有为。。。"
			fi
			;;
			woman)
			xxx
			;;
			*)
			xxx
			;;
esac
```

**扩展延伸：**

```
描述以下代码含义：	
:()
{
   :|:&
}
:
```

\#三、综合案例

## 1. 任务背景

现有的跳板机虽然实现了统一入口来访问生产服务器，yunwei用户权限太大可以操作跳板机上的所有目录文件，存在数据被误删的安全隐患，所以希望你做一些安全策略来保证跳板机的正常使用。

## 2. 具体要求

1. 只允许yunwei用户通过跳板机远程连接后台的应用服务器做一些维护操作
2. 公司运维人员远程通过yunwei用户连接跳板机时，跳出以下菜单供选择：

```
欢迎使用Jumper-server，请选择你要操作的主机：
1. DB1-Master
2. DB2-Slave
3. Web1
4. Web2
h. help
q. exit
```

1. 当用户选择相应主机后，直接**免密码登录**成功
2. 如果用户不输入一直提示用户输入，直到用户选择退出

## 3. 综合分析

1. 将脚本放到yunwei用户家目录里的.bashrc文件里（/shell05/jumper-server.sh）
2. 将菜单定义为一个函数[打印菜单]，方便后面调用
3. 用case语句来实现用户的选择【交互式定义变量】
4. 当用户选择了某一台服务器后，进一步询问用户需要做的事情 case...esac 交互式定义变量
5. 使用循环来实现用户不选择一直让其选择
6. 限制用户退出后直接关闭终端 exit

## 4. 落地实现

```
#!/bin/bash
# jumper-server
# 定义菜单打印功能的函数
menu()
{
cat <<-EOF
欢迎使用Jumper-server，请选择你要操作的主机：
1. DB1-Master
2. DB2-Slave
3. Web1
4. Web2
h. help
q. exit
	EOF
}
# 屏蔽以下信号
trap '' 1 2 3 19
# 调用函数来打印菜单
menu
#循环等待用户选择
while true
do
# 菜单选择，case...esac语句
read -p "请选择你要访问的主机:" host
case $host in
	1)
	ssh root@10.1.1.1
	;;
	2)
	ssh root@10.1.1.2
	;;
	3)
	ssh root@10.1.1.3
	;;
	h)
	clear;menu
	;;
	q)
	exit
	;;
esac
done


将脚本放到yunwei用户家目录里的.bashrc里执行：
bash ~/jumper-server.sh
exit
```

**进一步完善需求**

为了进一步增强跳板机的安全性，工作人员通过跳板机访问生产环境，但是不能在跳板机上停留。

```
#!/bin/bash
#公钥推送成功
trap '' 1 2 3 19
#打印菜单用户选择
menu(){
cat <<-EOF
欢迎使用Jumper-server，请选择你要操作的主机：
1. DB1-Master
2. DB2-Slave
3. Web1
4. Web2
h. help
q. exit
EOF
}

#调用函数来打印菜单
menu
while true
do
read -p "请输入你要选择的主机[h for help]：" host

#通过case语句来匹配用户所输入的主机
case $host in
	1|DB1)
	ssh root@10.1.1.1
	;;
	2|DB2)
	ssh root@10.1.1.2
	;;
	3|web1)
	ssh root@10.1.1.250
	;;
	h|help)
	clear;menu
	;;
	q|quit)
	exit
	;;
esac
done

自己完善功能：
1. 用户选择主机后，需要事先推送公钥；如何判断公钥是否已推
2. 比如选择web1时，再次提示需要做的操作，比如：
clean log
重启服务
kill某个进程
```

**回顾信号：**

```
1) SIGHUP 			重新加载配置    
2) SIGINT			键盘中断^C
3) SIGQUIT      	键盘退出
9) SIGKILL		 	强制终止
15) SIGTERM	    	终止（正常结束），缺省信号
18) SIGCONT	   	继续
19) SIGSTOP	   	停止
20) SIGTSTP     	暂停^Z
```

# 四、正则表达式

\##1. 正则表达式是什么？

**正则表达式**（Regular Expression、regex或regexp，缩写为RE），也译为正规表示法、常规表示法，是一种字符模式，用于在查找过程中匹配指定的字符。

许多程序设计语言都支持利用正则表达式进行**字符串操作**。例如，在Perl中就内建了一个功能强大的正则表达式引擎。

正则表达式这个概念最初是由Unix中的工具软件（例如sed和grep）普及开的。

支持正则表达式的程序如：locate |find| vim| grep| sed |awk

## 2. 正则能干什么？

1. 匹配邮箱、匹配身份证号码、手机号、银行卡号等
2. 匹配某些特定字符串，做特定处理等等

## 3. 正则当中名词解释

- **元字符**

  指那些在正则表达式中具有**特殊意义的专用字符**,如:点(.) 星(*) 问号(?)等

- **前导字符**

  位于**元字符**前面的字符.	ab**c*** aoo**o.**

\##4. 第一类正则表达式

### ㈠ 正则中普通常用的元字符

| 元字符                                                       | 功能                                         | 备注                                                         |
| ------------------------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------ |
| .                                                            | 匹配除了换行符以外的任意单个字符             |                                                              |
| *                                                            | 前导字符出现0次或连续多次                    |                                                              |
| .*                                                           | 任意长度字符                                 | ab.*                                                         |
| ^                                                            | 行首(以...开头)                              | ^root                                                        |
| $                                                            | 行尾(以...结尾)                              | bash$                                                        |
| ^$                                                           | 空行                                         |                                                              |
| []                                                           | 匹配括号里任意单个字符或一组单个字符         | [abc]                                                        |
| [^]                                                          | 匹配不包含括号里任一单个字符或一组单个字符   | [^abc]                                                       |
| [[1\]](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#fn1) | 匹配以括号里任意单个字符或一组单个字符开头   | [[2\]](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#fn2) |
| ^[^]                                                         | 匹配不以括号里任意单个字符或一组单个字符开头 | ^[^abc]                                                      |

- 示例文本

```
# cat 1.txt
ggle
gogle
google
gooogle
goooooogle
gooooooogle
taobao.com
taotaobaobao.com

jingdong.com
dingdingdongdong.com
10.1.1.1
Adfjd8789JHfdsdf/
a87fdjfkdLKJK
7kdjfd989KJK;
bSKJjkksdjf878.
cidufKJHJ6576,

hello world
helloworld yourself
```

- 举例说明

```

```

### ㈡ 正则中其他常用元字符

| 元字符  | 功能                                    | 备注         |
| ------- | --------------------------------------- | ------------ |
| \<      | 取单词的头                              |              |
| \>      | 取单词的尾                              |              |
| \< \>   | 精确匹配                                |              |
| \{n\}   | 匹配前导字符连续出现n次                 |              |
| \{n,\}  | 匹配前导字符至少出现n次                 |              |
| \{n,m\} | 匹配前导字符出现n次与m次之间            |              |
| \( \)   | 保存被匹配的字符                        |              |
| \d      | 匹配数字（**grep -P**）                 | [0-9]        |
| \w      | 匹配字母数字下划线（**grep -P**）       | [a-zA-Z0-9_] |
| \s      | 匹配空格、制表符、换页符（**grep -P**） | [\t\r\n]     |

**举例说明：**

```
需求：将10.1.1.1替换成10.1.1.254

1）vim编辑器支持正则表达式
# vim 1.txt
:%s#\(10.1.1\).1#\1.254#g 
:%s/\(10.1.1\).1/\1.254/g 

2）sed支持正则表达式【后面学】
# sed -n 's#\(10.1.1\).1#\1.254#p' 1.txt
10.1.1.254

说明：
找出含有10.1.1的行，同时保留10.1.1并标记为标签1，之后可以使用\1来引用它。
最多可以定义9个标签，从左边开始编号，最左边的是第一个。


需求：将helloworld yourself 换成hellolilei myself

# vim 1.txt
:%s#\(hello\)world your\(self\)#\1lilei my\2#g

# sed -n 's/\(hello\)world your\(self\)/\1lilei my\2/p' 1.txt 
hellolilei myself

# sed -n 's/helloworld yourself/hellolilei myself/p' 1.txt 
hellolilei myself
# sed -n 's/\(hello\)world your\(self\)/\1lilei my\2/p' 1.txt 
hellolilei myself

Perl内置正则：
\d      匹配数字  [0-9]
\w      匹配字母数字下划线[a-zA-Z0-9_]
\s      匹配空格、制表符、换页符[\t\r\n]

# grep -P '\d' 1.txt
# grep -P '\w' 2.txt
# grep -P '\s' 3.txt
```

### ㈢ 扩展类正则常用元字符

**丑话说在前面：**

我说我比较特殊，你要相信！否则我错给你看:smirk:

- grep你要用我，必须加 **-E** 或者 让你兄弟`egrep`来找我
- sed你要用我，必须加 **-r**

| 扩展元字符 | 功能                   | 备注                                         |
| ---------- | ---------------------- | -------------------------------------------- |
| +          | 匹配一个或多个前导字符 | bo+ 匹配boo、 bo                             |
| ?          | 匹配零个或一个前导字符 | bo? 匹配b、 bo                               |
| \|         | 或                     | 匹配a或b                                     |
| ()         | 组字符（看成整体）     | (my\|your)self：表示匹配myself或匹配yourself |
| {n}        | 前导字符重复n次        |                                              |
| {n,}       | 前导字符重复至少n次    |                                              |
| {n,m}      | 前导字符重复n到m次     |                                              |

**举例说明：**

```
# grep "root|ftp|adm" /etc/passwd
# egrep "root|ftp|adm" /etc/passwd
# grep -E "root|ftp|adm" /etc/passwd

# grep -E 'o+gle' test.txt 
# grep -E 'o?gle' test.txt 

# egrep 'go{2,}' 1.txt
# egrep '(my|your)self' 1.txt


使用正则过滤出文件中的IP地址：
# grep '[0-9]\{2\}\.[0-9]\{1\}\.[0-9]\{1\}\.[0-9]\{1\}' 1.txt 
10.1.1.1
# grep '[0-9]{2}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}' 1.txt 
# grep -E '[0-9]{2}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}' 1.txt 
10.1.1.1
# grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' 1.txt 
10.1.1.1
# grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' 1.txt 
10.1.1.1
```

\##5. 第二类正则

| 表达式    | 功能                             | 示例            |
| --------- | -------------------------------- | --------------- |
| [:alnum:] | 字母与数字字符                   | [[:alnum:]]+    |
| [:alpha:] | 字母字符(包括大小写字母)         | [[:alpha:]]{4}  |
| [:blank:] | 空格与制表符                     | [[:blank:]]*    |
| [:digit:] | 数字                             | [[:digit:]]?    |
| [:lower:] | 小写字母                         | [[:lower:]]{4,} |
| [:upper:] | 大写字母                         | [[:upper:]]+    |
| [:punct:] | 标点符号                         | [[:punct:]]     |
| [:space:] | 包括换行符，回车等在内的所有空白 | [[:space:]]+    |

```
[root@server shell05]# grep -E '^[[:digit:]]+' 1.txt
[root@server shell05]# grep -E '^[^[:digit:]]+' 1.txt
[root@server shell05]# grep -E '[[:lower:]]{4,}' 1.txt
```

## 6. 正则表达式总结

**把握一个原则，让你轻松搞定可恶的正则符号：**

1. 我要找什么？
   - 找数字 [0-9]
   - 找字母 [a-zA-Z]
   - 找标点符号 [[:punct:]]
2. 我要如何找？看心情找
   - 以什么为首 ^key
   - 以什么结尾 key$
   - 包含什么或不包含什么 [abc] ^[abc] [^abc] ^[^abc]
3. 我要找多少呀？
   - 找前导字符出现0次或连续多次 ab==*==
   - 找任意单个(一次)字符 ab==.==
   - 找任意字符 ab==.*==
   - 找前导字符连续出现几次 {n} {n,m} {n,}
   - 找前导字符出现1次或多次 go==+==
   - 找前到字符出现0次或1次 go==?==

# 五、正则元字符一栏表

**元字符**：在正则中，具有特殊意义的专用字符，如: 星号(*)、加号(+)等

**前导字符**：元字符前面的字符叫前导字符

| 元字符                                                       | 功能                                     | 示例                                                         |
| ------------------------------------------------------------ | ---------------------------------------- | ------------------------------------------------------------ |
| *                                                            | 前导字符出现0次或者连续多次              | ab* abbbb                                                    |
| .                                                            | 除了换行符以外，任意单个字符             | ab. ab8 abu                                                  |
| .*                                                           | 任意长度的字符                           | ab.* adfdfdf                                                 |
| []                                                           | 括号里的任意单个字符或一组单个字符       | [abc][0-9][a-z]                                              |
| [^]                                                          | 不匹配括号里的任意单个字符或一组单个字符 | [^abc]                                                       |
| [[3\]](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#fn3) | 匹配以括号里的任意单个字符开头           | [[4\]](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F25D87A9819C746E29E1D846E0187978C%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#fn4) |
| ^[^]                                                         | 不匹配以括号里的任意单个字符开头         |                                                              |
| ^                                                            | 行的开头                                 | ^root                                                        |
| $                                                            | 行的结尾                                 | bash$                                                        |
| ^$                                                           | 空行                                     |                                                              |
| \{n\}和{n}                                                   | 前导字符连续出现n次                      | [0-9]\{3\}                                                   |
| \{n,\}和{n,}                                                 | 前导字符至少出现n次                      | [a-z]{4,}                                                    |
| \{n,m\}和{n,m}                                               | 前导字符连续出现n-m次                    | go{2,4}                                                      |
| \<\>                                                         | 精确匹配单词                             | \<hello\>                                                    |
| \(\)                                                         | 保留匹配到的字符                         | \(hello\)                                                    |
| +                                                            | 前导字符出现1次或者多次                  | [0-9]+                                                       |
| ?                                                            | 前导字符出现0次或者1次                   | go?                                                          |
| \|                                                           | 或                                       | ^root\|^ftp                                                  |
| ()                                                           | 组字符                                   | (hello\|world)123                                            |
| \d                                                           | perl内置正则                             | grep -P \d+                                                  |
| \w                                                           | 匹配字母数字下划线                       |                                                              |

# 六、正则练习作业

## 1. 文件准备

```
# vim test.txt 
Aieur45869Root0000
9h847RkjfkIIIhello
rootHllow88000dfjj
8ikuioerhfhupliooking
hello world
192.168.0.254
welcome to uplooking.
abcderfkdjfkdtest
rlllA899kdfkdfj
iiiA848890ldkfjdkfj
abc
12345678908374
123456@qq.com
123456@163.com
abcdefg@itcast.com23ed
```

## 2. 具体要求

```
1、查找不以大写字母开头的行（三种写法）。
grep '^[^A-Z]' 2.txt
grep -v '^[A-Z]' 2.txt
grep '^[^[:upper:]]' 2.txt
2、查找有数字的行（两种写法）
grep '[0-9]' 2.txt
grep -P '\d' 2.txt
3、查找一个数字和一个字母连起来的
grep -E '[0-9][a-zA-Z]|[a-zA-Z][0-9]' 2.txt
4、查找不以r开头的行
grep -v '^r' 2.txt
grep '^[^r]' 2.txt
5、查找以数字开头的
grep '^[0-9]' 2.txt
6、查找以大写字母开头的
grep '^[A-Z]' 2.txt
7、查找以小写字母开头的
grep '^[a-z]' 2.txt
8、查找以点结束的
grep '\.$' 2.txt
9、去掉空行
grep -v '^$' 2.txt
10、查找完全匹配abc的行
grep '\<abc\>' 2.txt
11、查找A后有三个数字的行
grep -E 'A[0-9]{3}' 2.txt
grep  'A[0-9]\{3\}' 2.txt
12、统计root在/etc/passwd里出现了几次
grep -o 'root' 1.txt |wc -l

13、用正则表达式找出自己的IP地址、广播地址、子网掩码
ifconfig eth0|grep Bcast|grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
ifconfig eth0|grep Bcast| grep -E -o '([0-9]{1,3}.){3}[0-9]{1,3}'
ifconfig eth0|grep Bcast| grep -P -o '\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}'
ifconfig eth0|grep Bcast| grep -P -o '(\d{1,3}.){3}\d{1,3}'
ifconfig eth0|grep Bcast| grep -P -o '(\d+.){3}\d+'

# egrep --color '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /etc/sysconfig/network-scripts/ifcfg-eth0
IPADDR=10.1.1.1
NETMASK=255.255.255.0
GATEWAY=10.1.1.254

# egrep --color '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' /etc/sysconfig/network-scripts/ifcfg-eth0 
IPADDR=10.1.1.1
NETMASK=255.255.255.0
GATEWAY=10.1.1.254


14、找出文件中的ip地址并且打印替换成172.16.2.254
grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}' 1.txt |sed -n 's/192.168.0.\(254\)/172.16.2.\1/p'

15、找出文件中的ip地址
grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}' 1.txt

16、找出全部是数字的行
grep -E '^[0-9]+$' test
17、找出邮箱地址
grep -E '^[0-9]+@[a-z0-9]+\.[a-z]+$'


grep --help:
匹配模式选择：
Regexp selection and interpretation:
  -E, --extended-regexp     扩展正则
  -G, --basic-regexp        基本正则
  -P, --perl-regexp         调用perl的正则
  -e, --regexp=PATTERN      use PATTERN for matching
  -f, --file=FILE           obtain PATTERN from FILE
  -i, --ignore-case         忽略大小写
  -w, --word-regexp         匹配整个单词
  
```

# 七、课后作业

## 脚本搭建web服务

**要求如下**：

1. 用户输入web服务器的IP、域名以及数据根目录
2. 如果用户不输入则一直提示输入，直到输入为止
3. 当访问www.test.cc时可以访问到数据根目录里的首页文件“this is test page”

**参考脚本：**

```bash
#!/bin/bash
conf=/etc/httpd/conf/httpd.conf
input_fun()
{
  input_var=""
  output_var=$1
  while [ -z $input_var ]
	do
	read -p "$output_var" input_var
	done
	echo $input_var
}
ipaddr=$(input_fun "Input Host ip[192.168.0.1]:")
web_host_name=$(input_fun "Input VirtualHostName [www.test.cc]:")
root_dir=$(input_fun "Input host Documentroot dir:[/var/www/html]:")

[ ! -d $root_dir ] && mkdir -p $root_dir
chown apache.apache $root_dir && chmod 755 $root_dir
echo this is $web_host_name > $root_dir/index.html
echo "$ipaddr $web_host_name" >> /etc/hosts

[ -f $conf ] && cat >> $conf <<end
NameVirtualHost $ipaddr:80
<VirtualHost $ipaddr:80>
	ServerAdmin webmaster@$web_host_name
	DocumentRoot $root_dir
	ServerName $web_host_name
	ErrorLog logs/$web_host_name-error_log
	CustomLog logs/$web_host_name-access_loh common
</VirtualHost>
end
```

------





- - [typora-root-url: ....\pictures](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#typora-root-url-pictures)
- 一、文件编辑器知多少
  - [1. sed用来做啥？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-sed用来做啥)
  - [2. sed如何处理文件？](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-sed如何处理文件)
  - \1. 命令行格式
    - [㈠ 语法格式](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-语法格式)
    - ㈡ 举例说明
      - ① 对文件进行增、删、改、查操作
        - [1）打印文件内容](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1打印文件内容)
        - [2）增加文件内容](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2增加文件内容)
        - [3）修改文件内容](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3修改文件内容)
        - [4）删除文件内容](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#4删除文件内容)
      - [② 对文件进行搜索替换操作](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-对文件进行搜索替换操作)
      - [③ 其他命令](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-其他命令)
      - [④ 其他选项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#4-其他选项)
      - [⑤ sed结合正则使用](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#5-sed结合正则使用)
    - [㈠ 用法](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-用法)
    - [㈡ 注意事项](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-注意事项)
    - [㈢举例说明](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2FDE6B4DF94A024C548A220DD89C0286A5%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#三举例说明)

\#课程目标



- 掌握sed的基本语法结构
- 熟悉sed常用的命令，如打印p，删除d，插入i等

# 一、文件编辑器知多少

- **Windows系统**

![edit](http://./edit.png?ynotemdtimestamp=1607388328295)

- **Linux系统**

​	vim	vi	gedit nano emacs

\#二、强悍的sed介绍

## 1. sed用来做啥？

sed是Stream Editor（流编辑器）的缩写，简称流编辑器；用来处理文件的。

## 2. sed如何处理文件？

> sed是一行一行读取文件内容并按照要求进行处理，把处理后的结果输出到屏幕。

![sed](http://./sed.png?ynotemdtimestamp=1607388328295)

1. 首先sed读取文件中的一行内容，把其保存在一个临时缓存区中（也称为模式空间）
2. 然后根据需求处理临时缓冲区中的行，完成后把该行发送到屏幕上

**总结：**

1. 由于sed把每一行都存在临时缓冲区中，对这个**副本**进行编辑，所以不会直接修改原文件
2. Sed主要用来自动编辑一个或多个文件；简化对文件的反复操作,对文件进行过滤和转换操作

\#三、sed使用方法介绍

> sed常见的语法格式有两种，一种叫命令行模式，另一种叫脚本模式。

## 1. 命令行格式

### ㈠ 语法格式

sed [options] **'**处理动作**'** 文件名

- **常用选项**

| 选项 | 说明                   | 备注               |
| ---- | ---------------------- | ------------------ |
| -e   | 进行多项(多次)编辑     |                    |
| -n   | 取消默认输出           | 不自动打印模式空间 |
| -r   | 使用扩展正则表达式     |                    |
| -i   | 原地编辑（修改源文件） |                    |
| -f   | 指定sed脚本的文件名    |                    |

- **常见处理动作**

**丑话说在前面**：以下所有的动作都要在**单引号**里，你敢出轨，回家跪搓衣板

| 动作 | 说明                 | 备注             |
| ---- | -------------------- | ---------------- |
| 'p'  | 打印                 |                  |
| 'i'  | 在指定行之前插入内容 | 类似vim里的大写O |
| 'a'  | 在指定行之后插入内容 | 类似vim里的小写o |
| 'c'  | 替换指定行所有内容   |                  |
| 'd'  | 删除指定行           |                  |

### ㈡ 举例说明

- 文件准备

```
# vim a.txt 
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
298374837483
172.16.0.254
10.1.1.1
```

#### ① 对文件进行增、删、改、查操作

> 语法：sed 选项 **'\**定位+命令\**'** 需要处理的文件

##### 1）打印文件内容

```
[root@server ~]# sed ''  a.txt						对文件什么都不做
[root@server ~]# sed -n 'p'  a.txt					打印每一行，并取消默认输出
[root@server ~]# sed -n '1p'  a.txt					打印第1行
[root@server ~]# sed -n '2p'  a.txt					打印第2行
[root@server ~]# sed -n '1,5p'  a.txt				打印1到5行
[root@server ~]# sed -n '$p' a.txt 					打印最后1行
```

##### 2）增加文件内容

i 地址定位的上面插入

a 下面插入

```
[root@server ~]# sed '$a99999' a.txt 				文件最后一行下面增加内容
[root@server ~]# sed 'a99999' a.txt 				文件每行下面增加内容
[root@server ~]# sed '5a99999' a.txt 				文件第5行下面增加内容
[root@server ~]# sed '$i99999' a.txt 				文件最后一行上一行增加内容
[root@server ~]# sed 'i99999' a.txt 				文件每行上一行增加内容
[root@server ~]# sed '6i99999' a.txt 				文件第6行上一行增加内容
[root@server ~]# sed '/^uucp/ihello'				以uucp开头行的上一行插入内容
```

##### 3）修改文件内容

c 替换指定的整行内容

```
[root@server ~]# sed '5chello world' a.txt 		替换文件第5行内容
[root@server ~]# sed 'chello world' a.txt 		替换文件所有内容
[root@server ~]# sed '1,5chello world' a.txt 	替换文件1到5号内容为hello world
[root@server ~]# sed '/^user01/c888888' a.txt	替换以user01开头的行
```

##### 4）删除文件内容

```
[root@server ~]# sed '1d' a.txt 						删除文件第1行
[root@server ~]# sed '1,5d' a.txt 					删除文件1到5行
[root@server ~]# sed '$d' a.txt						删除文件最后一行
```

#### ② 对文件进行搜索替换操作

> 语法：sed 选项 **'s/搜索的内容/替换的内容/动作'** 需要处理的文件
>
> 其中，**s**表示search搜索；斜杠**/**表示分隔符，可以自己定义;动作一般是打印**p**和全局替换**g**

```
[root@server ~]# sed -n 's/root/ROOT/p' 1.txt 
[root@server ~]# sed -n 's/root/ROOT/gp' 1.txt 
[root@server ~]# sed -n 's/^#//gp' 1.txt 
[root@server ~]# sed -n 's@/sbin/nologin@itcast@gp' a.txt
[root@server ~]# sed -n 's/\/sbin\/nologin/itcast/gp' a.txt
[root@server ~]# sed -n '10s#/sbin/nologin#itcast#p' a.txt 
uucp:x:10:14:uucp:/var/spool/uucp:itcast
[root@server ~]# sed -n 's@/sbin/nologin@itcastheima@p' 2.txt 
注意：搜索替换中的分隔符可以自己指定

[root@server ~]# sed -n '1,5s/^/#/p' a.txt 		注释掉文件的1-5行内容
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
#adm:x:3:4:adm:/var/adm:/sbin/nologin
#lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

#### ③ 其他命令

| 命令 | 解释                                       | 备注       |
| ---- | ------------------------------------------ | ---------- |
| r    | 从另外文件中读取内容                       |            |
| w    | 内容另存为                                 |            |
| &    | 保存查找串以便在替换串中引用               | 和\(\)相同 |
| =    | 打印行号                                   |            |
| ！   | 对所选行以外的所有行应用命令，放到行数之后 | '1,5!'     |
| q    | 退出                                       |            |

**举例说明：**

```
r	从文件中读取输入行
w	将所选的行写入文件
[root@server ~]# sed '3r /etc/hosts' 2.txt 
[root@server ~]# sed '$r /etc/hosts' 2.txt
[root@server ~]# sed '/root/w a.txt' 2.txt 
[root@server ~]# sed '/[0-9]{4}/w a.txt' 2.txt
[root@server ~]# sed  -r '/([0-9]{1,3}\.){3}[0-9]{1,3}/w b.txt' 2.txt

!	对所选行以外的所有行应用命令，放到行数之后
[root@server ~]# sed -n '1!p' 1.txt 
[root@server ~]# sed -n '4p' 1.txt 
[root@server ~]# sed -n '4!p' 1.txt 
[root@server ~]# cat -n 1.txt 
[root@server ~]# sed -n '1,17p' 1.txt 
[root@server ~]# sed -n '1,17!p' 1.txt 

&   保存查找串以便在替换串中引用   \(\)

[root@server ~]# sed -n '/root/p' a.txt 
root:x:0:0:root:/root:/bin/bash
[root@server ~]# sed -n 's/root/#&/p' a.txt 
#root:x:0:0:root:/root:/bin/bash

# sed -n 's/^root/#&/p' passwd   注释掉以root开头的行
# sed -n -r 's/^root|^stu/#&/p' /etc/passwd	注释掉以root开头或者以stu开头的行
# sed -n '1,5s/^[a-z].*/#&/p' passwd  注释掉1~5行中以任意小写字母开头的行
# sed -n '1,5s/^/#/p' /etc/passwd  注释1~5行
或者
sed -n '1,5s/^/#/p' passwd 以空开头的加上#
sed -n '1,5s/^#//p' passwd 以#开头的替换成空

[root@server ~]# sed -n '/^root/p' 1.txt 
[root@server ~]# sed -n 's/^root/#&/p' 1.txt 
[root@server ~]# sed -n 's/\(^root\)/#\1/p' 1.txt 
[root@server ~]# sed -nr '/^root|^stu/p' 1.txt 
[root@server ~]# sed -nr 's/^root|^stu/#&/p' 1.txt 


= 	打印行号
# sed -n '/bash$/=' passwd    打印以bash结尾的行的行号
# sed -ne '/root/=' -ne '/root/p' passwd 
# sed -n '/nologin$/=;/nologin$/p' 1.txt
# sed -ne '/nologin$/=' -ne '/nologin$/p' 1.txt

q	退出
# sed '5q' 1.txt
# sed '/mail/q' 1.txt
# sed -r '/^yunwei|^mail/q' 1.txt
[root@server ~]# sed -n '/bash$/p;10q' 1.txt
ROOT:x:0:0:root:/root:/bin/bash


综合运用：
[root@server ~]# sed -n '1,5s/^/#&/p' 1.txt 
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
#adm:x:3:4:adm:/var/adm:/sbin/nologin
#lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

[root@server ~]# sed -n '1,5s/\(^\)/#\1/p' 1.txt 
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
#adm:x:3:4:adm:/var/adm:/sbin/nologin
#lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

#### ④ 其他选项

```
-e 多项编辑
-r	扩展正则
-i 修改原文件

[root@server ~]# sed -ne '/root/p' 1.txt -ne '/root/='
root:x:0:0:root:/root:/bin/bash
1
[root@server ~]# sed -ne '/root/=' -ne '/root/p' 1.txt 
1
root:x:0:0:root:/root:/bin/bash

在1.txt文件中的第5行的前面插入“hello world”;在1.txt文件的第8行下面插入“哈哈哈哈”

[root@server ~]# sed -e '5ihello world' -e '8a哈哈哈哈哈' 1.txt  -e '5=;8='

sed -n '1,5p' 1.txt
sed -ne '1p' -ne '5p' 1.txt
sed -ne '1p;5p' 1.txt

过滤vsftpd.conf文件中以#开头和空行：
[root@server ~]# grep -Ev '^#|^$' /etc/vsftpd/vsftpd.conf
[root@server ~]# sed -e '/^#/d' -e '/^$/d' /etc/vsftpd/vsftpd.conf
[root@server ~]# sed '/^#/d;/^$/d' /etc/vsftpd/vsftpd.conf
[root@server ~]# sed -r '/^#|^$/d' /etc/vsftpd/vsftpd.conf

过滤smb.conf文件中生效的行：
# sed -e '/^#/d' -e '/^;/d' -e '/^$/d' -e '/^\t$/d' -e '/^\t#/d' smb.conf
# sed -r '/^(#|$|;|\t#|\t$)/d' smb.conf 

# sed -e '/^#/d' -e '/^;/d' -e '/^$/d' -e '/^\t$/d' -e '/^\t#/' smb.conf


[root@server ~]# grep '^[^a-z]' 1.txt

[root@server ~]# sed -n '/^[^a-z]/p' 1.txt

过滤出文件中的IP地址：
[root@server ~]# grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' 1.txt 
192.168.0.254
[root@server ~]# sed -nr '/([0-9]{1,3}\.){3}[0-9]{1,3}/p' 1.txt 
192.168.0.254

[root@server ~]# grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}' 2.txt 
10.1.1.1
10.1.1.255
255.255.255.0

[root@server ~]# sed -nr '/([0-9]{1,3}\.){3}[0-9]{1,3}/p' 2.txt
10.1.1.1
10.1.1.255
255.255.255.0
过滤出ifcfg-eth0文件中的IP、子网掩码、广播地址
[root@server shell06]# grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ifcfg-eth0 
10.1.1.1
255.255.255.0
10.1.1.254
[root@server shell06]# sed -nr '/([0-9]{1,3}\.){3}[0-9]{1,3}/p' ifcfg-eth0|cut -d'=' -f2
10.1.1.1
255.255.255.0
10.1.1.254
[root@server shell06]# sed -nr '/([0-9]{1,3}\.){3}[0-9]{1,3}/p' ifcfg-eth0|sed -n 's/[A-Z=]//gp'
10.1.1.1
255.255.255.0
10.1.1.254

[root@server shell06]# ifconfig eth0|sed -n '2p'|sed -n 's/[:a-Z]//gp'|sed -n 's/ /\n/gp'|sed '/^$/d'
10.1.1.1
10.1.1.255
255.255.255.0
[root@server shell06]# ifconfig | sed -nr '/([0-9]{1,3}\.)[0-9]{1,3}/p' | head -1|sed -r 's/([a-z:]|[A-Z/t])//g'|sed 's/ /\n/g'|sed  '/^$/d'

[root@server shell06]# ifconfig eth0|sed -n '2p'|sed -n 's/.*addr:\(.*\) Bcast:\(.*\) Mask:\(.*\)/\1\n\2\n\3/p'
10.1.1.1 
10.1.1.255 
255.255.255.0

-i 选项  直接修改原文件
# sed -i 's/root/ROOT/;s/stu/STU/' 11.txt
# sed -i '17{s/YUNWEI/yunwei/;s#/bin/bash#/sbin/nologin#}' 1.txt
# sed -i '1,5s/^/#&/' a.txt
注意：
-ni  不要一起使用
p命令 不要再使用-i时使用
```

#### ⑤ sed结合正则使用

> sed 选项 'sed命令或者正则表达式或者地址定位=='== 文件名

1. 定址用于决定对哪些行进行编辑。地址的形式可以是数字、正则表达式、或二者的结合。
2. 如果没有指定地址，sed将处理输入文件的所有行。

| 正则          | 说明                                                        | 备注                            |
| ------------- | ----------------------------------------------------------- | ------------------------------- |
| /key/         | 查询包含关键字的行                                          | sed -n '/root/p' 1.txt          |
| /key1/,/key2/ | 匹配包含两个关键字之间的行                                  | sed -n '/^adm/,/^mysql/p' 1.txt |
| /key/,x       | 从匹配关键字的行开始到文件第x行之间的行（包含关键字所在行） | sed -n '/^ftp/,7p'              |
| x,/key/       | 从文件的第x行开始到与关键字的匹配行之间的行                 |                                 |
| x,y!          | 不包含x到y行                                                |                                 |
| /key/!        | 不包括关键字的行                                            | sed -n '/bash$/!p' 1.txt        |

\##2. 脚本格式

### ㈠ 用法

```
# sed -f scripts.sh  file		//使用脚本处理文件
建议使用   ./sed.sh   file

脚本的第一行写上
#!/bin/sed -f
1,5d
s/root/hello/g
3i777
5i888
a999
p
```

### ㈡ 注意事项

```
１）　脚本文件是一个sed的命令行清单。'commands'
２）　在每行的末尾不能有任何空格、制表符（tab）或其它文本。
３）　如果在一行中有多个命令，应该用分号分隔。
４）　不需要且不可用引号保护命令
５）　#号开头的行为注释
```

### ㈢举例说明

```
# cat passwd
stu3:x:509:512::/home/user3:/bin/bash
stu4:x:510:513::/home/user4:/bin/bash
stu5:x:511:514::/home/user5:/bin/bash

# cat sed.sh 
#!/bin/sed -f
2a\
******************
2,$s/stu/user/
$a\
we inster new line
s/^[a-z].*/#&/

[root@server ~]# cat 1.sed 
#!/bin/sed -f
3a**********************
$chelloworld
1,3s/^/#&/

[root@server ~]# sed -f 1.sed -i 11.txt 
[root@server ~]# cat 11.txt 
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
**********************
adm:x:3:4:adm:/var/adm:/sbin/nologin
helloworld
```

\##3. 补充扩展总结

```
1、正则表达式必须以”/“前后规范间隔
例如：sed '/root/d' file
例如：sed '/^root/d' file

2、如果匹配的是扩展正则表达式，需要使用-r选来扩展sed
grep -E
sed -r
+ ? () {n,m} | \d

注意：         
在正则表达式中如果出现特殊字符(^$.*/[]),需要以前导 "\" 号做转义
eg：sed '/\$foo/p' file

3、逗号分隔符
例如：sed '5,7d' file  				删除5到7行
例如：sed '/root/,/ftp/d' file	
删除第一个匹配字符串"root"到第一个匹配字符串"ftp"的所有行本行不找 循环执行
       
4、组合方式
例如：sed '1,/foo/d' file			删除第一行到第一个匹配字符串"foo"的所有行
例如：sed '/foo/,+4d' file			删除从匹配字符串”foo“开始到其后四行为止的行
例如：sed '/foo/,~3d' file			删除从匹配字符串”foo“开始删除到3的倍数行（文件中）
例如：sed '1~5d' file				从第一行开始删每五行删除一行
例如：sed -nr '/foo|bar/p' file	显示配置字符串"foo"或"bar"的行
例如：sed -n '/foo/,/bar/p' file	显示匹配从foo到bar的行
例如：sed '1~2d'  file				删除奇数行
例如：sed '0-2d'   file				删除偶数行 sed '1~2!d'  file

5、特殊情况
例如：sed '$d' file					删除最后一行
例如：sed '1d' file					删除第一行
	
6、其他：
sed 's/.//' a.txt						删除每一行中的第一个字符
sed 's/.//2' a.txt					删除每一行中的第二个字符
sed 's/.//N' a.txt					从文件中第N行开始，删除每行中第N个字符（N>2）
sed 's/.$//' a.txt					删除每一行中的最后一个字符


[root@server ~]# cat 2.txt 
1 a
2 b
3 c
4 d
5 e
6 f
7 u
8 k
9 o
[root@server ~]# sed '/c/,~2d' 2.txt 
1 a
2 b
5 e
6 f
7 u
8 k
9 o
```

\#四、课堂练习

1. 将任意数字替换成空或者制表符
2. 去掉文件1-5行中的数字、冒号、斜杠
3. 匹配root关键字替换成hello itcast，并保存到test.txt文件中
4. 删除vsftpd.conf、smb.conf、main.cf配置文件里所有注释的行及空行（不要直接修改原文件）
5. 使用sed命令截取自己的ip地址
6. 使用sed命令一次性截取ip地址、广播地址、子网掩码
7. 注释掉文件的2-3行和匹配到以root开头或者以ftp开头的行

```
1、将文件中任意数字替换成空或者制表符
2、去掉文件1-5行中的数字、冒号、斜杠
3、匹配root关键字的行替换成hello itcast，并保存到test.txt文件中
4、删除vsftpd.conf、smb.conf、main.cf配置文件里所有注释的行及空行（不要直接修改原文件）
5、使用sed命令截取自己的ip地址
# ifconfig eth0|sed -n '2p'|sed -n 's/.*addr://pg'|sed -n 's/Bcast.*//gp'
10.1.1.1  
# ifconfig eth0|sed -n '2p'|sed 's/.*addr://g'|sed 's/ Bcast:.*//g'
6、使用sed命令一次性截取ip地址、广播地址、子网掩码
# ifconfig eth0|sed -n '2p'|sed -n 's#.*addr:\(.*\) Bcast:\(.*\) Mask:\(.*\)#\1\n\2\n\3#p'
10.1.1.1 
10.1.1.255 
255.255.255.0

7、注释掉文件的2-3行和匹配到以root开头或者以ftp开头的行
# sed -nr '2,3s/^/#&/p;s/^ROOT|^ftp/#&/p' 1.txt
#ROOT:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#3daemon:x:2:2:daemon:/sbin:/sbin/nologin

# sed -ne '1,2s/^/#&/gp' a.txt -nre 's/^lp|^mail/#&/gp'
# sed -nr '1,2s/^/#&/gp;s/^lp|^mail/#&/gp' a.txt
```

\#五、课后实战

1、写一个初始化系统的脚本 1）自动修改主机名（如：ip是192.168.0.88，[则主机名改为server88.itcast.cc](http://xn--server88-wg0mja300iq0f268df4f.itcast.cc/)）

a. 更改文件非交互式 sed

/etc/sysconfig/network

b.将本主机的IP截取出来赋值给一个变量ip;再然后将ip变量里以.分割的最后一位赋值给另一个变量ip1

2）自动配置可用的yum源

3）自动关闭防火墙和selinux

2、写一个搭建ftp服务的脚本，要求如下： 1）不支持本地用户登录	local_enable=NO 2） 匿名用户可以上传 新建 删除	anon_upload_enable=YES anon_mkdir_write_enable=YES	3） 匿名用户限速500KBps anon_max_rate=500000

```shell
仅供参考：
#!/bin/bash
ipaddr=`ifconfig eth0|sed -n '2p'|sed -e 's/.*inet addr:\(.*\) Bcast.*/\1/g'`
iptail=`echo $ipaddr|cut -d'.' -f4`
ipremote=192.168.1.10
#修改主机名
hostname server$iptail.itcast.com
sed -i "/HOSTNAME/cHOSTNAME=server$iptail.itcast.com" /etc/sysconfig/network
echo "$ipaddr server$iptail.itcast.cc" >>/etc/hosts
#关闭防火墙和selinux
service iptables stop
setenforce 0 >/dev/null 2>&1
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
#配置yum源(一般是内网源)
#test network
ping -c 1 $ipremote > /dev/null 2>&1
if [ $? -ne 0 ];then
	echo "你的网络不通，请先检查你的网络"
	exit 1
else
	echo "网络ok."
fi
cat > /etc/yum.repos.d/server.repo << end
[server]
name=server
baseurl=ftp://$ipremote
enabled=1
gpgcheck=0
end

#安装软件
read -p "请输入需要安装的软件，多个用空格隔开：" soft
yum -y install $soft &>/dev/null

#备份配置文件
conf=/etc/vsftpd/vsftpd.conf
\cp $conf $conf.default
#根据需求修改配置文件
sed -ir '/^#|^$/d' $conf
sed -i '/local_enable/c\local_enable=NO' $conf
sed -i '$a anon_upload_enable=YES' $conf
sed -i '$a anon_mkdir_write_enable=YES' $conf
sed -i '$a anon_other_write_enable=YES' $conf
sed -i '$a anon_max_rate=512000' $conf
#启动服务
service vsftpd restart &>/dev/null && echo"vsftpd服务启动成功"

#测试验证
chmod 777 /var/ftp/pub
cp /etc/hosts /var/ftp/pub
#测试下载
cd /tmp
lftp $ipaddr <<end
cd pub
get hosts
exit
end

if [ -f /tmp/hosts ];then
	echo "匿名用户下载成功"
	rm -f /tmp/hosts
else
	echo "匿名用户下载失败"
fi
#测试上传、创建目录、删除目录等
cd /tmp
lftp $ipaddr << end
cd pub
mkdir test1
mkdir test2
put /etc/group
rmdir test2
exit
end

if [ -d /var/ftp/pub/test1 ];then
    echo "创建目录成功"
	if [ ! -d /var/ftp/pub/test2 ];then
    	echo "文件删除成功"
        fi
else
	if [ -f /var/ftp/pub/group ];then
	echo "文件上传成功"
        else
        echo "上传、创建目录删除目录部ok"
        fi 
fi   
[ -f /var/ftp/pub/group ] && echo "上传文件成功"
```





- - [typora-root-url: pictures](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#typora-root-url-pictures)
- 一、awk介绍
  - [1. awk概述](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-awk概述)
  - [2. awk能干啥?](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-awk能干啥)
  - \1. 命令行模式使用
    - [㈠ 语法结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-语法结构)
  - \2. 脚本模式使用
    - [㈠ 脚本编写](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-脚本编写)
    - [㈡ 脚本执行](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-脚本执行)
  - [1、常用内置变量举例](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-常用内置变量举例)
  - [2、内置变量分隔符举例](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-内置变量分隔符举例)
- 五、awk使用进阶
  - [1. 格式化输出`print`和`printf`](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-格式化输出print和printf)
  - \2. awk变量定义
    - - [㈠ 举例说明1](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-举例说明1)
      - [㈡ 举例说明2](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#二-举例说明2)
    - [㈠ 举例说明](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#一-举例说明)
  - \4. 课堂练习
    - ㈠ 流程控制语句
      - [① if结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-if结构)
      - [② if...else结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-ifelse结构)
      - [③ if...elif...else结构](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-ifelifelse结构)
    - ㈡ 循环语句
      - [① for循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-for循环)
      - [② while循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-while循环)
      - [③ 嵌套循环](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-嵌套循环)
- 六、awk统计案例
  - [1、统计系统中各种类型的shell](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-统计系统中各种类型的shell)
  - [2、统计网站访问状态](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-统计网站访问状态)
  - [3、统计访问网站的每个IP的数量](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-统计访问网站的每个ip的数量)
  - 4、统计网站日志中PV量
    - - [1. 任务/背景](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#1-任务背景)
      - [2. 具体要求](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#2-具体要求)
      - [3. 涉及知识点](https://note.youdao.com/md/preview.html?file=%2Fyws%2Fapi%2Fpersonal%2Ffile%2F8B95F12DC08648A49F90FF43C3CB99DE%3Fmethod%3Ddownload%26read%3Dtrue%26shareKey%3Db402ca42248d060e7bdd5ee145f47cc5#3-涉及知识点)

\#课程目标



- 熟悉awk的**命令行模式**基本语法结构
- 熟悉awk的相关内部变量
- 熟悉awk常用的打印函数print
- 能够在awk中匹配正则表达式打印相关的行

# 一、awk介绍

## 1. awk概述

- awk是一种编程语言，主要用于在linux/unix下对文本和数据进行处理，是linux/unix下的一个工具。数据可以来自标准输入、一个或多个文件，或其它命令的输出。
- awk的处理文本和数据的方式：**逐行扫描文件**，默认从第一行到最后一行，寻找匹配的特定模式的行，并在这些行上进行你想要的操作。
- awk分别代表其作者姓氏的第一个字母。因为它的作者是三个人，分别是Alfred Aho、Brian Kernighan、Peter Weinberger。
- gawk是awk的GNU版本，它提供了Bell实验室和GNU的一些扩展。

- 下面介绍的awk是以GNU的gawk为例的，在linux系统中已把awk链接到gawk，所以下面全部以awk进行介绍。

## 2. awk能干啥?

1. awk用来处理文件和数据的，是类unix下的一个工具，也是一种编程语言
2. 可以用来统计数据，比如网站的访问量，访问的IP量等等
3. 支持条件判断，支持for和while循环

\#二、awk使用方式

## 1. 命令行模式使用

### ㈠ 语法结构

```
awk 选项 '命令部分' 文件名


特别说明：
引用shell变量需用双引号引起
```

\###㈡ 常用选项介绍

- -F 定义字段分割符号，默认的分隔符是空格
- -v 定义变量并赋值

\###㈢ **'\**命名部分说明\**'**

- 正则表达式，地址定位

```
'/root/{awk语句}'				sed中： '/root/p'
'NR==1,NR==5{awk语句}'			sed中： '1,5p'
'/^root/,/^ftp/{awk语句}'  	sed中：'/^root/,/^ftp/p'
```

- {awk语句1**;**awk语句2**;**...}

```
'{print $0;print $1}'		sed中：'p'
'NR==5{print $0}'				sed中：'5p'
注：awk命令语句间用分号间隔
```

- BEGIN...END....

```
'BEGIN{awk语句};{处理中};END{awk语句}'
'BEGIN{awk语句};{处理中}'
'{处理中};END{awk语句}'
```

## 2. 脚本模式使用

### ㈠ 脚本编写

```
#!/bin/awk -f 		定义魔法字符
以下是awk引号里的命令清单，不要用引号保护命令，多个命令用分号间隔
BEGIN{FS=":"}
NR==1,NR==3{print $1"\t"$NF}
...
```

### ㈡ 脚本执行

```
方法1：
awk 选项 -f awk的脚本文件  要处理的文本文件
awk -f awk.sh filename

sed -f sed.sh -i filename

方法2：
./awk的脚本文件(或者绝对路径)	要处理的文本文件
./awk.sh filename

./sed.sh filename
```

\#三、 awk内部相关变量

| 变量          | 变量说明                           | 备注                              |
| ------------- | ---------------------------------- | --------------------------------- |
| $0            | 当前处理行的所有记录               |                                   |
| $1,$2,$3...$n | 文件中每行以间隔符号分割的不同字段 | awk -F: '{print $1,$3}'           |
| NF            | 当前记录的字段数（列数）           | awk -F: '{print NF}'              |
| $NF           | 最后一列                           | $(NF-1)表示倒数第二列             |
| FNR/NR        | 行号                               |                                   |
| FS            | 定义间隔符                         | 'BEGIN{FS=":"};{print $1,$3}'     |
| OFS           | 定义输出字段分隔符，默认空格       | 'BEGIN{OFS="\t"};print $1,$3}'    |
| RS            | 输入记录分割符，默认换行           | 'BEGIN{RS="\t"};{print $0}'       |
| ORS           | 输出记录分割符，默认换行           | 'BEGIN{ORS="\n\n"};{print $1,$3}' |
| FILENAME      | 当前输入的文件名                   |                                   |

## 1、常用内置变量举例

```
# awk -F: '{print $1,$(NF-1)}' 1.txt
# awk -F: '{print $1,$(NF-1),$NF,NF}' 1.txt
# awk '/root/{print $0}' 1.txt
# awk '/root/' 1.txt
# awk -F: '/root/{print $1,$NF}' 1.txt 
root /bin/bash
# awk -F: '/root/{print $0}' 1.txt      
root:x:0:0:root:/root:/bin/bash
# awk 'NR==1,NR==5' 1.txt 
# awk 'NR==1,NR==5{print $0}' 1.txt
# awk 'NR==1,NR==5;/^root/{print $0}' 1.txt 
root:x:0:0:root:/root:/bin/bash
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

## 2、内置变量分隔符举例

```
FS和OFS:
# awk 'BEGIN{FS=":"};/^root/,/^lp/{print $1,$NF}' 1.txt
# awk -F: 'BEGIN{OFS="\t\t"};/^root/,/^lp/{print $1,$NF}' 1.txt        
root            /bin/bash
bin             /sbin/nologin
daemon          /sbin/nologin
adm             /sbin/nologin
lp              /sbin/nologin
# awk -F: 'BEGIN{OFS="@@@"};/^root/,/^lp/{print $1,$NF}' 1.txt     
root@@@/bin/bash
bin@@@/sbin/nologin
daemon@@@/sbin/nologin
adm@@@/sbin/nologin
lp@@@/sbin/nologin
[root@server shell07]# 

RS和ORS：
修改源文件前2行增加制表符和内容：
vim 1.txt
root:x:0:0:root:/root:/bin/bash hello   world
bin:x:1:1:bin:/bin:/sbin/nologin        test1   test2

# awk 'BEGIN{RS="\t"};{print $0}' 1.txt
# awk 'BEGIN{ORS="\t"};{print $0}' 1.txt
```

\#四、 awk工作原理

```
awk -F: '{print $1,$3}' /etc/passwd
```

1. awk使用一行作为输入，并将这一行赋给内部变量$0，每一行也可称为一个记录，以换行符(RS)结束

2. 每行被间隔符**:**(默认为空格或制表符)分解成字段(或域)，每个字段存储在已编号的变量中，从$1开始

   问：awk如何知道用空格来分隔字段的呢？

   答：因为有一个内部变量FS来确定字段分隔符。初始时，FS赋为空格

3. awk使用print函数打印字段，打印出来的字段会以空格分隔，因为$1,$3之间有一个逗号。逗号比较特殊，它映射为另一个内部变量，称为输出字段分隔符OFS，OFS默认为空格

4. awk处理完一行后，将从文件中获取另一行，并将其存储在$0中，覆盖原来的内容，然后将新的字符串分隔成字段并进行处理。该过程将持续到所有行处理完毕

# 五、awk使用进阶

## 1. 格式化输出`print`和`printf`

```
print函数		类似echo "hello world"
# date |awk '{print "Month: "$2 "\nYear: "$NF}'
# awk -F: '{print "username is: " $1 "\t uid is: "$3}' /etc/passwd


printf函数		类似echo -n
# awk -F: '{printf "%-15s %-10s %-15s\n", $1,$2,$3}'  /etc/passwd
# awk -F: '{printf "|%15s| %10s| %15s|\n", $1,$2,$3}' /etc/passwd
# awk -F: '{printf "|%-15s| %-10s| %-15s|\n", $1,$2,$3}' /etc/passwd

awk 'BEGIN{FS=":"};{printf "%-15s %-15s %-15s\n",$1,$6,$NF}' a.txt

%s 字符类型  strings			%-20s
%d 数值类型	
占15字符
- 表示左对齐，默认是右对齐
printf默认不会在行尾自动换行，加\n
```

## 2. awk变量定义

```
# awk -v NUM=3 -F: '{ print $NUM }' /etc/passwd
# awk -v NUM=3 -F: '{ print NUM }' /etc/passwd
# awk -v num=1 'BEGIN{print num}' 
1
# awk -v num=1 'BEGIN{print $num}' 
注意：
awk中调用定义的变量不需要加$
```

\##3. awk中BEGIN...END使用

​	①BEGIN：表示在程序开始前执行

​	②END ：表示所有文件处理完后执行

​	③用法：`'BEGIN{开始处理之前};{处理中};END{处理结束后}'`

#### ㈠ 举例说明1

**打印最后一列和倒数第二列（登录shell和家目录）**

```
awk -F: 'BEGIN{ print "Login_shell\t\tLogin_home\n*******************"};{print $NF"\t\t"$(NF-1)};END{print "************************"}' 1.txt

awk 'BEGIN{ FS=":";print "Login_shell\tLogin_home\n*******************"};{print $NF"\t"$(NF-1)};END{print "************************"}' 1.txt

Login_shell		Login_home
************************
/bin/bash		/root
/sbin/nologin		/bin
/sbin/nologin		/sbin
/sbin/nologin		/var/adm
/sbin/nologin		/var/spool/lpd
/bin/bash		/home/redhat
/bin/bash		/home/user01
/sbin/nologin		/var/named
/bin/bash		/home/u01
/bin/bash		/home/YUNWEI
************************************
```

#### ㈡ 举例说明2

**打印/etc/passwd里的用户名、家目录及登录shell**

```
u_name      h_dir       shell
***************************

***************************

awk -F: 'BEGIN{OFS="\t\t";print"u_name\t\th_dir\t\tshell\n***************************"};{printf "%-20s %-20s %-20s\n",$1,$(NF-1),$NF};END{print "****************************"}'


# awk -F: 'BEGIN{print "u_name\t\th_dir\t\tshell" RS "*****************"}  {printf "%-15s %-20s %-20s\n",$1,$(NF-1),$NF}END{print "***************************"}'  /etc/passwd

格式化输出：
echo		print
echo -n	printf

{printf "%-15s %-20s %-20s\n",$1,$(NF-1),$NF}
```

### 4. awk和正则的综合运用

| 运算符 | 说明     |
| ------ | -------- |
| ==     | 等于     |
| !=     | 不等于   |
| >      | 大于     |
| <      | 小于     |
| >=     | 大于等于 |
| <=     | 小于等于 |
| ~      | 匹配     |
| !~     | 不匹配   |
| !      | 逻辑非   |
| &&     | 逻辑与   |
| \|\|   | 逻辑或   |

### ㈠ 举例说明

```
从第一行开始匹配到以lp开头行
awk -F: 'NR==1,/^lp/{print $0 }' passwd  
从第一行到第5行          
awk -F: 'NR==1,NR==5{print $0 }' passwd
从以lp开头的行匹配到第10行       
awk -F: '/^lp/,NR==10{print $0 }' passwd 
从以root开头的行匹配到以lp开头的行       
awk -F: '/^root/,/^lp/{print $0}' passwd
打印以root开头或者以lp开头的行            
awk -F: '/^root/ || /^lp/{print $0}' passwd
awk -F: '/^root/;/^lp/{print $0}' passwd
显示5-10行   
awk -F':' 'NR>=5 && NR<=10 {print $0}' /etc/passwd     
awk -F: 'NR<10 && NR>5 {print $0}' passwd 

打印30-39行以bash结尾的内容：
[root@MissHou shell06]# awk 'NR>=30 && NR<=39 && $0 ~ /bash$/{print $0}' passwd 
stu1:x:500:500::/home/stu1:/bin/bash
yunwei:x:501:501::/home/yunwei:/bin/bash
user01:x:502:502::/home/user01:/bin/bash
user02:x:503:503::/home/user02:/bin/bash
user03:x:504:504::/home/user03:/bin/bash

[root@MissHou shell06]# awk 'NR>=3 && NR<=8 && /bash$/' 1.txt  
stu7:x:1007:1007::/rhome/stu7:/bin/bash
stu8:x:1008:1008::/rhome/stu8:/bin/bash
stu9:x:1009:1009::/rhome/stu9:/bin/bash

打印文件中1-5并且以root开头的行
[root@MissHou shell06]# awk 'NR>=1 && NR<=5 && $0 ~ /^root/{print $0}' 1.txt
root:x:0:0:root:/root:/bin/bash
[root@MissHou shell06]# awk 'NR>=1 && NR<=5 && $0 !~ /^root/{print $0}' 1.txt
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin


理解;号和||的含义：
[root@MissHou shell06]# awk 'NR>=3 && NR<=8 || /bash$/' 1.txt
[root@MissHou shell06]# awk 'NR>=3 && NR<=8;/bash$/' 1.txt


打印IP地址
# ifconfig eth0|awk 'NR>1 {print $2}'|awk -F':' 'NR<2 {print $2}'    
# ifconfig eth0|grep Bcast|awk -F':' '{print $2}'|awk '{print $1}'
# ifconfig eth0|grep Bcast|awk '{print $2}'|awk -F: '{print $2}'


# ifconfig eth0|awk NR==2|awk -F '[ :]+' '{print $4RS$6RS$8}'
# ifconfig eth0|awk -F"[ :]+" '/inet addr:/{print $4}'
```

## 4. 课堂练习

1. 显示可以登录操作系统的用户所有信息 从第7列匹配以bash结尾，输出整行（当前行所有的列）

```
[root@MissHou ~] awk '/bash$/{print $0}'    /etc/passwd
[root@MissHou ~] awk '/bash$/{print $0}' /etc/passwd
[root@MissHou ~] awk '/bash$/' /etc/passwd
[root@MissHou ~] awk -F: '$7 ~ /bash/' /etc/passwd
[root@MissHou ~] awk -F: '$NF ~ /bash/' /etc/passwd
[root@MissHou ~] awk -F: '$0 ~ /bash/' /etc/passwd
[root@MissHou ~] awk -F: '$0 ~ /\/bin\/bash/' /etc/passwd
```

1. 显示可以登录系统的用户名

```
# awk -F: '$0 ~ /\/bin\/bash/{print $1}' /etc/passwd
```

1. 打印出系统中普通用户的UID和用户名

```
500	stu1
501	yunwei
502	user01
503	user02
504	user03


# awk -F: 'BEGIN{print "UID\tUSERNAME"} {if($3>=500 && $3 !=65534 ) {print $3"\t"$1} }' /etc/passwdUID	USERNAME


# awk -F: '{if($3 >= 500 && $3 != 65534) print $1,$3}' a.txt 
redhat 508
user01 509
u01 510
YUNWEI 511
```

\##5. awk的脚本编程

### ㈠ 流程控制语句

#### ① if结构

```
if语句：

if [ xxx ];then
xxx
fi

格式：
awk 选项 '正则，地址定位{awk语句}'  文件名

{ if(表达式)｛语句1;语句2;...｝}

awk -F: '{if($3>=500 && $3<=60000) {print $1,$3} }' passwd

# awk -F: '{if($3==0) {print $1"是管理员"} }' passwd 
root是管理员

# awk 'BEGIN{if('$(id -u)'==0) {print "admin"} }'
admin
```

#### ② if...else结构

```
if...else语句:
if [ xxx ];then
	xxxxx
	
else
	xxx
fi

格式：
{if(表达式)｛语句;语句;...｝else｛语句;语句;...}}

awk -F: '{ if($3>=500 && $3 != 65534) {print $1"是普通用户"} else {print $1,"不是普通用户"}}' passwd 

awk 'BEGIN{if( '$(id -u)'>=500 && '$(id -u)' !=65534 ) {print "是普通用户"} else {print "不是普通用户"}}'
```

#### ③ if...elif...else结构

```
if [xxxx];then
	xxxx
elif [xxx];then
	xxx
....
else
...
fi


if...else if...else语句：

格式：
{ if(表达式1)｛语句;语句；...｝else if(表达式2)｛语句;语句；...｝else if(表达式3)｛语句;语句；...｝else｛语句;语句；...｝}

awk -F: '{ if($3==0) {print $1,":是管理员"} else if($3>=1 && $3<=499 || $3==65534 ) {print $1,":是系统用户"} else {print $1,":是普通用户"}}'


awk -F: '{ if($3==0) {i++} else if($3>=1 && $3<=499 || $3==65534 ) {j++} else {k++}};END{print "管理员个数为:"i "\n系统用户个数为:"j"\n普通用户的个数为:"k }'


# awk -F: '{if($3==0) {print $1,"is admin"} else if($3>=1 && $3<=499 || $3==65534) {print $1,"is sys users"} else {print $1,"is general user"} }' a.txt 

root is admin
bin is sys users
daemon is sys users
adm is sys users
lp is sys users
redhat is general user
user01 is general user
named is sys users
u01 is general user
YUNWEI is general user

awk -F: '{  if($3==0) {print $1":管理员"} else if($3>=1 && $3<500 || $3==65534 ) {print $1":是系统用户"} else {print $1":是普通用户"}}'   /etc/passwd


awk -F: '{if($3==0) {i++} else if($3>=1 && $3<500 || $3==65534){j++} else {k++}};END{print "管理员个数为:" i RS "系统用户个数为:"j RS "普通用户的个数为:"k }' /etc/passwd
管理员个数为:1
系统用户个数为:28
普通用户的个数为:27


# awk -F: '{ if($3==0) {print $1":是管理员"} else if($3>=500 && $3!=65534) {print $1":是普通用户"} else {print $1":是系统用户"}}' passwd 

awk -F: '{if($3==0){i++} else if($3>=500){k++} else{j++}} END{print i; print k; print j}' /etc/passwd

awk -F: '{if($3==0){i++} else if($3>999){k++} else{j++}} END{print "管理员个数: "i; print "普通用个数: "k; print "系统用户: "j}' /etc/passwd 

如果是普通用户打印默认shell，如果是系统用户打印用户名
# awk -F: '{if($3>=1 && $3<500 || $3 == 65534) {print $1} else if($3>=500 && $3<=60000 ) {print $NF} }' /etc/passwd
```

### ㈡ 循环语句

#### ① for循环

```
打印1~5
for ((i=1;i<=5;i++));do echo $i;done

# awk 'BEGIN { for(i=1;i<=5;i++) {print i} }'
打印1~10中的奇数
# for ((i=1;i<=10;i+=2));do echo $i;done|awk '{sum+=$0};END{print sum}'
# awk 'BEGIN{ for(i=1;i<=10;i+=2) {print i} }'
# awk 'BEGIN{ for(i=1;i<=10;i+=2) print i }'

计算1-5的和
# awk 'BEGIN{sum=0;for(i=1;i<=5;i++) sum+=i;print sum}'
# awk 'BEGIN{for(i=1;i<=5;i++) (sum+=i);{print sum}}'
# awk 'BEGIN{for(i=1;i<=5;i++) (sum+=i);print sum}'
```

#### ② while循环

```
打印1-5
# i=1;while (($i<=5));do echo $i;let i++;done

# awk 'BEGIN { i=1;while(i<=5) {print i;i++} }'
打印1~10中的奇数
# awk 'BEGIN{i=1;while(i<=10) {print i;i+=2} }'
计算1-5的和
# awk 'BEGIN{i=1;sum=0;while(i<=5) {sum+=i;i++}; print sum }'
# awk 'BEGIN {i=1;while(i<=5) {(sum+=i) i++};print sum }'
```

#### ③ 嵌套循环

```
嵌套循环：
#!/bin/bash
for ((y=1;y<=5;y++))
do
	for ((x=1;x<=$y;x++))
	do
		echo -n $x	
	done
echo
done

awk 'BEGIN{ for(y=1;y<=5;y++) {for(x=1;x<=y;x++) {printf x} ;print } }'


# awk 'BEGIN { for(y=1;y<=5;y++) { for(x=1;x<=y;x++) {printf x};print} }'
1
12
123
1234
12345

# awk 'BEGIN{ y=1;while(y<=5) { for(x=1;x<=y;x++) {printf x};y++;print}}'
1
12
123
1234
12345

尝试用三种方法打印99口诀表：
#awk 'BEGIN{for(y=1;y<=9;y++) { for(x=1;x<=y;x++) {printf x"*"y"="x*y"\t"};print} }'

#awk 'BEGIN{for(y=1;y<=9;y++) { for(x=1;x<=y;x++) printf x"*"y"="x*y"\t";print} }'
#awk 'BEGIN{i=1;while(i<=9){for(j=1;j<=i;j++) {printf j"*"i"="j*i"\t"};print;i++ }}'

#awk 'BEGIN{for(i=1;i<=9;i++){j=1;while(j<=i) {printf j"*"i"="i*j"\t";j++};print}}'

循环的控制：
break		条件满足的时候中断循环
continue	条件满足的时候跳过循环
# awk 'BEGIN{for(i=1;i<=5;i++) {if(i==3) break;print i} }'
1
2
# awk 'BEGIN{for(i=1;i<=5;i++){if(i==3) continue;print i}}'
1
2
4
5
```

\##6. awk算数运算

```
+ - * / %(模) ^(幂2^3)
可以在模式中执行计算，awk都将按浮点数方式执行算术运算
# awk 'BEGIN{print 1+1}'
# awk 'BEGIN{print 1**1}'
# awk 'BEGIN{print 2**3}'
# awk 'BEGIN{print 2/3}'
```

# 六、awk统计案例

## 1、统计系统中各种类型的shell

```
# awk -F: '{ shells[$NF]++ };END{for (i in shells) {print i,shells[i]} }' /etc/passwd

books[linux]++
books[linux]=1
shells[/bin/bash]++
shells[/sbin/nologin]++

/bin/bash 5
/sbin/nologin 6

shells[/bin/bash]++			a
shells[/sbin/nologin]++		b
shells[/sbin/shutdown]++	c

books[linux]++
books[php]++
```

## 2、统计网站访问状态

```
# ss -antp|grep 80|awk '{states[$1]++};END{for(i in states){print i,states[i]}}'
TIME_WAIT 578
ESTABLISHED 1
LISTEN 1

# ss -an |grep :80 |awk '{states[$2]++};END{for(i in states){print i,states[i]}}'
LISTEN 1
ESTAB 5
TIME-WAIT 25

# ss -an |grep :80 |awk '{states[$2]++};END{for(i in states){print i,states[i]}}' |sort -k2 -rn
TIME-WAIT 18
ESTAB 8
LISTEN 1
```

## 3、统计访问网站的每个IP的数量

```
# netstat -ant |grep :80 |awk -F: '{ip_count[$8]++};END{for(i in ip_count){print i,ip_count[i]} }' |sort


# ss -an |grep :80 |awk -F":" '!/LISTEN/{ip_count[$(NF-1)]++};END{for(i in ip_count){print i,ip_count[i]}}' |sort -k2 -rn |head
```

## 4、统计网站日志中PV量

```
统计Apache/Nginx日志中某一天的PV量 　<统计日志>
# grep '27/Jul/2017' mysqladmin.cc-access_log |wc -l
14519

统计Apache/Nginx日志中某一天不同IP的访问量　<统计日志>
# grep '27/Jul/2017' mysqladmin.cc-access_log |awk '{ips[$1]++};END{for(i in ips){print i,ips[i]} }' |sort -k2 -rn |head

# grep '07/Aug/2017' access.log |awk '{ips[$1]++};END{for(i in ips){print i,ips[i]} }' |awk '$2>100' |sort -k2 -rn
```

**名词解释：**

网站浏览量（PV） 名词：PV=PageView (网站浏览量) 说明：指页面的浏览次数，用以衡量网站用户访问的网页数量。多次打开同一页面则浏览量累计。用户每打开一个页面便记录1次PV。

名词：VV = Visit View（访问次数） 说明：从访客来到您网站到最终关闭网站的所有页面离开，计为1次访问。若访客连续30分钟没有新开和刷新页面，或者访客关闭了浏览器，则被计算为本次访问结束。

独立访客（UV） 名词：UV= Unique Visitor（独立访客数） 说明：1天内相同的访客多次访问您的网站只计算1个UV。

独立IP（IP） 名词：IP=独立IP数 说明：指1天内使用不同IP地址的用户访问网站的数量。同一IP无论访问了几个页面，独立IP数均为1

\#七、课后作业

**作业1：** 1、写一个自动检测磁盘使用率的脚本，当磁盘使用空间达到90%以上时，需要发送邮件给相关人员 2、写一个脚本监控系统内存和交换分区使用情况

**作业2：** 输入一个IP地址，使用脚本判断其合法性： 必须符合ip地址规范，第1、4位不能以0开头，不能大于255不能小于0

\#八、企业实战案例

#### 1. 任务/背景

web服务器集群中总共有9台机器，上面部署的是Apache服务。由于业务不断增长，每天每台机器上都会产生大量的访问日志，现需要将每台web服务器上的apache访问日志**保留最近3天**的，3天以前的日志**转储**到一台专门的日志服务器上，已做后续分析。如何实现每台服务器上只保留3天以内的日志？

#### 2. 具体要求

1. 每台web服务器的日志对应日志服务器相应的目录里。如：web1——>web1.log（在日志服务器上）
2. 每台web服务器上保留最近3天的访问日志，3天以前的日志每天凌晨5:03分转储到日志服务器
3. 如果脚本转储失败，运维人员需要通过跳板机的菜单选择手动清理日志

#### 3. 涉及知识点

1. shell的基本语法结构
2. 文件同步rsync
3. 文件查找命令find
4. 计划任务crontab
5. apache日志切割
6. 其他