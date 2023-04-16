# todo: 多provider支持
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