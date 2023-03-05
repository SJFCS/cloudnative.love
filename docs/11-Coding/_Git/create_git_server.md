# CentOS7用git-daemon搭建Git服务器

[[toc]]

::: danger 危险

特别说明：使用git daemon开启启`receive-pack`服务后，任何人可以匿名访问git存储库，非常不安全，建议考虑使用gitolite项目来进行权限控制。

:::



为方便测试，我们在服务器上面使用docker 和 docker-compose来运行CentOS7容器，并在容器中运行git-daemon服务。

## 1. 准备工作

- 安装docker，并启动docker服务。
- 安装docker-compose包。

查看docker和docker-compose版本信息：

```sh
[root@hellogitlab ~]# docker --version
Docker version 20.10.12, build e91ed57
[root@hellogitlab ~]# docker-compose --version
docker-compose version 1.26.2, build unknown
[root@hellogitlab ~]#
```

## 2. 容器配置

### 2.1 编写docker-compose.yaml文件

创建文件夹`/dockerdata/gitserver`并在该文件中创建`docker-compose.yaml`文件：

```sh
# 创建gitserver目录
[root@hellogitlab ~]# mkdir -p /dockerdata/gitserver
# 创建持久化目录
[root@hellogitlab ~]# mkdir -p /dockerdata/gitserver/repos
[root@hellogitlab ~]# cd /dockerdata/gitserver
[root@hellogitlab gitserver]# touch docker-compose.yaml
```

然后使用vim编辑该文件，其内容如下：

```yaml
version: '3'
services:
  # 服务名称
  gitserver:
    # 指定容器退出后的重启策略为始终重启
    restart: always
    # 指定镜像名
    image: meizhaohui/meicentos
    # 指定容器名称
    container_name: gitserver
    # 指定容器中主机名
    hostname: gitserver.com
    # 模拟一个伪终端
    tty: true
    # 开启特权模式
    privileged: true
    # 暴露端口信息，使用宿主端口:容器端口（HOST:CONTAINER）格式
    ports:
      # git-daemon暴露端口
      - "9418:9418"
    # 数据持久化，宿主机路径:容器路径
    volumes:
      - "/dockerdata/gitserver/repos:/home/git/repos"

```

注意容器开放9418端口，9418是git-daemon服务默认端口。

### 2.2 启动容器

查看配置文件，并启动容器：

```sh
# 查看配置文件
[root@hellogitlab gitserver]# cat docker-compose.yaml
version: '3'
services:
  # 服务名称
  gitserver:
    # 指定容器退出后的重启策略为始终重启
    restart: always
    # 指定镜像名
    image: meizhaohui/meicentos
    # 指定容器名称
    container_name: gitserver
    # 指定容器中主机名
    hostname: gitserver.com
    # 模拟一个伪终端
    tty: true
    # 开启特权模式
    privileged: true
    # 暴露端口信息，使用宿主端口:容器端口（HOST:CONTAINER）格式
    ports:
      # git-daemon暴露端口
      - "9418:9418"
    # 数据持久化，宿主机路径:容器路径
    volumes:
      - "/dockerdata/gitserver/repos:/home/git/repos"

[root@hellogitlab gitserver]#

# 启动容器
[root@hellogitlab gitserver]# docker-compose -f docker-compose.yaml up -d
Creating network "gitserver_default" with the default driver
Creating gitserver ... done

# 查看容器启动状态
[root@hellogitlab gitserver]# docker-compose ps
  Name       Command    State                    Ports
------------------------------------------------------------------------
gitserver   /bin/bash   Up      0.0.0.0:9418->9418/tcp,:::9418->9418/tcp
[root@hellogitlab gitserver]#
```
可以看到，容器启动成功。



现在可以使用`docker exec`命令进入到容器中。

```sh
[root@hellogitlab ~]# docker exec -it gitserver /bin/bash
[root@gitserver /]# cd
[root@gitserver ~]# hostname
gitserver.com
[root@gitserver ~]#
```
可以看到，已经进入到容器的命令行终端了。


### 2.3 更新yum源

参考：

- centos帮助文档 https://mirrors.tuna.tsinghua.edu.cn/help/centos/
- epel帮助文档 https://mirrors.tuna.tsinghua.edu.cn/help/epel/


更新centos的源：

```sh
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
    -i.bak \
    /etc/yum.repos.d/CentOS-*.repo
```

更新epel的源：

```sh
sed -e 's!^metalink=!#metalink=!g' \
	-e 's!^#baseurl=!baseurl=!g' \
	-e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
	-e 's!//download\.example/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
	-e 's!http://mirrors!https://mirrors!g' \
	-i /etc/yum.repos.d/epel*.repo
```

更新ius的源，将以下内容写入到`/etc/yum.repos.d/ius.repo`里面：

```
[ius]
name = IUS for Enterprise Linux 7 - $basearch
#baseurl = https://repo.ius.io/7/$basearch/
baseurl = https://mirrors.tuna.tsinghua.edu.cn/ius/7//$basearch/
enabled = 1
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7

[ius-debuginfo]
name = IUS for Enterprise Linux 7 - $basearch - Debug
baseurl = https://repo.ius.io/7/$basearch/debug/
enabled = 0
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7

[ius-source]
name = IUS for Enterprise Linux 7 - Source
baseurl = https://repo.ius.io/7/src/
enabled = 0
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7
```



