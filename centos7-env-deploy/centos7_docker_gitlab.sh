
install_nginx(){
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
    gitlab/gitlab-ce:13.4.3-ce.0
}
vim /opt/gitlab/etc/gitlab.rb
docker exec gitlab gitlab-ctl reconfigure
chown -R www:www /opt/gitlab/data/gitlab-workhorse/


vi /etc/yum.repos.d/gitlab-ce.repo

[gitlab-ce]
name=gitlab-ce
# 清华大学的镜像源
baseurl=http://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7
repo_gpgcheck=0
gpgcheck=0
enabled=1
gpgkey=https://packages.gitlab.com/gpg.key


# 安装和配置openssh
sudo yum install -y curl policycoreutils-python openssh-server openssh-clients
sudo yum install postfix
sudo systemctl enable postfix
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
# 安装和配置邮件服务
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
vim /etc/postfix/main.cf
inet_protocols = ipv4
inet_interfaces = all

yum install -y gitlab-ce-13.4.3

修改
/etc/gitlab/gitlab.rc
external_url "https://gitlab.example.com"

external_url "http://www.legendchinese.com"
gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab-ctl start

gitlab-ctl reconfigure


https://mirrors.tuna.tsinghua.edu.cn/gitlab-ee/yum/el7/gitlab-ee-13.4.3-ee.0.el7.x86_64.rpm
rpm -i gitlab-ee-13.4.3-ee.0.el7.x86_64.rpm

参考文档
https://blog.csdn.net/u010375456/article/details/94965423
下载配置文件
https://gitlab.com/gitlab-org/gitlab-recipes/-/blob/master/web-server/nginx/gitlab-omnibus-ssl-nginx.conf

sudo yum install firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload



git clone ssh://git@git-scm.bitbaseotc.com:otc/bitbase-api.git
git clone ssh://git@192.168.10.10:23/test-devops/LinuxArchitect.git

git@git-scm.bitbaseotc.com:otc/bitbase-api.git
https://git-scm.bitbaseotc.com/otc/bitbase-api.git


