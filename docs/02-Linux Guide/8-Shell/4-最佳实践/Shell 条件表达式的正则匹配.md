Shell 编程中，我们可以使用双中括号运算符 `[[]]` 和 `=~` 来判断字符串是否匹配给定的正则表达式，例如匹配以 lvlv 结尾的字符串：
```bash
filelist="lvlvcheck dablelvlv checklvlv"
for file in $filelist
do 
	if [[ $file =~ lvlv$ ]]
	then
		echo $file
	fi
done
```

注意事项：`if [[ $file =~ lvlv$ ]]` 中注意有五个空格，而且正则表达式不能使用单引号或者双引号，否则会被当做普通字符串。