将centos和epel源更新的执行过程：

```sh
[root@gitserver /]# cd
[root@gitserver ~]# sed -e 's!^metalink=!#metalink=!g' \
> -e 's!^#baseurl=!baseurl=!g' \
> -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
> -e 's!//download\.example/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
> -e 's!http://mirrors!https://mirrors!g' \
> -i /etc/yum.repos.d/epel*.repo
[root@gitserver ~]# sed -e 's|^mirrorlist=|#mirrorlist=|g' \
>     -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
>     -i.bak \
>     /etc/yum.repos.d/CentOS-*.repo
[root@gitserver ~]#
```

并使用vim编辑`/etc/yum.repos.d/ius.repo`的内容，编辑完成后查看文件：

```sh
[root@gitserver ~]# cat /etc/yum.repos.d/ius.repo
[ius]
name = IUS for Enterprise Linux 7 - $basearch
#baseurl = https://repo.ius.io/7/$basearch/
baseurl = https://mirrors.tuna.tsinghua.edu.cn/ius/7//$basearch/
enabled = 1
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7

[ius-debuginfo]
name = IUS for Enterprise Linux 7 - $basearch - Debug
baseurl = https://repo.ius.io/7/$basearch/debug/
enabled = 0
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7

[ius-source]
name = IUS for Enterprise Linux 7 - Source
baseurl = https://repo.ius.io/7/src/
enabled = 0
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7
[root@gitserver ~]#
```

更新yum缓存：

```sh
[root@gitserver ~]# yum makecache fast
```

### 2.4 防火墙配置

我们git服务需要使用`9418`端口，我们将该端口加入到防火墙放行列表中。

可以在`~/.bashrc`中增加以下内容，增加防火墙添加端口的快捷命令：

```sh
#################################################
# Add/Delete a new port a for firewall zone
# 防火墙端口放行和移除
# -----------------------------------------------
alias afp='add_firewall_port'
# 增加防火墙放行端口号
function add_firewall_port() {
    port=$1
    check_port=$(firewall-cmd --list-all|grep "${port}"|wc -l)
    if [[ "${check_port}" -eq 0 ]]; then
        firewall-cmd --permanent --add-port="${port}/tcp"
        firewall-cmd --reload
        firewall-cmd --list-all
        firewall-cmd --list-all|grep "${port}"
    fi
}
```

然后使用`source ~/.bashrc`使命令生效。



放行端口`9418`:

```sh
[root@hellogitlab ~]# afp 9418
You're performing an operation over default zone ('public'),
but your connections/interfaces are in zone 'docker' (see --get-active-zones)
You most likely need to use --zone=docker option.

success
success
You're performing an operation over default zone ('public'),
but your connections/interfaces are in zone 'docker' (see --get-active-zones)
You most likely need to use --zone=docker option.
# 注意，此处的警告信息不用理会

public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: ssh dhcpv6-client
  ports: 9418/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

  ports: 9418/tcp
[root@hellogitlab ~]#
```

可以看到防火墙已经放行9418端口。



重启防火墙后，重启一下docker服务：

```sh
[root@hellogitlab ~]# systemctl restart docker
```





## 3. git服务器配置

### 3.1 升级git版本

查看当前git版本：

```sh
[root@gitserver ~]# git --version
git version 1.8.3.1
[root@gitserver ~]#
```

可以看到，版本比较低。我们可以升级一下git版本。

卸载旧的git包：

```sh
[root@gitserver ~]# yum remove git -y
Loaded plugins: fastestmirror, ovl
Resolving Dependencies
--> Running transaction check
---> Package git.x86_64 0:1.8.3.1-20.el7 will be erased
--> Processing Dependency: git = 1.8.3.1-20.el7 for package: perl-Git-1.8.3.1-20.el7.noarch
--> Running transaction check
---> Package perl-Git.noarch 0:1.8.3.1-20.el7 will be erased
--> Finished Dependency Resolution

Dependencies Resolved

========================================================================================================================
 Package                    Arch                     Version                           Repository                  Size
========================================================================================================================
Removing:
 git                        x86_64                   1.8.3.1-20.el7                    @updates                    22 M
Removing for dependencies:
 perl-Git                   noarch                   1.8.3.1-20.el7                    @updates                    57 k

Transaction Summary
========================================================================================================================
Remove  1 Package (+1 Dependent package)

Installed size: 22 M
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Erasing    : git-1.8.3.1-20.el7.x86_64                                                                            1/2
  Erasing    : perl-Git-1.8.3.1-20.el7.noarch                                                                       2/2
  Verifying  : perl-Git-1.8.3.1-20.el7.noarch                                                                       1/2
  Verifying  : git-1.8.3.1-20.el7.x86_64                                                                            2/2

Removed:
  git.x86_64 0:1.8.3.1-20.el7

Dependency Removed:
  perl-Git.noarch 0:1.8.3.1-20.el7

Complete!
[root@gitserver ~]#
```

我们可以通过安装`git224-all`来安装新版本的git包：

