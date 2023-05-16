
nmtui提供基于光标的文本用户界面（TUI）， nmtui可提供一个文本界面来与NetworkManager交互用于配置网络。该工具包含在NetworkManager-tui子软件包中。通常不会默认随NetworkManager的安装而安装该子软件包。需要单独安装 NetworkManager-tui。


## 消息框
```bash
# whiptail --title "<message box title>" --msgbox "<text to show>" <height> <width>
whiptail --title "Message box title" --msgbox " Choose Ok to continue." 10 60
```

## 对话框

```bash
# whiptail --title "<dialog box title>" --yesno "<text to show>" <height> <width>
#!/bin/bash
if (whiptail --title "Yes/No Box" --yesno "Choose between Yes and No." 10 60) then
    echo "You chose Yes. Exit status was $?."
else
    echo "You chose No. Exit status was $?."
fi
```
或者也可以是自定义的选项，实例如下：

```bash
#!/bin/bash
if (whiptail --title "Yes/No Box" --yes-button "Man" --no-button "Woman"  --yesno "What is your gender?" 10 60) then
    echo "You chose Man Exit status was $?."
else
    echo "You chose Woman. Exit status was $?."
fi
```

## 表单输入框

```bash
# whiptail --title "<input box title>" --inputbox "<text to show>" <height> <width> <default-text>
#!/bin/bash
NAME=$(whiptail --title "Free-form Input Box" --inputbox "What is your pet's name?" 10 60 Peter 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your name is:" $NAME
else
    echo "You chose Cancel."
fi
```
##  密码输入框

```bash
# whiptail --title "<password box title>" --passwordbox "<text to show>" <height> <width>

#!/bin/bash
PASSWORD=$(whiptail --title "Password Box" --passwordbox "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your password is:" $PASSWORD
else
    echo "You chose Cancel."
fi
```

## 菜单栏
```bash
# whiptail --title "<menu title>" --menu "<text to show>" <height> <width> <menu height> [ <tag> <item> ] . . .

#!/bin/bash
OPTION=$(whiptail --title "Menu Dialog" --menu "Choose your favorite programming language." 15 60 4 \
"1" "Python" \
"2" "Java" \
"3" "C" \
"4" "PHP"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your favorite programming language is:" $OPTION
else
    echo "You chose Cancel."
fi
```

## radiolist单选对话框

```bash
# whiptail --title "<radiolist title>" --radiolist "<text to show>" <height> <width> <list height> [ <tag> <item> <status> ] . . .

#!/bin/bash
DISTROS=$(whiptail --title "Test Checklist Dialog" --radiolist \
"What is the Linux distro of your choice?" 15 60 4 \
"debian" "Venerable Debian" ON \
"ubuntu" "Popular Ubuntu" OFF \
"centos" "Stable CentOS" OFF \
"mint" "Rising Star Mint" OFF 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "The chosen distro is:" $DISTROS
else
    echo "You chose Cancel."
fi　　
```

## 多选对话框
```bash
# whiptail --title "<checklist title>" --checklist "<text to show>" <height> <width> <list height> [ <tag> <item> <status> ] . . .

#!/bin/bash
DISTROS=$(whiptail --title "Checklist Dialog" --checklist \
"Choose preferred Linux distros" 15 60 4 \
"debian" "Venerable Debian" ON \
"ubuntu" "Popular Ubuntu" OFF \
"centos" "Stable CentOS" ON \
"mint" "Rising Star Mint" OFF 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your favorite distros are:" $DISTROS
else
    echo "You chose Cancel."
fi
```

## 进度条

https://blog.csdn.net/nicedante/article/details/128267149

```bash
# whiptail --gauge "<test to show>" <height> <width> <inital percent>
#!/bin/bash
{
    echo 25
    sleep 1
    echo 50
    sleep 1
    echo 75
    sleep 1
    echo 100
} | whiptail --gauge "Please wait while installing" 6 60 0
```

```
whiptail --gauge "Please wait while installing" 6 60 50
```
