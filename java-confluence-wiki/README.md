# 创建confluence数据库及用户
CREATE DATABASE confdb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on confdb.* to 'confuser'@'%' identified by 'bibi123.com';

如果没有设置需要设置一下
SET GLOBAL tx_isolation='READ-COMMITTED';

编写并构建Dockerfile
vim Dockerfile
FROM cptactionhank/atlassian-confluence:latest
USER root
COPY "atlassian-agent.jar" /opt/atlassian/confluence/
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh


开始构建镜像
docker build -t wolihi/java-confluence-wiki:v7.9.0 .
docker push wolihi/java-confluence-wiki:v7.9.0
如果是lastest就构建latest
docker build -t wolihi/java-confluence-wiki:latest .
docker push wolihi/java-confluence-wiki:latest

确认一下K8S挂载的nfs
showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes

开始安装
cd ~/devops/java-confluence-wiki
mkdir -p /usr/local/kubernetes/volumes/confluence-sys-data
mkdir -p /usr/local/kubernetes/volumes/confluence-run-data
chmod -R a+rw /usr/local/kubernetes/volumes/confluence-sys-data
chmod -R 777 /usr/local/kubernetes/volumes/confluence-sys-data
chmod -R a+rw /usr/local/kubernetes/volumes/confluence-run-data
chmod -R 777 /usr/local/kubernetes/volumes/confluence-run-data
chmod -R 777 /opt/kubernetes/volums/confluence-sys-data
chmod -R 777 /opt/kubernetes/volums/confluence-run-data
kubectl create -f java-confluence-pv.yaml
kubectl create -f java-confluence-pvc.yaml
kubectl create -f java-confluence-deployment.yaml

如果遇到问题重新安装一下
cd ~/devops/java-confluence-wiki
kubectl delete -f java-confluence-deployment.yaml
kubectl delete -f java-confluence-pv.yaml
kubectl patch pv confluence-pv-volume -p '{"metadata":{"finalizers":null}}'
rm -rf /usr/local/kubernetes/volumes/confluence-data


获取POD的IP
kubectl get pods -o wide | grep confluence

访问web获取服务器ID:
http://mouthmelt.com:31791/
获取密钥

进入目录开始执行jar包获取破解密钥:
cd ~/atlassian/
java -jar atlassian-agent.jar \
   -d -m darkernode@gmail.com -n BAT \
   -p conf -o http://10.1.104.43:8090 \
 -s B012-Q8OC-5W16-VKGO

复制密钥:
AAABow0ODAoPeJyNUl2PmzAQfOdXIPXZHCbhrhcJ6RJAKiqQqnCnvjqwCb6CjdYmbfrrawKn3kcUV
fKLVzOzs7P7qWDazuXRpkvboyvfX3m+HRal7bmeax0QQDSy7wGdlFcgFJSnHnLWQRBusyz+Hibr1
AoRmOZSRExDMBIJpYQurSuUCFSFvB9ZwaNoecc11HY7EezdyW607tXq5uZPw1twuLQyxoUGwUQF8
e+e42nu9vmeuHfmWc8c2YvLuOaTdJ4mWVLGkZUP3Q5wu39UgCog9MXcFa0eZT1U2hk/RMm9/sUQn
A9CV7Cs0vwIgcYB3mT5un6FblyxEMzUOEHneJ5M43E4zyqG3b8Yz5D4yNrhvIxgz1o1y78X2uKBC
a4mXCcH3XTQaqeS3WpB7+6pFUqhjcnYhN4GNcOfgELW8HDoTGHETbqXs/jP6QrNcHQ0+ZzXkURBm
kRFnJOU3rr+4tajnr9YLN9s99JBFYBHQEPfbMovxA3XS1JmYUmeNl9/XLrjjxfybcCqYQreX/Fr8
jnDHrmaxzNGgwtm5/jOHjfr8i9/WyrAMCwCFHzIjLyPRxmKuAlSyzCnYtjjIyjjAhQmdmgez22mG
BbO/8Ze9zDXY9sURA==X02k8


成功后测试msyql链接信息
jdbc:mysql://mysql-master-svc:3306/confdb?useUnicode=true&characterEncoding=utf8&sessionVariables=tx_isolation='READ-COMMITTED'&useSSL=false
