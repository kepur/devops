    安装openresty nginx
    useradd -s /sbin/nologin www 
    mkdir -p /usr/local/openssl
openresty1.17_install(){
    mkdir /opt/openresty && cd /opt/openresty
    wget https://openresty.org/download/openresty-1.17.8.2.tar.gz
    tar -zxvf openresty-1.17.8.2.tar.gz
    cd /opt/openresty/openresty-1.17.8.2
    sed -i 's/\.openssl\///g' /opt/openresty/openresty-1.17.8.2/bundle/nginx-1.17.8/auto/lib/openssl/conf
    sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' /opt/openresty/openresty-1.17.8.2/bundle/nginx-1.17.8/auto/lib/openssl/conf
    ./configure --user=www --group=www  --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl --prefix=/opt
    gmake && gmake install
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
}

时间同步
timedatectl set-timezone Asia/Shanghai
ntpdate -q 1.cn.pool.ntp.org
systemctl start ntpd
systemctl enable ntpd
systemctl enable nginx
systemctl enable mysqld.service
systemctl enable ntpd
systemctl enable firewalld.service 

安装mysql
wget https://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm
yum localinstall mysql57-community-release-el7-8.noarch.rpm -y
yum install mysql-community-server -y
sudo service mysqld start
cat /var/log/mysqld.log | grep "password"


安装redis
wget http://download.redis.io/releases/redis-4.0.6.tar.gz
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

