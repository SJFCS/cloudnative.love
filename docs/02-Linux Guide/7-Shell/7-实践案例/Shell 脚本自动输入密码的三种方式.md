**注意，如果创建.sh文件后不可以执行，请执行sudo chmod 755 文件名.sh来修改权限。**

### **方式一**

使用 echo “密码” | （管道符）

使用场景: sudo 命令 

在使用普通用户执行 root 命令时有时候会需要输入密码，并且在输入密码后一段时间不需要再次输入（但是不影响），这时候可以使用

比如我需要一键清空服务器，则可以创建一个clear.sh文件（假使我的密码是 123456）：

```
echo "123456" | sudo rm -rf /*
```

那么在执行的时候，我只需要./clear.sh就可以清空我的整个数据库。

### **方式二**

重定向

用重定向方法实现交互的前提是指令需要有参数来指定密码输入方式，如ftp就有-i参数来指定使用标准输入来输入密码

shell用重定向作为标准输入的用法是：cmd<<delimiter ,shell 会将分界符delimiter之后直到下一个同样的分界符之前的内容作为输入

使用场景：不仅仅输入一个密码，还需要输入用户名。

```
ftp -i -n 192.168.21.46 <<EOF
user 用户名 密码
EOF
```

### **方式三**

expect  

echo + 管道符不是什么时候都可以生效（比如我写的自动提交博客脚本最后需要输入我的服务器的 git 仓库密码就不生效），因此我们可以使用 expect 方法来执行。

```
set timeout 30
spawn ssh -l 用户名 10.125.25.189
expect "password:"
send "要输入的密码"    
interact
```

这里的语句是这样的：

> 设置超时时间为30s  
> spawn 是 expect 的起始语句，可以理解为从此处开始  
> spawn 后面的语句是执行 ssh 连接  
> expect：当发现password:这个字符串后，在后方输入send后面的内容  
> send：要输入的密码  
> interact：执行完留在远程控制台，不加这句执行完后返回本地控制台

再举一个例子  
这个例子是我真实的脚本文件（但是磨掉了密码），平时用于往我的服务器中提交 hexo 博客

```
cd /Users/jim/hexo
echo '123456' | sudo -S hexo clean 
sudo hexo g 
spawn sudo -S hexo d
expect "password:"
send "123456"
```

首先进入到hexo文件夹下

因为要用到sudo 来 clean/generate/deploy我的博客，所以我这里使用一个 echo+管道符，输入一次 sudo 命令（短时间内不需要再重复输入，所以我只写了一个）

提交到远程仓库，这里需要输入远程仓库的密码，所以我用spawn标记这句话

```
当 expect（发现）到"password:"后执行send
```

将我的密码 send（发送到）到控制台  
