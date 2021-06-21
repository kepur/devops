#手动配置
workdir=/opt/pkg_dir/
pkg_dir=/opt/pkg_dir
openssl_root_url="https://www.openssl.org/source/"
python_root_url="https://www.python.org/ftp/python/"
mysql_root_url="https://repo.mysql.com//"
openresty_root_url="https://openresty.org/download/"
redis_root_url="https://download.redis.io/releases/"
nginx_install_path=/opt
service_web_domain=""
service_webapi_domain=""
service_websocket_domain=""

if [ ! -d "/opt/pkg_dir" ];then
  mkdir -p /opt/pkg_dir
  else
  echo "文件夹已经存在"
fi
get_os_info(){
    IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    local cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    local cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
    local freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
    local load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    local arch=$( uname -m )
    local lbit=$( getconf LONG_BIT )
    local host=$( hostname )
    local kern=$( uname -r )

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
change_localtime(){
	echo "安装ntp服务并校验时间..............."
	timedatectl set-timezone Asia/Shanghai
	ntpdate -q 1.cn.pool.ntp.org
	systemctl start ntpd
	systemctl enable ntpd
	systemctl enable ntpd
}
change_ssh_port(){
	echo "更改ssh默认端口..............."
	sleep 1s
	sed -i '/^Port.*/d' /etc/ssh/sshd_config && echo "Port 2631" >> /etc/ssh/sshd_config
	setenforce 0
	systemctl restart sshd.service
}
change_yum_source(){
    wget http://mirrors.aliyun.com/repo/Centos-7.repo
    mv /etc/yum.repos.d/CentOs-Base.repo /etc/yum.repos.d/CentOs-Base.repo.bak
    mv /etc/yum.repos.d/Centos-7.repo /etc/yum.repos.d/CentOs-Base.repo
    yum clean all
    yum makecache
}
yum_init(){
    yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel libffi-devel -y
    yum groupinstall "Development tools"  -y 
    yum install unzip zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel  readline-devel  -y
    wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libffi-devel-3.0.13-18.el7.x86_64.rpm
}
openssl_install(){
    openssl_version=$1
    echo $openssl_version
	openssl=openssl-$openssl_version.tar.gz
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
	mkdir -p /usr/local/openssl-$openssl_version
	./config --prefix=/usr/local/openssl-$openssl_version
	make && make install
	\mv /usr/bin/openssl /usr/bin/openssl.old
	\mv /usr/include/openssl /usr/include/openssl.old
	ln -s /usr/local/openssl-$openssl_version/bin/openssl /usr/bin/openssl
	ln -s /usr/local/openssl-$openssl_version/include/openssl/ /usr/include/openssl
	echo "/usr/local/openssl-$openssl_version/lib/">>/etc/ld.so.conf
	ldconfig
	openssl version -a
}
redis_install(){
    redis_version=$1
	echo $redis_version
	Redis=redis-$redis_version.tar.gz
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
	system daemon-reload
	systemctl enable redis.service
	systemctl restart redis.service
}
python_install(){
    python_version=$1
	echo $python_version
	python=Python-$python_version.tar.xz
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
    #https://repo.mysql.com//mysql80-community-release-el7-3.noarch.rpm
    #https://repo.mysql.com//mysql57-community-release-el7-8.noarch.rpm
    #mysqlurl="https://jp-1301785062.cos.ap-tokyo.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
    #检查是否安装
    #yum repolist enabled | grep "mysql.*-community.*"
    echo "正在执行mysql安装"
    mysqlpasswd=$1
    mysql_version="mysql57"
    #mysql_version="mysql80"
    if [[ $openresty_version =~ "mysql57" ]]
    then
        mysql=Python-$mysql_version-community-release-el7-8.noarch.rpm
    else
        mysql=Python-$mysql_version-community-release-el7-3.noarch.rpm
    fi
    if [ -f "$pkg_dir$python" ];then
		echo " 文件 $python 找到 "
	else
		echo "文件 $python 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${mysql_root_url}/$mysql -P $pkg_dir/; then
            echo "Failed to download $mysql \n 下载$mysql, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && rpm -ivh mysql57-community-release-el7-8.noarch.rpm
	yum -y install mysql-server mysql-devel
	service mysqld restart
	systemctl enable mysqld.services	
	oldpass=`grep pass /var/log/mysqld.log | awk '{print $NF}'`
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${mysqlpasswd}"';"
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e " flush privileges;"
}
openresty_install(){
    # https://openresty.org/download/openresty-1.19.3.2.tar.gz
    # https://openresty.org/download/openresty-1.19.3.1.tar.gz
    # https://openresty.org/download/openresty-1.17.8.2.tar.gz
    openresty_version=$1
    echo $openresty_version
	openresty=openresty-$openresty_version.tar.gz
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
    ./configure --user=www --group=www  --with-luajit --without-lua_resty_dns --without-lua_resty_websocket --without-http_redis2_module --with-http_postgres_module --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl --prefix=$nginx_install_path
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
    ''' >> /lib/systemd/system/nginx.service
    systemctl enable nginx.service
    systemctl start nginx.service
    systemctl enable ntpd
    systemctl enable nginx
}
overwrite_nginx_configfile(){
worker_processes=`expr $( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo ) \* 2` 
openfilelimits=$( ulimit -a|grep "open files" )
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
echo '''
user  www;
worker_processes  '${worker_processes}';
worker_cpu_affinity '${cpu_affinity}';
error_log  logs/error.log;
#pid        logs/nginx.pid;
events {
    worker_connections  '${openfilelimits}';
}
http {
    include       mime.types;
    default_type  application/octet-stream;

    map $HTTP_CF_CONNECTING_IP  $clientRealIp {
    ""    $remote_addr;
    ~^(?P<firstAddr>[0-9.]+),?.*$    $firstAddr;
    }
    proxy_set_header X-Real-IP $remote_addr;
    #proxy_set_header X-Real-IP $clientRealIp;
    log_format  main  "$http_x_forwarded_for- $remote_user [$time_local] $request 
                      $status $body_bytes_sent $http_referer 
                      $http_user_agent $http_x_forwarded_for ";
    log_format  main_json '\{"time_local"\:'[$time_local]'\,
    "ClientRealIp"\:'$clientRealIp'\,
    "request_domain"\:'$http_host'\,
    "request"\:'$request'\,
    "status"\:'$status'\,
    "body_bytes_sent"\:'$body_bytes_sent'\,
    "http_referer"\:'$http_referer'\,
    "request_uri"\:'$request_uri'\,
    "http_user_agent"\:'$http_user_agent'\,
    "remote_addr"\:'$remote_addr'\,
    "request_time"\:'$request_time'\,
    "request_filename"\:'$request_filename'\,
    "http_x_forwarded_for"\:'$http_x_forwarded_for'\,
    "fastcgi_script_name"\:'$fastcgi_script_name'\,
    "document_root"\:'$document_root'\,
    "request_body"\:'$request_body'\,
    "response_body"\:'$resp_body" }'\;
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
    proxy_set_header   Host  $host;
    open_file_cache max=204800 inactive=20s;
    open_file_cache_min_uses 1;
    open_file_cache_valid 60s;
    proxy_cache_path '${nginx_install_path}'/nginx/cache/proxy_cache levels=1:2 keys_zone=cache_one:100m inactive=1d max_size=30g; #100m和30G，按照服务要求，适当增大
    #################### JumpSever include #########################
    include vhost/*.conf;
    ####################undeifne domain #########################
    server {
        listen 80 default_server;
        server_name _;
        if ($request_method = POST) {
            return 307 https://$host$request_uri;
        }	
        access_log '${nginx_install_path}'/nginx/logs/nginx_undefine.access.log;
        error_log  logs/nginx_error.log;
        error_log  /dev/null crit;
        return 301 https://www.baidu.com/s?wd=wtf;
    }
}
''' >> $nginx_install_path/nginx/conf/nginx.conf
echo '''
########################设置IP白名单############
location / {
    if ( $geo = 1 ){
        return 403;
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
if ($query_string ~ "union.*select.*\(") {
set $block_sql_injections 1;
}
if ($query_string ~ "union.*all.*select.*") {
set $block_sql_injections 1;
}
if ($query_string ~ "concat.*\(") {
set $block_sql_injections 1;
}
if ($block_sql_injections = 1) {
return 403;
}

########################lock file injections防止恶意请求############

set $block_file_injections 0;
if ($query_string ~ "[a-zA-Z0-9_]=http://") {
set $block_file_injections 1;
}
if ($query_string ~ "[a-zA-Z0-9_]=(\.\.//?)+") {
set $block_file_injections 1;
}
if ($query_string ~ "[a-zA-Z0-9_]=/([a-z0-9_.]//?)+") {
set $block_file_injections 1;
}
if ($block_file_injections = 1) {
return 403;
}

########################Block common exploits防止XSS注入############
set $block_common_exploits 0;
if ($query_string ~ "(<|%3C).*script.*(>|%3E)") {
set $block_common_exploits 1;
}
if ($query_string ~ "GLOBALS(=|\[|\%[0-9A-Z]{0,2})") {
set $block_common_exploits 1;
}
if ($query_string ~ "_REQUEST(=|\[|\%[0-9A-Z]{0,2})") {
set $block_common_exploits 1;
}
if ($query_string ~ "proc/self/environ") {
set $block_common_exploits 1;
}
if ($query_string ~ "mosConfig_[a-zA-Z_]{1,21}(=|\%3D)") {
set $block_common_exploits 1;
}
if ($query_string ~ "base64_(en|de)code\(.*\)") {
set $block_common_exploits 1;
}
if ($block_common_exploits = 1) {
return 403;
}

########################Block common exploits #############
set $block_spam 0;
if ($query_string ~ "\b(ultram|unicauca|valium|viagra|vicodin|xanax|ypxaieo)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(erections|hoodia|huronriveracres|impotence|levitra|libido)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(ambien|blue\spill|cialis|cocaine|ejaculation|erectile)\b") {
set $block_spam 1;
}
if ($query_string ~ "\b(lipitor|phentermin|pro[sz]ac|sandyauer|tramadol|troyhamby)\b") {
set $block_spam 1;
}
if ($block_spam = 1) {
return 403;
} 
########################Block user agents  防止用户代理请求 #############
set $block_user_agents 0;
# Dont disable wget if you need it to run cron jobs!
#if ($http_user_agent ~ "Wget") {
# set $block_user_agents 1;
#}

# Disable Akeeba Remote Control 2.5 and earlier
if ($http_user_agent ~ "Indy Library") {
set $block_user_agents 1;
}

# Common bandwidth hoggers and hacking tools.
if ($http_user_agent ~ "libwww-perl") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GetRight") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GetWeb!") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Go!Zilla") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Download Demon") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "Go-Ahead-Got-It") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "TurnitinBot") {
set $block_user_agents 1;
}
if ($http_user_agent ~ "GrabNet") {
set $block_user_agents 1;
}
if ($block_user_agents = 1) {
return 403;
}
''' >> $nginx_install_path/nginx/conf/vhost/commom.server.module
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

service_web_domain=""
service_webapi_domain=""
service_websocket_domain=""
echo '''
 server {
        listen       80;
        server_name  '${service_web_domain}';
        root         /data/nginx/pubcloud-w;
        access_log '${nginx_install_path}'/nginx/logs/'${service_web_domain}'_access.log main_json;
        error_log '${nginx_install_path}'/nginx/logs/'${service_web_domain}'_error.log;
        set $resp_body "";
        body_filter_by_lua '
        local resp_body = string.sub(ngx.arg[1],1,1000)
        ngx.ctx.buffered=(ngx.ctx.buffered or "")..resp_body
        if ngx.arg[2]then
        ngx.var.resp_body = ngx.ctx.buffered
        end';
        location / {
        if ( $geo = 1 ){
            return 403;
        }
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
''' >$nginx_install_path/nginx/conf/vhost/pubcloudapi.conf
echo '''
   server {
        listen       80;
        server_name  '${service_webapi_domain}';
        access_log '${nginx_install_path}'/nginx/logs/'${service_webapi_domain}'_access.log main_json;
        error_log '${nginx_install_path}'/nginx/logs/'${service_webapi_domain}'_error.log;
        set $resp_body "";
        body_filter_by_lua '
        local resp_body = string.sub(ngx.arg[1],1,1000)
        ngx.ctx.buffered=(ngx.ctx.buffered or "")..resp_body
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
''' >$nginx_install_path/nginx/conf/vhost/pubcloud.conf
echo '''
server {
    listen       80;
    server_name  '${service_websocket_domain}';
    access_log '${nginx_install_path}'/nginx/logs/'${service_websocket_domain}'_access.log main_json;
    error_log '${nginx_install_path}'/nginx/logs/'${service_websocket_domain}'_error.log;
    set $resp_body "";
    body_filter_by_lua '
    local resp_body = string.sub(ngx.arg[1],1,1000)
    ngx.ctx.buffered=(ngx.ctx.buffered or "")..resp_body
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
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://127.0.0.1:10001/;
    }
    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
''' >$nginx_install_path/nginx/conf/vhost/pubcloudws.conf
openresty_install 1.19.3.1
read -p "请输入mysqlroot的密码" newMysqlPass
mysql574_install $newMysqlPass