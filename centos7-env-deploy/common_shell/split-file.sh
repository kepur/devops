#!/bin/sh
#mother file
FILE_PATH=$1
#linenum of each file
FILE_NUM=$2
i=1
sub=1
#ĸ�ļ�������
totalline=`wc -l ${FILE_PATH} | awk '{print $1}'`
#�����ļ�����
((inc=totalline/FILE_NUM))

cat ${FILE_PATH} | while read line
do

    if ((i<=inc))
    then
        ((i++))
    else
        ((sub++))
         i=2
    fi

    echo ${line} >>${FILE_PATH}.${sub}
done