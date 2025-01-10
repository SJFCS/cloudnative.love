有时候打开文件编辑完了才发现没有权限写当前文件,退出重新编辑？不用！vim里面调用外部命令写时使用sudo就可以了。

:w 命令如果不提供参数,则将当前缓冲区写到当前编辑的文件内，但是如果提供参数，比如
:w new_file 则将当前缓冲区内容写到新文件new_file中，其实:w命令有很多种形式
更进一步

:\[range\]w\[rite\] \[++opt\] !{cmd}
Execute {cmd} with \[range\] lines as standard input
上面的命令形式，将range范围内的缓冲区作为标准输入调用cmd命令。

而tee命令读取标准输入，然后将其写到文件和标准输出中,在vim中%代表当前编辑缓冲区的文件名，从而有了下面的命令：

:w !sudo tee %

还可以利用cat命令来达到同样的目的：

:w !sudo sh -c "cat > %"


## 使用 command 有几个好处：

避免别名冲突：command 确保你调用的是原始的命令，而不是可能被别名或函数重写的版本。

清晰性：它使代码更易读，明确表示你希望使用系统命令而非自定义的版本。

保持功能完整性：在某些情况下，如果你重写了一个命令的功能，使用 command 可以确保调用原始功能，而不受影响。




```bash
#!/bin/bash
# set -e          ：在命令失败时立即退出。
# set -o pipefail ：使得管道中任何命令的失败都会导致整个管道返回失败状态。
# set -u          ：在使用未定义的变量时退出，防止使用未初始化的变量。
# set -x          ：调试模式，输出每个命令及其参数，可以帮助跟踪脚本执行过程。通常在调试时使
set -e
set -o pipefail

# 测试命令
echo "Hello World" | grep "NotFound" | wc -l
echo "当 set -o pipefail 时这个消息不会显示，因为上面的命令失败了。"
```
#在这个例子中，grep "NotFound" 将不会找到任何匹配的行，因此它的返回状态是非零。由于我们使用了 set -o pipefail，整个管道的返回状态将是失败的(此行管道中的所有命令都会执行完，不会中途停下)，从而导致脚本立即退出，不会执行后面的 echo 命令。

#如果不使用 set -o pipefail，即使 grep 失败，脚本也可能会继续执行，因为 wc -l 会成功运行，从而导致脚本不及时发现错误。




## 重定向区别
区别在于sudo sh -c 'cat <<-EOF >> 1和sudo sh -c 'cat > 1 << "EOF"
是的，区别主要在于重定向和引号的使用：
cat <<-EOF >> 1：
使用 >> 是为了追加内容到文件 1。如果文件已存在，内容会被加到文件末尾。
使用 <<-EOF 时，- 选项会允许你在缩进时去掉前导空格，但依然会解析变量
cat > 1 << "EOF"：
使用 > 会覆盖文件 1 的内容。如果文件已存在，其内容会被替换。
使用 << "EOF" 确保了内容不会解析其中的变量或特殊字符，保持原样。
所以，如果你想保留内容原样并覆盖文件，使用第二种方式更合适。如果需要追加而保留原样，第一种方式则需要调整引号以避免解析
sudo sh -c 'cat >> /etc/profile << "EOF"

一个读变量一个不读变量

sudo sh -c 'cat << EOF >> /etc/profile
# Set LANG to English if in TTY, not using SSH, and no desktop environment
if [[ \$TERM = "linux" ]] && [[ -z \$SSH_TTY ]] && [[ -z \$DISPLAY ]]; then
    export LANG="en_US.utf8"
    # Default config in /etc/locale.cnf will be used otherwise
fi
EOF'

sudo sh -c 'cat >> /etc/profile << "EOF"
# Set LANG to English if in TTY, not using SSH, and no desktop environment
if [[ $TERM = "linux" ]] && [[ -z $SSH_TTY ]] && [[ -z $DISPLAY ]] && [[ "$(tty)" == "/dev/tty"* ]]; then
    export LANG="en_US.utf8"
    # Default config in /etc/locale.cnf will be used otherwise
fi
EOF'

