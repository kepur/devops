#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
[ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
host=$( hostname )
kern=$( uname -r )
#软件包安装路径
pkg_dir=/opt/pkg_dir
#下载地址
openssl_root_url="https://www.openssl.org/source"
python_root_url="https://www.python.org/ftp/python"
mysql_root_url="https://repo.mysql.com/"
openresty_root_url="https://openresty.org/download"
redis_root_url="https://download.redis.io/releases"
erlang_root_url="https://erlang.org/download"
rabbitmq_root_url='https://github.com/rabbitmq/rabbitmq-server/releases/download'
node_root_url='https://nodejs.org/dist'
#需要配置
nginx_install_path="/opt"
service_web_domain=""
service_webapi_domain=""
service_websocket_domain=""
newMysqlPass=""
#卡机程序默认安装路径
workdir=/opt/pubcloudplatform
cardplatform_download_url="https://jp-1301785062.cos.ap-tokyo.myqcloud.com"
cardplatformfront="cardplatform_front_end"
cardplatformback="cardplatform_back_end"
redispasswd="Aaredis.com"
pubcloud_platform_db_passwd="Aa123..com"
rabbitmq_username='admin'
rabbitmq_password='pWdrAbiTin'
if [ ! -d "/opt/pkg_dir" ];then
  mkdir -p /opt/pkg_dir
  else
  echo "程序包下载文件夹已经存在"
fi
if [ ! -d "/opt/pubcloudplatform" ];then
  mkdir -p /opt/pubcloudplatform
  else
  echo "卡机工作目录已经存在"
fi

get_os_info(){
    echo "########## System Information ##########"
    echo 
    echo "CPU model            : ${cname}"
    echo "Number of cores      : ${cores}"
    echo "CPU frequency        : ${freq} MHz"
    echo "Total amount of ram  : ${tram} MB"
    echo "Total amount of swap : ${swap} MB"
    echo "System uptime        : ${up}"
    echo "Load average         : ${load}"
    echo "OS                   : ${opsy}"
    echo "Arch                 : ${arch} (${lbit} Bit)"
    echo "Kernel               : ${kern}"
    echo "Hostname             : ${host}"
    echo "IPv4 address         : ${IP}"
    echo 
    echo "########################################"
}

change_yum_source(){
    wget http://mirrors.aliyun.com/repo/Centos-7.repo
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
    mv /etc/yum.repos.d/Centos-7.repo /etc/yum.repos.d/CentOs-Base.repo
    yum clean all
    yum makecache
}

yum_init(){
    yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl libffi-devel -y
    yum groupinstall "Development tools"  -y 
    yum install unzip zlib-devel bzip2-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel  readline-devel  -y
    #wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libffi-devel-3.0.13-18.el7.x86_64.rpm
}


change_localtime(){
	echo "安装ntp服务并校验时间..............."
	timedatectl set-timezone Asia/Shanghai
	ntpdate -q 1.cn.pool.ntp.org
	systemctl start ntpd
	systemctl enable ntpd
	systemctl enable ntpd
    echo "当前时间为:" && date
}

change_ssh_port(){
    local port=$1
	echo "更改ssh默认端口..............." && sleep 1s
    setenforce 0
    #注释原来端口 
    #sed -i '/^Port.*/d' /etc/ssh/sshd_config
    sed -i "/Port.*/a Port $port" /etc/ssh/sshd_config
	systemctl restart sshd.service
}


openssl_install(){
    local openssl_version=$1
    echo $openssl_version
	local openssl=openssl-$openssl_version.tar.gz
	echo "$openssl"
	if [ -f "$pkg_dir$openssl" ];then
		echo " 文件 $openssl 找到 "
	else
		echo "文件 $openssl 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${openssl_root_url}/$openssl -P $pkg_dir/; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Openssl安装"
	tar -zxvf $openssl && cd openssl-$openssl_version
	mkdir -p /usr/local/openssl
	./config --prefix=/usr/local/openssl
	make && make install
	\mv /usr/bin/openssl /usr/bin/openssl.old
	\mv /usr/include/openssl /usr/include/openssl.old
	ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
	ln -s /usr/local/openssl/include/openssl/ /usr/include/openssl
	echo "/usr/local/openssl/lib/">>/etc/ld.so.conf
	ldconfig
	openssl version -a
}


redis_install(){
    echo "正在安装redis" && sleep 3s
    local redis_version=$1
	echo $redis_version
	local Redis=redis-$redis_version.tar.gz
	echo "$python"
	if [ -f "$pkg_dir$Redis" ];then
		echo " 文件 $Redis 找到 "
	else
		echo "文件 $Redis 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${redis_root_url}/$Redis -P $pkg_dir/; then
            echo "Failed to download $Redis \n 下载$Redis失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Redis安装"
	tar -zxvf $Redis
	cd redis-$redis_version\
	make MALLOC=libc
	cd \src
	make install 
	mkdir -p /etc/redis/
	cp $pkg_dir/redis-$redis_version/redis.conf /etc/redis/6379.conf
	cp $pkg_dir/redis-$redis_version/utils/redis_init_script /etc/init.d/redisd
	sed -i '2i\
	# chkconfig:   2345 90 10
	# description:  Redis is a persistent key-value database' /etc/init.d/redisd
	echo '''
	[Unit]
	Description=redis-server
	After=network.target

	[Service]
	#Type=forking
	ExecStart=/usr/local/bin/redis-server /etc/redis/6379.conf
	PrivateTmp=true

	[Install]
	WantedBy=multi-user.target
	''' >> /lib/systemd/system/redis.service
	systemctl daemon-reload
	systemctl enable redis.service
	systemctl restart redis.service
}


python_install(){
    local python_version=$1
	echo $python_version
	local python=Python-$python_version.tar.xz
	echo "$python"
	if [ -f "$pkg_dir$python" ];then
		echo " 文件 $python 找到 "
	else
		echo "文件 $python 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${python_root_url}/$python_version/$python -P $pkg_dir/; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行python安装"
	tar -xvf $python && cd Python-$python_version
	./configure --prefix=/usr/local/python$python_version/ --enable--shared --with-openssl=/usr/local/openssl
	make && make install
	rm -rf /usr/bin/python /usr/bin/pip
	ln -s /usr/local/python$python_version/bin/python3 /usr/bin/python
	ln -s /usr/local/python$python_version/bin/pip3 /usr/bin/pip
	sed -i 's/python/python2/g' /usr/bin/yum
	sed -i 's/python/python2/g' /usr/libexec/urlgrabber-ext-down
}


mysql_install(){
    #read -p "请输入mysqlroot的密码" newMysqlPass
    #https://repo.mysql.com//mysql80-community-release-el7-3.noarch.rpm
    #https://repo.mysql.com//mysql57-community-release-el7-8.noarch.rpm
    #https://repo.mysql.com//mysql57-community-release-el7-3.noarch.rpm
    #mysqlurl="https://jp-1301785062.cos.ap-tokyo.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
    #检查是否安装
    #yum repolist enabled | grep "mysql.*-community.*"
    echo "正在执行mysql安装"
    local mysqlpasswd=$1
    local mysql_version="mysql57"
    #mysql_version="mysql80"
    if [[ $openresty_version =~ "mysql57" ]]
    then
        mysql=$mysql_version-community-release-el7-3.noarch.rpm
    else
        mysql=$mysql_version-community-release-el7-8.noarch.rpm
    fi
    if [ -f "$pkg_dir$mysql" ];then
		echo " 文件 $mysql 找到 "
	else
		echo "文件 $mysql 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${mysql_root_url}/$mysql -P $pkg_dir/; then
            echo "Failed to download $mysql \n 下载$mysql, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && rpm -ivh $mysql
	yum -y install mysql-server mysql-devel
    #如缺少插件
    #rpm -ivh https://repo.almalinux.org/almalinux/8.3-beta/BaseOS/x86_64/os/Packages/numactl-libs-2.0.12-11.el8.x86_64.rpm
	systemctl restart mysqld
	systemctl enable mysqld.services	
	oldpass=`grep pass /var/log/mysqld.log | awk '{print $NF}'`
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${mysqlpasswd}"';"
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e " flush privileges;"
}


openresty_install(){
    useradd -s /sbin/nologin www 
    # https://openresty.org/download/openresty-1.19.3.2.tar.gz
    # https://openresty.org/download/openresty-1.19.3.1.tar.gz
    # https://openresty.org/download/openresty-1.17.8.2.tar.gz
    local openresty_version=$1
    echo $openresty_version
	local openresty=openresty-$openresty_version.tar.gz
	echo "$openresty"
	if [ -f "$pkg_dir/$openresty" ];then
		echo " 文件 $openresty 找到 "
	else
		echo "文件 $openresty 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${openresty_root_url}/$openresty -P $pkg_dir/; then
            echo "Failed to download $openresty \n 下载$openresty, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Openresty安装"
    tar -zxvf $openresty
    cd $pkg_dir/openresty-$openresty_version
    if [[ $openresty_version =~ "1.19" ]]
    then
        echo "支持的版本"
        sed -i 's/\.openssl\///g' $pkg_dir/openresty-$openresty_version/bundle/nginx-1.19.3/auto/lib/openssl/conf
        sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' $pkg_dir/openresty-$openresty_version/bundle/nginx-1.19.3/auto/lib/openssl/conf
    else
        echo "非1.19版本" && sleep 2s
    fi
    if [[ $openresty_version =~ "1.17" ]]
    then
        echo "支持的版本"
        sed -i 's/\.openssl\///g'  $pkg_dir/openresty-$openresty_version/bundle/nginx-1.17.8/auto/lib/openssl/conf
        sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' $pkg_dir/openresty-$openresty_version/bundle/nginx-1.17.8/auto/lib/openssl/conf
    else
        echo "非1.17版本" && sleep 2s
    fi
    ./configure --user=www --group=www  --with-luajit --without-lua_resty_dns --without-lua_resty_websocket --without-http_redis2_module  --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl --prefix=$nginx_install_path
    cd 
    gmake && gmake install
echo '''
[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
ExecStart='${nginx_install_path}'/nginx/sbin/nginx
ExecReload='${nginx_install_path}'/nginx/sbin/nginx reload
ExecStop='${nginx_install_path}'/nginx/sbin/nginx quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
''' > /lib/systemd/system/nginx.service
    systemctl daemon-reload
    if [ ! -d "${nginx_install_path}/nginx/cache/proxy_cache" ];then
        mkdir -p ${nginx_install_path}/nginx/cache/proxy_cache
    else
        echo "文件夹${nginx_install_path}/nginx/cache/proxy_cache 已经存在"
    fi
    if [ ! -d "${nginx_install_path}/nginx/conf/vhost" ];then
        mkdir -p ${nginx_install_path}/nginx/conf/vhost
    else
        echo "文件夹${nginx_install_path}/nginx/vhost已经存在"
    fi
    systemctl enable nginx.service
    systemctl start nginx
}


overwrite_nginx_configfile(){
    #local worker_processes=`expr $( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo ) \* 2` 
    local worker_processes=`expr $( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo ) ` 
    local openfilelimits=$( ulimit -a|grep "open files" | awk '{print $4 }')
    mv $nginx_install_path/nginx/conf/nginx.conf $nginx_install_path/nginx/conf/nginx.confbak
    case "$cores" in
    2)
        echo  "双核CPU"
        cpu_affinity="01 10"
    ;;
    [4-8])
        echo "4-8核CPU"
        cpu_affinity="0001 0010 0100 1000"
    ;;
    [8-20])
        echo "8核以上CPU"
        cpu_affinity="00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000"
    ;;
    esac
