---
title: LDAP
---

```
15.绑定到外部验证服务，配置autofs                                                                                                                          
1、系统host.domainX.example.com提供了一个LDAP验证服务。您的系统需要按照以下要  求绑定到这个服务 上：        
验证服务器的基本DN是：dc=domainX,dc=example,dc=com                                                                                 
账户信息和验证信息都是由LDAP提供的                                                                                                                       
连接需要使用证书进行加密，证书可以在下面的链接中下载：http://host.domainX.example.com/pub/domainX.crt    
（当正确完成配置后，用户ldapuserX应该能够登录到您的系统中，但是没有主目录。当您完成autofs的题目之后，才能 
生成主目录。用户ldapuserX的密码是password                                                                                               
解：yum install authconfig-gtk.x86_64 sssd krb5-workstation.x86_64  
                system-config-authentication                                                                                                                            
                                                                                                                                                   
                                                                                                
2、按照下述要求配置autofs用来自动挂载LDAP用户的主目录                                                                                       
host.domainX.example.com(172.16.X.250)通过NFS输出了/share目录到您的系统。这个文件系统包含了用户              
ldapuserX的主目录，并且已经预先配置好了                                                                                                   
ldapuserX的用户的主目录是host.domainX.example.com:/share/ldapuserX                                                                  
ldapuserX的主目录应该挂载到本地的/share/ldapuserX目录下                                                                                       
用户对其主目录必须是可写的                                                                                                                                    
ldapuserX用户的密码是password                                                                                                                         
                                                                                                                                                                                
解：yum install  autofs.x86_64                                                                                                               
systemctl     start     autofs                                                                                                              
systemctl     enable     autofs                                                                                                           
vim     /etc/auto.master                                                                                                                   
        /share/ldapuser10     /etc/auto.misc                                                                                    
vim     /etc/auto.misc                                                                                                                       
        *     -rw     host.domain10.example.com:/share/&                                                                 
systemctl     restart     autofs                                                                                                           
df -hT          验证                    
```