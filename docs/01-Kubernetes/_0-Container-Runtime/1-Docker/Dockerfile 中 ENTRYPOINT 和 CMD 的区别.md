---
title: Dockerfile 中 ENTRYPOINT 和 CMD 的区别
tags: [Docker]
---
https://web.yueh.dev/learning/dockerfile-difference-between-entrypoint-and-cmd

:::tip
本文将会解释 `RUN`,`CMD`和`ENTRYPOINT`之间的不同之处以及如何在Dockerfiles中更好的使用它们。
:::
## RUN

**RUN 指令：用于指定 docker build 过程中要运行的命令。**

**语法格式：**

  + `shell` 格式：`RUN <command> `

  + `exec` 格式：`RUN ["<executeable>","<param1>","param2",...]`

  + `RUN ["/bin/bash","-c","<executeable>","param1","param2",...]`

## Entrypoint

**`Entrypoint`指令用于设定容器启动时第一个运行的命令及其参数**。

**语法格式**

+ `shell` 格式：`ENTRYPOINT <command> `

+ `exec` 格式：`ENTRYPOINT ["<executeable>","<param1>","<param2>",...]`

+ `ENTRYPOINT ["/docker-entrypoint.sh"]` 脚本名中通常包含entrypoint关键字。

  例如，下面就是Postgres官方镜像中的ENTRYPOINT脚本中的内容：

  ```bash
  #!/bin/bash
  set -e
  if [ "$1" = 'postgres' ]; then
      chown -R postgres "$PGDATA"
      if [ -z "$(ls -A "$PGDATA")" ]; then
          gosu postgres initdb
      fi
      exec gosu postgres "$@"
  fi
  exec "$@"
  ```

+ 在docker compose中使用entrypoint指令的方法与在Dockerfiles中一样，唯一不同的是在compose中entrypoint使用全小写的形式。
  你也可以在docker-compose.yml文件中以列表的形式来定义它的值：
  
  ```bash
  entrypoint:
      - php
      - -d
      - zend_extension=/usr/local/lib/php/xdebug.so
      - -d
      - memory_limit=-1
      - vendor/bin/phpunit
  ```
  
## CMD

**`CMD`（Dockerfiles）/ `command`指令的主要用意是设置容器的默认执行的命令。**`CMD / command`设定的命令会在`entrypoint`之后执行。

**语法格式：**

- `shell` 格式：`CMD <command>`

- `exec` 格式：`CMD ["executable","param1","param2",...]`

- 参数列表格式：`CMD ["param1", "param2",...]`(as default parameters to ENTRYPOINT)。在设置好`ENTRYPOINT`指令后，可将`CMD`指定的内容作为参数传给`ENTRYPOINT`

- 和`Dockerfiles`中使用`CMD`这样来定义的方式不同，`docker compose`中在`docker-compose.yml`使用的是`command`指令来定义：
  
  ```bash
  command: ["bundle", "exec", "thin", "-p", "3000"]
  ```

>可通过命令行传参的形式`docker run <image> <command>`，参数`<command>`可覆盖镜像`Dockerfiles中`的`CMD`指令。
>
>不要再Dockerfiles中多次定义CMD，不然，只会有最后一次定义的值会生效。
>
>`CMD` 指令的格式和 `RUN` 相似，二者运行的时间点不同；CMD 在docker run 时运行，而非docker build；

 ## 最佳实践

容器生命周期与PID为1的主进程有关，主进程退出则容器关闭。当使用`shell` 格式去启动一个进程signal时，实际的命令会被包装为  `sh -c signal `的参数的形式进行执行，`docker inspect signal`可以看到

```
Path:/bin/sh
Args:[
-c,
signal]
```

或者`docker exec signal ps` 看一下可以看到pid为1的进程并不是signal, 而是sh.

此时signal进程的状态与容器无关，这并不是我们想看到的。在`docker stop`命令执行的时候，会先向容器中PID为1的进程发送系统信号SIGTERM，而我们的signal进程无法收到SIGTERM信号无法优雅的退出。

由于综上原因所以推荐使用`exec`格式作为最佳实践，你需要将命令和其参数带双引号以JSON数组的格式书写。

> `exec`格式，Docker不会使用shell来运行。这意味着通常的shell处理过程不会发生。如果你需要在shell环境中运行，那么你可以这样做：
> CMD/ENTRYPOINT [ "sh", "-c", "executable" ]

