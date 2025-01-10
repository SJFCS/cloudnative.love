gnome3中，gconf已经完全被dconf所替代，用于gnome配置管理类似win的注册表，它有一个界面编辑器dconf-editor，也可以通过gsettings命令行来进行编辑
paru -S dconf-editor

dconf dump / > current_settings.txt

没有地址栏对我来说也很烦人。

gsettings set org.gnome.nautilus.preferences always-use-location-entry true