```sh
# 搜索git2u相关的包
[root@gitserver ~]# yum search git224
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ftp.sjtu.edu.cn
 * epel: mirror.sjtu.edu.cn
 * extras: ftp.sjtu.edu.cn
 * updates: ftp.sjtu.edu.cn
================================================= N/S matched: git224 ==================================================
git224.x86_64 : Fast Version Control System
git224-all.noarch : Meta-package to pull in all git tools
git224-core.x86_64 : Core package of git with minimal functionality
git224-core-doc.noarch : Documentation files for git-core
git224-cvs.noarch : Git tools for importing CVS repositories
git224-daemon.x86_64 : Git protocol daemon
git224-email.noarch : Git tools for sending patches via email
git224-gitk.noarch : Git repository browser
git224-gitweb.noarch : Simple web interface to git repositories
git224-gui.noarch : Graphical interface to Git
git224-instaweb.noarch : Repository browser in gitweb
git224-p4.noarch : Git tools for working with Perforce depots
git224-perl-Git.noarch : Perl interface to Git
git224-perl-Git-SVN.noarch : Perl interface to Git::SVN
git224-subtree.x86_64 : Git tools to merge and split repositories
git224-svn.noarch : Git tools for interacting with Subversion repositories

  Name and summary matches only, use "search all" for everything.
[root@gitserver ~]#

# 查看git224-all的信息
[root@gitserver ~]# yum info  git224-all
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ftp.sjtu.edu.cn
 * epel: mirror.sjtu.edu.cn
 * extras: ftp.sjtu.edu.cn
 * updates: ftp.sjtu.edu.cn
Available Packages
Name        : git224-all
Arch        : noarch
Version     : 2.24.4
Release     : 1.el7.ius
Size        : 19 k
Repo        : ius/x86_64
Summary     : Meta-package to pull in all git tools
URL         : https://git-scm.com/
License     : GPLv2
Description : Git is a fast, scalable, distributed revision control system with an
            : unusually rich command set that provides both high-level operations
            : and full access to internals.
            :
            : This is a dummy package which brings in all subpackages.

[root@gitserver ~]#
```

安装包：

```sh
[root@gitserver ~]# yum install git224-all git224-daemon -y
....中间安装日志省略
Installed:
  git224-all.noarch 0:2.24.4-1.el7.ius                      git224-daemon.x86_64 0:2.24.4-1.el7.ius

Dependency Installed:
  cvs.x86_64 0:1.11.23-35.el7                                 cvsps.x86_64 0:2.2-0.14.b1.el7
  dejavu-fonts-common.noarch 0:2.33-6.el7                     dejavu-sans-fonts.noarch 0:2.33-6.el7
  emacs-filesystem.noarch 1:24.3-23.el7                       fontconfig.x86_64 0:2.13.0-4.3.el7
  fontpackages-filesystem.noarch 0:1.44-8.el7                 freetype.x86_64 0:2.8-14.el7_9.1
  gamin.x86_64 0:0.1.10-16.el7                                git224.x86_64 0:2.24.4-1.el7.ius
  git224-core.x86_64 0:2.24.4-1.el7.ius                       git224-core-doc.noarch 0:2.24.4-1.el7.ius
  git224-cvs.noarch 0:2.24.4-1.el7.ius                        git224-email.noarch 0:2.24.4-1.el7.ius
  git224-gitk.noarch 0:2.24.4-1.el7.ius                       git224-gitweb.noarch 0:2.24.4-1.el7.ius
  git224-gui.noarch 0:2.24.4-1.el7.ius                        git224-instaweb.noarch 0:2.24.4-1.el7.ius
  git224-p4.noarch 0:2.24.4-1.el7.ius                         git224-perl-Git.noarch 0:2.24.4-1.el7.ius
  git224-perl-Git-SVN.noarch 0:2.24.4-1.el7.ius               git224-subtree.x86_64 0:2.24.4-1.el7.ius
  git224-svn.noarch 0:2.24.4-1.el7.ius                        gnutls.x86_64 0:3.3.29-9.el7_6
  libX11.x86_64 0:1.6.7-4.el7_9                               libX11-common.noarch 0:1.6.7-4.el7_9
  libXau.x86_64 0:1.0.8-2.1.el7                               libXft.x86_64 0:2.3.2-2.el7
  libXrender.x86_64 0:0.9.10-1.el7                            libmodman.x86_64 0:2.0.1-8.el7
  libpng.x86_64 2:1.5.13-8.el7                                libproxy.x86_64 0:0.4.11-11.el7
  libsecret.x86_64 0:0.18.6-1.el7                             libxcb.x86_64 0:1.13-1.el7
  lighttpd.x86_64 0:1.4.54-1.el7                              neon.x86_64 0:0.30.0-4.el7
  nettle.x86_64 0:2.7.1-9.el7_9                               openssl.x86_64 1:1.0.2k-24.el7_9
  pakchois.x86_64 0:0.4-10.el7                                pcre2.x86_64 0:10.23-2.el7
  perl-Authen-SASL.noarch 0:2.15-10.el7                       perl-CGI.noarch 0:3.63-4.el7
  perl-Compress-Raw-Bzip2.x86_64 0:2.061-3.el7                perl-Compress-Raw-Zlib.x86_64 1:2.061-4.el7
  perl-DBD-SQLite.x86_64 0:1.39-3.el7                         perl-DBI.x86_64 0:1.627-4.el7
  perl-Digest.noarch 0:1.17-245.el7                           perl-Digest-HMAC.noarch 0:1.03-5.el7
  perl-Digest-MD5.x86_64 0:2.52-3.el7                         perl-Digest-SHA.x86_64 1:5.85-4.el7
  perl-FCGI.x86_64 1:0.74-8.el7                               perl-GSSAPI.x86_64 0:0.28-9.el7
  perl-IO-Compress.noarch 0:2.061-2.el7                       perl-IO-Socket-IP.noarch 0:0.21-5.el7
  perl-IO-Socket-SSL.noarch 0:1.94-7.el7                      perl-MailTools.noarch 0:2.12-2.el7
  perl-Mozilla-CA.noarch 0:20130114-5.el7                     perl-Net-Daemon.noarch 0:0.48-5.el7
  perl-Net-LibIDN.x86_64 0:0.12-15.el7                        perl-Net-SMTP-SSL.noarch 0:1.01-13.el7
  perl-Net-SSLeay.x86_64 0:1.55-6.el7                         perl-PlRPC.noarch 0:0.2020-14.el7
  perl-TimeDate.noarch 1:2.30-2.el7                           perl-YAML.noarch 0:0.84-5.el7
  psmisc.x86_64 0:22.20-17.el7                                subversion.x86_64 0:1.7.14-16.el7
  subversion-libs.x86_64 0:1.7.14-16.el7                      subversion-perl.x86_64 0:1.7.14-16.el7
  systemd-sysv.x86_64 0:219-78.el7_9.5                        tcl.x86_64 1:8.5.13-8.el7
  tk.x86_64 1:8.5.13-6.el7                                    trousers.x86_64 0:0.3.14-2.el7

Dependency Updated:
  openssl-devel.x86_64 1:1.0.2k-24.el7_9    openssl-libs.x86_64 1:1.0.2k-24.el7_9    systemd.x86_64 0:219-78.el7_9.5
  systemd-libs.x86_64 0:219-78.el7_9.5

Complete!
[root@gitserver ~]# echo $?
0
[root@gitserver ~]#
```

