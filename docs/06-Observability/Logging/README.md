# Logging

kubernetes 集群的日志收集与分析方案，目前主要有两个：
[VictoriaLogs ](https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247508401&idx=1&sn=9d5e81332aa8672305205a1db0e6b1e1&chksm=fdbaaeaccacd27baf5e818b7c395f1b3bdf86e39640e0946a7980eb06c5c4cc3c1413d9de947&mpshare=1&srcid=0629qCg6NJDEli6mtQEEQt3k&sharer_sharetime=1688027602712&sharer_shareid=9b996575050d80b9b16b938075c280c4&from=timeline&scene=2&subscene=1&clicktime=1688032817&enterid=1688032817&sessionid=0&ascene=2&fasttmpl_type=0&fasttmpl_fullversion=6722933-zh_CN-zip&fasttmpl_flag=0&realreporttime=1688032817507&devicetype=android-33&version=28002639&nettype=3gnet&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQlD0JqrflNanz0fkgNTvgqxLvAQIE97dBBAEAAAAAAHE4DFjQDvgAAAAOpnltbLcz9gKNyK89dVj0v1N0zk1IZ56i2zmqRcqODvemRwjLmBwfrSaC2%2FlBivSBamrf%2B7n%2FOe8s9ATmD5U5sXm%2Bj%2FkQjqM2fjuvxpOTO4UOTUuxif%2BrSwXQLdBBORPKKI2l0U3aK4mjsCXGFraJhIm9RyTCm03Ib44Xl%2Fv9tnN4zjuZaBQ9vyU8Ws9LIFdvWB74xq2fSZKgvOQr2SWjOd8ALy%2FGg9u0yib1XSO40FQjjTu6J846nXerL4MzVYk910oKafmV6sVznSuvwEbhLaWKNrC81U0%2F&pass_ticket=YXFMw02bp8ImbxNcOelPN0Z%2FBimSNCtNRnj3XC3Bmc1547TX4knDKPV8kzVoleos&wx_header=3)

