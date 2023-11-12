
```bash
ls -1ldhXtr




# ls只显示文件名
ls -1 ./ | tr '\n' '\0' | xargs -0 -n 1 basename | less
```


-1：将每个项目输出到一行中（每个项目独占一行）。
-l：使用长格式输出，在每个文件的详细信息下面显示更多属性信息。
-d：如果文件是目录，只列出目录文件本身，而不列出目录中的其他文件。
-h：使用易于人类阅读的格式显示文件大小（比如 GB，MB 等）。
-a：显示所有文件和目录，包括以“.”开头的隐藏文件。
-i：显示每个文件的 inode 号。


-X：按照文件扩展名进行排序。
-t：按照修改时间进行排序，最近修改的文件排在最前面。
-r：将文件列表按照相反的顺序输出。
-S：按文件大小排序，较大的文件排在前面。
-u：按照访问时间进行排序，最后访问的文件排在最前面。

-C：以多列格式输出，按字母顺序在多行中输出文件和目录。
-m：以逗号分隔的列表格式显示文件。
-R：递归地显示指定目录下的所有目录和文件。
-U：以未排序的方式列出项目（与排序无关）。


```
用法：ls [选项]... [文件]...
列出 <文件>（默认为当前目录）的信息。
如果既没有指定 -cftuvSUX 中任何一个，也没有指定 --sort，则按字母排序项目。

长选项的必选参数对于短选项也是必选的。
  -a, --all                  不要隐藏以 . 开头的项目
  -A, --almost-all           列出除 . 及 .. 以外的所有项目
      --author               与 -l 同时使用时，列出每个文件的作者
  -b, --escape               以 C 风格的转义序列表示不可打印的字符
      --block-size=大小      与 -l 同时使用时，打印大小前将其除以 <大小>；
                             例如："--block-size=M"；参见下方的 <大小> 格式

  -B, --ignore-backups       不要列出以 ~ 结尾的项目
  -c                         与 -lt 一起使用时：按照 ctime 排序，并显示
                             ctime（文件状态信息最后修改的时间）；
                             与 -l 一起使用时：显示 ctime 并按照名称排序；
                             其它情况：按照 ctime 排序，最新的最前

  -C                         逐列列出项目
      --color[=何时]         指定 <何时> 使用彩色输出；更多信息请见下文
  -d, --directory            列出目录本身，而不是目录的内容
  -D, --dired                产生适合 Emacs 的 dired 模式使用的输出
  -f                         按照目录顺序列出各项目
  -F, --classify[=何时]      指定 <何时> 在项目后追加指示符号（*/=@| 中的一个）
      --file-type            类似，但不追加 "*" 字符
      --format=关键字        across 同 -x、commas 同 -m、horizontal 同 -x、
                               long 同 -l、single-column 同 -1、verbose 同 -l、
                               vertical 同 -C

      --full-time            等于 -l --time-style=full-iso
  -g                         类似 -l，但不列出所有者
      --group-directories-first
                             将目录排在文件前面；
                             此选项可与 --sort 一起使用，但是一旦使用
                             --sort=none (-U) 则禁用此选项

  -G, --no-group             使用长列表格式时，不输出组名
  -h, --human-readable       同时使用 -l 或 -s 时，将大小表示为 1K 234M 2G 等
      --si                   类似，但是使用 1000 的幂，而不是 1024
  -H, --dereference-command-line
                             跟随命令行中列出的符号链接
      --dereference-command-line-symlink-to-dir
                             跟随命令行中列出的、指向目录的符号链接

      --hide=模式            隐藏符合 shell <模式> 的项目
                             （-a 或 -A 使此选项失效）

      --hyperlink[=何时]     指定 <何时> 使用超链接显示文件名
      --indicator-style=关键字  指定在项目名称后追加的指示符号的风格：
                                none（默认）、slash（同 -p）、
                                file-type（同 --file-type）、classify（同 -F）

  -i, --inode                显示每个文件的索引编号（inode 号）
  -I, --ignore=模式          隐藏符合 shell <模式> 的项目
  -k, --kibibytes            显示文件系统使用量时，默认使用 1024 字节的块大小；
                             只用于 -s 和每个目录的总计

  -l                         使用长列表格式
  -L, --dereference          当显示符号链接的文件信息时，显示符号链接指向
                             的文件的信息，而非符号链接本身的信息

  -m                         所有项目以逗号分隔，并填满整行行宽
  -n, --numeric-uid-gid      类似 -l，但列出用户和组的 ID 号
  -N, --literal              输出不加引号的项目名称
  -o                         类似 -l，但不列出有关组的信息
  -p, --indicator-style=slash
                             对目录追加 "/" 作为指示符号
  -q, --hide-control-chars   以 "?" 字符代替不可打印的字符
      --show-control-chars   原样显示无法打印的字符（这是默认行为，除非被调用
                             时的程序名是 "ls" 且在终端中进行输出）

  -Q, --quote-name           在项目名称两侧加上双引号
      --quoting-style=关键字  使用指定的加引号方式显示项目名称：
                              literal、locale、shell、shell-always、
                              shell-escape、shell-escape-always、c、escape
                              （该选项优先于 QUOTING_STYLE 环境变量）

  -r, --reverse              排序时逆序排列
  -R, --recursive            递归地列出子目录
  -s, --size                 显示给每个文件分配的大小，单位为块
  -S                         根据文件大小排序，最大的最前
      --sort=关键字          按照 <关键字> 而非名称进行排序：none（同 -U）、
                               size（同 -S）、time（同 -t）、version（同 -v）、
                               extension（同 -X）、width

      --time=关键字          选择用于显示或排序的时间戳；
                               访问时间（同 -u）：atime、access、use；
                               元数据变更时间（同 -c）：ctime、status；
                               修改时间（默认）：mtime、modification；
                               创建时间：birth、creation；
                             和 -l 同时使用时，<关键字> 指定要显示的时间类型；
                             和 --sort=time 同时使用时，按照 <关键字> 进行排序
                               （最新的最前）

      --time-style=时间风格
                             使用 -l 时显示的时间/日期格式；参见下面
                             <时间风格> 的相关内容
  -t                         按时间排序，最新的最前；参见 --time
  -T, --tabsize=列数         指定制表符宽度为 <列数>，而非默认的 8
  -u                         与 -lt 同时使用时：显示访问时间且按访问时间排序；
                             与 -l 同时使用时：显示访问时间但按名称排序；
                             其他情况：按访问时间排序，最新的最前


  -U                         不进行排序；按照目录顺序列出项目
  -v                         对文本中的数字（或版本号）进行自然排序
  -w, --width=列数           设置输出宽度为 <列数>。0 表示无限制
  -x                         逐行列出项目而不是逐列列出
  -X                         按照扩展名的字母顺序排序
  -Z, --context              输出每个文件的所有安全上下文信息
      --zero                 以 NUL 字符而非换行结束每个输出行
  -1                         每行只列出一个文件
      --help        显示此帮助信息并退出
      --version     显示版本信息并退出

<大小> 参数是一个整数，后面可以跟一个单位（例如：10K 指 10*1024）。
可用的单位有 K、M、G、T、P、E、Z、Y、R、Q（1024 的幂），
以及 KB、MB、...（1000 的幂）。
也可以使用二进制前缀：KiB=K、MiB=M，以此类推。

<时间风格> 参数可以是 full-iso、long-iso、iso、locale，或者 +格式。
<格式> 的解析方式同 date(1)。如果 <格式> 是 格式1<换行符>格式2 的话，
则 <格式1> 将应用于时间较久远的文件，<格式2> 将应用于时间较近的文件。
<时间风格> 如果带有 "posix-" 前缀，则它只会在区域设置非 POSIX 时生效。
另外，可以使用 TIME_STYLE 环境变量设置默认使用的风格。

<何时> 参数的默认值是 "always"，也可以设为 "auto" 或 "never"。

使用颜色来区分文件类型的功能默认禁用，也可以使用 --color=never 禁用。
若使用 --color=auto 选项，ls 只在标准输出连接至终端时才生成颜色代码。
LS_COLORS 环境变量可以改变颜色设置。可以使用 dircolors(1) 命令来设置它。

退出状态：
 0  表示正常，
 1  表示小问题（例如：无法访问子目录），
 2  表示严重问题（例如：无法使用命令行参数）。

GNU coreutils 在线帮助：https://www.gnu.org/software/coreutils/
请向 http://translationproject.org/team/zh_CN.html 报告任何翻译错误
完整文档 https://www.gnu.org/software/coreutils/ls
或者在本地使用：info '(coreutils) ls invocation'
```










