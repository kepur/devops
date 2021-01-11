#!/bin/bash
拷贝本地机器的内容到远程机器
-a           #归档模式传输, 等于-tropgDl
-v           #详细模式输出, 打印速率, 文件数量等
-z           #传输时进行压缩以提高效率
--delete     #让目标目录和源目录数据保持一致
--password-file=xxx #使用密码文件

------------------- -a 包含 ------------------
-r           #递归传输目录及子目录，即目录下得所有目录都同样传输。
-t           #保持文件时间信息
-o           #保持文件属主信息
-p           #保持文件权限
-g           #保持文件属组信息
-l           #保留软连接
-D           #保持设备文件信息
----------------------------------------------

-L           #保留软连接指向的目标文件
-e           #使用的信道协议,指定替代rsh的shell程序
--exclude=PATTERN   #指定排除不需要传输的文件模式
--exclude-from=file #文件名所在的目录文件
$RSYNC_PASSWORD 		# 用来存放rsync密码的变量，使用之后可以不使用--password-file=xxx

src="/usr/local/webroot/java-web-bld"
rsync -rauvvt --progress \
--password-file=/etc/rsyncd-test.passwd \
--exclude="console/data" \
--exclude=".svn" \
--exclude="WEB-INF/logs" \
--exclude="res/upload" \
--exclude="WEB-INF/upload" \
--exclude="WEB-INF/temp" \
--exclude="env.properties" \
/usr/local/webroot/java-web-bld/ rsyncuser@xxx.xx.xx.xxx::backend

#执行排除指定类型文件不推送
touch /etc/rsync_exclude.txt
#粘入内容
.[a-z]*
.git/*
logs
appsettings.json
nlog.config
ocelot.*.json
rsync -avz --delete --exclude-from=/etc/rsync_exclude.txt --password-file=/root/rsyncd.passwd  /data/myrsync/* admin@192.168.1.103::site01common

rsync -avz --password-file=/root/passwd  admin@192.168.204.130::common /tmp  >/dev/null 2>&1



$ rsync -av /home/coremail/ 192.168.11.12:/home/coremail/

df -hT

启动rsync
/usr/bin/rsync --daemon --config=/etc/rsyncd.conf

#添加开机启动
echo "rsync --daemon --config=/etc/rsyncd.conf"  >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
#重启服务
pkill rsync  
/usr/bin/rsync --daemon --config=/etc/rsyncd.conf



拉取代码
rsync -avz --password-file=/etc/rsyncd.secrets admin@10.25.96.10::devops /opt/web/

推送代码






top -n 1 |grep Cpu
free -m
ps -aux|grep mysqld
