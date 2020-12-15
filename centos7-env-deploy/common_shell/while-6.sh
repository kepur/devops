exec <$1
sum=0
while read line
do
  num=`echo $line|awk '{print $10}'`
  [ -n "$num" -a "$num" = "${num//[^0-9]/}" ] || continue
  ((sum=sum+$num))
done
  echo "${1}:${sum} bytes =`echo $((${sum}/1024))`KB"
