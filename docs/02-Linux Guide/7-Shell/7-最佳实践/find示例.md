功能描述：从当前目录里面找到 CUDA_VERSION相关信息
第一种实现方法：find + exec +grep
```
find . -type f -exec  grep -Hn --color=auto "CUDA_VERSION" {} \;
```

第二种实现方法 find+xargs +grep
```
find . -type f | xargs  grep -Hn --color=auto "CUDA_VERSION" 
```

