cat >Dockerfile <<EOF
FROM docker.io/openshift/base-centos7:latest
MAINTAINER wolihi "wolihi@gmail.com"
RUN yum makecache
RUN yum -y install php-fpm php php-gd php-mysql php-mbstring php-xml php-mcrypt  php-imap php-odbc php-pear php-xmlrpc
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php-fpm.d/www.conf
RUN sed -i 's/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1/' /etc/php-fpm.d/www.conf
EXPOSE 9000
CMD ["/sbin/php-fpm"]
EOF


docker build -t wolihi/php-payment-office:v1.0 .
docker push wolihi/php-payment-office:v1.0


mkdir -p /usr/local/kubernetes/volumes/php-payment-data
chmod -R a+rw /usr/local/kubernetes/volumes/php-payment-data
chmod -R 777 /usr/local/kubernetes/volumes/php-payment-data
