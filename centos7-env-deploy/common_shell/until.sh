#!/bin/sh
i=10
until ((i>11))
 do
        echo $i
        ((i--))
	 exit
done
