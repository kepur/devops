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
echo "---------------404请求查询--------------"
tail -n 1000000 /opt/nginx/logs/*access.log | grep 'HTTP/1.1" 404'
echo "---------------500请求查询--------------"
tail -n 1000000 /opt/nginx/logs/*access.log | grep 'HTTP/1.1" 500'
echo "---------------401请求查询--------------"
tail -n 1000000 /opt/nginx/logs/*access.log | grep 'HTTP/1.1" 401'
echo "---------------HTTP当前所有连接IP--------------"
netstat -tun | grep ":80"
echo "--------------HTTPS当前所有连接IP--------------"
netstat -tun | grep ":443"
echo "---------------MYSQL当前所有连接IP--------------"
netstat -tun | grep ":3306"
echo "---------------ssh当前所有连接IP--------------"
netstat -tun | grep ":48456"
echo "---------------PhpADMIN当前所有连接IP--------------"
netstat -tun | grep ":59159"
echo "---------------root sql历史执行--------------"
cat ~/.mysql_history
echo "---------------后门用户查询默认26--------------"
cat /etc/passwd | wc -l
echo "---------------并发统计--------------"
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
