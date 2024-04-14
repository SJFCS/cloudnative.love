https://www.zhihu.com/question/511958588/answer/3137705299?utm_psn=1765122065286434817&utm_id=0
https://golang.design/go-questions/interface/duck-typing/

我们有一只鸭子和一只鸡，他们工作得很好。我们发现鸭子和鸡有很多重复的地方，他们都会飞，都有两只脚两个翅膀，都会唧唧或者嘎嘎叫。于是我们抽象出鸟这个父类，鸭子和鸡都继承了鸟这个父类， 当我们想要在飞的时候额外做点什么，只需要修改鸟就好了，代码得到了缩减，维护起来看似方便了。鸟工作得也很好。

我们业务不断扩展，企鹅出现了。 它不会飞，但是会游泳。 鸟的工作出了问题，于是我们把飞行这个功能被下沉到了会飞的鸟类，企鹅继承自一个不会飞的鸟类。接下来橡皮鸭子出现了，人们对于它究竟是不是鸟有了争议。开始浪费时间大量的讨论什么是鸟，鸟该做些什么。

但我们的生活中没有鸟（请注意这句话），鸟是一个抽象， 我们生活中有鸡，有鸭。我们觉得他们有一些相同的地方，于是把拥有这些相同点的东西叫做鸟，但永远不知道下一个遇见的，能不能算鸟， 鸟的定义要不要修改。这就是继承不适用的原因，让我们看看组合会怎么样。我们找到了鸡和鸭的共同点， 会飞，两只脚，两个翅膀，会叫。 这些东西加上其他的特质『组合』成了鸡或鸭。 会飞这个能力就能提出来，使用在每一个需要飞行能力的地方。 当我遇到企鹅，就不用拿飞行来『组合』它。飞行，不应该是鸡或鸭从父类继承的能力，而应该是『飞行能力』组合成了鸡鸭的一部分。





package main

import "fmt"

// IGreeting 接口
type IGreeting interface {
    sayHello()
}

// English 实现了 IGreeting 接口
type English struct{}

func (e English) sayHello() {
    fmt.Println("Hello!")
}

// Spanish 实现了 IGreeting 接口
type Spanish struct{}

func (s Spanish) sayHello() {
    fmt.Println("Hola!")
}

// sayHello 函数接收任何实现了 IGreeting 接口的类型
func sayHello(i IGreeting) {
    i.sayHello()
}

func main() {
    eng := English{}
    esp := Spanish{}

    // 这些调用展示了多态性
    sayHello(eng) // 输出: Hello!
    sayHello(esp) // 输出: Hola!
}

在这个例子中，English和Spanish类型都实现了IGreeting接口，因为它们都有sayHello()方法。sayHello(eng)和sayHello(esp)调用中，eng和esp实例按它们实际的类型调用自己的sayHello()实现。这就是i.sayHello()如何与接口里的sayHello()有关系的：i.sayHello()调用的是传入实例的具体sayHello()方法实现，而这种能力是通过接口多态性实现的。


