#!/bin/bash
#author:oldboy
#QQ 31333741
# Source function library.
[ -f /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions
RETVAL=0
httpd="/application/apache/bin/httpd"
start() {
        $httpd -k start >/dev/null 2>&1
        RETVAL=$?
        [ $RETVAL -eq 0 ] && action "Æô¶¯ httpd:" /bin/true ||\
        action "Æô¶¯ httpd:" /bin/false
        return $RETVAL
}

stop() {
        $httpd -k stop >/dev/null 2>&1
        [ $? -eq 0 ] && action "Í£Ö¹ httpd:" /bin/true ||\
        action "Í£Ö¹ httpd:" /bin/false
        return $RETVAL
}
case "$1" in
  start)
        start
		;;
  stop)
        stop
        ;;
  restart)
       
       sh $0 stop
       sh $0 start
        ;;
   *)
        echo "Format error!"
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
exit $RETVAL
