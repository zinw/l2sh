#!/bin/bash

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear
printf "
########################################################
#                                                      #
# This is a Shell-Based tool of making LAN to Internet #
# throuth NAT.                                         #
# There are 2 parts of the tool. This is for NAT_GW.   #
#                                                      #
########################################################
"

ip_file=/opt/ip.list
echo "Please input the path of the file,\nwhich is used to save the ip list of LAN:"
read -p "(Default ip_file: /opt/ip.list):" ip_file
if [ "$ip_file" = "" ]; then
	ip_file=/opt/ip.list
fi
touch $ip_file

END_CONDITION="0"
until [ "$END_CONDITION" = "0" ]
do
	node_ip=$(ifconfig eth0|awk -F"[: ]+" '/inet addr/{print $4}')
	echo "Please input a node ip, which is needed to do nat:"
	read -p "(like but not: $node_ip; "0" to quit):" node_ip
	if [ "$node_ip" = "" ]; then
		echo "The node_ip can not be empty!"
	else
		echo $node_ip >>$ip_file
	fi
done

if [[ -s $ip_file ]]; then
	service iptables start 2>/dev/null
	chkconfig iptables on
	iptables -F -t nat
	while read ip
	do
		iptables -t nat -A POSTROUTING -s $ip -j MASQUERADE
	done <$ip_file
else
	echo "no ip list file"
fi
sed -i 's/exit 0//g' /etc/rc.local
cat >>/etc/rc.local<<EOF
while read ip
do
	iptables -t nat -A POSTROUTING -s \$ip -j MASQUERADE
done <$ip_file
EOF

os=$(head -n1 /etc/issue|cut -d\  -f1)
forwarding_enabled=$(sysctl -a 2>/dev/null | grep -E '^net.ipv4.conf.all.forwarding' | awk -F'=' '{print $2}')
if [[ "$forwarding_enabled" -eq 0 ]]; then
	sed -i 's/.*net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
	sysctl -p
fi

printf "
########################################################
#                                                      #
# This is a Shell-Based tool of making LAN to Internet #
# throuth NAT.                                         #
# There are 2 parts of the tool. This is for NAT_GW.   #
#                                                      #
########################################################
The alternative gateway ip is "$(ifconfig eth0|awk -F"[: ]+" '/inet addr/{print $4}')".
"

