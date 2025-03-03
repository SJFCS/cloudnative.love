本教程将指导您设置[Google Authenticator PAM](https://github.com/google/google-authenticator-libpam)，以便为连接到 Linux 服务器的用户启用 SSH 2FA。

警告：如果您通过SSH进行所有配置，请不要在测试一切正常之前关闭会话，否则您可能会被锁定。

注意：请确保将密钥、验证码和恢复码记录在安全的地方，例如密码管理器。如果您无法访问 TOTP 应用程序，恢复码是重新获得访问权限的唯一方法。

 在system-remote-login 行上方添加pam_google_authenticator.so
```bash
sudo vim /etc/pam.d/sshd

#%PAM-1.0

auth      required  pam_google_authenticator.so nullok
auth      include   system-remote-login
account   include   system-remote-login
password  include   system-remote-login
session   include   system-remote-login
```

nullok 参数的含义:
nullok 是 pam_google_authenticator.so 模块的一个选项，其作用是允许那些未配置Google身份验证器的用户仍然能够通过认证。这意味着：
- 有配置的用户：如果用户已经设置了Google身份验证器（即在其主目录下存在 .google_authenticator 文件），系统将要求他们输入由Google身份验证器生成的动态验证码作为第二步验证。
- 未配置的用户：如果用户尚未设置Google身份验证器（即 .google_authenticator 文件不存在或为空），nullok 选项允许他们仅通过常规的认证方式（如密码）登录，而不需要第二步验证。

启用键盘交互式身份验证
```bash
sudo vim /etc/ssh/sshd_config

KbdInteractiveAuthentication yes
UsePAM yes
PrintMotd no
```

重启服务
```bash
sudo systemctl restart ssh
```





添加`auth required pam_google_authenticator.so`到首行，可用于tty控制台登录 /etc/pam.d/login，和GDM 登录/etc/pam.d/gdm-password文件






生成密钥文件
警告：只有生成了密钥文件（见下文）的用户才允许使用 SSH 登录。
google-authenticator
提示： 安装 qrencode以生成可扫描的二维码。使用身份验证器应用程序扫描二维码以自动配置密钥。

```bash
$ google-authenticator
Do you want authentication tokens to be time-based (y/n) y
generated_QR_code_here
Your new secret key is: ZVZG5UZU4D7MY4DH
Your verification code is 269371
Your emergency scratch codes are:
  70058954
  97277505
  99684896
  56514332
  82717798

Do you want me to update your "/home/username/.google_authenticator" file (y/n) y

Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. Do you want to do so (y/n) n

If the computer that you are logging into is not hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
```
建议妥善保存紧急刮擦代码（打印出来并保存在安全的地方），因为当您丢失手机（即您的 OTP 生成器）时，它们是您登录的唯一方式（通过 SSH）。它们也存储在 中~/.google_authenticator，因此只要您已登录，就可以随时查找它们。




https://wiki.archlinux.org/title/Google_Authenticator
https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04













但 TOTP 并不是添加双因素身份验证的唯一方法。通用第二因素 (U2F)和WebAuthn等标准为双因素身份验证提供了更安全的选项，这些标准可以通过Teleport轻松利用 。

https://wiki.archlinux.org/title/SSH_keys#Copying_the_public_key_to_the_remote_server
https://wiki.archlinux.org/title/OpenSSH#Force_public_key_authentication
https://wiki.archlinux.org/title/Google_Authenticator