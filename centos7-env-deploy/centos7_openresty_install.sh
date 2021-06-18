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
    ./configure --user=www --group=www  --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-openssl=/usr/local/openssl --prefix=/opt/nginx
    cd 
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
    systemctl enable ntpd
    systemctl enable nginx
}
openresty_install 1.19.3.1
