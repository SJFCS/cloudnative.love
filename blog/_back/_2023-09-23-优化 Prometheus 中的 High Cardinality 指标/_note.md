https://www.doit.com/how-to-add-custom-grafana-dashboards-in-code-using-the-kube-prometheus-stack-helm-chart/
## 项目介绍
https://aleiwu.com/post/prometheus-operator/
Prometheus Operator

提供了更多的灵活性和可定制性，但同时也意味着在部署和维护时可能需要更多的手动配置工作。

如果您需要更高的定制灵活性，希望能够更细致地控制Prometheus的配置，且不介意投入时间深入了解Prometheus Operator和Kubernetes的CRD，那么直接使用Prometheus Operator可能更合适。

kube-prometheus-stack
内置仪表板和规则，开箱即用，通过Helm chart管理，升级和维护变得更加简单。但大部分定制都需要通过修改Helm chart的values.yaml来实现，这可能不如直接使用Prometheus Operator灵活。

在kube-prometheus-stack的基础上，通过添加自定义的ServiceMonitor或PrometheusRule来满足特定的监控需求。这样既保留了开箱即用的便利，又不失一定的灵活性和可扩展性。


## 配置
配置文件中包含了3个模块：global、rule_files 和 scrape_configs

- global 模块控制 Prometheus Server 的全局配置：
  - scrape_interval：表示 prometheus 抓取指标数据的频率，默认是15s，我们可以覆盖这个值
  - evaluation_interval：用来控制评估规则的频率，prometheus 使用规则产生新的时间序列数据或者产生警报
- rule_files：告警规则和录制规则
- scrape_configs 抓取指标


Prometheus还提供了更多的relabeling动作，比如：
- replace: 基于正则表达式和源标签的内容替换目标标签的值。
- keep: 如果标签匹配到正则表达式，则保留该抓取目标；否则丢弃。
- drop: 与keep相反，匹配到的抓取目标会被丢弃。

举个例子，如果你想从某个特定环境抓取指标，比如只从生产环境：
```yaml
- source_labels: [__meta_kubernetes_namespace]
  regex: ^prod-.*
  action: keep
```
这个配置会保留所有命名空间以prod-开头的抓取目标，其他的则被丢弃。

## 指标
Prometheus 定义了4种不同的指标类型：Counter（计数器）、Gauge（仪表盘）、Histogram（直方图）、Summary（摘要）。

Counter (只增不减的计数器) 如 http_requests_total、node_cpu_seconds_total

    例如，通过 rate() 函数获取 HTTP 请求量的增长率：
    rate(http_requests_total[5m])
    查询当前系统中，访问量前 10 的 HTTP 请求：
    topk(10, http_requests_total)

Gauge（可增可减的仪表盘）如：node_memory_MemFree_bytes（主机当前空闲的内存大小）、node_memory_MemAvailable_bytes（可用内存大小）

    查看系统的当前状态：
    node_memory_MemFree_bytes
    对于 Gauge 类型的监控指标，通过 PromQL 内置函数 delta() 可以获取样本在一段时间范围内的变化情况。例如，计算 CPU 温度在两个小时内的差异：
    delta(cpu_temp_celsius{host="zeus"}[2h])
    还可以直接使用 predict_linear() 对数据的变化趋势进行预测。例如，预测系统磁盘空间在4个小时之后的剩余情况：
    predict_linear(node_filesystem_free_bytes[1h], 4 * 3600)

Histogram 和 Summary 主用用于统计和分析样本的分布情况。(区分是平均的慢还是长尾的慢)

prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.5"} 0.012352463
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.9"} 0.014458005
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.99"} 0.017316173
prometheus_tsdb_wal_fsync_duration_seconds_sum 2.888716127000002
prometheus_tsdb_wal_fsync_duration_seconds_count 216
从上面的样本中可以得知当前 Prometheus Server 进行 wal_fsync 操作的总次数为216次，耗时2.888716127000002s。其中中位数（quantile=0.5）的耗时为0.012352463，9分位数（quantile=0.9）的耗时为0.014458005s。