使用 ls -ld 命令查看软链接时，不会显示软链接指向的原始文件名，只会显示软链接本身的信息和权限。这是因为 -d 选项会将软链接本身看作一个目标而非递归查看目标内容。

如果要查看软链接指向的原始文件名，可以使用 -l 选项代替 -d，即使用 ls -l 软链接名称 命令。这样就可以看到软链接指向的原始文件名，如下所示：
```bash
$ ls -l link
lrwxrwxrwx 1 user user 13 Oct 12 22:33 link -> /home/user/fil
```









## 列出当前目录文件名

```
ls   #列出当前目录文件名，不包括隐藏文件，且无法看到符号链接链向的文件# -a   ALLls -a #列出当前目录下所有文件，包括隐藏文件，当前目录.以及上一级目录..ls -A #列出当前目录下所有文件，包括隐藏文件，不包括前目录.以及上一级目录..ls -al  # 列出当前目录所有文件，并且使用长格式显示所有信息，包括权限，大小，用户，时间等，与ll作用相同
```

## 以易读方式列出当前目录文件大小

相关参数-h（human-readable）,如下所示，文件大小不以初始字节显示，而是以k或者M为单位显示。

```
ls -lh   总用量 1.4Mdrwxrwxr-x 3 hyb  hyb  4.0K 10月 19  2017 Area3drwxrwxr-x 3 hyb  hyb  4.0K 10月 19  2017 home-rw-r--r-- 1 root root 1.3K 10月 19  2017 home.ziplrwxrwxrwx 1 hyb  hyb     8 9月  13 21:19 test -> home.zip-rw-rw-r-- 1 hyb  hyb  1.3M 9月  16 15:30 test.zipdrwxrwxr-x 2 hyb  hyb  4.0K 10月 19  2017 user
```