查看git224相关的包，并查看git版本信息：

```sh
[root@gitserver ~]# rpm -qa|grep git224
git224-core-2.24.4-1.el7.ius.x86_64
git224-subtree-2.24.4-1.el7.ius.x86_64
git224-perl-Git-2.24.4-1.el7.ius.noarch
git224-email-2.24.4-1.el7.ius.noarch
git224-p4-2.24.4-1.el7.ius.noarch
git224-perl-Git-SVN-2.24.4-1.el7.ius.noarch
git224-gitk-2.24.4-1.el7.ius.noarch
git224-all-2.24.4-1.el7.ius.noarch
git224-core-doc-2.24.4-1.el7.ius.noarch
git224-2.24.4-1.el7.ius.x86_64
git224-gitweb-2.24.4-1.el7.ius.noarch
git224-cvs-2.24.4-1.el7.ius.noarch
git224-instaweb-2.24.4-1.el7.ius.noarch
git224-svn-2.24.4-1.el7.ius.noarch
git224-gui-2.24.4-1.el7.ius.noarch
git224-daemon-2.24.4-1.el7.ius.x86_64
[root@gitserver ~]# git --version
git version 2.24.4
[root@gitserver ~]#
```

可以看到git已经成功升级到2.24.4版本。

### 3.2 创建git用户及其家目录

创建`git`用户，用于运行Git服务:

```sh
# 注意，此处因为我们配置了容器持久化挂载，目录已经自动创建，忽略警告⚠️即可
[root@gitserver ~]# useradd git
useradd: warning: the home directory already exists.
Not copying any file from skel directory into it.
[root@gitserver ~]# grep 'git' /etc/passwd
git:x:1000:1000::/home/git:/bin/bash
[root@gitserver ~]# ls -lah /home/git/
total 12K
drwxr-xr-x 3 root root 4.0K Mar 13 16:22 .
drwxr-xr-x 1 root root 4.0K Mar 13 16:22 ..
drwxr-xr-x 2 root root 4.0K Mar 13 16:15 repos
```

修改路径`/home/git`权限：

```sh
[root@gitserver ~]# chown -R git:git /home/git
[root@gitserver ~]# ls -lah /home/git/
total 12K
drwxr-xr-x 3 git  git  4.0K Mar 13 16:22 .
drwxr-xr-x 1 root root 4.0K Mar 13 16:22 ..
drwxr-xr-x 2 git  git  4.0K Mar 13 16:15 repos
```

为了便于后面测试克隆我们git服务器上面的存储库，我们在`repos`目录中创建一个测试用的祼版本库：

```sh
# 创建祼版本库gitserver.git
[root@gitserver ~]# git init --bare /home/git/repos/gitserver.git
Initialized empty Git repository in /home/git/repos/gitserver.git/
[root@gitserver ~]# ls -lah /home/git/repos/
total 12K
drwxr-xr-x 3 git  git  4.0K Mar 13 16:56 .
drwxr-xr-x 3 git  git  4.0K Mar 13 16:22 ..
drwxr-xr-x 7 root root 4.0K Mar 13 16:56 gitserver.git

# 修改文件夹权限
[root@gitserver ~]# chown -R git:git /home/git/repos/gitserver.git/
[root@gitserver ~]# ls -lah /home/git/repos/gitserver.git/
total 40K
drwxr-xr-x 7 git git 4.0K Mar 13 16:56 .
drwxr-xr-x 3 git git 4.0K Mar 13 16:56 ..
drwxr-xr-x 2 git git 4.0K Mar 13 16:56 branches
-rw-r--r-- 1 git git   66 Mar 13 16:56 config
-rw-r--r-- 1 git git   73 Mar 13 16:56 description
-rw-r--r-- 1 git git   23 Mar 13 16:56 HEAD
drwxr-xr-x 2 git git 4.0K Mar 13 16:56 hooks
drwxr-xr-x 2 git git 4.0K Mar 13 16:56 info
drwxr-xr-x 4 git git 4.0K Mar 13 16:56 objects
drwxr-xr-x 4 git git 4.0K Mar 13 16:56 refs
[root@gitserver ~]#
```

