# VirtualBox虚拟机磁盘空间扩容

[[toc]]



今天我要将VirtualBox中`jumpServer-server`虚拟机的硬盘空间从20GB扩展到50GB。


## 准备工作

- 扩容前，先前需要扩容的虚拟机关机。
- 将VirtualBox的安装路径，如"C:\Program Files\Oracle\VirtualBox"，添加到`Path`环境变量中。

添加完成后，在命令行窗口查看是否能执行`VBoxManage`命令。


查看`VBoxManage`版本信息：

```sh
$ VBoxManage.exe --version
6.0.12r133076
```


查看`VBoxManage`帮助信息：

```sh
$ VBoxManage.exe --help > vboxmanage.help
```

我们查看一下`vboxmanage.help`文件内容如下：

```sh
$ cat vboxmanage.help
Oracle VM VirtualBox Command Line Management Interface Version 6.0.12
(C) 2005-2019 Oracle Corporation
All rights reserved.

Usage:

  VBoxManage [<general option>] <command>
 
 
General Options:
 
  [-v|--version]            print version number and exit
  [-q|--nologo]             suppress the logo
  [--settingspw <pw>]       provide the settings password
  [--settingspwfile <file>] provide a file containing the settings password
  [@<response-file>]        load arguments from the given response file (bourne style)
 
 
Commands:
 
  list [--long|-l] [--sorted|-s]          vms|runningvms|ostypes|hostdvds|hostfloppies|
                            intnets|bridgedifs|hostonlyifs|natnets|dhcpservers|
                            hostinfo|hostcpuids|hddbackends|hdds|dvds|floppies|
                            usbhost|usbfilters|systemproperties|extpacks|
                            groups|webcams|screenshotformats|cloudproviders|
                            cloudprofiles

  showvminfo                <uuid|vmname> [--details]
                            [--machinereadable]
  showvminfo                <uuid|vmname> --log <idx>

  registervm                <filename>

  unregistervm              <uuid|vmname> [--delete]

  createvm                  --name <name>
                            [--groups <group>, ...]
                            [--ostype <ostype>]
                            [--register]
                            [--basefolder <path>]
                            [--uuid <uuid>]
                            [--default]

  modifyvm                  <uuid|vmname>
                            [--name <name>]
                            [--groups <group>, ...]
                            [--description <desc>]
                            [--ostype <ostype>]
                            [--iconfile <filename>]
                            [--memory <memorysize in MB>]
                            [--pagefusion on|off]
                            [--vram <vramsize in MB>]
                            [--acpi on|off]
                            [--pciattach 03:04.0]
                            [--pciattach 03:04.0@02:01.0]
                            [--pcidetach 03:04.0]
                            [--ioapic on|off]
                            [--hpet on|off]
                            [--triplefaultreset on|off]
                            [--apic on|off]
                            [--x2apic on|off]
                            [--paravirtprovider none|default|legacy|minimal|
                                                hyperv|kvm]
                            [--paravirtdebug <key=value> [,<key=value> ...]]
                            [--hwvirtex on|off]
                            [--nestedpaging on|off]
                            [--largepages on|off]
                            [--vtxvpid on|off]
                            [--vtxux on|off]
                            [--pae on|off]
                            [--longmode on|off]
                            [--ibpb-on-vm-exit on|off]
                            [--ibpb-on-vm-entry on|off]
                            [--spec-ctrl on|off]
                            [--l1d-flush-on-sched on|off]
                            [--l1d-flush-on-vm-entry on|off]
                            [--mds-clear-on-sched on|off]
                            [--mds-clear-on-vm-entry on|off]
                            [--nested-hw-virt on|off]
                            [--cpu-profile "host|Intel 80[86|286|386]"]
                            [--cpuid-portability-level <0..3>
                            [--cpuid-set <leaf[:subleaf]> <eax> <ebx> <ecx> <edx>]
                            [--cpuid-remove <leaf[:subleaf]>]
                            [--cpuidremoveall]
                            [--hardwareuuid <uuid>]
                            [--cpus <number>]
                            [--cpuhotplug on|off]
                            [--plugcpu <id>]
                            [--unplugcpu <id>]
                            [--cpuexecutioncap <1-100>]
                            [--rtcuseutc on|off]
                            [--graphicscontroller none|vboxvga|vmsvga|vboxsvga]
                            [--monitorcount <number>]
                            [--accelerate3d on|off]
                            [--accelerate2dvideo on|off]
                            [--firmware bios|efi|efi32|efi64]
                            [--chipset ich9|piix3]
                            [--bioslogofadein on|off]
                            [--bioslogofadeout on|off]
                            [--bioslogodisplaytime <msec>]
                            [--bioslogoimagepath <imagepath>]
                            [--biosbootmenu disabled|menuonly|messageandmenu]
                            [--biosapic disabled|apic|x2apic]
                            [--biossystemtimeoffset <msec>]
                            [--biospxedebug on|off]
                            [--boot<1-4> none|floppy|dvd|disk|net>]
                            [--nic<1-N> none|null|nat|bridged|intnet|hostonly|
                                        generic|natnetwork]
                            [--nictype<1-N> Am79C970A|Am79C973|
                                            82540EM|82543GC|82545EM|
                                            virtio]
                            [--cableconnected<1-N> on|off]
                            [--nictrace<1-N> on|off]
                            [--nictracefile<1-N> <filename>]
                            [--nicproperty<1-N> name=[value]]
                            [--nicspeed<1-N> <kbps>]
                            [--nicbootprio<1-N> <priority>]
                            [--nicpromisc<1-N> deny|allow-vms|allow-all]
                            [--nicbandwidthgroup<1-N> none|<name>]
                            [--bridgeadapter<1-N> none|<devicename>]
                            [--hostonlyadapter<1-N> none|<devicename>]
                            [--intnet<1-N> <network name>]
                            [--nat-network<1-N> <network name>]
                            [--nicgenericdrv<1-N> <driver>
                            [--natnet<1-N> <network>|default]
                            [--natsettings<1-N> [<mtu>],[<socksnd>],
                                                [<sockrcv>],[<tcpsnd>],
                                                [<tcprcv>]]
                            [--natpf<1-N> [<rulename>],tcp|udp,[<hostip>],
                                          <hostport>,[<guestip>],<guestport>]
                            [--natpf<1-N> delete <rulename>]
                            [--nattftpprefix<1-N> <prefix>]
                            [--nattftpfile<1-N> <file>]
                            [--nattftpserver<1-N> <ip>]
                            [--natbindip<1-N> <ip>
                            [--natdnspassdomain<1-N> on|off]
                            [--natdnsproxy<1-N> on|off]
                            [--natdnshostresolver<1-N> on|off]
                            [--nataliasmode<1-N> default|[log],[proxyonly],
                                                         [sameports]]
                            [--macaddress<1-N> auto|<mac>]
                            [--mouse ps2|usb|usbtablet|usbmultitouch]
                            [--keyboard ps2|usb
                            [--uart<1-N> off|<I/O base> <IRQ>]
                            [--uartmode<1-N> disconnected|
                                             server <pipe>|
                                             client <pipe>|
                                             tcpserver <port>|
                                             tcpclient <hostname:port>|
                                             file <file>|
                                             <devicename>]
                            [--uarttype<1-N> 16450|16550A|16750
                            [--lpt<1-N> off|<I/O base> <IRQ>]
                            [--lptmode<1-N> <devicename>]
                            [--guestmemoryballoon <balloonsize in MB>]
                            [--audio none|null|dsound]
                            [--audioin on|off]
                            [--audioout on|off]
                            [--audiocontroller ac97|hda|sb16]
                            [--audiocodec stac9700|ad1980|stac9221|sb16]
                            [--clipboard disabled|hosttoguest|guesttohost|
                                         bidirectional]
                            [--draganddrop disabled|hosttoguest|guesttohost|
                                         bidirectional]
                            [--vrde on|off]
                            [--vrdeextpack default|<name>
                            [--vrdeproperty <name=[value]>]
                            [--vrdeport <hostport>]
                            [--vrdeaddress <hostip>]
                            [--vrdeauthtype null|external|guest]
                            [--vrdeauthlibrary default|<name>
                            [--vrdemulticon on|off]
                            [--vrdereusecon on|off]
                            [--vrdevideochannel on|off]
                            [--vrdevideochannelquality <percent>]
                            [--usbohci on|off]
                            [--usbehci on|off]
                            [--usbxhci on|off]
                            [--usbrename <oldname> <newname>]
                            [--snapshotfolder default|<path>]
                            [--teleporter on|off]
                            [--teleporterport <port>]
                            [--teleporteraddress <address|empty>
                            [--teleporterpassword <password>]
                            [--teleporterpasswordfile <file>|stdin]
                            [--tracing-enabled on|off]
                            [--tracing-config <config-string>]
                            [--tracing-allow-vm-access on|off]
                            [--usbcardreader on|off]
                            [--autostart-enabled on|off]
                            [--autostart-delay <seconds>]
                            [--recording on|off]
                            [--recordingscreens all|<screen ID> [<screen ID> ...]]
                            [--recordingfile <filename>]
                            [--recordingvideores <width> <height>]
                            [--recordingvideorate <rate>]
                            [--recordingvideofps <fps>]
                            [--recordingmaxtime <s>]
                            [--recordingmaxsize <MB>]
                            [--recordingopts <key=value> [,<key=value> ...]]
                            [--defaultfrontend default|<name>]

  clonevm                   <uuid|vmname>
                            [--snapshot <uuid>|<name>]
                            [--mode machine|machineandchildren|all]
                            [--options link|keepallmacs|keepnatmacs|
                                       keepdisknames|keephwuuids]
                            [--name <name>]
                            [--groups <group>, ...]
                            [--basefolder <basefolder>]
                            [--uuid <uuid>]
                            [--register]

  movevm                    <uuid|vmname>
                            --type basic
                            [--folder <path>]

  import                    <ovfname/ovaname>
                            [--dry-run|-n]
                            [--options keepallmacs|keepnatmacs|importtovdi]
                            [more options]
                            (run with -n to have options displayed
                             for a particular OVF)

  export                    <machines> --output|-o <name>.<ovf/ova/tar.gz>
                            [--legacy09|--ovf09|--ovf10|--ovf20|--opc10]
                            [--manifest]
                            [--iso]
                            [--options manifest|iso|nomacs|nomacsbutnat]
                            [--vsys <number of virtual system>]
                                    [--vmname <name>]
                                    [--product <product name>]
                                    [--producturl <product url>]
                                    [--vendor <vendor name>]
                                    [--vendorurl <vendor url>]
                                    [--version <version info>]
                                    [--description <description info>]
                                    [--eula <license text>]
                                    [--eulafile <filename>]
                            [--cloud <number of virtual system>]
                                    [--vmname <name>]
                                    [--cloudprofile <cloud profile name>]
                                    [--cloudshape <shape>]
                                    [--clouddomain <domain>]
                                    [--clouddisksize <disk size in GB>]
                                    [--cloudbucket <bucket name>]
                                    [--cloudocivcn <OCI vcn id>]
                                    [--cloudocisubnet <OCI subnet id>]
                                    [--cloudkeepobject <true/false>]
                                    [--cloudlaunchinstance <true/false>]
                                    [--cloudpublicip <true/false>]

  startvm                   <uuid|vmname>...
                            [--type gui|sdl|headless|separate]
                            [-E|--putenv <NAME>[=<VALUE>]]

  controlvm                 <uuid|vmname>
                            pause|resume|reset|poweroff|savestate|
                            acpipowerbutton|acpisleepbutton|
                            keyboardputscancode <hex> [<hex> ...]|
                            keyboardputstring <string1> [<string2> ...]|
                            keyboardputfile <filename>|
                            setlinkstate<1-N> on|off |
                            nic<1-N> null|nat|bridged|intnet|hostonly|generic|
                                     natnetwork [<devicename>] |
                            nictrace<1-N> on|off |
                            nictracefile<1-N> <filename> |
                            nicproperty<1-N> name=[value] |
                            nicpromisc<1-N> deny|allow-vms|allow-all |
                            natpf<1-N> [<rulename>],tcp|udp,[<hostip>],
                                        <hostport>,[<guestip>],<guestport> |
                            natpf<1-N> delete <rulename> |
                            guestmemoryballoon <balloonsize in MB> |
                            usbattach <uuid>|<address>
                                      [--capturefile <filename>] |
                            usbdetach <uuid>|<address> |
                            audioin on|off |
                            audioout on|off |
                            clipboard disabled|hosttoguest|guesttohost|
                                      bidirectional |
                            draganddrop disabled|hosttoguest|guesttohost|
                                      bidirectional |
                            vrde on|off |
                            vrdeport <port> |
                            vrdeproperty <name=[value]> |
                            vrdevideochannelquality <percent> |
                            setvideomodehint <xres> <yres> <bpp>
                                            [[<display>] [<enabled:yes|no> |
                                              [<xorigin> <yorigin>]]] |
                            setscreenlayout <display> on|primary <xorigin> <yorigin> <xres> <yres> <bpp> | off
                            screenshotpng <file> [display] |
                            recording on|off |
                            recording screens all|none|<screen>,[<screen>...] |
                            recording filename <file> |
                            recording videores <width>x<height> |
                            recording videorate <rate> |
                            recording videofps <fps> |
                            recording maxtime <s> |
                            recording maxfilesize <MB> |
                            setcredentials <username>
                                           --passwordfile <file> | <password>
                                           <domain>
                                           [--allowlocallogon <yes|no>] |
                            teleport --host <name> --port <port>
                                     [--maxdowntime <msec>]
                                     [--passwordfile <file> |
                                      --password <password>] |
                            plugcpu <id> |
                            unplugcpu <id> |
                            cpuexecutioncap <1-100>
                            webcam <attach [path [settings]]> | <detach [path]> | <list>
                            addencpassword <id>
                                           <password file>|-
                                           [--removeonsuspend <yes|no>]
                            removeencpassword <id>
                            removeallencpasswords
                            changeuartmode<1-N> disconnected|
                                                server <pipe>|
                                                client <pipe>|
                                                tcpserver <port>|
                                                tcpclient <hostname:port>|
                                                file <file>|
                                                <devicename>]

  discardstate              <uuid|vmname>

  adoptstate                <uuid|vmname> <state_file>

  snapshot                  <uuid|vmname>
                            take <name> [--description <desc>] [--live]
                                 [--uniquename Number,Timestamp,Space,Force] |
                            delete <uuid|snapname> |
                            restore <uuid|snapname> |
                            restorecurrent |
                            edit <uuid|snapname>|--current
                                 [--name <name>]
                                 [--description <desc>] |
                            list [--details|--machinereadable] |
                            showvminfo <uuid|snapname>

  closemedium               [disk|dvd|floppy] <uuid|filename>
                            [--delete]

  storageattach             <uuid|vmname>
                            --storagectl <name>
                            [--port <number>]
                            [--device <number>]
                            [--type dvddrive|hdd|fdd]
                            [--medium none|emptydrive|additions|
                                      <uuid|filename>|host:<drive>|iscsi]
                            [--mtype normal|writethrough|immutable|shareable|
                                     readonly|multiattach]
                            [--comment <text>]
                            [--setuuid <uuid>]
                            [--setparentuuid <uuid>]
                            [--passthrough on|off]
                            [--tempeject on|off]
                            [--nonrotational on|off]
                            [--discard on|off]
                            [--hotpluggable on|off]
                            [--bandwidthgroup <name>]
                            [--forceunmount]
                            [--server <name>|<ip>]
                            [--target <target>]
                            [--tport <port>]
                            [--lun <lun>]
                            [--encodedlun <lun>]
                            [--username <username>]
                            [--password <password>]
                            [--passwordfile <file>]
                            [--initiator <initiator>]
                            [--intnet]

  storagectl                <uuid|vmname>
                            --name <name>
                            [--add ide|sata|scsi|floppy|sas|usb|pcie]
                            [--controller LSILogic|LSILogicSAS|BusLogic|
                                          IntelAHCI|PIIX3|PIIX4|ICH6|I82078|
                            [             USB|NVMe]
                            [--portcount <1-n>]
                            [--hostiocache on|off]
                            [--bootable on|off]
                            [--rename <name>]
                            [--remove]

  bandwidthctl              <uuid|vmname>
                            add <name> --type disk|network
                                --limit <megabytes per second>[k|m|g|K|M|G] |
                            set <name>
                                --limit <megabytes per second>[k|m|g|K|M|G] |
                            remove <name> |
                            list [--machinereadable]
                            (limit units: k=kilobit, m=megabit, g=gigabit,
                                          K=kilobyte, M=megabyte, G=gigabyte)

  showmediuminfo            [disk|dvd|floppy] <uuid|filename>

  createmedium              [disk|dvd|floppy] --filename <filename>
                            [--size <megabytes>|--sizebyte <bytes>]
                            [--diffparent <uuid>|<filename>
                            [--format VDI|VMDK|VHD] (default: VDI)
                            [--variant Standard,Fixed,Split2G,Stream,ESX,
                                       Formatted]

  modifymedium              [disk|dvd|floppy] <uuid|filename>
                            [--type normal|writethrough|immutable|shareable|
                                    readonly|multiattach]
                            [--autoreset on|off]
                            [--property <name=[value]>]
                            [--compact]
                            [--resize <megabytes>|--resizebyte <bytes>]
                            [--move <path>]
                            [--setlocation <path>]
                            [--description <description string>]
  clonemedium               [disk|dvd|floppy] <uuid|inputfile> <uuid|outputfile>
                            [--format VDI|VMDK|VHD|RAW|<other>]
                            [--variant Standard,Fixed,Split2G,Stream,ESX]
                            [--existing]

  mediumproperty            [disk|dvd|floppy] set <uuid|filename>
                            <property> <value>

                            [disk|dvd|floppy] get <uuid|filename>
                            <property>

                            [disk|dvd|floppy] delete <uuid|filename>
                            <property>

  encryptmedium             <uuid|filename>
                            [--newpassword <file>|-]
                            [--oldpassword <file>|-]
                            [--cipher <cipher identifier>]
                            [--newpasswordid <password identifier>]

  checkmediumpwd            <uuid|filename>
                            <pwd file>|-

  convertfromraw            <filename> <outputfile>
                            [--format VDI|VMDK|VHD]
                            [--variant Standard,Fixed,Split2G,Stream,ESX]
                            [--uuid <uuid>]
  convertfromraw            stdin <outputfile> <bytes>
                            [--format VDI|VMDK|VHD]
                            [--variant Standard,Fixed,Split2G,Stream,ESX]
                            [--uuid <uuid>]

  getextradata              global|<uuid|vmname>
                            <key>|[enumerate]

  setextradata              global|<uuid|vmname>
                            <key>
                            [<value>] (no value deletes key)

  setproperty               machinefolder default|<folder> |
                            hwvirtexclusive on|off |
                            vrdeauthlibrary default|<library> |
                            websrvauthlibrary default|null|<library> |
                            vrdeextpack null|<library> |
                            autostartdbpath null|<folder> |
                            loghistorycount <value>
                            defaultfrontend default|<name>
                            logginglevel <log setting>
                            proxymode system|noproxy|manual
                            proxyurl <url>

  usbfilter                 add <index,0-N>
                            --target <uuid|vmname>|global
                            --name <string>
                            --action ignore|hold (global filters only)
                            [--active yes|no] (yes)
                            [--vendorid <XXXX>] (null)
                            [--productid <XXXX>] (null)
                            [--revision <IIFF>] (null)
                            [--manufacturer <string>] (null)
                            [--product <string>] (null)
                            [--remote yes|no] (null, VM filters only)
                            [--serialnumber <string>] (null)
                            [--maskedinterfaces <XXXXXXXX>]

  usbfilter                 modify <index,0-N>
                            --target <uuid|vmname>|global
                            [--name <string>]
                            [--action ignore|hold] (global filters only)
                            [--active yes|no]
                            [--vendorid <XXXX>|""]
                            [--productid <XXXX>|""]
                            [--revision <IIFF>|""]
                            [--manufacturer <string>|""]
                            [--product <string>|""]
                            [--remote yes|no] (null, VM filters only)
                            [--serialnumber <string>|""]
                            [--maskedinterfaces <XXXXXXXX>]

  usbfilter                 remove <index,0-N>
                            --target <uuid|vmname>|global

  sharedfolder              add <uuid|vmname>
                            --name <name> --hostpath <hostpath>
                            [--transient] [--readonly] [--automount]

  sharedfolder              remove <uuid|vmname>
                            --name <name> [--transient]

  guestproperty             get <uuid|vmname>
                            <property> [--verbose]

  guestproperty             set <uuid|vmname>
                            <property> [<value> [--flags <flags>]]

  guestproperty             delete|unset <uuid|vmname>
                            <property>

  guestproperty             enumerate <uuid|vmname>
                            [--patterns <patterns>]

  guestproperty             wait <uuid|vmname> <patterns>
                            [--timeout <msec>] [--fail-on-timeout]

  guestcontrol              <uuid|vmname> [--verbose|-v] [--quiet|-q]
                              [--username <name>] [--domain <domain>]
                              [--passwordfile <file> | --password <password>]

                              run [common-options]
                              [--exe <path to executable>] [--timeout <msec>]
                              [-E|--putenv <NAME>[=<VALUE>]] [--unquoted-args]
                              [--ignore-operhaned-processes] [--profile]
                              [--no-wait-stdout|--wait-stdout]
                              [--no-wait-stderr|--wait-stderr]
                              [--dos2unix] [--unix2dos]
                              -- <program/arg0> [argument1] ... [argumentN]]

                              start [common-options]
                              [--exe <path to executable>] [--timeout <msec>]
                              [-E|--putenv <NAME>[=<VALUE>]] [--unquoted-args]
                              [--ignore-operhaned-processes] [--profile]
                              -- <program/arg0> [argument1] ... [argumentN]]

                              copyfrom [common-options]
                              [--follow] [-R|--recursive]
                              <guest-src0> [guest-src1 [...]] <host-dst>

                              copyfrom [common-options]
                              [--follow] [-R|--recursive]
                              [--target-directory <host-dst-dir>]
                              <guest-src0> [guest-src1 [...]]

                              copyto [common-options]
                              [--follow] [-R|--recursive]
                              <host-src0> [host-src1 [...]] <guest-dst>

                              copyto [common-options]
                              [--follow] [-R|--recursive]
                              [--target-directory <guest-dst>]
                              <host-src0> [host-src1 [...]]

                              mkdir|createdir[ectory] [common-options]
                              [--parents] [--mode <mode>]
                              <guest directory> [...]

                              rmdir|removedir[ectory] [common-options]
                              [-R|--recursive]
                              <guest directory> [...]

                              removefile|rm [common-options] [-f|--force]
                              <guest file> [...]

                              mv|move|ren[ame] [common-options]
                              <source> [source1 [...]] <dest>

                              mktemp|createtemp[orary] [common-options]
                              [--secure] [--mode <mode>] [--tmpdir <directory>]
                              <template>

                              stat [common-options]
                              <file> [...]

  guestcontrol              <uuid|vmname> [--verbose|-v] [--quiet|-q]

                              list <all|sessions|processes|files> [common-opts]

                              closeprocess [common-options]
                              <   --session-id <ID>
                                | --session-name <name or pattern>
                              <PID1> [PID1 [...]]

                              closesession [common-options]
                              <  --all | --session-id <ID>
                                | --session-name <name or pattern> >

                              updatega|updateguestadditions|updateadditions
                              [--source <guest additions .ISO>]
                              [--wait-start] [common-options]
                              [-- [<argument1>] ... [<argumentN>]]

                              watch [common-options]

  metrics                   list [*|host|<vmname> [<metric_list>]]
                                                 (comma-separated)

  metrics                   setup
                            [--period <seconds>] (default: 1)
                            [--samples <count>] (default: 1)
                            [--list]
                            [*|host|<vmname> [<metric_list>]]

  metrics                   query [*|host|<vmname> [<metric_list>]]

  metrics                   enable
                            [--list]
                            [*|host|<vmname> [<metric_list>]]

  metrics                   disable
                            [--list]
                            [*|host|<vmname> [<metric_list>]]

  metrics                   collect
                            [--period <seconds>] (default: 1)
                            [--samples <count>] (default: 1)
                            [--list]
                            [--detach]
                            [*|host|<vmname> [<metric_list>]]

  natnetwork                add --netname <name>
                            --network <network>
                            [--enable|--disable]
                            [--dhcp on|off]
                            [--port-forward-4 <rule>]
                            [--loopback-4 <rule>]
                            [--ipv6 on|off]
                            [--port-forward-6 <rule>]
                            [--loopback-6 <rule>]

  natnetwork                remove --netname <name>

  natnetwork                modify --netname <name>
                            [--network <network>]
                            [--enable|--disable]
                            [--dhcp on|off]
                            [--port-forward-4 <rule>]
                            [--loopback-4 <rule>]
                            [--ipv6 on|off]
                            [--port-forward-6 <rule>]
                            [--loopback-6 <rule>]

  natnetwork                start --netname <name>

  natnetwork                stop --netname <name>

  natnetwork                list [<pattern>]

  hostonlyif                ipconfig <name>
                            [--dhcp |
                            --ip<ipv4> [--netmask<ipv4> (def: 255.255.255.0)] |
                            --ipv6<ipv6> [--netmasklengthv6<length> (def: 64)]]
                            create |
                            remove <name>

  dhcpserver                add|modify --netname <network_name> |
                                       --ifname <hostonly_if_name>
                            [--ip <ip_address>
                            --netmask <network_mask>
                            --lowerip <lower_ip>
                            --upperip <upper_ip>]
                            [--enable | --disable]
                            [--options [--vm <name> --nic <1-N>]
                             --id <number> [--value <string> | --remove]]
                             (multiple options allowed after --options)

  dhcpserver                remove --netname <network_name> |
                                   --ifname <hostonly_if_name>

  usbdevsource              add <source name>
                            --backend <backend>
                            --address <address>
  usbdevsource              remove <source name>

 Medium content access:

  VBoxManage mediumio <[--disk=uuid|filename] | [--dvd=uuid|filename] | [--floppy=uuid|filename]>
      [--password-file-|filename] formatfat [--quick]

  VBoxManage mediumio <[--disk=uuid|filename] | [--dvd=uuid|filename] | [--floppy=uuid|filename]>
      [--password-file-|filename] cat [--hex] [--offset=byte-offset] [--size=bytes] [--output=-|filename]

  VBoxManage mediumio <[--disk=uuid|filename] | [--dvd=uuid|filename] | [--floppy=uuid|filename]>
      [--password-file-|filename] stream [--format=image-format] [--variant=image-variant] [--output=-|filename]

 Introspection and guest debugging:

  VBoxManage debugvm <uuid|vmname> dumpvmcore [--filename=name]

  VBoxManage debugvm <uuid|vmname> info <item> [args...]

  VBoxManage debugvm <uuid|vmname> injectnmi

  VBoxManage debugvm <uuid|vmname> log [[--release] | [--debug]] [group-settings...]

  VBoxManage debugvm <uuid|vmname> logdest [[--release] | [--debug]] [destinations...]

  VBoxManage debugvm <uuid|vmname> logflags [[--release] | [--debug]] [flags...]

  VBoxManage debugvm <uuid|vmname> osdetect

  VBoxManage debugvm <uuid|vmname> osinfo

  VBoxManage debugvm <uuid|vmname> osdmesg [--lines=lines]

  VBoxManage debugvm <uuid|vmname> getregisters [--cpu=id] [reg-set.reg-name...]

  VBoxManage debugvm <uuid|vmname> setregisters [--cpu=id] [reg-set.reg-name=value...]

  VBoxManage debugvm <uuid|vmname> show [[--human-readable] | [--sh-export] | [--sh-eval] | [--cmd-set]]
      [settings-item...]

  VBoxManage debugvm <uuid|vmname> stack [--cpu=id]

  VBoxManage debugvm <uuid|vmname> statistics [--reset] [--descriptions] [--pattern=pattern]

 Extension package management:

  VBoxManage extpack install [--replace] <tarball>

  VBoxManage extpack uninstall [--force] <name>

  VBoxManage extpack cleanup

 Unattended guest OS installation:

  VBoxManage unattended detect <--iso=install-iso> [--machine-readable]

  VBoxManage unattended install <uuid|vmname> <--iso=install-iso> [--user=login] [--password=password]
      [--password-file=file] [--full-user-name=name] [--key=product-key] [--install-additions] [--no-install-additions]
      [--additions-iso=add-iso] [--install-txs] [--no-install-txs] [--validation-kit-iso=testing-iso] [--locale=ll_CC]
      [--country=CC] [--time-zone=tz] [--hostname=fqdn] [--package-selection-adjustment=keyword] [--dry-run]
      [--auxiliary-base-path=path] [--image-index=number] [--script-template=file] [--post-install-template=file]
      [--post-install-command=command] [--extra-install-kernel-parameters=params] [--language=lang]
      [--start-vm=session-type]
```

