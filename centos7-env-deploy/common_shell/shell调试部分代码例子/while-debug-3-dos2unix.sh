#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function:while-3 example
# version:1.1
#!/bin/sh
i=1
sum=0
while ((i <=100 ))
do
	((sum=sum+i))
	((i++))
done
printf "totalsum is :$sum\n"
