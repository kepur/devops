BASEPATH=/opt/nginx/logs
ACCESSPATH=/opt/nginx/logs/access_logs
ERRORPATH=/opt/nginx/logs/error_logs
alogs="http.655az_access.log
https.655az_access.log
best1pay_access.log
https.cdn.655az_access.log
cdn_qsmsyd_access.log
qsmsyd_access.log
"
for alog in $alogs
do
mv $BASEPATH/$alog $ACCESSPATH/$(date -d yesterday +%Y%m%d%H)_$alog;
touch $BASEPATH/$alog;
kill -USR1 `cat /var/run/nginx.pid`;
done
elogs="best1pay_error.log
http.655az_error.log
https.655az_error.log
qsmsyd_error.log
"
for elog in $elogs
do
mv $BASEPATH/$elog $ERRORPATH/$(date -d yesterday +%Y%m%d%H)_$elog;
touch $BASEPATH/$elog;
kill -USR1 `cat /var/run/nginx.pid`;
done
