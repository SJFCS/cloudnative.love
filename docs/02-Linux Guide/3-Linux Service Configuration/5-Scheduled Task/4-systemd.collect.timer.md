---
title: sysstat-collect.timer
---

https://www.ruanyifeng.com/blog/2018/03/systemd-timer.html

systemd 定时器单元可激活另一个不同类型的单元（如某个服务）

样本：
sysstat-collect.timer

```bash
[Unit]
Description=Run system activity accounting tool every 10 minutes

[Timer]
OnCalendar=*:00/10

[Install]
WantedBy=sysstat.service
```

每十分钟
2019-03-*2：35，37，39：16
2019年整个三月的每一天，分别于12：35：16、12：37：16和12：39：16激活相应服务单元

可以使用参数（如OnUnitActiveSec）来指定相对定时器，如 OnUnitActiveSec=5min 选项将使用定时器单元再改定时器单元最后一次激活其相应单元15分钟后触发相应单元

:::cautioin
请勿修改 /usr/lib/systemd/system 目录下的任何单元配置文件，其会被软件包更新所覆盖。
请在 /etc/systemd/system 目录下复制您要更改带的单元配置文件
如果 存在两个同名的文件，则/etc/systemd/system目录下的文件生效

:::


配置顶是单元配置文件后使用
systemctl daemon-reload 重载systemd配置

使用 `systemctl enable --now <unitname>.timer`