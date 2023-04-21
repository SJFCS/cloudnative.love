~~~



MtxTsjULsAyo66XE_UFq
https://www.jianshu.com/p/6d8bf392a683
http://www.54tianzhisheng.cn/2020/10/13/flink-history-server/
https://blog.csdn.net/shirukai/article/details/109452700
https://cloud.tencent.com/developer/news/451821
优化

数据库地址 pgm-bp1ec8v4i0856skj168190.pg.rds.aliyuncs.com 账号 sonar  密码 i6JcwtTS_A0
端口 5432

docker run -d  --name postgtrs10 \
-p 5432:5432 \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=123456 \
postgres:10

docker run -d --name sonarqube \
-p 9000:9000 --link postgtrs10 \
-e SONARQUBE_JDBC_CURL=jdbc:postgresql://postgres10:5432/sonar \
-e SONARQUBE_JDBC_USERNAME=sonar \
-e SONARQUBE_JDBC_PASSWORD=123456 \
sonarqube:8.9.1-community


======
docker run -d --name sonarqube \
-p 9000:9000 \
-e SONARQUBE_JDBC_CURL=jdbc:postgresql://pgm-bp1ec8v4i0856skj168190.pg.rds.aliyuncs.com:5432/sonar 
-e SONARQUBE_JDBC_USERNAME=sonar \
-e SONARQUBE_JDBC_PASSWORD=i6JcwtTS_A0 \
sonarqube:8.9.1-community

---

docker run -d --name sonarqube \
    -p 9000:9000 \
    -e SONAR_JDBC_URL=jdbc:postgresql://pgm-bp1ec8v4i0856skj168190.pg.rds.aliyuncs.com:5432/sonar  \
    -e SONAR_JDBC_USERNAME=sonar \
    -e SONAR_JDBC_PASSWORD=i6JcwtTS_A0 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
    sonarqube:8.9.1-community
    
    
======

SONARQUBE_URL=172.16.66.200:9000
myAuthenticationToken=0cff2ecbb2ee13f224b360e9a779b1dbb2be44eb
YOUR_REPO=/opt
docker run \
    --rm -it \
    -e SONAR_HOST_URL="http://${SONARQUBE_URL}" \
    -e SONAR_LOGIN="${myAuthenticationToken}" \
    -v "${YOUR_REPO}:/usr/src" \
    sonarsource/sonar-scanner-cli bash
~~~

![image-20211121004409053](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:31:44-image-20211121004409053.png)

## 插件

![image-20211121012629874](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:32:44-image-20211121012629874.png)

>**Chinese Pack**
>
>**Findbugs**
>
>```
>docker cp ./sonar-gitlab-plugin-4.1.0-SNAPSHOT.jar  sonar_sonarqube_1:/opt/sonarqube/extensions/plugins/
>```
>



https://github.com/zeyangli/sonarqube-community-branch-plugin

https://www.bilibili.com/video/BV11J411674t?p=40

https://www.bilibili.com/video/BV1gM4y1M73A?from=search&seid=6961530744296002811&spm_id_from=333.337.0.0

https://www.bilibili.com/video/BV1MK4y1t7Kn?from=search&seid=6961530744296002811&spm_id_from=333.337.0.0

![image-20211121014356293](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:52:48-image-20211121014356293.png)

![image-20211121014449978](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:52:51-image-20211121014449978.png)



![image-20211118234222868](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/typora-user-images/2021.11.21-01:32:48-image-20211118234222868.png)

![image-20211118234226418](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/typora-user-images/2021.11.21-01:32:47-image-20211118234226418.png)

## 扫描

~~~
      mvn clean verify -Dmaven.test.skip=true
      mvn -e -X --batch-mode sonar:sonar
        -Dsonar.host.url=http://172.16.66.200:9000
        -Dsonar.gitlab.commit_sha=$CI_COMMIT_SHA
        -Dsonar.gitlab.ref_name=$CI_COMMIT_REF_NAME
        -Dsonar.gitlab.project_id=$CI_PROJECT_ID
        -Dsonar.issuesReport.html.enable=true
        -Dsonar.analysis.mode=preview #设置后，sonar不创建项目，只做分析


mvn --batch-mode sonar:sonar \
    -Dsonar.host.url=http://192.168.1.139:9000 \
    -Dsonar.login=admin \
    -Dsonar.password=admin \
    -Dsonar.issuesReport.html.enable=true \
    -Dsonar.preview.excludePlugins=issueassign,scmstats

if [ $? -eq 0 ]; then
    echo "sonarqube code-analyze over."
fi
没有preview模式，会将结果直接上传sonarqube，我们可以到sonarqube页面查看结果了。

~~~



![image-20211119001611344](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:32:53-image-20211119001611344.png)

![image-20211119001819533](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:32:55-image-20211119001819533.png)

![image-20211119001109163](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:32:57-image-20211119001109163.png)

![image-20211119002655631](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:32:59-image-20211119002655631.png)

![image-20211119002513305](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:33:00-image-20211119002513305.png)

![image-20211118235842038](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:33:02-image-20211118235842038.png)

![image-20211119002040691](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/sonarqube/2021.11.21-01:33:05-image-20211119002040691.png)