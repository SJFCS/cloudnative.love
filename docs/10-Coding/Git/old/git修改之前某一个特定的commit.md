假如之前的某个提交的上一笔commit id是：928fc8a3686bf5fcf4527873e075703a9998c127
```
git log #查看commit id 找到上一笔commit id
git rebase 928fc8a3686bf5fcf4527873e075703a9998c127 --interactive
```
然后在vi中修改pick为edit，wq保存退出，接着进行内容修改，git add后git commit --amend
最后git rebase --continue即可再次回到最新的头部
