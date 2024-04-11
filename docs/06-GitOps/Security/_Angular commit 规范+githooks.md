git 加密
- https://github.com/getsops/sops
- https://github.com/awslabs/git-secrets
- https://github.com/AGWA/git-crypt
  - https://qiita.com/tmiki/items/5d403025b1f5536423b4
  - https://dev.to/heroku/how-to-manage-your-secrets-with-git-crypt-56ih  
  - https://www.reddit.com/r/devops/comments/sa2qbo/thoughts_on_using_gitcrypt/






https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#heading=h.greljkmo14y0

https://docs.google.com/document/d/1JoVGGtazP2_z-jJ6m_jujXdUys-QJ4JnB3YldqriOvE/edit#heading=h.t7ifoyph8bd3


https://juejin.cn/post/6974301879731748900



- 1
  - https://axionl.me/p/%E5%BD%92%E6%A1%A3-%E7%94%A8-chezmoi-%E7%AE%A1%E7%90%86%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6/#keepassxc
  - git-secret：在 Git 存储库中加密和存储密钥（上） 
  - git hooks + 安全 + 提交message
    - git hooks：https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90
    - https://github.com/aitemr/awesome-git-hooks
    - https://juejin.cn/post/6974301879731748900
    - 例子 https://www.freecodecamp.org/chinese/news/how-to-add-commit-hooks-to-git-with-husky-to-automate-code-tasks/
    - 例子 https://blog.urth.org/2020/05/08/comparing-code-quality-meta-tools/
    - 迁移 https://www.bitovi.com/blog/how-to-migrate-husky-to-lefthook
    - 例子 https://selivan.github.io/2017/04/08/ansible-check-on-commit-vault-files-are-encrypted.html
      - https://gist.github.com/saumets/0ba33b6d0ece8a3f156e321a1eb2d0c1
      - https://chillingchua.wordpress.com/2016/09/02/ansible-vault-git-pre-commit-hook/
      - https://docs.gitlab.cn/jh/development/contributing/style_guides.html
      - https://gist.github.com/ralovely/9367737
      - https://github.com/heywoodlh/ansible/blob/master/lefthook.yml 这个命令是调用 gitleaks 工具来检测 Git 仓库中的敏感信息泄露问题。gitleaks 是一个通过扫描 Git 历史记录来发现和防止敏感数据泄漏的工具。这个命令的参数含义如下：


Husky - 一个流行的用于管理 Git 钩子的 JavaScript 工具，它通过修改项目的 package.json文件中的配置来使用。
overcommit - 一个完全用 Ruby 编写的 Git 钩子管理器。
lefthook - 另一个跨平台的 Git 钩子管理器，可以作为 yarn 或 npm 的包添加。




## 浅谈 Git 的安全策略与实践

一、git签名 vault 密钥认证  分发  冒名顶替
二、密钥管理与git-secret    git-secret vs git-crypt


在服务器上部署和配置软件有一个众所周知的问题：通常您必须将私有数据（例如数据库密码、应用程序密钥、OAuth 密钥等）存储在 git 存储库之外。
如果选择将这些机密以未加密的方式存储在 git 存储库中，即使存储库是私有的，则在签出存储库的任何位置复制机密都存在安全风险。

将机密与 git 存储库分开存储有哪些缺点？
- 这些文件不受版本控制。文件名、位置和密码会不时更改，或者出现新信息，并删除其他信息。当机密与存储库分开存储时，无法确定每次提交或部署都使用了哪个版本的配置文件。
- 在构建自动化部署系统时，将有一个额外的步骤：下载这些机密配置文件并将其放置在需要的位置。这也意味着您必须维护额外的安全服务器，以存储所有机密。

如何 git-secret 解决这些问题？
- git-secret 加密文件并将其存储在存储库 git 中，为每次提交提供更改历史记录。
- git-secret 除了提供适当的私钥（以允许解密）和用于 git secret reveal 解密所有机密文件外，不需要任何额外的部署操作。

git-secret 是一个 bash 工具，用于将私有数据存储在 git 存储库中。


