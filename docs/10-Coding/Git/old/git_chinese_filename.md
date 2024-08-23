# Git status时中文文件名乱码

在创建中文文件名的文件时，使用`git status`查看状态时，可以看到文件名乱码，不知道对应的文件到底是哪一个，如下所示：

```sh
[mzh@MacBookPro test (master)]$ ll
total 8
drwxr-xr-x   4 mzh   wheel   128B  3 20 11:29 .
drwxrwxrwt   7 root  wheel   224B  3 20 10:30 ..
drwxr-xr-x  14 mzh   wheel   448B  3 20 11:29 .git
-rw-r--r--   1 mzh   wheel    53B  3 19 00:17 data.txt
[mzh@MacBookPro test (master)]$ ls -l
total 8
-rw-r--r--  1 mzh  wheel  53  3 19 00:17 data.txt
[mzh@MacBookPro test (master)]$ echo '测试钩子' > 钩子.txt
[mzh@MacBookPro test (master ✗)]$ ls -l
total 16
-rw-r--r--  1 mzh  wheel  53  3 19 00:17 data.txt
-rw-r--r--  1 mzh  wheel  13  3 20 11:29 钩子.txt
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	"\351\222\251\345\255\220.txt"

nothing added to commit but untracked files present (use "git add" to track)
[mzh@MacBookPro test (master ✗)]$
```

可以看到，当我们创建“钩子.txt”文件时，查看状态时，文件被显示为“\351\222\251\345\255\220.txt”， 这是什么，看不懂。

git 默认中文文件名是 \xxx\xxx 等八进制形式，是因为对0x80以上的字符进行quote转义。

只需要设置`core.quotepath`设为`false`，中文文件名则会显示正常。

```sh
# 查看当前配置
[mzh@MacBookPro test (master ✗)]$ git config --global core.quotepath

# 设置为新值
[mzh@MacBookPro test (master ✗)]$ git config --global core.quotepath false

# 再次查看core.quotepath的值
[mzh@MacBookPro test (master ✗)]$ git config --global core.quotepath
false

# 查看状态，可以看到文件名已经正常显示中文了
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	钩子.txt

nothing added to commit but untracked files present (use "git add" to track)
[mzh@MacBookPro test (master ✗)]$
```

禁止转义后，可以正常查看中文文件名了。

