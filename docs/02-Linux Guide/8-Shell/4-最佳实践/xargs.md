假设你想要复制一个特定文件到 5 个或者更多的文件夹中，这意味着你需要输入 5 次或者更多的cp命令么？

要摆脱这个问题，你可以用 cp 命令与 echo命令、管道、xargs 命令一起使用：

```bash
echo /home/aaronkilik/test/ /home/aaronkilik/tmp | xargs -n 1 cp -v /home/aaronkilik/bin/sys_info.sh
```
上面的命令中，目录的路径（dir1、dir2、dir3...dirN）被管道作为输入到 xargs 命令中，含义是：

- -n 1 - 告诉 xargs 命令每个命令行最多使用一个参数，并发送到 cp 命令中。
- cp – 用于复制文件。
- -v – 启用详细模式来显示更多复制细节。