可以看到相关命令很多，我们需要使用的命令是`list`和`modifymedium`这两个子命令：

```sh
list [--long|-l] [--sorted|-s]          vms|runningvms|ostypes|hostdvds|hostfloppies|
                        intnets|bridgedifs|hostonlyifs|natnets|dhcpservers|
                        hostinfo|hostcpuids|hddbackends|hdds|dvds|floppies|
                        usbhost|usbfilters|systemproperties|extpacks|
                        groups|webcams|screenshotformats|cloudproviders|
                        cloudprofiles
                            
modifymedium              [disk|dvd|floppy] <uuid|filename>
                        [--type normal|writethrough|immutable|shareable|
                                readonly|multiattach]
                        [--autoreset on|off]
                        [--property <name=[value]>]
                        [--compact]
                        [--resize <megabytes>|--resizebyte <bytes>]
                        [--move <path>]
                        [--setlocation <path>]
                        [--description <description string>]
```

## 查看现有虚拟机硬盘信息

我们先查看一下虚拟机内部硬盘情况：

```sh
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   17G  1.6G   16G  10% /
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.5M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               1014M  145M  870M  15% /boot
tmpfs                    184M     0  184M   0% /run/user/0
[root@localhost ~]# fdisk -l

Disk /dev/sda: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```





