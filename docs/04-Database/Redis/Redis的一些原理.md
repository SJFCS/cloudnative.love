# Redis的一些原理

https://blog.csdn.net/men_wen/article/details/75668345

#### 如何理解Redis集群的Slot映射
##### redis使用slot作为索引来管理数据
> Redis在单机模式时，使用数据结构dict来实现数据库。
>
> Redis在集群模式时，也是使用数据结构dict来实现数据库，但是集群模式对于数据库有其他需求，包括数据的节点无关性、内部操作对客户端需要屏蔽、冗余备份等，
  并且在一定的情况，数据还需要在不同的节点间实现迁移。
> 
> Redis引入的slot来解决如何实现集群模式下部分需求的问题？事实下，节点并不是存储在slot里面，slot只是用于管理数据与节点相联的手段而已。
  在处理相关逻辑问题时，redis使用slot作为索引来管理数据下的所有数据。
>
> 举一个例子，集群模式下，使用redis-cli连接服务器节点A（指派了slot[2000-3000]）并issue如下指令set name derekzhuo
  服务器节点A计算name的slot为1000，发现slot 1000不在本节点上，向redis-cli返回该slot的节点信息； 
  redis-cli连接新的node，并且重新issue该指令。以上流程就是cluster模式下如何处理一个键的流程，也可以很清楚地看出slot的作用其实就是用于做key索引而已。
