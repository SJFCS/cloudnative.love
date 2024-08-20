## Dependabot,RenovateBot,Snyk 


References 参考
- https://github.com/dependabot/dependabot-core
- https://docs.renovatebot.com/

- https://www.reddit.com/r/golang/comments/14km58c/dependabot_vs_renovatebot/
- https://www.jvt.me/posts/2024/04/12/use-renovate/
- https://news.ycombinator.com/item?id=40011111

Our team a job ago used both while I was there. There was not much difference between the two for our Go projects. However, I have and will continue to choose Renovate going forward.
当我在那里时，我们的团队以前工作时使用了这两种方法。对于我们的 Go 项目来说，两者没有太大区别。然而，我已经并将继续选择翻新。

Where it shines is the ability to group dependencies together. While this did not have much impact on our Go projects, our node / NestJS based projects benefited immensely. Out of the box, Renovate comes with a host of known frameworks (like NestJS), tool sets, etc. Dependabot would open legions of PRs for a Nest upgrade, most of which you had to merge together anyway. Renovate opened one PR to do the job. Saved us time and effort.
它的亮点是将依赖项分组在一起的能力。虽然这对我们的 Go 项目没有太大影响，但我们基于 Node/NestJS 的项目却受益匪浅。 Renovate 开箱即用，附带了许多已知的框架（如 NestJS）、工具集等。Dependabot 会打开大量 PR 以进行 Nest 升级，其中大部分无论如何都必须合并在一起。 Renovate 开设了一个 PR 来完成这项工作。节省了我们的时间和精力。

Renovate allows you to configure your own groups also. If you have Go updates you often upgrade at the same time, tell Renovate to bundle them together in one PR.
Renovate 还允许您配置自己的组。如果您经常同时升级 Go 更新，请告诉 Renovate 将它们捆绑在一个 PR 中。

This and other features have made it my go to (pun intended) dependency bot. I do still enable Dependabot for security notices on my repos, but those again are usually node / NestJS based to catch the odd cases of a dependency of a dependency of a dependency needing an upgrade.
这个功能和其他功能使其成为我选择（双关语）依赖机器人。我仍然在我的存储库上启用 Dependabot 来获取安全通知，但这些通常又是基于 Node/NestJS 的，以捕获需要升级的依赖项的依赖项的依赖项的奇怪情况。






Is there a reason why you not simply allow Renovate to read your Dependabot Alerts and let it do it? https://docs.renovatebot.com/configuration-options/#vulnerabilityalerts
您是否有理由不简单地允许 Renovate 读取您的 Dependabot 警报并让它执行此操作？ https://docs.renovatebot.com/configuration-options/#vulnerabilityalerts

Also it supports an alternative sources of CVEs with https://osv.dev
它还通过https://osv.dev支持 CVE 的替代来源