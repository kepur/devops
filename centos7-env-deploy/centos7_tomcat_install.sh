
#!/bin/bash
jdkurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/jdk-8u191-linux-x64.tar.gz"
jdk180191_install(){
	echo "正在执行jdk安装"
	cd /opt/
	tar -zxvf $jdk -C /opt/java
	echo '''
	JAVA_HOME=/opt/java/jdk1.8.0_191
	JRE_HOME=/opt/java/jdk1.8.0_191/jre
	PATH=$JAVA_HOME/bin:$PATH:$JRE_HOME/bin
	CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
	''' >> /etc/profile
	chmod 777 /etc/profile
	source /etc/profile
	echo "java环境安装"
	sleep 1s
	java
}
tomcat8.5.23_install(){
	echo "apache-tomcat8环境安装"
	cd /opt/
	tar -zxvf apache-tomcat-8.5.23.tar.gz -C /opt/java/
	sed -i '2i\JAVA_HOME=/opt/java/jdk1.8.0_191\nJRE_HOME=/opt/java/jdk1.8.0_191/jre' /opt/java/apache-tomcat-8.5.23/bin/setclasspath.sh
	sed -i "s/8080/8085/g" /opt/java/apache-tomcat-8.5.23/conf/server.xml
	echo '''
	[Unit]
	Description=tomcat
	After=network.target
	
	[Service]
	Type=oneshot
	ExecStart=/opt/java/apache-tomcat-8.5.23/bin/startup.sh   //自已的tomcat目录
	ExecStop=/opt/java/apache-tomcat-8.5.23/bin/shutdown.sh
	ExecReload=/bin/kill -s HUP $MAINPID
	RemainAfterExit=yes
	
	[Install]
	WantedBy=multi-user.target
	''' >> /lib/systemd/system/tomcat.service
	systemctl start tomcat.service
	systemctl enable tomcat.service
}