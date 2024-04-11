---
title: Journalctl命令详解和持久化
---

:::info 推荐阅读
[Journalctl中文手册-金步国](http://www.jinbuguo.com/systemd/journalctl.html)
:::

## 简介

Systemd 统一管理所有 Unit 的启动日志。带来的好处就是 ，可以只用journalctl一个命令，查看所有日志（内核日志和 应用日志）。

**journalctl配置文件路径 ▼**

```
/etc/systemd/journald.conf 
```

**journalctl日志保存路径 ▼**

```
/var/log/journal
```

- 日志服务仅将日志文件保存在单个结构中。
- 因为日志是压缩和格式化的二进制数据，所以在查看和定位非常快。

## 基本命令

journal后跟参数或match字段来进行日志过滤

match字段可以通过 "FIELD=VALUE" 的格式来匹配具体的日志记录, 如：_SYSTEMD_UNIT=sshd.service，等同于参数-u sshd.service

日志信息的定义也类似一个实体类型，具体的信息被保存在各个对应的字段中，比如 MESSAGE、MESSAGE_ID、_PID、_UID、_HOSTNAME、_SYSTEMD_UNIT 等等因此可以通过这些字段的内容匹配相关的日志记录：

**查看所有可用的 match 字段`man   systemd.journal-fields `**

+ 可以同时添加多个不同字段或参数进行匹配，它们之间是与的关系，就是同时符合多个条件的记录才会被匹配

+ 不同字段之间如果用+链接表示或关系，相同字段 空格链接 表示或关系

**可以使用man和-h来查询详细用法**

```bash
journalctl -h
man journalctl

# 查看所有可用的 match 字段
man   systemd.journal-fields 
```


```
Flags:
     --system              显示系统日志
     --user                显示当前用户的用户日志
  -M --machine=CONTAINER   Operate on local container
  -S --since=DATE          指定开始日期
  -U --until=DATE          指定结束日期
  -c --cursor=CURSOR       Show entries starting at the specified cursor
     --after-cursor=CURSOR Show entries after the specified cursor
     --show-cursor         Print the cursor after all the entries
  -b --boot[=ID]           显示引导日志，可为当前引导的日志或指定某次引导
     --list-boots          显示引导的简要信息
  -k --dmesg               查看当前引导的内核日志（不显示应用日志）
  -u --unit=UNIT           显示指定 unit 的日志
  -t --identifier=STRING   显示带有指定syslog标识符的条目
  -p --priority=RANGE      Show entries with the specified priority
  -e --pager-end           Immediately jump to the end in the pager
  -f --follow              实时显示日志
  -n --lines[=INTEGER]     显示最新的n行，默认10
     --no-tail             Show all lines, even in follow mode
  -r --reverse             Show the newest entries first
  -o --output=STRING       Change journal output mode (short, short-iso,
                                   short-precise, short-monotonic, verbose,
                                   export, json, json-pretty, json-sse, cat)
     --utc                 Express time in Coordinated Universal Time (UTC)
  -x --catalog             Add message explanations where available
     --no-full             Ellipsize fields
  -a --all                 Show all fields, including long and unprintable
  -q --quiet               Do not show privilege warning
     --no-pager            Do not pipe output into a pager
  -m --merge               Show entries from all available journals
  -D --directory=PATH      Show journal files from directory
     --file=PATH           Show journal file
     --root=ROOT           Operate on catalog files underneath the root ROOT
     --interval=TIME       Time interval for changing the FSS sealing key
     --verify-key=KEY      Specify FSS verification key
     --force               Override of the FSS key pair with --setup-keys

Commands:
  -h --help                Show this help text
     --version             Show package version
  -F --field=FIELD         列出可用值
     --new-id128           Generate a new 128-bit ID
     --disk-usage          Show total disk usage of all journal files
     --vacuum-size=BYTES   Reduce disk usage below specified size
     --vacuum-time=TIME    Remove journal files older than specified date
     --flush               Flush all journal data from /run into /var
     --header              Show journal header information
     --list-catalog        Show all message IDs in the catalog
     --dump-catalog        Show entries in the message catalog
     --update-catalog      Update the message catalog database
     --setup-keys          Generate a new FSS key pair
     --verify              Verify journal file consistency
```

### 按服务

例如，查看httpd服务当天的运行状况

```bash
journalctl -u httpd.service --since today   可添加多个-u 来查看多个服务
```

**对同一个字段应用多个 match 条件的情况**，比如：

```bash
journalctl _SYSTEMD_UNIT=sshd.service _SYSTEMD_UNIT=httpd.service
```

  此时 ,两个服务的日志都会输出过来

### 按时间

```
--since
--until
```

- 时间段负责指定给定时间之前和之后的日志记录。

**时间值可以采用多种格式，例如以下格式 ▼**

```
YYYY-MM-DD HH:MM:SS
```

**如果未填充时间部分，则默认使用“00:00:00”▼**

```
journalctl --since "2018-03-26" --until "2018-03-26 03:00"
```

- **可以使用"yesterday"、"today"、"tomorrow"、"ago"或"now"。▼**

```
journalctl --since 09:00 --until "1 hour ago"
journalctl --since "20 min ago"
```

### 按优先级

可以使用journalctl配合-p选项显示特定优先级的信息，从而过滤掉优先级较低的信息。

例如，只显示错误级别或者更高的日志条目：

```html
    [root@centos7 ~]# journalctl -p err -b
    [root@centos7 ~]# journalctl -p 3 -b
```

比如添加 PRIORITY 字段的匹配条件：

```bash
journalctl _SYSTEMD_UNIT=sshd.service PRIORITY=3
```

> 注意各个字段的取值，比如为 PRIORITY 设置 debug、info 是不工作的，必须设置为对应的数字。可以通过 `journalctl -F  PRIORITY `来查看某个字段的可选值：

这将只显示被标记为错误、严重、警告或者紧急级别的信息。Journal的这种实现方式与标准syslog信息在级别上是一致的。大家可以使用优先级名称或者其相关量化值。以下各数字为由最高到最低优先级：

```html
    0: emerg
    1: alert
    2: crit
    3: err
    4: warning
    5: notice
    6: info
    7: debug
```

### 按进程、用户或者群组ID

由于某些服务当中包含多个子进程，因此如果我们希望通过进程ID实现查询，也可以使用相关过滤机制。

这里需要指定_PID字段。例如，如果PID为8088，则可输入：

```html
journalctl _PID=8088
```

有时候我们可能希望显示全部来自特定用户或者群组的日志条目，这就需要使用_UID或者_GID。例如，如果大家的Web服务器运行在www-data用户下，则可这样找到该用户ID：

```bash
id -u www-data

33
```

接下来，我们可以使用该ID返回过滤后的journal结果：

```bash
journalctl _UID=33 --since today
```

Systemd journal拥有多种可实现过滤功能的字段。其中一些来自被记录的进程，有些则由journald用于自系统中收集特定时间段内的日志。

之前提到的_PID属于后一种。Journal会自动记录并检索进程PID，以备日后过滤之用。大家可以查看当前全部可用journal字段：

```bash
man systemd.journal-fields
```

下面来看针对这些字段的过滤机制。-F选项可用于显示特定journal字段内的全部可用值。

例如，要查看systemd journal拥有条目的群组ID，可使用以下命令：

```html
[root@centos7 ~]# journalctl -F _GID
```

### 查看重启后的日志

当做了**持久化**后，日志不会随重启而丢失，使用如下命令查询每次引导的摘要信息

```
[root@node1 ~]# journalctl --list-boots
 -1 5878584fe563473088d90553ba8e7228 Wed 2021-07-02 20:25:17 CST—Sat 2021-07-05 19:21:22 CST
 0 dc64adbe7dc9452f9b30778d179033ce Wed 2021-07-07 21:45:43 CST—Sat 2021-07-17 11:28:11 CST

```

此时我们就可以通过 -b 选项来选择查看某次引导中的日志：

```bash
journalctl -b -1
或
journalctl -b 5878584fe563473088d90553ba8e7228

下面的命令都会输出当前引导的日志信息：
journalctl -b
journalctl -b 0
```

### 输出方式

到这里，过滤部分已经介绍完毕。我们也可以使用多种方式对输出结果进行修改，从而调整journalctl的显示内容。

分页显示（默认，可通过按键和命令进行滚动、翻页、跳转、筛选等），journalctl会在pager内显示输出结果以便于查阅。

```html
journalctl --no-full
```

标准格式（将一次性打印所有日志），这样就可以用一些文本工具过滤出自己感兴趣的信息了。

```html
journalctl --no-pager
```

完整显示所有字段内容，即使其中包含非打印字符或者字段内容超长。
默认情况下，包含非打印字符的字段将被缩写为"blob data"(二进制数据)。

```html
journalctl -a
```

### 输出格式

如果大家需要对journal条目进行处理，则可能需要使用更易使用的格式以简化数据解析工作。幸运的是，journal能够以多种格式进行显示，只须添加-o选项加格式说明即可。

例如，我们可以将journal条目输出为JSON格式：

```html
    [root@centos7 ~]# journalctl -b -u httpd -o json
```

也可以使用json-pretty格式以更好地处理数据结构，这种方法易读性，显示的内容也比较全面：

```html
    [root@centos7 ~]# journalctl -u httpd -o  json-pretty
```

以下为可用于显示的各类格式：

```html
    cat: 只显示信息字段本身。
    export: 适合传输或备份的二进制格式。
    json: 标准JSON，每行一个条目。
    json-pretty: JSON格式，适合人类阅读习惯。
    json-sse: JSON格式，经过打包以兼容server-sent事件。
    short: 默认syslog类输出格式。
    short-iso: 默认格式，强调显示ISO 8601挂钟时间戳。
    short-monotonic: 默认格式，提供普通时间戳。
    short-precise: 默认格式，提供微秒级精度。
    verbose: 显示该条目的全部可用journal字段，包括通常被内部隐藏的字段。
```

## journalctl相关配置

### journald.conf参数详解

`/etc/systemd/journald.conf`

```bash
[Journal]
#persistent日志存储到磁盘，none丢弃日志
Storage=persistent 
#压缩日志
Compress=yes 
#为日志添加序列号
Seal=yes 
#每个用户分别记录日志
SplitMode=uid 
#日志同步到磁盘的间隔，高级别的日志，如：CRIT、ALERT、EMERG 三种总是实时同步
SyncIntervalSec=1m 

#即制日志的最大流量，此处指 30s 内最多记录 100000 条日志，超出的将被丢弃
RateLimitInterval=30s 
#与 RateLimitInterval 配合使用
RateLimitBurst=100000

#指定journal所能使用的最高持久存储容量，默认值是10%空间与4G空间两者中的较小者
SystemMaxUse=64G 
#指定journal在添加新条目时需要保留的剩余空间，默认值是15%空间与4G空间两者中的较大者
SystemKeepFree=1G 

#单个日志文件的大小限制，超过此限制将触发滚动保存
SystemMaxFileSize=128M 

RuntimeMaxUse=: 指定易失性存储中的最大可用磁盘容量（/run文件系统之内）。
RuntimeKeepFree=: 指定向易失性存储内写入数据时为其它应用保留的空间量（/run文件系统之内）。
RuntimeMaxFileSize=: 指定单一journal文件可占用的最大易失性存储容量（/run文件系统之内）。

#日志滚动的最大时间间隔，若不设置则完全以大小限制为准
MaxFileSec=1day
#日志最大保留时间，超过时限的旧日志将被删除
MaxRetentionSec=100year 

#是否转发符合条件的日志记录到本机的其它日志管理系统，如：rsyslog
ForwardToSyslog=yes 
ForwardToKMsg=no
#是否转发符合条件的日志到所有登陆用户的终端
ForwardToWall=yes 
MaxLevelStore=debug 
MaxLevelSyslog=err 
MaxLevelWall=emerg 
ForwardToConsole=no 
#TTYPath=/dev/console
#MaxLevelConsole=info
#MaxLevelKMsg=notice
```

### 日志持久化

`systemd-journald `服务收集到的日志默认保存在` /run/log/journal `目录中，重启系统会丢掉以前的日志信息。 

```bash
[root@node2 ~]# tree /run/log/journal
/run/log/journal
└── 0890afb5b11746428e1a5f173ffd7b06
    ├── system@c4399080a26245c4be3b1524ea188744-0000000000000001-0005c688c13f473d.journal
    └── system.journal
```

我们可以让 `systemd-journald` 服务把所有的日志都保存到文件中，这样重新启动后就不会丢掉以前的日志。▼

```
# 持久化保存日志的目录
mkdir /var/log/journal 
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]

# 持久化保存到磁盘
Storage=persistent

# 压缩历史日志
Compress=yesSyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000

# 最大占用空间 
10GSystemMaxUse=10G

# 单日志文件最大 200M
SystemMaxFileSize=200M

# 日志保存时间 2 周
MaxRetentionSec=2week

# 不将日志转发到 
syslogForwardToSyslog=no

EOF
systemctl restart systemd-journald
```

之后 `/run/log/journal` 下面就没有 journal 的日志了，日志文件被保存在` /var/log/journal `目录下：

> 持久化保存journal的日志，默认只会保存一个月的日志

```bash
[root@node1 ~]# tree /var/log/journal
/var/log/journal
└── 7e54d40ce1304cd3a05520633dca946d
    └── system.journal
```

### 日志管理

存储这么多数据当然会带来巨大压力，因此我们还需要了解如何清理部分陈旧日志以释放存储空间。

**查看当前日志占用磁盘的空间的总大小**

```bash
[root@centos7 ~]# journalctl --disk-usage 
Archived and active journals take up 8.0M on disk.
```

**指定日志文件最大空间**

```bash
journalctl --vacuum-size=32G
```

**指定日志文件保存多久**

```bash
journalctl --vacuum-time=1years
```

**写入配置文件`/etc/systemd/journald.conf`**

```bash
[Journal]
Storage=persistent 
SystemMaxUse=32G 
MaxRetentionSec=1year 
```

如果要手动删除日志文件，则需要在删除之前轮转（循环）日志。

```
systemctl kill --kill-who=main --signal=SIGUSR2 systemd-journald.service
```

**然后，重启journald ▼**

```
systemctl restart systemd-journald.service
```

**检查日志是否如常？日志文件是否完好且未损坏？ ▼**

```
journalctl --verify
```

