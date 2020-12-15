#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function: 
# version:1.1 
################################################
# oldboy trainning info.      
# oldboy QQ:31333741
# site:http://www.etiantian.org
# blog:http://oldboy.blog.51cto.com
# oldboy trainning QQ group: 208160987 226199307
################################################
. /etc/init.d/functions
LOG_FILE=/tmp/httpd.log
apachectl="/application/apache/bin/apachectl"
wget --quiet --spider http://10.0.0.179:8000 && RETVAL=$?
[ ! -f $LOG_FILE ] && touch $LOG_FILE 
if [ "$RETVAL" != "0" ] 
  then
     echo -e "Httpd is not running\n" >$LOG_FILE
        for num in `seq 10`
         do   
            killall httpd  >/dev/null 2>&1 
            [ $? -ne 0 ] && {
              echo "Httpd is killed" >>$LOG_FILE
              break;
	     }
	    sleep 2
	 done
     $apachectl restart >/dev/null 2>&1 && Status="restarted" || Status="unknown" 
     [ "$Status" = "restarted" ] && action "Httpd is restarted" /bin/true||\
      action "Httpd is restarted" /bin/false
      mail -s "`uname -n`'s httpd status is $Status" 3133371@qq.com <$LOG_FILE
      exit
else
    action "httpd is running" /bin/true
    exit 0
fi
