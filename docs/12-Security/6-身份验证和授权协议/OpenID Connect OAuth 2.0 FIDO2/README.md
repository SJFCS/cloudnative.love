# OpenID Connect和OAuth 2.0

https://editst.com/2022/canokey-guide/
https://blog.huggy.moe/posts/2022/1-canokey-pigeon/
https://phyng.com/2022/12/14/yubikey.html#fido-u2f-ssh
https://blog.cubercsl.site/post/canokey-unboxing/

Google的单点登录（SSO）系统不是基于Kerberos实现的。Google使用的是OpenID Connect（OIDC）和OAuth 2.0这两个协议来实现其单点登录系统。


OpenID Connect是一种基于OAuth 2.0协议的身份验证协议，它允许用户使用一个身份提供者（如Google）的身份验证来访问多个应用程序。OAuth 2.0是一种授权协议，用于授权第三方应用程序访问用户的资源。


Google的SSO系统使用OpenID Connect来验证用户的身份，并使用OAuth 2.0来授权用户访问受保护的资源。当用户登录到Google时，他们的身份验证信息会被OpenID Connect认证服务器验证，并生成一个访问令牌。该访问令牌可以用于访问用户在Google上存储的资源，以及其他使用Google身份验证的应用程序。


因此，Google的单点登录系统不是基于Kerberos实现的，而是基于OpenID Connect和OAuth 2.0实现的。




FIDO2 https://demo.mailcow.email/