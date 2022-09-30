# 阿里云

阿里云是目前国内最成熟的云服务提供商。
## 费用优化
### 日志服务对接 kubernetes

在使用 pulumi_alicloud 创建 kubernetes 集群时，就可以选择对接「日志服务」，自动部署 logtail-ds。
但是默认的对接方式可能不适用你的应用场景，如果需要自定义「日志服务」的采集策略，就需要手动设置 logtail-ds 的采集规则。

- [通过DaemonSet-控制台方式采集Kubernetes标准输出](https://help.aliyun.com/document_detail/66658.html)

比如在使用 Istio 时，`istio-proxy` 这个 sidecar 默认情况下会将大量 access_log 输出到控制台，被日志服务抓取。

为了节约资金（穷），我们希望平时能让「日志服务」忽略 `istio-proxy` 的日志，在需要的时候再手动开启。
这对应的 logtail-ds 配置如下：

```json
{
    "inputs": [
        {
            "detail": {
                "IncludeLabel": {},
                "ExcludeLabel": {
                    "io.kubernetes.container.name": "istio-proxy"
                }
            },
            "type": "service_docker_stdout"
        }
    ]
}
```

这可以通过 Web 控制台配置，也可以使用 terraform/pulumi 自动配置，参见 [alicloud_logtail_config - terraform](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/logtail_config)
