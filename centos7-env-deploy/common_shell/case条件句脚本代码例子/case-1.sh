read -p "Please input a number:" ans 
case "$ans" in
1)
    echo  "the num you input is 1"
;;
2)
    echo "the num you input is 2"
;;
[3-9])
    echo "the num you input is $ans"
;;
*)
    echo "the num you input must be less 9."
    exit;
;;
esac



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