在 Prometheus Server 自身返回的样本数据中，我们还能找到类型为 Histogram 的监控指标prometheus_tsdb_compaction_chunk_range_seconds_bucket：

prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="100"} 71
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="400"} 71
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="1600"} 71
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="6400"} 71
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="25600"} 405
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="102400"} 25690
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="409600"} 71863
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="1.6384e+06"} 115928
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="6.5536e+06"} 2.5687892e+07
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="2.62144e+07"} 2.5687896e+07
prometheus_tsdb_compaction_chunk_range_seconds_bucket{le="+Inf"} 2.5687896e+07
prometheus_tsdb_compaction_chunk_range_seconds_sum 4.7728699529576e+13
prometheus_tsdb_compaction_chunk_range_seconds_count 2.5687896e+07
与 Summary 类型的指标相似之处在于 Histogram 类型的样本同样会反应当前指标的记录的总数(以 _count 作为后缀)以及其值的总量（以 _sum 作为后缀）。不同在于 Histogram 指标直接反应了在不同区间内样本的个数，区间通过标签 le 进行定义。

## 查询函数
不过通常区间向量都会应用一个函数后变成可以绘制的瞬时向量，Prometheus 中对瞬时向量和区间向量有很多操作的函数，不过对于区间向量来说最常用的函数并不多，使用最频繁的有如下几个函数：
https://prometheus.io/docs/prometheus/latest/querying/functions/

- rate(): 计算整个时间范围内区间向量中时间序列的每秒平均增长率
- irate(): 仅使用时间范围中的最后两个数据点来计算区间向量中时间序列的每秒平均增长率，irate 只能用于绘制快速变化的序列，在长期趋势分析或者告警中更推荐使用 rate 函数
- increase(): 计算所选时间范围内时间序列的增量，它基本上是速率乘以时间范围选择器中的秒数


有的时候可能想要查看5分钟前或者昨天一天的区间内的样本数据，这个时候我们就需要用到位移操作了，位移操作的关键字是 offset，比如我们可以查询30分钟之前的 master 节点 CPU 的空闲指标数据：
node_cpu_seconds_total{instance="ydzs-master", mode="idle"} offset 30m

https://www.qikqiak.com/k8strain2/monitor/promql/
https://www.qikqiak.com/k8strain/monitor/promql/
https://hulining.gitbook.io/prometheus/practices/histograms
https://www.youtube.com/watch?v=feHSU0BMcco
https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-k8s-stack/README.md
https://medium.com/@shubhamjadhav957/integration-of-thanos-with-prometheus-and-s3-as-storage-731e8d0a773f

## 录制规则
rate(apiserver_request_total[5m])  14s 

groups:
- name: example
  rules:
  - record: apiserver:request_rate_5m
    expr: rate(apiserver_request_total[5m])

Prometheus 会按照配置文件中指定的频率（默认是每15秒一次）执行该规则中的表达式，并将结果作为一个新的时间序列数据存储起来。

    rate(apiserver_request_total[5m]) 的查询已经很慢，你可能会担心录制规则在执行这个查询以生成新的记录时会进一步增加负载。让我们来解析这个情况以及为什么使用录制规则仍然是一个提升性能的好策略。



## 优化
针对rate(apiserver_request_total[5m])这类Prometheus查询的优化，确实存在一些方法可以在不使用录制规则的情况下提高性能。要理解优化的方法，首先要了解查询慢的潜在原因：

高基数（High Cardinality）：apiserver_request_total指标如果拥有大量的标签和标签值组合，会导致基数非常高。每一个独特的标签组合都会被当作一个独立的时间序列，这会显著增加Prometheus处理查询所需的计算量。

资源限制：Prometheus服务器的CPU、内存或I/O性能可能成为瓶颈，影响查询性能。

大量历史数据：对于拥有大量历史数据的时间序列，计算rate()函数可能需要处理大量的样本点。

针对上述潜在原因，以下是一些优化策略：

