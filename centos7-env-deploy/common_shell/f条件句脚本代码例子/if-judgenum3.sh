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
print_usage(){
    printf "������Ĳ����������Ի����������밴�����﷨ִ��:\n"
    echo -e "$0 ����1 ����2"
    exit 1
}

#judge para num
if [ $# -ne 2 ]
   then
     print_usage
fi

#judge num
[ -n "`echo $1|sed 's/[0-9]//g'`"  -a  -n "`echo $2|sed 's/[0-9]//g'`" ] &&\
echo "��������������Ϊ����" && exit 1

[ -n "`echo $1|sed 's/[0-9]//g'`" ] && echo "��һ����������Ϊ����" && exit 1

[ -n "`echo $2|sed 's/[0-9]//g'`" ] && echo "�ڶ�����������Ϊ����" && exit 1

#��ʼ�ж�
if [ $1 -gt $2 ]
  then
     echo "$1 > $2"
elif [ $1 -eq $2 ]
  then 
     echo "$1 = $2"
else
     echo "$1 < $2"
fi
