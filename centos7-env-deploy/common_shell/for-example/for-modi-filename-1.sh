#!/bin/sh
for file in `ls ./*.jpg`  
#shell脚本for循环，file为变量依次取得ls ./*.jpg的结果文件名
do
mv $file `echo $file|sed 's/_finished//g'` 
#使用mv命令进行更改文件，新的文件名字符串拼接是本题的重点。
done
