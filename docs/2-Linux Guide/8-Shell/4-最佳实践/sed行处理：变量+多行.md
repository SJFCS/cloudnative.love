1、变量
如果原则与被替换的字符串均为变量，常用的'需要用"
```
sed -i "s/$a/$b/g" 1.xml
```

2、追加多行
需要使用a，并用\连接
如：
```
sed -i '/keyword/a\xxx\
yyy\
zzz' 1.xml
```
3、根据关键字进行多行文本替换
```
sed -i ':a;$!{N;ba};s/StartKW.*EndKW/newStr/'
```
StartKW~EndKW可以是多行的文本，newStr如果需要多行，可以`\n`连接