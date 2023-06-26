#!/bin/bash
# 创建软链
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir

if [ "$1" ];then
  base_repodir=$1
  if [ ! -d "${base_repodir}" ];then
    echo "dir:${base_repodir} is not exist "
    exit 1
  fi
fi

if [ -z "$base_repodir" ];then
  echo "Usage: $0 [base_repodir] "
  echo "Example: $0 /mnt/dfs/10/EasyData-V6.5.0"
  exit 1
fi


#确认目录是否存在不存在则创建目录
for dir in `find -type d`
do
  if [ ! -d "$base_repodir/${dir}" ];then
    mkdir -p "$base_repodir/${dir}"
  fi
done

#删除baserepo中 所有链接到本次update 的所有软连接
find $base_repodir -type l -ls |grep "${base_dir}" |awk -F " ->| " '{print $(NF-2)}' |xargs rm -f

#建立软链接
for f in `find -type f |egrep -v "(create_links.sh|delete_links.sh)"`
do
  ln -sf $base_dir/${f} "$base_repodir/${f}"
  echo "create link from ${f} to $base_repodir/${f} success"
done