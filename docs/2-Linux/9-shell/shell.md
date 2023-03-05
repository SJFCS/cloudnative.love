What does "--" (double-dash) mean?
https://unix.stackexchange.com/questions/11376/what-does-double-dash-mean

更准确地说，在大多数 [Bash内置--命令](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)和许多其他命令中使用双破折号 ( )来表示命令选项的结束，之后仅接受位置参数。

使用示例：假设您要为字符串 grep 文件-v。通常-v将被视为反转匹配含义的选项（仅显示不匹配的行），但您可以像这样--对字符串进行 grep ：-v

grep -- -v file



rm -f -- -f
第一个-f作为 的选项rm，而第二个作为要删除的文件的名称，因为过去的所有内容--都不作为选项。