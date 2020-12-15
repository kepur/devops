#!/bin/bash
echo " 初始化安装请确保网络通畅DNS解析正常......" 
file2="/opt/GeoIP.tar.gz"
file4="/opt/nginx-1.13.6.tar.gz"
file5="/opt/ngx_cache_purge-2.3.tar.gz"
file6="openssl-1.0.2q.tar.gz"
if command -v wget >/dev/null 2>&1; then 
  echo 'exists wget' 
else 
  echo 'install wget' 
  yum install -y wget
fi
echo -e "请把下列安装包放到/opt目录下 \n$file1\n$file2\n$file3\n$file4\n$file5\n$file6 "
if [ -f "$file2" ];then
	echo "文件 $file2 存在 "
else
	echo "文件 $file2 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/GeoIP.tar.gz
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
	echo "文件 $file6 不存在将自动下载" && wget -P /opt/  http://linux-1254084810.file.myqcloud.com/openssl-1.0.2q.tar.gz
fi
yum update -y && yum install initscripts gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
cd /opt/
tar -zxvf openssl-1.0.2q.tar.gz
cd openssl-1.0.2q
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
mv /opt/*.gz /opt/openssl*/ /opt/ngx_cache_purge-2.3/ nginx-1.13.6/ /opt/soft
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
echo '''#user  nobody;
worker_processes  2;
error_log  logs/error.log  info;
pid        logs/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  logs/vc.geepacificinc.com.access.log  main;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;
    gzip  on;
    include /opt/nginx/conf/vhost/*.conf;
''' > /opt/nginx/conf/nginx.conf
mkdir -p /opt/nginx/conf/vhost/
mkdir -p /opt/nginx/conf/cert/
mkdir -p /opt/nginx/logs/vhost/
yum install -y ntp
sed -i '/^ZONE.*/d' /etc/sysconfig/clock && echo -e '''ZONE="Asia/Shanghai\nUTC=false"''' >> /etc/sysconfig/clock
\cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate -q 1.cn.pool.ntp.org
service ntpd restart
chkconfig --level 2345 nginx on
chkconfig --level 2345 env1 on
chkconfig --level 2345 env2 on
chkconfig --level 2345 ntpd on
echo "安装完成..............."
