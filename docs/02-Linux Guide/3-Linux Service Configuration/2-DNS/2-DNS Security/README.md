以下2种功能皆由Bind 9所提供的安全防护。TSIG提供DNS server间在做Zone Transfer及DNS更新(更新zone的设定…)时对其传输资料所做的加密签章，并能对其他DNS server做认证；”rndc” command提供使用者能远端控管DNS server，并对传输资料做加密，来提高DNS server的安全防护。

## TSIG

Transaction Signature(TSIG ; RFC 2845)是使用加密签章验证DNS讯息，特别是回应与更新。它是以MD5 hash加密签章(cryptographic signature)方式，以认证DNS server间资料传输。首先须于Primary master上自行产生加密签章，之后将此签章传递给Slave，经设定后由Slave以密码签章送往Primary master要求Zone Transfer。同时亦提供服务给加密签章签署过的动态更新要求。TSIG功能为确认DNS之资讯是由某特定DNS Server提供；并且大多数应用于DNS间之Zone Transfer，确保Slave与Primary DNS server复制资料不会由其它假的DNS server提供或被篡改截取。

### TSIG设定步骤
-   产生key值  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security002.jpg)  
    输入“ **dnssec-keygen -a hmac-md5 -b 128 -n HOST example** ”表示以”hmac-md5”演算法来产生share key，”128”表示所产生key的长度(bits)，最长可以产生512 bits 的key；而”example”表示当执行指令后所产生的2个档案分别名为”Kexample.+157+45717.key” 和”Kexample.+157+45717.private”，而key值就存放在Kexample.+157+45717.key档案中。  
    
-   设定两边DNS servers的/etc/named.conf (1)  
    如果产生的key值为: OQCfZ2DMmOrIkX8m5dqtRg==，则在双方电脑的named.conf档案中加入  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security003.jpg)  
    
-   设定两边DNS server的/etc/named.conf (2)  
    在双方电脑的named.conf档案中加入  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security004.jpg)  
    server后面接的是对方的IP address，若host1与host2为DNS server，则host1便在此设host2的IP address，反之亦同。  
    
-   在zone transfer部分  
    只要在named.conf档案中在zone后面加上”allow-transfer{ key example; };”，使得DNS server间在做zone transfer时可以利用TSIG的方式来传送资料。  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security005.jpg)  
    
-   在zone update的部分  
    只要在named.conf档案中对想要更新的zone后面加上”allow-update {key example; };”，使得我们在更新时可以利用TSIG的方式来传送资料。  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security006.jpg)  
    附带一提的是，由例子可以得知我们是使用与zone transfer时相同的key；即”example”，若要有所区隔，我们可以重新产生新的key值，而使用与zone transfer不同的key值来传送。(由”nsupdate” command来做zone update，”nsupdate” command的相关细节可由”man nsupdate”得知。)  
    
-   检查/var/log/messages  
    重新启动Bind后，检查messages档案是否有任何错误讯息。

## rndc

Bind 9之后提供新的功能为”rndc”(remote name daemon control)，不过可视为Bind旧版ndc的延伸，它可使系统管理者利用rndc command远端或本端(localhost)控制管理Bind，并以加密方式来传送资料，以防止其他非授权使用者控制Bind。

### rndc设定步骤(local端)
1.  产生/etc/rndc.key档案  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security007.jpg)  
    执行”rndc-confgen -a”指令后，会在/etc目录下产生rndc.key档案，而所产生的档案内容如下图所示:  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security008.jpg)  
    “algorithm hmac-md5”表示我们是使用”hmac-md5”演算法来产生”secret”每次执行都会产生不一样的”secret”  
    
2.  产生/etc/rndc.conf档案  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security009.jpg)  
    执行上图指令后会在/etc目录下产生rndc.conf档案，将档案中secret置换成rndc.key的secret。置换后的档案内容如下: ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security011.jpg)  
    
3.  修改/etc/named.conf  
    如rndc.conf档案后面的注解所示，在/etc/named.conf档案中加入  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security012.jpg)  
    
4.  检查/var/log/messages  
    重新启动Bind后，若在/var/log/messages中发现  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security014.jpg)  
    则表示设定成功。
5.  测试  
    即表示之后便可以在本机端利用”rndc”command来控制管理Bind。  
    例如:  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security015.jpg)  
    rndc后面接status参数可以展示出目前DNS server的相关讯息，可以接的参数可以由只输入”rndc”后面不加任何参数，执行后便会列出所有可以接的参数为何。  
    有关”rndc” command的用法可由”man rndc”查询得知。  
    

[![](http://dns-learning.twnic.net.tw/bind/security.html../images/up.gif)](http://dns-learning.twnic.net.tw/bind/security.html#top)

### rndc设定步骤(远端)

远端控制管理Bind的意思是在其他的电脑上能透过”rndc”command的方式来对远端的DNS server(Bind)做设定或是管理的动作，由于透过rndc的方式，所以能增加资料传送的安全性。

1.  在设定local端时，我们已产生rndc.key及rndc.conf，所以就继续沿用此2个档案。  
    
2.  修改/etc/named.conf  
    在named.conf档案中加入  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security016.jpg)  
    allow{ any; }表示允许任何电脑连线到此电脑，inet 后面则接DNS server IP address。  
    
3.  检查/var/log/messages  
    重新启动Bind后，若在/var/log/messages中发现  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security018.jpg)  
    即表示之后便可以在远端电脑利用”rndc”command来控制管理Bind。  
    
4.  设定远端电脑的rndc.key及rndc.conf  
    将远端电脑中的rndc.key及rndc.conf档案中的secret设成与欲控制的DNS server中rndc.key之secret相同，如此才能控制远端DNS server。  
    
5.  测试  
    ![](http://dns-learning.twnic.net.tw/bind/security.htmlimages/security019.jpg)  
    rndc –s 后面接DNS server IP address(domain name亦可)。执行后可列出远端DNS server相关讯息。