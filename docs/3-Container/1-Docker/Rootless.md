Docker daemon 只能以root身份运行 一直让人诟病。

曾经 `ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock` 作为默认配置，导致的 Docker Remote API 未授权漏洞，由于默认为root身份所以危害极大。

一些后起之秀如 Podman 本身在设计之初就是 Rootless 的，Docker 终于在 19.03 中发布了一个重要的特性 “Rootless Container支持”。

详见 --> https://developer.aliyun.com/article/700923