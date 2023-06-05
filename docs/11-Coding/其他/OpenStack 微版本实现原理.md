从Python代码的实现及调用分支角度分析

在OpenStack Kilo 版本的Nova项目中，首次引入了 API Microversioning 的概念，随后各个项目遵循此设计，根据需求也引入了微版本功能。引入微版本主要目的就是让开发人员在修改API代码时能够向前兼容，而不是加入一个新的API扩展，同时也不影响用户的使用。针对同一个请求，通过在请求中指定API的版本，后台在处理请求时就能根据版本信息找到对应的具体动作。关于API Microversion 的使用，参考官网：[https://docs.openstack.org/magnum/pike/contributor/api-microversion.html](https://web.archive.org/web/20201031121347/https://docs.openstack.org/magnum/pike/contributor/api-microversion.html) ，本文主要介绍Microversion 的实现原理。

本文通过分析Manila项目(Pike)中创建share server 时根据版本号选择create()方法的原理，对Microversioning 的实现进行说明。首先先列出主要代码，并加以解释： manila/api/v2/shares.py

```python
class ShareController(shares.ShareMixin,
                      share_manage.ShareManageMixin,
                      share_unmanage.ShareUnmanageMixin,
                      wsgi.Controller,
                      wsgi.AdminActionsMixin):
      ...

      @wsgi.Controller.api_version("2.31")  
      def create(self, req, body):
          ...

      @wsgi.Controller.api_version("2.24", "2.30")  # noqa
       def create(self, req, body):  # pylint: disable=E0102
           ...

      @wsgi.Controller.api_version("2.0", "2.23")  # noqa
       def create(self, req, body):  # pylint: disable=E0102
           ...
      ...
```

manila/api/openstack/wsgi.py

```python
class Controller(object):
    ...
    def __getattribute__(self, key):
        ...
        def version_select(*args, **kwargs):
            ...
            func_list = self.versioned_methods[key]
            #遍历元素为类VersionedMethod实例的列表，找到与版本号匹配的处理方法
            for func in func_list: 
                if version_request.matches_versioned_method(func):
                    # Update the version_select wrapper function so
                    # other decorator attributes like wsgi.response
                    # are still respected.
                    functools.update_wrapper(version_select, func.func)
                    return func.func(self, *args, **kwargs)
           ...
    @classmethod
    def api_version(cls, min_ver, max_ver=None, experimental=False):
        ...
        def decorator(f):
            obj_min_ver = api_version.APIVersionRequest(min_ver)
            if max_ver:
                obj_max_ver = api_version.APIVersionRequest(max_ver)
            else:
                obj_max_ver = api_version.APIVersionRequest()
            # Add to list of versioned methods registered
            func_name = f.__name__
            '''
            生成VersionedMethod实例，将被装饰的函数名，函数本身、装饰器传进来的版  
            本区间参数保存在实例中，相当于将版本号和方法绑定起来。
            '''
            new_func = versioned_method.VersionedMethod(
                func_name, obj_min_ver, obj_max_ver, experimental, f)

            func_dict = getattr(cls, VER_METHOD_ATTR, {})
            if not func_dict:
                setattr(cls, VER_METHOD_ATTR, func_dict)

            func_list = func_dict.get(func_name, [])
            if not func_list:
                func_dict[func_name] = func_list    # 以方法名为key,func_list列表为值，建立词典。
            func_list.append(new_func)    # 将VersionedMethod实例保存在func_list中
            func_list.sort(reverse=True)
            return f
        return decorator
```

通过阅读上面代码，我们发现，选择不同的create() 方法主要是由create() 方法的装饰器 函数 api\_version() 实现的。api\_version() 函数的传进的参数将决定每个create() 适用的请求版本，即通过api\_version() 方法，实现了Microversion 的功能。

api\_version() 函数的运行原理理解如下：

需要明白的是，装饰器函数在服务启动加载代码至内存的时候就已经运行完成。在Python解释器在加载shares.py 模块的时候会依次为每一个create 方法分配一段内存空间，每加载一个create方法，装饰器函数 api\_version() 就会被执行一次。在api\_version()中 主要完成了：

1.  生成VersionedMethod 类的一个实例，返回赋值给 new\_func。在实例中， 保存了create 方法适用的版本区间( self.start\_version , self.end\_version , self.experimental )，create方法的名字 (self.name 字符串类型)，create 方法本身(self.func, function 类型)。
2.  将每一个VersionMethod 实例用一个列表 func\_list 保存起来，并且最后以函数名”create” 为key，function\_list 为value， 将列表保存在词典里。

func\_dict， func\_list 作为类属性，因此不会因为每次调用api\_version 而被覆盖。

当服务运行起来，响应具体的请求时，通过Controller 类中的version\_select 方法遍历func\_list 列表，匹配版本区间，找个一个合适的create 方法。

最后，用一个简单的例子来说明微版本实现的原理，相信读者会一目了然。代码如下：

```python
# -*- coding: utf-8 -*-

class VersionMethod(object):
    def __init__(self,version,f):
        self.version = version
        self.f = f 

class Controller(object):
    def __init__(self):
        pass

    def select_version(self,key,version):
        func_list = self.version_method[key]
        for func in func_list:
            if func.version == version:
               return func.f()
        print("Not find the proper method") 

    @classmethod   
    def api_version(cls,version):
        print("call api_version") # 通过打印信息，以便观察代码执行时间
        def decorator(f):
            func_name = f.__name__
            new_func = VersionMethod(version, f)
            func_dict = getattr(cls, "version_method", {})
            if not func_dict:
                setattr(cls, "version_method", func_dict)
            func_list = func_dict.get(func_name, [])
            if not func_list:
                func_dict[func_name] = func_list
            func_list.append(new_func)
            return f
        return decorator

@Controller.api_version(1)
def do():
    print("play game1")

@Controller.api_version(2)
def do():
    print("play game2")

'''
不用执行以下两句，也可以观察到api_version 中的print方法被执行，
说明在代码加载时，装饰器方法已被执行
'''
Controller().select_version("do", 1)
Controller().select_version("do", 3)
```