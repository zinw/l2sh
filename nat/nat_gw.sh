#!/bin/bash

ip_file=$1
if [[ -s $ip_file ]]; then
    iptables -F -t nat
	while read ip
	do
		iptables -t nat -A POSTROUTING -s $ip -j MASQUERADE
	done <$ip_file
else
	echo "no ip list file"
fi

forwarding_enabled=$(sysctl -a 2>/dev/null | grep -E '^net.ipv4.conf.all.forwarding' | awk -F'=' '{print $2}')

if [[ "$forwarding_enabled" -eq 0 ]]; then
    sysctl -w net.ipv4.conf.all.forwarding=1
    echo "please add 'sysctl -w net.ipv4.conf.all.forwarding=1' to /etc/rc.local or modify /etc/sysctl.conf."
fi
