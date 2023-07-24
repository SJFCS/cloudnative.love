可以把域名解析到GitHub Pages，然后用GitHub Pages跳转到你的云服务器。（或者其他静态网页托管平台应该也行）

只需要在你GitHub Pages的index.html里写一个`meta：<meta http-equiv="refresh" content="0;url= IP_Address"> "IP_Address"`

填你的云服务器ip(+端口)，这样就可以跳转到你的服务器，绕过域名封锁。
