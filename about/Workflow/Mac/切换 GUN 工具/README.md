---
title: 切换 GUN 工具
---
MacOS 的自带命令行工具是 BSD 版本，行为参数和 GNU/Linux 不一致，无法很好的调试 shell 脚本。
本文介绍如何将 MacOS 的将命令行工具从 BSD 版本替换为 GNU 版本

## 安装 GNU 工具
如需要搜索所有 GNU 工具列表，可以通过以下命令获得：
```bash
brew search gnu
```
安装所需工具
```bash
brew install coreutils
brew install gawk
brew install gsed
brew install findutils
brew install gnu-sed
brew install gnu-indent
brew install gnu-tar
brew install gnu-which
brew install gnutls
brew install grep
brew install gzip
brew install screen
brew install watch
brew install wdiff --with-gettext
brew install wget
brew install less
brew install unzip
```
您可以通过在命令前加上“g”来调用它们，或者将它们添加到您的PATH环境变量中以替换默认的Mac工具。
## 在 BSD 与 GNU 之间切换
如果您不想改变脚本中的命令，也可以使用PATH环境变量来优先使用GNU工具，而不是默认的BSD工具。
也可以使用 `brew link gnu-sed --with-default-names` 设置优先级

### 方法一
Homebrew 安装的命令工具默认放置在 /usr/local/opt/，而系统自带 BSD 工具的路径为 /usr/bin/。当安装的 GNU 命令与系统自带命令重复时，用前缀 g 可以指定使用 GNU 版本。如果想省去 g 前缀，在环境变量 PATH 中把 GNU 工具的执行路径放置于 /usr/bin 之前即可

假设您已经使用 Homebrew 安装了 GNU 工具。您可以在终端中运行以下命令，切换到 GNU：
```bash
export PATH="/usr/local/opt/<PACKAGE>/libexec/gnubin:$PATH"
# <PACKAGE> 为工具包名称
```

可添加到 ~/.zshrc （若使用 Bash，则为 ~/.bash_profile） 


```bash
gnu_utils=(
  PACKAGE
  # the other utils ...
)

gnu() {
  for _util in "${gnu_utils[@]}"; do
    export PATH="/usr/local/opt/$_util/libexec/gnubin:$PATH"
  done
  [[ $1 == "--quiet" ]] || echo "Switched to GNU utils!"
}

bsd() {
  for _util in "${gnu_utils[@]}"; do
    export PATH="$(echo $PATH | sed "s|/usr/local/opt/$_util/libexec/gnubin:||")"
  done
  echo "Switched to BSD utils!"
}

gnu --quiet
```
终端输入 `bsd` 和 `gnu` 进行模式切换

### 方法二
```bash
brew install gnu-sed --with-default-names
```
这是一个在 MacOS 上使用 Homebrew 软件包管理器安装 GNU Sed 文本编辑器的命令，并使用选项“--with-default-names” 将其命名为 “sed”，以避免与 MacOS 默认的 BSD Sed 发生冲突。这将使用户能够在命令行中使用 “sed” 而无需指定 GNU Sed 的路径。

**如何切换回来**
如果您已经安装了使用命令 “brew install gnu-sed --with-default-names” 安装的 GNU Sed ，并且想要切换回 MacOS 默认的 BSD Sed ，则可以使用以下命令：
```bash
brew unlink gnu-sed && brew link sed
```
**再切换回去**
如果您想要再次切换回GNU Sed，可以使用以下命令：
```bash
brew unlink sed && brew link gnu-sed --with-default-names
```
这将取消链接 MacOS 默认的 sed 并链接使用 “--with-default-names” 选项安装的 GNU Sed。现在，您可以在命令行中使用 “sed” 而不必指定 GNU Sed 的路径。
