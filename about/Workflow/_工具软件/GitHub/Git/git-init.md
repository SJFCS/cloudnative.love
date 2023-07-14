https://insights.thoughtworks.cn/how-to-sign-git-commit/
https://docs.github.com/en/authentication/managing-commit-signature-verification
https://ulyc.github.io/2021/01/18/2021%E5%B9%B4-%E7%94%A8%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%E6%96%B9%E6%B3%95%E4%BD%BF%E7%94%A8PGP-%E4%B8%AD/
https://juejin.cn/post/7055485446058426405
## 前言
## 加密算法对比
ed25519与约 3000 位 RSA 相当

ed25519属于ECC 抗量子

https://proton.me/blog/elliptic-curve-cryptography

https://security.stackexchange.com/questions/143083/ssh-key-strength-factor-besides-key-length-say-ed25519-vs-rsa-4096


## Git 初始化
```bash
git_user_name=SongJinfeng
git_user_email=song.jinfeng@outlook.com

git config --global user.name ${git_user_name}
git config --global user.email ${git_user_email}

# 上面设置对全局生效，如果仅对当前仓库进行配置，则可以去掉 `--global` 参数

ssh-keygen -t ed25519 -C "song.jinfeng@outlook.com" -f ~/.ssh/id_ed25519 -N '' -q
# -t 密钥类型，这里选更优的 ed25519 而不是 rsa
# -C 注释信息，可省略，默认为用户@主机名
# -f 存放目录
# -N 密码
# -q 静默模式
```
Settings SSH and GPG keys https://github.com/settings/keys

## GPG 签名
GPG（GNU Privacy Guard）是一个用于加密和签名数据的开源软件。它使用公钥加密和私钥解密的方式来实现数据的安全传输和验证。

在GPG中，密钥分为公钥和私钥。公钥用于加密数据和验证签名，可以公开分享给其他人使用。私钥用于解密数据和生成数字签名，必须严格保密，只有密钥的拥有者可以使用。

当您使用GPG生成密钥对时，会生成一对公钥和私钥。在您引用的命令中，"--edit-key"是用于编辑密钥的命令。通过该命令，您可以对密钥进行不同的操作，包括生成子密钥。


主密钥（也称为主私钥）用于生成子密钥，而子密钥才用于实际的加密和签名操作。这样设计的主要原因是安全性和灵活性。

安全性：主密钥是您的核心身份和控制点，它用于生成和管理子密钥。通过将主密钥保持离线和安全，可以降低主密钥被泄露或损坏的风险。如果主密钥受到威胁，您可以撤销并生成新的子密钥，而无需重新生成整个密钥对。

灵活性：创建子密钥允许您对密钥的用途进行更细粒度的控制。您可以为不同的任务或身份创建不同的子密钥，例如加密、签名、认证等。这样，您可以根据需要选择特定的子密钥，而不必使用主密钥进行所有操作。如果需要撤销或更改某个子密钥，您可以单独操作该子密钥，而不会影响其他子密钥或主密钥。

总结起来，创建子密钥是一种安全和灵活的做法。主密钥用于生成和管理子密钥，而子密钥用于实际的加密和签名操作。这样的设计提供了更好的密钥管理和操作控制，同时增强了密钥的安全性。
### 创建主密钥
```bash
# gpg --default-new-key-algo rsa4096 --gen-key
gpg --default-new-key-algo ed25519 --gen-key
```
:::
当要求输入您的电子邮件地址时，请确保输入您的 GitHub 帐户经过验证的电子邮件地址。为
如果要保密您的个人电子邮件地址，您可以使用 [noreply GitHub 中的电子邮件地址](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/blocking-command-line-pushes-that-expose-your-personal-email-address)作为您的提交电子邮件地址。


[参考](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address) 
:::


### 创建子密钥签名

要创建子密钥，您可以按照以下步骤进行操作：

首先，确保您已经安装了GPG软件并生成了主密钥对。如果您还没有生成主密钥对，请运行以下命令来生成：

gpg --gen-key
这将引导您完成生成密钥对的过程，包括选择密钥类型、密钥长度、有效期等。

生成主密钥后，您可以使用以下命令来创建子密钥：

gpg --edit-key [您的密钥ID]
将命令中的[您的密钥ID]替换为您的实际密钥ID。您可以在生成密钥时或使用gpg --list-keys命令来找到密钥ID。

运行上述命令后，GPG将进入交互式编辑模式。输入以下命令来添加子密钥：

addkey
按照提示选择子密钥的类型，例如加密子密钥或签名子密钥。您还可以选择密钥的长度和有效期。

