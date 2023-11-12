---
title: Arch 食用指南
---
## 是什么
在安装archlinux后如何设置和使用
## 不是什么
不会手把手指导你安装Arch Linux，这被认为是基础的。



- https://arch.icekylin.online/
- https://arch-linux.osrc.com/
- https://archlinuxstudio.github.io/ArchLinuxTutorial/#/
- https://ubunlog.com/zh-CN/waydroid-%E4%B8%80%E5%A5%97%E5%9C%A8-ubuntu-%E4%B8%8A%E8%BF%90%E8%A1%8C%E4%BD%A0%E7%9A%84%E5%AE%89%E5%8D%93%E5%BA%94%E7%94%A8%E7%9A%84%E5%B7%A5%E5%85%B7/
- https://python-archinstall.readthedocs.io/en/latest/index.html
## 配置管理
- https://github.com/chaneyzorn/dotfiles
- https://github.com/nix-community/home-manager
- https://nixos.org/
- https://dotfiles.github.io/
- https://venthur.de/2021-12-19-managing-dotfiles-with-stow.html

我使用arch linux 作为日常办公使用，现在我想要重新在其他设备上安装archlinux，但我发现我的很多配置已经忘记了，有没有什么方法可以声明式我的linux配置，方便我进行gitops管理，使其可以在任何时候轻松的重新部署安装。我目前知道nix可以解决此需求，但我记得nix不如arch的包管理好用。所以有没有更好地方式，避免我的系统发生配置偏移
    ansible不是我想要的答案
### Dotfiles
Dotfiles 是指以点开头的文件和文件夹，它们通常包含着系统的配置，如 Shell 配置、编辑器配置、Git 配置等等。

使用 Dotfiles 的好处是，你可以将所有的配置放在一个 Git 仓库中进行版本控制，这样你就可以轻松地在任何地方部署相同的配置。此外，你还可以使用工具如 GNU Stow 来管理你的 Dotfiles，它可以将配置链接到你的家目录中，使得配置文件的更新更加方便。

下面是一些步骤，可以帮助你使用 Dotfiles 来管理你的配置：

创建一个 Git 仓库，用于存储你的 Dotfiles。你可以将其上传到 GitHub 或 GitLab 等平台上，这样就可以轻松地在多台设备上同步你的配置。
将你的 Dotfiles 放在仓库的根目录下，例如 ~/.bashrc、~/.vimrc 等等。
创建一个脚本来链接你的 Dotfiles 到家目录中。你可以使用 GNU Stow 等工具来完成这个任务。例如，如果你要链接 ~/.bashrc，可以运行以下命令：stow bash。这个命令会将仓库中的 bash/.bashrc 链接到你的家目录下的 .bashrc 文件中。
将你的 Dotfiles 添加到版本控制系统中，使用 Git 进行管理。
通过使用 Dotfiles，你可以轻松地在任何设备上同步和管理你的配置文件。如果你要重新安装 Arch Linux，只需在新系统上克隆你的 Dotfiles 仓库，然后运行脚本链接你的配置即可。这样就可以确保你的系统配置保持一致，避免出现配置偏移的问题。

### nix

另一种方法是使用像 Nix 这样的函数式包管理系统。Nix 允许你声明式地定义系统配置，这样你可以方便地将其复制到其他设备上。与普通的 Linux 发行版不同，Nix 具有完全隔离的包管理系统，这意味着你可以在同一系统上安装不同版本的软件而不会产生冲突。

与 Dotfiles 相比，Nix 具有更强大的配置管理功能，但也需要更多的学习和配置。

**nix会和原有包管理冲突嘛**  
Nix 不会和 Arch 原有的包管理器冲突，因为它与 Arch 的软件包没有任何关联。它使用自己的软件包集合，这些软件包是专门为 Nix 设计的，并且不会干扰 Arch 的软件包。因此，你可以在 Arch 上同时使用 Nix 和 Pacman（Arch 的包管理器），而不会出现任何冲突。

至于 Nix 的魔法，它主要在于它的功能和架构。Nix 的一个关键特性是它的声明式软件包管理方式。与其他包管理器不同，它不仅仅是将软件包安装到系统中，而是将它们安装到独立的环境中，这些环境可以保证软件包之间没有冲突，并且可以方便地进行版本控制和回滚。此外，Nix 还支持自动构建软件包，这意味着它可以自动下载源代码并构建软件包，以确保软件包的完整性和可重复性。

虽然 Nix 的软件源不像 Arch 的 AUR 那么丰富，但 Nix 仍然提供了一个不错的软件包集合。此外，Nix 还支持自定义软件包，这意味着你可以轻松地将任何软件包添加到你的 Nix 配置文件中，并使用 Nix 进行构建和安装。因此，尽管 Nix 的软件源可能没有 AUR 那么丰富，但你仍然可以使用 Nix 构建和安装你需要的任何软件包。

### docker
另外，你也可以考虑使用 Docker 或者其他容器技术来管理你的配置。  
使用 Docker 可以将你的应用程序及其依赖项打包在一起，并将其复制到其他设备上。这样就可以确保应用程序在不同设备上的运行环境是一致的。但是，使用 Docker 也需要一些学习和配置，特别是对于那些没有使用过容器技术的人来说。

总之，有很多方法可以管理你的 Linux 配置，你需要根据你的具体需求和技能水平来选择合适的方案。