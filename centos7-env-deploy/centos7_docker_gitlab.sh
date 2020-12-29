
install_nginx(){

openresty1.17_install(){
    useradd -s /sbin/nologin www 
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
}
install_docker(){
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum makecache fast 
    sudo yum install docker-ce -y
    yum list docker-ce.x86_64  --showduplicates | sort -r
    sudo yum install docker-ce-19.03.9-3.el7 -y
    sudo systemctl start docker
    systemctl enable docker
}
pull_gitlab(){
    docker pull gitlab/gitlab-ce:13.4.3-ce.0
}
run_gitlab(){
    mkdir -p /opt/gitlab/{etc,log,data}
    docker run \
        --detach \
        --publish 8443:443 \
        --publish 8092:80 \
        --name gitlab \
        --restart unless-stopped \
        -v /opt/gitlab/etc:/etc/gitlab \
        -v /opt/gitlab/log:/var/log/gitlab \
        -v /opt/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce
}
vim /opt/gitlab/etc/gitlab.rb
docker exec gitlab gitlab-ctl reconfigure
chown -R www:www /opt/gitlab/data/gitlab-workhorse/