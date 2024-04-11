```conf
server {
        listen          8080; # 监听端口
        server_name     project_name; # 网站名称
        root            /home/work/project_name; # 静态文件地址，自己根据情况指定
        # 如果你的项目指定了basename，那么这里需要路径重写
        # 否则所有的静态文件请求都会返回html文件
        location ~* ^/(basename) {
                rewrite "^/basename/(.*)$" /$1 break;
                try_files  $uri /index.html;
        }
        # 如果你的接口地址不是直接请求后端，而是和前端地址一样
        # 那么需要设置nginx代理，可以这样设置
        location /api {
            pass_proxy: http://10.0.0.112.114:9000
        }
        # 设置允许跨域
        proxy_set_header Access-Control-Allow-Origin *;
        # 设置一些缓存相关的请求头
        add_header Cache-Control no-cache;
}
```