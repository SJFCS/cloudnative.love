# Git hooks钩子脚本的使用

[[toc]]



## 1. 简介

- 你可以使用Git钩子(hook)，任何时候当版本库中出现如提交或补丁这样的特殊事件时，都会触发执行一个或多个任意的脚本。
- 通常情况下，一个事件会分解成多个规定好的步骤，可以为每个步骤绑定自定义脚本。
- 当Git事件发生时，每一步开始都会调用相应的脚本。
- 钩子只属于并作用于一个特定的版本库，在克隆操作的时候不会复制。钩子不会传递到新克隆的版本库，也不会改变新克隆的仓库的行为。
- 一个钩子既可以在当前本地版本库的上下文中运行，也可以在远程版本库的上下文中运行。一个是本地钩子，一个是远程版本库中的钩子。
- 大多数Git钩子属于这两类：
    - 前置(pre)钩子，会在动作完成前调用。要在变更应用前进行批准、拒绝或者调整操作，可以使用这些钩子。
    - 后置(post)钩子，会在动作完成之后调用，它常用来触发通知（如邮件通知）或者进行额外处理，如执行构建或关闭bug。
- 通常情况下，如果前置钩子以非零状态退出（这是代表失败的惯例），那么Git的动作会中止。后置钩子的结束状态总是会被忽略，因为它不再影响动作的结果，因为此时动作已经完成了。即后置钩子的状态码对动作无效。
- 一般而言，Git开发人员主张谨慎地使用钩子。他们认为，钩子应当作为最后的手段，只有当你通过其他方式不能达到相同效果时才使用钩子。可以使用Git别名或者`alias`别名来完成相同的任务，或者使用一些shell脚本来分别增强`git commit`、`git checkout`和`git branch`等。
- 钩子可能带来如下问题：
    - 钩子会改变Git的行为。
    - 钩子可以使原来很快的操作变得很慢。如在提交前进行单元测试，但这会让提交变得缓慢。在Git中，提交应当是一次快速操作，从而鼓励频繁地提交，进面避免数据丢失。因此减缓提交速度会让Git的使用变得不那么愉快。
    - 一个出问题的钩子脚本会影响你的工作和效率。解决它的唯一办法就是禁用它。
    - 版本库中的钩子不会自动复制。
- 有5个合理的理由去为Git命令或操作添加钩子：
    1. 为了撤销底层命令做出的决定。`update`和`pre-commit`钩子都是用于这个目的的。
    2. 为了在命令开始执行后对生成的数据进行操作。例如，使用`commit-msg`钩子修改提交日志消息。
    3. 在仅能使用Git协议访问时，对连接的远程端进行操作。如执行`git update-server-info`的`post-update`钩子就是为了完成这个任务的。
    4. 为了获得互斥锁。这是一个很少见的需求，但还是有钩子能实现它。
    5. 为了根据命令的输出执行几种可能的操作之一。`post-checkout`钩子就是一个明显的例子。

## 2. 安装钩子

- 每个钩子都是一个脚本。
- 作用于一个特定版本库的钩子集合都能在`.git/hooks`目录下面找到。
- Git不会在版本库间复制钩子。
- 每个钩子都是以它相关联的事件来命名的。如`git commit`操作之前即刻执行的钩子称为`.git/hooks/pre-commit`。
- 一个钩子脚本必须遵循UNIX脚本的基本规则：
    - 钩子必须是可执行的，即有`x`可执行权限。
    - 钩子脚本必须在首行指明该脚本使用的语言，如`#!/bin/bash`。
- 如果存在特定的钩子并且钩子有正确的名字和文件授权，那么Git就能自动使用它。

### 2.1 钩子示例

根据具体的Git版本，你可以会发现在版本库创建时就已经存在一些钩子了。在你创建新的版本库时，那些钩子是自动复制自你的Git模板目录的。

通常钩子都复制自`/usr/share/git-core/templates/hooks`目录。

查看Git模板目录下的钩子示例：

```sh
mei@4144e8c22fff:~/git$ ls -lh /usr/share/git-core/templates/hooks
total 52K
-rwxr-xr-x 1 root root  478 Mar  4  2021 applypatch-msg.sample
-rwxr-xr-x 1 root root  896 Mar  4  2021 commit-msg.sample
-rwxr-xr-x 1 root root 3.1K Mar  4  2021 fsmonitor-watchman.sample
-rwxr-xr-x 1 root root  189 Mar  4  2021 post-update.sample
-rwxr-xr-x 1 root root  424 Mar  4  2021 pre-applypatch.sample
-rwxr-xr-x 1 root root 1.6K Mar  4  2021 pre-commit.sample
-rwxr-xr-x 1 root root  416 Mar  4  2021 pre-merge-commit.sample
-rwxr-xr-x 1 root root 1.4K Mar  4  2021 pre-push.sample
-rwxr-xr-x 1 root root 4.8K Mar  4  2021 pre-rebase.sample
-rwxr-xr-x 1 root root  544 Mar  4  2021 pre-receive.sample
-rwxr-xr-x 1 root root 1.5K Mar  4  2021 prepare-commit-msg.sample
-rwxr-xr-x 1 root root 3.6K Mar  4  2021 update.sample
mei@4144e8c22fff:~/git$
```



我们也可以在`.git/hooks`目录中看到钩子示例，这些示例都是从Git模板复制过来的：

```sh
mei@4144e8c22fff:~/git$ find .git/hooks/*|sort
.git/hooks/applypatch-msg.sample
.git/hooks/commit-msg.sample
.git/hooks/fsmonitor-watchman.sample
.git/hooks/post-update.sample
.git/hooks/pre-applypatch.sample
.git/hooks/pre-commit.sample
.git/hooks/pre-merge-commit.sample
.git/hooks/pre-push.sample
.git/hooks/pre-rebase.sample
.git/hooks/pre-receive.sample
.git/hooks/prepare-commit-msg.sample
.git/hooks/update.sample
mei@4144e8c22fff:~/git$ find .git/hooks/*|wc -l
12
```

可以看到，有12个钩子示例文件。



关于钩子示例你需要知道的一些东西：

- 模板钩子可能不是你确定想要的。你可以阅读、修改、学习它们，但是你很少会想使用它们。
- 尽管钩子是默认创建的，但它们初始时都是禁用的。新版本的Git中有以`.sample`后缀命名的可执行钩子。
- 为了启用示例钩子，必须移除文件名中的`.sample`后缀，而且要适当设置它的可执行位权限。

### 2.2 创建第一个钩子

如我们在提交本文档时，gitee会返回一个带彩色输出的文本"remote: Powered by GITEE.COM [GNK-6.3]"：


我们看看能不能添加类似的钩子脚本输出该文本。

