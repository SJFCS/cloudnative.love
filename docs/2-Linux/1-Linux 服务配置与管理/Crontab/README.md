---
title: Crontab
---
Crontab 用于定时周期性执行任务或命令。

Cron 最佳实践：
- https://blog.sanctum.geek.nz/cron-best-practices/
- https://www.endpointdev.com/blog/2008/12/best-practices-for-cron/
学习笔记：
- https://www.geeksforgeeks.org/crontab-in-linux-with-examples/
- https://einverne.github.io/post/2017/03/crontab-schedule-task.html
## 通过脚本设置 Crontab
- 把可执行文件扔到 /etc/cron.* 目录里面就能执行。比如 /etc/cron.daily 就是每天执行的脚本。
- 如果需要更细致的时间控制，可以将脚本扔到 /etc/cron.d 里面，这里面的文件格式跟普通的 cron 类似，但是命令之前多了一个用户名，可以指定以任意身份执行命令。
- 如果想实现类似 crontab -e 的管理方式，那么直接去 /var/spool/cron/ 修改文件就好了，那个目录里面的文件名对应着用户名
    ```bash
    echo "00 */1 * * * commandxxx" >> /var/spool/cron/root
    ```
- 导出和导入
    ```bash
    crontab -l > now.cron
    echo '0 0 * * * echo test' >> now.cron
    crontab now.cron
    ```