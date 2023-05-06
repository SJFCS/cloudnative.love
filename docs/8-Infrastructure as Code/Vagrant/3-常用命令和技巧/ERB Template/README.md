---
title: ERB Template
---
## 进一步优化
进一步优化 Vagrantfile，使其更加易读和面向对象化。以下是一些可能的优化方式：

- 使用类和方法来管理虚拟机的配置。可以将 Vagrantfile 中的每个虚拟机配置封装到一个类中，然后通过方法来设置各种配置项。这样可以避免在 Vagrantfile 中重复编写相似的配置项，提高代码重用性和可读性。

- 使用模板来生成 Vagrantfile。可以使用模板引擎（如 ERB）来生成 Vagrantfile，将重复的代码抽象成模板，然后通过填充变量来生成具体的配置文件。这样可以提高代码复用性和可读性，同时还可以方便地生成多个相似的 Vagrantfile。

## ERB 模板
`--template FILE` 参数提供用于生成 Vagrantfile 的自定义 ERB 模板

- 创建一个 Vagrantfile.erb 文件，文件名必须以 .erb 结尾。
- 在 Vagrantfile.erb 文件中，使用 Ruby 代码定义变量和逻辑。
- 在 Vagrantfile 文件中，使用 erb 方法加载 Vagrantfile.erb 文件，并传入变量。

示例 Vagrantfile.erb  代码：

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "<%= box %>"
  config.vm.network "forwarded_port", guest: <%= guest_port %>, host: <%= host_port %>
end
```

Vagrantfile 文件：

```ruby
# 定义变量
box = "ubuntu/xenial64"
guest_port = 80
host_port = 8080

# 加载 Vagrantfile.erb 并传入变量
vagrantfile = ERB.new(File.read("Vagrantfile.erb")).result(binding)

# 输出 Vagrantfile
puts vagrantfile

# 使用 Vagrant API 创建虚拟机
Vagrant.configure("2") do |config|
  eval(vagrantfile)
end
```

运行 `vagrant up` 命令，Vagrant 会读取生成的 Vagrantfile 文件并创建虚拟机。


:::caution注意事项
- ERB 模板中的 Ruby 代码必须使用 <%= %> 或 <% %> 标签包裹。
- ERB 模板中的 Ruby 代码可以访问当前环境中的变量和方法。
- ERB 模板中的 Ruby 代码可以使用条件语句和循环语句。
- Vagrantfile.erb 文件和 Vagrantfile 文件必须在同一目录下。
- Vagrantfile.erb 文件中的代码必须符合 Vagrantfile 的语法规范。
:::

## template

Vagrant 4.0 之后提供了 vagrant init --template FILE 命令来指定使用自定义的 Vagrantfile 模板文件。

- 创建一个 Vagrantfile.erb 文件，文件名必须以 .erb 结尾。
- 在 Vagrantfile.erb 文件中，使用 Ruby 代码定义变量和逻辑。
- 运行 vagrant init --template Vagrantfile.erb 命令，Vagrant 会使用 Vagrantfile.erb 文件作为模板生成 Vagrantfile 文件。

Vagrantfile.erb 文件：

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "<%= box %>"
  config.vm.network "forwarded_port", guest: <%= guest_port %>, host: <%= host_port %>
end
```

其中 <%= box %> 和 <%= guest_port %> 和 <%= host_port %> 是在运行命令时通过 `--var` 参数或环境变量传入的值，例如：
```bash
vagrant init --template Vagrantfile.erb --var box=ubuntu/xenial64 --var guest_port=8080 --var host_port=8888
```
也可以通过设置环境变量来传递值，例如：
```bash
export VAGRANT_VAR_box="ubuntu/xenial64"
export VAGRANT_VAR_guest_port="8080"
export VAGRANT_VAR_host_port="8888"
vagrant init --template Vagrantfile.erb
```