减少标签的基数
精简标签：审视apiserver_request_total指标的标签，看是否有可以合并或移除的标签，每减少一个标签，就可以显著减少时间序列的数量。

使用更粗的聚合：如果可能，考虑是否能对数据进行更粗粒度的聚合。例如，如果有基于多个地理位置的标签，看是否可以合并为更大的地理单位。

优化Prometheus资源
增加资源：确保Prometheus服务器有足够的CPU和内存资源。在云环境中，可能意味着升级到更大的机器类型。

调整配置：优化Prometheus的存储配置，比如调整块（block）的大小，以及调整内存中的样本数量，以减少对磁盘的I/O操作。

调整查询
减小查询范围：如果适用，尝试减少查询的时间范围，例如从[5m]调整到[1m]，这将减少需要处理的数据量。

使用预计算的时间范围：对于某些场景，考虑是否可以接受预计算一个较长时间范围的速率，例如[10m]或[15m]，这可以减少查询的频率和计算量。

使用Counter类型的增量查询
利用Counter增量：对于Counter类型的指标，考虑只查询最近的增量变化，而不是完整的速率计算。这需要外部逻辑来管理和比较增量值，但可以显著减少计算量。



在处理时间序列数据时，是否认为14个标签构成“高基数”（High Cardinality）取决于几个因素，包括：

每个标签的独特值数量：基数是独特标签组合的总数。如果每个标签都有多个可能的值，那么这些标签的组合可能会迅速增加总的时间序列数量。例如，如果你有14个标签，每个标签只有2个独特值，那么理论上可能的组合数量为2^14 = 16384。如果每个标签的独特值更多，那么组合数会呈指数级增长。

查询范围和深度：如果你的查询涉及多个标签，Prometheus 需要在其数据库中查找所有匹配的时间序列。随着标签数量的增加，匹配和计算的复杂度也会上升，特别是在大数据集上。

Prometheus 实例的规模和配置：一个配置良好并且有充足资源的 Prometheus 实例能够处理相对较高的基数，而一个资源受限的实例则可能会在面对较高标签基数时遇到性能瓶颈。

## ui Load time: 501ms   Resolution: 14s   Result series: 898 解释



## 尽早干掉维度(Cardinality)过高的指标
根据我们的经验，Prometheus 里有 50% 以上的存储空间和 80% 以上的计算资源(CPU、内存)都是被那么两三个维度超高的指标用掉的。而且这类维度超高的指标由于数据量很大，稍微查得野一点就会 OOM 搞死 Prometheus 实例。

首先要明确这类指标是对 Prometheus 的滥用，类似需求完全应该放到日志流或数仓里去算。但是指标的接入方关注的往往是业务上够不够方便，假如足够方便的话什么都可以往 label 里塞。这就需要我们防患于未然，一个有效的办法是

用警报规则找出维度过高的坏指标，然后在 Scrape 配置里 Drop 掉导致维度过高的 label。
```
# 统计每个指标的时间序列数，超出 10000 的报警
count by (__name__)({__name__=~".+"}) > 10000
```

“坏指标”报警出来之后，就可以用 metric_relabel_config 的 drop 操作删掉有问题的 label（比如 userId、email 这些一看就是问题户），这里的配置方式可以查阅文档

对了，这条的关键词是尽早，最好就是部署完就搞上这条规则，否则等哪天 Prometheus 容量满了再去找业务方说要删 label，那业务方可能就要忍不住扇你了……

## Rate 类函数 + Recording Rule 的坑
可能你已经知道了 PromQL 里要先 rate() 再 sum()，不能 sum() 完再 rate()（不知道也没事，马上讲）。但当 rate() 已经同类型的函数如 increase() 和 recording rule 碰到一起时，可能就会不小心掉到坑里去。

