将内网云主机的默认网关改到某台有外网的主机上. 可以使用以下两个脚本完成: [nat_gw.sh](https://raw.github.com/Zinway-Liu/l2sh/master/nat/nat_gw.sh), [nat_node.sh](https://raw.github.com/Zinway-Liu/l2sh/master/nat/nat_node.sh)
操作步骤如下:

# 做网关的云主机上
1. 将nat_gw.sh下载到云主机，并加执行权限
2. 执行nat_gw.sh，根据脚本提示进行相应操作
3. 将nat_node.sh下载到云主机，然后将nat_node.sh上传到只有内网的云主机上去

# 只有内网的云主机上
1. 找到上传过来的nat_node.sh文件，并加执行权限
2. 执行nat_node.sh，根据脚本提示输入做网关的云主机的内网IP
3. 测试该主机与Internet的连通性

