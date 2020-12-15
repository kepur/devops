#!/bin/sh
#author:oldboy
#qq:31333741
#http://oldboy.blog.51cto.com
userchars="test"
passfile="/tmp/user.log"
for num in `seq 3`
 do
   useradd $userchars$num
   passwd="`echo "date $RANDOM"|md5sum|cut -c3-11`"
   echo "$passwd"|passwd --stdin $userchars$num
   echo  -e "user:$userchars$num\tpasswd:$passwd">>$passfile
   #sleep 1
done
echo ------this is oldboy trainning class contents----------------
cat $passfile