### 3.3 启动git daemon服务

启动git daemon服务：

```sh
[root@gitserver ~]# git daemon --verbose --export-all --user=git  --base-path=/home/git/repos /home/git/repos
[437] Ready to rumble
```

可以可以看到进入交互显示模式：

```sh
[437] Ready to rumble
```

此处的`437`表示`git daemon`服务的进程ID。



重新打开一个命令行终端，进入到容器中：

```sh
[root@hellogitlab ~]# docker exec -it gitserver /bin/bash
[root@gitserver /]# cd
[root@gitserver ~]# ps -ef|grep git
root       436    42  0 16:58 pts/1    00:00:00 git daemon --verbose --export-all --user=git --base-path=/home/git/repos /home/git/repos
git        437   436  0 16:58 pts/1    00:00:00 /usr/libexec/git-core/git-daemon --verbose --export-all --user=git --base-path=/home/git/repos /home/git/repos
root       458   438  0 16:59 pts/2    00:00:00 grep --color=auto git
[root@gitserver ~]# netstat -tunlp|grep git
tcp        0      0 0.0.0.0:9418            0.0.0.0:*               LISTEN      437/git-daemon
tcp6       0      0 :::9418                 :::*                    LISTEN      437/git-daemon
[root@gitserver ~]#
```

可以看到，git-daemon服务已经在运行。



### 3.4 远程克隆与提交

在宿主机上面尝试克隆：

```sh
[meizhaohui@hellogitlab ~]$ git clone git://hellogitlab.com/gitserver.git
Cloning into 'gitserver'...
warning: You appear to have cloned an empty repository.
[meizhaohui@hellogitlab ~]$
```

可以看到，克隆成功！！



这时候在服务器的终端上就会显示一些被客户端连接的信息，我们可以根据这些信息来判断是否读取成功：

```sh
[437] Ready to rumble
[461] Connection from 106.54.98.83:57870
[461] Extended attribute "host": hellogitlab.com
[461] Request upload-pack for '/gitserver.git'
[437] [461] Disconnected
```

如下图所示：




使用自己的电脑尝试克隆下载：

```sh
[mzh@MacBookPro ~ ]$ git clone git://hellogitlab.com/gitserver.git
Cloning into 'gitserver'...
warning: You appear to have cloned an empty repository.
```

![](/img/20220313170701.png)

此时，可以看到服务器终端也有日志信息更新，说明我们配置的git服务是正常的。



现在可以看到，已经在自己的电脑上面克隆了一个空的存储库副本，我们尝试提交文件看看能不能提交成功。

```sh
[mzh@MacBookPro ~ ]$ cd gitserver
[mzh@MacBookPro gitserver (master)]$ ls
[mzh@MacBookPro gitserver (master)]$ git remote -v
origin	git://hellogitlab.com/gitserver.git (fetch)
origin	git://hellogitlab.com/gitserver.git (push)
[mzh@MacBookPro gitserver (master)]$ echo 'test git push' > test.txt
[mzh@MacBookPro gitserver (master ✗)]$ git add test.txt
[mzh@MacBookPro gitserver (master ✗)]$ git commit -m"test git push"
[master (root-commit) 2d2c515] test git push
 1 file changed, 1 insertion(+)
 create mode 100644 test.txt
 [mzh@MacBookPro gitserver (master)]$ git push origin master
fatal: remote error: access denied or repository not exported: /gitserver.git
```

此时，可以看到，提交失败，看看服务器端日志，发现有更新日志。

![](/img/20220313175350.png)

提示`'receive-pack': service not enabled for '/home/git/repos/gitserver.git'`，即远程仓库没有开启`receive-pack`服务。

因此，我们在启动git daemon服务时，需要开启`receive-pack`服务。



### 3.5 开启远程提交功能

上一节我们知道想提交修改到git服务器，需要在git服务器端开启`receive-pack`服务。

我们看一下`git daemon`的帮助信息：

