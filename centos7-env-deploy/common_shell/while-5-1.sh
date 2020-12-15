#!/bin/sh
while true
do
status=`curl -I -s --connect-timeout 10 $1|head -1|cut -d " " -f 2`
 if [ "$status" = "200"  ] ;then
        echo "this url is good" 
 else
        echo " this url is bad"
        echo $ok
  fi
  sleep 2
done

