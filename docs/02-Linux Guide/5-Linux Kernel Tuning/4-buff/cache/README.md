buff/cache是Linux系统中的内存缓存，用于加速文件系统的访问速度。

buff/cache是buffers和cache之和

buffers是内核缓冲区用到的内存，对应的是/proc/meminfo 中的 Buffers 值

cache是内核页缓存和Slab用到的内存，对应的是/proc/meminfo中的Cached与SReclaimable之和


如果需要清理buff/cache，可以使用以下命令之一：

通过释放内存的方式清理buff/cache：
   echo 1 > /proc/sys/vm/drop_caches
通过释放PageCache和dentries/inodes的方式清理buff/cache：
   sync && echo 2 > /proc/sys/vm/drop_caches && sync
通过释放PageCache、dentries/inodes以及swap cache的方式清理buff/cache：
   sync && echo 3 > /proc/sys/vm/drop_caches && sync
注意：清理buff/cache可能会导致系统的性能有所下降，因此应该谨慎使用。








https://www.zhihu.com/question/29203599/answer/3135136268




