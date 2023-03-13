---
title: 环境初始化
---

import CodeBlock from '@theme/CodeBlock';

## 制作docker镜像

```dockerfile
FROM 1yasper/gphost
COPY greenplum-db-5.*-rhel7-x86_64.rpm /home/gpadmin/greenplum-db.rpm
RUN rpm -i /home/gpadmin/greenplum-db.rpm
RUN chown -R gpadmin /usr/local/greenplum-db*
RUN rm -f /home/gpadmin/greenplum-db.rpm
```
```bash
docker build -t greenplum
```

<!-- import Source from '!!raw-loader!./Dockerfile';

<CodeBlock language="dockerfile" title="Dockerfile">{Source}</CodeBlock> -->

## docker-compose配置集群
```dockercompose


```
## 初始化集群
```bash


```