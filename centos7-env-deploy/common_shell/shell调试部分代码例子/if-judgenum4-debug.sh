#!/bin/bash
#created by oldboy QQ 31333741
#date:20100918
#function:int compare
read -p "pls input two num:" a b
echo $a $b
exit 
###########
#if [ $a -lt $b ]
if (($a < $b ))
  then
   echo "$a<$b"
elif [ $a -eq $b ]
  then
   echo "$a=$b"
else
   echo "$a>$b"
fi
