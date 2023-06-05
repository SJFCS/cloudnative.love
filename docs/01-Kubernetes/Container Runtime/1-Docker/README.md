---
title: Docker
tags: [Docker]
---
# Docker

- [docker_practice](https://github.com/yeasy/docker_practice)

## docker-compose

本地容器编排工具

- [awesome-compose 配置示例](https://github.com/docker/awesome-compose)

- [Docker Docs - docker-compose 配置参考](https://docs.docker.com/compose/compose-file/)

`docker-compose` [使用兼容模式设置内存和 CPU 限制](https://nickjanetakis.com/blog/docker-tip-78-using-compatibility-mode-to-set-memory-and-cpu-limits)：

1. 在 `services.<service-name>.deploy.resources` 中设定好资源限制，如下。
```yaml
   deploy:
     resources:
        limits:
           cpus: '2'
           memory: 2G
        reservations:
           cpus: '0.5'
           memory: 200M
```
1. 通过 `dockere-compose  --compatibility up` 运行。它将尝试将设置资源限制的 API v3 方式转换回 v2 兼容属性。

## Docker Swarm Mode

容器集群编排工具（前身是 Classic-Swarm 和 SwarmKit）

而它使用的配置文件也是 `docker-compose.yml`，只是多了一些集群相关的参数（scale 等）

详见 [官方文档](https://docs.docker.com/engine/swarm/) 。

### Swarm vs Kubernetes vs Nomad

1. Dockere Swarm: Docker是推动容器时代到来的软件，Swarm 借Docker之势流行一时，可最终还是在容器编排之争中完败给了k8s
2. Kubernetes: 由cncf社区运作的k8s已经在容器编排的战争中取得了胜利，目前生态强大，生产首选。
3. Nomad: hashicorp 出品的容器编排工具，比 Kubernetes 更轻量，可以和 Vault,Consul,Terraform 等工具完美集成。如果用了hashicorp全家桶或者追求轻量化可以考虑这个。
