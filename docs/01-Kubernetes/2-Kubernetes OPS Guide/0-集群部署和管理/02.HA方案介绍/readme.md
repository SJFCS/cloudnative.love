第一，除了kubelet之外，Kubernetes所有组件容器化；

第二，通过haproxy和keepalived构建Loadbalancer实现Master的高可用。

熟悉kubelet配置参数的都知道，我们在给kubelet配置apiserver的时候，可以通过“--api-servers”指定多个：

这看起来似乎已经做到apiserver的高可用配置了，但是实际上当第一个apiserver挂掉之后, 不能成功的连接到后面的apiserver，也就是说目前仍然只有第一个apiserver起作用。



如果上述问题解决之后, 似乎不需要额外的loadbalancer也能实现master的高可用了，但是，除了kubelet需要配置apiserver，controller manager和scheduler都需要配置apiserver，目前我们还只能通过“--master”配置一个apiserver，无法支持多个apiserver。



社区后续打算支持multi-master配置，实现Kubernetes Master的高可用，而且计划在Kubernetes 1.4版本中合入。



即使将来社区实现了通过multi-master配置的高可用方式，本次分享的Master High Availability仍然非常有意义，因为在私有云场景中，External Loadbalancer除了实现Master的高可用和负载均衡外，还可以针对Worker Node实现Nodeport请求的负载均衡，从而不仅实现了应用的高可用访问，同时也大大提高了应用的访问速度和性能。

https://github.com/kubernetes/kubernetes/issues/18174
https://github.com/munnerz/keepalived-cloud-provider