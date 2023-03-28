---
title: vim 与系统剪切板之间的交互
---
https://harttle.land/2020/09/04/vim-clipboard.html  
https://www.cnblogs.com/gmpy/p/11177719.html  
https://mbinary.xyz/wsl-vim-clipboard.html  
http://vimcasts.org/blog/2013/11/getting-vim-with-clipboard-support/  
https://stackoverflow.com/questions/58306002/vs-code-vim-extension-copy-and-paste  
## TL; DR


## clipboard

```
vim --version| grep "clipboard"
```
支持这特性的检索结果应该包含 `+clipboard`，而不支持则会是 `-clipboard`
2.如果不支持的话，需要安装`vim-gnome`，或者[从源码构建vim](https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source)
Linux 下，如果是 Debian 或 Ubuntu 可以安装 vim-gtk、vim-gnome，Redhat/CentOS 则可以安装 vim-X11。
或者安装gvim
## registers 

有人知道如何在 vim 中显示缓存中用于剪切、复制、粘贴、撤消、重做等操作的内容列表吗？  
https://stackoverflow.com/questions/60431864/how-to-display-the-content-of-the-cache-in-vim


例如我们在vim中`y`操作复制的内容，实际就是暂存到registers 中。


要查看复制/粘贴操作中使用的registers的内容 ，可以使用:

