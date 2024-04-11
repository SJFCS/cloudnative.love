在线关闭CPU核心。ps: 可以通过systemd来管理
```
# eg1 offline a CPU
echo 0 > /sys/devices/system/cpu/cpu3/online
# eg2 offline a CPU
echo 1 > /sys/devices/system/cpu/cpu3/online
lscpu		# list cpu
chcpu -d 1	# disable cpu 1
chcpu -e 1	# enable cpu 1

```