```sh
[root@hellogitlab ~]# git daemon --help|awk NF
GIT-DAEMON(1)                                         Git Manual                                        GIT-DAEMON(1)
NAME
       git-daemon - A really simple server for Git repositories
SYNOPSIS
       git daemon [--verbose] [--syslog] [--export-all]
                    [--timeout=<n>] [--init-timeout=<n>] [--max-connections=<n>]
                    [--strict-paths] [--base-path=<path>] [--base-path-relaxed]
                    [--user-path | --user-path=<path>]
                    [--interpolated-path=<pathtemplate>]
                    [--reuseaddr] [--detach] [--pid-file=<file>]
                    [--enable=<service>] [--disable=<service>]
                    [--allow-override=<service>] [--forbid-override=<service>]
                    [--access-hook=<path>] [--[no-]informative-errors]
                    [--inetd |
                     [--listen=<host_or_ipaddr>] [--port=<n>]
                     [--user=<user> [--group=<group>]]]
                    [--log-destination=(stderr|syslog|none)]
                    [<directory>...]
DESCRIPTION
       A really simple TCP Git daemon that normally listens on port "DEFAULT_GIT_PORT" aka 9418. It waits for a
       connection asking for a service, and will serve that service if it is enabled.
       It verifies that the directory has the magic file "git-daemon-export-ok", and it will refuse to export any Git
       directory that hasn’t explicitly been marked for export this way (unless the --export-all parameter is
       specified). If you pass some directory paths as git daemon arguments, you can further restrict the offers to a
       whitelist comprising of those.
       By default, only upload-pack service is enabled, which serves git fetch-pack and git ls-remote clients, which
       are invoked from git fetch, git pull, and git clone.
       This is ideally suited for read-only updates, i.e., pulling from Git repositories.
       An upload-archive also exists to serve git archive.
OPTIONS
       --strict-paths
           Match paths exactly (i.e. don’t allow "/foo/repo" when the real path is "/foo/repo.git" or
           "/foo/repo/.git") and don’t do user-relative paths.  git daemon will refuse to start when this option is
           enabled and no whitelist is specified.
       --base-path=<path>
           Remap all the path requests as relative to the given path. This is sort of "Git root" - if you run git
           daemon with --base-path=/srv/git on example.com, then if you later try to pull
           git://example.com/hello.git, git daemon will interpret the path as /srv/git/hello.git.
       --base-path-relaxed
           If --base-path is enabled and repo lookup fails, with this option git daemon will attempt to lookup
           without prefixing the base path. This is useful for switching to --base-path usage, while still allowing
           the old paths.
       --interpolated-path=<pathtemplate>
           To support virtual hosting, an interpolated path template can be used to dynamically construct alternate
           paths. The template supports %H for the target hostname as supplied by the client but converted to all
           lowercase, %CH for the canonical hostname, %IP for the server’s IP address, %P for the port number, and %D
           for the absolute path of the named repository. After interpolation, the path is validated against the
           directory whitelist.
       --export-all
           Allow pulling from all directories that look like Git repositories (have the objects and refs
           subdirectories), even if they do not have the git-daemon-export-ok file.
       --inetd
           Have the server run as an inetd service. Implies --syslog (may be overridden with --log-destination=).
           Incompatible with --detach, --port, --listen, --user and --group options.
       --listen=<host_or_ipaddr>
           Listen on a specific IP address or hostname. IP addresses can be either an IPv4 address or an IPv6 address
           if supported. If IPv6 is not supported, then --listen=hostname is also not supported and --listen must be
           given an IPv4 address. Can be given more than once. Incompatible with --inetd option.
       --port=<n>
           Listen on an alternative port. Incompatible with --inetd option.
       --init-timeout=<n>
           Timeout (in seconds) between the moment the connection is established and the client request is received
           (typically a rather low value, since that should be basically immediate).
       --timeout=<n>
           Timeout (in seconds) for specific client sub-requests. This includes the time it takes for the server to
           process the sub-request and the time spent waiting for the next client’s request.
       --max-connections=<n>
           Maximum number of concurrent clients, defaults to 32. Set it to zero for no limit.
       --syslog
           Short for --log-destination=syslog.
       --log-destination=<destination>
           Send log messages to the specified destination. Note that this option does not imply --verbose, thus by
           default only error conditions will be logged. The <destination> must be one of:
           stderr
               Write to standard error. Note that if --detach is specified, the process disconnects from the real
               standard error, making this destination effectively equivalent to none.
           syslog
               Write to syslog, using the git-daemon identifier.
           none
               Disable all logging.
           The default destination is syslog if --inetd or --detach is specified, otherwise stderr.
       --user-path, --user-path=<path>
           Allow ~user notation to be used in requests. When specified with no parameter, requests to
           git://host/~alice/foo is taken as a request to access foo repository in the home directory of user alice.
           If --user-path=path is specified, the same request is taken as a request to access path/foo repository in
           the home directory of user alice.
       --verbose
           Log details about the incoming connections and requested files.
       --reuseaddr
           Use SO_REUSEADDR when binding the listening socket. This allows the server to restart without waiting for
           old connections to time out.
       --detach
           Detach from the shell. Implies --syslog.
       --pid-file=<file>
           Save the process id in file. Ignored when the daemon is run under --inetd.
       --user=<user>, --group=<group>
           Change daemon’s uid and gid before entering the service loop. When only --user is given without --group,
           the primary group ID for the user is used. The values of the option are given to getpwnam(3) and
           getgrnam(3) and numeric IDs are not supported.
           Giving these options is an error when used with --inetd; use the facility of inet daemon to achieve the
           same before spawning git daemon if needed.
           Like many programs that switch user id, the daemon does not reset environment variables such as $HOME when
           it runs git programs, e.g.  upload-pack and receive-pack. When using this option, you may also want to set
           and export HOME to point at the home directory of <user> before starting the daemon, and make sure any Git
           configuration files in that directory are readable by <user>.
       --enable=<service>, --disable=<service>
           Enable/disable the service site-wide per default. Note that a service disabled site-wide can still be
           enabled per repository if it is marked overridable and the repository enables the service with a
           configuration item.
       --allow-override=<service>, --forbid-override=<service>
           Allow/forbid overriding the site-wide default with per repository configuration. By default, all the
           services may be overridden.
       --[no-]informative-errors
           When informative errors are turned on, git-daemon will report more verbose errors to the client,
           differentiating conditions like "no such repository" from "repository not exported". This is more
           convenient for clients, but may leak information about the existence of unexported repositories. When
           informative errors are not enabled, all errors report "access denied" to the client. The default is
           --no-informative-errors.
       --access-hook=<path>
           Every time a client connects, first run an external command specified by the <path> with service name
           (e.g. "upload-pack"), path to the repository, hostname (%H), canonical hostname (%CH), IP address (%IP),
           and TCP port (%P) as its command-line arguments. The external command can decide to decline the service by
           exiting with a non-zero status (or to allow it by exiting with a zero status). It can also look at the
           $REMOTE_ADDR and $REMOTE_PORT environment variables to learn about the requestor when making this
           decision.
           The external command can optionally write a single line to its standard output to be sent to the requestor
           as an error message when it declines the service.
       <directory>
           A directory to add to the whitelist of allowed directories. Unless --strict-paths is specified this will
           also include subdirectories of each named directory.
SERVICES
       These services can be globally enabled/disabled using the command-line options of this command. If
       finer-grained control is desired (e.g. to allow git archive to be run against only in a few selected
       repositories the daemon serves), the per-repository configuration file can be used to enable or disable them.
       upload-pack
           This serves git fetch-pack and git ls-remote clients. It is enabled by default, but a repository can
           disable it by setting daemon.uploadpack configuration item to false.
       upload-archive
           This serves git archive --remote. It is disabled by default, but a repository can enable it by setting
           daemon.uploadarch configuration item to true.
       receive-pack
           This serves git send-pack clients, allowing anonymous push. It is disabled by default, as there is no
           authentication in the protocol (in other words, anybody can push anything into the repository, including
           removal of refs). This is solely meant for a closed LAN setting where everybody is friendly. This service
           can be enabled by setting daemon.receivepack configuration item to true.
EXAMPLES
       We assume the following in /etc/services
               $ grep 9418 /etc/services
               git             9418/tcp                # Git Version Control System
       git daemon as inetd server
           To set up git daemon as an inetd service that handles any repository under the whitelisted set of
           directories, /pub/foo and /pub/bar, place an entry like the following into /etc/inetd all on one line:
                       git stream tcp nowait nobody  /usr/bin/git
                               git daemon --inetd --verbose --export-all
                               /pub/foo /pub/bar
       git daemon as inetd server for virtual hosts
           To set up git daemon as an inetd service that handles repositories for different virtual hosts,
           www.example.com and www.example.org, place an entry like the following into /etc/inetd all on one line:
                       git stream tcp nowait nobody /usr/bin/git
                               git daemon --inetd --verbose --export-all
                               --interpolated-path=/pub/%H%D
                               /pub/www.example.org/software
                               /pub/www.example.com/software
                               /software
           In this example, the root-level directory /pub will contain a subdirectory for each virtual host name
           supported. Further, both hosts advertise repositories simply as git://www.example.com/software/repo.git.
           For pre-1.4.0 clients, a symlink from /software into the appropriate default repository could be made as
           well.
       git daemon as regular daemon for virtual hosts
           To set up git daemon as a regular, non-inetd service that handles repositories for multiple virtual hosts
           based on their IP addresses, start the daemon like this:
                       git daemon --verbose --export-all
                               --interpolated-path=/pub/%IP/%D
                               /pub/192.168.1.200/software
                               /pub/10.10.220.23/software
           In this example, the root-level directory /pub will contain a subdirectory for each virtual host IP
           address supported. Repositories can still be accessed by hostname though, assuming they correspond to
           these IP addresses.
       selectively enable/disable services per repository
           To enable git archive --remote and disable git fetch against a repository, have the following in the
           configuration file in the repository (that is the file config next to HEAD, refs and objects).
                       [daemon]
                               uploadpack = false
                               uploadarch = true
ENVIRONMENT
       git daemon will set REMOTE_ADDR to the IP address of the client that connected to it, if the IP address is
       available. REMOTE_ADDR will be available in the environment of hooks called when services are performed.
GIT
       Part of the git(1) suite
Git 2.24.4                                            03/11/2021                                        GIT-DAEMON(1)
[root@hellogitlab ~]#
```

