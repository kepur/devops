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
ip_add="$1" 
port="$2"
print_usage(){
	   echo -e "$0 ip port"
	   exit 1
}
		
#judge para num
if [ $# -ne 2 ]
	then
		print_usage
fi
PORT_COUNT=`nmap $ip_add  -p $port|grep open|wc -l`
#echo -e "\n" |telnet $ip_add $port||grep Connected
#echo -e "\n"|telnet 10.0.0.179 8000|grep Connected
[[ $PORT_COUNT -ge 1 ]] && echo "$ip_add $port is ok." || echo "$ip_add $port is unknown."
