```bash
#vi auto_push.sh

#!/bin/bash
docker images |awk '{print$1":"$2}'|sed -n '2,$p' > ./images_list.txt
cat images_list.txt | while read line
do
docker push  `echo "$line"`    
done
```