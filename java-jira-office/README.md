将atlassian-agent.jar放在一个你不会随便删除的位置（你服务器上的所有Atlassian服务可共享同一个atlassian-agent.jar）。
设置环境变量JAVA_OPTS（这其实是Java的环境变量，用来指定其启动java程序时附带的参数），把-javaagent参数附带上。具体可以这么做：
你可以把：export JAVA_OPTS="-javaagent:/path/to/atlassian-agent.jar ${JAVA_OPTS}"这样的命令放到.bashrc或.bash_profile这样的文件内。
你可以把：export JAVA_OPTS="-javaagent:/path/to/atlassian-agent.jar ${JAVA_OPTS}"这样的命令放到服务安装所在bin目录下的setenv.sh或setenv.bat（供windows使用）中。
你还可以直接命令行执行：JAVA_OPTS="-javaagent:/path/to/atlassian-agent.jar" /path/to/start-confluence.sh来启动你的服务。
或者你所知的其他修改环境变量的方法，但如果你机器上有无关的服务，则不建议修改全局JAVA_OPTS环境变量。
总之你想办法把-javaagent参数附带到要启动的java进程上。
配置完成请重启你的Confluence服务。
如果你想验证是否配置成功，可以这么做：
执行类似命令：ps aux|grep java 找到对应的进程看看-javaagent参数是否正确附上。
在软件安装目录类似：/path/to/confluence/logs/catalina.outTomcat日志内应该能找到：========= agent working =========的输出字样。
export JAVA_OPTS="-javaagent:/path/to/atlassian-agent.jar ${JAVA_OPTS}"

showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes
rm -rf /usr/local/kubernetes/volumes/jira-data
mkdir -p /usr/local/kubernetes/volumes/jira-data
chmod -R a+rw /usr/local/kubernetes/volumes/redis-data

kubectl patch pv jira-pv-volume -p '{"metadata":{"finalizers":null}}'
docker build -t wolihi/java-jira-office:v8.1.0 .
docker push wolihi/java-jira-office:v8.1.0
docker push wolihi/java-jira-office:latest
