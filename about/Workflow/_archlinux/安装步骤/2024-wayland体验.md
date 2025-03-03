开启nvidia rdm
开启 systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
否则会触发/etc/udev/rules.d/61-gdm.rules 默认的gnome禁用waylan规则

开启分数缩放 ，开启后需要登出再登录 否则会出现窗口定位问题
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']" 

# 多屏幕登录界面
(在wayland下面生成屏幕配置)
❯ sudo mkdir -p /etc/systemd/system/gdm.service.d/
❯ sudo vim /etc/systemd/system/gdm.service.d/override.conf
[Service]
ExecStartPre=/bin/cp /home/admin/.config/monitors.xml /var/lib/gdm/.config/monitors.xml

❯ systemctl daemon-reload
❯ systemctl restart gdm