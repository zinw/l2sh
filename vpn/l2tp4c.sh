#!/bin/bash

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear
printf "
####################################################
#                                                  #
# This is a Shell-Based tool of l2tp installation  #
# For CentOS 32bit and 64bit                       #
#                                                  #
####################################################
"

iprange="10.8.0"
echo "Please input IP-Range:"
read -p "(Default Range: 10.8.0):" iprange
if [ "$iprange" = "" ]; then
	iprange="10.8.0"
fi

mypsk="UCLOUD.cn"
echo "Please input PSK:"
read -p "(Default PSK: UCLOUD.cn):" mypsk
if [ "$mypsk" = "" ]; then
	mypsk="UCLOUD.cn"
fi

l2tp_username="ucloud"
echo "Please input L2TP username:"
read -p "(Default L2TP username: ucloud):" l2tp_username
if [ "$l2tp_username" = "" ]; then
        l2tp_username="ucloud"
fi

l2tp_password="ucloud.cn"
echo "Please input L2TP password:"
read -p "(Default L2TP password: ucloud.cn):" l2tp_password
if [ "$l2tp_password" = "" ]; then
        l2tp_password="ucloud.cn"
fi

clear
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
echo "Server Local IP:"
echo "$iprange.1"
echo ""
echo "Client Remote IP Range:"
echo "$iprange.10-$iprange.100"
echo ""
echo "L2TP username:"
echo "$l2tp_username"
echo ""
echo "L2TP password:"
echo "$l2tp_password"
echo ""
echo "PSK:"
echo "$mypsk"
echo ""
echo "Press any key to start..."
char=`get_char`
clear

yum -y update
yum -y upgrade
yum -y install ppp iptables libpcap-devel lsof openswan xl2tpd
cat >/etc/ipsec.conf<<EOF
version 2.0
 
config setup
    dumpdir=/var/run/pluto/
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v6:fd00::/8,%v6:fe80::/10
    oe=off
    protostack=netkey
 
conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT
 
conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=0.0.0.0
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF
cat >>/etc/ipsec.secrets<<EOF
0.0.0.0 %any: PSK "$mypsk"
EOF
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sysctl -p
for each in /proc/sys/net/ipv4/conf/*
do
echo 0 > $each/accept_redirects
echo 0 > $each/send_redirects
done
cat >/etc/xl2tpd/xl2tpd.conf<<EOF
[global]
listen-addr = 0.0.0.0
ipsec saref = yes
[lns default]
ip range = $iprange.10-$iprange.100
local ip = $iprange.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF
cat >/etc/ppp/options.xl2tpd<<EOF
require-mschap-v2
ms-dns  8.8.8.8
ms-dns  8.8.4.4
asyncmap 0
noccp
auth
crtscts
hide-password
idle 1800
mtu 1410
mru 1410
nodefaultroute
debug
modem
lock
proxyarp
connect-delay 5000
name l2tpd
lcp-echo-interval 30
lcp-echo-failure 4
EOF
cat >>/etc/ppp/chap-secrets<<EOF
$l2tp_username        l2tpd   $l2tp_password                *
EOF
cat >/opt/l2tpreset<<EOF
#!/bin/bash
 
for each in /proc/sys/net/ipv4/conf/*
do
echo 0 > $each/accept_redirects
echo 0 > $each/send_redirects
done
EOF
chmod +x /opt/l2tpreset
/opt/l2tpreset
cat >>/etc/rc.local<<EOF
/opt/l2tpreset
EOF
iptables -t nat -A POSTROUTING -s $iprange.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
service ipsec restart
service xl2tpd restart
service iptables restart
chkconfig ipsec on
chkconfig xl2tpd on
chkconfig iptables on
clear
ipsec verify
printf "
####################################################
#                                                  #
# This is a Shell-Based tool of l2tp installation  #
# For CentOS 32bit and 64bit                       #
#                                                  #
####################################################
if there are no [FAILED] above, then you can
connect to your L2TP VPN Server with the default
user/pass below:

username:$l2tp_username
password:$l2tp_password
PSK:$mypsk

"