任何使用`docker run <image> <command>`命令传入的`<command>`参数都会附加在`entrypoint`指令之后，并且用此命令传入的参数会覆盖在Dockerfile中使用`CMD`指令设定的值。比如`docker run <image> bash`命令会将`bash`命令附加在`entrypoint`指令设定的值的后面。

Docker建议使用ENTRYPOINT来设置镜像的主命令，然后再使用CMD指令来提供默认的标记。如下代码是同时使用这两个指令的一个例子：

```
FROM ubuntu
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
```

`CMD`应该总是以`CMD [“executable”, “param1”, “param2”…]`这种形式来定义。因此，如果这个镜像提供了诸如Apache或Rails的服务，你需要像`CMD ["apache2","-DFOREGROUND"]`这样来定义它。建议任何基于服务的镜像都以这种形式来定义CMD指令。

在[Dockerfile reference](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.docker.com%2Fengine%2Freference%2Fbuilder%2F%23usage)里针对这个问题有更多的解释。

> 以shell形式来定义`ENTRYPOINT`会防止任何`CMD`或`run`命令行参数的使用。但是它的缺点是，此时`ENTRYPOINT`会以`/bin/bash -c`下的一个子命令执行，这件导致无法传送信号。这也意味着执行的命令在容器里不是pid 1，因此它也收不到Unix信号。此时，执行命令将无法收到`docker stop <container>`命令发出的`SIGTEM`信号。

 如果`CMD`用于给`ENTRYPOINT`提供默认的参数，那么`CMD`和`ENTRYPOINT`指令都应该以JSON数组的形式来定义。

**例子**

```bash
java -Xmx256M -jar /app.jar

# 写成 exec 格式就是

ENTRYPOINT ["java", "-Xmx256M", "-jar", "/app.jar"]

# 而不能写成

ENTRYPOINT ["java", "-Xmx256M", "-jar /app.jar"]

```
exec 格式要求一个坑一个参数，所以像上面见到的那样无法在中间动态插入参数，比如不能在中间某一个位置上写上 "-Xmx5G -Xms2G", 这分明是两个参数，只能在后面附加参数

shell 格式由于命令总是由 "/bin/sh -e" 启动的子进程，它不是 PID 1 超级进程，从而无法收到 Unix 的信号，自然不能收到从 docker stop  发来的  SIGTERM 信号。

简述一下 docker stop  工作原理，它向容器中的 PID 为 1 进程发送 SIGTERM 信号，并给予 10 秒钟(可用参数 --time) 清理，超时才 -9 强杀，这样可以比较优雅的关闭容器。"/bin/sh -e" 是一个 PID 1 进程，它收到了 SIGTERM 却不会转发给它的子命令，这样就造成了 "/bin/sh -e" 收到 SIGTERM 未作响应被强杀，同时把它的子进程毫无征兆的干掉了。像在  Java 中用 Runtime.addShutdownHook() 是捕获不到该信号的。

## 总结

`CMD`和`ENTRYPOINT`都定义了容器运行时的执行命令。如下是它们的一些使用规则：

1. `CMD`和`ENTRYPOINT`在Dockerfiles中应该至少应该有一个被定义。
2. 当构建可执行容器时，应该定义`ENTRYPOINT`指令。
3. `CMD`要么用于给`ENTRYPOINT`提供默认参数，要么用于在容器中执行一个特定命令。
4. `CMD`可以通过容器启动命令`docker run`的参数来替换它。
5. `ENTRYPOINT`可以通过`docker run --entrypoint`或`docker-compose run --entrypoint`来替换它

## Find out more

Docker的官网文档可以查阅到Dockerfiles中的其他指令的用法和使用案例：

- [Docker’s Dockerfile Reference](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.docker.com%2Fengine%2Freference%2Fbuilder%2F%23usage)
- [Docker’s Docker Compose File Reference](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.docker.com%2Fcompose%2Fcompose-file%2F)
- [Docker’s Best practices for writing Dockerfiles](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.docker.com%2Fdevelop%2Fdevelop-images%2Fdockerfile_best-practices%2F)

**参考资料**：

[Docker ENTRYPOINT & CMD: Dockerfile best practices](https://links.jianshu.com/go?to=https%3A%2F%2Fmedium.freecodecamp.org%2Fdocker-entrypoint-cmd-dockerfile-best-practices-abc591c30e21)

https://yanbin.blog/dockerfile-difference-between-shell-exec-forms/

https://blog.csdn.net/m0_45406092/article/details/119007685
