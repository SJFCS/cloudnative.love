# Git commit提交模板

可以通过设置提交模板来规则自己的日志信息。

此处直接给出模板文件内容：

```
docs(Git): subject

<body>

<footer>

# 标题行：50个字符以内，描述主要变更内容，按以下形式填写
# <type>(<scope>): <subject>
# - type 提交的类型
#    feat：新特性, 
#    fix：修改问题, 
#    docs：文档修改，仅仅修改了文档，比如 README, CHANGELOG, CONTRIBUTE等等, 
#    style：代码格式修改, 修改了空格、格式缩进、逗号等等，不改变代码逻辑，注意不是css修改， 
#    refactor：代码重构，没有加新功能或者修复 bug, 
#    perf: 优化相关，比如提升性能、体验，
#    test：测试用例，包括单元测试、集成测试等, 
#    chore：其他修改, 比如改变构建流程, 修改依赖管理，增加工具等，
#    revert: 回滚到上一个版本。
# - scope: 影响的的范围
#    影响的的范围，可以为空，如Git、CentOS等模块，或者全局All。
# - subject
#    主题，提交描述
#
# 主体内容：更详细的说明文本，建议72个字符以内。 需要描述的信息包括:
#
# * 为什么这个变更是必须的? 
#   它可能是用来修复一个bug，增加一个feature，提升性能、可靠性、稳定性等等
# * 它如何解决这个问题? 具体描述解决问题的步骤
# * 是否存在副作用、风险? 
#
# 尾部：如果需要的话可以添加一个链接到issue地址或者其它文档，或者关闭某个issue。
# 
# 注意，标题行、主体内容、尾部之间都有一个空行！
```



设置全局模板：

```sh
# 设置全局模板
[mzh@MacBookPro ~ ]$ git config --global commit.template ~/.commit.template

# 查看模板配置信息
[mzh@MacBookPro ~ ]$ git config --global commit.template
/Users/mzh/.commit.template
[mzh@MacBookPro ~ ]$
```

然后使用vim编辑器将模板内容写入到`~/.commit.template`文件中。

然后，我们尝试修改并进行提交，如提交本文档的修改：

```sh
# 将文件添加到暂存区
[mzh@MacBookPro git (master ✗)]$ git add README.md git_commit_template.md

# 查看状态
[mzh@MacBookPro git (master ✗)]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   README.md
	new file:   git_commit_template.md

# 使用git commit打开提交信息编辑器
[mzh@MacBookPro git (master ✗)]$ git commit
```

此时，Git会自动加载模板文件的内容到临时的编辑器文件中，如下图所示：


此时，我们就可以参考模板说明修改我们的提交日志了，如我修改完成后，日志信息如下：


```sh
[mzh@MacBookPro git (master ✗)]$ git commit
[master 1fd4972] docs(Git): use git commit template
 2 files changed, 133 insertions(+), 1 deletion(-)
 create mode 100644 myblog/docs/CM/git/git_commit_template.md
[mzh@MacBookPro git (master ✗)]$ git log -n 1
commit 1fd4972e6ded192622b62efde1f7f48051257337
Author: Zhaohui Mei <mzh.whut@gmail.com>
Date:   Sun Mar 20 14:26:18 2022 +0800

    docs(Git): use git commit template
    
    use the command `git config --global commit.template ~/.commit.template` to set the template.
[mzh@MacBookPro git (master ✗)]$
```

说明我们的模板正常可用！后续就不用为提交日志时不知道修改类型对应的英文单词是什么而烦恼。

