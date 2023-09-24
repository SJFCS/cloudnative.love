kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f argocd-ingress.yaml

# https://it.cha138.com/android/show-51590.html
# hNGfGFdYblnlwK3b
# kubectl -n argocd patch secret argocd-secret   -p '{"stringData": {
#       "admin.password": "$2a$10$88NHgAw3gSbPmMGvPH8wl.E.wh/JpxF6LpAkN.3YzI8vCKqz92rpi",
#       "admin.passwordMtime": "'$(date +%FT%T%Z)'"
#     }}'

# https://blog.horus-k.com/2020/12/04/argo-cd%E5%AE%89%E8%A3%85/
# https://www.digitalocean.com/community/tutorials/how-to-deploy-to-kubernetes-using-argo-cd-and-gitops
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo