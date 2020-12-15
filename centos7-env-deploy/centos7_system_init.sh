#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
options=("Option 1" "Option 2" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "1.系统初始化下载文件")
            echo "you chose choice 1"
            ;;
        "2.下载openssl")
            echo "you chose choice 2"
			download_file
            ;;
        "3.安装openssl")
			openssl_install
            ;;
        "4.")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
system_init(){
	yum update -y && yum install gcc pcre pcre-devel zlib-devel openssl perl openssl-devel -y
  	clear
	echo
    echo "###############################################################"
    echo "# CentOS  Installer                                     #"
    echo "# System Supported: CentOS 6+ / Debian 7+ / Ubuntu 12+        #"
    echo "# Intro: https://teddysun.com/448.html                        #"
    echo "# Author: Teddysun <i@teddysun.com>                           #"
    echo "###############################################################"
    echo
	echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s
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
	sed -i '/^Port.*/d' /etc/ssh/sshd_config && echo "Port 38245" >> /etc/ssh/sshd_config
	setenforce 0
	systemctl restart sshd.service
}


