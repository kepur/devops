#!/bin/bash
#author:oldboy
#QQ 31333741
# Source function library.
. /etc/rc.d/init.d/functions

httpd="/application/apache/bin/httpd"
case "$1" in
  start)
        $httpd -k $1 >/dev/null 2>&1
        [ $? -eq 0 ] && action "���� httpd:" /bin/true ||\
        action "���� httpd:" /bin/false
        ;;
  stop)
        $httpd -k $1 >/dev/null 2>&1
        if [ $? -eq 0 ] 
        then
          action "ֹͣ httpd:" /bin/true
        else
          action "ֹͣ httpd:" /bin/false
        fi
        ;;
   restart)
        $httpd -k $1 >/dev/null 2>&1
        [ $? -eq 0 ] && action "���� httpd:" /bin/true||\
        action "���� httpd:" /bin/false
        ;;
   *)
        echo "Format error!"
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
