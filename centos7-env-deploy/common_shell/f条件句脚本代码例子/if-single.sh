#!/bin/sh
#单分支IF结构及条件语法
#created by oldboy QQ:31333741
#DATE:20110313
#整数比较,用-lt格式。
echo ####################
if [ 10 -lt 12  ]
   then
        echo "Yes,10 is less than 12"
fi
#提示：当条件为数字时，此法老男孩常用。
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
#提示：当条件为字符串时，此法老男孩常用。
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
#if [[ 10<12  ]];then   #--->此语法错误
if [[ 10 < 12  ]];then 
#if [[ "10" < "12"  ]];then #-->ok
     echo "Yes,10 is less than 12"
fi
echo ####################
#if (( "10" -lt "12" ));then  #--->此语法错误
#if (( "10" < "12" ));then
if (( 10 < 12 ));then
     echo "Yes,10 is less than 12"
fi
