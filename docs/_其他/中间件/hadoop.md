kerberos
hadoop ranger

下载
https://hadoop.apache.org/releases.html

```bash
wget --no-check-certificate  https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
```

添加hadoop用户并添加sudo权限

shell> useradd hadoop #添加用户hadoop 
shell> passwd hadoop #设置用户hadoop的密码 
shell> chmod u+w /etc/sudoers # 添加写权限
shell> vi /etc/sudoers

进入编辑模式，找到这一 行："root ALL=(ALL) ALL"在起下面添加"hadoop ALL=(ALL) ALL"，然后保存退出。

https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html

https://www.w3cschool.cn/hadoop/a86m1jyo.html

hadoop 简介 https://www.bmc.com/blogs/hadoop-cloud-native-kubernetes/



搜索引擎需要对抓取到的结果进行管理。当索引结果越来越多时，保证存储和查询速度，保证数万台服务器内容一致的难度越来越高。Google于03至06年左右公布了三篇论文，描述了GFS、BigTable、MapReduce三种技术以解决这些问题。由于Google并没有公布算法细节，因此由雅虎牵头，在06年左右建立了开源项目Hadoop，目的是根据Google的三篇论文，实现一个大规模的管理计算系统。但直到08年，Hadoop同Google公布的一些关键指标仍有几倍的差距。百度曾经由王选院士的一个博士带领，想基于Google论文独立实现(金字塔计划)一个自己的系统，但开发难度过大项目夭折，最终也转向了Hadoop。如今，Amazon、Facebook、Yahoo包括百度都在大规模应用Hadoop，而Google已经从2010年开始迁移到新的三驾马车Caffeine、Pregel、Dremel上了。单就搜索技术而言，Google不是领先百度，而是领先全世界。

2009-2012年，Google公布了世界上第一个全球化的数据库系统Spanner，这套系统将分布在全球各地的数据中心连接到一起，利用原子钟和GPS，打破了地理间隔，实现了全球规模具有一致性和实时性的数据库。在Google之前，很多人认为这种系统不可能做出来，但Google做到了[1]。

另外，除了搜索，Google在深度学习和机器人方面也是全球领先的，尤其是后者。


[1]  [Exclusive: Inside Google Spanner, the Largest Single Database on Earth](https://link.zhihu.com/?target=http%3A//www.wired.com/wiredenterprise/2012/11/google-spanner-time/all/)