将内网云主机的默认网关改到某台有外网的主机上（适用于CentOS和Ubuntu）。
操作步骤如下:

# 做网关的云主机上
1. wget -c http://static.ucloud.cn/nat/do_masquerade.sh -P /opt && chmod +x /opt/do_masquerade.sh
2. 在该主机的/etc/rc.local中, 添加/opt/do_masquerade.sh /opt/ip.list
   (其中ip.list每行填一个纯内网主机的IP)
3. /opt/do_masquerade.sh /opt/ip.list

# 无外网的内网服务器上
1. wget -c http://static.ucloud.cn/nat/enable_alternative_gw.sh -P /opt && chmod +x /opt/enable_alternative_gw.sh
2. /opt/enable_alternative_gw.sh $original_gw $GW_IP
   ($original_gw是原始的网关IP，$GW_IP是做网关的云主机的内网IP)
3. enable_alternative_gw.sh脚本只需要执行一次