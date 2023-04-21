---
title: Vault
tags: [Security,Vault]
---
# [Vault](https://github.com/hashicorp/vault)

Vault 是 hashicorp 推出的 secrets 管理、加密即服务与权限管理工具。它的功能简介如下：

secrets 管理：支持保存各种自定义信息、自动生成各类密钥，vault 自动生成的密钥还能自动轮转(rotate)
认证方式：支持接入各大云厂商的账号体系（比如阿里云RAM子账号体系）或者 LDAP 等进行身份验证，不需要创建额外的账号体系。
权限管理：通过 policy，可以设定非常细致的 ACL 权限。
密钥引擎：也支持接管各大云厂商的账号体系（比如阿里云RAM子账号体系），实现 API Key 的自动轮转。
支持接入 kubernetes rbac 认证体系，通过 serviceaccount+role 为每个 Pod 单独配置认证角色。
支持通过 sidecar/init-container 将 secrets 注入到 pod 中，或者通过 k8s operator 将 vault 数据同步到 k8s secrets 中

https://thiscute.world/posts/experience-of-vault/