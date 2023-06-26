## 1、数组冒泡（小到大）
方式一 固定数组

```bash
[root@controller-test ccx]# cat 4.sh 
#!/bin/bash
array=(1 5 8 22 13 66 341 666 4 666)

for ((i=0;i<${#array[*]}-1;i++)) ; do
        for ((j=0;j<${#array[*]}-$i-1;j++)) ; do
                if [ ${array[$j]} -gt ${array[$j+1]} ] ; then
                        swap=${array[$j]}
                        array[$j]=${array[$j+1]}
                        array[$j+1]=$swap
                fi
        done
done

echo ${array[*]}
[root@controller-test ccx]# sh 4.sh
1 4 5 8 13 22 66 341 666 666
[root@controller-test ccx]# 
```
方式二（接收用户定义数组）
```bash
[root@controller-test ccx]# cat b.sh 
#!/bin/bash
#array=(1 5 8 22 13 66 341 666 4 666)
echo  -n "read num : "
read -a array

for ((i=0;i<${#array[*]}-1;i++)) ; do
        for ((j=0;j<${#array[*]}-$i-1;j++)) ; do
                if [ ${array[$j]} -gt ${array[$j+1]} ] ; then
                        swap=${array[$j]}
                        array[$j]=${array[$j+1]}
                        array[$j+1]=$swap
                fi
        done
done

echo "maopaohou:${array[*]}"
[root@controller-test ccx]# sh b.sh 
read num : 3 1 5 777 5 666 333
maopaohou:1 3 5 5 333 666 777
[root@controller-test ccx]# 
```
## 2、求数组最大值

方式1 固定数组

```bash
[root@controller-test ccx]# cat 1.sh
#!/bin/bash

array=(1 666 3 5 7 22 33 666 12 18 20 66)

max=${array[0]}
for (( i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -gt $max ] ; then
                max=${array[$i]}
                if [ ${array[$i]} -eq $max ] ; then
                        sum=(${array[$i]})
                else
                        continue
                fi
        else
                continue
        fi
done
#echo max:$max
for a in $sum ; do
        echo max=$a
done


[root@controller-test ccx]# sh 1.sh
max=666
[root@controller-test ccx]# 
```


方式二(用户输入自定义数字)
```bash
[root@controller-test ccx]# cat a.sh 
#!/bin/bash

#array=(1 666 3 5 7 22 33 666 12 18 20 66)
echo -n 'read num :'
read -a array

max=${array[0]}
for (( i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -gt $max ] ; then
                max=${array[$i]}
                if [ ${array[$i]} -eq $max ] ; then
                        sum=(${array[$i]})
                else
                        continue
                fi
        else
                continue
        fi
done
#echo max:$max
for a in $sum ; do
        echo max=$a
done


[root@controller-test ccx]# sh a.sh 
read num :2 44 231 65 3 2 66 4 666
max=666
[root@controller-test ccx]# 
```
3、求数组的最大值和起数组下标
```bash
[root@controller-test ccx]# cat 3.sh 
#!/bin/bash

array=(1 666 3 5 7 22 33 666 12 18 20 66)

max=${array[0]}
for (( i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -gt $max ] ; then
                max=${array[$i]}
        else
                continue
        fi
done
echo max:$max
for ((i=1; i<${#array[*]} ; i++)) ; do
        if [ ${array[$i]} -eq $max ] ; then
                echo xiabiao:array[$i] = $max
        fi
done

[root@controller-test ccx]# sh 3.sh 
max:666
xiabiao:array[1] = 666
xiabiao:array[7] = 666
[root@controller-test ccx]# cat 3.sh 
#!/bin/bash

array=(1 666 3 5 7 22 33 666 12 18 20 66)

max=${array[0]}
for (( i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -gt $max ] ; then
                max=${array[$i]}
        else
                continue
        fi
done
echo max:$max
for ((i=1; i<${#array[*]} ; i++)) ; do
        if [ ${array[$i]} -eq $max ] ; then
                echo xiabiao:array[$i] = $max
        fi
done

[root@controller-test ccx]# sh 3.sh 
max:666
xiabiao:array[1] = 666
xiabiao:array[7] = 666
[root@controller-test ccx]# 
```

4、找出数组中最小值和次最小值，并打印出其对应的下标

```bash
[root@controller-test ccx]# cat 5.sh 
#!/bin/bash

array=(18 13 13 6 23 21 32 12 19 23)
#定义第一个值
min=${array[0]}
# 求出最小值
for (( i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -lt $min ] ; then
                min=${array[$i]}
        else
                continue
        fi
done
echo min:$min
#重新定义第一个值
min2=${array[0]}
#依然是求出最小值
for ((i=0; i<${#array[*]-1}; i++ )) ; do
        if [ ${array[$i]} -lt $min2 ] ; then
#如果等于之前求出的最小值，就跳过
                if [ ${array[$i]} -eq $min ] ; then
                        continue
                else
                        min2=${array[$i]}
                fi
        fi
done
echo min2=$min2

# 找出最小值的下标
for ((i=1; i<${#array[*]} ; i++)) ; do
        if [ ${array[$i]} -eq $min ] ; then
                echo 最小值下标及最小值：array[$i] = $min
        fi
done
#找出次小值的下标
for ((i=1; i<${#array[*]} ; i++)) ; do
        if [ ${array[$i]} -eq $min2 ] ; then
                echo 次小值下标及最小值：array[$i] = $min2
        fi
done
[root@controller-test ccx]# sh 5.sh 
min:6
min2=12
最小值下标及最小值：array[3] = 6
次小值下标及最小值：array[7] = 12
[root@controller-test ccx]# 
```

