# service模块

[[toc]]

## 1. 概要

- `service`模块用于控制远程主机上面的服务。
- 该模块实际上是代理多种模块，如`systemd`、`sysvinit`模块等。这允许管理机器的异质环境，而无需为每个服务管理器创建特定任务。 
- 对于windows主机，请使用`win_service`模块。
- 源码：[https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/service.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/service.py)
- 官方文档：[https://docs.ansible.com/ansible/latest/modules/service_module.html](https://docs.ansible.com/ansible/latest/modules/service_module.html)



## 2. 参数

| 参数                                                         | 可选值                                                       | 默认值                 | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------- | ------------------------------------------------------------ |
| **arguments**                                                       string |                                                              |                        | 命令行的附加参数。别名`args`                                 |
| **enabled**                                                       boolean | yes/no                                                       |                        | 服务是否开机启动。`**enabled`和`state`两个参数至少需要指定一个。** |
| **name**                                                       string                                              **required** |                                                              |                        | 必须参数，服务名称。                                         |
| **pattern**                                                       string |                                                              |                        | 如果服务不响应·status·命令，请在`ps`命令的输出中找到要查找的子字符串，作为状态结果的替代。 如果找到该字符串，则将假定服务已启动。 |
| **runlevel**                                                       string |                                                              | **Default:** "default" | 服务在运行层级。                                             |
| **sleep**                                                       integer |                                                              |                        | 如果该服务正在重新启动，则在`stop`和`start`命令之间睡眠几秒钟。 这有助于解决行为异常的初始化脚本在发出停止进程的信号后立即退出问题。 并非所有服务管理器都支持睡眠功能，比如`systemd`将忽略此设置。 |
| **state**                                                       string | **Choices:**                                                                                                                                                               reloaded                                                                                                                                                                                               restarted                                                                                                                                                                                               started                                                                                                                                                                                               stopped |                        | `started`/`stopped`是幂等动作，除非必要，否则将不会运行命令。   `restarted`重新启动将始终启动服务。 `reloaded`将始终重新加载配置文件(不用重启服务，直接重新加载配置文件，客户端感觉不到服务异常，平滑切换。)，并启动服务。 **`enabled`和`state`两个参数至少需要指定一个。** |
| **use**                                                       string | **Default:** "auto"                                          |                        | 服务模块实际上使用的系统特定的模块，通常通过自动检测，此设置可以强制使用特定的模块。 通常使用`ansible_service_mgr`的值，并且在找不到匹配项时退回到旧的`service`模块。 |



## 3. 返回值

| 键                                                   | 何时返回       | 描述信息                               |
| ---------------------------------------------------- | -------------- | -------------------------------------- |
| **name**                                    string   | 成功时         | 处理的服务的名称,如`"name": "httpd"`   |
| **state**                                     string | 成功时         | 服务的当前状态，如`"state": "started"` |
| **status**                                   dict    | 成功时         | 服务响应的`status`状态信息             |
| **enabled**                                bool      | 设置开机启动时 | 服务是否开机启动，如`"enabled": true`  |



## 4. 官方示例

```yaml
- name: Start service httpd, if not started
  service:
    name: httpd
    state: started

- name: Stop service httpd, if started
  service:
    name: httpd
    state: stopped

- name: Restart service httpd, in all cases
  service:
    name: httpd
    state: restarted

- name: Reload service httpd, in all cases
  service:
    name: httpd
    state: reloaded

- name: Enable service httpd, and not touch the state
  service:
    name: httpd
    enabled: yes

- name: Start service foo, based on running process /usr/bin/foo
  service:
    name: foo
    pattern: /usr/bin/foo
    state: started

- name: Restart network service for interface eth0
  service:
    name: network
    state: restarted
    args: eth0
```



## 5. 基础知识准备

如果我们想访问httpd或nginx提供的网页服务，我们需要关闭防火墙或者防火墙放行httpd或nginx对应的端口。

```sh
# 查看防火墙状态
[ansible@node1 ~]$ systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2020-08-13 09:40:44 CST; 7h ago
     Docs: man:firewalld(1)
 Main PID: 2577 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─2577 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

# 停止防火墙
[ansible@node1 ~]$ sudo systemctl stop firewalld
[ansible@node1 ~]$ systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since Thu 2020-08-13 16:54:19 CST; 3s ago
     Docs: man:firewalld(1)
  Process: 2577 ExecStart=/usr/sbin/firewalld --nofork --nopid $FIREWALLD_ARGS (code=exited, status=0/SUCCESS)
 Main PID: 2577 (code=exited, status=0/SUCCESS)
[ansible@node1 ~]$

# 重启防火墙
[ansible@node1 ~]$ sudo systemctl start firewalld && systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2020-08-13 16:56:00 CST; 6ms ago
     Docs: man:firewalld(1)
 Main PID: 4515 (firewalld)
   CGroup: /system.slice/firewalld.service
           ├─4515 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
           ├─4517 /usr/sbin/iptables -w -L -n
           └─4518 /usr/sbin/iptables -w -L -n
[ansible@node1 ~]$ 

# 放行httpd服务对应的端口号80
[ansible@node1 ~]$ sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
success

# 重启防火墙
[ansible@node1 ~]$ sudo firewall-cmd --reload
success

# 查看端口放行情况，可以看到80端口已经放行
[ansible@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: dhcpv6-client ssh
  ports: 80/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	
[ansible@node1 ~]$
```



## 6. 使用临时命令

我们先来使用临时命令尝试运行一下`service`模块的命令。

先确保需要测试的包，如`nginx`或`httpd`已经安装成功：

```sh
# 查看httpd和nginx的版本信息
[ansible@node1 ~]$ httpd -v
Server version: Apache/2.4.41 (IUS)
Server built:   Aug 25 2019 19:41:04
[ansible@node1 ~]$ nginx -v
nginx version: nginx/1.16.1
```

确定node1节点的`httpd`服务已经停止：

```sh
[ansible@master ~]$ ansible node1 -m service -a "name=httpd state=stopped"
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "name": "httpd",
    "state": "stopped",
    "status": {
        "ActiveEnterTimestamp": "Tue 2021-12-21 22:01:27 CST",
        ...... 省略
        "SubState": "dead",
        ...... 省略
        "WatchdogTimestampMonotonic": "0",
        "WatchdogUSec": "0"
    }
}
[ansible@master ~]$
```

通过`"state": "stopped"`可以看到`httpd`服务已经是停止状态。



## 7. 使用剧本

下面我们主要使用httpd、nginx、mysql包来进行相关的测试。



### 7.1 启动未启动的服务

我们在执行剧本前，先在node1节点上面看一下`httpd`服务在状态：

```sh
[ansible@node1 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:httpd.service(8)
[ansible@node1 ~]$
```

可以看到`httpd`服务并没有启动。

然后再执行剧本：

```sh
[ansible@master ~]$ cat service.yml 
- hosts: node1
  tasks:
    # 如果httpd服务没有启动，则启动httpd
    - name: Start service httpd, if not started
      service:
        name: httpd
        state: started
      become: yes
[ansible@master ~]$ ansible-lint service.yml 
[ansible@master ~]$ ansible-playbook --syntax-check service.yml 

playbook: service.yml
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Start service httpd, if not started] ******************************************************
changed: [node1] => {"changed": true, "name": "httpd", "state": "started", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "systemd-journald.socket system.slice -.mount remote-fs.target tmp.mount network.target basic.target nss-lookup.target", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，剧本执行成功。服务启动成功。



我们可以把`status`对应的结果保存到一个文件中(如`out.json`)，然后使用`jq`命令格式化输出一下：

```sh
[ansible@master ~]$ cat out.json |jq
{
  "ActiveEnterTimestampMonotonic": "0",
  "ActiveExitTimestampMonotonic": "0",
  "ActiveState": "inactive",
  "After": "systemd-journald.socket system.slice -.mount remote-fs.target tmp.mount network.target basic.target nss-lookup.target",
  "AllowIsolate": "no",
  "AmbientCapabilities": "0",
  "AssertResult": "no",
  "AssertTimestampMonotonic": "0",
  "Before": "shutdown.target",
  "BlockIOAccounting": "no",
  "BlockIOWeight": "18446744073709551615",
  "CPUAccounting": "no",
  "CPUQuotaPerSecUSec": "infinity",
  "CPUSchedulingPolicy": "0",
  "CPUSchedulingPriority": "0",
  "CPUSchedulingResetOnFork": "no",
  "CPUShares": "18446744073709551615",
  "CanIsolate": "no",
  "CanReload": "yes",
  "CanStart": "yes",
  "CanStop": "yes",
  "CapabilityBoundingSet": "18446744073709551615",
  "ConditionResult": "no",
  "ConditionTimestampMonotonic": "0",
  "Conflicts": "shutdown.target",
  "ControlPID": "0",
  "DefaultDependencies": "yes",
  "Delegate": "no",
  "Description": "The Apache HTTP Server",
  "DevicePolicy": "auto",
  "Documentation": "man:httpd.service(8)",
  "Environment": "LANG=C",
  "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)",
  "ExecMainCode": "0",
  "ExecMainExitTimestampMonotonic": "0",
  "ExecMainPID": "0",
  "ExecMainStartTimestampMonotonic": "0",
  "ExecMainStatus": "0",
  "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
  "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
  "FailureAction": "none",
  "FileDescriptorStoreMax": "0",
  "FragmentPath": "/usr/lib/systemd/system/httpd.service",
  "GuessMainPID": "yes",
  "IOScheduling": "0",
  "Id": "httpd.service",
  "IgnoreOnIsolate": "no",
  "IgnoreOnSnapshot": "no",
  "IgnoreSIGPIPE": "yes",
  "InactiveEnterTimestampMonotonic": "0",
  "InactiveExitTimestampMonotonic": "0",
  "JobTimeoutAction": "none",
  "JobTimeoutUSec": "0",
  "KillMode": "mixed",
  "KillSignal": "28",
  "LimitAS": "18446744073709551615",
  "LimitCORE": "18446744073709551615",
  "LimitCPU": "18446744073709551615",
  "LimitDATA": "18446744073709551615",
  "LimitFSIZE": "18446744073709551615",
  "LimitLOCKS": "18446744073709551615",
  "LimitMEMLOCK": "65536",
  "LimitMSGQUEUE": "819200",
  "LimitNICE": "0",
  "LimitNOFILE": "4096",
  "LimitNPROC": "7259",
  "LimitRSS": "18446744073709551615",
  "LimitRTPRIO": "0",
  "LimitRTTIME": "18446744073709551615",
  "LimitSIGPENDING": "7259",
  "LimitSTACK": "18446744073709551615",
  "LoadState": "loaded",
  "MainPID": "0",
  "MemoryAccounting": "no",
  "MemoryCurrent": "18446744073709551615",
  "MemoryLimit": "18446744073709551615",
  "MountFlags": "0",
  "Names": "httpd.service",
  "NeedDaemonReload": "no",
  "Nice": "0",
  "NoNewPrivileges": "no",
  "NonBlocking": "no",
  "NotifyAccess": "main",
  "OOMScoreAdjust": "0",
  "OnFailureJobMode": "replace",
  "PermissionsStartOnly": "no",
  "PrivateDevices": "no",
  "PrivateNetwork": "no",
  "PrivateTmp": "yes",
  "ProtectHome": "no",
  "ProtectSystem": "no",
  "RefuseManualStart": "no",
  "RefuseManualStop": "no",
  "RemainAfterExit": "no",
  "Requires": "-.mount basic.target",
  "RequiresMountsFor": "/var/tmp",
  "Restart": "no",
  "RestartUSec": "100ms",
  "Result": "success",
  "RootDirectoryStartOnly": "no",
  "RuntimeDirectoryMode": "0755",
  "SameProcessGroup": "no",
  "SecureBits": "0",
  "SendSIGHUP": "no",
  "SendSIGKILL": "yes",
  "Slice": "system.slice",
  "StandardError": "inherit",
  "StandardInput": "null",
  "StandardOutput": "journal",
  "StartLimitAction": "none",
  "StartLimitBurst": "5",
  "StartLimitInterval": "10000000",
  "StartupBlockIOWeight": "18446744073709551615",
  "StartupCPUShares": "18446744073709551615",
  "StatusErrno": "0",
  "StopWhenUnneeded": "no",
  "SubState": "dead",
  "SyslogLevelPrefix": "yes",
  "SyslogPriority": "30",
  "SystemCallErrorNumber": "0",
  "TTYReset": "no",
  "TTYVHangup": "no",
  "TTYVTDisallocate": "no",
  "TasksAccounting": "no",
  "TasksCurrent": "18446744073709551615",
  "TasksMax": "18446744073709551615",
  "TimeoutStartUSec": "1min 30s",
  "TimeoutStopUSec": "1min 30s",
  "TimerSlackNSec": "50000",
  "Transient": "no",
  "Type": "notify",
  "UMask": "0022",
  "UnitFilePreset": "disabled",
  "UnitFileState": "disabled",
  "Wants": "system.slice",
  "WatchdogTimestampMonotonic": "0",
  "WatchdogUSec": "0"
}
[ansible@master ~]$ 
```

而通过node1节点检查`httpd`服务在状态信息：

```sh
[ansible@node1 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:httpd.service(8)
[ansible@node1 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-08-12 16:36:51 CST; 40s ago
     Docs: man:httpd.service(8)
 Main PID: 6070 (httpd)
   Status: "Running, listening on: port 80"
   CGroup: /system.slice/httpd.service
           ├─6070 /usr/sbin/httpd -DFOREGROUND
           ├─6071 /usr/sbin/httpd -DFOREGROUND
           ├─6072 /usr/sbin/httpd -DFOREGROUND
           ├─6073 /usr/sbin/httpd -DFOREGROUND
           ├─6074 /usr/sbin/httpd -DFOREGROUND
           └─6075 /usr/sbin/httpd -DFOREGROUND

Aug 12 16:36:46 node1.ansible.com systemd[1]: Starting The Apache HTTP Server...
Aug 12 16:36:51 node1.ansible.com httpd[6070]: Server configured, listening on: port 80
Aug 12 16:36:51 node1.ansible.com systemd[1]: Started The Apache HTTP Server.
[ansible@node1 ~]$ 
```

可以看到服务已经启动了！

如果在VirtualBox的可以设置端口转发功能(node1节点点击设置-->网络-->网卡2-->端口转发，新建一个端口转发规则，规则详情如下：名称：Rule1, 协议：TCP, 主机IP空着不填写，主机端口：8080，或者其他的，子系统IP空着不填写，子系统端口：80， 对应上面httpd启动后的`Status: "Running, listening on: port 80"`中的80端口)，这样可以在宿主机上面通过`http://localhost:8080/`看到`httpd`服务提供的网页，网页上面显示"It works!"。

注意，如果你打开`http://localhost:8080/`没有反应的话，有可能是防火墙正在运行，可以使用`systemctl stop firewalld`停止防火墙或者放行80端口。



### 7.2 停止服务

现在我们使用剧本来停止`httpd`服务。

```sh
[ansible@master ~]$ cat service.yml 
- hosts: node1
  tasks:
    # 如果httpd服务启动了，则停止httpd服务
    - name: Stop service httpd, if started
      service:
        name: httpd
        state: stopped
      become: yes
[ansible@master ~]$ ansible-lint service.yml 
[ansible@master ~]$ ansible-playbook --syntax-check service.yml 

playbook: service.yml
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Stop service httpd, if started] ***********************************************************
changed: [node1] => {"changed": true, "name": "httpd", "state": "stopped", "status": {"ActiveEnterTimestamp": "Wed 2020-08-12 17:17:40 CST", "ActiveEnterTimestampMonotonic": "27077592", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "remote-fs.target systemd-journald.socket -.mount basic.target tmp.mount nss-lookup.target network.target system.slice", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "yes", "AssertTimestamp": "Wed 2020-08-12 17:17:17 CST", "AssertTimestampMonotonic": "21643547", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Wed 2020-08-12 17:17:17 CST", "ConditionTimestampMonotonic": "21643547", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/httpd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "3556", "ExecMainStartTimestamp": "Wed 2020-08-12 17:17:17 CST", "ExecMainStartTimestampMonotonic": "21645277", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Wed 2020-08-12 17:17:17 CST] ; stop_time=[n/a] ; pid=3556 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Wed 2020-08-12 17:17:17 CST", "InactiveExitTimestampMonotonic": "21645320", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "3556", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target -.mount", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StatusText": "Total requests: 7; Idle/Busy workers 100/0;Requests/sec: 0.00805; Bytes served/sec:   6 B/sec", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestamp": "Wed 2020-08-12 17:17:40 CST", "WatchdogTimestampMonotonic": "27077565", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

剧本执行成功。此时将`status`的结果保存到`out.json`中，再进行查看：

```sh
[ansible@master ~]$ cat out.json |jq
{
  "ActiveEnterTimestamp": "Wed 2020-08-12 17:17:40 CST",
  "ActiveEnterTimestampMonotonic": "27077592",
  "ActiveExitTimestampMonotonic": "0",
  "ActiveState": "active",
  "After": "remote-fs.target systemd-journald.socket -.mount basic.target tmp.mount nss-lookup.target network.target system.slice",
  "AllowIsolate": "no",
  "AmbientCapabilities": "0",
  "AssertResult": "yes",
  "AssertTimestamp": "Wed 2020-08-12 17:17:17 CST",
  "AssertTimestampMonotonic": "21643547",
  "Before": "shutdown.target",
  "BlockIOAccounting": "no",
  "BlockIOWeight": "18446744073709551615",
  "CPUAccounting": "no",
  "CPUQuotaPerSecUSec": "infinity",
  "CPUSchedulingPolicy": "0",
  "CPUSchedulingPriority": "0",
  "CPUSchedulingResetOnFork": "no",
  "CPUShares": "18446744073709551615",
  "CanIsolate": "no",
  "CanReload": "yes",
  "CanStart": "yes",
  "CanStop": "yes",
  "CapabilityBoundingSet": "18446744073709551615",
  "ConditionResult": "yes",
  "ConditionTimestamp": "Wed 2020-08-12 17:17:17 CST",
  "ConditionTimestampMonotonic": "21643547",
  "Conflicts": "shutdown.target",
  "ControlGroup": "/system.slice/httpd.service",
  "ControlPID": "0",
  "DefaultDependencies": "yes",
  "Delegate": "no",
  "Description": "The Apache HTTP Server",
  "DevicePolicy": "auto",
  "Documentation": "man:httpd.service(8)",
  "Environment": "LANG=C",
  "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)",
  "ExecMainCode": "0",
  "ExecMainExitTimestampMonotonic": "0",
  "ExecMainPID": "3556",
  "ExecMainStartTimestamp": "Wed 2020-08-12 17:17:17 CST",
  "ExecMainStartTimestampMonotonic": "21645277",
  "ExecMainStatus": "0",
  "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
  "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Wed 2020-08-12 17:17:17 CST] ; stop_time=[n/a] ; pid=3556 ; code=(null) ; status=0/0 }",
  "FailureAction": "none",
  "FileDescriptorStoreMax": "0",
  "FragmentPath": "/usr/lib/systemd/system/httpd.service",
  "GuessMainPID": "yes",
  "IOScheduling": "0",
  "Id": "httpd.service",
  "IgnoreOnIsolate": "no",
  "IgnoreOnSnapshot": "no",
  "IgnoreSIGPIPE": "yes",
  "InactiveEnterTimestampMonotonic": "0",
  "InactiveExitTimestamp": "Wed 2020-08-12 17:17:17 CST",
  "InactiveExitTimestampMonotonic": "21645320",
  "JobTimeoutAction": "none",
  "JobTimeoutUSec": "0",
  "KillMode": "mixed",
  "KillSignal": "28",
  "LimitAS": "18446744073709551615",
  "LimitCORE": "18446744073709551615",
  "LimitCPU": "18446744073709551615",
  "LimitDATA": "18446744073709551615",
  "LimitFSIZE": "18446744073709551615",
  "LimitLOCKS": "18446744073709551615",
  "LimitMEMLOCK": "65536",
  "LimitMSGQUEUE": "819200",
  "LimitNICE": "0",
  "LimitNOFILE": "4096",
  "LimitNPROC": "7259",
  "LimitRSS": "18446744073709551615",
  "LimitRTPRIO": "0",
  "LimitRTTIME": "18446744073709551615",
  "LimitSIGPENDING": "7259",
  "LimitSTACK": "18446744073709551615",
  "LoadState": "loaded",
  "MainPID": "3556",
  "MemoryAccounting": "no",
  "MemoryCurrent": "18446744073709551615",
  "MemoryLimit": "18446744073709551615",
  "MountFlags": "0",
  "Names": "httpd.service",
  "NeedDaemonReload": "no",
  "Nice": "0",
  "NoNewPrivileges": "no",
  "NonBlocking": "no",
  "NotifyAccess": "main",
  "OOMScoreAdjust": "0",
  "OnFailureJobMode": "replace",
  "PermissionsStartOnly": "no",
  "PrivateDevices": "no",
  "PrivateNetwork": "no",
  "PrivateTmp": "yes",
  "ProtectHome": "no",
  "ProtectSystem": "no",
  "RefuseManualStart": "no",
  "RefuseManualStop": "no",
  "RemainAfterExit": "no",
  "Requires": "basic.target -.mount",
  "RequiresMountsFor": "/var/tmp",
  "Restart": "no",
  "RestartUSec": "100ms",
  "Result": "success",
  "RootDirectoryStartOnly": "no",
  "RuntimeDirectoryMode": "0755",
  "SameProcessGroup": "no",
  "SecureBits": "0",
  "SendSIGHUP": "no",
  "SendSIGKILL": "yes",
  "Slice": "system.slice",
  "StandardError": "inherit",
  "StandardInput": "null",
  "StandardOutput": "journal",
  "StartLimitAction": "none",
  "StartLimitBurst": "5",
  "StartLimitInterval": "10000000",
  "StartupBlockIOWeight": "18446744073709551615",
  "StartupCPUShares": "18446744073709551615",
  "StatusErrno": "0",
  "StatusText": "Total requests: 7; Idle/Busy workers 100/0;Requests/sec: 0.00805; Bytes served/sec:   6 B/sec",
  "StopWhenUnneeded": "no",
  "SubState": "running",
  "SyslogLevelPrefix": "yes",
  "SyslogPriority": "30",
  "SystemCallErrorNumber": "0",
  "TTYReset": "no",
  "TTYVHangup": "no",
  "TTYVTDisallocate": "no",
  "TasksAccounting": "no",
  "TasksCurrent": "18446744073709551615",
  "TasksMax": "18446744073709551615",
  "TimeoutStartUSec": "1min 30s",
  "TimeoutStopUSec": "1min 30s",
  "TimerSlackNSec": "50000",
  "Transient": "no",
  "Type": "notify",
  "UMask": "0022",
  "UnitFilePreset": "disabled",
  "UnitFileState": "disabled",
  "Wants": "system.slice",
  "WatchdogTimestamp": "Wed 2020-08-12 17:17:40 CST",
  "WatchdogTimestampMonotonic": "27077565",
  "WatchdogUSec": "0"
}
[ansible@master ~]$
```

通过与之前`httpd`服务成功运行时的输出对比可以看到，运行时`"SubState": "running"`，停止服务器`"SubState": "dead"`。

此时httpd服务已经停止了，我们如果再次运行一次剧本，剧本并不会失败：

```sh
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Stop service httpd, if started] ***********************************************************
ok: [node1] => {"changed": false, "name": "httpd", "state": "stopped", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "basic.target -.mount nss-lookup.target system.slice network.target tmp.mount remote-fs.target systemd-journald.socket", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$
```



### 7.3 重启服务

现在我们来重启服务。

```sh
[ansible@master ~]$ cat service.yml 
- hosts: node1
  tasks:
    # 无论httpd服务是否启动，重启httpd服务
    - name: Restart service httpd, in all cases
      service:
        name: httpd
        state: restarted
      become: yes
[ansible@master ~]$ ansible-lint service.yml 
[ansible@master ~]$ ansible-playbook --syntax-check service.yml 

playbook: service.yml
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Restart service httpd, in all cases] ******************************************************
changed: [node1] => {"changed": true, "name": "httpd", "state": "started", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "systemd-journald.socket remote-fs.target system.slice tmp.mount nss-lookup.target -.mount network.target basic.target", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到，此时`httpd`服务启动了！在node1节点上面检查一下：

```sh
[ansible@node1 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2020-08-13 16:51:16 CST; 25min ago
     Docs: man:httpd.service(8)
 Main PID: 4375 (httpd)
   Status: "Total requests: 4; Idle/Busy workers 71/28;Requests/sec: 0.00263; Bytes served/sec:   2 B/sec"
   CGroup: /system.slice/httpd.service
           ├─4375 /usr/sbin/httpd -DFOREGROUND
           ├─4376 /usr/sbin/httpd -DFOREGROUND
           ├─4377 /usr/sbin/httpd -DFOREGROUND
           ├─4378 /usr/sbin/httpd -DFOREGROUND
           ├─4379 /usr/sbin/httpd -DFOREGROUND
           ├─4380 /usr/sbin/httpd -DFOREGROUND
           ├─4501 /usr/sbin/httpd -DFOREGROUND
           └─4757 /usr/sbin/httpd -DFOREGROUND
[ansible@node1 ~]$ 
```

可以看到`httpd`服务的确启动了！



### 7.4 重新加载服务与开机启动服务

```sh
[ansible@master ~]$ cat service.yml 
- hosts: node1
  tasks:
    # 无论httpd服务是否启动，重新加载httpd服务，会启动服务
    - name: Reload service httpd, in all cases
      service:
        name: httpd
        state: reloaded
      become: yes

    # 将httpd服务加入到开机启动
    - name: Enable service httpd, and not touch the state
      service:
        name: httpd
        enabled: yes
      become: yes
[ansible@master ~]$ ansible-lint service.yml 
[ansible@master ~]$ ansible-playbook --syntax-check service.yml 

playbook: service.yml
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Reload service httpd, in all cases] *******************************************************
changed: [node1] => {"changed": true, "name": "httpd", "state": "started", "status": {"ActiveEnterTimestamp": "Thu 2020-08-13 16:51:16 CST", "ActiveEnterTimestampMonotonic": "25826685167", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "network.target -.mount nss-lookup.target tmp.mount systemd-journald.socket basic.target remote-fs.target system.slice", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "yes", "AssertTimestamp": "Thu 2020-08-13 16:51:10 CST", "AssertTimestampMonotonic": "25821313783", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Thu 2020-08-13 16:51:10 CST", "ConditionTimestampMonotonic": "25821313782", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/httpd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "4375", "ExecMainStartTimestamp": "Thu 2020-08-13 16:51:10 CST", "ExecMainStartTimestampMonotonic": "25821323586", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Thu 2020-08-13 16:51:10 CST] ; stop_time=[n/a] ; pid=4375 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Thu 2020-08-13 16:51:10 CST", "InactiveExitTimestampMonotonic": "25821323610", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "4375", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StatusText": "Total requests: 4; Idle/Busy workers 100/0;Requests/sec: 0.00227; Bytes served/sec:   1 B/sec", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestamp": "Thu 2020-08-13 16:51:16 CST", "WatchdogTimestampMonotonic": "25826685139", "WatchdogUSec": "0"}}

TASK [Enable service httpd, and not touch the state] ********************************************
changed: [node1] => {"changed": true, "enabled": true, "name": "httpd", "status": {"ActiveEnterTimestamp": "Thu 2020-08-13 16:51:16 CST", "ActiveEnterTimestampMonotonic": "25826685167", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "network.target -.mount nss-lookup.target tmp.mount systemd-journald.socket basic.target remote-fs.target system.slice", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "yes", "AssertTimestamp": "Thu 2020-08-13 16:51:10 CST", "AssertTimestampMonotonic": "25821313783", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Thu 2020-08-13 16:51:10 CST", "ConditionTimestampMonotonic": "25821313782", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/httpd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "4375", "ExecMainStartTimestamp": "Thu 2020-08-13 16:51:10 CST", "ExecMainStartTimestampMonotonic": "25821323586", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[Thu 2020-08-13 17:20:38 CST] ; stop_time=[Thu 2020-08-13 17:20:43 CST] ; pid=4964 ; code=exited ; status=0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Thu 2020-08-13 16:51:10 CST] ; stop_time=[n/a] ; pid=4375 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Thu 2020-08-13 16:51:10 CST", "InactiveExitTimestampMonotonic": "25821323610", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "4375", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StatusText": "Total requests: 4; Idle/Busy workers -1/-1;Requests/sec: 0.00226; Bytes served/sec:   1 B/sec", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "system.slice", "WatchdogTimestamp": "Thu 2020-08-13 16:51:16 CST", "WatchdogTimestampMonotonic": "25826685139", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

再次查看`httpd`服务状态：

```sh
[ansible@node1 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2020-08-13 16:51:16 CST; 33min ago
     Docs: man:httpd.service(8)
 Main PID: 4375 (httpd)
   Status: "Total requests: 4; Idle/Busy workers 100/0;Requests/sec: 0.00203; Bytes served/sec:   1 B/sec"
   CGroup: /system.slice/httpd.service
           ├─4375 /usr/sbin/httpd -DFOREGROUND
           ├─4966 /usr/sbin/httpd -DFOREGROUND
           ├─4967 /usr/sbin/httpd -DFOREGROUND
           ├─4968 /usr/sbin/httpd -DFOREGROUND
           ├─4969 /usr/sbin/httpd -DFOREGROUND
           └─4970 /usr/sbin/httpd -DFOREGROUND
[ansible@node1 ~]$ 
```

此时我们可以看到`httpd`服务Main PID并没有发生变化，`reload`不用重启服务，直接重新加载配置文件，客户端感觉不到服务异常，平滑切换。并且可以看到`loaded`行中有`enabled`，说明开机启动配置成功。



### 7.5 重新加载服务与移除开机启动服务

我们把服务停止掉，然后再执行剧本。

```sh
[ansible@node1 ~]$ sudo systemctl stop httpd
[ansible@node1 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Thu 2020-08-13 17:38:15 CST; 2s ago
     Docs: man:httpd.service(8)
  Process: 4375 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=0/SUCCESS)
 Main PID: 4375 (code=exited, status=0/SUCCESS)
   Status: "Total requests: 4; Idle/Busy workers 100/0;Requests/sec: 0.00142; Bytes served/sec:   1 B/sec"
[ansible@node1 ~]$ 
```

执行剧本：

```sh
[ansible@master ~]$ cat service.yml 
- hosts: node1
  tasks:
    # 无论httpd服务是否启动，重新加载httpd服务，会启动服务
    - name: Reload service httpd, in all cases
      service:
        name: httpd
        state: reloaded
      become: yes

    # 将httpd服务从开机启动列表中移除
    - name: Diabled service httpd, and not touch the state
      service:
        name: httpd
        enabled: no
      become: yes
[ansible@master ~]$ ansible-lint service.yml 
[ansible@master ~]$ ansible-playbook --syntax-check service.yml 

playbook: service.yml
[ansible@master ~]$ ansible-playbook service.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [node1] ************************************************************************************

TASK [Gathering Facts] **************************************************************************
ok: [node1]

TASK [Reload service httpd, in all cases] *******************************************************
changed: [node1] => {"changed": true, "name": "httpd", "state": "started", "status": {"ActiveEnterTimestamp": "Thu 2020-08-13 16:51:16 CST", "ActiveEnterTimestampMonotonic": "25826685167", "ActiveExitTimestamp": "Thu 2020-08-13 17:38:14 CST", "ActiveExitTimestampMonotonic": "28644944441", "ActiveState": "inactive", "After": "network.target basic.target -.mount systemd-journald.socket tmp.mount nss-lookup.target system.slice remote-fs.target", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "yes", "AssertTimestamp": "Thu 2020-08-13 16:51:10 CST", "AssertTimestampMonotonic": "25821313783", "Before": "shutdown.target multi-user.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Thu 2020-08-13 16:51:10 CST", "ConditionTimestampMonotonic": "25821313782", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "1", "ExecMainExitTimestamp": "Thu 2020-08-13 17:38:15 CST", "ExecMainExitTimestampMonotonic": "28645958127", "ExecMainPID": "4375", "ExecMainStartTimestamp": "Thu 2020-08-13 16:51:10 CST", "ExecMainStartTimestampMonotonic": "25821323586", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Thu 2020-08-13 16:51:10 CST] ; stop_time=[Thu 2020-08-13 17:38:15 CST] ; pid=4375 ; code=exited ; status=0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestamp": "Thu 2020-08-13 17:38:15 CST", "InactiveEnterTimestampMonotonic": "28645958283", "InactiveExitTimestamp": "Thu 2020-08-13 16:51:10 CST", "InactiveExitTimestampMonotonic": "25821323610", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StatusText": "Total requests: 4; Idle/Busy workers 100/0;Requests/sec: 0.00142; Bytes served/sec:   1 B/sec", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "enabled", "WantedBy": "multi-user.target", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}

TASK [Diabled service httpd, and not touch the state] *******************************************
changed: [node1] => {"changed": true, "enabled": false, "name": "httpd", "status": {"ActiveEnterTimestamp": "Thu 2020-08-13 17:43:16 CST", "ActiveEnterTimestampMonotonic": "28947164468", "ActiveExitTimestamp": "Thu 2020-08-13 17:38:14 CST", "ActiveExitTimestampMonotonic": "28644944441", "ActiveState": "active", "After": "network.target basic.target -.mount systemd-journald.socket tmp.mount nss-lookup.target system.slice remote-fs.target", "AllowIsolate": "no", "AmbientCapabilities": "0", "AssertResult": "yes", "AssertTimestamp": "Thu 2020-08-13 17:43:11 CST", "AssertTimestampMonotonic": "28942103473", "Before": "shutdown.target multi-user.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Thu 2020-08-13 17:43:11 CST", "ConditionTimestampMonotonic": "28942103473", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/httpd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "The Apache HTTP Server", "DevicePolicy": "auto", "Documentation": "man:httpd.service(8)", "Environment": "LANG=C", "EnvironmentFile": "/etc/sysconfig/httpd (ignore_errors=no)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "5338", "ExecMainStartTimestamp": "Thu 2020-08-13 17:43:11 CST", "ExecMainStartTimestampMonotonic": "28942103816", "ExecMainStatus": "0", "ExecReload": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[Thu 2020-08-13 17:43:11 CST] ; stop_time=[n/a] ; pid=5338 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/httpd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "httpd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestamp": "Thu 2020-08-13 17:38:15 CST", "InactiveEnterTimestampMonotonic": "28645958283", "InactiveExitTimestamp": "Thu 2020-08-13 17:43:11 CST", "InactiveExitTimestampMonotonic": "28942103834", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "mixed", "KillSignal": "28", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "7259", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "7259", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "5338", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "httpd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "yes", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "-.mount basic.target", "RequiresMountsFor": "/var/tmp", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StatusText": "Started, listening on: port 80", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TasksAccounting": "no", "TasksCurrent": "18446744073709551615", "TasksMax": "18446744073709551615", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "enabled", "WantedBy": "multi-user.target", "Wants": "system.slice", "WatchdogTimestamp": "Thu 2020-08-13 17:43:16 CST", "WatchdogTimestampMonotonic": "28947164445", "WatchdogUSec": "0"}}

PLAY RECAP **************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@master ~]$ 
```

可以看到`httpd`服务启动了，并且任务`Diabled service httpd, and not touch the state`中返回了`"enabled": false`,说明开机启动移除了，我们在node1节点上面实际检查一下。

```sh
[ansible@node1 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2020-08-13 17:43:16 CST; 38s ago
     Docs: man:httpd.service(8)
 Main PID: 5338 (httpd)
   Status: "Running, listening on: port 80"
   CGroup: /system.slice/httpd.service
           ├─5338 /usr/sbin/httpd -DFOREGROUND
           ├─5339 /usr/sbin/httpd -DFOREGROUND
           ├─5340 /usr/sbin/httpd -DFOREGROUND
           ├─5341 /usr/sbin/httpd -DFOREGROUND
           ├─5342 /usr/sbin/httpd -DFOREGROUND
           └─5343 /usr/sbin/httpd -DFOREGROUND
[ansible@node1 ~]$ 
```

可以看到`httpd`服务启动了，开机启动状态是`disabled`!

service模块其他参数用得较少，此处忽略。

