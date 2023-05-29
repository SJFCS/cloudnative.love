https://issues.apache.org/jira/browse/FLINK-9953

47.96.8.102

http://47.97.196.119

nexus：Yizhou996

jenkins：arXvivY1cf9xUKF3naBr4p8H9oTeQ7w3

sonarqube：Yizhou996

jenkins api token: 11dfd81f57a9456a4b9e65502af47e7017

Sonarqube  token：

songer-sonar：02cb7d032d1779d0d280fe3218e09fea82f592a4

![image-20211121215601406](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:14:41-image-20211121215601406.png)

![image-20211121215622128](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:14:44-image-20211121215622128.png)

![image-20211121215910428](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:21-image-20211121215910428.png)

## jekins安装 （Docker）

[install in docker](https://www.jenkins.io/doc/book/installing/docker/#setup-wizard)

~~~
docker network create jenkins

docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
  
  
cat <<EOF>>
FROM jenkins/jenkins:lts-jdk11
USER root
RUN  sed -i s@/deb.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list; \
     sed -i s@/security.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list; \
     apt-get clean && apt-get update; \
     apt-get install -y lsb-release; \
     python3 -m pip install ansible==2.10.6 -i  https://pypi.tuna.tsinghua.edu.cn/simple/; \
     rm -rf /root/.cache/pip && apt-get clean
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.1 docker-workflow:1.26"
EOF


docker build -t myjenkins-blueocean:1.1 .

docker run \
  --name jenkins-blueocean \
  --rm \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:1.1 
  
  
  
  
  
  
  docker run \
  --name=jenkins \
  --hostname=b918df815347 \
  --user=jenkins \
  --env=DOCKER_HOST=tcp://docker:2376 \
  --env=DOCKER_CERT_PATH=/certs/client \
  --env=DOCKER_TLS_VERIFY=1 \
  --env=PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=LANG=C.UTF-8 \
  --env=JENKINS_HOME=/var/jenkins_home --env=JENKINS_SLAVE_AGENT_PORT=50000 \
  --env=REF=/usr/share/jenkins/ref --env=JENKINS_VERSION=2.303.3 \
  --env=JENKINS_UC=https://updates.jenkins.io \
  --env=JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental \
  --env=JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals \
  --env=COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log \
  --env=JAVA_HOME=/opt/java/openjdk \
  --volume=jenkins-data:/var/jenkins_home \
  --volume=jenkins-docker-certs:/certs/client:ro \
  --volume=/var/jenkins_home \
  --network=jenkins -p 50000:50000 -p 8080:8080 \
  --restart=no \
  --label='org.opencontainers.image.revision=0b797f0249ac92e78b77d3a161cdfe877a864728' \
  --label='org.opencontainers.image.source=https://github.com/jenkinsci/docker' \
  --label='org.opencontainers.image.version=2.303.3' --label='org.opencontainers.image.vendor=Jenkins project' \
  --label='org.opencontainers.image.licenses=MIT' --label='org.opencontainers.image.title=Official Jenkins Docker image' \
  --label='org.opencontainers.image.url=https://www.jenkins.io/' \
  --label='org.opencontainers.image.description=The Jenkins Continuous Integration and Delivery server' \
  --log-driver=journald --runtime=docker-runc \
  --detach=true jenkins/jenkins:lts-jdk11
~~~

 [Post-installation setup wizard](https://www.jenkins.io/doc/book/installing/docker/#setup-wizard)

~~~
docker exec jenkins-blueocean  cat /var/jenkins_home/secrets/initialAdminPassword
~~~

插件

~~~
Generic Webhook Trigger
~~~

Jira流水线配置

![image-20211122002241586](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:23:47-image-20211122002241586.png)

jira-devops-service  jira-devops-service

![image-20211122002304293](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:23:40-image-20211122002304293.png)

![image-20211122002312191](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:23:54-image-20211122002312191.png)

![image-20211122002337166](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:23:42-image-20211122002337166.png)

Jira流水线脚本

jira.jenkinsfile

~~~

~~~

![image-20211122002500216](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:25:02-image-20211122002500216.png)

![image-20211122003005339](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-00:30:10-image-20211122003005339.png)

![image-20211122003128432](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:45-image-20211122003128432.png)

![image-20211122003206176](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:48-image-20211122003206176.png)

![image-20211122012739637](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:50-image-20211122012739637.png)

![image-20211122012824945](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:54-image-20211122012824945.png)

![image-20211122012849690](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:15:58-image-20211122012849690.png)

gitlab.groovy

~~~

~~~

![image-20211122002705161](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:01-image-20211122002705161.png)

![image-20211122002720622](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:04-image-20211122002720622.png)

![image-20211122002818727](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:07-image-20211122002818727.png)

![image-20211122002838599](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:10-image-20211122002838599.png)

jira.groovy

~~~
~~~

![image-20211122002903282](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:13-image-20211122002903282.png)

## Jira配置

https://www.cnblogs.com/clsn/p/8093301.html

https://sjf.atlassian.net/plugins/servlet/webhooks

~~~
http://10.0.0.10:8080/generic-webhook-trigger/invoke?token=jira-devops-service&projectKey=${project.key}
~~~

![image-20211122003424307](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:17-image-20211122003424307.png)

## 注意



![image-20211122010916721](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:20-image-20211122010916721.png)

![image-20211122010954976](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/mana%20/2021.11.22-02:16:23-image-20211122010954976.png)