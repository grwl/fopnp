#!/bin/sh -x

#
# This script needs to be launched on MITM bridge,
# to to connect to downlink, uplink, and tap.
#
# Given arguments "1.2.3.4 5.6.7.8 9.10.11.12",
# creates three GRE tunnels to these 3 hosts (downlink, uplink, tap)
#

setup_tunnel() {
	#
	# Given arguments "1.2.3.4 1",
	# creates GRE tunnel to 1.2.3.4 with key 1
	#

	ip link delete gretap$2 || true
	ip link add gretap$2 type gretap \
		local `ip route get $1 | sed -n 's/.*src //p'`
		remote $1 key $2 \
		
	ip link set dev gretap$2 up

	echo GRE tunnel gretap$2 created with remote $1 key $2
done

setup_tunnel $1 1
setup_tunnel $2 2
setup_tunnel $3 3

if true ; then
	brctl addbr br0 || true
	brctl setfd br0 0
	brctl stp br0 off
	ifconfig br0 up

	for key in 1 2 ; do
		brctl addif br0 gretap$key
		echo Added GRE tunnel gretap$key into br0
	done
fi

