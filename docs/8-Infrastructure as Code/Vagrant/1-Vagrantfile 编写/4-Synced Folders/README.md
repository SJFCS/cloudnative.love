---
title: Synced Folders
sidebar_position: 5
---


```
default_synced_folder:
create: true
owner: vagrant
group: vagrant
mount_options: ["dmode=755", "fmode=644"]
type: virtualbox # virtualbox、NFS 或 rsync


## 共享目录
server['mount']&.each do |mount|
mount_point, mount_path = mount.split(':').map(&:strip)
puts "#{server['name']} 挂载目录:  #{mount_point} -> #{mount_path}"
# node.vm.synced_folder mount_point, mount_path, default_synced_folder
node.vm.synced_folder mount_point, mount_path, default_config['default_synced_folder']
end 
```

使用sync共享目录创建阿里云主机

本机要安装rsnyc

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine39"
  config.vm.provider "aliyun" do |aliyun, override|
    override.vm.synced_folder ".", "/vagrant", type: "rsync"
  end
end
```
安装vagrant-aliyun插件：
```bash
vagrant plugin install vagrant-aliyun
```

配置阿里云的访问密钥和秘钥：

```bash
export ALICLOUD_ACCESS_KEY="your_access_key"
export ALICLOUD_SECRET_KEY="your_secret_key"
```

vagrant up --provider=aliyun
