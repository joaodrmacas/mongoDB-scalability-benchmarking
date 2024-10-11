docker rm --force $(docker ps -aq)
docker volume rm $(docker volume ls -q)
