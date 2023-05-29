---
title: At
---
at 命令可为 Linux 用户安排**延迟任务**。使用时请确保 at 已安装且 atd 守护进程已运行。

用户可以使用 at 为 atd 守护进程添加任务队列，atd 守护进程提供了 a 到 z 共 26 个队列，越往后优先级越低。

## 创建延迟任务
`at TIMESPEC` 以交互方式创建新任务，如输入 `at now +5min` 后 at 会从 stdin 管道读取要执行的命令，此时手动输入需要延迟执行的任务命令后按 `Ctrl + d` 保存退出。

`TIMESPEC` 参数允许用户描述准确的作业时间，下面列出了一些组合示例：
- now +5min
- teatime tomorrow (teatime 为 16:00)
- noon +4 days
- 5pm august 3 2021

```bash title="以交互方式创建作业"
❯ at -q g teatime
at Mon May 15 16:00:00 2023
at> echo "It's teatime" >> /home/admin/tea.txt
at> Ctrl+d
job 9 at Mon May 15 16:00:00 2023
``` 

```bash title="以管道方式创建一个作业"
❯ echo "date >> /home/admin/myjob.txt" |at now +10min
job 8 at Sun May 14 16:25:00 2023
```

```bash title="对于复杂的脚本使用重定向更为方便"
❯ at now +5min < myscript.sh
```



## 查看和检查延迟任务
:::caution
- 非特权用户只能查看和管理自身的作业，root 用户可以查看和管理所有作业
- 当作业执行后，作业将自动从队列中删除。 
:::

```bash title="查看队列信息"
❯ atq # 或 `at -l`
8           Sun May 14 16:25:00 2023    a         admin
作业编号     计划作业的执行时间             默认队列a   用户
```
显示任务内容以检查是否可用 `at -c 作业编号`
```bash title="查看队列内容"
❯ at -c 8
```

## 删除作业
`atrm 作业编号` 将会删除计划的作业

```bash
❯ atq
9       Mon May 15 16:00:00 2023 g admin
❯ atrm 9
❯ atq
```