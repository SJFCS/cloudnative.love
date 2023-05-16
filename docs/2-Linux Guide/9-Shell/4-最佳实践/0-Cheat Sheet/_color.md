# echo输出带颜色的字体  写成变量方便调用，支持echo和printf
[[toc]]

## 概述


在`Linux`命令行终端或`Bash Shell`脚本中适当使用颜色，能够让第一时间感觉到您的命令或脚本执行过程中差异。本文主要介绍使用`echo`输出带颜色的字体。

## `echo`不带参数输出字符串

当`echo`命令不带参数时，可以直接输出字符串，如下所示:

```sh
[meizhaohui@localhost ~]$ echo "abc"
abc
[meizhaohui@localhost ~]$ echo def
def
```

## `echo`带参数输出字符串

当`echo`命令带`-e`参数时，可以使用反斜杠`\`输出特殊的字符。

echo输出带颜色的字体格式如下:

```sh
$ echo -e "\033[字背景颜色;字体颜色m字符串\033[0m"
    
# 其中: "\033" 引导非常规字符序列。”m”意味着设置属性然后结束非常规字符序列。
```

例如:

```sh
$ echo -e "\033[41;32m红色背景绿色文字\033[0m"
    
# 其中: 41的位置代表底色, 32的位置是代表字的颜色。
```

下面是代码输出绿色文字:

```sh
$ echo -e "\033[32m绿色文字\033[0m"
```

## 使用复杂的颜色输出


### 输出红字和绿字

```sh
$ echo -e "\033[31m红字\033[32m绿字\033[0m" # 输出红字和绿字
```



### 输出红字和带黄色背景的绿字

```sh
$ echo -e "\033[31m红字\033[43;32m绿字带黄色背景\033[0m" # 输出红字和带黄色背景的绿字
```

![red_green_font_yellow_background.png](/img/red_green_font_yellow_background.png) 


### 带下划线的白色背景的红字、高亮的红色背景的绿字

```sh
$ echo -e "\033[4;47;31m带下划线的白色背景的红字\033[0m\033[1;41;32m高亮的红色背景的绿字\033[0m"
```

![underline_highlight1](/img/underline_highlight1.png)



### 带下划线的白色背景的红字、高亮的红色背景的绿字

```sh
$ echo -e "\033[4m\033[47m\033[31m带下划线的白色背景的红字\033[0m \033[1m\033[41m\033[32m高亮的红色背景的绿字\033[0m"
```

![underline_highlight2](/img/underline_highlight2.png)    


### 带下划线的白色背景的红字、高亮的红色背景的带下划线的绿字

```sh
$ echo -e "\033[4m\033[47m\033[31m带下划线的白色背景的红字\033[0m \033[1;4m\033[41m\033[32m高亮的红色背景的带下划线的绿字\033[0m"
```

![underline_highlight3](/img/underline_highlight3.png)    


通过以上示例可知：控制符可以进行组合在一起，如`\033[4;47;31m`将三个属性组合在一起(属性数字中间使用分号;隔开)；也可以`\033[4m\033[47m\033[31m`每个属性单独写。

## 字背景颜色范围`40–47`

- `40`:黑
- `41`:红
- `42`:绿
- `43`:黄色
- `44`:蓝色
- `45`:紫色
- `46`:天蓝
- `47`:白色

## 字颜色`30–37`

- `30`:黑
- `31`:红
- `32`:绿
- `33`:黄
- `34`:蓝色
- `35`:紫色
- `36`:天蓝
- `37`:白色

## ANSI控制码的说明

- `\33[0m` 关闭所有属性
- `\33[1m` 设置高亮度
- `\33[4m` 下划线
- `\33[5m` 闪烁
- `\33[7m` 反显

如果经常使用颜色控制的话，可以将颜色控制符进行定义好。
可以在`~/.bashrc`中设置个人偏好，使用`vi ~/.bashrc`打开`.bashrc`文件：并将下面的变量写入到文件中：

将下面的变量写入到`~/.bashrc`文件中:

```sh
[meizhaohui@localhost ~]$ vi ~/.bashrc
bg_black=”\033[40m”
bg_red=”\033[41m”
bg_green=”\033[42m”
bg_yellow=”\033[43m”
bg_blue=”\033[44m”
bg_purple=”\033[45m”
bg_cyan=”\033[46m”
bg_white=”\033[47m”
    
fg_black=”\033[30m”
fg_red=”\033[31m”
fg_green=”\033[32m”
fg_yellow=”\033[33m”
fg_blue=”\033[34m”
fg_purple=”\033[35m”
fg_cyan=”\033[36m”
fg_white=”\033[37m”
    
set_clear=”\033[0m”
set_bold=”\033[1m”
set_underline=”\033[4m”
set_flash=”\033[5m”
```

输入完成后，先按`Esc`键，再按`:`键，并输入`wq`保存退出。

使用以下命令使刚才的修改生效:

```sh
[meizhaohui@localhost ~]$ source ~/.bashrc
```

此时按如下命令输入相应的字体:

```sh
[meizhaohui@localhost ~]$ echo -e "${bg_red}${fg_green}${set_bold}红色背景粗体的绿色字${set_clear}"
红色背景粗体的绿色字
红色背景粗体的绿色字  
[meizhaohui@localhost ~]$ echo -e "${bg_red}${fg_green}红色背景的绿色字${set_clear}"
红色背景的绿色字
红色背景的绿色字
```

如果要在脚本中使用使用`~/.bashrc`中定义的`bg_red`、`fg_green`等变量，可以在`shell`脚本中使用`source ~/.bashrc `或者点操作符加载`~/.bashrc`文件到脚本中。

打印颜色脚本:

```sh
[meizhaohui@localhost ~]$ cat print_color.sh
#!/bin/bash
#Source personal definitions
source ~/.bashrc
# 或使用以下命令：
# . ~/.bashrc
echo -e "${bg_red}${fg_green}${set_bold}红色背景粗体的绿色字${set_clear}"
```

运行脚本:

```sh
[meizhaohui@localhost ~]$ sh print_color.sh
```

![red_back_bold_green.PNG](/img/red_back_bold_green.PNG)    

## 日志颜色控制

当我们编写Shell脚本时，需要将日志信息保存起来，我们也可以使用`echo`命令输出带颜色的字体，方便查看日志信息。

如，我们将以下代码加入到`~/.bashrc`文件中，并重新加载，使其生效。

```sh
#################################################
# Get now date string.
# 当前日期字符串
#################################################
function now_date() {
    format=$1
    if [[ "${format}" ]]; then
        now=$(date +"${format}")
    else
        now=$(date +"%Y%m%d_%H%M%S")
    fi

    echo "${now}"
}

#################################################
# Basic log function.
# 基本日志，输出时间戳
# ex: [2021/08/15 19:16:10]
#################################################
function echo_log() {
    now=$(date +"[%Y/%m/%d %H:%M:%S]")
    echo -e "\033[1;$1m${now}$2\033[0m"
}

#################################################
# Debug log message.
# 调试日志，黑色
#################################################
function msg_debug() {
    echo_log 30 "[Debug] ====> $*"
}

#################################################
# Error log message.
# 异常日志，红色
#################################################
function msg_error() {
    echo_log 31 "[Error] ====> $*"
}

#################################################
# Success log message.
# 成功日志，绿色
#################################################
function msg_success() {
    echo_log 32 "[Success] ====> $*"
}

#################################################
# Warning log message.
# 警告日志，黄色
#################################################
function msg_warn() {
    echo_log 33 "[Warning] ====> $*"
}

#################################################
# Information log message.
# 一般消息日志，蓝色
#################################################
function msg_info() {
    echo_log 34 "[Info] ====> $*"
}
```

然后，在命令行就可以打印不同样式的消息了。

```sh
[meizhaohui@hellogitlab ~]$ msg_debug 'debug message'
[2021/08/21 12:35:45][Debug] ====> debug message
[meizhaohui@hellogitlab ~]$ msg_info "info message"
[2021/08/21 12:35:47][Info] ====> info message
[meizhaohui@hellogitlab ~]$ msg_warn 'warn message'
[2021/08/21 12:35:58][Warning] ====> warn message
[meizhaohui@hellogitlab ~]$ msg_error 'error message'
[2021/08/21 12:36:16][Error] ====> error message
[meizhaohui@hellogitlab ~]$ msg_success 'success message'
[2021/08/21 12:36:25][Success] ====> success message
```

实际效果如下：

![](/img/20210821123847.png)

可以看到，这种效果非常漂亮。后面我们可以把相应的消息写入到日志文件中，后期查看日志文件内容时，也可以看到有颜色的日志信息。

请看以下示例：

```sh
[meizhaohui@hellogitlab ~]$ msg_info "info message" >> log.txt
[meizhaohui@hellogitlab ~]$ msg_warn 'warn message' >> log.txt
[meizhaohui@hellogitlab ~]$ msg_success 'success message' >> log.txt
[meizhaohui@hellogitlab ~]$ cat log.txt
[2021/08/21 12:40:14][Info] ====> info message
[2021/08/21 12:40:27][Warning] ====> warn message
[2021/08/21 12:40:37][Success] ====> success message
[meizhaohui@hellogitlab ~]$
```

效果如下：

![](/img/20210821124157.png)





参考文献：

1、[控制输出颜色的shell脚本](http://www.jb51.net/article/90436.htm)

