#!/bin/bash

echo

echo "-------------------磁盘状态--------------------"

date

echo

df -hT

echo

echo "------------------------CPU-------------------------"

date

echo

top -n 1 |grep Cpu
echo

echo "------------------------内存----------------------"

date

echo

free -m

echo

echo "-------------------Mysql状态-----------------"

date

echo

ps -aux|grep mysqld

echo "---------nginx并发状态 --------"
#netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
echo "---------check system user 34 if more have problem --------"
#2020 01 08:15:30
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/bin:/sbin/nologin
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
#adm:x:3:4:adm:/var/adm:/sbin/nologin
#lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
#sync:x:5:0:sync:/sbin:/bin/sync
#shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
#halt:x:7:0:halt:/sbin:/sbin/halt
#mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
#operator:x:11:0:operator:/root:/sbin/nologin
#games:x:12:100:games:/usr/games:/sbin/nologin
#ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
#nobody:x:99:99:Nobody:/:/sbin/nologin
#systemd-network:x:192:192:systemd Network Management:/:/sbin/nologin
#dbus:x:81:81:System message bus:/:/sbin/nologin
#polkitd:x:999:997:User for polkitd:/:/sbin/nologin
#ntp:x:38:38::/etc/ntp:/sbin/nologin
#postfix:x:89:89::/var/spool/postfix:/sbin/nologin
#sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
#chrony:x:998:996::/var/lib/chrony:/sbin/nologin
#soap:x:1001:10::/home/soap:/bin/bash
#mysql:x:1002:1002::/home/mysql:/sbin/nologin
#www:x:1003:1003::/home/www:/sbin/nologin
#redis:x:1004:1004::/home/redis:/sbin/nologin
#memcached:x:1005:1005::/home/memcached:/sbin/nologin
#saslauth:x:997:76:Saslauthd user:/run/saslauthd:/sbin/nologin
#cloud007:x:1006:10::/home/cloud007:/bin/bash
#cloud54556:x:1007:1007::/home/cloud54556:/bin/bash
#mongod:x:996:994:mongod:/var/lib/mongo:/bin/false
#xuanwokong009:x:1011:10::/home/xuanwokong009:/bin/bash
#zabbix:x:995:993:Zabbix Monitoring System:/var/lib/zabbix:/sbin/nologin
#git:x:1012:1012::/home/git:/bin/bash
#apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
#csadmin:x:1013:1013::/home/csadmin:/bin/bash

cat /etc/passwd | wc -l
echo "---------------404请求查询--------------"
tail -n 100000  /opt/nginx/logs/https.655az_access.log | grep 'HTTP/1.1" 404'
echo "---------------500请求查询--------------"
tail -n 100000 /opt/nginx/logs/https.655az_access.log | grep 'HTTP/1.1" 500'
echo "---------------401请求查询--------------"
tail -n 100000 /opt/nginx/logs/https.655az_access.log | grep 'HTTP/1.1" 401'
echo "---------------HTTP当前所有连接IP--------------"
netstat -tun | grep ":80" | wc -l
echo "--------------HTTPS当前所有连接IP--------------"
netstat -tun | grep ":443" | wc -l
echo "---------------MYSQL当前所有连接IP--------------"
netstat -tun | grep ":3306" | wc -l
echo "---------------ssh当前所有连接IP--------------"
netstat -tun | grep ":59157"
echo "---------------PhpADMIN当前所有连接IP--------------"
#check mysql user : select user,host from mysql.user; 
#default checkabc mysql root server xianwokong009 dianjin898 root root 
netstat -tun | grep ":59159"
echo "---------------root sql历史执行--------------"
cat ~/.mysql_history
