
# VIM编辑器的使用

[[toc]]

## VIM的模式


-  `命令模式`：vim默认启动进入此模式。
-  `插入模式`：在命令模式下，使用`i`或`o`或`a`可以进入插入模式（`insert`）。
-  `修改模式`：在命令模式下，使用`R`可以进入修改模式（`Replace`）。
-  `扩展命令模式`：在命令模式下，使用英文冒号`:`可以进入扩展命令模式（`:`）。

## 命令模式常用快捷键


-  `G`      移动到文件的最后一行。
-  `nG`     n为数字，移动到文件的第n行。
-  `gf`　　 打开以光标所在字符串为文件名的文件
-  `gg`　　 移动到文件的第一行。
-  `N[Enter]`　　向下移动N行。
-  `h` 　　 向左移动光标（`←`）
-  `j` 　　 向下移动光标（`↓`）
-  `k` 　　 向上移动光标（`↑`）
-  `l（小L）` 　向右移动光标（`→`）
-  `20j`    　　向下移动20行
-  `+` 或 `Enter`　　把光标移至下一行第一个非空白字符
-  `-`　　把光标移至上一行第一个非空白字符
-  `^`     把光标移至本行第一个非空白字符
-  `0或Home`  移动光标至行首
-  `$或End` 　移动光标至行尾
-  `w`　　 向右移动一个单词,光标停在下一个单词开头
-  `W`  　 向右移动一个单词,光标移动时忽略一些标点
-  `b`　　 向左移动一个单词,光标停在下一个单词开头
-  `B`　　 向左移动一个单词，光标移动时忽略一些标点
-  `e`　　 向右移动一个单词,光标停在下一个单词末尾
-  `E`　　 向右移动一个单词，光标移动时忽略一些标点
-  `ge`　　 向左移动一个单词,光标停在下一个单词末尾
-  `gE`　　 向左移动一个单词，光标移动时忽略一些标点
-  `H` 　　 移动光标至屏幕的最上方那一行行首
-  `M` 　　 移动光标至屏幕的最中间那一行行首
-  `L` 　　 移动光标至屏幕的最下方那一行行首
-  `(`      移动光标至上一句
-  `)`      移动光标至下一句
-  `{`      移动光标至上一段
-  `}`      移动光标至上一段
-  `ctrl+b`　　屏幕向上移动一页
-  `ctrl+f`　　屏幕向下移动一页
-  `ctrl+d`　　屏幕向上移动半页
-  `ctrl+u`　　屏幕向下移动半页
-  `ctrl+e`　　屏幕向下移动一行
-  `n%`        到文件n%的位置，如1%，50%, 100%之类
-  `zz`        将当前行移动到屏幕中央
-  `zt`        将当前行移动到屏幕顶端
-  `zb`        将当前行移动到屏幕底端
-  `dd`　　
   剪切当前行（不是删除，因为此时在缓存内保存了一份剪切的字符串）。
-  `d$` 　　 删除光标位置到该行最后一个字符(包括光标字元)。
-  `d0` 　　 删除光标字元至行首字符(不包括光标字元)。
-  `dG` 　　 删除光标所在行至最后一行所有字符(包括光标所在行)。
-  `d1G` 　　删除光标所在行（包括光标所在行）与首行间所有字符。
-  `ndd`　　删除光标所在行（包括）向下的n行。
-  `dw` 　　
   删除光标所在字符至下一个单词间所有字符(包括下一个单词前面的空格)。
-  `daw`　　剪切光标所在位置的单词。
-  `das` 　 剪切光标所在位置的句子。
-  `x` 　　 向后删除一个字符。
-  `nx`　　 向后删除n个字符。
-  `yy` 　　 复制当前行。
-  `nyy`　　复制n行（包含当前行）。
-  `y1G`　　复制第一行至当前行所有字符。
-  `yG`　　 复制当前行到最后一行所有字符。
-  `y0`　　 复制当前行行首字符至光标字符间所有字符。
-  `y$`　　 复制当前行光标字符到行尾字符间所有字符。
-  `yaw`　　复制光标所在位置的单词。
-  `yas`　　复制光标所在位置的句子。
-  `ZZ`　　 保存更改并退出。
-  `p`  　　
    将已经复制的数据粘贴到光标的下一行（若是使用y0,y$复制的行的一部分，则粘贴时，会粘贴到光标所在行的光标字符后面）。
