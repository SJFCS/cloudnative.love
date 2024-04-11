---
title: MongoDB
tags: [Database,MongoDB]
sidebar_position: 3
---

[bitnami/mongodb](https://github.com/bitnami/bitnami-docker-mongodb) 把一些参数和副本集的功能封装到了环境变量里面，使用起来比 Docker 官方提供的 Mongo 镜像更方便。

## [副本集 replication](https://www.mongodb.com/docs/manual/replication/)

Mongo 的副本集使用 Raft 算法选主（和 Etcd 一样），来保证副本集的高可用，因此通常建议使用奇数个节点。

bitnami/mongo 通过设定一些强制性的参数，让我们可以方便地通过环境变量强制某个节点成为主节点。

# [分片 Sharding](https://docs.mongodb.com/manual/sharding/)

副本集通过 Raft 算法保证 MongoDB 的高可用。而分片则是将数据拆分到不同的副本集上，提升 MongoDB 总体的性能。