#!/bin/bash
redis406_install(){
	echo "正在执行redis安装"
	sleep 1s
	tar -zxvf redis-4.0.6.tar.gz
	cd \redis-4.0.6\
	make MALLOC=libc
	cd \src
	make install 
	cp /opt/redis-4.0.6/redis.conf /etc/redis/6379.conf
	cp /opt/redis-4.0.6/utils/redis_init_script /etc/init.d/redisd
	sed -i '2i\
	# chkconfig:   2345 90 10
	# description:  Redis is a persistent key-value database' /etc/init.d/redisd
	echo '''
	[Unit]
	Description=redis-server
	After=network.target

	[Service]
	Type=forking
	ExecStart=/usr/local/bin/redis-server /etc/redis/6379.conf
	PrivateTmp=true

	[Install]
	WantedBy=multi-user.target
	''' >> /lib/systemd/system/redis.service
	systemctl enable redis.service
	systemctl restart redis.service
}

#https://download.redis.io/releases/redis-6.2.3.tar.gz?_ga=2.171752800.1114973999.1621433299-296576591.1621433299
redis_root_url="https://download.redis.io/releases/"
pkg_dir=/opt/pkg_dir
if [ ! -d "/opt/pkg_dir" ];then
  mkdir -p /opt/pkg_dir
  else
  echo "文件夹已经存在"
fi
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
	Type=forking
	ExecStart=/usr/local/bin/redis-server /etc/redis/6379.conf
	PrivateTmp=true

	[Install]
	WantedBy=multi-user.target
	''' >> /lib/systemd/system/redis.service
	systemctl enable redis.service
	systemctl restart redis.service

}

function menu_choice {
	clear 
	echo
	echo -e "\t\t. 选择python安装的版本"
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
