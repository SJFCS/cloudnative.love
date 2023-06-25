以下2种功能皆由Bind 9所提供的安全防护。TSIG提供DNS server间在做Zone Transfer及DNS更新(更新zone的设定…)时对其传输资料所做的加密签章，并能对其他DNS server做认证；”rndc” command提供使用者能远端控管DNS server，并对传输资料做加密，来提高DNS server的安全防护。

http://dns-learning.twnic.net.tw/bind/security.html