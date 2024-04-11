https://cloud.tencent.com/developer/article/1768444

Argo CD每三分钟轮询一次Git存储库，以检测清单的变化。为了消除轮询带来的延迟，可以将API服务器配置为接收Webhook事件。Argo CD支持来自GitHub，GitLab，Bitbucket，Bitbucket Server和Gogs的Git Webhook通知，更多点击官网：https://argoproj.github.io/argo-cd/。
