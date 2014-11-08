#!/bin/sh

[ "$1" = "YES" ] || exit

# stop all containers
docker stop -t=0 `sudo docker ps -q`

# remove all container
docker rm `sudo docker ps -aq`

#docker rmi `sudo docker images 

