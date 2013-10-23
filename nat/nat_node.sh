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
# There are 2 parts of the tool. This is for NAT_Node. #
#                                                      #
########################################################
"

gw=$(ifconfig eth0|awk -F"[: ]+" '/inet addr/{print $4}'|cut -c1-4).0.1
echo "Please input the alternative gateway ip:"
read -p "(Default gateway: $gw):" gw
if [ "$gw" = "" ]; then
	gw=$(ifconfig eth0|awk -F"[: ]+" '/inet addr/{print $4}'|cut -c1-4).0.1
fi

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo "We will change the gateway to $gw !"
echo ""
echo "Press any key to start..."
char=`get_char`
echo ""

os=$(head -n1 /etc/issue|cut -d\  -f1)
case $os in
	CentOS)
	sed -i "s/.*GATEWAY.*/GATEWAY=$gw/" /etc/sysconfig/network-scripts/ifcfg-eth0
	service network restart
	;;
	Ubuntu)
	sed -i "s/.*gateway.*/gateway $gw/" /etc/network/interfaces
	/etc/init.d/networking restart
	;;
	*)
	echo "The script does not apply to this operating system."
	;;
esac

printf "
########################################################
#                                                      #
# This is a Shell-Based tool of making LAN to Internet #
# throuth NAT.                                         #
# There are 2 parts of the tool. This is for NAT_Node. #
#                                                      #
########################################################
"

