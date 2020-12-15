#! /bin/bash
TIME=`date`
SEND_TO=$1
TITLE="nagios alert"
CONTENT=$2

SERVICE_ID=`eval echo $SEND_TO|awk -F, '{print $1}'`
SERVICE_KEY=`eval echo $SEND_TO|awk -F, '{print $2}'`
EVENT_TYPE='trigger'
DESCRIPTION="$TITLE-$CONTENT"

DATA="{service_id : \"$SERVICE_ID\", description : \"$DESCRIPTION\",event_type : \"$EVENT_TYPE\"}"

curl --silent -H "servicekey:$SERVICE_KEY" -X POST -d "$DATA" http://gaojing.baidu.com/event/create          
