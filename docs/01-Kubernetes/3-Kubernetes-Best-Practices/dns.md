# k8s dns 优化

因为 dns 服务直接影响整个集群的应用，需要对 dns 有个整体的把控，dns 自身的性能(qps) 和 dns 解析的延迟等。另外 k8s 集群内部中有很多服务需要访问外部的服务，比如数据库实例 mysql、redis 等，可以通过定制化 dns config 优化 dns 的性能。



k8s dns 的作用是提供内部的服务发现机制，pod 支持的 dns policy 分别是:

- None
- Default
- ClusterFirst
- ClusterFirstHostNet
详情查看 [dns-pod-service](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy)

issue：
[kubernetes-dns-resolution-ndots-options-and-why-it-may-affect-application-performances](https://pracucci.com/kubernetes-dns-resolution-ndots-options-and-why-it-may-affect-application-performances.html)

[racy-conntrack-and-dns-lookup-timeouts](https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts)



## issue 1: ndots
上面的 known issue 1 描述的很清楚了，k8s 默认的 dns policy 是 ClusterFirst，因为 ndots 和 serach domain 在访问外部 dns 会有额外的查询次数。

```bash
root@tmp-55c7865869-fdrt6:/# host -v baidu.com
Trying "baidu.com.default.svc.cluster.local"
Trying "baidu.com.svc.cluster.local"
Trying "baidu.com.cluster.local"
Trying "baidu.com"
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50562
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;baidu.com.			IN	A

;; ANSWER SECTION:
baidu.com.		30	IN	A	220.181.38.148
baidu.com.		30	IN	A	39.156.69.79

Received 77 bytes from 10.96.0.10#53 in 24 ms
Trying "baidu.com"
Host baidu.com not found: 3(NXDOMAIN)
Received 27 bytes from 10.96.0.10#53 in 2 ms
Trying "baidu.com"
Host baidu.com not found: 3(NXDOMAIN)
Received 27 bytes from 10.96.0.10#53 in 1 ms
```
coredns log:
```bash
2019-08-06T13:24:35.649Z [INFO] 10.81.130.109:40851 - 52890 "A IN baidu.com.lx-innovation.svc.cluster.local. udp 59 false 512" NXDOMAIN qr,aa,rd,ra 152 0.000116739s
2019-08-06T13:24:35.65Z [INFO] 10.81.130.109:48677 - 61836 "A IN baidu.com.svc.cluster.local. udp 45 false 512" NXDOMAIN qr,aa,rd,ra 138 0.000072353s
2019-08-06T13:24:35.65Z [INFO] 10.81.130.109:41557 - 40802 "A IN baidu.com.cluster.local. udp 41 false 512" NXDOMAIN qr,aa,rd,ra 134 0.000153477s
```

**优化方案**

- 如果你的服务只需要访问外部的 dns，没有内部的服务依赖，可以通过修改 pod 的 dns 策略为 Default, pod 会继承节点上的 resolver，但是这个时候你无法通过域名访问内部的 service
- 通过自定义 dns config，覆盖集群内的 ndots 数量，如果你访问的域名 dots 数量大于 ndots 会跳过搜索域的查询直接访问你的 dns

**性能测试**
下面是 coredns 的默认配置，使用 dnspolicy ClusterFirst 测试去访问外部的 dns，coredns 解析不了会 proxy 到 coredns 的 /etc/resolv.conf，因为 coredns 的 dnspolicy 是 Default，也就是说最后会通过 coredns 所在节点的 /etc/resolver.config 解析。

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```


测试访问外部的 dns 的性能，先通过 dig +trace 拿到dns 解析经过的 name server 地址

运行一个包含 dnsutils 的镜像：
```bash
kubectl run -it --rm tmp --image=tutum/dnsutils -- bash
```

```bash
root@netutils-8c4bffb9d-94f7c:/# dig +trace <xxxx>.mysql.rds.aliyuncs.com

; <<>> DiG 9.10.3-P4-Ubuntu <<>> +trace rm-2zef59njre3axsky3.mysql.rds.aliyuncs.com
;; global options: +cmd
.			30	IN	NS	a.root-servers.net.
.			30	IN	NS	b.root-servers.net.
.			30	IN	NS	e.root-servers.net.
.			30	IN	NS	i.root-servers.net.
.			30	IN	NS	h.root-servers.net.
.			30	IN	NS	f.root-servers.net.
.			30	IN	NS	d.root-servers.net.
.			30	IN	NS	l.root-servers.net.
.			30	IN	NS	k.root-servers.net.
.			30	IN	NS	g.root-servers.net.
.			30	IN	NS	c.root-servers.net.
.			30	IN	NS	m.root-servers.net.
.			30	IN	NS	j.root-servers.net.
.			30	IN	RRSIG	NS 8 0 518400 20190820050000 20190807040000 59944 . f+guGx5Rpb3tXRd/lfzX8Zo6WwWouztr/5GVDPgTDIVpDnLhQ/TBE4ih 5dpTVLnagU4WargLeHVh0h94e2wemx3IMl2UxKrPJMao+IEWCu55/9+z WJtQKLPz6XpW/AqDov+g2uCWBhrXybn1m/ldj+sKAA3wiCRkYqbKS6Xn htlJG2SMGPY5fIGDoJ04flxSWbjx7xzdXbDYHyhupwHXnFaRKD3RrsWB 4Px5AycR7dNuv6nBylFK+/TtqR7c4KSHL3G1dIzTelYVCVqkcMcZxZMN sHNSgR8pBbyKL2uX8Pal1J+T7xaW9Ggdhkv31CHc+ZP+rQ3MEPn9MhfA n02A7g==
;; Received 717 bytes from 10.85.0.10#53(10.85.0.10) in 1 ms

com.			172800	IN	NS	a.gtld-servers.net.
com.			172800	IN	NS	b.gtld-servers.net.
com.			172800	IN	NS	c.gtld-servers.net.
com.			172800	IN	NS	d.gtld-servers.net.
com.			172800	IN	NS	e.gtld-servers.net.
com.			172800	IN	NS	f.gtld-servers.net.
com.			172800	IN	NS	g.gtld-servers.net.
com.			172800	IN	NS	h.gtld-servers.net.
com.			172800	IN	NS	i.gtld-servers.net.
com.			172800	IN	NS	j.gtld-servers.net.
com.			172800	IN	NS	k.gtld-servers.net.
com.			172800	IN	NS	l.gtld-servers.net.
com.			172800	IN	NS	m.gtld-servers.net.
com.			86400	IN	DS	30909 8 2 E2D3C916F6DEEAC73294E8268FB5885044A833FC5459588F4A9184CF C41A5766
com.			86400	IN	RRSIG	DS 8 1 86400 20190820050000 20190807040000 59944 . huSg2GwPUqkeUQCha0p1GQTRrg5OkC+SVNgvQikPtuV8gsef21UrqlUf Sy6gPy2IbFcCeXxkxp0b7vWYXXj4dyfT6NMjGzzOVufWX6wILuk+Zdb7 m3B6UidVVaHdT2ijt8N/P/mv6rTttzsLeJSR7IEm/w3uQcrrvB1gbFmB 0CLLq81Wmz9LR4JqA6jLKzw+5pEOrPGHqZkhGn+Mp9dQZFhR5aL8veLp gddLGByys2F5BhYNgnUCbv3Kz5taTEFfIx7+alClASd5BcDYObF78Ewf EHaBQ+q031wQh90ZquEh7i8pZ9P9aXoI3hlfQqyNQdDlQjnjogiuFk5n tzyeng==
;; Received 1203 bytes from 192.58.128.30#53(j.root-servers.net) in 171 ms

aliyuncs.com.		172800	IN	NS	ns3.aliyun.com.
aliyuncs.com.		172800	IN	NS	ns4.aliyun.com.
aliyuncs.com.		172800	IN	NS	ns5.aliyun.com.
CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN NSEC3 1 1 0 - CK0Q1GIN43N1ARRC9OSM6QPQR81H5M9A NS SOA RRSIG DNSKEY NSEC3PARAM
CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN RRSIG NSEC3 8 2 86400 20190811044603 20190804033603 17708 com. DFIdCVmw76xkgFouDSnCX8/TUMjZOkvQ/VmNcdSW3tE2rTDsD6VszVwN p5vV0iBTyXFk1lM3F4edA+zWR+fyCMwFfQs0vGdL4PHYbYMfxlY9cswx 36W5suvp6oZGEMapfhDFRCcQG88kmIYjGKLjo9QAeTQKEStghE7DWD5S O3M=
4AJFHAJHFJAUROIL6A9UT0R2CIN7L8SP.com. 86400 IN NSEC3 1 1 0 - 4AJGQ4APQ38E7MDII5QJ737POPUBQVDT NS DS RRSIG
4AJFHAJHFJAUROIL6A9UT0R2CIN7L8SP.com. 86400 IN RRSIG NSEC3 8 2 86400 20190811053618 20190804042618 17708 com. bg9kMI5Kh/vTchfsMH0yMQXjCYdr4iK0dN+htgrkEQ1iXR47qATbQXpQ tWqNLeMBEpD5TFERcVgOhP1iuDXxmNwVT9PB3BQPgF+jCF3FYZlnl91L ExYdr96bDlVt7ZmeJk68+LiLKz1W0W70jw/hXBs9goKp9hswStOgCwK9 HPQ=
;; Received 714 bytes from 192.41.162.30#53(l.gtld-servers.net) in 261 ms

<xxxx>.mysql.rds.aliyuncs.com. 60	IN A 172.16.48.46
;; Received 88 bytes from 106.11.35.29#53(ns3.aliyun.com) in 6 ms
```

运行 dnsperf：

```bash
kubectl run -it --rm  --image=mrlesmithjr/dnsperf -- bash
echo "<xxxx>.mysql.rds.aliyuncs.com A" >> mysql
```
使用 coredns clusterIP: dnsperf -s 10.85.0.10 -l 30 -c 30 -Q 60 -v -d mysql

```bash
Statistics:

  Queries sent:         1800
  Queries completed:    1800 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 1800 (100.00%)
  Average packet size:  request 61, response 120
  Run time (s):         30.000178
  Queries per second:   59.999644

  Average Latency (s):  0.000563 (min 0.000404, max 0.000974)
  Latency StdDev (s):   0.000053
```

直接使用节点的 nameserver: dnsperf -s 100.100.2.138 -l 30 -c 30 -Q 60 -v -d mysql


```bash
Statistics:

  Queries sent:         1800
  Queries completed:    1800 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 1800 (100.00%)
  Average packet size:  request 61, response 77
  Run time (s):         30.000115
  Queries per second:   59.999770

  Average Latency (s):  0.000176 (min 0.000104, max 0.000353)
  Latency StdDev (s):   0.000033
```

直接使用阿里云的 dns 服务器：dnsperf -s 106.11.35.29 -l 30 -c 30 -Q 60 -v -d mysql

```bash
Statistics:

  Queries sent:         1800
  Queries completed:    1800 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 1800 (100.00%)
  Average packet size:  request 61, response 77
  Run time (s):         30.000118
  Queries per second:   59.999764

  Average Latency (s):  0.006806 (min 0.005873, max 0.009381)
  Latency StdDev (s):   0.000467
```
结论：因为有缓存的原因，最快的可能不是 dig +trace 的最后一跳，使用最快的那一个即可，上面节点上的 /etc/resolver 指向的 name server 最块。



## issue 2: timeout

[如何复现](https://github.com/kubernetes/kubernetes/issues/56903#issuecomment-518672637)

解决方案：

- 改容器的镜像
- 自定义 dnsconfig，添加 option
- 使用 nodelocaldns，nodelocaldns 会对整个 dns 解析有一个优化，但是升级会比较麻烦，高可用方案现在只能用于 kube-proxy 的 iptables。

coredns 配置

根据 [kubedns 性能测试 的报告](http://perf-dash.k8s.io/)，根据规模可以调整 coredns 的 request 和 limit。

设置 coredns 为 critical pod，避免节点内存压力被驱逐，目前集群中除了系统组件外，还有 coredns 和 ingress controller 设置为 critical pod

```bash
kubectl -n kube-system patch deployment nginx-ingress-controller -p '{"spec": {"template": {"spec": {"priorityClassName": "system-cluster-critical"}}}}'
```


advanced options

自定义 name server


一些特殊的情况可以自定义 name server，节点上的 dns 不能解析你的 dns，或者走节点的 dns 解析没有你已知的 name server 快，可以通过 coredns foward plugin 自定义。

```bash
apiVersion: v1
data:
  Corefile: |
    aliyuncs.com {
        forward . 106.11.35.29:53
        log
    }
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```
internal DNS to CNAME

外部的数据库一般都有一个 cname 地址，可以通过 externalName service 映射外部的数据库实例。好处是应用的配置只需要访问 my-rds 这个地址，而不需要关心 myapp.rds.whatever.aws.says。

```bash
apiVersion: v1
kind: Service
metadata:
  name: my-rds
spec:
  ports:
  - port: 12345
type: ExternalName
externalName: myapp.rds.whatever.aws.says
```


references

- [man resolv.conf](https://linux.die.net/man/5/resolv.conf)
- [kubernetes pod resolver](https://github.com/kubernetes/kubernetes/issues/78138)(结论应该是取决于镜像本身，alpine 会并发的查询 A 和 AAAA)
- [proposal for service externalName](https://github.com/kubernetes/kubernetes/pull/29073/files)
- [coredns ppt](https://github.com/coredns/presentations)
- [dns 升级迁移和资源配额](https://github.com/coredns/deployment/tree/master/kubernetes)
- [kubedns 性能测试](http://perf-dash.k8s.io/)