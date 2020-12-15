#!/bin/bash  
for a in `seq 9`
do
        for b in `seq 9`
        do
                [ $a -ge $b ] && echo -en "$a x $b = $(expr $a \* $b)  "
        done
echo " "
done
