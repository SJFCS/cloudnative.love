# 企业级虚拟机资源管理平台
    每个设备都可以加进来，创建虚拟机后，自动设置网络进行路由。可随时暂停调度，支持多个provider
    目的是支持任何的虚拟化平台，可以灵活的调度，灵活的添加和移除节点，灵活的网络转发。
    只包含最常用的虚拟功能，面向个人/企业的虚拟机临时环境管理，没有复杂的功能
    kubevirt
# dhcp 空网卡
# 快照 别名 本地hosts ssh同步  hook  多provider支持  消息推送   审批
```ruby
config.vm.provider "aliyun" do |aliyun, override|
  aliyun.access_key_id = "YOUR_ACCESS_KEY"
  aliyun.access_key_secret = "YOUR_ACCESS_KEY_SECRET"
  aliyun.instance_type = "ecs.t5-lc1m1.small" # 选择ECS实例类型，可以根据需要进行修改
  aliyun.image_id = "ubuntu_18_04_64_20G_alibase_20200825.vhd" # 指定使用的镜像
  aliyun.region_id = "cn-shanghai" # 指定地域
  aliyun.security_groups = ["default"] # 指定访问权限
  aliyun.internet_charge_type = "PayByTraffic" # 指定带宽计费类型
  aliyun.max_bandwidth_out = 1 # 指定最大带宽值
  aliyun.endpoint = "https://ecs.aliyuncs.com/"
  override.ssh.username = "ubuntu" # 指定访问ECS实例的用户名
end
```
```ruby
Vagrant.configure("2") do |config|
  providers = {
    "aliyun" => {
      "provider" => "aliyun",
      "instance_type" => "ecs.t5-lc1m1.small",
      # Other Aliyun provider settings...
    },
    "vmware" => {
      "provider" => "vmware_workstation",
      "gui" => true,
      # Other VMware provider settings...
    },
    "virtualbox" => {
      "provider" => "virtualbox",
      "gui" => true,
      # Other VirtualBox provider settings...
    }
  }

  selected_provider = providers[ENV["PROVIDER"] || "virtualbox"]

  config.vm.provider selected_provider["provider"].to_sym do |v, override|
    selected_provider.each do |key, value|
      next if key == "provider"
      v.send("#{key}=", value)
    end
  end
end
```
```ruby
# 指定第一个 VM 的 IP 地址为 192.168.0.2，第二个 VM 的 IP 地址为 192.168.0.3
config.vm.define "machine1" do |machine1|
    machine1.vm.hostname = "machine1"
    machine1.vm.provider :aliyun do |aliyun, override|
        aliyun.instance_name = "machine1"
        aliyun.image_id = "ubuntu_16_0402_64_20G_cloudinit_20180922.vhd"
        aliyun.instance_type = "ecs.t5-lc2m2.small"
        aliyun.region_id = "cn-beijing"
        aliyun.security_group_id = "sg-2ze5bahwuere5gan4***"
        override.ssh.username = "username1"
        override.ssh.private_key_path = "/path/to/key1.pem"
        override.vm.box = "aliyun_16.04_amd64"
        override.vm.network :private_network, ip: "192.168.0.2"
    end
end

config.vm.define "machine2" do |machine2|
    machine2.vm.hostname = "machine2"
    machine2.vm.provider :aliyun do |aliyun, override|
        aliyun.instance_name = "machine2"
        aliyun.image_id = "ubuntu_16_0402_64_20G_cloudinit_20180922.vhd"
        aliyun.instance_type = "ecs.t5-lc2m2.small"
        aliyun.region_id = "cn-beijing"
        aliyun.security_group_id = "sg-2ze5bahwuere5gan4***"
        override.ssh.username = "username2"
        override.ssh.private_key_path = "/path/to/key2.pem"
        override.vm.box = "aliyun_16.04_amd64"
        override.vm.network :private_network, ip: "192.168.0.3"
    end
end
```
## Vagrant Access插件可以结合LDAP（轻量目录访问协议）实现对虚拟机的访问控制。

Vagrant Access提供了一个LDAP身份验证插件，可以将LDAP配置与Vagrant Access集成。以下是一些实现步骤：
安装LDAP身份验证插件。你可以使用以下命令在Vagrant上安装LDAP身份验证插件：
```bash
vagrant plugin install vagrant-auth-ldap
```
配置LDAP身份验证。你需要在Vagrantfile中配置LDAP身份验证。以下是一个示例配置：

