这是将VirtualBox .OVA转换为Vagrant Box的逐步指南。

1.列出您的VM，以查找要转换的VM ID：
```
/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe 
$ VBoxManage list vms
"testing" {a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4}
```

2.您现在可以将.OVA VM打包为Vagrant框：
```
$ vagrant package --base a3f59eed-b9c5-4a5f-9977-187f8eb8c4d4 --output name-of-your-box.box

```

the command `vagrant package` runs for quite some time before it can creates a Vagrant box. Be faithful and wait.

3.将新box添加到本地：
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