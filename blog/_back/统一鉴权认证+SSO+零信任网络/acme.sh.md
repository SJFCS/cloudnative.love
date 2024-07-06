可能当前版本的acme默认是ZeroSSL
别看网站上面签发泛域名证书要花钱，如果您通过ZeroSSL官网在线申请SSL证书,免费账户是有3个域的额度限制的，但通过acme.sh申请则没有这个限制，所以建议使用acme.sh进行申请，简单方便。




acme.sh --set-default-ca  --server zerossl

设置 cloudflare API key
export CF_Key="cloudflare 中查看你的 Global API Key" 
export CF_Email="你的 cloudflare 邮箱"



acme.sh  --register-account  -m myemail@example.com --server zerossl
acme.sh --dns dns_huaweicloud --issue -d domain.com -d *.domain.com

复制证书
acme.sh  --installcert  -d  damain.com   \
        --key-file   /home/ssl/key.pem \
        --fullchain-file /home/ssl/cert.pem