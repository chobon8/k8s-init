#!/bin/bash

cat >> /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
IPADDR=192.168.137.202
NETMASK=255.255.255.0
GATEWAY=192.168.137.1
DNS1=119.29.29.29
DNS2=8.8.8.8
EOF

sed -i 's/\BOOTPROTO="dhcp"/BOOTPROTO="static"/' /etc/sysconfig/network-scripts/ifcfg-eth0