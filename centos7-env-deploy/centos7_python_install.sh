yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
yum groupinstall "Development tools"  -y
yum install unzip zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel  readline-devel  -y
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libffi-devel-3.0.13-18.el7.x86_64.rpm
yum install libffi-devel -y
cd /opt/
ansible_insall(){
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



if [ -f "/opt/$openssl" ];then
	echo "文件 $openssl 存在"
else 
	echo "文件 $openssl 不存在将自动下载" && wget -P /opt/  $pythonurl
fi


tar -zxvf $openssl
cd openssl-1.0.2r
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
cd /opt/
python3.7.3_install(){
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



