---
title: Find 进阶用法示例

categories:
  - Linux基础命令
series: 
  - 
lastmod: '2020-03-07'
featuredImage: 
authors: zhuanzai
draft: false
toc: true
---


**原文来自：http://www.codebelief.com/article/2017/02/26-examples-of-find-command-on-linux/**

Linux系统中的 `find` 命令在查找文件时非常有用而且方便。它可以根据不同的条件来查找文件，例如权限、拥有者、修改日期/时间、文件大小等等。在这篇文章中，我们将学习如何使用 `find` 命令以及它所提供的选项来查找文件。

在绝大多数Linux发行版中，你都可以直接使用 `find` 命令而无需进行任何安装操作。如果你想在linux系统的命令行中变得特别高效，那么 `find` 是你必须掌握的命令之一。

`find` 命令的基本语法如下：

```bash
$ find [path] [option] [expression]
```

### 一、基本用法

##### 1. 列出当前目录和子目录下的所有文件

这个命令会列出当前目录以及子目录下的所有文件。

```bash
$ find
.
./abc.txt
./subdir
./subdir/how.php
./cool.php
```

该命令与以下命令效果相同

```bash
$ find .
$ find . -print
```

##### 2. 查找特殊的目录或路径

下面的命令会查找当前目录下 `test` 文件夹中的文件，默认列出所有文件。

```bash
$ find ./test
./test
./test/abc.txt
./test/subdir
./test/subdir/how.php
./test/cool.php
```

下面的命令用于查找指定名称的文件。

```bash
$ find ./test -name "abc.txt"
./test/abc.txt
```

也可以使用通配符

```bash
$ find ./test -name "*.php"
./test/subdir/how.php
./test/cool.php
```

请注意，所有的文件夹都会被递归地查找。所以，这是用于查找指定扩展名文件的一种非常强大的方式。

如果我们尝试搜索 `/` 文件夹，也就是根目录，就会搜索整个文件系统，包括挂载的设备以及网络存储设备。所以请小心使用。当然，你随时可以通过按 `Ctrl + C` 来终止命令。

注意：当指定文件夹的时候（例如示例中的"./test"文件夹），忽略末尾的斜杠是没有问题的。但是，如果文件夹是一个指向其它位置的链接（symlink）时，你必须在末尾写上斜杠才能使find命令正常工作（find ./test/）。

**忽略大小写**

在查找文件名时，忽略大小写往往非常有用。要忽略大小写，只需要使用 `iname` 选项，而不是 `name` 选项。

```bash
$ find ./test -iname "*.Php"
./test/subdir/how.php
./test/cool.php
```

总是用双引号或单引号来包围匹配模式（文件名参数），这非常有用。不这样做的话有时也能正常工作，有时也可能会产生奇怪的结果。

##### 3. 限制目录查找的深度

`find` 命令默认会递归查找整个目录树，而这非常消耗时间和资源。好在目录查找的深度可以手动指定。例如我们只想查找一到两层以内的子目录，可以通过 `maxdepth` 选项来指定。

```bash
$ find ./test -maxdepth 2 -name "*.php"
./test/subdir/how.php
./test/cool.php

$ find ./test -maxdepth 1 -name *.php
./test/cool.php
```

第二个示例中指定了 `maxdepth` 为1，表明最多只查找一层内的子目录，也就是只查找当前文件夹。

当我们只想在当前目录下查找，而不是查找整个目录树的时候，这个选项会特别有用。

与 `maxdepth` 选项相似，还有一个选项叫做 `mindepth` ，正如名字所表示的那样，它会至少到达第 N 层子目录后才开始查找文件。

##### 4. 反向查找

除了查找满足条件的文件之外，我们还可以查找不满足条件的所有文件。当我们知道要在查找中排除哪些文件时，这个选项就能发挥作用了。

```bash
$ find ./test -not -name "*.php"
./test
./test/abc.txt
./test/subdir
```

在上面的示例中我们找到了所有扩展名不是 `php` 的文件和文件夹。我们也可以使用感叹号 `!` 来代替 `-not`。

