```
首先进入到 /var/lib/docker/overlay2 目录下,查看谁占用的较多

du -s ./* | sort -rn | more

3、再通过目录名查找容器名

docker ps -q | xargs docker inspect --format '{{.Image}}, {{.Name}}, {{.GraphDriver.Data.WorkDir}}' | grep 67a4
```