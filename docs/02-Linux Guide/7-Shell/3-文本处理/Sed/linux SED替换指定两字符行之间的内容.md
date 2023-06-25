```bash
[root@localhost wzcs]# cat a
asf
<123>
defasf
fsdsas
<ds123>
</%123>
<^123>
dffa
<1234>
<a123>
</123>
dffadsfs
afdasffds
[root@localhost wzcs]# sed    '/^<123>$/,/^<\/123>$/{/^<123>$/b;/^<\/123>$/b;s/.*/www/}' a 
asf
<123>
www
www
www
www
www
www
www
www
</123>
dffadsfs
afdasffds
[root@localhost wzcs]# sed  -i  '/^<123>$/,/^<\/123>$/{/^<123>$/b;/^<\/123>$/b;s/.*/www/}' a 
[root@localhost wzcs]# cat a
asf
<123>
www
www
www
www
www
www
www
www
</123>
dffadsfs
afdasffds
```