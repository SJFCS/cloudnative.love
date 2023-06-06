1. sed 'c' command 是替换匹配到的一整行，如果在这一行再加点别的内容，观察的更清楚些：

```bash
# cat sed.txt
|    Alias admin   |
# cat sed.txt | sed '/Alias admin/c Alias chao'
Alias chao
```

2. 'c' command 会吞掉后面的替换内容的空格，如果‘c'后面的 第一个非空格字符 是'\'，那么替换的内容是 '\'之后 的内容，如果是其他字符，则从该字符开始替换。

```bash
# cat sed.txt | sed '/Alias admin/c    Alias chao'
Alias chao
```

这里虽然 'c' 后面跟了几个空格，但是空格都被“吃掉”了，实际替换是从 ‘Alias'的 'A' 开始的。

```bash
# cat sed.txt | sed '/Alias admin/c\    Alias chao'
    Alias chao
```

3. 我们更多的会用修改命令: 's' command, 只修改匹配到的内容：

```bash
# cat sed.txt
|    Alias admin   |
# cat sed.txt | sed 's/Alias admin/Alias chao/'
|    Alias chao   |
```

综上所述可以使用下面俩格式：
```bash
sed -i '/Alias admin/c\    Alias chao' httpd.conf
sed -i 's/Alias admin/Alias chao/' httpd.conf
```