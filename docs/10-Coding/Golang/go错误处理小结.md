## error的本质
转载：https://www.zouhl.com/posts/go%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86%E5%B0%8F%E7%BB%93/

go语言中的error本质就是一个接口。

```go
type error interface {
	Error() string
}
```
我们常用的errors.new则是返回一个实现了error接口errString结构体的**指针**（如果返回的不是指针，则无法进行底层比较）。

```go
func New(text string) error {
   return &errorString{text}
}

// errorString is a trivial implementation of error.
type errorString struct {
   s string
}

func (e *errorString) Error() string {
   return e.s
}
```

## 与c比较

c是单返回值，一般通过传递指针作为入参，返回值为nil表示成功，负数表示失败并判断对应的错误原因。

go语言是多值返回，一般在函数签名中带上实现了err interface的对象，交由调用者来判断。

## error的几种使用方式

### 预定义错误

```go
var EOF = errors.New("EOF")
var ErrClosedPipe = errors.New("io: read/write on closed pipe")
```
例如常见的io.EOF就是预定义错误。

预定义错误需成为你API的公共部分。公共的函数或者方法需要返回一个特定值的错误，该值必须是公共的，调用者可以使用该值进行判断。

但是多个包之间的可能会因此产生源码依赖关系，所以需尽量避免使用预定义错误。

### error type

error type 是实现了error接口的自定义类型。例如下面的Error类型可以操作方式和记录文件路径

```go
// PathError records an error and the operation and file path that caused it.
type PathError struct {
	Op   string
	Path string
	Err  error
}

func (e *PathError) Error() string { return e.Op + " " + e.Path + ": " + e.Err.Error() }

func (e *PathError) Unwrap() error { return e.Err }
```
因为Error是一个type，调用者需要使用断言转换成这个类型，来获取跟更多的字段信息。

调用者需要使用类型断言和类型switch（如下代码所示），就需要让error成为公开的，这种模型会导致和调用者产生强耦合，从而导致API变得脆弱。我们应该避免使用错误类型，或者使其成为公共API的一部分。

```go
// underlyingError returns the underlying error for known os error types.
func underlyingError(err error) error {
	switch err := err.(type) {
	case *PathError:
		return err.Err
	case *LinkError:
		return err.Err
	case *SyscallError:
		return err.Err
	}
	return err
}
```
### 不透明的错误处理
在处理错误的时候，只需要返回错误，而不去假定其内容

```go
if err != nil {
  return err
}
```
## wrap和pkg/errors
go 1.13为errors和fmt包引入了新特性，以简化包含其它错误的错误。其中最重要的是：包含另一个错误的error可以实现返回底层错误的unwrap方法。如果e1.Unwrap()返回e2，那么我们说e1包装了e2，你可以展开e1获得e2。

go 1.13中fmt.Errorf支持新的%w谓词。

```go
err := fmt.Errorf("access denied: %w", ErrPermission)
```
用%w包装错误可用于erros.Is以及erros.As (内部循环unwrap(err)，再进行比较判断)：

errors.Is函数将错误与值进行比较。

```go
// Similar to:
//   if err == ErrNotFound { … }
if errors.Is(err, ErrNotFound) {
    // something wasn't found
}
```
As函数测试错误是否为特定类型。

```go
// Similar to:
//   if e, ok := err.(*QueryError); ok { … }
var e *QueryError
// Note: *QueryError is the type of the error.
if errors.As(err, &e) {
    // err is a *QueryError, and e is set to the error's value
}
```
尽管go 1.13加入了wrap功能，能够对下层的错误进行封装，但是其返回的错误信息不带有错误的堆栈信息，不方便我们进行排查问题。下面介绍结合pkg/errros库来使用go 1.13的wrap功能。

1. 使用pkg/errors的Wrap或者Wrapf函数对堆栈信息进行封装，errors.Wrap(err, "access denied")来代替fmt.Errorf("access denied: %w",err)

```go
// Wrap returns an error annotating err with a stack trace
// at the point Wrap is called, and the supplied message.
// If err is nil, Wrap returns nil.
func Wrap(err error, message string) error {
 if err == nil {
     return nil
 }
 err = &withMessage{
     cause: err,
     msg:   message,
 }
 return &withStack{
     err,
     callers(),
 }
}
```
2. 在需要打印堆栈信息时，使用谓词%+v输出堆栈信息。

```go
fmt.Printf("main :%+v\n", err)
```
3. pkg/errors库也实现了go 1.13加入了新特性（UnWrap，Is，As），所以在判断错误类型时。

完整示例如下

```go
package main
   
import (
 "errors"
 "fmt"
   
 xerrors "github.com/pkg/errors"
)
   
type ErrPath struct {
 msg string
}
   
func (p *ErrPath) Error() string {
 return p.msg
}
   
   
func main() {
 err := test2()
 // var e *ErrPath
 e:= &ErrPath{}
 defer func() {
     if err:= recover();err!=nil {
         fmt.Println(err)
     }
 }()
 if errors.As(err, &e) {
     fmt.Println("err is ErrPath")
 }
 fmt.Printf("main: %+v\n", err)
}
   
func test0() error {
 return xerrors.Wrap(&ErrPath{msg: "path not exists"}, "test0 failed")
}
   
func test1() error {
 return test0()
}
   
func test2() error {
 return test1()
}
```
   