我们停止掉之前的进程，重新运行一下`git daemon`服务，并且增加`--enable=receive-pack`选项：

```sh
[root@gitserver ~]# git daemon --verbose --export-all --enable=receive-pack --user=git --base-path=/home/git/repos /home/git/repos
[63] Ready to rumble
```

然后尝试在本地电脑再执行一次`git push origin master`命令：

```sh
[mzh@MacBookPro gitserver (master)]$ git push origin master
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 231 bytes | 231.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To git://hellogitlab.com/gitserver.git
 * [new branch]      master -> master
 
[mzh@MacBookPro gitserver (master)]$ git log -n 1|awk NF
commit 2d2c515e2262318d1f03082293478290f7c03be2
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 13 17:49:58 2022 +0800
    test git push
```



可以看到，提交成功了！

此时去容器中检查一下：

```sh
[root@gitserver /]# cd /home/git/repos/gitserver.git/
[root@gitserver gitserver.git]# ls
branches  config  description  HEAD  hooks  info  objects  refs
[root@gitserver gitserver.git]# git log
commit 2d2c515e2262318d1f03082293478290f7c03be2 (HEAD -> master)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 13 17:49:58 2022 +0800

    test git push
[root@gitserver gitserver.git]#
```

可以看到，服务器端已经获取到了客户端提交的记录了。说明我们的提交正常。



