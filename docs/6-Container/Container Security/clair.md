# 使用clair扫描Docker镜像漏洞

[[toc]]

参考: 
- [https://github.com/arminc/clair-scanner](https://github.com/arminc/clair-scanner)

我们可以通过`clair`来扫描Docker镜像漏洞。

## 1. 安装基础工具

我们需要安装`git`和`golang`:

```sh
$ sudo yum install -y git golang
```

查看`git`和`golang`的版本信息：

```sh
$ git --version
git version 2.24.4
$ go version
go version go1.16.13 linux/amd64
```

配置`go`加速：

```sh
# Golang environment settings
export GOROOT=/usr/lib/golang # golang install path
export GOPATH=~/data/go_data # golang workspace
export GOBIN=${GOPATH}/bin # golang exe files
export PATH=${GOBIN}:${PATH}
export GOPROXY=https://goproxy.cn
export GO111MODULE=on
```

将以上配置加入到`~/.bashrc`文件中，并使用`source ~/.bashrc`加载配置。



## 2. 编译安装clair-scanner

```sh
# Clone the repo 下载代码
$ git clone https://github.com/arminc/clair-scanner.git

# Build and install 构建和安装
$ cd clair-scanner
$ make build
$ make installLocal

# Run 运行
$ ./clair-scanner -h
```



## 3. 下载镜像

```sh
# 下载漏洞数据库镜像
$ docker pull arminc/clair-db

# 下载clair-local-scan镜像
$ docker pull arminc/clair-local-scan:v2.1.8_9bca9a9a7bce2fd2e84efcc98ab00c040177e258
```

查看镜像：
```sh
$ docker images
REPOSITORY                TAG                                               IMAGE ID       CREATED        SIZE
arminc/clair-db           latest                                            a2f42fc0ce5e   14 hours ago   679MB
arminc/clair-local-scan   v2.1.8_9bca9a9a7bce2fd2e84efcc98ab00c040177e258   e77be8484e41   14 hours ago   464MB
redis                     latest                                            bba24acba395   7 days ago     113MB
```



## 4. 运行容器

运行容器：

```sh
$ docker run -d --name clair-db arminc/clair-db:latest
0a2721f943bfbe45250a129564d36ab2b1c78dfdb0bed4c9f53243426e3a7a02
$ docker run -p 6060:6060 --link clair-db:postgres -d --name clair arminc/clair-local-scan:v2.1.8_9bca9a9a7bce2fd2e84efcc98ab00c040177e258
28edf93ba32b66d5616d41337cfc5b449788669032ecb26b9994d68bf1ac9334
$ 
```

查看运行的容器：

```sh
$ docker ps
CONTAINER ID   IMAGE                                                                     COMMAND                  CREATED              STATUS              PORTS                                                 NAMES
28edf93ba32b   arminc/clair-local-scan:v2.1.8_9bca9a9a7bce2fd2e84efcc98ab00c040177e258   "/usr/bin/dumb-init …"   About a minute ago   Up About a minute   0.0.0.0:6060->6060/tcp, :::6060->6060/tcp, 6061/tcp   clair
0a2721f943bf   arminc/clair-db:latest                                                    "docker-entrypoint.s…"   2 minutes ago        Up 2 minutes        5432/tcp                                              clair-db
$
```



## 5. 扫描

获取docker0的IP信息：

```sh
$ ifconfig docker0|grep "inet "
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
```

此处的`172.18.0.1`即是docker0的IP。



我们对下载的`redis`镜像进行扫描：

```sh
$ clair-scanner --ip="172.18.0.1" -c "http://localhost:6060" redis:latest 2>&1 > redis.report
2022/04/06 23:33:52 [INFO] ▶ Start clair-scanner
2022/04/06 23:33:56 [INFO] ▶ Server listening on port 9279
2022/04/06 23:33:56 [INFO] ▶ Analyzing ce48e167cda6274020886d8aabe7c3e6abde585ad1c70b82ffb1552e63e9fd05
2022/04/06 23:33:56 [INFO] ▶ Analyzing dab7039dbbb8a78585185a7a03ab46192f8e16b56a53ad26d85b859146b1b537
2022/04/06 23:33:56 [INFO] ▶ Analyzing c26aeb5606adb4e186fde99b2e864347fe880e0ab67a49c58cfd046f10bdc54e
2022/04/06 23:33:56 [INFO] ▶ Analyzing 6c6b40f210f159593404920484982353968f7af428de397e9f791786ded74628
2022/04/06 23:33:56 [INFO] ▶ Analyzing 7af902ae1e7b599066bda5c9f1122a9ea3127a7002acb26e26ce0357633c6437
2022/04/06 23:33:56 [INFO] ▶ Analyzing 257cc5e4f2ad448c685be02ef26e0ea40daf48efa1049121e5adeb4bfc65ca55
2022/04/06 23:33:56 [WARN] ▶ Image [redis:latest] contains 39 total vulnerabilities
2022/04/06 23:33:56 [ERRO] ▶ Image [redis:latest] contains 39 unapproved vulnerabilities
$ head -n 13 redis.report 
+------------+-----------------------------+--------------+------------------+--------------------------------------------------------------+
| STATUS     | CVE SEVERITY                | PACKAGE NAME | PACKAGE VERSION  | CVE DESCRIPTION                                              |
+------------+-----------------------------+--------------+------------------+--------------------------------------------------------------+
| Unapproved | Low CVE-2016-2781           | coreutils    | 8.32-4           | chroot in GNU coreutils, when used with --userspec,          |
|            |                             |              |                  | allows local users to escape to the parent session           |
|            |                             |              |                  | via a crafted TIOCSTI ioctl call, which pushes               |
|            |                             |              |                  | characters to the terminal's input buffer.                   |
|            |                             |              |                  | https://security-tracker.debian.org/tracker/CVE-2016-2781    |
+------------+-----------------------------+--------------+------------------+--------------------------------------------------------------+
| Unapproved | Negligible CVE-2011-4116    | perl         | 5.32.1-4+deb11u2 | _is_safe in the File::Temp module for                        |
|            |                             |              |                  | Perl does not properly handle symlinks.                      |
|            |                             |              |                  | https://security-tracker.debian.org/tracker/CVE-2011-4116    |
+------------+-----------------------------+--------------+------------------+--------------------------------------------------------------+
```

效果图如下：


可以看到最新的`redis`镜像包含39个漏洞需要处理。



## 6. 故障排除

[https://github.com/arminc/clair-scanner](https://github.com/arminc/clair-scanner) 中给出了几个常见故障的示例：

>  Troubleshooting
>
> If you get `[CRIT] ▶ Could not save Docker image [image:version]: Error response from daemon: reference does not exist`, this means that image `image:version` is not locally present. You should have this image present locally before trying to analyze it (e.g.: `docker pull image:version`).
>
> Errors like `[CRIT] ▶ Could not analyze layer: Clair  responded with a failure: Got response 400 with message  {"Error":{"Message":"could not find layer"}}` indicates that Clair can not retrieve a layer from `clair-scanner`. This means that you probably specified a wrong IP address in options (`--ip`). Note that you should use a publicly accessible IP when clair is running in a container, or it wont be able to connect to `clair-scanner`. If clair is running inside the docker, use the docker0 ip address. You can find the docker0 ip address by running `ifconfig docker0 | grep inet`
>
> `[CRIT] ▶ Could not read Docker image layers: manifest.json is not valid` fires when image version is not specified and is required. Try to add `:version` (.e.g. `:latest`) after the image name.
>
> `[CRIT] ▶ Could not analyze layer: POST to Clair  failed Post http://docker:6060/v1/layers: dial tcp: lookup docker on  127.0.0.53:53: no such host` indicates that clair server could ne be reached. Double check hostname and port in `-c` argument, and your clair settings (in clair's `docker-compose.yml` for instance if you run it this way).

即：

- `[CRIT] ▶ Could not save Docker image [image:version]: Error response from daemon: reference does not exist`，即`image:version`镜像不在本地，即你没有下载该镜像，不能直接扫描，需要使用`docker pull image:version`先下载镜像。
- `[CRIT] ▶ Could not analyze layer: Clair responded with a failure:  Got response 400 with message {"Error":{"Message":"could not find  layer"}}`，即`--ip`配置异常，应使用`ifconfig docker0|grep inet`来获取docker0的IP地址。
- `[CRIT] ▶ Could not read Docker image layers: manifest.json is not valid`，未指定镜像版本信息。
- `[CRIT] ▶ Could not analyze layer: POST to Clair failed Post  http://docker:6060/v1/layers: dial tcp: lookup docker on 127.0.0.53:53:  no such host`，Clair服务器网站无法访问。应仔细检查`-c`参数中的主机名和端口，对应本文中的`docker run -p 6060:6060 --link clair-db:postgres -d --name clair arminc/clair-local-scan:v2.1.8_9bca9a9a7bce2fd2e84efcc98ab00c040177e258`运行的容器。