echo "配置nginx配置文件" && sleep 2s
echo "
user  www;
worker_processes  ${worker_processes};
worker_cpu_affinity ${cpu_affinity};
error_log  logs/error.log;
#pid        logs/nginx.pid;
events {
    worker_connections  ${openfilelimits};
}
http {
    include       mime.types;
    default_type  application/octet-stream;

    map \$HTTP_CF_CONNECTING_IP  \$clientRealIp {
    \"\"   \$remote_addr;
    ~^(?P<firstAddr>[0-9.]+),?.*$   \$firstAddr;
    }
    proxy_set_header X-Real-IP \$remote_addr;
    #proxy_set_header X-Real-IP \$clientRealIp;
    log_format  main  \"\$http_x_forwarded_for- \$remote_user [\$time_local] \$request
                    \$status \$body_bytes_sent \$http_referer
                    \$http_user_agent \$http_x_forwarded_for\";
    log_format  main_json  ' {\"time_local\":\"\$time_local\",
    \"ClientRealIp\":\"\$clientRealIp\",
    \"request_domain\":\"\$http_host\",
    \"request\":\"\$request\",
    \"status\":\"\$status\",
    \"body_bytes_sent\":\"\$body_bytes_sent\",
    \"http_referer\":\"\$http_referer\",
    \"request_uri\":\"\$request_uri\",
    \"http_user_agent\":\"\$http_user_agent\",
    \"remote_addr\":\"\$remote_addr\",
    \"request_time\":\"\$request_time\",
    \"request_filename\":\"\$request_filename\",
    \"http_x_forwarded_for\":\"\$http_x_forwarded_for\",
    \"fastcgi_script_name\":\"\$fastcgi_script_name\",
    \"document_root\":\"\$document_root\",
    \"request_body\":\"\$request_body\",
    \"response_body\":\"\$resp_body\"} ';
    access_log  logs/access.log  main;
    sendfile        on;
    server_tokens off;
    keepalive_timeout 75;
    server_names_hash_bucket_size 128;
    client_header_buffer_size 128k;
    large_client_header_buffers 4 128k;
    server_name_in_redirect off;
    client_max_body_size 10m;
    client_body_buffer_size 128k;
    tcp_nopush     on;
    tcp_nodelay    on;

    gzip  on;                        
    gzip_min_length 1k;              
    gzip_buffers 4 16k;
    gzip_http_version 1.1;
    gzip_comp_level 3;
    gzip_disable "MSIE [1-6].";
    gzip_types text/plain application/x-javascript text/css text/xml application/xml image/jpeg image/gif image/png;
    gzip_vary on;
    gzip_proxied any;

    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_connect_timeout 300;       
    proxy_send_timeout 300;       
    proxy_read_timeout 300;           
    proxy_buffer_size 16k;          
    proxy_buffers 6 64k;            
    proxy_busy_buffers_size 128k;    
    proxy_temp_file_write_size 64k; 
    proxy_set_header   Host  \$host;
    open_file_cache max=204800 inactive=20s;
    open_file_cache_min_uses 1;
    open_file_cache_valid 60s;
    proxy_cache_path ${nginx_install_path}/nginx/cache/proxy_cache levels=1:2 keys_zone=cache_one:100m inactive=1d max_size=30g; #100m和30G，按照服务要求，适当增大
    #################### JumpSever include #########################
    include vhost/*.conf;
    include vhost/*.map;
    ####################undeifne domain #########################
    server {
        listen 80 default_server;
        server_name _;
        if (\$request_method = POST) {
            return 307 https://\$host\$request_uri;
        }	
        access_log ${nginx_install_path}/nginx/logs/nginx_undefine.access.log;
        error_log  logs/nginx_error.log;
        error_log  /dev/null crit;
        return 301 https://www.baidu.com/s?wd=wtf;
    }
}
" > $nginx_install_path/nginx/conf/nginx.conf
echo "配置卡机管理系统nginx基本安全公共模块配置" && sleep 2s
echo '''
########################设置IP白名单############
location / {
    if ( $geo = 1 ){
        return 403;
    }
}
########################拦截GET、POST 以及 HEAD 之外的请求############
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
	return    444;
}
########################拦截GET、POST 以及 HEAD 之外的请求############

#location ~ .*\.(php|cgi|jsp|asp|aspx)$ {
location ~ .*\.(jsp|asp|aspx)$ {
    return 301 http://www.baidu.com/s?wd=mmp;
}
######################## Block SQL injections 防止SQL注入#############
set $block_sql_injections 0;
if ($query_string ~ \"union.*select.*\(") {
set $block_sql_injections 1;
}
if ($query_string ~ \"union.*all.*select.*\") {
set $block_sql_injections 1;
}
if ($query_string ~ \"concat.*\(\") {
set $block_sql_injections 1;
}
if ($block_sql_injections = 1) {
return 403;
}

########################lock file injections防止恶意请求############

set $block_file_injections 0;
if ($query_string ~ \"[a-zA-Z0-9_]=http://\") {
set $block_file_injections 1;
}
if ($query_string ~ \"[a-zA-Z0-9_]=(\.\.//?)+\") {
set $block_file_injections 1;
}
if ($query_string ~ \"[a-zA-Z0-9_]=/([a-z0-9_.]//?)+\") {
set $block_file_injections 1;
}
if ($block_file_injections = 1) {
return 403;
}

########################Block common exploits防止XSS注入############
set $block_common_exploits 0;
if ($query_string ~ \"(<|%3C).*script.*(>|%3E)\") {
set $block_common_exploits 1;
}
if ($query_string ~ \"GLOBALS(=|\[|\%[0-9A-Z]{0,2})\") {
set $block_common_exploits 1;
}
if ($query_string ~ \"_REQUEST(=|\[|\%[0-9A-Z]{0,2})\") {
set $block_common_exploits 1;
}
if ($query_string ~ \"proc/self/environ\") {
set $block_common_exploits 1;
}
if ($query_string ~ \"mosConfig_[a-zA-Z_]{1,21}(=|\%3D)\") {
set $block_common_exploits 1;
}
if ($query_string ~ \"base64_(en|de)code\(.*\)\") {
set $block_common_exploits 1;
}
if ($block_common_exploits = 1) {
return 403;
}

########################Block common exploits #############
set $block_spam 0;
if ($query_string ~ \"\b(ultram|unicauca|valium|viagra|vicodin|xanax|ypxaieo)\b\") {
set $block_spam 1;
}
if ($query_string ~ \"\b(erections|hoodia|huronriveracres|impotence|levitra|libido)\b\") {
set $block_spam 1;
}
if ($query_string ~ \"\b(ambien|blue\spill|cialis|cocaine|ejaculation|erectile)\b\") {
set $block_spam 1;
}
if ($query_string ~ \"\b(lipitor|phentermin|pro[sz]ac|sandyauer|tramadol|troyhamby)\b\") {
set $block_spam 1;
}
if ($block_spam = 1) {
return 403;
} 
########################Block user agents  防止用户代理请求 #############
set $block_user_agents 0;
# Dont disable wget if you need it to run cron jobs!
#if ($http_user_agent ~ \"Wget\") {
# set $block_user_agents 1;
#}

# Disable Akeeba Remote Control 2.5 and earlier
if ($http_user_agent ~ \"Indy Library\") {
set $block_user_agents 1;
}

# Common bandwidth hoggers and hacking tools.
if ($http_user_agent ~ \"libwww-perl\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"GetRight\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"GetWeb!\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"Go!Zilla\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"Download Demon\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"Go-Ahead-Got-It\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"TurnitinBot\") {
set $block_user_agents 1;
}
if ($http_user_agent ~ \"GrabNet\") {
set $block_user_agents 1;
}
if ($block_user_agents = 1) {
return 403;
}
''' > $nginx_install_path/nginx/conf/vhost/commom.server.module
echo "配置卡机管理系统nginx卡机IP访问白名单" && sleep 2s
echo '''
geo $clientRealIp $geo{
default 1;
127.0.0.1/32 0;
#vdi
122.53.61.149 0;
210.5.114.138 0;
103.44.235.242 0;
223.119.201.2 0;
122.55.108.34 0;
180.232.123.106 0;
121.96.53.99 0;
122.53.214.107 0;
180.232.123.101 0;
122.53.214.108 0;
203.177.208.142 0;
203.177.137.206 0;
122.55.108.34 0;
223.119.193.154 0;
#botpanel
16.162.45.222 0;
8.134.54.138 0;
49.232.246.188 0;
119.28.130.208 0;
18.166.226.192 0;
18.163.182.156 0;
16.162.47.155 0;
18.167.12.141 0;
18.162.168.236 0;
18.162.54.122 0;
18.162.149.64 0;
}''' >$nginx_install_path/nginx/conf/vhost/whiteip.map
echo "配置卡机管理系统nginx server web配置文件" && sleep 2s
echo "server {
    listen       80;
    server_name  ${service_web_domain};
    root         $workdir/$cardplatformfront/dist;
    include      $nginx_install_path/nginx/conf/vhost/commom.server.module;
    access_log ${nginx_install_path}/nginx/logs/${service_web_domain}_access.log main_json;
    error_log ${nginx_install_path}/nginx/logs/${service_web_domain}_error.log;
    set \$resp_body '';
    body_filter_by_lua '
    local resp_body = string.sub(ngx.arg[1],1,1000)
    ngx.ctx.buffered=(ngx.ctx.buffered or \"\")..resp_body
    if ngx.arg[2]then
    ngx.var.resp_body = ngx.ctx.buffered
    end';
    location / {
    add_header Access-Control-Allow-Orgin '*';
    index index.html;
    }
    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
" >$nginx_install_path/nginx/conf/vhost/pubcloud.conf
echo "配置卡机管理系统nginx webapi server配置文件" && sleep 2s
echo "server {
    listen       80;
    server_name  ${service_webapi_domain};
    include      $nginx_install_path/nginx/conf/vhost/commom.server.module;
    access_log ${nginx_install_path}/nginx/logs/${service_webapi_domain}_access.log main_json;
    error_log ${nginx_install_path}/nginx/logs/${service_webapi_domain}_error.log;
    set $resp_body \"\";
    body_filter_by_lua '
    local resp_body = string.sub(ngx.arg[1],1,1000)
    ngx.ctx.buffered=(ngx.ctx.buffered or \"\")..resp_body
    if ngx.arg[2]then
    ngx.var.resp_body = ngx.ctx.buffered
    end
    ';
    location / {
    add_header Access-Control-Allow-Orgin '*';
    proxy_pass http://127.0.0.1:10000/;
    }
    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
" >$nginx_install_path/nginx/conf/vhost/pubcloudapi.conf
echo "配置卡机管理系统nginx websocket server配置文件" && sleep 2s
echo "server {
    listen       80;
    server_name  ${service_websocket_domain};
    include      $nginx_install_path/nginx/conf/vhost/commom.server.module;
    access_log '${nginx_install_path}/nginx/logs/${service_websocket_domain}_access.log main_json;
    error_log ${nginx_install_path}/nginx/logs/${service_websocket_domain}_error.log;
    set \$resp_body \" \";
    body_filter_by_lua '
    local resp_body = string.sub(ngx.arg[1],1,1000)
    ngx.ctx.buffered=(ngx.ctx.buffered or \"\")..resp_body
    if ngx.arg[2]then
    ngx.var.resp_body = ngx.ctx.buffered
    end
    ';
    location / {
    add_header Access-Control-Allow-Orgin '*';
    proxy_pass http://127.0.0.1:10000/;
    }
    location /ws/result {
    add_header Access-Control-Allow-Orgin '*';
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"upgrade\";
    proxy_pass http://127.0.0.1:10001/;
    }
    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
" >$nginx_install_path/nginx/conf/vhost/pubcloudws.conf
echo "配置nginx日志切割文件" && sleep 2s
echo '''
BASEPATH='$nginx_install_path'/nginx/logs
ACCESSPATH='$nginx_install_path'/nginx/logs/access_logs
ERRORPATH='$nginx_install_path'/nginx/logs/error_logs
ngxlogs="'$service_webapi_domain'_access.log
'$service_webapi_domain'_access.log
'$service_web_domain'_access.log
"
for alog in $ngxlogs
do
mv $BASEPATH/$alog $ACCESSPATH/$(date -d yesterday +%Y%m%d%H)_$alog;
touch $BASEPATH/$alog;
kill -USR1 `cat /var/run/nginx.pid`;
done
elogs="'$service_webapi_domain'_error.log
'$service_webapi_domain'_error.log
'$service_web_domain'_error.log
"
for elog in $elogs
do
mv $BASEPATH/$elog $ERRORPATH/$(date -d yesterday +%Y%m%d%H)_$elog;
touch $BASEPATH/$elog;
kill -USR1 `cat /var/run/nginx.pid`;
done
''' >$nginx_install_path/nginx/sbin/nginxcutlog.sh
    curr_user=`echo $USER`
    echo "1 0 * * * bash $nginx_install_path/nginx/bin/nginxcutlog.sh" >> "/var/spool/cron/$curr_user"
    systemctl restart nginx && sleep 5s
}


erlang_install(){
    local erlang_version=$1
	echo $erlang_version
	local Erlang=otp_src_$erlang_version.tar.gz
	echo "$Erlang"
	if [ -f "$pkg_dir$Erlang" ];then
		echo " 文件 $Erlang 找到 "
	else
		echo "文件 $Erlang 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${erlang_root_url}/$Erlang -P $pkg_dir/; then
            echo "Failed to download $Erlang \n 下载$Erlang失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Erlang安装"
	tar -zxvf $Erlang
	mv otp_src_$erlang_version /usr/local/
	cd /usr/local/otp_src_$erlang_version
	./configure --prefix=/usr/local/erlang/ --with-ssl=/usr/local/openssl
	make install 
	echo 'export PATH=$PATH:/usr/local/erlang/bin' >>/etc/profile
	source /etc/profile
	ln -s /usr/local/erlang/bin/erl /usr/bin/erl
}

#https://github.com/rabbitmq/rabbitmq-server/releases/download/3.7.15/rabbitmq-server-generic-unix-3.7.15.tar.xz
rabbit_mq_install(){
    local rabbitmq_version=$1
	echo $rabbitmq_version
	local rabbitmq=rabbitmq-server-generic-unix-$rabbitmq_version.tar.xz
	echo "$rabbitmq"
	if [ -f "$pkg_dir$rabbitmq" ];then
		echo " 文件 $rabbitmq 找到 "
	else
		echo "文件 $rabbitmq 不存在将自动下载" 
		if ! wget -c -t3 -T60 $rabbitmq_root_url/v$rabbitmq_version/$rabbitmq -P $pkg_dir/; then
            echo "Failed to download $rabbitmq \n 下载$rabbitmq, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Erlang安装"
	yum install -y xz && xz -d $rabbitmq
	tar -xvf rabbitmq-server-generic-unix-$rabbitmq_version.tar
	mv rabbitmq_server-$rabbitmq_version /usr/local/
	mv /usr/local/rabbitmq_server-$rabbitmq_version /usr/local/rabbitmq
	echo 'export PATH=$PATH:/usr/local/rabbitmq/sbin' >>/etc/profile
	source /etc/profile
	rabbitmq-server -detached
	rabbitmq-plugins enable rabbitmq_management
    echo "rabbitmq当前状态" && sleep 2s
    rabbitmqctl status
    sleep 3s
}


node_install(){
    if test -z "$(ls | find ~/ -name node && find ~/ -name node_modules | rpm -qa node )"; then
	echo "已安装nodejs 将卸载之前的版本."
        yum remove nodejs npm -y
        rm -rf /usr/local/lib/node*
        rm -rf  /usr/local/include/node*
        rm -rf /usr/local/node*
        rm -rf /usr/local/bin/npm
        rm -rf /usr/local/share/man/man1/node.1
        rm -rf  /usr/local/lib/dtrace/node.d
        rm -rf ~/.npm
        rm -rf /usr/bin/node
        rm -rf /usr/bin/npm
    else
        echo "开始安装nodejs."
    fi
    node_version=$1
	echo $node_version
	nodejs=node-v$node_version-linux-x64.tar.gz
	echo "$nodejs"
	if [ -f "$pkg_dir$nodejs" ];then
		echo " 文件 $nodejs 找到 "
	else
		echo "文件 $nodejs 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${node_root_url}/v$node_version/$nodejs -P $pkg_dir/; then
            echo "Failed to download $nodejs \n 下载$nodejs失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Nodejs安装"
	tar -zxvf $nodejs
    mv node-v$node_version-linux-x64 /usr/local/
    ln -s /usr/local/node-v$node_version-linux-x64/bin/node /usr/bin/node
    ln -s /usr/local/node-v$node_version-linux-x64/bin/npm /usr/bin/npm
}


#创建数据库
mysql_service_config(){
    $public_cloud_platform_database_passwd=$1
    echo "您的public_cloud_platform数据库密码为:$public_cloud_platform_database_passwd" && sleep 3s
    /usr/bin/mysql --connect-expired-password -uroot -p${newMysqlPass} -e " create user 'card'@'%' identified by '$public_cloud_platform_database_passwd';"
    /usr/bin/mysql --connect-expired-password -uroot -p${newMysqlPass} -e " grant all privileges on *.* to card@'%' identified by '$public_cloud_platform_database_passwd';"
    /usr/bin/mysql --connect-expired-password -uroot -p${newMysqlPass} -e " create database public_cloud_platform default character set utf8;"
    /usr/bin/mysql --connect-expired-password -uroot -p${newMysqlPass} -e " flush privileges;"
}


#配置rabbitmq
rabbitmq_service_config(){
    source /etc/profile 
    local rabbitmq_user=$1
    local rabbitmq_passwd=$2
    echo "为rabbit 设置用户名为:$rabbitmq_user 密码为:$rabbitmq_passwd" && sleep 3s
    rabbitmqctl list_users
    rabbitmqctl add_user $rabbitmq_user $rabbitmq_passwd
    rabbitmqctl set_user_tags $rabbitmq_user administrator
    rabbitmqctl set_permissions -p / $rabbitmq_user ".*" ".*" ".*"
    rabbitmqctl list_permissions
    echo "请检查rabbitmq 状态" && sleep 2s
    rabbitmqctl status
    sleep 3s
}


#redis配置密码
redis_service_config(){
    rediswd=$1
    echo "您的redis密码设置为: $rediswd"
    sed -i "/requirepass.*/a requirepass $rediswd" /etc/redis/6379.conf
    systemctl restart redis
}


