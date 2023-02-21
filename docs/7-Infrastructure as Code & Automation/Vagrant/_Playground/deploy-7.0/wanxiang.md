sudo groupadd mysqlpaas
sudo useradd mysqlpaas -g mysqlpaas -s /bin/bash -d /home/mysqlpaas

sudo bash -c 'cat << EOF >> /etc/sudoers
mysqlpaas ALL=(ALL:ALL) NOPASSWD:ALL
EOF'

sudo su - mysqlpaas
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q

sudo mkdir -p -m 700 /home/mysqlpaas/.ssh 
sudo vi /home/mysqlpaas/.ssh/authorized_keys
sudo chmod 600 /home/mysqlpaas/.ssh/authorized_keys

docker存储 万象存储 eops存储



## bug 
/mnt/data02//docker

sudo chown  mysqlpaas ~/.ssh/authorized_keys
sudo chown mysqlpaas /mnt/datasql/

easyops 需要每个节点都手动装docker吗

docker目录不一样容易混淆

Downloading playbooks: http://repo.bdms.service.163.org/EasyData-V7.0//centos7/easyo
./upgrade_playbook_700.sh  /home/easyops/easyops-2.0.1.1/services-spec/tools http://repo.bdms.service.163.org/EasyData-V7.0