## 辅助容器

```
FROM nginx
RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY content /usr/share/nginx/html
COPY conf /etc/nginx
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx
VOLUME /var/log/nginx/log
```
docker build -t mynginx_image
docker run --name mynginx -p 80:80 -d mynginx_image
启动一个具有 shell 的辅助容器 mynginx4_files，以访问刚刚创建的 mynginx4 容器的内容和配置目录：
docker run -i -t --volumes-from mynginx --name mynginx4_files debian /bin/bash

:::tip
按下 Ctrl+p，然后按下 Ctrl+q：这个方法会将你从当前容器的 shell 中断开，但是容器仍然在后台运行，你可以通过执行 "docker attach" 命令重新连接到容器的 shell。

按下 Ctrl+d 或者输入 exit 命令：这个方法会终止当前容器的运行，同时也会关闭容器中的 shell。
:::
