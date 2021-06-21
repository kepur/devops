
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
    if [[ $openresty_version =~ "1.19.9" ]]
    then
        echo "支持的版本"
        sed -i 's/\.openssl\///g' $pkg_dir/openresty-$openresty_version/bundle/nginx-1.19.9/auto/lib/openssl/conf
        sed -i 's/openssl\/include\/openssl\/ssl.h/include\/openssl\/ssl.h/g' $pkg_dir/openresty-$openresty_version/bundle/nginx-1.19.9/auto/lib/openssl/conf
    else
        echo "非1.19.9版本" && sleep 2s
    fi
    if [[ $openresty_version =~ "1.19.3" ]]
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
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
worker_processes=`expr $cores \* 2` 
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
echo '''
server {
    listen       443 ssl;
    server_name ezzysleep.com www.ezzysleep.com;
    ssl_certificate  /opt/nginx/conf/ssl/ezzysleep.crt;
    ssl_certificate_key /opt/nginx/conf/ssl/ezzysleep.key;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    include /opt/nginx/conf/vhost/common.server.module;
    access_log /opt/nginx/logs/ezzysleep.access.log main;
    access_log /opt/nginx/logs/ezzysleep.access_json.log main_json;
    error_log /opt/nginx/logs/ezzysleep.error.log;
    lua_need_request_body on;
    set $allow false;
    set $resp_body "";
    body_filter_by_lua '
     local resp_body = string.sub(ngx.arg[1],1,1000)
     ngx.ctx.buffered=(ngx.ctx.buffered or "")..resp_body
     if ngx.arg[2]then
        ngx.var.resp_body = ngx.ctx.buffered
     end
     ';
    location / {
        #proxy_set_header X-Forwarded-Proto  $scheme;
        #proxy_set_header   Host $http_host:$server_port;
        proxy_set_header X-Real-IP $http_x_forwarded_for;
        proxy_read_timeout 300;
        proxy_pass http://ezzysleep;
        recursive_error_pages on;
    }
    location ~ .*\.(php|cgi|jsp|asp|aspx|apk)$ {
        return 301 http://www.baidu.com/s?wd=helloword;
    }
    location /hello{
        default_type 'text.plain';
        content_by_lua 'ngx.say("hello,lua")';
    }
}
''' >$nginx_install_path/nginx/conf/vhost/example.conf
}
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
#botpanel
16.162.45.222 0;
}
''' >> $nginx_install_path/nginx/conf/vhost/whiteip.map
openresty_install 1.19.3.1