[有赞百亿级日志系统架构设计](https://zhuanlan.zhihu.com/p/62438446)

[持续降本：B站日志平台3.0演进之路](https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247508324&idx=1&sn=7e2fbbf9314735ca5a66b64e213899af&chksm=fdbaae79cacd276fc43cc6f14d34bc37a88d59e0b7efb654e3ffb93163be51bf1425fea1ddb3&mpshare=1&srcid=0623XWr67XiWTrsXBatcOBzU&sharer_sharetime=1687521815800&sharer_shareid=9b996575050d80b9b16b938075c280c4&from=timeline&scene=2&subscene=1&clicktime=1687677906&enterid=1687677906&sessionid=0&ascene=2&fasttmpl_type=0&fasttmpl_fullversion=6722933-zh_CN-zip&fasttmpl_flag=0&realreporttime=1687677906244&devicetype=android-33&version=2800255b&nettype=WIFI&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQhqnmaDHe8jwY9kQCsh1TIRLvAQIE97dBBAEAAAAAAFg6NLSXSOkAAAAOpnltbLcz9gKNyK89dVj0xfT5fnG0IVuNrMTErmlkYypy5gyprOOBVSiFGMq6WFGbO6jJAKVQEf8vaV%2B9nK2swFdC5r5rfVw0lV334R47%2F6tTmLP1Y2FSUTNvu9JcRkJdqK2blZiHBgiWDS4dX32shXgYMiCEY4o3WOl84KjAX0EfctQXV7D1mGZLiz1gnI%2F4eCdPInY6XYDEWTDmHI0puAURPHH32u%2FwNvhGk%2F3lYr2ZlVZPRSt5Xb2UL5luNOD5wnwiUoSMffTldmuST2soKd7G7i7uy0e2&pass_ticket=%2Bn0gPRt0wA4jC5%2B6pI4uyURfLZh8%2FYnci%2BHlmr5tQ1F46mxx3G0zRUX4wnWsXb0T&wx_header=3)


1. EFK: 传统的日志收集与分析方案，用户量巨大。但是比较重，而且吃性能。
2. loki: grafanalab 出品的新一代日志收集方案。参照 Prometheus 的思路给日志打标签，不提供全文检索。

这里提供两种方案的部署，具体的对比参见 loke 官方文档：[Loki/Promtail/Grafana vs EFK](https://grafana.com/docs/loki/latest/overview/comparisons/)


## 日志是否落盘

在日志量很大的情况下，日志先写入本地磁盘，再通过 fluentd 等 agent 采集日志，对磁盘 IO 会有很大压力，整体性能不高。

如果遇到这种情况，建议将业务容器的日志组件直接对接日志系统，日志直接用 UDP 协议发送到后端，这样做性能会有一个很大的提升。
但是缺点就是，日志可能会因为网络问题、日志接收端负载等问题发生丢失。另一方面日志就只能通过日志系统查看了，`kubectl log` 将无法查看到任何日志。


https://www.51cto.com/article/595529.html


## 相关文档

- [9个技巧，解决K8s中的日志输出问题](https://zhuanlan.zhihu.com/p/114510384)


- [Linux 系统日志](https://linux.vbird.org/linux_basic/centos7/0570syslog.php)


https://devconnected.com/the-definitive-guide-to-centralized-logging-with-syslog-on-linux/

https://devconnected.com/linux-logging-complete-guide/




logger "ex200 in progress"
AI
这个命令将用来向系统日志中添加一条信息，该信息内容为 "ex200 in progress"。系统日志可以通过运行 dmesg 或者 journalctl -k 命令来查看。

通常情况下，开发人员可以在他们的脚本文件中添加 logger 命令作为一个实用工具，以便在调试和发布脚本时记录事件的状态和时刻。此外，系统管理员也可以使用 logger 命令来记录系统事件以及运行中的错误，这有助于监测系统的运作，发现问题并进行故障排除。




dmesg 或者 journalctl -k 区别
AI
dmesg 和 journalctl -k 都可以用于在 Linux 系统上查看内核的日志，但其工作方式略有不同。

dmesg 命令会显示系统启动后从内核缓冲区中读取的所有信息。这包括内核引导信息、硬件信息，以及一些内核相关的警告和错误。 这里需要注意，dmesg显示的是缓冲区的内容，而非永久存储在磁盘上的日志文件。所以，如果重启了系统，再次运行 dmesg 将会清除之前的所有日志，重新开始记录。

journalctl -k 命令是由 systemd 守护程序提供的一个利用 systemd-journald 的工具，可用于查看系统启动后记录的所有内核日志。 除了内核消息，journalctl 还记录了各种系统和进程日志，因此可以通过各种过滤器，筛选出自己想要的日志信息。使用journalctl -k时，只会显示内核相关的日志信息。

总的来说，dmesg 更偏向于查看内核启动期间的消息，而 journalctl -k 则是更全面的查看内核和系统日志的方式。





1. OpenObserve
OpenObserve 是一个基于 Rust 的开源平台，可以通过支持日志、指标和追踪来满足你所有的可观察性需求。它的目标是提供一个平台，该平台可以替代 Prometheus 用于指标、Elasticsearch 用于日志、Jaeger 用于链路追踪、Grafana 用于仪表板等，并且他还可以和 S3、GCS、Minio、Azure Blob 等对象存储服务兼容使用，比 Elasticsearch 低 140 倍的存储成本。

使用 OpenObserve，你不需要学习新的查询语言来查询日志，因为它支持 SQL 作为其主要的日志和追踪查询语言，以及 PromQL 用于查询指标数据。它也非常容易安装和操作，由于其基于 Rust 来编写的，所以它只需要很少的资源来运行。

它还提供了一个直观且易于使用的 UI 界面，允许你管理和可视化你正在收集的各种可观察性数据。在摄取或查询时，你可以丰富、解析、删除敏感数据，并删除日志的不需要的部分，以便只留下相关的部分。

OpenObserve 还提供了一个内置的报警机制，可以将警报发送到 Slack、Microsoft Teams 和其他渠道。它还支持团队成员之间的协作，并使用基于角色的访问控制来根据团队成员的级别控制对数据的访问，确保你的数据的整体安全。

OpenObserve 的优点

在一个包中提供日志、指标、链路追踪、仪表板、报警和函数支持。
免费计划提供每月 200GB 的摄取和 15 天的保留。
支持日志查询的 SQL 和指标的 PromQL。
团队的基于角色的访问控制。
由于其高效的数据存储过程，存储成本要低得多。
用 Rust 编写以获得高性能。
OpenObserve 的缺点

作为一个相对较新的产品，它没有像其他已经存在了更长时间的解决方案那样经过长时间的测试。
在撰写本文时，对日志和链路追踪的支持比指标更成熟。
2. Grafana Loki

Loki 是由 Grafana 团队制作的一个日志管理系统，它根据开源 AGPLv3 许可证发布。由于其日志存储机制，它是独一无二的，只对每个日志流的标签和元数据进行索引，而不是日志的内容。这使它需要更少的存储空间，也可以更快地处理日志消息。然而，这种方式的缺点是，与其他平台相比，它在日志搜索功能上就不那么好用了。

它使用 Promtail（专门为 Loki 构建的日志收集器）通过 HTTP API 拉取日志。然后将日志分组成流并用标签进行索引，但是为了提高性能和降低存储成本，日志的文本并未被索引。一旦日志在 Loki 中，它们可以使用 Loki 的查询语言 LogQL 进行检索。它还与 Grafana 无缝集成，用于通过其可定制的仪表板显示从日志数据生成的各种数据。

Loki 还提供了一个强大的报警系统，你可以创建在满足某些条件时将触发的规则，然后将它们发送到 Prometheus AlertManager，然后将它们路由到适当的目的地，这确保了能够快速识别并及时解决关键问题。

部署 Grafana Loki 有 3 个方式：

单机模式：适合小型部署和开发环境。
微服务模式：适合大型部署和生产环境。
Grafana Cloud：由 Grafana 团队托管的 SaaS 解决方案。
Grafana Loki 的优点

与 Grafana 无缝集成，提供了强大的可视化功能。
由于其独特的索引策略，存储和处理日志的成本较低。
提供了一个强大的报警系统。
支持多种部署选项。
Grafana Loki 的缺点

日志搜索功能不如其他平台简单直接。
需要学习新的查询语言 LogQL。
3. SigNoz

igNoz 是一个日志收集和分析工具，可以收集和管理来自各种来源的日志、指标、跟踪和异常。它为使用 OpenTelemetry 检测应用程序提供本机支持，以防止供应商锁定，将收集到的数据存储在 ClickHouse 中，然后在用户友好的仪表板中聚合和可视化数据。

借助 SigNoz，您可以使用其查询生成器、PromQL 或 ClickHouse 查询轻松设置警报的动态阈值。其查询生成器简化了搜索和过滤日志的过程，任何触发的警报都会通过 Slack、PagerDuty 等渠道向您发送通知。

SigNoz 还支持与流行框架和技术的集成，使其与广泛的应用程序堆栈兼容。这使您能够主动监控和优化各种服务，以提高其性能、更快地排除故障和修复问题，并增强其整体可靠性。

SigNoz 采用模块化架构构建，可以轻松扩展以满足您不断增长的需求。您可以灵活地定义自己的保留期和采样率，仅根据应用程序负载优化数据存储成本。

SigNoz 的优点

提供了一个全面的解决方案，包括指标、追踪和日志。
使用 OpenTelemetry 进行数据收集，可以轻松地与你的应用程序集成。
提供良好的默认设置，可以将其安装在 Kubernetes 集群中，并立即开始收集日志和指标。
开箱即用地提供图表和可视化功能。
自动计算重要的指标，如错误率和 99 百分位数。
可以轻松设置动态警报阈值，并及时发送通知。
SigNoz 的缺点

文档可能不够清晰，因为它主要涵盖存储和保留期配置。
升级有时会导致问题。
统一的仪表板目前不可用。
定制性有限。

4. Highlight.io

Highlight.io 是一个开源的日志管理工具，专为开发者和运维团队设计，用于收集、索引和分析日志数据。它使用 Elasticsearch 作为其后端存储，提供了一个强大的搜索和分析功能。

Highlight 是一个全栈监控平台，不仅提供日志管理，还提供会话重放和错误监控，利用 ClickHouse 进行数据存储和检索。它旨在使您能够跟踪应用程序的行为、识别错误或错误、分析日志并轻松找到性能问题的根本原因。

只需两行代码，您就可以在安装此工具后开始使用它进行日志记录。它将立即开始从您的应用程序收集日志。然后可以轻松搜索和查询这些日志消息和属性。它还允许您将警报设置为当日志达到指定阈值时所需的频率。您将通过支持的渠道收到通知，包括电子邮件、Slack、Discord 或 webhooks。

Highlight 与所有流行的现代框架无缝集成，例如 Python、Golang、Node.js、React、Rails 等等。它允许您以可理解和可操作的方式可视化基础设施的每个部分，从用户点击到服务器错误。它提供免费计划以及灵活的即用即付定价计划，您当然可以自行托管。

Highlight.io 的优点

提供了一个全面的日志管理解决方案，包括收集、索引和分析。提供了一个直观的用户界面和强大的搜索功能。提供了一个警报系统。

设置简单快捷。
警报功能非常高效。
提供了一个直观的用户界面和强大的搜索功能。
与所有流行的框架无缝协作。
Highlight.io 的缺点

它没有像其他工具那样经过实战考验。