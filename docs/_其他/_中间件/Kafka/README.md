# 从Kafka导入数据至ClickHouse


https://help.aliyun.com/document_detail/425427.html

## topic
```bash
## 创建topic
kafka-topics.sh --create --zookeeper 192.168.28.171:2181 --replication-factor 1 --partitions 1 --topic test001

Created topic test001.
## 删除toppic
#  kafka-topics.sh --delete --zookeeper 192.168.28.171:2181 --topic test-topic
## 查看topic列表
kafka-topics.sh --list --zookeeper 192.168.28.171:2181

__consumer_offsets
test001
## 查看topic描述
kafka-topics.sh --describe --zookeeper 192.168.28.171:2181  --topic test001

Topic: test001  TopicId: 0NRsKCSkRrSTi3ok1Pq_Kg PartitionCount: 1       ReplicationFactor: 1    Configs:
        Topic: test001  Partition: 0    Leader: 0       Replicas: 0     Isr: 0
```
## 消息

```bash
## 生产者
kafka-console-producer.sh  --bootstrap-server   192.168.177.86:9092  --topic test001
## 消费者
kafka-console-consumer.sh --bootstrap-server 192.168.177.86:9092  --topic test001  --from-beginning

## 再打开一个窗口，执行命令查看消费者group：
kafka-consumer-groups.sh --bootstrap-server 192.168.177.86:9092 --list
## 查看组内具体消费者信息
kafka-consumer-groups.sh  --bootstrap-server 192.168.177.86:9092 --describe --group GROUPNAME
## 执行命令查看groupid等于console-consumer-21022的消费情况：
kafka-consumer-groups.sh --group console-consumer-21022 --describe --bootstrap-server 192.168.177.86:9092
```

## 吞吐量测试

```bash
生产者吞吐量测试

bin/kafka-producer-perf-test.sh --topic test-topic --num-records 500000 --record-size 200 
--throughput -1 --producer-props bootstrap.servers=localhost:9092,localhost:9093,localhost:9094 acks=1

输出：
500000 records sent, 196386.488610 records/sec (37.46 MB/sec), 464.37 ms avg latency, 699.00 ms max latency, 563 ms 50th, 688 ms 95th, 693 ms 99th, 698 ms 99.9th.

平均吞吐量是37.56MB/s ，平均每秒发送消息196386条，平均延迟0.464秒，最大延迟0.699秒，平均有50%的消息发送需要0.563秒，平均95%的消息需要0.688秒，平均99%的消息需要0.693秒，平均99.9%的消息需要0.698秒

 

消费者吞吐量测试

bin/kafka-consumer-perf-test.sh --broker-list localhost:9092,localhost:9093,localhost:9094 --fetch-size 200 
--messages 500000 --topic test-topic

输出：
start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec
2019-05-25 17:29:49:653, 2019-05-25 17:29:52:605, 95.3676, 32.3061, 500009, 169379.7425, 12, 2940, 32.4379, 170071.0884

测试消费50w条消息的吞吐量，1秒多消耗95MB，吞吐量大约92MB/s 也就是736Mb/s
```



## 

```sql
root@node1[16:38:22]:~$ clickhouse-client
ClickHouse client version 21.9.4.35 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 21.9.4 revision 54449.

node1 :)  SELECT 1

SELECT 1

Query id: 3030daa8-3f09-46ee-8eae-9812ec877d35

┌─1─┐
│ 1 │
└───┘

1 rows in set. Elapsed: 0.003 sec.

node1 :) CREATE TABLE source
:-] (
:-]     `ts` DateTime,
:-]     `tag` String,
:-]     `message` String
:-] )
:-] ENGINE = Kafka()
:-] SETTINGS kafka_broker_list = '192.168.177.86:9092',
:-]          kafka_topic_list = 'test001',
:-]          kafka_group_name = 'console-consumer-74236',
:-]          kafka_format = 'JSONEachRow',
:-]          kafka_skip_broken_messages = 1,
:-]          kafka_num_consumers = 2

CREATE TABLE source
(
    `ts` DateTime,
    `tag` String,
    `message` String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = '192.168.177.86:9092', kafka_topic_list = 'tag', kafka_group_name = 'clickhouse', kafka_format = 'JSONEachRow', kafka_skip_broken_messages = 1, kafka_num_consumers = 2

Query id: cda373b1-ae86-4054-9fa6-ac9e4c90d171

Ok.

0 rows in set. Elapsed: 0.004 sec.

node1 :)
node1 :) CREATE TABLE target
:-] (
:-]     `ts` DateTime,
:-]     `tag` String
:-] )
:-] ENGINE = MergeTree()
:-] PARTITION BY toYYYYMM(ts)
:-] ORDER BY tag

CREATE TABLE target
(
    `ts` DateTime,
    `tag` String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(ts)
ORDER BY tag

Query id: 48639500-5b73-49e0-9c80-d8e25733f39c

Ok.

0 rows in set. Elapsed: 0.003 sec.

node1 :) CREATE MATERIALIZED VIEW source_mv TO target AS
:-] SELECT
:-]     ts,
:-]     tag
:-] FROM source

CREATE MATERIALIZED VIEW source_mv TO target AS
SELECT
    ts,
    tag
FROM source

Query id: 67e479a5-8597-4d93-a00a-1bcd3bfa2c36

Ok.

0 rows in set. Elapsed: 0.004 sec.

node1 :) exit

```



```
2020-06-28 level1 message
2020-06-28 level2 message
2020-06-28 level3 message

select * from target
```







https://zhuanlan.zhihu.com/p/639548746?utm_id=0