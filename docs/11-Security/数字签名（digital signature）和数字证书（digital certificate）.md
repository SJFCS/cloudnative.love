---
title: 数字签名和数字证书
tags: [Security,Public Key Infrastructure]
---

加密方法可以分为两大类。一类是单钥加密（private key cryptography），还有一类叫做双钥加密（public key cryptography）。前者的加密和解密过程都用同一套密码，后者的加密和解密过程用的是两套密码。

:::tip
转载自 [What is a Digital Signature?](http://www.youdzone.com/signature.html)
:::

### 单钥加密

在单钥加密的情况下，密钥只有一把，所以密钥的保存变得很重要。一旦密钥泄漏，密码也就被破解。

### 双钥加密

在双钥加密的情况下，密钥有两把，一把是公开的公钥，还有一把是不公开的私钥。

**双钥加密的原理如下：**

1. 公钥和私钥是一一对应的关系，有一把公钥就必然有一把与之对应的、独一无二的私钥，反之亦成立。
2. 所有的（公钥, 私钥）对都是不同的。
3. 用公钥可以解开私钥加密的信息，反之亦成立。
4. 同时生成公钥和私钥应该相对比较容易，但是从公钥推算出私钥，应该是很困难或者是不可能的。

> + 部分加密算法通过密文和私钥可以推算出公钥，反之困难，所以私钥要保存好。
> + 在双钥体系中，公钥用来加密信息，私钥用来数字签名。
> + 目前，通用的单钥加密算法为DES（Data Encryption Standard），通用的双钥加密算法为RSA（ Rivest-Shamir-Adleman），都产生于上个世纪70年代。

#### 数字签名

信息传输的途中，我们的信息很有可能被第三方劫持篡改，所以我们需要保证信息的完整性，通用方法是使用散列算法如SHA1，MD5将传输内容hash一次获得hash值，即摘要。客户端使用服务端的公钥对摘要和信息内容进行加密，然后传输给服务端，服务端使用私钥进行解密获得原始内容和摘要值，这时服务端使用相同的hash算法对原始内容进行hash，然后与摘要值比对，如果一致，说明信息是完整的。

### 数字证书

因为任何人都可以生成自己的（公钥，私钥）对，所以为了防止有人散布伪造的公钥骗取信任，就需要一个可靠的第三方CA机构来生成经过认证的（公钥，私钥）对。

数字证书是由权威的CA（Certificate Authority）机构给服务端进行颁发，CA机构通过服务端提供的相关信息生成证书，证书内容包含了持有人的相关信息，服务器的公钥，签署者签名信息（数字签名）等，最重要的是公钥在数字证书中。

## 数字签名、数字证书 是什么。

1.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:36-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080901.png)

鲍勃有两把钥匙，一把是公钥，另一把是私钥。

2.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:37-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080902.png)

鲍勃把公钥送给他的朋友们----帕蒂、道格、苏珊----每人一把。

3.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:39-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080903.png)

苏珊要给鲍勃写一封保密的信。她写完后用鲍勃的公钥加密，就可以达到保密的效果。

4.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:41-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080904.png)

鲍勃收信后，用私钥解密，就看到了信件内容。这里要强调的是，只要鲍勃的私钥不泄露，这封信就是安全的，即使落在别人手里，也无法解密。

5.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:43-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080905.png)

鲍勃给苏珊回信，决定采用"数字签名"。他写完后先用Hash函数，生成信件的摘要（digest）。

6.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:44-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080906.png)

然后，鲍勃使用私钥，对这个摘要加密，生成"数字签名"（signature）。

7.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:46-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080907.png)

鲍勃将这个签名，附在信件下面，一起发给苏珊。

8.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:48:31-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080908.png)

苏珊收信后，取下数字签名，用鲍勃的公钥解密，得到信件的摘要。由此证明，这封信确实是鲍勃发出的。

9.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:47-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080909.png)

苏珊再对信件本身使用Hash函数，将得到的结果，与上一步得到的摘要进行对比。如果两者一致，就证明这封信未被修改过。

10.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:49-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080910.png)

复杂的情况出现了。道格想欺骗苏珊，他偷偷使用了苏珊的电脑，用自己的公钥换走了鲍勃的公钥。此时，苏珊实际拥有的是道格的公钥，但是还以为这是鲍勃的公钥。因此，道格就可以冒充鲍勃，用自己的私钥做成"数字签名"，写信给苏珊，让苏珊用假的鲍勃公钥进行解密。

11.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:51-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080911.png)

后来，苏珊感觉不对劲，发现自己无法确定公钥是否真的属于鲍勃。她想到了一个办法，要求鲍勃去找"证书中心"（certificate authority，简称CA），为公钥做认证。证书中心用自己的私钥，对鲍勃的公钥和一些相关信息一起加密，生成"数字证书"（Digital Certificate）。

12.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:53-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080912.png)

鲍勃拿到数字证书以后，就可以放心了。以后再给苏珊写信，只要在签名的同时，再附上数字证书就行了。

13.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:46:55-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080913.png)

苏珊收信后，用CA的公钥解开数字证书，就可以拿到鲍勃真实的公钥了，然后就能证明"数字签名"是否真的是鲍勃签的。

## "数字证书"实例：https协议。

15.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:48-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080915.png)

首先，客户端向服务器发出加密请求。

16.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:49-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080916.png)

服务器用自己的私钥加密网页以后，连同本身的数字证书，一起发送给客户端。

17.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:51-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080917.png)

客户端（浏览器）的"证书管理器"，有"受信任的根证书颁发机构"列表。客户端会根据这张列表，查看解开数字证书的公钥是否在列表之内。

18.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:53-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080918.png)

如果数字证书记载的网址，与你正在浏览的网址不一致，就说明这张证书可能被冒用，浏览器会发出警告。

19.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:55-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080919.jpg)

如果这张数字证书不是由受信任的机构颁发的，浏览器会发出另一种警告。

20.

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/image-fusice.oss-cn-hangzhou.aliyuncs.com/image/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89/2021.06.01-10:47:59-https-image-fusice.oss-cn-hangzhou.aliyuncs.com-image-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-2021.06.01-10-47-56-D-assets-%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D%EF%BC%88digital%20signature%EF%BC%89%E5%92%8C%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%EF%BC%88digital%20certificate%EF%BC%89-bg2011080920.png)

如果数字证书是可靠的，客户端就可以使用证书中的服务器公钥，对信息进行加密，然后与服务器交换加密信息。


## 扩展阅读
- [密码学笔记](http://www.ruanyifeng.com/blog/2006/12/notes_on_cryptography.html)
- [自签名证书和CA证书的区别和制作、使用](https://www.cnblogs.com/zhaobowen/p/13321578.html)
- [一文看懂HTTPS、证书机构（CA）、证书、数字签名、私钥、公钥](https://www.jianshu.com/p/29e0ba31fb8d)