---
title: OpenSSH✨
---
- https://huataihuang.gitbooks.io/cloud-atlas/content/service/ssh/ssh_use_specific_key_and_ssh-keygen.html
- https://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html
- https://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html
- https://www.cnblogs.com/keerya/p/7612715.html
- https://www.cnblogs.com/f-ck-need-u/p/7129122.html#auto_id_2
- https://www.cnblogs.com/ftl1012/p/ssh.html

```bash
ssh -o BatchMode=yes -o StrictHostKeyChecking=yes vagrant@node2

SSH 的 BatchMode=yes 选项指示 SSH 客户端在连接远程主机时不需要任何交互式输入，即使出现任何提示或错误，也不会中断 SSH 连接。这在自动化脚本或批处理程序中非常有用，因为它允许 SSH 连接在不需要人工干预的情况下进行。


当 BatchMode=yes 选项设置为 yes 时，SSH 客户端不会尝试在连接远程主机时询问任何问题，例如确认主机的指纹或输入密码。如果连接失败，SSH 客户端也不会显示任何错误消息，而是直接退出。因此，在使用 BatchMode=yes 选项时，您需要确保 SSH 客户端已经配置好所需的身份验证信息和主机指纹，以确保 SSH 连接的成功。
```

SSH 登陆一台新主机时，会提醒我们检查主机密钥的指纹。 不过怎么查看主机密钥的指纹呢？用什么命令？ 这个问题显然不是第一次被问到，一篇 2008 年的文章 就指出了答案： 在新主机上运行命令

ssh-keygen -l -f ~/.ssh/id_rsa

-l 选项指示打印公钥的指纹。-f 指定公钥文件。 对于 RSA、DSA 密钥而言，不必须指定公钥文件，命令会自动寻找匹配文件。

查看主机密钥的指纹的命令居然字面意思是生成密钥，的确不太直观。 无独有偶，我们还知道删除 SSH 密钥的命令叫 ssh-add。
```bash
ssh-agent bash
ssh-add <ssh-key-path>
# ssh-agent bash: 启动 SSH 代理并打开一个新的 shell 环境。SSH 代理是一个进程，它可以管理用户的 SSH 密钥并使得用户不需要重复地输入密码进行 SSH 认证。在使用 SSH 连接时，每次需要使用私钥进行认证操作，使用 SSH 代理可以减少重复输入密码的次数，并提高 SSH 连接的安全性。

# ssh-add <ssh-key-path>：将指定路径下的 SSH 密钥加载到 SSH 代理中。在使用 SSH 代理时，需要手动将 SSH 密钥添加到代理中，才能使用代理进行 SSH 认证操作。只要 SSH 代理存活（例如使用 ssh-agent bash 命令开启的代理），则添加的 SSH 密钥会一直保存在代理中，直到代理被关闭或密钥被手动删除。

# ansible [pattern] -m [module] -u [remote user] -a "[module options]"
# -u root     # 使用 root 账户登录远程主机，这个对应前面 playbook 中的 remote_user
# all         # [pattern]，all 表示选中 my-hosts 中的所有主机
# -m [module] # 指定使用的 ansible 模块，默认使用 `command`，即在远程主机上执行 -a 参数中的命令
# -a "ls -al"    # 指定 module 的参数，这里是提供给 `command` 模块的参数。
```

为什么 ssh 密钥默认为 600 而不是 400？authorized_keys 不可变？
- https://www.reddit.com/r/linux4noobs/comments/bjpbnl/why_are_ssh_keys_600_and_not_400_by_default/

你真的了解authorized_keys 么？
- https://www.503error.com/2020/%E4%BD%A0%E7%9C%9F%E7%9A%84%E4%BA%86%E8%A7%A3authorized_keys-%E4%B9%88%EF%BC%9F/1718.html
- https://www.ibm.com/docs/en/zos/2.3.0?topic=daemon-format-authorized-keys-file


https://wangdoc.com/ssh/client
本文对SSH连接验证机制进行了非常详细的分析，还详细介绍了"Shell基本功能"和了解"公钥加密"的概念。，相信能让各位对ssh有个全方位较透彻的了解，而不是仅仅只会用它来连接远程主机。



参考文章：

