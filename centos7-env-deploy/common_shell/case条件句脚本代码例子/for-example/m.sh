#!/bin/bash for ((i=1;i<=100;i++)) do   pass=`openssl rand 20 -base64|md5sum|cut -c 3-11`   useradd -p $pass oldboy$i   echo  "oldboy$i:$pass" | chpasswd   echo  "user:oldboy$i pass:$pass" done 
