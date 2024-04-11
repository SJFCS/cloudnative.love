## 转义字符
有时候，我们会通过cat 的方式在终端敲入多行shell 命令到一个文件中，其中会遇到诸如“ \` ” （ESC 下边的键）或者 “$” 这两个特殊的字符。把这两个字符敲入文件，需要做转义处理。

例如，我们看到这样的一个shell 脚本。

```
vi example.txt

for  i  in `find derectory1 -type f -name "*.tgz"`
do
  gunzip -c  $i | docker load
done
```

在终端通过cat 输出上边的文件，需要这样做：

-   对特殊字符使用转义字符

```
cat > example.txt << EOF
for i in \`find docker_tar -type f -name "*.tgz" \`
do
  gunzip -c \$i |docker load
done
EOF
```

-   或者，如果对于一个文件中有多处需要转义的字符，最简单的办法就是在开始的EOF 两边加上引号就可以 ，具体如下:

```
cat > example.txt << "EOF"
for i in `find docker_tar -type f -name "*.tgz" `
do
  gunzip -c $i |docker load
done
EOF
```

## `cat <<EOF` 与 `cat <<-EOF的区别`

两个都是获取stdin,并在EOF处结束stdin，输出stdout。

但是`<<-`是什么意思呢？

先来看man中的说明：

**If the redirection operator is `<<-`, then all leading tab characters are stripped from input lines and  the  line  containing  delimiter.**

翻译过来的意思就是：如果重定向的操作符是`<<-`，那么分界符（EOF）所在行的开头部分的制表符（Tab）都将被去除。

这可以解决由于脚本中的自然缩进产生的制表符。

通俗一点的解释：

在我们使用`cat <<EOF`时，我们输入完成后，需要在一个新的一行输入EOF结束stdin的输入。EOF必须顶行写，前面不能用制表符或者空格。

比如,下面的语句就不会出错：

```
cat <<EOF
Hello,world!
EOF
```

如果结束分解符EOF前有制表符或者空格，则EOF不会被当做结束分界符，只会继续被当做stdin来输入。

而`<<-`就是为了解决这一问题：

```
cat <<-EOF
Hello,world!
      EOF
```

上面的写法，虽然最后的EOF前面有多个制表符和空格，但仍然会被当做结束分界符，表示stdin的结束。

