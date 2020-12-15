安装mongo3.4
mongo3.4_install(){
	echo >>'''
	[mongodb-org-3.4]  
	name=MongoDB Repository  
	baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/  
	gpgcheck=1  
	enabled=1  
	gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
	''' /etc/yum.repos.d/mongodb-org-3.4.repo
	yum makecache
	yum -y install mongodb-org
	whereis mongod
	systemctl enable mongod.service
	systemctl start mongod.service
}

