默认情况下，为了安全性，Kustomize 有些版本会限制只能加载和处理位于或者子目录下的文件。

在某些情况下，如自动化的环境或者 CI/CD 管道中，或者比如当你的 Kustomize 配置依赖于共享或全局的资源定义，而这些资源并不在 Kustomize 工作目录或其子目录下时。你可能需要加载位于 Kustomize 根目录之外的资源或补丁文件，这时就需使用 `--load-restrictor=LoadRestrictionsNone` 选项可以禁用这种加载限制，允许 Kustomize 加载文件系统上任何位置的文件。

kustomize edit set image foo/bar=foo/bar:$TAG_VERSION
kustomize edit add secret sl-demo-app --from-literal=db-password=12345
kustomize build github.com/kubernetes-sigs/kustomize/examples/multibases/dev/?ref=v1.0.6

kustomize build overlays/dev | kubectl apply -f -
kubectl apply -k overlays/dev
kustomize build --helm-command helm   --enable-helm base -o ./build/
kubectl kustomize ./


https://github.com/kubernetes-sigs/kustomize/issues/5250
