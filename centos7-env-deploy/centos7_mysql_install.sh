#!/bin/bash
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s
mysql="mysql57-community-release-el7-8.noarch.rpm"
mysqlurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
echo "正在执行mysql安装"
cd /opt/
mysql574_install
mysql574_install(){
	read -p "请输入mysqlroot的密码" NewPass
	rpm -ivh mysql57-community-release-el7-8.noarch.rpm
	yum -y install mysql-server
	service mysqld restart
	systemctl enable mysqld.service
	oldpass=`grep pass /var/log/mysqld.log | awk '{print $NF}'`
	/usr/local/mysql/bin/mysql --connect-expired-password -uroot -p${oldpass} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${NewPass}"';"
	/usr/local/mysql/bin/mysql --connect-expired-password -uroot -p${oldpass} -e " flush privileges;"
}

