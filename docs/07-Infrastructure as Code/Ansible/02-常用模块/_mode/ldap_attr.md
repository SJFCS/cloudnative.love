# ldap_attrs模块

- 本模块用于添加或删除LDAP属性值。
- 官方文档 [https://docs.ansible.com/ansible/latest/collections/community/general/ldap_attrs_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/ldap_attrs_module.html)
- 看官方示例，通过该模块配置LDAP属性也不是特别的方便。建议使用LDAP Admin图形化配置，如果需要批量导入用户数据，可以使用python第三方包python-ldap来编写导入脚本。
- LDAP Admin: [http://www.ldapadmin.org/index.html](http://www.ldapadmin.org/index.html)
- python-ldap: [https://pypi.org/project/python-ldap/](https://pypi.org/project/python-ldap/)
- python-ldap docs: [python-ldap Reference Documentation https://www.python-ldap.org/en/python-ldap-3.4.3/reference/index.html](https://www.python-ldap.org/en/python-ldap-3.4.3/reference/index.html)
- 设置ldap对象密码，请参考ldap_passwd模块 [https://docs.ansible.com/ansible/latest/collections/community/general/ldap_passwd_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/ldap_passwd_module.html)
- 添加或删除ldap实例对象，请参考ldap_entry模块[https://docs.ansible.com/ansible/latest/collections/community/general/ldap_entry_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/ldap_entry_module.html)，本模块只能判断实例对象是否存在，不能判断实例对象的某个属性是否存在，如果要判断实例对象的某个属性是否存在，需要使用`ldap_attrs`模块。

