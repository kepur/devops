#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function: oldboy trainning stripts
# version:1.1 
################################################
# oldboy trainning info.      
# oldboy QQ:31333741
# site:http://www.etiantian.org
# blog:http://oldboy.blog.51cto.com
# oldboy trainning QQ group: 208160987 226199307
################################################
#function:���֧if���int�ͱȽ�
if [ $# \!= 2 ];then
   echo "usage:sh $0 a b (a,b must be int)"
   exit 1
fi
if [ $1 \< $2  ];then
   echo "$1<$2"
elif [ $1 \= $2 ];then
   echo "$1=$2"
else
   echo "$1>$2"
fi
