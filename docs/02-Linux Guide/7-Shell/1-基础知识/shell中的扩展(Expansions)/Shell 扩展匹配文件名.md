---
title: 使用命令行扩展
---
https://opengers.github.io/linux/linux-shell-brace-parameter-command-pathname-expansion/


Bash shell 有多种扩展命令行的方式，包括模式匹配、主目录扩展、字符串扩展和变量替换。其中最强大的或许是路径名称匹配功能，在过去被称为通配。BaSh 通配功能通常称为“通配符”，可以使管理大量文件变得更加轻松。使用“扩展”的元字符来匹配要寻找的文件名和路径名，可以一次性针对集中的一组文件执行命令。

## 模式匹配

通配是一种 shll 命令解析操作，它将一个通配符模式扩展到一组匹配的路径名。在执行命令之前，命令行元字符由匹配列表替换。不返回匹配项的模式，将原始模式请求显示为字面上的文本。下列
为常见的元字符和模式类。
**元字符和匹配项表**

| 模式        | 匹配项                                                             |
| ----------- | ------------------------------------------------------------------ |
| \*          | 由零个或更多字符组成的任何字符串。                                 |
| ?           | 任何一个字符。                                                     |
| [abc...]    | 括起的类（位于两个方括号之间）中的任何一个字符。                   |
| [!abc...]   | 不在括起的类中的任何一个字符。                                     |
| [^abc...]   | 不在括起的类中的任何一个字符。                                     |
| [[:alpha:]] | 任何字母字符。                                                     |
| [[:lower:]] | 任何小写字符。                                                     |
| [[:upper:]] | 任何大写字符。                                                     |
| [[:alnum:]] | 任何字母字符或数字。                                               |
| [[:punct:]] | 除空格和字母数字以外的任何可打印字符。                             |
| [[:digit:]] | 从 0 到 9 的任何单个数字。                                         |
| [[:space:]] | 任何一个空白字符。这可能包括制表符、换行符、回车符、换页符或空格。 |

## 波形符扩展

波形符(~)可匹配当前用户的主目录。

:::tip
## linux 中 ~ 和 ${HOME} 有什么区别，为什么脚本常常使用后者
在 Linux 中，~ 和 ${HOME} 都表示当前用户的主目录。
~ 是一个特殊的符号，它会被 shell 扩展为当前用户的主目录。例如，如果当前用户为 user1，则 ~ 将扩展为 /home/user1。
${HOME} 是一个环境变量，它包含当前用户的主目录的路径。您可以在 shell 中使用 echo $HOME 命令查看它的值。

虽然 ~ 和 ${HOME} 实际上是等效的，但脚本通常使用后者，因为它是一个明确的环境变量，可以被其他程序和脚本使用。此外，${HOME} 可以在需要时被设置为其他值，例如在脚本中切换用户时。
:::

## 大括号扩展
大括号扩展用于生成任意字符串。大括号包含字符串的逗号分隔列表或顺序表达式。结果包含大括
号定义之前或之后的文本。大括号扩展可以互相嵌套。此外，双句点语法（)可扩展成一个序列，使
得{m..p}扩展为mnop。
```bash
[user@host glob]$echo [Sunday,Monday,Tuesday,Wednesday}.log
Sunday.log Monday.log Tuesday.log wednesday.log
[user@host glob]$echo file{1..3}.txt
file1.txt file2.txt file3.txt
[user@host glob]$echo filef{a..c}.txt
filea.txt fileb.txt filec.txt
[user@host glob]$echo filef{a,b}{1,2}.txt
filea1.txt filea2.txt fileb1.txt fileb2.txt
[user@host glob]$echo file{a{1,2},b,c}.txt
fileal.txt filea2.txt fileb.txt filec.txt
[user@host glob]$
```
大括号扩展的实际用途是快速创建多个文件或目录。
```bash
[user@host glob]$mkdir ../RHEL[6,7,8}
[user@host glob]$ls ../RHEL*
RHEL6 RHEL7 RHEL8

mkdir -pv /demo/test{1，2，3}
mv demoxx{,.back}
```
## 变量扩展
变量的作用类似于可以在内存中存储值的命名容器。通过变量，可以从命令行或在 shl 脚本内轻松
访问和修改存储的数据。
您可以通过以下语法将数据作为值分配给变量
可以使用变量扩展将变量名称转换为命令行上的值。如果字符串以美元符号(S)开头，那么 sh 就
会尝试将该字符串的其余部分用作变量名称，并将它替换为变量中包含的任何值。
```bash
[user@host -]USERNAME=operator
[user@host -]echo $USERNAME
operator
```

为了避免因其他shll扩展而引起的错误，您可以将变量的名称放在大括号中，如 `${VARIABLENAME}`
```bash
[user@host ~]USERNAME=operator
[user@host ~]echo ${USERNAME}
operator
```

## 命令替换
命令替换允许命令的输出替换命令行上的命令本身。$（命令）形式可以互相嵌套多个命令扩展。
```bash
[user@host glob]$echo Today is $(date +%A).
Today is Wednesday.
[user@host glob]$echo The time is $(date +%M)minutes past $(date +%1%p).
The time is 26 minutes past 11AM.
[user@host glob]$
```
:::tip 
较旧形式的命令替换使用反引号：`命令`。反引号形式的缺点包括：1)反引号在视
觉上很容易与单引号混淆；2)反引号无法嵌套。
:::

## 防止参数被扩展
在 Bash shell 中，许多字符有特殊含义。为了防止 shell 在命令行的某些部分上执行 shell 扩展，您
可以为字符和字符串加引号或执行转义。反斜杠是 Bash shell 中的转义字符。它可以防止紧随其后的字符被扩展。
```bash
[user@host glob]$echo The value of $HOME is your home directory.
The value of /home/user is your home directory.
[user@host glob]$echo The value of \$HOME is your home directory.
The value of $HOME is your home directory.
[user@host glob]$
```

在上面的示例中，保护美元符号免于扩展导致 Bash 将其视为常规字符，因此也就未在$oME上执
行变量扩展。
如果要保护较长的字符串，则使用单引号()或双引号(")来括起字符串。它们的作用略有不同。单
引号将阻止所有shell扩展。双引号则阻止大部分shell扩展。
使用双引号可以阻止通配和shel扩展，但依然允许命令和变量替换。
```bash
[user@host glob]$myhost=$(hostname -s);echo $myhost
host
[user@host glob]$echo "\***\*hostname is ${myhost}\*\*\***" \***\*hostname is host \*\***
[user@host glob]$
```
使用单引号则可以按字面解译所有的文本。
```bash
[user@host glob]$echo "will variable $myhost evaluate to $(hostname -s)?"
will variable myhost evaluate to host?
[user@host glob]$echo 'will variable $myhost evaluate to $(hostname -s)?'
will variable $myhost evaluate to $(hostname -s)?
[user@host glob]$
```

