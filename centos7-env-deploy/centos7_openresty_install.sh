openresty117_install(){
    #安装openresty nginx
    useradd -s /sbin/nologin www 
    mkdir -p /usr/local/openssl
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
    timedatectl set-timezone Asia/Shanghai
    ntpdate -q 1.cn.pool.ntp.org
    systemctl start ntpd
    systemctl enable ntpd
    systemctl enable nginx
}
# https://openresty.org/download/openresty-1.19.3.2.tar.gz
# https://openresty.org/download/openresty-1.19.3.1.tar.gz
# https://openresty.org/download/openresty-1.17.8.2.tar.gz
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
pkg_dir=/opt/pkg_dir
openresty_root_url="https://openresty.org/download/"
nginx_install_path=/opt
openresty_install(){
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
local cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
local openfilelimits=$( ulimit -a|grep "open files" )
mv $nginx_install_path/nginx/conf/nginx.conf $nginx_install_path/nginx/conf/nginx.confbak
echo '''
user  www;
worker_processes  '${cores}';
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
    log_format  main  '$http_x_forwarded_for- $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    log_format  main_json '{"time_local":[$time_local],
    "ClientRealIp":"$clientRealIp",
    "request_domain":"$http_host",
    "request":"$request",
    "status":"$status",
    "body_bytes_sent":"$body_bytes_sent",
    "http_referer":"$http_referer",
    "request_uri":"$request_uri",
    "http_user_agent":"$http_user_agent",
    "remote_addr":"$remote_addr",
    "request_time":"$request_time",
    "request_filename":"$request_filename",
    "http_x_forwarded_for":"$http_x_forwarded_for",
    "fastcgi_script_name":"$fastcgi_script_name",
    "document_root":"$document_root",
    "request_body":"$request_body",
    "response_body":"$resp_body"}';
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
}
openresty_install 1.19.3.1