```bash
find ./test ! -name "*.php"
```

##### 5. 结合多个查找条件

我们可以同时使用多个查找条件来指定文件名并排除某些文件。

```bash
$ find ./test -name 'abc*' ! -name '*.php'
./test/abc.txt
./test/abc
```

上面的命令查找所有以 `abc` 开头并且不含 `.php` 扩展名的文件。这个示例展现了 `find` 命令自带的查找表达式是多么的强大。

**OR 操作符**

当我们使用多个查找条件时， `find` 命令会将它们通过 `AND` 操作符结合起来，也就是说，只有满足所有条件的文件才会被列出。不过，如果我们需要进行基于 `OR` 运算的查找时，可以加上 `-o` 开关。

```bash
$ find -name '*.php' -o -name '*.txt'
./abc.txt
./subdir/how.php
./abc.php
./cool.php
```

上面的命令查找所有以 `.php` 结尾或者以 `.txt` 结尾的文件。

##### 6. 只查找文件或目录

有时我们只想通过某个名字查找对应的文件或对应的目录，我们可以很容易实现这个要求。

```bash
$ find ./test -name abc*
./test/abc.txt
./test/abc

只查找文件

$ find ./test -type f -name "abc*"
./test/abc.txt

只查找目录

$ find ./test -type d -name "abc*"
./test/abc
```

非常有用而且方便！

##### 7. 同时在多个目录下查找

如果你想要在两个不同的目录内进行查找，命令非常简单。

```bash
$ find ./test ./dir2 -type f -name "abc*"
./test/abc.txt
./dir2/abcdefg.txt
```

检查一下，它确实列出了来自给定的两个目录的文件。

##### 8. 查找隐藏文件

在Linux系统中，隐藏文件的名字以英文的句号开头，即 `.` 。所以要列出隐藏文件，只需加上简单的文件名过滤条件就行了。

```bash
$ find ~ -type f -name ".*"
```

### 二、基于文件权限和属性的查找

##### 9. 查找指定权限的文件

通过指定 `perm` 选项，我们可以查找具有特定权限的文件。下面的示例中查找了所有具有 `0664` 权限的文件。

```bash
$ find . -type f -perm 0664
./abc.txt
./subdir/how.php
./abc.php
./cool.php
```

我们可以用这个命令来查找带有错误权限的文件，这些文件可能会产生安全问题。

可以结合 `反向查找` 来进行权限检查。

```bash
$ find . -type f ! -perm 0777
./abc.txt
./subdir/how.php
./abc.php
./cool.php
```

##### 10. 查找具有 SGID/SUID 属性的文件

下面的命令查找所有具有 `644` 权限和 `SGID` 属性的文件。

```null
# find / -perm 2644

```

我们同样可以使用 `1664` 来查找设置了 `粘滞位` （sticky bit）的文件。

```null
# find / -perm 1644

```

`perm` 选项除了接受数值型参数外，同样接受 `chmod` 命令中的模式串。在下面的查找中，我们用另一种语法来代替数字。

```bash
$ find / -maxdepth 2 -perm /u=s 2>/dev/null
/bin/mount
/bin/su
/bin/ping6
/bin/fusermount
/bin/ping
/bin/umount
/sbin/mount.ecryptfs_private
```

注意：由于权限不足，某些目录会拒接访问。命令中的 `2>/dev/null` 正是用于清除输出中的错误访问结果。

##### 11. 查找只读文件

```bash
$ find /etc -maxdepth 1 -perm /u=r
/etc
/etc/thunderbird
/etc/brltty
/etc/dkms
/etc/phpmyadmin
... output truncated ...
```

##### 12. 查找可执行文件

```bash
$ find /bin -maxdepth 2 -perm /a=x
/bin
/bin/preseed_command
/bin/mount
/bin/zfgrep
/bin/tempfile
... output truncated ...
```

### 三、基于文件拥有者和用户组的查找

##### 13. 查找属于特定用户的文件

查找当前目录下，属于 `bob` 的文件。

```bash
$ find . -user bob
.
./abc.txt
./abc
./subdir
./subdir/how.php
./abc.php
```

