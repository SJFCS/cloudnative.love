

# Git版本控制管理

[[toc]]

本文是对Jon Loeliger等著的第二版《Git版本控制管理》一书的总结。

## 第1章 介绍

### 1.1 背景

- 一个可以管理和追踪软件代码或其他类似内容的不同版本的工具，通常称为：版本控制系统VCS，或者源代码管理器SCM，或者修订控制系统RCS，或其他各种和修订、代码、内容、版本、控制、管理和系统等相关的叫法。本书中，版本控制系统VCS一词就是泛指一切这样的工具。
- 本书主要介绍Git这款功能强大、灵活而且开销低的VCS。
- Git由Linux Torvalds发明，超初是为了方便管理Linux内核的开发工作。

### 1.2 Git的诞生

- 通常来说，当工具跟不上项目需求时，开发人员就会开发一个新的工具。

- Git设计优良，能够胜任世界范围内大规模的软件开发工程。

- 在Git诞生之前，Linux内核开发过程中使用BitKeeper来作为版本控制系统，但在2005年，BitKeeper所有方对他们的免费的BitKeeper加入了额外的限制，Linux社区意识到，使用BitKeeper不再是一个长期可行的解决方案。Linus本人开始寻找替代品。这次，他回避使用商业解决方案，在自由软件包中寻找。但是，当时现有的VCS存在一些缺陷。Linus没能找到的有关特性有：

    - 有助于分布式开发。需要允许并行开发，各人可以在自己的版本库中独立且同时地开发，而不需要与中心版本库时刻同步。
    - 能够胜任上千开发人员的规模。Linus深知，每个Linux版本都凝聚了数以千计的开发人员的心血，所以新的VCS需要支持非常多的开发人员。
    - 性能优异。新的VCS需要能够快速并且高效地执行。不管是个人的更新操作，还是网络传输操作，都需要保证执行速度，为了节约存储空间，从而节约传输时间，需要使用`压缩`和`差异比较`技术。
    - 保持完整性和可靠性。因为Git是一个分布式版本控制系统，所以非常需要能够绝对的保证数据的完整性和不会被意外修改，Git使用一个叫做`安全散列函数SHA1`的通用加密散列函数，来命名和识别数据库中的对象。实践证明，这是一种足够可靠的方式。
    - 强化责任。版本控制系统的一个关键方面，就是能够定位谁改动了文件，甚至改动的原因。对所有的改动进行责任追踪。
    - 不可变性。版本库中存储的数据对象均是不可变的。一旦创建数据对象并把它们存放在数据库中，它们便不可修改。
    - 原子事务。可以让一系列不同但是相关的操作要么全部执行要么一个都不执行。
    - 支持并且鼓励基于分支的开发。几乎所有的VCS都支持在同一个项目存在多个支线，例如代码变更的一条支线叫开发，同时又存在另一条支线要测试。Git把这样的支线叫做“分支”。需要提供一个简单、清晰、快速的分支合并功能。
    - 完整的版本库。为了让各个开发人员不需要查询中心服务器就可以得到历史修订信息，每个人的版本库都有一份关于每个文件的完整历史修改信息。
    - 一个清晰的内部设计。Git的对象模型拥有着简单的结构，并且能够保存原始数据最基本的部分和目录结构，能够记录变更内容等。
    - 免费自由-Be free, as in freedom。

### 1.3 先例

- SCCS——源代码控制系统 Source Code Control System。
- RCS——修订控制系统Revision Control System。
- CVS——并行版本系统Concurrent Version System。
- SVN——Subversion。
- BitKeeper。
- Mercruial。

Git沿用了Mercurial用散列指纹来唯一标识文件的内容，文件名只是一个绰号，旨在方便用户操作。



### 1.4 时间线

