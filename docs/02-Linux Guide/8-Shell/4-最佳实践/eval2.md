shell变量基础 以及用变量的值作为新的变量名

https://blog.csdn.net/mydriverc2/article/details/78930881

https://unix.stackexchange.com/questions/1527/bash-eval-array-variable-name

1.eval命令将会首先扫描命令行进行所有的替换，憨厚再执行命令。该命令使用于那些一次扫描无法实现其功能的变量。该命令对变量进行两次扫描。这些需要进行两次扫描的变量有时候被称为复杂变量。

说明：
第一步: "$var"  -->name
第二步: echo '$'"$var" -->$name
第三步: `eval $name` -->yushuang

```bash

result1="r1"
result2="r2"
result3="r3"
 
for i in {1..3}
do
    result=`eval echo '$'"result$i"`
    echo $result
done
```

```bash
#!/bin/sh
vip3="vip3333"
m=3
val=`eval echo '$'vip$m`
echo $val
```