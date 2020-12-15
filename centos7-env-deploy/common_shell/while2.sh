#!/bin/sh
i=10
while ((i>0))
 do
  if [ $i -eq 3 ] ;then
      continue;
	#break;
  fi

        echo $i
        ((i--))
done

