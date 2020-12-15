#!/bin/sh
# oldboy QQ:31333741
for file in `ls ./*.jpg` 
 do 
/bin/mv $file `echo "${file%_finished*}.jpg"`  #这里就是变量的截取新方法。
done 
