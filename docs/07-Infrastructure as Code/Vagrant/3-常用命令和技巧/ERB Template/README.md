---
title: ERB Template
---
## 进一步优化
进一步优化 Vagrantfile，使其更加易读和面向对象化。以下是一些可能的优化方式：

- 使用类和方法来管理虚拟机的配置。可以将 Vagrantfile 中的每个虚拟机配置封装到一个类中，然后通过方法来设置各种配置项。这样可以避免在 Vagrantfile 中重复编写相似的配置项，提高代码重用性和可读性。

- 使用模板来生成 Vagrantfile。可以使用模板引擎（如 ERB）来生成 Vagrantfile，将重复的代码抽象成模板，然后通过填充变量来生成具体的配置文件。这样可以提高代码复用性和可读性，同时还可以方便地生成多个相似的 Vagrantfile。

## ERB 模板
`vagrant init --template FILE` 可指定 ERB 模板来生成 Vagrantfile


:::warning注意事项
- ERB 模板中的 Ruby 代码必须使用 `<%= %>` 或 `<% %>`标签包裹。
- ERB 模板中的 Ruby 代码可以访问当前环境中的变量和方法。
- ERB 模板中的 Ruby 代码可以使用条件语句和循环语句。
- Vagrantfile.erb 文件中的代码必须符合 Vagrantfile 的语法规范。
:::


编写 Vagrantfile.erb 文件：

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "<%= ENV['BOX'] %>"
  config.vm.network "forwarded_port", guest: '<%= ENV['GUEST_PORT'] %>', host: '<%= ENV['HOST_PORT'] %>'
end
```
然后，通过以下命令来设置环境变量并生成 Vagrantfile 文件：

```bash
export box="ubuntu/xenial64"
export guest_port=8080
export host_port=8888
vagrant init --template Vagrantfile.erb
```
