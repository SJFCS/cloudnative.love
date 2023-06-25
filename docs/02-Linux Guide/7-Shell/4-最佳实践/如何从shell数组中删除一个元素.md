## 根据下标删除

```bash
#!/bin/bash

array1=(a b c d a b c d)
```
我希望从上面的数组中删除第二个元素，如何删除呢？

```bash
#!/bin/bash

array1=(a b c d a b c d)
unset array1[1]

echo ${array1[*]}
```

输出结果：

```
a c d a b c d
```

## 根据元素值删除
在有些情况下，我们想删除数组中指定元素，比如删除上述数组中的b。代码如下：

```bash
!/bin/bash

array1=(a b c d a b c d)
array1=( ${array1[*]/b} )

echo ${array1[*]}
```
结果如下：

```
a c d a c d
```

## 删除包含某个字符的元素

```bash
!/bin/bash

array1=(abc bcd cdf dfg)
array1=( "${array1[@]/*b*}" )

echo ${array1[*]}
```


