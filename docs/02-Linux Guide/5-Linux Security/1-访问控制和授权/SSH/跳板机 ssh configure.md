# 跳板机 ssh configure
[ops@package0 ~]$ cat  ~/.ssh/config
Host cnode*
    User easyops
    ProxyCommand ncat --proxy  10.196.80.225:10010  --proxy-type socks5 %h %p
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no

Host bigdata-demo*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang

Host hadoop-ky-test*.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test

Host jnode*
    User easyops
    ProxyCommand ncat --proxy  10.196.68.168:10010  --proxy-type socks5 %h %p
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    Compression yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
    ControlMaster auto
    ControlPersist 4h


Host qa*node*
    User easyops
    ProxyCommand ncat --proxy  10.196.73.157:10010  --proxy-type socks5 %h %p
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no

Host 172.30.3.*
    ProxyCommand ncat --proxy  10.196.73.157:10010  --proxy-type socks5 %h %p
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
Host 6502
    HostName hadoop6502.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/6502
Host 5411
    HostName hadoop5411.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/6502
Host 5412
    HostName hadoop5412.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/6502
Host 5437
    HostName hadoop5437.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/6502


Host 10.198.108.*
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test13
    HostName easyops-test13.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test7
    HostName easyops-test7.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12
Host test8
    HostName easyops-test8.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12
Host test16
    HostName easyops-test16.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test15
    HostName easyops-test15.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test14
    HostName easyops-test14.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12
Host demo3
    HostName bigdata-demo3.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6
Host demo4
    HostName bigdata-demo4.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6

Host demo5
    HostName bigdata-demo5.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6

Host demo6
    HostName bigdata-demo6.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6


Host 7205
    HostName hadoop7205.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/hadoop7205
Host 7206
    HostName hadoop7206.jd.163.org
    Port 1046
    User easyops
Host test9
    HostName easyops-test9.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12
Host test16
    HostName easyops-test16.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test15
    HostName easyops-test15.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12

Host test14
    HostName easyops-test14.jdlt.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/test12
Host demo3
    HostName bigdata-demo3.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6
Host demo4
    HostName bigdata-demo4.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6

Host demo5
    HostName bigdata-demo5.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6

Host demo6
    HostName bigdata-demo6.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6


Host 7205
    HostName hadoop7205.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/hadoop7205
Host 7206
    HostName hadoop7206.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/hadoop7205


Host tnode1.local
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null


# DP
Host dp1
    HostName 10.196.98.253
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang

Host dp2
    HostName 10.196.98.254
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host dp3
    HostName 10.196.98.255
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host dp4
    HostName 10.196.99.1
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host 10.196.80.*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host 10.196.137.*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host hadoop72*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host 10.*.*.*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host cnode*-ndh.*
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
Host 7187
    HostName hadoop7187.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/7187
Host 7279
    HostName hadoop7279.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/7187
Host 7278
    HostName hadoop7278.jd.163.org
    Port 1046
    User easyops
    IdentityFile ~/.ssh/7187


#VKO
Host vko01
    HostName easyops-vko01.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6

Host vko02
    HostName easyops-vko02.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6


Host vko03
    HostName easyops-vko03.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6


Host vko04
    HostName easyops-vko04.jd.163.org
    User easyops
    Port 1046
    IdentityFile ~/.ssh/demo3-6
Host hadoop*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host hadoop8045*
    HostName hadoop8045.jd.163.org
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host easyops-vko*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang


Host bigdata-demo*
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang

Host bigdata-demo71
    HostName bigdata-demo7
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host bigdata-demo81
    HostName bigdata-demo8
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host bigdata-demo91
    HostName bigdata-demo9
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang
Host bigdata-demo101
    HostName bigdata-demo10
    Port 1046
    User fangzhihao
    IdentityFile ~/.ssh/zhfang

Host n?node*
    User easyops
    ProxyCommand ncat --proxy  10.196.84.205:10010  --proxy-type socks5 %h %p
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no

Host *node*
  User easyops
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host 192.168.123.*
    User easyops
    Port 22
    ProxyCommand ncat --proxy  10.198.108.16:8000  --proxy-type socks5 %h %p
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no