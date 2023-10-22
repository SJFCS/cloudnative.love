https://wandouduoduo.github.io/articles/22217062.html

## 安装
```
# 下载源码包
wget http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
# 解压
tar -xf inotify-tools-3.14.tar.gz
# 编译
./configure --prefix=/usr/local/inotify
# 安装
make && make install
```

```
#!/bin/bash
src=/data/                           # 需同步的源目录
des=data                             # 目标服务器上的目标目录
rsync_passwd_file=/etc/rsyncd.passwd            # rsync验证的密码文件
ip=192.168.0.18                     # 目标服务器
user=root                            # rsync --daemon定义的验证用户名
cd ${src}                            
# 此步骤是由于rsync同步的特性决定的。必须要先cd到源目录，inotify再监听 ./ 才能rsync同步后目录结构一致，有兴趣的同学可以进行各种尝试观看其效果
/usr/local/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file
# 把监控到有发生更改的"文件路径列表"循环
do
        INO_EVENT=$(echo $file | awk '{print $1}')   # 得到事件类型
        INO_FILE=$(echo $file | awk '{print $2}')    # 得到更改的文件
        echo "-------------------------------$(date)------------------------------------"
        echo $file
        #对事件增加、修改、写入完成、移入判断
        #增、改放在同一个判断，因为他们都肯定是针对文件的操作，即使是新建目录，要同步的也只是一个空目录，不会影响速度。
        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]         # 判断事件类型
        then
                echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
                rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des} 
# INO_FILE变量代表路径哦  -c校验文件内容
#仔细看 上面的rsync同步命令 源是用了$(dirname ${INO_FILE})变量 即每次只针对同步发生改变的文件的目录(只同步目标文件的方法在生产环境的某些极端
#环境下会漏文件 现在可以在不漏文件下也有不错的速度 做到平衡)
#然后用-R参数把源的目录结构递归到目标后面，保证目录结构一致性
        fi
        #删除、移出事件判断
        if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
        then
                echo 'DELETE or MOVED_FROM'
                rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des} 
#看rsync命令 如果直接同步已删除的路径${INO_FILE}会报no such or directory错误 所以这里同步的源是被删文件或目录的上一级路径
#并加上--delete来删除目标上有而源中没有的文件，这里不能做到指定文件删除，如果删除的路径越靠近根，则同步的目录月多，同步删除的操作就越花时间。
#这里有更好方法的同学，欢迎交流。
        fi
        #修改属性事件 指 touch chgrp chmod chown等操作
        if [[ $INO_EVENT =~ 'ATTRIB' ]]
        then
                echo 'ATTRIB'
                if [ ! -d "$INO_FILE" ]
# 如果修改属性的是目录 则不同步，因为同步目录会发生递归扫描，等此目录下的文件发生同步时，rsync会顺带更新此目录。
                then
                        rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des}
                fi
        fi
done
```


```
我们通过上面脚本就可以进行实时同步，但是我们因为实时同步需求和同步速度等问题，只同步了监控开启后才发生了更改的文件。但没有启动inotify监控前和期间发生更改的文件，就做不到同步。所以这里我们每2个小时做1次全量同步，来防止各种意外遗漏，保证目录的一致性。

# 写个定时任务
crontab -e

* */2 * * * rsync -avz --password-file=/etc/rsync-client.pass /data/ root@192.168.0.18::data
```