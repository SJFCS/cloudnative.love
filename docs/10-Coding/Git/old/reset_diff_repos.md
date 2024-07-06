# Git多个远程仓库不同步时的补救办法

[[toc]]

git本地仓库是可以与多个远程仓库关联的。我是一个本地仓库关联了github和gitee两个远程仓库：

```sh
$ git remote -v
gitee	git@gitee.com:meizhaohui/vueblog.git (fetch)
gitee	git@gitee.com:meizhaohui/vueblog.git (push)
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)
```

今天提前时，发现修改只提交到github，而不能正常提交到gitee上面。在github上面和gitee上面查看提交记录，发现gitee上面之前多了一次提交，但没有拉取到本地来，此次提交时，将修改只提交到了github上面，gitee提交不了。

下面记录处理过程。思路如下：

- 将本地这次修改的文件在别的位置进行备份。
- 本地解除gitee仓库绑定。
- 本地将提交到github上面的记录撤销，并清理github上面的痕迹，使本地还原成比较旧的状态。
- 本地增加gitee仓库绑定，并从gitee上面拉取gitee上面的修改记录。
- 将修改强推到github仓库中。
- 将备份的修改文件复制到仓库中，再进行正常推送到两个仓库。

gitee上面多出的一条记录，未检出到本地：

## 1. 操作方法

### 1.1 备份文件

备份本次修改的文件到电脑上其他位置：

```sh
$ cp template.md
$ ll ~/template.md
-rw-r--r--@ 1 mzh  staff   2.5K  2 12 18:38 /Users/mzh/template.md
```

### 1.2 本地解除gitee仓库绑定

使用`git remote remove`命令来解除仓库绑定，避免后面还原了不该还原的仓库提交记录：
```sh
# 查看远程仓库情况，有github和gitee两个仓库
$ git remote -v
gitee	git@gitee.com:meizhaohui/vueblog.git (fetch)
gitee	git@gitee.com:meizhaohui/vueblog.git (push)
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)

# 解除gitee绑定
$ git remote remove gitee

# 再次查看远程仓库情况，只剩下默认的github仓库
$ git remote -v
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)
```

### 1.3 撤消本地最后一次提交记录

查看本地最后两条日志记录，`1a40692bfe33f1dc80836765296f097363763db3`这条提交是我们提交到github上面，未能提交到gitee上面去，我需要撤消这次提交，并将其从github上面删除掉。
```sh
$ git log -n 2|awk NF
commit 1a40692bfe33f1dc80836765296f097363763db3
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Fri Feb 10 07:06:41 2023 +0800
    CM(ansible): use template module
commit 2d35e161bdfdb390a93e6882f566e8c623b5deb9
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Thu Jan 5 22:28:06 2023 +0800
    CM(ansible): use tempfile module
```

本地回退1次提交：
```sh
$ git reset --hard HEAD~1
HEAD is now at 2d35e16 CM(ansible): use tempfile module
```
可以看到，本地HEAD已经指向到`2d35e161bdfdb390a93e6882f566e8c623b5deb9`这次提交，表明本地已经回退了一次提交。

此时，需要强制更新远程的历史提交记录：
```sh
$ git push -f
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
remote:
remote:
To github.com:meizhaohui/vueblog.git
 + 1a40692...2d35e16 master -> master (forced update)
$ echo $?
0
```
此时，可以看到，github远程仓库已经回退了。


### 1.5 本地增加gitee仓库绑定

使用`git remote add`增加gitee仓库绑定：
```sh
$ git remote add gitee git@gitee.com:meizhaohui/vueblog.git
$ git remote -v
gitee	git@gitee.com:meizhaohui/vueblog.git (fetch)
gitee	git@gitee.com:meizhaohui/vueblog.git (push)
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)
```
可以看到已经绑定成功。

### 1.6 拉取gitee上面的修改

我们要将gitee上面多出的修改拉取到本地：
```sh
$ git pull gitee master
From gitee.com:meizhaohui/vueblog
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> gitee/master
Updating 2d35e16..0dbefa5
Fast-forward
 myblog/docs/.vuepress/public/scripts/ansible/tempfile.yml | 23 ++++++++++++++++
 myblog/docs/CM/ansible/tempfile.md                        | 80 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 101 insertions(+), 2 deletions(-)
 create mode 100644 myblog/docs/.vuepress/public/scripts/ansible/tempfile.yml

$ git pull gitee master
From gitee.com:meizhaohui/vueblog
 * branch            master     -> FETCH_HEAD
Already up to date.
```
可以看到gitee上面的修改记录已经拉取到本地了。

### 1.7 将修改强推到github仓库

此时查看本地修改状态：
```sh
$ git status
On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
可以看到，本地有一个提交待提交到远程仓库。这个提交就是已经提交到gitee，未提交到github的那个修改记录。

使用`git push -f`强制推送到远程仓库：
```sh
$ git push -f
Enumerating objects: 22, done.
Counting objects: 100% (22/22), done.
Delta compression using up to 8 threads
Compressing objects: 100% (12/12), done.
Writing objects: 100% (12/12), 2.73 KiB | 2.73 MiB/s, done.
Total 12 (delta 7), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (7/7), completed with 7 local objects.
remote:
remote:
To github.com:meizhaohui/vueblog.git
   2d35e16..0dbefa5  master -> master
```

由于gitee上面已经有该条记录，此处仅显示提交到github上面的提交过程日志。

### 1.8 提交备份文件

将备份文件复制到当前目录，并进行提交：
```sh
# 复制备份的文件到仓库中
[mzh@MacBookPro ansible (master)]$ cp ~/template.md .

# 查看仓库状态
[mzh@MacBookPro ansible (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   template.md

no changes added to commit (use "git add" and/or "git commit -a")


# 将当前目录加入暂存区
[mzh@MacBookPro ansible (master ✗)]$ git add .

# 再次查看仓库状态
[mzh@MacBookPro ansible (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   template.md

# 设置提交日志信息
[mzh@MacBookPro ansible (master ✗)]$ git commit -m "CM(ansbile): use template module"
[master eaa1689] CM(ansbile): use template module
 1 file changed, 34 insertions(+)
 
# 提交 
[mzh@MacBookPro ansible (master)]$ gp
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Delta compression using up to 8 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (7/7), 1.68 KiB | 1.68 MiB/s, done.
Total 7 (delta 4), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (4/4), completed with 4 local objects.
remote:
remote:
To github.com:meizhaohui/vueblog.git
   0dbefa5..eaa1689  master -> master
==============================
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Delta compression using up to 8 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (7/7), 1.68 KiB | 1.68 MiB/s, done.
Total 7 (delta 4), reused 0 (delta 0), pack-reused 0
remote: Powered by GITEE.COM [GNK-6.4]
To gitee.com:meizhaohui/vueblog.git
   0dbefa5..eaa1689  master -> master
```

可以看到提交成功！说明两个仓库又保持同步一致了！！

注意，此处的`gp`是快捷命令：
```sh
$ alias gp
gp='git push && rc "=" 30 && git push gitee master
```

到此，本次git多个远程仓库不同步的问题就处理完成了。