#配置卡机前端程序
cardsvr_frontend_config(){
	if [ -f "$workdir/${cardplatformfront}.zip" ];then
		echo " 文件 ${cardplatformfront}.zip 找到 "
	else
		echo "文件 ${cardplatformfront}.zip 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${cardplatform_download_url}/${cardplatformfront}.zip -P $workdir/; then
            echo "Failed to download ${cardplatformfront}.zip \n 下载${cardplatformfront}.zip, 请手动下载到${workdir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$workdir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
cd $workdir && unzip $workdir/${cardplatformfront}.zip    
#替换
mv $workdir/cardplatform_front_end/src/utils/request.js $workdir/cardplatform_front_end/src/utils/request.jsbak
#sed -i "/^baseURL.*/d" $workdir/cardplatform-frond-end/src/utils/request.js && echo "baseURL: 'https://cardapi.zfgs168.com',">> 
echo "
import axios from 'axios';
import store from '../store';
import { getToken } from '@/utils/auth'
const websocket_base_url  = 'wss://${service_websocket_domain}'
const service = axios.create({
    // process.env.NODE_ENV === 'development' 来判断是否开发环境
    adapter: require('axios/lib/adapters/xhr'),
    baseURL: 'https://${service_webapi_domain}',
    timeout: 150000
});
export {
    websocket_base_url
}

service.interceptors.request.use(
    config => {
        if (store.getters.token) {
            config.headers['Authorization'] = 'Token ' + getToken() // 让每个请求携带自定义token 请根据实际情况自行修改
        }
        return config
    },
    error => {
        // Do something with request error
        console.log(error) // for debug
        Promise.reject(error)
    }
)

// response 拦截器
service.interceptors.response.use(
    response => {
        /**
         * code为非20000是抛错 可结合自己业务进行修改
         */
        return response.data
    },
    error => {
        console.log('err' + error) // for debug
        return Promise.reject(error)
    }
)
export default service
" > $workdir/$cardplatformfront/src/utils/request.js
  cd $workdir/$cardplatformfront 
  rm -rf $workdir/$cardplatformfront/node_modules/
  chmod -R 775 $workdir/$cardplatformfront
  npm cache clean --force
  npm install  
  npm run build
}
#装错重新安装
remove_backend_service(){
    rm -f /usr/lib/systemd/system/websocket.service
    rm -f /usr/local/bin/uwsgi
    rm -f /usr/local/bin/virtualenv
    rm -rf $workdir/${cardplatformback}.zip
    rm -rf $workdir/${cardplatformback}
    pip uninstall uwsgi -y
    pip uninstall virtualenv -y
}
#配置卡机后端程序
cardsvr_backend_config(){
	if [ -f "$workdir${cardplatformback}.zip" ];then
		echo " 文件 ${cardplatformback}.zip 找到 "
	else
		echo "文件 ${cardplatformback}.zip 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${cardplatform_download_url}/${cardplatformback}.zip -P $workdir/; then
            echo "Failed to download ${cardplatformback}.zip \n 下载${cardplatformback}.zip, 请手动下载到${workdir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$workdir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi

cd $workdir && unzip $workdir/${cardplatformback}.zip
cd $workdir/${cardplatformback}
pip install virtualenv
python -m pip install --upgrade pip
#自定义安装openssl 需要卸载默认yum安装的openssl-devel
yum remove -y openssl-devel
python -m pip install uwsgi 
ln -s /usr/local/python3.8.9/bin/uwsgi /usr/local/bin/uwsgi
ln -s /usr/local/python3.8.9/bin/virtualenv /usr/local/bin/virtualenv
#创建virtualenv虚拟环境 配置地址
#/data/software/vue_pubCloud_platform_w/src/utils 
#mkdir -p /opt/publiccloudplatform/ && cd /opt/publiccloudplatform/
#卡机后端程序包需要配置的地方
#rabbitmq 配置 /main/config.yml
#redis和mysql 配置 main/setting.py
#webscoket服务配置  websocket.service
#计划任务配置 ./celery start
#获取卡机前端升级包
#uwsgi配置     .uwsgi.ini
echo "写入uwsgi配置文件到 $workdir/$cardplatformback/" && sleep 2s
mv $workdir/$cardplatformback/uwsgi.ini $workdir/$cardplatformback/uwsgi.bak
echo "
[uwsgi]
chdir=$workdir/$cardplatformback
pythonpath=$workdir/cardmgtplatform/lib/python3.8/site-packages
module=main.wsgi
master=True
pidfile=/tmp/pubcloud.pid
vacuum=True
max-requests=4000
daemonize=./pubcloud.log
http=:10000
processes=4
">$workdir/$cardplatformback/${cardplatformback}/uwsgi.ini
echo "写入websocket配置文件到/usr/lib/systemd/system/websocket.service" && sleep 2s
echo "[Unit]
Description=public cloud platform websocket service
After=network.target

[Service]
Type=simple
WorkingDirectory=$workdir/$cardplatformback
Environment=DJANGO_SETTINGS_MODULE=main.settings
ExecStart=$workdir/cardmgtplatform/bin/daphne --access-log $workdir/$cardplatformback/websocket-access.log -b 0.0.0.0 -p 10001 main.asgi:application
Restart=always

[Install]
WantedBy=multi-user.target
">/usr/lib/systemd/system/websocket.service
systemctl daemon-reload
systemctl start websocket
echo "写入rabbitmq 配置文件到 $workdir/$cardplatformback/main/config.yml" && sleep 2s
mv $workdir/$cardplatformback/main/config.yml $workdir/$cardplatformback/main/config.ymlbak
echo "main:
  env: 'DEMO'
  debug: True
  #log_type: 'file'
  log_type: 'print'
  log_path: 'logs/'


redis:
  host: '127.0.0.1'
  port: 6379
  password: '$redispasswd'

url:
  sso_url: 'http://sso.dev.bagunai.com'
  sso_token: '437221b42ce7b8b9d25cc6cd04683e5e097cfd7012b7336929c22c6a377ffbf6'
  sso_user_data: '/api/v1/common/userAccount/get_user_data/'
  logout_location: '/identity/login.html'

  cmdb_sso_url: 'http://cmdb.dev.bagunai.com'
  
  cmdb_url: 'http://cmdb.dev.bagunai.com'
  cmdb_token: '437221b42ce7b8b9d25cc6cd04683e5e097cfd7012b7336929c22c6a377ffbf6'

  feitian_url: 'http://feitian.dev.bagunai.com'
  serverapply_url: '/feitian/cloudServerBuy/createApply'

rabbitmq:
  broker: 'amqp://admin:admin@localhost:5672/'
  host: '127.0.0.1'
  port: 5672
  user: '$rabbitmq_username'
  pass: '$rabbitmq_password'

openstack:
  rcbc-dev:
    host: 'http://clouddev.bssrv.com'
    admin:
      user: 'cmdbdevadmin'
      password: 'cmdbdevadmin'
      id: '06ad01220fe047c7940cc651936c9651'
    user:
      user: 'cmdbdevuser'
      password: 'cmdbdevuser'
      id: '06ad01220fe047c7940cc651936c9651'
    project: 'A02'
    key: NULL
    exclude_project: ['admin', 'service', 'tempest']
    ip_range_min: 10
    ip_range_max: 240
"> $workdir/$cardplatformback/main/config.yml
echo "#添加redis和mysql配置到python设置档到 $workdir/$cardplatformback/main/setting.py" && sleep 2s
mv $workdir/$cardplatformback/main/settings.py $workdir/$cardplatformback/main/settings.pybak
echo "from pathlib import Path
import sys
import os
import yaml
from libs import tool
import base64

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(BASE_DIR, 'apps'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'in+mic1^%69=k43_7#@(woj=#rdjhserznw4py%0ssssss'
# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True
ALLOWED_HOSTS = ['*']
# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'corsheaders',
    'rest_framework',
    'rest_framework.authtoken',
    'django_filters',
    'guardian',
    'channels',
    'drf_yasg',
    'apps.permcontrol',
    'apps.audit',
    'apps.aws',
    'apps.gcp',
    'apps.alicloud',
    'apps.tencent',
    'apps.account',
    'apps.url_permission',
    'apps.public_api',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # 'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
]

ROOT_URLCONF = 'main.urls'
CORS_ORIGIN_ALLOW_ALL = True
CORS_ALLOW_CREDENTIALS = True
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')]
        ,
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'main.wsgi.application'
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'public_cloud_platform',
        'USER': 'card',
        'PASSWORD': '$pubcloud_platform_db_passwd',
        'HOST': '127.0.0.1',
        'PORT': '3306',
        'OPTIONS': {
            # 'init_command': \"SET sql_mode='STRICT_TRANS_TABLES'\",
            \"init_command\": \"SET foreign_key_checks = 0;\",
        },
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]
LANGUAGE_CODE = 'zh-hans'
# TIME_ZONE = 'UTC'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_L10N = True
USE_TZ = True
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, \"static/\")

REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',

    ),
    'DEFAULT_SCHEMA_CLASS': 'rest_framework.schemas.coreapi.AutoSchema',
}

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'guardian.backends.ObjectPermissionBackend',
)

ASGI_APPLICATION = \"main.routing.application\"
CHANNEL_LAYERS = {
     \"default\": {
         # \"BACKEND\": \"channels.layers.InMemoryChannelLayer\",
         'BACKEND': 'channels_redis.core.RedisChannelLayer',
         \"CONFIG\": {
             \"hosts\": [\"redis://:$redispasswd@127.0.0.1:6379/0\"],
             \"symmetric_encryption_keys\": [SECRET_KEY],
         },
     }
}
# celery时区设置
CELERY_TIMEZONE = 'Asia/Shanghai'
CELERY_ENABLE_UTC = False
conf_path = 'main/config.yml'
audit_path = 'main/audit.yml'

with open(conf_path, encoding='UTF-8') as f:
    conf = yaml.full_load(f.read())

CURRENT_ENV = conf['main']['env']
DEBUG = conf['main']['debug']
ALLOWED_HOSTS = ['*']
CMDB_URL = conf['url']['cmdb_url']
CMDB_TOKEN = conf['url']['cmdb_token']
LOG_TYPE = conf['main']['log_type']
LOG_PATH = conf['main']['log_path']
log = tool.Log()
log.PATH = LOG_PATH
if LOG_TYPE == 'file':
    logger = log.file_logger()