但这个时候，我们可以看到，我们没有添加任何自己的公钥信息到git服务器上面，我们直接匿名就提交成功了。由`git daemon`的帮助信息，我们知道`receive-pack`服务默认是关闭的，当开启该服务时，git服务器则允许匿名推送！此时任何人都可以将任何内容推送到存储库中，包括删除引用等，这仅适用于每个人都很友善的封闭局域网环境，但如果我们在公网上提供git服务的话，则不应开启该服务。



因此，我们移除`--enable=receive-pack`选项，重新运行`git daemon`服务。

```sh
[root@gitserver ~]# git daemon --verbose --export-all --user=git --base-path=/home/git/repos /home/git/repos
[102] Ready to rumble
```

![](/img/20220313223752.png)



尝试在本地修改文件，并进行提交，如上节所示，会提交失败：

```sh
[mzh@MacBookPro gitserver (master)]$ cat test.txt
test git push
[mzh@MacBookPro gitserver (master)]$ echo 'test disable receive-pack service' >> test.txt
[mzh@MacBookPro gitserver (master ✗)]$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
[mzh@MacBookPro gitserver (master ✗)]$ git add test.txt
[mzh@MacBookPro gitserver (master ✗)]$ git commit -m"test disable receive-pack service"
[master a4cda34] test disable receive-pack service
 1 file changed, 1 insertion(+)
[mzh@MacBookPro gitserver (master)]$ git push origin master
fatal: remote error: access denied or repository not exported: /gitserver.git
[mzh@MacBookPro gitserver (master)]$
```

可以看到，没能提交成功，我们尝试将自己的公钥信息复制到git服务器，并再次进行提交。



- 在容器中创建`git`的公钥和密钥。

```sh
[root@gitserver ~]# su - git
Last login: Sun Mar 13 22:46:00 CST 2022 on pts/2
-bash-4.2$ pwd
/home/git
-bash-4.2$ ssh-keygen -C git@gitserver
Generating public/private rsa key pair.
Enter file in which to save the key (/home/git/.ssh/id_rsa):
Created directory '/home/git/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/git/.ssh/id_rsa.
Your public key has been saved in /home/git/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:S1+dPjenmjjXhgHc5hYTZvb1vmFJBEGJs/nxfPzgr6g git@gitserver
The key's randomart image is:
+---[RSA 2048]----+
|            +++  |
|           +=o ..|
|         ..=oo=o.|
|          o.=oo=+|
|        S  +.++o+|
|       . o .+..+o|
|        . .. ++o=|
|          ..o+o=+|
|          .oEoo. |
+----[SHA256]-----+
-bash-4.2$ ls -lah .ssh
total 16K
drwx------ 2 git git 4.0K Mar 13 22:46 .
drwxr-xr-x 4 git git 4.0K Mar 13 22:46 ..
-rw------- 1 git git 1.7K Mar 13 22:46 id_rsa
-rw-r--r-- 1 git git  395 Mar 13 22:46 id_rsa.pub
-bash-4.2$
```

- 创建`~/.ssh/authorized_keys`文件，用于存储信任的客户端的公钥信息。

```sh
-bash-4.2$ touch ~/.ssh/authorized_keys
-bash-4.2$ ls -lah ~/.ssh/authorized_keys
-rw-rw-r-- 1 git git 0 Mar 13 22:52 /home/git/.ssh/authorized_keys
```

将自己的电脑的公钥信息复制一份存储到git服务器git账号的`~/.ssh/authorized_keys`文件中。
```sh
$ cat ~/.ssh/id_rsa.pub
```

你可以使用该命令查看你的公钥信息，并粘贴到git服务器git账号的`~/.ssh/authorized_keys`文件，修改后可以查看一下文件内容：

```sh
-bash-4.2$ cat ~/.ssh/authorized_keys
```

此时，再在客户端尝试的提交：

```sh
[mzh@MacBookPro gitserver (master)]$ git push origin master
fatal: remote error: access denied or repository not exported: /gitserver.git
```

推送失败，同时查看服务器端日志信息：

```sh
[root@gitserver ~]# git daemon --verbose --export-all --user=git --base-path=/home/git/repos /home/git/repos
[102] Ready to rumble
[261] Connection from 171.113.24.229:30299
[261] Extended attribute "host": hellogitlab.com
[261] Request receive-pack for '/gitserver.git'
[261] 'receive-pack': service not enabled for '/home/git/repos/gitserver.git'
[102] [261] Disconnected (with error)
```

可以看到，仍然是不能推送成功，并提示需要开启`receive-pack`服务。



由上面我们知道，要想通过`git daemon`服务提交git的远程推送，则需要开启`receive-pack`服务，而开启了该服务，则任何人都可以提交推送，则此时会非常不安全，因此建议使用`gitolite`项目来创建git服务器。



