# git异常处理

[[toc]]

## `Peer's Certificate issuer is not recognized`异常


在CentOS7操作系统中搭建了内部使用的gitlab平台，当使用`git clone`下载代码时会提示以下异常：

```sh
fatal: unable to access 'https://*****/xx.git/': Peer's Certificate issuer is not recognized.
```

导致该问题的原因是系统证书问题，因为系统会对SSL证书进行验证，操作系统判断这个操作可能会造成不好的影响，并进行了阻止，停止了下载操作。

因为该gitlab仓库是我们信任的，我们只需要设置跳过SSL证书验证就可以，执行以下命令：

```sh
git config --global http.sslVerify false
```

## GitHub无法访问或访问缓慢解决办法

在终端执行指令`sudo vi /etc/hosts`打开hosts文件进行编辑 插入如下内容，保存退出即可！

```
# github
204.232.175.78 http://documentcloud.github.com
207.97.227.239 http://github.com
204.232.175.94 http://gist.github.com
107.21.116.220 http://help.github.com
207.97.227.252 http://nodeload.github.com
199.27.76.130 http://raw.github.com
107.22.3.110 http://status.github.com
204.232.175.78 http://training.github.com
207.97.227.243 http://www.github.com
```



## Please commit your changes or stash them before you merge

解决方法：

- `git stash`暂存。
- `git pull`拉取远程仓库代码。
- `git stash pop`释放暂存修改。



当你有多个设备都向同一个仓库中提交文件时，有时就会出现这种情况：

- 你在A设备是对文件file进行了修改，并提交到git仓库里面去了。
- 随后，你应该在B设备上面先检出最新的修改到本地，但你忘记了这一步。
- 然后，你在B设备上面也修改了文件file，然后尝试从远程拉取最新的代码，就会出现这种异常。

如我们在 [https://gitee.com/meizhaohui/testgit](https://gitee.com/meizhaohui/testgit) 仓库中有一个`main.c`的文件：

```c
#include <stdio.h>
 
int main()
{
    /* 我的第一个 C 程序 */
    printf("Hello, World! \n");
 
    return 0;
}
```

我们先在Web界面上进行修改，然后提交。


此时文件已经增加了一行内容`printf("Edited in Chrome! \n");`。

我们再尝试在本地修改：

```sh
# 使用vim进行编辑修改
[mzh@MacBookPro testgit (master)]$ vi main.c

# 查看差异
[mzh@MacBookPro testgit (master ✗)]$ git diff|awk NF
diff --git a/main.c b/main.c
index 7a98610..20f6996 100644
--- a/main.c
+++ b/main.c
@@ -4,6 +4,7 @@ int main()
 {
     /* 我的第一个 C 程序 */
     printf("Hello, World! \n");
-
+    printf("Edited in Vim! \n");
+
     return 0;
 }
```

尝试拉取代码：

```sh
[mzh@MacBookPro testgit (master ✗)]$ git pull
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
Unpacking objects: 100% (3/3), 1.08 KiB | 554.00 KiB/s, done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
From gitee.com:meizhaohui/testgit
   cbf4eb5..9187ca3  master     -> origin/master
Updating cbf4eb5..9187ca3
error: Your local changes to the following files would be overwritten by merge:
	main.c
Please commit your changes or stash them before you merge.
Aborting
```

可以看到，已经出现了`Please commit your changes or stash them before you merge.`异常，不能拉取远程仓库最新的代码了。

假如我们不想放弃本地的修改，此时的解决方法：

```sh
# 先存储本地的修改
[mzh@MacBookPro testgit (master ✗)]$ git stash
Saved working directory and index state WIP on master: cbf4eb5 add main.c.

# 然后，从远程仓库拉取最新的代码
[mzh@MacBookPro testgit (master)]$ git pull
Updating cbf4eb5..9187ca3
Fast-forward
 main.c | 1 +
 1 file changed, 1 insertion(+)
 
# 把存储在栈中的修改释放出来
[mzh@MacBookPro testgit (master)]$ git stash pop
Auto-merging main.c
CONFLICT (content): Merge conflict in main.c
The stash entry is kept in case you need it again.

# 查看差异
[mzh@MacBookPro testgit (master ✗)]$ git diff|awk NF
diff --cc main.c
index 9489ab1,1e12a0c..0000000
--- a/main.c
+++ b/main.c
@@@ -4,7 -4,7 +4,12 @@@ int main(
  {
      /* 我的第一个 C 程序 */
      printf("Hello, World! \n");
++<<<<<<< Updated upstream
 +    printf("Edited in Chrome! \n");
 +
++=======
+     printf("Edited in Vim! \n");
+
++>>>>>>> Stashed changes
      return 0;
  }
```

此时，使用vim编辑`main.c`文件，将文件中标记为上游的修改和栈中的修改，进行对比分析，看看需要保留哪些，如我们需要两者，则可以编辑成这样的：

```sh
#include <stdio.h>

int main()
{
    /* 我的第一个 C 程序 */
    printf("Hello, World! \n");
    printf("Edited in Chrome! \n");
    printf("Edited in Vim! \n");

    return 0;
}
```

然后，再进行提交：

```sh
[mzh@MacBookPro testgit (master ✗)]$ git add main.c
[mzh@MacBookPro testgit (master ✗)]$ git commit -m"edited in vim"
[master 118bbd5] edited in vim
 1 file changed, 2 insertions(+), 1 deletion(-)
[mzh@MacBookPro testgit (master)]$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 318 bytes | 318.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Powered by GITEE.COM [GNK-6.3]
To gitee.com:meizhaohui/testgit.git
   9187ca3..118bbd5  master -> master
```

可以看到，提交成功了！

此时，可以在浏览器中看到刚才的提交：


 

参考文献

- [GitHub无法访问或访问缓慢解决办法
](https://cloud.tencent.com/developer/article/1036704)
