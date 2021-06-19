#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function: oldboy trainning stripts,check_service.
# version:1.1 
################################################
# oldboy trainning info.      
# oldboy QQ:31333741
# site:http://www.etiantian.org
# blog:http://oldboy.blog.51cto.com
# oldboy trainning QQ group: 208160987 226199307
################################################
#set -x
RETVAL=0
SCRIPTS_PATH="/server/scripts"
MAIL_GROUP="31333741@qq.com 49000448@qq.com"
## web detection function
LOG_FILE="/tmp/web_check.log"
function Get_Url_Status(){
FAILCOUNT=0
for (( i=1 ; $i <= 3 ; i++ )) 
 do 
    wget -T 20 --tries=2 --spider http://${HOST_NAME} >/dev/null 2>&1
    if [ $? -ne 0 ]
        then
         let FAILCOUNT+=1;
    fi
done

#if 3 times then send mail.
if [ $FAILCOUNT -eq 3 ]
     then 
       RETVAL=1
       NOW_TIME=`date +"%m-%d %H:%M:%S"`
       SUBJECT_CONTENT="http://${HOST_NAME} service is error,${NOW_TIME}."
       for MAIL_USER in $MAIL_GROUP
         do 
            echo "send to :$MAIL_USER ,Title:$SUBJECT_CONTENT" >$LOG_FILE
            mail -s "$SUBJECT_CONTENT " $MAIL_USER <$LOG_FILE
        done
else
      RETVAL=0
fi
return $RETVAL
}
#func end.
[ ! -d "$SCRIPTS_PATH" ] && {
  mkdir -p $SCRIPTS_PATH
EOF
}

[ ! -f "$SCRIPTS_PATH/domain.list" ] && {
  cat >$SCRIPTS_PATH/domain.list<<EOF
www.etiantian.org
blog.etiantian.org
EOF
}
#service check 
for  HOST_NAME in `cat $SCRIPTS_PATH/domain.list`
   do
       echo -n "checking $HOST_NAME: "
       #Get_Url_Status
       Get_Url_Status && echo ok||echo no
done
