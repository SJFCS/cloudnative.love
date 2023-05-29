```bash
#!/bin/bash

function uninst_openssh() {
  echo "The version for OPENSSH in this host is:"
  rpm -qa |grep openssh
  echo -n "Do you want to remove this packages { yes / no }"
  read input
  case $input in
    Y|y|YES|yes)
      echo -e "\033[5m You choice Yes.Please do not close this terminal after uninstall, or you can not connect it anymore!! \033[0m"
      echo 'Backup sshd and ssh config'
      if [[ ! -d sshbak ]]; then
        mkdir sshbak
      fi
      cp -fr /etc/ssh/* ./sshbak/
      rpm -qa |grep openssh|xargs -i rpm -e --nodeps {}
      yum localinstall -y *.rpm
      cp -f sshkey/id_rsa /root/.ssh/
      cp -f sshkey/authorized_keys /root/.ssh/
      cp -f sshbak/* /etc/ssh/
      systemctl restart sshd
      systemctl status sshd
      ;;
    *)
      exit -1;
      ;;
  esac
}

uninst_openssh

```