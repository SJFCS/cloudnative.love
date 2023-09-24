---
title: Bazel📝
---
https://static.googleusercontent.com/media/research.google.com/en/us/pubs/archive/37755.pdf

https://developer.aliyun.com/article/1150284

https://my.oschina.net/biedamingming/blog/4480498

Bazel 是一个由Google开发的构建工具，用于构建和测试多语言软件项目。它支持多种编程语言，包括Java，C++，Python和Objective-C。Bazel使用一个基于规则的构建系统来管理代码库中的依赖关系，并提供了高度可扩展性和可重复性的构建过程。

Google使用Bazel来构建其大型的开源项目，例如TensorFlow、Angular、Protocol Buffers等。这些项目都具有大量的代码、依赖项和测试用例，使用Bazel可以大大提高构建速度和可重现性，从而使开发人员能够更快地迭代和发布代码

Bazel的优势包括：
- 高度可扩展性：可以处理大型代码库和复杂的依赖关系。
- 高度可重复性：构建过程是确定性的，可以避免构建错误。
- 多语言支持：支持多种编程语言，可以在同一个工具链下处理不同的语言。
- 高性能：可以并行构建和测试。
- 易于维护：使用声明性语言来定义构建规则，易于理解和维护。

一个简单的例子是构建一个Java项目。假设您有一个名为“hello-world”的Java项目，可以使用以下BUILD文件来定义构建规则：

```bash
java_binary(
    name = "hello-world",
    srcs = glob(["src/main/java/**/*.java"]),
    main_class = "com.example.HelloWorld",
    deps = [
        "//path/to/dependency1",
        "//path/to/dependency2",
    ],
)
```
这个BUILD文件定义了一个名为“hello-world”的Java二进制文件，它的源代码在“src/main/java/”目录下，它的主类是“com.example.HelloWorld”，并且它依赖于两个其他Bazel规则。


您可以使用以下命令来构建和运行该项目：

```bash
bazel build //:hello-world
bazel run //:hello-world
```


## 以下是使用Bazel构建Java项目的示例：

在项目根目录下创建一个名为WORKSPACE的文件，其中包含以下内容：

```conf
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "maven",
    sha256 = "d7b3f3c8fbf7d5c5c5b7b5f5a8a5a5a5b5b7b5f5a8a5a5a5b5b7b5f5a8a5a5a5",
    urls = [
        "https://mirror.bazel.build/apache/maven-3.6.3-bin.tar.gz",
        "https://archive.apache.org/dist/maven/maven-3.6.3/binaries/maven-3.6.3-bin.tar.gz",
    ],
)

load("@maven//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "junit:junit:4.13.2",
    ],
    repositories = [
        "https://repo.maven.apache.org/maven2",
    ],
)
```
这里使用http_archive规则来下载Maven，并使用maven_install规则从Maven仓库下载JUnit。

在项目根目录下创建一个名为BUILD.bazel的文件，其中包含以下内容：

```conf
load("@maven//:workspace.bzl", "rules")

rules()

java_library(
    name = "my_library",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@maven//:junit_junit",
    ],
)

java_test(
    name = "my_test",
    srcs = glob(["src/test/java/**/*.java"]),
    deps = [
        ":my_library",
        "@maven//:junit_junit",
    ],
)
```
这里定义了一个Java库my_library和一个Java测试my_test，它们都依赖于JUnit。srcs参数使用glob函数来指定源代码文件的位置。

在项目根目录下创建一个名为src/main/java/com/example/mylibrary/MyClass.java的文件，其中包含以下内容：

```java
package com.example.mylibrary;

public class MyClass {
    public static void main(String[] args) {
        System.out.println("Hello, world!");
    }
}
```

在项目根目录下创建一个名为src/test/java/com/example/mylibrary/MyClassTest.java的文件，其中包含以下内容：

```java
package com.example.mylibrary;

import org.junit.Test;
import static org.junit.Assert.*;

public class MyClassTest {
    @Test
    public void test() {
        assertEquals(2, 1 + 1);
    }
}
```

现在可以运行`bazel build //:my_library`和`bazel test //:my_test`来构建和运行代码了。

## 以下是一个更复杂的示例，展示了Bazel在构建大型Java项目时的一些优势：


假设我们正在构建一个名为my_project的Java应用程序，该应用程序包含许多模块和依赖项。我们使用Bazel构建该项目，并且希望利用Bazel的优势来提高构建速度和可重现性。

1. 使用外部依赖项

为了提高构建速度，我们使用Bazel的外部依赖项功能来管理我们的第三方依赖项。在我们的WORKSPACE文件中，我们声明了所有需要的外部依赖项：

```conf
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "com_google_guava",
    url = "https://github.com/google/guava/archive/v31.0.1-jre.tar.gz",
    sha256 = "07c1a7c1e2f2f7c9b9aa9d4c4f3d26b7c1b4ad2d7f59fbf8f5b5c5b5a0b69e6d",
)

http_archive(
    name = "junit",
    url = "https://github.com/junit-team/junit4/archive/r2.0.0.tar.gz",
    sha256 = "e7d8f84f0d0fd9a3420751c5e6b8de04d431a630f0e97521bdfb3e3b3f1c9c2e",
)
```
然后，在我们的BUILD文件中，我们可以引用这些依赖项：

```conf
java_library(
    name = "my_library",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@com_google_guava//jar",
        "@junit//jar",
    ],
)
```
1. 利用缓存和增量构建

由于我们使用了外部依赖项，Bazel可以将它们缓存在本地和远程缓存中。这意味着在下一次构建时，Bazel可以重用已编译的依赖项，从而大大缩短构建时间。

此外，Bazel使用增量构建来确定哪些目标需要重新构建。这意味着如果只更改了一个Java文件，则Bazel只会重新编译该文件及其依赖项，而不是整个项目。这可以大大提高构建效率。

3. 并行构建

Bazel可以并行构建多个目标，从而提高构建速度。例如，如果我们有多个Java库和应用程序，我们可以同时构建它们，而不是一次只构建一个。这可以在某些情况下显著提高构建速度。


总的来说，Bazel可以提供更快的构建速度、更好的可重现性和更高的可扩展性，从而使开发人员更轻松地管理和维护大型Java项目。