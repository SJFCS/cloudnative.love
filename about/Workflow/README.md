---
title: Workflow
---

在这里我想整理和分享一些提升效率的工具和方法，包括不限于

- 佳软分享
- Rss 好站推荐
- Arch Linux 食用方法
- HomeLab 等折腾记录

## Linux

我使用 Arch Linux 作为主力已经有段时间了，尽管初期有着陡峭的学习曲线，但仍阻挡不了我对其的喜爱。这段时间使用下来 Linux 确实能 save my life ，在学习一些技术时 Linux 的环境能帮我节省很多时间。

Arch Linux 最大的特色就是其包管理机制，包直接来自上游，不改名不拆包，及时的滚动更新。官方源、社区源和AUR源可以覆盖常用的所有软件，在 Arch Linux 可以**非常轻松**地将所有一切全部通过包管理其来进行管理。

如果你用过 APT 系包管理器，你一定有过满世界找 PPA 源的经历，并且多数 PPA 并非官方维护质量令人担忧，有时找不到 PPA 源只能手动安装 .deb 包。如果你有这样的困扰可以切换到 Arch 系 Linux 这里有世界上最好的包管理！！

如果要我推荐 Linux Laptop 发行版的话，我会推荐一下几个：

- Pop!_OS/Ubuntu

    Ubuntu 对机器学习等支持做的比较好，网络上文档也很多,任何问题都比较容易解决

- Arch Linux/EndeavourOS/Garuda Linux
  
    如果有信心解决你所出现的任何问题的话，可以了考虑用 Arch 系的发行版，你会得到一个十分省心的包管理

- Fedora Workstation
  
    红帽的 rpm 的应用可以说少得可怜了，如果喜欢红帽系的可以考虑

- NixOS
  
    使用 Nix 语言提供了**声明式的包管理**，可以通过一个声明式文件定义系统的全部细节，实现系统完整可复现、版本快速切换等功能。

- 不要用 Manjaro ！！！

   - 1、它没有 Archive 源你无法回滚你的系统，
   - 2、延迟两周并不是在测试 Arch 包打包本身的质量，而是在测试他们拿来 Arch 的包和他们自己乱改的核心包之间的兼容性 
   - 3、意味着你要放弃 Arch Linux 最大的特色 AUR 源或者忍受其可能因不兼容而导致问题
   - 更多内容请查看这个文章 https://manjarno.snorlax.sh/

下面是我的主力配置

import AsciinemaPlayer from '@site/src/components/AsciinemaPlayer';

<AsciinemaPlayer
    src="/casts/neofetch.cast"
    poster="npt:0:5"
    preload={true}
    autoPlay={true}
    idleTimeLimit="2"
/>


终端我使用了[powerlevel10k](https://github.com/romkatv/powerlevel10k) 主题，字体为 [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation) ，当然也推荐 [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) 这款字体，zsh 框架我使用了 [grml-zsh-config](https://grml.org/zsh/)，如果你愿意也可以使用 Oh-My-Zsh

虽然 Arch Linux 的滚动更新较为激进容易出现问题，但好在官方提供了仓库快照 [archive源](https://archive.archlinux.org/)，如果发现问题你可以利用它将系统回滚到之前任意一天的状态。

为了避免滚挂 我使用了 BTRFS 文件系统，其快照功能十分好用，但每次都通过 Timeshift 手动创建十分麻烦，推荐安装 [timeshift-autosnap](https://gitlab.com/gobonja/timeshift-autosnap)  利用 Pacman hook 在包更新前自动使用 Timeshift 创建快照。

并且建议使用 [grub-btrfs](https://github.com/Antynea/grub-btrfs) 实现在 grub 引导界面启动到快照的能力。注意要挂载 /run/timeshift/backup 为固定目录，不然每次开机 timeshift 会创建随机数字目录来存放快照，这会让 grub 找不到快照位置。

这样你就获得了一个极其坚固的 Arch Linux 了，曾经我出滚挂过两次，但都是小问题修修补补也过来了，目前还没遇到非常严重的问题。

后续我打算将我的 Arch Linux 配置过程和遇到的一些问题详细记录下来希望能帮到一些小伙伴们。