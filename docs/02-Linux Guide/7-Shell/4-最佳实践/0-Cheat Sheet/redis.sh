[root@redis-master src]# vim /etc/init.d/redis-server
#!/bin/bash
# redis - this script starts and stops the redis-server daemon
# chkconfig:   - 85 15
# description:  Redis is a persistent key-value database
# processname: redis-server
# config:      /usr/local/redis/etc/redis.conf
# config:      /etc/sysconfig/redis
# pidfile:     /usr/local/redis/var/redis-server.pid
  
# Source function library.
. /etc/rc.d/init.d/functions
  
# Source networking configuration.
. /etc/sysconfig/network
  
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
  
redis="/usr/local/redis/bin/redis-server"
prog=$(basename $redis)
  
REDIS_CONF_FILE="/usr/local/redis/etc/redis.conf"
  
[ -f /etc/sysconfig/redis ] && . /etc/sysconfig/redis
  
lockfile=/var/lock/subsys/redis-server
  
start() {
    [ -x $redis ] || exit 5
    [ -f $REDIS_CONF_FILE ] || exit 6
    echo -n $"Starting $prog: "
    daemon $redis $REDIS_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
  
stop() {
    echo -n $"Stopping $prog: "
    killproc $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
  
restart() {
    stop
    start
}
  
#reload() {
#    echo -n $"Reloading $prog: "
#    killproc $redis -HUP
#    RETVAL=$?
#    echo
#}
  
#force_reload() {
#    restart
#}
  
#rh_status() {
#    status $prog
#}
  
#rh_status_q() {
#    rh_status >/dev/null 2>&1
#}
  
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
#    reload)
#        rh_status_q || exit 7
#        $1
#        ;;
#    force-reload)
#        force_reload
#        ;;
#    status)
#        rh_status
#        ;;
#    condrestart|try-restart)
#        rh_status_q || exit 0
#            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 2
esac
 
# 执行权限
[root@redis-master src]# chmod 755 /etc/init.d/redis-server