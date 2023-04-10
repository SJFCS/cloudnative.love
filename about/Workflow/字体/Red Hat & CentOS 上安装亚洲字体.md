 Red Hat & CentOS 上安装亚洲字体

```bash
yum grouplist
yum groupinstall "Chinese Support"
yum groupinstall Fonts
```
```
1. local -a 查询本地有的字符编码

2. 中文有些会显示乱码。可能LANG为zh_CN.utf-8。

　　1） 全局设置更改LANG:更改/etc/sysconfig/i18n的内容为：LANG="zh_CN.gb2312"

　　2） 当前会话更改LANG:export LANG=zh_CN.gb2312


1. sed 's/$/\r/' linux.txt > dos.txt　linux换行符改成dos换行符

2.  大批量删除文件 find . -name "2016*" |xargs rm -rf 

　　如果直接使用rm 2016*会报参数列表过长

17. 从根目录开始查找所有扩展名为.log的文本文件，并找出包含”ERROR”的行
　　find / -type f -name "*.log" | xargs grep "ERROR"
```


## Linux系统修改编码

```
方法1：

vi   /etc/sysconfig/i18n


修改为:

LANG="zh_CN.GBK"
SUPPORTED="zh_CN.UTF-8:zh_CN:zh"
SYSFONT="latarcyrheb-sun16"

export LC_ALL="zh_CN.GBK"
export LANG="zh_CN.GBK"
```
 
二、理解locale的设置

设定locale就是设定12大类的locale分类属性，即 12个LC_*。除了这12个变量可以设定以外，为了简便起见，还有两个变量：LC_ALL和LANG。

它们之间有一个优先级的关系：`LC_ALL > LC_* > LANG`
