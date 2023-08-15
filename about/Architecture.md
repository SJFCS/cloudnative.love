---
title: 关于本站
sidebar_position: 0
slug: /
---
## 本站技术栈

- 构建工具迭代记录： hexo --> hugo  --> docusaurus 
- 托管服务商迭代记录： GitHub Pages --> Vercel + Cloudflare CDN + Cloudflare Zero Trust
- Domain 托管商迭代记录：GoDaddy --> Cloudflare
- 集成 [umami](https://umami.is/) 统计访客记录，利用 [supabase](https://supabase.com/) 免费的 postgresql 作为数据库
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
  - 添加 [react-tagcloud](https://www.npmjs.com/package/react-tagcloud) 标签替换原生标签，原生标签按首字分类不适合中文
- 轮播展示
  - 添加首页 [swiper](https://www.npmjs.com/package/swiper) 轮播
- 图片缩放
  - 移动端证书展示页面的图片支持放大 [react-medium-image-zoom](https://www.npmjs.com/package/react-medium-image-zoom)
- 本地文字索引
  - 集成本地搜索功能 [docusaurus-search-local](https://github.com/easyops-cn/docusaurus-search-local)
