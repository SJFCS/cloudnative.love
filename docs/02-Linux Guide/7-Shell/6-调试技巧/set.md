https://www.ruanyifeng.com/blog/2017/11/bash-set.html


https://jiangliheng.github.io/2020/03/21/shell-debug/

=======
```bash
使用shell的执行选项，下面将介绍一些常用选项的用法：

-n 只读取shell脚本，但不实际执行
-x 进入跟踪方式，显示所执行的每一条命令
-c “string” 从strings中读取命令

“-n”可用于测试shell脚本是否存在语法错误，但不会实际执行命令。在shell脚本编写完成之后，实际执行之前，首先使用”-n”选项来测试脚本是否存在语法错误是一个很好的习惯。因为某些shell脚本在执行时会对系统环境产生影响，比如生成或移动文件等，如果在实际执行才发现语法错误，您不得不手工做一些系统环境的恢复工作才能继续测试这个脚本。

“-c”选项使shell解释器从一个字符串中而不是从一个文件中读取并执行shell命令。当需要临时测试一小段脚本的执行结果时，可以使用这个选项，如下所示：
sh -c ‘a=1;b=2;let c=$a+$b;echo “c=$c”‘

“-x”选项可用来跟踪脚本的执行，是调试shell脚本的强有力工具。”-x”选项使shell在执行脚本的过程中把它实际执行的每一个命令行显示出来，并且在行首显示一个”+”号。 “+”号后面显示的是经过了变量替换之后的命令行的内容，有助于分析实际执行的是什么命令。 “-x”选项使用起来简单方便，可以轻松对付大多数的shell调试任务,应把其当作首选的调试手段。

如果把本文前面所述的trap ‘command’ DEBUG机制与“-x”选项结合起来，我们就可以既输出实际执行的每一条命令，又逐行跟踪相关变量的值，对调试相当有帮助。

我们以debug.sh脚本为例：

root@localhost:~# cat -n debug.sh
1 #!/bin/sh
2 trap ‘echo “before execute line:$LINENO,a=$a,b=$b,c=$c”‘ DEBUG
3 a=1
4 if [ “$a” -eq 1 ]
5 then
6 b=2
7 else
8 b=1
9 fi
10 c=3
11 echo end
现在对该脚本加上“-x”选项来执行它：

root@localhost:~# sh -x debug.sh
+ trap echo “before execute line:$LINENO,a=$a,b=$b,c=$c” DEBUG
trap: DEBUG: bad trap
+ a=1
+ [ 1 -eq 1 ]
+ b=2
+ c=3
+ echo end
end
在上面的结果中，前面有“+”号的行是shell脚本实际执行的命令，前面有“++”号的行是执行trap机制中指定的命令，其它的行则是输出信息。

shell的执行选项除了可以在启动shell时指定外，亦可在脚本中用set命令来指定。 “set – 参数”表示启用某选项，”set +参数”表示关闭某选项。有时候我们并不需要在启动时用”-x”选项来跟踪所有的命令行，这时我们可以在脚本中使用set命令，如以下脚本片段所示：

set -x#启动”-x”选项
要跟踪的程序段
set +x#关闭”-x”选项

set命令同样可以使用前面介绍的调试钩子—DEBUG函数来调用，下面是DEBUG函数代码:
root@localhost:~# cat debugOth.sh
#!/bin/sh
DEBUG()
{
if [ “DEBUG”=”true” ];then
$@
fi
}
a=1
DEBUG echo “a=$a”
if [ “$a” -eq 1 ]
then
b=2
else
b=1
fi
DEBUG echo “b=$b”
c=3
DEBUG echo “c=$c”

$@ 与$*相同，但是使用时加引号，并在引号中返回每个参数。
如”$@”用「”」括起来的情况、以”$1″ “$2” … “$n” 的形式输出所有参数。
这样可以避免脚本交付使用时删除这些调试语句的麻烦，如以下脚本片段所示：
DEBUG set -x#启动”-x”选项
要跟踪的程序段

DEBUG set +x#关闭”-x”选项
root@localhost:~# sh debugOth.sh
a=1
b=2
c=3
root@localhost:~# sh -x debugOth.sh
+ a=1
+ DEBUG echo a=1
+ [ DEBUG=true ]
+ echo a=1
a=1
+ [ 1 -eq 1 ]
+ b=2
+ DEBUG echo b=2
+ [ DEBUG=true ]
+ echo b=2
b=2
+ c=3
+ DEBUG echo c=3
+ [ DEBUG=true ]
+ echo c=3
c=3

四. 对”-x”选项的增强

“-x”执行选项是目前最常用的跟踪和调试shell脚本的手段，但其输出的调试信息仅限于进行变量替换之后的每一条实际执行的命令以及行首的一个”+” 号提示符，居然连行号这样的重要信息都没有，对于复杂的shell脚本的调试来说，还是非常的不方便。幸运的是，我们可以巧妙地利用shell内置的一些环境变量来增强”-x”选项的输出信息，下面先介绍几个shell内置的环境变量：

$LINENO
代表shell脚本的当前行号，类似于C语言中的内置宏__LINE__

$FUNCNAME
函数的名字，类似于C语言中的内置宏__func__,但宏__func__只能代表当前所在的函数名，而$ FUNCNAME的功能更强大，它是一个数组变量，其中包含了整个调用链上所有的函数的名字，故变量${FUNCNAME[0]}代表shell脚本当前正在执行的函数的名字，而变量${FUNCNAME[1]}则代表调用函数${FUNCNAME[0]}的函数的名字，余者可以依此类推。

$PS4
主提示符变量$PS1和第二级提示符变量$PS2比较常见，但很少有人注意到第四级提示符变量$PS4的作用。我们知道使用“- x”执行选项将会显示shell脚本中每一条实际执行过的命令，而$PS4的值将被显示在“-x”选项输出的每一条命令的前面。在Bash Shell中，缺省的$PS4的值是”+”号。(现在知道为什么使用”-x”选项时，输出的命令前面有一个”+”号了吧？)。

利用$PS4这一特性，通过使用一些内置变量来重定义$PS4的值，我们就可以增强”-x”选项的输出信息。例如先执行export PS4=’+{$LINENO:${FUNCNAME[0]}} ‘, 然后再使用“-x”选项来执行脚本，就能在每一条实际执行的命令前面显示其行号以及所属的函数名。

以下是一个存在bug的shell脚本的示例，本文将用此脚本来示范如何用“-n”以及增强的“-x”执行选项来调试shell脚本。这个脚本中定义了一个函数isRoot(),用于判断当前用户是不是root用户，如果不是，则中止脚本的执行。

root@localhost:~# cat debugOthO.sh
#!/bin/sh
isRoot()
{
if [ `echo $UID |awk ‘{print int($0)}’` -ne 0 ]
return 1
else
return 0
fi
}
isRoot
if [$? -ne 0 ];then
echo “Must be root to run this script”
exit 1
else
echo “welcome root user”
#do something
fi
首先执行# sh -n debugOthO.sh来进行语法检查，输出如下：
root@localhost:~# sh -n debugOthO.sh
debugOthO.sh: 6: debugOthO.sh: Syntax error: “else” unexpected (expecting “then”)

发现了一个语法错误，通过仔细检查第6行前后的命令，我们发现是第4行的if语句缺少then关键字引起的(写惯了C程序的人很容易犯这个错误)。我们可以把第4行修改为if [ “$UID” -ne 0 ]; then来修正这个错误。再次运行# sh -n debugOthO.sh来进行语法检查，没有再报告错误。接下来就可以实际执行这个脚本了，执行结果如下：

root@localhost:~# sh debugOthO.sh
debugOthO.sh: 11: debugOthO.sh: [0: not found
welcome root user

尽管脚本没有语法错误了，在执行时却又报告了错误。错误信息还非常奇怪“[0: not found”。现在我们可以试试定制$PS4的值，并使用“-x”选项来跟踪：

root@localhost:~# export PS4=’+{$LINENO:${FUNCNAME[0]}} ‘
root@localhost:~# bash -x debugOthO.sh
+ isRoot
++ echo 0
++ awk ‘{print int($0)}’
+ ‘[‘ 0 -ne 0 ‘]’
+ return 0
+ ‘[0’ -ne 0 ‘]’
debugOthO.sh: line 11: [0: command not found
+ echo ‘welcome root user’
welcome root user

从输出结果中，我们可以看到脚本实际被执行的语句，该语句的行号以及所属的函数名也被打印出来，从中可以清楚的分析出脚本的执行轨迹以及所调用的函数的内部执行情况。由于执行时是第11行报错，这是一个if语句,到这里我们就知道由于第11行的[号后面缺少了一个空格，导致[号与紧挨它的变量$?的值1被shell解释器看作了一个整体，并试着把这个整体视为一个命令来执行，故有“ [0: command not found”这样的错误提示。只需在[号后面插入一个空格就一切正常了。

shell中还有其它一些对调试有帮助的内置变量，比如在Bash Shell中还有BASH_SOURCE, BASH_SUBSHELL等一批对调试有帮助的内置变量，您可以通过man sh或man bash来查看，然后根据您的调试目的,使用这些内置变量来定制$PS4，从而达到增强“-x”选项的输出信息的目的。

五. 总结

现在让我们来总结一下调试shell脚本的过程：
首先使用“-n”选项检查语法错误，然后使用“-x”选项跟踪脚本的执行，使用“-x”选项之前，别忘了先定制PS4变量的值来增强“-x”选项的输出信息，至少应该令其输出行号信息(先执行export PS4=’+[$LINENO]’，更一劳永逸的办法是将这条语句加到您用户主目录的.bash_profile文件中去)，这将使你的调试之旅更轻松。也可以利用trap,调试钩子等手段输出关键调试信息，快速缩小排查错误的范围，并在脚本中使用“set -x”及“set +x”对某些代码块进行重点跟踪。这样多种手段齐下，相信您已经可以比较轻松地抓出您的shell脚本中的臭虫了。
如果您的脚本足够复杂，还需要更强的调试能力，可以使用shell调试器bashdb，这是一个类似于GDB的调试工具，可以完成对shell脚本的断点设置，单步执行，变量观察等许多功能，使用bashdb对阅读和理解复杂的shell脚本也会大有裨益。关于bashdb的安装和使用，不属于本文范围，您可参阅http://bashdb.sourceforge.net/上的文档并下载试用
```