```bash
removePath = "/home/ljx/*jar"
echo removePath
sh "/bin/rm -f  ${removePath}"
执行结果

/home/ljx/*jar
/bin/rm -f  '/home/ljx/*jar'

被加了单引号，执行成功但没有生效，通配符加\转义也会被加上单引号

有时候自动生成配置是会有影响
```




```bash
grep和cur-d等命令单引号里面既使用正则，又使用变量的方法
a='{"type":"d_log", "log_format":"d_log", "exclude":"123456 "}'
key="log_format"
echo $a |grep -Po "$key" #默认只能用双引号取变量，为了使用正则，只能使用单引号了
 

echo $a |grep -Po ''"${key}"'' #就这样，里面的单引号修饰里面的双引号，实现变量的获取

curl -d ' { "'"${key}"'": "hahhaha" }'也是
```





