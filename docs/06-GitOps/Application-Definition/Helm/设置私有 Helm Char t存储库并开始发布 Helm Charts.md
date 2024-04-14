---
title: 设置私有 Helm Char t存储库并开始发布 Helm Charts！
---
https://artifacthub.io/packages/helm/cloudnative-love/
在这篇文章中，我将分享一个非常简单的方法来创建和发布一个掌舵图。

### 第一步

让我们创建一个超级简单的 GitHub Repo/Project：

![Helm Chart 存储库教程](https://assets-global.website-files.com/622642781cd7e96ac1f66807/62315557c3899da1f6aa2257_f31ed07e32fe72c9ab4fa5bb30be41422f9c966c.png)

### 第二步

现在，让我们创建一个名为**gh-pages**的分支。我已经在用户界面上，所以我现在不会克隆/签出。  

![gh-页面](https://assets-global.website-files.com/622642781cd7e96ac1f66807/623155591b5de40fc862a7b8_603ddfce0a31e18fb1d217ff34a3f7545834d129.png)

### 第三步

让我们按照[Chart 存储库指南](https://helm.sh/docs/topics/chart_repository/)来确保我们的存储库已准备好托管 Helm Chart 存储库。您需要确保您的 **gh-pages 分支** 设置为 GitHub Pages。单击您的存储库 **设置**，向下滚动到 **GitHub 页面** 部分，然后按如下所示进行设置：

![GitHub 页面](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555b0c506caf75642150_97dbe96d430da4a7d2a9cf9170fdca1b37a0f9a6_2_690x454.png)

### 第四步

现在，是时候按照 GitHub 操作指南赋予此存储库超能力了：[自动化 GitHub 页面图表的图表发布者操作](https://helm.sh/docs/howto/chart_releaser_action/)。

进入存储库
```bash
mkdir Chart && cd Chart
helm create example
helm package example
helm repo index .
# git checkout -b gh-pages 创建分支
```

在这样的设置中，您可以使用默认分支来存储图表代码，并使用 gh-pages 分支作为图表存储库
- [Helm | 用于自动化 GitHub 页面图表的图表发布器操作](https://helm.sh/docs/howto/chart_releaser_action/#github-actions-workflow)


### 第五步

现在是时候添加我们的图表源路径，将项目推向其起源，并祈祷最好的结果。我发现关于这部分的 Helm 文档有点差，这就是我写这篇文章的原因之一。

这是我们目前的状态：

![舵图](https://assets-global.website-files.com/622642781cd7e96ac1f66807/623155591937249a6ad98f59_102e75315ba8834f85d9361c5b1048504bd5d117.png)

让我们创建一个路径来托管我的非常简单和虚拟的 NGINX Helm Chart 源，然后我将添加我拥有的非常漂亮的 Helm Chart：

mkdir 图表

![舵图](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555b5d2f5b9002bc4332_ee86ce6d0014a3036d2ead0349509bb666638d9c.png)

这是我通过遵循文档中的教程获得的 Helm 源。我没有改变任何东西。

让我们在 Chart.yaml 中添加一个随机版本，以确保它正常工作：

![Helm 图表版本](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555b1937245598d99040_e7e94c586ae10fc23367b9d45607894a8c84a879.png)

### 第六步

好的！是时候将其推向我们的原点了！

![推至原点](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555c1b5de4367362a7b9_cd0846db5d976e0c954e99f14dfac98e605264d0_2_690x401.png)

### 第七步

让我们确保这有效。

I’ll take a look at the GitHub Action tab. Looks solid to me:  
我将查看GitHub Action选项卡。看起来很坚固：

![GitHub 行动](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555d4e767757d4641b41_72355ccaebfcf86f08b6e22f9d4f54f754321fed_2_690x194.png)

I don’t believe in it. I’ll test it again; version #14 now!  
我不相信它。我再测试一次;现在是第14版！

![Helm 图表版本](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555c0bc311713fe6fc18_6acdc2a2a85e66243778a2efea73fd1be64a01e2.png)

![舵图](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555dc3899d435eaa2aad_720033158eee0ee0c453b8072237bf63384cc1ca_2_690x233.png)

It works! 真的有用！

![舵图](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555e1b5de410dd62a7ba_efa59523a7c7fa3f6afd299efe41f03e7ba5b506_2_690x381.png)

**Important:** you can also check that the Action is handling well our index.yaml, in the **gh-pages** branch. This file is super important to any HTTP Repo, right?  
重要提示：你也可以在gh-pages分支中检查Action是否处理好了index.yaml。这个文件对任何HTTP Repo都非常重要，对吗？

![GitHub 操作测试](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555ec3899d2304aa2bb9_f53e3c1c9a472a2fde05994648573e0f33d44be6_2_690x152.png)

You can check this out by reaching the same path in your Lab:  
您可以通过在实验室中访问相同的路径来检查这一点：  
[https://gabrielcerioni.github.io/harness-helm-charts/index.yaml](https://gabrielcerioni.github.io/harness-helm-charts/index.yaml)

![YAML](https://assets-global.website-files.com/622642781cd7e96ac1f66807/6231555e0bc3113378e6fdea_3e45e29631a854774513cd564456aec229469e28_2_690x310.png)






## 参考
- https://www.harness.io/blog/helm-chart-repo
- http://m.tnblog.net/hb/article/details/7945
- https://medium.com/@dunefro/show-helm-charts-on-artifacthub-via-hosting-on-github-pages-102ee1f98d35
## GitHub Actions
- https://github.com/marketplace/actions/helm-chart-releaser
- https://github.com/marketplace/actions/helm-chart-testing
- https://github.com/marketplace/actions/kind-cluster
- https://github.com/marketplace/actions/github-pages-overwriter