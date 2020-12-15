#!/bin/bash
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s 

file1="/opt/apache-tomcat-7.0.68.tar.gz"
file2="/opt/GeoIP.tar.gz"
file3="/opt/jdk-8u151-linux-x64.tar.gz"
file4="/opt/nginx-1.13.6.tar.gz"
file5="/opt/ngx_cache_purge-2.3.tar.gz"
file6="/opt/openssl-1.1.0g.tar.gz"
echo -e "请把下列安装包放到/opt目录下 \n$file1\n$file2\n$file3\n$file4\n$file5\n$file6 " $$ sleep 2s
if [ -f "$file1" ];then
	echo "文件 $file1 存在"
else
	echo "文件 $file1 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/apache-tomcat-7.0.68.tar.gz
fi
if [ -f "$file2" ];then
	echo " 文件 $file2 存在 "
else
	echo "文件 $file2 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/GeoIP.tar.gz
fi
if [ -f "$file3" ];then
	echo "文件 $file3 存在"
else
	echo "文件 $file3 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/jdk-8u151-linux-x64.tar.gz
fi
if [ -f "$file4" ];then
	echo "文件 $file4 存在"
else
	echo "文件 $file4 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/nginx-1.13.6.tar.gz
fi
if [ -f "$file5" ];then
	echo "文件 $file5 存在"
else
	echo "文件 $file5 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/ngx_cache_purge-2.3.tar.gz
fi
if [ -f "$file6" ];then
	echo "文件 $file6 存在"
else 
	echo "文件 $file6 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/openssl-1.1.0g.tar.gz