## 递归列出当前目录以及子目录的文件

相关参数-R（recursive）。

```
ls -lR
```

但是这样列出来的内容可读性较差，可参考后面的使用。

## 列出特定目录下的文件

参数与前面类似，最后再跟上目录名，例如：

```
ls -a testlrwxrwxrwx 1 hyb hyb 8 9月  13 21:19 test -> home.zip
```

## 列出符合条件的文件

参数与前面类似，最后跟上条件，例如列出所有以te开头的文件:

```
ls -al te*lrwxrwxrwx 1 hyb hyb       8 9月  13 21:19 test -> home.zip-rw-rw-r-- 1 hyb hyb 1345047 9月  16 15:30 test.zip
```

## 按指定顺序列出文件

列出时，也可以按照指定字段排序列出，同样还可以配合前面的参数一起使用，例如:

```
ls -lt  #按文件修改时间排序ls -alS  #按文件大小排序ls  -X   #按扩展名排序
```

## 计算目录下的文件或目录数量

先介绍以下文件权限列，文件权限列的开头代表了文件类型：

-   l 链接文件
    
-   d 目录
    
-   \- 普通文件  
    下面命令中^-的含义为，以-开头的字符，有兴趣的可以学习更多正则表达式的使用，这里不再赘述。
    

```
ls -l | grep "^-" | wc -l  #计算当前目录下文件数量ls -lR | grep "^-" | wc -l #包括子目录ls -lR | grep "^d" | wc -l #计算当前目录下的目录数量，且不包括.和..ls -lR | grep "^l" | wc -l  #计算当前目录下的链接数量
```

## 列出目录下部分文件

当目录下文件较多时，可以结合more命令，只显示部分，例如:

```
ls -al|more
```

## 列出目录下所有文件的完整路径

例如，列出LTE目录下所有文件完整路径，$9代表第9列，即文件名，-R，递归子目录。

```
ls -lR |grep '^-' |awk '{print "/LTE/" $9}'/LTE/1.txt/LTE/home.zip/LTE/test.zip/LTE/qqq.txt/LTE/test.txt/LTE/qqq.txtls -lR |grep '^-' |awk '{print "/LTE/" $1 " " $9 }' ##打印第一列和第九列
```

^-也可以改为以下几种：

-   ^l 列出目录下所有链接
    
-   ^\[-l\] 列出目录下所有文件和链接
    
-   ^d 列出目录下所有目录
    
