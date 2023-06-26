keep owner ship

一起正确使用 mkdir -m -p 和 chown  https://stackoverflow.com/questions/25873479/using-mkdir-m-p-and-chown-together-correctly#new-answer


我已经厌倦了mkdir跟着chown，如果你想在创建过程中设置所有者，

install -d -m 0755 -o someuser -g somegroup /dir/dir2

sudo -uTHE_USER mkdir -p -m=00755 "/dir/dir2"
如果您想在没有写访问权限的THE_USER目录下创建一个拥有的目录，那将不起作用。THE_USER – 