fi
yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
cd /opt/
tar -zxvf openssl-1.1.0g.tar.gz
cd openssl-1.1.0g
mkdir -p /usr/local/openssl
./config --prefix=/usr/local/openssl
make && make install
\mv /usr/bin/openssl /usr/bin/openssl.old
\mv /usr/include/openssl/ /usr/include/openssl.old
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl/ /usr/include/openssl
echo "/usr/local/openssl/lib/">>/etc/ld.so.conf
ldconfig 
openssl version -a
cd /opt/
mkdir -p /opt/java
tar -zxvf apache-tomcat-7.0.68.tar.gz -C /opt/java
tar -zxvf jdk-8u151-linux-x64.tar.gz -C /opt/java
\cp -R /opt/java/apache-tomcat-7.0.68/ /opt/java/apache-tomcat-env2
echo '''
JAVA_HOME=/opt/java/jdk1.8.0_151
JRE_HOME=/opt/java/jdk1.8.0_151/jre
PATH=$JAVA_HOME/bin:$PATH:$JRE_HOME/bin
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
export JAVA_HOME JRE_HOME PATH CLASSPATH
export TOMCAT_HOME=/opt/Java/apache-tomcat-7.0.68
export CATALINA_HOME=/opt/Java/apache-tomcat-7.0.68
export CLASSPATH=$CLASSPATH:$CATALINA_HOME/common/lib
export CATALINA_BASE=/opt/Java/apache-tomcat-7.0.68
''' >> /etc/profile
chmod 777 /etc/profile
source /etc/profile
echo "java环境安装"
sleep 1s
java
sleep 1s
echo '''
#!/bin/bash
#
# tomcatd This shell script takes care of starting and stopping
# standalone tomcat
#
# chkconfig: 345 91 10
# description: tomcat service
# processname: tomcatd
# config file:
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] &&exit 0
prog=tomcatd
export JAVA_HOME=/opt/java/jdk1.8.0_151
export CATALINA_HOME=/opt/java/apache-tomcat-7.0.68

PATH=$PATH:$JAVA_HOME/bin
STARTUP=$CATALINA_HOME/bin/startup.sh
SHUTDOWN=$CATALINA_HOME/bin/shutdown.sh
if [ ! -f $CATALINA_HOME/bin/startup.sh ]
then
echo "CATALINA_HOME for tomcatd not available"
exit
fi
start() {
#Start daemons.
echo -n $"Startting tomcat service: "
daemon $STARTUP
RETVAL=$?
return $RETVAL
}
stop() {
#Stop daemons.
echo -n $"Stoping tomcat service: "
$SHUTDOWN
RETVAL=$?
return $RETVAL
}
# See how we were called.
case "$1" in
start)
start
;;
stop)
stop
;;
restart|reload)
stop
start
RETVAL=$?
;;
status)
status $prog
RETVAL=$?
;;
*)
echo$"Usage: $0 {start|stop|restart|status}"
exit 1
esac
exit $RETVAL
''' >> /etc/init.d/env1
chmod +x /etc/init.d/env1
cp /etc/init.d/env1 /etc/init.d/env2
sed -i "s/apache-tomcat-7.0.68/apache-tomcat-env2/g"  /etc/init.d/env2
chmod +x /etc/init.d/env2
sed -i "s/8005/8015/g" /opt/java/apache-tomcat-env2/conf/server.xml
sed -i "s/8080/8081/g" /opt/java/apache-tomcat-env2/conf/server.xml
sed -i "s/8009/8019/g" /opt/java/apache-tomcat-env2/conf/server.xml
mkdir -p /opt/nginx
useradd -s /sbin/nologin www 
tar -zxvf nginx-1.13.6.tar.gz
tar -zxvf GeoIP.tar.gz
tar -zxvf ngx_cache_purge-2.3.tar.gz
cd /opt/GeoIP-1.4.8
./configure
make && make install
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig
cd /opt/nginx-1.13.6/
sed -i 's/\.openssl\///g' /opt/nginx-1.13.6/auto/lib/openssl/conf
sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' /opt/nginx-1.13.6/auto/lib/openssl/conf
./configure --user=www --group=www --prefix=/opt/nginx --add-module=../ngx_cache_purge-2.3 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl  --with-http_geoip_module
make && make install
gzip -d GeoIP.dat.gz && mkdir /opt/Geoip && mv GeoIP.dat /Geoip
mkdir /opt/soft
mv /opt/*.gz /opt/openssl-1.1.0g/ /opt/ngx_cache_purge-2.3/ nginx-1.13.6/ /opt/soft
echo '''
#!/bin/sh 
# 
# nginx - this script starts and stops the nginx daemon 
# 
# chkconfig:   - 85 15 
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \ 
#               proxy and IMAP/POP3 proxy server 
# processname: nginx 
# config:      /etc/nginx/nginx.conf 
# config:      /etc/sysconfig/nginx 
# pidfile:     /var/run/nginx.pid 

# Source function library. 
. /etc/rc.d/init.d/functions 

# Source networking configuration. 
. /etc/sysconfig/network 

# Check that networking is up. 
[ "$NETWORKING" = "no" ] && exit 0 

nginx="/opt/nginx/sbin/nginx" 
prog=$(basename $nginx) 

NGINX_CONF_FILE="/opt/nginx/conf/nginx.conf" 

[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx 

lockfile=/var/lock/subsys/nginx 

start() { 
    [ -x $nginx ] || exit 5 
    [ -f $NGINX_CONF_FILE ] || exit 6 
    echo -n $"Starting $prog: " 
    daemon $nginx -c $NGINX_CONF_FILE 
    retval=$? 
    echo 
    [ $retval -eq 0 ] && touch $lockfile 
    return $retval 
} 

stop() { 
    echo -n $"Stopping $prog: " 
    killproc $prog -QUIT 
    retval=$? 
    echo 
    [ $retval -eq 0 ] && rm -f $lockfile 
    return $retval 
killall -9 nginx 
} 

restart() { 
    configtest || return $? 
    stop 
    sleep 1 
    start 
} 

reload() { 
    configtest || return $? 
    echo -n $"Reloading $prog: " 
    killproc $nginx -HUP 
RETVAL=$? 
    echo 
} 

force_reload() { 
    restart 
} 

configtest() { 
$nginx -t -c $NGINX_CONF_FILE 
} 

rh_status() { 
    status $prog 
} 

rh_status_q() { 
    rh_status >/dev/null 2>&1 
} 

case "$1" in 
    start) 
        rh_status_q && exit 0 
    $1 
        ;; 
    stop) 
        rh_status_q || exit 0 
        $1 
        ;; 
    restart|configtest) 
        $1 
        ;; 
    reload) 
        rh_status_q || exit 7 
        $1 
        ;; 
    force-reload) 
        force_reload 
        ;; 
    status) 
        rh_status 
        ;; 
    condrestart|try-restart) 
        rh_status_q || exit 0 
            ;; 
    *)    
      echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}" 
        exit 2 
esac
''' >> /etc/init.d/nginx
chmod +x /etc/init.d/nginx
echo '''
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#########################################################
###            ADD_SSH_IP   #####
-A INPUT -s 121.127.7.136/29 -m state --state NEW -m tcp -p tcp --dport 48456 -j ACCEPT
-A INPUT -s 180.232.70.66/29 -m state --state NEW -m tcp -p tcp --dport 48456 -j ACCEPT
-A INPUT -s 122.54.194.243 -m state --state NEW -m tcp -p tcp --dport 48456 -j ACCEPT
#########################################################
###            ADD_WebServer_Port      #####
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8081 -j ACCEPT
#################################################################
##            ADD_ACCESS_IP  ###
#Local_address
-A INPUT -d 224.0.0.0/8 -i eth0 -j ACCEPT
-A INPUT -i eth0 -d 224.0.0.0/8 -j ACCEPT
#ApiServer
-A INPUT -s 47.74.51.229 -j ACCEPT 
#PayServer
-A INPUT -s 47.74.50.175 -j ACCEPT
#############Bak_ApiPay_Sr############
-A INPUT -s 47.91.253.58 -j ACCEPT
#############PC_Web############
-A INPUT -s 13.231.134.62 -j ACCEPT
#############Mobile_Web
-A INPUT -s 54.95.103.54 -j ACCEPT
#############WebControl
-A INPUT -s 54.65.41.172 -j ACCEPT
#############DB_Center
-A INPUT -s 52.193.28.200 -j ACCEPT
#############Agent_Sr
-A INPUT -s 13.231.78.29 -j ACCEPT
#############PT_PClient
-A INPUT -s 13.115.143.112 -j ACCEPT
#################################################################
##            ADD_VPN_ACCESS_IP      ###
#################################################################
##         VPN_HK                ###
-A INPUT -s 119.28.221.227 -j ACCEPT
##         VPN_CD                ###
-A INPUT -s 118.24.98.12 -j ACCEPT
##         VPN_GZ                ###
-A INPUT -s 119.29.227.182 -j ACCEPT
##         VPN_BK                ###
-A INPUT -s 192.144.143.36 -j ACCEPT
##         VPN_SH                ###
-A INPUT -s 118.25.4.108 -j ACCEPT
##########################ICMP_ACCEPT############################
-A INPUT -s 180.232.70.64/29  -p icmp -j ACCEPT
-A INPUT -s 121.127.7.136/29  -p icmp -j ACCEPT
-A INPUT -s 122.54.194.243  -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j DROP
-A INPUT -p tcp -s 0.0.0.0/0  -j DROP
COMMIT
''' >/etc/sysconfig/iptables
sed -i '/^Port.*/d' /etc/ssh/sshd_config && echo "Port 48456" >> /etc/ssh/sshd_config
setenforce 0
service sshd restart
service iptables restart
sed -i '/^ZONE.*/d' /etc/sysconfig/clock && echo -e '''ZONE="Asia/Shanghai\nUTC=false"''' >> /etc/sysconfig/clock
\cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -q 1.cn.pool.ntp.org
service ntpd restart
chkconfig --level 2345 nginx on
chkconfig --level 2345 env1 on
chkconfig --level 2345 env2 on
chkconfig --level 2345 ntpd on
chkconfig --level 2345 iptables on
echo "安装完成..............."
sleep 1s
