#!/bin/sh
# oldboy QQ:31333741
for file in `ls ./*.jpg` 
 do 
/bin/mv $file `echo "${file%_finished*}.jpg"`  #������Ǳ����Ľ�ȡ�·�����
done 