我们先要确保虚拟机`jumpserver-server`已经处于关机状态：


可以看到当前虚拟分配空间为20GB，我们要将这个空间扩展到50GB。



我们使用`list`子命令查看：



```sh
$ VBoxManage.exe list hdds
UUID:           b3ed5728-6780-413a-8455-5832d1445ccc
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\centos7\centos7.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           0c710edc-8f56-4536-9694-0fff70302e90
Parent UUID:    b3ed5728-6780-413a-8455-5832d1445ccc
State:          created
Type:           normal (differencing)
Location:       C:\vmdata\VirtualBoxVMs\centos7\Snapshots/{0c710edc-8f56-4536-9694-0fff70302e90}.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           3449ef94-d547-4b84-adc1-7e7203e661e3
Parent UUID:    0c710edc-8f56-4536-9694-0fff70302e90
State:          created
Type:           normal (differencing)
Location:       C:\vmdata\VirtualBoxVMs\centos7\Snapshots/{3449ef94-d547-4b84-adc1-7e7203e661e3}.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           e33642ce-621f-4731-bd4b-7b4e7d6f4e45
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\jumpserver-client\jumpserver-client.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           17621f4b-e916-45f2-9e71-da1f4caa8024
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\jumpserver-server\jumpserver-server.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled
```

