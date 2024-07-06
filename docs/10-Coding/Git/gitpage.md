可以把域名解析到GitHub Pages，然后用GitHub Pages跳转到你的云服务器。（或者其他静态网页托管平台应该也行）

只需要在你GitHub Pages的index.html里写一个`meta：<meta http-equiv="refresh" content="0;url= IP_Address"> "IP_Address"`

填你的云服务器ip(+端口)，这样就可以跳转到你的服务器



- 这是一个HTML元标签（meta）用于实现页面自动跳转到另一个URL。其中，http-equiv属性的值为"refresh"，表示使用刷新这种方式实现跳转；content属性的值用来指定跳转的延迟时间（以秒为单位），这里的值是0，意味着立即跳转。url参数用于指定跳转的目标URL，将IP_Address替换为实际的IP地址或网址。

例如：
```
<meta http-equiv="refresh" content="0;url=http://www.example.com">
```
这个元标签表示浏览器将立即从当前页面跳转到"http://www.example.com"这个网址。




- 这是一个使用JavaScript实现页面跳转的示例。该脚本通过设置window.location.href属性实现页面跳转。
```
<script type="text/javascript">window.location.href="https://ihtcboy.com";</script>
```
当浏览器解析到这一段脚本时，它会执行JavaScript代码，并立即将用户导航到"https://ihtcboy.com"这个网址。


前者是使用HTML中的`<meta>`标签实现跳转，这种方式比较简单、直接。
JavaScript方式是通过编写脚本来实现跳转。这种方式更灵活，允许你在特定条件下触发跳转或者实现更复杂的跳转逻辑。



那么在 Repo 下建立一个 404.html，这样是不是就可以拿到访问文章的链接，然后就你所欲为！（拿旧域名替换成新域名就可以啦！）马上就开始行动吧！

404.html 文件，内容为：

```
<script src="http://cdn.bootcss.com/purl/2.3.1/purl.min.js"></script>

<script>
var url = purl();
if (url.attr('host') == 'ihtc.cc') {
    var old_url = url.attr('source');
    var new_url = old_url.replace('ihtc.cc', "ihtcboy.com");
    window.location.replace(new_url); 
}else if (url.attr('host') == 'www.ihtc.cc') {
    var old_url = url.attr('source');
    var new_url = old_url.replace('www.ihtc.cc', "ihtcboy.com");
    window.location.replace(new_url);
}else {
    window.location.href="https://ihtcboy.com";
}
    
</script>
```
从浏览器访问 www.ihtc.cc/xxx 或 ihtc.cc/xxx 的读者，都会被重定向到 ihtcboy.com!

https://github.com/HeTianCong/HeTianCong.github.io/tree/master

作者：iHTCboy
链接：https://www.jianshu.com/p/2c31cfb6c9b1
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。