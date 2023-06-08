日志内容：
```bash
test06 test06 test06`
2020-01-01 10:00:00
test test test test
test01 test01 test01
test02 test02 test02
chen  chen chen 
tgga ga 
2020-01-01 12:00:00
test03 test03 test04
test05 test05 test05
```
截取命令：
```bash
sed -n '/10:00:00/,/12:00:00/p' test.log
```