
[019-批量修改redis TTL和批量删除key](https://anjia0532.github.io/2019/05/10/redis-batch-changed-ttl/)

[集群架构实例的命令限制](https://help.aliyun.com/document_detail/145968.htm?spm=a2c4g.11186623.0.0.3cf665b3kC0dXx)

[lua中神奇的table](http://blog.lujun9972.win/blog/2018/06/17/lua%E4%B8%AD%E7%A5%9E%E5%A5%87%E7%9A%84table/index.html)

[Redis 如何批量设置过期时间？PIPLINE的使用](https://juejin.cn/post/7033389382769836063)

[Redis Scan 原理解析与踩坑](https://www.lixueduan.com/posts/redis/redis-scan/)

[Redis：使用scan配合lua脚本进行删除key](https://www.jianshu.com/p/5a95a8209e5b)

[Redis结合Lua脚本实现高并发原子性操作 ](https://www.cnblogs.com/barrywxx/p/8563284.html)

```
向redis插入上千万数据
批量生成redis测试数据
1.Linux Bash下面执行
  for((i=1;i<=20000000;i++)); do echo "set k$i v$i" >> /tmp/redisTest.txt ;done;
  生成2千万条redis批量设置kv的语句(key=kn,value=vn)写入到/tmp目录下的redisTest.txt文件中
2.用vim去掉行尾的^M符号，使用方式如下：：
  vim /tmp/redisTest.txt
    :set fileformat=dos #设置文件的格式，通过这句话去掉每行结尾的^M符号
    ::wq #保存退出
3.通过redis提供的管道--pipe形式，去跑redis，传入文件的指令批量灌数据，需要花10分钟左右
  cat /tmp/redisTest.txt | 路径/redis-5.0.0/src/redis-cli -h 主机ip -p 端口号 --pipe
```

-ERR bad lua script for redis cluster, all the keys that the script uses should be passed using the KEYS arrayrn
阿里云的Redis集群对Lua脚本调用的时候做了限制：

为了保证脚本里面的所有操作都在相同slot进行，云数据库Redis集群版本会对Lua脚本做如下限制：

`所有key都应该由KEYS数组来传递，redis.call/pcall中调用的redis命令，key的位置必须是KEYS array（不能使用Lua变量替换KEYS），否则直接返回错误信息：`

```lua
--获取KEY
local key1 = KEYS[1]

local val = redis.call('incr', key1)
local ttl = redis.call('ttl', key1)

--获取ARGV内的参数并打印
local times = ARGV[1]
local expire = ARGV[2]

redis.log(redis.LOG_DEBUG,tostring(times))
redis.log(redis.LOG_DEBUG,tostring(expire))

redis.log(redis.LOG_NOTICE, "incr "..key1.." "..val);
if val == 1 then
    redis.call('expire', key1, tonumber(expire))
else
    if ttl == -1 then
        redis.call('expire', key1, tonumber(expire))
    end
end

if val > tonumber(times) then
    return 0
end

return 1
```

本脚本的功能是通过Redis做集群的限流，此处不做赘述。有时间会专门写一节关于Redis实现分布式限流的文章。

解决
因为使用的是redis集群，在调用lua脚本的时候，key的位置必须是数组（不能使用Lua变量替换KEYS数组），否则直接返回错误信息。所以需要对lua脚本进行改正，去掉自定义的变量local，直接使用传入的KEYS数组。

```lua
--获取KEY
-- local key1 = KEYS[1] **去掉**

local val = redis.call('incr', KEYS[1])
local ttl = redis.call('ttl', KEYS[1])

--获取ARGV内的参数并打印
local times = ARGV[1]
local expire = ARGV[2]

redis.log(redis.LOG_DEBUG,tostring(times))
redis.log(redis.LOG_DEBUG,tostring(expire))

redis.log(redis.LOG_NOTICE, "incr "..KEYS[1].." "..val);
if val == 1 then
    redis.call('expire', KEYS[1], tonumber(expire))
else
    if ttl == -1 then
        redis.call('expire', KEYS[1], tonumber(expire))
    end
end

if val > tonumber(times) then
    return 0
end

return 1
```
## Lua使用限制

为了保证脚本里面的所有操作都在相同slot进行，云数据库Redis集群版本会对Lua脚本做如下限制：

-   所有key都应该由KEYS数组来传递，
    
    `redis.call/pcall`
    
    中调用的redis命令，key的位置必须是KEYS array（不能使用Lua变量替换KEYS），否则直接返回错误信息：
    
    ```shell
    -ERR bad lua script for redis cluster, all the keys that the script uses should be passed using the KEYS arrayrn
    ```
    
-   所有key必须在一个slot上，否则返回错误信息：
    
    ```shell
    -ERR eval/evalsha command keys must be in same slotrn
    ```
    
-   调用必须要带有key，否则直接返回错误信息：
    
    ```shell
    -ERR for redis cluster, eval/evalsha number of keys can't be negative or zerorn
    ```
    

参考地址：[Lua脚本支持与限制](https://help.aliyun.com/document_detail/92942.html?spm=5176.13910061.sslink.1.36426f0dV6cOrU)

```
org.redisson.client.RedisException: ERR bad lua script for redis cluster, all the keys that the script uses should be passed using the KEYS array, and KEYS should not be in expression. 
```
修改阿里云redis中script_check_enable参数为0即可解决该问题
https://developer.aliyun.com/article/645851