#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function: oldboy trainning stripts
# version:1.1 
################################################
# oldboy trainning info.      
# oldboy QQ:31333741
# site:http://www.etiantian.org
# blog:http://oldboy.blog.51cto.com
# oldboy trainning QQ group: 208160987 226199307
################################################
#DbProcessCount normal:2
#DbPortCount    normal:1
#function:check mysql status
MySQLSTARTUP="/data/3306/mysql"
DbProcessCount=`ps -ef|grep mysql|grep -v grep|wc -l`
DbPortCount=`netstat -lnt|grep 3306|wc -l`

if [ $DbProcessCount -eq 2 ] && [ $DbPortCount -eq 1 ]
  then
    echo "mysql is running! " 
else
    $MySQLSTARTUP start >/tmp/mysql.log
   sleep 20;
   if [ $DbProcessCount -ne 2 ] || [ $DbPortCount -ne 1 ]
      then 
          killall mysqld >/dev/null 2>&1
		  sleep 5
          killall mysqld >/dev/null 2>&1
		  sleep 5
          [ $DbPortCount -eq 0 ] && $MySQLSTARTUP start >>/tmp/mysql.log
		  [ $? -eq 0 ] &&     echo "mysql is started"
   fi
   mail -s "mysql restarted" 31333741@qq.com < /tmp/mysql.log
   
fi
