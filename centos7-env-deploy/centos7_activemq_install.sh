activemq5.15_install(){
	mkdir -p /opt/activemq
	tar -zxvf apache-activemq-5.15.8-bin.tar.gz -C /opt/activemq/
	mv /opt/activemq/apache-activemq-5.15.8/* /opt/activemq/
	/opt/activemq/bin/linux-x86-64/activemq start
    /opt/activemq/bin/linux-x86-64/activemq status
}