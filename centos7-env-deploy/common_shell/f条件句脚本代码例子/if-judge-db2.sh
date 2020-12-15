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
MySQLSTARTUP="/data/3306/mysql"
mysql -uroot -p'oldboy' -S /data/3306/mysql.sock -e "select version();" >/dev/null 2>&1
if [ $? -eq 0 ]
  then
    echo "mysql is running! " 
else
    $MySQLSTARTUP start >/tmp/mysql.log
    sleep 10;
    mysql -uroot -p'oldboy' -S /data/3306/mysql.sock -e "select version();" >/dev/null 2>&1
    if [ $? -ne 0 ]
      then 
        killall mysqld  >/dev/null 2>&1
        killall mysqld  >/dev/null 2>&1
		sleep 10
        $MySQLSTARTUP start >>/tmp/mysql.log
    fi
   mail -s "mysql restarted" 31333741@qq.com < /tmp/mysql.log
fi