else:
    logger = log.stream_logger()

">$workdir/$cardplatformback/main/settings.py
echo "创建python虚拟环境" && sleep 2s
cd $workdir && virtualenv cardmgtplatform
pip install --upgrade certifi
echo "进入python虚拟环境并导入环境变量" && sleep 2s
source $workdir/cardmgtplatform/bin/activate
echo "初始软件" && sleep 2s
cd $workdir/$cardplatformback && pip install -r requirement.txt
echo "初始化映射数据库" && sleep 2s
pip install --upgrade certifi
python manage.py makemigrations
python manage.py migrate
echo "下面将创建系统用户 " && sleep 3s
python manage.py createsuperuser
uwsgi --ini uwsgi.ini
echo "启动计划任务" && sleep 2s
./celery.sh start
}


aconda_install_y(){
    wget   https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
    vim /root/.bashrc
    export PATH="/root/anaconda3/bin:$PATH"
    source /root/.bashrc
    conda create -n python38 python=python3.8.8
}
card_service_install(){
    get_os_info 
    change_yum_source 
    yum_init
    change_localtime
    #更改ssh端口 指定2631
    change_ssh_port 2631
    #安装openssl 指定1.1.1k版本
    openssl_install 1.1.1k
    #安装rabbit mq 指定22.0版本
    redis_install 6.2.3
    #安装python 指定3.8.9版本
    python_install 3.8.9
    #安装rabbit mq 指定22.0版本
    erlang_install 22.0
    #安装rabbit mq 指定3.7.15版本
    rabbit_mq_install 3.7.15
    #安装mysql
    mysql_install $newMysqlPass
    #安装openresty 指定1.19.3.1版本
    openresty_install 1.19.3.1
    #安装nginx后 添加配置文件
    overwrite_nginx_configfile 
    #安装node npm
    node_install 12.20.0
    #创建数据库
    mysql_service_config
    #rabbitmq创建用户
    rabbitmq_service_config $rabbitmq_username  $rabbitmq_password
    #redis设置密码
    redis_service_config $redispasswd
    #卡机前端程序下载安装
    cardsvr_frontend_config
    #卡机后端程序下载安装
    cardsvr_backend_config
}
card_service_install