完成子密钥的设置后，您可以使用以下命令保存更改并退出编辑模式：

save
这将保存您的子密钥并返回到命令行界面。

通过上述步骤，您可以成功创建子密钥。请注意，子密钥的生成是基于主密钥的，因此确保您已经生成了主密钥并妥善保管主密钥的安全。


gpg --expert --edit-key 765F28EE5ABB452B addkey
您可以使用以下命令来创建一个没有交互式过程的ed25519子密钥：

echo -e "addkey\n8\n1y\nsave" | gpg --expert --command-fd 0 --edit-key 765F28EE5ABB452B
该命令使用echo命令将多个命令作为输入传递给GPG，以避免交互式过程。其中：

addkey表示要添加一个新的子密钥。
8表示选择ed25519算法。
1y表示子密钥的过期时间为一年。
save表示保存更改并退出编辑器。
请注意，此命令仍然需要您提供主密钥的密码，以便GPG可以访问密钥。如果您希望完全避免交互式过程，可以将主密钥的密码传递给GPG，例如：

echo -e "addkey\n8\n1y\nsave" | gpg --batch --passphrase "your-passphrase" --pinentry-mode loopback --expert --command-fd 0 --edit-key 765F28EE5ABB452B
但是，这种做法存在一定的安全风险，请谨慎使用。



### 导出密钥
gpg --list-secret-keys --keyid-format LONG

gpg --armor --export 3AA5C34371567BD2

将 GPG 密钥添加到您的 GitHub 帐户。


签名你的提交。
git commit 命令给我们提供了利用gpg来签名commit的选项： -S[]， --gpg-sign[=]， 我们可以在写提交代码的时候加上-S 来签名你的提交：

git commit -S507BB1CAC6286AF9 -m 'commit message'
到这一步， git签名就已经完成了， 但是， 每个提交都要写-S 加 keyid 还是有些麻烦的， 我们通过修改git 的配置（配置哪个层级自己选择， 我选择的是全局）来让git自动签名每一个提交：

git config --global user.signingkey 8212A0B5AE54CE94
git config --global commit.gpgsign true

~/.gitconfig
~/.ssh/config

让GitHub可验证
gpg --export -a 8212A0B5AE54CE94
在本地查看签名
git log --show-signature







## SSH 签名
https://taoshu.in/git/ssh-sign.html

https://dev.tobychung.com/signing-git-commits-with-ssh-keys

假设有一个文件/tmp/a.txt，我们想使用~/.ssh/id_ed25519给它做签名，我们可以：
ssh-keygen -Y sign -f ~/.ssh/id_ed25519 -n file /tmp/a.txt
各参数的功能如下：
-Y sign表示计算签名
-f指定私钥
-n file是给签名指定类型
执行之后就会得到一个签名文件/tmp/a.txt.sig


有了签名，我们就可以验证是不是有坏人篡改了文件内容了。验证签名需要一个公钥列表：
验签命令如下：
ssh-keygen -Y verify -f allowed_signers -I hi@taoshu.in -n file -s /tmp/a.txt.sig < /tmp/a.txt



```
# 使用 SSH 签名
git config gpg.format ssh
# 指定 SSH 私钥文件
git config user.signingKey ~/.ssh/id_ed25519.pub
# 指定可信公钥列表文件
git config gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
# 开启自动签名（可选）
git config commit.gpgsign true
git config tag.gpgsign true

git show --show-signature |head
```


## FAQ
### 更新git签名

如果您无法恢复之前的 GPG 私钥，但是希望对之前的提交重新签名，您可以使用新的 GPG 密钥对其进行签名。


首先，确保您已经生成了新的 GPG 密钥对并将其添加到您的 GPG 密钥环中。您可以使用以下命令生成新的 GPG 密钥对：

gpg --gen-key
按照提示提供必要的信息来生成新的 GPG 密钥对。

在生成新的 GPG 密钥对后，您可以使用以下命令将新的 GPG 密钥设置为默认密钥：

git config --global user.signingkey [新的 GPG 密钥 ID]
将 [新的 GPG 密钥 ID] 替换为您生成的新 GPG 密钥对的 ID。

确认您已经设置了新的 GPG 密钥后，您可以使用以下命令批量重新签名之前的提交：

git filter-branch --commit-filter 'export GNUPGHOME="$(mktemp -d)"; gpg --import [新的密钥文件]; git commit-tree "$@"' -- --all
将 [新的密钥文件] 替换为您生成的新 GPG 密钥对的密钥文件路径。