可以看到最后`jumpserver-server.vdi`对应的UUID是`17621f4b-e916-45f2-9e71-da1f4caa8024`,磁盘空间是`Capacity:       20480 MBytes`,我们需要修改为`Capacity:       51200 MBytes`，即空间为50GB。



## 扩容

使用`VBoxManage.exe modifymedium `命令扩容：

```sh
$ VBoxManage.exe modifymedium 17621f4b-e916-45f2-9e71-da1f4caa8024 --resize 51200
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

$ VBoxManage.exe list hdds
UUID:           b3ed5728-6780-413a-8455-5832d1445ccc
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\centos7\centos7.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           0c710edc-8f56-4536-9694-0fff70302e90
Parent UUID:    b3ed5728-6780-413a-8455-5832d1445ccc
State:          created
Type:           normal (differencing)
Location:       C:\vmdata\VirtualBoxVMs\centos7\Snapshots/{0c710edc-8f56-4536-9694-0fff70302e90}.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           3449ef94-d547-4b84-adc1-7e7203e661e3
Parent UUID:    0c710edc-8f56-4536-9694-0fff70302e90
State:          created
Type:           normal (differencing)
Location:       C:\vmdata\VirtualBoxVMs\centos7\Snapshots/{3449ef94-d547-4b84-adc1-7e7203e661e3}.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           e33642ce-621f-4731-bd4b-7b4e7d6f4e45
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\jumpserver-client\jumpserver-client.vdi
Storage format: VDI
Capacity:       20480 MBytes
Encryption:     disabled

UUID:           17621f4b-e916-45f2-9e71-da1f4caa8024
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       C:\vmdata\VirtualBoxVMs\jumpserver-server\jumpserver-server.vdi
Storage format: VDI
Capacity:       51200 MBytes
Encryption:     disabled

$
```

