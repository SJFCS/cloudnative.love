# paru 不会在内核更新之后自动重建包含内核模块的包
:::
原文地址：https://ttys3.dev/blog/paru-aur-helper-does-not-rebuild-kernel-module-package-after-kernel-upgraded
:::
`paru` 和 `yay` 一样，是一个 aur helper.

最近用 paru 安装一个叫 `ipt_ndpi` 的包，里面包含了 iptables 扩展和内核模块。

当前内核是从 5.12.10 升级到 5.12.11 的：

```
❯ uname -a
Linux wudeng 5.12.11-arch1-1 #1 SMP PREEMPT Wed, 16 Jun 2021 15:25:28 +0000 x86_64 GNU/Linux

❯ paru -V
paru v1.7.2 +git - libalpm v13.0.0
```

尝试重新安装：

```
🔴 1 ❯ paru -S ipt_ndpi
:: Resolving dependencies...
:: Calculating conflicts...
:: Calculating inner conflicts...

Aur (1) ipt_ndpi-1.2_3.2.0.2224.8a19d7e3-1

:: Proceed to review? [Y/n]: y

:: Downloading PKGBUILDs...
 PKGBUILDs up to date
:: Proceed with installation? [Y/n]: y
fetching devel info...
==> Making package: ipt_ndpi 1.2_3.5.0.3243.640643d9-1 (Fri 18 Jun 2021 11:27:46 PM CST)
==> Retrieving sources...
  -> Updating ipt_ndpi git repo...
Fetching origin
==> Validating source files with sha256sums...
    ipt_ndpi ... Skipped
==> Making package: ipt_ndpi 1.2_3.5.0.3243.640643d9-1 (Fri 18 Jun 2021 11:27:50 PM CST)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Updating ipt_ndpi git repo...
Fetching origin
==> Validating source files with sha256sums...
    ipt_ndpi ... Skipped
==> Removing existing $srcdir/ directory...
==> Extracting sources...
  -> Creating working copy of ipt_ndpi git repo...
Cloning into 'ipt_ndpi'...
done.
==> Starting prepare()...
Already on 'flow_info-3.2'
Your branch is up to date with 'origin/flow_info-3.2'.
autoreconf: export WARNINGS=
autoreconf: Entering directory '.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal --force -I m4
autoreconf: configure.ac: tracing
autoreconf: running: libtoolize --copy --force
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, '.'.
libtoolize: copying file './ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'm4'.
libtoolize: copying file 'm4/libtool.m4'
libtoolize: copying file 'm4/ltoptions.m4'
libtoolize: copying file 'm4/ltsugar.m4'
libtoolize: copying file 'm4/ltversion.m4'
libtoolize: copying file 'm4/lt~obsolete.m4'
autoreconf: configure.ac: not using Intltool
autoreconf: configure.ac: not using Gtkdoc
autoreconf: running: aclocal --force -I m4
autoreconf: running: /usr/bin/autoconf --force
configure.ac:41: warning: The macro `AC_PROG_CC_STDC' is obsolete.
configure.ac:41: You should run autoupdate.
./lib/autoconf/c.m4:1666: AC_PROG_CC_STDC is expanded from...
configure.ac:41: the top level
configure.ac:46: warning: The macro `AC_PROG_CC_STDC' is obsolete.
configure.ac:46: You should run autoupdate.
./lib/autoconf/c.m4:1666: AC_PROG_CC_STDC is expanded from...
configure.ac:46: the top level
configure.ac:49: warning: $as_echo is obsolete; use AS_ECHO(["message"]) instead
lib/m4sugar/m4sh.m4:692: _AS_IF_ELSE is expanded from...
lib/m4sugar/m4sh.m4:699: AS_IF is expanded from...
./lib/autoconf/general.m4:2249: AC_CACHE_VAL is expanded from...
./lib/autoconf/general.m4:2270: AC_CACHE_CHECK is expanded from...
m4/ax_pthread.m4:88: AX_PTHREAD is expanded from...
configure.ac:49: the top level
configure.ac:232: warning: The macro `AC_HAVE_HEADERS' is obsolete.
configure.ac:232: You should run autoupdate.
./lib/autoconf/oldnames.m4:35: AC_HAVE_HEADERS is expanded from...
configure.ac:232: the top level
autoreconf: running: /usr/bin/autoheader --force
autoreconf: running: automake --add-missing --copy --force-missing
configure.ac:34: installing './compile'
configure.ac:34: installing './config.guess'
configure.ac:34: installing './config.sub'
configure.ac:6: installing './install-sh'
configure.ac:6: installing './missing'
fuzz/Makefile.am: installing './depcomp'
parallel-tests: installing './test-driver'
autoreconf: './config.sub' is updated
autoreconf: './config.guess' is updated
autoreconf: Leaving directory '.'
./configure
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a race-free mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking how to print strings... printf
checking whether make supports the include directive... yes (GNU style)
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether the compiler supports GNU C... yes
checking whether gcc accepts -g... yes
checking for gcc option to enable C11 features... none needed
checking whether gcc understands -c and -o together... yes
checking dependency style of gcc... gcc3
checking for a sed that does not truncate output... /usr/bin/sed
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for fgrep... /usr/bin/grep -F
checking for ld used by gcc... /usr/bin/ld
checking if the linker (/usr/bin/ld) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
checking the name lister (/usr/bin/nm -B) interface... BSD nm
checking whether ln -s works... yes
checking the maximum length of command line arguments... 1572864
checking how to convert x86_64-pc-linux-gnu file names to x86_64-pc-linux-gnu format... func_convert_file_noop
checking how to convert x86_64-pc-linux-gnu file names to toolchain format... func_convert_file_noop
checking for /usr/bin/ld option to reload object files... -r
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for ar... ar
checking for archiver @FILE support... @
checking for strip... strip
checking for ranlib... ranlib
checking command to parse /usr/bin/nm -B output from gcc object... ok
checking for sysroot... no
checking for a working dd... /usr/bin/dd
checking how to truncate binary pipes... /usr/bin/dd bs=4096 count=1
checking for mt... no
checking if : is a manifest tool... no
checking for stdio.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for strings.h... yes
checking for sys/stat.h... yes
checking for sys/types.h... yes
checking for unistd.h... yes
checking for dlfcn.h... yes
checking for objdir... .libs
checking if gcc supports -fno-rtti -fno-exceptions... no
checking for gcc option to produce PIC... -fPIC -DPIC
checking if gcc PIC flag -fPIC -DPIC works... yes
checking if gcc static flag -static works... yes
checking if gcc supports -c -o file.o... yes
checking if gcc supports -c -o file.o... (cached) yes
checking whether the gcc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking whether -lc should be explicitly linked in... no
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... yes
checking for g++... g++
checking whether the compiler supports GNU C++... yes
checking whether g++ accepts -g... yes
checking for g++ option to enable C++11 features... none needed
checking dependency style of g++... gcc3
checking how to run the C preprocessor... gcc -E
checking whether gcc is Clang... no
checking whether pthreads work with -pthread... yes
checking for joinable pthread attribute... PTHREAD_CREATE_JOINABLE
checking whether more special flags are required for pthreads... no
checking for PTHREAD_PRIO_INHERIT... yes
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for JSONC... yes
checking for netinet/in.h... yes
checking for stdint.h... (cached) yes
checking for stdlib.h... (cached) yes
checking for string.h... (cached) yes
checking for unistd.h... (cached) yes
checking for json.h... yes
checking DPDK (used by ndpiReader)... no (missing /home/ttys3/DPDK)
checking for numa_available in -lnuma... yes
checking for pcap_open_live in -lpcap... yes
checking for pthread_setaffinity_np in -lpthread... yes
checking for gcry_cipher_checktag in -lgcrypt... yes
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating Makefile
config.status: creating example/Makefile
config.status: creating example/Makefile.dpdk
config.status: creating tests/Makefile
config.status: creating tests/unit/Makefile
config.status: creating tests/dga/Makefile
config.status: creating libndpi.pc
config.status: creating src/include/ndpi_define.h
config.status: creating src/lib/Makefile
config.status: creating python/Makefile
config.status: creating fuzz/Makefile
config.status: creating src/include/ndpi_api.h
config.status: creating tests/do.sh
config.status: creating tests/do_valgrind.sh
config.status: creating src/include/ndpi_config.h
config.status: executing depfiles commands
config.status: executing libtool commands
depbase=`echo ndpi_network_list_compile.o | sed 's|[^/]*$|.deps/&|;s|\.o$||'`;\
gcc -DHAVE_CONFIG_H -I. -I../../src/include  -I../../src/include/  -I../../src/lib/third_party/include/   -g -O2 -I/usr/include/json-c  -fPIC -DPIC -DNDPI_LIB_COMPILATION  -MT ndpi_network_list_compile.o -MD -MP -MF $depbase.Tpo -c -o ndpi_network_list_compile.o ndpi_network_list_compile.c &&\
mv -f $depbase.Tpo $depbase.Po
/bin/sh ../../libtool  --tag=CC   --mode=link gcc  -g -O2 -I/usr/include/json-c  -fPIC -DPIC -DNDPI_LIB_COMPILATION    -o ndpi_network_list_compile ndpi_network_list_compile.o  -lgcrypt  -ljson-c
libtool: link: gcc -g -O2 -I/usr/include/json-c -fPIC -DPIC -DNDPI_LIB_COMPILATION -o ndpi_network_list_compile ndpi_network_list_compile.o  -lgcrypt -ljson-c
./ndpi_network_list_compile -o ndpi_network_list.c.inc ndpi_network_list_amazon.yaml ndpi_network_list_std.yaml ndpi_network_list_tor.yaml ndpi_network_list_whatsapp.yaml
Warning: line  814: '209.148.214.135/21' is not network (NETFLIX)
==> Starting pkgver()...
gawk: cmd. line:1: warning: regexp escape sequence `\"' is not a known regexp operator
gawk: cmd. line:1: warning: regexp escape sequence `\"' is not a known regexp operator
==> Sources are ready.
ipt_ndpi-1.2_3.2.0.2224.8a19d7e3-1: parsing pkg list...
:: ipt_ndpi-1.2_3.2.0.2224.8a19d7e3-1 is up to date -- skipping build
loading packages...
warning: ipt_ndpi-1.2_3.5.0.3243.640643d9-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Package (1)  Old Version                New Version                Net Change

