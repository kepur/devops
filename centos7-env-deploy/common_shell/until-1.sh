#!/bin/sh
i=1
until ((i >100))
do
  ((sum=sum+i))
  ((i++))
done
[ -n "$sum" ] && echo $sum
