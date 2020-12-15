#!/bin/bash
#
# tomcatd This shell script takes care of starting and stopping
# standalone tomcat
#
# chkconfig: 345 91 10
# description: tomcat service
# processname: tomcatd
# config file:
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] &&exit 0
prog=tomcatd
export JAVA_HOME=/opt/java/jdk1.8.0_51
export CATALINA_HOME=/opt/java/apache-tomcat-7.0.63

PATH=$PATH:$JAVA_HOME/bin
STARTUP=$CATALINA_HOME/bin/startup.sh
SHUTDOWN=$CATALINA_HOME/bin/shutdown.sh
if [ ! -f $CATALINA_HOME/bin/startup.sh ]
then
echo "CATALINA_HOME for tomcatd not available"
exit
fi
start() {
#Start daemons.
echo-n $"Startting tomcat service: "
daemon $STARTUP
RETVAL=$?
return $RETVAL
}
stop() {
#Stop daemons.
echo -n $"Stoping tomcat service: "
$SHUTDOWN
RETVAL=$?
return $RETVAL
}
# See how we were called.
case "$1" in
start)
start
;;
stop)
stop
;;
restart|reload)
stop
start
RETVAL=$?
;;
status)
status $prog
RETVAL=$?
;;
*)
echo$"Usage: $0 {start|stop|restart|status}"
exit 1
esac
exit $RETVAL