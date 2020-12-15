#!/bin/bash

echo

echo "-------------------CiPanKongJian--------------------"

date

echo

df -hT

echo

echo "------------------------CPU-------------------------"

date

echo

top -n 1 |grep Cpu
echo

echo "------------------------NeiCun----------------------"

date

echo

free -m

echo

echo "-------------------GuanJianJinCheng-----------------"

date

echo

ps -aux|grep mysqld
