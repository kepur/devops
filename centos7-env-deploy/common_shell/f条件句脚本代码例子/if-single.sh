#!/bin/sh
#����֧IF�ṹ�������﷨
#created by oldboy QQ:31333741
#DATE:20110313
#�����Ƚ�,��-lt��ʽ��
echo ####################
if [ 10 -lt 12  ]
   then
        echo "Yes,10 is less than 12"
fi
#��ʾ��������Ϊ����ʱ���˷����к����á�
echo ###################
if [ 10 \< 12  ]
   then
        echo "Yes,10 is less than 12"
fi
echo ####################
if [ "10" \< "12"  ]
   then
        echo "Yes,10 is less than 12"
fi
#��ʾ��������Ϊ�ַ���ʱ���˷����к����á�
echo ####################
if [ "10" -lt "12"  ]
   then
        echo "Yes,10 is less than 12"
fi

echo ####################

if [[ "ddd" -lt "ffff"  ]];then
     echo "Yes,ddd is less than ffff"
fi
echo ####################
#if [[ 10<12  ]];then   #--->���﷨����
if [[ 10 < 12  ]];then 
#if [[ "10" < "12"  ]];then #-->ok
     echo "Yes,10 is less than 12"
fi
echo ####################
#if (( "10" -lt "12" ));then  #--->���﷨����
#if (( "10" < "12" ));then
if (( 10 < 12 ));then
     echo "Yes,10 is less than 12"
fi