find ~/.gnupg -name "*.gpg" -o -name "*.asc"

这个命令将使用 git filter-branch 对所有分支的提交进行重新签名。它会创建临时的 GPG 密钥环，并将您的新 GPG 密钥导入其中，然后对每个提交进行重新签名。

请注意，重新签名提交可能会导致 Git 历史记录的变动，因此在执行此操作之前，请确保对代码库进行适当的备份，并确保其他人了解并同步了这些更改。
git log --show-signature
### 删除已有密钥
```bash
❯ gpg --list-secret-keys --keyid-format=long
/home/admin/.gnupg/pubring.kbx
------------------------------
sec   rsa4096/8F38C82C4787ADF9 2022-09-23 [SC]
      3C4670BF228B86E0B9CA73438F38C82C4787ADF9
uid                   [ 绝对 ] SJFCS (SongJinfeng) <song.jinfeng@outlook.com>
uid                   [ 绝对 ] SongJinfeng (SongJinfeng) <song.jinfeng@outlook.com>
ssb   rsa4096/AAAE48C5D4B4906B 2022-09-23 [E]


gpgkey=`gpg --list-secret-keys --keyid-format=long |sed -n '3p |awk '{print $2}'|cut -d/ -f2`

gpg_sub_key_arr=($(gpg --list-secret-keys --keyid-format=long |grep -E "^ssb" |awk '{print $2}' |cut -d/ -f2))


for key in "${arr[@]}"
do
    gpg --batch --delete-secret-key --yes "$key" &>/dev/null
done
```
在这个例子中，-q 和 --yes 选项将禁用任何提示和交互，而 --batch 选项将确保在批处理模式下运行。&>/dev/null 将输出重定向到 /dev/null，以避免在脚本中出现任何输出。
gpg --armor --export 
gpg --delete-secret-key AAAE48C5D4B4906B
gpg --delete-key  765F28EE5ABB452B

### 密码延迟
配置gpg-agent的 default-cache-ttl， 让我们解密后的私钥在内存中存在的时间稍微长一些（默认10分钟）， 比如， 一天：
~/.gnupg/gpg-agent.conf
default-cache-ttl-ssh 86400
max-cache-ttl-ssh 86400

### 开机自动解锁密码

如果你想在开机时自动解锁 Git 的签名密码，可以考虑使用 Git Credential Manager（GCM）来缓存你的认证凭据。GCM 可以在第一次提交后缓存你的凭据，然后在你下次提交时自动使用它们，而无需再次输入你的用户名和密码。你可以在 Git 的全局配置中启用 GCM，具体操作如下：

打开终端或命令提示符窗口，并输入以下命令来安装 GCM：
   git config --global credential.helper manager-core
然后，当你提交代码时，Git 会提示你输入你的用户名和密码。输入它们后，Git 会将它们缓存在 GCM 中，以便下次自动使用。
   git push
现在，当你下次提交时，Git 将自动使用 GCM 中的缓存凭据，而无需再次输入用户名和密码。





如果你想在第一次提交时也自动缓存你的 Git 签名密码，可以考虑使用 Git Credential Store。Git Credential Store 可以将你的凭据保存在本地存储中，并在以后的提交中自动使用它们，而无需再次输入用户名和密码。具体操作如下：

安装 Git Credential Store。在终端窗口中输入以下命令：
   git config --global credential.helper store
提交你的代码，并在 Git 弹出的窗口中输入你的用户名和密码，以便将它们缓存到本地存储中。
   git push
现在，你的 Git 签名密码已经缓存在本地存储中，并可以在以后的提交中自动使用它们，而无需再次输入用户名和密码。请注意，由于你的密码存储在本地计算机上，因此请确保你的计算机安全，并不要与他人共享你的计算机或密码。


### 到期如何续期
在 GPG 中，如果您的密钥已经过期，您可以通过以下步骤为其续期：

检查密钥：使用 gpg --list-keys 命令列出您的密钥，并找到需要续期的密钥的 ID。

进入编辑模式：使用 gpg --edit-key [密钥ID] 命令进入密钥编辑模式。将 [密钥ID] 替换为您需要续期的密钥的实际 ID。

设置有效期：在编辑模式下，使用 expire 命令设置新的有效期。根据提示输入新的有效期值，例如 1y 表示1年、30d 表示30天等等。

保存更改：输入 save 命令保存更改并退出编辑模式。

向信任库中重新导入密钥：使用 gpg --import [密钥文件] 命令重新导入密钥文件，并确保所有用户都在信任库中。