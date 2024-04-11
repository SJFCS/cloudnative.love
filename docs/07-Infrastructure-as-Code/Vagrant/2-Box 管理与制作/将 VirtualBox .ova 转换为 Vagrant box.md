---
title: VirtualBox .ova 转换为 Vagrant box 逐步指南
---

:::tip
来自：https://gist.github.com/aondio/66a79be10982f051116bc18f1a5d07dc
:::

1.列出您的 VM，以查找要转换的 VM ID
```bash
# 如果 Windows下使用 git-bash 则用：/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe 
$ VBoxManage list vms
"testing" {a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4}
```

2.将 .OVA VM 打包为Vagrant Box
```
$ vagrant package --base a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4 --output name-of-your-box.box
```

3.将新box添加到本地
```
$ vagrant box add new-box-name name-of-your-box.box
vagrant box add --name
```

4. 开始使用你的新镜像
```
$ vagrant init #Init the new box with a Vagrantfile
$ vagrant up
$ vagrant ssh
```