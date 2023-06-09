pCap工具
https://www.zhihu.com/question/581458796/answer/2945152462?utm_id=0
- [tcpdump](https://www.tcpdump.org/)
- [eCapture](https://github.com/gojue/ecapture)
- [wireshark](https://www.wireshark.org/) 
  ssh+wireshark+tcpdump   
  `ssh root@192.168.1.10 -p 22 "tcpdump -i eth0 -n tcp port 8080 -s 0 -l -w -" | "wireshark.exe" -k -i -`
- [tshark](https://www.wireshark.org/docs/wsug_html_chunked/AppToolstshark.html)
- [portswigger](https://portswigger.net/burp)
- [charlesproxy](https://www.charlesproxy.com/)
- [telerik](https://www.telerik.com/fiddler)
- [proxyman](https://proxyman.io/)

在计算机网络管理中，pcap（packet capture）由捕获网络流量的应用程序编程接口（API）组成。类Unix的系统主要是在libpcap库中实现pcap，而Windows系统则是使用名为WinPcap的libpcap端口。

监控软件可能会使用libpcap或WinPcap捕获通过网络传播的数据包，并在较新版本中链路层的网络上传输数据包，以及获取可能与libpcap或WinPcap一起使用的网络接口列表。pcap API是用C编写的，所以其他语言，如Java，.NET语言以及脚本语言通常需要使用封装器，libpcap或WinPcap本身并不提供封装。而C++程序则可以直接链接到C API或使用面向对象的封装器。

libpcap和WinPcap提供了许多开源和商业网络工具的数据包捕获和过滤引擎，包括协议分析器（数据包嗅探器）、网络监视器、网络入侵检测系统、流量生成器和网络测试器。libpcap和WinPcap还支持将捕获的数据包保存到文件中，并读取包含保存的数据包的文件; 使用libpcap或WinPcap可以编写应用程序，就能够很好的捕获网络流量并对其进行分析，或使用相同的分析代码读取保存的捕获并进行分析。以libpcap和WinPcap使用的格式保存的捕获文件可以由能够读取该格式的应用程序（如tcpdump，Wireshark，CA NetMaster或Microsoft Network Monitor 3.x）进行读取。

libpcap和WinPcap创建和读取的文件格式的MIME类型为application / vnd.tcpdump.pcap。典型的文件扩展名是.pcap，除此之外.cap和.dmp也是常用的。

![](http://mmbiz.qpic.cn/mmbiz_png/wpkib3J60o2icic7CT4DWMr0AicoaOpIlhOfps0k9m1TJpeAiakGM3qoNvsYMpk9AI69DJ92Y58SMzG1vSKWZm0bibHg/0?wx_fmt=png)        流量监控

Nload

nload是个很好用的一个工具，功能也很强。只是相对单一，只能查看总的流量，不能像iptraf那样，可针对IP，协议等。可以实时地监控网卡的流量，分Incoming和Outgoing两部分，也就是流入与流出的流量。

Iftop

Iftop可以测量通过单个套接字连接流动的数据，它的工作方式与Nload不同。Iftop使用pcap库来捕获进出网络适配器的数据包，然后总结大小和计数，以查找正在使用的总带宽。虽然iftop可以报告单个连接使用的带宽，但它不能报告特定套接字连接中涉及的进程名称。但是，基于pcap库，iftop可以过滤流量并根据筛选器指定的所选主机连接报告带宽使用情况。

Jnettop

 Jnettop是一个流量显示器，它可以捕获通过其正在运行的主机的流量，并显示按带宽排序的流量。

Iptraf

Iptraf是一款互动多彩的IP Lan显示器，它可以显示单个连接和数据在主机之间流动的数量。

Nethogs

NetHogs是一个小型的net top工具,不像大多数工具那样拖慢每个协议或者是每个子网的速度而是按照进程进行带宽分组.NetHogs不需要依赖载入某个特殊的内核模块. 如果发生了网络阻塞你可以启动NetHogs立即看到哪个PID造成的这种状况.这样就很容易找出哪个程序跑飞了然后突然占用你的带宽。

Bmon

Bmon（Bandwidth Monitor）是一种类似于nload的工具，可以显示系统上所有网络接口的流量负载。其输出还包括一个图形和一个具有数据包级细节的部分。

Slurm

Slurm也是一个网络负载监视器，它可以显示设备统计信息以及ascii图。其支持3种不同风格的图形，每种都可以使用c、s和l键激活。不过，slurm不显示有关网络负载的任何进一步的细节。

Tcptrack

Tcptrack类似于iftop，并使用pcap库来捕获数据包并计算各种统计信息，比如每个连接中使用的带宽。它还支持可用于监视特定连接的标准pcap过滤器。

Vnstat

Vnstat与大多数其他工具有所不同。它实际上是在运行后台服务/守护进程，并始终记录数据传输的大小，依据此，它可以用于生成网络使用历史的报告。

Bwm-ng

Bwm-ng（下一代带宽监视器）是另一个非常简单的实时网络负载监视器，主要用于报告数据传输到系统中所有可用网络接口的速度的汇总。

CBM

一个小型的带宽监视器，可以通过网络接口显示流量。除此之外并没有其他选择，只是流量统计显示和实时更新。

Speedometer

一个小而简单的工具，可以通过一个给定的界面绘制出流量和流出量的好看图。

Pktstat

Pktstat可以实时显示所有活动连接，以及通过它们传输数据的速度。它还会显示连接的类型，即tcp或udp，以及有关http请求的详细信息。

Netwatch

Netwatch是netdiag工具集合的一部分，它也显示了本地主机和其他远程主机之间的连接以及数据在每个连接上传输的速度。

Trafshow

和netwatch和pktstat一样，trafshow可以报告当前的活动连接以及它们的协议和每个连接上的数据传输速度。除此之外，它可以使用pcap类型的过滤器过滤掉连接。

netload

netload命令只显示当前流量负载的小节，以及从程序启动以来传输的总字节数。除此之外它没有更多的功能，它是netdiag的一部分。

ifstat

ifstat能够以批量样式模式报告网络带宽。其输出的格式是使用其他程序或实用程序易于日志和解析的格式。

Dstat

Dstat是一个多功能工具（用python编写的），可以监视不同的系统统计信息，并以批量样式模式报告，或将数据记录到csv或类似文件。此示例显示如何使用dstat来报告网络带宽

Collectl

Collectl以类似于dstat的风格报告系统统计信息，像dstat一样，它收集了有关各种不同系统资源（如cpu，内存，网络等）的统计信息。以下简单介绍如何使用它来报告网络使用/带宽。

![](http://mmbiz.qpic.cn/mmbiz_png/wpkib3J60o2icic7CT4DWMr0AicoaOpIlhOfps0k9m1TJpeAiakGM3qoNvsYMpk9AI69DJ92Y58SMzG1vSKWZm0bibHg/0?wx_fmt=png)        流量捕获

Libpcap / Tcpdump

TcpDump可以将网络中传送的数据包完全截获下来提供分析。它支持针对网络层、协议、主机、网络或端口的过滤，并提供and、or、not等逻辑语句来帮助你去掉无用的信息。

Ngrep

Ngrep致力于提供GNU grep的大部分常见功能，并将其应用于网络层。ngrep是一个pcap感知工具，它允许你指定扩展的常规或十六进制表达式以匹配数据包的数据有效负载。目前其主要通过以太网，PPP，SLIP，FDDI，令牌环和空接口识别TCP，UDP和ICMP，并以与更常见的数据包嗅探工具（如tcpdump和snoop）相同的方式了解bpf过滤器逻辑。

TTT

Tele Traffic Tapper（TTT）是tcpdump的另一个后代，但它能够进行实时的图形和远程流量监控。ttt并不会替代tcpdump，而是可以帮助你更好的了解使用tcpdump的内容。它会监控网络，并在时间窗口内自动选择流量的主要贡献者。其图表默认情况下每秒更新一次。

n2disk

n2disk是网络流量记录器应用程序，其是具有索引功能的千兆网络流量记录器。使用n2disk，你可以从实时网络接口以千兆位速率（如果硬件足够支撑的话可以达到高于10000兆/秒）捕获全尺寸网络数据包，并将其写入文件而不会丢失任何数据包。n2disk的设计会使用于将文件写入磁盘的时间很长，你必须指定在执行过程中可能写入的不同文件的最大数量，并且如果n2disk达到最大文件数，则它将开始从最后的开始，你可以对固定的时间窗口内的流量进行完整的查看。

PF\_RINGPF\_RING

PF\_RING是一种新型的网络套接字，可显着提高数据包捕获速度，具有以下属性：可用于Linux内核2.6.32及更高版本。其不需要修补内核，只需加载内核模块。

jNetPcap

jNetPcap适用于Linux和Windows的Java数据包捕获库。jNetPcap可以直接使用libpcap WinPcap，也可以利用Java Native Interface（JNI）来使用libpcap / WinPcap提供的功能。

![](http://mmbiz.qpic.cn/mmbiz_png/wpkib3J60o2icic7CT4DWMr0AicoaOpIlhOfps0k9m1TJpeAiakGM3qoNvsYMpk9AI69DJ92Y58SMzG1vSKWZm0bibHg/0?wx_fmt=png)        流量分析

Wireshark

精心设计的工具套件支持数据包分析器和协议解码器。它还包括一些实用的工具和脚本从而可以使其支持大多数常见的用法。

WANDA

精心收集的基于libtrace构建的工具，可以用来处理网络流量。

Tcptrace

俄亥俄大学Shawn Ostermann写的一个工具，用于分析TCP转储文件。它可以输入由几个流行的数据包捕获程序生成的文件，包括tcpdump，snoop，etherpeek，HP Net Metrix以及WinDump。tcptrace可以产生几种不同类型的输出，其中包含每个链接上的信息，例如已发送和接收的经过时间，字节和段，重传，往返时间，窗口广告，吞吐量等。除此之外，它还可以生成一些图表进行进一步分析。

Tstat

是一个无源嗅探器，其能够通过大量流量特征为网络和传输层面的流量模式提供多种说明。

Tcpsplit

Tcpsplit会将单个libpcap数据包追踪分解为若干子追踪，其可沿TCP连接边界打破追踪，以使TCP连接不会跨两个子追踪分割。这对于使大型追踪文件很容易就可以进行深入分析和子集追踪，以及仅在部分追踪上进行分析非常有用。

Tcpflow

Tcpflow可以捕获作为TCP连接（流）的一部分传输的数据的程序，并以方便协议分析或调试的方式存储数据。像tcpdump这样的程序可以显示在线上看到的数据包的摘要，但通常不存储实际传输的数据。相比之下，tcpflow能够重建实际的数据流，并将每个流存储在一个单独的文件中供以后分析。

Tcpreplay

Tcpreplay可以使用libnet在接口上重播pcap文件。

Tcpstat

Tcpstat可以报告某些网络接口统计信息，非常像vmstat对系统统计信息。其可以通过监视特定接口或通过从文件读取以前保存的tcpdump数据来获取其信息。

Tcplook

Tracelook是一个Tcl / TK程序，用于以图形方式查看使用-w参数创建的追踪文件的内容到tcpdump。其应该能够查看所有协议，但目前只能够查看TCP连接。虽然程序缓慢，但却会使使用系统资源的效果非常出色。

Tcpdpriv

Tcpdpriv是能够从网络接口（或使用-w参数创建的追踪文件到tcpdump）收集的数据包中消除机密信息（用户数据和地址）的程序。Tcpdpriv可以删除TCP和UDP的有效载荷，以及其他协议的整个IP有效载荷。其实现了几种地址加扰方法; 顺序编号方法及其变体，以及具有保留地址前缀的散列方法。

Tcpslice

Tcpslice是用于提取使用tcpdump的-w标志生成的数据包追踪文件的部分的工具。它可以组合多个追踪文件，和/或基于时间提取一个或多个追踪的部分。

TCP-Reduce

TCP-Reduce是Bourne shell脚本的集合，用于将tcpdump追踪减少到追踪中存在的每个TCP连接的一行摘要，脚本仅查看TCP SYN / FIN / RST数据包。追踪中没有SYN数据包的连接（如追踪开始时的连接）不会在摘要中显示。报告的垃圾邮件（其中一些内容丢失）会通知给stderr为bogon，并被丢弃。有时候脚本会被重新传输然后改变了序列号，并且报告了错误连接的大小 ：总是检查大型连接（例如100 MB或更多）的可信度。

dpkt

Python数据包创建/解析库。

Pcap2har

使用库dpkt将.pcap网络捕获文件转换为HTTP存档文件的程序。

LibnetLibnet

这是收集例程以帮助构建和处理网络数据包。它为低级网络数据包整形，处理和注入提供了便携式框架。Libnet在IP层和链路层提供便携式数据包创建接口，以及一系列补充和补充功能。

LibnidsLibnids

由拉斐尔·沃杰彻苏克设计，是网络入侵检测系统的E-组件的实现。它可以模拟Linux 2.0.x的IP堆栈、并提供IP碎片整理、TCP流装配和TCP端口扫描检测。libnids最有价值的功能是可靠性，研究人员对其进行了一些测试，证明了libnids可以尽可能地预测受保护的Linux主机的行为。

ECapEcap

具有Web前端的分布式网络嗅探器。

HttpSniffer

一个多线程工具，用于从PCAP文件中嗅探TCP流统计信息和嵌入式HTTP头。携带HTTP的每个TCP流都以JSON格式导出到文本文件。

AIEngine

AIEngine是下一代互动/可编程数据包检测引擎，具有学习功能，无需任何人为干预。其具有NIDS功能，DNS域分类，网络收集器等等。AIEngine还帮助网络/安全专业人员识别流量并开发签名，以便在NIDS，防火墙，流量分类器等上使用它们。

Network Expect

Network Expect是一个允许轻松构建可与网络流量交互的工具的框架。根据脚本，可以将流量注入到网络中，并且可以基于接收到的网络流量进行决策并采取行动。解释语言提供分支和高级控制结构以指导与网络的交互。Network Expect使用libpcap进行数据包捕获和libwireshark（来自Wireshark项目）进行数据包解析任务。

Socket Sentry

Socket Sentry是一个KDE等离子体的实时网络流量监控器，与iftop和netstat等工具一样。

Sniff

能够使tcpdump程序的输出更容易阅读和解析的程序。

EtherApe

EtherApe是以太网模拟的Unix的图形网络监视器。具有链路层，IP和TCP模式，以图形方式显示网络活动，其中主机和链接的大小随流量而变化，并且是利用彩色编码协议来显示。它支持以太网，FDDI，令牌环，ISDN，PPP和SLIP设备。它可以过滤要显示的流量，并且可以从文件读取流量，也可以从网络中获取流量。

Snort

由Sourcefire开发的，现在由思科拥有的开源网络入侵防御和检测系统（IDS / IPS）。其结合了签名，协议和基于异常检测的优势，Snort是全球最广泛部署的IDS / IPS技术。拥有数百万的下载量和约50万注册用户，目前已成为IPS的实际标准。

ScapyScapy

强大的交互式数据包处理程序。它能够伪造或解码大量协议的数据包，将其发送到线上，捕获它们，匹配请求和回复等等。它可以轻松地处理大多数经典任务，如扫描，示踪，探测，单元测试，攻击或网络发现（可以替代hping，nmap的85％，arpspoof，arp-sk，arping，tcpdump，tethereal，p0f等）。在其他大多数工具无法处理的许多其他特定任务中也可以执行得很好，例如发送无效帧，注入自己的802.11帧，组合技术（VLAN跳频+ ARP缓存中毒，WEP加密通道上的VOIP解码... ）等

Bro

Bro是基于Unix的开放源代码网络入侵检测系统（NIDS），被动地监控网络流量并寻找可疑活动。Bro通过首先解析网络流量来提取其应用程序级语义，然后执行面向事件的分析器来检测入侵，该分析器将活动与被认为很麻烦的模式进行比较。其分析包括检测特定的攻击（包括由签名定义的攻击，以及由事件定义的攻击）和异常活动（例如，连接到某些服务的某些主机或连接尝试失败的模式）。

Ntop

Ntop是一个网络流量探测器，它能够显示网络使用情况，类似于那些受欢迎的顶级Unix命令。ntop是基于libpcap的，它以便携式方式编写，以便其可以在每个Unix平台和Win32上都能够运行。

CoralReef

CoralReef是由CAIDA开发的用于分析被动互联网流量监视器收集的数据的软件套件。它提供了一个编程库libcoral，类似于libpcap，具有ATM和其他网络类型的扩展，可从C和Perl获得。该软件目前支持使用OC3mon和OC12mon卡实时收集流量数据的专用PC盒，以及从pcap tracefiles读取。版本3.4即将发布，支持通过bpf启用的设备进行侦听。CoralReef包括驱动程序，分析，Web报表生成，示例和捕获软件。该包由CAIDA开发人员在互联网测量社区的支持和协作下维护。

Xplot

xplot是在20世纪80年代末写的，支持对TCP数据包追踪的分析。

Multitail

MultiTail 与 tail 程序比较相似，但其功能更为强大。MultiTail 支持通过在控制台创建多个窗格的形式来同时监视多个文件。不仅如此，MultiTail 还能截获其他程序的输出，并对日志文件进行合并以便更有效地被查看。另外，在使用 MultiTail 查看文件时，你也可以运用它的着色和过滤功能。

Netsniff-ng

Netsniff-ng是一个免费的Linux网络实用程序的工具包。

NetDude

Netdude（NETwork DUmp数据显示和编辑器）。从他们的网页你可以看到这样一句话，“它是一个基于GUI的工具，允许你对tcpdump tracefiles中的数据包进行详细更改。”

Libcrafter

Libcrafter是一个用于C++的高级库，旨在使网络数据包的创建和解码变得更简单。它能够制作或解码大多数常见网络协议的数据包，将其发送到线上，捕获并匹配请求和回复。

WinPcap

来自Guy Harris的WinPcap和WinDump状态的消息摘录。

Sniffer

嗅探器产品系列涵盖了不同的应用领域（分布式，便携式和无线环境）。嗅探器解决方案监控，排除故障，分析，报告和主动管理网络性能。它们确保了整个企业基础架构（包括所有LAN，WAN和高速拓扑）的峰值性能，从10/100以太网到最新的高速异步ATM，千兆和Packet-over SONET（PoS）骨干网。

Sanitize

Sanitize是五个Bourne shell脚本的集合，可用于减少tcpdump追踪，通过重新编号主机和剥离数据包内容以解决安全性和隐私问题。其每个脚本都会将tcpdump追踪文件作为输入，并以固定列格式生成缩小的ASCII文件。

Ipsumdump

ipsumdump程序将TCP / IP转储文件归结为易于由人类和程序读取的自描述ASCII格式。Ipsumdump可以从网络接口，tcpdump文件和现有的ipsumdump文件读取数据包。它将在必要时透明地解压缩tcpdump或ipsumdump文件。它可以随机抽取流量，根据其内容过滤流量，匿名IP地址，并按时间戳对来自多个转储的数据包进行排序。此外，它可以可选地创建一个包含实际数据包数据的tcpdump文件，并且使用CLICK作为插入模块也很方便。

Ntopng

Ntopng是原始ntop的下一代版本，一个显示网络使用情况的网络流量探测器，类似于受欢迎的顶级Unix命令。ntop基于libpcap，它以便携式方式编写，以便在每个Unix平台，MacOSX和Win32上虚拟运行。 

![](http://mmbiz.qpic.cn/mmbiz_png/wpkib3J60o2icic7CT4DWMr0AicoaOpIlhOfps0k9m1TJpeAiakGM3qoNvsYMpk9AI69DJ92Y58SMzG1vSKWZm0bibHg/0?wx_fmt=png)        文件提取

Xplico

Xplico的目标是从互联网流量中提取捕获所包含的应用数据。例如，从pcap文件Xplico提取每个邮件（POP，IMAP和SMTP协议），所有HTTP内容，每个VoIP呼叫（SIP）、FTP、TFTP等。Xplico不是网络协议分析器。Xplico是一个开源网络法医分析工具（NFAT）。Xplico根据GNU通用公共许可证发布，并在Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported（CC BY-NC-SA 3.0）许可证下发布了一些脚本。

Justniffer

Justniffer是一个网络协议分析器，可以捕获网络流量并以自定义的方式生成日志，还可以模拟Apache Web服务器日志文件，追踪响应时间，并从HTTP流量中提取所有“截取”文件。

NetworkMiner

NetworkMiner是Windows的网络取证分析工具（NFAT）（也可用于Linux / Mac OS X / FreeBSD）。NetworkMiner可以用作被动网络嗅探器/数据包捕获工具，以便检测操作系统，会话，主机名，打开端口等，而不会在网络上造成任何流量。NetworkMiner还可以解析PCAP文件以进行离线分析，并从PCAP文件重新生成/重组传输的文件和证书。

Tcpxtract

Tcpxtract是一种基于文件签名从网络流量中提取文件的工具。基于文件类型的页眉和页脚（有时称为“雕刻”）提取文件是一种古老的数据恢复技术。Foremost这样的工具使用这种技术可以从任意数据流中恢复文件，其是专门用于通过网络传输的拦截文件的应用。填补类似需求的其他工具有流网和EtherPEG。driftnet和EtherPEG是用于在网络上监控和提取图形文件的工具，网络管理员通常使用它来警告用户的互联网活动。driftnet和EtherPEG的主要局限性在于它们只支持三种文件类型，不需要添加更多方法。他们使用的搜索技术也是不可扩展的，不会跨数据包边界搜索。

Foremost

Foremost是一个控制台程序，可以根据头文件，页脚和内部数据结构来恢复文件。这个过程通常被称为数据雕刻。最重要的是可以处理图像文件，例如由dd，Safeback，Encase等生成的文件，或直接在驱动器上。页眉和页脚可由配置文件指定，也可以使用命令行开关指定内置文件类型。这些内置类型查看给定文件格式的数据结构，从而实现更可靠和更快速的恢复。

Dsniff

Dsniff是网络审计和渗透测试工具的集合。dsniff、filesnarf、mailsnarf、msgsnarf、urlsnarf以及webspy可以被动地监视网络以获取有趣的数据（密码，电子邮件，文件等）；arpspoof、dnsspoof和macof则能够拦截通常对攻击者不可用的网络流量（例如，由于第2层切换所产生的）。sshmitm和webmitm则能够通过利用ad-hoc PKI中的弱绑定来实现对重定向的SSH和HTTPS会话的“monkey-in-the-middle”攻击。

Chaosreade

Chaosreader是可以追踪TCP / UDP 等会话并从snoop或tcpdump日志中获取应用程序数据的免费工具。这是一种“任意蛇”程序，因为它将从网络流量日志中捕获的数据获取telnet会话，FTP文件，HTTP传输（HTML，GIF，JPEG，...），SMTP电子邮件等。其可以创建一个链接到所有会话详细信息的html索引文件，包括用于telnet，rlogin，IRC，X11和VNC会话的实时重播程序，并生成图像报告和HTTP GET / POST内容报告。Chaosreader也可以在独立模式下运行—调用tcpdump或snoop（如果可用的话）来创建日志文件，然后处理它们。

Tcpick

Tcpick是一种基于文本模式嗅探器的libpcap，可以追踪、重组和重新排序tcp流。Tcpick能够将捕获的流保存在不同的文件中，或者将它们显示在终端中，因此可以通过ftp或http来传输文件。当连接在不同的显示模式下关闭时，可以显示终端上的所有流，如hexdump，hexdump，ascii，只能打印字符串，而它则可以使用raw模式以及颜色模式，这有助于阅读并更好地理解程序的输出。实际上它可以处理几个接口，包括以太网卡和ppp，追踪网络用户正在做什么是很有用的，并且可以与grep，sed，awk等文本模式工具一起使用。
