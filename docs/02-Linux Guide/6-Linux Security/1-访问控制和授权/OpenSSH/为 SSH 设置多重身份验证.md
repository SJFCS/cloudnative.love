https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-20-04
https://wiki.archlinux.org/title/Google_Authenticator
https://systemoverlord.com/2018/03/03/openssh-two-factor-authentication-but-not-service-accounts.html

多重身份验证(MFA) 或双因素身份验证(2FA) 需要多个因素才能进行身份验证或登录。
例如密码或安全问题、身份验证器应用程序或安全令牌、生物认证你的指纹或声音


一个常见因素是 OATH-TOTP 应用程序，例如 Google Authenticator。OATH-TOTP（开放身份验证基于时间的一次性密码）是一种开放协议，可生成一次性密码，通常是每 30 秒循环一次的六位数字。



本文将介绍如何使用 OATH-TOTP 应用程序以及 SSH 密钥来启用 SSH 身份验证。此外，我们还将介绍 MFA 的一些其他用例以及一些有用的提示和技巧。

## 环境准备

要学习本教程，您将需要：

安装了 OATH-TOTP 应用程序的智能手机或平板电脑，例如 Google Authenticator。或者，您还可以使用名为“oathtool”的 Linux 命令行应用程序来生成 OATH-TOTP 代码。它可以在各种发行版[仓库中](https://www.cyberciti.biz/faq/use-oathtool-linux-command-line-for-2-step-verification-2fa/)使用


## 第 1 步 — 安装 Google 的 PAM
PAM 代表可插入身份验证模块，是 Linux 系统上用于对用户进行身份验证的身份验证基础结构。因为 Google 制作了 OATH-TOTP 应用程序，所以他们还制作了一个可生成 TOTP 的 PAM，并且与任何 OATH-TOTP 应用程序完全兼容，例如 Google Authenticator 或[Authy](https://www.authy.com/)。

安装 PAM 后，我们将生成 TOTP 密钥。该密钥是按用户生成的，而不是在系统范围内生成的。


```bash
sudo apt-get update
sudo apt-get install libpam-google-authenticator
google-authenticator
```
运行命令后，应用程序会询问一些问题。第一个询问身份验证令牌是否应该基于时间：

```
Output
Do you want authentication tokens to be time-based (y/n) y

此 PAM 允许基于时间或基于顺序的令牌。使用基于顺序的标记意味着代码从某个点开始，然后在每次使用后递增代码。使用基于时间的令牌意味着代码会在特定时间范围后发生更改。我们将坚持基于时间的，因为这是 Google Authenticator 等应用程序所期望的，所以回答“y是”。

回答完这个问题后，很多输出会滚动过去，其中包括一个很大的二维码。使用手机上的身份验证器应用程序扫描二维码或手动输入密钥。如果二维码太大而无法扫描，您可以使用二维码上方的 URL 获取较小的版本。添加后，您将在应用程序中看到一个每 30 秒更改一次的六位代码。

Output
Do you want me to update your "~/.google_authenticator" file (y/n) y

这会将密钥和选项写入文件.google_authenticator。如果您拒绝，程序将退出并且不会写入任何内容，这意味着身份验证器将无法工作：


Output
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

通过在这里回答“是”，您可以通过使每个代码在使用后立即过期来防止重放攻击。这可以防止攻击者捕获您刚刚使用的代码并用它登录：


Output
By default, a new token is generated every 30 seconds by the mobile app.
In order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. This allows for a
time skew of up to 30 seconds between the authentication server and client. Suppose you
experience problems with poor time synchronization. In that case, you can increase the window
from its default size of 3 permitted codes (one previous code, the current
code, the next code) to 17 permitted codes (the eight previous codes, the current
code, and the eight next codes). This will permit a time skew of up to 4 minutes
between client and server.
Do you want to do so? (y/n) n

此处回答“是”允许在移动的四分钟窗口内最多输入 17 个有效代码。如果回答“否”，则您将在 1:30 分钟的滚动窗口中限制为 3 个有效代码。除非您发现 1:30 分钟窗口存在问题，否则回答“否”是更安全的选择。.google_authenticator您可以稍后在存储在主目录根目录下的文件中更改此设置：


Output
If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than three login attempts every 30s.
Do you want to enable rate-limiting (y/n) y

速率限制意味着远程攻击者只能尝试一定数量的猜测，然后被迫等待一段时间才能再次尝试。如果您之前没有直接在 SSH 中配置速率限制，那么现在这样做是一项很好的强化技术。


```

:::tip
注意：完成此设置后，如果您想备份密钥，可以将文件复制~/.google_authenticator到受信任的位置。从那里，您可以将其部署到其他系统上或在备份后重新部署。
:::

现在 Google 的 PAM 已安装并配置完毕，下一步是配置 SSH 以使用您的 TOTP 密钥。我们需要告诉 SSH 有关 PAM 的信息，然后配置 SSH 以使用它。

## 步骤 2 — 配置 OpenSSH 以使用 MFA/2FA
:::warning
因为我们将通过 SSH 进行 SSH 更改，所以永远不要关闭初始 SSH 连接，这一点很重要。相反，打开第二个 SSH 会话来进行测试。这是为了避免在 SSH 配置错误时将自己锁定在服务器之外。一旦一切正常，您就可以安全地关闭任何会话。另一个安全预防措施是创建您将编辑的系统文件的备份，因此如果出现问题，您可以恢复到原始文件并使用干净的配置重新开始。
:::

首先，备份sshd配置文件：
```
sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.bak
sudo vim /etc/pam.d/sshd
```
将以下行添加到文件底部：

```
. . .
# Standard Un*x password updating.
@include common-password
auth required pam_google_authenticator.so nullok
auth required pam_permit.so
```

nullok最后一行末尾的单词告诉 PAM 此身份验证方法是可选的。这允许没有 OATH-TOTP 令牌的用户仍然仅使用 SSH 密钥登录。所有用户都拥有 OATH-TOTP 令牌后，您可以nullok从此行中删除以强制执行 MFA。pam_permit.so如果用户不使用 MFA 令牌登录，则需要使用第二行来允许身份验证。登录时，每种方法都需要 SUCCESS 来允许身份验证。如果用户不使用 MFA 身份验证工具，则使用该nullok选项将为交互式键盘身份验证返回 IGNORE。pam_permit.so然后返回 SUCCESS 并允许身份验证继续进行。


保存并关闭文件。

接下来，我们将配置 SSH 以支持这种身份验证。

首先对文件进行备份：
```
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo vim /etc/ssh/sshd_config
```

查找 ChallengeResponseAuthentication 并将其值设置为yes：

```
. . .
# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication yes
. . .
```
保存并关闭文件，然后重新启动 SSH 以重新加载配置文件。
:::tip
重新启动sshd服务不会关闭我们当前打开的连接，这意味着您不会冒使用此命令将自己锁定的风险：
:::
```
sudo systemctl restart sshd.service
```

:::warning
要测试到目前为止一切是否正常，请打开另一个终端并尝试通过 SSH 登录。保持当前 SSH 会话打开并使用附加会话进行测试非常重要，否则您可能会在某个时候将自己锁定，并需要使用 Web 控制台重新进入。
:::

:::tip
注意：如果您之前创建了 SSH 密钥并正在使用它，您会发现无需输入用户密码或 MFA 验证码。这是因为默认情况下 SSH 密钥会覆盖所有其他身份验证选项。否则，您应该会收到密码和验证码提示。
:::
接下来，要启用 SSH 密钥作为第一个因素，将验证码作为第二个因素，我们需要告诉 SSH 使用哪些因素并防止 SSH 密钥覆盖所有其他类型。

## 第 3 步 — 让 SSH 了解 MFA
如果您正在使用 SSH 密钥，MFA 仍然无法工作。要使 SSH 感知 MFA，请重新打开sshd配置文件：

在文件底部添加以下行。这告诉 SSH 需要哪些身份验证方法。我们告诉 SSH 用户需要 SSH 密钥以及密码或验证码（或三者兼有）：
```
sudo vim /etc/ssh/sshd_config
AuthenticationMethods publickey,password publickey,keyboard-interactive
```
保存并关闭文件。

接下来，再次打开PAMsshd配置文件：
```
sudo vim /etc/pam.d/sshd
```
找到该行并通过添加一个字符作为该行的第一个字符@include common-auth来注释掉它。#这告诉 PAM 不要提示输入密码：

```
. . .
# Standard Un*x authentication.
#@include common-auth
. . .
```
保存并关闭文件，然后重新启动 SSH：

```
sudo systemctl restart sshd.service

```

现在尝试使用不同的终端会话/窗口再次登录服务器。与上次不同，SSH 应该要求您提供验证码。输入它，您就完成了登录。尽管没有迹象表明您的 SSH 密钥已被使用，但您的登录尝试使用了两个因素。如果您想验证这一点，可以-v在 SSH 命令后添加（用于详细）。

开关-v将产生如下输出：

```
Example SSH output\
. . .
debug1: Authentications that can continue: publickey
debug1: Next authentication method: publickey
debug1: Offering RSA public key: /Users/sammy/.ssh/id_rsa
debug1: Server accepts key: pkalg rsa-sha2-512 blen 279
Authenticated with partial success.
debug1: Authentications that can continue: password,keyboard-interactive
debug1: Next authentication method: keyboard-interactive
Verification code:
```

在输出的末尾，您将看到 SSH 在何处使用您的 SSH 密钥，然后要求输入验证码。您现在可以使用 SSH 密钥和一次性密码通过 SSH 登录。如果您想强制执行所有三种身份验证类型，可以按照下一步操作。

恭喜，您在通过 SSH 远程登录服务器时已成功添加第二个因素。如果这就是您想要的 — 使用 SSH 密钥和 TOTP 令牌来启用 SSH 的 MFA（对于大多数人来说，这是最佳配置） — 那么您就完成了。

以下是一些有关恢复、自动使用等的提示和技巧。


## 第 4 步 — 添加第三个因素（可选）
在步骤 3 中，我们在文件中列出了批准的身份验证类型sshd_config：

- publickey（SSH 密钥）
- password publickey（密码）
- keyboard-interactive（验证码）

尽管我们列出了三个不同的因素，但到目前为止我们选择的选项仅允许 SSH 密钥和验证码。如果您想拥有所有三个因素（SSH 密钥、密码和验证码），只需进行一项快速更改即可启用所有三个因素。

打开PAMsshd配置文件：
```
sudo nano /etc/pam.d/sshd
```
找到您之前注释掉的行 ，#@include common-auth并通过删除该#字符来取消注释该行。保存并关闭文件。现在再次重新启动 SSH：
```
sudo systemctl restart sshd.service
```

通过启用该选项@include common-auth，PAM 除了检查 SSH 密钥并要求输入验证码（我们之前已经这样做过）之外，现在还会提示输入密码。现在，我们可以通过两个不同的渠道（您的计算机用于 SSH 密钥，您的手机用于 TOTP 令牌）使用我们知道的东西（密码）和我们拥有的两种不同类型的东西（SSH 密钥和验证码）。


## 第 5 步 — 恢复对 Google MFA 的访问（可选）
与您强化和保护的任何系统一样，您有责任管理该安全性。在这种情况下，这意味着不要丢失您的 SSH 密钥或 TOTP 密钥，并确保您有权访问 TOTP 应用程序。然而，有时会发生一些事情，您可能会失去对进入所需的按键或应用程序的控制。

### 丢失您的 TOTP 密钥

如果您丢失了 TOTP 密钥，您可以将恢复过程分为几个步骤。第一个是在不知道验证码的情况下重新登录，第二个是找到密钥或重新生成密钥以进行正常的 MFA 登录。如果您购买了新手机并且没有将您的机密转移到新的身份验证器应用程序，则通常会发生这种情况。

那么您有两种重新获得访问权限的选项：

- 对系统的控制台（本地/非 ssh）访问（通常是物理访问或通过 iDrac 等方式）
- 拥有未启用 MFA 的其他用户

第二个选项是安全性较低的选项，因为使用 MFA 的目的是强化所有 SSH 连接，但如果您失去对 MFA 身份验证器应用程序的访问权限，它就是一种故障保护。

登录后，有两种方法可以帮助获取 TOTP 密钥：

- 恢复现有密钥
- 生成新密钥


在每个用户的主目录中，密钥和 Google 身份验证器设置都保存在文件中~/.google-authenticator。该文件的第一行是一个密钥。获取密钥的快速方法是执行以下命令，该命令显示文件的第一行google-authenticator（即密钥）。然后，获取该密钥并将其手动输入到 TOTP 应用程序中：

```
head -n 1 /home/sammy/.google_authenticator
```

恢复现有密钥后，您可以将其手动输入到身份验证器应用程序中，也可以在下面的 URL 中填写相关详细信息，然后让 Google 生成一个二维码供您扫描。您需要添加您的用户名、主机名、文件中的密钥.google-authenticator，然后添加您为“entry-name-in-auth-app”选择的任何名称，以便轻松识别此密钥与不同的 TOTP 令牌：

```
https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/username@hostname%3Fsecret%3D16-char-secret%26issuer%3Dentry-name-in-auth-app
```
如果出于某种原因不使用现有密钥（例如，无法轻松地与受影响的用户安全地共享密钥），您可以~/.google-authenticator直接删除该文件。这将允许用户仅使用一个因素再次登录（假设您没有通过删除该nullok选项来强制执行 MFA）。然后他们可以运行google-authenticator以生成新密钥。

### 无法访问 TOTP 应用程序
如果您需要登录服务器，但无法访问 TOTP 应用程序来获取验证码，您仍然可以使用首次创建密钥时显示的恢复代码（最近 5 个）进行登录文件的行.google-authenticator。请注意，这些恢复代码是一次性使用的。但是，要实现此功能，您需要在无法访问 TOTP 应用程序时提供恢复代码。

## 第 6 步 — 更改身份验证设置（可选）
如果您想在初始配置后更改 MFA 设置，而不是使用更新的设置生成新配置，您只需编辑该~/.google-authenticator文件即可。该文件中的选项按以下方式显示：

```
<secret key>
<options>
<recovery codes>
```
该文件中设置的选项在选项部分有一行；如果您在初始设置期间对特定选项回答“否”，则程序会排除相应的选项。

您可以对此文件进行以下一些更改：

要启用顺序代码而不是基于时间的代码，请将行更改" TOTP_AUTH为" HOTP_COUNTER 1。
要允许多次使用单个代码，请删除该行" DISALLOW_REUSE。
要将代码过期窗口延长到 4 分钟，请添加行" WINDOW_SIZE 17.
要禁用多次失败登录（速率限制），请删除该行" RATE_LIMIT 3 30。
要更改速率限制阈值，请找到该行" RATE_LIMIT 3 30并调整数字。原文3中的 表示一段时间内的尝试次数， 表示30时间（以秒为单位）。
要禁用恢复代码，请删除文件底部的五个八位代码。

## 第 7 步 — 避免某些账户的 MFA（可选）
可能存在这样的情况：单个用户或几个服务帐户（即应用程序使用的帐户，而不是人类使用的帐户）需要在未启用 MFA 的情况下进行 SSH 访问。例如，某些使用 SSH 的应用程序（如某些 FTP 客户端）可能不支持 MFA。如果应用程序无法请求验证码，则请求可能会被卡住，直到 SSH 连接超时。

要控制对用户使用哪些因素，您可以编辑 /etc/pam.d/sshd 文件。

要允许某些帐户使用 MFA，而仅允许其他帐户使用 SSH，请确保以下设置处于/etc/pam.d/sshd活动状态：

```
# PAM configuration for the Secure Shell service

# Standard Un*x authentication.
#@include common-auth

. . .

# Standard Un*x password updating.
@include common-password
auth required pam_google_authenticator.so nullok
```

这里，@include common-auth被注释掉，因为需要禁用密码。如果某些帐户禁用了 MFA，则您无法强制执行 MFA，因此请将该nullok选项保留在最后一行。

设置此配置后，google-authenticator以任何需要 MFA 的用户身份运行，并且不要为仅使用 SSH 密钥的用户运行它。

## 步骤 8 — 使用配置管理自动设置（可选）
许多系统管理员使用配置管理工具（例如 Puppet、Chef 或 Ansible）来管理他们的系统。每当新用户创建帐户时，您都可以使用这样的系统来安装和设置密钥。

google-authenticator支持命令行开关以在单个非交互式命令中设置所有选项。要查看所有选项，您可以键入google-authenticator --help。下面的命令将按照步骤 1 中的概述进行所有设置：

```
google-authenticator -t -d -f -r 3 -R 30 -w 3
```

上面引用的选项如下：

-t => 基于时间的计数器
-d => 禁止令牌重用
-f => 强制将设置写入文件而不提示用户
-r => 尝试输入正确代码的次数
-R => 用户可以尝试输入正确代码的时间（以秒为单位）
-w => 一次可以有多少个代码有效（这指的是有效代码的 1:30 分钟 - 4 分钟窗口）

这将完整配置身份验证器，将其保存到文件中，然后输出密钥、二维码和恢复码。（如果您添加标志-q，则不会有任何输出。）如果您以自动方式使用此命令，请确保您的脚本捕获密钥和/或恢复代码并使它们可供用户使用。

## 步骤 9 — 强制所有用户执行 MFA（可选）
如果您想对所有用户强制执行 MFA（即使是在第一次登录时），或者不想依赖用户生成密钥，则有一种快速方法可以处理此问题。您可以为每个用户使用相同的.google-authenticator文件，因为文件中没有存储特定于用户的数据。

为此，在创建配置文件后，特权用户需要将该文件复制到每个主目录的根目录，并将其权限更改为适当的用户。您还可以将文件复制到/etc/skel/，在创建后自动将文件复制到每个新用户的主目录。

:::warning
警告：这可能会带来安全风险，因为每个人都共享相同的第二个因素。这意味着，如果它被泄露，就好像每个用户都只有一个因素一样。如果您想使用此方法，请考虑这一点。
:::

强制创建用户密钥的另一种方法是使用 bash 脚本：

- 创建 TOTP 代币，
- 提示他们下载 Google Authenticator 应用程序并扫描将显示的二维码，以及
- google-authenticator检查文件是否已存在后为他们运行应用程序.google-authenticator。

为了确保该脚本在用户登录时运行，您可以为其命名.bash_login并将其放置在用户主目录的根目录中。

## 结论
在本教程中，您跨两个通道（您的计算机 + 您的手机）向服务器添加了两个因素（SSH 密钥 + MFA 令牌）。您使外部代理很难通过 SSH 暴力进入您的计算机，并大大提高了您计算机的安全性。

请记住，如果您正在寻求有关保护 SSH 连接安全的进一步指导，请查看有关强化[ OpenSSH和强化](https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04) [OpenSSH 客户端](https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-client-on-ubuntu-20-04)的教程。





可使用如下脚本进行设置。

```bash
#!/bin/bash
#### 可能会重复，需要仔细查看改完的文件去重
# 根据你的需求设置 SSH 配置变量

PermitRootLogin=no         # 是否允许 root 用户通过 SSH 登录系统。
# RSAAuthentication=yes      # 允许 RSA 秘钥认证
PubkeyAuthentication=yes   # 是否允许使用密钥进行 SSH 登录。
PasswordAuthentication=no  # 是否允许使用密码进行 SSH 登录。
PermitEmptyPasswords=no    # 是否允许用户使用空密码登录系统。
X11Forwarding=no           # 是否允许启用 X11 转发功能，开启后可在 SSH 会话中运行图形界面程序。

# 例子：sed --in-place=.bak -r 's/^#?(PermitRootLogin|PermitEmptyPasswords|PasswordAuthentication|X11Forwarding) yes/\1 no/' /etc/ssh/sshd_config
sudo cat /etc/ssh/sshd_config | grep -e "PubkeyAuthentication" -e "PermitRootLogin" -e "PasswordAuthentication" -e "PermitEmptyPasswords" -e "X11Forwarding"
# 编辑 sshd_config 文件
sudo sed -i.bak -r \
  -e "s/^(#)?PermitRootLogin\s+(yes|no)/PermitRootLogin $PermitRootLogin/" \
  -e "s/^(#)?PubkeyAuthentication\s+(yes|no)/PubkeyAuthentication $PubkeyAuthentication/" \
  -e "s/^(#)?PasswordAuthentication\s+(yes|no)/PasswordAuthentication $PasswordAuthentication/" \
  -e "s/^(#)?PermitEmptyPasswords\s+(yes|no)/PermitEmptyPasswords $PermitEmptyPasswords/" \
  -e "s/^(#)?X11Forwarding\s+(yes|no)/X11Forwarding $X11Forwarding/" \
  /etc/ssh/sshd_config

sudo cat /etc/ssh/sshd_config | grep -e "PubkeyAuthentication" -e "PermitRootLogin" -e "PasswordAuthentication" -e "PermitEmptyPasswords" -e "X11Forwarding"
```

然后手动重启 sshd 服务 `systemctl restart sshd` 



https://www.v2ex.com/t/928798

https://unix.stackexchange.com/questions/727492/passwordauthentication-no-but-i-can-still-login-by-password?ref=vnxi.net