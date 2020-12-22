centos 6

添加防火墙端口
添加192.168.0.122 tomcat 防火墙开放端口要添加22端口之后，防火墙是先允许后拒绝
vim /etc/sysconfig/iptables
/etc/init.d/iptables restart
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
添加192.168.0.103 tomcat 防火墙开放端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8090 -j ACCEPT
/etc/init.d/iptables restart
重启生效

iptables-save > /opt/FireWall_Bak/ipt_$(date +%Y%m%d).bak