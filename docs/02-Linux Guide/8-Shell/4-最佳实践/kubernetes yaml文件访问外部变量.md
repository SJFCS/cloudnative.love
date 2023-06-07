1、在 shell脚本里 使用export为变量赋值

```bash
export REGISTRY_HOST=$1
export IMAGE_MYSQL_VERSION=$2
```

2、在yaml中编辑如下，红色部分就是变量引用了
```yaml
    spec:
      containers:
        - name: mysql
          image: $REGISTRY_HOST/mysql:$IMAGE_MYSQL_VERSION
          imagePullPolicy: Always
```
3、启动时使用如下命令
```bash
envsubst < mysql.yaml | kubectl apply -f -
```
还有其它的方式可以变相解决变量传输的问题，但是这些都比较麻烦，不推荐
1、使用 替换命令，比如sed，在create之前进行替换
2、使用cat eof 来动态生成yaml文件

https://stackoverflow.com/questions/56003777/how-to-pass-environment-variable-in-kubectl-deployment