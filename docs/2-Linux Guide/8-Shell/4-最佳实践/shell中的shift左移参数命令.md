shift命令用于对参数的向左移动，通常用于在不知道传入参数个数的情况下依次遍历每个参数，然后进行相应的处理（常见与Linux中各种程序的启动脚本）。在扫描处理脚本程序的参数时，经常要用到shift命令。

shift命令每执行一次，参数序列顺次左移一个位置，$#的值减1，用于分别处理每个参数，移出去的参数不再可用。

注意：$#表示脚本后跟随的参数总的个数，$n可以获取脚本后跟随的第n个参数的值。

例：加法计算
```bash
[root@youxi1 ~]# vim a.sh
#!/bin/bash
if [ $# -le 0 ] ; then
  echo "没有足够的参数"
  exit
fi
sum=0
while [ $# -gt 0 ] ; do
  sum=$[$sum+$1]
  shift
done
echo result is $sum
[root@youxi1 ~]# sh a.sh
没有足够的参数
[root@youxi1 ~]# sh a.sh 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
result is 120
```
