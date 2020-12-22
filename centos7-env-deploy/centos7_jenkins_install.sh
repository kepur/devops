#!/bin/bash


yum -y install java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64
wget https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-7.4.6-x64.bin
chmod 755 atlassian-confluence-7.4.6-x64.bin
chmod +x atlassian-confluence-7.4.6-x64.bin
cd /opt/atlassian/confluence/confluence/WEB-INF/lib/
\cp /opt/atlassian/confluence/confluence/WEB-INF/lib/atlassian-extras-decoder-v2-3.4.1.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/atlassian-extras-decoder-v2-3.4.1.jarbak
rm -rf /opt/atlassian/confluence/confluence/WEB-INF/lib/atlassian-extras-decoder-v2-3.4.1.jar




sh /opt/atlassian/confluence/bin/startup.sh
sh /opt/atlassian/confluence/bin/start-confluence.sh


wget https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-6.8.0.tar.gz
tar zxvf atlassian-confluence-6.8.0.tar.gz -C /opt
vim /opt/atlassian-confluence-6.8.0/confluence/WEB-INF/classes/confluence-init.properties
confluence.home=/opt/confluence
/opt/atlassian-confluence-6.8.0/bin/startup.sh
cp atlassian-extras-decoder-v2-3.3.0.jar atlassian-extras-decoder-v2-3.3.0.jarbak

mv atlassian-extras-2.4.jar atlassian-extras-decoder-v2-3.3.0.jar
sh ../../../bin/stop-confluence.sh
sh ../../../bin/start-confluence.sh
B0YN-QO4Y-FHIS-YT45