1. 获取开始、结束时间（获取当前时间）
```bash
timer_start=`date "+%Y-%m-%d %H:%M:%S"`
timer_end=`date "+%Y-%m-%d %H:%M:%S"`
```
2. 计算时间差
```bash
duration=`echo $(($(date +%s -d "${timer_end}") - $(date +%s -d "${timer_start}"))) | awk '{t=split("60 s 60 m 24 h 999 d",a);for(n=1;n<t;n+=2){if($1==0)break;s=$1%a[n]a[n+1]s;$1=int($1/a[n])}print s}'`
echo "开始： $timer_start"
echo "结束： $timer_end"
echo "耗时： $duration"
```
3. 执行结果
```bash
开始： 2021-11-04 11:53:45
结束： 2021-11-04 11:53:46
耗时： 1s
```