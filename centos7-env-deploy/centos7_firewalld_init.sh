#!/bin/bash
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s
geoip="GeoIP.tar.gz"
jdk="jdk-8u191-linux-x64.tar.gz"
nginx="nginx-1.15.8.tar.gz"
ngx="ngx_cache_purge-2.3.tar.gz"
openssl="openssl-1.0.2q.tar.gz"
redis="redis-4.0.6.tar.gz"
mysql="mysql57-community-release-el7-8.noarch.rpm"
geoipurl="http://linux-1254084810.file.myqcloud.com/GeoIP.tar.gz"
jdkurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/jdk-8u191-linux-x64.tar.gz"
nginxurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/nginx-1.15.8.tar.gz"
ngxurl="http://linux-1254084810.file.myqcloud.com/ngx_cache_purge-2.3.tar.gz"
mysqlurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
opensslurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/openssl-1.0.2q.tar.gz"
redisurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/redis-4.0.6.tar.gz"
echo -e "请把下列安装包放到/opt目录下 \n$geoip\n$jdk\n$nginx\n$ngx\n$openssl\n " $$ sleep 2s
if [ -f "/opt/$geoip" ];then
	echo " 文件 $geoip 存在 "
else
	echo "文件 $geoip 不存在将自动下载" && wget -P /opt/  $geoipurl
fi
if [ -f "/opt/$jdk" ];then
	echo "文件 $jdk 存在"
else
	echo "文件 $jdk 不存在将自动下载" && wget -P /opt/  $jdkurl
fi
if [ -f "/opt/$nginx" ];then
	echo "文件 $nginx 存在"
else
	echo "文件 $nginx 不存在将自动下载" && wget -P /opt/  $nginxurl
fi
if [ -f "/opt/$ngx" ];then
	echo "文件 $ngx 存在"
else
	echo "文件 $ngx 不存在将自动下载" && wget -P /opt/  $ngxurl
fi
if [ -f "/opt/$mysql" ];then
	echo "文件 $mysql 存在"
else 
	echo "文件 $mysql 不存在将自动下载" && wget -P /opt/  $mysqlurl
fi
if [ -f "/opt/$openssl" ];then
	echo "文件 $openssl 存在"
else 
	echo "文件 $openssl 不存在将自动下载" && wget -P /opt/  $opensslurl
fi

yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
cd /opt/
echo "正在执行openssl安装"
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
sleep 2s
cd /opt/
echo "正在执行mysql安装"
rpm -ivh mysql57-community-release-el7-8.noarch.rpm
yum -y install mysql-server
service mysqld restart
echo "请复制您的密码"
grep "password" /var/log/mysqld.log
sleep 2s
echo "正在执行redis安装"
sleep 1s
cd /opt/
tar -zxvf redis-4.0.6.tar.gz
cd redis-4.0.6\
make MALLOC=libc
cd \src
make install 
mkdir -p /etc/redis
cp /opt/redis-4.0.6/redis.conf /etc/redis/6379.conf
cp /opt/redis-4.0.6/utils/redis_init_script /etc/init.d/redisd
sed -i '2i\
# chkconfig:   2345 90 10
# description:  Redis is a persistent key-value database' /etc/init.d/redisd
echo '''
[Unit]
Description=The redis-server Process Manager
After=syslog.target network.target

[Service]
Type=simple
PIDFile=/var/run/redis_6379.pid
ExecStart=/usr/local/redis/redis-server /usr/local/redis/redis.conf         
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID

[Install]
WantedBy=multi-user.target
''' >> /lib/systemd/system/redis.service
systemctl enable redis.service
systemctl restart redis.service
echo "正在执行jdk安装"
cd /opt/
mkdir -p /opt/java
tar -zxvf $jdk -C /opt/java
echo '''
JAVA_HOME=/opt/java/jdk1.8.0_191
JRE_HOME=/opt/java/jdk1.8.0_191/jre
PATH=$JAVA_HOME/bin:$PATH:$JRE_HOME/bin
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
''' >> /etc/profile
chmod 777 /etc/profile
source /etc/profile
echo "java环境安装"
sleep 1s
java
echo "正在安装Geoip"
tar -zxvf $geoip
cd /opt/GeoIP-1.4.8
./configure
make && make install
sleep 1s
echo "正在执行nginx安装"
cd /opt
tar -zxvf $nginx
tar -zxvf $ngx
cd /opt/nginx-1.15.8/
mkdir -p /opt/nginx
useradd -s /sbin/nologin www 
sed -i 's/\.openssl\///g' /opt/nginx-1.15.8/auto/lib/openssl/conf
sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' /opt/nginx-1.15.8/auto/lib/openssl/conf
cd /opt/nginx-1.15.8
./configure --user=www --group=www --prefix=/opt/nginx --add-module=../ngx_cache_purge-2.3 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl  --with-http_geoip_module
make && make install
echo '''
[Unit]
Description=nginx
After=network.target

[Service]
Type=forking
ExecStart=/opt/nginx/sbin/nginx
ExecReload=/opt/nginx/sbin/nginx reload
ExecStop=/opt/nginx/sbin/nginx quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
''' >> /lib/systemd/system/nginx.service
systemctl enable nginx.service
systemctl start nginx.service
systemctl status nginx.service
echo "更改ssh默认端口..............."
sleep 1s
sed -i '/^Port.*/d' /etc/ssh/sshd_config && echo "Port 48456" >> /etc/ssh/sshd_config
setenforce 0
systemctl restart sshd.service
echo "安装ntp服务并校验时间..............."
timedatectl set-timezone Asia/Shanghai
ntpdate -q 1.cn.pool.ntp.org
systemctl start ntpd
systemctl enable ntpd
systemctl enable nginx
systemctl enable mysqld.service
systemctl enable ntpd
systemctl enable firewalld.service 
echo "添加防火墙..............."
sleep 1s
firewall-cmd --permanent --zone=public --add-forward-port=port=38789:proto=tcp:toport=3306
firewall-cmd --permanent --zone=public --add-port=8090-8094/tcp
firewall-cmd --permanent --zone=public --add-port=48456/tcp
firewall-cmd --permanent --zone=public --add-port=3020/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --reload
cd /opt/
mkdir /opt/soft
mv /opt/*.gz /opt/openssl-1*/ /opt/ngx_cache_purge-2.3/ /opt/nginx-1.*/ /opt/mysql* /opt/soft
