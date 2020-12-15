#!/bin/bash  
LOGDIR="/opt/sqllog"  
DATADIR="/data/mysql"  
LOG=${LOGDIR}/general.log
LOG_ERROR=${DATADIR}/mysql-error.log 
LOG_SLOW_QUERIES=${DATADIR}/mysql-slow.log
SOCKET="/tmp/mysql.sock"  
#SAVE TIMES
DAYS=20
SAVEDIR=$(date -d "yesterday" +"%Y-%m-%d")  
mkdir -p ${LOGDIR}/${SAVEDIR}
while read logfile age  
do 
   mv $logfile ${LOGDIR}/${SAVEDIR}  
done << EOF 
${LOG}
${LOG_ERROR}  
${LOG_SLOW_QUERIES}  
EOF
/usr/bin/mysqladmin --defaults-extra-file=/etc/my.cnf --socket=${SOCKET} flush-logs
/usr/bin/find $LOGDIR -type f -ctime +$DAYS -delete  
