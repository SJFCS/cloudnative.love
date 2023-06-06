shell 变量基础 以及用变量的值作为新的变量名

https://blog.csdn.net/mydriverc2/article/details/78930881

1.eval 可以用来回显简单的变量：

```bash
#!/bin/sh
val=100
echo $val
eval echo $val
```

2.eval 也能用来执行含有字符串的命令：

```bash
#!/bin/sh
echo "hello bit" > myfile
myfile="cat myfile"
eval $myfile
```

3.eval 命令还可以显示我们传递给脚本的最后一个参数：

```bash
#!/bin/sh
eval echo \$$#
```

```bash
/test.sh 1 2 3 4
4
```

4.eval 命令也可以创建指向变量的指针：

```bash
val=100
ptr=val

echo $val
eval echo \$$ptr
```

拼接

```bash
#!/bin/sh
i=1
a1=1234
eval echo \$a$i
```

```bash
#!/bin/bash
a='my'
b='site'
my_site='my site www.361way.com'
echo a_b is "$a"_"$b"
# echo $("$a"_"$b") 会报错
eval echo '$'"$a"_"$b"
eval echo '$'{"$a"_"$b"}
```

再来个示例，该例中文件有两列，第一列为变量名，第二列为变量值，读取该文件后将第二列的值赋值给第一列，通过`echo ${第一列列名}` 就可以获取后面的 value 值。如下：

变量名与变量值映射表：

```bash
# more name_value.txt
site www.361way.com
mail itybku@139.com
user admin
```

脚本内容：

```bash
#!/bin/bash
while read NAME VALUE
do
eval "${NAME}=${VALUE}"
done < name_value.txt
echo "$site $mail $user"
```

执行该脚本，结果如下：

```bash
www.361way.com itybku@139.com admin
```

众所周知， shell 中只支持一维数组。你可以轻易的写下如下脚本：

```bash
#!/bin/sh
#first way
arr=(0 1 2 3)
#second way
for i in `seq 0 3`
do
    arr[$i]=$i
done

#get one element
echo "first element: ${arr[0]}"
#get all element
echo "all element: ${arr[*]}"
#get arr len
echo "arr len: ${#arr[*]}"
```

输出结果：

```bash
first element: 0
all element: 0 1 2 3
arr len: 4
```

但有的时候， 二维数组对我们非常有用。 比如你可以实现一个 3\*3 的乘法表格， 你可能会这么去做：

```bash
#!/bin/sh

arr0=(1,2,3)
arr1=(2,4,6)
arr2=(3,6,9)

i=1
j=2
#you want arr[i][j]
echo ${arr$i[$j]}
```

输出结果：

```bash
./one.sh: line 10: ${arr$i[$j]}: bad substitution
```

原因是 shell 知会进行一次扫描和变量替换，所以不能引用变量作为变量名的一部分。 这个时候你会想到“eval”，它的作用是先扫描改行并完成所有的变量替换， 然后执行替换后的命令。 例如：

```bash
#!/bin/sh

i=1
a1=1234
eval echo \$a$i
```

输出结果
1234

注意：第一个$前要用\, 向eval表明这是一个普通的$字符， 不需要理解为变量。 否则会 eval 会吧$a 当成一个变量。

了解了 eval 的功力后， 我们就可以写出一个边长的二维数组了：

```bash
#!/bin/sh

row_nun=5
column_num=8

for i in `seq 0 $row_num`
do
    for j in `seq 0 $column_num`
    do
        let value=$i*$j
        eval arr$i[$j]=$value
    done
    eval echo \${arr$i[*]}
done
```

将会输出

```bash
0 0 0 0 0 0 0 0 0
0 1 2 3 4 5 6 7 8
0 2 4 6 8 10 12 14 16
0 3 6 9 12 15 18 21 24
0 4 8 12 16 20 24 28 32
0 5 10 15 20 25 30 35 40
```

eval 的作用是再次执行命令行处理，也就是说，对一个命令行，执行两次命令行处理。这个命令要用好，就要费一定的功夫。我举两个例子，抛砖引玉。

1、例子 1：用 eval 技巧实现 shell 的控制结构 for

用 eval 技巧实现 shell 的控制结构 for。

```bash
#!/bin/sh
evalit(){
    if [ $cnt = 1 ];then
            eval $@
            return
    else
            let cnt="cnt-1"
            evalit $@
    fi
    eval $@
}
cnt=$1
echo $cnt | egrep "^[1-9][0-9]*$" >/dev/null
if [ $? -eq 0 ]; then
    shift
    evalit $@
else
    echo 'ERROR!!! Check your input!'
fi
[root@home root]# ./myscript1 3 hostname
home
home
home
[root@home root]# ./myscript1 5 id |cut -f1 -d' '
uid=0(root)
uid=0(root)
uid=0(root)
uid=0(root)
uid=0(root)
```

注意：bash 里有两个很特殊的变量，它们保存了参数列表。
```
$*，保存了以$IFS 指定的分割符所分割的字符串组。
$@，原样保存了参数列表，也就是"$1""$2"...
```

这里我使用了函数递归以及 eval 实现了 for 结构。
当执行 eval $@时，它经历了步骤如下：
第1步，分割成eval $@
第6步，扩展$@为 hostname
第 11 步，找到内置命令 eval
重复一次命令行处理，第 11 步，找到 hostname 命令，执行。

注意：也许有人想当然地认为，何必用 eval 呢？直接$@来执行命令就可以了嘛。

例子 2：一个典型错误的例子

错误！这里给个典型的例子大家看看。

```bash
[root@home root]# a="id | cut -f1 -d' '"
[root@home root]# $a
id：无效选项 # f
请尝试执行‘id # help’来获取更多信息。
[root@home root]# eval $a
uid=0(root)
```

如果命令行复杂的话(包括管道或者其他字符)，直接执行$a字符串的内容就会出错。分析如下。
`$a` 的处理位于第 6 步 ── 参数扩展，也就是说，跳过了管道分析，于是"|", "cut", "-f1", "-d"都变成了 id 命令的参数，当然就出错啦。
但使用了 eval，它把第一遍命令行处理所得的"id", "|", "cut", "-f1", "-d"这些字符串再次进行命令行处理，这次就能正确分析其中的管道了。

总而言之：要保证你的命令或脚本设计能正确通过命令行处理，跳过任意一步，都可能造成意料外的错误！

例子 3：设置系统的 ls 色彩显示
```bash
eval $(dircolors -b /etc/dircolors)
```
eval 语句通知 shell 接受 eval 参数，并再次通过命令行处理的所有步骤运行它们。
它使你可以编写脚本随意创建命令字符串，然后把它们传递给 shell 执行;
`$()`是命令替换，返回命令的输出字符串。
其中 dircolors 命令根据/etc/dircolors 配置文件生成设置环境变量 LS_COLORS 的 bash 代码，内容如下
```bash
[root@localhost root]# dircolors -b > tmp
[root@localhost root]# cat tmp
LS_COLORS='no=00:fi=00:di=01;34:ln=01; ......
export LS_COLORS #这里我没有指定配置文件，所以 dircolors 按预置数据库生成代码。
其输出被 eval 命令传递给 shell 执行。
```
eval 是对 Bash Shell 命令行处理规则的灵活应用，进而构造"智能"命令实现复杂的功能。
上面提及的命令是 eval 其中一个很普通的应用，它重复了 1 次命令行参数传递过程，纯粹地执行命令的命令。
其实它是 bash 的难点，是高级 bash 程序员的必修之技。