再次在VirtualBox中查看虚拟机虚拟分配空间大小：

![1589675559489](/img/1589675559489.png)

## 启动虚拟机分配空间

进入到jumpserver虚拟机后，查看磁盘情况：

```sh
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   17G  1.6G   16G  10% /      # 说明：此处并没有新增
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.5M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               1014M  145M  870M  15% /boot
tmpfs                    184M     0  184M   0% /run/user/0
```

可以看到根目录的空间Size是`17G`，并没有修改为`50G`，说明刚才在命令行扩容的空间在虚拟机还没有分配，所以需要对新增的硬盘进行分区、格式化操作。



### 查看分区情况



```sh
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

可以看到磁盘已经扩展到53.7GB，但是还不能使用。

### 开始分区

```sh
[root@localhost ~]# fdisk -l /dev/sda

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
[root@localhost ~]# fdisk /dev/sda2
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x213fc3e8.

Command (m for help): q

[root@localhost ~]# fdisk /dev/sda
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): m   # 备注：查看帮助信息
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

Command (m for help): p  # 备注：查看当前分区表

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM

Command (m for help): n  # 备注：新建分区表
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p  # 备注：选择主分区
Partition number (3,4, default 3):    # 备注：保持默认
First sector (41943040-104857599, default 41943040):   # 备注：提示修改大小，保持默认
Using default value 41943040
Last sector, +sectors or +size{K,M,G} (41943040-104857599, default 104857599): # 备注：提示修改大小，保持默认
Using default value 104857599
Partition 3 of type Linux and of size 30 GiB is set

