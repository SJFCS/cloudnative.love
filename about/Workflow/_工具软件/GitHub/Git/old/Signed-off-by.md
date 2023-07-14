# 什么是Signed-off-by

在看一些开源代码的 `git log`查看历史提交日志的时候，往往会发现里面有些 日志信息中除了说明修改内容还有一行：`Signed-off-by: xxx`。那这个`Signed-off-by`到底是什么呢？

参考：

- [What is the Sign Off feature in Git for?](https://stackoverflow.com/questions/1962094/what-is-the-sign-off-feature-in-git-for)

其中[Brian Campbell](https://stackoverflow.com/users/69755/brian-campbell)的回答：

> Sign-off is a requirement for getting patches into the Linux kernel and a few other projects, but most projects don't actually use it.
>
> It was introduced in the wake of the SCO lawsuit, (and other accusations of copyright infringement from SCO, most of which they never actually took to court), as a Developers Certificate of Origin. It is used to say that you certify that you have created the patch in question, or that you certify that to the best of your knowledge, it was created under an appropriate open-source license, or that it has been provided to you by someone else under those terms. This can help establish a chain of people who take responsibility for the copyright status of the code in question, to help ensure that copyrighted code not released under an appropriate free software (open source) license is not included in the kernel.

- 签名是将修补程序归入Linux内核和其他一些项目的要求，但大多数项目实际上没有使用它。
- 签名行用于表明你确认针对问题创建了个补丁包，或者你认为你是在适当的开源协议下由你或者其他的某个组织的人创建了该修改。
- 通过签名行有助于确认责任，确认版权状态等。
- 签名是提交消息结束时的一行，该消息是谁提交的。 它的主要目的是改善谁做了什么，特别是用在补丁提交时。

我们可以在`git`源代码中看到很多类似的签名行信息：

```sh
mei@4144e8c22fff:~/git$ git log -n 1
commit 670b81a890388c60b7032a4f5b879f2ece8c4558 (HEAD -> master, origin/master, origin/HEAD, test1, dev)
Author: Junio C Hamano <gitster@pobox.com>
Date:   Mon Jun 14 13:23:28 2021 +0900

    The second batch

    Signed-off-by: Junio C Hamano <gitster@pobox.com>
mei@4144e8c22fff:~/git$ git show faf16d4e97ed45e8e570a8d1d568449e948284f0 --stat
commit faf16d4e97ed45e8e570a8d1d568449e948284f0
Author: Sergey Organov <sorganov@gmail.com>
Date:   Fri May 21 00:46:56 2021 +0300

    t4013: test "git log -m --stat"

    This is to ensure we won't break different diff formats when we start
    to imply "-p" by "-m".

    Signed-off-by: Sergey Organov <sorganov@gmail.com>
    Signed-off-by: Junio C Hamano <gitster@pobox.com>

 t/t4013-diff-various.sh           |  1 +
 t/t4013/diff.log_-m_--stat_master | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)
mei@4144e8c22fff:~/git$
```

 可以看到，有的是只有一个签名行，有的有峡谷个签名行！

我们可以通过`-s`或`--signoff`参数来追加签名行：

```sh
     -s, --signoff
           Add Signed-off-by line by the committer at the end of the commit log message. The meaning of a signoff
           depends on the project, but it typically certifies that committer has the rights to submit this work under
           the same license and agrees to a Developer Certificate of Origin (see http://developercertificate.org/ for
           more information).
```

当我们创建修改，并使用该参数修改提交修改时：

```sh
[mzh@MacBookPro git (master ✗)]$ git add Signed-off-by.md
[mzh@MacBookPro git (master ✗)]$ git commit -s
```


可以看到，签名行`Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>`已经加入到提交信息当中。

```sh
# 查看日志
# 注：此处的`--no-pager`是关闭分页开关
[mzh@MacBookPro git (master ✗)]$ git --no-pager log -n 1
commit 4d2333ecb06463be05abfef275b6defab02e3021 (HEAD -> master)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 20 15:59:00 2022 +0800

    docs(Git): what is Signed-off-by

    what is the Singed-off-by in the git commit log.

    Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
```

