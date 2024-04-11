---
title: Image Build
---


- Kaniko 
- [buildpacks](https://openfunction.dev/zh-cn/blog/2022/01/04/cloud-native-buildpacks-%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
- [buildkit](https://github.com/moby/buildkit)
- [Source-to-Image (S2I)](https://github.com/openshift/source-to-image)
- Jib 


在 Dockerfile 中使用 ARG 命令定义变量，例如：
```
   ARG MY_VAR=default_value
```
在构建命令中使用 --build-arg 选项传递变量值，例如：
```
   kaniko build --build-arg MY_VAR=new_value -t my_image .
```
这将会将 MY_VAR 变量的值设置为 "new_value"，并将该值传递到构建过程中。

https://buildkite.com/blog/docker-kaniko-buildpacks-building-containers-in-containers-on-k8s





## 容器镜像构建不可重复

因为各种各样的原因，对同一份源码多次打容器镜像，结果可能是不一致的。

比如：

1. 底层镜像更新了，比如 debian:buster 就永远是最新的小版本。
2. 构建环境变更了。比如多阶段构建的 sdk 镜像更新了，或者依赖库更新了。
3. 即使镜像构建环境完全一致，因为时间戳等原因，也会导致镜像 Hash 摘要不一样。

总之就是即使源码没有变化，多次构建出的镜像也不会一致。

如果要求比较严格，那生产环境只应该上线被测试过的镜像，也就是要求「镜像一致」！
可开发人员通常都以 Git 仓库为中心，大家更希望只要求「源码一致」。

如果只要求「源码一致」，整个 CI/CD 流程可以简化很多，开发测试环境和生产环境可以完全隔离，只需要交付源码。

而如果要求镜像一致，那测试通过的镜像必须被传递到生产环境，必须交付测试环境的镜像到生产环境，流程会更复杂。

这里的分歧，源自「容器镜像构建不可重复」这个问题。


[docker-save-and-docker-export](https://jingsam.github.io/2017/08/26/docker-save-and-docker-export.html)



https://github.com/raif-ahmed/ubi-vs-distroless-images

https://www.reddit.com/r/redhat/comments/s2jz7y/current_thoughts_on_ubi/

https://www.rookout.com/blog/developer-tooling-for-kubernetes-in-2021-part-4/

https://github.com/shipwright-io/build/blob/main/docs/buildstrategies.md

https://github.com/aws/containers-roadmap/issues/1409

![avatar](https://user-images.githubusercontent.com/67560/122096995-28265780-cddd-11eb-9b6a-abd497a584ea.png)


[OCI 镜像规范](https://opencontainers.org/)


# Dockerfiles 集锦
编写 Dockerfile 时，可以在 github 上先搜索一下相关的项目，参考（COPY）别人的 Dockerfile，避免无从下手的情况。

运维相关
- [jumpserver](https://github.com/jumpserver/Dockerfile)

CI/CD 相关
- [jenkins: docker-inbound-agent](https://github.com/jenkinsci/docker-inbound-agent)
- [docker-android-build-box](https://github.com/mingchen/docker-android-build-box)
- [docker-sonarqube](https://github.com/SonarSource/docker-sonarqube)


数据库相关
- [docker-redis](https://github.com/bitnami/bitnami-docker-redis)
- [docker-mysql](https://hub.docker.com/_/mysql/)


语言相关
- [python: miniconda3](https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile)
- [python: official](https://github.com/docker-library/python)
- [pypiserver - python](https://github.com/pypiserver/pypiserver)

- [dotnet-docker](https://github.com/dotnet/dotnet-docker)
- [baget - csharp](https://github.com/loic-sharma/BaGet)

- [golang](https://github.com/docker-library/golang)