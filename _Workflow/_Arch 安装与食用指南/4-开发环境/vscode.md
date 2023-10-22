https://www.v2ex.com/t/979052

https://segmentfault.com/q/1010000016731279

https://code.visualstudio.com/docs/devcontainers/containers

VScode下golang 同一个包下不同文件之间函数调用问题

同文件夹下的两个文件，在都处于main包的情况下，无法在mian()里直接调用另一个文件中的函数，会报错：undefined。

一般来讲，大家用的都是Code runner插件作为运行工具。但是用的时候需要配置以下该插件的settings.json。
```
    "code-runner.executorMap": {
        "go": "cd $dir && go run .", // 替换处1
    },
    "code-runner.executorMapByGlob": {
        "$dir\\*.go": "go" // 替换处2
    }
```



VS代码集成终端中不显示 powerlevel10k 图标
"terminal.integrated.fontFamily": "MesloLGS NF",

