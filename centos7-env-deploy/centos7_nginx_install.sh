#!/bin/bash
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s
geoip="GeoIP.tar.gz"
nginx="nginx-1.15.8.tar.gz"
ngx="ngx_cache_purge-2.3.tar.gz"
openssl="openssl-1.0.2q.tar.gz"
nginxurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/nginx-1.15.8.tar.gz"
ngxurl="http://linux-1254084810.file.myqcloud.com/ngx_cache_purge-2.3.tar.gz"

nginx1.158_install(){
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
}


add_firewalld(){
	echo "添加防火墙..............."
	sleep 1s
	systemctl enable firewalld
	systemctl start firewalld
	firewall-cmd --permanent --zone=public --add-forward-port=port=38789:proto=tcp:toport=3306
	firewall-cmd --permanent --zone=public --add-forward-port=port=40928:proto=tcp:toport=8078
	firewall-cmd --permanent --zone=public --add-port=40928/tcp
	firewall-cmd --permanent --zone=public --add-port=48456/tcp
	firewall-cmd --permanent --zone=public --add-port=80/tcp
	firewall-cmd --permanent --zone=public --add-port=443/tcp
	firewall-cmd --reload
}




