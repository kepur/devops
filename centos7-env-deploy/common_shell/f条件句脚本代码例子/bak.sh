scp -P22 -r -p ./oldboy oldboy@192.168.1.178:~
ssh -t -p 22 oldboy@192.168.1.178 sudo rsync -avz -P  oldboy /root/
