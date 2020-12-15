#!/bin/sh
while true
do
status=`curl -I -s --connect-timeout 10 $1|head -1| awk '{print $2}'`
ok=`curl -I -s --connect-timeout 10 $1|head -1|cut -d " " -f 3`
if [ "$status" = "200"  ] && [ "$ok"="OK" ];the
        echo "this url is good" 
else
        echo " this url is bad"
fi
  sleep 3
done
