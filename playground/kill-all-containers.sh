#!/bin/sh

if [ "$1" != "YES" ] ; then
	echo "Usage: $0 YES"
	exit 2
fi

# stop all containers
docker stop -t=0 `sudo docker ps -q`

# remove all container
#docker rm `sudo docker ps -aq`
#docker rmi `sudo docker images 

# remove interfaces created by launch.sh
ifaces="h1-eth1 h2-eth1 h3-eth1 h4-eth1 exampleCOM homeA homeB modemA-eth1 modemB-eth1 example-eth1 ftp-eth0 mail-eth0 www-eth0"
for i in $ifaces; do
	ip link delete $i
done