它用于 gpg 使用您信任的用户的公钥加密文件
且您使用 git secret tell email@address.id .然后，这些用户可以使用他们的个人密钥解密这些文件。
使用 git secret removeperson email@address.id 从存储库的 git-secret 密钥环中删除其公钥，然后重新加密文件。然后他们将无法再解密秘密。





git-secret 是一个基于shell脚本的工具，它允许用户在git仓库中存储他们的私密数据。git-secret使用GPG加密和解密文件，以隐藏那些不应当被公开的文件内容。使用git-secret，开发者可以确保敏感数据如密码、私钥、证书等不会无意中被推送到远程仓库中。
实践案例：
假设您有一个含有敏感配置文件的项目，如.env文件，您不希望将其暴露在公共git仓库中。您可以使用git-secret来安全地保管这些敏感信息。
步骤如下：

安装git-secret：在大多数操作系统中，您可以通过包管理器如apt（对于Debian基础系统）或brew（对于Mac）安装git-secret。
初始化git-secret：在仓库根目录执行git secret init。这将创建一个名为.gitsecret的文件夹，用于存储git-secret需要的文件。
添加使用者：如果您的项目中有多位贡献者，并且他们需要访问被加密的文件，您需要将他们的公钥添加到git-secret中。使用git secret tell [user's email]，该邮箱地址需要与GPG密钥对应。
添加文件到git-secret：使用git secret add [file name]将.env文件添加到git-secret中。这将告诉git-secret有哪些文件需要加密。
加密文件：执行git secret hide将添加的文件加密。这会创建加密版本的文件，例如.env.secret。
共享与管理：已加密的文件会被提交到git仓库，而.env文件（实际含敏感信息的文件）则应添加到.gitignore以避免被推送。当其他开发者克隆仓库并需要访问敏感文件时，他们可以使用git secret reveal来解密这些文件，前提是他们有适当的GPG私钥。 通过这样一个案例，可以看出git-secret是如何帮助团队成员共享敏感信息，同时保持信息的秘密性和安全性。

## 三、ansible-Vault
https://cn.linux-console.net/?p=21441
使用ansible-vault进行加密的步骤相对简单。Ansible Vault是Ansible的一部分，是一种用于保护敏感数据的工具。以下是一般的步骤：

创建加密的变量文件：您可以使用ansible-vault create filename命令来创建一个新的加密文件。这个文件可以包含敏感数据。在执行此命令后，系统会提示您设置一个密码。
编辑加密的文件：如果需要对已加密的文件进行编辑，可以使用ansible-vault edit filename命令。_system_会提示您输入在第一步中设置的密码以解锁文件。
加密已有的文件：如果您已经有了一个包含敏感数据的普通文件，可以使用ansible-vault encrypt filename命令来对其进行加密。您将需要输入密码来完成加密过程。
查看加密的文件内容：要查看已加密文件的内容，可以使用ansible-vault view filename命令，并在提示时输入密码。
解密文件：如果您想要解除文件加密，可以使用ansible-vault decrypt filename命令，并在提示时输入密码。 每当执行这些操作时，都会提示您输入密码。确保您使用的是强密码，并且不要遗忘。这个密码用于加密和解密数据，任何拥有密码的人都可以访问被保护的信息。所以要谨慎管理这个密码。记得在写playbook时，如果使用了被ansible-vault加密的文件或变量，运行playbook时需要加上 --ask-vault-pass 或者使用一个包含密码的密码文件。

## 大纲
三、Git Hooks深度应用
A. Git Hooks简介与安全意义
B. 建立安全的Git Hooks策略
1. 提交消息校验
2. 代码质量检查
3. 保护敏感数据
C. 实践案例分析
1. husky与pre-commit工具对比 钩子脚本的自动安装与共享
2. 使用lefthook迁移Git Hooks
3. 利用gitleaks防止敏感信息泄露

B. Git Hooks集成实例
1. 使用Gitlab风格指南自动化代码审查
2. 结合Ansible Vault加强配置管理

五、Git Hooks与持续集成/持续部署(CI/CD)
A. Git Hooks与CI/CD的关系
B. 在CI/CD流程中自动化执行Git Hooks
C. CI/CD与Git Hooks的最佳组合实践

