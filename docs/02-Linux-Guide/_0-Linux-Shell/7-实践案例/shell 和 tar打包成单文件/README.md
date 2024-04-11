```bash
#!/usr/bin/env bash

function check_md5sum {
  M=$(tail -n+`awk '/^__ARCHIVE__/ {print NR + 1; exit 0}' "$0"` "$0" | md5sum | awk '{print $1}')
  if [ "$M" != "59c0ab34a7dae73ec2dd1842d8b5f540" ]; then
    echo "Corrupted installer!" >&2
    exit 1
  fi
  echo "Installer checksum ok."
}

function install {
  #check_md5sum > /dev/null
  sudo rm -rf /tmp/docker_installer.*
  TMP=`mktemp -d /tmp/docker_installer.XXX`
  tail -n+`awk '/^__ARCHIVE__/ {print NR + 1; exit 0}' "$0"` "$0" | sudo tar xz -C $TMP
```


```bash
[root@iZ2ze1o0n0b42z scripts]#mkdir test
[root@iZ2ze1o0n0b42z scripts]#ls
test 
[root@iZ2ze1o0n0b42z scripts]#cd test/
[root@iZ2ze1o0n0b42z test]#ls
[root@iZ2ze1o0n0b42z test]#cd ../
[root@iZ2ze1o0n0b42z scripts]#echo abc > test/a.txt
[root@iZ2ze1o0n0b42z scripts]#tar cf test.tar test
[root@iZ2ze1o0n0b42z scripts]#ls
test  test.tar 
[root@iZ2ze1o0n0b42z scripts]#vim test.sh
#!/bin/bash
#
#********************************************************************
#Author:		liuhao
#QQ: 			1921160095
#Date: 			2021-02-22
#FileName：		test.sh
#Copyright (C): 	2021 All rights reserved
#********************************************************************
line=17
# 脚本行数+1,不能使用变量
tail -n +$line $0 > test.tar
#把整个包中的tar包生成
tar xf test.tar
exit 0
# 需要加入退出符号，不然报错
[root@iZ2ze1o0n0b42z scripts]#chmod +x test.sh 
[root@iZ2ze1o0n0b42z scripts]#cat test.sh test.tar > onetest.bin  
#把脚本和tar包输入重定向就行了
[root@iZ2ze1o0n0b42z scripts]#chmod +x  onetest.bin
[root@iZ2ze1o0n0b42z scripts]#mv onetest.bin /youyou/
[root@iZ2ze1o0n0b42z scripts]#cd /youyou/
[root@iZ2ze1o0n0b42z youyou]#ls
onetest.bin
[root@iZ2ze1o0n0b42z youyou]#./onetest.bin 
[root@iZ2ze1o0n0b42z youyou]#ls
onetest.bin  test  test.tar
[root@iZ2ze1o0n0b42z youyou]#cat test/a.txt 
abc

```


```bash
target=xxx-patch.sh
 
tar -czf ../install.tgz *
 
 
echo -e "\nPAYLOAD:" >> $target
cat ../install.tgz >> $target
 
echo "start install patch!"
 
payload_offset=$(($(grep -na -m1 "^PAYLOAD:$" $0|cut -d':' -f1) + 1))
tail -n +$payload_offset $0 | tar zx -C / > /dev/null 2>&1
 
 
# xxxxx
# your code here
# xxxxx 
 
exit 0
```