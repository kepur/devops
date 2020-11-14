

# 创建confluence数据库及用户
CREATE DATABASE confdb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on confdb.* to 'confuser'@'%' identified by 'bibi123.com';


vim Dockerfile
FROM cptactionhank/atlassian-confluence:latest
USER root
COPY "atlassian-agent.jar" /opt/atlassian/confluence/
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh

docker build -t wolihi/java-confluence-wiki:v7.4.0 .
docker push wolihi/java-confluence-wiki:v7.4.0
docker push wolihi/java-confluence-wiki:latest


showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes
cd ~/devops/java-confluence-wiki
kubectl delete -f java-confluence-deployment.yaml
kubectl delete -f java-confluence-pv.yaml
kubectl patch pv confluence-pv-volume -p '{"metadata":{"finalizers":null}}'
rm -rf /usr/local/kubernetes/volumes/confluence-data

mkdir -p /usr/local/kubernetes/volumes/confluence-data
chmod -R a+rw /usr/local/kubernetes/volumes/confluence-data
kubectl create -f java-confluence-deployment.yaml
kubectl create -f java-confluence-pv.yaml
