# Linux Logs
/var/log/syslog：记录系统级别的事件和错误，如启动和关闭、进程启动和停止、内核消息等等。

/var/log/auth.log：记录系统身份验证和授权事件，如用户登录、sudo操作、SSH连接等等。

/var/log/kern.log：记录与内核相关的事件和错误，例如硬件驱动程序、系统调用等等。

/var/log/messages：记录系统级别和应用程序级别的事件和错误，包括上述日志文件中未记录的信息。


/var/log/messages：包含系统的大多数日志信息，包括启动、关机、系统内核、网络服务等。
/var/log/syslog：包含系统的系统日志信息，如用户登录、系统错误、邮件等。
/var/log/auth.log：包含系统的认证日志信息，如用户登录、su切换、sudo使用等。
/var/log/secure：类似于auth.log，但是是在安全模式下的日志信息。
/var/log/dmesg：包含系统启动时内核的输出信息。
/var/log/boot.log：包含系统启动过程中的输出信息。
/var/log/httpd/：包含Apache Web服务器的访问日志信息。
/var/log/mysql/：包含MySQL服务器的运行日志信息。
/var/log/maillog：包含邮件服务器的运行日志信息。
/var/log/cron：包含定时任务的日志信息。
注：日志文件路径和名称可能因Linux系统的版本和安装的软件而有所不同。