-  `P`　　
   将已经复制的数据粘贴到光标的上一行（若是使用y0,y$复制的行的一部分，则粘贴时，会粘贴到光标所在行的光标字符前面）。
-  `u`　　 复原上一操作（撤消）。
-  `ctrl+R`　　重做上一操作。
-  `.`    　　 点号，重做上一操作。
-  `J`　　    将当前行与下一行合并为一行。
-  `gJ`　　 将当前行与下一行合并为一行,不过合并后不留空格。
- `<<`      段落向左缩进一个shiftwidth
- `>>`      段落向右缩进一个shiftwidth
- `gq`     对选中的长文字进行重排
-  `o` 　　 当前行下插入空行，并进入插入模式。
-  `O`　　  当前行上插入空行，并进入插入模式。
-  `i`　　  进入插入模式，从当前光标所在处插入。
-  `I` 　　 进入插入模式，从当前行第一个非空格处开始插入。
-  `a`　　 进入插入模式，从当前光标所在处下一个字符开始插入。
-  `A`　　进入插入模式，从当前光标所在行最后一个字符开始插入。
- `8i=<ESC>` 重复输入小技巧，先按数字`8`,再按`i`进入插入模式，再按`=`或其他字符，如`=-`，再按`Esc`退出键，再按一次键，就会出现`8`次`=-`组成的字符串。如`=-=-=-=-=-=-=-=-`
-  `ESC健` 　　返回命令模式。



## 编辑模式


在命令模式下按`i`、`o`、`a`等键可进入插入模式（编辑模式）。

-   `o`　　当前行下插入空行，并进入插入模式。
-   `O`　　当前行上插入空行，并进入插入模式。 
-   `i`　　进入插入模式，从当前光标所在处插入。
-   `I`　　进入插入模式，从当前行第一个非空格处开始插入。
-   `a`　　进入插入模式，从当前光标所在处下一个字符开始插入。
-   `A`　　进入插入模式，从当前光标所在行最后一个字符开始插入。

另外按字母`s`也可以进入插入模式： 

-  `s`　　小s，删除光标字符，并进入编辑模式，并在光标所在位置开始编辑。
-  `S`　　大S，删除光标所在行，并进入编辑模式，并在行首开始编辑。
-  `ns`　删除包含光标字符在内的n个字符，并进入编辑模式。
-  `nS`　大S，删除光标所在行在内及其后的n-1行，并进入编辑模式。

## 扩展命令模式常用操作键


-  `:r filename` 在当前位置插入另一个文件的内容
-  `:[n]r filename` 在当前文件第n行插入另一个文件的内容
-  `:r !date` 在光标处插入当前日期与日期，同理，`:r !command`可以将其他`shell`命令的输出插入到当前文档
-  `:r !cat filename|head -n N`  在当前文件光标的下一行插入文件filename的前N行
-  `:w` 　保存
-  `:q`　  离开vim
-  `:q!`　 强制离开
-  `:wq`　 保存后离开
-  `:w [filename]`　　　　将当前文本另存为filename
-  `:n1,n2 w [filename]`　　将n1至n2行内容另存为filename
- `:ce(nter)`  本行文字居中
- `:le(ft)`    本行文字靠左
- `:ri(ght)`   本行文字靠右
-  `/word` 　　　　　　　　　 向下查找关键字word。
-  `?word`　　　　　　　　　　向上查找关键字word。
-  `:n1,n2s/word1/word2/g`　　在第n1行与第n2行之间查找word1字符串，并直接替换为word2。
-  `:1,$s/word1/word2/g`　　　在第1行最后一行之间查找word1字符串，并直接替换为word2。
-  `:1,$s/word1/word2/gc`
   　　　　在第1行最后一行之间查找word1字符串，并替换为word2（替换时询问用户是否替换）。
