#!/bin/sh
while [ 1 ]
 do
    uptime >>./uptime.log
    usleep 1000000
done

