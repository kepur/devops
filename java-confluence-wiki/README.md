

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
kubectl create -f java-confluence-pv.yaml
kubectl create -f java-confluence-deployment.yaml



AAABow0ODAoPeJyNUl2PmzAQfOdXIPXZHCbhrhcJ6RJAKiqQqnCnvjqwCb6CjdYmbfrrawKn3kcUV
fKLVzOzs7P7qWDazuXRpkvboyvfX3m+HRal7bmeax0QQDSy7wGdlFcgFJSnHnLWQRBusyz+Hibr1
AoRmOZSRExDMBIJpYQurSuUCFSFvB9ZwaNoecc11HY7EezdyW607tXq5uZPw1twuLQyxoUGwUQF8
e+e42nu9vmeuHfmWc8c2YvLuOaTdJ4mWVLGkZUP3Q5wu39UgCog9MXcFa0eZT1U2hk/RMm9/sUQn
A9CV7Cs0vwIgcYB3mT5un6FblyxEMzUOEHneJ5M43E4zyqG3b8Yz5D4yNrhvIxgz1o1y78X2uKBC
a4mXCcH3XTQaqeS3WpB7+6pFUqhjcnYhN4GNcOfgELW8HDoTGHETbqXs/jP6QrNcHQ0+ZzXkURBm
kRFnJOU3rr+4tajnr9YLN9s99JBFYBHQEPfbMovxA3XS1JmYUmeNl9/XLrjjxfybcCqYQreX/Fr8
jnDHrmaxzNGgwtm5/jOHjfr8i9/WyrAMCwCFHzIjLyPRxmKuAlSyzCnYtjjIyjjAhQmdmgez22mG
BbO/8Ze9zDXY9sURA==X02k8


msyql链接信息
jdbc:mysql://mysql-master-svc:3306/confdb?useUnicode=true&characterEncoding=utf8&sessionVariables=tx_isolation='READ-COMMITTED'&8&useSSL=false
