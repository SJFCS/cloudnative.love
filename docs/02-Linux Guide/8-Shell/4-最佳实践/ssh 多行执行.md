```bash
ssh otherhost << EOF
  ls some_folder; 
  ./someaction.sh 'some params'
  pwd
  ./some_other_action 'other params'
EOF
```
为了避免`I also get this output to my local: Pseudo-terminal will not be allocated because stdin is not a terminal.`问题，您可以（取决于您在远程站点上所做的事情）将第一行替换为
```bash
ssh otherhost /bin/bash << EOF
touch "/tmp/${NAME}"
EOF
```


1 使用分号隔开
使用 分号 ;来隔开命令

```bash
ssh User@Host 'source /etc/profile ; uptime'
```
2 使用管道符号隔开
使用管道|来隔开命令
```bash
ssh User@Host 'source /etc/profile | uptime'
```
3 使用写EOF的方式
同样适用于一条 / 多条命令
```bash
ssh User@Host << EOF
> ls -al
> source /etc/profile
> EOF
```
4 使用脚本的方式
使用脚本的方式花样就更多了，例如有一个脚本myinit.sh在/home/admin/code/下面

远程连接服务器
```bash
ssh User@Host 'bash -s' < /home/admin/code/myinit.sh
```