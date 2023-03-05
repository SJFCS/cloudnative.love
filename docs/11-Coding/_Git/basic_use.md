# git的基本使用

[[toc]]

## 修改Github历史提交记录中的username和email信息

GitHub提交时，发现github没有统计贡献值，多半是由于邮箱没有关联。

下面是解决方法的具体步骤。

- 克隆项目

克隆项目，并切换到项目根目录下：

```sh
$ git clone git@github.com:meizhaohui/vueblog.git
$ cd vueblog
```

- 查看本地配置的用户名和邮箱地址

```sh
$ git config --global user.email
mistake@email.com
$ git config  user.email
mistake@email.com
$ git config --global user.name
Zhaohui Mei
$ git config user.name
Zhaohui Mei
```
可以发现全局的和本项目的邮箱都是错的邮箱。

- 修改全局和本项目的邮箱地址

将本地邮箱地址改成正确的邮箱。

```sh
$ git config --global user.email "mzh.whut@gmail.com"
$ git config user.email "mzh.whut@gmail.com"
$ git config --global user.email
mzh.whut@gmail.com
$ git config user.email
mzh.whut@gmail.com
```

- 配置修改脚本

项目根目录下面修改脚本文件，脚本内容如下：

```sh
$ cat change_history_commit_username_email.sh
#!/bin/sh
git filter-branch --env-filter '
OLD_EMAIL="mistake@email.com" # 填入旧的、错误的email
CORRECT_NAME="Zhaohui Mei" # 填入修改后的username
CORRECT_EMAIL="mzh.whut@gmail.com" # 填入修改后的email
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

下载脚本 [change_history_commit_username_email.sh](/scripts/shell/change_history_commit_username_email.sh)

修改脚本中的OLD_EMAIL、CORRECT_NAME、CORRECT_EMAIL等参数

- 执行shell脚本

```sh
$ sh change_history_commit_username_email.sh
Rewrite 3473c357c13a91716e97e9ae572a8db195fafbdf (22/25) (1 seconds passed, remaining 0 predicted)
Ref 'refs/heads/master' was rewritten
```

::: tip 提示
脚本需要放置在项目的根目录下面，否则会提示如下异常：

```sh
$ sh change_history_commit_username_email.sh
You need to run this command from the toplevel of the working tree.
```
:::


- 提交修改

```sh
$ git push --force --tags origin 'refs/heads/*'
Enumerating objects: 321, done.
Counting objects: 100% (321/321), done.
Delta compression using up to 8 threads
Compressing objects: 100% (178/178), done.
Writing objects: 100% (321/321), 2.56 MiB | 569.00 KiB/s, done.
Total 321 (delta 125), reused 181 (delta 87)
remote: Resolving deltas: 100% (125/125), done.
To https://github.com/meizhaohui/vueblog.git
 + 3473c35...1e6ed60 master -> master (forced update)
```


提交完成后，可以发现Github个人页面上面的贡献图示位置已经变成绿色，说明修改成功。

参考: [修改Github历史提交记录中的username和email信息](https://blog.csdn.net/Kexiii/article/details/86561273)


## github合并分支到master



在写项目的时候习惯创建一个dev分支用于更新代码，等到整个或者阶段性完成的时候再合并到master上

步骤如下:

```sh
# 切换到master分支
$ git checkout master
Switched to branch 'master'
# 将dev分支的代合并到master
$ git merge dev

# 查看状态
git status

# 推送
git push origin master
```


## github设置免密上传文件


### 生成密钥


生成密钥:

```sh
ssh-keygen -t rsa -C "mzh.whut@gmail.com"
```

你运行时，将命令中的`mzh.whut@gmail.com`替换成你自己的邮箱即可。运行以上命令生成密钥，运行过程中一路按回车键(Enter)。命令执行完成后，会在家目录中生成`.ssh`目录，并生成两个文件：`id_rsa`(密钥)和`id_rsa.pub`(公钥)，复制公钥`id_rsa.pub`文件中的内容复制。

### 将公钥保存到github中


-  登陆`github`后，依次打开 `Settings`-> `SSH and GPG keys`，点击 `New SSH key` ，将刚才复制的公钥`id_rsa.pub`内容粘贴到`Key`输入框中，并指定一个`Title`标题，并点击`Add SSH Key`保存。

### 本地git环境配置


#### 设置用户名和邮箱


-  设置用户名:

```sh
$ git config --global user.name "Zhaohui Mei"
```

你执行时请将`Zhaohui Mei`替换成你的名字，建议使用英文字符组成的名字。

-  设置邮箱:

```sh
$ git config --global user.email "mzh.whut@gmail.com"
```
你执行时请将`mzh.whut@gmail.com`替换成你的邮箱地址，建议与github上面你配置的邮箱地址保持一致。

-  查看用户名设置是否生效:

```sh
$ git config user.name
```

-  查看邮箱设置是否生效:

```sh
git config user.email
```

### 设置git凭证存储


- 如果你使用的是SSH方式连接远端，并且设置了一个没有口令的密钥，这样就可以在不输入用户名和密码的情况下安全地传输数据。 然而，这对`HTTP`协议来说是不可能的——每一个连接都是需要用户名和密码的。 "`store`"模式会将凭证用明文的形式存放在磁盘中，并且永不过期。 这意味着除非你修改了你在`Git`服务器上的密码，否则你永远不需要再次输入你的凭证信息。

-  新建存储凭证数据的文件，使用以下命令新建凭证存储文件:

```sh
$ touch ~/.git-credentials
```

-  将用户名和密码数据存储到凭证文件中，在`~/.git-credentials`文件中添加以下数据： `https://username:password@github.com`

-  配置git凭证凭证存储:

```sh
$ git config --global credential.helper store
```

注：`git`配置文件存放路径为：`~/.gitconfig`

-  `~/.git-credentials`文件中,如果密码中包含特殊字符，需要进行`urlEncode`转义，如`@`符号需要写作`%40`，列举部分转换规则：


| 字符 | urlEncode |
|------|-----------|
| #    | %23       |
| $    | %24       |
| +    | %2b       |
| @    | %40       |
| :    | %3a       |
| =    | %3d       |
| ?    | %3f       |


### 下载远程仓并测试修改上库


-  使用以下命令进行远程仓的下载:

```sh
$ git clone https://github.com/meizhaohui/vueblog.git
```
-  下载完成后，对下载的文件做一些修改，并保存
-  使用`git diff`查看修改差异:

```sh
$ git diff
```

-  将修改文件添加到本地库:

```sh
$ git add -A
```

-  添加commit信息:

```sh
$ git commit -m"commit log"  (注：此处不要使用单引号包裹commit log信息)
```

-查看远程仓信息:

```sh
$ git remote -v
```

-  查看本地分支信息:

```sh 
$ git branch
```
- 将本地库中的修改push到远程仓库中:

```sh
$ git push origin master:master  (注：第一个master为本地分支，第二个master为远程分支)
```

## 检查某个文件是否被`git`忽略

检查`change_history_commit_username_email.sh`文件是否被`git`忽略，被忽略的文件不会被`git`提交到仓库中：

```sh
$ git check-ignore -v change_history_commit_username_email.sh
.gitignore:112:change_history_commit_username_email.sh	change_history_commit_username_email.sh
```

以上结果可知`.gitignore`的第112行规则忽略了该文件。我们对该文件做的任何修改都会被`git`忽略掉。
