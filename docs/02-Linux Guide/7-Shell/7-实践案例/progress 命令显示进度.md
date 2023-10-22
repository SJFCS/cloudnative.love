progress 命令几乎可以监控所有命令的进度，例如在移动文件，下载文件、复制文件、等操作，支持常用命令的监控

progress 命令是一个简单但功能强大的 Linux/Unix 命令行工具，可让用户查看文件操作的进度。

progress 命令几乎可以监控所有命令的进度，例如在下载文件、复制文件、等操作，支持常用命令的监控。

progress 命令默认监控命令包括 cp，mv，dd，tar，rsync，grep，cut，sort md5sum，gzip，bzip2 ，7z等命令，更多默认监控的命令请查看progress 命令的帮助。

在本教程中，我们将说明如何在 Linux 使用 progress 命令查看指定命令操作进度和剩余时间的信息。

## 安装 progress

progress 命令并没有预安装在大多数 Linux 发行版。要检查你的 Linux 发行版是否已安装 progress，请按快捷键 `CTRL+ALT+T` 打开终端，键入 progress，然后按 Enter。

如果你还没有安装 progress 命令，终端将会打印消息 Command 'progress' not found，你可以运行以下命令安装 progress 命令。

如果你的计算机运行的是基于 Debian 的 Linux 发行版，例如 Ubuntu，Linux Mint等。请运行 `sudo apt install progress` 命令安装 progress。

如果你的计算机运行的是基于 Redhat的 Linux 发行版，例如 CentOS，Fedora 等。请运行 `sudo yum install progress` 命令安装 progress。

```
sudo apt-get install -y progress #Debian ubuntu

##RedHat CentOS
sudo yum install epel-release
sudo yum install progress
```

## progress 命令

progress 命令的基本语法如下：

```
progress [-qdwmM] [-W secs] [-c command] [-p pid]
```

使用 progress 命令的最简单的方式不指定任何选项，progress 命令将会打印正在运行的默认监控命令进度和剩余时间信息。

如果你要监控的命令不存在默认的命令中，你可以使用 progress 命令的 -c 选项指定要监控的命令。也可以使用 -p 选项指定进程的 pid。

要查看默认监控的命令列表，请运行命令 progress --help | head -n 6 | tail -n 1。

```
progress --help | head -n 6 | tail -n 1
```

```
cp mv dd tar cat rsync grep fgrep egrep cut sort md5sum sha1sum sha224sum sha256sum sha384sum sha512sum adb gzip gunzip bzip2 bunzip2 xz unxz lzma unlzma 7z 7za zcat bzcat lzcat split gpg
```

## progress 选项

progress 命令常用的选项：

-   \-q / --quiet                 隐藏所有打印的消息。  
-   \-w / --wait                 显示IO的吞吐量和剩余时间。
-   \-m / --monitor            持续监控进程直到要监控进程的退出或者手动按 Ctrl+C 退出。
-   \-a / --additional-command  添加命令到默认监控命令列表。
-   \-c / --command  监控指定命令的名称 (ex: firefox)。
-   \-p / --pid id               监控指定进程的 PID (ex: `pidof firefox`)。
-   \-i / --ignore-file file        忽略指定文件。
-   \-o / --open-mode {r|w}       报告文件的打开模式。
-   \-v / --version                 打印命令的版本。
-   \-h / --help                    打印帮助信息。

## 查看 cp 命令复制进度

在复制大量文件或目录时，使用 progress 命令可以让我们了解当前复制的进度和评估的剩余时间。

例如，以下命令会将 bigfile 文件的复制到 newfile 文件，并显示当前进度和剩余时间的信息。

```
cp bigfile newfile & progress -mp $!
```

```
[211364] cp /home/myfreax/swapfile
25.8% (528.6 MiB / 2 GiB)
```

在这个命令中，我们使用 progress 命令的 -m 选项持续监控 cp 命令的进度和剩余时间，直到 cp 命令的退出。progress 也将会自动退出。

& 符号表示先运行左侧的命令然后再运行右侧命令，这样可以让轻松获取之前运行进程的 pid，progress 命令的 -p 选项指定要监控进程的 pid。$! 是最近运行的进程 pid。

## 查看 tar 命令压缩和解压文件进度

在压缩或解压缩大量文件时，你可能也需要使用 progress 命令查看操作的进度和估计剩余时间。

监控 tar 命令进度的信息和剩余时间查看 cp 命令类似，都是使用 progress 命令监控指定进程的进程。

例如，以下命令会将一个名为 source 的目录压缩成一个名为 `archive.tar.gz` 的压缩文件，并显示压缩进度信息：

```
tar czfv archive.tar.gz source & progress -mp $!
```

## 查看 mv 命令移动文件进度

以下命令会将一个名为 `source` 的目录重命名为 `destination`，并显示重命名进度信息：

```
mv source destination & progress -mp $!
```

## 监控多个命令的进度

如果你需要同时监控多个命令进度信息，可以使用 progress 命令的 -m 选项持续监控所有命令的进度。

如果你只需要查看一次默认命令的进度和剩余时间信息，也可以在不指定任何选项运行 progress 命令。 progress 命令将会收集正在运行的或者即将运行的默认命令进度和剩余时间信息。

注意：progress 命令的 -m 选项仅支持默认的命令，如果你要监控多个命令且不在默认命令，可以使用 -a 选项添加默认监控命令列表。

```
progress -m
```

## 结论

总的来说，progress 命令可以在许多不同的上下文中使用，可以帮助我们更好地了解长时间运行的命令的进度和估计完成时间。

无论是在复制、压缩、安装软件包还是移动和重命名文件或目录时，使用 progress 命令都可以使我们更有效当前任务的进度。