Command (m for help): t  # 备注：修改分区id
Partition number (1-3, default 3): 3  # 备注： 选择分3
Hex code (type L to list all codes): L   # 查看所有可用的分区编码，我们使用8e

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
Hex code (type L to list all codes): 8e  # 备注：输入分区编码8e
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): w   # 备注：保存
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
[root@localhost ~]#
```

再次查看分区情况：

```sh
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
/dev/sda3        41943040   104857599    31457280   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   17G  1.6G   16G  10% /
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.5M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               1014M  145M  870M  15% /boot
tmpfs                    184M     0  184M   0% /run/user/0
```

为了不重启虚拟机，使用`partprobe`命令使配置生效：

```sh
[root@localhost ~]# partprobe
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
/dev/sda3        41943040   104857599    31457280   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

可以看到新的分区`/dev/sda3`已经标记为Linux LVM，如果没有需要`reboot`或者`partprobe`。


## 调整LVM大小

### 查看当前LVM信息

```sh
[root@localhost ~]# vgdisplay
  --- Volume group ---
  VG Name               centos   # 备注：注意关注此行
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <19.00 GiB
  PE Size               4.00 MiB
  Total PE              4863
  Alloc PE / Size       4863 / <19.00 GiB
  Free  PE / Size       0 / 0   
  VG UUID               IaHi9d-Q4Ia-WBrL-WFqd-sv9S-a5o3-SjHNkc
```

