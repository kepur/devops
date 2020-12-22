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


容器内的server更改
vi /opt/atlassian/confluence/conf/server.xml
我这里已经写好了
mkdir -p /root/atlassian/confluence/
cat >/root/atlassian/confluence/server.xml <<EOF
<?xml version="1.0"?>
<Server port="8000" shutdown="SHUTDOWN">
  <Service name="Tomcat-Standalone">
     <Connector port="8090" connectionTimeout="20000" redirectPort="8443"
                   maxThreads="48" minSpareThreads="10"
                   enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
                   protocol="org.apache.coyote.http11.Http11NioProtocol"
                   scheme="https" secure="true" proxyName="mouthmelt.com" proxyPort="443"/>-->
    <Engine name="Standalone" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="false" startStopThreads="4">
        <Context path="" docBase="../confluence"  debug="0" reloadable="false" useHttpOnly="true" >
          <Manager pathname=""/>
          <Valve className="org.apache.catalina.valves.StuckThreadDetectionValve" threshold="60"/>
        </Context>
        <Context path="${confluence.context.path}/synchrony-proxy" docBase="../synchrony-proxy" reloadable="false" >
          <Valve className="org.apache.catalina.valves.StuckThreadDetectionValve" threshold="60"/>
        </Context>
      </Host>
    </Engine>
  </Service>
</Server>
EOF



创建configmap
kubectl delete configmap tomcat-config
kubectl create configmap tomcat-config --from-file=/root/atlassian/confluence/server.xml




开始构建镜像


vim ~/atlassian/Dockerfile
cd ~/atlassian/
docker build -t wolihi/java-confluence-wiki:v7.9.0 .
docker push wolihi/java-confluence-wiki:v7.9.0
如果是lastest就构建latest
docker build -t wolihi/java-confluence-wiki:latest .
docker push wolihi/java-confluence-wiki:latest

docker pull wolihi/java-confluence-wiki:v7.4.0
docker单独启动
docker run -d --name confluence \
  --restart always \
  -p 18090:8090 -p 18091:8091 \
  -e TZ="Asia/Shanghai" \
  -v /opt/confluence:/var/atlassian/confluence \
wolihi/java-confluence-wiki:v7.4.0

  -v /opt/atlassian/confluence:/opt/atlassian/confluence \


确认一下K8S挂载的nfs
showmount -e 10.25.96.30
mount -t nfs 10.25.96.30:/opt/kubernetes/volums /usr/local/kubernetes/volumes

开始安装
cd ~/devops/java-confluence-wiki
mkdir -p /usr/local/kubernetes/volumes/confluence-data
chmod -R a+rw /usr/local/kubernetes/volumes/confluence-data
chmod -R 777 /usr/local/kubernetes/volumes/confluence-data
kubectl create -f java-confluence-pv.yaml
kubectl create -f java-confluence-pvc.yaml
kubectl create -f java-confluence-deployment.yaml


如果遇到问题重新安装一下
cd ~/devops/java-confluence-wiki
kubectl delete -f java-confluence-deployment.yaml
kubectl delete -f java-confluence-pvc.yaml
kubectl delete -f java-confluence-pv.yaml
kubectl patch pv confluence-run-data-pv-volume -p '{"metadata":{"finalizers":null}}'
rm -rf /usr/local/kubernetes/volumes/confluence-data


获取POD的IP
kubectl get pods -o wide | grep confluence

访问web获取服务器ID:
http://202.182.110.99:31791
https://mouthmelt.com
获取密钥

进入目录开始执行jar包获取破解密钥:
cd ~/atlassian/
java -jar atlassian-agent.jar \
   -d -m darkernode@gmail.com -n BAT \
   -p conf -o http://10.1.135.30:8090 \
 -s B9O2-R32P-YULT-D846

java -jar atlassian-agent.jar \
   -d -m darkernode@gmail.com -n BAT \
   -p conf -o http://10.25.96.40:8090 \
 -s BMMN-3ASP-9D7W-2OO9



 java -jar atlassian-agent.jar \
   -d -m darkernode@gmail.com -n BAT \
   -p conf -o 172.17.0.2:8090 \
 -s B11T-TPM9-R9H0-KGQY

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
