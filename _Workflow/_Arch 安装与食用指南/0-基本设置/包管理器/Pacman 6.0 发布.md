# Pacman 6.0 发布
更多 https://ttys3.dev/blog/paru-the-new-aur-helper
:::
原文：https://ttys3.dev/blog/pacman-6-0-released
:::
Published on

Friday, June 4, 2021

Authors

-   ![avatar](https://ttys3.dev/_next/image?url=%2Fstatic%2Fimages%2Favatar.png&w=96&q=75)
    
    Name
    
    ttyS3
    
    Twitter
    

最近升级到了 pacman 6.0 版本。主要的新功能是支持多线程下载了。

如果是从旧版本升级的，那么其实配置需要自己手动合并。简单来说就是添加一行

即可。

虽然将下载器配置成aria2 或 curl （新版本的curl 有多线程下载功能 -Z ) 也能实现多线程下载，但是终究还是不如官方直接支持香。

贴下我的完整配置 `/etc/pacman.conf` ：

```
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   = tree-sitter
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
Color
#NoProgressBar
CheckSpace
VerbosePkgLists
ParallelDownloads = 5

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

# NOTE: You must run `pacman-key --init` before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux
# packagers with `pacman-key --populate archlinux`.

#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#   - URLs will have $repo replaced by the name of the current repo
#   - URLs will have $arch replaced by the name of the architecture
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#

# The testing repositories are disabled by default. To enable, uncomment the
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.

#[testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

# If you want to run 32 bit applications on your x86_64 system,
# enable the multilib repositories as required here.

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

#[multilib]
#Include = /etc/pacman.d/mirrorlist

# An example of a custom package repository.  See the pacman manpage for
# tips on creating your own repositories.
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs

## 中国科学技术大学 (安徽合肥) (ipv4, ipv6, http, https)
[archlinuxcn]
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
```

对应的, aur helper 工具 `paru` 最近也升级到 v1.7.1 了。

`/etc/paru.conf` 配置：

```
#
# $PARU_CONF
# /etc/paru.conf
# ~/.config/paru/paru.conf
#
# See the paru.conf(5) manpage for options

#
# GENERAL OPTIONS
#
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always
#BottomUp
#RemoveMake
#SudoLoop
#UseAsk
#CombinedUpgrade
#CleanAfter
#UpgradeMenu
#NewsOnUpgrade

#LocalRepo
#Chroot
#MovePkgs

#
# Binary OPTIONS
#
[bin]
FileManager = vifm
#MFlags = --skippgpcheck
#Sudo = doas
```