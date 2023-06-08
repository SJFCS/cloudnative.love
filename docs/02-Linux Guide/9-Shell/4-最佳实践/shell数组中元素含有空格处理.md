shell数组中元素含有空格处理 

```bash
array=("I am Chinese" "Good")
```

错误用法
```bash
for item in ${array[@]}; do
    echo $item
done
结果：
I
am
Chinese
Good
```

正确用法
```bash
for item in "${array[@]}"; do
    echo $item
done

或者

for (( i = 0; i < ${#array[@]}; i++ )); do
    echo ${array[$i]}
done

结果：

I am Chinese
Good
```