如在我们的测试存储库的`hooks`目录下新建一个`post-receive`的脚本：

```sh
[root@hellogitlab hooks]# chmod u+x post-receive
[root@hellogitlab hooks]# ls -lah post-receive
-rwxr--r-- 1 git git 88 Mar 19 00:00 post-receive
[root@hellogitlab hooks]# cat post-receive
#!/bin/bash
echo -e "Powered by \033[1;33mGITEE.COM\033[0m [\033[1;35mGNK-6.3\033[0m]"

[root@hellogitlab hooks]#
```

然后，在本地客户端进行检出，并尝试提交：


可以看到，提交成功，并且显示了和码云一模一样的输出！说明我们的`post-receive`脚本生效了。

我们改一下脚本，改成我们自己的：

```sh
[root@hellogitlab hooks]# cat post-receive
#!/bin/bash
echo -e "Powered by \033[1;33mHelloGitlab.com\033[0m [\033[1;35m^_^\033[0m]"

[root@hellogitlab hooks]# sh post-receive
Powered by HelloGitlab.com [^_^]
[root@hellogitlab hooks]#
```

然后再尝试提交，可以看到已经变成我们自己设计的返回语句了：






## 3. 可用的钩子

- 随着Git的进化，越来越多的新钩子被启用。可以使用`git help hooks`来查看当前版本的Git中可用的钩子。

