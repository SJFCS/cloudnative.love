ansible-conlse
curl 后台下载安装包
万象磁盘注意
更新git签名
检查环境 磁盘数量  /,/usr,/home,/tmp 空间



可以通过在终端输入以下命令来临时阻止Linux休眠：
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
 systemctl status sleep.target
这将禁用系统的睡眠、挂起、休眠和混合睡眠模式，直到你重新启用它们。如果要重新启用这些模式，可以使用以下命令：
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target


https://taoshu.in/git/ssh-sign.html
https://insights.thoughtworks.cn/how-to-sign-git-commit/
https://docs.github.com/en/authentication/managing-commit-signature-verification
## 删除已有

❯ gpg --list-secret-keys --keyid-format=long
/home/admin/.gnupg/pubring.kbx
------------------------------
sec   rsa4096/8F38C82C4787ADF9 2022-09-23 [SC]
      3C4670BF228B86E0B9CA73438F38C82C4787ADF9
uid                   [ 绝对 ] SJFCS (SongJinfeng) <song.jinfeng@outlook.com>
uid                   [ 绝对 ] SongJinfeng (SongJinfeng) <song.jinfeng@outlook.com>
ssb   rsa4096/AAAE48C5D4B4906B 2022-09-23 [E]
ssb   rsa4096/AAAE48C5D4B4906B 2022-09-23 [E]


gpgkey=`gpg --list-secret-keys --keyid-format=long |sed -n '3p |awk '{print $2}'|cut -d/ -f2`

gpg_sub_key_arr=($(gpg --list-secret-keys --keyid-format=long |grep -E "^ssb" |awk '{print $2}' |cut -d/ -f2))


for key in "${arr[@]}"
do
    gpg --batch --delete-secret-key --yes "$key" &>/dev/null
done
在这个例子中，-q 和 --yes 选项将禁用任何提示和交互，而 --batch 选项将确保在批处理模式下运行。&>/dev/null 将输出重定向到 /dev/null，以避免在脚本中出现任何输出。



gpg --armor --export 
gpg --delete-secret-key AAAE48C5D4B4906B
gpg --delete-key  $gpgkey










ssh-keygen -t ed25519 -C "注释信息" -f ~/.ssh/id_ed25519 -N '' -q
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -q
ssh-keygen -t ed25519 -C "song.jinfeng@outlook.com" -f ~/.ssh/id_ed25519 -N '' -q


  




git config user.name SongJinfeng
git config user.email song.jinfeng@outlook.com

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





## add

gpg --full-generate-key
如果您使用的版本不是 2.1.17 或更高版本，则该gpg --full-generate-key命令不起作用。粘贴下面的文本
gpg --default-new-key-algo rsa4096 --gen-key


类型，密钥大小，密钥的有效时间长度，验证您的选择是否正确，输入您的用户 ID 信息。

:::
当要求输入您的电子邮件地址时，请确保输入您的 GitHub 帐户经过验证的电子邮件地址。为了保证您的电子邮件地址的私密性，请使用 GitHub 提供的no-reply电子邮件地址。
如果您想保密您的个人电子邮件地址，您可以使用noreplyGitHub 中的电子邮件地址作为您的提交电子邮件地址。要使用您的noreply电子邮件地址从命令行推送提交，请在 Git 中设置提交电子邮件地址时使用该电子邮件地址。要使用您的noreply地址进行基于 Web 的 Git 操作，请在 GitHub 上设置您的提交电子邮件地址并选择Keep my email address private。
https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/blocking-command-line-pushes-that-expose-your-personal-email-address

https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address
:::

## list
gpg --list-secret-keys --keyid-format LONG

gpg --armor --export 3AA5C34371567BD2
复制您的 GPG 密钥，以 开头-----BEGIN PGP PUBLIC KEY BLOCK-----和结尾-----END PGP PUBLIC KEY BLOCK-----。

将 GPG 密钥添加到您的 GitHub 帐户。




签名你的提交。
git commit 命令给我们提供了利用gpg来签名commit的选项： -S[]， --gpg-sign[=]， 我们可以在写提交代码的时候加上-S 来签名你的提交：

git commit -S507BB1CAC6286AF9 -m 'commit message'
到这一步， git签名就已经完成了， 但是， 每个提交都要写-S 加 keyid 还是有些麻烦的， 我们通过修改git 的配置（配置哪个层级自己选择， 我选择的是全局）来让git自动签名每一个提交：

$ git config --global user.signingkey 507BB1CAC6286AF9
$ git config --global commit.gpgsign true



让GitHub可验证
gpg --export -a <keyid>
在本地查看签名
git log --show-signature



## 密码延迟
配置gpg-agent的 default-cache-ttl， 让我们解密后的私钥在内存中存在的时间稍微长一些（默认10分钟）， 比如， 一天：
~/.gnupg/gpg-agent.conf
default-cache-ttl-ssh 86400
max-cache-ttl-ssh 86400

## 开机自动解锁密码

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












除了 Git Credential Manager 和 Git Credential Store

将 SSH 密钥添加到 SSH 代理。在终端窗口中输入以下命令：
   ssh-add ~/.ssh/id_rsa
这将向 SSH 代理添加你的 SSH 密钥，以便 Git 可以在不输入密码的情况下使用它。
