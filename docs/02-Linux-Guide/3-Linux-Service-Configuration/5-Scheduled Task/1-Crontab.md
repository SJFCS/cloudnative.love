---
title: Crontab
---

Crontab 用于**定时周期性**执行任务或命令。

使用时请确保 crond 守护进程已运行，使用 crontab 命令进行管理。

:::warning
- crontab 依赖系统时间，修改时间或者时区后需要重启 crond 服务。
- 在 crontab 中 % 是有特殊含义的，表示换行的意思。如果要用的话必须进行转义 \%，如经常用的 date '+%Y%m%d' 在 crontab 里是不会执行的，应该换成 date '+\%Y\%m\%d'。 
- 如果计划任务产生**未被重定向的输出或错误**，则 crond 守护进程会尝试使用配置的邮件服务器将该信息通过电子邮件发送给作业所有者。
:::

## 常用命令

| 命令             | 描述                               |
| ---------------- | ---------------------------------- |
| crontab -u       | 指定用户，若未指定则默认为当前用户 |
| crontab -l       | 列出当前用户的计划作业             |
| crontab -r       | 删除当前用户的所有作业             |
| crontab -e       | 编辑当前用户的作业                 |
| crontab filename | 导入作业，并清空原有作业           |

:::tip
- 导出 crontab: `crontab -l > crontab.txt`
- 导入 crontab: `crontab crontab.txt`
- crontab 命令可以从 stdin（标准输入）读取数据，这样就不必创建一个临时文件来存储 crontab 配置，例如：
  `cat <stdin> | crontab -`
- 除非 `EDITOR` 环境变量配置了不同编辑器，否则 `crontab -e` 默认会调用 Vim 。
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

- "\*" ：表示始终
- 数字：注意 0 和 7 均可以表示周日
- x-y：表示范围，x 到 y（含）
- x,y：表示列表。例如分钟列中的 `5,10-13,17` 表示任务在每小时过去五分钟，10 分钟，11 分钟，12 分钟，13 分钟，17 分钟后运行
- _/x：x 表示间隔的时间。例如分钟列中 `_/7` 表示每七分钟运行一次任务
- 还可以使用简写： "@reboot"、"@yearly"、"@annually"、"@monthly"、"@weekly"、"@daily"、"@midnight"、 "@hourly"、"@every_minute"、"@every_2_hours" 
- 可以声明 NAME=value 格式的环境变量。它将影响声明行下面的所有行：
  - `SHELL` 解释 crontab 的 shell
  - `MAILT0` 指定谁来接收邮件输出

例子：周一到周五每天上午 9 点到晚上 6 点每小时执行一次 `/usr/local/bin/daily_backup`
```bash
00 09-18/1 * * Mon-Fri /usr/local/bin/daily_backup
# “/1”可以省略，表示在指定时间范围内每分钟都执行一次命令
00 09-18 * * Mon-Fri /usr/local/bin/daily_backup
```

## 系统任务

系统任务以 root 身份运行。系统级别的 crontab 文件通常保存在 `/etc/crontab` 文件和 `/etc/cron.d` 目录中。
:::warning建议
创建系统任务时应始终在 `/etc/cron.d` 目录下创建 crontab 文件, 防止在更新软件包时将 `/etc/crontab` 覆盖。  
:::

可执行文件和脚本若要周期性运行，可将其放在 `/etc/cron.*` 目录下，例如用于执行系统维护任务，如日志轮换、备份等。目录如下：

- /etc/cron.daily
- /etc/cron.deny
- /etc/cron.hourly
- /etc/cron.monthly
- /etc/-cron.weekly


:::warning
注意: 这些目录应放置可执行文件，而不是 crontab 文件
:::
## 用户任务

`crontab -e` 命令用于编辑当前用户的 cron 作业配置文件，该文件默认存储在 `/var/spool/cron/crontabs/` 目录下，文件名为当前用户的用户名。注意，这个文件权限为`0600`只能由系统管理员和当前 owner 编辑。

```bash title="通过脚本设置用户任务"
echo "*/5 * * * * /path/to/command" | sudo install -m 0600 -o myuser -g crontab /dev/stdin /var/spool/cron/crontabs/myuser
```
上述示例将 "*/5 * * * * /path/to/command" 这个Cron作业添加到 "myuser" 用户的 Cron 作业文件中：
- "-m"选项设置文件的权限为"0600"
- "-o"选项设置所有者为"myuser"
- "-g"选项设置组为"crontab"。
