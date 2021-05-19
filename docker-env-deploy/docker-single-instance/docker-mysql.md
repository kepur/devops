docker pull mysql:5.7


mkdir -p /opt/mysql/conf 
mkdir -p /opt/mysql/data 
mkdir -p /opt/mysql/log


docker run -p 33306:3306 --name mysql -v /opt/mysql/conf:/etc/mysql -v /opt/mysql/log:/var/log/mysql -v /opt/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=Aa123.com -d mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

yum install -y lrzsz
rz pronsearch


docker cp pronsearch.sql mysql:/root/
docker exec -it mysql bash



docker pull wolihi/flask-pronsearch-web:v1.0
#指定运行环境文件
docker run --env-file .env -p 5099:7788 --name pronsearch -d wolihi/flask-pronsearch-web:v1.0
#指定系统变量
docker run -p 5099:7788 --name pronsearch --env db_host='172.17.0.3' -e db_port='3306' -e db_name='pronsearch' -e db_username='root' -e db_password='Aa123.com' -d wolihi/flask-pronsearch-web:v1.0

docker run -p 5099:7788 --name pronsearch --env db_host='172.17.0.3' -e db_port='3306' -e db_name='pronsearch' -e db_username='root' -e db_password='Aa123.com' -d wolihi/flask-pronsearch-web:v1.0

#测试
docker exec -it pronsearch /bin/bash
apt-get update
apt-get install telnet -y