-  `:.,+5s/^/#/g`　　　　　　　　将当前行及下面5行标记为注释(包括当前行，共6行)。
-  `:6,9 de`　　　　　　　　　　删除第6至第9行。
-  `:2,8 co 10`　　　　　　　　复制第2行至第8行内容至第10行后面(从下一行开始)
-  `:set nu` 　　　　　　　　　　显示行号。
-  `:set nonu`　　　　　　　　不显示行号。
-  `:set hlsearch`　　　　　　　　高亮度搜索显示
-  `:set nohlsearch`　　　　　　不高亮度搜索显示
-  `:set autoindent/noautoindent`　　自动缩进
-  `:set ruler/noruler` 　　　　　　设置右下角状态栏说明
-  `:set showmode/noshowmode`　　设置是否显示左下角（-INSERT-）状态列
-  `:set backspace=2`　　　　　　=2时，退格键可删除任意字符，=0或=1时只能删除刚输入的字符。
-  `:set` 　　　　　　　　　　显示与系统预设值不同的设定参数。
-  `:set all`　　　　　　　　　　显示所有的环境参数值
-  `:syntax on/off`  　　　　　　设置语法高亮
-  `:set bg=dark/light`　　　　　　设置背景（background）为暗色/亮色
-  `:set tabstop=4`　　　　　　     设置Tab宽度
-  `:set shiftwidth=4`　　　　　　设置每一级缩进的宽度
-  `:Sex`      水平分割一个窗口，浏览文件系统
-  `:Vex`        垂直分割一个窗口，浏览文件系统

## `~/.vimrc`常用环境变量设置


-  set hlsearch　　　　“设置高亮度反白
-  set backspace=2　　　　“可随时用退格键删除
-  set ruler　　　　　　“可显示最后一行的状态
-  set showmode　　　　“显示状态
-  set nu　　　　　　“显示行号
-  set bg=dark　　　　“显示不同的底色色调
-  set softtabstop=4   “统一缩进为4
-  set tabstop=4　　　　"设置Tab宽度
-  set shiftwidth=4　　　　"设置每一级缩进的宽度
-  set fileencodings=utf-8,gbk,gb18030,gk2312
-  syntax on　　　　　　"语法高亮
-  set showcmd　　　　"输入的命令显示出来，看的清楚些
-  set clipboard+=unnamed　　　　"共享剪贴板
-  set cursorline　　　　"突出显示当前行
-  set noeb　　　　　　"去掉输入错误的提示声音
-  set confirm　　　　　　"在处理未保存或只读文件的时候，弹出确认
-  set autoindent　　　　"设置自动缩进
-  set cindent       "设置自动缩进
-  set expandtab　　"用空格代替制表符
-  set smarttab　　　　"在行和段开始处使用制表符
-  set laststatus=2　　　　"总是显示状态栏

`~/.vimrc`配置文件内容如下:

```sh
set hlsearch
set backspace=2
set ruler
set showmode
set nu
set bg=dark
set softtabstop=4
set shiftwidth=4
set fileencodings=utf-8,gbk,gb18030,gk2312
syntax on
set showcmd
set clipboard+=unnamed
set cursorline
set confirm
set autoindent
set cindent 
set expandtab                                                            
set laststatus=2
```

## 可视模式


-  可视模式（`Visual
   Black`），也即区块选择模式，此时可以对列字符进行操作。
-  在命令模式下，按`v`或`V`或`ctrl+v`可以进入到可视模式。
-  `v` 　　　　进入可视模式，并进行单字符（反白）选择。
-  `V`　　　　进入可视模式，并进行行（反白）选择。
-  `ctrl+v`
   　　进入可视模式，并进行区块选择，以长方形的方式（反白）选择字符。
-  `y` 　　　　将反白的地方复制下来。
-  `d`　　　　删除反白区域。
-  进入可视模式后，可以按方向键或`h`/`j`/`k`/`l`(向左、向下、向上、向右)进行反白区域选择。

## 多视窗功能


-  输入`:sp`进入多视窗模式，此时，可以对文本进行前后对照或不同档案间进行对照。
-  `:sp`  同一文件两个视窗，进行前后对照。
-  `:sp [filename]`  两个文件进行对照。

在多视窗模式下：

-  `ctrl+w`   可依次在多个视窗间进行上下循环切换。 
-  `ctrl+w+k` 可依次在多个视窗间进行从下到上切换（先按ctrl+w，松开后，再按k）。
-  `ctrl+w+j`  可依次在多个视窗间进行从上到下切换（先按ctrl+w，松开后，再按j）。
-  `ctrl+w+q`  关闭当前视窗下面的视窗（先按ctrl+w，松开后，再按q）。