- Git于2005年4月7日诞生。正式成为自托管项目。
- 2005年4月16日，Linux内核的第一个提交也诞生了。
- Git源码地址：[https://github.com/git/git](https://github.com/git/git) 。
- Linux源码地址：[https://github.com/torvalds/linux/](https://github.com/torvalds/linux/)

下载git源码，由于国内下载github代码比较慢，我们可以注册一个码云的账号，并将github中的代码导入到码云上面。

- 码云地址：[https://gitee.com/](https://gitee.com/)

我将github上面git源码导入到我的码云上的地址为：[https://gitee.com/meizhaohui/git](https://gitee.com/meizhaohui/git)

下载Git源码：

```sh
$ git clone git@gitee.com:meizhaohui/git.git
Cloning into 'git'...
remote: Enumerating objects: 309613, done.
remote: Counting objects: 100% (309613/309613), done.
remote: Compressing objects: 100% (76164/76164), done.
remote: Total 309613 (delta 231105), reused 309613 (delta 231105), pack-reused 0
Receiving objects: 100% (309613/309613), 163.07 MiB | 9.03 MiB/s, done.
Resolving deltas: 100% (231105/231105), done.
Updating files: 100% (3967/3967), done.
```

下载完成后，就会有一个git目录：

```sh
[mzh@MacBookPro ~ ]$ cd git
[mzh@MacBookPro git (master)]$ ls
CODE_OF_CONDUCT.md             git-gui                        protocol-caps.h
COPYING                        git-instaweb.sh                protocol.c
Documentation                  git-merge-octopus.sh           protocol.h
GIT-VERSION-GEN                git-merge-one-file.sh          prune-packed.c
INSTALL                        git-merge-resolve.sh           prune-packed.h
LGPL-2.1                       git-mergetool--lib.sh          quote.c
Makefile                       git-mergetool.sh               quote.h
README.md                      git-p4.py                      range-diff.c
RelNotes                       git-quiltimport.sh             range-diff.h
SECURITY.md                    git-rebase--preserve-merges.sh reachable.c
abspath.c                      git-request-pull.sh            reachable.h
aclocal.m4                     git-send-email.perl            read-cache.c
add-interactive.c              git-sh-i18n.sh                 rebase-interactive.c
add-interactive.h              git-sh-setup.sh                rebase-interactive.h
add-patch.c                    git-submodule.sh               rebase.c
advice.c                       git-svn.perl                   rebase.h
advice.h                       git-web--browse.sh             ref-filter.c
alias.c                        git.c                          ref-filter.h
alias.h                        git.rc                         reflog-walk.c
alloc.c                        gitk-git                       reflog-walk.h
alloc.h                        gitweb                         refs
apply.c                        gpg-interface.c                refs.c
apply.h                        gpg-interface.h                refs.h
archive-tar.c                  graph.c                        refspec.c
archive-zip.c                  graph.h                        refspec.h
archive.c                      grep.c                         remote-curl.c
archive.h                      grep.h                         remote.c
attr.c                         hash-lookup.c                  remote.h
attr.h                         hash-lookup.h                  replace-object.c
banned.h                       hash.h                         replace-object.h
base85.c                       hashmap.c                      repo-settings.c
bisect.c                       hashmap.h                      repository.c
bisect.h                       help.c                         repository.h
blame.c                        help.h                         rerere.c
blame.h                        hex.c                          rerere.h
blob.c                         http-backend.c                 reset.c
blob.h                         http-fetch.c                   reset.h
block-sha1                     http-push.c                    resolve-undo.c
bloom.c                        http-walker.c                  resolve-undo.h
bloom.h                        http.c                         revision.c
branch.c                       http.h                         revision.h
branch.h                       ident.c                        run-command.c
builtin                        imap-send.c                    run-command.h
builtin.h                      iterator.h                     send-pack.c
bulk-checkin.c                 json-writer.c                  send-pack.h
bulk-checkin.h                 json-writer.h                  sequencer.c
bundle.c                       khash.h                        sequencer.h
bundle.h                       kwset.c                        serve.c
cache-tree.c                   kwset.h                        serve.h
cache-tree.h                   levenshtein.c                  server-info.c
cache.h                        levenshtein.h                  setup.c
chdir-notify.c                 line-log.c                     sh-i18n--envsubst.c
chdir-notify.h                 line-log.h                     sha1collisiondetection
check-builtins.sh              line-range.c                   sha1dc
check_bindir                   line-range.h                   sha1dc_git.c
checkout.c                     linear-assignment.c            sha1dc_git.h
checkout.h                     linear-assignment.h            sha256
chunk-format.c                 list-objects-filter-options.c  shallow.c
chunk-format.h                 list-objects-filter-options.h  shallow.h
ci                             list-objects-filter.c          shell.c
color.c                        list-objects-filter.h          shortlog.h
color.h                        list-objects.c                 sideband.c
column.c                       list-objects.h                 sideband.h
column.h                       list.h                         sigchain.c
combine-diff.c                 ll-merge.c                     sigchain.h
command-list.txt               ll-merge.h                     simple-ipc.h
commit-graph.c                 lockfile.c                     sparse-index.c
commit-graph.h                 lockfile.h                     sparse-index.h
commit-reach.c                 log-tree.c                     split-index.c
commit-reach.h                 log-tree.h                     split-index.h
commit-slab-decl.h             ls-refs.c                      stable-qsort.c
commit-slab-impl.h             ls-refs.h                      strbuf.c
commit-slab.h                  mailinfo.c                     strbuf.h
commit.c                       mailinfo.h                     streaming.c
commit.h                       mailmap.c                      streaming.h
common-main.c                  mailmap.h                      string-list.c
compat                         match-trees.c                  string-list.h
config.c                       mem-pool.c                     strmap.c
config.h                       mem-pool.h                     strmap.h
config.mak.dev                 merge-blobs.c                  strvec.c
config.mak.in                  merge-blobs.h                  strvec.h
config.mak.uname               merge-ort-wrappers.c           sub-process.c
configure.ac                   merge-ort-wrappers.h           sub-process.h
connect.c                      merge-ort.c                    submodule-config.c
connect.h                      merge-ort.h                    submodule-config.h
connected.c                    merge-recursive.c              submodule.c
connected.h                    merge-recursive.h              submodule.h
contrib                        merge.c                        symlinks.c
convert.c                      mergesort.c                    t
convert.h                      mergesort.h                    tag.c
copy.c                         mergetools                     tag.h
credential.c                   midx.c                         tar.h
credential.h                   midx.h                         tempfile.c
csum-file.c                    name-hash.c                    tempfile.h
csum-file.h                    negotiator                     templates
ctype.c                        notes-cache.c                  thread-utils.c
daemon.c                       notes-cache.h                  thread-utils.h
date.c                         notes-merge.c                  tmp-objdir.c
decorate.c                     notes-merge.h                  tmp-objdir.h
decorate.h                     notes-utils.c                  trace.c
delta-islands.c                notes-utils.h                  trace.h
delta-islands.h                notes.c                        trace2
delta.h                        notes.h                        trace2.c
detect-compiler                object-file.c                  trace2.h
diff-delta.c                   object-name.c                  trailer.c
diff-lib.c                     object-store.h                 trailer.h
diff-merges.c                  object.c                       transport-helper.c
diff-merges.h                  object.h                       transport-internal.h
diff-no-index.c                oid-array.c                    transport.c
diff.c                         oid-array.h                    transport.h
diff.h                         oidmap.c                       tree-diff.c
diffcore-break.c               oidmap.h                       tree-walk.c
diffcore-delta.c               oidset.c                       tree-walk.h
diffcore-order.c               oidset.h                       tree.c
diffcore-pickaxe.c             pack-bitmap-write.c            tree.h
diffcore-rename.c              pack-bitmap.c                  unicode-width.h
diffcore-rotate.c              pack-bitmap.h                  unimplemented.sh
diffcore.h                     pack-check.c                   unix-socket.c
dir-iterator.c                 pack-objects.c                 unix-socket.h
dir-iterator.h                 pack-objects.h                 unix-stream-server.c
dir.c                          pack-revindex.c                unix-stream-server.h
dir.h                          pack-revindex.h                unpack-trees.c
editor.c                       pack-write.c                   unpack-trees.h
entry.c                        pack.h                         upload-pack.c
entry.h                        packfile.c                     upload-pack.h
environment.c                  packfile.h                     url.c
environment.h                  pager.c                        url.h
ewah                           parallel-checkout.c            urlmatch.c
exec-cmd.c                     parallel-checkout.h            urlmatch.h
exec-cmd.h                     parse-options-cb.c             usage.c
fetch-negotiator.c             parse-options.c                userdiff.c
fetch-negotiator.h             parse-options.h                userdiff.h
fetch-pack.c                   patch-delta.c                  utf8.c
fetch-pack.h                   patch-ids.c                    utf8.h
fmt-merge-msg.c                patch-ids.h                    varint.c
fmt-merge-msg.h                path.c                         varint.h
fsck.c                         path.h                         version.c
fsck.h                         pathspec.c                     version.h
fsmonitor.c                    pathspec.h                     versioncmp.c
fsmonitor.h                    perl                           walker.c
fuzz-commit-graph.c            pkt-line.c                     walker.h
fuzz-pack-headers.c            pkt-line.h                     wildmatch.c
fuzz-pack-idx.c                po                             wildmatch.h
generate-cmdlist.sh            ppc                            worktree.c
generate-configlist.sh         preload-index.c                worktree.h
gettext.c                      pretty.c                       wrap-for-bin.sh
gettext.h                      pretty.h                       wrapper.c
git-add--interactive.perl      prio-queue.c                   write-or-die.c
git-archimport.perl            prio-queue.h                   ws.c
git-bisect.sh                  progress.c                     wt-status.c
git-compat-util.h              progress.h                     wt-status.h
git-cvsexportcommit.perl       promisor-remote.c              xdiff
git-cvsimport.perl             promisor-remote.h              xdiff-interface.c
git-cvsserver.perl             prompt.c                       xdiff-interface.h
git-difftool--helper.sh        prompt.h                       zlib.c
git-filter-branch.sh           protocol-caps.c
[mzh@MacBookPro git (master)]$
```

查看远程仓库路径：

```sh
[mzh@MacBookPro git (master)]$ git remote -v
origin	git@gitee.com:meizhaohui/git.git (fetch)
origin	git@gitee.com:meizhaohui/git.git (push)
```

将github远程库添加到远程库列表中：

```sh
[mzh@MacBookPro git (master)]$ git remote add github git@github.com:git/git.git
[mzh@MacBookPro git (master)]$ git remote -v
github	git@github.com:git/git.git (fetch)
github	git@github.com:git/git.git (push)
origin	git@gitee.com:meizhaohui/git.git (fetch)
origin	git@gitee.com:meizhaohui/git.git (push)
```

查看git的最开始的十次提交：

```sh
$ git log  --reverse --oneline |head
e83c516331 Initial revision of "git", the information manager from hell
8bc9a0c769 Add copyright notices.
e497ea2a9b Make read-tree actually unpack the whole tree.
bf0c6e839c Make "cat-file" output the file contents to stdout.
19b2860cba Use "-Wall -O2" for the compiler to get more warnings.
24778e335a Factor out "read_sha1_file" into mapping/inflating/unmapping.
2ade934026 Add "check_sha1_signature()" helper function
20222118ae Add first cut at "fsck-cache" that validates the SHA1 object store.
7660a188df Add new fsck-cache to Makefile.
9426167765 Add "-lz" to link line to get in zlib.
```

查看第一次的提交人和提交信息：

```sh
[mzh@MacBookPro git (master)]$ git log e83c516331|awk NF
commit e83c5163316f89bfbde7d9ab23ca2e25604af290
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Apr 7 15:13:13 2005 -0700
    Initial revision of "git", the information manager from hell
```

可以看到Linus于2005年4月7日15:13:13提交了Git的第一个commit!



### 1.5 名字有何含义

- git是愚蠢无用的人的意思！



## 第2章 安装Git

- Git支持Windows、Linux、MacOS等多种操作系统。
- windows和MacOS上面直接可以下载Git的二进制安装包进行安装。MacOS上面安装可参考 [Download for macOS](https://git-scm.com/download/mac)。
- Linux系统上面可以使用包管理器进行安装。如ubuntu系统安装`apt-get install git`，CentOS系统安装`yum install git`等。可参考 [Download for Linux and Unix](https://git-scm.com/download/linux)。
- 也可以通过源码编译安装，但相对麻烦一些。

为了不影响我的电脑的git环境，我在docker ubuntu容器中安装git。你也可以直接在自己的电脑上进行测试。

- 下载镜像

```sh
[mzh@MacBookPro ~ ]$ docker pull ubuntu
```

- 启动ubuntu容器

```sh
[mzh@MacBookPro ~ ]$ docker run --privileged --name ubuntu -it -d ubuntu /bin/bash
```

- 进入到容器中,注dkin是快捷命令

```sh
# alias dkin='dockerin'
# function dockerin()
# {
#     docker exec -it $1 /bin/bash
# }
[mzh@MacBookPro ~ ]$ dkin ubuntu
```

- 查看ubuntu系统版本信息

```sh
root@4144e8c22fff:/# cat /etc/issue
Ubuntu 20.04 LTS \n \l
```

- 在容器中创建用户mei
```sh
root@4144e8c22fff:/# useradd mei -d /home/mei -s /bin/bash -m
```

- 安装必备软件vim git

```sh
root@4144e8c22fff:/# apt-get install vim git -y
```

- 查看git版本

```sh
root@4144e8c22fff:/# git --version
git version 2.25.1
```


- 解决git帮助异常

由于docker中的系统是最小化安装的，删除了不需要的包和内容，如需使用需要将这些内容恢复，方可使用，因此需要使用`unminimize`命令进行恢复。

```sh
root@4144e8c22fff:/# git help clone
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, including manpages, you can run the 'unminimize'
command. You will still need to ensure the 'man-db' package is installed.

# 安装man-db包
root@4144e8c22fff:/# apt-get install man-db -y

# unminimize取消最小化
root@4144e8c22fff:/# unminimize
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

This script restores content and packages that are found on a default
Ubuntu server system in order to make this system more suitable for
interactive use.

Reinstallation of packages may fail due to changes to the system
configuration, the presence of third-party packages, or for other
reasons.

This operation may take some time.

Would you like to continue? [y/N] y
```




- 切换到用户mei

```sh
root@4144e8c22fff:/# su mei
mei@4144e8c22fff:/$ cd
mei@4144e8c22fff:~$ pwd
/home/mei
mei@4144e8c22fff:~$ git --version
git version 2.25.1
```

后续我们就在该环境下进行测试操作。

## 第3章 起步

### 3.1 Git命令行

Git简单易用，只需要在命令行输入`git`，Git就会不带任何参数地列出它的选项和最常用的子命令：

```sh
mei@4144e8c22fff:~$ git
usage: git [--version] [--help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           <command> [<args>]

These are common Git commands used in various situations:

start a working area (see also: git help tutorial)
   clone             Clone a repository into a new directory
   init              Create an empty Git repository or reinitialize an existing one

work on the current change (see also: git help everyday)
   add               Add file contents to the index
   mv                Move or rename a file, a directory, or a symlink
   restore           Restore working tree files
   rm                Remove files from the working tree and from the index
   sparse-checkout   Initialize and modify the sparse-checkout

examine the history and state (see also: git help revisions)
   bisect            Use binary search to find the commit that introduced a bug
   diff              Show changes between commits, commit and working tree, etc
   grep              Print lines matching a pattern
   log               Show commit logs
   show              Show various types of objects
   status            Show the working tree status

grow, mark and tweak your common history
   branch            List, create, or delete branches
   commit            Record changes to the repository
   merge             Join two or more development histories together
   rebase            Reapply commits on top of another base tip
   reset             Reset current HEAD to the specified state
   switch            Switch branches
   tag               Create, list, delete or verify a tag object signed with GPG

collaborate (see also: git help workflows)
   fetch             Download objects and refs from another repository
   pull              Fetch from and integrate with another repository or a local branch
   push              Update remote refs along with associated objects

'git help -a' and 'git help -g' list available subcommands and some
concept guides. See 'git help <command>' or 'git help <concept>'
to read about a specific subcommand or concept.
See 'git help git' for an overview of the system.
mei@4144e8c22fff:~$
```

- 查看完整的git子命令列表，可以输入`git help --all`：

```sh
mei@4144e8c22fff:~$ git help --all
See 'git help <command>' to read about a specific subcommand

Main Porcelain Commands
   add                  Add file contents to the index
   am                   Apply a series of patches from a mailbox
   archive              Create an archive of files from a named tree
   bisect               Use binary search to find the commit that introduced a bug
   branch               List, create, or delete branches
   bundle               Move objects and refs by archive
   checkout             Switch branches or restore working tree files
   cherry-pick          Apply the changes introduced by some existing commits
   citool               Graphical alternative to git-commit
   clean                Remove untracked files from the working tree
   clone                Clone a repository into a new directory
   commit               Record changes to the repository
   describe             Give an object a human readable name based on an available ref
   diff                 Show changes between commits, commit and working tree, etc
   fetch                Download objects and refs from another repository
   format-patch         Prepare patches for e-mail submission
   gc                   Cleanup unnecessary files and optimize the local repository
   gitk                 The Git repository browser
   grep                 Print lines matching a pattern
   gui                  A portable graphical interface to Git
   init                 Create an empty Git repository or reinitialize an existing one
   log                  Show commit logs
   merge                Join two or more development histories together
   mv                   Move or rename a file, a directory, or a symlink
   notes                Add or inspect object notes
   pull                 Fetch from and integrate with another repository or a local branch
   push                 Update remote refs along with associated objects
   range-diff           Compare two commit ranges (e.g. two versions of a branch)
   rebase               Reapply commits on top of another base tip
   reset                Reset current HEAD to the specified state
   restore              Restore working tree files
   revert               Revert some existing commits
   rm                   Remove files from the working tree and from the index
   shortlog             Summarize 'git log' output
   show                 Show various types of objects
   sparse-checkout      Initialize and modify the sparse-checkout
   stash                Stash the changes in a dirty working directory away
   status               Show the working tree status
   submodule            Initialize, update or inspect submodules
   switch               Switch branches
   tag                  Create, list, delete or verify a tag object signed with GPG
   worktree             Manage multiple working trees

Ancillary Commands / Manipulators
   config               Get and set repository or global options
   fast-export          Git data exporter
   fast-import          Backend for fast Git data importers
   filter-branch        Rewrite branches
   mergetool            Run merge conflict resolution tools to resolve merge conflicts
   pack-refs            Pack heads and tags for efficient repository access
   prune                Prune all unreachable objects from the object database
   reflog               Manage reflog information
   remote               Manage set of tracked repositories
   repack               Pack unpacked objects in a repository
   replace              Create, list, delete refs to replace objects

Ancillary Commands / Interrogators
   annotate             Annotate file lines with commit information
   blame                Show what revision and author last modified each line of a file
   count-objects        Count unpacked number of objects and their disk consumption
   difftool             Show changes using common diff tools
   fsck                 Verifies the connectivity and validity of the objects in the database
   gitweb               Git web interface (web frontend to Git repositories)
   help                 Display help information about Git
   instaweb             Instantly browse your working repository in gitweb
   merge-tree           Show three-way merge without touching index
   rerere               Reuse recorded resolution of conflicted merges
   show-branch          Show branches and their commits
   verify-commit        Check the GPG signature of commits
   verify-tag           Check the GPG signature of tags
   whatchanged          Show logs with difference each commit introduces

Interacting with Others
   archimport           Import a GNU Arch repository into Git
   cvsexportcommit      Export a single commit to a CVS checkout
   cvsimport            Salvage your data out of another SCM people love to hate
   cvsserver            A CVS server emulator for Git
   imap-send            Send a collection of patches from stdin to an IMAP folder
   p4                   Import from and submit to Perforce repositories
   quiltimport          Applies a quilt patchset onto the current branch
   request-pull         Generates a summary of pending changes
   send-email           Send a collection of patches as emails
   svn                  Bidirectional operation between a Subversion repository and Git

Low-level Commands / Manipulators
   apply                Apply a patch to files and/or to the index
   checkout-index       Copy files from the index to the working tree
   commit-graph         Write and verify Git commit-graph files
   commit-tree          Create a new commit object
   hash-object          Compute object ID and optionally creates a blob from a file
   index-pack           Build pack index file for an existing packed archive
   merge-file           Run a three-way file merge
   merge-index          Run a merge for files needing merging
   mktag                Creates a tag object
   mktree               Build a tree-object from ls-tree formatted text
   multi-pack-index     Write and verify multi-pack-indexes
   pack-objects         Create a packed archive of objects
   prune-packed         Remove extra objects that are already in pack files
   read-tree            Reads tree information into the index
   symbolic-ref         Read, modify and delete symbolic refs
   unpack-objects       Unpack objects from a packed archive
   update-index         Register file contents in the working tree to the index
   update-ref           Update the object name stored in a ref safely
   write-tree           Create a tree object from the current index

Low-level Commands / Interrogators
   cat-file             Provide content or type and size information for repository objects
   cherry               Find commits yet to be applied to upstream
   diff-files           Compares files in the working tree and the index
   diff-index           Compare a tree to the working tree or index
   diff-tree            Compares the content and mode of blobs found via two tree objects
   for-each-ref         Output information on each ref
   get-tar-commit-id    Extract commit ID from an archive created using git-archive
   ls-files             Show information about files in the index and the working tree
   ls-remote            List references in a remote repository
   ls-tree              List the contents of a tree object
   merge-base           Find as good common ancestors as possible for a merge
   name-rev             Find symbolic names for given revs
   pack-redundant       Find redundant pack files
   rev-list             Lists commit objects in reverse chronological order
   rev-parse            Pick out and massage parameters
   show-index           Show packed archive index
   show-ref             List references in a local repository
   unpack-file          Creates a temporary file with a blob's contents
   var                  Show a Git logical variable
   verify-pack          Validate packed Git archive files

Low-level Commands / Syncing Repositories
   daemon               A really simple server for Git repositories
   fetch-pack           Receive missing objects from another repository
   http-backend         Server side implementation of Git over HTTP
   send-pack            Push objects over Git protocol to another repository
   update-server-info   Update auxiliary info file to help dumb servers

Low-level Commands / Internal Helpers
   check-attr           Display gitattributes information
   check-ignore         Debug gitignore / exclude files
   check-mailmap        Show canonical names and email addresses of contacts
   check-ref-format     Ensures that a reference name is well formed
   column               Display data in columns
   credential           Retrieve and store user credentials
   credential-cache     Helper to temporarily store passwords in memory
   credential-store     Helper to store credentials on disk
   fmt-merge-msg        Produce a merge commit message
   interpret-trailers   Add or parse structured information in commit messages
   mailinfo             Extracts patch and authorship from a single e-mail message
   mailsplit            Simple UNIX mbox splitter program
   merge-one-file       The standard helper program to use with git-merge-index
   patch-id             Compute unique ID for a patch
   sh-i18n              Git's i18n setup code for shell scripts
   sh-setup             Common Git shell script setup code
   stripspace           Remove unnecessary whitespace
mei@4144e8c22fff:~$
```

可以看到Git的子命令特别的多。不要怕，我们慢慢的来了解它们。



- 查看Git版本信息

前面我们已经执行过，直接输入`git --version`即可。

```sh
mei@4144e8c22fff:~$ git --version
git version 2.25.1
mei@4144e8c22fff:~$ git version
git version 2.25.1
```

- 查看帮助信息

Git子命令都可以通过使用`git help subcommand`、`git --help subcommand`或者`git subcommand --help`来查看帮助文档信息。

我们尝试获取`clone`子命令的帮助信息：

```sh
# 方式一，git help subcommand
mei@4144e8c22fff:~$ git help clone|head -n 25|awk NF
GIT-CLONE(1)                                                              Git Manual                                                             GIT-CLONE(1)
NAME
       git-clone - Clone a repository into a new directory
SYNOPSIS
       git clone [--template=<template_directory>]
                 [-l] [-s] [--no-hardlinks] [-q] [-n] [--bare] [--mirror]
                 [-o <name>] [-b <name>] [-u <upload-pack>] [--reference <repository>]
                 [--dissociate] [--separate-git-dir <git dir>]
                 [--depth <depth>] [--[no-]single-branch] [--no-tags]
                 [--recurse-submodules[=<pathspec>]] [--[no-]shallow-submodules]
                 [--[no-]remote-submodules] [--jobs <n>] [--sparse] [--] <repository>
                 [<directory>]
DESCRIPTION
       Clones a repository into a newly created directory, creates remote-tracking branches for each branch in the cloned repository (visible using git
       branch --remotes), and creates and checks out an initial branch that is forked from the cloned repository's currently active branch.
       After the clone, a plain git fetch without arguments will update all the remote-tracking branches, and a git pull without arguments will in addition
       merge the remote master branch into the current master branch, if any (this is untrue when "--single-branch" is given; see below).
       This default configuration is achieved by creating references to the remote branch heads under refs/remotes/origin and by initializing
       remote.origin.url and remote.origin.fetch configuration variables.
mei@4144e8c22fff:~$

# 方式二，git --help subcommand
mei@4144e8c22fff:~$ git --help clone|head -n 25|awk NF
GIT-CLONE(1)                                                              Git Manual                                                             GIT-CLONE(1)
NAME
       git-clone - Clone a repository into a new directory
SYNOPSIS
       git clone [--template=<template_directory>]
                 [-l] [-s] [--no-hardlinks] [-q] [-n] [--bare] [--mirror]
                 [-o <name>] [-b <name>] [-u <upload-pack>] [--reference <repository>]
                 [--dissociate] [--separate-git-dir <git dir>]
                 [--depth <depth>] [--[no-]single-branch] [--no-tags]
                 [--recurse-submodules[=<pathspec>]] [--[no-]shallow-submodules]
                 [--[no-]remote-submodules] [--jobs <n>] [--sparse] [--] <repository>
                 [<directory>]
DESCRIPTION
       Clones a repository into a newly created directory, creates remote-tracking branches for each branch in the cloned repository (visible using git
       branch --remotes), and creates and checks out an initial branch that is forked from the cloned repository's currently active branch.
       After the clone, a plain git fetch without arguments will update all the remote-tracking branches, and a git pull without arguments will in addition
       merge the remote master branch into the current master branch, if any (this is untrue when "--single-branch" is given; see below).
       This default configuration is achieved by creating references to the remote branch heads under refs/remotes/origin and by initializing
       remote.origin.url and remote.origin.fetch configuration variables.
       
# 方式三，git subcommand --help
mei@4144e8c22fff:~$ git clone --help|head -n 25|awk NF
GIT-CLONE(1)                                                              Git Manual                                                             GIT-CLONE(1)
NAME
       git-clone - Clone a repository into a new directory
SYNOPSIS
       git clone [--template=<template_directory>]
                 [-l] [-s] [--no-hardlinks] [-q] [-n] [--bare] [--mirror]
                 [-o <name>] [-b <name>] [-u <upload-pack>] [--reference <repository>]
                 [--dissociate] [--separate-git-dir <git dir>]
                 [--depth <depth>] [--[no-]single-branch] [--no-tags]
                 [--recurse-submodules[=<pathspec>]] [--[no-]shallow-submodules]
                 [--[no-]remote-submodules] [--jobs <n>] [--sparse] [--] <repository>
                 [<directory>]
DESCRIPTION
       Clones a repository into a newly created directory, creates remote-tracking branches for each branch in the cloned repository (visible using git
       branch --remotes), and creates and checks out an initial branch that is forked from the cloned repository's currently active branch.
       After the clone, a plain git fetch without arguments will update all the remote-tracking branches, and a git pull without arguments will in addition
       merge the remote master branch into the current master branch, if any (this is untrue when "--single-branch" is given; see below).
       This default configuration is achieved by creating references to the remote branch heads under refs/remotes/origin and by initializing
       remote.origin.url and remote.origin.fetch configuration variables.
mei@4144e8c22fff:~$
```

可以看到，三种方式都可以获取到帮助信息。

- 带连字符的命令

从历史上来看，Git是作为一套简单的、独特的、独立的命令提供的，并按照UNIX工具包的哲学来开发的：打造小的、可互操作的工具。每条命令都留有一个带连字符的名字，如`git-commit`和`git-log`。而现在开发人员之间的趋势是使用一条简单的可执行的`git`命令并附加上子命令。但话虽如此，`git-commit`和`git commit`形式上是相同的。

```sh
root@4144e8c22fff:~# find / -name 'git-commit'
/usr/lib/git-core/git-commit
root@4144e8c22fff:~# ls -lah /usr/lib/git-core/
total 26M
drwxr-xr-x 3 root root  24K Jul 10 00:51 .
drwxr-xr-x 1 root root 4.0K Jul 11 15:02 ..
-rwxr-xr-x 1 root root 3.0M Mar  4 13:01 git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-add -> git
-rwxr-xr-x 1 root root  46K Mar  4 13:01 git-add--interactive
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-am -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-annotate -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-apply -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-archive -> git
-rwxr-xr-x 1 root root 8.1K Mar  4 13:01 git-bisect
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-bisect--helper -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-blame -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-branch -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-bundle -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-cat-file -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-check-attr -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-check-ignore -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-check-mailmap -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-check-ref-format -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-checkout -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-checkout-index -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-cherry -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-cherry-pick -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-clean -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-clone -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-column -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-commit -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-commit-graph -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-commit-tree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-config -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-count-objects -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-credential -> git
-rwxr-xr-x 1 root root 1.7M Mar  4 13:01 git-credential-cache
-rwxr-xr-x 1 root root 1.7M Mar  4 13:01 git-credential-cache--daemon
-rwxr-xr-x 1 root root 1.7M Mar  4 13:01 git-credential-store
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-daemon
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-describe -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-diff -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-diff-files -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-diff-index -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-diff-tree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-difftool -> git
-rwxr-xr-x 1 root root 2.2K Mar  4 13:01 git-difftool--helper
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-env--helper -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fast-export -> git
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-fast-import
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fetch -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fetch-pack -> git
-rwxr-xr-x 1 root root  16K Mar  4 13:01 git-filter-branch
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fmt-merge-msg -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-for-each-ref -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-format-patch -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fsck -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-fsck-objects -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-gc -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-get-tar-commit-id -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-grep -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-hash-object -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-help -> git
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-http-backend
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-http-fetch
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-http-push
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-imap-send
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-index-pack -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-init -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-init-db -> git
-rwxr-xr-x 1 root root  22K Mar  4 13:01 git-instaweb
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-interpret-trailers -> git
-rwxr-xr-x 1 root root  17K Mar  4 13:01 git-legacy-stash
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-log -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-ls-files -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-ls-remote -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-ls-tree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-mailinfo -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-mailsplit -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-base -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-file -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-index -> git
-rwxr-xr-x 1 root root 2.5K Mar  4 13:01 git-merge-octopus
-rwxr-xr-x 1 root root 3.7K Mar  4 13:01 git-merge-one-file
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-ours -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-recursive -> git
-rwxr-xr-x 1 root root  944 Mar  4 13:01 git-merge-resolve
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-subtree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-merge-tree -> git
-rwxr-xr-x 1 root root  11K Mar  4 13:01 git-mergetool
-rw-r--r-- 1 root root 9.0K Mar  4 13:01 git-mergetool--lib
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-mktag -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-mktree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-multi-pack-index -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-mv -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-name-rev -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-notes -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-pack-objects -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-pack-redundant -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-pack-refs -> git
-rw-r--r-- 1 root root 2.6K Mar  4 13:01 git-parse-remote
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-patch-id -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-prune -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-prune-packed -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-pull -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-push -> git
-rwxr-xr-x 1 root root 3.7K Mar  4 13:01 git-quiltimport
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-range-diff -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-read-tree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-rebase -> git
-rw-r--r-- 1 root root  29K Mar  4 13:01 git-rebase--preserve-merges
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-receive-pack -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-reflog -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-remote -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-remote-ext -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-remote-fd -> git
lrwxrwxrwx 1 root root   15 Mar  4 13:01 git-remote-ftp -> git-remote-http
lrwxrwxrwx 1 root root   15 Mar  4 13:01 git-remote-ftps -> git-remote-http
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-remote-http
lrwxrwxrwx 1 root root   15 Mar  4 13:01 git-remote-https -> git-remote-http
-rwxr-xr-x 1 root root 1.8M Mar  4 13:01 git-remote-testsvn
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-repack -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-replace -> git
-rwxr-xr-x 1 root root 4.1K Mar  4 13:01 git-request-pull
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-rerere -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-reset -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-restore -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-rev-list -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-rev-parse -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-revert -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-rm -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-send-pack -> git
-rw-r--r-- 1 root root 2.4K Mar  4 13:01 git-sh-i18n
-rwxr-xr-x 1 root root 1.7M Mar  4 13:01 git-sh-i18n--envsubst
-rw-r--r-- 1 root root  17K Mar  4 13:01 git-sh-prompt
-rw-r--r-- 1 root root 9.1K Mar  4 13:01 git-sh-setup
-rwxr-xr-x 1 root root 1.7M Mar  4 13:01 git-shell
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-shortlog -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-show -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-show-branch -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-show-index -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-show-ref -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-sparse-checkout -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-stage -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-stash -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-status -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-stripspace -> git
-rwxr-xr-x 1 root root  26K Mar  4 13:01 git-submodule
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-submodule--helper -> git
-rwxr-xr-x 1 root root  18K Mar  4 13:01 git-subtree
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-switch -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-symbolic-ref -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-tag -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-unpack-file -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-unpack-objects -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-update-index -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-update-ref -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-update-server-info -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-upload-archive -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-upload-pack -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-var -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-verify-commit -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-verify-pack -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-verify-tag -> git
-rwxr-xr-x 1 root root 4.3K Mar  4 13:01 git-web--browse
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-whatchanged -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-worktree -> git
lrwxrwxrwx 1 root root    3 Mar  4 13:01 git-write-tree -> git
drwxr-xr-x 2 root root 4.0K Jul 10 00:51 mergetools
```

可以看到大部分的`git`连字符命令都软链接到了`git`命令。

- 短选项与长选项

Git的命令能够理解短选项和长选项。如，`git commit`命令将下面两条命令视为等价的。

```sh
# 短选项
$ git commit -m "Fixed a type."

# 长选项
$ git commit --message="Fixed a type."
```

注意，有些选项只有一种形式。



- 祼双破折号的使用

可以使用祼双破折号的约定来分离一系列参数。

例如，使用双破折号来分离命令行的控制部分与操作数部分，如文件名。

```sh
$ git diff -w master origin -- tools/Makefile
```

你也可能需要使用双破折号分离并显示标识文件名，否则会认为它们是命令的另一部分。如，如果你碰巧有一个文件名和一个标签都叫做`main.c`，然后你会看到不同的行为：

```sh
# 检出main.c标签
$ git checkout main.c

# 检出文件main.c
$ git checkout -- main.c
```

为了测试这种不同的行为，我们在码云上面创建一个测试仓库 [https://gitee.com/meizhaohui/testgit](https://gitee.com/meizhaohui/testgit) , 并在其中创建一个`main.c`的标签，并增加一个`main.c`文件。

配置完成后，我们尝试使用`https`形式下载代码：

```sh
mei@4144e8c22fff:~$ git clone https://gitee.com/meizhaohui/testgit.git
Cloning into 'testgit'...
Username for 'https://gitee.com': meizhaohui
Password for 'https://meizhaohui@gitee.com':
remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 8 (delta 1), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (8/8), 1.64 KiB | 129.00 KiB/s, done.
mei@4144e8c22fff:~$
```

此时需要输入用户名和密码。



测试使用破折号与不使用的区别：

```sh
mei@4144e8c22fff:~$ ls
testgit
mei@4144e8c22fff:~$ cd testgit/
mei@4144e8c22fff:~/testgit$ ls
README.en.md  README.md  main.c
mei@4144e8c22fff:~/testgit$ git remote -v
origin	https://gitee.com/meizhaohui/testgit.git (fetch)
origin	https://gitee.com/meizhaohui/testgit.git (push)

# 使用双破折号，不会切换分支，只是尝试检出文件
mei@4144e8c22fff:~/testgit$ git checkout -- main.c
mei@4144e8c22fff:~/testgit$ ls
README.en.md  README.md  main.c

# 分支信息是master
mei@4144e8c22fff:~/testgit$ git branch
* master
mei@4144e8c22fff:~/testgit$ git checkout main.c
Note: switching to 'main.c'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at 31d636a Initial commit

# 修改一下配置
mei@4144e8c22fff:~/testgit$ git config advice.detachedHead false

# 检出main.c标签
mei@4144e8c22fff:~/testgit$ git checkout main.c
HEAD is now at 31d636a Initial commit

# 此时可以发现文件发生了变化
mei@4144e8c22fff:~/testgit$ ls
README.en.md  README.md
mei@4144e8c22fff:~/testgit$

# 当前分支也发生变化
mei@4144e8c22fff:~/testgit$ git branch
* (HEAD detached at main.c)
  master
mei@4144e8c22fff:~/testgit$ git tag
main.c
```

该示例可以说明，是否使用双破折号，命令的效果不一样！

### 3.2 Git使用快速入门

为了实际见识Git的操作，我们新建一个版本库，添加一些内容，然后管理一些修订版本。

- `git init`将目录转换成Git版本库。

```sh
mei@4144e8c22fff:~$ mkdir public_html
mei@4144e8c22fff:~$ cd public_html/
mei@4144e8c22fff:~/public_html$ echo 'My website is alive!' > index.html
mei@4144e8c22fff:~/public_html$ git init
Initialized empty Git repository in /home/mei/public_html/.git/
mei@4144e8c22fff:~/public_html$ ls -lah
total 16K
drwxrwxr-x 3 mei mei 4.0K Jul 15 13:00 .
drwxr-xr-x 4 mei mei 4.0K Jul 15 12:59 ..
drwxrwxr-x 7 mei mei 4.0K Jul 15 13:00 .git
-rw-rw-r-- 1 mei mei   21 Jul 15 13:00 index.html
```

可以看到`git init`会创建一个隐藏目录，在项目的顶层目录，名为`.git`。Git把所有修订信息都放在这唯一的顶层`.git`目录中。隐藏在`.git`目录内的版本库由Git维护。

- `git add`将文件添加到版本库中。
- `git status`查看当前状态。

```sh
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	index.html

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/public_html$ git add index.html
mei@4144e8c22fff:~/public_html$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   index.html

mei@4144e8c22fff:~/public_html$
```

此时，Git会将`index.html`文件暂存(Staged)起来，这是提交之前的中间步骤。

- `git commit`提交。

```sh
mei@4144e8c22fff:~/public_html$ git commit -m"Initial contents of public_html"

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'mei@4144e8c22fff.(none)')
mei@4144e8c22fff:~/public_html$
```

可以看到，直接使用`git commit`提交，不提供用户名和邮箱信息时，Git不知道你是谁，因此必须指定姓名和邮箱地址。

通过`git commit`的帮助文档我们可以知道，可以指定`--author`参数来强制更新作者信息：

```sh
mei@4144e8c22fff:~/public_html$ git commit --help|grep -A 2 "\-\-author"
                  [--allow-empty-message] [--no-verify] [-e] [--author=<author>]
                  [--date=<date>] [--cleanup=<mode>] [--[no-]status]
                  [-i | -o] [--pathspec-from-file=<file> [--pathspec-file-nul]]
--
       --author=<author>
           Override the commit author. Specify an explicit author using the standard A U Thor <author@example.com> format. Otherwise <author> is assumed to
           be a pattern and is used to search for an existing commit by that author (i.e. rev-list --all -i --author=<author>); the commit author is then
           copied from the first such commit found.

mei@4144e8c22fff:~/public_html$
```

我们尝试在提交时使用`--author`参数：

```sh
mei@4144e8c22fff:~/public_html$ git commit -m"Initial contents of public_html" --author="Zhaohui Mei <mzh.whut@gmail.com>"

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'mei@4144e8c22fff.(none)')
```

可以看到，在Git新版本中，直接使用`--author`参数仍然会提示异常。

### 3.3 配置提交作者信息

虽然我们可以通过在`git commit`中指定`--author`参数，但更常用的方法是，在全局指定用户名和邮箱信息，正如上面提示的信息那样，使用以下命令：

```sh
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

我们在全局配置一下作者信息，如我的邮箱地址是`mzh@hellogitlab.com`，用户名是`Zhaohui Mei`，则全局配置命令如下：

```sh
# 配置邮箱
mei@4144e8c22fff:~$ git config --global user.email "mzh@hellogitlab.com"
# 配置用户名
mei@4144e8c22fff:~$ git config --global user.name "Zhaohui Mei"
# 查看全局配置信息
mei@4144e8c22fff:~$ git config --global --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
```

此时，我们再尝试使用`git commit`来设置`--author`参数提交：

```sh
mei@4144e8c22fff:~/public_html$ git commit -m"Initial contents of public_html" --author="Zhaohui Mei <mzh.whut@gmail.com>"
[master (root-commit) daa3d7d] Initial contents of public_html
 Author: Zhaohui Mei <mzh.whut@gmail.com>
 1 file changed, 1 insertion(+)
 create mode 100644 index.html
 
# 查看提交日志信息 
mei@4144e8c22fff:~/public_html$ git log -n 1
commit daa3d7d538f64637f2b475015ed6858324f17223 (HEAD -> master)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Jul 17 01:20:00 2021 +0000

    Initial contents of public_html
mei@4144e8c22fff:~/public_html$
```

可以看到，已经正常提交成功了，并且作者信息使用的是命令行参数中指定的作者信息，而不是默认全局的用户名和邮箱信息。



为了验证是否可以通过`GIT_AUTHOR_NAME`和`GIT_AUTHOR_EMAIL`环境变量的方式来设置用户名和邮箱信息，我们先将全局配置的用户名和邮箱信息给移除掉：

```sh
# 查看全局配置信息
mei@4144e8c22fff:~$ git config --global --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei

# 删除全局配置项
mei@4144e8c22fff:~$ git config --global --unset user.email
mei@4144e8c22fff:~$ git config --global --unset user.name

# 再次查看全局配置信息
mei@4144e8c22fff:~$ git config --global --list
```

可以看到现在已经没有全局配置项了。



我们对`index.html`进行一些修改：

```sh
# 查看修改后的文件内容
mei@4144e8c22fff:~/public_html$ cat index.html
<html>
<body>
My website is alive!
</body>
</html>
mei@4144e8c22fff:~/public_html$ 

# 查看修改差异
mei@4144e8c22fff:~/public_html$ git diff
diff --git a/index.html b/index.html
index 34217e9..8638631 100644
--- a/index.html
+++ b/index.html
@@ -1 +1,5 @@
+<html>
+<body>
 My website is alive!
+</body>
+</html>
```

此时，我们再次进行提交，但在提交时，指定一下`GIT_AUTHOR_NAME`和`GIT_AUTHOR_EMAIL`环境变量：

```sh
mei@4144e8c22fff:~/public_html$ GIT_AUTHOR_EMAIL="mzh.whut@gmail.com" && GIT_AUTHOR_NAME="meizhaohui" && git commit -m"Convert to HTML" index.html

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'mei@4144e8c22fff.(none)')
mei@4144e8c22fff:~/public_html$ git commit -m"Convert to HTML" index.html

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'mei@4144e8c22fff.(none)')
```

此时，可以看到，提交失败，仍然提示需要配置全局用户名和邮箱。因此我按上面的方式再次把全局用户名和邮箱配置好：

```sh
mei@4144e8c22fff:~$ git config --global user.email "mzh@hellogitlab.com"
mei@4144e8c22fff:~$ git config --global user.name "Zhaohui Mei"
mei@4144e8c22fff:~$ git config --global --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
```

再次使用环境变量的方式进行提交：

```sh
mei@4144e8c22fff:~/public_html$ GIT_AUTHOR_EMAIL="mzh.whut@gmail.com" && GIT_AUTHOR_NAME="meizhaohui" && git commit -m"Convert to HTML" index.html
[master b7dc136] Convert to HTML
 1 file changed, 4 insertions(+)
mei@4144e8c22fff:~/public_html$ git log -n 1
commit b7dc13619a73fa49fe7ea0b9284bcb277717a984 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sat Jul 17 01:44:07 2021 +0000

    Convert to HTML
mei@4144e8c22fff:~/public_html$ echo $GIT_AUTHOR_NAME
meizhaohui
mei@4144e8c22fff:~/public_html$ echo $GIT_AUTHOR_EMAIL
mzh.whut@gmail.com
```

此处可以看到，设定的环境变量在提交过程中没有起作用，因为日志信息中作者信息是`Author: Zhaohui Mei <mzh@hellogitlab.com>`，与我们设定的环境变量不一样。

### 3.4 查看提交信息

- `git log`命令会产生版本库里一系列单独提交的历史信息。

我们刚才已经进行了两次提交，我们查看一下：

```sh
mei@4144e8c22fff:~/public_html$ git log
commit b7dc13619a73fa49fe7ea0b9284bcb277717a984 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sat Jul 17 01:44:07 2021 +0000

    Convert to HTML

commit daa3d7d538f64637f2b475015ed6858324f17223
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Jul 17 01:20:00 2021 +0000

    Initial contents of public_html
mei@4144e8c22fff:~/public_html$
```

条目按时间逆序罗列出来(*严格来说，它们不是按照时间顺序，而是提交的拓扑顺序排列*)，每条信息显示了提交作者的名字和邮箱地址，提交日期，哟赶紧去的日志信息以及提交的内部识别码(也就是commit id)。

- `git show <commit_id>`命令可以查看特定提交的更加详细的信息。

```sh
mei@4144e8c22fff:~/public_html$ git show
commit b7dc13619a73fa49fe7ea0b9284bcb277717a984 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sat Jul 17 01:44:07 2021 +0000

    Convert to HTML

diff --git a/index.html b/index.html
index 34217e9..8638631 100644
--- a/index.html
+++ b/index.html
@@ -1 +1,5 @@
+<html>
+<body>
 My website is alive!
+</body>
+</html>
mei@4144e8c22fff:~/public_html$ git show daa3d7d538f64637f2b475015ed6858324f17223
commit daa3d7d538f64637f2b475015ed6858324f17223
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Jul 17 01:20:00 2021 +0000

    Initial contents of public_html

diff --git a/index.html b/index.html
new file mode 100644
index 0000000..34217e9
--- /dev/null
+++ b/index.html
@@ -0,0 +1 @@
+My website is alive!
mei@4144e8c22fff:~/public_html$
```

如果在`git show`命令中未指定commit_id，则会显示最近一次提交的详细信息。

- `git show-branch`,查看当前开发分支简洁的单行摘要信息。

```sh
mei@4144e8c22fff:~/public_html$ git show-branch
[master] Convert to HTML
mei@4144e8c22fff:~/public_html$ git show-branch --more=10
[master] Convert to HTML
[master^] Initial contents of public_html
mei@4144e8c22fff:~/public_html$
mei@4144e8c22fff:~/public_html$ git branch
* master
```

不带参数时，默认只列出最新的提交。`--more=10`参数表示额外显示10个版本。

### 3.5 查看提交差异

- `git diff`命令可以查看差异信息。

```sh
mei@4144e8c22fff:~/public_html$ git log |grep ^commit
commit b7dc13619a73fa49fe7ea0b9284bcb277717a984
commit daa3d7d538f64637f2b475015ed6858324f17223
mei@4144e8c22fff:~/public_html$ git diff daa3d7d538f64637f2b475015ed6858324f17223 b7dc13619a73fa49fe7ea0b9284bcb277717a984
diff --git a/index.html b/index.html
index 34217e9..8638631 100644
--- a/index.html
+++ b/index.html
@@ -1 +1,5 @@
+<html>
+<body>
 My website is alive!
+</body>
+</html>
mei@4144e8c22fff:~/public_html$
```

比较两个版本时，将较早的版本放在命令行的前面，较新的版本放在命令行的后面。

这个输出与`diff`程序的输出非常相似。

不要担心那些十六进制数字，Git提供了许多更短、更简单的方式来执行这样的命令，而无须产生这样大而复杂的数字。

### 3.6 版本库内文件的删除和重命名

- `git rm filename`删除文件。
- `git mv filename1 filename2`重命名文件。

任何一情况下，暂存的变更必须随后进行提交。

### 3.7 创建版本库副本

- 可以使用`git clone`命令创建版本库的一个完整的副本，或叫克隆。这使得世界各地的人可以通过Git在相同的文件上从事他们喜欢的项目，并保持与其他版本库同步。

我们可以在主目录创建一个`public_html`的副本，命名为`my_website`：

```sh
mei@4144e8c22fff:~/public_html$ cd
mei@4144e8c22fff:~$ git clone public_html my_website
Cloning into 'my_website'...
done.
mei@4144e8c22fff:~$
mei@4144e8c22fff:~$ cd my_website/
mei@4144e8c22fff:~/my_website$ git log
commit b7dc13619a73fa49fe7ea0b9284bcb277717a984 (HEAD -> master, origin/master, origin/HEAD)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sat Jul 17 01:44:07 2021 +0000

    Convert to HTML

commit daa3d7d538f64637f2b475015ed6858324f17223
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Jul 17 01:20:00 2021 +0000

    Initial contents of public_html
mei@4144e8c22fff:~/my_website$ ls
index.html
mei@4144e8c22fff:~/my_website$ cat index.html
<html>
<body>
My website is alive!
</body>
</html>
```

可以看到`my_website`中的文件内容与`public_html`文件夹里面完全一样，日志信息也是一样的。

更通用的是，我们使用`git clone`命令来下载远程的Git仓库代码。如：

```sh
mei@4144e8c22fff:~$ git clone git@gitee.com:meizhaohui/git.git
Cloning into 'git'...
The authenticity of host 'gitee.com (180.97.125.228)' can't be established.
ECDSA key fingerprint is SHA256:FQGC9Kn/eye1W8icdBgrQp+KkGYoFgbVr17bmjey0Wc.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'gitee.com,180.97.125.228' (ECDSA) to the list of known hosts.
git@gitee.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
mei@4144e8c22fff:~$ git clone https://gitee.com/meizhaohui/git.git
Cloning into 'git'...
remote: Enumerating objects: 309613, done.
remote: Counting objects: 100% (309613/309613), done.
remote: Compressing objects: 100% (76164/76164), done.
remote: Total 309613 (delta 231105), reused 309613 (delta 231105), pack-reused 0
Receiving objects: 100% (309613/309613), 163.07 MiB | 6.58 MiB/s, done.
Resolving deltas: 100% (231105/231105), done.
mei@4144e8c22fff:~$
```

通过该方式下载了Git的源码！一个Git源码的版本库副本就在本地创建好了！！



### 3.8 配置文件

- `/etc/gitconfig`，系统级配置文件，不一定存在，可通过`git config --system`来修改，优先级最低。
- `~/.gitconfig`，用户级配置文件，可用`git config --global`来修改，优先级比系统级配置文件高。
- `.git/config`，版本库特定的配置文件，可以通过`git config --local`来修改，优先级最高。

```sh
# 查看系统级配置信息
mei@4144e8c22fff:~/public_html$ git config --system --list
fatal: unable to read config file '/etc/gitconfig': No such file or directory

# 查看用户级配置信息
mei@4144e8c22fff:~/public_html$ git config --global --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei

# 查看版本库配置信息
mei@4144e8c22fff:~/public_html$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
```

尝试修改版本库特定配置信息：

```sh
# 查看版本库配置文件内容
mei@4144e8c22fff:~/public_html$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
mei@4144e8c22fff:~/public_html$ 	

# 查看版本库配置项
mei@4144e8c22fff:~/public_html$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
mei@4144e8c22fff:~/public_html$ 

# 更新版本库配置项信息
mei@4144e8c22fff:~/public_html$ git config --local user.name meizhaohui

# 查看版本库配置项
mei@4144e8c22fff:~/public_html$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
user.name=meizhaohui
mei@4144e8c22fff:~/public_html$ 

# 查看版本库配置文件
mei@4144e8c22fff:~/public_html$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[user]
	name = meizhaohui
```

可以发现版本库配置文件中已经增加了配置内容。



查看用户级配置文件内容：

```sh
mei@4144e8c22fff:~$ cat ~/.gitconfig
[user]
	email = mzh@hellogitlab.com
	name = Zhaohui Mei
mei@4144e8c22fff:~$
```

配置帮助信息：

```sh
mei@4144e8c22fff:~$ git config
usage: git config [<options>]

Config file location
    --global              use global config file
    --system              use system config file
    --local               use repository config file
    --worktree            use per-worktree config file
    -f, --file <file>     use given config file
    --blob <blob-id>      read config from given blob object

Action
    --get                 get value: name [value-regex]
    --get-all             get all values: key [value-regex]
    --get-regexp          get values for regexp: name-regex [value-regex]
    --get-urlmatch        get value specific for the URL: section[.var] URL
    --replace-all         replace all matching variables: name value [value_regex]
    --add                 add a new variable: name value
    --unset               remove a variable: name [value-regex]
    --unset-all           remove all matches: name [value-regex]
    --rename-section      rename section: old-name new-name
    --remove-section      remove a section: name
    -l, --list            list all
    -e, --edit            open an editor
    --get-color           find the color configured: slot [default]
    --get-colorbool       find the color setting: slot [stdout-is-tty]

Type
    -t, --type <>         value is given this type
    --bool                value is "true" or "false"
    --int                 value is decimal number
    --bool-or-int         value is --bool or --int
    --path                value is a path (file or directory name)
    --expiry-date         value is an expiry date

Other
    -z, --null            terminate values with NUL byte
    --name-only           show variable names only
    --includes            respect include directives on lookup
    --show-origin         show origin of config (file, standard input, blob, command line)
    --default <value>     with --get, use default value when missing entry

mei@4144e8c22fff:~$
```

直接使用`git config`可以获取配置相关的简短的帮助信息，如果使用`git config --help`可以获取配置的详细帮助信息。

```sh
mei@4144e8c22fff:~$ git config --help|head
GIT-CONFIG(1)                                                             Git Manual                                                            GIT-CONFIG(1)

NAME
       git-config - Get and set repository or global options

SYNOPSIS
       git config [<file-option>] [--type=<type>] [--show-origin] [-z|--null] name [value [value_regex]]
       git config [<file-option>] [--type=<type>] --add name value
       git config [<file-option>] [--type=<type>] --replace-all name value [value_regex]
       git config [<file-option>] [--type=<type>] [--show-origin] [-z|--null] --get name [value_regex]
mei@4144e8c22fff:~$
mei@4144e8c22fff:~$ git config --help|wc
   3515   31555  230642
```

可以看到，`git config`有3515行的帮助信息！！非常详细。

- 移除配置项`git config --unset`。

我们可以使用`git config --unset`命令来移除某些不需要的配置项。如我们将刚才在版本库级别配置的用户名给移除掉：

```sh
mei@4144e8c22fff:~/public_html$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
user.name=meizhaohui
mei@4144e8c22fff:~/public_html$ git config --local --unset user.name
mei@4144e8c22fff:~/public_html$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
mei@4144e8c22fff:~/public_html$
mei@4144e8c22fff:~/public_html$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
```

可以看到，配置文件中的配置内容被清理掉，从命令行中查看配置项列表中`user.name`也被清除掉了。

### 3.9 设置别名

正如Linux操作系统中可以使用别名一样，我们在Git中也可以使用别名。如果你经常输入一条常用而复杂的Git命令，你可以考虑为它设置一个简单的Git别名，或者使用Linux别名。

- 不使用别名时，执行命令

```sh
mei@4144e8c22fff:~/public_html$ git log --graph --abbrev-commit --pretty=oneline
* b7dc136 (HEAD -> master) Convert to HTML
* daa3d7d Initial contents of public_html
```

可以发现命令比较长，还容易打错。

- 通过Git设置别名

我们如果想将上面的长命令设置一个`git simple`的简单命令，则可以按如下方式操作：

```sh
# 第一步，看别名是否被占用
mei@4144e8c22fff:~/public_html$ git simple
git: 'simple' is not a git command. See 'git --help'.

# 可以发现上述simple命令没有被占用
# 设置别名，注意，别名中引号内部不需要git开头
mei@4144e8c22fff:~/public_html$ git config --global alias.simple 'log --graph --abbrev-commit --pretty=oneline'

# 查看配置项
mei@4144e8c22fff:~/public_html$ git config --global --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
alias.simple=log --graph --abbrev-commit --pretty=oneline

# 使用别名查看提交信息
mei@4144e8c22fff:~/public_html$ git simple
* b7dc136 (HEAD -> master) Convert to HTML
* daa3d7d Initial contents of public_html
```

要以看到别名设置后，马上就可以使用了。



- 通过Linux alias设置别名

我们也可以通过Linux `alias`命令来设置别名。如我经常使用`git status`查看当前版本库的状态，我们可以设置一个别名`gs`:

```
mei@4144e8c22fff:~/public_html$ git status
On branch master
nothing to commit, working tree clean
mei@4144e8c22fff:~/public_html$ alias gs='git status'
mei@4144e8c22fff:~/public_html$ gs
On branch master
nothing to commit, working tree clean
```

如果想让`alias`配置的命令永久有效，则可以在`~/.bashrc`配置中加入上述命令。

我们也可以为`git log --graph --abbrev-commit --pretty=oneline`命令设置一个别名`gg`。

使用`vim ~/.bashrc`编译配置文件，在最后增加以下别名：

```sh
alias v.='vim ~/.bashrc'
alias s.='source ~/.bashrc && echo "Reload OK"'
alias gs='git status'
alias gg='git log --graph --abbrev-commit --pretty=oneline'
```

退出后，查看配置文件：

```sh
mei@4144e8c22fff:~/public_html$ tail -n 4 ~/.bashrc
alias v.='vim ~/.bashrc'
alias s.='source ~/.bashrc && echo "Reload OK"'
alias gs='git status'
alias gg='git log --graph --abbrev-commit --pretty=oneline'
```

使用`source ~/.bashrc`重新加载配置文件。

```sh
mei@4144e8c22fff:~/public_html$ source ~/.bashrc
mei@4144e8c22fff:~/public_html$ s.
Reload OK
mei@4144e8c22fff:~/public_html$ gg
* b7dc136 (HEAD -> master) Convert to HTML
* daa3d7d Initial contents of public_html
mei@4144e8c22fff:~/public_html$ gs
On branch master
nothing to commit, working tree clean
mei@4144e8c22fff:~/public_html$
```

此时，可以看到，使用`alias`配置的更简单的命令已经生效了！

这两种方式都可以配置命令的别名。我更喜欢使用Linux `alias`命令来配置别名，可以配置更简短的别名，相比Git的别名，我可以少输入`git `等字符！

## 第4章 基本的Git概念

### 4.1 基本概念

#### 4.1.1 版本库

- Git版本库(repository)只是一个简单的数据库，其中包含所有用来维护与管理项目的修订版本和历史的信息。
- 一个版本库维护项目整个生命周期的完整副本。
- Git版本库不仅仅提供版本库中所有文件的完整副本，还提供版本库本身的副本。
- Git在每个版本库里维护一组配置项。如版本库的用户名和邮箱地址信息。
- Git在把一个版本库克隆clone或者复制到另一个版本库的时候，配置设置不会跟着转移。
- 在版本库中，Git维护两个主要的数据结构：**对象库object store**和**索引index**。所有这些版本库数据存放在工作目录根目录下的.git的隐藏子目录中。

#### 4.1.2 Git对象类型

对象库是Git版本库实现的心脏。它包含用户的原始数据文件和所有日志信息、作者信息、日期，以及其他用来重建项目任意版本或分支的信息。

Git放在对象库中的对象只有4种类型：块blob，目录树tree，提交commit，标签tag。这4种原子对象构成Git高层数据结构的基础。

- 块blob: 文件的每一个版本表示为一个块(blob)。 blob是二进制大对象 *binary large object*的缩写。用来指代某些可以包含任意数据的变量或文件，同时其内部结构会被程序忽略。一个blob被视为一个墨盒。一个blob保存一个文件的数据，但不包含任何关于这个文件的元数据，甚至连文件名也没有。
- 目录树tree: 一个目录树tree对象代表一层目录信息。它记录blob标识符、路径名和在一个目录里所有文件的一些元数据。它也可以递归引用其他目录树或子树对象，从而建立一个包含文件和子目录的完整层次结构。
- 提交commit: 一个提交commit对象保存版本库中每一次变化的元数据，包括作者、提交者、提交日期和日志消息。每一个提交对象指向一个目录树对象，这个目录树对象在一张完整的快照中捕获提交时版本库的状态。最初的提交或者根提交(root commit)是没有父提交的。大多数提交都有一个父提交。
- 标签tag: 一个标签对象分配一个任意的且人类可读的名字给一个特定对象，通常是一个提交对象。虽然像commit-id那样指的是一个确切且定义好的提交，但是一个更熟悉的标签名(如:v1.1.0)可能会更有意义。

随意时间的推移，所有信息在对象库中会变化和增长，项目的编辑、添加和删除都会被跟踪和建模。为了有效地利用磁盘空间和网络带宽，Git把对象压缩并存储在打包文件 *(pack file)* 里，这些文件也在对象库里。





#### 4.1.3 索引

- 索引是一个临时的、动态的二进制文件。它描述整个版本库的目录结构。
- 索引捕获项目在某个时刻的整体结构的一个版本。
- 项目的状态可以用一个提交和一棵目录树表示，它可以来自项目历史中的任意时刻，也可以是你正在开发的未来状态。
- 工作原理：当你通过执行Git命令在索引中暂存stage变更，这些变更通常是添加、删除或者编辑某个文件或某些文件。索引会记录和保存那些变更，保障它们的安全直到你准备好提交了。还可以删除或者替换索引中的变更。索引支持一个由你主导的从复杂的版本库状态到一个可推测的更好状态的逐步过渡。



#### 4.1.4 可寻址内容名称

- Git对象库被组织及实现成一个内容寻址的存储系统。
- 对象库中每个对象都有一个唯一的名称，这个名称是向对象的内容应用SHA1得到SHA1散列值。
- 一个对象的完整内容决定了该散列值，这个散列值能有效并唯一地对应特定的内容。
- 文件的任意微小变化都会导致SHA1散列值的改变，使得文件的新版本被单独编入索引。

> **SHA-1**（英语：Secure Hash Algorithm 1，中文名：安全散列算法1）是一种[密码散列函数](https://baike.baidu.com/item/密码散列函数)，[美国国家安全局](https://baike.baidu.com/item/美国国家安全局)设计，并由美国国家标准技术研究所（NIST）发布为联邦数据处理标准（FIPS）。SHA-1可以生成一个被称为消息摘要的160[位](https://baike.baidu.com/item/位)（20[字节](https://baike.baidu.com/item/字节)）散列值，散列值通常的呈现形式为40个[十六进制](https://baike.baidu.com/item/十六进制/4162457)数。

- SHA1的值是一个160位的数，通常表示为一个40位的十六进制数。有时候，在显示期间，SHA1值被简化成一个较小的、唯一的前缀。
- Git用户所说的SHA1、散列码和对象ID都是指同一个东西。

::: tip 提示

- 全局唯一标识符：SHA散列计算的一个重要特性是不管内容在哪里，它对同样的内容始终产生同样的ID。
- 换言之，在不同的目录里甚至不同机器中的相同的文件内容产生的SHA1哈希ID是完全相同的。
- 因此，文件的SHA1散列ID是一种有效的全局唯一标识符。
- 在互联网上，文件或者任意大小的blob都可以通过仅比较它们的SHA1标识符来判断是否相同。

:::





#### 4.1.5 Git追踪内容

- Git不仅仅是一个VCS，它同时也是一个内容追踪系统content tracking system。
- Git的内容追踪主要表现为两个关键的形式。
- Git的对象库基于其对象内容的散列计算的值，而不是基于用户原始文件布局的文件名或目录名设置。因此，当Git放置一个文件到对象库中的时候，它基于数据的散列而不是文件名。事实上，Git并不追踪那些和文件次相关的文件名或者目录名。
- Git追踪的是内容而不是文件。
- **如果两个文件的内容完全一样，无论是否在相同的目录，Git在对象库里只保存一份blob形式的内容副本。** Git仅根据文件内容来计算每一个文件的散列值，如果文件有相同的SHA1值，它们的内容就是相同的，然后将这个blob对象放到对象库里，并以SHA1值作为索引。项目中的这两个文件，不管它们在用户的目录结构中处于什么位置，都使用那个相同的对象提供其内容。如果这些文件中的一个发生了变化，Git会为它计算一个新的SHA1值，识别出它现在是一个不同的blob对象，然后把这个新的blob加到对象库里。原来的blob在对象库里保持不变，为没有变化的文件所使用。
- 当文件从一个版本变到下一个版本的时候，Git的内部数据库有效地存储每个文件的每个版本，而不是它们的差异。因为Git使用一个文件的全部内容的散列值作为文件名，所以它必须对每个文件的完整副本进行操作。Git不能将工作或者对象库条目建立在文件内容的一部分或者文件的两个版本之间的差异上。





#### 4.1.6 路径名与内容

- Git需要维护一个明确的文件列表来组成版本库的内容。
- Git把文件名视为一段区别于文件内容的数据。
- Git仅仅记录每个路径名，并且确保能通过它的内容精确地重建文件和目录，这些是由散列值过索引的。
- Git的物理数据布局并不模仿用户的文件目录结构。Git的内部结构是一种更高效的数据结构。



#### 4.1.7 打包文件

- Git使用了一种收做打包文件pack file的更有效的存储机制。要创建一个打包文件，Git首先定位内容非常相似的全部文件，然后为它们之一存储整个内容，之后计算相似文件之间的差异并且只存储差异。例如，如果你只添加一行到文件中，Git可能会存储新版本的全部内容，然后记录那一行的更改作为差异，并存储在包里。
- Git可以在版本库里的任何地方取出两个文件并计算差异，只要它认为它们足够相似来产生良好的数据压缩。因此，Git有一套相当复杂的算法来定位和匹配版本库中潜在的全局候选差异。
- Git还维护打包文件中表示每个完整文件(包含完整内容的文件和通过差异重建出来的文件)的原始blob的SHA1值。这给定位包内对象的索引机制提供了基础。
- 打包文件和对象库中其他对象存储在一起。它们也用于网络中版本库的高效数据传输。





### 4.2  对象库图示

- blob对象是数据结构的“底端”；它什么也不引用而且只被树对象引用。每个blob块由一个矩形表示。

- 树对象指向若干blob对象，也可能指向其他树对象。许多不同的提交对象可能指向任何给定的树对象。每个树对象由一个三角形表示。

- 一个圆圈表示一个提交对象。一个提交对象指向一个特定的树对象，并且这个树对象是由提交对象引入版本库的。

- 每个标签由一个平行四边形表示。每个标签可以指向最多一个提交对象。
- 分支不是一个基本的Git对象，但是它在命名提交对象的时候起到了至关重要的作用。把每个分支画成一个圆角矩形。



### 4.3 Git在工作时的概念

我们来创建一个新的版本库，并更详细的检查内容文件和对象库。

#### 4.3.1 创建版本库

- 使用`git init`创建一个空的版本库。

```sh
# 创建目录
mei@4144e8c22fff:~$ mkdir hello

# 切换到hello目录下
mei@4144e8c22fff:~$ cd hello/

# 创建一个空的版本库
mei@4144e8c22fff:~/hello$ git init
Initialized empty Git repository in /home/mei/hello/.git/

# 查看当前目录的所有文件
mei@4144e8c22fff:~/hello$ find .|sort
.
./.git
./.git/HEAD
./.git/branches
./.git/config
./.git/description
./.git/hooks
./.git/hooks/applypatch-msg.sample
./.git/hooks/commit-msg.sample
./.git/hooks/fsmonitor-watchman.sample
./.git/hooks/post-update.sample
./.git/hooks/pre-applypatch.sample
./.git/hooks/pre-commit.sample
./.git/hooks/pre-merge-commit.sample
./.git/hooks/pre-push.sample
./.git/hooks/pre-rebase.sample
./.git/hooks/pre-receive.sample
./.git/hooks/prepare-commit-msg.sample
./.git/hooks/update.sample
./.git/info
./.git/info/exclude
./.git/objects
./.git/objects/info
./.git/objects/pack
./.git/refs
./.git/refs/heads
./.git/refs/tags
mei@4144e8c22fff:~/hello$
```

可以看到，`.git`目录包含很多内容，这些文件是基于模板目录显示的，根据需要可以进行调整。根据使用的Git的版本，实际列表可能看起来会有一点不同。例如，旧版本的Git不对`.git/hooks`文件夹中的文件使用`.sample`后缀。

- 在一般情况下，不需要查看或者操作`.git`目录下的文件。认为这些隐藏的文件是Git底层(plumbing)或者配置的一部分。Git有一小部分命令来处理这些隐藏的文件，但是你很少会用到它们。

最初，除了几个占位符之外，`.git/objects`目录（用来存放所有Git对象的目录）是空的。

```sh
mei@4144e8c22fff:~/hello$ find .git/objects
.git/objects
.git/objects/pack
.git/objects/info
```

现在，让我们来小心地创建一个简单的对象。

```sh
# 创建一个hello.txt文件
mei@4144e8c22fff:~/hello$ echo 'hello world' > hello.txt

# 将文件加入到暂存区
mei@4144e8c22fff:~/hello$ git add .
```

此时再次查看`.git/objects`目录：

```sh
mei@4144e8c22fff:~/hello$ find .git/objects
.git/objects
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
```

可以发现已经发生变化了！



#### 4.3.1 扩展 Git是如何计算散列值的？

参考：

- [How does git compute file hashes?](https://stackoverflow.com/questions/7225313/how-does-git-compute-file-hashes)

- [Git Tip of the Week: Objects](https://alblue.bandlem.com/2011/08/git-tip-of-week-objects.html)

Git计算散列值的方法：

```
 Commit Hash (SHA1) = SHA1("blob " + <size_of_file> + "\0" + <contents_of_file>)
```

文本 "blob "是一个常量前缀，"\0" 也是一个常量并且是 NULL 字符。 `<size_of_file>`是文件长度 和 `<contents_of_file>`是文件内容， 因文件而异。

- 即Git会在文件内容前面添加一些字符，包含`blob `前缀，文件长度，"\0" ，以及文件内容。



我们来测试一下。

```sh
# 方式1，计算散列值
mei@4144e8c22fff:~/hello$ echo -e 'blob 12\0hello world'|shasum
3b18e512dba79e4c8300dd08aeb37f8e728b8dad  -

# 方式2，计算散列值，注意printf最后的\n
mei@4144e8c22fff:~/hello$ printf "blob 12\0hello world\n"|openssl dgst --sha1
(stdin)= 3b18e512dba79e4c8300dd08aeb37f8e728b8dad

# 方式3，计算散列值，使用git内置命令
mei@4144e8c22fff:~/hello$ echo 'hello world'|git hash-object --stdin
3b18e512dba79e4c8300dd08aeb37f8e728b8dad

# 方式4，直接使用git内置命令来计算文件的散列值
mei@4144e8c22fff:~/hello$ git hash-object hello.txt
3b18e512dba79e4c8300dd08aeb37f8e728b8dad

# 注意，如果字符后面不带换行符，计算出现的hash值与git实际的hash值不一样
mei@4144e8c22fff:~/hello$ echo -n 'hello world'|git hash-object --stdin
95d09f2b10159347eece71399a7e2e907ea3df4f
```



也可以直接在linux定义以下函数：

```sh
git-hash-object-test () { # substitute when the `git` command is not available
    local type=blob
    [ "$1" = "-t" ] && shift && type=$1 && shift
    # depending on eol/autocrlf settings, you may want to substitute CRLFs by LFs
    # by using `perl -pe 's/\r$//g'` instead of `cat` in the next 2 commands
    local size=$(cat $1 | wc -c | sed 's/ .*$//')
    ( echo -en "$type $size\0"; cat "$1" ) | sha1sum | sed 's/ .*$//'
}
```

测试：

```sh
mei@4144e8c22fff:~/hello$ git-hash-object-test hello.txt
3b18e512dba79e4c8300dd08aeb37f8e728b8dad
```

可以看到，与上述获取到正确的结果相同。说明这个函数也是可以正常使用的。



空文件的散列值：

```sh
# 创建空文件
mei@4144e8c22fff:~/hello$ touch empty

# 通过git自带命令计算空文件的散列值
mei@4144e8c22fff:~/hello$ git hash-object empty
e69de29bb2d1d6434b8b29ae775ad8c2e48c5391

# 通过自定义命令计算空文件的散列值
mei@4144e8c22fff:~/hello$ git-hash-object-test empty
e69de29bb2d1d6434b8b29ae775ad8c2e48c5391

# 将空文件empty删除掉
mei@4144e8c22fff:~/hello$ rm empty
```



#### 4.3.2  对象、散列和blob

当为hello.txt创建一个对象的时候，Git并不关心hello.txt的文件名。Git只关心文件里面的内容。

计算blob的SHA1散列值，把散列值的十六进制表示作为文件名放进对象库中。

- 两个不同blob产生相同SHA1散列值的机会十分渺茫。当这种情况发生的时候，称为一次碰撞。
- SHA1是安全散列加密算法。
- 对于160位数，你有2^160或者大约10^48种可能的SHA1散列值。这个数是极其巨大的，即使你雇用一万亿人来每秒产生一万亿个新的唯一blob对象，持续一万亿年，你也只有10^43个blob对象。
- 160位的SHA1散列值对应20个字节，这需要40个字节的十六进制来表示。
- Git在前两个数字后面插入一个`/`以提高文件系统效率（如果你把太多的文件放在同一个目录中，一些文件系统会变慢。使SHA1的第一个字节成为一个目录是一个很简单的办法，可以为所有均匀分布的可能对象创建一个固定的、256路分区的命令空间）。
- Git没有对文件的内容做很多事情，可以在任何时候使用散列值把它从对象库里提取出来。

查看对象库对应的文件内容：

```sh
mei@4144e8c22fff:~/hello$ git cat-file -p 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
hello world
mei@4144e8c22fff:~/hello$

# 查看该对象的类型，返回的是blob，说明是一个blob块对象
mei@4144e8c22fff:~/hello$ git cat-file -t 3b18e5
blob
```

- `git cat-file`查看存储库对象的内容。

查看`git cat-file`的帮助信息:

```sh
mei@4144e8c22fff:~/hello$ git cat-file --help|head -n 5
GIT-CAT-FILE(1)                                                           Git Manual                                                          GIT-CAT-FILE(1)

NAME
       git-cat-file - Provide content or type and size information for repository objects
mei@4144e8c22fff:~/hello$
mei@4144e8c22fff:~/hello$ git cat-file -h
usage: git cat-file (-t [--allow-unknown-type] | -s [--allow-unknown-type] | -e | -p | <type> | --textconv | --filters) [--path=<path>] <object>
   or: git cat-file (--batch | --batch-check) [--follow-symlinks] [--textconv | --filters]

<type> can be one of: blob, tree, commit, tag
    -t                    show object type
    -s                    show object size
    -e                    exit with zero when there's no error
    -p                    pretty-print object's content
    --textconv            for blob objects, run textconv on object's content
    --filters             for blob objects, run filters on object's content
    --path <blob>         use a specific path for --textconv/--filters
    --allow-unknown-type  allow -s and -t to work with broken/corrupt objects
    --buffer              buffer --batch output
    --batch[=<format>]    show info and content of objects fed from the standard input
    --batch-check[=<format>]
                          show info about objects fed from the standard input
    --follow-symlinks     follow in-tree symlinks (used with --batch or --batch-check)
    --batch-all-objects   show all objects with --batch or --batch-check
    --unordered           do not order --batch-all-objects output

mei@4144e8c22fff:~/hello$
```



Git知道手动输入40个字符是很不切实际的，因此它提供了一个命令通过对象的唯一前缀来查找对象的散列值。

```sh
mei@4144e8c22fff:~/hello$ git rev-parse 3b18
3b18e512dba79e4c8300dd08aeb37f8e728b8dad
mei@4144e8c22fff:~/hello$ git rev-parse 3b18e5
3b18e512dba79e4c8300dd08aeb37f8e728b8dad
```



#### 4.3.3  文件和树

既然`hello world`那个blob块已经安置在对象库里了，那么它的文件名又发生了什么事呢？如果不能通过文件名找到文件Git就太没用了。

- 正如前面提到的，Git通过另一种叫做 **目录树tree** 的对象来跟踪文件的路径名。当使用`git add`命令时，Git会给添加的每个文件的内容创建一个对象，但它并不会马上为树创建一个对象。相反，索引更新了，索引位于`.git/index`中，它跟踪文件的路径名和相应的blob。
- 每次执行命令(比如,`git add`、`git rm`或者`git mv`)的时候，Git会用新的路径名和blob信息来更新索引。
- 任何时间都可以从当前索引创建一个树对象。只要通过底层的`git write-tree`命令来捕获索引当前信息的快照就可以了。

目前，该索引只包含一个文件，`hello.txt`：

```sh
mei@4144e8c22fff:~/hello$ git ls-files --stage
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	hello.txt
```

- `git ls-files`显示索引中的文件信息。

查看命令`git ls-files`的帮助信息:

```
mei@4144e8c22fff:~/hello$ git ls-files --help|head -n 5
GIT-LS-FILES(1)                                                           Git Manual                                                          GIT-LS-FILES(1)

NAME
       git-ls-files - Show information about files in the index and the working tree

mei@4144e8c22fff:~/hello$
mei@4144e8c22fff:~/hello$ git ls-files -h
usage: git ls-files [<options>] [<file>...]

    -z                    paths are separated with NUL character
    -t                    identify the file status with tags
    -v                    use lowercase letters for 'assume unchanged' files
    -f                    use lowercase letters for 'fsmonitor clean' files
    -c, --cached          show cached files in the output (default)
    -d, --deleted         show deleted files in the output
    -m, --modified        show modified files in the output
    -o, --others          show other files in the output
    -i, --ignored         show ignored files in the output
    -s, --stage           show staged contents' object name in the output
    -k, --killed          show files on the filesystem that need to be removed
    --directory           show 'other' directories' names only
    --eol                 show line endings of files
    --empty-directory     don't show empty directories
    -u, --unmerged        show unmerged files in the output
    --resolve-undo        show resolve-undo information
    -x, --exclude <pattern>
                          skip files matching pattern
    -X, --exclude-from <file>
                          exclude patterns are read from <file>
    --exclude-per-directory <file>
                          read additional per-directory exclude patterns in <file>
    --exclude-standard    add the standard git exclusions
    --full-name           make the output relative to the project top directory
    --recurse-submodules  recurse through submodules
    --error-unmatch       if any <file> is not in the index, treat this as an error
    --with-tree <tree-ish>
                          pretend that paths removed since <tree-ish> are still present
    --abbrev[=<n>]        use <n> digits to display SHA-1s
    --debug               show debugging data

mei@4144e8c22fff:~/hello$
```

我们在执行底层命令`git write-tree`前，再次查看`.git/object`目录下有哪些文件：

```sh
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
```

- `git write-tree` 根据当前索引创建一个树对象。

查看`git write-tree`帮助信息：

```sh
# git-write-tree - Create a tree object from the current index
mei@4144e8c22fff:~/hello$ git write-tree -h
usage: git write-tree [--missing-ok] [--prefix=<prefix>/]

    --missing-ok          allow missing objects
    --prefix <prefix>/    write tree object for a subdirectory <prefix>
```

创建树对象：

```sh
mei@4144e8c22fff:~/hello$ git write-tree
68aba62e560c0ebc3396e8ae9335232cd93a3f60
```

查看`.git/object`目录下有哪些文件：

```sh
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
```

可以发现多出了`68`文件夹，以及`aba62e560c0ebc3396e8ae9335232cd93a3f60`文件。

查看该对象的内容：

```sh
# 查看对象的类型，返回tree，说明该对象是一个树对象
mei@4144e8c22fff:~/hello$ git cat-file -t 68aba62
tree

# 查看树对象的内容
mei@4144e8c22fff:~/hello$ git cat-file -p 68aba62
100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad	hello.txt

# 索引中的内容
mei@4144e8c22fff:~/hello$ git ls-files --stage
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	hello.txt
```

可以看到树对象68aba62已经捕获了索引中的信息。

第一个数100644是对象的文件属性的八进制表示。

`3b18e512dba79e4c8300dd08aeb37f8e728b8dad`是`hello world`的blob的对象名，`hello.txt`是与该blob关联的名字。

- `git ls-tree`显示树对象内容。

也可以使用`git ls-tree`来显示树对象的内容：

```sh
mei@4144e8c22fff:~/hello$ git ls-tree --help|head -n 5|awk NF
GIT-LS-TREE(1)                                                            Git Manual                                                           GIT-LS-TREE(1)
NAME
       git-ls-tree - List the contents of a tree object
mei@4144e8c22fff:~/hello$ git ls-tree -h
usage: git ls-tree [<options>] <tree-ish> [<path>...]

    -d                    only show trees
    -r                    recurse into subtrees
    -t                    show trees when recursing
    -z                    terminate entries with NUL byte
    -l, --long            include object size
    --name-only           list only filenames
    --name-status         list only filenames
    --full-name           use full path names
    --full-tree           list entire tree; not just current directory (implies --full-name)
    --abbrev[=<n>]        use <n> digits to display SHA-1s

mei@4144e8c22fff:~/hello$
```

我们查看一下树对象`68aba62e560c0ebc3396e8ae9335232cd93a3f60`的内容：

```sh
mei@4144e8c22fff:~/hello$ git ls-tree 68aba62e560c0ebc3396e8ae9335232cd93a3f60
100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad	hello.txt
mei@4144e8c22fff:~/hello$
```

#### 4.3.3 扩展 Git是如何生成树对象的散列值的？



参考：[Git工程开发实践（二）——Git内部实现机制](https://blog.51cto.com/u_9291927/2173002)

树对象的SHA1散列值计算方法如下：

```
tree <content length><NUL><file mode> <filename><NUL><item sha>
```

说明：content length是生成的内容长度，NUL是`\0`字符，file mode是文件模式，如`100644`，filename是文件名，item sha是blob对象散列值的二进制形式。

我们来看一下树对象`68aba62e560c0ebc3396e8ae9335232cd93a3f60`这个散列值是如何计算出来的。

当前索引中的内容：

```sh
mei@4144e8c22fff:~/hello$ git ls-files --stage
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	hello.txt
mei@4144e8c22fff:~/hello$
```

对该行进行处理，生成树对象的散列值。

首先使用`xxd`把blob块对象`3b18e512dba79e4c8300dd08aeb37f8e728b8dad`转换成二进制的形式，并将结果保存为sha1.txt以方便后面做追加操作。

```sh
mei@4144e8c22fff:~/hello$ echo -en '3b18e512dba79e4c8300dd08aeb37f8e728b8dad'|xxd -r -p > sha1.txt
```

构建content部分，并保存至文件content.txt：

```sh
mei@4144e8c22fff:~/hello$ echo -en "100644 hello.txt\0" | cat - sha1.txt > content.txt
```

计算content的长度：

```sh
mei@4144e8c22fff:~/hello$ cat content.txt |wc -c
37
```

长度为37。

生成SHA1散列值：

```sh
mei@4144e8c22fff:~/hello$ echo -en "tree 37\0" | cat - content.txt |shasum
68aba62e560c0ebc3396e8ae9335232cd93a3f60  -
mei@4144e8c22fff:~/hello$ echo -en "tree 37\0" | cat - content.txt |openssl dgst --sha1
(stdin)= 68aba62e560c0ebc3396e8ae9335232cd93a3f60
```

得到树对象的散列值为`68aba62e560c0ebc3396e8ae9335232cd93a3f60`。

而我们知道，通过`git write-tree`得到的树对象散列值如下：

```sh
mei@4144e8c22fff:~/hello$ git write-tree
68aba62e560c0ebc3396e8ae9335232cd93a3f60
```

可以看到，我们通过命令行手动计算的散列值与`git write-tree`生成的树对象散列值是一样的！！！说明我们的计算方法是对的。

以上只是验证了按这种方式计算的树对象的散列值刚好相同，后续还需要确认树对象的散列值的计算方法。



#### 4.3.4 对Git使用SHA1的一点说明



- 当我们多次对相同的索引计算其树对象的散列值时，其散列值是相同的。

多次执行`git write-tree`:

```sh
mei@4144e8c22fff:~/hello$ git write-tree
68aba62e560c0ebc3396e8ae9335232cd93a3f60
mei@4144e8c22fff:~/hello$ git write-tree
68aba62e560c0ebc3396e8ae9335232cd93a3f60
mei@4144e8c22fff:~/hello$ git write-tree
68aba62e560c0ebc3396e8ae9335232cd93a3f60
```

可以看到，返回的树对象的散列值保持不变。Git并不需要重新创建一个新的树对象。

```sh
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
```

`.git/objects`中并没有新增对象。

- 散列函数在数学意义上是一个真正的函数：对于一个给定的输入，它的输出总是相同的。这样的散列函数也称为摘要。
- 相同的散列值并不算碰撞，只有两个不同的对象产生一个相同的散列值时才算碰撞。



#### 4.3.5 树层次结构

- 只对单个文件的信息是很好管理的。但项目包含复杂而且深层嵌套的目录结构，并且会随着时间的推移而重构和移动。

下面我们创建一个子目录，并包含hello.txt的一个完全相同的副本，让我们看看Git是如何处理的：

```sh
mei@4144e8c22fff:~/hello$ mkdir subdir && cp hello.txt subdir/
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
mei@4144e8c22fff:~/hello$ git add subdir/hello.txt
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
mei@4144e8c22fff:~/hello$
```

我们创建了子目录subdir，并将hello.txt复制了一份到subdir/目录中，在我们执行`git add`前后，`.git/object`中的对象并没有新增。

此时查看索引中的内容：

```sh
mei@4144e8c22fff:~/hello$ git ls-files -s
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	hello.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	subdir/hello.txt
```

可以看到，索引中增加了一行，包含了`subdir/hello.txt`相关的信息。此时我们创建一个对对象：

```sh
mei@4144e8c22fff:~/hello$ git write-tree
492413269336d21fac079d4a4672e55d5d2147ac
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/49
.git/objects/49/2413269336d21fac079d4a4672e55d5d2147ac
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
mei@4144e8c22fff:~/hello$
```

可以看到，创建了树对象`492413269336d21fac079d4a4672e55d5d2147ac`。

查看一下树对象的内容：

```sh
mei@4144e8c22fff:~/hello$ git ls-tree 492413269336d21fac079d4a4672e55d5d2147ac
100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad	hello.txt
040000 tree 68aba62e560c0ebc3396e8ae9335232cd93a3f60	subdir
mei@4144e8c22fff:~/hello$ git cat-file -p 492413269336d21fac079d4a4672e55d5d2147ac
100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad	hello.txt
040000 tree 68aba62e560c0ebc3396e8ae9335232cd93a3f60	subdir
```

通过两种方式查看到树对象的内容是一样的。

新的顶级树包含两个条目：原始的hello.txt以及新的子目录，子目录是树而不是blob。subdir的对象名，是之前的树对象。



#### 4.3.6 提交

上一节我们已经将hello.txt添加到暂存区了，也通过`git write-tree`生成了树对象，下面也可以使用底层命令创建提交对象。

- `git commit-tree`创建提交对象。

```sh
mei@4144e8c22fff:~/hello$ git commit-tree --help|head -n 5
GIT-COMMIT-TREE(1)                                                        Git Manual                                                       GIT-COMMIT-TREE(1)

NAME
       git-commit-tree - Create a new commit object

mei@4144e8c22fff:~/hello$ git commit-tree --help|head -n 5|awk NF
GIT-COMMIT-TREE(1)                                                        Git Manual                                                       GIT-COMMIT-TREE(1)
NAME
       git-commit-tree - Create a new commit object
mei@4144e8c22fff:~/hello$ git commit-tree -h
usage: git commit-tree [(-p <parent>)...] [-S[<keyid>]] [(-m <message>)...] [(-F <file>)...] <tree>

    -p <parent>           id of a parent commit object
    -m <message>          commit message
    -F <file>             read commit log message from file
    -S, --gpg-sign[=<key-id>]
                          GPG sign commit
```

通过查看帮助文档可知，`This is usually not what an end user wants to run directly. See git-commit(1) instead.`不推荐直接使用该命令来创建一个提交对象，而应使用`git commit`命令来代替。

我们先使用这种方式来创建提交对象，后面再测试一次使用`git commit`来创建提交对象。

```sh
mei@4144e8c22fff:~/hello$ git commit-tree -m "Commit a file that says hello" 492413269336d21fac079d4a4672e55d5d2147ac
174a235d644ebbcad3b9c8f4c817e0f048c15fe3
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/49
.git/objects/49/2413269336d21fac079d4a4672e55d5d2147ac
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/17
.git/objects/17/4a235d644ebbcad3b9c8f4c817e0f048c15fe3
.git/objects/info
```

可以看到，此时多出了一个对象`174a235d644ebbcad3b9c8f4c817e0f048c15fe3`，与教程中的对象值不一样。

查看提交对象的内容：

```sh
mei@4144e8c22fff:~/hello$ git cat-file -p 174a235d644ebbcad3b9c8f4c817e0f048c15fe3
tree 492413269336d21fac079d4a4672e55d5d2147ac
author Zhaohui Mei <mzh@hellogitlab.com> 1626963401 +0800
committer Zhaohui Mei <mzh@hellogitlab.com> 1626963401 +0800

Commit a file that says hello
mei@4144e8c22fff:~/hello$
```

查看对象的类型：

```sh
mei@4144e8c22fff:~/hello$ git cat-file -t 174a235d644ebbcad3b9c8f4c817e0f048c15fe3
commit
```

可以看到`174a235d644ebbcad3b9c8f4c817e0f048c15fe3`是一个提交对象。

如果你在计算机上按步骤操作，你会发现你生成的提交对象不一样。

原因如下：

- 这是不同的提交。提交包含你的名字和创建提交的时间，尽管这区别很微小，但依然是不同的。但你的提交却有相同的树。



树对象和提交对象是分开的。不同的提交经常指向同一棵树。

在实际生活中，你应跳过底层的`git write-tree`和`git commit-tree`命令的步骤。而是只使用`git commit`命令。成为一个快乐的Git用户，你不需要记住那些底层命令。

- `git show --pretty=fuller COMMIT_ID`查看提交的详细细节。

我们查看一下刚才的提交的详情：

```sh
mei@4144e8c22fff:~/hello$ git show --pretty=fuller 174a235d644ebbcad3b9c8f4c817e0f048c15fe3
commit 174a235d644ebbcad3b9c8f4c817e0f048c15fe3
Author:     Zhaohui Mei <mzh@hellogitlab.com>
AuthorDate: Thu Jul 22 22:16:41 2021 +0800
Commit:     Zhaohui Mei <mzh@hellogitlab.com>
CommitDate: Thu Jul 22 22:16:41 2021 +0800

    Commit a file that says hello

diff --git a/hello.txt b/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/hello.txt
@@ -0,0 +1 @@
+hello world
diff --git a/subdir/hello.txt b/subdir/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/subdir/hello.txt
@@ -0,0 +1 @@
+hello world
mei@4144e8c22fff:~/hello$
```

- 一般情况下，作者和提交者是同一个人，也有一些情况下，他们是不同的。



#### 4.3.6 扩展 提交

现在，我们忘了那些底层的命令吧。

我们直接在一行命令中重试之前的一系列操作，并使用`git commit`进行提交：

```sh
mei@4144e8c22fff:~$ mkdir hello && cd hello && git init && echo 'hello world' > hello.txt && git add hello.txt && mkdir subdir && cp hello.txt subdir/ && git add subdir/hello.txt && git commit -m"Commit a file that says hello"
Initialized empty Git repository in /home/mei/hello/.git/
[master (root-commit) 80d703a] Commit a file that says hello
 2 files changed, 2 insertions(+)
 create mode 100644 hello.txt
 create mode 100644 subdir/hello.txt
mei@4144e8c22fff:~/hello$ git log
commit 80d703ac7da69ce3e5c0c87c8173fb23c50b5105 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:04:51 2021 +0800

    Commit a file that says hello
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/49
.git/objects/49/2413269336d21fac079d4a4672e55d5d2147ac
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/info
.git/objects/80
.git/objects/80/d703ac7da69ce3e5c0c87c8173fb23c50b5105
mei@4144e8c22fff:~/hello$
```

可以看到，除了最后的提交对象不同外，其他对象与之前测试的结果是一样。

此时，可以通过`git log`查看到提交日志信息：

```sh
mei@4144e8c22fff:~/hello$ git log
commit 80d703ac7da69ce3e5c0c87c8173fb23c50b5105 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:04:51 2021 +0800

    Commit a file that says hello
```

相应的，也可以看到分支情况：

```sh
mei@4144e8c22fff:~/hello$ git branch
* master
```

查看提交详情：

```sh
mei@4144e8c22fff:~/hello$ git show --pretty=fuller 80d703ac7da69ce3e5c0c87c8173fb23c50b5105
commit 80d703ac7da69ce3e5c0c87c8173fb23c50b5105 (HEAD -> master)
Author:     Zhaohui Mei <mzh@hellogitlab.com>
AuthorDate: Thu Jul 22 23:04:51 2021 +0800
Commit:     Zhaohui Mei <mzh@hellogitlab.com>
CommitDate: Thu Jul 22 23:04:51 2021 +0800

    Commit a file that says hello

diff --git a/hello.txt b/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/hello.txt
@@ -0,0 +1 @@
+hello world
diff --git a/subdir/hello.txt b/subdir/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/subdir/hello.txt
@@ -0,0 +1 @@
+hello world
```

可以看到，除了提交时间不一样外，其他的内容与使用底层命令`git write-tree`和`git commit-tree`得到的结果是一样的。



我们再来复盘一次使用底层命令进行操作推演：

```sh
mei@4144e8c22fff:~$ mkdir hello
mei@4144e8c22fff:~$ cd hello
mei@4144e8c22fff:~/hello$ git init
Initialized empty Git repository in /home/mei/hello/.git/
mei@4144e8c22fff:~/hello$ echo 'hello world' > hello.txt
mei@4144e8c22fff:~/hello$ mkdir subdir
mei@4144e8c22fff:~/hello$ cp hello.txt subdir/
mei@4144e8c22fff:~/hello$ git add .
mei@4144e8c22fff:~/hello$ gs
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   hello.txt
	new file:   subdir/hello.txt

mei@4144e8c22fff:~/hello$ git branch
mei@4144e8c22fff:~/hello$ git ls-files -s
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	hello.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	subdir/hello.txt
mei@4144e8c22fff:~/hello$ git write-tree
492413269336d21fac079d4a4672e55d5d2147ac

# ==========> 注意此处，写树对象后，查看分支情况和日志情况都是异常的！！！
mei@4144e8c22fff:~/hello$ git branch
mei@4144e8c22fff:~/hello$ git log
fatal: your current branch 'master' does not have any commits yet
mei@4144e8c22fff:~/hello$ git commit-tree -m"Commit a file that says hello" 492413269336d21fac079d4a4672e55d5d2147ac
b938f3081d70bd52a2032ef3f870b3a0afc5e376
mei@4144e8c22fff:~/hello$ git cat-file -p b938f3081d70bd52a2032ef3f870b3a0afc5e376
tree 492413269336d21fac079d4a4672e55d5d2147ac
author Zhaohui Mei <mzh@hellogitlab.com> 1626967226 +0800
committer Zhaohui Mei <mzh@hellogitlab.com> 1626967226 +0800

Commit a file that says hello

# ==========> 注意此处，写提交对象后，查看分支情况和日志情况都是异常的！！！
mei@4144e8c22fff:~/hello$ git log
fatal: your current branch 'master' does not have any commits yet
mei@4144e8c22fff:~/hello$ git branch
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/49
.git/objects/49/2413269336d21fac079d4a4672e55d5d2147ac
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/b9
.git/objects/b9/38f3081d70bd52a2032ef3f870b3a0afc5e376
.git/objects/info
mei@4144e8c22fff:~/hello$

# 查看.git/refs下的文件
mei@4144e8c22fff:~/hello$ find .git/refs/
.git/refs/
.git/refs/heads
.git/refs/tags
```

即，直接使用底次`git commit-tree`命令可以创建一个提交对象，但并没有提交数据！！！！没有提交记录！

```sh
mei@4144e8c22fff:~/hello$ git log b938f3081d70bd52a2032ef3f870b3a0afc5e376
commit b938f3081d70bd52a2032ef3f870b3a0afc5e376
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:20:26 2021 +0800

    Commit a file that says hello
```

可以看到，使用`git commit`提交与`git commit-tree`底层命令进行提交还是存在一些差异的！



我们可以在 [git log and show on a bare repo](https://stackoverflow.com/questions/6214711/git-log-and-show-on-a-bare-repo)找到答案。

其中，[Richard Hansen](https://stackoverflow.com/users/712605/richard-hansen)的答案告诉我们：

 > Fix
 >
 >To get rid of the error message, you can do one of the following:
 >
 >- Change `HEAD` to point to a branch that does exist:
 >
 >    ```sh
 >    git symbolic-ref HEAD refs/heads/some_other_branch
 >    ```
 >
 >- Push a new `master` branch into the repository from somewhere else
 >
 >- Create a new `master` branch locally:
 >
 >    ```sh
 >    git branch master some_existing_commit
 >    ```

为了消除这种错误消息，可以使用以上三种方法中的一种，我们使用第三种方式来解决。



我们需要再执行一步命令`git branch master b938f3081d70bd52a2032ef3f870b3a0afc5e376`来创建一个分支：

```sh
# 创建分支
mei@4144e8c22fff:~/hello$ git branch master b938f3081d70bd52a2032ef3f870b3a0afc5e376
mei@4144e8c22fff:~/hello$ git branch
* master
mei@4144e8c22fff:~/hello$ git log
commit b938f3081d70bd52a2032ef3f870b3a0afc5e376 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:20:26 2021 +0800

    Commit a file that says hello
    
# 查看.git/refs下的文件
mei@4144e8c22fff:~/hello$ find .git/refs/
.git/refs/
.git/refs/heads
.git/refs/heads/master
.git/refs/tags
```

总结：

`git commit`与`git commit-tree`的区别：

- `git commit-tree`命令基于一个tree树对象的hash id创建了一个commit提交对象。
- `git commit`则是将暂存区的内容放到仓库。暂存区的通常通常是一个commit对象。`git commit`还额外做了其他的事情。


分支与提交的关系：

- Git的分支必须指向一个commit,没有任何commit就没有任何分支。提交第一个commit后Git自动创建master分支。



正如我们上面操作的，在使用`git commit-tree`创建提交对象commit_id后，还需要使用`git branch master commit_id`来将提交对象与分支`master`绑定在一起。这样绑定后，就有了分支，也能查看`git log`日志信息了！！！

也就是说，`git commit`命令在创建了提交对象后，又将提交对象与分支进行绑定了！绑定分支后，我们就可以直接查看到`git log`的日志信息。

按Git的建议，我们只用使用`git commit`去提交修改就行，没有必要去使用底层的`git commit-tree`命令！





#### 4.3.7 标签

- Git还管理的一个对象是`标签`，尽管Git只实现了一种标签对象，但是有两种基本的标签类型。
- 两种标签类型：轻量级的(lightweight)和带附注的(annotated)。
- 轻量级标签只是一个提交对象的引用，通常被版本库视为私有的。这些标签并不会在版本库里创建永久的对象。
- 带附注的标签则会创建一个对象。
- Git在命名一个提交的时候对轻量级的标签和带标注的标签同等对待。
- `git tag`命令来创建标签！

先看看这个命令的帮助信息。

```sh
mei@4144e8c22fff:~$ git tag --help|head -n 4|awk NF
GIT-TAG(1)                                                                Git Manual                                                               GIT-TAG(1)
NAME
       git-tag - Create, list, delete or verify a tag object signed with GPG
mei@4144e8c22fff:~$ git tag -h
usage: git tag [-a | -s | -u <key-id>] [-f] [-m <msg> | -F <file>]
		<tagname> [<head>]
   or: git tag -d <tagname>...
   or: git tag -l [-n[<num>]] [--contains <commit>] [--no-contains <commit>] [--points-at <object>]
		[--format=<format>] [--[no-]merged [<commit>]] [<pattern>...]
   or: git tag -v [--format=<format>] <tagname>...

    -l, --list            list tag names
    -n[<n>]               print <n> lines of each tag message
    -d, --delete          delete tags
    -v, --verify          verify tags

Tag creation options
    -a, --annotate        annotated tag, needs a message
    -m, --message <message>
                          tag message
    -F, --file <file>     read message from file
    -e, --edit            force edit of tag message
    -s, --sign            annotated and GPG-signed tag
    --cleanup <mode>      how to strip spaces and #comments from message
    -u, --local-user <key-id>
                          use another key to sign the tag
    -f, --force           replace the tag if exists
    --create-reflog       create a reflog

Tag listing options
    --column[=<style>]    show tag list in columns
    --contains <commit>   print only tags that contain the commit
    --no-contains <commit>
                          print only tags that don't contain the commit
    --merged <commit>     print only tags that are merged
    --no-merged <commit>  print only tags that are not merged
    --sort <key>          field name to sort on
    --points-at <object>  print only tags of the object
    --format <format>     format to use for the output
    --color[=<when>]      respect format colors
    -i, --ignore-case     sorting and filtering are case insensitive

mei@4144e8c22fff:~$
```

可以看到，使用`git tag`命令可以创建、删除、检验或者列出当前的标签。

我们来创建一个`V1.0`的标签：

```sh
# 列出当前标签
mei@4144e8c22fff:~/hello$ git tag --list
# 不带任何参数时，也是列出当前标签
mei@4144e8c22fff:~/hello$ git tag
# 创建标签
mei@4144e8c22fff:~/hello$ git tag -m"Tag version 1.0" V1.0
# 再次列出当前的标签
mei@4144e8c22fff:~/hello$ git tag --list
V1.0
mei@4144e8c22fff:~/hello$ git tag
V1.0
```

此时，我们查看一下Git的对象文件：

```sh
mei@4144e8c22fff:~/hello$ find .git/objects/
.git/objects/
.git/objects/68
.git/objects/68/aba62e560c0ebc3396e8ae9335232cd93a3f60
.git/objects/49
.git/objects/49/2413269336d21fac079d4a4672e55d5d2147ac
.git/objects/38
.git/objects/38/ab1e8230e171894dd47a24fb27bf2873322159
.git/objects/pack
.git/objects/3b
.git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
.git/objects/b9
.git/objects/b9/38f3081d70bd52a2032ef3f870b3a0afc5e376
.git/objects/info
mei@4144e8c22fff:~/hello$
```

可以发现新增了对象数据。

我们查看一下`V1.0`标签对象的SHA1值：

```sh
mei@4144e8c22fff:~/hello$ git rev-parse V1.0
38ab1e8230e171894dd47a24fb27bf2873322159
```

这样获取到了标签对象的SHA1值为`38ab1e8230e171894dd47a24fb27bf2873322159`。

我们查看一下该对象的内容和类型：

```sh
mei@4144e8c22fff:~/hello$ git cat-file -p 38ab1e8230e171894dd47a24fb27bf2873322159
object b938f3081d70bd52a2032ef3f870b3a0afc5e376
type commit
tag V1.0
tagger Zhaohui Mei <mzh@hellogitlab.com> 1627141359 +0800

Tag version 1.0
mei@4144e8c22fff:~/hello$ git cat-file -t 38ab1e8230e171894dd47a24fb27bf2873322159
tag
```

标签指向对象`b938f3081d70bd52a2032ef3f870b3a0afc5e376`，是一个commit提交对象。正是我们在上一节的最后的提交对象。

我们查看一下当前日志信息：

```sh
mei@4144e8c22fff:~/hello$ git log
commit b938f3081d70bd52a2032ef3f870b3a0afc5e376 (HEAD -> master, tag: V1.0)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:20:26 2021 +0800

    Commit a file that says hello
```

可以看到对于提交对象`b938f3081d70bd52a2032ef3f870b3a0afc5e376`,其有一个标签，标签名为`V1.0`。

- 通常情况下，Git通过某些分支来给特定的提交命名标签。



查看标签的详情：

```sh
mei@4144e8c22fff:~/hello$ git show V1.0
tag V1.0
Tagger: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sat Jul 24 23:42:39 2021 +0800

Tag version 1.0

commit b938f3081d70bd52a2032ef3f870b3a0afc5e376 (HEAD -> master, tag: V1.0)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Thu Jul 22 23:20:26 2021 +0800

    Commit a file that says hello

diff --git a/hello.txt b/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/hello.txt
@@ -0,0 +1 @@
+hello world
diff --git a/subdir/hello.txt b/subdir/hello.txt
new file mode 100644
index 0000000..3b18e51
--- /dev/null
+++ b/subdir/hello.txt
@@ -0,0 +1 @@
+hello world
mei@4144e8c22fff:~/hello$
```









## 第5章 文件管理和索引

- Git在工作目录和版本库之间加设了一层索引index，用来暂存stage、收集或者修改。
- 当你使用Git来管理代码时，你会在工作目录下编辑，在索引中积累修改，然后把索引中累积的修改作为一次性的变更来进行提交。
- 可以把Git的索引看作是一组打算的或预期的修改。
- 一次提交其实是分两步的过程：暂存变更和提交变更。在工作目录下而不在索引中的变更是没暂存的，没暂存的变更是不会被提交的。

### 5.1 关于索引的一切

- Git的索引不包含任何文件内容，它仅仅追踪提交的内容。
- 当执行`git commit`命令的时候，Git会通过检查索引而不是工作目录来找到提交的内容。
- 在任何时候，可以通过`git status`命令查询索引的状态。
- `git diff`命令可以显示两组不同的差异。`git diff`会显示仍留在工作目录中未暂存的变更；`git diff --cached`显示已经暂存并且因此要有助于下次提交的变更。
- 可以用`git diff`的这两种形式引导你完成暂存变更的过程。刚开始，`git diff`显示所有修改的大集合，`git diff --cached`则是空的。而当暂存时，前者的集合将会收缩，后者会增大。如果所有修改都暂存了并准备提交，`git diff --cached`将是满的，而`git diff`则什么也不显示。





### 5.2 Git中的文件分类

Git将所有文件分为3类：已追踪的、被忽略的以及未追踪的。

- 已追踪的(Tracked):已追踪的文件是指已经在版本库中的文件，或者是已经暂存到索引中的文件。
- 被忽略的(Ignored): 被忽略的文件必须在版本库中被明确声明为不可见的或被忽略，即使它可能会在你的工作目录中出现。一个软件项目通常都会有很多被忽略的文件。Git维护一个默认忽略文件列表，也可以配置版本库来识别其他文件。
- 未追踪的(Untracked):未追踪的文件是指那些不在前两类中的文件。
- 编辑器和构建环境常常会在源码文件周围遗留一些临时文件。在版本库中这些文件通常是不应被当作源文件追踪的。而为了让Git忽略目录中的文件，只需要将该文件名添加到一个特殊的文件`.gitignore`中就可以。
- `.gitignore`文件对Git的特殊的意义，但是它和版本库中任何其他普通文件都是同样管理的。
- 除非把`.gitignore`添加到索引中，否则Git仍会把它当成未追踪的文件。



### 5.3 使用`git add`暂存文件

- `git add`命令将暂存一个文件。
- 如果一个文件是未追踪的，那么`git add`就会将文件的状态转化成已追踪的。
- 如果`git add`作用于一个目录，那么该目录下的文件和子目录都会递归暂存起来。



查看`git add`的帮助信息：

```sh
mei@4144e8c22fff:~$ git add --help|head -n 5|awk NF
GIT-ADD(1)                                                                Git Manual                                                               GIT-ADD(1)
NAME
       git-add - Add file contents to the index
mei@4144e8c22fff:~/my_stuff$ git add -h
usage: git add [<options>] [--] <pathspec>...

    -n, --dry-run         dry run
    -v, --verbose         be verbose

    -i, --interactive     interactive picking
    -p, --patch           select hunks interactively
    -e, --edit            edit current diff and apply
    -f, --force           allow adding otherwise ignored files
    -u, --update          update tracked files
    --renormalize         renormalize EOL of tracked files (implies -u)
    -N, --intent-to-add   record only the fact that the path will be added later
    -A, --all             add changes from all tracked and untracked files
    --ignore-removal      ignore paths removed in the working tree (same as --no-all)
    --refresh             don't add, only refresh the index
    --ignore-errors       just skip files which cannot be added because of errors
    --ignore-missing      check if - even missing - files are ignored in dry run
    --chmod (+|-)x        override the executable bit of the listed files
    --pathspec-from-file <file>
                          read pathspec from file
    --pathspec-file-nul   with --pathspec-from-file, pathspec elements are separated with NUL character
```

- 在Git的对象模型中，在发出`git add`命令时，每个文件的全部内容都将被复制到对象库中，并且按文件的SHA1名来索引。
- 暂存一个文件也称作缓存(caching)一个文件。或者叫把文件放进索引。
- 可以使用`git ls-files`命令查看隐藏在对象模型下的东西，并且可以找到那些暂存文件的SHA1值。

```sh
# 显示索引中文件信息
mei@4144e8c22fff:~/my_stuff$ git ls-files --stage
100644 0487f44090ad950f61955271cf0a2d6c6a83ad9a 0	.gitignore
100644 534469f67ae5ce72a7a274faf30dee3c2ea1746d 0	data

# 查看对象文件夹文件列表
mei@4144e8c22fff:~/my_stuff$ find .git/objects/
.git/objects/
.git/objects/04
.git/objects/04/87f44090ad950f61955271cf0a2d6c6a83ad9a
.git/objects/pack
.git/objects/53
.git/objects/53/4469f67ae5ce72a7a274faf30dee3c2ea1746d
.git/objects/info
```



- 使用`git hash-object file`命令可以直接计算文件的SHA1值，注意，目录不能hash。

对文件进行修改：

```sh
# 编辑文件后，查看文件内容
mei@4144e8c22fff:~/my_stuff$ cat data
New data
And some more data now
mei@4144e8c22fff:~/my_stuff$

# 查看文件的新的SHA1值
mei@4144e8c22fff:~/my_stuff$ git hash-object data
e476983f39f6e4f453f0fe4a859410f63b58b500

# 可以发现文件生成了新的散列值，但在.git/objects目录下并没有增新的对象
mei@4144e8c22fff:~/my_stuff$ find .git/objects/
.git/objects/
.git/objects/04
.git/objects/04/87f44090ad950f61955271cf0a2d6c6a83ad9a
.git/objects/pack
.git/objects/53
.git/objects/53/4469f67ae5ce72a7a274faf30dee3c2ea1746d
.git/objects/info
```

将文件再加入到暂存区，然后再查看一下索引：

```sh
mei@4144e8c22fff:~/my_stuff$ git add data
mei@4144e8c22fff:~/my_stuff$ find .git/objects/
.git/objects/
.git/objects/e4
.git/objects/e4/76983f39f6e4f453f0fe4a859410f63b58b500
.git/objects/04
.git/objects/04/87f44090ad950f61955271cf0a2d6c6a83ad9a
.git/objects/pack
.git/objects/53
.git/objects/53/4469f67ae5ce72a7a274faf30dee3c2ea1746d
.git/objects/info
mei@4144e8c22fff:~/my_stuff$ git ls-files
.gitignore
data
mei@4144e8c22fff:~/my_stuff$ git ls-files --stage
100644 0487f44090ad950f61955271cf0a2d6c6a83ad9a 0	.gitignore
100644 e476983f39f6e4f453f0fe4a859410f63b58b500 0	data
```

可以看到文件已经暂存了，索引中的内容已经更新了。





### 5.4  使用`git commit`的一些注意事项

#### 5.4.1 使用`git commit --all`

- `git commit`的`-a`或`--all`选项会导致执行提交之前自动暂存所有未暂存的和未追踪的文件变化，包括中工作副本中删除已追踪的文件，
- 如果执行`git commit --all`命令，Git会递归整个版本库，暂存所有已知的和修改的文件，然后提交它们。此时会打开编辑器，让输入提交消息，并显示哪些文件会被提交。
- 如果一个子目录是一个全新的目录，而且该目录下没有任何文件名或路径是已经追踪的，则此时即使使用`git commit --all`也不会将其提交。要想提交这种目录，必须先使用`git add`先将目录添加进暂存区，再使用`git commit --all`则可以全部提交。



#### 5.4.2 编写提交日志消息

- 如果不通过命令行直接提供日志消息，Git会启用编辑器。并提示你写一个日志消息。
- 编辑器的选取根据配置文件中的设定来确定。



- 当系统安装有`nano`和`vim`时，Git默认会启动`nano`编辑器。

```sh
mei@4144e8c22fff:~$ nano --version|head -n 1
 GNU nano, version 4.8
mei@4144e8c22fff:~$ vim --version|head -n 1
VIM - Vi IMproved 8.1 (2018 May 18, compiled Apr 15 2020 06:40:31)
```

如果我们在Git工作目录直接输入`git commit`则会进入到`nano`界面。而`nano`我们平时很少使用，更多的时候使用的是`vim`。

我们修改一下编辑器。

我们可以设置以下环境变量：

```sh
mei@4144e8c22fff:~/commit-all-example$ export GIT_EDITOR=vim
mei@4144e8c22fff:~/commit-all-example$
```

此时，我们输入`git commit`则会打开vim编辑器。

- Git不会处理空提交，即没有任何提交消息的提交！

当我们直接退出编辑器时，会提示没有输入任何提交消息：

```sh
mei@4144e8c22fff:~/commit-all-example$ git commit
Aborting commit due to empty commit message.
```

由于未输入任何消息，则放弃提交。



另外，我们也可以通过在Git中设置编辑器。刚才我们已经使用`export GIT_EDITOR=vim`设置了默认的编辑器。

我们使用`git config --global core.editor`来设置编辑器试一下。

尝试全局设置编辑器：

```sh
mei@4144e8c22fff:~/commit-all-example$ git config --global core.editor 'nano'
mei@4144e8c22fff:~/commit-all-example$ git config --global core.editor
nano
mei@4144e8c22fff:~/commit-all-example$ git commit
Aborting commit due to empty commit message.
```

此时，虽然全局使用`nano`编辑器，但使用`git commit`时仍然打开了`vim`编辑器。说明使用Git的全局设置并未生效，而是使用了`export GIT_EDITOR=vim`的设置。



我们再尝试设置存储库级别的编辑器：

```sh
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor 'nano'
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor
nano
mei@4144e8c22fff:~/commit-all-example$ git commit
Aborting commit due to empty commit message.
```

此时，使用的编辑器也是`vim`，说明本地设置未能生效。

在3.3节中，提到以下知识：

- 多个配置选项和环境变量常常是为了同一个目的出现的。如在编写提交日志消息的时候，编辑器的选择按照以下步骤的顺序确定：
    - `GIT_EDITOR`环境变量。
    - `core.editor`配置选项。
    - `VISUAL`环境变量。
    - `EDITOR`环境变量。
    - `vi`命令。

由于我们在前面设置了`GIT_EDITOR`环境变量为`vim`，因此Git会将vim作为编辑器。

```sh
# 删除环境变量GIT_EDITOR
mei@4144e8c22fff:~/commit-all-example$ unset GIT_EDITOR
mei@4144e8c22fff:~/commit-all-example$ git commit
Aborting commit due to empty commit message.
```

当我们将环境变量`GIT_EDITOR`删除后，马上使用`git commit`进行提交时，编辑器就变成了`nano`。说明我们使用配置文件设置是正确的。

假如我将编辑器设置成一个不存在的编辑器名称，会怎么样呢？

```sh
mei@4144e8c22fff:~/commit-all-example$ emacs
bash: emacs: command not found
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor emacs
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor
emacs
mei@4144e8c22fff:~/commit-all-example$ git commit
hint: Waiting for your editor to close the file... error: cannot run emacs: No such file or directory
error: unable to start editor 'emacs'
Please supply the message using either -m or -F option.
mei@4144e8c22fff:~/commit-all-example$
```

可以看到，当编辑器程序不存在时，使用`git commit`将不能正常打开编辑器，将会提示异常。



我们将编辑器修改为我们常用的`vim`。

```sh
mei@4144e8c22fff:~/commit-all-example$ git config --global core.editor vim
mei@4144e8c22fff:~/commit-all-example$ git config --global core.editor
vim
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor vim
mei@4144e8c22fff:~/commit-all-example$ git config --local core.editor
vim
mei@4144e8c22fff:~/commit-all-example$ git commit
Aborting commit due to empty commit message.
```

这样后期Git都会使用vim作为默认的编辑器了！



### 5.5 使用`git rm`

- `git rm`会在版本库和工作目录中同时删除文件。
- 从工作目录和索引中删除一个文件，并不会删除该文件在版本库中的历史记录。文件的任何版本，只要是提交到版本库的历史记录的一部分，就会留在对象库并优点历史记录。
- `git rm`也是一条对索引进行操作的命令，所以它对没有添加到版本库或索引中的文件是不起作用的。
- 要将一个文件由已暂存的转换成未暂存的，可以使用`git rm --cached`命令。
- `git rm --cached`命令会删除索引中的文件并且把它保留在工作目录中。`git rm`会将文件从索引和工作目录中都删除。
- 请谨慎使用`git rm --cached`命令，有可能你忘记将已经追踪的文件转换成了未追踪的状态了。
- `git rm`在删除一个文件之前，会先进行检查以确保工作目录下的该文件的版本与当前分支中的最新版本是匹配的。这个验证可以防止文件的修改意外丢失。

```sh
mei@4144e8c22fff:~/commit-all-example$ git diff notyet
diff --git a/notyet b/notyet
index 3dfdc59..da34ada 100644
--- a/notyet
+++ b/notyet
@@ -1 +1,2 @@
 something else
+new
mei@4144e8c22fff:~/commit-all-example$ git rm notyet
error: the following file has local modifications:
    notyet
(use --cached to keep the file, or -f to force removal)
```

可以看到`notyet`由于增加了一行`new`，在删除时，会提示本地该文件已经被修改了，不能直接删除。

- 可以使用`git rm -f`强制删除文件。

```sh
mei@4144e8c22fff:~/commit-all-example$ git rm -f notyet
rm 'notyet'
```

如果不小心删除了该文件，也可以从版本库中恢复回来：

```sh
# 恢复文件
mei@4144e8c22fff:~/commit-all-example$ git checkout HEAD -- notyet
mei@4144e8c22fff:~/commit-all-example$ ls
notyet  ready  subdir
mei@4144e8c22fff:~/commit-all-example$ cat notyet
something else
```





### 5.6 使用`git mv`

- 如果你需要移动或复命名文件，可以对旧文件使用`git rm`命令，然后使用`git add`命令添加新文件，或者可以直接使用`git mv`命令。

`git mv`命令的帮助信息：

```sh
mei@4144e8c22fff:~/test-mv$ git mv --help|head -n 5|awk NF
GIT-MV(1)                                                                 Git Manual                                                                GIT-MV(1)
NAME
       git-mv - Move or rename a file, a directory, or a symlink
mei@4144e8c22fff:~/test-mv$ git mv -h
usage: git mv [<options>] <source>... <destination>

    -v, --verbose         be verbose
    -n, --dry-run         dry run
    -f, --force           force move/rename even if target exists
    -k                    skip move/rename errors

mei@4144e8c22fff:~/test-mv$
```



下面我们来测试一下`git mv`，创建一个版本库，并在版本库中添加一个`stuff`文件：

```sh
mei@4144e8c22fff:~$ mkdir test-mv
mei@4144e8c22fff:~$ cd test-mv
mei@4144e8c22fff:~/test-mv$ git init
Initialized empty Git repository in /home/mei/test-mv/.git/
mei@4144e8c22fff:~/test-mv$ echo 'something' > stuff
mei@4144e8c22fff:~/test-mv$ gs
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	stuff

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/test-mv$ git add .
mei@4144e8c22fff:~/test-mv$ git commit -m"add one file"
[master (root-commit) c19762a] add one file
 1 file changed, 1 insertion(+)
 create mode 100644 stuff
mei@4144e8c22fff:~/test-mv$
```

现在文件stuff已经添加到版本库中了。我们将`stuff`命名为`newstuff`：

```sh
mei@4144e8c22fff:~/test-mv$ git mv stuff newstuff
mei@4144e8c22fff:~/test-mv$ gs
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	renamed:    stuff -> newstuff

mei@4144e8c22fff:~/test-mv$ git commit -m"move stuff to newstuff"
[master 0112e0c] move stuff to newstuff
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename stuff => newstuff (100%)
```

可以看到`git mv`操作会自动将修改添加到暂存区，不需要我们手动执行`git add`命令。



- Git记得全部的历史记录，但是显示要限制于在命令中指定的文件名。`git log --follow`命令会让Git在日志中回溯并找到内容相关联的整个历史记录。

可以看一下以下差别：

```sh
# 不使用--follow选项，只查看到了一条历史记录
mei@4144e8c22fff:~/test-mv$ git log newstuff
commit 0112e0cfa80c240542d2b96cddb93aa27ab8e3b9 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 07:11:41 2021 +0800

    move stuff to newstuff
    
# 使用follow选项，可以看到文件重命名前的原始文件的提交记录，查看到两条历史记录了
mei@4144e8c22fff:~/test-mv$ git log --follow newstuff
commit 0112e0cfa80c240542d2b96cddb93aa27ab8e3b9 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 07:11:41 2021 +0800

    move stuff to newstuff

commit c19762a29fa408a7c7e1c7ed6b0fa125a756ce17
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 07:07:50 2021 +0800

    add one file
```

我们可以在`git log`的帮助信息中查看到`--follow           Continue listing the history of a file beyond renames (works only for a single file).` 即，`--follow`选项，继续列出重命名之外的文件历史记录（仅适用于单个文件）。也就是说该选项会追溯单文件的整个历史记录。

- VCS的经典问题之一就是文件重命名会导致它们丢失对文件历史记录的追踪。而Git即使经历过重命名，也仍然能保留历史记录信息。

当我们再次进行重命名后，仍然是可以查找到文件的源头历史：

```sh
mei@4144e8c22fff:~/test-mv$ mv newstuff otherstuff
mei@4144e8c22fff:~/test-mv$ gs
On branch master
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	deleted:    newstuff

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	otherstuff

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/test-mv$ git add .
mei@4144e8c22fff:~/test-mv$ gs
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	renamed:    newstuff -> otherstuff

mei@4144e8c22fff:~/test-mv$ git commit -m"move newstuff to otherstuff"
[master ddb0ebd] move newstuff to otherstuff
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename newstuff => otherstuff (100%)
mei@4144e8c22fff:~/test-mv$ git log otherstuff
commit ddb0ebd315adbfbf9258158e01db826a6f23b19e (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 19:14:27 2021 +0800

    move newstuff to otherstuff
mei@4144e8c22fff:~/test-mv$ git log --follow otherstuff
commit ddb0ebd315adbfbf9258158e01db826a6f23b19e (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 19:14:27 2021 +0800

    move newstuff to otherstuff

commit 0112e0cfa80c240542d2b96cddb93aa27ab8e3b9
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 07:11:41 2021 +0800

    move stuff to newstuff

commit c19762a29fa408a7c7e1c7ed6b0fa125a756ce17
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jul 26 07:07:50 2021 +0800

    add one file
mei@4144e8c22fff:~/test-mv$
```

经过了两次重命名后，`otherstuff`文件的历史记录仍然可以找到！





### 5.7 追踪重命名注解

- Git不追踪重命名。
- 重命名只会影响树对象。树对象保存内容间的关系，而内容本身保存在blob块中。
- GIt基于散列的简单存储系统简化了许多其他RCS被难倒或选择回避的事情。
- 没有能完美处理文件重命名的系统。



### 5.8 `.gitignore`文件

- `.gitignore`文件用来忽略不需要版本库管理的文件。
- 你可以忽略任何文件，只需要将想要忽略的文件的文件名加到同一目录下的`.gitignore`文件中即可。也可以将文件名添加到版本库顶层目录下的`.gitignore`文件中来忽略它。

`.gitignore`文件的格式如下：

- 空行会被忽略，以井号#开头的行可以用于注释。#跟在其他文本后面，则不表示注释。
- 一个简单的字面置文件名匹配任何目录中的同名文件。
- 目录名由末尾的反斜杠/标记。
- 支持Shell通配符，如星号`*`可扩展为shell通配模式。
- 起始的感叹号!会对该行其余的模式进行取反。
- `.gitignore`在版本库中被视为一个普通文件。
- 可以在各级目录中使用`.gitignore`文件，子目录的`.gitignore`优先级高于父级目录的`.gitignore`。



我们来测试一下`.gitignore`文件。创建一个版本库，并随意添加一些文件。

```sh
mei@4144e8c22fff:~$ mkdir test-ignore
mei@4144e8c22fff:~$ cd test-ignore/
mei@4144e8c22fff:~/test-ignore$ git init
Initialized empty Git repository in /home/mei/test-ignore/.git/
mei@4144e8c22fff:~/test-ignore$ touch test.py
mei@4144e8c22fff:~/test-ignore$ mkdir app1
mei@4144e8c22fff:~/test-ignore$ mkdir app2
mei@4144e8c22fff:~/test-ignore$ cp test.py app1/
mei@4144e8c22fff:~/test-ignore$ cp test.py app2/
mei@4144e8c22fff:~/test-ignore$ touch main.c
mei@4144e8c22fff:~/test-ignore$ touch main.o
mei@4144e8c22fff:~/test-ignore$ touch app1/app1.o
mei@4144e8c22fff:~/test-ignore$ touch app2/app2.o

# 查看版本库上的文件，查看所有文件，但忽略.git文件夹
mei@4144e8c22fff:~/test-ignore$ tree -a -I .git
.
|-- .gitignore
|-- app1
|   |-- app1.o
|   `-- test.py
|-- app2
|   |-- app2.o
|   `-- test.py
|-- main.c
|-- main.o
`-- test.py

2 directories, 8 files
mei@4144e8c22fff:~/test-ignore$ gs
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	app1/
	app2/
	main.c
	main.o
	test.py

nothing added to commit but untracked files present (use "git add" to track)
```

忽略`test.py`文件：

```sh
mei@4144e8c22fff:~/test-ignore$ echo 'test.py' > .gitignore
mei@4144e8c22fff:~/test-ignore$ gs
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore
	app1/
	app2/
	main.c
	main.o

nothing added to commit but untracked files present (use "git add" to track)
```

可以使用以下命令来查看哪些文件被忽略：

- `git status --ignored` 查看被忽略的文件。
- `git check-ignore`命令查看文件是否被忽略。

```sh
# 使用git status查看被忽略的文件
mei@4144e8c22fff:~/test-ignore$ git status --ignored
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore
	app1/
	app2/
	main.c
	main.o

Ignored files:
  (use "git add -f <file>..." to include in what will be committed)
	app1/test.py
	app2/test.py
	test.py

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/test-ignore$
```

可以看到，当我们仅在`.gitignore`中指定`test.py`时，Git会忽略所有目录中的`test.py`文件。

我们也可以使用`git check-ignore`命令来检查一下。

```sh
mei@4144e8c22fff:~/test-ignore$ git check-ignore --help|head -n 5|awk NF
GIT-CHECK-IGNORE(1)                                                       Git Manual                                                      GIT-CHECK-IGNORE(1)
NAME
       git-check-ignore - Debug gitignore / exclude files
mei@4144e8c22fff:~/test-ignore$ git check-ignore -h
usage: git check-ignore [<options>] <pathname>...
   or: git check-ignore [<options>] --stdin

    -q, --quiet           suppress progress reporting
    -v, --verbose         be verbose

    --stdin               read file names from stdin
    -z                    terminate input and output records by a NUL character
    -n, --non-matching    show non-matching input paths
    --no-index            ignore index when checking
```

我们检查工作目录下的三个`test.py`文件：

```sh
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v test.py && echo $?
.gitignore:1:test.py	test.py
0
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v app1/test.py && echo $?
.gitignore:1:test.py	app1/test.py
0
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v app2/test.py && echo $?
.gitignore:1:test.py	app2/test.py
0
```

可以看到`.gitignore`第一行的`test.py`同时匹配上了3个`test.py`，这三个文件都被忽略了！



假如我们现在要忽略所有`.o`文件，则可以像下面这样操作。

忽略所有`.o`文件：

```sh
mei@4144e8c22fff:~/test-ignore$ echo -e '# ignore object file\n*.o' >> .gitignore
mei@4144e8c22fff:~/test-ignore$ cat .gitignore
test.py
# ignore object file
*.o
mei@4144e8c22fff:~/test-ignore$ gs
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore
	main.c

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/test-ignore$ git status --ignored
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore
	main.c

Ignored files:
  (use "git add -f <file>..." to include in what will be committed)
	app1/
	app2/
	main.o
	test.py

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/test-ignore$
```

现在由于我们加了了忽略`.o`文件，此时`app1`和`app2`文件都被忽略了。我们使用`git check-ignore`检查一下。

```sh
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v app1/app1.o
.gitignore:3:*.o	app1/app1.o
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v app2/app1.o
.gitignore:3:*.o	app2/app1.o
mei@4144e8c22fff:~/test-ignore$ git check-ignore -v main.o
.gitignore:3:*.o	main.o
```

可以看到`.gitignore`的第3行`*.o`使用通配符匹配到了多个`.o`文件。



一般我们仅在版本库顶层目录设置`.gitignore`，你也可以在子目录中设置`.gitignore`文件。





## 第6章 提交

- 在Git中，提交commit是用来记录版本库的变更的。
- 当提交时，Git会记录索引的快照并把快照放进对象库。
- 提交是将变更引入版本库的唯一方法，任何版本库中的变更都必须由一个提交引入。
- 最常见的提交是由开发人员引入的。但Git自身也会引入提交。除了用户在合并之前做的提交外，合并操作自身会导致在版本库中多出一个提交。

### 6.1 原子变更集

- 每一个Git提交都代表一个相对于之前的状态的单个原子变更集。
- 对于一个提交中的所有做过的改动，无论多少目录、文件、行、字节的改变，要么全部应用，要么全部拒绝。
- Git不关心文件为什么变化。即变更的内容并不重要。
- Git不会把版本库置于两次提交之间的过渡状态。



### 6.2 识别提交

- 在团队工作中，识别个人的提交是一个很重要的任务。
- 当创建新分支时，必须要选择某个提交来作为分支点。
- 当比较代码差异时，必须要指定两个提交。
- 当编辑提交历史记录时，必须提供一个提交集。
- 在Git中，可以通过显式或隐式引用来指代每一个提交。
- 唯一的40位十六进制SHA1散列值提交ID是显式引用。始终指向最新提交的HEAD则是隐式引用。





#### 6.2.1 绝对提交名

- 对提交来说，最严谨的名字是它的散列标识符。
- 散列ID是个绝对名，这意味它只能表示唯一的一个提交。
- 每一个提交的散列ID都是全局唯一的。不仅仅是对某个版本库，而且是对任意和所有版本库都是唯一的。
- 由于输入一个40位十六进制的SHA1数字是一项繁琐且容易出错的工作，因此Git允许你使用版本库的对象库中唯一的前缀来缩短这个数字。



下面是Git自己的版本库中的一个例子：

```sh
# 查看Git的最开始的3次提交
mei@4144e8c22fff:~/git$ git log --reverse --oneline|head -n 3
e83c516331 Initial revision of "git", the information manager from hell
8bc9a0c769 Add copyright notices.
e497ea2a9b Make read-tree actually unpack the whole tree.

# 使用SHA1散列前缀来来看日志信息
mei@4144e8c22fff:~/git$ git log --oneline e83c5
e83c516331 Initial revision of "git", the information manager from hell
mei@4144e8c22fff:~/git$ git log --oneline e83
fatal: ambiguous argument 'e83': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
mei@4144e8c22fff:~/git$

# 第一次提交是林纳斯提交的
mei@4144e8c22fff:~/git$ git log e83c5
commit e83c5163316f89bfbde7d9ab23ca2e25604af290
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Apr 7 15:13:13 2005 -0700

    Initial revision of "git", the information manager from hell
mei@4144e8c22fff:~/git$
```



#### 6.2.2 引用和符号引用

- 引用(ref)是一个SHA1散列值，指向Git对象库中的对象。
- 虽然一个引用可以指向任何Git对象，但是它通常指向提交对象。
- 符号引用（symbolic reference）,或称为symref，间接指向Git对象。它们仍然是一个引用。
- 本地特性分支名称、远程跟踪分支名称和标签名都是引用。
- 引用都存储在版本库的`.git/refs/`目录中。目录中基本上有三种不同的命名空间代表不同的引用：`refs/heads/ref`代表本地分支，`refs/remotes/ref`代表远程跟踪分支，`refs/tags/ref`代表标签。

例如，一个叫做`dev`的本地特性分支就是`refs/heads/dev`的缩写。因为远程追踪分支在`refs/remotes`命名空间中，所以`origin/master`实际上是`refs/remotes/origin/master`，标签`v1.0`就是`refs/tags/v1.0`的缩写。

如果你有一个分支和一个标签使用相同的名称，Git会根据`git rev-parse`手册上的列表选取每个匹配项：

```
<refname>, e.g. master, heads/master, refs/heads/master
    A symbolic ref name. E.g.  master typically means the commit object referenced by refs/heads/master. 
    If you happen to have both heads/master and tags/master, you can explicitly say heads/master to tell Git which one you mean. 
    When ambiguous, a <refname> is disambiguated by taking the first match in the following rules:
    If $GIT_DIR/<refname> exists, that is what you mean (this is usually useful only for HEAD, FETCH_HEAD, ORIG_HEAD, MERGE_HEAD and CHERRY_PICK_HEAD);
    otherwise, refs/<refname> if it exists;    
    otherwise, refs/tags/<refname> if it exists;   
    otherwise, refs/heads/<refname> if it exists;
    otherwise, refs/remotes/<refname> if it exists;
    otherwise, refs/remotes/<refname>/HEAD if it exists.
```

- 使用`git init`初始化的版本库默认没有任何的符号引用。


我们创建一个`test-ref`仓库，可以看到`.git/refs`目录下没有生成`ref`文件：

```sh
mei@4144e8c22fff:~$ mkdir test-ref
mei@4144e8c22fff:~$ cd test-ref
mei@4144e8c22fff:~/test-ref$ git init
Initialized empty Git repository in /home/mei/test-ref/.git/
mei@4144e8c22fff:~/test-ref$ find .git/refs/
.git/refs/
.git/refs/heads
.git/refs/tags
mei@4144e8c22fff:~/test-ref$ find .git/refs/ -exec ls -ld {} \;
drwxrwxr-x 4 mei mei 4096 Jul 28 23:02 .git/refs/
drwxrwxr-x 2 mei mei 4096 Jul 28 23:02 .git/refs/heads
drwxrwxr-x 2 mei mei 4096 Jul 28 23:02 .git/refs/tags
```

- 从技术角度来说，Git的目录名`.git`这个名字是可以改变的，Git的内部文件都使用变量`$GIT_DIR`，而不是字面量`.git`。

GIt中特殊的符号引用：

- `HEAD`， HEAD始终指向当前分支的最近提交。当切换分支时，HEAD会更新为指向新分支的最近提交。
- `ORIG_HEAD`，某些操作，如合并merge和复位reset,会把调整为新值之前的先前版本的HEAD记录到ORIG_HEAD中，可以使用ORIG_HEAD来恢复或回滚到之前的状态或者做一个比较。
- `FETCH_HEAD`，当使用远程库时， `git fetch`命令将所有抓取分支的头记录到`.git/FETCH_HEAD`中，FETCH_HEAD是最近抓取fetch的分支HEAD的缩写。
- `MERGE_HEAD`，当一个合并操作正在进行时，其他分支的头暂时记录在MERGE_HEAD中，换言之，MERGE_HEAD是正在合并进HEAD的提交。
- 不使用使用这些特殊名称来创建你自己的分支。





#### 6.2.3 相对提交名

- `master^`始终指的是在`master`分支中的倒数第二个提交。
- 除了第一个根提交之外，每一个提交都来自至少一个比它更早的提交，这其中的直接祖先称作该提交的父提交。
- 若一个提交存在多个父提交，那么它必定是由合并操作产生的。只有当存在合并时，才会有多个父提交！
- 在同一代提交中，插入符号`^`是用来选择不同的父提交的。给定一个提交`C`，则`C^1`是其第一个父提交，`C^2`是其第二个父提交，`C^3`是其第三个父提交，依次类推。一个提交至少有一个父提交，不一定有多个父提交！！
- 波浪线`~`用于返回父提交之前并选择上一代提交。`C~1`表示提交`C`的第一个父提交，`C~2`是祖父提交，`C~3`是曾祖父提交。
- Git也支持其他形式的简写，如`C^`和`C~`两种形式的简写分别等同于`C^1`和`C~1`。
- 注意，`C^^^`与`C^3`不是等价的，而是等价于`C^1^1^1`。



提交历史图中可以看到类似的显示：

```sh
mei@4144e8c22fff:~/git$ git rev-parse master
670b81a890388c60b7032a4f5b879f2ece8c4558
mei@4144e8c22fff:~/git$ git show-branch --more=35|tail -10
[master~14] Merge branch 'ah/setup-extensions-message-i18n-fix'
[master~14^2] setup: split "extensions found" messages into singular and plural
[master~15] Merge branch 'ah/fetch-reject-warning-grammofix'
[master~15^2] fetch: improve grammar of "shallow roots" message
[master~16] Merge branch 'jk/doc-color-pager'
[master~16^2] doc: explain the use of color.pager
[master~17] Merge branch 'tl/fix-packfile-uri-doc'
[master~17^2] packfile-uri.txt: fix blobPackfileUri description
[master~18] Merge branch 'ry/clarify-fast-forward-in-glossary'
[master~18^2] docs: improve fast-forward in glossary content
```

查看相对提交的散列值：

```sh
mei@4144e8c22fff:~/git$ git rev-parse master~14
ccf03789058e9fd2a6120d88a3ad1ceac478e5ab
mei@4144e8c22fff:~/git$ git rev-parse master~14^2
8013d7d9ee7674774f6dbdbaeab11ce173bee016
```

我们也可以通过`git log`查看提交对应的父提交的父提交的哈希值。

```sh
mei@4144e8c22fff:~/git$ git log --pretty="commit:%h    parents:%p" -n 20
commit:670b81a890    parents:98f3f03bcb
commit:98f3f03bcb    parents:2019256717 7ba3016729
commit:2019256717    parents:c189dba20e f0d4d398e2
commit:c189dba20e    parents:d9d3b76fee 5317dfeaed
commit:d9d3b76fee    parents:ac2158649d 225f7fa847
commit:ac2158649d    parents:8e444e66df 4e0a64a713
commit:8e444e66df    parents:169914ede2 f5bfcc823b
commit:169914ede2    parents:4dd75a195b 25e65b6dd5
commit:4dd75a195b    parents:0dd2fd18f8 ae1a7eefff
commit:0dd2fd18f8    parents:f4f7304b44 f6e2cd0625
commit:f4f7304b44    parents:135997254a 6aacb7d861
commit:135997254a    parents:289af16300 cd5b33fbdc
commit:289af16300    parents:211eca0895 1197f1a463
commit:211eca0895    parents:ccf0378905
commit:ccf0378905    parents:3153c83c77 8013d7d9ee
commit:3153c83c77    parents:7ce7a617b9 09667e9516
commit:7ce7a617b9    parents:8e1d2fc0cc a84216c684
commit:8e1d2fc0cc    parents:7f06d94e72 3127ff90ea
commit:7f06d94e72    parents:e4b5d2a83f e22f2daed0
commit:e4b5d2a83f    parents:b009fd41e8 e2c5993744
mei@4144e8c22fff:~/git$
```

如第一行记录的提交`670b81a890`，其只有一个父提交`98f3f03bcb`:

```sh
mei@4144e8c22fff:~/git$ git rev-parse 670b81a890^
98f3f03bcbf4e0eda498f0a0c01d9bd90de9e106
mei@4144e8c22fff:~/git$ git rev-parse 670b81a890^1
98f3f03bcbf4e0eda498f0a0c01d9bd90de9e106
mei@4144e8c22fff:~/git$ git rev-parse 670b81a890^2
670b81a890^2
fatal: ambiguous argument '670b81a890^2': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
mei@4144e8c22fff:~/git$
```

使用`670b81a890^2`抛出了异常，因为该提交只有一个父提交，没有两个父提交。



而`98f3f03bcb`有两个父提交`2019256717`和`7ba3016729`:

```sh
mei@4144e8c22fff:~/git$ git rev-parse 98f3f03bcb^
2019256717d70bcfa1c6cd3869cfdc02310adb7a
mei@4144e8c22fff:~/git$ git rev-parse 98f3f03bcb^1
2019256717d70bcfa1c6cd3869cfdc02310adb7a
mei@4144e8c22fff:~/git$ git rev-parse 98f3f03bcb^2
7ba30167291eb89f2e587b7cabfa4e7555de4ed5
mei@4144e8c22fff:~/git$ git rev-parse 98f3f03bcb^3
98f3f03bcb^3
fatal: ambiguous argument '98f3f03bcb^3': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
mei@4144e8c22fff:~/git$
```

可以看到，通过`98f3f03bcb^1`获取到第一个父提交，通过`98f3f03bcb^2`获取到第2个父提交。



我们可以通过以下命令来获取所有提交有哪些父提交、父提交个数等。

```sh
# 获取提交的父提交哈希ID
mei@4144e8c22fff:~/git$ git log --pretty="commit:%h    parents:%p" -n 5
commit:670b81a890    parents:98f3f03bcb
commit:98f3f03bcb    parents:2019256717 7ba3016729
commit:2019256717    parents:c189dba20e f0d4d398e2
commit:c189dba20e    parents:d9d3b76fee 5317dfeaed
commit:d9d3b76fee    parents:ac2158649d 225f7fa847

# 获取提交的父提交个数
mei@4144e8c22fff:~/git$ git log --pretty="commit:%h    parents:%p" -n 5|awk '{print $1"\tparents:"NF-1}'
commit:670b81a890	parents:1
commit:98f3f03bcb	parents:2
commit:2019256717	parents:2
commit:c189dba20e	parents:2
commit:d9d3b76fee	parents:2

# 获取提交的父提交个数最多的提交
mei@4144e8c22fff:~/git$ git log --pretty="commit:%h    parents:%p"|awk '{print $1"\tparents:"NF-1}'|sort -nr -t":" -k3|head
commit:16d7601e17	parents:10
commit:d425142e2a	parents:6
commit:addafaf92e	parents:5
commit:5401f3040b	parents:5
commit:211232bae6	parents:5
commit:92643a27cc	parents:4
commit:7bd1527d2d	parents:4
commit:63c2fcefd8	parents:4
commit:474bc4e274	parents:4
commit:2d310d8a01	parents:4
mei@4144e8c22fff:~/git$
```

可以知道`16d7601e17`这次提交有10个父提交，我们检查一下：

```sh
mei@4144e8c22fff:~/git$ git log --pretty="commit:%h    parents:%p"|grep 16d7601e17
commit:b71c6c3b64    parents:16d7601e17
commit:16d7601e17    parents:f7a8834ba4 492595cfc7 63100874c1 474642b4a4 331450f18a 76756d6706 6a47fa0efa 146a6f1097 f50d5055bf 5440eb0ea2
mei@4144e8c22fff:~/git$
```



### 6.3  提交历史记录

#### 6.3.1 查看旧提交

- 显示提交历史记录的主要命令是`git log`。
- 在参数形式上，`git log`跟`git log HEAD`是一样的，输出每一个可从HEAD找到的历史记录中的提交日志信息。
- 变更从HEAD提交开始显示，并从提交图中回溯。大致按时间逆序显示。

为了和书上的显示结果保持一致，我们切换到`1fbb58b4153e90eda08c2b022ee32d90729582e6`这次提交，并绑定到`dev`分支上：

```sh
mei@4144e8c22fff:~/git$ git checkout -b dev 1fbb58b415
Switched to a new branch 'dev'
mei@4144e8c22fff:~/git$ git branch
* dev
  master
```

此时查看日志信息：

```sh
mei@4144e8c22fff:~/git$ git log
commit 1fbb58b4153e90eda08c2b022ee32d90729582e6 (HEAD -> dev)
Merge: 58949bb18a 76bb40cde0
Author: Junio C Hamano <gitster@pobox.com>
Date:   Thu May 15 01:31:15 2008 -0700

    Merge git://repo.or.cz/git-gui

    * git://repo.or.cz/git-gui:
      git-gui: Delete branches with 'git branch -D' to clear config
      git-gui: Setup branch.remote,merge for shorthand git-pull
      git-gui: Update German translation
      git-gui: Don't use '$$cr master' with aspell earlier than 0.60
      git-gui: Report less precise object estimates for database compression

commit 58949bb18a1610d109e64e997c41696e0dfe97c3
Author: Chris Frey <cdfrey@foursquare.net>
Date:   Wed May 14 19:22:18 2008 -0400

    Documentation/git-prune.txt: document unpacked logic

    Clarifies the git-prune man page, documenting that it only
    prunes unpacked objects.

    Signed-off-by: Chris Frey <cdfrey@foursquare.net>
    Signed-off-by: Junio C Hamano <gitster@pobox.com>

commit c7ea453618e41e05a06f05e3ab63d555d0ddd7d9
Merge: 4b172de81b 08ba820fd7
Author: Junio C Hamano <gitster@pobox.com>
。。。省略
```



查看两个区间内的提交：

```sh
mei@4144e8c22fff:~/git$ git log --abbrev-commit --pretty=short dev~12..dev~10
commit 6d9878cc60
Author: Jeff King <peff@peff.net>

    clone: bsd shell portability fix

commit 30684dfaf8
Author: Jeff King <peff@peff.net>

    t5000: tar portability fix
mei@4144e8c22fff:~/git$
```

这是查看dev分支上之前10次和第11次的提交。

- `--abbrev-commit`参数用于显示缩写散列ID值。
- `--pretty=short`用于调整每个提交的信息量，short表示简短的信息，还可以是`oneline`单行显示或`full`完整显示。

```sh
mei@4144e8c22fff:~/git$ git log --abbrev-commit --pretty=oneline dev~12..dev~10
6d9878cc60 clone: bsd shell portability fix
30684dfaf8 t5000: tar portability fix
mei@4144e8c22fff:~/git$ git log --abbrev-commit --pretty=full dev~12..dev~10
commit 6d9878cc60
Author: Jeff King <peff@peff.net>
Commit: Junio C Hamano <gitster@pobox.com>

    clone: bsd shell portability fix

    When using /bin/sh from FreeBSD 6.1, the value of $? is lost
    when calling a function inside the 'trap' action. This
    resulted in clone erroneously indicating success when it
    should have reported failure.

    As a workaround, we save the value of $? before calling any
    functions.

    Signed-off-by: Jeff King <peff@peff.net>
    Signed-off-by: Junio C Hamano <gitster@pobox.com>

commit 30684dfaf8
Author: Jeff King <peff@peff.net>
Commit: Junio C Hamano <gitster@pobox.com>

    t5000: tar portability fix

    The output of 'tar tv' varies from system to system. In
    particular, the t5000 was expecting to parse the date from
    something like:

      -rw-rw-r-- root/root         0 2008-05-13 04:27 file

    but FreeBSD's tar produces this:

      -rw-rw-r--  0 root   root        0 May 13 04:27 file

    Instead of relying on tar's output, let's just extract the
    file using tar and stat the result using perl.

    Signed-off-by: Jeff King <peff@peff.net>
    Signed-off-by: Junio C Hamano <gitster@pobox.com>
```



- `--stat`参数可以列出提交中所更改的文件以及每个更改的文件中有多少行做了改动。

```sh
mei@4144e8c22fff:~/git$ git log --abbrev-commit --pretty=oneline --stat dev~12..dev~10
6d9878cc60 clone: bsd shell portability fix
 git-clone.sh | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)
30684dfaf8 t5000: tar portability fix
 t/t5000-tar-tree.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)
```

`git log`中还有很多其他的参数，可以查看帮助文档。



#### 6.3.2 提交图

略。

#### 6.3.3 提交范围

略。

### 6.4 查找提交

Git提供多种机制来帮助你找到符合特定条件的提交。

我们以Git源码进行测试。

#### 6.4.1 使用`git bisect`查找bug是哪个提交引入的

查看`git bisect`的帮助信息：

```sh
mei@4144e8c22fff:~/git$ git bisect --help|head -n 4|awk NF
GIT-BISECT(1)                                         Git Manual                                        GIT-BISECT(1)
NAME
       git-bisect - Use binary search to find the commit that introduced a bug
mei@4144e8c22fff:~/git$ git bisect -h
usage: git bisect [help|start|bad|good|new|old|terms|skip|next|reset|visualize|view|replay|log|run]

git bisect help
	print this long help message.
git bisect start [--term-{old,good}=<term> --term-{new,bad}=<term>]
		 [--no-checkout] [<bad> [<good>...]] [--] [<pathspec>...]
	reset bisect state and start bisection.
git bisect (bad|new) [<rev>]
	mark <rev> a known-bad revision/
		a revision after change in a given property.
git bisect (good|old) [<rev>...]
	mark <rev>... known-good revisions/
		revisions before change in a given property.
git bisect terms [--term-good | --term-bad]
	show the terms used for old and new commits (default: bad, good)
git bisect skip [(<rev>|<range>)...]
	mark <rev>... untestable revisions.
git bisect next
	find next bisection to test and check it out.
git bisect reset [<commit>]
	finish bisection search and go back to commit.
git bisect (visualize|view)
	show bisect status in gitk.
git bisect replay <logfile>
	replay bisection log.
git bisect log
	show bisect log.
git bisect run <cmd>...
	use <cmd>... to automatically bisect.

Please use "git help bisect" to get the full man page.
mei@4144e8c22fff:~/git$
```

可知，该命令是使用进制搜索查找引入错误的提交。

通过`git bisect start`开始二分查找，然后指定一个旧的版本看哪个版本是`good`好的，再检查下一个是好是坏。



#### 6.4.2 `git blame`代码行最后是谁修改的

- `git blame`可以告诉你一个文件中的每一行最后是谁修改的和哪次提交做出了变更。
- `blame`是责备，责任的意思，即这一行代码最后由谁负责，因为你最后修改了这一行，你就需要为你的修改负责。

我们测试一下。

先查看`README.md`文件30-37行的内容：

```sh
mei@4144e8c22fff:~/git$ sed -n '30,37p' README.md
installed).

The user discussion and development of Git take place on the Git
mailing list -- everyone is welcome to post bug reports, feature
requests, comments and patches to git@vger.kernel.org (read
[Documentation/SubmittingPatches][] for instructions on patch submission).
To subscribe to the list, send an email with just "subscribe git" in
the body to majordomo@vger.kernel.org. The mailing list archives are
mei@4144e8c22fff:~/git$
```

再修改`git blame`查看一下这些行最后是由谁修改的：

```sh
mei@4144e8c22fff:~/git$ git blame -L 30,37 README.md
aa98eb3d658 README    (Christian Couder 2009-02-24 21:16:37 +0100 30) installed).
556b6600b25 README    (Nicolas Pitre    2007-01-17 13:04:39 -0500 31)
556b6600b25 README    (Nicolas Pitre    2007-01-17 13:04:39 -0500 32) The user discussion and development of Git take place on the Git
556b6600b25 README    (Nicolas Pitre    2007-01-17 13:04:39 -0500 33) mailing list -- everyone is welcome to post bug reports, feature
07f050c9996 README    (Matthieu Moy     2012-02-23 13:52:06 +0100 34) requests, comments and patches to git@vger.kernel.org (read
6164972018b README.md (Matthieu Moy     2016-02-25 09:37:27 +0100 35) [Documentation/SubmittingPatches][] for instructions on patch submission).
07f050c9996 README    (Matthieu Moy     2012-02-23 13:52:06 +0100 36) To subscribe to the list, send an email with just "subscribe git" in
07f050c9996 README    (Matthieu Moy     2012-02-23 13:52:06 +0100 37) the body to majordomo@vger.kernel.org. The mailing list archives are
mei@4144e8c22fff:~/git$
```

对于`git`的源代码，其`README.md`文件的第30到37行分别由哪些人修改的。比如，32行的内容`The user discussion and development of Git take place on the Git`，最后是由`Nicolas Pitre`这个开发人员于2007-01-17 13:04:39 -0500这个时间修改的，对应的提交ID是`556b6600b25`。

我们使用`git show`查看一下该提交到底修改了什么：

```sh
mei@4144e8c22fff:~/git$ git show 556b6600b25|head
commit 556b6600b25713054430b1dcaa731120eefbbd5b
Author: Nicolas Pitre <nico@fluxnic.net>
Date:   Wed Jan 17 13:04:39 2007 -0500

    sanitize content of README file

    Current README content is way too esoteric for someone looking at GIT
    for the first time. Instead it should provide a quick summary of what
    GIT is with a few pointers to other resources.

mei@4144e8c22fff:~/git$ git show 556b6600b25|grep 'The user'
+The user discussion and development of Git take place on the Git
mei@4144e8c22fff:~/git$
```

由于此次修改的内容比较多，你可以直接使用`git show 556b6600b25`查看修改的内容，此处仅显示前十行，然后通过过滤可以看到，的确有一个`+The user discussion and development of Git take place on the Git`,表示此次修改增加了一行，其内容是`The user discussion and development of Git take place on the Git`,这刚好与我们使用`git blame`显示出来的结果是对应的。说明的确可以通过`git blame`找到是谁修改了这行代码！！



## 第7章 分支

- 分支是在软件项目中启动一条单独的开发线的基本方法。
- Git的分支系统是轻量级的、简单的。

### 7.1 使用分支的原因

有无数个技术、哲学、管理，甚至是社会方面的理由来创建分支。如：

- 一个分支通常代表一个单独的客户发布版。
- 一个分支可以封装一个开发阶段，比如原型、测试、稳定或临近发布。
- 一个分支可以隔离一个特性的开发或者研究特别复杂的bug。
- 每一个分支可以代表单个贡献者的工作，另一个分支集成分支，可以专门用于凝聚(五笔`uxbc`)力量。



Git把列出的这些分支视为特性分支(topic branch)或开发分支(development branch)，特性仅指每个分支在版本库中的特定的目的。



#### 7.1.1 分支还是标签

- 标签和分支用于不同的目的。
- 标签是一个静态的名字，它不随着时间的推移而改变。一旦应用，你不应该对它做任何改动。它相当于地上的一个支柱和参考点。
- 分支是动态的，并且随着你的每次提交而移动。分支名用来跟随你的持续开发。
- 可以用同一个名字来命名分支和标签。但应避免使用相同的名称命名分支和标签。



### 7.2 分支名

- 版本库中的默认分支是`master`，大多数开发人员在这个分支上保持版本库中最强大和最可靠的开发线。
- 最佳实践是不要修改`master`分支的名称，也不要删除它。
- 为了支持可扩展性和分类组织，可以创建一个带层次的分支名，类似于UNIX的路径名。如`bug/pr-01`，`bug/pr-02`。
- Git支持Unix类似的通配符，如`*`。

分支名的限制，可以使用`git check-ref-format --help`来查看分支名的要求。该命令会检查`refname`是否是可接受的，如果不是的话，则会以非零状态退出。

```sh
mei@4144e8c22fff:~/git$ git check-ref-format --help|cat
GIT-CHECK-REF-FOR(1)                                  Git Manual                                 GIT-CHECK-REF-FOR(1)

NAME
       git-check-ref-format - Ensures that a reference name is well formed

SYNOPSIS
       git check-ref-format [--normalize]
              [--[no-]allow-onelevel] [--refspec-pattern]
              <refname>
       git check-ref-format --branch <branchname-shorthand>

DESCRIPTION
       Checks if a given refname is acceptable, and exits with a non-zero status if it is not.

       A reference is used in Git to specify branches and tags. A branch head is stored in the refs/heads hierarchy,
       while a tag is stored in the refs/tags hierarchy of the ref namespace (typically in $GIT_DIR/refs/heads and
       $GIT_DIR/refs/tags directories or, as entries in file $GIT_DIR/packed-refs if refs are packed by git gc).

       Git imposes the following rules on how references are named:

        1. They can include slash / for hierarchical (directory) grouping, but no slash-separated component can begin
           with a dot .  or end with the sequence .lock.

        2. They must contain at least one /. This enforces the presence of a category like heads/, tags/ etc. but the
           actual names are not restricted. If the --allow-onelevel option is used, this rule is waived.

        3. They cannot have two consecutive dots ..  anywhere.

        4. They cannot have ASCII control characters (i.e. bytes whose values are lower than \040, or \177 DEL),
           space, tilde ~, caret ^, or colon : anywhere.

        5. They cannot have question-mark ?, asterisk *, or open bracket [ anywhere. See the --refspec-pattern option
           below for an exception to this rule.

        6. They cannot begin or end with a slash / or contain multiple consecutive slashes (see the --normalize
           option below for an exception to this rule)

        7. They cannot end with a dot ..

        8. They cannot contain a sequence @{.

        9. They cannot be the single character @.

       10. They cannot contain a \.

       These rules make it easy for shell script based tools to parse reference names, pathname expansion by the
       shell when a reference name is used unquoted (by mistake), and also avoid ambiguities in certain reference
       name expressions (see gitrevisions(7)):

        1. A double-dot ..  is often used as in ref1..ref2, and in some contexts this notation means ^ref1 ref2 (i.e.
           not in ref1 and in ref2).

        2. A tilde ~ and caret ^ are used to introduce the postfix nth parent and peel onion operation.

        3. A colon : is used as in srcref:dstref to mean "use srcref's value and store it in dstref" in fetch and
           push operations. It may also be used to select a specific object such as with git cat-file: "git cat-file
           blob v1.3.3:refs.c".

        4. at-open-brace @{ is used as a notation to access a reflog entry.

       With the --branch option, the command takes a name and checks if it can be used as a valid branch name (e.g.
       when creating a new branch). But be cautious when using the previous checkout syntax that may refer to a
       detached HEAD state. The rule git check-ref-format --branch $name implements may be stricter than what git
       check-ref-format refs/heads/$name says (e.g. a dash may appear at the beginning of a ref component, but it is
       explicitly forbidden at the beginning of a branch name). When run with --branch option in a repository, the
       input is first expanded for the "previous checkout syntax" @{-n}. For example, @{-1} is a way to refer the
       last thing that was checked out using "git switch" or "git checkout" operation. This option should be used by
       porcelains to accept this syntax anywhere a branch name is expected, so they can act as if you typed the
       branch name. As an exception note that, the "previous checkout operation" might result in a commit object name
       when the N-th last thing checked out was not a branch.

OPTIONS
       --[no-]allow-onelevel
           Controls whether one-level refnames are accepted (i.e., refnames that do not contain multiple /-separated
           components). The default is --no-allow-onelevel.

       --refspec-pattern
           Interpret <refname> as a reference name pattern for a refspec (as used with remote repositories). If this
           option is enabled, <refname> is allowed to contain a single * in the refspec (e.g., foo/bar*/baz or
           foo/bar*baz/ but not foo/bar*/baz*).

       --normalize
           Normalize refname by removing any leading slash (/) characters and collapsing runs of adjacent slashes
           between name components into a single slash. If the normalized refname is valid then print it to standard
           output and exit with a status of 0, otherwise exit with a non-zero status. (--print is a deprecated way to
           spell --normalize.)

EXAMPLES
       o   Print the name of the previous thing checked out:

               $ git check-ref-format --branch @{-1}

       o   Determine the reference name to use for a new branch:

               $ ref=$(git check-ref-format --normalize "refs/heads/$newbranch")||
               { echo "we do not like '$newbranch' as a branch name." >&2 ; exit 1 ; }

GIT
       Part of the git(1) suite

Git 2.25.1                                            03/04/2021                                 GIT-CHECK-REF-FOR(1)
mei@4144e8c22fff:~/git$
```



下面列出帮助信息中，10条引用命名的规则：

- 1. 可以使用`/`斜杠创建分层的命名方案，但是，分支名不能以`.`开头，也不能是`.lock`结尾。
- 2. 必须至少包含一个`/`，由于我们一版使用的是相对引用，此条是非必须的。
- 3. 不包包含两个点号`..`。
- 4. 不能包含ASCII码控制符，如低于`\040`的字符、空格、波浪号`~`、插入符`^`、冒号`:`。
- 5. 不能包含`?`、`*`、`[`等。
- 6. 不能以`/`斜杠开头。
- 7. 不能以`.`圆点结尾。
- 8. 不能包含`@{`序列。
- 9. 不能包含单一的`@`字符。
- 10. 不能包含`\`反斜杠。

可以看到，规则真复杂。建议使用英文小写开头、后接英文小写、数字、`-`等组成的引用命名。



我们使用`git chec-ref-format`进行命名检查一下。

```sh
# 分支名异常的示例
mei@4144e8c22fff:~/git$ git check-ref-format --branch "@{"
fatal: '@{' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "/"
fatal: '/' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "/bug"
fatal: '/bug' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "/.bug"
fatal: '/.bug' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch ".bug"
fatal: '.bug' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "bug/"
fatal: 'bug/' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "bug."
fatal: 'bug.' is not a valid branch name
mei@4144e8c22fff:~/git$ git check-ref-format --branch "bug\\"
fatal: 'bug\' is not a valid branch name


# 分支名正确的示例
mei@4144e8c22fff:~/git$ git check-ref-format --branch "bug/pr-1"
bug/pr-1
mei@4144e8c22fff:~/git$ git check-ref-format --branch "bug/pr-2"
bug/pr-2
mei@4144e8c22fff:~/git$ git check-ref-format --branch "develop"
develop
mei@4144e8c22fff:~/git$ git check-ref-format --branch "master"
master
mei@4144e8c22fff:~/git$ git check-ref-format --branch "feature-01"
feature-01
mei@4144e8c22fff:~/git$ git check-ref-format --branch "feature-02"
feature-02
mei@4144e8c22fff:~/git$
```

可以看到使用英文字母开头+横线`-`+数字序列作为分支名比较靠谱。



### 7.3 使用分支

- 在任何给定的时间里， 版本库中可能有许多不同的分支。但最多只有一个当前的或活动的分支。
- 活动分支决定在工作目录中检出哪些文件。
- 默认情况下，`master`分支是活动分支，但可以把任何分支设置成当前分支。
- 分支允许版本库中每一分支的内容赂许多不同的方向发散。
- 当一个版本库你分出至少一个分支时，把每次提交应用到某个分支，取决于哪个分支是活动的。
- 每个分支在一特定的版本库中必须有唯一的名字，这个名字始终指向该分支上最近提交的版本。一个分支的最近提交称为该分支的头部(tip或head)。
- Git不会保持分支的起源信息。
- 发布一分支必须是显式的完成。
- 如果复制版本库，分支名和那些分支上的开发都将是新复制版本库的副本的一部分。



### 7.4 创建分支

- 新的分支基于版本库中现在的提交。
- 可以使用`git branch branchName`创建分支。
- `git branch`命令只是把分支名引进版本库。并没有改变工作目录去使用新的分支。

如创建`dev`分支：

```sh
mei@4144e8c22fff:~/git$ git branch dev
mei@4144e8c22fff:~/git$ git branch
  dev
* master
mei@4144e8c22fff:~/git$
```

可以看到虽然创建新的分支`dev`，但当前分支还是`master`，并没有切换到`dev`分支。

### 7.5 列出分支名

- 可以直接使用`git branch`列出版本库中的分支名。
- `git branch -r`则会列出远程分支。
- `git branch -a`则会列出本地分支和远程分支。

```sh
mei@4144e8c22fff:~/git$ git branch -r
  origin/HEAD -> origin/master
  origin/maint
  origin/master
  origin/next
  origin/seen
  origin/todo
mei@4144e8c22fff:~/git$ git branch -a
  dev
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/maint
  remotes/origin/master
  remotes/origin/next
  remotes/origin/seen
  remotes/origin/todo
```



### 7.6 查看分支

- `git show-branch`则可以提供比`git branch`更详细的分支信息。

```sh
mei@4144e8c22fff:~/git$ git show-branch
! [dev] The second batch
 * [master] The second batch
--
+* [dev] The second batch
mei@4144e8c22fff:~/git$
```

`git show-branch`的输出被一排破折号(如第4行的`--`)分为两部分。分隔符上方的部分列出分支名，并用方括号括起来，每行一个。每个分支名前会用感叹号或星号标记，如果该分支是当前分支，则会用星号`*`标记(如第3行的`master`分支是当前分支，用星号标记了)。输出的下半部分是一个表示每个分支中提交的矩阵。



### 7.7 检出分支

- 工作目录一次只能反映一个分支。
- 要在不同的分支上开始工作，要发出`git checkout`命令。
- 使用`git checkout branchName`可以使用`branchName`分支变成新的当前分支。它改变了工作树文件和目录结构来匹配给定分支的状态。

如现在我们要切换到`dev`分支，则可以这样：

```sh
mei@4144e8c22fff:~/git$ git checkout dev
Switched to branch 'dev'
mei@4144e8c22fff:~/git$ git branch
* dev
  master
mei@4144e8c22fff:~/git$ git show-branch
* [dev] The second batch
 ! [master] The second batch
--
*+ [dev] The second batch
mei@4144e8c22fff:~/git$
```

可以看到当前分支已经是`dev`分支了，在分支名`dev`前方也可以看到星号标记。



选择一个新的当前分支可能会对工作树文件和目录结构产生巨大影响。如：

- 在要被检出的分支中但不在当前分支中的文件和目录，会从对象库中检出并放置到工作树中。
- 在当前分支中但不在要被检出的分支中的文件和目录，会从工作树中删除。
- 这两个分支都有的文件会被修改为要被检出的分支的内容。



如果想在创建分支的同时检出到该分支，则可以使用以下快捷命令：

- `git checkout -b new-branch`，这样git会创建`new-branch`分支，并切换到该分支。

```sh
mei@4144e8c22fff:~/git$ git checkout -b test
Switched to a new branch 'test'
mei@4144e8c22fff:~/git$ git branch
  dev
  master
* test
mei@4144e8c22fff:~/git$
```

可以看到，此时我们直接切换到了`test`分支，并没有使用`git branch`命令来先创建`test`分支。



### 7.8 删除分支

- 可以使用`git branch -d branchName`删除版本库中的分支`branchName`。
- 不能删除当前分支。
- `git branch -D branchName`会强制删除分支。



```sh
# 当前分支是test分支
mei@4144e8c22fff:~/git$ git branch
  dev
  master
* test
mei@4144e8c22fff:~/git$

# 尝试删除当前分支，可以发现无法删除
mei@4144e8c22fff:~/git$ git branch -d test
error: Cannot delete branch 'test' checked out at '/home/mei/git'

# 切换分支
mei@4144e8c22fff:~/git$ git checkout dev
Switched to branch 'dev'

# 再次删除test分支，可以删除成功
mei@4144e8c22fff:~/git$ git branch -d test
Deleted branch test (was 670b81a890).

# 再次查看分支情况，发现test分支已经没有了
mei@4144e8c22fff:~/git$ git branch
* dev
  master
```



- Git不会保持任何形式的关于分支名创建、移动、操纵、合并或删除的历史记录。一旦某个分支名删除了，它就没了。



## 第8章 diff差异

- `diff`是英文单词`differences`差异的缩写，指的是两个事务的不同。
- 使用`git diff`可以对版本库中的对象进行比较，显示其差异。

`git diff`命令的基本来源：

- 整个提交图中的任意树对象；
- 工作目录；
- 索引。

`git diff`命令可以使用上述三种来源的组合进行如下4种基本比较。

- `git diff`，显示工作目录和索引之间的差异。
- `git diff commit` , 显示工作目录和给你写提交间的差异。
- `git diff --cached commit`， 显示索引中的变更和给你写提交中的变更之间的差异。
- `git diff commit1 commit2`， 显示任意两个提交之间的差异。



当你对你的工作满意的时候，你可以利用`git add`命令暂存该文件，一旦将更改的文件暂存了，`git diff`命令就不会再为该文件输出diff。

- `git diff --cached`命令可以显示下次提交时索引中的额外变更或已暂存的变更。
- `git diff --staged`也可以看到暂存区中已经暂存的变更。





## 第9章 合并



- Git是一个分布式版本控制系统。
- 一次合并会结合两个或多个历史提交分支。
- 尽管Git还支持同时合并三个、四个或多个分支，但是大多数情况下，一次合并只结合两个分支。
- 当Git无法自动合并时，你需要在所有冲突都解决后做一次最终提交。

为了把`other_branch`合并到`branch`分支中，你应该检出目标分支并把其他分支合并进去，需要执行以下命令：

```sh
$ git checkout branch
$ git merge other_branch
```

合并的时候可能会存在冲突，这个时候你需要解决冲突。

- `git merge`操作是区分上下文的，当前分支始终是目标分支，其他一个或多个分支始终合并到当前分支。
- 当冲突出现时，通过三方比较或合并标记强调工作目录的每个冲突文件的副本。三方合并标记线`<<<<<<<<`、`========`、`>>>>>>>>`是自动生成的，但是它们只是提供给你看的，而不是给程序看的，一旦解决了冲突，就应该在文本编辑器里删除它们。



合并涉及到多次合并策略，相对麻烦。我一般会使用`Beyond Compare`对比工具，对比两个分支或目录的差异，并将需要提交的修改合并到目标分支或目录里面，避免冲突的出现，再进行提交。



## 第10章 更改提交



### 10.1 关于修改历史记录的注意事项

- 作为一般原则，只要没有其他开发人员已经获取了你的版本库的副本，你就可以自由地修改和完善版本库提交历史记录。
- 如果一个分支已经公开，并且可能已经存在于其他版本库中，那你就不应该重写、修改或更改该分支的任何部分。



### 10.2 使用`git reset`

- `git reset`命令会把版本库和工作目录改变为已知状态。
- 具体而言，`git reset`调整`HEAD`引用指向给定的提交，默认情况下还会更新索引以匹配该提交。
- `git reset`可以覆盖并销毁工作目录中的修改，数据可能会丢失。即使你备份了文件，也可能无法恢复你的工作。（可以复制一份版本库目录到别的文件夹进行备份，避免自己新修改的数据丢失）
- `git reset`命令的重点是`HEAD`、索引和工作目录建立与恢复已知的状态。
- `git reset`有三个主要选项:`--soft`、`--mixed`、`--hard`。

`git reset`不同选项对HEAD、索引和工作目录的内容的影响：

| 选项      | HEAD | 索引 | 工作目录 |
| --------- | ---- | ---- | -------- |
| `--soft`  | 是   | 否   | 否       |
| `--mixed` | 是   | 是   | 否       |
| `--hard`  | 是   | 是   | 是       |

即：

- 使用`--soft`选项时，会将HEAD引用指赂给定提交，但索引和工作目录的内容保持不变。
- 使用`--mixed`选项时，会将HEAD引用指赂给定提交，索引内容也跟着改变以符合给定提交的树结构，但工作目录的内容保持不变。这种是`git reset`的默认模式。
- 使用`--soft`选项时，会将HEAD引用指赂给定提交，索引内容也跟着改变以符合给定提交的树结构，同时工作目录的内容也改变以反映给定提交表示的树的状态。

我们简单的使用`git reset --hard`可以将本次做的修改全部还原。如果我们只想恢复某一个文件，可以使用`git checkout filename`。



如我们假设在`git`源码仓库中做一些修改，然后进行恢复。

我们先查看当前最新的日志信息：

```sh
mei@4144e8c22fff:~/git$ git log --pretty=oneline -n 1
670b81a890388c60b7032a4f5b879f2ece8c4558 (HEAD -> master, origin/master, origin/HEAD, dev) The second batch
```

随意做一些修改：

```sh
mei@4144e8c22fff:~/git$ echo 'add test 1' > help.c
mei@4144e8c22fff:~/git$ echo 'add test 2' > help.h
mei@4144e8c22fff:~/git$ git status
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   help.c
	modified:   help.h

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/git$
```



还原所有修改：

```sh
mei@4144e8c22fff:~/git$ git reset --hard
HEAD is now at 670b81a890 The second batch
mei@4144e8c22fff:~/git$ git status
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

nothing to commit, working tree clean
mei@4144e8c22fff:~/git$
```

可以看到，我们做的修改直接被还原了。



使用`git checkout filename`还原单个文件：

```sh
mei@4144e8c22fff:~/git$ echo 'add test 1' > help.c
mei@4144e8c22fff:~/git$ echo 'add test 2' > help.h
mei@4144e8c22fff:~/git$ gs
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   help.c
	modified:   help.h

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/git$ git checkout help.h
Updated 1 path from the index
mei@4144e8c22fff:~/git$ gs
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   help.c

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/git$
```

可以看到，我们使用`git checkout help.h`将`help.h`的修改还原了，现在只有`help.c`发生了变化。



#### 10.2.1 还原提交示例

`git reset`一个常见用法是简单地重做或清除分支上的最近提交。

```sh
mei@4144e8c22fff:~$ mkdir reset
mei@4144e8c22fff:~$ cd reset
mei@4144e8c22fff:~/reset$ ls

# 创建存储库
mei@4144e8c22fff:~/reset$ git init
Initialized empty Git repository in /home/mei/reset/.git/

# 创建第一个提交
mei@4144e8c22fff:~/reset$ echo 'foo' > master_file
mei@4144e8c22fff:~/reset$ git add master_file
mei@4144e8c22fff:~/reset$ git commit -m"Add master_file to master branch."
[master (root-commit) e8b365c] Add master_file to master branch.
 1 file changed, 1 insertion(+)
 create mode 100644 master_file

# 创建第二个提交
mei@4144e8c22fff:~/reset$ echo 'more foo' >> master_file
mei@4144e8c22fff:~/reset$ git add .
mei@4144e8c22fff:~/reset$ git commit -m"Add more foo."
[master d0662a8] Add more foo.
 1 file changed, 1 insertion(+)
 
# 查看分支信息 
mei@4144e8c22fff:~/reset$ git show-branch --more=5
[master] Add more foo.
[master^] Add master_file to master branch.
mei@4144e8c22fff:~/reset$

# 查看日志信息
mei@4144e8c22fff:~/reset$ git log --pretty=oneline -n 2
d0662a8b18600abb8850bdae44dd92e6716760f6 (HEAD -> master) Add more foo.
e8b365c2dad8235f8bedac9cb1a7ebc4e20253e5 Add master_file to master branch.

# 查看HEAD和HEAD^对应的commit id
mei@4144e8c22fff:~/reset$ git rev-parse HEAD
d0662a8b18600abb8850bdae44dd92e6716760f6
mei@4144e8c22fff:~/reset$ git rev-parse HEAD^
e8b365c2dad8235f8bedac9cb1a7ebc4e20253e5
```

我们备份一个`reset`目录，便于下面做测试时还原数据。

```sh
mei@4144e8c22fff:~/reset$ cp -rf ~/reset ~/reset.bak
```



假设现在意识到第二个提交是错的，要返回改变一下。这是`git reset --mixed HEAD^`的典型应用，`HEAD^`是指向当前master HEAD的父提交，代表完成第二个有缺陷的提交之前的状态。

现在我们来还原：

```sh
# 查看当前文件的内容
mei@4144e8c22fff:~/reset$ cat master_file
foo
more foo
mei@4144e8c22fff:~/reset$ 

# 还原
# --mixed 是默认的
mei@4144e8c22fff:~/reset$ git reset HEAD^
Unstaged changes after reset:
M	master_file

# 查看分支状况，可以看到，刚才第二次的提交已经没有了
mei@4144e8c22fff:~/reset$ git show-branch --more=5
[master] Add master_file to master branch.

# 这时查看日志信息，可以看到第二次的提交也没有了
mei@4144e8c22fff:~/reset$ git log --pretty=oneline
e8b365c2dad8235f8bedac9cb1a7ebc4e20253e5 (HEAD -> master) Add master_file to master branch.

# 查看文件内容，可以看到，我们修改后的文件内容还保持原样
mei@4144e8c22fff:~/reset$ cat master_file
foo
more foo

# 查看分支状态，此时可以看到，状态还原到第二次执行git add之前的状态
mei@4144e8c22fff:~/reset$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   master_file

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/reset$
```

因为`git reset --mixed`会重置索引，所有必须重新暂存你想要提交的修改。这让你有什么我发错在做出新提交之前重新编辑你的文件，添加其他文件，或者执行其他修改。



我们复制一下备份数据。

```sh
mei@4144e8c22fff:~/reset$ cp -rf ~/reset.bak ~/reset
```



假如你要完全取消第二次提交，不再关心它的内容了，在这种情况下，使用`--hard`选项：

```sh
# 强制还原，这样第二次做的修改都不会保存
mei@4144e8c22fff:~/reset$ git reset --hard HEAD^
HEAD is now at e8b365c Add master_file to master branch.
mei@4144e8c22fff:~/reset$ git show-branch --more=5
[master] Add master_file to master branch.
mei@4144e8c22fff:~/reset$ git log
commit e8b365c2dad8235f8bedac9cb1a7ebc4e20253e5 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sun Jan 9 19:13:59 2022 +0800

    Add master_file to master branch.
mei@4144e8c22fff:~/reset$

# 此时master_file变成最原始的状态
mei@4144e8c22fff:~/reset$ cat master_file
foo
```



#### 10.2.2 查看版本库引用变化的历史记录

你可以使用`git reflog`查看版本库中引用变化的历史记录：

```sh
mei@4144e8c22fff:~/reset$ git reflog
e8b365c (HEAD -> master) HEAD@{0}: reset: moving to HEAD
e8b365c (HEAD -> master) HEAD@{1}: reset: moving to HEAD^
d0662a8 HEAD@{2}: commit: Add more foo.
e8b365c (HEAD -> master) HEAD@{3}: commit (initial): Add master_file to master branch.
mei@4144e8c22fff:~/reset$
```



总结：

- `git reset --mixed HEAD^`，取消本次提交，但不还原本次所做的修改。
- `git reset --hard HEAD^`，取消本次提交，并且将本次做的修改都还原成原始状态。



### 10.3 使用git cherry-pick

- `git cherry-pick`提交命令会在当前分支上应用给定提交引入的变更。这将引入一个新的独特的提交。
- 使用`git cherry-pick`并不改变版本库中的现有历史记录，而是添加历史记录。

下面示例演示将`dev`分支上的提交应用到`master`分支：

```sh
mei@4144e8c22fff:~$ mkdir pick
mei@4144e8c22fff:~$ cd pick/
mei@4144e8c22fff:~/pick$ ls
mei@4144e8c22fff:~/pick$ git init
Initialized empty Git repository in /home/mei/pick/.git/
mei@4144e8c22fff:~/pick$ echo 'foo' > bar.txt
mei@4144e8c22fff:~/pick$ git add .
mei@4144e8c22fff:~/pick$ git commit -m"add foo"
[master (root-commit) 5c5d79e] add foo
 1 file changed, 1 insertion(+)
 create mode 100644 bar.txt
mei@4144e8c22fff:~/pick$ git log --pretty=oneline
5c5d79eb96535fa83b35b3ae51b629ed77b546d2 (HEAD -> master) add foo

# 切换到dev分支，并在分支上做修改
mei@4144e8c22fff:~/pick$ git checkout -b dev
Switched to a new branch 'dev'
mei@4144e8c22fff:~/pick$ cat bar.txt
foo
mei@4144e8c22fff:~/pick$ echo 'foo dev' >> bar.txt

# 提交dev分支上的修改
mei@4144e8c22fff:~/pick$ git add .
mei@4144e8c22fff:~/pick$ git status
On branch dev
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   bar.txt

mei@4144e8c22fff:~/pick$ git commit -m"add foo in bar"
[dev 196b823] add foo in bar
 1 file changed, 1 insertion(+)
 
# 查看dev分支的提交日志
mei@4144e8c22fff:~/pick$ git log --pretty=oneline
196b82313ca6d577c5c680d2732eaad2cba0f616 (HEAD -> dev) add foo in bar
5c5d79eb96535fa83b35b3ae51b629ed77b546d2 (master) add foo

# 切换到master分支
mei@4144e8c22fff:~/pick$ git checkout master
Switched to branch 'master'

# 使用cherry-pick将dev分支提交合并到master分支
mei@4144e8c22fff:~/pick$ git cherry-pick dev
[master 6acedc9] add foo in bar
 Date: Sun Jan 9 20:31:28 2022 +0800
 1 file changed, 1 insertion(+)
 
# 查看master分支的提交信息，可以看到6acedc9f54dafeb9fed79333cf81427464b7c358这个提交已经引入到master分支
mei@4144e8c22fff:~/pick$ git log --pretty=oneline
6acedc9f54dafeb9fed79333cf81427464b7c358 (HEAD -> master) add foo in bar
5c5d79eb96535fa83b35b3ae51b629ed77b546d2 add foo
mei@4144e8c22fff:~/pick$
```



### 10.4 使用git revert撤销修改

- `git revert`提交命令跟`git cherry-pick`提交命令大致是相同的，但有一个重要区别：它应用给定提交的逆过程。因此，此命令用于引入一个新提交来抵消给定提交的影响。

```sh
# 在上一节的基础上，执行`git revert dev`撤销dev提交的影响
mei@4144e8c22fff:~/pick$ git revert dev
[master 2b73916] Revert "add foo in bar"
 1 file changed, 1 deletion(-)
 
# 查看日志，可以看到引入了一次新的提交2b73916a83e13a0e29b50f1257933771f3782fd7
mei@4144e8c22fff:~/pick$ git log
commit 2b73916a83e13a0e29b50f1257933771f3782fd7 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sun Jan 9 22:06:32 2022 +0800

    Revert "add foo in bar"

    This reverts commit 196b82313ca6d577c5c680d2732eaad2cba0f616.

commit 6acedc9f54dafeb9fed79333cf81427464b7c358
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sun Jan 9 20:31:28 2022 +0800

    add foo in bar

commit 5c5d79eb96535fa83b35b3ae51b629ed77b546d2
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Sun Jan 9 20:30:26 2022 +0800

    add foo
mei@4144e8c22fff:~/pick$ gs
On branch master
nothing to commit, working tree clean
mei@4144e8c22fff:~/pick$ ls
bar.txt

# bar.txt已经还原到最初的状态
mei@4144e8c22fff:~/pick$ cat bar.txt
foo
mei@4144e8c22fff:~/pick$
```





### 10.5 reset、revert与checkout

- 如果你想切换到不同的分支，使用`git checkout`，当前分支和HEAD引用会变为匹配给定分支的头。
- `git reset`不会改变分支，会改变当前工作目录的状态，`git reset`会重置当前分支的HEAD引用。
- `git revert`命令作用于全部提交，而不是文件。
- 如果你的版本库已经公开发布，就不应用修改提交历史记录。此时可以使用`git revert`相"撤销"某次修改。



### 10.6 修改最新提交git commit --amend

- 改变当前分支最近一次提交的最简单的方法之一是使用`git commit --amend`。
- 通常情况下，`amend`意味着提交内容基本相同，但某些方面需要调整或清理。
- `git commit --amend`最频繁的用途是在刚做出一个提交后修改录入错误。

看以下示例：

```sh
mei@4144e8c22fff:~/git$ echo 'test amend' >> http.h
mei@4144e8c22fff:~/git$ git add .

# 提交，填完日志信息
mei@4144e8c22fff:~/git$ git commit -m"test commit"
[master 4dbf579cfc] test commit
 1 file changed, 1 insertion(+)
 
# 查看刚才提交的日志信息
mei@4144e8c22fff:~/git$ git log --pretty=oneline -n 1
4dbf579cfcc66d9071614cb9c55c0abbdb923169 (HEAD -> master) test commit

# 尝试修改日志信息，运行`git commit --amend`会打开编辑器，重新编辑后，保存日志信息
mei@4144e8c22fff:~/git$ git commit --amend
[master 819e27d405] test commit amend
 Date: Sun Jan 9 22:30:15 2022 +0800
 1 file changed, 1 insertion(+)
 
# 再次查看日志信息，可以看到日志信息已经发生变更
mei@4144e8c22fff:~/git$ git log --pretty=oneline -n 1
819e27d4059c921d3d74fae1b3c0238f3fbf70bc (HEAD -> master) test commit amend
mei@4144e8c22fff:~/git$
```



对文件进行修改：

```sh
mei@4144e8c22fff:~/git$ tail -n 1 http.h
test amend

# 尝试对文件进行修复
mei@4144e8c22fff:~/git$ echo "test use amend" >> http.h
mei@4144e8c22fff:~/git$ tail -n 2 http.h
test amend
test use amend

# 追加文件
mei@4144e8c22fff:~/git$ git add http.h

# 使用git commit --amend 追加文件修改和日志信息
mei@4144e8c22fff:~/git$ git commit --amend
[master 1371b151a5] test use commit amend to change file and log info
 Date: Sun Jan 9 22:30:15 2022 +0800
 1 file changed, 2 insertions(+)
 
# 再次查看最后的提交
mei@4144e8c22fff:~/git$ git log --pretty=oneline -n 1
1371b151a5898e18a26e4535b9ed5bd35796a011 (HEAD -> master) test use commit amend to change file and log info
mei@4144e8c22fff:~/git$

# 查看最后的两次提交，可以看到除了1371b151a5898e18a26e4535b9ed5bd35796a011这个提交外，我们没有引入新的提交
mei@4144e8c22fff:~/git$ git log --pretty=oneline -n 2
1371b151a5898e18a26e4535b9ed5bd35796a011 (HEAD -> master) test use commit amend to change file and log info
670b81a890388c60b7032a4f5b879f2ece8c4558 (origin/master, origin/HEAD, test1, dev) The second batch
```





### 10.7 变基提交git rebase

- `git rebase`命令是用来改变一串提交以什么为基础的。

我们来模拟书上面的变基操作。

```sh
A <-- B <-- C <-- D <-- E    master 分支
      \<-- W  <-- X  <-- Y <-- Z  topic 分支 
```

master分支和topic分支都在开发中。最初topic分支是从master分支的提交B处开始的。在此期间master分支已经进展到了提交E。

我们创建一个`rebase`的存储库，模拟这个操作。

```sh
# 创建存储库目录
mei@4144e8c22fff:~$ mkdir rebase

# 切换到存储库
mei@4144e8c22fff:~$ cd rebase/

# 初始化存储库
mei@4144e8c22fff:~/rebase$ git init
Initialized empty Git repository in /home/mei/rebase/.git/

# 创建提交A
mei@4144e8c22fff:~/rebase$ echo 'a' > A && git add A && git commit -m"Add A"
[master (root-commit) fd70500] Add A
 1 file changed, 1 insertion(+)
 create mode 100644 A
 
# 查看提交A的日志信息
mei@4144e8c22fff:~/rebase$ git log -n 1
commit fd705000b6bfb7c7060df2adb3268be7e3c77b33 (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jan 10 20:38:05 2022 +0800

    Add A
    
# 创建提交B
mei@4144e8c22fff:~/rebase$ echo 'b' > B && git add B && git commit -m"Add B"
[master 36904cd] Add B
 1 file changed, 1 insertion(+)
 create mode 100644 B
 
# 查看提交日志信息
mei@4144e8c22fff:~/rebase$ git log -n 2
commit 36904cd4d7b4c7ab75aba7b372fb0ade885e089c (HEAD -> master)
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jan 10 20:38:26 2022 +0800

    Add B

commit fd705000b6bfb7c7060df2adb3268be7e3c77b33
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Mon Jan 10 20:38:05 2022 +0800

    Add A
    
# 此时，创建分支topic
mei@4144e8c22fff:~/rebase$ git checkout -b topic
Switched to a new branch 'topic'

# 可以看到，现在有两个分支了
mei@4144e8c22fff:~/rebase$ git branch
  master
* topic

# 在topic分支上创建提交W
mei@4144e8c22fff:~/rebase$ echo 'w' > W && git add W && git commit -m"Add W"
[topic 9cdde64] Add W
 1 file changed, 1 insertion(+)
 create mode 100644 W
 
# 查看提交日志信息
mei@4144e8c22fff:~/rebase$ git log --pretty=oneline -n 3
9cdde64114925f1887aeaf42b5debb9a76e94283 (HEAD -> topic) Add W
36904cd4d7b4c7ab75aba7b372fb0ade885e089c (master) Add B
fd705000b6bfb7c7060df2adb3268be7e3c77b33 Add A

# 此时切换到master分支，创建一下C/D/E提交
mei@4144e8c22fff:~/rebase$ git branch
* master
  topic
mei@4144e8c22fff:~/rebase$ git log --pretty=oneline -n 3
36904cd4d7b4c7ab75aba7b372fb0ade885e089c (HEAD -> master) Add B
fd705000b6bfb7c7060df2adb3268be7e3c77b33 Add A
mei@4144e8c22fff:~/rebase$ echo 'c' > C && git add C && git commit -m"Add C"
[master 9f08e45] Add C
 1 file changed, 1 insertion(+)
 create mode 100644 C
mei@4144e8c22fff:~/rebase$ echo 'd' > D && git add D && git commit -m"Add D"
[master 907cf80] Add D
 1 file changed, 1 insertion(+)
 create mode 100644 D
mei@4144e8c22fff:~/rebase$ echo 'e' > E && git add E && git commit -m"Add E"
[master 631842e] Add E
 1 file changed, 1 insertion(+)
 create mode 100644 E
mei@4144e8c22fff:~/rebase$ git log --pretty=oneline -n 5
631842e0953b80805f2201230f5fd8cbdc5609f2 (HEAD -> master) Add E
907cf80fbc1b42c104987774510709f7b7c244f8 Add D
9f08e450f4ee748bfff9ecfbe0864532de7404fd Add C
36904cd4d7b4c7ab75aba7b372fb0ade885e089c Add B
fd705000b6bfb7c7060df2adb3268be7e3c77b33 Add A

# 切换到topic分支
mei@4144e8c22fff:~/rebase$ git checkout topic
Switched to branch 'topic'

# 查看日志信息
mei@4144e8c22fff:~/rebase$ git log --pretty=oneline -n 5
9cdde64114925f1887aeaf42b5debb9a76e94283 (HEAD -> topic) Add W
36904cd4d7b4c7ab75aba7b372fb0ade885e089c Add B
fd705000b6bfb7c7060df2adb3268be7e3c77b33 Add A

# 在topic分支上创建X/Y/Z提交
mei@4144e8c22fff:~/rebase$ echo 'x' > X && git add X && git commit -m"Add X"
[topic 8dfcf31] Add X
 1 file changed, 1 insertion(+)
 create mode 100644 X
mei@4144e8c22fff:~/rebase$ echo 'y' > Y && git add Y && git commit -m"Add Y"
[topic 3d0770b] Add Y
 1 file changed, 1 insertion(+)
 create mode 100644 Y
mei@4144e8c22fff:~/rebase$ echo 'z' > Z && git add Z && git commit -m"Add Z"
[topic 0872d60] Add Z
 1 file changed, 1 insertion(+)
 create mode 100644 Z
 
# 在topic分支上面查看日志信息
mei@4144e8c22fff:~/rebase$ git log --pretty=oneline -n 6
0872d60010af2ea43361e97c55450ec35330ceff (HEAD -> topic) Add Z
3d0770b0d8fac5f30eed43d55cfe911ab46de91e Add Y
8dfcf3132e09bf6ed119e093bbf9c118d5bba77b Add X
9cdde64114925f1887aeaf42b5debb9a76e94283 Add W
36904cd4d7b4c7ab75aba7b372fb0ade885e089c Add B
fd705000b6bfb7c7060df2adb3268be7e3c77b33 Add A

# 查看分支信息
mei@4144e8c22fff:~/rebase$ git show-branch
! [master] Add E
 * [topic] Add Z
--
 * [topic] Add Z
 * [topic^] Add Y
 * [topic~2] Add X
 * [topic~3] Add W
+  [master] Add E
+  [master^] Add D
+  [master~2] Add C
+* [topic~4] Add B

# rebase前，查看日志信息
mei@4144e8c22fff:~/rebase$ git log --graph --pretty=oneline --abbrev-commit
* 0872d60 (HEAD -> topic) Add Z
* 3d0770b Add Y
* 8dfcf31 Add X
* 9cdde64 Add W
* 36904cd Add B
* fd70500 Add A

# 进行变基提交，将master后面的提交应用到topic分支上
mei@4144e8c22fff:~/rebase$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: Add W
Applying: Add X
Applying: Add Y
Applying: Add Z

# rebase后，再次查看日志信息
mei@4144e8c22fff:~/rebase$ git log --graph --pretty=oneline --abbrev-commit
* ccd953d (HEAD -> topic) Add Z
* c3a4594 Add Y
* 01cb615 Add X
* dbf846b Add W
* 631842e (master) Add E
* 907cf80 Add D
* 9f08e45 Add C
* 36904cd Add B
* fd70500 Add A
mei@4144e8c22fff:~/rebase$

# 查看当前分支是topic分支
mei@4144e8c22fff:~/rebase$ git branch
  master
* topic

# 切换到master分支
mei@4144e8c22fff:~/rebase$ git checkout master
Switched to branch 'master'

# 查看master分支的提交信息，可以看到master分支的提交还是A/B/C/D/E，没有发生变化
mei@4144e8c22fff:~/rebase$ git log --graph --pretty=oneline --abbrev-commit
* 631842e (HEAD -> master) Add E
* 907cf80 Add D
* 9f08e45 Add C
* 36904cd Add B
* fd70500 Add A
mei@4144e8c22fff:~/rebase$
```

对比rebase前后的日志显示：


可以看到，master分支的提交C/D/E被移到W的前面，W/X/Y/Z被重新提交，原来的W/X/Y/Z的提交已经不存在，对应的commit id也没有。

此时，新的提交图如下：

```sh
A <-- B <-- C <-- D <-- E    master 分支
                        \<-- W'  <-- X'  <-- Y' <-- Z'  topic 分支 
```

rebase是一个非常强大的操作，可以实现一些神奇的功能，但是强大也意味着有隐患，因为如果使用得不好可能给团队的代码造成非常大的问题，成为团队当中被无情指责的背锅侠。所以我们在使用之前一定要先了解清楚原理，之后再小心谨慎地使用，否则很有可能会产生问题。

要记住的最重要的概念是：

- 变基把提交重写成新提交。
- 不可达的旧提交会消失。
- 任何旧的、变基前的提交的用户可能被困住。



## 第11章 储藏和引用日志

### 11.1 储藏stash

在日常开发周期中，当要经常中断、修复bug、处理来自同事或领导的紧急需求，导致你必须停止你正在进行的工作时，你这个时候就可以使用储藏(stash)功能。

- 储藏可以捕获你的工作进度，允许你保存工作进度并且当你方便时再回到该进度。你可以通过Git提供的分支及提交机制来实现该功能。但储藏是一种快捷方式。它让你仅通过一条简单的命令就全面彻底地捕获工作目录和索引。

查看`git stash`的帮助信息：

```sh
mei@4144e8c22fff:~/stash$ git stash --help|awk NF|head -n 24
GIT-STASH(1)                                                                     Git Manual                                                                     GIT-STASH(1)
NAME
       git-stash - Stash the changes in a dirty working directory away
SYNOPSIS
       git stash list [<options>]
       git stash show [<options>] [<stash>]
       git stash drop [-q|--quiet] [<stash>]
       git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>]
       git stash branch <branchname> [<stash>]
       git stash [push [-p|--patch] [-k|--[no-]keep-index] [-q|--quiet]
                    [-u|--include-untracked] [-a|--all] [-m|--message <message>]
                    [--] [<pathspec>...]]
       git stash clear
       git stash create [<message>]
       git stash store [-m|--message <message>] [-q|--quiet] <commit>
DESCRIPTION
       Use git stash when you want to record the current state of the working directory and the index, but want to go back to a clean working directory. The command saves
       your local modifications away and reverts the working directory to match the HEAD commit.
       The modifications stashed away by this command can be listed with git stash list, inspected with git stash show, and restored (potentially on top of a different
       commit) with git stash apply. Calling git stash without any arguments is equivalent to git stash push. A stash is by default listed as "WIP on branchname ...", but
       you can give a more descriptive message on the command line when you create one.
       The latest stash you created is stored in refs/stash; older stashes are found in the reflog of this reference and can be named using the usual reflog syntax (e.g.
       stash@{0} is the most recently created stash, stash@{1} is the one before it, stash@{2.hours.ago} is also possible). Stashes may also be referenced by specifying
       just the stash index (e.g. the integer n is equivalent to stash@{n}).
mei@4144e8c22fff:~/stash$
```



为了便于测试，我们增加一些快捷命令，`acf`用于快速创建文件，并进行提交, `gone`用于查看单行日志信息：

```sh
alias acf='add_commit_file'
function add_commit_file() {
    file="$1"
    echo "${file}" > "${file}" && git add "${file}" && git commit -m"Add ${file}"
}
# shorthand: git log --oneline
alias gone='git log --pretty=oneline  --abbrev-commit'
```

尝试创建一些文件并提交：

```sh
# 创建测试目录
mei@4144e8c22fff:~$ mkdir stash

# 切换目录
mei@4144e8c22fff:~$ cd stash/

# 初始化存储库
mei@4144e8c22fff:~/stash$ git init
Initialized empty Git repository in /home/mei/stash/.git/

# 创建并提交文件A
mei@4144e8c22fff:~/stash$ acf A
[master (root-commit) 29dbfc6] Add A
 1 file changed, 1 insertion(+)
 create mode 100644 A
 
# 创建并提交文件B
mei@4144e8c22fff:~/stash$ acf B
[master 5e7d6de] Add B
 1 file changed, 1 insertion(+)
 create mode 100644 B
 
# 查看日志信息
mei@4144e8c22fff:~/stash$ gone
5e7d6de (HEAD -> master) Add B
29dbfc6 Add A
```

假设我们现在尝试使用`git stash save`储藏我们现在的修改。

```sh
# 查看当前存储库状态
mei@4144e8c22fff:~/stash$ gs
On branch master
nothing to commit, working tree clean

# 此时使用git stash save，可以看到，由于本地没有任何修改，没有存储任何修改
mei@4144e8c22fff:~/stash$ git stash save
No local changes to save
mei@4144e8c22fff:~/stash$
```

在我们本地没有做任何修改时，`git stash save`没有储藏任何修改。

因此，我们需要做一些修改。

```sh
mei@4144e8c22fff:~/stash$ echo 'C' > C
mei@4144e8c22fff:~/stash$ gs
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	C

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/stash$ acf 'D'
[master 98bb58b] Add D
 1 file changed, 1 insertion(+)
 create mode 100644 D
mei@4144e8c22fff:~/stash$ gs
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	C

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/stash$ gone
98bb58b (HEAD -> master) Add D
5e7d6de Add B
29dbfc6 Add A
mei@4144e8c22fff:~/stash$ git stash save "WIP: Doing real work about C"
No local changes to save
```

我们尝试添加了C文件，但没有进行提交，同时，添加了D文件，并进行了提交。此时使用`git stash save`储藏文件，仍然显示`No local changes to save`，说明我们的储藏没有起作用。



我们再添加一个E文件，并将C文件追加到暂存区：

```sh
mei@4144e8c22fff:~/stash$ echo 'E' > E
mei@4144e8c22fff:~/stash$ gs
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	C
	E

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/stash$ git add C
mei@4144e8c22fff:~/stash$ gs
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   C

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E
```

此时再使用`git stash`命令：

```sh
mei@4144e8c22fff:~/stash$ git stash save "WIP: Doing real work about C"
Saved working directory and index state On master: WIP: Doing real work about C
mei@4144e8c22fff:~/stash$ gs
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/stash$
```

可以看到，追加到暂存区的C文件的修改被`stash`处理了，但E文件没有被处理。



说明我们对C文件的修改已经被储藏了。

```sh
# 列出储藏的实体列表
mei@4144e8c22fff:~/stash$ git stash list
stash@{0}: On master: WIP: Doing real work about C

# 显示储藏实体的变更记录
mei@4144e8c22fff:~/stash$ git stash show
 C | 1 +
 1 file changed, 1 insertion(+)
```



现在我们可以做别的事情了，比如重新生成一个C文件，并且让C文件的内容是CC：

```sh
# 显示当前的文件列表，可以看到C文件已经不在当前文件列表中
mei@4144e8c22fff:~/stash$ ls
A  B  D  E

# 现在我们重新创建一个文件C
mei@4144e8c22fff:~/stash$ echo 'CC' > C

# 追加并提交
mei@4144e8c22fff:~/stash$ git add C
mei@4144e8c22fff:~/stash$ git commit -m"add C with content CC"
[master 8271041] add C with content CC
 1 file changed, 1 insertion(+)
 create mode 100644 C
 
# 查看存储库状态
mei@4144e8c22fff:~/stash$ gs
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

nothing added to commit but untracked files present (use "git add" to track)

# 查看此时C文件的内容
mei@4144e8c22fff:~/stash$ cat C
CC

# 此时我们想恢复我们的储藏的数据，发现存在冲突，恢复失败
mei@4144e8c22fff:~/stash$ git stash pop
CONFLICT (add/add): Merge conflict in C
Auto-merging C
The stash entry is kept in case you need it again.

# 储藏列表中仍然存在一个实体
mei@4144e8c22fff:~/stash$ git stash list
stash@{0}: On master: WIP: Doing real work about C

# 查看文件C的内容，要以看到有上游的CC，以及储藏的C
mei@4144e8c22fff:~/stash$ cat C
<<<<<<< Updated upstream
CC
=======
C
>>>>>>> Stashed changes
mei@4144e8c22fff:~/stash$
```

此时，需要解决冲突。

此时，我们可以手动将上游的数据删除掉，仅保存储藏的数据，使用VIM编辑C文件，编辑完成后，查看C文件：

```sh
mei@4144e8c22fff:~/stash$ cat C
C
mei@4144e8c22fff:~/stash$ gs
On branch master
Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
	both added:      C

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/stash$ git stash list
stash@{0}: On master: WIP: Doing real work about C
```

此时，我们的储藏栈的还存在一个实体，应将其删除，此时可以使用`git stash drop`删除它：

```sh
mei@4144e8c22fff:~/stash$ git stash drop
Dropped refs/stash@{0} (30e4a98630cd9a879949b88ce6d1ff236338c9bd)
mei@4144e8c22fff:~/stash$ git stash list
mei@4144e8c22fff:~/stash$ gs
On branch master
Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
	both added:      C

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

no changes added to commit (use "git add" and/or "git commit -a")
mei@4144e8c22fff:~/stash$
```

似乎我们删除错了，因为现在的状态因为看到`both added`，我们尝试恢复删除的储藏实体。

```sh
# 重新应用stash一下
mei@4144e8c22fff:~/stash$ git stash apply 30e4a98630cd9a879949b88ce6d1ff236338c9bd
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   C

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

mei@4144e8c22fff:~/stash$ echo $?
0
# 储藏栈已经清空了
mei@4144e8c22fff:~/stash$ git stash list

# 再次查看状态，C文件已经恢复到原来的状态了
mei@4144e8c22fff:~/stash$ gs
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   C

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	E

# C文件已经恢复到原来状态
mei@4144e8c22fff:~/stash$ cat C
C
mei@4144e8c22fff:~/stash$
```



总结：

- `git stash push -m"stash message"`将变更存储到储藏栈中，用于代替`git stash save`。
- `git stash list`显示储藏栈中实体列表。
- `git stash show`显示给定储藏条目相对于它的父提交的索引和文件变更记录。
- `git stash drop`删除储藏栈状态。
- `git stash apply`应用储藏栈状态。
- `git stash pop`应用储藏栈状态并删除储藏栈状态，等价于`apply`后再执行`drop`。



### 11.2 引用日志

- 引用日志(reflog)记录非祼版本库中分支头的改变。
- 每次对引用的更新，包括对`HEAD`的，引用日志都会更新以记录这些引用发生了哪些变化。
- 把引用日志当和面包屑轨迹一样指示你和你的引用去过哪里。
- 你可以通过引用日志来跟随你的足迹并回溯你的分支操作。
- 从根本上讲，任何修改引用或更改分支头的Git操作都会记录。

我们先来看一下这个命令的帮助信息：

```sh
mei@4144e8c22fff:~$ git reflog --help|awk NF
GIT-REFLOG(1)                                                                    Git Manual                                                                    GIT-REFLOG(1)
NAME
       git-reflog - Manage reflog information
SYNOPSIS
       git reflog <subcommand> <options>
DESCRIPTION
       The command takes various subcommands, and different options depending on the subcommand:
           git reflog [show] [log-options] [<ref>]
           git reflog expire [--expire=<time>] [--expire-unreachable=<time>]
                   [--rewrite] [--updateref] [--stale-fix]
                   [--dry-run | -n] [--verbose] [--all [--single-worktree] | <refs>...]
           git reflog delete [--rewrite] [--updateref]
                   [--dry-run | -n] [--verbose] ref@{specifier}...
           git reflog exists <ref>
       Reference logs, or "reflogs", record when the tips of branches and other references were updated in the local repository. Reflogs are useful in various Git commands,
       to specify the old value of a reference. For example, HEAD@{2} means "where HEAD used to be two moves ago", master@{one.week.ago} means "where master used to point
       to one week ago in this local repository", and so on. See gitrevisions(7) for more details.
       This command manages the information recorded in the reflogs.
       The "show" subcommand (which is also the default, in the absence of any subcommands) shows the log of the reference provided in the command-line (or HEAD, by
       default). The reflog covers all recent actions, and in addition the HEAD reflog records branch switching. git reflog show is an alias for git log -g --abbrev-commit
       --pretty=oneline; see git-log(1) for more information.
       The "expire" subcommand prunes older reflog entries. Entries older than expire time, or entries older than expire-unreachable time and not reachable from the current
       tip, are removed from the reflog. This is typically not used directly by end users -- instead, see git-gc(1).
       The "delete" subcommand deletes single entries from the reflog. Its argument must be an exact entry (e.g. "git reflog delete master@{2}"). This subcommand is also
       typically not used directly by end users.
       The "exists" subcommand checks whether a ref has a reflog. It exits with zero status if the reflog exists, and non-zero status if it does not.
OPTIONS
   Options for show
       git reflog show accepts any of the options accepted by git log.
   Options for expire
       --all
           Process the reflogs of all references.
       --single-worktree
           By default when --all is specified, reflogs from all working trees are processed. This option limits the processing to reflogs from the current working tree
           only.
       --expire=<time>
           Prune entries older than the specified time. If this option is not specified, the expiration time is taken from the configuration setting gc.reflogExpire, which
           in turn defaults to 90 days.  --expire=all prunes entries regardless of their age; --expire=never turns off pruning of reachable entries (but see
           --expire-unreachable).
       --expire-unreachable=<time>
           Prune entries older than <time> that are not reachable from the current tip of the branch. If this option is not specified, the expiration time is taken from the
           configuration setting gc.reflogExpireUnreachable, which in turn defaults to 30 days.  --expire-unreachable=all prunes unreachable entries regardless of their
           age; --expire-unreachable=never turns off early pruning of unreachable entries (but see --expire).
       --updateref
           Update the reference to the value of the top reflog entry (i.e. <ref>@{0}) if the previous top entry was pruned. (This option is ignored for symbolic
           references.)
       --rewrite
           If a reflog entry's predecessor is pruned, adjust its "old" SHA-1 to be equal to the "new" SHA-1 field of the entry that now precedes it.
       --stale-fix
           Prune any reflog entries that point to "broken commits". A broken commit is a commit that is not reachable from any of the reference tips and that refers,
           directly or indirectly, to a missing commit, tree, or blob object.
           This computation involves traversing all the reachable objects, i.e. it has the same cost as git prune. It is primarily intended to fix corruption caused by
           garbage collecting using older versions of Git, which didn't protect objects referred to by reflogs.
       -n, --dry-run
           Do not actually prune any entries; just show what would have been pruned.
       --verbose
           Print extra information on screen.
   Options for delete
       git reflog delete accepts options --updateref, --rewrite, -n, --dry-run, and --verbose, with the same meanings as when they are used with expire.
GIT
       Part of the git(1) suite
Git 2.25.1                                                                       03/04/2021                                                                    GIT-REFLOG(1)
mei@4144e8c22fff:~$
```

通过帮助文档，通常我们只用使用`git reflog show`或`git reflog`这个命令就可以。



现在我们进行一些简单的测试。

```sh
# 创建测试目录
mei@4144e8c22fff:~$ mkdir reflog

# 切换到测试目录下
mei@4144e8c22fff:~$ cd reflog/

# 初始化存储库
mei@4144e8c22fff:~/reflog$ git init
Initialized empty Git repository in /home/mei/reflog/.git/

# 创建并提交文件A
# 快捷命令请参考11.1节
mei@4144e8c22fff:~/reflog$ acf A
[master (root-commit) 5ef601f] Add A
 1 file changed, 1 insertion(+)
 create mode 100644 A
 
# 创建并提交文件B
mei@4144e8c22fff:~/reflog$ acf B
[master bad84bf] Add B
 1 file changed, 1 insertion(+)
 create mode 100644 B
 
# 此时使用git reflog查看引用日志记录
# 可以看到，每次提交都会记录一条引用日志记录，此时已经有两条记录了
mei@4144e8c22fff:~/reflog$ git reflog
bad84bf (HEAD -> master) HEAD@{0}: commit: Add B
5ef601f HEAD@{1}: commit (initial): Add A

# 切换一下当前分支到dev分支
mei@4144e8c22fff:~/reflog$ git checkout -b dev
Switched to a new branch 'dev'

# 创建并提交文件C
mei@4144e8c22fff:~/reflog$ acf C
[dev 39abfab] Add C
 1 file changed, 1 insertion(+)
 create mode 100644 C
 
# 此时使用git reflog查看引用日志记录
# 可以看到，切换分支和提交文件会记录一条引用日志记录，此时已经有4条记录了
mei@4144e8c22fff:~/reflog$ git reflog
39abfab (HEAD -> dev) HEAD@{0}: commit: Add C
bad84bf (master) HEAD@{1}: checkout: moving from master to dev
bad84bf (master) HEAD@{2}: commit: Add B
5ef601f HEAD@{3}: commit (initial): Add A

# 切换一下当前分支到master分支
mei@4144e8c22fff:~/reflog$ git checkout master
Switched to branch 'master'

# 查看当前分支
mei@4144e8c22fff:~/reflog$ git branch
  dev
* master

# 创建并提交文件D
mei@4144e8c22fff:~/reflog$ acf D
[master 75e59b2] Add D
 1 file changed, 1 insertion(+)
 create mode 100644 D

# 此时使用git reflog查看引用日志记录
# 可以看到，切换分支和提交文件会记录一条引用日志记录，此时已经有6条记录了
mei@4144e8c22fff:~/reflog$ git reflog show
75e59b2 (HEAD -> master) HEAD@{0}: commit: Add D
bad84bf HEAD@{1}: checkout: moving from dev to master
39abfab (dev) HEAD@{2}: commit: Add C
bad84bf HEAD@{3}: checkout: moving from master to dev
bad84bf HEAD@{4}: commit: Add B
5ef601f HEAD@{5}: commit (initial): Add A

# git reflog show 是git reflog的默认选项
mei@4144e8c22fff:~/reflog$ git reflog
75e59b2 (HEAD -> master) HEAD@{0}: commit: Add D
bad84bf HEAD@{1}: checkout: moving from dev to master
39abfab (dev) HEAD@{2}: commit: Add C
bad84bf HEAD@{3}: checkout: moving from master to dev
bad84bf HEAD@{4}: commit: Add B
5ef601f HEAD@{5}: commit (initial): Add A

# 仅查看某个分支(dev)的引用日志信息
mei@4144e8c22fff:~/reflog$ git reflog dev
39abfab (dev) dev@{0}: commit: Add C
bad84bf dev@{1}: branch: Created from HEAD

# 仅查看某个分支(master)的引用日志信息
mei@4144e8c22fff:~/reflog$ git reflog master
75e59b2 (HEAD -> master) master@{0}: commit: Add D
bad84bf master@{1}: commit: Add B
5ef601f master@{2}: commit (initial): Add A
mei@4144e8c22fff:~/reflog$
```

可以看到，单独查看分支master和dev的引用日志信息的总数与直接使用`git reflog`的总数不一样！

我们再来创建一个分支`feature`分支：

```sh
# 创建分支
mei@4144e8c22fff:~/reflog$ git branch feature

# 查看分支信息
mei@4144e8c22fff:~/reflog$ git branch
  dev
  feature
* master

# 查看引用日志信息，可以看到，仅创建分支时，不会新增引用日志记录
mei@4144e8c22fff:~/reflog$ git reflog
75e59b2 (HEAD -> master, feature) HEAD@{0}: commit: Add D
bad84bf HEAD@{1}: checkout: moving from dev to master
39abfab (dev) HEAD@{2}: commit: Add C
bad84bf HEAD@{3}: checkout: moving from master to dev
bad84bf HEAD@{4}: commit: Add B
5ef601f HEAD@{5}: commit (initial): Add A
mei@4144e8c22fff:~/reflog$
```

可以看到，仅创建分支时，不会新增引用日志记录。



引用日志记录每条记录信息，是引用日志记录中记录的单次事务，从最近的变更开始倒序显示：

- 最左侧的一列，是发生变更时的提交ID。
- 第二列中形如`HEAD@{1}`的条目为每个事务的提交提供方便的别名。
- 每一行的冒号后面是对发生事务的描述。



我们通过别名，使用一些Git命令，如：

```sh
mei@4144e8c22fff:~/reflog$ git show HEAD@{3}
commit bad84bfcea7bc1b106ec057a6768cc68f3424a74
Author: Zhaohui Mei <mzh@hellogitlab.com>
Date:   Tue Jan 11 21:22:35 2022 +0800

    Add B

diff --git a/B b/B
new file mode 100644
index 0000000..223b783
--- /dev/null
+++ b/B
@@ -0,0 +1 @@
+B
mei@4144e8c22fff:~/reflog$
```



如果Git为版本库中每个引用的每次操作都维护一个事务历史记录，那么引用日志最终不就会变得非常巨大吗？



幸运的是，这并不会发生。Git会时不时地自动执行垃圾回收进程。在这个过程中，一些老旧的引用日志条目会过期并被丢弃。

通常情况下，一个提交，如果既不能从某个分支或引用指向，也不可达，将会默认在30天后过期，而那些可达的提交将默认在90天后过期。

如果这样的安排不理想，那么可以通过设置版本库中的配置变量`gc.reflogExpireUnreachable`和`gc.reflgExpire`的值来满足需求。

可以使用`git reflog delete`命令来删除单个条目，或使用`git reflog expire`命令直接让条目过期并被立即删除。它也可以用来强制使引用日志过期。



我们尝试一下清理引用日志：

```sh
# 在测试前，先备份一下reflog目录
mei@4144e8c22fff:~/reflog$ cd ..
mei@4144e8c22fff:~$ cp -rf reflog{,.bak}
mei@4144e8c22fff:~$ cd reflog

# 查看引用日志，可以发现有6条记录
mei@4144e8c22fff:~/reflog$ git reflog
75e59b2 (HEAD -> master, feature) HEAD@{0}: commit: Add D
bad84bf HEAD@{1}: checkout: moving from dev to master
39abfab (dev) HEAD@{2}: commit: Add C
bad84bf HEAD@{3}: checkout: moving from master to dev
bad84bf HEAD@{4}: commit: Add B
5ef601f HEAD@{5}: commit (initial): Add A

# 设置引用日志的过期时间为现在，并处理所有条目，也就是删除所有的引用日志记录信息
mei@4144e8c22fff:~/reflog$ git reflog expire --expire=now --all

# 此时再次查看引用日志信息，可以看到已经没有记录了
mei@4144e8c22fff:~/reflog$ git reflog
mei@4144e8c22fff:~/reflog$
```



我们查看一下清理后的文件夹与清理前的文件夹对比情况：

```sh
mei@4144e8c22fff:~/reflog$ cd ..
mei@4144e8c22fff:~$ diff -r reflog reflog.bak
diff -r reflog/.git/logs/HEAD reflog.bak/.git/logs/HEAD
0a1,6
> 0000000000000000000000000000000000000000 5ef601f87cbd1d74097ceee9e32d4c274a694d6f Zhaohui Mei <mzh@hellogitlab.com> 1641907352 +0800	commit (initial): Add A
> 5ef601f87cbd1d74097ceee9e32d4c274a694d6f bad84bfcea7bc1b106ec057a6768cc68f3424a74 Zhaohui Mei <mzh@hellogitlab.com> 1641907355 +0800	commit: Add B
> bad84bfcea7bc1b106ec057a6768cc68f3424a74 bad84bfcea7bc1b106ec057a6768cc68f3424a74 Zhaohui Mei <mzh@hellogitlab.com> 1641907369 +0800	checkout: moving from master to dev
> bad84bfcea7bc1b106ec057a6768cc68f3424a74 39abfab9d8798548226cda03bd87841a9e40b3dd Zhaohui Mei <mzh@hellogitlab.com> 1641907381 +0800	commit: Add C
> 39abfab9d8798548226cda03bd87841a9e40b3dd bad84bfcea7bc1b106ec057a6768cc68f3424a74 Zhaohui Mei <mzh@hellogitlab.com> 1641907399 +0800	checkout: moving from dev to master
> bad84bfcea7bc1b106ec057a6768cc68f3424a74 75e59b25c80c1479fd47cea279fe378366ca7fff Zhaohui Mei <mzh@hellogitlab.com> 1641907409 +0800	commit: Add D
diff -r reflog/.git/logs/refs/heads/dev reflog.bak/.git/logs/refs/heads/dev
0a1,2
> 0000000000000000000000000000000000000000 bad84bfcea7bc1b106ec057a6768cc68f3424a74 Zhaohui Mei <mzh@hellogitlab.com> 1641907369 +0800	branch: Created from HEAD
> bad84bfcea7bc1b106ec057a6768cc68f3424a74 39abfab9d8798548226cda03bd87841a9e40b3dd Zhaohui Mei <mzh@hellogitlab.com> 1641907381 +0800	commit: Add C
diff -r reflog/.git/logs/refs/heads/feature reflog.bak/.git/logs/refs/heads/feature
0a1
> 0000000000000000000000000000000000000000 75e59b25c80c1479fd47cea279fe378366ca7fff Zhaohui Mei <mzh@hellogitlab.com> 1641913892 +0800	branch: Created from master
diff -r reflog/.git/logs/refs/heads/master reflog.bak/.git/logs/refs/heads/master
0a1,3
> 0000000000000000000000000000000000000000 5ef601f87cbd1d74097ceee9e32d4c274a694d6f Zhaohui Mei <mzh@hellogitlab.com> 1641907352 +0800	commit (initial): Add A
> 5ef601f87cbd1d74097ceee9e32d4c274a694d6f bad84bfcea7bc1b106ec057a6768cc68f3424a74 Zhaohui Mei <mzh@hellogitlab.com> 1641907355 +0800	commit: Add B
> bad84bfcea7bc1b106ec057a6768cc68f3424a74 75e59b25c80c1479fd47cea279fe378366ca7fff Zhaohui Mei <mzh@hellogitlab.com> 1641907409 +0800	commit: Add D
mei@4144e8c22fff:~$
```


可以看到:

- 引用日志都存储在`.git/logs`目录下。
- `.git/logs/HEAD`文件包含`HEAD`值的历史记录。
- 子目录`.git/logs/refs/`包含所有引用的历史记录。
- 二级子目录`.git/logs/refs/heads`包含分支头的历史记录。



此时，我们查看一下`core.logallrefupdates`配置的信息，然后再尝试切换一下分支：

```sh
mei@4144e8c22fff:~$ cd reflog

# 查看引用日志的配置选项core.logallrefupdates，可以发现其值为true,即表示开启引用日志记录
mei@4144e8c22fff:~/reflog$ git config core.logallrefupdates
true

# 查看当前分支，当前分支是master分支
mei@4144e8c22fff:~/reflog$ git branch
  dev
  feature
* master

# 切换一下分支
mei@4144e8c22fff:~/reflog$ git checkout dev
Switched to branch 'dev'

# 查看分支情况，已经切换到dev分支
mei@4144e8c22fff:~/reflog$ git branch
* dev
  feature
  master

# 查看引用日志记录
mei@4144e8c22fff:~/reflog$ git reflog
39abfab (HEAD -> dev) HEAD@{0}: checkout: moving from master to dev
```

设置`core.logallrefupdates`的值为`false`。

```sh
# 设置关闭引用日志记录
mei@4144e8c22fff:~/reflog$ git config core.logallrefupdates false

# 查看配置值，可以看到已经变成false了
mei@4144e8c22fff:~/reflog$ git config core.logallrefupdates
false

# 此时，查看引用日志记录，看到记录仍然存在
mei@4144e8c22fff:~/reflog$ git reflog
39abfab (HEAD -> dev) HEAD@{0}: checkout: moving from master to dev

# 切换分支
mei@4144e8c22fff:~/reflog$ git checkout feature
Switched to branch 'feature'

# 查看分支情况
mei@4144e8c22fff:~/reflog$ git branch
  dev
* feature
  master
  
# 查看引用日志记录情况，发现还在记录引用日志信息，说明我们的配置没有生效
mei@4144e8c22fff:~/reflog$ git reflog
75e59b2 (HEAD -> feature, master) HEAD@{0}: checkout: moving from dev to feature
39abfab (dev) HEAD@{1}: checkout: moving from master to dev
mei@4144e8c22fff:~/reflog$
```

上面的测试尝试，我们知道`git config core.logallrefupdates false`没有生效！！



## 第12章 远程版本库

- 一个克隆是版本库的副本。
- 一个克隆包含所有原始对象；每个克隆都是独立、自治的版本库，与原始版本库是真正对称、地位相同的。
- 一个克隆允许每个开发人员可以在本地独立地工作，不需要中心版本库，投票或者锁。
- 归根到底，克隆使Git易于扩展，并允许地理上分离的很多贡献者一起协作。
- 克隆版本库只是共享代码的第一步。
- 远程版本库`remote`是一个引用或句柄，通过文件系统或网络指向另一个版本库。
- 可以使用远程版本库作为简称，代替又长又复杂的Git URL。
- 可以在版本库中定义任意数量的远程版本库，从而创建共享版本库的阶梯网络。
- 一旦远程版本库建立，Git新可以使用推push或拉pull模式在版本库之间传输数据。例如，习惯做法是偶尔从原始版本库转移提交数据到克隆版本库，以保持克隆版本库处于同步状态。还可以创建一个远程版本库来从克隆版本库传输数据到原始版本库，或设置两个版本库进行双向信息交换。
- 要跟踪其他版本库的数据，Git使用远程追踪分支(remote-tracking branch)。版本库中的每个远程追踪分支都作为远程版本库中特定分支的一个代理。要集成本地修改与远程追踪分支对应的远程修改，可以建立一个本地追踪分支(local-tracking branch)来建立集成的基础。
- 你可以将你的版本库提供给他人，Git一般称作发布版本库(publishing a repository)。

本章将展示在多个版本库之间共享、跟踪和获取数据的多个示例与技术。



### 12.1 版本库概念

#### 12.1.1 祼版本库和开发版本库

- 一个Git版本库要么是一个祼(bare)版本库，要么是一个开发(非祼)(development, nonbare)版本库。
- 开发版本库用于常规的日常开发。它保持当前分支的概念，并在工作目录中提供检出当前分支的副本。使用`git init`创建。
- 相反，一个祼版本库没有工作目录，并且不应该用于正常开发。祼版本库没有检出分支的概念。使用`git init --bare`创建。
- 祼版本库可以简单地看做`.git`目录的内容。不应该在祼版本库中进行提交操作。
- 祼版本库看起来似乎没有多大用处，但它的角色是关键的：作为协作开发的权威焦点。其他开发人员从祼版本库中克隆(clone)和抓取(fetch)，并推送(push)更新。

我们来看一下祼版本库与非祼版本库的区别。

```sh
mei@4144e8c22fff:~$ mkdir nonbare
mei@4144e8c22fff:~$ mkdir bare

# 创建非祼版本库
mei@4144e8c22fff:~$ git init nonbare
Initialized empty Git repository in /home/mei/nonbare/.git/

# 创建祼版本库
mei@4144e8c22fff:~$ git init --bare bare
Initialized empty Git repository in /home/mei/bare/

# 查看两个目录的差异
mei@4144e8c22fff:~$ diff bare nonbare
Only in nonbare: .git
Only in bare: HEAD
Only in bare: branches
Only in bare: config
Only in bare: description
Only in bare: hooks
Only in bare: info
Only in bare: objects
Only in bare: refs

# 查看非祼版本库的文件列表
mei@4144e8c22fff:~$ find nonbare/
nonbare/
nonbare/.git
nonbare/.git/branches
nonbare/.git/config
nonbare/.git/hooks
nonbare/.git/hooks/pre-rebase.sample
nonbare/.git/hooks/pre-commit.sample
nonbare/.git/hooks/pre-push.sample
nonbare/.git/hooks/fsmonitor-watchman.sample
nonbare/.git/hooks/pre-applypatch.sample
nonbare/.git/hooks/post-update.sample
nonbare/.git/hooks/commit-msg.sample
nonbare/.git/hooks/pre-merge-commit.sample
nonbare/.git/hooks/update.sample
nonbare/.git/hooks/applypatch-msg.sample
nonbare/.git/hooks/pre-receive.sample
nonbare/.git/hooks/prepare-commit-msg.sample
nonbare/.git/HEAD
nonbare/.git/description
nonbare/.git/refs
nonbare/.git/refs/heads
nonbare/.git/refs/tags
nonbare/.git/info
nonbare/.git/info/exclude
nonbare/.git/objects
nonbare/.git/objects/pack
nonbare/.git/objects/info

# 查看祼版本库的文件列表
mei@4144e8c22fff:~$ find bare/
bare/
bare/branches
bare/config
bare/hooks
bare/hooks/pre-rebase.sample
bare/hooks/pre-commit.sample
bare/hooks/pre-push.sample
bare/hooks/fsmonitor-watchman.sample
bare/hooks/pre-applypatch.sample
bare/hooks/post-update.sample
bare/hooks/commit-msg.sample
bare/hooks/pre-merge-commit.sample
bare/hooks/update.sample
bare/hooks/applypatch-msg.sample
bare/hooks/pre-receive.sample
bare/hooks/prepare-commit-msg.sample
bare/HEAD
bare/description
bare/refs
bare/refs/heads
bare/refs/tags
bare/info
bare/info/exclude
bare/objects
bare/objects/pack
bare/objects/info
mei@4144e8c22fff:~$

# 查看开发库中.git目录与祼版本库的差异
# 可以看到配置文件存在差异，但子目录情况完全一样！
mei@4144e8c22fff:~$ diff nonbare/.git/ bare/
Common subdirectories: nonbare/.git/branches and bare/branches
diff nonbare/.git/config bare/config
4,5c4
< 	bare = false
< 	logallrefupdates = true
---
> 	bare = true
Common subdirectories: nonbare/.git/hooks and bare/hooks
Common subdirectories: nonbare/.git/info and bare/info
Common subdirectories: nonbare/.git/objects and bare/objects
Common subdirectories: nonbare/.git/refs and bare/refs
```

可以看到，非祼版本库多了一层`.git`目录，祼版本库中没有`.git`目录。

- 默认情况下，Git在开发版本库中可以使用引用日志(reflog)，可以看到`logallrefupdates = true`配置，但在祼版本库中不行。
- 祼版本库中不能创建远程版本库。
- 如果你要创建一个版本库供开发人员推送修改，那么它应该是祼版本库。





#### 12.1.2 版本库克隆

- `git clone`命令会创建一个新的Git版本库，基于你通过文件系统或网络地址指定的原始版本库。
- Git并不需要复制原始版本库的所有信息，相反，Git会忽略只跟原始版本库相关的信息，如远程追踪分支。
- 在正常使用`git clone`命令时，原始版本库中存储在`refs/heads/`下的本地开发分支，会成为新的克隆版本库中`refs/remotes/`下的远程追踪分支。原始版本库中`refs/remotes/`下的远程追踪分支不会克隆。
- 跟从复制的引用可达的所有对象一样，原始版本库中的标签被复制到克隆版本库中。然后，版本库特定的信息，如原始版本库中的钩子(hooks)、配置文件、引用日志(reflog)和储藏(stash)都不在克隆中重现。

为了便于测试，我们创建两个目录`remotes`和`locals`，然后将上面的两个目录`nonbare`和`bare`存储库移动到`remotes`目录下。

```sh
# 创建远程和本地文件夹目录
mei@4144e8c22fff:~$ mkdir remotes locals

# 将祼存储库bare移动到remotes目录下
mei@4144e8c22fff:~$ mv bare/ remotes/

# 将非祼存储库nonbare移动到remotes目录下
mei@4144e8c22fff:~$ mv nonbare/ remotes/
```

我们在`bare`和`nonbare`存储库分别做一些修改。

```sh
# 切换到远程测试目录
mei@4144e8c22fff:~$ cd remotes/

# 切换到祼存储库
mei@4144e8c22fff:~/remotes$ cd bare/

# 尝试在祼存储库中添加和提交文件，提示致命错误，该操作必须在工作树中进行，说明在祼存储库不能进行该操作
mei@4144e8c22fff:~/remotes/bare$ acf A
fatal: this operation must be run in a work tree

# 切换到非祼存储库nonbare下
mei@4144e8c22fff:~/remotes/bare$ cd ..
mei@4144e8c22fff:~/remotes$ cd nonbare/

# 创建并提交文件A
mei@4144e8c22fff:~/remotes/nonbare$ acf A
[master (root-commit) 4be9a60] Add A
 1 file changed, 1 insertion(+)
 create mode 100644 A
 
# 创建并提交文件B
mei@4144e8c22fff:~/remotes/nonbare$ acf B
[master 7ecb4a0] Add B
 1 file changed, 1 insertion(+)
 create mode 100644 B
 
# 查看单行日志记录
mei@4144e8c22fff:~/remotes/nonbare$ gone
7ecb4a0 (HEAD -> master) Add B
4be9a60 Add A

# 创建并切换到dev分支
mei@4144e8c22fff:~/remotes/nonbare$ git checkout -b dev
Switched to a new branch 'dev'

# 查看引用日志信息
mei@4144e8c22fff:~/remotes/nonbare$ git reflog
7ecb4a0 (HEAD -> dev, master) HEAD@{0}: checkout: moving from master to dev
7ecb4a0 (HEAD -> dev, master) HEAD@{1}: commit: Add B
4be9a60 HEAD@{2}: commit (initial): Add A
```

现在我们在`locals`本地目录中尝试克隆远程目录下的存储库。

```sh
mei@4144e8c22fff:~/locals$ git clone ~/remotes/nonbare/
Cloning into 'nonbare'...
done.
mei@4144e8c22fff:~/locals$ git clone ~/remotes/bare/
Cloning into 'bare'...
warning: You appear to have cloned an empty repository.
done.
mei@4144e8c22fff:~/locals$ ls -lah
total 16K
drwxrwxr-x 4 mei mei 4.0K Jan 13 22:47 .
drwxr-xr-x 6 mei mei 4.0K Jan 13 22:09 ..
drwxrwxr-x 3 mei mei 4.0K Jan 13 22:47 bare
drwxrwxr-x 3 mei mei 4.0K Jan 13 22:47 nonbare
```

可以看到，祼存储库和非祼存储库都能正常克隆下来。

查看配置信息：

```sh
mei@4144e8c22fff:~/locals$ cd bare/
mei@4144e8c22fff:~/locals/bare$ git config --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
alias.simple=log --graph --abbrev-commit --pretty=oneline
core.editor=vim
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=/home/mei/remotes/bare/
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
mei@4144e8c22fff:~/locals/bare$ cd ../nonbare/
mei@4144e8c22fff:~/locals/nonbare$ git config --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
alias.simple=log --graph --abbrev-commit --pretty=oneline
core.editor=vim
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=/home/mei/remotes/nonbare/
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
mei@4144e8c22fff:~/locals/nonbare$
```


可以看到，只有远程url不一样，其他配置是一样的。

### 12.2  引用其他版本库

- Git支持多种形式的统一资源定位符(Uniform Resource Locator, URL)，URL可以用来命名远程版本库。
- 当你有一个数据必须通过网络获取的真正远程版本库时，数据传输的最有效形式通常称为Git原生协议(Git native protocol),它指的是Git内部用来传输数据的自定义协议。如`git://example.com/path/to/repo.git`。
- 对于经过身份验证的安全连接，Git原生协议可以通过Secure Shell（SSH）连接使用URL模板进行隧道封装。如`ssh://[user@]example.com[:port]/path/to/repo.git`。
- 另外，Git还支持HTTP和HTTPS形式的URL,如`https://github.com/torvalds/linux.git`。

### 12.3 使用远程版本库的示例

- `git pull`操作有两个根本步骤，每个步骤都由独立的Git命令实现。
- `git pull`意味着先执行`git fetch`，然后执行`git merge`或`git rebase`。默认情况下，第二个步骤是`merge`，因为这始终是大多数情况下期望的行为。
- 因为拉取`pull`操作还进行`merge`或`rebase`步骤，所以`git push`和`git pull`不被视为相对的。
- `git push`和`git fetch`被认为是相对的，推送push和抓取fetch都负责在版本库之间传输数据，但方向相反。
- 你也可以单独执行`git fetch`和`git merge`操作。

### 12.4 图解远程版本库开发周期

省略。

### 12.5 远程版本库配置

- 手动追踪远程版本库的所有信息是十分烦琐且困难的，你需要记住版本库的完成URL;每次想抓取更新时，你必须在命令行上一次又一次地输入远程版本库引用和refspec；你必须重构分支映射，等等。重复输入信息也是很容易出错的。

- Git为建立和维护远程版本库信息提供三种机制，所有这三种机制的最终结果都体现在`.git/config`配置文件记录的配置信息上：

    - `git remote`命令。
    - `git config`命令。
    - 直接编辑`.git/config`配置文件。

    

查看`git remote`的帮助信息：

```sh
$ git remote --help|head -n 23|awk NF
GIT-REMOTE(1)                                                                                   Git Manual                                                                                   GIT-REMOTE(1)
NAME
       git-remote - Manage set of tracked repositories
SYNOPSIS
       git remote [-v | --verbose]
       git remote add [-t <branch>] [-m <master>] [-f] [--[no-]tags] [--mirror=<fetch|push>] <name> <url>
       git remote rename <old> <new>
       git remote remove <name>
       git remote set-head <name> (-a | --auto | -d | --delete | <branch>)
       git remote set-branches [--add] <name> <branch>...
       git remote get-url [--push] [--all] <name>
       git remote set-url [--push] <name> <newurl> [<oldurl>]
       git remote set-url --add [--push] <name> <newurl>
       git remote set-url --delete [--push] <name> <url>
       git remote [-v | --verbose] show [-n] <name>...
       git remote prune [-n | --dry-run] <name>...
       git remote [-v | --verbose] update [-p | --prune] [(<group> | <remote>)...]
DESCRIPTION
       Manage the set of repositories ("remotes") whose branches you track.
```

像我这个`vueblog`仓库，为了方便设置备份，并加快国内访问，我配置了多个远程URL。如：

```sh
[mzh@MacBookPro docs (master)]$ git remote -v
gitee	git@gitee.com:meizhaohui/vueblog.git (fetch)
gitee	git@gitee.com:meizhaohui/vueblog.git (push)
gogs	ssh://git@gogs.hellogitlab.com:10022/meizhaohui/vueblog.git (fetch)
gogs	ssh://git@gogs.hellogitlab.com:10022/meizhaohui/vueblog.git (push)
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)
```

`origin`的是默认的，`gitee`和`gogs`是后来添加的。

- 运行 `git remote add <shortname> <url>` 添加一个新的远程 Git 仓库，同时指定一个方便使用的简写

需要使用以下命令：

```sh
$ git remote add gitee git@gitee.com:meizhaohui/vueblog.git
$ git remote add gogs ssh://git@gogs.hellogitlab.com:10022/meizhaohui/vueblog.git
```



- 使用`git remote rm <name>`可以从本地版本库中删除给定的远程版本库及其关联的远程追踪分支。
- 远程版本库中可能已经有分支被其他开发员删除了，`git remote prune`命令可以用来删除你的本地版本库中那些陈旧的(相对于实际的远程版本库)远程追踪分支。
- 可以使用`git remote rename <old> <new>`来重命名一个远程版本库及其所有引用。
- 也可以使用`git remote set-url shortname new-url`的方式来设置新的URL地址。



通常我们也可以使用`git config`来设置我们关心的配置，直接使用`git config --list`则会显示出当前版本库的配置情况：

```sh
mei@4144e8c22fff:~/locals/bare$ git config --list
user.email=mzh@hellogitlab.com
user.name=Zhaohui Mei
alias.simple=log --graph --abbrev-commit --pretty=oneline
core.editor=vim
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=/home/mei/remotes/bare/
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
```



你也可以使用你喜欢的文本编辑器直接编辑`.git/config`配置文件，在某些情况下，这样做会更简单。但有时，也可能容易出错。因此，通常只有在开发人员非常熟悉Git的特性和配置文件时才这么做。



### 12.6 使用追踪分支

- 你的`master`分支可以被认为是`origin/master`分支引进的开发的扩展。
- 在克隆操作或把远程版本库添加到版本库中时会引入远程追踪分支。
- 可以使用`git remote show origin`显示远程`origin`版本库信息。

```sh
[mzh@MacBookPro docs (master ✗)]$ git remote -v
gitee	git@gitee.com:meizhaohui/vueblog.git (fetch)
gitee	git@gitee.com:meizhaohui/vueblog.git (push)
gogs	ssh://git@gogs.hellogitlab.com:10022/meizhaohui/vueblog.git (fetch)
gogs	ssh://git@gogs.hellogitlab.com:10022/meizhaohui/vueblog.git (push)
origin	git@github.com:meizhaohui/vueblog.git (fetch)
origin	git@github.com:meizhaohui/vueblog.git (push)

# 查看origin远程版本库和分支信息
[mzh@MacBookPro docs (master ✗)]$ git remote show origin
* remote origin
  Fetch URL: git@github.com:meizhaohui/vueblog.git
  Push  URL: git@github.com:meizhaohui/vueblog.git
  HEAD branch: master
  Remote branch:
    master tracked
  Local branch configured for 'git pull':
    master merges with remote master
  Local ref configured for 'git push':
    master pushes to master (up to date)

# 查看gitee远程版本库和分支信息
[mzh@MacBookPro docs (master ✗)]$ git remote show gitee
* remote gitee
  Fetch URL: git@gitee.com:meizhaohui/vueblog.git
  Push  URL: git@gitee.com:meizhaohui/vueblog.git
  HEAD branch: master
  Remote branch:
    master tracked
  Local ref configured for 'git push':
    master pushes to master (up to date)
```

- 随着本地和远程追踪分支对的创建，可以对两个分支之间进行相对比较。除了正常的`diff`/`log`及其他基于内容的比较外，Git提供了每个分支提交数目的快速摘要和判断一个分支比另一个分支 **领先 **还是 **落后** 的方法。
- 如果你的本地开发在本地追踪分支上引入新提交，就认为它领先相应的远程追踪分支。相反，如果你在远程追踪分支上获取新提交，并且它们不存在于你的本地追踪分支中，Git就会认为你的本地追踪分支落后于相应的远程追踪分支。

### 12.7 添加和删除远程分支 

- 在本地克隆分支上创建的任何新开发，在父版本版中都是不可见的，除非你直接请求把它传过去。
- 同样，在你的版本库中删除一个分支仍然是一个本地变化，它不会从父版本版中删除，除非你请求从远程版本库中删除它。



推送分支到远程仓库：

```sh
# 克隆远程仓库到本地
$ git clone git@gitee.com:meizhaohui/testgit.git
Cloning into 'testgit'...
remote: Enumerating objects: 8, done.
remote: Total 8 (delta 0), reused 0 (delta 0), pack-reused 8
Receiving objects: 100% (8/8), done.
Resolving deltas: 100% (1/1), done.

# 切换到本地版本库中
$ cd testgit

# 查看远程分支，可以看到没有foo分支
$ git branch -r|awk NF
  origin/HEAD -> origin/master
  origin/master
 
# 查看本地分支
$ git branch |awk NF
* master

# 创建并切换到foo分支
$ git checkout -b foo
Switched to a new branch 'foo'

# 查看本地分支，可以看到多了foo分支
$ git branch |awk NF
* foo
  master
  
# 查看远程分支，并没有多foo分支
$ git branch -r|awk NF
  origin/HEAD -> origin/master
  origin/master

# 将foo分支推送到远程版本库
$ git push origin foo
Total 0 (delta 0), reused 0 (delta 0)
remote: Powered by GITEE.COM [GNK-6.2]
remote: Create a pull request for 'foo' on Gitee by visiting:
remote:     https://gitee.com/meizhaohui/testgit/pull/new/meizhaohui:foo...meizhaohui:master
To gitee.com:meizhaohui/testgit.git
 * [new branch]      foo -> foo

# 查看版本分支，可以看到已经多了origin/foo分支
$ git branch -r|awk NF
  origin/HEAD -> origin/master
  origin/foo
  origin/master
$
```

可以看到，远程仓库中已经多了foo分支。说明使用`git push origin foo`命令可以将`foo`分支推送到远程仓库。



将远程仓库分支删除：

```sh
# 将远程仓库中的foo分支删除掉
$ git push origin :foo
remote: Powered by GITEE.COM [GNK-6.2]
To gitee.com:meizhaohui/testgit.git
 - [deleted]         foo
 
# 查看远程仓库分支，可以看到已经没有foo分支了
$ git branch -r|awk NF
  origin/HEAD -> origin/master
  origin/master
$
```



我们也可以使用下面的方式删除远程分支：

```sh
# 再次创建一个远程分支foo
$ git push origin foo
Total 0 (delta 0), reused 0 (delta 0)
remote: Powered by GITEE.COM [GNK-6.2]
remote: Create a pull request for 'foo' on Gitee by visiting:
remote:     https://gitee.com/meizhaohui/testgit/pull/new/meizhaohui:foo...meizhaohui:master
To gitee.com:meizhaohui/testgit.git
 * [new branch]      foo -> foo
 
# 将远程分支foo从存储库中删除，与上面的git push origin :foo命令等价
$ git push origin --delete foo
remote: Powered by GITEE.COM [GNK-6.2]
To gitee.com:meizhaohui/testgit.git
 - [deleted]         foo
$
```



### 12.8 祼版本库和git推送

- 作为git版本库的点对点语义的结果，所有版本库的地位是平等的。
- 我们鼓励你只推送到祼版本库。这不是一个硬性且快速的规定，但它对普通开发人员是个很好的指南，被认为是最佳实践。



## 第13章 版本库管理



### 13.1 谈谈服务器

- 从技术角度讲，Git是不需要服务器的，而对于其他的VCS来说，一个集中式服务器往往是必不可少的。而Git则不需要一定要有一个这样的服务器来架设Git版本库。

### 13.2 发布版本库

- 无论你要建立开源的开发环境，还是创建私有小组的内部开发项目，其协作机制在本质上都是相同的。这两种情况之间的主要区别就是版本库的位置和访问方式。
- Git并没有尝试去管理访问权限，而是把这个问题留给了其他工具。如，SSH可能更适合这个任务。
- 在任何情况下，当你要发布一个版本库时，都强烈建议发布祼版本库。

#### 13.2.1  带访问控制的版本库

#### 13.2.2  允许匿名读取访问的版本库

- 使用git daemon发布版本库。
- 使用http守护进程发布版本库。

#### 13.2.3  允许匿名写入权限的版本库



特别说明，13.2 发布版本库相对复杂，会单独编写相关文档，此处不详细展开。



#### 13.2.4 在GitHb上发面版本库

主要包含以下几个步骤：

- 创建GitHub的版本库；
- 为新的版本库命名；
- 选择访问控制级别；
- 初始化版本库；
- 添加远程版本库；
- 推送内容；
- 查看网站。

### 13.3  有关发布版本库的建议

- 对于自己比较重视其价值的东西，千万要记得自己备份！！！

### 13.4 版本库结构

- Git在检出时，得到的不仅仅是你想要的那个特定的版本，而是整个历史记录。因此，可以从本地版本库中重建一个文件的任何版本。
- 共享的集中的版本库模式在Git中纯粹是一种社会约定和协议。

### 13.5 分布式开发指南

- 一旦你已经发布了一个版本库，别人就可以进行克隆，那你应该把它视为静态的并避免其被修改。
- 通过将提交和发布分离，开发人员可以进行更加精确、专注、小型且有逻辑的步骤的提交。任何微小的变化都可以在不影响其他版本库或开发人员的情况下进行。从某种意义上讲，提交操作是离线进行的，因为它不需要访问网络来记录进度，只需要在你自己的版本库中推进步骤。
- Git并不关心哪个提交先进行，提交之间唯一真正可靠的关系，就是提交对象中直接记录的父子关系。
- 只有懦夫才使用磁盘备份，真的勇士敢于将他们最重要的东西上传到FTP，让世界上其他人来做镜像。-- Linus Torvalds

### 13.6 清楚你的位置

- 我们习惯性称父版本库为新克隆的版本库的上游upstream，称新克隆的版本库为原始父版本库的下游downstream。
- 上游和下游的概念与克隆操作是没有直接关系的。
- 凡是你发送变更的版本库一般都被认为是你的上游，那些依赖于你作为它们的基础的版本库被认为是你的下游。
- 在开发中，两个常见的角色是维护者maintainer和开发人员developer，维护者主要承担集成工作或管理工作，而开发人员主要负责生成变更。
- 一旦某个分支已经发布，维护者就不应该再更改它。

### 13.7 多版本库协作

- 每次克隆版本库时，这个行为就可视为复刻(fork)该项目。
- 复刻这个术语源自一个想法：当创建一个复刻时，其实创建了两条同步的开发道路，它就像开发道路上的一个分叉口。
- 当一个开源项目的开发人员不满意主开发的效果是，拷贝一份源代码，开始维护他自己的版本，传统意义上，这就叫做复刻。
- 在这样的意义上，复刻照惯例被视为一种负面的事。大部分开源项目都做出了巨大的努力，以避免复刻的发生。
- 只有当复刻最终不再合并回一起时，复刻才是一个问题。
- 返回给核心项目的复刻称为合并请求pull request。合并请求便复刻能够直观可视，使多分支的智能管理更加方便。



## 第14章 补丁

- Git实现了自己的传输协议用于版本库间的交换数据。出于效率考虑，Git传输协议会进行一个小的握手，来确定源版本库中的哪些提交不在目的版本库中，最终传输提交的二进制压缩形式。接收的版本库会将新的提交合并到它的本地历史记录中，同时添加到提交图中，并按需更新分支和标签。
- Git也可以使用HTTP在版本库之间交换数据，虽然HTTP协议不如Git原生协议高效，但是它也具有来回传输提交的能力。
- 要交换提交并保持分布式版本库同步，Git原生协议和HTTP协议并不是唯一的机制。Git还支持“补丁和应用”操作，通常通过email来进行数据交换。
- `git format-patch`会生成email形式的补丁。
- `git send-email`会通过简单邮件传输协议SMTP来发送一个Git补丁。
- `git am`会应用邮件消息中的补丁。



在测试过程中，配置了`sendemail`相关的配置，仍然发送不了邮件通知，提示类似如下异常：

```sh
mei@4144e8c22fff:~/test/testgit$ git send-email -to mzh@hellogitlab.com 0001-add-a.txt.patch 0002-add-b.txt.patch --smtp-debug
0001-add-a.txt.patch
0002-add-b.txt.patch
(mbox) Adding cc: Zhaohui Mei <mzh@hellogitlab.com> from line 'From: Zhaohui Mei <mzh@hellogitlab.com>'
Unable to initialize SMTP properly. Check config and use --smtp-debug. VALUES: server=smtp.qq.com encryption=tls hello=localhost.localdomain port=465 at /usr/lib/git-core/git-send-email line 1558.
```

测试失败。



## 第15章 钩子

钩子是一个有趣的话题，此处不详细展开，请参考 [git 钩子脚本的使用](./git_hooks.md)。



## 第16章 合并项目

- 有很多原因会让你想要将一些别的项目合并入自己的项目中。
- 子模块(submodule)不但构成了你自己的Git版本库中的一部分，而且它独立地存在于它自己的源代码版本库中。
- 如果你的项目子模块一旦导入，就永远与旧项目脱离了关系，则你不需要使用本章中讲的submodule。
- 如果许多应用程序都依赖于某个共同的工具库或者某组库，并且希望每个应用都可以在它自己的Git版本库中开发、共享、分支和合并，达到逻辑模块分离。

### 16.1 旧解决方案：部分检出

在许多版本控制系统中，一种流行的功能叫部分检出，使用部分检出的好处之一是，不必下载巨大的、完整的文件历史记录。



- 在使用Git时，下载的不仅仅是一组选中文件的当前版本，而是所有文件的所有版本。每个Git版本库都是版本库一个完整的副本。



### 16.2 显而易见的解决方案：将代码导入项目

将需要的库导入你的版本库的子目录。如果你需要更新库，就可以直接将一组新的文件复制过来。

这种方案的优缺点：

优点：

- 永远不会出现库版本意外错误的情况。
- 易于解释和理解。
- 外部导入的工具库是否使用Git或VCS都没有关系。
- 你的应用程序版本库自成一体。
- 即使你没有库所在版本库的提交权限，你也可以很方便地将面向你自己的应用程序的补丁应用到自己的版本库中。
- 为应用程序创建分支时也会为库创建一个分支。

缺点：

- 每一个导入相同库的应用程序都会重复复制该库的文件。
- 如果你的应用程序更改了工具库的副本，那么共享这些变更的唯一的方法就是通过产生差异并将其应用到主库的版本库中。



### 16.3 自动化解决方案：使用自定义脚本检出子项目

每次当你克隆主项目时，就手动把子项目克隆到新克隆出来的项目的子目录中。

这种方式的优势：

- 子模块不一定要在Git中。
- 主项目的历史记录永远不会跟子项目的历史记录混淆。
- 如果你在子项目中做了更改，你可以直接将它们贡献回原项目。

同时这种方式也有需要处理的问题：

- 向其他用户解释如何检出所有子项目是非常繁琐的。
- 需要以某种方式来确定得到的子项目的版本都是正确的。
- 当切换分支时或拉取别人的更改时，子项目不会自动更新。
- 如果你对子项目做了修改，那么必须单独对它进行提交推送操作。
- 如果你没有权限贡献回子项目，那么你将不能轻松地做出特定于应用程序的更改。

即，手动克隆具体极大的灵活性，但同时也容易出现过分复杂化，或者出现错误。你可以做一个自动化的脚本来做这些事情。



### 16.4 原生解决方案：gitlink和git submodule

- git submodule命令比简单地将子项目的历史记录导入主项目的版本库更复杂。
- 它和基于脚本的解决方案基本一致，但有更多的限制。‘

#### 16.4.1 gitlink

- gitlink是从一个树对象（tree object）到一个提交对象（commit object）的链接。
- 每个提交对象都指向一个树对象，而每一个树对象都指向一组blob对象和树对象，分别对应文件和子目录。
- 每个提交的树对象都唯一标识了该提交中一组确切的文件、文件名和访问权限。
- gitlink是Git用来直接指向另一个Git库所使用的机制。

我们按书的的示例改造测试一下，如编写本博客系统，在`docs`目录下存在多个不同的子模块，如在`CM`文件来下还有`git`模块。

我们来模块在`myapp`中增加一个`git`模块的gitlink。

步骤1：在github上面创建测试仓库`myapp`:




步骤2：在github上面创建子模块仓库`git`:




步骤3：克隆`myapp`到本地：

```sh
$ cd /tmp
$ git clone git@github.com:meizhaohui/myapp.git
Cloning into 'myapp'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
$
```



步骤4：创建`docs/CM/`目录：

```sh
$ cd myapp
$ mkdir -p docs/CM
```



步骤5： 克隆子模块：

```sh
$ cd docs/CM
$ git clone git@github.com:meizhaohui/git.git
Cloning into 'git'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
$ ls ./git
README.md
$
```



步骤6：创建gitlink:

```sh
$ git add git
warning: adding embedded git repository: docs/CM/git
hint: You've added another git repository inside your current repository.
hint: Clones of the outer repository will not contain the contents of
hint: the embedded repository and will not know how to obtain it.
hint: If you meant to add a submodule, use:
hint:
hint: 	git submodule add <url> docs/CM/git
hint:
hint: If you added this path by mistake, you can remove it from the
hint: index with:
hint:
hint: 	git rm --cached docs/CM/git
hint:
hint: See "git help submodule" for more information.
```

此时抛出了警告信息。我们先不管。

因为已经有一个名为`git/.git`的目录，所以执行`git add git`命令时就会创建一个gitlink指向它。

::: warning 警告

通常情况下，`git add git`和`git add git/`是相同的，但是，如果你想创建gitlink，那么两者是不同的！在刚才展示的过程中，添加了斜杠的`git add git/`将不会创建一个`gitlink`，它只把`git`目录下的所有文件都添加进来，而这种结果不是我们想要的。

:::

查看一下状态信息：

```sh
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   git

$
```

看到一个新的文件`git`待提交。



步骤7： 创建提交信息：

```sh
$ git commit -m"import blog submodule git"
[main 7001c3a] import blog submodule git
 1 file changed, 1 insertion(+)
 create mode 160000 docs/CM/git
$
```

使用`git ls-tree`来显示树对象的内容:

```sh
$ git ls-tree HEAD
160000 commit 7f8392b9f80a3c16b366e6845ba19aa3a0389808	git
$
```

可以看到`git`子目录是`commit`类型，模式码为`16000`，这说明它是一个gitlink。

中间的散列值`7f8392b9f80a3c16b366e6845ba19aa3a0389808`刚好是`git`创建初始化提交对象的ID。



查看子项目对象的信息：

```sh
$ cd git
$ git --no-pager log -n 1
commit 7f8392b9f80a3c16b366e6845ba19aa3a0389808 (HEAD -> main, origin/main, origin/HEAD)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sat Mar 26 20:49:13 2022 +0800

    Initial commit
$ git remote -v
origin	git@github.com:meizhaohui/git.git (fetch)
origin	git@github.com:meizhaohui/git.git (push)
$
```

可以看到，子项目的散列值和`git ls-tree`里面显示的是一样的。



步骤8：推送修改到远程仓库：

```sh
#  GitHub 官方表示，从2020年10月1日起，在该平台上创建的所有新的源代码仓库将默认被命名为 "main"，而不是原先的"master"。值得注意的是，现有的存储库不会受到此更改影响。
# 推送到远程main分支中
$ git push origin main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 355 bytes | 355.00 KiB/s, done.
Total 4 (delta 0), reused 0 (delta 0)
To github.com:meizhaohui/myapp.git
   60dbdac..7001c3a  main -> main
```

提交成功后，可以在github上面看到刚才提交的记录：




因然，此时，我们已经提交了我们的gitlink引用，但是，我们尝试将我们的`myapp`仓库检出到别的目录，查看一下是否自动检出`git`子目录下的内容。

```sh
$ cd /tmp
$ git clone git@github.com:meizhaohui/myapp.git myapp1
Cloning into 'myapp1'...
remote: Enumerating objects: 7, done.
remote: Counting objects: 100% (7/7), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 7 (delta 0), reused 4 (delta 0), pack-reused 0
Receiving objects: 100% (7/7), done.
$ cd myapp1
$ ll
total 8
drwxr-xr-x   5 mzh   wheel   160B  3 26 21:41 .
drwxrwxrwt  10 root  wheel   320B  3 26 21:41 ..
drwxr-xr-x  12 mzh   wheel   384B  3 26 21:41 .git
-rw-r--r--   1 mzh   wheel    39B  3 26 21:41 README.md
drwxr-xr-x   3 mzh   wheel    96B  3 26 21:41 docs
$ cd docs/CM/git
$ ls -lah
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 21:41 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 21:41 ..
```

可以看到，子项目库没有被检出，是空的！！

- 假如你将你包含gitlink子项目的项目推送到另一个版本库，Git不会将子项目的提交、树和blob对象一同推送。如果你克隆你的主版本库，其中的子项目库也会是空的。

如何找到这些缺失的子项目呢，这正是`git submodule`命令做的工作。



#### 16.4.2 `git submodule`命令

现在我们进入到上一切目录，并检出子模块：

```sh
# 切换到上级目录
$ cd ..

# 查看当前目录
$ pwd
/tmp/myapp1/docs/CM

# 查看当前索引中的内容
$ git ls-files --stage -- git
160000 7f8392b9f80a3c16b366e6845ba19aa3a0389808 0	git

# 检出git子仓库
$ git clone git@github.com:meizhaohui/git.git
Cloning into 'git'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.

# 切换到对应的提交
$ git checkout 7f8392b
Note: switching to '7f8392b'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at 7f8392b Initial commit

# 查看子项目中的文件
$ ll
total 8
drwxr-xr-x   4 mzh  wheel   128B  3 26 21:51 .
drwxr-xr-x   3 mzh  wheel    96B  3 26 21:41 ..
drwxr-xr-x  12 mzh  wheel   384B  3 26 21:51 .git
-rw-r--r--   1 mzh  wheel    22B  3 26 21:51 README.md
```

可以看到，子项目文件已经检出。



上面的一系列操作(切换目录、检出，切换提交等等)就等同于`git submodule update`命令，只不过`git submodule update`做得更多，如为你决定检出正确的提交ID。如果没有一点提示，`git submodule update`不知道如何处理。



我们来测试一下，重新检出`myapp`到`myapp2`目录。

```sh
$ cd /tmp
$ git clone git@github.com:meizhaohui/myapp.git myapp2
Cloning into 'myapp2'...
remote: Enumerating objects: 7, done.
remote: Counting objects: 100% (7/7), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 7 (delta 0), reused 4 (delta 0), pack-reused 0
Receiving objects: 100% (7/7), done.
$
```

切换到`myapp2`目录，然后执行`git submodule update`命令：

```sh
$ cd myapp2
$ git submodule update
$ ls -lah docs/CM/git
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 22:02 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 22:02 ..
$ cd docs/CM/git
$ git submodule update
$ ls -lah
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 22:02 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 22:02 ..
$ cd ..
$ pwd
/tmp/myapp2/docs/CM
$ git submodule update
$ ls -lah git
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 22:02 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 22:02 ..
$
```

可以看到，执行`git submodule update`没有起作用，没有克隆子项目到本地来。



如果此时执行`git submodule add`命令：

```sh
$ git submodule add git@github.com:meizhaohui/git.git git
'docs/CM/git' already exists in the index
```

提示`docs/CM/git`已经在索引中存在了，不让创建。我们将命令行里面最后的`git`换成`git-docs`测试一下：

```sh
$ git submodule add git@github.com:meizhaohui/git.git git-docs
Cloning into '/private/tmp/myapp2/docs/CM/git-docs'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
$ ll
total 0
drwxr-xr-x  4 mzh  wheel   128B  3 26 22:52 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 22:02 ..
drwxr-xr-x  2 mzh  wheel    64B  3 26 22:02 git
drwxr-xr-x  4 mzh  wheel   128B  3 26 22:52 git-docs
$ cd git-docs
$ git remote -v
origin	git@github.com:meizhaohui/git.git (fetch)
origin	git@github.com:meizhaohui/git.git (push)
$ ls -lah
total 16
drwxr-xr-x  4 mzh  wheel   128B  3 26 22:52 .
drwxr-xr-x  4 mzh  wheel   128B  3 26 22:52 ..
-rw-r--r--  1 mzh  wheel    47B  3 26 22:52 .git
-rw-r--r--  1 mzh  wheel    22B  3 26 22:52 README.md
$
```

可以看到，设置一个不在索引中的目录为子模块的路径时，`git submodule add`命令可以执行成功，并自动克隆子仓库到本地。

切换到项目根目录，查看配置文件：

```sh
$ cd /tmp/myapp2
$ cat .gitmodules
[submodule "docs/CM/git-docs"]
	path = docs/CM/git-docs
	url = git@github.com:meizhaohui/git.git
$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@github.com:meizhaohui/myapp.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
[submodule "docs/CM/git-docs"]
	url = git@github.com:meizhaohui/git.git
	active = true
$
```

可以看到`.gitmodules`和`.git/config`配置文件中都增加了`submodule`相关的配置。

此时我们检查一下状态信息：

```sh
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitmodules
	new file:   docs/CM/git-docs

$
```

可以看到，新增了两个文件，我们尝试提交：

```sh
$ git add .
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitmodules
	new file:   docs/CM/git-docs

$ git commit -m"add git submodule"
[main 6a4680e] add git submodule
 2 files changed, 4 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 docs/CM/git-docs
$ git push origin main
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 480 bytes | 480.00 KiB/s, done.
Total 5 (delta 0), reused 0 (delta 0)
To github.com:meizhaohui/myapp.git
   7001c3a..6a4680e  main -> main
$
```

此时，在github上面查看`git-docs`目录，可以发现其不一样了：


说明我们的子模块生效了！

我们将本地`myapp`目录中的`docs/CM/git`文件删除，并提交到`myapp`仓库中。



我们此时去更新一下本地的`myapp`目录：

```sh
$ cd /tmp/myapp
$ git remote -v
origin	git@github.com:meizhaohui/myapp.git (fetch)
origin	git@github.com:meizhaohui/myapp.git (push)

# 从远程仓库拉取数据
$ git pull
remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 5 (delta 0), reused 5 (delta 0), pack-reused 0
Unpacking objects: 100% (5/5), done.
From github.com:meizhaohui/myapp
   7001c3a..6a4680e  main       -> origin/main
Updating 7001c3a..6a4680e
Fast-forward
 .gitmodules      | 3 +++
 docs/CM/git-docs | 1 +
 2 files changed, 4 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 docs/CM/git-docs

# 查看git-docs目录，可以看到该目录中没有任何文件
$ ls -lah docs/CM/git-docs
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 23:18 .
drwxr-xr-x  4 mzh  wheel   128B  3 26 23:18 ..

# 查看子模块的配置文件，可以看到，已经有子模块的配置
$ cat .gitmodules
[submodule "docs/CM/git-docs"]
	path = docs/CM/git-docs
	url = git@github.com:meizhaohui/git.git
	
# 查看.git/config项目配置文件
$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@github.com:meizhaohui/myapp.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
```

可以看到项目配置中并没有`submodule`相关的配置。

此时需要执行`git submodule init`让`.gitmodules`文件中的设置复制到`.git/config`文件中：

```sh
$ git submodule init
Submodule 'docs/CM/git-docs' (git@github.com:meizhaohui/git.git) registered for path 'docs/CM/git-docs'
$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@github.com:meizhaohui/myapp.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
[submodule "docs/CM/git-docs"]
	active = true
	url = git@github.com:meizhaohui/git.git
$
```

可以看到子模块`docs/CM/git-docs`已经注册到项目中了。

此时再执行`git submodule update`:

```sh
$ ll docs/CM/git-docs
total 0
drwxr-xr-x  2 mzh  wheel    64B  3 26 23:18 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 23:27 ..
$ git submodule update
Cloning into '/private/tmp/myapp/docs/CM/git-docs'...
Submodule path 'docs/CM/git-docs': checked out '7f8392b9f80a3c16b366e6845ba19aa3a0389808'
$ ll docs/CM/git-docs
total 16
drwxr-xr-x  4 mzh  wheel   128B  3 26 23:36 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 23:27 ..
-rw-r--r--  1 mzh  wheel    47B  3 26 23:36 .git
-rw-r--r--  1 mzh  wheel    22B  3 26 23:36 README.md
$
```

可以看到，执行`git submodule update`后，子仓库的文件已经更新到项目路径中了。



现在我们假如更新了`git`子仓库里面的文章，新增了一篇文章：

```sh
$ cd /tmp
$ git clone  git@github.com:meizhaohui/git.git
Cloning into 'git'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
$ cd git
$ ll
total 8
drwxr-xr-x   4 mzh   wheel   128B  3 26 23:53 .
drwxrwxrwt  12 root  wheel   384B  3 26 23:53 ..
drwxr-xr-x  12 mzh   wheel   384B  3 26 23:53 .git
-rw-r--r--   1 mzh   wheel    22B  3 26 23:53 README.md
$ echo 'new doc' > blog1.md
$ echo '1. [new doc](./blog1.md)' >> README.md
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   README.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	blog1.md

no changes added to commit (use "git add" and/or "git commit -a")
$ git add .
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   README.md
	new file:   blog1.md

$ git commit -m"add new doc"
[main 28bbcb8] add new doc
 2 files changed, 2 insertions(+)
 create mode 100644 blog1.md
$ git push origin main
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 338 bytes | 338.00 KiB/s, done.
Total 4 (delta 0), reused 0 (delta 0)
To github.com:meizhaohui/git.git
   7f8392b..28bbcb8  main -> main
$
```



我们来检查一下`myapp`仓库会怎么变化。

```sh
$ cd /tmp/myapp
$ git pull
Already up to date.
$ cd docs/CM/git-docs
$ ls -lah
total 16
drwxr-xr-x  4 mzh  wheel   128B  3 26 23:36 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 23:27 ..
-rw-r--r--  1 mzh  wheel    47B  3 26 23:36 .git
-rw-r--r--  1 mzh  wheel    22B  3 26 23:36 README.md
$
```

可以看到，子模块更新了，但在项目中使用`git pull`更新时，并不会将子模块的更新后的文件拉取到本地来。

那我们手动执行一下`git submodule update`更新一下：

```sh
$ git submodule update
$ echo $?
0
$ cat .gitmodules
[submodule "docs/CM/git-docs"]
	path = docs/CM/git-docs
	url = git@github.com:meizhaohui/git.git
$ ll docs/CM/git-docs
total 16
drwxr-xr-x  4 mzh  wheel   128B  3 26 23:36 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 23:27 ..
-rw-r--r--  1 mzh  wheel    47B  3 26 23:36 .git
-rw-r--r--  1 mzh  wheel    22B  3 26 23:36 README.md
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

可以看到，并没有获取到最新的更新到本地。本地也没有更新。

如果我们要更新子项目，则可以执行以下命令：

```sh
# 切换到子项目目录
$ cd docs/CM/git-docs

# 拉取子项目最新代码
$ git pull origin main
From github.com:meizhaohui/git
 * branch            main       -> FETCH_HEAD
Updating 7f8392b..28bbcb8
Fast-forward
 README.md | 1 +
 blog1.md  | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 blog1.md
 
# 查看更新后的文件，可以看到blog1.md文件已经更新到本地了，说明获取到子项目最新的代码了 
$ ll
total 24
drwxr-xr-x  5 mzh  wheel   160B  3 28 23:32 .
drwxr-xr-x  3 mzh  wheel    96B  3 26 23:27 ..
-rw-r--r--  1 mzh  wheel    47B  3 26 23:36 .git
-rw-r--r--  1 mzh  wheel    47B  3 28 23:32 README.md
-rw-r--r--  1 mzh  wheel     8B  3 28 23:32 blog1.md

# 切换到上级目录
$ cd ..

# 查看父项目状态，可以看到`git-docs`文件已经发生变化
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   git-docs (new commits)

no changes added to commit (use "git add" and/or "git commit -a")
$
```

此时，可以将子项目的映射关系更新到git仓库中：

```sh
$ git add .
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   git-docs

$ git commit -m "更新子项目映射"
[main d258f9c] 更新子项目映射
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git push origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 354 bytes | 354.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:meizhaohui/myapp.git
   1a2f771..d258f9c  main -> main
$
```

在github上面查看刚才提交的信息：


这样，我们的项目就配置了子项目的最新映射，后面可以隔一段时间，决定是否获取子项目的更新，并同步到本项目中来。



## 第17章 子模块最佳实践

- `git submodule add address local-directory-name`，为上层项目注册一个新的子模块，其远程地址为`address`，本地文件夹名为`local-directory-name`。
- `git submodule status`总结项目的所有子模块的提交引用和脏状态。
- `git submodule init`使用子模块的长期存储配置文件`.gitmodules`来更新本地版本库的`.git/config`文件。
- `git submodule update`使用`.git/config`中的地址抓取子模块的内容，并在分离的HEAD指针状态下检出上层项目的子模块记录引用。
- `git submodule summay`展示每个子模块当前状态相对于提交状态间变化的补丁。



## 第18章 结合SVN版本库使用Git

略



## 第19章 高级操作

### 19.1 使用`git filter-branch`

- `git filter-branch`是一个能用的分支操作命令，可以通过自定义命令来利用它操作不同的`git`对象，从而重写分支上的提交。一些过滤器可以对提交起作用，一些对树对象和目录结构起作用，还有一些则可以操作`git`环境。
- 强大的功能伴随着巨大的责任。
- `fiter-branch`命令的目的和功能也正是我警告的来源：它具有改写整个版本库提交历史的潜能，如果对一个已经对外发布供大家克隆和使用的版本库执行此命令，将会给使用该版本库的其他人带来无尽的苦恼。
- `fiter-branch`命令会在版本库中的一个或多个分支上运行一系列过滤器，每个过滤器可以搭配一条自定义过滤器命令。这些过滤器命令不必全部执行，甚至可以只执行一个。但是它们按顺序执行，于是前面过滤器可以影响后面过滤器的行为。
- 如`subdurectory-filter`可以在提交前起过滤作用，而`tag-name-filter`则在提交后起作用。


查看`git filter-branch`帮助信息：

```sh
root@4144e8c22fff:/# su - mei
mei@4144e8c22fff:~$ git --version
git version 2.25.1
mei@4144e8c22fff:~$ git filter-branch --help
GIT-FILTER-BRANCH(1)                                  Git Manual                                 GIT-FILTER-BRANCH(1)

NAME
       git-filter-branch - Rewrite branches

SYNOPSIS
       git filter-branch [--setup <command>] [--subdirectory-filter <directory>]
               [--env-filter <command>] [--tree-filter <command>]
               [--index-filter <command>] [--parent-filter <command>]
               [--msg-filter <command>] [--commit-filter <command>]
               [--tag-name-filter <command>] [--prune-empty]
               [--original <namespace>] [-d <directory>] [-f | --force]
               [--state-branch <branch>] [--] [<rev-list options>...]

WARNING
       git filter-branch has a plethora of pitfalls that can produce non-obvious manglings of the intended history
       rewrite (and can leave you with little time to investigate such problems since it has such abysmal
       performance). These safety and performance issues cannot be backward compatibly fixed and as such, its use is
       not recommended. Please use an alternative history filtering tool such as git filter-repo[1]. If you still
       need to use git filter-branch, please carefully read the section called "SAFETY" (and the section called
       "PERFORMANCE") to learn about the land mines of filter-branch, and then vigilantly avoid as many of the
       hazards listed there as reasonably possible.

DESCRIPTION
       Lets you rewrite Git revision history by rewriting the branches mentioned in the <rev-list options>, applying
       custom filters on each revision. Those filters can modify each tree (e.g. removing a file or running a perl
       rewrite on all files) or information about each commit. Otherwise, all information (including original commit
       times or merge information) will be preserved.

       The command will only rewrite the positive refs mentioned in the command line (e.g. if you pass a..b, only b
       will be rewritten). If you specify no filters, the commits will be recommitted without any changes, which
       would normally have no effect. Nevertheless, this may be useful in the future for compensating for some Git
       bugs or such, therefore such a usage is permitted.

       NOTE: This command honors .git/info/grafts file and refs in the refs/replace/ namespace. If you have any
       grafts or replacement refs defined, running this command will make them permanent.

       WARNING! The rewritten history will have different object names for all the objects and will not converge with
       the original branch. You will not be able to easily push and distribute the rewritten branch on top of the
       original branch. Please do not use this command if you do not know the full implications, and avoid using it
       anyway, if a simple single commit would suffice to fix your problem. (See the "RECOVERING FROM UPSTREAM
       REBASE" section in git-rebase(1) for further information about rewriting published history.)

       Always verify that the rewritten version is correct: The original refs, if different from the rewritten ones,
       will be stored in the namespace refs/original/.

       Note that since this operation is very I/O expensive, it might be a good idea to redirect the temporary
       directory off-disk with the -d option, e.g. on tmpfs. Reportedly the speedup is very noticeable.

   Filters
       The filters are applied in the order as listed below. The <command> argument is always evaluated in the shell
       context using the eval command (with the notable exception of the commit filter, for technical reasons). Prior
       to that, the $GIT_COMMIT environment variable will be set to contain the id of the commit being rewritten.
       Also, GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL, GIT_AUTHOR_DATE, GIT_COMMITTER_NAME, GIT_COMMITTER_EMAIL, and
       GIT_COMMITTER_DATE are taken from the current commit and exported to the environment, in order to affect the
       author and committer identities of the replacement commit created by git-commit-tree(1) after the filters have
       run.

       If any evaluation of <command> returns a non-zero exit status, the whole operation will be aborted.

       A map function is available that takes an "original sha1 id" argument and outputs a "rewritten sha1 id" if the
       commit has been already rewritten, and "original sha1 id" otherwise; the map function can return several ids
       on separate lines if your commit filter emitted multiple commits.

OPTIONS
       --setup <command>
           This is not a real filter executed for each commit but a one time setup just before the loop. Therefore no
           commit-specific variables are defined yet. Functions or variables defined here can be used or modified in
           the following filter steps except the commit filter, for technical reasons.

       --subdirectory-filter <directory>
           Only look at the history which touches the given subdirectory. The result will contain that directory (and
           only that) as its project root. Implies the section called "Remap to ancestor".

       --env-filter <command>
           This filter may be used if you only need to modify the environment in which the commit will be performed.
           Specifically, you might want to rewrite the author/committer name/email/time environment variables (see
           git-commit-tree(1) for details).

       --tree-filter <command>
           This is the filter for rewriting the tree and its contents. The argument is evaluated in shell with the
           working directory set to the root of the checked out tree. The new tree is then used as-is (new files are
           auto-added, disappeared files are auto-removed - neither .gitignore files nor any other ignore rules HAVE
           ANY EFFECT!).

       --index-filter <command>
           This is the filter for rewriting the index. It is similar to the tree filter but does not check out the
           tree, which makes it much faster. Frequently used with git rm --cached --ignore-unmatch ..., see EXAMPLES
           below. For hairy cases, see git-update-index(1).

       --parent-filter <command>
           This is the filter for rewriting the commit's parent list. It will receive the parent string on stdin and
           shall output the new parent string on stdout. The parent string is in the format described in git-commit-
           tree(1): empty for the initial commit, "-p parent" for a normal commit and "-p parent1 -p parent2 -p
           parent3 ..." for a merge commit.

       --msg-filter <command>
           This is the filter for rewriting the commit messages. The argument is evaluated in the shell with the
           original commit message on standard input; its standard output is used as the new commit message.

       --commit-filter <command>
           This is the filter for performing the commit. If this filter is specified, it will be called instead of
           the git commit-tree command, with arguments of the form "<TREE_ID> [(-p <PARENT_COMMIT_ID>)...]" and the
           log message on stdin. The commit id is expected on stdout.

           As a special extension, the commit filter may emit multiple commit ids; in that case, the rewritten
           children of the original commit will have all of them as parents.

           You can use the map convenience function in this filter, and other convenience functions, too. For
           example, calling skip_commit "$@" will leave out the current commit (but not its changes! If you want
           that, use git rebase instead).

           You can also use the git_commit_non_empty_tree "$@" instead of git commit-tree "$@" if you don't wish to
           keep commits with a single parent and that makes no change to the tree.

       --tag-name-filter <command>
           This is the filter for rewriting tag names. When passed, it will be called for every tag ref that points
           to a rewritten object (or to a tag object which points to a rewritten object). The original tag name is
           passed via standard input, and the new tag name is expected on standard output.

           The original tags are not deleted, but can be overwritten; use "--tag-name-filter cat" to simply update
           the tags. In this case, be very careful and make sure you have the old tags backed up in case the
           conversion has run afoul.

           Nearly proper rewriting of tag objects is supported. If the tag has a message attached, a new tag object
           will be created with the same message, author, and timestamp. If the tag has a signature attached, the
           signature will be stripped. It is by definition impossible to preserve signatures. The reason this is
           "nearly" proper, is because ideally if the tag did not change (points to the same object, has the same
           name, etc.) it should retain any signature. That is not the case, signatures will always be removed, buyer
           beware. There is also no support for changing the author or timestamp (or the tag message for that
           matter). Tags which point to other tags will be rewritten to point to the underlying commit.

       --prune-empty
           Some filters will generate empty commits that leave the tree untouched. This option instructs
           git-filter-branch to remove such commits if they have exactly one or zero non-pruned parents; merge
           commits will therefore remain intact. This option cannot be used together with --commit-filter, though the
           same effect can be achieved by using the provided git_commit_non_empty_tree function in a commit filter.

       --original <namespace>
           Use this option to set the namespace where the original commits will be stored. The default value is
           refs/original.

       -d <directory>
           Use this option to set the path to the temporary directory used for rewriting. When applying a tree
           filter, the command needs to temporarily check out the tree to some directory, which may consume
           considerable space in case of large projects. By default it does this in the .git-rewrite/ directory but
           you can override that choice by this parameter.

       -f, --force
           git filter-branch refuses to start with an existing temporary directory or when there are already refs
           starting with refs/original/, unless forced.

       --state-branch <branch>
           This option will cause the mapping from old to new objects to be loaded from named branch upon startup and
           saved as a new commit to that branch upon exit, enabling incremental of large trees. If <branch> does not
           exist it will be created.

       <rev-list options>...
           Arguments for git rev-list. All positive refs included by these options are rewritten. You may also
           specify options such as --all, but you must use -- to separate them from the git filter-branch options.
           Implies the section called "Remap to ancestor".

   Remap to ancestor
       By using git-rev-list(1) arguments, e.g., path limiters, you can limit the set of revisions which get
       rewritten. However, positive refs on the command line are distinguished: we don't let them be excluded by such
       limiters. For this purpose, they are instead rewritten to point at the nearest ancestor that was not excluded.

EXIT STATUS
       On success, the exit status is 0. If the filter can't find any commits to rewrite, the exit status is 2. On
       any other error, the exit status may be any other non-zero value.

EXAMPLES
       Suppose you want to remove a file (containing confidential information or copyright violation) from all
       commits:

           git filter-branch --tree-filter 'rm filename' HEAD

       However, if the file is absent from the tree of some commit, a simple rm filename will fail for that tree and
       commit. Thus you may instead want to use rm -f filename as the script.

       Using --index-filter with git rm yields a significantly faster version. Like with using rm filename, git rm
       --cached filename will fail if the file is absent from the tree of a commit. If you want to "completely
       forget" a file, it does not matter when it entered history, so we also add --ignore-unmatch:

           git filter-branch --index-filter 'git rm --cached --ignore-unmatch filename' HEAD

       Now, you will get the rewritten history saved in HEAD.

       To rewrite the repository to look as if foodir/ had been its project root, and discard all other history:

           git filter-branch --subdirectory-filter foodir -- --all

       Thus you can, e.g., turn a library subdirectory into a repository of its own. Note the -- that separates
       filter-branch options from revision options, and the --all to rewrite all branches and tags.

       To set a commit (which typically is at the tip of another history) to be the parent of the current initial
       commit, in order to paste the other history behind the current history:

           git filter-branch --parent-filter 'sed "s/^\$/-p <graft-id>/"' HEAD

       (if the parent string is empty - which happens when we are dealing with the initial commit - add graftcommit
       as a parent). Note that this assumes history with a single root (that is, no merge without common ancestors
       happened). If this is not the case, use:

           git filter-branch --parent-filter \
                   'test $GIT_COMMIT = <commit-id> && echo "-p <graft-id>" || cat' HEAD

       or even simpler:

           git replace --graft $commit-id $graft-id
           git filter-branch $graft-id..HEAD

       To remove commits authored by "Darl McBribe" from the history:

           git filter-branch --commit-filter '
                   if [ "$GIT_AUTHOR_NAME" = "Darl McBribe" ];
                   then
                           skip_commit "$@";
                   else
                           git commit-tree "$@";
                   fi' HEAD

       The function skip_commit is defined as follows:

           skip_commit()
           {
                   shift;
                   while [ -n "$1" ];
                   do
                           shift;
                           map "$1";
                           shift;
                   done;
           }

       The shift magic first throws away the tree id and then the -p parameters. Note that this handles merges
       properly! In case Darl committed a merge between P1 and P2, it will be propagated properly and all children of
       the merge will become merge commits with P1,P2 as their parents instead of the merge commit.

       NOTE the changes introduced by the commits, and which are not reverted by subsequent commits, will still be in
       the rewritten branch. If you want to throw out changes together with the commits, you should use the
       interactive mode of git rebase.

       You can rewrite the commit log messages using --msg-filter. For example, git svn-id strings in a repository
       created by git svn can be removed this way:

           git filter-branch --msg-filter '
                   sed -e "/^git-svn-id:/d"
           '

       If you need to add Acked-by lines to, say, the last 10 commits (none of which is a merge), use this command:

           git filter-branch --msg-filter '
                   cat &&
                   echo "Acked-by: Bugs Bunny <bunny@bugzilla.org>"
           ' HEAD~10..HEAD

       The --env-filter option can be used to modify committer and/or author identity. For example, if you found out
       that your commits have the wrong identity due to a misconfigured user.email, you can make a correction, before
       publishing the project, like this:

           git filter-branch --env-filter '
                   if test "$GIT_AUTHOR_EMAIL" = "root@localhost"
                   then
                           GIT_AUTHOR_EMAIL=john@example.com
                   fi
                   if test "$GIT_COMMITTER_EMAIL" = "root@localhost"
                   then
                           GIT_COMMITTER_EMAIL=john@example.com
                   fi
           ' -- --all

       To restrict rewriting to only part of the history, specify a revision range in addition to the new branch
       name. The new branch name will point to the top-most revision that a git rev-list of this range will print.

       Consider this history:

                D--E--F--G--H
               /     /
           A--B-----C

       To rewrite only commits D,E,F,G,H, but leave A, B and C alone, use:

           git filter-branch ... C..H

       To rewrite commits E,F,G,H, use one of these:

           git filter-branch ... C..H --not D
           git filter-branch ... D..H --not C

       To move the whole tree into a subdirectory, or remove it from there:

           git filter-branch --index-filter \
                   'git ls-files -s | sed "s-\t\"*-&newsubdir/-" |
                           GIT_INDEX_FILE=$GIT_INDEX_FILE.new \
                                   git update-index --index-info &&
                    mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"' HEAD

CHECKLIST FOR SHRINKING A REPOSITORY
       git-filter-branch can be used to get rid of a subset of files, usually with some combination of --index-filter
       and --subdirectory-filter. People expect the resulting repository to be smaller than the original, but you
       need a few more steps to actually make it smaller, because Git tries hard not to lose your objects until you
       tell it to. First make sure that:

       o   You really removed all variants of a filename, if a blob was moved over its lifetime.  git log --name-only
           --follow --all -- filename can help you find renames.

       o   You really filtered all refs: use --tag-name-filter cat -- --all when calling git-filter-branch.

       Then there are two ways to get a smaller repository. A safer way is to clone, that keeps your original intact.

       o   Clone it with git clone file:///path/to/repo. The clone will not have the removed objects. See git-
           clone(1). (Note that cloning with a plain path just hardlinks everything!)

       If you really don't want to clone it, for whatever reasons, check the following points instead (in this
       order). This is a very destructive approach, so make a backup or go back to cloning it. You have been warned.

       o   Remove the original refs backed up by git-filter-branch: say git for-each-ref --format="%(refname)"
           refs/original/ | xargs -n 1 git update-ref -d.

       o   Expire all reflogs with git reflog expire --expire=now --all.

       o   Garbage collect all unreferenced objects with git gc --prune=now (or if your git-gc is not new enough to
           support arguments to --prune, use git repack -ad; git prune instead).

PERFORMANCE
       The performance of git-filter-branch is glacially slow; its design makes it impossible for a
       backward-compatible implementation to ever be fast:

       o   In editing files, git-filter-branch by design checks out each and every commit as it existed in the
           original repo. If your repo has 10^5 files and 10^5 commits, but each commit only modifies five files,
           then git-filter-branch will make you do 10^10 modifications, despite only having (at most) 5*10^5 unique
           blobs.

       o   If you try and cheat and try to make git-filter-branch only work on files modified in a commit, then two
           things happen

           o   you run into problems with deletions whenever the user is simply trying to rename files (because
               attempting to delete files that don't exist looks like a no-op; it takes some chicanery to remap
               deletes across file renames when the renames happen via arbitrary user-provided shell)

           o   even if you succeed at the map-deletes-for-renames chicanery, you still technically violate backward
               compatibility because users are allowed to filter files in ways that depend upon topology of commits
               instead of filtering solely based on file contents or names (though this has not been observed in the
               wild).

       o   Even if you don't need to edit files but only want to e.g. rename or remove some and thus can avoid
           checking out each file (i.e. you can use --index-filter), you still are passing shell snippets for your
           filters. This means that for every commit, you have to have a prepared git repo where those filters can be
           run. That's a significant setup.

       o   Further, several additional files are created or updated per commit by git-filter-branch. Some of these
           are for supporting the convenience functions provided by git-filter-branch (such as map()), while others
           are for keeping track of internal state (but could have also been accessed by user filters; one of
           git-filter-branch's regression tests does so). This essentially amounts to using the filesystem as an IPC
           mechanism between git-filter-branch and the user-provided filters. Disks tend to be a slow IPC mechanism,
           and writing these files also effectively represents a forced synchronization point between separate
           processes that we hit with every commit.

       o   The user-provided shell commands will likely involve a pipeline of commands, resulting in the creation of
           many processes per commit. Creating and running another process takes a widely varying amount of time
           between operating systems, but on any platform it is very slow relative to invoking a function.

       o   git-filter-branch itself is written in shell, which is kind of slow. This is the one performance issue
           that could be backward-compatibly fixed, but compared to the above problems that are intrinsic to the
           design of git-filter-branch, the language of the tool itself is a relatively minor issue.

           o   Side note: Unfortunately, people tend to fixate on the written-in-shell aspect and periodically ask if
               git-filter-branch could be rewritten in another language to fix the performance issues. Not only does
               that ignore the bigger intrinsic problems with the design, it'd help less than you'd expect: if
               git-filter-branch itself were not shell, then the convenience functions (map(), skip_commit(), etc)
               and the --setup argument could no longer be executed once at the beginning of the program but would
               instead need to be prepended to every user filter (and thus re-executed with every commit).

       The git filter-repo[1] tool is an alternative to git-filter-branch which does not suffer from these
       performance problems or the safety problems (mentioned below). For those with existing tooling which relies
       upon git-filter-branch, git repo-filter also provides filter-lamely[2], a drop-in git-filter-branch
       replacement (with a few caveats). While filter-lamely suffers from all the same safety issues as
       git-filter-branch, it at least ameliorates the performance issues a little.

SAFETY
       git-filter-branch is riddled with gotchas resulting in various ways to easily corrupt repos or end up with a
       mess worse than what you started with:

       o   Someone can have a set of "working and tested filters" which they document or provide to a coworker, who
           then runs them on a different OS where the same commands are not working/tested (some examples in the
           git-filter-branch manpage are also affected by this). BSD vs. GNU userland differences can really bite. If
           lucky, error messages are spewed. But just as likely, the commands either don't do the filtering
           requested, or silently corrupt by making some unwanted change. The unwanted change may only affect a few
           commits, so it's not necessarily obvious either. (The fact that problems won't necessarily be obvious
           means they are likely to go unnoticed until the rewritten history is in use for quite a while, at which
           point it's really hard to justify another flag-day for another rewrite.)

       o   Filenames with spaces are often mishandled by shell snippets since they cause problems for shell
           pipelines. Not everyone is familiar with find -print0, xargs -0, git-ls-files -z, etc. Even people who are
           familiar with these may assume such flags are not relevant because someone else renamed any such files in
           their repo back before the person doing the filtering joined the project. And often, even those familiar
           with handling arguments with spaces may not do so just because they aren't in the mindset of thinking
           about everything that could possibly go wrong.

       o   Non-ascii filenames can be silently removed despite being in a desired directory. Keeping only wanted
           paths is often done using pipelines like git ls-files | grep -v ^WANTED_DIR/ | xargs git rm. ls-files will
           only quote filenames if needed, so folks may not notice that one of the files didn't match the regex (at
           least not until it's much too late). Yes, someone who knows about core.quotePath can avoid this (unless
           they have other special characters like \t, \n, or "), and people who use ls-files -z with something other
           than grep can avoid this, but that doesn't mean they will.

       o   Similarly, when moving files around, one can find that filenames with non-ascii or special characters end
           up in a different directory, one that includes a double quote character. (This is technically the same
           issue as above with quoting, but perhaps an interesting different way that it can and has manifested as a
           problem.)

       o   It's far too easy to accidentally mix up old and new history. It's still possible with any tool, but
           git-filter-branch almost invites it. If lucky, the only downside is users getting frustrated that they
           don't know how to shrink their repo and remove the old stuff. If unlucky, they merge old and new history
           and end up with multiple "copies" of each commit, some of which have unwanted or sensitive files and
           others which don't. This comes about in multiple different ways:

           o   the default to only doing a partial history rewrite (--all is not the default and few examples show
               it)

           o   the fact that there's no automatic post-run cleanup

           o   the fact that --tag-name-filter (when used to rename tags) doesn't remove the old tags but just adds
               new ones with the new name

           o   the fact that little educational information is provided to inform users of the ramifications of a
               rewrite and how to avoid mixing old and new history. For example, this man page discusses how users
               need to understand that they need to rebase their changes for all their branches on top of new history
               (or delete and reclone), but that's only one of multiple concerns to consider. See the "DISCUSSION"
               section of the git filter-repo manual page for more details.

       o   Annotated tags can be accidentally converted to lightweight tags, due to either of two issues:

           o   Someone can do a history rewrite, realize they messed up, restore from the backups in refs/original/,
               and then redo their git-filter-branch command. (The backup in refs/original/ is not a real backup; it
               dereferences tags first.)

           o   Running git-filter-branch with either --tags or --all in your <rev-list options>. In order to retain
               annotated tags as annotated, you must use --tag-name-filter (and must not have restored from
               refs/original/ in a previously botched rewrite).

       o   Any commit messages that specify an encoding will become corrupted by the rewrite; git-filter-branch
           ignores the encoding, takes the original bytes, and feeds it to commit-tree without telling it the proper
           encoding. (This happens whether or not --msg-filter is used.)

       o   Commit messages (even if they are all UTF-8) by default become corrupted due to not being updated -- any
           references to other commit hashes in commit messages will now refer to no-longer-extant commits.

       o   There are no facilities for helping users find what unwanted crud they should delete, which means they are
           much more likely to have incomplete or partial cleanups that sometimes result in confusion and people
           wasting time trying to understand. (For example, folks tend to just look for big files to delete instead
           of big directories or extensions, and once they do so, then sometime later folks using the new repository
           who are going through history will notice a build artifact directory that has some files but not others,
           or a cache of dependencies (node_modules or similar) which couldn't have ever been functional since it's
           missing some files.)

       o   If --prune-empty isn't specified, then the filtering process can create hoards of confusing empty commits

       o   If --prune-empty is specified, then intentionally placed empty commits from before the filtering operation
           are also pruned instead of just pruning commits that became empty due to filtering rules.

       o   If --prune-empty is specified, sometimes empty commits are missed and left around anyway (a somewhat rare
           bug, but it happens...)

       o   A minor issue, but users who have a goal to update all names and emails in a repository may be led to
           --env-filter which will only update authors and committers, missing taggers.

       o   If the user provides a --tag-name-filter that maps multiple tags to the same name, no warning or error is
           provided; git-filter-branch simply overwrites each tag in some undocumented pre-defined order resulting in
           only one tag at the end. (A git-filter-branch regression test requires this surprising behavior.)

       Also, the poor performance of git-filter-branch often leads to safety issues:

       o   Coming up with the correct shell snippet to do the filtering you want is sometimes difficult unless you're
           just doing a trivial modification such as deleting a couple files. Unfortunately, people often learn if
           the snippet is right or wrong by trying it out, but the rightness or wrongness can vary depending on
           special circumstances (spaces in filenames, non-ascii filenames, funny author names or emails, invalid
           timezones, presence of grafts or replace objects, etc.), meaning they may have to wait a long time, hit an
           error, then restart. The performance of git-filter-branch is so bad that this cycle is painful, reducing
           the time available to carefully re-check (to say nothing about what it does to the patience of the person
           doing the rewrite even if they do technically have more time available). This problem is extra compounded
           because errors from broken filters may not be shown for a long time and/or get lost in a sea of output.
           Even worse, broken filters often just result in silent incorrect rewrites.

       o   To top it all off, even when users finally find working commands, they naturally want to share them. But
           they may be unaware that their repo didn't have some special cases that someone else's does. So, when
           someone else with a different repository runs the same commands, they get hit by the problems above. Or,
           the user just runs commands that really were vetted for special cases, but they run it on a different OS
           where it doesn't work, as noted above.

GIT
       Part of the git(1) suite

NOTES
        1. git filter-repo
           https://github.com/newren/git-filter-repo/

        2. filter-lamely
           https://github.com/newren/git-filter-repo/blob/master/contrib/filter-repo-demos/filter-lamely

Git 2.25.1                                            03/04/2021                                 GIT-FILTER-BRANCH(1)
```

可以看到，帮助信息非常长。

考试到`git filter-branch`及其复杂，并在实际中很少使用，此处不进行详细的实践操作。



## 第20章 提示、技巧和技术

### 20.9 定制Git命令

我们可以使用`alias`来设置git快捷命令。我们也可以使用如下方式来定制自己的Git命令。

- 写下你的命令或脚本，命名以前缀`git-`开头，并存放到`~/bin`目录，或者shell PATH环境变量能找到的其他地方。

如果你想要一个脚本，用来确定你是否在Git版本库顶层。把它称为`git-top-check`，可以编写如下的脚本：

```sh
#!/bin/bash
# filename: git-top-check
# description: check current folder is the top level directory of a Git repo?

if [[ -d ".git" ]]; then
    echo "This is a top level Git development repository."
    exit 0
fi

echo "This is not a top level Git development repository."
exit 1

```

download git-top-check

将其存放在`/usr/bin`目录下，并增加可执行权限：

```sh
# chmod +x /usr/bin/git-top-check
```

然后在切换到一个存储库目录下：

```sh
mei@4144e8c22fff:~/git$ git remote -v
origin	https://gitee.com/meizhaohui/git.git (fetch)
origin	https://gitee.com/meizhaohui/git.git (push)
mei@4144e8c22fff:~/git$ git top-check
This is a top level Git development repository.
mei@4144e8c22fff:~/git$ cd ..
mei@4144e8c22fff:~$ git top-check
This is not a top level Git development repository.
mei@4144e8c22fff:~$
```

可以看到，能够正常执行`git top-check`命令，说明我们定制的Git命令能够正常工作！



### 20.11 清理

可以使用`git clean`清理工作树中未追踪的文件。

```sh
mei@4144e8c22fff:~/git$ git clean --help|awk NF
GIT-CLEAN(1)                                          Git Manual                                         GIT-CLEAN(1)
NAME
       git-clean - Remove untracked files from the working tree
SYNOPSIS
       git clean [-d] [-f] [-i] [-n] [-q] [-e <pattern>] [-x | -X] [--] <path>...
DESCRIPTION
       Cleans the working tree by recursively removing files that are not under version control, starting from the
       current directory.
       Normally, only files unknown to Git are removed, but if the -x option is specified, ignored files are also
       removed. This can, for example, be useful to remove all build products.
       If any optional <path>... arguments are given, only those paths are affected.
OPTIONS
       -d
           Normally, when no <path> is specified, git clean will not recurse into untracked directories to avoid
           removing too much. Specify -d to have it recurse into such directories as well. If any paths are
           specified, -d is irrelevant; all untracked files matching the specified paths (with exceptions for nested
           git directories mentioned under --force) will be removed.
       -f, --force
           If the Git configuration variable clean.requireForce is not set to false, git clean will refuse to delete
           files or directories unless given -f or -i. Git will refuse to modify untracked nested git repositories
           (directories with a .git subdirectory) unless a second -f is given.
       -i, --interactive
           Show what would be done and clean files interactively. See "Interactive mode" for details.
       -n, --dry-run
           Don't actually remove anything, just show what would be done.
       -q, --quiet
           Be quiet, only report errors, but not the files that are successfully removed.
       -e <pattern>, --exclude=<pattern>
           Use the given exclude pattern in addition to the standard ignore rules (see gitignore(5)).
       -x
           Don't use the standard ignore rules (see gitignore(5)), but still use the ignore rules given with -e
           options from the command line. This allows removing all untracked files, including build products. This
           can be used (possibly in conjunction with git restore or git reset) to create a pristine working directory
           to test a clean build.
       -X
           Remove only files ignored by Git. This may be useful to rebuild everything from scratch, but keep manually
           created files.
INTERACTIVE MODE
       When the command enters the interactive mode, it shows the files and directories to be cleaned, and goes into
       its interactive command loop.
       The command loop shows the list of subcommands available, and gives a prompt "What now> ". In general, when
       the prompt ends with a single >, you can pick only one of the choices given and type return, like this:
               *** Commands ***
                   1: clean                2: filter by pattern    3: select by numbers
                   4: ask each             5: quit                 6: help
               What now> 1
       You also could say c or clean above as long as the choice is unique.
       The main command loop has 6 subcommands.
       clean
           Start cleaning files and directories, and then quit.
       filter by pattern
           This shows the files and directories to be deleted and issues an "Input ignore patterns>>" prompt. You can
           input space-separated patterns to exclude files and directories from deletion. E.g. "*.c *.h" will
           excludes files end with ".c" and ".h" from deletion. When you are satisfied with the filtered result,
           press ENTER (empty) back to the main menu.
       select by numbers
           This shows the files and directories to be deleted and issues an "Select items to delete>>" prompt. When
           the prompt ends with double >> like this, you can make more than one selection, concatenated with
           whitespace or comma. Also you can say ranges. E.g. "2-5 7,9" to choose 2,3,4,5,7,9 from the list. If the
           second number in a range is omitted, all remaining items are selected. E.g. "7-" to choose 7,8,9 from the
           list. You can say * to choose everything. Also when you are satisfied with the filtered result, press
           ENTER (empty) back to the main menu.
       ask each
           This will start to clean, and you must confirm one by one in order to delete items. Please note that this
           action is not as efficient as the above two actions.
       quit
           This lets you quit without do cleaning.
       help
           Show brief usage of interactive git-clean.
SEE ALSO
       gitignore(5)
GIT
       Part of the git(1) suite
Git 2.25.1                                            03/04/2021                                         GIT-CLEAN(1)
mei@4144e8c22fff:~/git$
```

即：

- `-d`选项可递归删除未追踪的目录。
- `-f`强制删除。
- `-i`进入交互模式。
- `-n`显示会执行哪些操作，但不实际执行。
- `-q`仅报告异常，不显示哪些文件被移除。

如创建3个文件夹和4个文件:

```
mei@4144e8c22fff:~/git$ mkdir -p d1/d2/d3
mei@4144e8c22fff:~/git$ echo f0 > f0
mei@4144e8c22fff:~/git$ echo f1 >d1/f1
mei@4144e8c22fff:~/git$ echo f2 > d1/d2/f2
mei@4144e8c22fff:~/git$ echo f3 > d1/d2/d3/f3
mei@4144e8c22fff:~/git$ git status
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	d1/
	f0

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/git$
```

直接执行，会抛出异常：

```sh
mei@4144e8c22fff:~/git$ git clean
fatal: clean.requireForce defaults to true and neither -i, -n, nor -f given; refusing to clean
mei@4144e8c22fff:~/git$
```

增加`-n`参数，看看`git clean`会清理哪些文件：

```sh
mei@4144e8c22fff:~/git$ git clean -n
Would remove f0
mei@4144e8c22fff:~/git$ ls f0
f0
mei@4144e8c22fff:~/git$
```

可以盾到，`-n`参数会显示会清理哪些文件，但并没有实际清理，`f0`文件仍然存在。



使用`-f`参数直接强制清理：

```sh
mei@4144e8c22fff:~/git$ git clean -f
Removing f0
mei@4144e8c22fff:~/git$ ls f0
ls: cannot access 'f0': No such file or directory
mei@4144e8c22fff:~/git$ git status
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	d1/

nothing added to commit but untracked files present (use "git add" to track)
mei@4144e8c22fff:~/git$
```

可以看到`f0`文件被清理。`d1`文件夹仍然存在，未被清理。

我们再加上`-d`参数：

```sh
mei@4144e8c22fff:~/git$ git clean -d -n
Would remove d1/
mei@4144e8c22fff:~/git$ git clean -d -f
Removing d1/
mei@4144e8c22fff:~/git$ git status
On branch master
Your branch is up to date with 'origin/master'.

You are currently bisecting, started from branch 'master'.
  (use "git bisect reset" to get back to the original branch)

nothing to commit, working tree clean
mei@4144e8c22fff:~/git$
```

可以看到，使用`-d`参数后，递归的清理掉了文件夹下面未被跟踪的文件。



## 第21章 Git和GitHub

- 复刻是对一个项目创建一个私人副本，真正为核心项目带来价值的是合并请求(pull request)。