为了让大家查询得更快一点，我们设计了一个 Recording Rule，用 sum() 来去掉维度过高的 bad_label，得到一个新指标。那么只要不涉及到 bad_label，大家就可以用新指标进行查询，Recording Rule 如下：
```
sum(old_metric) without (bad_label)
```
用了一段时候后，大家发现 new_metric 做 rate() 得到的 QPS 趋势图里经常有奇怪的尖峰，但 old_metric 就不会出现。这时我们恍然大悟：绕了个弯踩进了 rate() 的坑里。

这背后与 rate() 的实现方式有关，rate() 在设计上假定对应的指标是一个 Counter，也就是只有 incr(增加) 和 reset(归0) 两种行为。而做了 sum() 或其他聚合之后，得到的就不再是一个 Counter 了，举个例子，比如 sum() 的计算对象中有一个归0了，那整体的和会下降，而不是归零，这会影响 rate() 中判断 reset(归0) 的逻辑，从而导致错误的结果。写 PromQL 时这个坑容易避免，但碰到 Recording Rule 就不那么容易了，因为不去看配置的话大家也想不到 new_metric 是怎么来的。

要完全规避这个坑，可以遵守一个原则：Recording Rule 一步到位，直接算出需要的值，避免算出一个中间结果再拿去做聚合。

## 警报和历史趋势图未必 Match
最近半年常常被问两个问题：

- 我的历史趋势图看上去超过水位线了，警报为什么没报？
- 我的历史趋势图看上去挺正常的，警报为什么报了？

这其中有一个原因是：趋势图上每个采样点的采样时间和警报规则每次的计算时间不是严格一致的。当时间区间拉得比较大的时候，采样点非常稀疏，不如警报计算的间隔来得密集，这个现象尤为明显，比如时序图采样了 0秒，60秒，120秒三个点。而警报在15秒，30秒，45秒连续计算出了异常，那在图上就看不出来。另外，经过越多的聚合以及函数操作，不同时间点的数据差异会来得越明显，有时确实容易混淆。

这个其实不是问题，碰到时将趋势图的采样间隔拉到最小，仔细比对一下，就能验证警报的准确性。而对于聚合很复杂的警报，可以先写一条 Recording Rule, 再针对 Recording Rule 产生的新指标来建警报。这种范式也能帮助我们更高效地去建分级警报（超过不同阈值对应不同的紧急程度）

## Alertmanager 的 group_interval 会影响 resolved 通知

https://aleiwu.com/post/prometheus-alert-why/
## 如何滤掉bad lable 


在Prometheus中，"bad labels"通常指那些对于时间序列的区分度、查询性能或者数据意义没有实质性帮助，或者由于其高基数导致存储和性能问题的标签。要查找并丢弃这些标签，你可以采取几个步骤来审查和优化你的指标和标签。

1. 审查标签和识别问题标签
在开始之前，你需要确定哪些标签可能是问题标签。这可能包括：

高基数标签：拥有大量唯一值的标签，比如用户ID、会话ID等。
低价值标签：对于监控目标的理解或警报逻辑没有实质性帮助的标签。
动态标签：其值持续变化的标签，如基于时间戳的标签。
2. 使用PromQL来识别高基数标签
你可以使用PromQL查询来帮助识别具有高基数的标签。以下是一个例子，使用count by (label)表达式来计数每个标签值的出现次数，以此来识别可能的高基数标签。假设我们关注的标签名为instance:

count by (instance) ({__name__=~".+"})

这个查询会返回每个instance标签值的时间序列数量。如果某个标签值的数量异常高，这可能表明它是一个高基数标签。

3. 在Prometheus配置中丢弃问题标签
确定了要丢弃的标签后，你可以在Prometheus的配置文件中使用metric_relabel_configs来丢弃这些标签。这样做可以在指标被存储之前修改它们，从而避免不必要的标签造成的性能问题。

下面是一个配置示例，展示了如何丢弃名为bad_label的标签：

scrape_configs:
  - job_name: 'your_job_name'
    # 其他抓取配置...
    metric_relabel_configs:
      - action: labeldrop
        regex: 'bad_label'


metric_relabel_configs是在指标被存储之前处理的，这意味着丢弃的标签不会出现在Prometheus的数据中，也不会被后续的查询或警报规则使用。

