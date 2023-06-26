```
bash -i 可以创建新的tty

su - zcwyou -c 'whoami'

su - user1 <<EOF
echo "This script is running as user1"
whoami
ls -la /home/user1/
EOF

sudo -u zcwyou 'whoami'

runuser - zcwyou -c 'mkdir -p ~/hello; ls -l' 
```