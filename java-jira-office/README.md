# 创建jira数据库及用户
CREATE DATABASE jiradb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on jiradb.* to 'jirauser'@'%' identified by 'bibi123.com';

如果没有设置需要设置一下
SET GLOBAL tx_isolation='READ-COMMITTED';

vim Dockerfile
FROM cptactionhank/atlassian-jira-software:latest
USER root
COPY "atlassian-agent.jar" /opt/atlassian/jira/
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/jira/bin/setenv.sh

开始构建镜像
docker build -t wolihi/java-jira-office:v8.1.0 .
docker push wolihi/java-jira-office:v8.1.0
docker push wolihi/java-jira-office:latest

测试挂载
showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes
cd ~/devops/java-jira-office

创建pod
mkdir -p /usr/local/kubernetes/volumes/jira-data
chmod -R a+rw /usr/local/kubernetes/volumes/jira-data
chmod -R 777 /usr/local/kubernetes/volumes/jira-data
chmod -R 777 /opt/kubernetes/volumes/jira-data
kubectl create -f java-jira-deployment.yaml
kubectl create -f java-jira-pv.yaml

如果有问题回退
cd ~/devops/java-jira-office
kubectl delete -f java-jira-deployment.yaml
kubectl delete -f java-jira-pv.yaml
kubectl patch pv jira-pv-volume -p '{"metadata":{"finalizers":null}}'
rm -rf /usr/local/kubernetes/volumes/jira-data

获取POD的IP
kubectl get pods -o wide | grep jira

访问web获取服务器ID:
http://jira.mouthmelt.com:31790/
获取密钥

进入jar所在目录执行命令获取破解密钥:
cd ~/atlassian/
java -jar atlassian-agent.jar \
  -d -m darkernode@gmail.com -n BAT \
  -p jira -o http://10.1.166.146:8080 \
  -s BHDW-75UE-85BR-LFJM
