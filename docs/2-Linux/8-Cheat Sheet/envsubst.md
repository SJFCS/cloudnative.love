envsubst < mysql.yaml | kubectl apply -f -

spec:
    containers:
    - name: mysql
        image: $REGISTRY_HOST/mysql:$IMAGE_MYSQL_VERSION
        imagePullPolicy: Always

