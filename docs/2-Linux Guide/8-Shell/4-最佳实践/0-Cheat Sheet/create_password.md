# 创建随机密码

[[toc]]

以下命令都是创建16个字符的密码。





## 1. 使用SHA算法加密日期

```sh
$ date +%s |sha256sum |base64 |head -c 16;echo
ODliYjY3Y2ZmNTVj
$ date +%s |sha256sum |base64 |head -c 16;echo
N2Y0MmZlZDZkMjRk
```



## 2. 使用md5sum命令

```sh
$ date +%N |md5sum |head -c 16;echo
1c31a47b93857481
$ date +%N |md5sum |head -c 16;echo
5039a615151fa1a6
```



## 3. 使用tr命令


tr命令关键参数：
-  `-c`或`--complerment`：取代所有不属于第一字符集的字符；
- `-d`或`--delete`：删除所有属于第一字符集的字符。

```sh
# 生成数字密码
$ tr -dc 0-9 < /dev/urandom|head -c ${1:-16};echo
5658523653422550
$ tr -dc 0-9 < /dev/urandom|head -c ${1:-16};echo
7046679611033024

# 生成小写密码
$ tr -dc a-z < /dev/urandom|head -c ${1:-16};echo
dsqowqtniwqnbwag
$ tr -dc a-z < /dev/urandom|head -c ${1:-16};echo
otzflcchronltvjf

# 生成大写密码
$ tr -dc A-Z < /dev/urandom|head -c ${1:-16};echo
BROXRNFUUKNSBDVP
$ tr -dc A-Z < /dev/urandom|head -c ${1:-16};echo
UHOPQGVJIVQKYQVV

# 生成包含大小写和数字的密码
$ tr -dc A-Za-z1-9 < /dev/urandom|head -c ${1:-16};echo
BRlAlHrl7klJNXJG
$ tr -dc A-Za-z1-9 < /dev/urandom|head -c ${1:-16};echo
omHYH5Sbj2JIuMSm
```



## 4. 使用uuidgen命令

```sh
$ uuidgen |head -c 16;echo
b6e019be-95a0-44
$ uuidgen |head -c 16;echo
5a740b56-dfad-41
```



## 5. 使用openssl命令

```sh
$ openssl rand -base64 16|head -c 16;echo
kfzFd/lQR4kTwLyg
$ openssl rand -base64 16|head -c 16;echo
CQtfAYyCDTms1E0D
```



## 6. 使用strings命令

```sh
# 转换为人类可读的密码
$ strings /dev/urandom | tr -cd 'a-zA-Z0-9' |head -c 16;echo
CiSZwYq6Gess0QXu
$ strings /dev/urandom | tr -cd 'a-zA-Z0-9' |head -c 16;echo
SdYr1I7DiyaU4e3W
```



## 7. 使用dd命令

```sh
$ dd if=/dev/urandom bs=1 count=16 2>/dev/null|base64 -w 0|head -c 16;echo
VC5QOTuM+Kbr4LIx
$ dd if=/dev/urandom bs=1 count=16 2>/dev/null|base64 -w 0|head -c 16;echo
eXBTvjTU4WD/saoT
```



## 8. 使用第三方工具pwgen生成密码

```sh
$ pwgen --help
Usage: pwgen [ OPTIONS ] [ pw_length ] [ num_pw ]

Options supported by pwgen:
  -c or --capitalize
	Include at least one capital letter in the password
  -A or --no-capitalize
	Don't include capital letters in the password
  -n or --numerals
	Include at least one number in the password
  -0 or --no-numerals
	Don't include numbers in the password
  -y or --symbols
	Include at least one special symbol in the password
  -r <chars> or --remove-chars=<chars>
	Remove characters from the set of characters to generate passwords
  -s or --secure
	Generate completely random passwords
  -B or --ambiguous
	Don't include ambiguous characters in the password
  -h or --help
	Print a help message
  -H or --sha1=path/to/file[#seed]
	Use sha1 hash of given file as a (not so) random generator
  -C
	Print the generated passwords in columns
  -1
	Don't print the generated passwords in columns
  -v or --no-vowels
	Do not use any vowels so as to avoid accidental nasty words
$ pwgen
lahl5Ahk ahdong4G eeLooPo4 yi4oGhie queLaiX4 ak0Aete8 Je8nooMo Faifoo5o
eezo1Oog lo0ahR0e Geet0uto phe2Xak7 eiHuroo1 Cah1eini naiDi7Mi gieS9uQu
gaeVie2o ub6Auch4 ah9Oocek Lohph7oo We5eicie cohf0eeF Xai9beew ahf7miGi
Koh3see8 Ohji8sae Lung0ae0 Ha3pae4I Phes1sei Ailu4Kow keliJ2ag CohYiey7
ig0aWooj mu4ooKee AeZ8Een4 Aish8Thu ieVai1ei bou6Ahzo eiR4eido VeiCh4sh
puMie5ru Wohfain4 fieG5fai Di8Ohqu6 yai4iK5o hit4siGh siuw7aeY pafaiJu1
oquoY0he Enev2ach Iuhooza0 ooshee3B oQu5xaew quah1Shi Eesa9cae iaHie8ee
Eiv2oNgi uoLur7No Dier8gei vu2Peenu Peen6iey ohM4zeil iDo3dahc Peichoh3
meim6oBu phiebo2E te9eiTho us3Chu8x ut7Tie1j aGi8Ohb9 chee6Ohf aefoh3Oe
ohxae4Su en5Outh0 omooT3fo eeWie4Ju iFait0Ax ohWohvi0 Ing5Seiv gieJ2sha
Eish4ahV Shoocoh6 oKei0qui Keidan9r ki1niLee Aed7nae6 eih7Ahp6 uotaeX2a
Chaez1ee AiD9chie joogh8Oh rieShiu3 aech2Gah ohB3foow Vo4og8th fee6Dae1
Ob0Liedo Vo7pahQu ESh3aeza ooVie3he pouM7zoh jou4Aibi SaiMei2v Shohg8vu
Xaowoe0o johC5iu4 ooCh5aid ooquei3A el2Ohdoh OoL9Aiz4 Lut4oi3m udahG7oh
eeh1Keil ies3aKah Bee4taif ooL6auL5 OhTh1dee Na1ahle7 Voh6Aero Aipheeg7
iv0Pe0oY xah8Xoav sabeth0A bah6Eiw1 Lee6quu5 eiNg1iec Oozahl3V iDa7aphi
Gayai5th eifeeSh4 Noe7sooh Li3EiKie EBai7OhL xu7Ood8z Iex9pe1u cuPevij7
choo8gaJ Kush6tho cieMaem0 eeNae3we Oojoh9oo Yoh2upoh fie4ohNg Gohmae2i
meNahn5B aeth0Eik veinga9Y oohah7Oh uelaeF7x caeRePh4 Xook5ohm aeMah7ch
tae5uM0a iSieke2y kah4Lo4G Ohy0shah fahp8eeL thahPoo3 Eiko8boo oofiWoo5
$

# 产生16位的随机密码
$ pwgen -cns 16 1
aBath6gvdYSUaov0
$ pwgen -cns 16 1
Xn58hti2XX68UYgH
$ pwgen -cns 16 1
QYUQCyy2CJd4fPfE
```



## 9. 快速重置只读用户密码

示例:

```sh
[root@1e615690b378 ~]# newpassword=$(date|md5sum|head -c 16);echo -n "$newpassword"|passwd --stdin reader > /dev/null && echo -e "username: reader\npassword: $newpassword" || echo "[Error] password reset failed."
username: reader
password: a2ad3e777f3b3a27
[root@1e615690b378 ~]# newpassword=$(date|md5sum|head -c 16);echo -n "$newpassword"|passwd --stdin reader > /dev/null && echo -e "username: reader\npassword: $newpassword" || echo "[Error] password reset failed."
username: reader
password: db4c48808cbd4051
[root@1e615690b378 ~]# newpassword=$(date|md5sum|head -c 16);echo -n "$newpassword"|passwd --stdin reader > /dev/null && echo -e "username: reader\npassword: $newpassword" || echo "[Error] password reset failed."
username: reader
password: 5014519231e4e13f
[root@1e615690b378 ~]#
```

在`~/.bashrc`中设置快捷命令：

```sh
# 重置只读用户密码
alias resetreader='newpassword=$(date|md5sum|head -c 16);echo -n "$newpassword"|passwd --stdin reader > /dev/null && echo -e "username: reader\npassword: $newpassword" || echo "[Error] password reset failed."'
```

重新加载后，执行命令：

```sh
[root@1e615690b378 ~]# resetreader
username: reader
password: a8de7c374174f451
[root@1e615690b378 ~]# resetreader
username: reader
password: 19f26be82e9df2c7
[root@1e615690b378 ~]# resetreader
username: reader
password: 480e10834fc8fd30
```

以下计算破解包含26个小写字母+10个数字组成的16位随机密码，按每秒100万次运算，大概需要多久才能破解：

```sh
$ bc
bc 1.06
Copyright 1991-1994, 1997, 1998, 2000 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'.
(26+10)^16/(1000000*60*60*24*365)
252367488265
```

可以看到结果是一个非常大的数字，2523亿年。可以认为设置16位密码非常安全。
