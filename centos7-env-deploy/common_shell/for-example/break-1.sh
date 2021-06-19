for((i=0; i<=5; i++))
do
  if [ $i -eq 3 ] ;then
      #continue;
      break;
  fi
    echo $i
done
echo "ok"