ipt_ndpi     1.2_3.5.0.3243.640643d9-1  1.2_3.5.0.3243.640643d9-1    0.00 MiB

Total Installed Size:  3.18 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n]
(1/1) checking keys in keyring                                  [###################################] 100%
(1/1) checking package integrity                                [###################################] 100%
(1/1) loading package files                                     [###################################] 100%
(1/1) checking for file conflicts                               [###################################] 100%
(1/1) checking available disk space                             [###################################] 100%
warning: could not get file information for usr/lib/modules/5.12.10-arch1-1/
warning: could not get file information for usr/lib/modules/5.12.10-arch1-1/extra/
warning: could not get file information for usr/lib/modules/5.12.10-arch1-1/extra/xt_ndpi.ko.gz
:: Processing package changes...
(1/1) reinstalling ipt_ndpi                                     [###################################] 100%
:: Running post-transaction hooks...
(1/3) Arming ConditionNeedsUpdate...
(2/3) Updating module dependencies...
(3/3) Refreshing PackageKit...
  ~ took 26s
```

可以发现包还是被安装到了 旧内核目录： `5.12.10-arch1-1`

```
  /usr/lib/modules 
❯ ll
drwxr-xr-x root root 4.0 KB Fri Jun 18 23:28:01 2021  5.12.10-arch1-1
drwxr-xr-x root root 4.0 KB Fri Jun 18 02:12:44 2021  5.12.11-arch1-1


  /usr/lib/modules 
❯ tree 5.12.10-arch1-1
5.12.10-arch1-1
└── extra
    └── xt_ndpi.ko.gz

1 directory, 1 file

❯ tree -L 1 5.12.11-arch1-1
5.12.11-arch1-1
├── build
├── extramodules
├── kernel
├── modules.alias
├── modules.alias.bin
├── modules.builtin
├── modules.builtin.alias.bin
├── modules.builtin.bin
├── modules.builtin.modinfo
├── modules.dep
├── modules.dep.bin
├── modules.devname
├── modules.order
├── modules.softdep
├── modules.symbols
├── modules.symbols.bin
├── pkgbase
└── vmlinuz

3 directories, 15 files
```

然后我仔细观察了下 paru 输出的信息，里面有关键的：

```
:: ipt_ndpi-1.2_3.2.0.2224.8a19d7e3-1 is up to date -- skipping build
loading packages...
warning: ipt_ndpi-1.2_3.5.0.3243.640643d9-1 is up to date -- reinstalling
```

然后我仔细观察了下这个 [PKGBUILD](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ipt_ndpi):

```
# Maintainer: Shalygin Konstantin <k0ste@k0ste.ru>
# Contributor: Shalygin Konstantin <k0ste@k0ste.ru>

pkgname='ipt_ndpi'
pkgver=1.2_3.2.0.2224.8a19d7e3
pkgrel=1
pkgdesc='nDPI as netfilter extension.'
arch=('any')
url='https://github.com/vel21ripn/nDPI'
license=('GPL')
depends=('iptables')
makedepends=('git')
source=("${pkgname}::git+${url}")
sha256sums=('SKIP')
# define '-lts' for linux-lts package
_linux_custom=""
_kernver="`pacman -Ql linux${_linux_custom} | awk '/(\/modules\/)([0-9.-])+-(.*)'${_linux_custom}'\/$/ {print $2}' | head -n1`"

pkgver() {
  cd "${srcdir}/${pkgname}"
  ndpi_version=`gawk 'match($0, /pr_info\("xt_ndpi\sv([0-9.]+)\sndpi\s%s\"$/, a) {print a[1]}' ndpi-netfilter/src/main.c`
  git_version=`gawk 'match($0, /^(#define)\s(NDPI_GIT_RELEASE)\s(\")([a-z0-9.-]+)(\")$/, a) {print a[4]}' src/include/ndpi_config.h | sed -e 's/-/./g'`
  echo -e "${ndpi_version}_${git_version}"
}

prepare() {
  cd "${srcdir}/${pkgname}"
  git checkout flow_info-3.2
  ./autogen.sh
  cd "src/lib"
  make ndpi_network_list.c.inc
}

build() {
  cd "${srcdir}/${pkgname}/ndpi-netfilter"
  make KERNEL_DIR="${_kernver}build"
}

check() {
  cd "${srcdir}/${pkgname}/ndpi-netfilter"
  gzip --best -c "src/xt_ndpi.ko" > "src/xt_ndpi.ko.gz"
}

package() {
  cd "${srcdir}/${pkgname}/ndpi-netfilter"
  install -Dm755 "ipt/libxt_ndpi.so" "${pkgdir}/usr/lib/xtables/libxt_ndpi.so"
  install -Dm644 "src/xt_ndpi.ko.gz" "${pkgdir}${_kernver}/extra/xt_ndpi.ko.gz"
  install -Dm644 "INSTALL" "${pkgdir}/usr/share/doc/${pkgname}/README"
}
```

原因出来了，这里面有：

```
_kernver="`pacman -Ql linux${_linux_custom} | awk '/(\/modules\/)([0-9.-])+-(.*)'${_linux_custom}'\/$/ {print $2}' | head -n1`"

install -Dm644 "src/xt_ndpi.ko.gz" "${pkgdir}${_kernver}/extra/xt_ndpi.ko.gz"
```

因此，在当时包构建的时候，它会取当前内核版本号，然后把 `xt_ndpi.ko.gz` install 到相应的目录， 由于 paru 并没有重建包，因此导致在新内核上安装到了错误的位置。

因此 rebuild 就可以解决问题。

```
paru -S --rebuild ipt_ndpi
```

___

有没有办法从程序上检测这种变动呢？ 我觉得完全是可以的。简单地 list 一下这个包里面的内容，如果找到了位于 `usr/lib/modules/` 下的文件，则说明这个包是有包含内核模块的，从目录名 `5.12.11-arch1-1` 里我们完全可以提取出内核版本是 `5.12.11`， 然后再与当前运行的内核版本匹配，如果不匹配，则 paru 可以自动重建包。

```
🔴 2 ❯ tar -tvlf ipt_ndpi-1.2_3.5.0.3243.640643d9-1-any.pkg.tar.zst
-rw-r--r-- root/root     45891 2021-06-18 23:39 .BUILDINFO
-rw-r--r-- root/root       587 2021-06-18 23:39 .MTREE
-rw-r--r-- root/root       339 2021-06-18 23:39 .PKGINFO
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/lib/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/lib/modules/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/lib/modules/5.12.11-arch1-1/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/lib/modules/5.12.11-arch1-1/extra/
-rw-r--r-- root/root   3289358 2021-06-18 23:39 usr/lib/modules/5.12.11-arch1-1/extra/xt_ndpi.ko.gz
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/lib/xtables/
-rwxr-xr-x root/root     31408 2021-06-18 23:39 usr/lib/xtables/libxt_ndpi.so
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/share/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/share/doc/
drwxr-xr-x root/root         0 2021-06-18 23:39 usr/share/doc/ipt_ndpi/
-rw-r--r-- root/root      9812 2021-06-18 23:39 usr/share/doc/ipt_ndpi/README
```

把这个解决方案向 paru 作者反馈了， 作者直接拒绝了。

可能作者觉得这不是 paru 要处理的问题，而是使用者应该处理的问题吧？

但是，人的记忆是不如电脑的，很多事情是容易忘记的。如果 paru 能自动识别需要重建不是更好？

虽然这个功能有点像“白名单”， 针对内核版本号检测了，那我是不是针对其它 lib 的版本号兼容性也要进行检测？ 我觉得不尽然，能处理内核版本号的问题，不是更好？为什么支持内核检测了就一定要支持其它lib?没有哪有这个规定啊。

所以，说白了就是，这个想法，跟作者的理念是不符合的。

开源的东西，很多时候都是这样吧。是作者意愿的一种表达。这就是为什么开源容易出现很多 fork, 因为，一言不合就 fork啊，你不愿意添加，那就我自己来干喽。

当然，我目前还没有闲到这种自己去维护另一个版本的 paru 的地步。因此，先这么着吧。说不定哪天有空了，我真的 fork 了。