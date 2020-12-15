maven3.6.0_install(){
	echo "安装mvn..............."
	wget http://mirror.rise.ph/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
	mkdir -p /opt/maven
	tar -zxvf apache-maven-3.6.0-bin.tar.gz -C /opt/maven/
	mv /opt/maven/apache-maven-3.6.0/* /opt/maven/
	echo '''
	export M2_HOME=/opt/maven
	export PATH=$PATH:$JAVA_HOME/bin:$M2_HOME/bin
	''' >> /etc/profile
	source /etc/profile
}

