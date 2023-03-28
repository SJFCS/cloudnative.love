显示、设置、转换系统时间与日期

```bash
# 格式化输出：
date +"%Y-%m-%d"
2009-12-07

# 输出昨天日期：
date -d "1 day ago" +"%Y-%m-%d"
2012-11-19

# 2秒后输出：
date -d "2 second" +"%Y-%m-%d %H:%M.%S"
2012-11-20 14:21.31

# 传说中的 1234567890 秒：
date -d "1970-01-01 1234567890 seconds" +"%Y-%m-%d %H:%M:%S"
# 或者
date -d@1234567890 +"%F %T"
# 输出结果
2009-02-13 23:02:30

# 时间格式转换：
date -d "2009-12-12" +"%Y/%m/%d %H:%M.%S"
# 输出结果
2009/12/12 00:00.00

# apache格式转换：
date -d "Dec 5, 2009 12:00:37 AM" +"%Y-%m-%d %H:%M.%S"
# 输出结果
2009-12-05 00:00.37

# 格式转换后时间游走：
date -d "Dec 5, 2009 12:00:37 AM 2 year ago" +"%Y-%m-%d %H:%M.%S"
# 输出结果
2007-12-05 00:00.37

# 时间加减操作：
date +%Y%m%d                   # 显示年月日
date -d "+1 day" +%Y%m%d       # 显示前一天的日期
date -d "-1 day" +%Y%m%d       # 显示后一天的日期
date -d "-1 month" +%Y%m%d     # 显示上一月的日期
date -d "+1 month" +%Y%m%d     # 显示下一月的日期
date -d "-1 year" +%Y%m%d      # 显示前一年的日期
date -d "+1 year" +%Y%m%d      # 显示下一年的日期

# 设定时间：
date -s                         # 设置当前时间，只有root权限才能设置，其他只能查看
date -s 20120523                # 设置成20120523，这样会把具体时间设置成00:00:00
date -s 01:01:01                # 设置具体时间，不会对日期做更改
date -s "01:01:01 2012-05-23"   # 这样可以设置全部时间
date -s "01:01:01 20120523"     # 这样可以设置全部时间
date -s "2012-05-23 01:01:01"   # 这样可以设置全部时间
date -s "20120523 01:01:01"     # 这样可以设置全部时间

# 有时需要检查一组命令花费的时间：
start=$(date +%s)
nmap wangchujiang.com &> /dev/null
end=$(date +%s)
difference=$(( end - start ))
# 显示执行时间
echo $difference seconds.

# 当你考虑输出带有时间的字符串时，例如（Current time: 2019/05/19）：
# 通常使用的方法：
echo "Current time: $(date +"%Y/%m/%d")"
# 另一种方法：
suffix='Current time:'
# 注意如果换成单引号就不能替换变量了。
date +"${suffix} %Y/%m/%d"
```