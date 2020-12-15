#!/bin/bash
# this script is created by oldboy.
# e_mail:31333741@qq.com
# qqinfo:31333741
# function:case example
# version:1.1
read -p "Please input the fruit name you like :" ans 
case "$ans" in
apple|APPLE)
    echo  "the fruit name you like is alpple"
;;
banana|BANANA)
    echo  "the fruit name you like is banana"
;;
pear|PEAR)
    echo  "the fruit name you like is pear"
;;
*)
    echo "Here is not the fruit name you like."
    exit;
;;
esac
