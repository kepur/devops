zookeeper3.5.4_install(){
	cd /opt/
	mkdir -p /opt/zookeeper
	tar -zxvf zookeeper-3.5.4-beta.tar.gz -c /opt/zookeeper/
	mv /opt/zookeeper/zookeeper-3.5.4-beta/* /opt/zookeeper/
	mkdir -p /opt/zookeeper/data
	mkdir -p /opt/zookeeper/logs
	cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
	sed -i 's/tmp\/zookeeper/opt\/zookeeper\/data/g' /opt/zookeeper/conf/zoo.cfg
	echo '''
	dataLogDir=/opt/zookeeper/logs
	server.1=10.25.96.4:2888:3888
	server.2=10.25.96.3:2888:3888
	server.3=10.25.96.5:2888:3888
	''' >> /opt/zookeeper/conf/zoo.cfg
	echo '1' > /opt/zookeeper/data/myid
	/opt/zookeeper/bin/zkServer.sh start
}

