#!/bin/sh
while true
do
  curl -I -s http://baidu.com|head -1
  curl -I -s http://g.cn|head -1
  sleep 2
done
