ssh -p 59157 xuanwokong009@35.189.169.232
sOlaris1023#
139.180.199.52

netstat -tun | grep ":59159"

tail -n 100000 /opt/nginx/logs/https.655az_access.log | grep 'HTTP/1.1" 301'
tar -zcvf files.tar.gz files/
scp -P 48456 files.tar.gz xunhuan@108.61.183.82:/home/xunhuan/www
scp -P 48456 files.tar.gz xunhuan@185.227.70.119:/home/xunhuan/www
scp -P 48456 files.tar.gz xunhuan@45.32.123.206:/home/xunhuan/www
scp -P 48456 files.tar.gz xunhuan@45.77.1.111:/home/xunhuan/www
scp -P 48456 files.tar.gz xunhuan@fe1e3d8d-8615-4f72-aff2-34c67503da74.ddns.moonvm.net:/home/xunhuan/www

cd www
tar -zxvf files.tar.gz

#!/bin/bash
TIME=`date +%m%d%H%M`
cd ~/www/
tar -zcvf mobile${TIME}.tar.gz mobile/
rm -rf mobile
unzip mobile.zip

mongo
show dbs


腾讯云 3000
MOON   1200
代付  10212

#aws_center
ssh-copy-id -i /root/.ssh/id_rsa.pub root@15.164.78.154 -p 48456
#webkr 
ssh-copy-id -i /root/.ssh/id_rsa.pub root@185.227.70.119 -p 48456
#webjp
ssh-copy-id -i /root/.ssh/id_rsa.pub root@108.61.183.82 -p 48456
#websg
ssh-copy-id -i /root/.ssh/id_rsa.pub root@45.32.123.206 -p 48456
#webus
ssh-copy-id -i /root/.ssh/id_rsa.pub root@45.77.1.111 -p 48456
#webtw 
ssh-copy-id -i /root/.ssh/id_rsa.pub root@fe1e3d8d-8615-4f72-aff2-34c67503da74.ddns.moonvm.net -p 48456


cat  blog_access20150331.log | grep "31/Mar/2015" |awk '{print $1,}'|sort |uniq -c|sort -nr|head

cat www_access20150403.log | awk '{print $1,$11}' | sort | uniq -c | sort -nr | head

日志切割：
cat www.cdstm.cn.access.log  | grep 02/Apr >> /weblogs/logs/www_access20150402.log 将日志已10月10日的切割出一个文件
cat ***.log | grep 日志文件中的时间格式为准 >> 输出目录


日志访问IP统计：

#cat  blog_access20150331.log | grep "31/Mar/2015" |awk '{print $1,}'|sort |uniq -c|sort -nr|head

#cat www_access20150403.log | awk '{print $1,$11}' | sort | uniq -c | sort -nr | head


cat www.cdstm.cn.log | awk '{print $1,$7}' | sort | uniq -c | sort -nr > abcd
 

cat www.cdstm.cn.access.log | awk '{print $1}' | sort | uniq -c | sort -nr > abcd

 ps -aux |grep tomcat-6-sms |sed -n '2p'|awk '{print $2}'

nginx 并发 连接数
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'


eval `ssh-agent`
vim ~/.bashrc
grep -r server_name |grep cloud
free -g

wget --no-check-certificate -O shadowsocks.sh https://cyh.abcdocker.com/vpn/shadowsocks.sh

netstat -anlop |grep LISTEN
php -m |grep cache
netstat -anlop |grep LISTE|more

curl icanhazip.com

more /data/wwwlogs/test.pma.mzz258.com_nginx.log |awk '{print $1}'|sort -rn |uniq -c |sort -rn


ls -al /proc/1434 | grep cwd

#!/bin/bash
cp -f /confbak2/www/config.php /www/
cp -f /confbak2/www/kjg/Config/config.db.php /www/kjg/Config/


stty erase ^h
if [ $# -eq 0 ];then
read -p "请输入要解压的文件名:" unzipname
else
unzipname=$1
fi
var=$unzipname
echo " 正在创建减压目录 ${var%.}  start ..."
mkdir ${var%.}
unzip $unzipname -d ${var%.*} || { "解压文件失败，请确认输入路径";sleep 1;exit 1;}
echo " 解压成功 done ......."
sleep 1s


#!/bin/bash
read -p "plz input your backup webname:" webname
echo " we will back www.$webname data start ..."
zip -qjv /home/bak/$webname.zip /web/www/uz/www.$webname/*
echo " 压缩成功 done ......."
sleep 2s 
echo " 正在传输到远程服务器........"
sleep 2s
sshpass -p 'DDrcW9FqjNuq' scp /home/bak/$webname.zip root@154.85.191.6:/opt/hkbak_Sr_1/web/
echo " 传输成功done......"
sleep 1s
echo "传输完成后请创建网站相关目录后再解压......"
sleep 2s
