---
title: Golang✨
tags: [Coding, Golang]
---
## index

[Golang | 既是接口又是类型，interface是什么神仙用法？](https://www.zhihu.com/question/602686497?utm_id=0)

```
2.4 go mod
·g01.11版本开始支持g0m0du1es
·包的存放路径为{G0PATH},windows.默认在SUSERPR0FILE%\g0(C:\Users\XXx\go)
g0.m0d记录依赖包的名字以及版本号等信息
●
g0.sUm记录依赖包的校验信息
使用g0mod初始化项目：
mkdir go-demo
cd go-demo
g0m0 d init g0-dem0#生成g0.m0d和g0.sUm
go env -w GOPROXY="https:/goproxy.cn,direct"

下载未安装但使用的包
go mod 










Go语言共有25个关键字：
break        default      func         interface    select
case         defer        go           map          struct
chan         else         goto         package      switch
const        fallthrough  if           range        type
continue     for          import       return       var


TypeScript（TS）：与JS相同，共47个关键字
Python：35个关键字
Java：50个关键字





## while
for condition {
    // 循环体
}


在 Go 中，可以使用 for 循环来模拟 while，同时通过 break 语句来中断循环。以下是一个示例代码：

for {
    // 循环体
    if condition {
        break
    }
}
在这个示例中，for 循环没有任何条件，因此会一直执行循环体，直到 condition 变为 true 时才会通过 break 语句中断循环。
```