`centos`是我的`VolumeGroup`的名称，实际操作时，需要使用实际显示的名称。

### 创建物理卷并进行扩展LVM

把新分区的空间创建一个新的物理卷：

```sh
# 创建物理卷
[root@localhost ~]# pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created.

# 扩展LVM的VolumeGroup
[root@localhost ~]# vgextend centos /dev/sda3
  Volume group "centos" successfully extended
  
# 扩展LVM的逻辑卷
[root@localhost ~]# lvextend /dev/mapper/centos-root /dev/sda3
  Size of logical volume centos/root changed from <17.00 GiB (4351 extents) to 46.99 GiB (12030 extents).
  Logical volume centos/root successfully resized.

# 调整逻辑卷大小
[root@localhost ~]# resize2fs /dev/mapper/centos-root
resize2fs 1.42.9 (28-Dec-2013)
resize2fs: Bad magic number in super-block while trying to open /dev/mapper/centos-root
Couldn't find valid filesystem superblock.
```



可以发现调整逻辑卷大小失败：

```sh
[root@localhost ~]# resize2fs /dev/mapper/centos-root
resize2fs 1.42.9 (28-Dec-2013)
resize2fs: Bad magic number in super-block while trying to open /dev/mapper/centos-root
Couldn't find valid filesystem superblock.

# 查看文件格式，发现/dev/mapper/centos-root是xfs格式的
[root@localhost ~]# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        17G  1.6G   16G   10% /
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     920M     0  920M   0% /dev/shm
tmpfs                   tmpfs     920M  8.5M  911M   1% /run
tmpfs                   tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  145M  870M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0

# xfs格式的文件扩充需要使用 xfs_growfs
[root@localhost ~]# xfs_growfs /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=1113856 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=4455424, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 4455424 to 12318720

# 查看修改后的效果
[root@localhost ~]# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        47G  1.6G   46G   4% /
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     920M     0  920M   0% /dev/shm
tmpfs                   tmpfs     920M  8.5M  911M   1% /run
tmpfs                   tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  145M  870M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0
```

可以看到虚拟机的磁盘大小已经调整成功。

