执行需要交互的命令

这里思考sh分配tty和五交互模式，还有将输出打印到本地模式

```bash
ssh user@remoteNode "sudo ls /root"
sudo: sorry, you must have a tty to run sudo

ssh user@remoteNode "top"
TERM environment variable not set.
```

这两条命令虽然提示的失败原因不同，但它们有一个共同点：都需要与用户交互(需要 TTY)。所以它们失败的原因也是相同的：
默认情况下，当你执行不带命令的 ssh 连接时，会为你分配一个 TTY。因为此时你应该是想要运行一个 shell 会话。
但是当你通过 ssh 在远程主机上执行命令时，并不会为这个远程会话分配 TTY。此时 ssh 会立即退出远程主机，所以需要交互的命令也随之结束。
好在我们可以通过 -t 参数显式的告诉 ssh，我们需要一个 TTY 远程 shell 进行交互！
添加 -t 参数后，ssh 会保持登录状态，直到你退出需要交互的命令。

```bash
ssh user@remoteNode "sudo ls /root"
sudo: sorry, you must have a tty to run sudo   #必须分配一个终端
ssh -t user@remoteNode "sudo ls /root"
[sudo] password for user:        #加-t选项后成功，输入用户密码
```