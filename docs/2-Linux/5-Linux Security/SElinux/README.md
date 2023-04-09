---
title: SElinux
---

```bash
semanage port -a -t http_port_t -p tcp 8080
```
参数说明：

port：管理端口相关的SELinux策略。
-a：添加新的端口策略。
-t：指定新端口的类型为 http_port_t，该类型用于标记 HTTP 通信端口。
-p：指定协议为 TCP。
8080：指定新的自定义端口。

```bash
semanage fcontext -a -t httpd_sys_content_t "/var/www/html/mysite(/.*)?"
```
参数说明：

fcontext：修改 SELinux 应用程序的文件上下文。
-a：添加新的文件上下文路径映射。
-t：指定新的上下文类型为 httpd_sys_content_t，该类型用于允许 SELinux 策略访问 Apache HTTP 服务器的默认文档根目录及其内容。
"/var/www/html/mysite(/.*)?"：指定新的文件路径，该路径必须在 "/" 前加上 "fcontext" 标签，用于标记指定路径下的所有文件和子目录。
restorecon：还原所有文件的 SELinux 上下文。
```bash
semanage permissive -a httpd_t
```
参数说明：

permissive：表示将 httpd_t 上下文标记为 permissive 模式，这将允许SELinux放宽权限规则，并在获取权限失败时仅记录日志但不终止程序的执行。
-a：添加 SELinux 策略元素。
httpd_t：httpd 是 Apache HTTP 服务器（httpd daemon）的缩写，-t 标记指定上下文类型为 httpd_t，用于表示 httpd daemon 进程。

```bash
semanage host -a -t www_home_t -s 192.168.0.10 mysite.com
```
参数说明：

host：管理 SELinux 主机映射规则。
-a：添加新的主机条目。
-t：指定主机条目类型为 www_home_t，该类型用于将 SELinux 策略的资源和主机名关联起来。
-s：指定IP地址。
192.168.0.10：新的网址映射的IP地址。
mysite.com：新的网址映射的域名。




restorecon 是一个用于还原文件或目录的 SELinux 上下文的工具。它可以将指定文件或目录的 SELinux 上下文还原回它在 SELinux 策略中定义的通常的默认值。restorecon 命令会查找与指定的文件或目录相关的 SELinux 规则，并使它们对指定的文件或目录生效。

restorecon 的一般用法是在系统修改了一个文件或创建了一个新文件后、或者迁移文件文件时使用，以确保文件的 SELinux 上下文与修改或迁移前相同，或者适合用于新的位置或磁盘。

示例命令：
```bash
sudo restorecon -Rv /var/www/html/mysite
```
该命令会递归地遍历 /var/www/html/mysite 目录及其子目录，并将其中的所有文件和目录的 SELinux 上下文恢复到策略文件中定义的默认值，其中 -R 选项表示递归操作，-v 选项表示输出操作的详细信息。





## 助记
以下是一些助记方法，可以帮助记忆一些常见的 Linux 命令：

cd：Change Directory，用于切换当前工作目录；
ls：List，用于查看当前目录的文件和目录列表；
cp：Copy，用于将文件或目录复制到目标位置；
mv：Move，用于将文件或目录移动到目标位置，也可用于重命名文件或目录；
rm：Remove，用于删除文件或目录；
mkdir：Make Directory，用于创建一个新的目录；
rmdir：Remove Directory，用于删除一个空目录；
touch：用于创建或更新文件的时间戳。
grep：Global Regular Expression Print，用于在一个或多个文件中查找符合规则的文本行；
sed：Stream Editor，用于按照指定的规则对文本进行编辑和替换；
awk：用于处理文本文件的一种工具，可以根据指定的规则对文本进行分割、筛选和格式化等操作；
tar： Tape Archive，用于打包和压缩文件和目录；
sudo：Superuser Do，用于以超级用户权限执行命令；
chown：Change Owner，用于更改文件或目录的所有者；
chmod：Change Mode，用于更改文件或目录的访问权限；
ssh：Secure SHell，用于建立加密的远程连接和执行命令；
scp：Secure CoPy，用于在不同主机之间复制文件和目录；
curl：用于在终端上下载和上传数据；
wget：Web Get，用于从 Web 上下载文件。

restorecon: Restore Context，在恢复文件或目录的 SELinux 上下文；
SELinux Context ON restore，由于单词结合起来可以形成 acronym，类似于 SCON，可以帮助您记住 restorecon；
