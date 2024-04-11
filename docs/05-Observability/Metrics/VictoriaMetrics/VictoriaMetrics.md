我们知道，若要保证一个系统的稳定运行，那么对于这个系统的监控是不可或缺的环节。当今在云原生领域中，Prometheus作为已经毕业的CNCF项目，已经成为了非常主流的监控和报警工具。但它也存在一些缺点，例如：默认情况下，其数据存储于本地文件的TSDB中，不利于容灾和做数据管理，若用于生产一般需要搭配第三方的如InfulxDB进行使用。大数据量的场景下，指标的收集和管理性能存在一定的瓶颈。

而我们今天介绍的VictoriaMetrics可以认为是Prometheus在上述问题上的一个增强版。它不仅能作为时序数据库结合Prometheus使用进行指标的长期远程存储，也能单独作为一个监控解决方案对Prometheus进行平替。

对比其他一些主流的监控方案、时序数据库，VictoriaMetrics具有如下优势：

- 指标数据的收集和查询具有极高的性能和良好的垂直和水平伸缩性，比InfluxDB和TimesscaleDB的性能高出20倍
- 在处理高技术时间序列时，内存方面做出了优化，比InfluxDB少10x倍，比Prometheus、Thanos或Cortex少7倍
- 数据存储的压缩方式更加高效。比TimescaleDB少70倍，与Prometheus、Thanos、Cortex相比，所需存储空间也少7倍。
- 针对高延迟IO和低IOPS存储进行了优化
- 单节点的VictoriaMetrics即可替代Thanos、M3DB、Cortex、InfluxDB或TimescaleDB等竞品中等规模的集群
- 对于Prometheus具有良好的兼容性，能够支持Prometheus的配置文件、PromQL、各类API、数据格式，并有一些自己的增强API。

https://cloudnative.to/blog/victoriametrics/
https://blog.cong.moe/post/2021-08-23-use-victoria-metrics-replace-prometheus/