---
title: 关于本站
sidebar_position: 0
---
:::tip 建站初衷

网络上技术资源很多，大多数时候我们也能从网上找到答案，但不可否认，资源太分散，而且绝大多数文章都是浅尝辄止，想找到一些优秀的、比较原理性的文章真的没那么容易。

所以，我希望在这里创作一些有价值的文章，并记录我的成长，希望本站能帮助到更多的小伙伴。

:::

:::caution 注意

本站所有技术内容均为个人观点，不保证正确，另外随着时间变化部分技术内容也可能会失效，请读者自行甄别。

另外本站使用的许多配图多来源于网络，如有侵权，请联系我删除。

:::

## 本站技术栈

- 构建工具迭代记录： hexo --> hugo  --> docusaurus 
- 托管服务商迭代记录： Github Pages --> Vercel + cloudflare
- 集成 [umami](https://umami.is/) 统计访客记录，利用 [supabase](https://supabase.com/) 提供的 postgresql 作为后端存储
- 集成 [Google Analytics](https://analytics.google.com/) 数据统计服务
- 本站字体
  - 正文字体： [LXGW WenKai / 霞鹜文楷](https://github.com/lxgw/LxgwWenKai)
  - 代码块字体： [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)
  - 终端播放器字体： [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
- 终端录制
  - 集成 [AsciinemaPlayer](https://github.com/asciinema/asciinema-player) 并添加外部字体支持 [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation) 
- 评论系统
  - 集成 [giscus](https://giscus.app/) 添加了黑暗模式自适应使其可以跟随本站主题，doc 文档下方宽度自适应，自动适配不同尺寸设备
- 返回顶部按钮
  - 为 blog 添加返回顶部按钮
- 标签系统
  - 添加 [react-tagcloud](https://www.npmjs.com/package/react-tagcloud) 标签替换原生标签，原生标签按首字分类不适合中文。
- 轮播展示
  - 添加首页 [swiper](https://www.npmjs.com/package/swiper) 轮播
- 图片缩放
  - 移动端证书图片支持放大 [react-medium-image-zoom](https://www.npmjs.com/package/react-medium-image-zoom)
- 本地文字索引
  - 集成本地搜索功能 [docusaurus-search-local](https://github.com/easyops-cn/docusaurus-search-local)

```mdx-code-block
import DocCardList from '@theme/DocCardList';

<DocCardList />
```
<!-- 
## 本站标签分类

文件夹一般设置在三个层级以内，主要靠打标签的功能来实现跨边界的二度信息归类。

如果把文件夹分类想象成是纵轴的话，那么就可以把标签体系看成横轴。

以安全分类来举例:

- 有具体归属的放在各自中文件夹下面,打上安全标签 
  - k8s/安全
  - 容器/安全
  - linux/网络/安全

- 没有具体归属的则放在以tagC命名的文件夹下,打上安全标签和自身标签
  - 安全/Jumpserver
  - 安全/Metasploit 
名词解释缩写格式：子网广播转发 (Subnet Broadcast Forwarding，SBF)

react引入均放在文档开头

命令行尽量不带$和#，除非命令下方贴出返回结果。避免# 用sudo 代替


readme 可以不写一句话简介，文章要写
当用下面组件时 有用
import DocCardList from '@theme/DocCardList';

<DocCardList />



所有实验都要有vagrant或者dockerfile
-->