```ruby
config.ldap.host = "ldap.example.com"
config.ldap.port = 389
config.ldap.base = "dc=example,dc=com"
config.ldap.filter = "(uid=%{username})"
config.ldap.username = "cn=admin,dc=example,dc=com"
config.ldap.password = "password"
```
其中，config.ldap.host是LDAP服务器的主机名或IP地址，config.ldap.port是LDAP服务器的端口号，config.ldap.base是LDAP服务器的基础DN，config.ldap.filter是用于查找用户的LDAP筛选器，config.ldap.username和config.ldap.password是用于身份验证的LDAP管理员凭据。

配置Vagrant Access。你需要在Vagrantfile中配置Vagrant Access，以便使用LDAP身份验证插件。以下是一个示例配置：

```ruby
config.access.ldap = true
```

配置LDAP用户组。你需要在LDAP服务器中创建一个用户组，并将用户添加到该组中。在Vagrantfile中，你可以使用以下命令授权LDAP用户组访问Vagrant环境：

```ruby
config.access.add_box "ubuntu/xenial64", groups: ["ldap_group"]
```
其中，"ubuntu/xenial64"是你的Vagrant环境名称，["ldap_group"]是授权访问此环境的LDAP用户组。


综上所述，通过使用LDAP身份验证插件和Vagrant Access，你可以实现基于LDAP的Vagrant环

## 通过ceph和virt插件实现远程创建主机或挂载远程磁盘

## 加入审批流水线控制


有没有带界面的企业使用的开发环境管理工具，用于解决虚拟机的创建回收与分配问题。
需要带有审批功能，对用户访问虚拟机进行权限控制和组的划分

如vagrant，但它没有界面来操作，而且实现上述功能需要很多插件和脚本，上手难度大

## Python和Vagrantfile可以互操作。可以使用Python的Vagrant API来编写Python脚本，以与Vagrant进行交互并管理虚拟机。也可以在Vagrantfile中嵌入Python脚本，以便在Vagrantfile中编写更灵活的配置。

## 远程gui

## 通过iso启动
```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  config.vm.define "my_vm" do |my_vm|
    my_vm.vm.box = "ubuntu/focal64"
    my_vm.vm.boot_mode = "disk"
    my_vm.vm.box_url = "https://vagrantcloud.com/ubuntu/focal64"
    my_vm.vm.network "forwarded_port", guest: 80, host: 8080
    my_vm.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    my_vm.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y apache2
    SHELL
    my_vm.vm.synced_folder ".", "/vagrant", disabled: true
    my_vm.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", "0", "--device", "0", "--type", "dvddrive", "--medium", "ubuntu-20.04.3-live-server-amd64.iso"]
    end
  end
end
```

https://www.vagrantmanager.com/

https://www.virtualizor.com/



## 要使用Vagrantfile启动远程的provider，您需要使用Vagrant的插件“vagrant-ssh”。您可以在Vagrantfile中配置SSH设置，以便使用vagrant ssh命令连接到远程provider。以下是一个示例Vagrantfile，可以用于启动远程provider：

```
Vagrant.configure("2") do |config|

  config.vm.provider "aws" do |aws, override|
    aws.access_key_id = "YOUR_ACCESS_KEY"
    aws.secret_access_key = "YOUR_SECRET_KEY"
    aws.region = "YOUR_REGION"
    aws.instance_type = "YOUR_INSTANCE_TYPE"
    aws.security_groups = ["YOUR_SECURITY_GROUP"]
    aws.keypair_name = "YOUR_KEYPAIR_NAME"
    # Set this to the IP of the remote machine
    override.ssh.host = "REMOTE_IP_ADDRESS"
    override.ssh.username = "YOUR_USERNAME"
    override.ssh.private_key_path = "PATH_TO_YOUR_PRIVATE_KEY"
  end

end
```

## 通过lable生成 inventory
```ruby
Vagrant.configure("2") do |config|
  # ...

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end

  config.vm.provision "shell", inline: "echo hello"

  # enable vagrant_ansible_inventory plugin
  config.trigger.after :up do
    run("vagrant plugin install vagrant_ansible_inventory") unless Vagrant.has_plugin?("vagrant_ansible_inventory")
  end
  config.vm.provision :ansible do |ansible|
    ansible.limit = "all"
    ansible.playbook = "playbook.yml"
    ansible.groups = {
      "web" => ["web1", "web2"],
      "db" => ["db1"],
    }
  end
end
```