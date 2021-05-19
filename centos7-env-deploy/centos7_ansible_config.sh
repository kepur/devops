#!/bin/sh
sys_init(){
    yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel libffi-devel -y
    yum groupinstall "Development tools"  -y 
    yum install unzip zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel  readline-devel  -y
    mkdir -p $pkg_dir && cd $pkg_dir
}
#PYTHON2
pkg_dir=/opt/pkg_dir
openssl="openssl-1.1.1g.tar.gz"
setuptools="setuptools-33.1.1.zip"
pip="pip-8.1.0.tar.gz"

#PYTHON3
python_root_url="https://www.python.org/ftp/python/"

#https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz

download_file(){
    wget https://api.qsmsyd.com/centos7-env-deploy/common/ansible_batch.py
    local opnssl_root_url="https://www.openssl.org/source/"
    local setuptools_root_url="https://api.qsmsyd.com/download/"
    local pip_root_url="https://api.qsmsyd.com/download/"
	if [ -f "$pkg_dir$openssl" ];then
		echo " 文件 $openssl 找到 "
	else
		echo "文件 $openssl 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${opnssl_root_url}/$openssl -P $pkg_dir/ ; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    if [ -f "$pkg_dir$setuptools" ];then
		echo " 文件 $setuptools 找到 "
	else
		echo "文件 $setuptools 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${setuptools_root_url}/$setuptools -P $pkg_dir/; then
            echo "Failed to download $setuptools \n 下载$setuptools失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    if [ -f "$pkg_dir$pip" ];then
		echo " 文件 $pip 找到 "
	else
		echo "文件 $pip 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${pip_root_url}/$pip -P $pkg_dir/; then
            echo "Failed to download $pip \n 下载$pip, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
}
openssl_install(){
	cd $pkg_dir && echo "正在执行openssl安装"
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
py27_ansible_insall(){
    cd $pkg_dir && echo "正在执行ansible安装"
	unzip $pkg_dir/$setuptools -d $pkg_dir
	tar -zxvf $pkg_dir/$pip -C $pkg_dir
	cd $pkg_dir/setuptools-33.1.1 && python2.7  setup.py  install
	cd $pkg_dir/pip-8.1.0 && python2.7 setup.py install
	yum install -y ansible
	pip2 install --upgrade pip
	pip2 install pywinrm
}
python373_install(){
    if [ -f "$pkg_dir$python" ];then
		echo " 文件 $python 找到 "
	else
		echo "文件 $python 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${python_root_url}/3.7.3/$python -P $pkg_dir/; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行python安装"
	tar -xvf $python && cd Python-3.7.3
	./configure --prefix=/usr/local/python3.7.3/ --enable--shared --with-openssl=/usr/local/openssl
	make && make install
	rm -rf /usr/bin/python /usr/bin/pip
	ln -s /usr/local/python3.7.3/bin/python3 /usr/bin/python
	ln -s /usr/local/python3.7.3/bin/pip3 /usr/bin/pip
	sed -i 's/python/python2/g' /usr/bin/yum
	sed -i 's/python/python2/g' /usr/libexec/urlgrabber-ext-down
}
#https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz
python_install(){
	python_version=$1
    echo "安装python版本为:"$python_version
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

python_choice(){
	function menu_choice {
		clear 
		echo
		echo -e "\t\t\t 选择需要安装的Python版本"
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
		echo -en "\t\t Enter option:" 
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
}
function menu {
clear 
echo
echo -e "\t\t. Centos7 python ansible安装脚本"
echo -e "\t1. 系统初始化"
echo -e "\t2. 下载文件"
echo -e "\t3. 安装openssl" 
echo -e "\t4. 安装py27_ansible" 
echo -e "\t5. 安装python3" 
echo -e "\t0. Exit menu\n\n"
echo -en "\t\t Enter option:" 
read -n 1 option
}
while [ 1 ]
do 
    menu
    case $option in
    0)
        break ;;
    1)
        sys_init  ;;
    2)
        download_file ;;
    3)
        openssl_install ;;
	4)
        py27_ansible_insall ;;
	5)
        python_choice ;;
    *)
        clear
        echo "sorry,wrong selection" ;;
    esac
    echo -en "\n\n\t\thit any to contunue"
    read -n 1 line
done