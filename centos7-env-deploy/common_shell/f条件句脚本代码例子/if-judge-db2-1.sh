#!/bin/bash
################################################
MYUSER=root
MYPASS="oldboy"
MYSOCK=/data/3306/mysql.sock
MySQL_STARTUP="/data/3306/mysql"
LOG_PATH=/tmp
LOG_FILE=${LOG_PATH}/mysqllogs_`date +%F`.log
MYSQL_PATH=/usr/local/mysql/bin
MYSQL_CMD="$MYSQL_PATH/mysql -u$MYUSER -p$MYPASS -S $MYSOCK"
$MYSQL_CMD -e "select version();" >/dev/null 2>&1
if [ $? -eq 0 ] 
then
	echo "MySQL is running! " 
	exit 0
else
    $MySQL_STARTUP start >$LOG_FILE
    sleep 5;
    $MYSQL_CMD -e "select version();" >/dev/null 2>&1
    if [ $? -ne 0 ]
      then 
        for num in `seq 5`
        do
           killall mysqld  >/dev/null 2>&1 
	   [ $? -ne 0 ] && break;
	       sleep 1
		done
        $MySQL_STARTUP start >>$LOG_FILE 
    fi
    $MYSQL_CMD -e "select version();" >/dev/null 2>&1 && Status="restarted" || Status="unknown"
    mail -s "MySQL status is $Status" 31333741@qq.com < $LOG_FILE
fi
exit $RETVAL
