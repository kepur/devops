#!/bin/bash
# version:1.1
. /etc/init.d/functions

url_list=(
http://etiantian.org
http://blog.etiantian.org
http://oldboy.blog.51cto.com
)

function wait()
{
echo -n '3秒后,执行该操作.';
for ((i=0;i<3;i++))
do
  echo -n ".";sleep 1
done
echo
}

function check_url()
{
wait
echo 'check url...'
for ((i=0; i<`echo ${#url_list[*]}`; i++))
do
judge=($(curl -I -s ${url_list[$i]}|head -1|tr "\r" "\n"))
if [[ "${judge[1]}" == '200' && "${judge[2]}"=='OK' ]]
   then
   action "${url_list[$i]}" /bin/true
else
   action "${url_list[$i]}" /bin/false
fi
done
}

check_url
