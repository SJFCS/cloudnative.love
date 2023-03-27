## 自动设置 Time zone 时区
### 基于地理定位的设置
要根据 IP 地址位置自动设置时区，可以使用地理定位 API 检索时区，例如 `curl https://ipapi.co/timezone` ，并将输出传递给 timedatectl set-timezone 进行自动设置。一些提供免费或部分免费服务的地理知识产权应用程式介面如下:
[Abstract IP geolocation API](https://www.abstractapi.com/ip-geolocation-api)  
[FreegeoIP](https://freegeoip.app/) 
[IP-api](https://ip-api.com/)  
[IPAPI](https://ipapi.co/)  
[Ipdata](https://ipdata.co/)  
[Ipstack](https://ipstack.com/)  
[TimezoneApi](https://timezoneapi.io/)  
### 每次 NetworkManager 连接到网络时更新时区
创建 NetworkManager 调度程序脚本:

```bash title="/etc/NetworkManager/dispatcher.d/09-timezone"
#!/bin/sh
case "$2" in
    up)
        timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"
    ;;
esac
```
:::info
提示: 使用 `connectivity-change` 而不是 `up` 可以防止在连接 VPN 时发生时区更改。
:::
### 每个用户/会话或临时设置

如果你想让应用程序“看到”与系统时区不同的时区，设置 TZ 环境变量，例如:
```bash
$ date && export TZ=":/usr/share/zoneinfo/Asia/Shanghai" && date
Tue Feb 21 21:24:25 CST 2023
Tue Feb 21 21:24:25 CST 2023
```