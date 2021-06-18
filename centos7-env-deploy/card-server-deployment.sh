
workdir=/opt/pkg_dir/
pkg_dir=/opt/pkg_dir
if [ ! -d "/opt/pkg_dir" ];then
  mkdir -p /opt/pkg_dir
  else
  echo "文件夹已经存在"
fi
openssl_root_url="https://www.openssl.org/source/"
python_root_url="https://www.python.org/ftp/python/"


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
mysql574_install(){
    cd /opt/
    echo "正在执行mysql安装"
    mysql="mysql57-community-release-el7-8.noarch.rpm"
    mysqlurl="https://jp-1301785062.cos.ap-tokyo.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
    wget $mysqlurl

	read -p "请输入mysqlroot的密码" NewPass
	rpm -ivh mysql57-community-release-el7-8.noarch.rpm
	yum -y install mysql-server
	service mysqld restart
	systemctl enable mysqld.services
	oldpass=`grep pass /var/log/mysqld.log | awk '{print $NF}'`
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${NewPass}"';"
	/usr/bin/mysql --connect-expired-password -uroot -p${oldpass} -e " flush privileges;"
}