用过linux shell里面的while循环的都知道，循环里面对外部变量的修改是不生效的。比如：
```bash
variable = old_value
cat file | while read line
do
     do something
     variable = new_value
done
echo $varable
```
输出将会是：old_value

解决办法：
```bash
variable = old_value
while read line
do
     do something
     variable = new_value
done < file
echo $variable
```
输出将会是：new_value
