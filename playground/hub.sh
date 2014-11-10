#!/bin/sh -x

mitmbr=mitmbr0
A=gretap1
B=gretap2

tapbr=tapbr0
T=gretap3

aip=10.25.1.65
amac=36:68:a6:dc:62:ea

bip=10.25.1.1
bmac=06:75:d6:06:99:1d

tip=10.10.10.10
tmac=5a:ed:08:41:ab:eb

# Cleanup

arptables -F
#ebtables -t filter -F
iptables -t nat -F

ifconfig $mitmbr down
brctl delbr $mitmbr
ovs-vsctl del-br $tapbr

# fixme
ip link del veth0
ip link del veth1

# Create non-learning hub with 3 ports: A, B, and T

brctl addbr $mitmbr
brctl stp $mitmbr off
brctl setfd $mitmbr 0
echo 0 > /sys/class/net/mitmbr0/bridge/ageing_time 
brctl addif $mitmbr $A
brctl addif $mitmbr $B
brctl addif $mitmbr $T
ifconfig $mitmbr up

# No communication between A/B/T and the host

#ebtables -t filter -A INPUT -i $A -j DROP
#ebtables -t filter -A OUTPUT -o $A -j DROP
#ebtables -t filter -A INPUT -i $B -j DROP
#ebtables -t filter -A OUTPUT -o $B -j DROP
#ebtables -t filter -A INPUT -i $T -j DROP
#ebtables -t filter -A OUTPUT -o $T -j DROP

# ARP requests: from T will be forwarded by the bridge to both ports, masquarade them
#arptables -A FORWARD --opcode 1 --h-length 6 -i $T -o $A -j mangle --mangle-ip-s $bip --mangle-mac-s $bmac
#arptables -A FORWARD --opcode 1 --h-length 6 -i $T -o $B -j mangle --mangle-ip-s $aip --mangle-mac-s $amac
arptables -A FORWARD --opcode 1 --h-length 6 -i $T -o $A -j mangle --mangle-ip-s $bip
arptables -A FORWARD --opcode 1 --h-length 6 -i $T -o $B -j mangle --mangle-ip-s $aip

# ARP replies: unmasquarade
#arptables -A FORWARD --opcode 2 --h-length 6 -i $A -d $bip -o $T -j mangle --mangle-ip-d $tip --mangle-mac-d $tmac
#arptables -A FORWARD --opcode 2 --h-length 6 -i $B -d $aip -o $T -j mangle --mangle-ip-d $tip --mangle-mac-d $tmac
arptables -A FORWARD --opcode 2 --h-length 6 -i $A -d $bip -o $T -j mangle --mangle-ip-d $tip
arptables -A FORWARD --opcode 2 --h-length 6 -i $B -d $aip -o $T -j mangle --mangle-ip-d $tip
#STUPID ebtables -t nat -A POSTROUTING -p ARP --arp-opcode 2 -o $T --arp-ip-dst $tip --j dnat --to-destination $tmac

#iptables -t nat -A POSTROUTING -j LOG
iptables -t nat -A POSTROUTING -o $mitmbr -m physdev --physdev-in $T -j SNAT --to-source $aip
#iptables -t nat -A POSTROUTING -o $mitmbr -m physdev --physdev-in $T -d $aip -j SNAT --to-source $bip

# fixme
#ip link add type veth
#brctl addif $mitmbr veth0
#ovs-vsctl add-br $tapbr
#ovs-vsctl add-port $tapbr veth1
#ovs-vsctl add-port $tapbr $T
#ip link set dev veth0 up
#ip link set dev veth1 up