```sh
$ git help hooks|awk NF
GITHOOKS(5)                        Git Manual                        GITHOOKS(5)
NAME
       githooks - Hooks used by Git
SYNOPSIS
       $GIT_DIR/hooks/* (or `git config core.hooksPath`/*)
DESCRIPTION
       Hooks are programs you can place in a hooks directory to trigger actions
       at certain points in git’s execution. Hooks that don’t have the
       executable bit set are ignored.
       By default the hooks directory is $GIT_DIR/hooks, but that can be changed
       via the core.hooksPath configuration variable (see git-config(1)).
       Before Git invokes a hook, it changes its working directory to either
       $GIT_DIR in a bare repository or the root of the working tree in a
       non-bare repository. An exception are hooks triggered during a push
       (pre-receive, update, post-receive, post-update, push-to-checkout) which
       are always executed in $GIT_DIR.
       Hooks can get their arguments via the environment, command-line
       arguments, and stdin. See the documentation for each hook below for
       details.
       git init may copy hooks to the new repository, depending on its
       configuration. See the "TEMPLATE DIRECTORY" section in git-init(1) for
       details. When the rest of this document refers to "default hooks" it’s
       talking about the default template shipped with Git.
       The currently supported hooks are described below.
HOOKS
   applypatch-msg
       This hook is invoked by git-am(1). It takes a single parameter, the name
       of the file that holds the proposed commit log message. Exiting with a
       non-zero status causes git am to abort before applying the patch.
       The hook is allowed to edit the message file in place, and can be used to
       normalize the message into some project standard format. It can also be
       used to refuse the commit after inspecting the message file.
       The default applypatch-msg hook, when enabled, runs the commit-msg hook,
       if the latter is enabled.
   pre-applypatch
       This hook is invoked by git-am(1). It takes no parameter, and is invoked
       after the patch is applied, but before a commit is made.
       If it exits with non-zero status, then the working tree will not be
       committed after applying the patch.
       It can be used to inspect the current working tree and refuse to make a
       commit if it does not pass certain test.
       The default pre-applypatch hook, when enabled, runs the pre-commit hook,
       if the latter is enabled.
   post-applypatch
       This hook is invoked by git-am(1). It takes no parameter, and is invoked
       after the patch is applied and a commit is made.
       This hook is meant primarily for notification, and cannot affect the
       outcome of git am.
   pre-commit
       This hook is invoked by git-commit(1), and can be bypassed with the
       --no-verify option. It takes no parameters, and is invoked before
       obtaining the proposed commit log message and making a commit. Exiting
       with a non-zero status from this script causes the git commit command to
       abort before creating a commit.
       The default pre-commit hook, when enabled, catches introduction of lines
       with trailing whitespaces and aborts the commit when such a line is
       found.
       All the git commit hooks are invoked with the environment variable
       GIT_EDITOR=: if the command will not bring up an editor to modify the
       commit message.
       The default pre-commit hook, when enabled—and with the
       hooks.allownonascii config option unset or set to false—prevents the use
       of non-ASCII filenames.
   pre-merge-commit
       This hook is invoked by git-merge(1), and can be bypassed with the
       --no-verify option. It takes no parameters, and is invoked after the
       merge has been carried out successfully and before obtaining the proposed
       commit log message to make a commit. Exiting with a non-zero status from
       this script causes the git merge command to abort before creating a
       commit.
       The default pre-merge-commit hook, when enabled, runs the pre-commit
       hook, if the latter is enabled.
       This hook is invoked with the environment variable GIT_EDITOR=: if the
       command will not bring up an editor to modify the commit message.
       If the merge cannot be carried out automatically, the conflicts need to
       be resolved and the result committed separately (see git-merge(1)). At
       that point, this hook will not be executed, but the pre-commit hook will,
       if it is enabled.
   prepare-commit-msg
       This hook is invoked by git-commit(1) right after preparing the default
       log message, and before the editor is started.
       It takes one to three parameters. The first is the name of the file that
       contains the commit log message. The second is the source of the commit
       message, and can be: message (if a -m or -F option was given); template
       (if a -t option was given or the configuration option commit.template is
       set); merge (if the commit is a merge or a .git/MERGE_MSG file exists);
       squash (if a .git/SQUASH_MSG file exists); or commit, followed by a
       commit SHA-1 (if a -c, -C or --amend option was given).
       If the exit status is non-zero, git commit will abort.
       The purpose of the hook is to edit the message file in place, and it is
       not suppressed by the --no-verify option. A non-zero exit means a failure
       of the hook and aborts the commit. It should not be used as replacement
       for pre-commit hook.
       The sample prepare-commit-msg hook that comes with Git removes the help
       message found in the commented portion of the commit template.
   commit-msg
       This hook is invoked by git-commit(1) and git-merge(1), and can be
       bypassed with the --no-verify option. It takes a single parameter, the
       name of the file that holds the proposed commit log message. Exiting with
       a non-zero status causes the command to abort.
       The hook is allowed to edit the message file in place, and can be used to
       normalize the message into some project standard format. It can also be
       used to refuse the commit after inspecting the message file.
       The default commit-msg hook, when enabled, detects duplicate
       "Signed-off-by" lines, and aborts the commit if one is found.
   post-commit
       This hook is invoked by git-commit(1). It takes no parameters, and is
       invoked after a commit is made.
       This hook is meant primarily for notification, and cannot affect the
       outcome of git commit.
   pre-rebase
       This hook is called by git-rebase(1) and can be used to prevent a branch
       from getting rebased. The hook may be called with one or two parameters.
       The first parameter is the upstream from which the series was forked. The
       second parameter is the branch being rebased, and is not set when
       rebasing the current branch.
   post-checkout
       This hook is invoked when a git-checkout(1) or git-switch(1) is run after
       having updated the worktree. The hook is given three parameters: the ref
       of the previous HEAD, the ref of the new HEAD (which may or may not have
       changed), and a flag indicating whether the checkout was a branch
       checkout (changing branches, flag=1) or a file checkout (retrieving a
       file from the index, flag=0). This hook cannot affect the outcome of git
       switch or git checkout.
       It is also run after git-clone(1), unless the --no-checkout (-n) option
       is used. The first parameter given to the hook is the null-ref, the
       second the ref of the new HEAD and the flag is always 1. Likewise for git
       worktree add unless --no-checkout is used.
       This hook can be used to perform repository validity checks, auto-display
       differences from the previous HEAD if different, or set working dir
       metadata properties.
   post-merge
       This hook is invoked by git-merge(1), which happens when a git pull is
       done on a local repository. The hook takes a single parameter, a status
       flag specifying whether or not the merge being done was a squash merge.
       This hook cannot affect the outcome of git merge and is not executed, if
       the merge failed due to conflicts.
       This hook can be used in conjunction with a corresponding pre-commit hook
       to save and restore any form of metadata associated with the working tree
       (e.g.: permissions/ownership, ACLS, etc). See
       contrib/hooks/setgitperms.perl for an example of how to do this.
   pre-push
       This hook is called by git-push(1) and can be used to prevent a push from
       taking place. The hook is called with two parameters which provide the
       name and location of the destination remote, if a named remote is not
       being used both values will be the same.
       Information about what is to be pushed is provided on the hook’s standard
       input with lines of the form:
           <local ref> SP <local sha1> SP <remote ref> SP <remote sha1> LF
       For instance, if the command git push origin master:foreign were run the
       hook would receive a line like the following:
           refs/heads/master 67890 refs/heads/foreign 12345
       although the full, 40-character SHA-1s would be supplied. If the foreign
       ref does not yet exist the <remote SHA-1> will be 40 0. If a ref is to be
       deleted, the <local ref> will be supplied as (delete) and the <local
       SHA-1> will be 40 0. If the local commit was specified by something other
       than a name which could be expanded (such as HEAD~, or a SHA-1) it will
       be supplied as it was originally given.
       If this hook exits with a non-zero status, git push will abort without
       pushing anything. Information about why the push is rejected may be sent
       to the user by writing to standard error.
   pre-receive
       This hook is invoked by git-receive-pack(1) when it reacts to git push
       and updates reference(s) in its repository. Just before starting to
       update refs on the remote repository, the pre-receive hook is invoked.
       Its exit status determines the success or failure of the update.
       This hook executes once for the receive operation. It takes no arguments,
       but for each ref to be updated it receives on standard input a line of
       the format:
           <old-value> SP <new-value> SP <ref-name> LF
       where <old-value> is the old object name stored in the ref, <new-value>
       is the new object name to be stored in the ref and <ref-name> is the full
       name of the ref. When creating a new ref, <old-value> is 40 0.
       If the hook exits with non-zero status, none of the refs will be updated.
       If the hook exits with zero, updating of individual refs can still be
       prevented by the update hook.
       Both standard output and standard error output are forwarded to git
       send-pack on the other end, so you can simply echo messages for the user.
       The number of push options given on the command line of git push
       --push-option=... can be read from the environment variable
       GIT_PUSH_OPTION_COUNT, and the options themselves are found in
       GIT_PUSH_OPTION_0, GIT_PUSH_OPTION_1,... If it is negotiated to not use
       the push options phase, the environment variables will not be set. If the
       client selects to use push options, but doesn’t transmit any, the count
       variable will be set to zero, GIT_PUSH_OPTION_COUNT=0.
       See the section on "Quarantine Environment" in git-receive-pack(1) for
       some caveats.
   update
       This hook is invoked by git-receive-pack(1) when it reacts to git push
       and updates reference(s) in its repository. Just before updating the ref
       on the remote repository, the update hook is invoked. Its exit status
       determines the success or failure of the ref update.
       The hook executes once for each ref to be updated, and takes three
       parameters:
       •   the name of the ref being updated,
       •   the old object name stored in the ref,
       •   and the new object name to be stored in the ref.
       A zero exit from the update hook allows the ref to be updated. Exiting
       with a non-zero status prevents git receive-pack from updating that ref.
       This hook can be used to prevent forced update on certain refs by making
       sure that the object name is a commit object that is a descendant of the
       commit object named by the old object name. That is, to enforce a
       "fast-forward only" policy.
       It could also be used to log the old..new status. However, it does not
       know the entire set of branches, so it would end up firing one e-mail per
       ref when used naively, though. The post-receive hook is more suited to
       that.
       In an environment that restricts the users' access only to git commands
       over the wire, this hook can be used to implement access control without
       relying on filesystem ownership and group membership. See git-shell(1)
       for how you might use the login shell to restrict the user’s access to
       only git commands.
       Both standard output and standard error output are forwarded to git
       send-pack on the other end, so you can simply echo messages for the user.
       The default update hook, when enabled—and with hooks.allowunannotated
       config option unset or set to false—prevents unannotated tags to be
       pushed.
   post-receive
       This hook is invoked by git-receive-pack(1) when it reacts to git push
       and updates reference(s) in its repository. It executes on the remote
       repository once after all the refs have been updated.
       This hook executes once for the receive operation. It takes no arguments,
       but gets the same information as the pre-receive hook does on its
       standard input.
       This hook does not affect the outcome of git receive-pack, as it is
       called after the real work is done.
       This supersedes the post-update hook in that it gets both old and new
       values of all the refs in addition to their names.
       Both standard output and standard error output are forwarded to git
       send-pack on the other end, so you can simply echo messages for the user.
       The default post-receive hook is empty, but there is a sample script
       post-receive-email provided in the contrib/hooks directory in Git
       distribution, which implements sending commit emails.
       The number of push options given on the command line of git push
       --push-option=... can be read from the environment variable
       GIT_PUSH_OPTION_COUNT, and the options themselves are found in
       GIT_PUSH_OPTION_0, GIT_PUSH_OPTION_1,... If it is negotiated to not use
       the push options phase, the environment variables will not be set. If the
       client selects to use push options, but doesn’t transmit any, the count
       variable will be set to zero, GIT_PUSH_OPTION_COUNT=0.
   post-update
       This hook is invoked by git-receive-pack(1) when it reacts to git push
       and updates reference(s) in its repository. It executes on the remote
       repository once after all the refs have been updated.
       It takes a variable number of parameters, each of which is the name of
       ref that was actually updated.
       This hook is meant primarily for notification, and cannot affect the
       outcome of git receive-pack.
       The post-update hook can tell what are the heads that were pushed, but it
       does not know what their original and updated values are, so it is a poor
       place to do log old..new. The post-receive hook does get both original
       and updated values of the refs. You might consider it instead if you need
       them.
       When enabled, the default post-update hook runs git update-server-info to
       keep the information used by dumb transports (e.g., HTTP) up to date. If
       you are publishing a Git repository that is accessible via HTTP, you
       should probably enable this hook.
       Both standard output and standard error output are forwarded to git
       send-pack on the other end, so you can simply echo messages for the user.
   push-to-checkout
       This hook is invoked by git-receive-pack(1) when it reacts to git push
       and updates reference(s) in its repository, and when the push tries to
       update the branch that is currently checked out and the
       receive.denyCurrentBranch configuration variable is set to updateInstead.
       Such a push by default is refused if the working tree and the index of
       the remote repository has any difference from the currently checked out
       commit; when both the working tree and the index match the current
       commit, they are updated to match the newly pushed tip of the branch.
       This hook is to be used to override the default behaviour.
       The hook receives the commit with which the tip of the current branch is
       going to be updated. It can exit with a non-zero status to refuse the
       push (when it does so, it must not modify the index or the working tree).
       Or it can make any necessary changes to the working tree and to the index
       to bring them to the desired state when the tip of the current branch is
       updated to the new commit, and exit with a zero status.
       For example, the hook can simply run git read-tree -u -m HEAD "$1" in
       order to emulate git fetch that is run in the reverse direction with git
       push, as the two-tree form of git read-tree -u -m is essentially the same
       as git switch or git checkout that switches branches while keeping the
       local changes in the working tree that do not interfere with the
       difference between the branches.
   pre-auto-gc
       This hook is invoked by git gc --auto (see git-gc(1)). It takes no
       parameter, and exiting with non-zero status from this script causes the
       git gc --auto to abort.
   post-rewrite
       This hook is invoked by commands that rewrite commits (git-commit(1) when
       called with --amend and git-rebase(1); however, full-history (re)writing
       tools like git-fast-import(1) or git-filter-repo[1] typically do not call
       it!). Its first argument denotes the command it was invoked by: currently
       one of amend or rebase. Further command-dependent arguments may be passed
       in the future.
       The hook receives a list of the rewritten commits on stdin, in the format
           <old-sha1> SP <new-sha1> [ SP <extra-info> ] LF
       The extra-info is again command-dependent. If it is empty, the preceding
       SP is also omitted. Currently, no commands pass any extra-info.
       The hook always runs after the automatic note copying (see
       "notes.rewrite.<command>" in git-config(1)) has happened, and thus has
       access to these notes.
       The following command-specific comments apply:
       rebase
           For the squash and fixup operation, all commits that were squashed
           are listed as being rewritten to the squashed commit. This means that
           there will be several lines sharing the same new-sha1.
           The commits are guaranteed to be listed in the order that they were
           processed by rebase.
   sendemail-validate
       This hook is invoked by git-send-email(1). It takes a single parameter,
       the name of the file that holds the e-mail to be sent. Exiting with a
       non-zero status causes git send-email to abort before sending any
       e-mails.
   fsmonitor-watchman
       This hook is invoked when the configuration option core.fsmonitor is set
       to .git/hooks/fsmonitor-watchman. It takes two arguments, a version
       (currently 1) and the time in elapsed nanoseconds since midnight, January
       1, 1970.
       The hook should output to stdout the list of all files in the working
       directory that may have changed since the requested time. The logic
       should be inclusive so that it does not miss any potential changes. The
       paths should be relative to the root of the working directory and be
       separated by a single NUL.
       It is OK to include files which have not actually changed. All changes
       including newly-created and deleted files should be included. When files
       are renamed, both the old and the new name should be included.
       Git will limit what files it checks for changes as well as which
       directories are checked for untracked files based on the path names
       given.
       An optimized way to tell git "all files have changed" is to return the
       filename /.
       The exit status determines whether git will use the data from the hook to
       limit its search. On error, it will fall back to verifying all files and
       folders.
   p4-pre-submit
       This hook is invoked by git-p4 submit. It takes no parameters and nothing
       from standard input. Exiting with non-zero status from this script
       prevent git-p4 submit from launching. Run git-p4 submit --help for
       details.
   post-index-change
       This hook is invoked when the index is written in read-cache.c
       do_write_locked_index.
       The first parameter passed to the hook is the indicator for the working
       directory being updated. "1" meaning working directory was updated or "0"
       when the working directory was not updated.
       The second parameter passed to the hook is the indicator for whether or
       not the index was updated and the skip-worktree bit could have changed.
       "1" meaning skip-worktree bits could have been updated and "0" meaning
       they were not.
       Only one parameter should be set to "1" when the hook runs. The hook
       running passing "1", "1" should not be possible.
GIT
       Part of the git(1) suite
NOTES
        1. git-filter-repo
           https://github.com/newren/git-filter-repo
Git 2.24.0                         11/04/2019                        GITHOOKS(5)
$
```



