#!/bin/bash
 
if [[ $# -ne 2 ]]; then
        echo "./enable_alternative_gw_4centos.sh original_gw alternative_gw"
        exit 1
fi
 
original_gw=$1
gw=$2

if [ $(head -n1 /etc/issue|cut -d\  -f1) = "CentOS" ]; then
	sed -i "s/GATEWAY=$original_gw/GATEWAY=$gw/" /etc/sysconfig/network-scripts/ifcfg-eth0
	service network restart
elif [ $(head -n1 /etc/issue|cut -d\  -f1) = "Ubuntu" ]; then
	sed -i "s/gateway $original_gw/gateway $gw/" /etc/network/interfaces
	/etc/init.d/networking restart
else
	echo "The script does not apply to this operating system."
	exit 1
