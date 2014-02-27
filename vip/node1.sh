#!/bin/bash

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear
printf "
############################################################
#                                                          #
# This is a Shell-Based tool of setting vip in keepalived  #
# on UHost on CentOS 32bit/64bit                           #
#                                                          #
# @node1                                                   #
#                                                          #
############################################################
"

vip=""
echo "请输入弹性内网IP："
read -p "（请正确填写，默认为空，写错会出事的）：" vip
node1=""
echo "请输入服务器A(node1)的内网IP："
read -p "（请正确填写，默认为空，写错会出事的）：" node1
node2=""
echo "请输入服务器B(node2)的内网IP："
read -p "（请正确填写，默认为空，写错会出事的）：" node2

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
echo "弹性内网IP(vip)："
echo "$vip"
echo ""
echo "服务器A(node1)的内网IP："
echo "$node1"
echo ""
echo "服务器B(node2)的内网IP："
echo "$node2"
echo ""
echo "Press any key to start..."
char=`get_char`

yum install -y keepalived
ip link add gretap1 type gretap local $node1 remote $node2
ip link set dev gretap1 up
ip addr add dev gretap1 10.1.1.2/24
cat >>/etc/rc.local<<EOF
ip link add gretap1 type gretap local $node1 remote $node2
ip link set dev gretap1 up
ip addr add dev gretap1 10.1.1.2/24
EOF
cat >/etc/keepalived/keepalived.conf<<EOF
global_defs {
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER
    interface gretap1
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        $vip dev eth0
    }
}
EOF
service keepalived start

printf "
############################################################
#                                                          #
# This is a Shell-Based tool of setting vip in keepalived  #
# on UHost on CentOS 32bit/64bit                           #
#                                                          #
# @node1                                                   #
#                                                          #
############################################################
"

