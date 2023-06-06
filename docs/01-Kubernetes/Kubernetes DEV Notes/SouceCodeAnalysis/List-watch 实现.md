List 是获取资源的全量数据。

Watch 客户端会保持长连接，通过 Transfer-Encoding: chunked 机制接收数据的变化情况。

通过 kubectl proxy 命令方便本地调用 apiserver，如下调用 curl 后客户端不会退出，如果 namespace 发现了变化，客户端依旧会继续接收用户的数据。

```bash
➜  ~ curl "127.0.0.1:8001/api/v1/namespaces?watch=true" -v
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to 127.0.0.1 (127.0.0.1) port 8001 (#0)
> GET /api/v1/namespaces?watch=true HTTP/1.1
> Host: 127.0.0.1:8001
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Type: application/json
< Date: Mon, 19 Aug 2019 03:56:47 GMT
< Transfer-Encoding: chunked
```

Watch 的实现可以保证数据的实时性和避免使用轮训的性能问题。


# kubernetes list-watch - zhengjiajin's blog

> ## Excerpt
> List-watch 实现 List 是获取资源的全量数据。 Watch 客户端会保持长连接，通过 Transfer-Encoding: chunked 机制接收数据的变化情况。 通过 kubectl proxy 命令方便本地调用 apiserver，如下调用 curl 后

---
## 如何保证事件可靠性

kubernetes 通过 informer list-watch 资源的变化，并处理相应的回调函数。

### sync cache

kubernetes 会在第一次启动的时候把数据全部加载到自己的本地缓存中以减少对 apiserver 的直接访问。同时可以避免因为组件故障导致没有处理相应的 event 变化。比如创建 pod 的时候 controller-manager 挂了，重启后会全量加载数据(即触发 ADD event)，以此保证资源的创建事件能被处理。

## 如何保证事件连续性

### resource version

kubernetes 的资源 metadata 都有一个 resourceversion 字段，resource version 是一个增量数据，在 watch API 可以指定 resource version 字段，k8s 会从 resource version 获取数据的变化。informer list-watch 的最佳实践是先 list?resourceVersion=0 获取 apiserver 数据(apiserver 会从缓存中获取数据)，然后拿到 resourceVersion 再去 执行 watch?resourceVersion={resourceVersion}

## Code Reference
https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/tools/cache/reflector.go#L159~L312