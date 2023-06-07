```bash
[root@k8s-01 ~]# cat kubedel.sh
#!/bin/bash
# 获取要删除的 namespace 名称
NAMESPACE="$1"
# 如果没有传入参数，提示用户传入 namespace 名称
if [ -z "$NAMESPACE" ]
then
    echo "请传入要删除的 namespace 名称："
    read NAMESPACE
fi
# 提示用户 namespace 名称
echo "您将要删除的 namespace 名称是：$NAMESPACE"
# 使用 kubectl 命令获取 namespace 对应的 JSON 格式，再用 jq 工具修改 namespace 的 spec 属性，并将修改后的 JSON 数据保存到 temp.json 文件中
kubectl get namespace "$NAMESPACE" -o json | jq '.spec = {"finalizers":[]}' > temp.json
# 使用 curl 命令发送 PUT 请求，删除指定的 namespace
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json "127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize"
# 检查是否删除成功，输出成功或失败信息
if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1
then
    echo "删除 namespace 成功"
else
    echo "删除 namespace 失败"
fi
```