> [第1章 ssh命令和SSH服务详解](https://www.cnblogs.com/f-ck-need-u/p/7129122.html)
>
> [SSH原理与运用（一）：远程登录](https://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)
>
> [SSH原理与运用（二）：远程操作与端口转发](https://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html)

## 1.1 非对称加密基础知识

1. **对称加密：加密和解密使用一样的算法，只要解密时提供与加密时一致的密码就可以完成解密。**例如QQ登录密码，银行卡密码，只要保证密码正确就可以。

2. **非对称加密：**通过公钥(public key)和私钥(private key)来加密、解密。公钥加密的内容可以使用私钥解密，私钥加密的内容可以使用公钥解密。一般使用公钥加密，私钥解密，但并非绝对如此，例如CA签署证书时就是使用自己的私钥加密。在接下来介绍的SSH服务中，虽然一直建议分发公钥，但也可以分发私钥。

所以，如果A生成了(私钥A，公钥A)，B生成了(私钥B，公钥B)，那么A和B之间的非对称加密会话情形包括：

1. A将自己的公钥A分发给B，B拿着公钥A将数据进行加密，并将加密的数据发送给A，A将使用自己的私钥A解密数据。
2. A将自己的公钥A分发给B，并使用自己的私钥A加密数据，然后B使用公钥A解密数据。
3. B将自己的公钥B分发给A，A拿着公钥B将数据进行加密，并将加密的数据发送给B，B将使用自己的私钥B解密数据。
4. B将自己的公钥B分发给A，并使用自己的私钥B加密数据，然后A使用公钥B解密数据。

虽然理论上支持4种情形，但在SSH的**身份验证阶段，SSH只支持服务端保留公钥，客户端保留私钥的方式，**所以方式只有两种：

1. 客户端生成密钥对，将公钥分发给服务端；
2. 服务端生成密钥对，将私钥分发给客户端。只不过出于安全性和便利性，一般都是客户端生成密钥对并分发公钥。后文将给出这两种分发方式的示例。

## 1.2 SSH概要

1. SSH是传输层和应用层上的安全协议，它只能通过加密连接双方会话的方式来保证连接的安全性。当使用ssh连接成功后，将建立客户端和服务端之间的会话，该会话是被加密的，之后客户端和服务端的通信都将通过会话传输。
2. SSH服务的守护进程为sshd，默认监听在22端口上。
3. 所有ssh客户端工具，包括ssh命令，scp，sftp，ssh-copy-id等命令都是借助于ssh连接来完成任务的。也就是说它们都连接服务端的22端口，只不过连接上之后将待执行的相关命令转换传送到远程主机上，由远程主机执行。
4. ssh客户端命令(ssh、scp、sftp等)读取两个配置文件：全局配置文件/etc/ssh/ssh_config和用户配置文件~/.ssh/config。实际上命令行上也可以传递配置选项。它们生效的优先级是：命令行配置选项 > ~/.ssh/config > /etc/ssh/ssh_config。
5. ssh涉及到两个验证：主机验证和用户身份验证。通过主机验证，再通过该主机上的用户验证，就能唯一确定该用户的身份。一个主机上可以有很多用户，所以每台主机的验证只需一次，但主机上每个用户都需要单独进行用户验证。
6. ssh支持多种身份验证，最常用的是密码验证机制和公钥认证机制，其中公钥认证机制在某些场景实现双机互信时几乎是必须的。虽然常用上述两种认证机制，但认证时的顺序默认是`gssapi-with-mic,hostbased,publickey,keyboard-interactive,password`。注意其中的主机认证机制hostbased不是主机验证，由于主机认证用的非常少(它所读取的认证文件为/etc/hosts.equiv或/etc/shosts.equiv)，所以网络上比较少见到它的相关介绍。总的来说，通过在ssh配置文件(注意不是sshd配置文件)中使用指令PreferredAuthentications改变认证顺序不失为一种验证的效率提升方式。
7. ssh客户端其实有不少很强大的功能，如端口转发(隧道模式)、代理认证、连接共享(连接复用)等。
8. ssh服务端配置文件为/etc/ssh/sshd_config，注意和客户端的全局配置文件/etc/ssh/ssh_config区分开来。
9. 很重要却几乎被人忽略的一点，**ssh登录时会请求分配一个伪终端**。但有些身份认证程序如sudo可以禁止这种类型的终端分配，导致ssh连接失败。例如使用ssh执行sudo命令时sudo就会验证是否要分配终端给ssh。

## 1.3  SSH 加密验证方法

SSH之所以能够保证安全，原因在于它采用了公钥加密。过程如下：

1. 远程主机收到用户的登录请求，把自己的公钥发给用户。
2. 用户使用这个公钥，将登录密码加密后，发送回来。
3. 远程主机用自己的私钥，解密登录密码，如果密码正确，就同意用户登录。

这个过程本身是安全的，但是实施的时候存在一个风险：如果有人截获了登录请求，然后冒充远程主机，将伪造的公钥发给用户，那么用户很难辨别真伪。因为不像https协议，SSH协议的公钥是没有证书中心（CA）公证的。

可以设想，如果攻击者插在用户与远程主机之间（比如在公共的wifi区域），用伪造的公钥，获取用户的登录密码。再用这个密码登录远程主机，那么SSH的安全机制就荡然无存了。这种风险就是著名的["中间人攻击"](http://en.wikipedia.org/wiki/Man-in-the-middle_attack)（Man-in-the-middle attack）。

**SSH协议是如何应对的呢？**

### 1.3.1 口令登录

如果你是第一次登录对方主机，系统会出现下面的提示：

```bas
    $ ssh user@host
    The authenticity of host 'host (12.18.429.21)' can't be established.
    RSA key fingerprint is 98:2e:d7:e0:de:9f:ac:67:28:c2:42:2d:37:16:58:4d.
    Are you sure you want to continue connecting (yes/no)?
```

这段话的意思是，无法确认host主机的真实性，只知道它的公钥指纹，问你还想继续连接吗？

所谓"公钥指纹"，是指公钥长度较长（这里采用RSA算法，长达1024位），很难比对，所以对其进行MD5计算，将它变成一个128位的指纹。上例中是98:2e:d7:e0:de:9f:ac:67:28:c2:42:2d:37:16:58:4d，再进行比较，就容易多了。

很自然的一个问题就是，用户怎么知道远程主机的公钥指纹应该是多少？回答是没有好办法，远程主机必须在自己的网站上贴出公钥指纹，以便用户自行核对。

假定经过风险衡量以后，用户决定接受这个远程主机的公钥。

```bas
Are you sure you want to continue connecting (yes/no)? yes
```

系统会出现一句提示，表示host主机已经得到认可。

```bas
Warning: Permanently added 'host,12.18.429.21' (RSA) to the list of known hosts.
```

然后，会要求输入密码。

```bas
　Password: (enter password)
```

如果密码正确，就可以登录了。

当远程主机的公钥被接受以后，它就会被保存在文件`~/.ssh/known_hosts`之中。

每个SSH用户都有自己的known_hosts文件，此外系统也有一个这样的文件，通常是`/etc/ssh/ssh_known_hosts`，保存一些对所有用户都可信赖的远程主机的公钥。

连接这台主机，会读取`~/.ssh/known_hosts`文件和`/etc/ssh/known_hosts`文件，搜索是否有对应的主机信息(host key，表示主机身份标识)。

1. 没有搜索到对应该地址的host key，则询问是否保存主机B发送过来的host key，
2. 如果搜索到了该地址的host key，则将此host key和主机B发送过来的host key做比对，
   1. 如果完全相同，则表示主机A曾经保存过主机B的host key，无需再保存，直接进入下一个过程——身份验证，
   2. 如果不完全相同，则提示是否保存主机B当前使用的host key。

### 1.3.2 公钥登录

使用密码登录，每次都必须输入密码，非常麻烦。好在SSH还提供了公钥登录，可以省去输入密码的步骤。

所谓"公钥登录"，原理很简单，就是用户将自己的公钥储存在远程主机上。登录的时候，远程主机会向用户发送一段随机字符串，用户用自己的私钥加密后，再发回来。远程主机用事先储存的公钥进行解密，如果成功，就证明用户是可信的，直接允许登录shell，不再要求密码。

这种方法要求用户必须提供自己的公钥。如果没有现成的，可以直接用ssh-keygen生成一个：

```bas
　$ ssh-keygen
```

运行上面的命令以后，系统会出现一系列提示，可以一路回车。其中有一个问题是，要不要对私钥设置口令（passphrase），如果担心私钥的安全，这里可以设置一个。

运行结束以后，在$HOME/.ssh/目录下，会新生成两个文件：id_rsa.pub和id_rsa。前者是你的公钥，后者是你的私钥。

这时再输入下面的命令，将公钥传送到远程主机host上面：

```bash
　$ ssh-copy-id user@host
```

好了，从此你再登录，就不需要输入密码了。

如果还是不行，就打开远程主机的/etc/ssh/sshd_config这个文件，检查下面几行前面"#"注释是否取掉。

```bash
    RSAAuthentication yes
    PubkeyAuthentication yes
    AuthorizedKeysFile .ssh/authorized_keys
```

然后，重启远程主机的ssh服务。

### 1.3.3 authorized_keys文件

远程主机将用户的公钥，保存在登录后的用户主目录的$HOME/.ssh/authorized_keys文件中。公钥就是一段字符串，只要把它追加在authorized_keys文件的末尾就行了。

这里不使用上面的ssh-copy-id命令，改用下面的命令，解释公钥的保存过程：

```bash
    $ ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub
```

这条命令由多个语句组成，依次分解开来看：

+ `ssh user@host`，表示登录远程主机；
+ `mkdir -p .ssh && cat >> .ssh/authorized_keys`，表示登录后在远程shell上执行的命令：
+ ` mkdir -p .ssh`的作用是，如果用户主目录中的.ssh目录不存在，就创建一个；
+ `cat >> .ssh/authorized_keys < ~/.ssh/id_rsa.pub`的作用是，将本地的公钥文件~/.ssh/id_rsa.pub，重定向追加到远程文件authorized_keys的末尾。

写入authorized_keys文件后，公钥登录的设置就完成了。

## 2.1本地端口转发

有时，绑定本地端口还不够，还必须指定数据传送的目标主机，从而形成点对点的"端口转发"。为了区别后文的"远程端口转发"，我们把这种情况称为"本地端口转发"（Local forwarding）。

假定host1是本地主机，host2是远程主机。由于种种原因，这两台主机之间无法连通。但是，另外还有一台host3，可以同时连通前面两台主机。因此，很自然的想法就是，通过host3，将host1连上host2。

我们在host1执行下面的命令：

```bash
    $ ssh -L 2121:host2:21 host3
```

命令中的L参数一共接受三个值，分别是"本地端口:目标主机:目标主机端口"，它们之间用冒号分隔。这条命令的意思，就是指定SSH绑定本地端口2121，然后指定host3将所有的数据，转发到目标主机host2的21端口（假定host2运行FTP，默认端口为21）。

这样一来，我们只要连接host1的2121端口，就等于连上了host2的21端口。

```bash
    $ ftp localhost:2121
```

"本地端口转发"使得host1和host3之间仿佛形成一个数据传输的秘密隧道，因此又被称为"SSH隧道"。

下面是一个比较有趣的例子。

```bash
    $ ssh -L 5900:localhost:5900 host3
```

它表示将本机的5900端口绑定host3的5900端口（这里的localhost指的是host3，因为目标主机是相对host3而言的）。

另一个例子是通过host3的端口转发，ssh登录host2。

```bash
    $ ssh -L 9001:host2:22 host3
```

这时，只要ssh登录本机的9001端口，就相当于登录host2了。

```bash
    $ ssh -p 9001 localhost
```

上面的-p参数表示指定登录端口。

## 2.2 远程端口转发

既然"本地端口转发"是指绑定本地端口的转发，那么"远程端口转发"（remote forwarding）当然是指绑定远程端口的转发。

还是接着看上面那个例子，host1与host2之间无法连通，必须借助host3转发。但是，特殊情况出现了，host3是一台内网机器，它可以连接外网的host1，但是反过来就不行，外网的host1连不上内网的host3。这时，"本地端口转发"就不能用了，怎么办？

解决办法是，既然host3可以连host1，那么就从host3上建立与host1的SSH连接，然后在host1上使用这条连接就可以了。

我们在host3执行下面的命令：

```bash
    $ ssh -R 2121:host2:21 host1
```

R参数也是接受三个值，分别是"远程主机端口:目标主机:目标主机端口"。这条命令的意思，就是让host1监听它自己的2121端口，然后将所有数据经由host3，转发到host2的21端口。由于对于host3来说，host1是远程主机，所以这种情况就被称为"远程端口绑定"。

绑定之后，我们在host1就可以连接host2了：

```bash
    $ ftp localhost:2121
```

这里必须指出，"远程端口转发"的前提条件是，host1和host3两台主机都有sshD和ssh客户端。