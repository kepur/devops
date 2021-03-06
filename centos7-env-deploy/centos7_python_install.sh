

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
	pip2 install --upgrade pip
	pip2 install pywinrm --ignore-installed requests 
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
python_anaconda_install(){
	curl https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh|sh
}
#PYTHON3
python_root_url="https://www.python.org/ftp/python/"
pkg_dir=/opt/pkg_dir
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
function menu_choice {
	clear 
	echo
	echo -e "\t\t. 选择python安装的版本"
	echo -e "\t1.  python3.7.3安装"
	echo -e "\t2.  python3.7.7安装"
	echo -e "\t3.  python3.7.9安装"
	echo -e "\t4.  python3.8.3安装"
	echo -e "\t5.  python3.8.7安装"
	echo -e "\t6.  python3.8.9安装"
	echo -e "\t7.  python3.9.0安装"
	echo -e "\t8.  python3.9.2安装"
	echo -e "\t9.  python3.9.4安装"
	echo -e "\t0. Exit menu\n\n"
	#-en 选项会去掉末尾的换行符，这让菜单看起来更专业一些
	echo -en "\t\t Enter option:" 
	#read 命令读取用户输入
	read -n 1 choice_version
	}
while [ 1 ]
	do 
		menu_choice
		case $choice_version in
		0)
			break ;;
		1)
			python_install 3.7.3;;
		2)
			python_install 3.7.7;;
		3)
			python_install 3.7.9;;
		4)
			python_install 3.8.3;;
		5)
			python_install 3.8.7;;
		6)
			python_install 3.8.9;;
		7)
			python_install 3.9.0;;
		8)
			python_install 3.9.2;;
		9)
			python_install 3.9.4;;
		*)
			clear
			echo "sorry,wrong selection" ;;
		esac
		echo -en "\n\n\t\thit any to contunue"
		read -n 1 line
done
