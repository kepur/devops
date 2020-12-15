例子
docker run -d -p 80:80 --read-only -v $(pwd)/nginx-cache:/var/cache/nginx -v $(pwd)/nginx-pid:/var/run nginx

mkdir -p /opt/docker/nginx/conf
mkdir -p /opt/docker/nginx/cert
mkdir -p /opt/docker/nginx/vhost
mkdir -p /opt/docker/nginx/logs

docker run -d --name nginx \
    -p 80:80 \
    -p 443:443 \
    -v /opt/docker/nginx/conf/nginx.conf:/opt/nginx/conf/nginx.conf:ro \
    -v /opt/docker/nginx/vhost:/opt/nginx/conf/vhost:ro \
    -v /opt/docker/nginx/cert:/opt/nginx/cert:ro \
    -v /opt/docker/nginx/logs:/opt/nginx/logs \
    --restart=always \
    --name=gateway \
    --network=net1 \
    wolihi/nginx
	

nginx主配置文件
-v /opt/docker/nginx/conf/nginx.conf:/opt/nginx/conf/nginx.conf
nginx虚拟主机配置文件
-v /opt/docker/nginx/vhost:/opt/nginx/conf/vhost
nginx证书配置文件
-v /opt/docker/nginx/cert:/opt/nginx/cert
nginx日志配置文件
-v /opt/docker/nginx/logs:/opt/nginx/logs


多网站 配置文件例子
下面upstream是负载均衡
upstream seokfz{
        server 127.0.0.1:5010;
        server 127.0.0.1:5011;
        server 127.0.0.1:5012;
        server 127.0.0.1:5013;
}
server {
        listen 80;
		#监听域名一定要配置
        server_name *.seokfz.com seokfz.com;
		#开启443就按下面配置好重定向
        rewrite ^(.*)$ https://www.seokfz.com$1 permanent;
}
    server {
        listen 443;
        server_name  www.seokfz.com;
        access_log logs/seokfz.com.access.log;
        error_log logs/devseo.error.log;
#       if ($host != 'seokfz.com' ) {
#               rewrite ^/(.*)$ https://www.seokfz.com/$1 permanent;
#        }
        ssl on;
		#把你的证书文件放入/opt/nginx/cert目录 并在下面指定好路径
        ssl_certificate /opt/nginx/cert/www.seokfz.com.pem; #上传的证书pem文件
        ssl_certificate_key /opt/nginx/cert/www.seokfz.com.key; # 上传的证书key文件
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #设置传输协议 苹果要求必须满足 TLSv1.2 这里满足了 [2.传输协议的要求]
        ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!MEDIUM:!LOW:!aNULL:!eNULL; # 签字算法 [3.>签字算法的要求]
        ssl_prefer_server_ciphers on;
        location / {
                root /opt/web3;
                index index.html index.htm;
                proxy_pass http://seokfz;
        }
}