#wget https://github-releases.githubusercontent.com/924551/dc8e8180-ad39-11eb-8ade-b458a8d406d4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210519%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210519T151711Z&X-Amz-Expires=300&X-Amz-Signature=2ec2cb2dbae640467b54809df133a77bb4f9d0c6a9621f0a2217f6128bbaa7ff&X-Amz-SignedHeaders=host&actor_id=39118162&key_id=0&repo_id=924551&response-content-disposition=attachment%3B%20filename%3Drabbitmq-server-3.8.16-1.el7.noarch.rpm&response-content-type=application%2Foctet-stream
#https://erlang.org/download/otp_src_24.0.tar.gz
erlang_root_url="https://erlang.org/download/"
pkg_dir=/opt/pkg_dir
if [ ! -d "/opt/pkg_dir" ];then
  mkdir -p /opt/pkg_dir
  else
  echo "文件夹已经存在"
fi
erlang_install(){
    erlang_version=$1
	echo $erlang_version
	Erlang=otp_src_$erlang_version.tar.gz
	echo "$Erlang"
	if [ -f "$pkg_dir$Erlang" ];then
		echo " 文件 $Erlang 找到 "
	else
		echo "文件 $Erlang 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${erlang_root_url}/$Erlang -P $pkg_dir/; then
            echo "Failed to download $Erlang \n 下载$Erlang失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Erlang安装"
	tar -zxvf $Erlang
	mv otp_src_$erlang_version /usr/local/
	cd /usr/local/otp_src_$erlang_version
	./configure --prefix=/usr/local/erlang/ --with-ssl=/usr/local/openssl
	make install 
	echo 'export PATH=$PATH:/usr/local/erlang/bin' >>/etc/profile
	source /etc/profile
	ln -s /usr/local/erlang/bin/erl /usr/bin/erl
}

# rabbitmq-server-3.8.18-beta.1.tar.xz
# https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.17/rabbitmq-server-generic-unix-3.8.17.tar.xz
# https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.16/rabbitmq-server-generic-unix-3.8.16.tar.xz
# https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.15/rabbitmq-server-generic-unix-3.7.15.tar.xz
rabbitmq_root_url='https://github.com/rabbitmq/rabbitmq-server/releases/download/'
rabbit_mq_install(){
    rabbitmq_version=$1
	echo $rabbitmq_version
	rabbitmq=rabbitmq-server-generic-unix-$rabbitmq_version.tar.xz
	echo "$rabbitmq"
	if [ -f "$pkg_dir$rabbitmq" ];then
		echo " 文件 $rabbitmq 找到 "
	else
		echo "文件 $rabbitmq 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${erlang_root_url}/$rabbitmq_version/$rabbitmq -P $pkg_dir/; then
            echo "Failed to download $rabbitmq \n 下载$rabbitmq, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Erlang安装"
	yum install -y xz && xz -d $rabbitmq
	tar -xvf rabbitmq-server-generic-unix-$rabbitmq_version.tar
	mv rabbitmq_server-$rabbitmq_version/ /usr/local/
	mv /usr/local/rabbitmq_server-$rabbitmq_version/ /usr/local/rabbitmq
	echo 'export PATH=$PATH:/usr/local/rabbitmq/sbin' >>/etc/profile
	source /etc/profile
	rabbitmq-server -detached
	rabbitmq-plugins enable rabbitmq_management
}

#earlang 22.0 rabbitmq 37.15 
function menu_choice {
	clear 
	echo
	echo -e "\t\t. 选择Redis安装的版本"
	echo -e "\t1.  redis 4.0.6安装"
	echo -e "\t2.  redis 6.2.3安装"
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
			redis_install 4.0.6;;
		2)
			redis_install 6.2.3;;
		*)
			clear
			echo "sorry,wrong selection" ;;
		esac
		echo -en "\n\n\t\thit any to contunue"
		read -n 1 line
done
