#!/bin/bash
redisurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/redis-4.0.6.tar.gz"
redis="https://download.redis.io/releases/redis-6.2.3.tar.gz"

redis4.0.6_install(){
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
redis5.0_install(){
	tar -zxvf redis-4.0.6.tar.gz
	cd /opt/redis-4.0.6
	make MALLOC=libc
	cd /opt/redis-4.0.6/src
	make install 
	mkdir -p /etc/redis
	cp /opt/redis-4.0.6/redis.conf /etc/redis/6379.conf
	cp /opt/redis-4.0.6/utils/redis_init_script /etc/init.d/redisd
	echo "net.core.somaxconn = 2048" >> /etc/sysctl.conf 
	echo 511 > /proc/sys/net/core/somaxconn
	echo 2 > /proc/sys/vm/overcommit_memory
	echo 60 > /proc/sys/vm/overcommit_ratio
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	sysctl -p
	sed -i '2i\
	# chkconfig:   2345 90 10
	# description:  Redis is a persistent key-value database' /etc/init.d/redisd
	echo '''
	[Unit]
	Description=The redis-server Process Manager
	After=syslog.target network.target

	[Service]
	Type=simple
	PIDFile=/var/run/redis_6379.pid
	ExecStart=/usr/local/bin/redis-server /etc/redis/6379.conf 
	ExecReload=/bin/kill -USR2 $MAINPID
	ExecStop=/bin/kill -SIGINT $MAINPID
	[Install]
	WantedBy=multi-user.target
	''' >> /lib/systemd/system/redis.service
	systemctl daemon-reload
	systemctl enable redis.service
	systemctl start redis.service
}