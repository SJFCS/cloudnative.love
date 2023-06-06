嵌入单行的python，比如切割个字符串啥的



```bash
#!/bin/bash
function main()
{
	echo "$@" 
	# 最后那个"$@"是传递给python的参数
	result=$(python3 -c 'import sys; print(sys.argv[1].split(","))' "$@")
	echo "$result"
	exit 0
}

main "$@"
```

嵌入多行python：
```bash
#!/bin/bash
function getNum()
{
	# "$@"是传递给python的参数 python3 - 相当于从标准输入读入。
	python3 - "$@" <<END
#!/usr/bin/python3
import sys
if __name__ == "__main__":
    print(len(sys.argv[1].split(",")))
END
}

function main()
{
	echo "$@" 
	num=`getNum "$@"`
	echo "arg number : $num"
	exit 0
}

main "$@"
```
