#!/bin/sh
for filename in `ls *.jpg`
do
   mv $filename `echo $filename|cut -d . -f1`.gif
done
