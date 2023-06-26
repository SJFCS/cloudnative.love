```bash
python disk_run.py -h
```
# 测试文件系统性能命令：
```bash
python disk_run.py --filename=/data      # 这个/data 为挂载点
```
# 测试裸盘性能
```bash
python disk_run.py --filename=/dev/vda3 --type=1
```