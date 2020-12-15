#!/bin/bash
#created by oldboy QQ 31333741
#date:20100918
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
