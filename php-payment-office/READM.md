
##准备好cron文件设置crontab
1 0,1,6,12 * * * /usr/local/bin/php /usr/local/kubernetes/volumes/php-payment-data/www/cli.php report release
1 0,1,6,12 * * * /usr/local/bin/php /usr/local/kubernetes/volumes/php-payment-data/www_zf2860/cli.php report
0 */1 * * * /usr/local/bin/php /usr/local/kubernetes/volumes/php-payment-data/www_zf2860/cli.php merchantConvertRate
0 7 * * * /usr/local/bin/php /usr/local/kubernetes/volumes/php-payment-data/www_zf2860/cli.php merchantConvertRateOld
*/5 * * * * /usr/local/bin/php /usr/local/kubernetes/volumes/php-payment-data/www_zf2860/cli.php calculateBalance

---
#Dockerfile相关设置

设置语言环境
:%s/en_US/zh_CN/g
#添加cron
ADD configs/cron /etc/cron.d/
RUN chmod 755 /etc/cron.d/cron && crontab /etc/cron.d/cron
#修改配置文件
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php-fpm.d/www.conf
RUN sed -i 's/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1/' /etc/php-fpm.d/www.conf
#安装composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/sbin --filename=composer
RUN chmod +x /usr/local/sbin/composer
#设置时区
RUN mkdir -p /usr/local/kubernetes/volumes/php-payment-data && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#拷贝代码设置工作目录
COPY php-payment-office/ /usr/local/kubernetes/volumes/php-payment-data/
WORKDIR /usr/local/kubernetes/volumes/php-payment-data

---
查看计划任务有没有执行日志
tail -n 100 /usr/local/kubernetes/volumes/php-payment-data/www_zf2860/crontablog/*


构建
>ocker build -t wolihi/php-payment-office:v1.0 .
docker push wolihi/php-payment-office:v1.0



>docker build -t wolihi/php-payment-office:v7.3 .
docker push wolihi/php-payment-office:v7.3

>docker build -t wolihi/php-payment-office:v7.2 .
docker push wolihi/php-payment-office:v7.2

>docker build -t wolihi/php-payment-office:v7.2.1 .
docker push wolihi/php-payment-office:v7.2.1


创建目录
mkdir -p /usr/local/kubernetes/volumes/php-payment-data
chmod -R a+rw /usr/local/kubernetes/volumes/php-payment-data
chmod -R 777 /usr/local/kubernetes/volumes/php-payment-data

---原系统环境---
ssh -p 59157 xuanwokong009@35.189.169.232
sOlaris1023#
solarisdianjinof13dsf#s7

数据库备份 排除某个表/指定备份某个表
mysqldump -udianjin898 -p self_pay_zf2860 --ignore-table=self_pay_zf2860.admin_action_log > /opt/self_pay_zf2860_112304.sql
mysqldump -udianjin898 -p self_pay_zf2860 --tables admin_action_log > /opt/self_pay_zf2860_admin_action.sql
mysqldump -udianjin898 -p self_qrpay_zf2860 > /opt/self_qrpay_zf2860_112302.sql

传输数据库
scp -rp self_app_pay_zf286011_23_03.sql root@202.182.110.99:/opt
scp -rp self_pay_zf286011_23_03.sql root@202.182.110.99:/opt
scp -rp self_qrpay_zf286011_23_03.sql root@202.182.110.99:/opt

---现系统环境---

##新建数据库
>self_app_pay_zf2860
self_pay_zf2860
self_qrpay_zf2860
kubectl exec mysql-0 -it -- mysql -uroot -pAa123.com self_app_pay_zf2860</opt/self_app_pay_zf286011_23_03.sql
kubectl exec mysql-0 -it -- mysql -uroot -pAa123.com self_pay_zf2860</opt/self_pay_zf286011_23_03.sql
kubectl exec mysql-0 -it -- mysql -uroot -pAa123.com self_pay_zf2860</opt/self_pay_zf2860_admin_action.sql
kubectl exec mysql-0 -it -- mysql -uroot -pAa123.com self_qrpay_zf2860</opt/self_qrpay_zf286011_23_03.sql
kubectl exec mysql-0 -it -- mysql -uroot -pAa123.com self_pay_zf2860</opt/self_pay_zf2860_112304.sql


#进入redis清除数据
redis-cli -h redis-master-svc 
KEYS*
flushall











