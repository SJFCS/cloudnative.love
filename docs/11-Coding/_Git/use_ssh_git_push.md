# SSH隧道连接实现Git推送

[[toc]]

我们来看看如何配置服务器端的 SSH 访问。 本例中，我们将使用 `authorized_keys` 方法来对用户进行认证。

参考： [服务器上的 Git - 配置服务器](https://git-scm.com/book/zh/v2/%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%B8%8A%E7%9A%84-Git-%E9%85%8D%E7%BD%AE%E6%9C%8D%E5%8A%A1%E5%99%A8)

## 1. 创建git用户和认证文件

创建用户：

```sh
[root@hellogitlab ~]# useradd git
[root@hellogitlab ~]# ls -lah /home/git/
total 20K
drwx------  2 git  git  4.0K Mar 13 23:59 .
drwxr-xr-x. 8 root root 4.0K Mar 13 23:59 ..
-rw-r--r--  1 git  git    18 Oct 31  2018 .bash_logout
-rw-r--r--  1 git  git   193 Oct 31  2018 .bash_profile
-rw-r--r--  1 git  git   231 Oct 31  2018 .bashrc
[root@hellogitlab ~]#
```

创建认证文件：

```sh
[git@hellogitlab ~]$ ssh-keygen -C git@hellogitlab.com
Generating public/private rsa key pair.
Enter file in which to save the key (/home/git/.ssh/id_rsa):
Created directory '/home/git/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/git/.ssh/id_rsa.
Your public key has been saved in /home/git/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:VibY4vF0aHFF3Y65P2K3mEKOAvWsFiSRb4fG+MiUenI git@hellogitlab.com
The key's randomart image is:
+---[RSA 2048]----+
|      . . .oo. . |
|     o o +    . .|
|      X B +    + |
|     * # *    o .|
|    + X S      . |
|   o E + o .  .  |
|    + . o +    . |
|       + . o ooo.|
|      . .   ooo.o|
+----[SHA256]-----+
[git@hellogitlab ~]$ touch ~/.ssh/authorized_keys
[git@hellogitlab ~]$ chmod 600 ~/.ssh/authorized_keys
[git@hellogitlab ~]$ ls -lah ~/.ssh/
total 16K
drwx------ 2 git git 4.0K Mar 14 00:02 .
drwx------ 5 git git 4.0K Mar 14 00:02 ..
-rw------- 1 git git    0 Mar 14 00:02 authorized_keys
-rw------- 1 git git 1.7K Mar 14 00:02 id_rsa
-rw-r--r-- 1 git git  401 Mar 14 00:02 id_rsa.pub
[git@hellogitlab ~]$
```

将自己的电脑上面的公钥信息复制到该账号的`authorized_keys`文件中：

```sh
$ cat ~/.ssh/id_rsa.pub
```

通过该命令可以查看你的公钥信息。



复制后，可以在`git`账号下查看该公钥信息：

```sh
[git@hellogitlab ~]$ cat .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtZ....省略.... meizhaohui@MacOS
[git@hellogitlab ~]$
```



## 2. 创建祼版本库

创建目录，用于存储版本库：

```sh
[root@hellogitlab ~]# mkdir /git-server
[root@hellogitlab ~]# chown git:git /git-server/
[root@hellogitlab ~]# ls -ld /git-server/
drwxr-xr-x 2 git git 4096 Mar 14 00:10 /git-server/
```

然后，切换到git账号下，创建一个祼版本库：

```sh
[root@hellogitlab ~]# su - git
Last login: Mon Mar 14 00:01:55 CST 2022 on pts/3
[git@hellogitlab ~]$ git init --bare /git-server/test.git
Initialized empty Git repository in /git-server/test.git/
[git@hellogitlab ~]$ cd /git-server/test.git/
[git@hellogitlab test.git]$ ls -lah
total 40K
drwxrwxr-x 7 git git 4.0K Mar 14 00:11 .
drwxr-xr-x 3 git git 4.0K Mar 14 00:11 ..
drwxrwxr-x 2 git git 4.0K Mar 14 00:11 branches
-rw-rw-r-- 1 git git   66 Mar 14 00:11 config
-rw-rw-r-- 1 git git   73 Mar 14 00:11 description
-rw-rw-r-- 1 git git   23 Mar 14 00:11 HEAD
drwxrwxr-x 2 git git 4.0K Mar 14 00:11 hooks
drwxrwxr-x 2 git git 4.0K Mar 14 00:11 info
drwxrwxr-x 4 git git 4.0K Mar 14 00:11 objects
drwxrwxr-x 4 git git 4.0K Mar 14 00:11 refs
[git@hellogitlab test.git]$
```

此时一个祼版本库已经创建成功。

## 3. 远程克隆和推送

克隆下载：

```sh
[mzh@MacBookPro /tmp ]$ git clone ssh://git@hellogitlab.com:10000/git-server/test.git
Cloning into 'test'...
warning: You appear to have cloned an empty repository.
[mzh@MacBookPro /tmp ]$ cd test
[mzh@MacBookPro test (master)]$ ls
[mzh@MacBookPro test (master)]$ git remote -v
origin	ssh://git@hellogitlab.com:10000/git-server/test.git (fetch)
origin	ssh://git@hellogitlab.com:10000/git-server/test.git (push)
```

可以看到能够正常下载远程存储库。

我们尝试推送修改：

```sh
[mzh@MacBookPro test (master)]$ echo 'test git push' > data.txt
[mzh@MacBookPro test (master ✗)]$ git add data.txt
[mzh@MacBookPro test (master ✗)]$ git commit -m"test git push"
[master (root-commit) 46d5adf] test git push
 1 file changed, 1 insertion(+)
 create mode 100644 data.txt
[mzh@MacBookPro test (master)]$ git push origin master
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 229 bytes | 229.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://hellogitlab.com:10000/git-server/test.git
 * [new branch]      master -> master
[mzh@MacBookPro test (master)]$ git log -n 1|awk NF
commit 46d5adf7387bce84ec9f39b074ae823df5e8129e
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Mon Mar 14 00:23:22 2022 +0800
    test git push
[mzh@MacBookPro test (master)]$
```

可以看到推送成功。

我们去服务器端检查一下：

```sh
[git@hellogitlab test.git]$ git log -n 1
commit 46d5adf7387bce84ec9f39b074ae823df5e8129e (HEAD -> master)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Mon Mar 14 00:23:22 2022 +0800

    test git push
[git@hellogitlab test.git]$
```

可以看到，服务器端已经接收到了我的推送，说明我们的git仓库正常能够使用。



如果还有别的用户需要访问git存储库，只需要将该用户的公钥信息追加到服务器git账号的`/home/git/.ssh/authorized_keys`目录即可。



## 4. 限制用户不能登陆

借助一个名为 `git-shell` 的受限 shell 工具，你可以方便地将用户 `git` 的活动限制在与 Git 相关的范围内。 该工具随 Git 软件包一同提供。如果将 `git-shell` 设置为用户 `git` 的登录 shell（login shell）， 那么该用户便不能获得此服务器的普通 shell 访问权限。 若要使用 `git-shell`，需要用它替换掉 bash 或 csh，使其成为该用户的登录 shell。 为进行上述操作，首先你必须确保 `git-shell` 的完整路径名已存在于 `/etc/shells` 文件中：

```sh
[root@hellogitlab ~]# which git-shell
/bin/git-shell
[root@hellogitlab ~]# grep 'git-shell' /etc/shells

# 将/bin/git-shell追加到文件中
[root@hellogitlab ~]# echo '/bin/git-shell' >> /etc/shells
[root@hellogitlab ~]# grep 'git-shell' /etc/shells
/bin/git-shell
[root@hellogitlab ~]#
```

现在你可以使用 `chsh <username> -s <shell>` 命令修改任一系统用户的 shell：

```sh
[root@hellogitlab ~]# chsh git -s $(which git-shell)
Changing shell for git.
Shell changed.
[root@hellogitlab ~]# grep 'git' /etc/passwd
git:x:1004:1004::/home/git:/bin/git-shell
[root@hellogitlab ~]#
```

可以看到，`git`账号的shell已经更新为`/bin/git-shell`了。



在客户端再次尝试SSH连接服务器：

```sh
[mzh@MacBookPro ~ ]$ ssh git@hellogitlab.com -p 10000
Last login: Mon Mar 14 00:31:54 2022 from 171.113.24.229
fatal: Interactive git shell is not enabled.
hint: ~/git-shell-commands should exist and have read and execute access.
Connection to hellogitlab.com closed.
[mzh@MacBookPro ~ ]$
```

发现尝试被拒绝。



尝试推送：

```sh
[mzh@MacBookPro test (master)]$ echo 'test git-shell' >> data.txt
[mzh@MacBookPro test (master ✗)]$ git add data.txt
[mzh@MacBookPro test (master ✗)]$ git commit -m"test use git-shell"
[master c85486b] test use git-shell
 1 file changed, 1 insertion(+)
[mzh@MacBookPro test (master)]$ git push origin master
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Writing objects: 100% (3/3), 275 bytes | 275.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://hellogitlab.com:10000/git-server/test.git
   46d5adf..c85486b  master -> master
[mzh@MacBookPro test (master)]$
```

可以发送推送正常！



服务器端也可以看到刚推送的修改：

```sh
[root@hellogitlab ~]# cd /git-server/
[root@hellogitlab git-server]# ls
test.git
[root@hellogitlab git-server]# cd test.git/
[root@hellogitlab test.git]# git log -n 2|awk NF
commit c85486bba05a2702573a6eee5c602f3a6eae077a
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Mon Mar 14 00:41:30 2022 +0800
    test use git-shell
commit 46d5adf7387bce84ec9f39b074ae823df5e8129e
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Mon Mar 14 00:23:22 2022 +0800
    test git push
[root@hellogitlab test.git]#
```