### 3.1与提交相关的钩子

参考：[自定义 Git - Git 钩子](https://www.git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)

提交钩子的处理过程：


- `pre-commit`钩子在键入提交信息前运行。 它用于检查即将提交的快照，例如，检查是否有所遗漏，确保测试运行，以及核查代码。 如果该钩子以非零值退出，Git 将放弃此次提交，不过你可以用 `git commit --no-verify` 来绕过这个环节。 你可以利用该钩子，来检查代码风格是否一致（运行类似 `lint` 的程序）、尾随空白字符是否存在（自带的钩子就是这么做的），或新方法的文档是否适当。
- `prepare-commit-msg` 钩子在启动提交信息编辑器之前，默认信息被创建之后运行。 它允许你编辑提交者所看到的默认信息。 该钩子接收一些选项：存有当前提交信息的文件的路径、提交类型和修补提交的提交的 SHA-1 校验。 它对一般的提交来说并没有什么用；然而对那些会自动产生默认信息的提交，如提交信息模板、合并提交、压缩提交和修订提交等非常实用。 你可以结合提交模板来使用它，动态地插入信息。
- `commit-msg` 钩子接收一个参数，此参数即上文提到的，存有当前提交信息的临时文件的路径。 如果该钩子脚本以非零值退出，Git 将放弃提交，因此，可以用来在提交通过前验证项目状态或提交信息。
- `post-commit` 钩子在整个提交过程完成后运行。 它不接收任何参数，但你可以很容易地通过运行 `git log -1 HEAD` 来获得最后一次的提交信息。 该钩子一般用于通知之类的事情。

### 3.2 与补丁相关的钩子

当执行`git am`时应用补丁时相关的钩子：`applypatch-msg`、`pre-applypatch`、`post-applypatch`。

### 3.3 与推送相关的钩子

提交钩子的处理过程：


当执行`git push`时，Git的接收端（receiving end）可以执行一些钩子。此时执行的钩子也可以称为服务器端钩子。

- `pre-receive`，处理来自客户端的推送操作时，最先被调用的脚本是 `pre-receive`。 它从标准输入获取一系列被推送的引用。如果它以非零值退出，所有的推送内容都不会被接受。 你可以用这个钩子阻止对引用进行非快进（non-fast-forward）的更新，或者对该推送所修改的所有引用和文件进行访问控制。

- `update`，`update` 脚本和 `pre-receive` 脚本十分类似，不同之处在于它会为每一个准备更新的分支各运行一次。 假如推送者同时向多个分支推送内容，`pre-receive` 只运行一次，相比之下 `update` 则会为每一个被推送的分支各运行一次。 它不会从标准输入读取内容，而是接受三个参数：引用的名字（分支），推送前的引用指向的内容的 SHA-1 值，以及用户准备推送的内容的 SHA-1 值。 如果 update 脚本以非零值退出，只有相应的那一个引用会被拒绝；其余的依然会被更新。
- `post-receive`， `post-receive`钩子在整个过程完结以后运行，可以用来更新其他系统服务或者通知用户。 它接受与 `pre-receive` 相同的标准输入数据。 它的用途包括给某个邮件列表发信，通知持续集成（continous integration）的服务器， 或者更新问题追踪系统（ticket-tracking system） —— 甚至可以通过分析提交信息来决定某个问题（ticket）是否应该被开启，修改或者关闭。 该脚本无法终止推送进程，不过客户端在它结束运行之前将保持连接状态， 所以如果你想做其他操作需谨慎使用它，因为它将耗费你很长的一段时间。



## 4. 综合使用

本节我们来测试一下常用钩子的使用。

我们在`test.git`仓库下面做一些测试验证操作。

```sh
[mzh@MacBookPro ~ ]$ cd /tmp/test
[mzh@MacBookPro test (master ✗)]$ git remote -v
origin	ssh://git@hellogitlab.com:10000/git-server/test.git (fetch)
origin	ssh://git@hellogitlab.com:10000/git-server/test.git (push)
[mzh@MacBookPro test (master ✗)]$ find .git/hooks
.git/hooks
.git/hooks/commit-msg.sample
.git/hooks/pre-rebase.sample
.git/hooks/pre-commit.sample
.git/hooks/applypatch-msg.sample
.git/hooks/fsmonitor-watchman.sample
.git/hooks/pre-receive.sample
.git/hooks/prepare-commit-msg.sample
.git/hooks/post-update.sample
.git/hooks/pre-merge-commit.sample
.git/hooks/pre-applypatch.sample
.git/hooks/pre-push.sample
.git/hooks/update.sample
[mzh@MacBookPro test (master ✗)]$
```

可以看到，`.git/hooks`目录下面有很多示例钩子文件。



### 4.1 `pre-commit`的使用

我们先看`pre-commit`钩子，将先模板文件复制一下：

```sh
[mzh@MacBookPro test (master ✗)]$ ls -lh .git/hooks
total 104
-rwxr-xr-x  1 mzh  wheel   478B  3 19 00:03 applypatch-msg.sample
-rwxr-xr-x  1 mzh  wheel   896B  3 19 00:03 commit-msg.sample
-rwxr-xr-x  1 mzh  wheel   3.2K  3 19 00:03 fsmonitor-watchman.sample
-rwxr-xr-x  1 mzh  wheel   189B  3 19 00:03 post-update.sample
-rwxr-xr-x  1 mzh  wheel   424B  3 19 00:03 pre-applypatch.sample
-rwxr-xr-x  1 mzh  wheel   1.6K  3 19 00:03 pre-commit.sample
-rwxr-xr-x  1 mzh  wheel   416B  3 19 00:03 pre-merge-commit.sample
-rwxr-xr-x  1 mzh  wheel   1.3K  3 19 00:03 pre-push.sample
-rwxr-xr-x  1 mzh  wheel   4.8K  3 19 00:03 pre-rebase.sample
-rwxr-xr-x  1 mzh  wheel   544B  3 19 00:03 pre-receive.sample
-rwxr-xr-x  1 mzh  wheel   1.5K  3 19 00:03 prepare-commit-msg.sample
-rwxr-xr-x  1 mzh  wheel   3.5K  3 19 00:03 update.sample
[mzh@MacBookPro test (master ✗)]$ cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
[mzh@MacBookPro test (master ✗)]$ ls -lah .git/hooks/pre-commit
-rwxr-xr-x  1 mzh  wheel   1.6K  3 20 11:18 .git/hooks/pre-commit
```

查看该脚本的内容：

```sh
[mzh@MacBookPro test (master ✗)]$ cat .git/hooks/pre-commit
#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=$(git hash-object -t tree /dev/null)
fi

# If you want to allow non-ASCII filenames set this variable to true.
allownonascii=$(git config --bool hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ASCII filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
	# Note that the use of brackets around a tr range is ok here, (it's
	# even required, for portability to Solaris 10's /usr/bin/tr), since
	# the square bracket bytes happen to fall in the designated range.
	test $(git diff --cached --name-only --diff-filter=A -z $against |
	  LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0
then
	cat <<\EOF
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
EOF
	exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --
[mzh@MacBookPro test (master ✗)]$
```

该脚本的作用是跨平台项目倾向于避免非ASCII文件名，对文件名进行检查！

我们来测试一下。创建一个包含中文名的文件，并尝试提交：

```sh
[mzh@MacBookPro test (master)]$ ls -l
total 8
-rw-r--r--  1 mzh  wheel  53  3 19 00:17 data.txt

# 创建一个非ASCII的文件，钩子.txt
[mzh@MacBookPro test (master)]$ echo '测试钩子' > 钩子.txt
[mzh@MacBookPro test (master ✗)]$ ls -l
total 16
-rw-r--r--  1 mzh  wheel  53  3 19 00:17 data.txt
-rw-r--r--  1 mzh  wheel  13  3 20 11:29 钩子.txt

# 查看状态
# 如果你查看状态时，中文文件名乱码请设置`git config --global core.quotepath false`,禁用Git对文件名进行转义
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	钩子.txt

nothing added to commit but untracked files present (use "git add" to track)
[mzh@MacBookPro test (master ✗)]$
```

现在尝试创建commit信息。

```sh
# 将文件添加到暂存区
[mzh@MacBookPro test (master ✗)]$ git add .

# 尝试打开commit编辑器，可以看到抛出异常！！
[mzh@MacBookPro test (master ✗)]$ git commit
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
  
# 直接通过`-m`参数添加提交信息，同样抛出异常，异常退出！！
[mzh@MacBookPro test (master ✗)]$ git commit -m"add chinese file"
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
[mzh@MacBookPro test (master ✗)]$ echo $?
1
[mzh@MacBookPro test (master ✗)]$
```

该异常提示信息翻译过来就是：

> 错误：尝试添加非ASCII文件名。 
>
> 如果您想与其他平台上的人合作，这可能会导致问题。 
>
> 若想便于跨平台处理，建议重命名该文件。 
>
> 如果您知道自己在做什么，可以使用以下操作：    
>
>   `git config hooks.allownonascii true`

现在我们有两种处理方案：

- 设置`hooks.allownonascii`配置的值为`true`，即允许非ASCII文件名。
- 重命名文件。



当我们设置允许非ASCII文件名时：

```sh
[mzh@MacBookPro test (master ✗)]$ git config hooks.allownonascii true
[mzh@MacBookPro test (master ✗)]$ git commit
Aborting commit due to empty commit message.
[mzh@MacBookPro test (master ✗)]$
```

`pre-commit`钩子验证通过，并没有抛出异常！



为了便于跨平台文件共享，我们禁止非ASCII文件名，关闭开关，并重命名文件：

```sh
# 禁止非ASCII文件名
[mzh@MacBookPro test (master ✗)]$ git config hooks.allownonascii false
[mzh@MacBookPro test (master ✗)]$ git config hooks.allownonascii
false
[mzh@MacBookPro test (master ✗)]$ ls
data.txt   钩子.txt

# 重命名文件
[mzh@MacBookPro test (master ✗)]$ mv 钩子.txt hooks.txt

# 查看状态
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   钩子.txt

Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	deleted:    钩子.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	hooks.txt

# 将文件追加到暂存区
[mzh@MacBookPro test (master ✗)]$ git add .

# 再次查看状态
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   hooks.txt


# 尝试添加提交信息，可以看到，并没有抛出异常，说明`pre-commit`检查通过！！
[mzh@MacBookPro test (master ✗)]$ git commit
Aborting commit due to empty commit message.
[mzh@MacBookPro test (master ✗)]$
```



### 4.2 `prepare-commit-msg`的使用

测试本钩子前，将本地存储库还原：

```sh
[mzh@MacBookPro test (master ✗)]$ git reset --hard HEAD
HEAD is now at 7783b43 test git post-receice
```

复制钩子模板：

```sh
[mzh@MacBookPro test (master)]$ cp .git/hooks/prepare-commit-msg.sample .git/hooks/prepare-commit-msg
[mzh@MacBookPro test (master)]$ ls -l .git/hooks/prepare-commit-msg
-rwxr-xr-x  1 mzh  wheel  1492  3 20 13:15 .git/hooks/prepare-commit-msg
```

查看该脚本的内容：

```sh
[mzh@MacBookPro test (master)]$ cat .git/hooks/prepare-commit-msg
#!/bin/sh
#
# An example hook script to prepare the commit log message.
# Called by "git commit" with the name of the file that has the
# commit message, followed by the description of the commit
# message's source.  The hook's purpose is to edit the commit
# message file.  If the hook fails with a non-zero status,
# the commit is aborted.
#
# To enable this hook, rename this file to "prepare-commit-msg".

# This hook includes three examples. The first one removes the
# "# Please enter the commit message..." help message.
#
# The second includes the output of "git diff --name-status -r"
# into the message, just before the "git status" output.  It is
# commented because it doesn't cope with --amend or with squashed
# commits.
#
# The third example adds a Signed-off-by line to the message, that can
# still be edited.  This is rarely a good idea.

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
SHA1=$3

/usr/bin/perl -i.bak -ne 'print unless(m/^. Please enter the commit message/..m/^#$/)' "$COMMIT_MSG_FILE"

# case "$COMMIT_SOURCE,$SHA1" in
#  ,|template,)
#    /usr/bin/perl -i.bak -pe '
#       print "\n" . `git diff --cached --name-status -r`
# 	 if /^#/ && $first++ == 0' "$COMMIT_MSG_FILE" ;;
#  *) ;;
# esac

# SOB=$(git var GIT_COMMITTER_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
# git interpret-trailers --in-place --trailer "$SOB" "$COMMIT_MSG_FILE"
# if test -z "$COMMIT_SOURCE"
# then
#   /usr/bin/perl -i.bak -pe 'print "\n" if !$first_line++' "$COMMIT_MSG_FILE"
# fi
[mzh@MacBookPro test (master)]$
```

此时，可以参考 [Git commit提交模板](./git_commit_template.md) 设置一下你的提交模板。

创建修改：

```sh
# 创建修改
[mzh@MacBookPro test (master)]$ echo "test prepare-commit-msg" >> data.txt

# 追加到暂存区
[mzh@MacBookPro test (master ✗)]$ git add .

# 打开提交信息编辑器
[mzh@MacBookPro test (master ✗)]$ git commit
```


此时查看35-38行的位置，可以看到没有`Please enter the commit message`之类的信息，此时，重新打开一个终端，并切换到`.git`目录下：

```sh
[mzh@MacBookPro .git (master)]$ ls -lah COMMIT_EDITMSG*
-rw-r--r--  1 mzh  wheel   1.6K  3 20 14:48 COMMIT_EDITMSG
-rw-r--r--  1 mzh  wheel   1.7K  3 20 14:48 COMMIT_EDITMSG.bak
[mzh@MacBookPro .git (master)]$ diff COMMIT_EDITMSG COMMIT_EDITMSG.bak
36a37,39
> # Please enter the commit message for your changes. Lines starting
> # with '#' will be ignored, and an empty message aborts the commit.
> #
[mzh@MacBookPro .git (master)]$
```

可以看到，`prepare-commit-msg`钩子脚本起作用了，生成了备份的`COMMIT_EDITMSG.bak`文件。



### 4.3 `commit-msg`的使用

复制钩子模板：

```sh
[mzh@MacBookPro test (master)]$ cp .git/hooks/commit-msg.sample .git/hooks/commit-msg
[mzh@MacBookPro test (master)]$ cat .git/hooks/commit-msg
#!/bin/sh
#
# An example hook script to check the commit log message.
# Called by "git commit" with one argument, the name of the file
# that has the commit message.  The hook should exit with non-zero
# status after issuing an appropriate message if it wants to stop the
# commit.  The hook is allowed to edit the commit message file.
#
# To enable this hook, rename this file to "commit-msg".

# Uncomment the below to add a Signed-off-by line to the message.
# Doing this in a hook is a bad idea in general, but the prepare-commit-msg
# hook is more suited to it.
#
# SOB=$(git var GIT_AUTHOR_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
# grep -qs "^$SOB" "$1" || echo "$SOB" >> "$1"

# This example catches duplicate Signed-off-by lines.

test "" = "$(grep '^Signed-off-by: ' "$1" |
	 sort | uniq -c | sed -e '/^[ 	]*1[ 	]/d')" || {
	echo >&2 Error: Duplicate Signed-off-by lines.
	exit 1
}
[mzh@MacBookPro test (master)]$
```

此时，可以参考 [什么是Signed-off-by](./Signed-off-by.md) 了解一下签名行。



示例钩子脚本用于获取重复的签名行。我们来测试一下。



做一些修改，并尝试创建提交信息:

```sh
[mzh@MacBookPro test (master)]$ echo 'test commit-msg' >> data.txt && git add .
[mzh@MacBookPro test (master ✗)]$ git status
On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   data.txt

[mzh@MacBookPro test (master ✗)]$ git commit -s
```

此时，打开了提交信息编辑器，可以看到已经有了一个签名行：


此时，我们复制一下签名行，将日志设置为如下所示的内容：

```sh
docs(Git): use commit-msg

use commit-msg to catches duplicate Signed-off-by lines.

Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
Signed-off-by: Zhaohui Mei too <mzh.whut@gmail.com>
```

此时，并没有被拦截：

```sh
[mzh@MacBookPro test (master ✗)]$ git commit -s
master 9e14bcb] docs(Git): use commit-msg
 Date: Sun Mar 20 16:26:36 2022 +0800
 1 file changed, 1 insertion(+)
[mzh@MacBookPro test (master)]$ git log -n 1|cat
commit 9e14bcb3f7f40370620d1e03106ab46b0ed2c745
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 20 16:26:36 2022 +0800

    docs(Git): use commit-msg

    use commit-msg to catches duplicate Signed-off-by lines.

    Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
    Signed-off-by: Zhaohui Mei too <mzh.whut@gmail.com>
[mzh@MacBookPro test (master)]$
```

原因是，该脚本支持多个签名行，只要签名行的信息不完全一致就会放行。

现在我们将签名行改成一模一样：

```sh
docs(Git): use commit-msg

use commit-msg to catches duplicate Signed-off-by lines.

Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
```


此时保存，会提示异常：

```sh
[mzh@MacBookPro test (master)]$ git commit --amend
Error: Duplicate Signed-off-by lines.
[mzh@MacBookPro test (master)]$ echo $?
1
[mzh@MacBookPro test (master)]$
```

然后再次查看一下日志信息：

```sh
[mzh@MacBookPro test (master)]$ git --no-pager log -n 1
commit 9e14bcb3f7f40370620d1e03106ab46b0ed2c745 (HEAD -> master)
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 20 16:26:36 2022 +0800

    docs(Git): use commit-msg

    use commit-msg to catches duplicate Signed-off-by lines.

    Signed-off-by: Zhaohui Mei <mzh.whut@gmail.com>
    Signed-off-by: Zhaohui Mei too <mzh.whut@gmail.com>
[mzh@MacBookPro test (master)]$
```

可以看到，日志信息没有修改成功。

说明`commit-msg`钩子脚本正常生效了。



### 4.4 `post-commit`的使用

默认没有创建`post-commit.sample`文件，可以通过`git help hooks`查看`post-commit`的说明：

```sh
post-commit
       This hook is invoked by git-commit(1). It takes no parameters, and is invoked after a commit is made.

       This hook is meant primarily for notification, and cannot affect the outcome of git commit.
```

即`post-commit`对`git commit`的结果无影响，主要用于通知。

为了便于测试`pre-commit`、`prepare-commit-msg`、`commit-msg`和`post-commit`四个钩子的执行顺序，我们修改一下`pre-commit`、`prepare-commit-msg`、`commit-msg`三个钩子，并创建`.git/hooks/post-commit`文件，

使用`vim`编辑后，查看这几个钩子的开头两行：

```sh
[mzh@MacBookPro test (master)]$ head -n 2 .git/hooks/pre-commit
#!/bin/sh
echo 1>&2 'Running in pre-commit hook'
[mzh@MacBookPro test (master)]$ head -n 2 .git/hooks/prepare-commit-msg
#!/bin/sh
echo 1>&2 'Running in prepare-commit-msg hook'
[mzh@MacBookPro test (master)]$ head -n 2 .git/hooks/commit-msg
#!/bin/sh
echo 1>&2 'Running in commit-msg hook'
[mzh@MacBookPro test (master)]$ head -n 2 .git/hooks/post-commit
#!/bin/bash
echo 1>&2 'Running in post-commit hook'
[mzh@MacBookPro test (master)]$
```

由于我是直接创建的`post-commit`，并没有给它增加可执行权限：

```sh
[mzh@MacBookPro test (master)]$ ls -lah .git/hooks/post-commit
-rw-r--r--  1 mzh  wheel    52B  3 20 18:17 .git/hooks/post-commit
```



此时创建提交信息时，会提示以下提示信息：

```sh
[mzh@MacBookPro test (master)]$ echo 'Test local hook operation order' >> data.txt && git add .
[mzh@MacBookPro test (master ✗)]$ git commit -m"Test local hook operation order "
Running in pre-commit hook
Running in prepare-commit-msg hook
Running in commit-msg hook
hint: The '.git/hooks/post-commit' hook was ignored because it's not set as executable.
hint: You can disable this warning with `git config advice.ignoredHook false`.
[master ae503e0] Test local hook operation order
 1 file changed, 1 insertion(+)
[mzh@MacBookPro test (master)]$ echo $?
0
```

即由于没有给`post-commit`增加可执行权限，该钩子将会被忽略。

我们将该文件加上可执行权限：

```sh
[mzh@MacBookPro test (master)]$ chmod u+x .git/hooks/post-commit
[mzh@MacBookPro test (master)]$ ls -lah .git/hooks/post-commit
-rwxr--r--  1 mzh  wheel    52B  3 20 18:17 .git/hooks/post-commit
```

然后再尝试修改提交日志信息：

```sh
[mzh@MacBookPro test (master)]$ git commit --amend
Running in pre-commit hook
Running in prepare-commit-msg hook
Running in commit-msg hook
Running in post-commit hook
[master 593b74d] docs(Git): Test local hook operation order.
 Date: Sun Mar 20 18:18:41 2022 +0800
 1 file changed, 1 insertion(+)
[mzh@MacBookPro test (master)]$
```

可以看到，依次执行`pre-commit`、`prepare-commit-msg`、`commit-msg`和`post-commit`钩子。



### 4.5  `pre-receive`的使用



- `pre-receive`是服务器端钩子。

我们来测试一下。

查看服务器端钩子模板：

```sh
[meizhaohui@hellogitlab ~]$ cd /git-server/test.git/
[meizhaohui@hellogitlab test.git]$ find hooks/*
hooks/applypatch-msg.sample
hooks/commit-msg.sample
hooks/fsmonitor-watchman.sample
hooks/post-receive
hooks/post-update.sample
hooks/pre-applypatch.sample
hooks/pre-commit.sample
hooks/pre-merge-commit.sample
hooks/prepare-commit-msg.sample
hooks/pre-push.sample
hooks/pre-rebase.sample
hooks/pre-receive.sample
hooks/update.sample
[meizhaohui@hellogitlab test.git]$ 
```

复制`pre-receive.sample`钩子模板并修改权限：

```sh
[meizhaohui@hellogitlab test.git]$ sudo cp hooks/pre-receive.sample hooks/pre-receive
[meizhaohui@hellogitlab test.git]$ sudo chown git:git hooks/pre-receive
[meizhaohui@hellogitlab test.git]$ ls -lah hooks/pre-receive
-rwxr-xr-x 1 git git 544 Mar 22 22:12 hooks/pre-receive
[meizhaohui@hellogitlab test.git]$ 
```

查看钩子脚本内容：

```sh
[meizhaohui@hellogitlab test.git]$ cat hooks/pre-receive
#!/bin/sh
#
# An example hook script to make use of push options.
# The example simply echoes all push options that start with 'echoback='
# and rejects all pushes when the "reject" push option is used.
#
# To enable this hook, rename this file to "pre-receive".

if test -n "$GIT_PUSH_OPTION_COUNT"
then
        i=0
        while test "$i" -lt "$GIT_PUSH_OPTION_COUNT"
        do
                eval "value=\$GIT_PUSH_OPTION_$i"
                case "$value" in
                echoback=*)
                        echo "echo from the pre-receive-hook: ${value#*=}" >&2
                        ;;
                reject)
                        exit 1
                esac
                i=$((i + 1))
        done
fi
[meizhaohui@hellogitlab test.git]$ 
```

该脚本做的事情是：

- 如果客户端在`git push`时设置了`-o <option>, --push-option=<option>`参数，并且对应的参数值是以`echoback=`开头的话，则会回显`echoback=`后面的值。
- 如果客户端在`git push`时设置了`-o <option>, --push-option=<option>`参数，并且对应的参数值是`reject`的话，则异常退出，此时提交失败。

为了便于测试，我们在`reject`选项异常退出前，增加一行打印语句`echo "echo from the pre-receive-hook: you are rejected" >&2`

我们尝试在本地做一下试验：

```sh
# 设置pushOption配置
[mzh@MacBookPro test (master)]$ git config --add push.pushOption echoback="the first option"
[mzh@MacBookPro test (master)]$ git config --add push.pushOption echoback="the second option"
# 查看配置
[mzh@MacBookPro test (master)]$ git config --list|grep push
push.pushoption=echoback=the first option
push.pushoption=echoback=the second option
```

现在来做一些修改：

```sh
[mzh@MacBookPro test (master)]$ echo 'test pre-receive' >> data.txt && git add .
[mzh@MacBookPro test (master ✗)]$ git commit -m"test pre-receive hook"
Running in pre-commit hook
Running in prepare-commit-msg hook
Running in commit-msg hook
Running in post-commit hook
[master 2ec7a01] test pre-receive hook
 1 file changed, 1 insertion(+)
[mzh@MacBookPro test (master)]$ git push origin master --push-option=reject
fatal: the receiving end does not support push options
[mzh@MacBookPro test (master)]$ fatal: 远端意外挂断了

[mzh@MacBookPro test (master)]$ echo $?
128
```

结果发现，发生致命错误，提示`fatal: the receiving end does not support push options`，即远程不支持`push-option`选项，提交失败。



参考：[the receiving end does not support push options](https://stackoverflow.com/questions/45400553/the-receiving-end-does-not-support-push-options)

在服务器端设置`receive.advertisePushOptions`配置项为`true`:

```sh
[meizhaohui@hellogitlab test.git]$ git --version
git version 2.24.4
[meizhaohui@hellogitlab test.git]$ git config receive.advertisePushOptions
[meizhaohui@hellogitlab test.git]$ sudo git config receive.advertisePushOptions true
[meizhaohui@hellogitlab test.git]$ git config receive.advertisePushOptions
true
[meizhaohui@hellogitlab test.git]$ 
```

然后再在客户端进行`git push`测试：

```sh
[mzh@MacBookPro test (master)]$ git push origin master --push-option=reject
Enumerating objects: 14, done.
Counting objects: 100% (14/14), done.
Delta compression using up to 8 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (12/12), 1.10 KiB | 1.10 MiB/s, done.
Total 12 (delta 3), reused 0 (delta 0)
remote: echo from the pre-receive-hook: you are rejected
To ssh://hellogitlab.com:10000/git-server/test.git
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'ssh://git@hellogitlab.com:10000/git-server/test.git'
[mzh@MacBookPro test (master)]$
```

可以看到，显示了`remote: echo from the pre-receive-hook: you are rejected`，这是`pre-receive`钩子的中返回信息。

说明我们因为增加了`--push-option=reject`参数，我们的提交被服务器端拒绝了。



当我们去掉命令行中的`--push-option=reject`参数，此时，Git会使用我们通过`git config`配置的`push.pushOption`参数来传递值。

我们再次提交一下：

```sh
[mzh@MacBookPro test (master)]$ git push origin master
Enumerating objects: 14, done.
Counting objects: 100% (14/14), done.
Delta compression using up to 8 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (12/12), 1.10 KiB | 1.10 MiB/s, done.
Total 12 (delta 3), reused 0 (delta 0)
remote: count:2
remote: echo from the pre-receive-hook: the first option
remote: echo from the pre-receive-hook: the second option
remote: Powered by HelloGitlab.com [^_^]
To ssh://hellogitlab.com:10000/git-server/test.git
   7783b43..2ec7a01  master -> master
[mzh@MacBookPro test (master)]$
```


此时，可以看到，提交成功，并且远程服务器回显了我们`push.pushOption`参数值。

即，我们的的`pre-receive`钩子正常工作了。



### 4.6 `post-receive`的使用

此节请直接参考本文档，<a href="#_2-2-%E5%88%9B%E5%BB%BA%E7%AC%AC%E4%B8%80%E4%B8%AA%E9%92%A9%E5%AD%90">2.2 创建第一个钩子</a> 。





