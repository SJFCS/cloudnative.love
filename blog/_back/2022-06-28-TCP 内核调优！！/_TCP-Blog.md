## Linux 内核调优 —— TCP 篇
net.ipv4.tcp_syncookies=1 是一个Linux内核参数设置，用于开启或关闭 TCP SYN cookies 机制。

为了理解 TCP SYN cookies 的作用，需要了解一点网络背景知识。当一个 TCP 连接建立时，它开始于一个被称为三次握手（SYN, SYN-ACK, ACK）的过程。在握手的开始阶段，客户端发送一个 SYN (synchronize) 消息到服务器。服务器收到 SYN 消息后，就保留了一些状态信息，并回复一个 SYN-ACK (synchronization acknowledged) 消息。在这个过程中，服务器为每一个尝试建立的连接保存状态，可能占用大量资源。

SYN flood 攻击就利用这个特点，发送大量伪造的 SYN 消息到服务器，快速耗尽服务器资源，导致合法用户无法连接服务器。为应对这种攻击，就有了 TCP SYN cookies 技术。

当被设置为 net.ipv4.tcp_syncookies=1，TCP SYN cookies 会在服务器接收到 SYN 消息，但它的半连接队列（这是服务器保存连接状态的地方）已满时启用。使用 SYN cookies，服务器不在 SYN-ACK 处保存状态。相反，它会在返回 SYN-ACK 时包含一个编码的“cookie”信息。如果客户端回复一个包含此 cookie 的 ACK，服务器就能重新建立状态并接受连接。这样就可以在 SYN flood 攻击下明显提高服务器的处理能力。

但这个机制并非完美，SYN cookies 的使用会限制一些 TCP 的高级特性，例如窗口扩大（Window Scaling）和时间戳选项（Timestamps）。因此，它在正常环境下通常是关闭的，仅在检测到可能存在 SYN flood 攻击时临时开启。




## TFO
TFO（TCP Fast Open）是一种 TCP（传输控制协议）的扩展，其主要目的是减少建立 TCP 连接时的网络往返延迟。在传统的 TCP 协议中，通信的两端需要进行三次握手的过程（发送SYN，接收SYN-ACK，发送ACK）来建立连接，然后才可以开始传输数据。这个过程会需要至少一个完整的网络往返时间（RTT）。

TFO 通过在 TCP 的 SYN 包中添加一个新的选项（Fast-Open Cookie）来改进这个过程。在第一次连接中，服务器会给客户端发送一个 TFO Cookie。然后客户端在后续的连接中可以将这个 Cookie 以及数据一同在 SYN 包中发送给服务器。如果服务器验证了这个 Cookie 是有效的，那么它就会立即提取并处理这个 SYN 包中的数据，而不需要等待三次握手过程完之后再开始数据的传输。这样就可以减少了一个RTT，提高了连接的启动速度。

但也值得注意的是，由于这个特性可能会被恶意利用来进行重放攻击或者绕过防火墙，因此在实际部署中需要谨慎考虑。只有在对端也支持 TFO，并且网络环境可信任的情况下，才建议开启这个特性。

你可以通过在 Linux 中设置内核参数 net.ipv4.tcp_fastopen 来控制 TFO 的行为。需要注意的是，使用这个特性可能需要更新软件和库以支持新的 TCP 选项。





## 队列
https://www.veitor.net/posts/syn-queue-and-accept-queue/
https://blog.cloudflare.com/syn-packet-handling-in-the-wild/


模拟洪水
sudo hping3 -c 1000 192.168.8.100 -p 6443 -a 10.1.1.1 -S --flood

❯ sudo wrk -t 10 -c 200000 -d 30s http://127.0.0.1:8080


https://www.cnblogs.com/xiaolincoding/p/12995358.html
https://www.cnblogs.com/kumufengchun/p/15893977.html
