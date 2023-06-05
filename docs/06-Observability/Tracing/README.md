# Tracing

[Jaeger](https://github.com/jaegertracing/jaeger/) 是云原生社区最流行的开源链路追踪工具。

[signoz](https://signoz.io/)

Zipkin、Pinpoint、SkyWalking和CAT


```
OTEL_EXPORTER_OTLP_ENDPOINT: http://signoz-otel-collector.signoz.svc.cluster.local:4317
  OTEL_METRICS_EXPORTER: none
  OTEL_PROPAGATORS: b3


  DEPLOY_ENV: prod
  OTEL_EXPORTER_JAEGER_ENDPOINT: http://jaeger-allinone-collector.observability.svc.cluster.local:14250
  OTEL_METRICS_EXPORTER: prometheus
  OTEL_PROPAGATORS: tracecontext,baggage,b3,jaeger
  OTEL_TRACES_EXPORTER: jaeger
  OTEL_TRACES_SAMPLER: jaeger_remote
```