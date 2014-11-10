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

	ip link delete gretap$2 > /dev/null 2>&1 || true
	ip link add gretap$2 type gretap remote $1 key $2 \
		local `ip route get $1 | sed -n 's/.*src //p'`
		
	ip link set dev gretap$2 up

	echo GRE tunnel gretap$2 created with remote $1 key $2
}

if [ $# -eq 1 ] ; then
	setup_tunnel $1 1
	setup_tunnel $1 2
	setup_tunnel $1 3
elif [ $# -eq 3 ] ; then
	setup_tunnel $1 1
	setup_tunnel $2 2
	setup_tunnel $3 3
else
	echo "Usage: $0 GRE_PEER" >&2
	echo "Usage: $0 GRE_PEER_DOWNLINK GRE_PEER_UPLINK GRE_PEER_TAP" >&2
	exit 2
fi

