---
title: Docker 挂载单文件与主机不同步
tags: [Docker]
---
容器挂载了主机的文件，在主机上修改了容器里却没有同步，怎么回事？

示例: 起动 `nginx:1.14-alpine`，并挂载`/etc/nginx/conf.d/default`配置文件
``` bash
docker run -v default.conf:/etc/nginx/conf.d/default.conf -p 8080:80 -d nginx:1.14-alpine
```

然后在主机上修改了配置文件 `default.conf`，保存后发现容器内配置文件还是之前的和主机上面配置文件的不同步。

经过搜索找到了相关 issue： https://github.com/moby/moby/issues/6011

:::tip 原因
-v mount 挂载文件(或文件夹)时，docker 记录的是该文件的 inode，并用 inode 追踪。

当 vim 编辑了文件后，这个文件的 inode 就变了，所以不会同步更改。

同时该 issue 的 opener 使用的是 sed -i 修改，也会使 inode 发生变化，sed -i 的机制是创建一个新的临时文件，修改完后在重命名。
:::

对此，官方的建议是挂载文件夹，而不是文件。

同时有一个 PR 提交，添加挂载文件的注意事项。https://github.com/moby/moby/pull/6854/files#diff-cfc3e3181238c09727f367b4ce9931b4d87d626b97af68605f82b12f03819479