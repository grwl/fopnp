#!/bin/sh -x

#
# Given arguments "5.6.7.8 0 1",
# creates two GRE tunnels to 5.6.7.8 with keys 0 and 1.
# Optionally merges them in the bridge.
#

remote=$1 ; shift

local=`ip route get $remote | sed -n 's/.*src //p'`

for key in $* ; do
	ip link delete gretap$key || true
	ip link add gretap$key type gretap local $local remote $remote key $key
	ip link set dev gretap$key up

	echo GRE tunnel gretap$key created with remote $remote key $key
done

if true ; then
	brctl addbr br0 || true
	brctl setfd br0 0
	brctl stp br0 off
	ifconfig br0 up

	for key in $* ; do
		brctl addif br0 gretap$key
		echo Added GRE tunnel gretap$key into br0
	done
fi