在指定所属用户的同时，我们同样可以指定文件名。

```bash
$ find . -user bob -name '*.php'
```

很容易看出，我们可以通过增加过滤条件来缩小查找文件的范围。

##### 14. 查找属于特定用户组的文件

```null
# find /var/www -group developer

```

### 四、基于日期和时间的查找

除了上面介绍的查找条件外，另外一个非常棒的查找条件就是文件的修改和访问时间（日期）。当我们想要找出哪些文件在某段时间内被修改的时候，这个查找条件将会非常方便。我们来看几个例子。

##### 15. 查找过去的第 N 天被修改过的文件

```null
# find / -mtime 50

```

##### 16. 查找过去的 N 天内被访问过的文件

```null
# find / -atime -50

```

##### 17. 查找某段时间范围内被修改过内容的文件

```null
# find / -mtime +50 -mtime -100

```

##### 18. 查找过去的 N 分钟内状态发生改变的文件

```bash
$ find /home/bob -cmin -60
```

##### 19. 查找过去的 1 小时内被修改过内容的文件

```null
# find / -mmin -60

```

##### 20. 查找过去的 1 小时内被访问过的文件

```null
# find / -amin -60

```

### 五、基于文件大小的查找

##### 21. 查找指定大小的文件

```bash
$ find / -size 50M
```

##### 22. 查找大小在一定范围内的文件

```bash
$ find / -size +50M -size -100M
```

##### 23. 查找最大和最小的文件

我们可以将 `find` 命令与 `ls` 和 `sort`命令结合，从而找出最大或最小的文件。

下面的命令使用了 `sort` 命令的 `-r` 选项，也就是从大到小降序排列。经过 `head` 命令的过滤之后，会显示当前目录和子目录下最大的5个文件。命令的执行过程需要一段时间，查找的速度取决于文件的总数。

```bash
$ find . -type f -exec ls -s {} \; | sort -n -r | head 5
```

同样，我们可以去掉 `sort` 命令的 `-r` 选项来进行升序排列，从而显示出最小的5个文件。

```bash
$ find . -type f -exec ls -s {} \; | sort -n | head 5
```

##### 24. 查找空文件和空目录

查找空文件：

```null
# find /tmp -type f -empty

```

查找空目录：

```bash
$ find ~/ -type d -empty
```

非常简单！

### 六、高级操作

`find` 命令不仅可以通过特定条件来查找文件，还可以对查找到的文件使用任意linux命令进行操作。下面给出两个例子。

##### 25. 使用 ls 命令列出文件信息

我们使用 `find` 命令找到文件后，只能看到文件路径。如果想进一步查看文件信息，可以结合 `ls` 命令来实现。

```bash
$ find . -exec ls -ld {} \;
drwxrwxr-x 4 enlightened enlightened 4096 Aug 11 19:01 .
-rw-rw-r-- 1 enlightened enlightened 0 Aug 11 16:25 ./abc.txt
drwxrwxr-x 2 enlightened enlightened 4096 Aug 11 16:48 ./abc
drwxrwxr-x 2 enlightened enlightened 4096 Aug 11 16:26 ./subdir
-rw-rw-r-- 1 enlightened enlightened 0 Aug 11 16:26 ./subdir/how.php
-rw-rw-r-- 1 enlightened enlightened 29 Aug 11 19:13 ./abc.php
-rw-rw-r-- 1 enlightened enlightened 0 Aug 11 16:25 ./cool.php
```

##### 26. 删除找到的文件

下面的命令会删除 `tmp` 目录下扩展名为 `.txt` 的文件。

```bash
$ find /tmp -type f -name "*.txt" -exec rm -f {} \;
```

我们同样可以删除目录，只要把 `-type` 后面的 `f` 改为 `d` ，并且在 `rm` 命令后面加上 `-r` 即可。

```bash
$ find /tmp -type d -name "dirToRemove" -exec rm -r -f {} \;
```

英文原文：[25+ simple example of Linux find command](http://www.binarytides.com/linux-find-command-examples/)

