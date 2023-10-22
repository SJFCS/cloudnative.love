# docker run --name mynginx \
# --mount type=bind source=/var/www,target=/usr/share/nginx/html,readonly \
# --mount type=bind,source=/var/nginx/conf,target=/etc/nginx/conf,readonly \
# -p 80:80 -d nginx


# docker run --name some-nginx \
# -v $PWD/some/content:/usr/share/nginx/html:ro \
# -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro 
# -p 80:80 -d nginx


#!/bin/bash
# PS3=''

echo "Welcome to Docker Compose Options"

options=("Start" "Stop" "Reload" "Exec" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Start")
            echo "Starting Docker Compose"
            docker-compose up -d
            ;;
        "Stop")
            echo "Stopping Docker Compose and Removing Volumes and Orphans"
            docker-compose down --volumes --remove-orphans
            ;;
        "Reload")
            echo "Reload Nginx Config"
            docker-compose exec web nginx -s reload
            ;;
        "Exec")
            echo "Exec Nginx Container"
            docker-compose exec web bash
            ;;            
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo "Goodbye!"