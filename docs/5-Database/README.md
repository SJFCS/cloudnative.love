---
title: Database
sidebar_position: 5
tags: [Database]
---

## 值得了解的数据库
- OLAP
  - ClickHouse
  - Snowflake
  - Druid
  - ElasticSearch
- HTAP
  - TiDB
  - PostgreSQL
- 键值数据库
  - Redis
  - Etcd
  - 底层数据库：boltdb/rocksdb/leveldb
- 文档数据库
  - MongoDB 目前最为流行的NoSQL数据库，它是一种面向集合，模式无关的文档型数据库
- 时序数据库
  - VictoriaMetrics
  - Prometheus
- 特征向量搜索 / 相似度搜索 / 视频搜索 / 语义搜索
- 图数据库
  - https://github.com/dgraph-io/dgraph

## 一、关系数据库

关系数据库，也就是以关系为核心来组织数据的数据库，数据被看作关系的集合。它的理念是把数据尽可能拆分成多个二维表格，不同的表之间通过某种关系来连接起来。这样的好处有：
1. 如果数据的某一部分需要变动，只需要变动该数据所处的表就行，而不需要重新设计整个数据库。
1. 可以进行复杂的 SQL 查询
1. 保证事务的一致性

### 事务的 ACID 特性

关系数据库保证事务满足以下四个特性：
1. **原子性（Atomicity）**：整个事务中的所有操作，要么全部完成，要么全部不完成，不存在只有一部分完成的情况。如果事务在执行过程中触发了异常，整个事务都会失败并中止，数据库不会被改变。（因为没有 `COMMIT`）
    - **注意事务失败并不会自动`ROLLBACK`！**需要手动检测 SQLEXCEPTION，然后将事务 `ROLLBACK` 到某个 `SAVEPOINT` 或者直接 `ROLLBACK` 整个事务
    - 一句话总结，就是**记录 DB 之前的版本，允许回滚**
1. **持久性（Durability）**：一旦事务成功执行，它所作的更改就会一直存在于数据库中，不会丢失。（实际上持久性有很多的级别，保证数据绝对不丢失的方法并不存在）
1. **隔离性（Isolation）**：在并发事务下，各事务相互独立互不干扰。（或者说一个事务所做的修改在最终提交以前，该修改对其他事务不可见）
    - 隔离性是指为了避免并发事务的线程安全问题引入的锁机制以及各种并发安全控制机制
    - 为了平衡性能与隔离性，定义了以下四个隔离级别（可以说是**适当的破坏一致性来提升性能与并行度**）：
        - Read Uncommitted
        - Read Committed
        - Repeatable Read
        - Serializable（所有的事务操作都必须串行操作，完全隔离）


1. **一致性（Consistency）**：如果事务是并发多个，其外在表现也必须与串行事务一致。也就是说事务开始和结束之间的中间状态不会被其他事务看到。

**AID 是手段，C 是目的。**

MySQL 的 innoDB 引擎默认的隔离级别为 Repeatable Read，而 SQL Server、PostgrelSQL、Oracle 都以 Read Committed 为默认隔离级别。隔离级别可手动修改。

## 二、非关系数据库（NoSQL）

传统的关系数据库有如下缺点：
1. 对一致性的要求导致其在高并发下不堪重负
1. 数据读写必须经过 SQL 解析，大量数据、高并发下读写性能不足
1. “阻抗失谐”，即数据库中存储的对象与实际的对象实体有一定的差别
1. 扩展困难，关系模型一旦确定就很难修改。

于是 NoSQL 异军突起，关系数据库的缺点与 NoSQL 的优点几乎一一对应，两者可以说是互补的关系。

非关系数据库的优点：
1. NoSQL 只要求“弱一致性”，或者说“最终一致”，能胜任高并发场景
1. 无需经过 SQL 层的解析，读写性能很高
1. 键值模型（或文档模型、图模型）与面向对象的数据表达方式更相似更自然
1. 数据之间没有耦合，很容易修改拓展



## 数据序列化

数据序列化有多种格式可选，最流行的是 Json.

- [Data Serialization: JSON, BSON, MessengePack, Protocol Buffer, Thrift, Avro, Cap’n Proto, FlatBuffers ](https://yuhui-lin.github.io/post/2017-08-01_data-serialization/)

1. Json: 最流行的序列化格式，源自 JavaScript。
2. [Bson](http://bsonspec.org/):为 Json 数据存储而设计，CURD 性能高。
1. [MessagePack](https://github.com/msgpack/msgpack)：为 Json 的网络传输而设计，体积小。但是这个项目目前经营惨淡（stars 不多）。
1. [protocol-buffers](https://github.com/protocolbuffers/protobuf): 有严格定义(Schema)的序列化格式，目前非常流行。



## 参考

- [『浅入深出』MySQL 中事务的实现](https://draveness.me/mysql-transaction)

## 案例

>TiDB/CockroachDB/Vitess 值得关注

- [京东如何使用Vitess管理超大规模数据库](https://www.cncf.io/case-studies-cn/jd-com-vitess/)
- [Why This MySQL Alternative Beats Vitess and CRDB in Scaling Out Our Databases on K8s](https://www.pingcap.com/case-study/choose-a-mysql-alternative-over-vitess-and-crdb-to-scale-out-our-databases-on-k8s/)

