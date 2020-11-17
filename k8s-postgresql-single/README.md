
开始安装
mkdir -p /usr/local/kubernetes/volumes/postgresql-data
chmod -R a+rw /usr/local/kubernetes/volumes/postgresql-data
chmod -R 777 /usr/local/kubernetes/volumes/postgresql-data
cd ~/devops/k8s-postgresql-single
kubectl create -f postgresql-pv.yaml


POD=`kubectl get pods -l app=postgresql | grep Running | grep 1/1 | awk '{print $1}'`
kubectl exec -it $POD bash
psql -U postgres -h 127.0.0.1 -p 5432
create database confluence;

postgresql-client-service
confluence
postgres
bibi123.com

\encoding
update pg_database set encoding = pg_char_to_encoding('UTF8') where datname = 'your_database';
