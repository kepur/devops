#!/bin/bash
select option in "${mysqloptions[@]}"
do
    case $option in
        "1.安装mysql5.7")
            echo "you chose choice 1"
            ;;
        "2.")
            echo "you chose choice 2"
            ;;
        "3.安装openssl")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "4.")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s

mysql="mysql57-community-release-el7-8.noarch.rpm"
mysqlurl="https://linux-1254084810.cos.ap-chengdu.myqcloud.com/mysql57-community-release-el7-8.noarch.rpm"
echo "正在执行mysql安装"
cd /opt/


mysql5.7.4_install(){
	read -p "请输入mysqlroot的密码" NewPass
	rpm -ivh mysql57-community-release-el7-8.noarch.rpm
	yum -y install mysql-server
	service mysqld restart
	systemctl enable mysqld.service
	oldpass=`grep pass /var/log/mysqld.log | awk '{print $NF}'`
	/usr/local/mysql/bin/mysql --connect-expired-password -uroot -p${oldpass} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${NewPass}"';"
	/usr/local/mysql/bin/mysql --connect-expired-password -uroot -p${oldpass} -e " flush privileges;"
}

