---
title: Anacrontab
---

/etc/anacrontab 则是一个高级别的调度器，它也用于执行周期性任务。与 cron 不同的是，anacron 旨再确保重要的任务始终运行，可以检查任务上次执行的时间，，并在适当的情况下延迟执行，不会因为系统在执行任务时关闭或休眠而意外跳过。例如，如果因系统重启而导致某个任务未按实质性，则在系统就绪后会继续执行作业，但是启动任务时可能会存在分钟延迟，具体延迟由 `Delay in minutes` 参数而定。

如果系统上同时运行了 crond 和 anacron，则可能会出现计划任务的冲突。为了避免这种情况，我们使用 crond 来解释 `/etc/anacrontab` 文件。

:::warning
/etc/anacrontab 支持使用 NAME=value 的环境变量声明，但要注意 `START_HOURS_RANGE` 变量，它制定了任务运行的时间间隔，若超出此范围则任务将不会启动。如果某一天任务在此时间间隔内未运行，则必须等到第二天才能执行。
:::
## 常用命令

## 配置语法

在 /etc/anacrontab 中设置的任务，并不会像 cron 一样按时触发，而是在指定的时间段内的任何时间点上运行。例如：
```bash
7 15 test.daily /path/to/script.sh
```
这个任务意味着，在一天的闲置时间后的 15 分钟内，每 7 天执行一次 /path/to/script.sh 脚本。

run-parts 是一个命令，用于执行一个目录（如 /etc/cron.daily）中所有可执行文件。通常 run-parts 和 /etc/anacrontab 可以结合使用,在 /etc/anacrontab 文件中设置了类似以下的任务：
```bash
❯ cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1       5       cron.daily              nice run-parts /etc/cron.daily
7       25      cron.weekly             nice run-parts /etc/cron.weekly
@monthly 45     cron.monthly            nice run-parts /etc/cron.monthly
```