## 增加编程语言模板的`.vimrc`配置文件


`~/.vimrc`配置文件内容如下:

```sh
execute pathogen#infect()
syntax on
filetype plugin indent on
set hlsearch
set backspace=2
set autoindent
set ruler
set showmode
set nu
set bg=dark
set ts=4
set softtabstop=4
set shiftwidth=4
set fileencodings=utf-8,gbk,gb18030,gk2312
set showcmd
set clipboard+=unnamed
set cursorline
set confirm
set autoindent
set cindent 
set expandtab
set laststatus=2


"SET Comment START

autocmd BufNewFile *.c,*.py,*.go,*.sh exec ":call SetComment()" |normal 10Go

func SetComment()
    if expand("%:e") == 'c'
        call setline(1, "/*")
        call append(1, ' *      Filename: '.expand("%"))
        call append(2, ' *        Author: Zhaohui Mei<mzh.whut@gmail.com>')
        call append(3, ' *   Description:      ')
        call append(4, ' *   Create Time: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(5, ' * Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(6, ' */')
        call append(7, '')
        call append(8, '')
        call append(9, '')
        call append(10, '')
    elseif expand("%:e") == 'go'
        call setline(1, "/*")
        call append(1, ' *      Filename: '.expand("%"))
        call append(2, ' *        Author: Zhaohui Mei<mzh.whut@gmail.com>')
        call append(3, ' *   Description:      ')
        call append(4, ' *   Create Time: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(5, ' * Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(6, ' */')
        call append(7, 'package main')
        call append(8, '')
        call append(9, 'import "fmt"')
        call append(10, '')
        call append(11, 'func main() {')
        call append(12, '    fmt.Println("vim-go")')
        call append(13, '}')
    elseif expand("%:e") == 'py'
        call setline(1, '#!/usr/bin/python3')
        call append(1, '"""')
        call append(2, '#      Filename: '.expand("%"))
        call append(3, '#        Author: Zhaohui Mei<mzh.whut@gmail.com>')
        call append(4, '#   Description:      ')
        call append(5, '#   Create Time: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(6, '# Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(7, '"""')
        call append(8, '')
        call append(9, '')
        call append(10, '')
    elseif expand("%:e") == 'sh'
        call setline(1, '#!/bin/bash')
        call append(1, '##################################################')
        call append(2, '#      Filename: '.expand("%"))
        call append(3, '#        Author: Zhaohui Mei<mzh.whut@gmail.com>')
        call append(4, '#   Description:      ')
        call append(5, '#   Create Time: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(6, '# Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        call append(7, '##################################################')
        call append(8, '')
        call append(9, '')
        call append(10, '')
        endif
endfunc
map <F2> :call SetComment()<CR>:10<CR>o

"SET Comment END

"SET Last Modified Time START

func DataInsert()
    if expand("%:e") == 'c' || expand("%:e") == 'go'
        call cursor(6, 1)
        if search ('Last Modified') != 0
            let line = line('.')
            call setline(line, ' * Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        endif
    elseif expand("%:e") == 'py' || expand("%:e") == 'sh'
        call cursor(7, 1)
        if search ('Last Modified') != 0
            let line = line('.')
            call setline(line, '# Last Modified: '.strftime("%Y-%m-%d %H:%M:%S"))
        endif
    endif
endfunc
autocmd FileWritePre,BufWritePre *.c,*.py,*.go,*.sh ks|call DataInsert() |'s
"SET Last Modified Time END

"" refer:https://blog.csdn.net/qq844352155/article/details/50513072
```

使用`vim`新建`test.go`后显示如下:

```go
1 /*                                                                                                                      
2  *      Filename: test.go
3  *        Author: Zhaohui Mei<mzh.whut@gmail.com>
4  *   Description:      
5  *   Create Time: 2019-11-24 23:52:56
6  * Last Modified: 2019-11-24 23:52:56
7  */
8 package main
9 
10 import "fmt"
11 
12 
13 func main() {
14     fmt.Println("vim-go")
15 }
```
