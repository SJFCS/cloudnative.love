---
title: 排错、调优和测试
---
`ls –lhS` 将文件以从大到小顺序展现
`du -h --max-depth=1 | sort -hr`  
`du -h --max-depth=0 /tmp`  
`du -s /tmp`
`iostat`
如果 mv 命令卡住了，可以尝试使用另一个终端窗口或标签页运行以下命令，以查看正在进行的进度：
`lsof -p $(pgrep mv)`
这将显示 mv 命令正在使用的所有文件和文件描述符。你可以根据这些信息确定 mv 命令当前正在做什么，以及它是否卡在了某个文件上。

