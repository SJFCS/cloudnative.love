节点的ntpd服务未启动导致与其他两个节点的时间不一致。时间不一致导致此节点的flanneld地址与docker的bip不一致，进而导致pod异常

## 1. Flannel的地址与docker的bip是否一致

查看方法如下： 
```bash
ansible all -m shell -a 'cat /run/flannel/subnet.env && ps -ef | grep bip'
[root@heccloud01 ~]# cat /run/flannel/subnet.env && ps -ef | grep bip
FLANNEL_NETWORK=10.101.0.0/16
FLANNEL_SUBNET=10.101.44.1/24
FLANNEL_MTU=1500
FLANNEL_IPMASQ=false

root 3323 1 32 May20 ? 2-17:47:24 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://
/var/run/docker.sock --insecure-registry=172.25.18.103:9999 --bip=10.101.44.1/24 --mtu=1
500 --storage-driver=devicemapper --storage-opt dm.datadev=/dev/centos/data --storage
-opt dm.metadatadev=/dev/centos/metadata --log-opt max-size=1g --log-opt max-file=2
root 32322 17022 0 17:14 pts/2 00:00:00 grep --color=auto bip
```

## 2. CPU降频问题的处理方法

服务器未开启高性能、操作系统频率控制模块和Intel CPU的自身Pstate驱动这个三个问题会使CloudOS的系统处于降频中。针对操作系统频率控制模块和Intel_Pstate驱动导致CloudOS系统处于降频的检查方法如下：

```bash
cpupower frequency-info
# 1、j检查是否有运行频率控制驱动和Intel_Pstate驱动。
# 正常环境无相关的cpufreq driver运行，执行检查命令的回显如下所示：
analyzing CPU 0:
  no or unknown cpufreq driver is active on this CPU
  CPUs which run at the same hardware frequency: Not Available
  CPUs which need to have their frequency coordinated by software: Not Available
  maximum transition latency:  Cannot determine or is not supported.
Not Available
  available cpufreq governors: Not Available
  Unable to determine current policy
  current CPU frequency: Unable to call hardware
# 回显如上所示则不需要进行处理，如果显示有intel_pstate以及acpi等driver信息，则存在降频。这种情况下，该节点需要按照解决方案进行处理。
```

```bash title="/root/disable_cpu_powersave.sh"
#!/bin/bash

cat > /etc/modprobe.d/cpufreq.conf << EOF
blacklist pcc-cpufreq
blacklist acpi-cpufreq
EOF

grep -q "intel_pstate=disable" /etc/default/grub
if [ $? -ne 0 ];then
  sed -i 's/\(GRUB_CMDLINE_LINUX=.*\)"/\1 intel_pstate=disable"/g' /etc/default/grub
fi
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
```

执行脚本
```bash
[root@h3ccloud02 ~]# sh disable_cpu_powersave.sh 
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.14.0-49.el7.centos.x86_64
Found initrd image: /boot/initramfs-4.14.0-49.el7.centos.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-c74fbb43410a416cb5bc80ded8b9b6fa
Found initrd image: /boot/initramfs-0-rescue-c74fbb43410a416cb5bc80ded8b9b6fa.img
done
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.14.0-49.el7.centos.x86_64
Found initrd image: /boot/initramfs-4.14.0-49.el7.centos.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-c74fbb43410a416cb5bc80ded8b9b6fa
Found initrd image: /boot/initramfs-0-rescue-c74fbb43410a416cb5bc80ded8b9b6fa.img

```
在主节点执行：/opt/bin/reboot-all命令重启


Intel处理器从Sandy Bridge系列开始，增加了pstate驱动，该驱动会默认使用节能模式。
以上情况下会出现CPU降频，通常CPU频率只有固定频率的一半甚至更少
1、服务器BIOS、电源开启高性能模式，不同的服务器开启高性能方法稍有不同，请参考部署服务器配置手册进行修改；
2、禁用操作系统CPU频率控制模块（提供脚本解决）；
3、禁用操作系统Intel Pstate驱动（提供脚本解决）；
解决方案：
设置服务器高性能模式，同时升级CloudOS软件版本至E3108及以后。（待发布）


## 3.证书续期
查看证书有效期
openssl x509 -noout -text -in current.pem |grep Not

### 未过期
```bash title="install.sh"
#!/bin/bash

cd $(dirname $0)

ansible all -m ping
if [ $? -ne 0 ];then
  echo -e "\033[31mansible status is abnormal. repair it first.\033[0m"
  exit 1
fi

ansible all -m copy -a "src=cluster_check_csr_residual_1d.sh dest=/opt/gocronitor/scripts/"
if [ $? -ne 0 ];then
  echo -e "\033[31mcopy file failed.\033[0m"
  exit 1
fi

done_flag=0
ansible all -m service -a "name=gocronitor state=restarted"
if [ $? -ne 0 ]; then
  echo -e "\033[31mrestart gocronitor failed. retrying...\033[0m"
  nodes=$(ansible all --list-hosts | grep -v "hosts ([0-9]*):")
  if [ $? -ne 0 ];then
    echo -e "\033[31mget all hosts failed.\033[0m"
    exit 1
  fi
  for node in $nodes
  do
    ssh $node "systemctl restart gocronitor"
    if [ $? -ne 0 ]; then
      echo -e "\033[31m$node: restart gocronitor failed.\033[0m"
      done_flag=1
    else
      echo -e "\033[32m$node: restart gocronitor successfully.\033[0m"
    fi
  done
fi

if [ $done_flag -eq 0 ]; then
  echo -e "\033[32mDone\033[0m"
else
  echo -e "\033[31mTry again\033[0m"
fi
```


执行 `run install.sh on one controller node`
### 已经过期

先执行`oc get csr|grep -v "Appro"|awk '{print $1}'|xargs oc adm certificate approve`

然后执行上面的 install.sh


4. shell color

https://gist.github.com/vratiu/9780109