```
:reg

```
Vim 的撤销/重做历史记录以树形格式保存，可以通过以下方式查看:
```
:undolist

```
但是它并不是很方便，所以您可以使用像 [undotree](https://github.com/mbbill/undotree) 这样的插件。

如果希望查看命令历史记录，请使用:

```
:history

```



在vim中，这些寄存器也有好几个

| 表示符号                  | 名称                                   | 作用                                                                                              |
| ------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `""`                      | 无名（unnamed）寄存器                  | 缓存最后一次操作内容                                                                              |
| `"0` ～ `"9`              | 数字（numbered）寄存器                 | 缓存最近操作内容，复制与删除有别，`"0`寄存器缓存最近一次复制的内容，`"1`\-`"9`缓存最近9次删除内容 |
| `"-`                      | 行内删除（small delete）寄存器         | 缓存行内删除内容                                                                                  |
| `“a` ～ `"z`或`"A` - `”Z` | 具名（named）寄存器                    | 可用于主动指定                                                                                    |
| `":`, `".`, `"%`, `"#`    | 只读（read-only）寄存器                | 分别缓存最近命令、最近插入文本、当前文件名、当前交替文件名                                        |
| `"=`                      | 表达式（expression）寄存器             | 用于执行表达式命令                                                                                |
| `"*`, `"+`, `"~`          | 选择及拖拽（selection and drop）寄存器 | 存取GUI选择文本，可用于与外部应用交互                                                             |
| `"_`                      | 黑洞（black hole）寄存器               | 不缓存操作内容（干净删除）                                                                        |
| `"/`                      | 模式寄存器（last search pattern）      | 缓存最近的搜索模式                                                                                |

为了要与系统的剪切板交互，我们着重关注`"*`和`"+`

**在vim中进入visual视图后使用"Ny(N表示特定寄存器编好)，将内容复制到特定的剪切板**

因此，如果要把数据从vim拷贝到系统剪切板，我们只需要在**visual模式**下执行

```
"+y

```

注意的是，是 **双引号 + 加号寄存器 + y**。通过这命令后就可以去浏览器Ctrl+v啦

如果从浏览器Ctrl+c后，要粘贴到vim中，则需要

```
"+p

```

`"*`和`"+`有什么差别呢？

`"*` 是在系统剪切板中表示选择的内容  
`"+` 是在系统剪切板中表示选择后Ctrl+c复制的内容

## 3\. 使用快捷键

**"+y**和**"+p**的输入挺麻烦的，我们直接为他们创建个快捷键吧

```
" 支持在Visual模式下，通过C-y复制到系统剪切板
vnoremap <C-y> "+y
" 支持在normal模式下，通过C-p粘贴系统剪切板
nnoremap <C-p> "*p

```

将上面的内容到**~/.vimrc**中即可生效，效果就是：

1.  在vim的visual模式下选中了要复制的内容，再用Ctrl + y复制到系统剪切板，直接去其他窗口中Ctrl + v粘贴
2.  在其他窗口中选择之后（不一定要Ctrl + c），可直接在vim中用Ctrl + p来粘贴

## 4\. ssh远程复制

实现ssh远程复制到系统剪切板，此处用到 **clipper**，下图是其原理，简单来说就是远程通过socket/网络发到本地，本地再设置到系统剪切板。

[clipper](https://github.com/wincent/clipper)


## 4.1 本地安装

本质只是添加了 clipper 的可执行程序，不涉及任何库，除此之外，不同系统拷贝到剪切板的命令不同，请确保本地支持此命令：

-   Mac: pb
-   Linux: xclip 或者 xsel

> 《Windows/Mac/Linux 如何将内容输出到剪贴板》：[https://segmentfault.com/a/1190000024579429](https://segmentfault.com/a/1190000024579429)

### 4.1.1 For Mac

使用以下命令直接安装：

```
brew install clipper

```

### 4.1.2 For Linux

不支持常规的 `apt/yum`，可以考虑用源码安装：

```
git clone git://git.wincent.com/clipper.git
cd clipper
go build
sudo cp clipper /usr/local/bin

```

## 4.2 本地设置常驻服务

### 4.2.1 For Mac

在 `~/Library/LaunchAgents/` 创建文件 `com.wincent.clipper.plist`，添加以下内容：

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN http://www.apple.com/DTDs/PropertyList-1.0.dtd >
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.wincent.clipper</string>
<key>ProgramArguments</key>
<array>
<string>/usr/local/bin/clipper</string>
</array>
<key>EnvironmentVariables</key>
<dict>
<key>LANG</key>
<string>en_US.UTF-8</string>
</dict>
<key>KeepAlive</key>
<true/>
<key>LimitLoadToSessionType</key>
<string>Aqua</string>
</dict>
</plist>

```

然后执行：

```
launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.clipper.plist

```

验证是否正常运行：

```
$ ps aux | grep clipper
...
xxxx             45041   0.0  0.0 34979812   3300   ??  S     3:59下午   0:00.44 /usr/local/bin/clipper

```

### 4.2.2 For Linux

根据 Linux 发行版的不同，可能有点不一样。由于缺少环境验证，可以问问度娘。

其实拉起常驻服务的本质是运行 clipper ，采用默认的配置（端口：8377），我们甚至可以粗暴的跑个后台：

```
$ nohup clipper &>/dev/null &

```

clipper 的各个参数可以参考 `clipper --help`，大多数情况下使用默认的即可。

## 4.3 映射本地与远程的端口

由于我并不擅长网络，此处沿用 clipper 作者推荐的做法，在 ssh 连接时绑定端口

```
ssh -R localhost:8377:localhost:8377 user@host.example.org

```

当然，我们可以配置 ssh，省去每次 ssh 连接的 **\-R xxxx** 选项。

```
$ cat ~/.ssh/config
Host host.example.org
  RemoteForward 8377 localhost:8377

```

## 4.4 远程触发传输

触发的本质是使用 nc 命令向本地的 8377 端口发送数据，例如以下命令发送 _test_ 文本。

```
echo -n test | nc -N localhost 8377

```

-   _Ubuntu 要使用 **\-N** 参数，否则会无法退出，其他环境请自行验证_

### 4.4.1 vim 触发

我们只需要配置 **.vimrc**，设置个按键映射就可以了。

```
nnoremap <C-y> :call system('nc localhost 8377', @0)<CR>

```

上述的意思是，normal 模式下执行 `Ctrl + y` 触发传输，通过调用函数 system 执行 nc 命令，把寄存器0的内容通过端口8377发送出去。使用寄存器0意味着，我需要传输必须先 y 拷贝后，再执行 `Ctrl + y` 传输。

_由于我远程的ubuntu是服务器版本，vim不带GUI，导致vim不支持 \*/+ 寄存器，因此无法实现 Virtual 模式下直接复制，有条件的同学可以试试_

### 4.4.2 tmux 触发

配置 ~/.tmux.conf，添加以下内容：

```
# Bind "Enter" in copy mode to both copy and forward to Clipper:
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "nc -N localhost 8377"

```

在tmux的copy模式，绑定 Enter 按键实现拷贝和传输 Clipper