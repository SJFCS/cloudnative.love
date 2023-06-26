
```bash

bash <(curl -sL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirror.sh)

https://github.com/SuperManito/LinuxMirrors

#!/bin/bash

SYSTEM_NAME=`lsb_release -is`
SYSTEM_VERSION=`lsb_release -cs`
SYSTEM_VERSION_NUMBER=`lsb_release -rs`
echo -e "\033[37m      当前操作系统  $SYSTEM_NAME $SYSTEM_VERSION_NUMBER $SYSTEM_VERSION \033[0m"

```

shell脚本使用root
https://blog.csdn.net/qq_45467083/article/details/121179961