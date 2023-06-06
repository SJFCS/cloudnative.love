如何将压缩包放置到shell脚本后面
```bash
target=xxx-patch.sh
 
tar -czf ../install.tgz *
 
echo -e "\nPAYLOAD:" >> $target
cat ../install.tgz >> $target
 
rm -rf ../install.tgz
```

解压脚本 xxx-patch.sh
```bash
echo "start install patch!"
 
payload_offset=$(($(grep -na -m1 "^PAYLOAD:$" $0|cut -d':' -f1) + 1))
tail -n +$payload_offset $0 | tar zx -C / > /dev/null 2>&1
 
 
# xxxxx
# your code here
# xxxxx 
``` 


```bash
❯ echo abc > test/a.txt
tar cf test.tar test
❯ vim test.sh
#!/bin/bash
line=17
# 脚本行数+1,不能使用变量
tail -n +$line $0 > test.tar
#把整个包中的tar包生成
tar xf test.tar
exit 0
# 需要加入退出符号，不然报错
chmod +x test.sh 
cat test.sh test.tar > onetest.bin  
#把脚本和tar包输入重定向就行了
chmod +x  onetest.bin
```