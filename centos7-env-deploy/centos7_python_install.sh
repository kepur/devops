yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
yum groupinstall "Development tools"  -y
yum install unzip zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel  readline-devel  -y
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libffi-devel-3.0.13-18.el7.x86_64.rpm
yum install libffi-devel -y
cd /opt/
py27_ansible_insall(){
	wget https://api.qsmsyd.com/download/pip-8.1.0.tar.gz
	wget https://api.qsmsyd.com/download/setuptools-33.1.1.zip
	unzip setuptools-33.1.1.zip
	tar zxvf pip-8.1.0.tar.gz
	cd setuptools-33.1.1
	python2.7  setup.py  install
	cd pip-8.1.0
	python2.7 setup.py install
	pip install --upgrade pip
	pip2 install pywinrm
}

py39_ansible_insall(){
	wget https://api.qsmsyd.com/download/pip-8.1.0.tar.gz
	wget https://api.qsmsyd.com/download/setuptools-33.1.1.zip
	unzip setuptools-33.1.1.zip
	tar zxvf pip-8.1.0.tar.gz
	cd setuptools-33.1.1
	python2.7  setup.py  install
	cd pip-8.1.0
	python2.7 setup.py install
	pip install --upgrade pip
	pip2 install pywinrm
}



download_file(){
	cd /opt/
	#wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
	openssl="openssl-1.1.1g.tar.gz"
    local download_root_url="https://www.openssl.org/source/"

	if [ -f "/opt/pkg_dir/$openssl" ];then
		echo " 文件 $openssl 找到 "
	else
		echo "文件 $openssl 不存在将自动下载" 
		if ! wget -c -t3 -T60 -P ${download_root_url}/$openssl  $pkg_dir/; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到/opt/pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
}
openssl_install(){
	cd /opt/
	echo "正在执行openssl安装"
	tar -zxvf openssl-1.1.1g.tar.gz
	cd openssl-1.1.1g
	useradd -s /sbin/nologin www 
	mkdir -p /usr/local/openssl
	./config --prefix=/usr/local/openssl
	make && make install
	\mv /usr/bin/openssl /usr/bin/openssl.old
	\mv /usr/include/openssl/ /usr/include/openssl.old
	ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
	ln -s /usr/local/openssl/include/openssl/ /usr/include/openssl
	echo "/usr/local/openssl/lib/">>/etc/ld.so.conf
	ldconfig
	openssl version -a
}
python3.9.1_install(){
	https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tar.xz
	tar -xvf Python-3.9.1.tar.xz
	cd Python-3.9.1
	./configure --prefix=/usr/local/python3.9.1/ --enable--shared --with-openssl=/usr/local/openssl
	make && make install
	rm -rf /usr/bin/python /usr/bin/pip
	ln -s /usr/local/python3.9.1/bin/python3 /usr/bin/python
	ln -s /usr/local/python3.9.1/bin/pip3 /usr/bin/pip
	sed -i 's/python/python2/g' /usr/bin/yum
	sed -i 's/python/python2/g' /usr/libexec/urlgrabber-ext-down
}
python3.7.3_install(){
	wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
	tar -xvf Python-3.7.3.tar.xz
	cd Python-3.7.3
	./configure --prefix=/usr/local/python3.7.3/ --enable--shared --with-openssl=/usr/local/openssl
	make && make install
	rm -rf /usr/bin/python /usr/bin/pip
	ln -s /usr/local/python3.7.3/bin/python3 /usr/bin/python
	ln -s /usr/local/python3.7.3/bin/pip3 /usr/bin/pip
	sed -i 's/python/python2/g' /usr/bin/yum
	sed -i 's/python/python2/g' /usr/libexec/urlgrabber-ext-down
}




