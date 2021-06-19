wget https://github-releases.githubusercontent.com/924551/dc8e8180-ad39-11eb-8ade-b458a8d406d4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210519%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210519T151711Z&X-Amz-Expires=300&X-Amz-Signature=2ec2cb2dbae640467b54809df133a77bb4f9d0c6a9621f0a2217f6128bbaa7ff&X-Amz-SignedHeaders=host&actor_id=39118162&key_id=0&repo_id=924551&response-content-disposition=attachment%3B%20filename%3Drabbitmq-server-3.8.16-1.el7.noarch.rpm&response-content-type=application%2Foctet-stream
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
            echo "Failed to download $Erlang \n 下载$Redis失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Redis安装"
	tar -zxvf $Erlang
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
