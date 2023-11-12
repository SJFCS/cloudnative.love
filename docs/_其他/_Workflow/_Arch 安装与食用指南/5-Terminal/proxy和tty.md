
proxy切换在profile中添加
```
proxy=http://$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*'):20172

function setproxy() {
export {http,https,ftp,all}_proxy=$proxy
export {HTTP,HTTPS,FTP,ALL}_PROXY=$proxy
}

function unsetproxy() {
unset {http,https,ftp,all}_proxy
unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

function showproxy() {
env | grep -i proxy
}
```
tty自动识别
```
if [[ $(tty) == /dev/tty* ]]; then
    export LANG=en_US.UTF-8
else
    export LANG=zh_CN.UTF-8
fi
```