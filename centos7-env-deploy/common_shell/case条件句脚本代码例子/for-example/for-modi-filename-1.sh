#!/bin/sh
for file in `ls ./*.jpg`  
#shell�ű�forѭ����fileΪ��������ȡ��ls ./*.jpg�Ľ���ļ���
do
mv $file `echo $file|sed 's/_finished//g'` 
#ʹ��mv������и����ļ����µ��ļ����ַ���ƴ���Ǳ�����ص㡣
done
