OpenTelemetry 是一个开源的可观测性框架，由云原生基金会(CNCF)托管。它是 OpenCensus 和 OpenTracing 项目的合并。旨在为所有类型的可观测信号(如跟踪、指标和日志)提供单一标准。

- https://opentelemetry.io
- https://www.cncf.io
- https://opencensus.io



OpenTelemetry 支持不同的遥测数据类型：

- OpenTelemetry Trace 表示跨多个组件和服务的请求或操作的执行路径。它们提供详细的时间和上下文信息，允许开发人员了解请求流并确定性能瓶颈。
- OpenTelemetry Metrics 是对系统行为或资源利用率的定量测量。它们有助于监控和分析一段时间内的性能，并可用于警报、容量规划和趋势分析。
- OpenTelemetry Logs 包含有关应用程序中发生的事件、错误和活动的结构化或非结构化文本信息。它们对于调试、审计和故障排除非常有用。


开始使用 OpenTelemetry 最简单的方法是选择一个分布式跟踪工具( Jaeger/SigNoz/Uptrace)并遵循他们的文档。

[skywalking 扯皮](https://github.com/apache/skywalking/issues/7374#issuecomment-886676319)
https://github.com/apache/skywalking/issues/6210

https://xie.infoq.cn/article/602ae0b7cf0b7ccad0a760594

https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247508911&idx=1&sn=ad335737a2882e9adf1e2a03989d63ee&chksm=fdbaacb2cacd25a412827eb2523542b2c172b689b4c42da49e5c2017cf80fd4a6ceb53e9e48c&mpshare=1&srcid=0808IEHNfLwwhhouwB0cdbQ0&sharer_sharetime=1691495923273&sharer_shareid=9b996575050d80b9b16b938075c280c4&from=timeline&scene=2&subscene=1&clicktime=1691543527&enterid=1691543527&sessionid=0&ascene=2&fasttmpl_type=0&fasttmpl_fullversion=6803006-zh_CN-zip&fasttmpl_flag=0&realreporttime=1691543527133&devicetype=android-33&version=2800283f&nettype=3gnet&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQpCKds3ty1LY36RNFatblmBLvAQIE97dBBAEAAAAAAJsOJMfS6RUAAAAOpnltbLcz9gKNyK89dVj0ZXOuvMU9tX8Yqid4U2sjB%2BlR5uWppy8wlAhb2pGzKlAVtSmjbdWJ5cSk2fN2owIjEpmkwHT8P5a6QOMXn2Uu7CTe9gucHBds%2BLCktSvFm0D7vo6cCXP9BgZ7ruVEWw1I3t363li6CZCwvB9jpel5w35hOhjfvZ4pD2%2FDHKQPTM5CINFqNVP7nvqBc3u1KUIVTQs4EU7BLPX1l2xBIFfSfy643C9EINrELQlwjv5i9TUSTbIcxx5mIY9PG0iuZPvHb7bumkK%2F4eK6&pass_ticket=WXkaUmJYDfgm2PsksfaKbzmJuFvKO%2FwJlaHCzzfd5PCUa589cuQHa6htY88T3GnT&wx_header=3