---
title: Crontab
---

Crontab 用于**定时周期性**执行任务或命令。

使用时请确保 crond 守护进程已运行，使用 crontab 命令进行管理。

:::info
如果计划任务产生**未被重定向的输出或错误**，则 crond 守护进程会尝试使用配置的邮件服务器将该信息通过电子邮件发送给作业所有者。
:::

## 常用命令

| 命令             | 描述                                                                 |
| ---------------- | -------------------------------------------------------------------- |
| crontab -u       | 创建用户可以指定用户，来管理其他用户的作业，若未指定则默认为当前用户 |
| crontab -l       | 列出当前用户的计划作业                                               |
| crontab -r       | 删除当前用户的所有作业                                               |
| crontab -e       | 编辑当前用户的作业                                                   |
| crontab filename | 删除所有作业，并替换为从 filename 读取的作业                         |

:::tip
- crontab 命令可以从 stdin（标准输入）读取数据，这样就不必创建一个临时文件来存储 crontab 配置，例如：
  `cat <stdin> | crontab -`
- 除非 `EDITOR` 环境变量配置了不同，否则 `crontab -e` 默认会调用 Vim 。
:::

## 配置语法

```bash
*    *    *    *    *
-    -    -    -    -
|    |    |    |    |
|    |    |    |    +----- 星期中星期几 (0 - 7) (星期天 为0或7)
|    |    |    +---------- 月份 (1 - 12) 
|    |    +--------------- 一个月中的第几天 (1 - 31)
|    +-------------------- 小时 (0 - 23)
+------------------------- 分钟 (0 - 59)
```
- "*"  ：表示始终
- 数字：注意0和7均可以表示周日
- x-y：表示范围，x到y（含）
- x,y：表示列表。例如分钟列中的 `5,10-13,17` 表示任务在每小时过去五分钟，10分钟，11分钟，12分钟，13分钟，17分钟后运行
- */x：x表示间隔的时间。例如分钟列中 `*/7` 表示每七分钟运行一次任务

例子：周一到周五每天上午9点到晚上6点每小时执行一次/usr/local/bin/daily_backup
```bash
00 09-18/1 * * Mon-Fri /usr/local/bin/daily_backup
# “/1”可以省略，表示在指定时间范围内每分钟都执行一次命令
00 09-18 * * Mon-Fri /usr/local/bin/daily_backup
```

格式和变量：
- 你可以声明 NAME=value 格式的环境变量。它将影响声明行下面的所有行，常见变量如下：
- SHELL 解释crontab的shell
- MAILT0 指定谁来接收邮件输出
## 自动化目录

应始终在 /etc/cron.d  目录下创建 crontab 文件, 防止在更新软件包时将 /etc/crontab 覆盖

下面这些应防止可执行的shell脚本，而不是crontab文件
- /etc/cron.daily
- /etc/cron.deny
- /etc/cron.hourly
- /etc/cron.monthly
- /etc/-cron.weekly


## 通过脚本设置 Crontab

- 把可执行文件扔到 /etc/cron.\* 目录里面就能执行。比如 /etc/cron.daily 就是每天执行的脚本。
- 如果需要更细致的时间控制，可以将crontab扔到 /etc/cron.d 里面，这里面的文件格式跟普通的 cron 类似，但是命令之前多了一个用户名，可以指定以任意身份执行命令。
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

## anacrontab

run-parts 是一个命令，用于执行一个目录（如 /etc/cron.daily）中所有可执行文件。通常在 /etc/crontab 文件中设置了类似以下的任务：


/etc/anacrontab 旨再确保重要的任务始终运行，不会因为系统在执行任务时关闭或休眠而意外跳过。例如，如果因系统重启而导致某个任务未按实质性，则在系统就绪后会继续执行作业，但是启动任务时可能会邮寄分钟延迟，具体要是 文件中为改作业制定的Delay in minutes 参数而定。

/etc/anacrontab 则是一个高级别的调度器，它也用于执行周期性任务。与 cron 不同的是，anacron 可以检查任务上次执行的时间，并在适当的情况下延迟执行，以确保任务得以完成。在 /etc/anacrontab 中设置的任务，并不会像 cron 一样按时触发，而是在指定的时间段内的任何时间点上运行。例如：

7   15    test.daily    /path/to/script.sh
这个任务意味着，在一天的闲置时间后的 15 分钟内，每 7 天执行一次 /path/to/script.sh 脚本。

anacron REL7 使用 crond来介系词文件

run-parts 和 /etc/anacrontab 可以结合使用，通过run-parts执行已经定义在 /etc/anacrontab 中的任务。例如，可以在 /etc/crontab 中设置：

### 配置语法


## Cron 最佳实践：

- https://blog.sanctum.geek.nz/cron-best-practices/
- https://www.endpointdev.com/blog/2008/12/best-practices-for-cron/
  学习笔记：
- https://www.geeksforgeeks.org/crontab-in-linux-with-examples/
- https://einverne.github.io/post/2017/03/crontab-schedule-task.html