通过这种方式，你可以有效地识别和去除影响Prometheus性能的问题标签，优化你的监控系统的性能和资源使用

## 告警
自身显式通知

## 高可用
要以高度可用的方式运行 Prometheus，两个（或更多）实例需要使用相同的配置运行，只是它们将具有一个具有不同值的外部标签来标识它们。 Prometheus 实例抓取相同的目标并评估相同的规则，因此它们在内存和磁盘上将具有相同的数据，但由于外部标签不同，抓取和评估不会完全相同地发生。 。因此，针对每个 Prometheus 实例执行的查询请求可能返回略有不同的结果。对于警报评估，这种情况不会改变任何内容，因为警报通常仅在特定查询触发一段时间时才会触发。对于仪表板，应使用粘性会话（在 Kubernetes Service 上使用 sessionAffinity ），以便在刷新时获得一致的图表，或者您可以使用 Thanos Querier 之类的工具来联合数据。



```yaml
alertmanager:
  enabled: true
  alertmanagerSpec:
    replicas: 3 # 设置副本数量以实现高可用
    clusterAdvertiseAddress: "" # 自动使用各实例的Pod IP
    listenLocal: false
    clusterListenPort: 6783 # Alertmanager对等通信的默认端口
    clusterGossipInterval: "1s" # 调整为适合你的环境的值
    clusterPushpullInterval: "1s" # 调整为适合你的环境的值
    clusterPeerTimeout: "15s"
    clusterGossipNodes: 3 # 集群中的节点数量，与副本数量匹配
    externalUrl: "http://alertmanager.example.com" # 根据实际情况调整
```

## loki

SSD模式（Simple Scalable Deployment）不是传统的单体（Monolithic）模式，也不完全等同于完全微服务化（Fully Microservices）的架构。它是一种介于两者之间的部署方式，旨在利用微服务架构的可扩展性，同时保持配置和管理的简便性。具体来说，SSD模式通过将Loki的关键组件作为部分独立的微服务来部署，但这些微服务的数量和分离程度没有完全微服务化那么高。这样做既实现了一定程度的解耦，又避免了微服务架构可能带来的复杂性和管理难度。

SSD模式的架构组成
在SSD模式下，Loki的架构通常包括以下几个关键组件作为独立的服务运行：

分布式存储（Distributed Storage）：用于存储日志数据的组件，可以是本地存储、云存储或其他分布式存储解决方案。
Ingesters：负责接收、处理和暂存（在写入长期存储之前）日志数据的组件。
Queriers：处理日志查询请求的组件，它们从存储中检索并返回查询结果。
Query Frontend（可选）：一种优化查询性能的组件，通过缓存和查询分片等技术减少查询延迟。
Distributors：接收来自客户端的日志数据并将其分发到适当的Ingester的组件。
优点
通过这种部署方式，SSD模式继承了微服务架构的一些关键优点：

可扩展性：每个组件可以独立扩展，使得整个系统能够灵活应对不同的负载情况。
容错性：组件间的解耦也意味着系统的某个部分出现问题时，不会影响到整个系统的稳定性。
管理便捷性：尽管比单体模式复杂一些，SSD模式仍然比完全微服务化的架构更易于管理和配置，特别是对于不需要极端扩展性的场景。
结论
总之，SSD模式提供了一种折衷的解决方案，旨在兼顾易用性、可扩展性和系统复杂度。它适用于那些寻求在微服务架构的灵活性和单体架构的简便性之间找到平衡点的应用场景。不同的机构可以根据自身的需求和资源，调整微服务的划分和部署策略，以达到最佳的效果。


## loki redis pr

## 函数
### 变化率
rate（区间内首尾差值除以时间） irate（最后两项差值除以时间） increase （首尾差值总量）
deriv（gauge类型变化情况） delta predict_linear

## 聚合
sum/min/max/avg

count （序列总数）
topk

xxx_over_time
先rate再sum，因为rate可以处理conter=0的情况



by/without